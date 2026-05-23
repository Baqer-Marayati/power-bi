# Agent Guide

This file is the AI entrypoint for the Inventory Report module.

## Read Order

1. `README.md`
2. `Module/docs/foundation.md`
3. `Module/Project Memory/PROJECT_DNA.md`
4. `Module/Project Memory/DECISIONS.md`
5. `Module/Project Memory/CURRENT_STATUS.md`
6. `Module/Project Memory/NEXT_STEPS.md`
7. `Module/Project Memory/REFERENCE.md`

Then inspect the active project files (per company under `Companies/`):

- `Companies/CANON/Canon Inventory Report/Canon Inventory Report.pbip`
- **Fabric sync copy:** `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip` (edit here for Fabric-bound passes)

`Companies/PAPERENTITY/` holds the **Paper Inventory Report** PBIP for the second tenant copy.

For Inventory PBIP work, also load the Codex skill `powerbi-inventory-report` when available.

## Module Rules

- Keep report-specific truth inside this module.
- Put only shared cross-report assets in the portfolio `Portfolio/Shared/` layer.
- Archive completed one-off prompts/handoffs under `Module/Archive/` — do not leave them in active `Project Memory/`.
- PBIPs live under `Companies/CANON/` and `Companies/PAPERENTITY/`; work directly from PBIP (no zip packaging workflow).
