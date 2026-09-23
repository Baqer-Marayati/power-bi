# Reporting Hub

Reporting Hub is a domain-first reporting portfolio for multi-company Power BI work.

The repository is organized so a new contributor or model can answer two questions quickly:
- what the portfolio contains right now
- where the editable source of truth lives for the module in scope

## Quick Orientation

- Repository root = portfolio coordination, standards, shared memory, and onboarding.
- `Fabric/` = every report definition, laid out like the Power BI workspaces. Edit `Fabric/DevelopmentWorkspace/`; `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` mirror what is live. See [`Fabric/README.md`](Fabric/README.md).
- `Reports/<Domain>/` = report module: docs, project memory, company config, and scripts.
- `Portfolio/Shared/` = reusable assets, templates, themes, and cross-report tooling.
- `Portfolio/Memory/` = cross-report truth, current focus, decisions, and cataloging.

## Current Portfolio Reality

See these files first:
- [`Portfolio/Memory/REPORT_CATALOG.md`](Portfolio/Memory/REPORT_CATALOG.md) for authoritative module status
- [`Portfolio/Memory/ACTIVE_FOCUS.md`](Portfolio/Memory/ACTIVE_FOCUS.md) for the current starting point and canonical PBIP paths

Active modules today:
- `Reports/Finance`
- `Reports/Sales`
- `Reports/Service`
- `Reports/Inventory`

Scaffolded modules:
- `Reports/HR`
- `Reports/Marketing`

Parked modules:
- `Reports/DataExchange`

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

- Edit reports only in `Fabric/DevelopmentWorkspace/`. Publish to Canon Analytics or Paper Analytics with `Portfolio/scripts/fabric_release.py`, which also updates the live mirror folders.
- Do not put report copies under `Reports/*/Companies/`; that folder holds company config and overlays only.
- Keep stable onboarding/process docs in `Portfolio/docs/` and module `Module/docs/`.
- Keep live portfolio truth in `Portfolio/Memory/` and live module truth in `Module/Project Memory/`.
- Review happens in the Fabric Development Workspace after a Git sync. Nothing goes live until the owner names the report to publish.

## Module Contract

All domain modules follow the baseline contract in:
- [`Portfolio/Shared/Standards/report-module-contract.md`](Portfolio/Shared/Standards/report-module-contract.md)

## Contribution Guide

Use the portfolio-level contribution process in:
- [`Portfolio/CONTRIBUTING.md`](Portfolio/CONTRIBUTING.md)
