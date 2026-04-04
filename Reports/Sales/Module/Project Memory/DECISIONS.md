# Decisions

## Module Scope
- This module is dedicated to Sales reporting.
- Pages: Sales Overview, Sales Employees, BP Sales, BP Rebate.

## Origin Decision (2026-03-31)
- Report derived from the Aljazeera Master Model PBIP.
- Only the 4 sales/commercial pages were kept.
- Non-sales pages (Inventory Valuation, Receivables, Collections, Cash) were intentionally excluded.
- Those excluded pages may be routed to their natural modules (Inventory, Finance) in the future.

## Structure Rule
- Follow the portfolio report-module contract in `Shared/Standards/report-module-contract.md`.

## Delivery Rule
- PBIP is source of truth.
- Review from packaged artifacts.

## Visual Identity Rule
- Adopt the portfolio visual identity from Finance (navy-blue palette, branding lockup).
- IQD currency formatting throughout.

## Data Source Rule
- SAP HANA ODBC to CANON schema (same SAP instance as Finance).
- SalesFact SQL includes A/R Invoice, Credit Memo, warranty, and GL COGS adjustment logic.

## Server Safety Rule
- Same as Finance: this server hosts the production SAP database.
- All actions are production-critical. Read-only and passive automation only.
