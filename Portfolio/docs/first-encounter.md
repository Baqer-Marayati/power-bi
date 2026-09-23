# First Encounter Guide

Use this guide when a new human contributor or AI agent opens the repository for the first time.

## 1) Identify Your Scope First

Choose one scope before doing anything:

- **Portfolio scope**: standards, templates, catalog, architecture
- **Domain scope**: Finance/HR/Sales/Service/Marketing/Inventory module work
- **Release scope**: moving a reviewed report from the Development Workspace to Canon Analytics or Paper Analytics (`../../Fabric/README.md`)

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
      config/
      overlays/
  Module/
    Core/
    docs/
    Project Memory/
    scripts/
    Records/
    Archive/
```

## 4) Source-of-Truth Rule

- The editable source of truth is `Fabric/DevelopmentWorkspace/<Report Name>.pbip` and its `.Report` and `.SemanticModel` folders. Exact names are in `ACTIVE_FOCUS.md`.
- `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` show what is live. Never edit them by hand.
- Review happens in the Fabric Development Workspace after a Git sync. Publishing to a live workspace uses `../scripts/fabric_release.py`, and only when the owner names the report.

## 5) Validation Rule

After meaningful report edits:
1. run `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`
2. commit and push, then review in the Fabric Development Workspace (or Power BI Desktop from the same PBIP)
3. run screenshot capture workflow when review evidence is needed
4. update memory files

## 6) Multi-Company Rule

Company-specific differences go under:
- `Reports/<Domain>/Companies/<CompanyCode>/config`
- `Reports/<Domain>/Companies/<CompanyCode>/overlays`

Use config-first. Add overlays only when config cannot satisfy the requirement.

## 7) Common Failure Modes

- Editing the wrong company report in `Fabric/DevelopmentWorkspace/` (confirm Canon or Paper in the PBIP name).
- Editing a live mirror in `Fabric/CanonAnalytics/` or `Fabric/PaperAnalytics/` instead of the Development Workspace copy.
- Mixing screenshot casing (`Screenshots` vs `screenshots`); canonical is `Records/screenshots`.
- Keeping stale off-canvas visuals and hidden filters in PBIP pages.
- Writing live status in `../Shared/` instead of module memory files.

## 8) Practical First Actions

If no additional context is provided:
1. validate structure with `../scripts/validate-structure.ps1`
2. confirm target domain in `../Memory/REPORT_CATALOG.md`
3. confirm the report path in `../Memory/ACTIVE_FOCUS.md`
4. follow contribution constraints in `../CONTRIBUTING.md`

## 9) Another Mac, another Cursor account, or another AI client

Use this when you are **not** on your usual machine, or you use a **different Cursor (or VS Code) sign-in**: the repository and GitHub remote are shared; **MCP config, skills, and plugins are per machine / per account**, not cloned with the repo.

1. **GitHub:** Clone or pull this repo on the new Mac (for example `git clone git@github.com:Baqer-Marayati/reporting-hub.git`). Open the clone as the **workspace root** so `.cursor/rules/`, `.vscode/`, and `AGENTS.md` resolve correctly.

2. **Agent rules (come with the repo):** `.cursor/rules/` — no separate download; they apply when this folder is the workspace.

3. **Power BI Modeling MCP:** Optional for semantic model / TMDL work. Install per Microsoft’s [Power BI Modeling MCP Server](https://github.com/microsoft/powerbi-modeling-mcp) docs (VS Code extension, or `npx @microsoft/powerbi-modeling-mcp`). On this Mac, copy `.cursor/mcp.json.example` to `.cursor/mcp.json` if you use Cursor’s workspace MCP file (the real `mcp.json` is gitignored).

4. **Skills and plugins:** Not stored in Reporting Hub. Reinstall or copy the skill folders and plugin config you use into that Mac’s Cursor/Codex (or other client) paths, or sync them however you already manage personal tooling.

**Finance benchmark note (Power BI only):** The tracked Wiise Sample 2 shell lives under `Reports/Finance/Module/Design Benchmarks/Sample 2/`. Avoid a duplicate tree under `Reports/Finance/Design Benchmarks/` (Desktop can leave stray `.pbi` files there if the wrong folder is opened). Prefer the VS Code task **Finance: Open design benchmark (Wiise Sample 2) in Power BI Desktop** or `Reports/Finance/Module/scripts/open-design-benchmark.ps1` to open the canonical `.pbip`.
