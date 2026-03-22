# Portfolio Foundation

## Purpose

This file gives a fast, practical overview of how the overall reporting portfolio is organized.

Use it to understand:
- what the repository root means
- where shared assets belong
- where report-specific work belongs
- how to navigate without confusing active work and archived history

## Top-Level Meaning

- `Reports/`
  - one folder per report domain
- `Shared/`
  - cross-report templates, themes, data contracts, SQL, DAX patterns, and reusable benchmarks
- `Portfolio Memory/`
  - portfolio-wide decisions, status, and cataloging
- `docs/`
  - stable portfolio-level onboarding and architecture docs
- `Archive/`
  - retired or historical portfolio-level material

## Design Principle

The repository should answer two different questions cleanly:

1. How does the reporting ecosystem work?
2. How does this specific report work?

The root answers question 1.
Each report module answers question 2.

## Current Active Module

Current live module:
- `Reports/Finance`

Current active editable PBIP:
- `Reports/Finance/Financial Report/Financial Report.pbip`

## Structure Rules

- Put report-specific files inside the relevant `Reports/<Department>/` folder.
- Put reusable cross-report material in `Shared/`.
- Put portfolio-wide decisions in `Portfolio Memory/`.
- Put old or superseded material in clearly labeled archive folders.
- Avoid mixed folders like `old`, `misc`, `backup2`, or `final final`.

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
