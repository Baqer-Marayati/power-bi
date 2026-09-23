# Repository Structure

## Root Layer

The repository root is now the portfolio layer, not a single-report project folder.

## Main Areas

### `Fabric`

Contains every report definition, laid out like the Power BI workspaces:
- `DevelopmentWorkspace/` is Git-connected to the Fabric Development Workspace. Edit reports here.
- `CanonAnalytics/` and `PaperAnalytics/` mirror what is live. Only `../scripts/fabric_release.py` writes them.
- `workspaces.json` holds the IDs, and `RELEASES.md` is the publish log.

See `../../Fabric/README.md` for the workflow.

### `Reports`

Contains one folder per report module.

Current modules:
- `Finance` (active)
- `Sales`, `Service`, `Inventory` (active)
- `HR`, `Marketing` (scaffolded)
- `DataExchange` (parked)

A module holds docs, project memory, company config (`Companies/<CODE>/config`, `overlays`), and scripts. Its reports live in `Fabric/` (see `../Memory/ACTIVE_FOCUS.md` for exact paths).

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
