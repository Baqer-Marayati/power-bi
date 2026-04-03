# AI Index

Use this file as a fast routing map when an AI model receives the repository without local IDE rules.

## Task -> Path Map

- Understand the repository at first glance:
  - `README.md`
  - `docs/first-encounter.md`
  - `AGENTS.md`
- Understand architecture and folder design:
  - `docs/foundation.md`
  - `docs/portfolio-architecture.md`
  - `docs/structure.md`
- Understand operating behavior for agents:
  - `docs/agent-operating-playbook.md`
- Understand module contract and required layout:
  - `Shared/Standards/report-module-contract.md`
- See which reports are active/scaffolded:
  - `Portfolio Memory/REPORT_CATALOG.md`
- Check current portfolio truth:
  - `Portfolio Memory/CURRENT_STATUS.md`
  - `Portfolio Memory/DECISIONS.md`
- Contribute safely:
  - `CONTRIBUTING.md`

## Domain Work Routing

- Finance production work:
  - `Reports/Finance/README.md`
  - `Reports/Finance/AGENTS.md`
  - `Reports/Finance/Project Memory/CURRENT_STATUS.md`
- Data exchange workflows:
  - `Reports/DataExchange/README.md`
  - `Reports/DataExchange/docs/quickstart.md`
- Additional active PBIP modules (see `REPORT_CATALOG.md`):
  - `Reports/Sales`
  - `Reports/Service`
  - `Reports/Inventory`
- Scaffolded domains (baseline structure only):
  - `Reports/HR`
  - `Reports/Marketing`

## Automation Entry Points

- Structure validation:
  - `scripts/validate-structure.ps1`
- Module scaffolding:
  - `scripts/create-report-module.sh`
- Packaging and retention:
  - `scripts/package-report.ps1`
  - `scripts/archive-prune.ps1`
- Semantic model cache (blank-on-open):
  - `scripts/clear-model-cache.ps1`
- Theme drift check (registered `Custom_Theme49412231581938193.json` vs `Shared/Themes/`):
  - `scripts/validate-theme-vs-canonical.ps1`

## Common Questions

- "Where should I add a cross-report standard?"
  - `Shared/` + `docs/` + `Portfolio Memory/DECISIONS.md`
- "Where should I add a company-specific override?"
  - `Reports/<Domain>/Companies/<CompanyCode>/overlays`
- "Where is live status kept?"
  - Portfolio: `Portfolio Memory/CURRENT_STATUS.md`
  - Domain: `Reports/<Domain>/Project Memory/CURRENT_STATUS.md`
