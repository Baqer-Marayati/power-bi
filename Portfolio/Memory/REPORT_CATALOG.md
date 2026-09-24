# Report Catalog

Report definitions live in `Fabric/` (see `Fabric/README.md`). Edit `Fabric/DevelopmentWorkspace/`; `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` mirror what is live. Modules under `Reports/` hold docs, memory, config, and scripts.

## Active Reports

### Finance

- Module path: `Reports/Finance`
- Status: Active
- Reports: **Canon Financial Report** (live in Canon Analytics) and **Paper Financial Report** (live in Paper Analytics). PBIPs: `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip`, `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip`
- Notes: Current Al Jazeera financial reporting project

### Sales

- Module path: `Reports/Sales`
- Status: Active
- Reports: **Canon Sales Report** (live in Canon Analytics). PBIP: `Fabric/DevelopmentWorkspace/Canon Sales Report.pbip`. Paper Sales Report is parked in `Module/Archive/2026-09-24-parked-reports/`.
- Notes: Sales Analysis Report — 6-page PBIP (Sales Overview, Sales Map, Salesperson, Customers, Rebate, Target & Salaries) with SAP HANA ODBC semantic model (CANON schema). Derived from Aljazeera Master Model. Portfolio visual identity aligned. Page list refreshed 2026-08-24 from the live Fabric copy.

### Service

- Module path: `Reports/Service`
- Status: Active
- Reports: **Canon Service Report** is in the Development Workspace only. It was removed from Canon Analytics on 24 Sep 2026. PBIP: `Fabric/DevelopmentWorkspace/Canon Service Report.pbip`. Paper Service Report is parked in `Module/Archive/2026-09-24-parked-reports/`.
- Notes: Service Performance Report — 5-page PBIP with SAP HANA ODBC semantic model (CANON schema).

### Inventory

- Module path: `Reports/Inventory`
- Status: Active
- Reports: **Canon Inventory Report** (live in Canon Analytics) and **Paper Inventory Report** (live in Paper Analytics). PBIPs: `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip`, `Fabric/DevelopmentWorkspace/Paper Inventory Report.pbip`
- Notes: Inventory Report — 5 pages (Inventory Overview, Stock Value, Stock Health, Stock Actions, Landed Cost) with SAP HANA ODBC semantic model.

## Scaffolded

### HR

- Module path: `Reports/HR`
- Status: Scaffolded
- Notes: Domain module created with baseline docs/memory and company-template layout

### Marketing

- Module path: `Reports/Marketing`
- Status: Scaffolded
- Notes: Domain module created with baseline docs/memory and company-template layout

## Parked

### DataExchange

- Module path: `Reports/DataExchange`
- Status: Parked (24 Sep 2026)
- Reports: Canon and Paper Data Exchange Reports, in `Reports/DataExchange/Module/Archive/2026-09-24-parked-reports/`. Neither is in a Fabric workspace.
- Notes: Isolated export workspace. Not needed for now.

## Planned Reports

- Logistics

Create these as modules under `Reports/` only when real project work begins.

## Module Creation Rule

When a planned report becomes real:
1. create it from `../Shared/Templates/report-module-starter`
2. preferably use `../scripts/create-report-module.sh <ModuleName> "<ReportTitle>"`
3. put the report in `Fabric/DevelopmentWorkspace/` and add it to `Fabric/workspaces.json`
4. update this file from planned to active
