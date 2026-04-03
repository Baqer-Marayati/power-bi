# Reporting Hub

Reporting Hub is a **domain-first reporting portfolio** designed for multi-company, multi-report development.

The repository is optimized for:
- repeatable report module onboarding (`Finance`, `DataExchange`, `HR`, `Sales`, `Service`, `Marketing`, `Inventory`, …)
- consistent agent/model navigation on first encounter
- clear separation between source-of-truth PBIP work, shared assets, and review artifacts

## Quick Orientation

- Portfolio root = orchestration, standards, and cross-report context.
- `Reports/<Domain>/` = domain module where report work happens.
- `Shared/` = reusable assets and templates used by multiple domains.
- `Portfolio Memory/` = cross-report decisions, catalog, and active status.

## Domain Modules

Current module state (see `Portfolio Memory/REPORT_CATALOG.md` for detail):
- `Reports/Finance` — Active production module
- `Reports/DataExchange` — Active exchange workspace
- `Reports/Sales`, `Reports/Service`, `Reports/Inventory` — Active PBIP modules
- `Reports/HR`, `Reports/Marketing` — Scaffolded

## Start Here (First Encounter)

Read in this order:
1. [`AGENTS.md`](AGENTS.md)
2. [`docs/foundation.md`](docs/foundation.md)
3. [`docs/portfolio-architecture.md`](docs/portfolio-architecture.md)
4. [`docs/structure.md`](docs/structure.md)
5. [`docs/first-encounter.md`](docs/first-encounter.md)
6. [`docs/agent-operating-playbook.md`](docs/agent-operating-playbook.md)
7. [`docs/ai-index.md`](docs/ai-index.md)
8. [`Portfolio Memory/REPORT_CATALOG.md`](Portfolio%20Memory/REPORT_CATALOG.md)
9. [`Portfolio Memory/CURRENT_STATUS.md`](Portfolio%20Memory/CURRENT_STATUS.md)

Then open the target domain module (for example `Reports/Finance`).

## Working Rules

- Keep source-of-truth edits in PBIP folders inside the relevant domain module.
- Keep shared standards/templates in `Shared/` (no live status logs there).
- Keep domain status/decisions in each module's `Project Memory/`.
- Keep portfolio-wide truth in `Portfolio Memory/`.
- Rebuild packaged review artifacts after meaningful report edits.

## Module Contract

All domain modules follow the standard contract in:
- [`Shared/Standards/report-module-contract.md`](Shared/Standards/report-module-contract.md)

This contract defines required folders, archive style, company layering, and automation expectations.

## Contribution Guide

Use the portfolio-level process in:
- [`CONTRIBUTING.md`](CONTRIBUTING.md)
