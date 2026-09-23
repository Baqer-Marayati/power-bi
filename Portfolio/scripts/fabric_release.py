#!/usr/bin/env python3
"""Promote reviewed reports from the Development Workspace to the live workspaces.

The repository keeps two copies of every published report:

* ``Fabric/DevelopmentWorkspace/`` - Git-connected to the Fabric Development
  Workspace. Every report edit happens here.
* ``Fabric/CanonAnalytics/`` and ``Fabric/PaperAnalytics/`` - what is live in
  those workspaces. Only this script writes them.

Commands (all read-only unless ``--apply`` is given):

  status                          Pending changes, Development Workspace sync,
                                  live drift, gateway and schedule for every report.
  publish "<Report Name>"         Plan a publish; add --apply to run it.
  rollback "<Report Name>" --to <commit>
                                  Republish the live mirror as it was at <commit>.

Publishing updates the existing live model and report in place, so links,
viewers and permissions are unchanged. A report that is not live yet needs
``--create``. IDs live in ``Fabric/workspaces.json``; every publish is logged in
``Fabric/RELEASES.md``. Credentials come from the gitignored
``Portfolio/scripts/powerbi-api-local.env`` (service principal).
"""

from __future__ import annotations

import argparse
import base64
import datetime as dt
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FABRIC = ROOT / "Fabric"
MANIFEST = FABRIC / "workspaces.json"
RELEASES = FABRIC / "RELEASES.md"
BACKUPS = FABRIC / ".release-backups"
ENV_FILE = ROOT / "Portfolio/scripts/powerbi-api-local.env"
AUDIT = ROOT / "Portfolio/scripts/audit-report-consistency.py"

FABRIC_API = "https://api.fabric.microsoft.com/v1"
PBI_API = "https://api.powerbi.com/v1.0/myorg"
FABRIC_SCOPE = "https://api.fabric.microsoft.com/.default"
PBI_SCOPE = "https://analysis.windows.net/powerbi/api/.default"

# Service-generated TMDL annotations that Desktop and the service add or reorder on their own.
TMDL_NOISE = re.compile(r"^\s*annotation (UnderlyingDateTimeDataType|PBI_QueryOrder)\b")


class ReleaseError(Exception):
    pass


# --------------------------------------------------------------------------- files


def is_local_only(rel: str) -> bool:
    parts = rel.split("/")
    return ".pbi" in parts or parts[-1] == ".platform"


def load_tree(folder: Path) -> dict[str, bytes]:
    if not folder.is_dir():
        return {}
    files = {}
    for path in sorted(folder.rglob("*")):
        rel = path.relative_to(folder).as_posix()
        if path.is_file() and not is_local_only(rel) and path.name != ".DS_Store":
            files[rel] = path.read_bytes()
    return files


def model_parts(tree: dict[str, bytes]) -> dict[str, bytes]:
    return {p: b for p, b in tree.items() if p != "diagramLayout.json"}


def report_parts(tree: dict[str, bytes], model_id: str) -> dict[str, bytes]:
    parts = dict(tree)
    pbir = json.loads(parts["definition.pbir"])
    pbir["datasetReference"] = {"byConnection": {"connectionString": f"semanticmodelid={model_id}"}}
    parts["definition.pbir"] = json.dumps(pbir, indent=2).encode()
    return parts


def ignored_in_compare(rel: str) -> bool:
    return (
        is_local_only(rel)
        or rel in ("definition.pbir", "diagramLayout.json")
        or rel.startswith("definition/cultures/")
        or rel.startswith("StaticResources/SharedResources/BaseThemes/")
    )


def tmdl_shape(data: bytes):
    """TMDL as an order-insensitive tree.

    Desktop and the service reorder objects and re-wrap expressions, so siblings are
    sorted and expression lines (two or more tabs deeper than their object) are joined
    onto the object line.
    """
    root = {"text": "", "indent": -1, "children": [], "expr": []}
    stack = [root]
    for raw in data.decode("utf-8", "replace").replace("\r\n", "\n").split("\n"):
        line = raw.rstrip()
        if not line.strip() or TMDL_NOISE.match(line):
            continue
        indent = len(line) - len(line.lstrip("\t"))
        while stack[-1]["indent"] >= indent:
            stack.pop()
        parent = stack[-1]
        if parent is not root and indent >= parent["indent"] + 2:
            parent["expr"].append(line.strip())
            continue
        node = {"text": line.strip(), "indent": indent, "children": [], "expr": []}
        parent["children"].append(node)
        stack.append(node)

    def freeze(node):
        text = re.sub(r"\s+", " ", " ".join([node["text"], *node["expr"]]).strip())
        return text, tuple(sorted(freeze(child) for child in node["children"]))

    return freeze(root)


