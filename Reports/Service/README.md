# Service Performance Report Module

This module is the working home for the Service Performance Report inside the larger Reporting Hub portfolio.

## Purpose

Use this module for:
- report-specific PBIP work
- report-specific project memory
- department-specific documentation
- records and archives (as needed)

## Expected Working Areas

- `Companies/` — **CANON** and **PAPERENTITY** each contain a PBIP (CANON: `Canon Service Report/`; PAPERENTITY: `Paper Service Report/`) plus `config/` and `overlays/` (CANON already has `config/`)
- `Module/` — container for module internals:
  - `Module/docs/`
  - `Module/Project Memory/`
  - `Module/Core/`
  - `Module/scripts/`
  - `Module/Records/`
  - `Module/Archive/`

## Start Here

Read these in order:
- [`AGENTS.md`](AGENTS.md)
- [`Module/docs/foundation.md`](Module/docs/foundation.md)
- [`Module/Project Memory/PROJECT_DNA.md`](Module/Project%20Memory/PROJECT_DNA.md)
- [`Module/Project Memory/DECISIONS.md`](Module/Project%20Memory/DECISIONS.md)
- [`Module/Project Memory/CURRENT_STATUS.md`](Module/Project%20Memory/CURRENT_STATUS.md)

## Source Of Truth

- **Primary PBIP:** `Companies/CANON/Canon Service Report/Canon Service Report.pbip`
- **Alternate copy:** `Companies/PAPERENTITY/Paper Service Report/Paper Service Report.pbip`

Work directly from PBIP; there is no `ready.zip` or server-package export step in this module.
