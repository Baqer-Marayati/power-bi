# AI Index

Use this file as a fast routing map when an AI model receives the repository without local IDE rules.

## Task -> Path Map

- Understand the repository at first glance:
  - `../../README.md`
  - `first-encounter.md`
  - `../../AGENTS.md`
- Understand architecture and folder design:
  - `foundation.md`
  - `portfolio-architecture.md`
  - `structure.md`
- Understand operating behavior for agents:
  - `agent-operating-playbook.md`
- Understand module contract and required layout:
  - `../Shared/Standards/report-module-contract.md`
- See which reports are active/scaffolded:
  - `../Memory/REPORT_CATALOG.md`
- See the default current-project starting point and real PBIP entry paths:
  - `../Memory/ACTIVE_FOCUS.md`
- Check current portfolio truth:
  - `../Memory/CURRENT_STATUS.md`
  - `../Memory/DECISIONS.md`
- Contribute safely:
  - `../CONTRIBUTING.md`

## Domain Work Routing

- Finance production work:
  - `Reports/Finance/README.md`
  - `Reports/Finance/AGENTS.md`
  - `Reports/Finance/Module/Project Memory/CURRENT_STATUS.md`
- Data exchange workflows:
  - `Reports/DataExchange/README.md`
  - `Reports/DataExchange/Module/docs/quickstart.md`
- Additional active PBIP modules (see `REPORT_CATALOG.md`):
  - `Reports/Sales`
  - `Reports/Service`
  - `Reports/Inventory`
- Scaffolded domains (baseline structure only):
  - `Reports/HR`
  - `Reports/Marketing`

## Canonical Active PBIP Paths

Use these exact path patterns unless newer memory files say otherwise:
- Finance:
  - `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.pbip`
  - `Reports/Finance/Companies/PAPERENTITY/Paper Financial Report/Paper Financial Report.pbip`
- DataExchange:
  - `Reports/DataExchange/Companies/CANON/Canon Data Exchange Report/Canon Data Exchange Report.pbip`
  - `Reports/DataExchange/Companies/PAPERENTITY/Paper Data Exchange Report/Paper Data Exchange Report.pbip`
- Sales:
  - `Reports/Sales/Companies/CANON/Canon Sales Report/Canon Sales Report.pbip`
  - `Reports/Sales/Companies/PAPERENTITY/Paper Sales Report/Paper Sales Report.pbip`
- Service:
  - `Reports/Service/Companies/CANON/Canon Service Report/Canon Service Report.pbip`
  - `Reports/Service/Companies/PAPERENTITY/Paper Service Report/Paper Service Report.pbip`
- Inventory:
  - `Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.pbip`
  - `Reports/Inventory/Companies/PAPERENTITY/Paper Inventory Report/Paper Inventory Report.pbip`

## Automation Entry Points

- Structure validation:
  - `../scripts/validate-structure.ps1`
- Module scaffolding:
  - `../scripts/create-report-module.sh`
- Semantic model cache (blank-on-open):
  - `../scripts/clear-model-cache.ps1`
- Theme drift check (registered `Custom_Theme49412231581938193.json` vs `../Shared/Themes/`):
  - `../scripts/validate-theme-vs-canonical.ps1`

## Common Questions

- "Where should I add a cross-report standard?"
  - `../Shared/` + `../Memory/DECISIONS.md`
- "Where should I add a company-specific override?"
  - `Reports/<Domain>/Companies/<CompanyCode>/overlays`
- "Where is live status kept?"
  - Portfolio: `../Memory/CURRENT_STATUS.md`
  - Domain: `Reports/<Domain>/Module/Project Memory/CURRENT_STATUS.md`
