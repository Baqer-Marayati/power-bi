# Portfolio Foundation

## Purpose

This file gives a fast, practical overview of how the overall reporting portfolio is organized.

Use it to understand:
- what the repository root means
- where shared assets belong
- where report-specific work belongs
- how to navigate without confusing active work and archived history
- how multi-domain, multi-company reporting is expected to scale

## Top-Level Meaning

- `Reports/`
  - one folder per report domain
- `../Shared/`
  - cross-report templates, themes, data contracts, SQL, DAX patterns, and reusable benchmarks
- `../Memory/`
  - portfolio-wide decisions, status, and cataloging
- `./` (this folder)
  - stable portfolio-level onboarding and architecture docs
- `../Archive/`
  - retired or historical portfolio-level material

## Design Principle

The repository should answer two different questions cleanly:

1. How does the reporting ecosystem work?
2. How does this specific report work?

The root answers question 1.
Each report module answers question 2.

## Module State Snapshot

See `../Memory/REPORT_CATALOG.md` for the authoritative list.

- Active production module: `Reports/Finance`
- Active exchange module: `Reports/DataExchange`
- Additional active PBIP modules: `Reports/Sales`, `Reports/Service`, `Reports/Inventory`
- Scaffolded modules: `Reports/HR`, `Reports/Marketing`

Examples of active editable PBIP entry points (repeat per company code, e.g. **CANON** and **PAPERENTITY**):
- `Reports/Finance/Companies/<CODE>/Financial Report - <CODE>/Financial Report - <CODE>.pbip`
- `Reports/Sales/Companies/<CODE>/Sales Report - <CODE>/Sales Report - <CODE>.pbip`
- `Reports/Service/Companies/<CODE>/Service Report - <CODE>/Service Report - <CODE>.pbip`
- `Reports/Inventory/Companies/<CODE>/Inventory Report - <CODE>/Inventory Report - <CODE>.pbip`
- `Reports/DataExchange/Companies/<CODE>/Data Exchange Report - <CODE>/Data Exchange Report - <CODE>.pbip`

## Structure Rules

- Put report-specific files inside the relevant `Reports/<Department>/` folder.
- Put reusable cross-report material in `../Shared/`.
- Put portfolio-wide decisions in `../Memory/`.
- Put old or superseded material in clearly labeled archive folders.
- Avoid mixed folders like `old`, `misc`, `backup2`, or `final final`.
- Follow the module contract in `../Shared/Standards/report-module-contract.md`.

## First Encounter

For first-time navigation, use:
- `first-encounter.md`

## Archive Rule

Archive by meaning, not by hiding.

Good archive names should include:
- date
- subject
- status

Example:
- `2026-03-22_sales-template-v1_superseded`

## Future Growth

This portfolio is intentionally ready for:
- `Reports/HR`
- `Reports/Sales`
- `Reports/Service`
- `Reports/Inventory`
- `Reports/Logistics`

Create those only when they become real working modules.