def normalized(rel: str, data: bytes):
    if rel.endswith(".json") or rel.endswith(".pbir") or rel.endswith(".pbism"):
        try:
            return json.loads(data)
        except ValueError:
            pass
    if rel.endswith(".tmdl"):
        return tmdl_shape(data)
    return data


def content_diff(a: dict[str, bytes], b: dict[str, bytes]) -> list[str]:
    """Paths whose content differs, ignoring formatting and service-generated metadata."""
    paths = {p for p in set(a) | set(b) if not ignored_in_compare(p)}
    diff = []
    for rel in sorted(paths):
        if rel not in a or rel not in b:
            diff.append(rel)
        elif a[rel] != b[rel] and normalized(rel, a[rel]) != normalized(rel, b[rel]):
            diff.append(rel)
    return diff


def exact_diff(a: dict[str, bytes], b: dict[str, bytes]) -> list[str]:
    return sorted(p for p in set(a) | set(b) if a.get(p) != b.get(p))


def mirror_tree(source: Path, destination: Path) -> None:
    """Make destination match source, skipping local-only files."""
    wanted = load_tree(source)
    destination.mkdir(parents=True, exist_ok=True)
    for rel in load_tree(destination):
        if rel not in wanted:
            (destination / rel).unlink()
    for rel, data in wanted.items():
        target = destination / rel
        if not target.exists() or target.read_bytes() != data:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
    for directory in sorted((d for d in destination.rglob("*") if d.is_dir()), key=lambda d: -len(d.parts)):
        if ".pbi" not in directory.parts:
            try:
                directory.rmdir()
            except OSError:
                pass


# --------------------------------------------------------------------------- git


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=ROOT, check=True, capture_output=True, text=True).stdout.strip()


def require_clean_and_pushed() -> str:
    dirty = git("status", "--porcelain", "--", "Fabric")
    if dirty:
        raise ReleaseError(f"Fabric/ has uncommitted changes. Commit and push first:\n{dirty}")
    git("fetch", "-q", "origin", "main")
    head, remote = git("rev-parse", "HEAD"), git("rev-parse", "origin/main")
    if head != remote:
        raise ReleaseError(
            f"Local HEAD {head[:8]} is not origin/main {remote[:8]}. Push (or pull) so the "
            "Development Workspace can sync the same commit you are publishing."
        )
    return head


# --------------------------------------------------------------------------- API


