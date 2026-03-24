# Portfolio Decisions

## Structure Decision

- The repository is now organized as a reporting portfolio, not as a single-report folder.
- Each department report should live in its own module under `Reports/`.

## Modularity Decision

- Shared assets should be centralized in `Shared/` when reuse is expected.
- Report-specific live truth should remain inside each report's own docs and memory.
- Portfolio-level exported data snapshots for assistant analysis should live under `Shared/Data Drops/`, not inside a single report module.

## Archive Decision

- Historical material should be moved into clearly named archive folders instead of remaining mixed into active working areas.
- Archive names should explain date, subject, and status.

## Environment and Sync Decision

- The project now runs as a dual-workstation setup:
  - Mac authoring path: `/Users/baqer/Dropbox/Work/PowerBI/Reporting Hub`
  - Windows server execution path: `C:\Work\reporting-hub` (`/c/Work/reporting-hub` in Git Bash)
- GitHub `main` is the canonical synchronization layer between Mac and server.
- Required protocol before any implementation work:
  - Run pull/rebase first on the active machine.
  - Push after completed edits.
  - Pull on the other machine before resuming there.

## Security and Operations Decision

- Keep SAP interactions read-only for assistant-driven workflows.
- Do not commit environment credentials or server-local secret files.
- Use local Git excludes on server for runtime secret files:
  - `Shared/SAP Export Pipeline/config.json`
  - `Shared/SAP Export Pipeline/set_credentials.sh`
