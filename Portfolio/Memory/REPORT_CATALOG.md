# Report Catalog

## Active Reports

### Finance

- Module path: `Reports/Finance`
- Status: Active
- Multi-company: **CANON** and **PAPERENTITY** (Paper Company). PBIPs: `Companies/CANON/Canon Financial Report/*.pbip`, `Companies/PAPERENTITY/Paper Financial Report/*.pbip`
- Notes: Current Al Jazeera financial reporting project

### DataExchange

- Module path: `Reports/DataExchange`
- Status: Active
- Multi-company: **CANON** and **PAPERENTITY**. PBIPs: `Companies/CANON/Canon Data Exchange Report/*.pbip`, `Companies/PAPERENTITY/Paper Data Exchange Report/*.pbip`
- Notes: Isolated exchange workspace; keeps Finance source untouched; work from PBIP in Desktop

### HR

- Module path: `Reports/HR`
- Status: Scaffolded
- Notes: Domain module created with baseline docs/memory and company-template layout

### Sales

- Module path: `Reports/Sales`
- Status: Active
- Multi-company: **CANON** and **PAPERENTITY**. PBIPs: `Companies/CANON/Canon Sales Report/*.pbip`, `Companies/PAPERENTITY/Paper Sales Report/*.pbip`
- Notes: Sales Analysis Report — 5-page PBIP (Sales Overview, Sales Employees, BP Sales, BP Rebate, Commission) with SAP HANA ODBC semantic model (CANON schema). Derived from Aljazeera Master Model. Portfolio visual identity aligned; validate in Desktop after model changes.

### Service

- Module path: `Reports/Service`
- Status: Active
- Multi-company: **CANON** and **PAPERENTITY**. PBIPs: `Companies/CANON/Canon Service Report/*.pbip`, `Companies/PAPERENTITY/Paper Service Report/*.pbip`
- Notes: Service Performance Report — 5-page PBIP with SAP HANA ODBC semantic model (CANON schema). Validate in Desktop after model or layout changes.

### Marketing

- Module path: `Reports/Marketing`
- Status: Scaffolded
- Notes: Domain module created with baseline docs/memory and company-template layout

### Inventory

- Module path: `Reports/Inventory`
- Status: Active
- Multi-company: **CANON** and **PAPERENTITY**. PBIPs: `Companies/CANON/Canon Inventory Report/*.pbip`, `Companies/PAPERENTITY/Paper Inventory Report/*.pbip`
- Notes: Inventory Report — 5-page PBIP report with SAP HANA ODBC semantic model (CANON schema). Covers stock position, warehouse distribution, movements, categories, and procurement. Awaiting Desktop validation.

## Planned Reports

- Logistics

Create these as modules under `Reports/` only when real project work begins.

## Module Creation Rule

When a planned report becomes real:
1. create it from `../Shared/Templates/report-module-starter`
2. preferably use `../scripts/create-report-module.sh <ModuleName> "<ReportTitle>"`
3. update this file from planned to active
