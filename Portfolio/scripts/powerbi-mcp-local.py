#!/usr/bin/env python3
"""
Local MCP server (stdio) exposing read-only Power BI queries via service principal.

Built for OpenAI Secure MCP Tunnel -> ChatGPT. Bypasses the Entra/ChatGPT OAuth
PKCE-metadata incompatibility by not using interactive OAuth at all: queries run
under the tenant service principal (client credentials), same as
test-powerbi-api-readonly.py.

Usage (normally launched by tunnel-client, not by hand):
  python3 powerbi-mcp-local.py /path/to/powerbi-api-local.env
"""

from __future__ import annotations

import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

PROTOCOL_VERSION = "2025-06-18"

KNOWN_DATASETS = {
    "Paper Financial Report (live, Paper Analytics)": "96308a26-9381-4feb-886c-9c90afac6bf2",
    "Paper Inventory Report (live, Paper Analytics)": "017aa653-925e-4a5a-8437-26d939977641",
    "Canon Financial Report (dev workspace)": "b1e83d9b-1d75-4fdf-9fad-98318bf9147a",
    "Canon Sales Report (dev workspace)": "b5b3a510-fa4d-4e4d-b5bb-bdc12cef21b8",
    "Canon Inventory Report (dev workspace)": "d00adac5-83c9-4105-9dcf-bb9a6373bde3",
    "Canon Service Report (dev workspace)": "eef4b55c-fd94-45e0-8e83-d37bb38ccab7",
    "Paper Financial Report (dev workspace)": "cc7415d9-4d10-4b0a-acbb-6e2c9043bb2c",
    "Paper Inventory Report (dev workspace)": "b38eca52-b79c-43a9-b4b6-508c0a741b35",
}

_token_cache: dict[str, object] = {"token": None, "expires": 0.0}


def load_env(path: str) -> None:
    with open(path, encoding="utf-8") as handle:
        for raw in handle:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            key, sep, value = line.partition("=")
            if sep:
                os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


def get_token() -> str:
    if _token_cache["token"] and time.time() < float(_token_cache["expires"]) - 120:
        return str(_token_cache["token"])
    body = urllib.parse.urlencode(
        {
            "grant_type": "client_credentials",
            "client_id": os.environ["PBI_CLIENT_ID"],
            "client_secret": os.environ["PBI_CLIENT_SECRET"],
            "scope": "https://analysis.windows.net/powerbi/api/.default",
        }
    ).encode()
    request = urllib.request.Request(
        f"https://login.microsoftonline.com/{os.environ['PBI_TENANT_ID']}/oauth2/v2.0/token",
        data=body,
        method="POST",
        headers={"Content-Type": "application/x-www-form-urlencoded"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        payload = json.loads(response.read())
    _token_cache["token"] = payload["access_token"]
    _token_cache["expires"] = time.time() + int(payload.get("expires_in", 3600))
    return str(_token_cache["token"])


def pbi(method: str, url: str, body: dict | None = None) -> dict:
    data = json.dumps(body).encode() if body is not None else None
    request = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Authorization": f"Bearer {get_token()}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            return json.loads(response.read())
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")[:800]
        raise RuntimeError(f"Power BI API error {exc.code}: {detail}") from exc


def tool_list_workspaces() -> str:
    groups = pbi("GET", "https://api.powerbi.com/v1.0/myorg/groups")
    lines = []
    for group in groups.get("value", []):
        lines.append(f"- {group['name']} (workspace id: {group['id']})")
        datasets = pbi(
            "GET", f"https://api.powerbi.com/v1.0/myorg/groups/{group['id']}/datasets"
        )
        for dataset in datasets.get("value", []):
            lines.append(f"    - dataset: {dataset['name']} (id: {dataset['id']})")
    return "\n".join(lines) or "No workspaces visible."


def tool_execute_dax(dataset_id: str, dax_query: str) -> str:
    result = pbi(
        "POST",
        f"https://api.powerbi.com/v1.0/myorg/datasets/{dataset_id}/executeQueries",
        {
            "queries": [{"query": dax_query}],
            "serializerSettings": {"includeNulls": True},
        },
    )
    rows = result["results"][0]["tables"][0]["rows"]
    return json.dumps(rows[:500], ensure_ascii=False, default=str)


def tool_get_schema(dataset_id: str) -> str:
    parts = []
    for label, query in (
        ("TABLES", "EVALUATE SELECTCOLUMNS(INFO.VIEW.TABLES(), \"Table\", [Name], \"Description\", [Description])"),
        ("COLUMNS", "EVALUATE SELECTCOLUMNS(INFO.VIEW.COLUMNS(), \"Table\", [Table], \"Column\", [Name], \"Type\", [DataType])"),
        ("MEASURES", "EVALUATE SELECTCOLUMNS(INFO.VIEW.MEASURES(), \"Table\", [Table], \"Measure\", [Name], \"Expression\", [Expression])"),
    ):
        try:
            parts.append(f"== {label} ==\n{tool_execute_dax(dataset_id, query)}")
        except RuntimeError as exc:
            parts.append(f"== {label} == unavailable: {exc}")
    return "\n\n".join(parts)


TOOLS = [
    {
        "name": "list_workspaces_and_datasets",
        "description": (
            "List all Power BI workspaces and their semantic models (datasets) with IDs. "
            "Known datasets: "
            + "; ".join(f"{name}: {ds_id}" for name, ds_id in KNOWN_DATASETS.items())
        ),
        "inputSchema": {"type": "object", "properties": {}, "required": []},
    },
    {
        "name": "execute_dax",
        "description": (
            "Run a read-only DAX query (single EVALUATE statement) against a Power BI "
            "semantic model and return rows as JSON. Amounts are in Iraqi dinar (IQD). "
            "Use get_model_schema first if you don't know the tables/measures."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "dataset_id": {"type": "string", "description": "Semantic model GUID"},
                "dax_query": {"type": "string", "description": "DAX query with one EVALUATE statement"},
            },
            "required": ["dataset_id", "dax_query"],
        },
    },
    {
        "name": "get_model_schema",
        "description": "Return tables, columns, and measures (with DAX expressions) of a semantic model.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "dataset_id": {"type": "string", "description": "Semantic model GUID"},
            },
            "required": ["dataset_id"],
        },
    },
]


