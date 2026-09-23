# Portfolio Current Status

## Date

- Last updated: September 24, 2026

## Current reality

- The repo is a portfolio. `Reports/Finance` is the default deep-work module.
- Active modules: Finance (Canon, Paper), Inventory (Canon, Paper), Sales (Canon), Service (Canon). `Reports/DataExchange` is parked.
- `Reports/HR` and `Reports/Marketing` are scaffolds from 24 March 2026. They have no PBIP yet.
- Mac root: `/Users/baqer/Code/Power BI`. Windows checkout: `C:\Work\reporting-hub`. GitHub `main` is the shared copy.
- `History` and `Models` are outside this repo.
- Fabric tenant baseline (29 Aug 2026, East Asia, unedited snapshot): `FABRIC_TENANT_REGION_MIGRATION_BASELINE_2026-08-29.md`.

## Repo layout (24 Sep 2026)

The repo now mirrors the three Power BI workspaces. Full procedure: `Fabric/README.md`.

- `Fabric/DevelopmentWorkspace/` is Git-connected and is the only place report edits happen.
- `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` mirror what is live. Only `Portfolio/scripts/fabric_release.py` writes them.
- The report copies under `Reports/*/Companies/` were removed. Those folders keep `config/` and `overlays/` only.
- Paper Sales, Paper Service, and both Data Exchange reports are parked in their module's `Module/Archive/2026-09-24-parked-reports/`.

## What is live

All six reports match their live workspace. `fabric_release.py status` confirmed it on 24 Sep 2026, comparing content and ignoring formatting-only differences.

- Canon Analytics: Canon Financial, Canon Inventory, Canon Sales, Canon Service.
- Paper Analytics: Paper Financial, Paper Inventory.
- Canon Service went live on 24 Sep 2026, published by the API. Its scheduled refresh is still off.
- Every live model is on the B1HANA connection (`SAPB1_GATEWAY`).
- The release tool was tested end to end on 24 Sep 2026 with an in-place republish of Canon Service. The report link stayed the same, the gateway held, the refresh completed, and live matched the mirror afterwards.

New Canon Financial FX tables and the 19 Sep Canon Sales trace columns stay empty until those production models refresh.

## Standards already in force

- Number format, KPI units, and the retired `* Card Display` pattern: `Portfolio/Shared/Standards/fabric-reports-number-formatting.md`.
- Layout and typography: `Portfolio/Shared/Standards/fabric-reports-layout-standard.md`.
- Strict check on every push: `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`.
- Publish to Canon Analytics or Paper Analytics only with `Portfolio/scripts/fabric_release.py`, and only when the user names the report.

Do not recreate `* Card Display` measures on the Fabric fleet. The parked Paper Sales and Data Exchange models still contain the older helpers.

## Routing

- `REPORT_CATALOG.md` — which reports exist.
- `ACTIVE_FOCUS.md` — exact PBIP paths.
- `Fabric/workspaces.json` and `Fabric/RELEASES.md` — live IDs and the publish log.
- Each report’s live notes: `Reports/<Name>/Module/Project Memory/`.
- One-off prompts and discovery scripts belong in that module’s `Archive/`, not in active memory.

## Working-tree cleanup (23 Sep 2026)

- 149 April Finance screenshots were untracked. They remain on this machine under `Reports/Finance/Module/Records/screenshots/` and are gitignored.
- The three March Finance PBIP snapshots were removed from the tree. Restore steps are in `Reports/Finance/Module/Archive/README.md` (commit `2ba401a2`).
- No company PBIP and no Fabric report file was edited in that cleanup.
