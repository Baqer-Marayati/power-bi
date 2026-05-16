#!/usr/bin/env python3
"""
Smoke-test SAP HANA (read-only credentials from hana-b1-readonly.env).
Does not print secrets. Exit 0 only if SELECT 1 FROM DUMMY succeeds.
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path


def load_env_file(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    text = path.read_text(encoding="utf-8")
    if text.startswith("\ufeff"):
        text = text[1:]
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        # Allow spaces around "=" (Terminal paste often introduces them)
        m = re.match(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$", line)
        if not m:
            continue
        k, v = m.group(1), m.group(2).strip().strip('"').strip("'")
        out[k] = v
    return out


def main() -> int:
    p = argparse.ArgumentParser()
    default_env = Path(__file__).resolve().parent / "hana-b1-readonly.env"
    p.add_argument("--env-file", type=Path, default=default_env)
    args = p.parse_args()

    if not args.env_file.is_file():
        print(f"Missing env file: {args.env_file}", file=sys.stderr)
        print("Copy hana-b1-readonly.env.example and fill secrets.", file=sys.stderr)
        return 2

    env = load_env_file(args.env_file)
    missing = [
        k
        for k in ("HANA_HOST", "HANA_PORT", "HANA_DATABASE", "HANA_USERNAME", "HANA_PASSWORD")
        if not env.get(k)
    ]
    if missing:
        print(f"Set these in env file (empty values): {', '.join(missing)}", file=sys.stderr)
        return 2

    try:
        from hdbcli import dbapi
    except ImportError:
        print(
            "hdbcli is not installed. Run: pip install hdbcli",
            file=sys.stderr,
        )
        return 3

    port = int(env["HANA_PORT"])
    connect_kwargs = {
        "address": env["HANA_HOST"],
        "port": port,
        "user": env["HANA_USERNAME"],
        "password": env["HANA_PASSWORD"],
        "databaseName": env["HANA_DATABASE"],
    }

    encrypt = env.get("HANA_ENCRYPT", "").lower() in ("1", "true", "yes")
    if encrypt:
        connect_kwargs["encrypt"] = "true"
        if env.get("HANA_SSL_VALIDATE_CERTIFICATE", "").lower() == "false":
            connect_kwargs["sslValidateCertificate"] = "false"

    try:
        conn = dbapi.connect(**connect_kwargs)
    except Exception as e:
        print(f"HANA connect failed: {type(e).__name__}: {e}", file=sys.stderr)
        return 4

    try:
        cur = conn.cursor()
        cur.execute("SELECT 1 AS ok FROM DUMMY")
        row = cur.fetchone()
        if row and row[0] == 1:
            schema = env.get("HANA_SCHEMA") or os.environ.get("HANA_SCHEMA")
            msg = "HANA OK: SELECT 1 FROM DUMMY"
            if schema:
                msg += f"; schema configured: {schema}"
            print(msg)
            return 0
        print("Unexpected SELECT 1 result", file=sys.stderr)
        return 5
    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())
