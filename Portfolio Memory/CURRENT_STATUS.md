# Portfolio Current Status

## Date

- Last updated: March 24, 2026

## Current Reality

- The repository uses a portfolio-style reporting structure instead of a single-report root layout.
- `Reports/Finance` remains the active production report module.
- A separate non-production exchange workspace exists at `Reports/DataExchange/` for extraction and transfer workflows.
- The portfolio root is reserved for cross-report structure, documentation, shared assets, and report-module orchestration.

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
  - `Shared/SAP Export Pipeline/config.json`
  - `Shared/SAP Export Pipeline/set_credentials.sh`

## Immediate Meaning

- Future department reports should be added under `Reports/`.
- Shared standards and reusable assets should be added under `Shared/`.
- Cross-report planning and architecture should be recorded in `Portfolio Memory/`.
- Portfolio-level exported data snapshots for assistant analysis remain under `Shared/Data Drops/` (cross-report scope, not Finance-only).
