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

Then inspect the active project files (repo-root-relative; edit only the `Fabric/DevelopmentWorkspace/` copy):

- `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip`
- `Fabric/DevelopmentWorkspace/Paper Inventory Report.pbip` (second tenant)

Live copies are read-only mirrors in `Fabric/CanonAnalytics/Canon Inventory Report.*` and `Fabric/PaperAnalytics/Paper Inventory Report.*`, written only by `Portfolio/scripts/fabric_release.py`. `Companies/<CODE>/` in this module holds company `config/` and `overlays/` only.

For Inventory PBIP work, also load the Codex skill `powerbi-inventory-report` when available.

## Module Rules

- Keep report-specific truth inside this module.
- Put only shared cross-report assets in the portfolio `Portfolio/Shared/` layer.
- Archive completed one-off prompts/handoffs under `Module/Archive/` — do not leave them in active `Project Memory/`.
- PBIPs live under `Fabric/DevelopmentWorkspace/`; work directly from PBIP (no zip packaging workflow). After edits, run `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`, commit, and push for Fabric review. Publish only when the user names the report: `python3 Portfolio/scripts/fabric_release.py publish "<Report Name>"` (dry run), then `--apply`.
