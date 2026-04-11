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

- `Reports/`
  - one folder per report domain
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
- Active exchange workspace: `Reports/DataExchange`
- Additional active PBIP modules: `Reports/Sales`, `Reports/Service`, `Reports/Inventory`
- Scaffolded modules: `Reports/HR`, `Reports/Marketing`

For the exact current entry points, read `Portfolio/Memory/ACTIVE_FOCUS.md` before guessing company folder names.

Real active PBIP examples today:
- `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.pbip`
- `Reports/Finance/Companies/PAPERENTITY/Paper Financial Report/Paper Financial Report.pbip`
- `Reports/DataExchange/Companies/CANON/Canon Data Exchange Report/Canon Data Exchange Report.pbip`
- `Reports/Sales/Companies/CANON/Canon Sales Report/Canon Sales Report.pbip`
- `Reports/Service/Companies/CANON/Canon Service Report/Canon Service Report.pbip`
- `Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.pbip`

## Structure Rules

- Put report-specific files inside the relevant `Reports/<Domain>/` module.
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
