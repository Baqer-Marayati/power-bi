# Data Export Workspace Module

This module is an isolated PBIP workspace used only for data-export operations, separate from the live Finance report module.

## Purpose

Use this module for:
- one-time or repeatable export-only PBIP operations
- safe refresh-and-export workflows that must not alter `Reports/Finance`
- module-specific memory for export operations

## Expected Working Areas

- `Data Exchange Report/` (isolated PBIP used for exports only)
- `docs/`
- `Project Memory/`
- `Exports/`
- `Records/`
- `Archive/`

## Start Here

Read these in order:
- [`AGENTS.md`](AGENTS.md)
- [`docs/foundation.md`](docs/foundation.md)
- [`docs/quickstart.md`](docs/quickstart.md)
- [`Project Memory/PROJECT_DNA.md`](Project%20Memory/PROJECT_DNA.md)
- [`Project Memory/DECISIONS.md`](Project%20Memory/DECISIONS.md)
- [`Project Memory/CURRENT_STATUS.md`](Project%20Memory/CURRENT_STATUS.md)

## Source Of Truth

- The PBIP used for exports is: `Data Exchange Report/Data Exchange Report.pbip`.
- This module is intentionally decoupled from the live Finance module.
- Do not edit files in `Reports/Finance` when working in this module.
