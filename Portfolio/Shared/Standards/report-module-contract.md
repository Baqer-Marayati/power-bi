# Report Module Contract

This standard defines the minimum folder contract for all domain modules under `Reports/` (for example `Finance`, `HR`, `Sales`, `Service`, `Marketing`).

## Goals

- Keep module structure consistent across domains.
- Support multiple companies per domain with moderate isolation.
- Keep source-of-truth PBIP work in clear, repeatable paths under `Companies/<CompanyCode>/`.
- Make automation predictable (capture, retention, validation).

## Required Module Structure

Each domain module must include:

```text
Reports/<Domain>/
  AGENTS.md
  README.md
  Companies/
  Module/
    Core/
    docs/
    Project Memory/
    scripts/
    Records/
    Archive/
```

## Company PBIP layout

Active report projects live **per company** under:

```text
Companies/<CompanyCode>/<ActualReportFolder>/
  <ActualReportFolder>.pbip
  <ActualReportFolder>.Report/
  <ActualReportFolder>.SemanticModel/
```

Example codes in this portfolio: **CANON**, **PAPERENTITY** (Paper Company). Add additional `Companies/<CODE>/` folders as needed.
Use the real business/report folder name for that module; do not assume every module follows a synthetic `<ReportName> - <CompanyCode>` pattern.

## Folder Responsibilities

- `Core/`
  - Shared domain baseline assets that are **not** company-specific:
    - shared semantic fragments, reusable patterns, documentation assets.
  - Company-scoped PBIPs belong under `Companies/`, not in `Core/`.
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

- PBIP under `Companies/<CompanyCode>/.../` is the editable source of truth.
- Review and sign-off happen in **Power BI Desktop** from that PBIP.
- Modules may add a review/package artifact flow if the module memory explicitly documents it; that does not replace PBIP as source of truth.
- Modules must adopt the portfolio visual identity standard (shared theme/branding) unless an exception is explicitly approved and recorded in module decisions.
- After meaningful report edits: run screenshot capture as needed, validate in Desktop, and update module memory.
- Archive retention for historical snapshots follows each module's documented policy.

## Naming Conventions

- Domain folders: PascalCase (`Finance`, `HR`, `Sales`, `Service`, `Marketing`).
- Company folders: short uppercase code (`CANON`, `PAPERENTITY`).
- Report folder and PBIP stem: use the real module/company business name and keep the `.pbip`, `.Report`, and `.SemanticModel` stem aligned within that folder.
- Screenshot folder casing: `Records/screenshots` only.

## Migration Guidance

- Existing domain modules can align incrementally.
- Create contract folders first, then move/normalize assets with minimal disruption.
- Mark deprecated paths with README notes before deleting.
