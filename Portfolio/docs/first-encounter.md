# First Encounter Guide

Use this guide when a new human contributor or AI agent opens the repository for the first time.

## 1) Identify Your Scope First

Choose one scope before doing anything:

- **Portfolio scope**: standards, templates, catalog, architecture
- **Domain scope**: Finance/HR/Sales/Service/Marketing module work
- **Data exchange scope**: extraction/transfer workspace in `Reports/DataExchange`

If your task is about one report domain, move to that domain module immediately.

## 2) Follow the Navigation Chain

Read this chain in order:
1. `../../AGENTS.md`
2. `foundation.md`
3. `portfolio-architecture.md`
4. `structure.md`
5. `agent-operating-playbook.md`
6. `ai-index.md`
7. `../Memory/REPORT_CATALOG.md`
8. `../Memory/CURRENT_STATUS.md`

Then read the target domain module's:
- `README.md`
- `AGENTS.md`
- `Module/Project Memory/CURRENT_STATUS.md`
- `Module/Project Memory/DECISIONS.md`

## 3) Understand the Contract

Every domain module is expected to follow:
- `../Shared/Standards/report-module-contract.md`

Minimum expected shape:

```text
Reports/<Domain>/
  AGENTS.md
  README.md
  Companies/
    <CompanyCode>/
      <ReportName> - <CompanyCode>/   # PBIP + report + model folders
  Module/
    Core/
    docs/
    Project Memory/
    scripts/
    Records/
    Archive/
```

## 4) Source-of-Truth Rule

- PBIP files under `Companies/<CompanyCode>/<ReportName> - <CompanyCode>/` are the editable source of truth.
- Review and sign-off in Power BI Desktop from that PBIP.

## 5) Validation Rule

After meaningful report edits:
1. validate in Power BI Desktop (refresh, visuals, filters)
2. run screenshot capture workflow when review evidence is needed
3. review target pages from the latest capture set
4. update memory files

## 6) Multi-Company Rule

Company-specific differences go under:
- `Reports/<Domain>/Companies/<CompanyCode>/config`
- `Reports/<Domain>/Companies/<CompanyCode>/overlays`

Use config-first. Add overlays only when config cannot satisfy the requirement.

## 7) Common Failure Modes

- Editing the wrong company copy under `Companies/` (confirm **CODE** in path and PBIP name).
- Mixing screenshot casing (`Screenshots` vs `screenshots`); canonical is `Records/screenshots`.
- Keeping stale off-canvas visuals and hidden filters in PBIP pages.
- Writing live status in `../Shared/` instead of module memory files.

## 8) Practical First Actions

If no additional context is provided:
1. validate structure with `../scripts/validate-structure.ps1`
2. confirm target domain in `../Memory/REPORT_CATALOG.md`
3. confirm source-of-truth path in the domain `README.md`
4. follow contribution constraints in `../CONTRIBUTING.md`
