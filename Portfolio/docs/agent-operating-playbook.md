# Agent Operating Playbook

This playbook defines how AI agents should operate in this repository with low ambiguity and low risk.

## Execution Model

- Treat `reporting-hub` root as the portfolio coordination layer.
- Treat `Fabric/` as the only home of report definitions.
- Treat `Reports/<Domain>/` as the module for that report's docs, memory, config, and scripts.
- Make changes inside one scope at a time (portfolio or one domain), then validate.

## Decision Routing

When deciding where to write:
- cross-domain standard -> `Portfolio/Shared/` or `Portfolio/docs/`
- portfolio truth / current routing -> `Portfolio/Memory/`
- domain-specific behavior -> `Reports/<Domain>/Module/docs/` or `Reports/<Domain>/Module/Project Memory/DECISIONS.md`
- active progress log -> `Reports/<Domain>/Module/Project Memory/CURRENT_STATUS.md`
- company-specific settings -> `Reports/<Domain>/Companies/<CompanyCode>/config`
- report and semantic-model definitions -> `Fabric/DevelopmentWorkspace/` (never the live mirrors)

## Safe Editing Rules

- Prefer minimal diffs in PBIP/TMDL JSON-like files.
- Avoid broad refactors unless explicitly requested.
- Remove stale hidden visuals and stale interactions when repairing pages.
- Keep archive/history out of active working folders.

## Validation Chain

Use this order after report changes:
1. strict audit: `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`
2. structure validation script (when you need a repo-level check)
3. commit and push, then the user reviews in the Fabric Development Workspace (or Power BI Desktop from the same PBIP)
4. screenshot capture of all pages (when review evidence is required)
5. memory/status update

## Fabric Workspaces (edit, review, publish)

Full procedure: `Fabric/README.md`.

1. **Layout:** `Fabric/DevelopmentWorkspace/` is Git-connected to the Fabric Development Workspace and holds every editable report. `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` mirror what is live. IDs are in `Fabric/workspaces.json`.
2. **Edit rule:** change report and model definitions only under `Fabric/DevelopmentWorkspace/`. Never edit the live mirrors, and never recreate report copies under `Reports/*/Companies/`.
3. **Git:** when a change set is ready for review, commit narrowly and push to `origin/main` unless the user asks to wait. An unpushed commit is not visible in Fabric.
4. **Publish:** only when the user names the report. Run `python3 Portfolio/scripts/fabric_release.py publish "<Report Name>"`, read the plan, then re-run with `--apply`. Commit and push `Fabric/` afterwards, and update module memory.
5. **When the tool stops:** report its message. Do not use `--allow-drift` or `--allow-dev-mismatch` without the user's explicit yes.

## Multi-Company Pattern

For each domain:
- `Core/` holds shared non-company-specific baseline assets for that domain.
- `Companies/<CompanyCode>/config` holds company profile + datasource map + publish targets.
- `Companies/<CompanyCode>/overlays` holds optional per-company visual/model exceptions.
- Each company's report is `Fabric/DevelopmentWorkspace/<Company> <Report>.pbip` (for example `Canon Financial Report`, `Paper Financial Report`).

## First-Response Standard for Agents

Before substantial edits, state:
1. current known state from module memory
2. exact files to touch first
3. one clarifying question only if blocking

Then proceed without unnecessary waiting.
