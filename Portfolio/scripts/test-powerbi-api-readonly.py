#!/usr/bin/env python3
"""
Read-only smoke test for Power BI REST API (client credentials).

Safe operation: GET /groups — lists workspaces; does not modify tenant data.

Usage:
  export PBI_TENANT_ID="..." PBI_CLIENT_ID="..." PBI_CLIENT_SECRET="..."
  python3 test-powerbi-api-readonly.py

  # or (loads KEY=VAL into os.environ; file must stay local + gitignored):
  python3 test-powerbi-api-readonly.py /path/to/powerbi-api-local.env

Do not commit real credentials. Never paste client secrets into chat logs.
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


def _get_json(url: str, bearer: str) -> dict[str, object]:
    request = urllib.request.Request(
        url,
        method="GET",
        headers={"Authorization": f"Bearer {bearer}"},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        payload = response.read().decode("utf-8")
    return json.loads(payload)


def main() -> int:
    if len(sys.argv) == 2:
        _load_dotenv_file(sys.argv[1])

    tenant = os.environ.get("PBI_TENANT_ID", "").strip()
    client_id = os.environ.get("PBI_CLIENT_ID", "").strip()
    client_secret = os.environ.get("PBI_CLIENT_SECRET", "").strip()

    if not (tenant and client_id and client_secret):
        print(
            "Missing PBI_TENANT_ID / PBI_CLIENT_ID / PBI_CLIENT_SECRET.\n"
            "Set them in the environment or pass a local env file path.\n"
            "See powerbi-api-local.env.example in this folder.",
            file=sys.stderr,
        )
        return 2

    token_url = f"https://login.microsoftonline.com/{tenant}/oauth2/v2.0/token"
    try:
        token_body = _post_form(
            token_url,
            {
                "grant_type": "client_credentials",
                "client_id": client_id,
                "client_secret": client_secret,
                "scope": "https://analysis.windows.net/powerbi/api/.default",
            },
        )
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        print("Token request failed:", exc.code, detail, file=sys.stderr)
        return 1

    access_token = token_body.get("access_token")
    if not isinstance(access_token, str) or not access_token:
        print("Unexpected token response:", token_body, file=sys.stderr)
        return 1

    groups_url = "https://api.powerbi.com/v1.0/myorg/groups"
    try:
        groups = _get_json(groups_url, access_token)
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        print("Power BI API request failed:", exc.code, detail, file=sys.stderr)
        return 1

    value = groups.get("value")
    if not isinstance(value, list):
        print(json.dumps(groups, indent=2))
        return 0

    print(f"OK — read-only call succeeded. Workspace count: {len(value)}")
    for item in value[:25]:
        if not isinstance(item, dict):
            continue
        wid = item.get("id", "")
        name = item.get("name", "")
        print(f"- {name} ({wid})")
    if len(value) > 25:
        print(f"... and {len(value) - 25} more (truncated)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
