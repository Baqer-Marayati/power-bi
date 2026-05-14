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

## Fabric Development Workspace (Git-connected Fabric)

Use this when PBIP changes must appear in **Fabric** after **Git sync** from this repository.

1. **Layout:** `Fabric/DevelopmentWorkspace/` holds the PBIP pair (for example `Canon Inventory Report.pbip`, `Canon Inventory Report.Report/`, `Canon Inventory Report.SemanticModel/`) that Fabric’s workspace tracks.
2. **Start of work:** **Copy or sync** the target company PBIP from `Reports/<Domain>/Companies/<CompanyCode>/` into `Fabric/DevelopmentWorkspace/` so Fabric and the module stay aligned in content; then work in **`Fabric/DevelopmentWorkspace/`** for that review cycle.
3. **Edit rule:** For Fabric-first delivery, change definitions under `Fabric/DevelopmentWorkspace/` only. Treat `Reports/.../Companies/...` as the module’s canonical home; reconcile back when the user wants both trees identical.
4. **Git:** When a change set is ready for service review, **commit** (narrow scope) and **push** to GitHub (`origin`, typically `main`) unless the user asks to wait. The user **Sync**’s in Fabric to pull the commit.
5. **Agent default:** After Fabric-bound PBIP/TMDL edits, **push** so the remote matches local; an unpushed commit is not visible in Fabric.

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
