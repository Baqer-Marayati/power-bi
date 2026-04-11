# Agent Operating Playbook

This playbook defines how AI agents should operate in this repository with low ambiguity and low risk.

## Execution Model

- Treat `reporting-hub` root as the portfolio coordination layer.
- Treat `Reports/<Domain>/` as a self-contained delivery module.
- Make changes inside one scope at a time (portfolio or one domain), then validate.

## Decision Routing

When deciding where to write:
- cross-domain standard -> `Portfolio/Shared/` or `Portfolio/docs/`
- portfolio truth / current routing -> `Portfolio/Memory/`
- domain-specific behavior -> `Reports/<Domain>/Module/docs/` or `Reports/<Domain>/Module/Project Memory/DECISIONS.md`
- active progress log -> `Reports/<Domain>/Module/Project Memory/CURRENT_STATUS.md`
- company-specific settings -> `Reports/<Domain>/Companies/<CompanyCode>/config`

## Safe Editing Rules

- Prefer minimal diffs in PBIP/TMDL JSON-like files.
- Avoid broad refactors unless explicitly requested.
- Remove stale hidden visuals and stale interactions when repairing pages.
- Keep archive/history out of active working folders.

## Validation Chain

Use this order after report changes:
1. structure validation script (when you need a repo-level check)
2. open the company PBIP in Power BI Desktop and validate visuals, filters, and refresh
3. screenshot capture of all pages (when review evidence is required)
4. targeted page review
5. memory/status update

## Multi-Company Pattern

For each domain:
- `Core/` holds shared non-company-specific baseline assets for that domain.
- `Companies/<CompanyCode>/...` holds the editable PBIP for that company.
- Do not assume every module uses the synthetic `<ReportName> - <CompanyCode>` naming pattern; use module docs or portfolio memory for the real path.
- `Companies/<CompanyCode>/config` holds company profile + datasource map + publish targets.
- `Companies/<CompanyCode>/overlays` holds optional per-company visual/model exceptions.

## First-Response Standard for Agents

Before substantial edits, state:
1. current known state from module memory
2. exact files to touch first
3. one clarifying question only if blocking

Then proceed without unnecessary waiting.
