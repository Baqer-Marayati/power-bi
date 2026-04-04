# Data Export Workspace Module

This module is an isolated PBIP workspace used only for data-export operations, separate from the live Finance report module.

## Purpose

Use this module for:
- one-time or repeatable export-only PBIP operations
- safe refresh-and-export workflows that must not alter `Reports/Finance`
- module-specific memory for export operations

## Expected Working Areas

- `Companies/CANON/` — **Canon Data Exchange Report** PBIP (primary export workspace)
- `Companies/PAPERENTITY/` — **Paper Data Exchange Report** PBIP (second copy)
- `Module/` — container for module internals:
  - `Module/Core/` — shared baseline assets (when present)
  - `Module/docs/`
  - `Module/Project Memory/`
  - `Module/scripts/`
  - `Module/Records/`
  - `Module/Archive/`

## Start Here

Read these in order:
- [`AGENTS.md`](AGENTS.md)
- [`Module/docs/foundation.md`](Module/docs/foundation.md)
- [`Module/docs/quickstart.md`](Module/docs/quickstart.md)
- [`Module/Project Memory/PROJECT_DNA.md`](Module/Project%20Memory/PROJECT_DNA.md)
- [`Module/Project Memory/DECISIONS.md`](Module/Project%20Memory/DECISIONS.md)
- [`Module/Project Memory/CURRENT_STATUS.md`](Module/Project%20Memory/CURRENT_STATUS.md)

## Source Of Truth

- **Primary PBIP:** `Companies/CANON/Canon Data Exchange Report/Canon Data Exchange Report.pbip`
- **Alternate copy:** `Companies/PAPERENTITY/Paper Data Exchange Report/Paper Data Exchange Report.pbip`

This module is intentionally decoupled from the live Finance module. Work directly from PBIP; there is no `ready.zip` or server-package export step here. Do not edit files in `Reports/Finance` when working in this module.
