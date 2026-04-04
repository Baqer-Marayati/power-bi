#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path
from typing import Dict, List


REQUIRED_COLUMNS: Dict[str, List[str]] = {
    "bp_master": ["company_code", "bp_id", "bp_type", "bp_group", "payment_terms", "active_flag"],
    "item_master": ["company_code", "item_id", "item_group", "uom", "active_flag"],
    "ar_open_items": ["company_code", "doc_no", "bp_id", "posting_date", "due_date", "open_amount_lc", "days_overdue"],
    "ap_open_items": ["company_code", "doc_no", "bp_id", "posting_date", "due_date", "open_amount_lc", "days_overdue"],
    "journal_entries": ["company_code", "journal_no", "line_no", "posting_date", "account_code", "debit_lc", "credit_lc", "user_id"],
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate exported SAP snapshot files.")
    parser.add_argument("--snapshot-dir", required=True, help="Snapshot directory path")
    return parser.parse_args()


def validate_csv(path: Path, required_cols: List[str]) -> None:
    with path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None:
            raise RuntimeError(f"{path.name}: missing header row")
        missing = [c for c in required_cols if c not in reader.fieldnames]
        if missing:
            raise RuntimeError(f"{path.name}: missing required columns {missing}")
        row_count = sum(1 for _ in reader)
        if row_count < 1:
            raise RuntimeError(f"{path.name}: contains no data rows")


def validate_parquet(path: Path, required_cols: List[str]) -> None:
    try:
        import pyarrow.parquet as pq
    except ImportError as exc:
        raise RuntimeError("Parquet validation requires pyarrow installed") from exc

    table = pq.read_table(str(path))
    cols = set(table.schema.names)
    missing = [c for c in required_cols if c not in cols]
    if missing:
        raise RuntimeError(f"{path.name}: missing required columns {missing}")
    if table.num_rows < 1:
        raise RuntimeError(f"{path.name}: contains no data rows")


def main() -> None:
    args = parse_args()
    snapshot_dir = Path(args.snapshot_dir)
    if not snapshot_dir.exists():
        raise RuntimeError(f"Snapshot directory not found: {snapshot_dir}")

    files = list(snapshot_dir.glob("*"))
    if not files:
        raise RuntimeError(f"Snapshot directory is empty: {snapshot_dir}")

    for dataset, req_cols in REQUIRED_COLUMNS.items():
        csv_match = list(snapshot_dir.glob(f"{dataset}__*__v1.csv"))
        parquet_match = list(snapshot_dir.glob(f"{dataset}__*__v1.parquet"))
        if not csv_match and not parquet_match:
            raise RuntimeError(f"Missing dataset file for {dataset} (.csv or .parquet)")
        if csv_match:
            validate_csv(csv_match[0], req_cols)
        else:
            validate_parquet(parquet_match[0], req_cols)

    manifest = snapshot_dir / "manifest.md"
    if not manifest.exists():
        raise RuntimeError("manifest.md is missing")

    print(f"Snapshot validation passed: {snapshot_dir}")


if __name__ == "__main__":
    main()
