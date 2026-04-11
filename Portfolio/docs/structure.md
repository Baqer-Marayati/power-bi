# Repository Structure

## Root Layer

The repository root is now the portfolio layer, not a single-report project folder.

## Main Areas

### `Reports`

Contains one folder per report module.

Current modules:
- `Finance` (active)
- `DataExchange` (active exchange workspace)
- `Sales`, `Service`, `Inventory` (active PBIP modules)
- `HR`, `Marketing` (scaffolded)

Active PBIPs are under each module's `Companies/<CODE>/` (see `../Memory/REPORT_CATALOG.md` and `../Memory/ACTIVE_FOCUS.md` for real folder names).

### `Portfolio/Shared`

Contains reusable material shared across multiple report modules.

### `Portfolio/Memory`

Contains cross-report truth, current routing, decisions, and planning context.

### `Portfolio/docs`

Contains stable portfolio-level orientation and architecture docs.

### `Portfolio/Archive`

Contains retired or historical portfolio-level material.

### `Reports/<Domain>/Module`

Contains the stable non-company scaffolding for a module:
- `Core/`
- `docs/`
- `Project Memory/`
- `scripts/`
- `Records/`
- `Archive/`

## Navigation Rule

If the task is about one report, go into that report module.
If the task is about standards, shared assets, or multi-report planning, stay at the portfolio layer.

## Contract Rule

All report modules should align to:
- `../Shared/Standards/report-module-contract.md`
