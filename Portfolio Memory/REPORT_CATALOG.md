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

## Planned Reports

- HR
- Sales
- Service
- Inventory
- Logistics

Create these as modules under `Reports/` only when real project work begins.

## Module Creation Rule

When a planned report becomes real:
1. create it from `Shared/Templates/report-module-starter`
2. preferably use `./scripts/create-report-module.sh <ModuleName> "<ReportTitle>"`
3. update this file from planned to active
