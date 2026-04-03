# Report Catalog

## Active Reports

### Finance

- Module path: `Reports/Finance`
- Status: Active
- Notes: Current Al Jazeera financial reporting project

### DataExchange

- Module path: `Reports/DataExchange`
- Status: Active
- Notes: Isolated PBIP workspace for export operations; keeps Finance source untouched

### HR

- Module path: `Reports/HR`
- Status: Scaffolded
- Notes: Domain module created with baseline docs/memory and company-template layout

### Sales

- Module path: `Reports/Sales`
- Status: Active
- Notes: Sales Analysis Report — 5-page PBIP (Sales Overview, Sales Employees, BP Sales, BP Rebate, Commission) with SAP HANA ODBC semantic model (CANON schema). Derived from Aljazeera Master Model. Portfolio visual identity aligned; validate in Desktop after model changes.

### Service

- Module path: `Reports/Service`
- Status: Active
- Notes: Service Performance Report — 5-page PBIP with SAP HANA ODBC semantic model (CANON schema). CANON company config under `Companies/CANON/`. Validate in Desktop after model or layout changes.

### Marketing

- Module path: `Reports/Marketing`
- Status: Scaffolded
- Notes: Domain module created with baseline docs/memory and company-template layout

### Inventory

- Module path: `Reports/Inventory`
- Status: Active
- Notes: Inventory Report — 5-page PBIP report with SAP HANA ODBC semantic model (CANON schema). Covers stock position, warehouse distribution, movements, categories, and procurement. Awaiting Desktop validation.

## Planned Reports

- Logistics

Create these as modules under `Reports/` only when real project work begins.

## Module Creation Rule

When a planned report becomes real:
1. create it from `Shared/Templates/report-module-starter`
2. preferably use `./scripts/create-report-module.sh <ModuleName> "<ReportTitle>"`
3. update this file from planned to active
