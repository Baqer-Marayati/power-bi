# Active Focus

## Current default starting point

If a new model opens this repository without any extra context, assume the default deep-work target is:
- `Reports/Finance`

Start with:
1. `Portfolio/Memory/REPORT_CATALOG.md`
2. `Reports/Finance/README.md`
3. `Reports/Finance/AGENTS.md`
4. `Reports/Finance/Module/Project Memory/CURRENT_STATUS.md`
5. `Reports/Finance/Module/Project Memory/DECISIONS.md`

## Canonical active PBIP entry paths

Edit these. They are the Git-connected Development Workspace copies:

- Finance
  - `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip`
  - `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip`
- Sales
  - `Fabric/DevelopmentWorkspace/Canon Sales Report.pbip`
- Service
  - `Fabric/DevelopmentWorkspace/Canon Service Report.pbip`
- Inventory
  - `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip`
  - `Fabric/DevelopmentWorkspace/Paper Inventory Report.pbip`

What is live is mirrored, read-only, in `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/`. Publishing is `Portfolio/scripts/fabric_release.py`; see `Fabric/README.md`.

Parked (not in any workspace): Paper Sales, Paper Service, and both Data Exchange reports, under each module's `Module/Archive/2026-09-24-parked-reports/`.

## Current working assumptions

- `Reports/Finance` remains the primary production module.
- `Reports/DataExchange` is parked. Its two reports are in `Reports/DataExchange/Module/Archive/2026-09-24-parked-reports/`.
- **Inventory:** page tab names (May 2026) are Inventory Overview, Stock Value, Stock Health, Stock Actions, Landed Cost. See `Reports/Inventory/Module/Project Memory/DECISIONS.md`.
- PAPERENTITY is a permanent second company for Finance and Inventory, not a temporary experiment.
- Do not rename `Fabric/DevelopmentWorkspace/`; the Fabric Git connection points at it.
