# Sales Report Module

This module is the working home for Sales reporting in the Reporting Hub portfolio.

## Report: Sales Report

A 4-page sales analysis report covering sales performance, salesperson analysis, business partner sales, and BP rebate tracking. Built on SAP Business One (CANON schema) via SAP HANA ODBC.

### Pages

1. **Sales Overview** — Top-line sales KPIs, COGS, profit, margin
2. **Sales Employees** — Salesperson performance breakdown
3. **BP Sales** — Business partner sales analysis
4. **BP Rebate** — Business partner rebate tracking

### Data Source

- SAP HANA ODBC (`CANON` schema)
- Line-level sales data from A/R Invoices, A/R Credit Memos, warranty A/P provisions, and G/L COGS adjustments
- Salesperson and business partner dimensions

## Start Here

- `AGENTS.md`
- `Module/docs/foundation.md`
- `Module/Project Memory/CURRENT_STATUS.md`
- `Module/Project Memory/DECISIONS.md`
- `Module/Project Memory/NEXT_STEPS.md`

## Source of Truth

- **Primary PBIP (edit):** `Fabric/DevelopmentWorkspace/Canon Sales Report.pbip`
- **Live copy (read-only):** `Fabric/CanonAnalytics/Canon Sales Report.*`
- **Parked:** Paper Sales Report, under `Module/Archive/2026-09-24-parked-reports/PAPERENTITY/` (not in any workspace)

Paths under `Fabric/` are repo-root-relative. Work directly from PBIP and review in the Fabric Development Workspace; there is no `ready.zip` or server-package export step in this module. Publish with `Portfolio/scripts/fabric_release.py`.
