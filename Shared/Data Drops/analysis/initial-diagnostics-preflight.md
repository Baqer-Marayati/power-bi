# Initial Diagnostics (Preflight)

## Scope

This is the first analysis-cycle output before the first live snapshot has been dropped.

## Current Finding

- No incoming dataset batch exists yet under `Shared/Data Drops/incoming/<date>/`.
- Because no files are available, KPI and anomaly diagnostics cannot be computed yet.

## Readiness Checks Completed

- Export workflow is documented in `Reports/Finance/docs/workflows/powerbi-data-sharing-only.md`.
- Export spec template is available at `Shared/Data Drops/spec/export-spec.template.yaml`.
- Data dictionary template is available at `Shared/Data Drops/spec/data-dictionary.template.csv`.
- Snapshot manifest template is available at `Shared/Data Drops/incoming/manifest.template.md`.
- First-cycle diagnostics template is available at `Shared/Data Drops/analysis/first-cycle-diagnostics.template.md`.

## Prioritized Recommendations

### High Priority (do now)

1. Export the first five core datasets (`bp_master`, `item_master`, `ar_open_items`, `ap_open_items`, `journal_entries`) for one snapshot date.
2. Place files in `Shared/Data Drops/incoming/<YYYY-MM-DD>/` with the naming convention from the workflow doc.
3. Include a completed `manifest.md` and dictionary for all included columns.

### Medium Priority (next)

1. Mirror the same snapshot to private GitHub `staging`.
2. Run first diagnostic pass using the template and publish `analysis/<YYYY-MM-DD>/first-cycle-diagnostics.md`.
3. Promote validated snapshot to `main`.

### Follow-on

1. Expand to remaining starter datasets (`sales_order_open`, `purchase_order_open`, `inventory_movements`, `period_control`, `intercompany_map`).
2. Move high-volatility sets to daily cadence after two successful weekly cycles.
