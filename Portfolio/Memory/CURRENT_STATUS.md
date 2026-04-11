# Portfolio Current Status

## Date

- Last updated: April 11, 2026

## Current Reality

- The repository uses a portfolio-style reporting structure instead of a single-report root layout.
- `Reports/Finance` remains the primary production report module and the default deep-work starting point for new agents.
- `Reports/DataExchange` is the active isolated exchange workspace for extraction and transfer workflows.
- `Reports/Sales`, `Reports/Service`, and `Reports/Inventory` are active PBIP modules in the repo for both CANON and PAPERENTITY company copies.
- `Reports/HR` and `Reports/Marketing` remain scaffolded modules.
- The portfolio root is reserved for cross-report structure, documentation, shared assets, and report-module orchestration.

## Current Routing

- Use `REPORT_CATALOG.md` as the authoritative module-status map.
- Use `ACTIVE_FOCUS.md` as the fastest current-project routing file and canonical PBIP path map.
- Treat module `README.md`, `AGENTS.md`, and `Module/Project Memory/` as the next layer of truth after portfolio memory.

## Active Environments (Dual-Workstation Setup)

- Mac development workspace:
  - Cursor + GitHub + repo path: `/Users/baqer/Dropbox/Work/PowerBI/Reporting Hub`
- Windows server execution workspace:
  - Cursor + GitHub + repo path: `C:\Work\reporting-hub` (Git Bash path: `/c/Work/reporting-hub`)
- GitHub `main` is the shared source of truth across both environments.

## Working Method In Use

- Primary model is dual-copy sync:
  1. Pull before work on whichever machine is active.
  2. Commit and push from that machine.
  3. Pull on the other machine before continuing.
- The server is now in a validated, clean sync state after rebase conflict resolution and push/pull reconciliation.
- Local server-only secret files are intentionally excluded from tracking:
  - `../Shared/SAP Export Pipeline/config.json`
  - `../Shared/SAP Export Pipeline/set_credentials.sh`

## Immediate Meaning

- Future department reports should be added under `Reports/`.
- Shared standards and reusable assets should be added under `Portfolio/Shared/`.
- Cross-report planning and architecture should be recorded in `Portfolio/Memory/`.
- Portfolio-level exported data snapshots for assistant analysis remain under `Portfolio/Shared/Data Drops/` (cross-report scope, not Finance-only).

## New Portfolio Onboarding Layer

- Added first-encounter onboarding doc for agents and new contributors:
  - `../docs/first-encounter.md`
- Added deterministic agent operating playbook:
  - `../docs/agent-operating-playbook.md`
- Added AI retrieval index for generic model uploads:
  - `../docs/ai-index.md`
- Added portfolio contribution guide:
  - `../CONTRIBUTING.md`
- Added GitHub CI guardrail for structure enforcement:
  - `.github/workflows/validate-structure.yml`
- Added GitHub CI guardrail for markdown link health:
  - `.github/workflows/validate-doc-links.yml`
- Updated root navigation docs to reflect current multi-domain reality and contract-first workflow:
  - `README.md`
  - `AGENTS.md`
  - `../docs/foundation.md`
  - `../docs/portfolio-architecture.md`
  - `../docs/structure.md`