def handle(request: dict) -> dict | None:
    method = request.get("method")
    request_id = request.get("id")
    if method == "initialize":
        return {
            "jsonrpc": "2.0",
            "id": request_id,
            "result": {
                "protocolVersion": request.get("params", {}).get(
                    "protocolVersion", PROTOCOL_VERSION
                ),
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "powerbi-local", "version": "1.0.0"},
            },
        }
    if method in ("notifications/initialized", "notifications/cancelled"):
        return None
    if method == "ping":
        return {"jsonrpc": "2.0", "id": request_id, "result": {}}
    if method == "tools/list":
        return {"jsonrpc": "2.0", "id": request_id, "result": {"tools": TOOLS}}
    if method == "tools/call":
        params = request.get("params", {})
        name = params.get("name")
        args = params.get("arguments", {})
        try:
            if name == "list_workspaces_and_datasets":
                text = tool_list_workspaces()
            elif name == "execute_dax":
                text = tool_execute_dax(args["dataset_id"], args["dax_query"])
            elif name == "get_model_schema":
                text = tool_get_schema(args["dataset_id"])
            else:
                raise RuntimeError(f"Unknown tool: {name}")
            return {
                "jsonrpc": "2.0",
                "id": request_id,
                "result": {"content": [{"type": "text", "text": text}], "isError": False},
            }
        except Exception as exc:  # surfaced to the model as tool output
            return {
                "jsonrpc": "2.0",
                "id": request_id,
                "result": {
                    "content": [{"type": "text", "text": f"Error: {exc}"}],
                    "isError": True,
                },
            }
    if request_id is not None:
        return {
            "jsonrpc": "2.0",
            "id": request_id,
            "error": {"code": -32601, "message": f"Method not found: {method}"},
        }
    return None


def main() -> None:
    if len(sys.argv) == 2:
        load_env(sys.argv[1])
    missing = [
        key
        for key in ("PBI_TENANT_ID", "PBI_CLIENT_ID", "PBI_CLIENT_SECRET")
        if not os.environ.get(key)
    ]
    if missing:
        print(f"Missing env vars: {missing}", file=sys.stderr)
        raise SystemExit(2)
    for raw_line in sys.stdin:
        line = raw_line.strip()
        if not line:
            continue
        try:
            message = json.loads(line)
        except json.JSONDecodeError:
            continue
        response = handle(message)
        if response is not None:
            sys.stdout.write(json.dumps(response, ensure_ascii=False) + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    main()
