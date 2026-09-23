# Portfolio Foundation

## Purpose

This file gives a fast, practical overview of how the reporting portfolio is organized today.

Use it to understand:
- what the repository root means
- where shared assets belong
- where report-specific work belongs
- how to navigate without confusing active work and archived history
- how multi-domain, multi-company reporting is expected to scale

## Top-Level Meaning

- `Fabric/`
  - every report definition, laid out like the Power BI workspaces (`DevelopmentWorkspace/` to edit, `CanonAnalytics/` and `PaperAnalytics/` for what is live)
- `Reports/`
  - one folder per report domain: docs, memory, company config, scripts
- `Portfolio/Shared/`
  - cross-report templates, themes, data contracts, SQL, DAX patterns, screenshots, and reusable benchmarks
- `Portfolio/Memory/`
  - portfolio-wide decisions, current focus, status, and cataloging
- `Portfolio/docs/`
  - stable portfolio-level onboarding and architecture docs
- `Portfolio/Archive/`
  - retired or historical portfolio-level material

## Design Principle

The repository should answer two different questions cleanly:

1. How does the reporting ecosystem work?
2. How does this specific report work?

The portfolio layer answers question 1.
Each report module answers question 2.

## Module State Snapshot

The authoritative module list lives in `Portfolio/Memory/REPORT_CATALOG.md`.

- Active production focus: `Reports/Finance`
- Additional active modules: `Reports/Sales`, `Reports/Service`, `Reports/Inventory`
- Scaffolded modules: `Reports/HR`, `Reports/Marketing`
- Parked: `Reports/DataExchange`

For the exact current entry points, read `Portfolio/Memory/ACTIVE_FOCUS.md` before guessing company folder names.

Active PBIPs today (edit these):
- `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip`
- `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip`
- `Fabric/DevelopmentWorkspace/Canon Sales Report.pbip`
- `Fabric/DevelopmentWorkspace/Canon Service Report.pbip`
- `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip`
- `Fabric/DevelopmentWorkspace/Paper Inventory Report.pbip`

## Structure Rules

- Put report definitions only in `Fabric/DevelopmentWorkspace/`; never copy them into a module.
- Put report-specific docs, memory, and scripts inside the relevant `Reports/<Domain>/` module.
- Put reusable cross-report material in `Portfolio/Shared/`.
- Put portfolio-wide decisions and current routing in `Portfolio/Memory/`.
- Put old or superseded material in clearly labeled archive folders.
- Avoid mixed folders like `old`, `misc`, `backup2`, or `final final`.
- Follow the module contract in `Portfolio/Shared/Standards/report-module-contract.md`.

## First Encounter

For first-time navigation, use:
- `first-encounter.md`
- `ai-index.md`
- `../Memory/ACTIVE_FOCUS.md`

## Archive Rule

Archive by meaning, not by hiding.

Good archive names should include:
- date
- subject
- status

Example:
- `2026-03-22_sales-template-v1_superseded`

## Future Growth

This portfolio is intentionally ready for more domain modules.
Only treat a planned name as real when it is listed as Active or Scaffolded in `Portfolio/Memory/REPORT_CATALOG.md`.
