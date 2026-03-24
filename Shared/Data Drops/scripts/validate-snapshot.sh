#!/usr/bin/env bash
set -euo pipefail

# Validates that a snapshot folder has required files and non-empty data rows.
# Usage:
#   ./Shared/Data\ Drops/scripts/validate-snapshot.sh 2026-03-22

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 YYYY-MM-DD" >&2
  exit 1
fi

SNAPSHOT_DATE="$1"
if [[ ! "$SNAPSHOT_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "ERROR: date must be YYYY-MM-DD (got: $SNAPSHOT_DATE)" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TARGET_DIR="$ROOT_DIR/Shared/Data Drops/incoming/$SNAPSHOT_DATE"

required=(
  "manifest.md"
  "data_dictionary.csv"
  "bp_master__${SNAPSHOT_DATE}__v1.csv"
  "item_master__${SNAPSHOT_DATE}__v1.csv"
  "ar_open_items__${SNAPSHOT_DATE}__v1.csv"
  "ap_open_items__${SNAPSHOT_DATE}__v1.csv"
  "journal_entries__${SNAPSHOT_DATE}__v1.csv"
)

missing=0
for f in "${required[@]}"; do
  if [[ ! -f "$TARGET_DIR/$f" ]]; then
    echo "MISSING: $TARGET_DIR/$f"
    missing=1
  fi
done

if [[ $missing -eq 1 ]]; then
  echo "Validation failed: missing required files." >&2
  exit 1
fi

data_files=(
  "bp_master__${SNAPSHOT_DATE}__v1.csv"
  "item_master__${SNAPSHOT_DATE}__v1.csv"
  "ar_open_items__${SNAPSHOT_DATE}__v1.csv"
  "ap_open_items__${SNAPSHOT_DATE}__v1.csv"
  "journal_entries__${SNAPSHOT_DATE}__v1.csv"
)

row_issue=0
for f in "${data_files[@]}"; do
  # row_count includes header; need at least 2 lines for data presence
  row_count=$(python3 - <<PY
from pathlib import Path
p = Path(r"$TARGET_DIR/$f")
print(len(p.read_text(encoding="utf-8", errors="ignore").splitlines()))
PY
)
  if [[ "$row_count" -lt 2 ]]; then
    echo "NO_DATA_ROWS: $TARGET_DIR/$f (header only)"
    row_issue=1
  fi
done

if [[ $row_issue -eq 1 ]]; then
  echo "Validation failed: one or more CSV files contain no data rows." >&2
  exit 1
fi

echo "Validation passed for snapshot: $SNAPSHOT_DATE"
