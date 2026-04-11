# Reporting Hub

Reporting Hub is a domain-first reporting portfolio for multi-company Power BI work.

The repository is organized so a new contributor or model can answer two questions quickly:
- what the portfolio contains right now
- where the editable source of truth lives for the module in scope

## Quick Orientation

- Repository root = portfolio coordination, standards, shared memory, and onboarding.
- `Reports/<Domain>/` = self-contained report module.
- `Portfolio/Shared/` = reusable assets, templates, themes, and cross-report tooling.
- `Portfolio/Memory/` = cross-report truth, current focus, decisions, and cataloging.

## Current Portfolio Reality

See these files first:
- [`Portfolio/Memory/REPORT_CATALOG.md`](Portfolio/Memory/REPORT_CATALOG.md) for authoritative module status
- [`Portfolio/Memory/ACTIVE_FOCUS.md`](Portfolio/Memory/ACTIVE_FOCUS.md) for the current starting point and canonical PBIP paths

Active modules today:
- `Reports/Finance`
- `Reports/DataExchange`
- `Reports/Sales`
- `Reports/Service`
- `Reports/Inventory`

Scaffolded modules:
- `Reports/HR`
- `Reports/Marketing`

## Start Here

The authoritative read order lives in [`AGENTS.md`](AGENTS.md).

Recommended first-encounter flow:
1. [`AGENTS.md`](AGENTS.md)
2. [`Portfolio/docs/foundation.md`](Portfolio/docs/foundation.md)
3. [`Portfolio/docs/portfolio-architecture.md`](Portfolio/docs/portfolio-architecture.md)
4. [`Portfolio/docs/structure.md`](Portfolio/docs/structure.md)
5. [`Portfolio/docs/first-encounter.md`](Portfolio/docs/first-encounter.md)
6. [`Portfolio/docs/agent-operating-playbook.md`](Portfolio/docs/agent-operating-playbook.md)
7. [`Portfolio/docs/ai-index.md`](Portfolio/docs/ai-index.md)
8. [`Portfolio/Memory/REPORT_CATALOG.md`](Portfolio/Memory/REPORT_CATALOG.md)
9. [`Portfolio/Memory/ACTIVE_FOCUS.md`](Portfolio/Memory/ACTIVE_FOCUS.md)
10. [`Portfolio/Memory/CURRENT_STATUS.md`](Portfolio/Memory/CURRENT_STATUS.md)
11. [`Portfolio/Memory/DECISIONS.md`](Portfolio/Memory/DECISIONS.md)

Then open the target module, starting with that module's `README.md`, `AGENTS.md`, and `Module/Project Memory/`.

## Working Rules

- Keep editable report sources in PBIP folders under the relevant module's `Companies/<CODE>/`.
- Do not assume a synthetic folder pattern such as `<ReportName> - <CODE>`; use the module docs or `REPORT_CATALOG.md` for the real company folder names.
- Keep stable onboarding/process docs in `Portfolio/docs/` and module `Module/docs/`.
- Keep live portfolio truth in `Portfolio/Memory/` and live module truth in `Module/Project Memory/`.
- Follow each module's own review workflow. Some modules work directly from PBIP only; others also keep review/package artifacts.

## Module Contract

All domain modules follow the baseline contract in:
- [`Portfolio/Shared/Standards/report-module-contract.md`](Portfolio/Shared/Standards/report-module-contract.md)

## Contribution Guide

Use the portfolio-level contribution process in:
- [`Portfolio/CONTRIBUTING.md`](Portfolio/CONTRIBUTING.md)