class Api:
    def __init__(self) -> None:
        if not ENV_FILE.exists():
            raise ReleaseError(f"Missing credentials file {ENV_FILE}")
        for raw in ENV_FILE.read_text().splitlines():
            line = raw.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))
        self._tokens: dict[str, tuple[str, float]] = {}

    def token(self, scope: str) -> str:
        cached = self._tokens.get(scope)
        if cached and cached[1] > time.time() + 300:
            return cached[0]
        body = urllib.parse.urlencode({
            "grant_type": "client_credentials",
            "client_id": os.environ["PBI_CLIENT_ID"],
            "client_secret": os.environ["PBI_CLIENT_SECRET"],
            "scope": scope,
        }).encode()
        url = f"https://login.microsoftonline.com/{os.environ['PBI_TENANT_ID']}/oauth2/v2.0/token"
        status, _, payload = self._send("POST", url, body, {"Content-Type": "application/x-www-form-urlencoded"})
        if status != 200:
            raise ReleaseError(f"Token request failed ({status}): {payload}")
        self._tokens[scope] = (payload["access_token"], time.time() + int(payload.get("expires_in", 3600)))
        return payload["access_token"]

    @staticmethod
    def _send(method, url, data, headers, retries=6):
        last = None
        for attempt in range(retries):
            request = urllib.request.Request(url, data=data, method=method, headers=headers)
            try:
                with urllib.request.urlopen(request, timeout=180) as response:
                    raw = response.read().decode()
                    return response.status, {k.lower(): v for k, v in response.headers.items()}, (json.loads(raw) if raw else {})
            except urllib.error.HTTPError as error:
                raw = error.read().decode()
                if error.code == 429 and attempt < retries - 1:
                    time.sleep(int(error.headers.get("Retry-After") or 10))
                    continue
                try:
                    payload = json.loads(raw)
                except ValueError:
                    payload = raw[:2000]
                return error.code, {k.lower(): v for k, v in error.headers.items()}, payload
            except urllib.error.URLError as error:
                last = error
                time.sleep(3 * (attempt + 1))
        raise ReleaseError(f"Network failure calling {url}: {last}")

    def call(self, method, url, body=None, retries=6):
        scope = FABRIC_SCOPE if url.startswith(FABRIC_API) else PBI_SCOPE
        headers = {"Authorization": f"Bearer {self.token(scope)}"}
        data = None
        if body is not None:
            data = json.dumps(body).encode()
            headers["Content-Type"] = "application/json"
        return self._send(method, url, data, headers, retries)

    def wait(self, headers, label):
        location = headers.get("location")
        if not location:
            raise ReleaseError(f"{label}: accepted without an operation location")
        for _ in range(180):
            time.sleep(int(headers.get("retry-after") or 3))
            status, headers, payload = self.call("GET", location)
            state = payload.get("status") if isinstance(payload, dict) else None
            if state == "Succeeded":
                status, _, result = self.call("GET", location.rstrip("/") + "/result")
                return result if status < 400 else payload
            if state == "Failed":
                raise ReleaseError(f"{label} failed: {json.dumps(payload)[:1500]}")
        raise ReleaseError(f"{label} timed out")

    def get_definition(self, workspace, kind, item, fmt) -> dict[str, bytes]:
        status, headers, payload = self.call("POST", f"{FABRIC_API}/workspaces/{workspace}/{kind}/{item}/getDefinition?format={fmt}", {})
        if status == 202:
            payload = self.wait(headers, f"read {kind} definition")
        elif status >= 400:
            raise ReleaseError(f"Could not read {kind} {item}: {status} {payload}")
        return {p["path"]: base64.b64decode(p["payload"]) for p in payload["definition"]["parts"]}

    def update_definition(self, workspace, kind, item, fmt, parts: dict[str, bytes]) -> None:
        body = {"definition": {"format": fmt, "parts": encode(parts)}}
        status, headers, payload = self.call("POST", f"{FABRIC_API}/workspaces/{workspace}/{kind}/{item}/updateDefinition", body)
        if status == 202:
            self.wait(headers, f"update {kind}")
        elif status >= 400:
            raise ReleaseError(f"Update {kind} {item} failed: {status} {json.dumps(payload)[:1500]}")

    def create_item(self, workspace, kind, name, fmt, parts: dict[str, bytes]) -> str:
        body = {"displayName": name, "definition": {"format": fmt, "parts": encode(parts)}}
        try:
            status, headers, payload = self.call("POST", f"{FABRIC_API}/workspaces/{workspace}/{kind}", body, retries=1)
        except ReleaseError:
            status, headers, payload = 0, {}, {}
        if status in (200, 201):
            return payload["id"]
        if status == 202:
            try:
                result = self.wait(headers, f"create {kind}")
                if isinstance(result, dict) and result.get("id"):
                    return result["id"]
            except ReleaseError:
                pass
        elif status:
            raise ReleaseError(f"Create {kind} failed: {status} {json.dumps(payload)[:1500]}")
        for _ in range(30):
            found = self.find_item(workspace, kind, name)
            if found:
                return found
            time.sleep(5)
        raise ReleaseError(f"Create {kind} '{name}' did not confirm; check the workspace before retrying")

    def find_item(self, workspace, kind, name):
        _, _, payload = self.call("GET", f"{FABRIC_API}/workspaces/{workspace}/{kind}")
        for item in payload.get("value") or []:
            if item.get("displayName") == name:
                return item["id"]
        return None

    def connections(self, workspace, model):
        status, _, payload = self.call("GET", f"{FABRIC_API}/workspaces/{workspace}/items/{model}/connections")
        if status >= 400:
            raise ReleaseError(f"Could not read connections for {model}: {payload}")
        return payload.get("value") or []

    def bind(self, workspace, model, gateway) -> None:
        for ref in self.connections(workspace, model) or [{"connectionDetails": {"type": gateway["type"], "path": gateway["path"]}}]:
            details = ref.get("connectionDetails") or {}
            body = {"connectionBinding": {
                "id": gateway["id"],
                "connectivityType": "OnPremisesGateway",
                "connectionDetails": {"type": details.get("type"), "path": details.get("path")},
            }}
            status, _, payload = self.call("POST", f"{FABRIC_API}/workspaces/{workspace}/semanticModels/{model}/bindConnection", body)
            if status >= 400:
                raise ReleaseError(f"Binding to {gateway['name']} failed: {json.dumps(payload)[:800]}")

    def refresh(self, workspace, model) -> dict:
        started = dt.datetime.now(dt.timezone.utc) - dt.timedelta(minutes=1)
        status, _, payload = self.call("POST", f"{PBI_API}/groups/{workspace}/datasets/{model}/refreshes", {"notifyOption": "NoNotification"}, retries=2)
        if status >= 400:
            raise ReleaseError(f"Refresh request failed: {status} {payload}")
        for _ in range(240):
            time.sleep(15)
            _, _, payload = self.call("GET", f"{PBI_API}/groups/{workspace}/datasets/{model}/refreshes?$top=1")
            runs = payload.get("value") or []
            if not runs:
                continue
            run = runs[0]
            start = dt.datetime.fromisoformat(run["startTime"].replace("Z", "+00:00"))
            if start < started:
                continue
            if run.get("status") in ("Completed", "Failed", "Disabled", "Cancelled"):
                return run
        raise ReleaseError("Refresh did not finish within 60 minutes")

    def query(self, workspace, model, dax):
        body = {"queries": [{"query": dax}], "serializerSettings": {"includeNulls": True}}
        status, _, payload = self.call("POST", f"{PBI_API}/groups/{workspace}/datasets/{model}/executeQueries", body)
        if status >= 400:
            raise ReleaseError(f"Smoke query failed: {status} {payload}")
        return payload["results"][0]["tables"][0]["rows"]

    def schedule(self, workspace, model):
        status, _, payload = self.call("GET", f"{PBI_API}/groups/{workspace}/datasets/{model}/refreshSchedule")
        return payload if status == 200 else {}


