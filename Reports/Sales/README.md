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

- **Primary PBIP:** `Companies/CANON/Canon Sales Report/Canon Sales Report.pbip`
- **Alternate copy:** `Companies/PAPERENTITY/Paper Sales Report/Paper Sales Report.pbip`

Work directly from PBIP; there is no `ready.zip` or server-package export step in this module.
