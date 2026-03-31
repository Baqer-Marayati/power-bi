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
- `docs/foundation.md`
- `Project Memory/CURRENT_STATUS.md`
- `Project Memory/DECISIONS.md`
- `Project Memory/NEXT_STEPS.md`

## Source of Truth

- **PBIP project:** `Sales Report/Sales Report.pbip`
- Packaged artifacts are review outputs, not source-of-truth files.
