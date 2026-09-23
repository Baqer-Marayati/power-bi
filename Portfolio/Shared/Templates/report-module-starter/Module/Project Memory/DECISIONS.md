# Decisions

## Purpose

Use this file for approved directions and durable constraints in the <REPORT_TITLE> module.

## Portfolio visual identity (required baseline)

Before module-specific styling:

- Read `Shared/Standards/portfolio-visual-identity.md` and `Shared/Standards/page-layout-spec.md`.
- Use `Shared/Standards/portfolio-theme.tokens.json` when generating or adjusting themes.
- Canonical theme JSON copy: `Shared/Themes/Custom_Theme49412231581938193.json` (register under the PBIP’s `StaticResources/RegisteredResources/`; see Finance `report.json`).

Document any **intentional** deviation here with rationale.

## Source of truth

- Editable master: `Fabric/DevelopmentWorkspace/<Company> <REPORT_TITLE>.pbip` (one report per company).
- Review in the Fabric Development Workspace; publish with `Portfolio/scripts/fabric_release.py`. There is no zip packaging step.

## Examples of other decisions to record

- Data source system of record (SAP schema, files, etc.)
- Company-specific config under `Companies/<CompanyCode>/config/`
- Naming conventions for visuals if they differ from Finance (`label_*`, `slicer_*`, …)
