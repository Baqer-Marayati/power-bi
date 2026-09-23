# Portfolio Current Status

## Date

- Last updated: September 23, 2026

## Current reality

- The repo is a portfolio. `Reports/Finance` is the default deep-work module.
- Active PBIP modules, each with CANON and PAPERENTITY copies: Finance, Sales, Service, Inventory, DataExchange.
- `Reports/HR` and `Reports/Marketing` are scaffolds from 24 March 2026. They have no PBIP yet.
- Mac root: `/Users/baqer/Code/Power BI`. Windows checkout: `C:\Work\reporting-hub`. GitHub `main` is the shared copy.
- `History` and `Models` are outside this repo.
- Fabric tenant baseline (29 Aug 2026, East Asia, unedited snapshot): `FABRIC_TENANT_REGION_MIGRATION_BASELINE_2026-08-29.md`.

## What matches production

On 23 September 2026 the user synced five Development Workspace reports into production, and those module PBIPs were mirrored from `Fabric/DevelopmentWorkspace` with 0 drift:

- Canon Financial, Canon Inventory, Canon Sales → Canon Analytics
- Paper Financial, Paper Inventory → Paper Analytics

For those five: **production = Development Workspace = `Fabric/DevelopmentWorkspace/` = the module PBIP.**

Canon Service stays development-only. Its semantic model matches the module copy. Its report definition differs in 59 visual files. Publishing it, or copying Fabric back over the module, is a separate step.

New Canon Financial FX tables and the 19 Sep Canon Sales trace columns stay empty until those production models refresh.

## Standards already in force

- Number format, KPI units, and the retired `* Card Display` pattern: `Portfolio/Shared/Standards/fabric-reports-number-formatting.md`.
- Layout and typography: `Portfolio/Shared/Standards/fabric-reports-layout-standard.md`.
- Strict check on every push: `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`.
- Copy Fabric definitions back to module homes with `Portfolio/scripts/sync-fabric-to-modules.py` (dry-run unless `--apply`).

Do not recreate `* Card Display` measures on the Fabric fleet. Paper Sales and both Data Exchange models still contain the older helpers, and Paper Sales still binds three of them. Leave those until a dedicated parity pass.

## Routing

- `REPORT_CATALOG.md` — which reports exist.
- `ACTIVE_FOCUS.md` — exact PBIP paths.
- Each report’s live notes: `Reports/<Name>/Module/Project Memory/`.
- One-off prompts and discovery scripts belong in that module’s `Archive/`, not in active memory.

## Working-tree cleanup (23 Sep 2026)

- 149 April Finance screenshots were untracked. They remain on this machine under `Reports/Finance/Module/Records/screenshots/` and are gitignored.
- The three March Finance PBIP snapshots were removed from the tree. Restore steps are in `Reports/Finance/Module/Archive/README.md` (commit `2ba401a2`).
- No company PBIP and no Fabric report file was edited in that cleanup.
