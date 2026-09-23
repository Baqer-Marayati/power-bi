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
- Edit, review, and publish reports:
  - `../../Fabric/README.md`
- Additional active modules (see `REPORT_CATALOG.md`):
  - `Reports/Sales`
  - `Reports/Service`
  - `Reports/Inventory`
- Scaffolded domains (baseline structure only):
  - `Reports/HR`
  - `Reports/Marketing`
- Parked: `Reports/DataExchange`

## Canonical Active PBIP Paths

Edit these (Development Workspace). The live copies with the same names are in `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` and are read-only:
  - `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip`
  - `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip`
  - `Fabric/DevelopmentWorkspace/Canon Sales Report.pbip`
  - `Fabric/DevelopmentWorkspace/Canon Service Report.pbip`
  - `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip`
  - `Fabric/DevelopmentWorkspace/Paper Inventory Report.pbip`

## Automation Entry Points

- Structure validation:
  - `../scripts/validate-structure.ps1`
- Module scaffolding:
  - `../scripts/create-report-module.sh`
- Semantic model cache (blank-on-open):
  - `../scripts/clear-model-cache.ps1`
- Theme drift check (registered `Custom_Theme49412231581938193.json` vs `../Shared/Themes/`):
  - `../scripts/validate-theme-vs-canonical.ps1`
- Cross-report layout, explicit typography/KPI rhythm, and number-formatting audit (PBIP design tokens vs `../Shared/Standards/fabric-reports-layout-standard.md` and `../Shared/Standards/fabric-reports-number-formatting.md`):
  - `../scripts/audit-report-consistency.py`
  - human-readable: `python3 Portfolio/scripts/audit-report-consistency.py Fabric/DevelopmentWorkspace`
  - CI/strict: `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`
- Release tool (publish reviewed reports to Canon Analytics / Paper Analytics and keep the live mirrors):
  - health, read-only: `python3 Portfolio/scripts/fabric_release.py status`
  - dry run: `python3 Portfolio/scripts/fabric_release.py publish "<Report Name>"`
  - publish: add `--apply` (only when the user names the report)
  - roll back: `python3 Portfolio/scripts/fabric_release.py rollback "<Report Name>" --to <commit>`

## Common Questions

- "Where should I add a cross-report standard?"
  - `../Shared/` + `../Memory/DECISIONS.md`
- "Where should I add a company-specific override?"
  - `Reports/<Domain>/Companies/<CompanyCode>/overlays`
- "Where is live status kept?"
  - Portfolio: `../Memory/CURRENT_STATUS.md`
  - Domain: `Reports/<Domain>/Module/Project Memory/CURRENT_STATUS.md`