def encode(parts: dict[str, bytes]) -> list[dict]:
    return [{"path": p, "payload": base64.b64encode(b).decode(), "payloadType": "InlineBase64"} for p, b in sorted(parts.items())]


# --------------------------------------------------------------------------- manifest


def load_manifest() -> dict:
    return json.loads(MANIFEST.read_text())


def save_manifest(manifest: dict) -> None:
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n")


class Report:
    def __init__(self, manifest: dict, name: str) -> None:
        if name not in manifest["reports"]:
            known = ", ".join(manifest["reports"])
            raise ReleaseError(f"Unknown report '{name}'. Known: {known}")
        self.name = name
        self.entry = manifest["reports"][name]
        self.dev = manifest["development"]
        self.live = manifest["live"][self.entry["live"]]
        self.gateway = manifest["gatewayConnection"]

    @property
    def dev_root(self) -> Path:
        return ROOT / self.dev["folder"]

    @property
    def live_root(self) -> Path:
        return ROOT / self.live["folder"]

    def trees(self, root: Path) -> tuple[dict, dict]:
        return load_tree(root / f"{self.name}.Report"), load_tree(root / f"{self.name}.SemanticModel")

    def is_live(self) -> bool:
        return bool(self.entry.get("liveReportId") and self.entry.get("liveModelId"))


# --------------------------------------------------------------------------- checks


def gateway_ok(api: Api, report: Report) -> tuple[bool, str]:
    refs = api.connections(report.live["id"], report.entry["liveModelId"])
    names = ", ".join(f"{r.get('displayName') or r.get('connectivityType')}" for r in refs) or "none"
    return bool(refs) and all(r.get("id") == report.gateway["id"] for r in refs), names


