# Agent Guide

This file is the AI entrypoint for the Data Export Workspace module.

## Read Order

1. `README.md`
2. `Module/docs/foundation.md`
3. `Module/Project Memory/PROJECT_DNA.md`
4. `Module/Project Memory/DECISIONS.md`
5. `Module/Project Memory/CURRENT_STATUS.md`
6. `Module/Project Memory/NEXT_STEPS.md`
7. `Module/Project Memory/REFERENCE.md`

This module is **parked**: it has no active report, and neither PBIP is in a Fabric workspace. Both were moved, with their config and overlays, to `Module/Archive/2026-09-24-parked-reports/`:

- `Module/Archive/2026-09-24-parked-reports/CANON/Canon Data Exchange Report/Canon Data Exchange Report.pbip`
- `Module/Archive/2026-09-24-parked-reports/PAPERENTITY/Paper Data Exchange Report/Paper Data Exchange Report.pbip`
- `Module/Core/` — shared baseline assets for this module (when present)

To bring one back, copy its report into `Fabric/DevelopmentWorkspace/` (repo root) and add it to `Fabric/workspaces.json` before editing.

## Module Rules

- Keep export-workflow truth inside this module.
- This module exists to avoid touching `Reports/Finance` during export setup.
- Put shared cross-report data-drop assets in `Portfolio/Shared/Data Drops/`.
- Archive historical material explicitly instead of mixing it into active work folders.
- The parked PBIPs are history under `Module/Archive/`; do not edit them in place. If the module is revived, edit the copy in `Fabric/DevelopmentWorkspace/` and work directly from PBIP (no zip packaging workflow).
