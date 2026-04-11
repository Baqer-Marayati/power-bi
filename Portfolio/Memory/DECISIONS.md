# Portfolio Decisions

## 2026-04-04 — PAPERENTITY company branding: no logos or divider on any report page

- All PAPERENTITY company reports across all domains must **not** include the top-right logo group (Aljazeera logo, Canon logo, vertical divider, their parent group).
- This applies to: Paper Financial Report, Paper Sales Report, Paper Service Report, Paper Inventory Report, Paper Data Exchange Report — and any future PAPERENTITY reports.
- CANON company reports are unaffected and keep their logo group.
- If new pages are added to any PAPERENTITY report, do not add the logo/divider group.
- This is a permanent, company-level branding rule for PAPERENTITY.

## Structure Decision

- The repository is now organized as a reporting portfolio, not as a single-report folder.
- Each department report should live in its own module under `Reports/`.

## Modularity Decision

- Shared assets should be centralized in `Portfolio/Shared/` when reuse is expected.
- Report-specific live truth should remain inside each report's own docs and memory.
- Portfolio-level exported data snapshots for assistant analysis should live under `Portfolio/Shared/Data Drops/`, not inside a single report module.

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
  - `../Shared/SAP Export Pipeline/config.json`
  - `../Shared/SAP Export Pipeline/set_credentials.sh`

## Onboarding and Agent Navigation Decision

- Portfolio root onboarding is now explicit and mandatory for first encounter:
  - `../docs/first-encounter.md`
  - `../docs/agent-operating-playbook.md`
- Generic AI upload routing is standardized through:
  - `../docs/ai-index.md`
- Portfolio contribution behavior is standardized through:
  - `../CONTRIBUTING.md`
- Agents should identify scope first (portfolio vs specific domain) before edits.
- Module contract in `../Shared/Standards/report-module-contract.md` is the baseline for all new or upgraded domain modules.

## Automation Guardrail Decision

- Repository structure validation must run in CI on push and pull request via:
  - `.github/workflows/validate-structure.yml`
- Markdown link validation must run in CI on push and pull request via:
  - `.github/workflows/validate-doc-links.yml`

## Cross-Report Branding Decision

- The Finance report visual language is the baseline brand system for the portfolio.
- All current and future reports (including Inventory) should keep a unified theme across backgrounds, chart palettes, KPI styling, and overall reporting look-and-feel.
- Portfolio-level shared standards for this live in `Portfolio/Memory/SHARED_STANDARDS.md`.

## Pathing And Routing Decision

- Real active PBIP paths are authoritative as written in `Portfolio/Memory/REPORT_CATALOG.md` and `Portfolio/Memory/ACTIVE_FOCUS.md`.
- Do not assume a generic `<ReportName> - <CompanyCode>` folder convention when navigating active modules; several real company folders use explicit business names such as `Canon Financial Report` and `Paper Financial Report`.
- When onboarding a new model, route through portfolio memory first, then module `README.md`, `AGENTS.md`, and `Module/Project Memory/`.
