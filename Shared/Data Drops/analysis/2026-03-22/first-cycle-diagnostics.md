# First Cycle Diagnostics

## Input

- Snapshot date: 2026-03-22
- Manifest path: `Shared/Data Drops/incoming/2026-03-22/manifest.md`
- Dataset files: 5 validated files (`bp_master`, `item_master`, `ar_open_items`, `ap_open_items`, `journal_entries`)

## Data Quality Checks

- `bp_master`: 411 rows, 6 columns, duplicate-key extra rows = 0
- `item_master`: 376 rows, 5 columns, duplicate-key extra rows = 0
- `ar_open_items`: 233 rows, 7 columns, duplicate-key extra rows = 0
- `ap_open_items`: 30 rows, 7 columns, duplicate-key extra rows = 0
- `journal_entries`: 4693 rows, 8 columns, duplicate-key extra rows = 0
- `bp_master` null-rate flags (>2%): company_code=100.0%, bp_group=100.0%, payment_terms=100.0%
- `item_master` null-rate flags (>2%): company_code=100.0%, uom=100.0%
- `ar_open_items` null-rate flags (>2%): company_code=100.0%
- `ap_open_items` null-rate flags (>2%): company_code=100.0%
- `journal_entries` null-rate flags (>2%): company_code=100.0%

## KPI Diagnostics

- AR aging buckets (rows): {'0-30': 110, '31-60': 95, '61-90': 28, '90+': 0, 'missing': 0}
- AP aging buckets (rows): {'0-30': 18, '31-60': 9, '61-90': 3, '90+': 0, 'missing': 0}
- AR negative open amount rows: 7
- AP negative open amount rows: 2
- Journal zero debit/credit rows: 1640

## Anomalies

- High severity:
  - bp_master: very high null columns ['company_code', 'bp_group', 'payment_terms']
  - item_master: very high null columns ['company_code', 'uom']
  - ar_open_items: very high null columns ['company_code']
  - ap_open_items: very high null columns ['company_code']
  - journal_entries: very high null columns ['company_code']
- Medium severity:
  - Open-item sets include negative amounts; confirm credit-note handling and sign convention.
- Low severity:
  - Some journal lines have zero debit/credit; verify source extraction or balancing logic.

## Prioritized Recommendations

### High Impact (0-4 weeks)
1. Fill missing master-data attributes in export tables (`bp_group`, `payment_terms`, `uom`) or map them explicitly as unavailable.
2. Add company identifier from source (not constant) when multiple companies are in scope.
3. Keep only canonical file names (remove `__YYYY-MM-DD__v1.csv.csv` duplicates from incoming).

### Medium Impact (1-3 months)
1. Add reconciliation checks against source counts by date and company.
2. Add unique-key assertions for each dataset before snapshot acceptance.
3. Add user ID extraction for journal entries (replace placeholder `unknown`).

### Longer Horizon (3-12 months)
1. Expand export pack to include sales/purchase open orders and inventory movement sets.
2. Add automated trend and anomaly baselines across rolling snapshots.
3. Version data dictionary with explicit schema-change notes per batch.