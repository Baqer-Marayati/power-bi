# Report Module Contract

This standard defines the minimum folder contract for all domain modules under `Reports/` (for example `Finance`, `HR`, `Sales`, `Service`, `Marketing`).

## Goals

- Keep module structure consistent across domains.
- Support multiple companies per domain with moderate isolation.
- Keep every report definition in one place, `Fabric/`, laid out like the Power BI workspaces.
- Make automation predictable (capture, retention, validation).

## Required Module Structure

Each domain module must include:

```text
Reports/<Domain>/
  AGENTS.md
  README.md
  module.manifest.json
  Companies/
  Module/
    Core/
    docs/
    Project Memory/
    scripts/
    Records/
    Archive/
```

## Report location

Report definitions do not live in the module. They live in `Fabric/`:

```text
Fabric/
  DevelopmentWorkspace/            # Git-connected; edit here
    <Company> <Report>.pbip
    <Company> <Report>.Report/
    <Company> <Report>.SemanticModel/
  CanonAnalytics/, PaperAnalytics/ # live mirrors, written by fabric_release.py only
  workspaces.json                  # IDs per report
  RELEASES.md                      # publish log
```

Company codes in this portfolio are **CANON** and **PAPERENTITY** (Paper Company). `Companies/<CODE>/` in the module holds that company's `config/` and `overlays/` only. `validate-structure.ps1` fails if a `.pbip` appears under `Companies/`.

Reports that are not in any workspace are parked in `Module/Archive/<date>-parked-reports/`.

## Module Manifest

Active PBIP modules should include `module.manifest.json` at the module root. The manifest records company codes, actual PBIP paths, schema/database names when known, package/review artifact policy, and expected report/page metadata when practical.

Use the shared schema at `Portfolio/Shared/Standards/module-manifest.schema.json` as the baseline shape. Scripts and validation should prefer the manifest over hardcoded legacy paths when a module has one.

## Folder Responsibilities

- `Core/`
  - Shared domain baseline assets that are **not** company-specific:
    - shared semantic fragments, reusable patterns, documentation assets.
  - Company PBIPs belong in `Fabric/DevelopmentWorkspace/`, not in `Core/` or `Companies/`.
  - No company-specific secrets or one-off overrides.

- `Companies/<CompanyCode>/config/`
  - Company profile and environment mapping.
  - Recommended files:
    - `company.profile.json`
    - `datasource.map.json`
    - `publish.targets.json`

- `Companies/<CompanyCode>/overlays/`
  - Optional company-specific overrides only.
  - Use overlays only when config cannot solve the requirement.

- `Records/screenshots/`
  - Screenshot capture runs, diagnostics, and review evidence.
  - Use lowercase `screenshots` casing only.

- `Archive/`
  - Historical module-level snapshots and retired material.

- `scripts/`
  - Domain automation wrappers:
    - screenshot capture
    - structure validation
    - model cache maintenance (when applicable)

- `Project Memory/`
  - Durable project context:
    - `CURRENT_STATUS.md`
    - `DECISIONS.md`
    - `NEXT_STEPS.md`
    - `PROJECT_DNA.md`
    - `REFERENCE.md`

## Required Operating Rules

- `Fabric/DevelopmentWorkspace/<Company> <Report>.pbip` is the editable source of truth.
- Review happens in the Fabric Development Workspace after a Git sync (Power BI Desktop from the same PBIP is also fine).
- Publishing to Canon Analytics or Paper Analytics uses `Portfolio/scripts/fabric_release.py`, only when the owner names the report. See `Fabric/README.md`.
- Modules must adopt the portfolio visual identity standard (shared theme/branding) unless an exception is explicitly approved and recorded in module decisions.
- After meaningful report edits: run screenshot capture as needed, validate in Desktop, and update module memory.
- Archive retention for historical snapshots follows each module's documented policy.

## Naming Conventions

- Domain folders: PascalCase (`Finance`, `HR`, `Sales`, `Service`, `Marketing`).
- Company folders: short uppercase code (`CANON`, `PAPERENTITY`).
- PBIP stem: `<Company> <Report>` (for example `Canon Financial Report`), with `.pbip`, `.Report`, and `.SemanticModel` sharing it.
- Screenshot folder casing: `Records/screenshots` only.

## Migration Guidance

- Existing domain modules can align incrementally.
- Create contract folders first, then move/normalize assets with minimal disruption.
- Mark deprecated paths with README notes before deleting.
