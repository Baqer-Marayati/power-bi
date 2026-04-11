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
8. `../Memory/ACTIVE_FOCUS.md`
9. `../Memory/CURRENT_STATUS.md`

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
      <ActualReportFolder>/           # PBIP + report + model folders
  Module/
    Core/
    docs/
    Project Memory/
    scripts/
    Records/
    Archive/
```

## 4) Source-of-Truth Rule

- PBIP files under `Companies/<CompanyCode>/.../` are the editable source of truth.
- Do not assume every module follows the synthetic `<ReportName> - <CompanyCode>` pattern; confirm the real path in `REPORT_CATALOG.md`, `ACTIVE_FOCUS.md`, or the module README.
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

## 9) GitHub and local IDE tooling (Cursor / VS Code)

This repository is already a Git project. Clone it from your GitHub remote (for example `git clone git@github.com:Baqer-Marayati/reporting-hub.git`), then work from the cloned folder as the workspace root so `.cursor/rules/`, `.vscode/`, and `AGENTS.md` resolve correctly.

**Agent rules (in-repo, no download):** `.cursor/rules/` — portfolio and Finance rules apply automatically when you open this folder in Cursor.

**Power BI Modeling MCP (semantic model / TMDL):** Optional but recommended for model work. Microsoft documents installation in the [Power BI Modeling MCP Server](https://github.com/microsoft/powerbi-modeling-mcp) repository (VS Code extension with Copilot, or `npx @microsoft/powerbi-modeling-mcp`). For Cursor, copy `.cursor/mcp.json.example` to `.cursor/mcp.json` and adjust if your client expects a different top-level shape; the real `mcp.json` stays local and is listed in `.gitignore`.

**Skills and plugins:** Skills are not vendored inside this repo; they live in your personal skills directories (for example Cursor or Codex skill folders on your machine). Install or sync the Power BI–related skills you use from your own skill sources. Codex-style plugins, if you use them, are configured in your Codex or client plugin paths, not in Reporting Hub by default.

**Finance design benchmark PBIP:** The tracked Wiise Sample 2 benchmark lives only under `Reports/Finance/Module/Design Benchmarks/Sample 2/`. Do not maintain a second copy under `Reports/Finance/Design Benchmarks/` — Power BI Desktop can create stray `.pbi` folders there if the project is opened from the wrong path; delete that duplicate if it appears. Use the VS Code task **Finance: Open design benchmark (Wiise Sample 2) in Power BI Desktop** (or run `Reports/Finance/Module/scripts/open-design-benchmark.ps1`) to open the canonical `.pbip`.
