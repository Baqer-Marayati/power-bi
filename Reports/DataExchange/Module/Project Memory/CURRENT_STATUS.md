# Current Status

## Date

- Last updated: September 24, 2026

## Current Reality

- Sep 24, 2026 — repo restructured to mirror the workspaces (edit `Fabric/DevelopmentWorkspace/`, publish with `Portfolio/scripts/fabric_release.py`). This module is parked: neither Data Exchange report is in a workspace, and both PBIPs, with their config and overlays, moved to `Reports/DataExchange/Module/Archive/2026-09-24-parked-reports/` (`CANON/Canon Data Exchange Report/` and `PAPERENTITY/Paper Data Exchange Report/`).
- Module created as an isolated export workspace.
- Parked Canon PBIP: `Module/Archive/2026-09-24-parked-reports/CANON/Canon Data Exchange Report/Canon Data Exchange Report.pbip`
- Parked Paper PBIP: `Module/Archive/2026-09-24-parked-reports/PAPERENTITY/Paper Data Exchange Report/Paper Data Exchange Report.pbip`
- This module is intentionally separated from `Reports/Finance` to prevent accidental impact on the live Finance report.
- Report navigation uses a **single** page (`Data Export Pack`). Legacy copied Finance page folders that were not listed in `pages.json` were removed from `definition/pages/` to reduce noise (no change to the active page or semantic model).
