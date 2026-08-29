#!/usr/bin/env python3
"""Mirror the six Fabric iteration PBIP definitions back to module homes.

The Fabric workspace owns the report/model content during Fabric-first review
cycles. This script reconciles that content back to the canonical module PBIP
trees while deliberately preserving environment-local identity files:

* module-root ``*.pbip`` entry files
* report/model ``.platform`` files (logical IDs differ by workspace)
* any local ``.pbi`` cache directory

Default mode is a dry run. Pass ``--apply`` to copy changed/new content and
delete stale destination content inside the mapped ``.Report`` and
``.SemanticModel`` folders.
"""

from __future__ import annotations

import argparse
import filecmp
import shutil
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[2]
FABRIC_ROOT = REPO_ROOT / "Fabric" / "DevelopmentWorkspace"

DESTINATIONS = {
    "Canon Financial Report": (
        REPO_ROOT / "Reports/Finance/Companies/CANON/Canon Financial Report"
    ),
    "Paper Financial Report": (
        REPO_ROOT / "Reports/Finance/Companies/PAPERENTITY/Paper Financial Report"
    ),
    "Canon Sales Report": (
        REPO_ROOT / "Reports/Sales/Companies/CANON/Canon Sales Report"
    ),
    "Canon Inventory Report": (
        REPO_ROOT / "Reports/Inventory/Companies/CANON/Canon Inventory Report"
    ),
    "Paper Inventory Report": (
        REPO_ROOT / "Reports/Inventory/Companies/PAPERENTITY/Paper Inventory Report"
    ),
    "Canon Service Report": (
        REPO_ROOT / "Reports/Service/Companies/CANON/Canon Service Report"
    ),
}

PRESERVE_NAMES = {".platform"}
PRESERVE_PARTS = {".pbi"}


def included_files(root: Path) -> dict[Path, Path]:
    files = {}
    for path in root.rglob("*"):
        relative = path.relative_to(root)
        if path.is_file() and path.name not in PRESERVE_NAMES and not (
            set(relative.parts) & PRESERVE_PARTS
        ):
            files[relative] = path
    return files


def sync_tree(source: Path, destination: Path, apply: bool) -> tuple[int, int, int]:
    source_files = included_files(source)
    destination_files = included_files(destination)

    added = sorted(source_files.keys() - destination_files.keys())
    deleted = sorted(destination_files.keys() - source_files.keys())
    changed = sorted(
        relative
        for relative in source_files.keys() & destination_files.keys()
        if not filecmp.cmp(
            source_files[relative], destination_files[relative], shallow=False
        )
    )

    if apply:
        for relative in added + changed:
            target = destination / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source_files[relative], target)
        for relative in deleted:
            (destination / relative).unlink()
        for directory in sorted(
            (path for path in destination.rglob("*") if path.is_dir()),
            key=lambda path: len(path.parts),
            reverse=True,
        ):
            if directory.name not in PRESERVE_PARTS:
                try:
                    directory.rmdir()
                except OSError:
                    pass

    return len(added), len(changed), len(deleted)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--apply",
        action="store_true",
        help="write the reconciliation; default is dry-run",
    )
    args = parser.parse_args()

    totals = [0, 0, 0]
    for report_name, module_root in DESTINATIONS.items():
        if not module_root.is_dir():
            raise FileNotFoundError(f"Missing module root: {module_root}")
        print(report_name)
        for suffix in ("Report", "SemanticModel"):
            source = FABRIC_ROOT / f"{report_name}.{suffix}"
            destination = module_root / f"{report_name}.{suffix}"
            if not source.is_dir() or not destination.is_dir():
                raise FileNotFoundError(
                    f"Missing mapped tree: {source} -> {destination}"
                )
            result = sync_tree(source, destination, args.apply)
            totals = [left + right for left, right in zip(totals, result)]
            print(
                f"  {suffix:<13} add={result[0]:>3} "
                f"change={result[1]:>3} delete={result[2]:>3}"
            )

    mode = "APPLIED" if args.apply else "DRY RUN"
    print(
        f"{mode}: add={totals[0]} change={totals[1]} delete={totals[2]} "
        "(.pbip/.platform/.pbi preserved)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