def dev_workspace_diff(api: Api, report: Report, dev_report: dict, dev_model: dict) -> list[str]:
    live_report = api.get_definition(report.dev["id"], "reports", report.entry["devReportId"], "PBIR")
    live_model = api.get_definition(report.dev["id"], "semanticModels", report.entry["devModelId"], "TMDL")
    return [f"report/{p}" for p in content_diff(dev_report, live_report)] + [f"model/{p}" for p in content_diff(dev_model, live_model)]


def live_snapshot(api: Api, report: Report) -> tuple[dict, dict]:
    return (
        api.get_definition(report.live["id"], "reports", report.entry["liveReportId"], "PBIR"),
        api.get_definition(report.live["id"], "semanticModels", report.entry["liveModelId"], "TMDL"),
    )


def run_audit(report_folder: Path) -> None:
    result = subprocess.run([sys.executable, str(AUDIT), "--strict", str(report_folder)], cwd=ROOT, capture_output=True, text=True)
    if result.returncode != 0:
        tail = "\n".join((result.stdout + result.stderr).strip().splitlines()[-25:])
        raise ReleaseError(f"Strict consistency audit failed for {report_folder.name}:\n{tail}")


def say(message: str = "") -> None:
    print(message, flush=True)


# --------------------------------------------------------------------------- commands


def report_status(api: Api, report: Report) -> tuple[list[str], int]:
    lines, problems = [f"=== {report.name} -> {report.live['name']}"], 0
    dev_report, dev_model = report.trees(report.dev_root)
    mirror_report, mirror_model = report.trees(report.live_root)
    pending_r, pending_m = exact_diff(dev_report, mirror_report), exact_diff(dev_model, mirror_model)
    lines.append(f"  waiting to go live: {len(pending_r)} report file(s), {len(pending_m)} model file(s)")
    try:
        behind = dev_workspace_diff(api, report, dev_report, dev_model)
        lines.append("  Development Workspace: in sync with repo" if not behind else
                     f"  Development Workspace: {len(behind)} file(s) differ from repo (Sync in Fabric) {behind[:4]}")
    except ReleaseError as error:
        lines.append(f"  Development Workspace: could not read ({error})")
        problems += 1
    if not report.is_live():
        lines.append("  live: not published yet")
        return lines, problems
    live_report, live_model = live_snapshot(api, report)
    drift = [f"report/{p}" for p in content_diff(mirror_report, live_report)] + [f"model/{p}" for p in content_diff(mirror_model, live_model)]
    if drift:
        problems += 1
        lines.append(f"  live drift: {len(drift)} file(s) differ from {report.live['folder']} {drift[:6]}")
    else:
        lines.append(f"  live: matches {report.live['folder']}")
    ok, found = gateway_ok(api, report)
    problems += 0 if ok else 1
    lines.append(f"  gateway: {'OK' if ok else 'WRONG'} ({found})")
    sched = api.schedule(report.live["id"], report.entry["liveModelId"])
    lines.append(f"  scheduled refresh: {'on' if sched.get('enabled') else 'OFF'} {sched.get('times') or ''} {sched.get('localTimeZoneId') or ''}")
    return lines, problems


def cmd_status(args) -> int:
    manifest = load_manifest()
    api = Api()
    api.token(FABRIC_SCOPE)
    api.token(PBI_SCOPE)
    reports = [Report(manifest, name) for name in ([args.report] if args.report else manifest["reports"])]
    problems = 0
    with ThreadPoolExecutor(max_workers=len(reports)) as pool:
        futures = [pool.submit(report_status, api, report) for report in reports]
        for report, future in zip(reports, futures):
            try:
                lines, count = future.result()
            except ReleaseError as error:
                lines, count = [f"=== {report.name}", f"  could not check: {error}"], 1
            for line in lines:
                say(line)
            problems += count
    say("All reports healthy." if not problems else f"{problems} problem(s) found.")
    return 1 if problems else 0


