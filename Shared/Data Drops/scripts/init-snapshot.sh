#!/usr/bin/env bash
set -euo pipefail

# Initializes a dated snapshot folder with templates and starter CSV headers.
# Usage:
#   ./Shared/Data\ Drops/scripts/init-snapshot.sh 2026-03-22
#   ./Shared/Data\ Drops/scripts/init-snapshot.sh   # defaults to today

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
BASE_DIR="$ROOT_DIR/Shared/Data Drops"

SNAPSHOT_DATE="${1:-$(date +%F)}"
TARGET_DIR="$BASE_DIR/incoming/$SNAPSHOT_DATE"

if [[ ! "$SNAPSHOT_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "ERROR: date must be YYYY-MM-DD (got: $SNAPSHOT_DATE)" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

cp "$BASE_DIR/incoming/manifest.template.md" "$TARGET_DIR/manifest.md"
cp "$BASE_DIR/spec/data-dictionary.template.csv" "$TARGET_DIR/data_dictionary.csv"

# Replace placeholders in manifest.
export SNAPSHOT_DATE
export TARGET_DIR
export RUN_TS
RUN_TS="$(date +%FT%T)"
python3 - <<'PY'
import os
from pathlib import Path

snapshot_date = os.environ["SNAPSHOT_DATE"]
run_ts = os.environ["RUN_TS"]
manifest_path = Path(os.environ["TARGET_DIR"]) / "manifest.md"
text = manifest_path.read_text(encoding="utf-8")
text = text.replace("YYYY-MM-DD", snapshot_date)
text = text.replace("YYYY-MM-DDTHH:MM:SS", run_ts)
manifest_path.write_text(text, encoding="utf-8")
PY

# Create starter CSV skeletons (headers only).
cat > "$TARGET_DIR/bp_master__${SNAPSHOT_DATE}__v1.csv" <<'EOF'
company_code,bp_id,bp_type,bp_group,payment_terms,active_flag
EOF

cat > "$TARGET_DIR/item_master__${SNAPSHOT_DATE}__v1.csv" <<'EOF'
company_code,item_id,item_group,uom,active_flag
EOF

cat > "$TARGET_DIR/ar_open_items__${SNAPSHOT_DATE}__v1.csv" <<'EOF'
company_code,doc_no,bp_id,posting_date,due_date,open_amount_lc,days_overdue
EOF

cat > "$TARGET_DIR/ap_open_items__${SNAPSHOT_DATE}__v1.csv" <<'EOF'
company_code,doc_no,bp_id,posting_date,due_date,open_amount_lc,days_overdue
EOF

cat > "$TARGET_DIR/journal_entries__${SNAPSHOT_DATE}__v1.csv" <<'EOF'
company_code,journal_no,line_no,posting_date,account_code,debit_lc,credit_lc,user_id
EOF

echo "Initialized snapshot folder: $TARGET_DIR"
echo "Next: replace CSV header-only files with exported Power BI data."
