# Service Performance Report Module

This module is the working home for the Service Performance Report inside the larger Reporting Hub portfolio.

## Purpose

Use this module for:
- report-specific PBIP work
- report-specific project memory
- department-specific documentation
- records and archives (as needed)

## Expected Working Areas

- `Companies/` — **CANON** company settings (`config/`, `overlays/`); report files live under `Fabric/`
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

- **Primary PBIP (edit):** `Fabric/DevelopmentWorkspace/Canon Service Report.pbip`
- **Live copy:** none. Removed from Canon Analytics on 24 Sep 2026. The next publish uses `--create`.
- **Parked:** Paper Service Report, under `Module/Archive/2026-09-24-parked-reports/PAPERENTITY/` (not in any workspace)

Paths under `Fabric/` are repo-root-relative. Work directly from PBIP and review in the Fabric Development Workspace; there is no `ready.zip` or server-package export step in this module. Publish with `Portfolio/scripts/fabric_release.py`.