def publish(api: Api, report: Report, source_root: Path, args, label: str, commit: str) -> int:
    src_report, src_model = report.trees(source_root)
    if not src_report or not src_model:
        raise ReleaseError(f"{source_root} does not contain {report.name}.Report and .SemanticModel")
    mirror_report, mirror_model = report.trees(report.live_root)
    create = not report.is_live()
    if create and not args.create:
        raise ReleaseError(f"{report.name} is not live in {report.live['name']} yet. Re-run with --create.")

    say(f"Publish {report.name} -> {report.live['name']} ({label}, commit {commit[:8]})")
    say("Preflight")
    run_audit(source_root / f"{report.name}.Report")
    say("  strict audit: OK")

    report_changes = exact_diff(src_report, mirror_report)
    model_changes = exact_diff(src_model, mirror_model)
    say(f"  changes vs live mirror: {len(report_changes)} report file(s), {len(model_changes)} model file(s)")
    for rel in (report_changes + model_changes)[:15]:
        say(f"    {rel}")

    if label == "publish":
        behind = dev_workspace_diff(api, report, src_report, src_model)
        if behind and not args.allow_dev_mismatch:
            raise ReleaseError(
                "The Development Workspace does not match this commit, so what you reviewed is not what "
                f"would go live. Sync in Fabric, review, then retry. Differences: {behind[:8]}"
            )
        say("  Development Workspace: matches this commit" if not behind else "  Development Workspace: MISMATCH (allowed)")

    before = None
    if not create:
        before = live_snapshot(api, report)
        drift = [f"report/{p}" for p in content_diff(mirror_report, before[0])] + [f"model/{p}" for p in content_diff(mirror_model, before[1])]
        if drift and not args.allow_drift:
            raise ReleaseError(
                f"{report.live['name']} was changed outside this workflow ({len(drift)} file(s): {drift[:8]}). "
                "Find out who changed it before overwriting, or re-run with --allow-drift."
            )
        say("  live matches mirror: yes" if not drift else f"  live drift: {len(drift)} file(s) (allowed)")
        ok, found = gateway_ok(api, report)
        if not ok:
            raise ReleaseError(f"Live model is not on {report.gateway['name']} (found: {found}). Fix the gateway first.")
        say(f"  gateway: {report.gateway['name']}")

    push_model = create or bool(model_changes) or args.force
    push_report = create or bool(report_changes) or args.force
    refresh = args.refresh == "always" or (args.refresh == "auto" and push_model)
    if not push_model and not push_report:
        say("Nothing to publish: the live mirror already matches.")
        return 0
    say(f"Plan: {'create' if create else 'update'} model={'yes' if push_model else 'no'} report={'yes' if push_report else 'no'} refresh={'yes' if refresh else 'no'}")
    if not args.apply:
        say("Dry run only. Add --apply to publish.")
        return 0

    stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
    if before:
        backup = BACKUPS / f"{stamp} {report.name}"
        backup.mkdir(parents=True, exist_ok=True)
        for kind, parts in (("report", before[0]), ("model", before[1])):
            (backup / f"{kind}.json").write_text(json.dumps(encode(parts)))
        say(f"Backed up current live definitions to {backup.relative_to(ROOT)}")

    workspace = report.live["id"]
    if create:
        say("Creating model")
        model_id = api.create_item(workspace, "semanticModels", report.name, "TMDL", model_parts(src_model))
        report.entry["liveModelId"] = model_id
        time.sleep(10)
        api.bind(workspace, model_id, report.gateway)
    elif push_model:
        say("Updating model")
        api.update_definition(workspace, "semanticModels", report.entry["liveModelId"], "TMDL", model_parts(src_model))
    model_id = report.entry["liveModelId"]

    for _ in range(12):
        ok, found = gateway_ok(api, report)
        if ok:
            break
        time.sleep(5)
    if not ok:
        try:
            api.bind(workspace, model_id, report.gateway)
            ok, found = gateway_ok(api, report)
        except ReleaseError as error:
            found = f"{found}; {error}"
    if not ok:
        raise ReleaseError(
            f"Model is not on {report.gateway['name']} after publish ({found}). In Power BI open the model's "
            "settings > Gateway and cloud connections and map it to B1HANA, then run status."
        )
    say(f"Gateway: {report.gateway['name']}")

    if create:
        say("Creating report")
        report.entry["liveReportId"] = api.create_item(workspace, "reports", report.name, "PBIR", report_parts(src_report, model_id))
        manifest = load_manifest()
        manifest["reports"][report.name].update(liveModelId=model_id, liveReportId=report.entry["liveReportId"])
        save_manifest(manifest)
    elif push_report:
        say("Updating report")
        api.update_definition(workspace, "reports", report.entry["liveReportId"], "PBIR", report_parts(src_report, model_id))

    refresh_result = "not needed"
    if refresh:
        say("Refreshing model")
        run = api.refresh(workspace, model_id)
        refresh_result = run.get("status")
        if refresh_result != "Completed":
            raise ReleaseError(f"Refresh {refresh_result}: {(run.get('serviceExceptionJson') or '')[:1500]}. "
                               f"Definitions were published; roll back with: rollback \"{report.name}\" --to {git('rev-parse', 'HEAD')[:8]}")
        say("  refresh: Completed")

    rows = api.query(workspace, model_id, report.entry["smokeQuery"])
    value = next(iter(rows[0].values())) if rows else None
    if not value:
        raise ReleaseError(f"Smoke query returned no data: {rows}")
    say(f"Smoke check: {report.entry['smokeQuery']} -> {value}")

    after_report, after_model = live_snapshot(api, report)
    remaining = [f"report/{p}" for p in content_diff(src_report, after_report)] + [f"model/{p}" for p in content_diff(src_model, after_model)]
    if remaining:
        raise ReleaseError(f"Live content still differs after publish: {remaining[:8]}")
    say("Verified: live content matches what was published")

    for suffix in ("Report", "SemanticModel"):
        mirror_tree(source_root / f"{report.name}.{suffix}", report.live_root / f"{report.name}.{suffix}")
    pbip = source_root / f"{report.name}.pbip"
    if pbip.exists():
        shutil.copyfile(pbip, report.live_root / pbip.name)

    sched = api.schedule(workspace, model_id)
    schedule_note = "on" if sched.get("enabled") else "off"
    what = ", ".join(x for x, flag in (("model", push_model), ("report", push_report)) if flag)
    line = (f"| {dt.datetime.now().strftime('%Y-%m-%d %H:%M')} | {report.name} | {report.live['name']} | "
            f"{label} | `{commit[:8]}` | {what} | {refresh_result} | {value} | {schedule_note} |\n")
    with RELEASES.open("a") as handle:
        handle.write(line)

    say(f"Mirror updated: {report.live['folder']}/{report.name}.*")
    if schedule_note == "off":
        say("Note: scheduled refresh is OFF on this model.")
    say("Next: commit the mirror and RELEASES.md, then push:")
    say(f"  git add Fabric && git commit -m \"Release {report.name} to {report.live['name']}\" && git push")
    return 0


