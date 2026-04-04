# Reporting Hub

Reporting Hub is a **domain-first reporting portfolio** designed for multi-company, multi-report development.

The repository is optimized for:
- repeatable report module onboarding (`Finance`, `DataExchange`, `HR`, `Sales`, `Service`, `Marketing`, `Inventory`, …)
- consistent agent/model navigation on first encounter
- clear separation between source-of-truth PBIP work (per company under `Companies/<CODE>/`), shared assets, and optional records (screenshots, archives)

## Quick Orientation

- Portfolio root = orchestration, standards, and cross-report context.
- `Reports/<Domain>/` = domain module where report work happens.
- `Portfolio/Shared/` = reusable assets and templates used by multiple domains.
- `Portfolio/Memory/` = cross-report decisions, catalog, and active status.

## Domain Modules

Current module state (see `Portfolio/Memory/REPORT_CATALOG.md` for detail):
- `Reports/Finance` — Active production module
- `Reports/DataExchange` — Active exchange workspace
- `Reports/Sales`, `Reports/Service`, `Reports/Inventory` — Active PBIP modules
- `Reports/HR`, `Reports/Marketing` — Scaffolded

## Start Here (First Encounter)

Read in this order:
1. [`AGENTS.md`](AGENTS.md)
2. [`Portfolio/docs/foundation.md`](Portfolio/docs/foundation.md)
3. [`Portfolio/docs/portfolio-architecture.md`](Portfolio/docs/portfolio-architecture.md)
4. [`Portfolio/docs/structure.md`](Portfolio/docs/structure.md)
5. [`Portfolio/docs/first-encounter.md`](Portfolio/docs/first-encounter.md)
6. [`Portfolio/docs/agent-operating-playbook.md`](Portfolio/docs/agent-operating-playbook.md)
7. [`Portfolio/docs/ai-index.md`](Portfolio/docs/ai-index.md)
8. [`Portfolio/Memory/REPORT_CATALOG.md`](Portfolio/Memory/REPORT_CATALOG.md)
9. [`Portfolio/Memory/CURRENT_STATUS.md`](Portfolio/Memory/CURRENT_STATUS.md)

Then open the target domain module (for example `Reports/Finance`).

## Working Rules

- Keep source-of-truth edits in PBIP folders inside the relevant domain module.
- Keep shared standards/templates in `Portfolio/Shared/` (no live status logs there).
- Keep domain status/decisions in each module's `Project Memory/`.
- Keep portfolio-wide truth in `Portfolio/Memory/`.
- Validate and review in Power BI Desktop from the company PBIP folders under each module’s `Companies/<CODE>/` (no zip packaging step).

## Module Contract

All domain modules follow the standard contract in:
- [`Portfolio/Shared/Standards/report-module-contract.md`](Portfolio/Shared/Standards/report-module-contract.md)

This contract defines required folders, company layering, PBIP layout under `Companies/<CODE>/`, and automation expectations.

## Contribution Guide

Use the portfolio-level process in:
- [`Portfolio/CONTRIBUTING.md`](Portfolio/CONTRIBUTING.md)
