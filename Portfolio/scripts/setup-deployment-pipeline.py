#!/usr/bin/env python3
"""
Create a Power BI deployment pipeline (Dev → Prod) and assign workspaces.

Uses client credentials (same env file as test-powerbi-api-readonly.py).

Optional env / env-file keys:
  PBI_PIPELINE_DISPLAY_NAME (default: Canon – Dev to Production)
  PBI_PIPELINE_DESCRIPTION   (optional)
  PBI_DEV_WORKSPACE_NAME     (default: Development Workspace)
  PBI_PROD_WORKSPACE_NAME    (default: Canon Analytics)

Stage mapping (standard 3-stage pipeline): Development=0, Test=1 (skipped), Production=2.

Usage:
  python3 setup-deployment-pipeline.py /path/to/powerbi-api-local.env

Do not commit real credentials.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request


def _load_dotenv_file(path: str) -> None:
    with open(path, encoding="utf-8") as handle:
        for raw in handle:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            key, sep, value = line.partition("=")
            if not sep:
                continue
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            os.environ.setdefault(key, value)


def _post_form(url: str, data: dict[str, str]) -> dict[str, object]:
    body = urllib.parse.urlencode(data).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        payload = response.read().decode("utf-8")
    return json.loads(payload)


def _access_token(tenant: str, client_id: str, client_secret: str) -> str:
    token_url = f"https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token"
    token_body = _post_form(
        token_url,
        {
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
            "scope": "https://analysis.windows.net/powerbi/api/.default",
        },
    )
    token = token_body.get("access_token")
    if not isinstance(token, str) or not token:
        raise RuntimeError(f"Unexpected token response: {token_body!r}")
    return token


def _request(
    method: str,
    url: str,
    bearer: str,
    *,
    body: dict[str, object] | None = None,
) -> tuple[int, object]:
    payload: bytes | None
    headers = {"Authorization": f"Bearer {bearer}"}
    if body is not None:
        payload = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    else:
        payload = None
    request = urllib.request.Request(url, data=payload, method=method, headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            raw = response.read().decode("utf-8")
            code = response.status
            if not raw:
                return code, {}
            return code, json.loads(raw)
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        try:
            parsed: object = json.loads(detail) if detail else {}
        except json.JSONDecodeError:
            parsed = {"_raw": detail}
        raise RuntimeError(f"HTTP {exc.code} for {method} {url}: {parsed}") from exc


def _find_workspace_id(groups: list[object], name: str) -> str | None:
    target = name.strip().casefold()
    for item in groups:
        if not isinstance(item, dict):
            continue
        wname = item.get("name")
        wid = item.get("id")
        if isinstance(wname, str) and isinstance(wid, str) and wname.strip().casefold() == target:
            return wid
    return None


def main() -> int:
    if len(sys.argv) != 2:
        print(
            "Usage: python3 setup-deployment-pipeline.py /path/to/powerbi-api-local.env",
            file=sys.stderr,
        )
        return 2

    _load_dotenv_file(sys.argv[1])

    tenant = os.environ.get("PBI_TENANT_ID", "").strip()
    client_id = os.environ.get("PBI_CLIENT_ID", "").strip()
    client_secret = os.environ.get("PBI_CLIENT_SECRET", "").strip()

    if not (tenant and client_id and client_secret):
        print("Missing PBI_TENANT_ID / PBI_CLIENT_ID / PBI_CLIENT_SECRET.", file=sys.stderr)
        return 2

    pipeline_name = os.environ.get(
        "PBI_PIPELINE_DISPLAY_NAME",
        "Canon – Dev to Production",
    ).strip()
    pipeline_desc = os.environ.get("PBI_PIPELINE_DESCRIPTION", "").strip()
    dev_name = os.environ.get("PBI_DEV_WORKSPACE_NAME", "Development Workspace").strip()
    prod_name = os.environ.get("PBI_PROD_WORKSPACE_NAME", "Canon Analytics").strip()

    try:
        bearer = _access_token(tenant, client_id, client_secret)
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        print("Token request failed:", exc.code, detail, file=sys.stderr)
        return 1
    except RuntimeError as exc:
        print(exc, file=sys.stderr)
        return 1

    base = "https://api.powerbi.com/v1.0/myorg"

    # --- Resolve workspace IDs (service principal must be member of each) ---
    try:
        _, groups_payload = _request("GET", f"{base}/groups", bearer)
    except RuntimeError as exc:
        print(f"List workspaces failed: {exc}", file=sys.stderr)
        return 1

    value = groups_payload.get("value") if isinstance(groups_payload, dict) else None
    if not isinstance(value, list):
        print(f"Unexpected /groups response: {groups_payload!r}", file=sys.stderr)
        return 1

    dev_id = _find_workspace_id(value, dev_name)
    prod_id = _find_workspace_id(value, prod_name)
    if not dev_id:
        print(
            f'Workspace not found or no access: "{dev_name}". '
            f"Add the app to this workspace and ensure the name matches.",
            file=sys.stderr,
        )
        print("Workspaces visible to this principal:", file=sys.stderr)
        for item in value:
            if isinstance(item, dict) and isinstance(item.get("name"), str):
                print(f"  - {item['name']}", file=sys.stderr)
        return 1
    if not prod_id:
        print(
            f'Workspace not found or no access: "{prod_name}". '
            f"Add the service principal to this workspace (Admin/Member).",
            file=sys.stderr,
        )
        print("Workspaces visible to this principal:", file=sys.stderr)
        for item in value:
            if isinstance(item, dict) and isinstance(item.get("name"), str):
                print(f"  - {item['name']}", file=sys.stderr)
        return 1

    print(f'Development workspace: "{dev_name}" → {dev_id}')
    print(f'Production workspace:  "{prod_name}" → {prod_id}')

    # --- Find or create pipeline ---
    try:
        _, pipelines_payload = _request("GET", f"{base}/pipelines", bearer)
    except RuntimeError as exc:
        print(f"List pipelines failed: {exc}", file=sys.stderr)
        print(
            "If you see 403, add Application permission **Pipeline.ReadWrite.All** "
            "(and grant admin consent) for Power BI Service on the app registration.",
            file=sys.stderr,
        )
        return 1

    plist = pipelines_payload.get("value") if isinstance(pipelines_payload, dict) else None
    if not isinstance(plist, list):
        print(f"Unexpected /pipelines response: {pipelines_payload!r}", file=sys.stderr)
        return 1

    pipeline_id: str | None = None
    for p in plist:
        if not isinstance(p, dict):
            continue
        dn = p.get("displayName")
        pid = p.get("id")
        if (
            isinstance(dn, str)
            and isinstance(pid, str)
            and dn.strip() == pipeline_name.strip()
        ):
            pipeline_id = pid
            print(f'Found existing pipeline: "{dn}" → {pid}')
            break

    if not pipeline_id:
        create_body: dict[str, object] = {"displayName": pipeline_name}
        if pipeline_desc:
            create_body["description"] = pipeline_desc
        try:
            code, created = _request("POST", f"{base}/pipelines", bearer, body=create_body)
        except RuntimeError as exc:
            print(f"Create pipeline failed: {exc}", file=sys.stderr)
            print(
                "Common fixes: Pipeline.ReadWrite.All + tenant setting "
                '"Service principals can create … deployment pipelines"; '
                "app must be allowed to create pipelines.",
                file=sys.stderr,
            )
            return 1
        if code not in (200, 201):
            print(f"Unexpected status {code}: {created!r}", file=sys.stderr)
            return 1
        if not isinstance(created, dict) or not isinstance(created.get("id"), str):
            print(f"Unexpected create response: {created!r}", file=sys.stderr)
            return 1
        pipeline_id = created["id"]
        print(f'Created pipeline "{pipeline_name}" → {pipeline_id}')

    assert pipeline_id is not None

    # --- Assign stages (0 = Development, 2 = Production) ---
    assignments = [
        (0, dev_id, dev_name),
        (2, prod_id, prod_name),
    ]

    for stage_order, workspace_id, label in assignments:
        assign_url = f"{base}/pipelines/{pipeline_id}/stages/{stage_order}/assignWorkspace"
        try:
            code, body = _request(
                "POST",
                assign_url,
                bearer,
                body={"workspaceId": workspace_id},
            )
        except RuntimeError as exc:
            print(f"Assign stage {stage_order} ({label}) failed: {exc}", file=sys.stderr)
            if "WorkspaceHasNoCapacity" in str(exc) or "Alm_InvalidRequest_WorkspaceHasNoCapacity" in str(exc):
                print(
                    "\nThis usually means the workspace is still on **shared (Pro) capacity**.\n"
                    "**Deployment pipelines need Premium Per User, Premium, or Fabric capacity**\n"
                    "on the workspace before it can join a pipeline.\n\n"
                    "In Power BI / Fabric: open the workspace → **Workspace settings** → **License / Premium** →\n"
                    "**Assign to capacity** (same capacity family as production, or a dedicated dev capacity).\n"
                    "Then run this script again.\n",
                    file=sys.stderr,
                )
            else:
                print(
                    "Often: principal must be **Admin** on both workspaces, workspace not already "
                    "linked to another pipeline, and **Workspace.ReadWrite.All** may be required "
                    "in addition to pipeline permissions.",
                    file=sys.stderr,
                )
            return 1
        if code not in (200, 201, 204):
            print(f"Unexpected assign status {stage_order}: {code} {body!r}", file=sys.stderr)
            return 1
        print(f"Assigned stage {stage_order} → workspace ({label}) OK")

    # --- Show pipeline with stages ---
    expand_url = f"{base}/pipelines/{pipeline_id}?$expand=stages"
    try:
        _, detail = _request("GET", expand_url, bearer)
    except RuntimeError as exc:
        print(f"Warning: could not reload pipeline detail: {exc}", file=sys.stderr)
        return 0

    print(json.dumps(detail, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