def cmd_publish(args) -> int:
    commit = require_clean_and_pushed()
    report = Report(load_manifest(), args.report)
    return publish(Api(), report, report.dev_root, args, "publish", commit)


def cmd_rollback(args) -> int:
    require_clean_and_pushed()
    report = Report(load_manifest(), args.report)
    commit = git("rev-parse", args.to)
    folder = report.live["folder"]
    with tempfile.TemporaryDirectory() as tmp:
        archive = subprocess.run(["git", "archive", commit, "--", folder], cwd=ROOT, check=True, capture_output=True).stdout
        subprocess.run(["tar", "-x", "-C", tmp], input=archive, check=True)
        source = Path(tmp) / folder
        return publish(Api(), report, source, args, f"rollback to {commit[:8]}", commit)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)

    status = sub.add_parser("status", help="read-only health of every report")
    status.add_argument("report", nargs="?")

    for name in ("publish", "rollback"):
        cmd = sub.add_parser(name)
        cmd.add_argument("report")
        cmd.add_argument("--apply", action="store_true", help="actually publish (default is a dry run)")
        cmd.add_argument("--refresh", choices=("auto", "always", "never"), default="auto",
                         help="auto refreshes only when the model changed")
        cmd.add_argument("--force", action="store_true", help="push model and report even if unchanged")
        cmd.add_argument("--allow-drift", action="store_true", help="overwrite live changes made outside this workflow")
        cmd.add_argument("--create", action="store_true", help="create the report if it is not live yet")
        if name == "publish":
            cmd.add_argument("--allow-dev-mismatch", action="store_true",
                             help="publish even if the Development Workspace is not synced to this commit")
        else:
            cmd.add_argument("--to", required=True, help="commit whose live mirror should be republished")

    args = parser.parse_args()
    try:
        return {"status": cmd_status, "publish": cmd_publish, "rollback": cmd_rollback}[args.command](args)
    except ReleaseError as error:
        print(f"STOPPED: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
