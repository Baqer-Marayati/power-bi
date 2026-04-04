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

Then inspect the active project files (per company under `Companies/`):

- `Companies/CANON/Canon Data Exchange Report/Canon Data Exchange Report.pbip`
- `Module/Core/` — shared baseline assets for this module (when present)

`Companies/PAPERENTITY/` holds the **Paper Data Exchange Report** PBIP for the second tenant copy.

## Module Rules

- Keep export-workflow truth inside this module.
- This module exists to avoid touching `Reports/Finance` during export setup.
- Put shared cross-report data-drop assets in `Portfolio/Shared/Data Drops/`.
- Archive historical material explicitly instead of mixing it into active work folders.
- PBIPs live under `Companies/CANON/` and `Companies/PAPERENTITY/`; work directly from PBIP (no zip packaging workflow).
