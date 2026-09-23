# Cleanup Inventory

## Date

- Last updated: September 23, 2026

## Purpose

This inventory classifies cleanup candidates before moving, deleting, or consolidating anything. Active PBIP project trios remain protected unless a dedicated migration task updates references and validates in Power BI Desktop.

## Protected No-Touch

- `Reports/Finance/Companies/CANON/Canon Financial Report/`
- `Reports/Finance/Companies/PAPERENTITY/Paper Financial Report/`
- `Reports/Sales/Companies/CANON/Canon Sales Report/`
- `Reports/Sales/Companies/PAPERENTITY/Paper Sales Report/`
- `Reports/Service/Companies/CANON/Canon Service Report/`
- `Reports/Service/Companies/PAPERENTITY/Paper Service Report/`
- `Reports/Inventory/Companies/CANON/Canon Inventory Report/`
- `Reports/Inventory/Companies/PAPERENTITY/Paper Inventory Report/`
- `Reports/DataExchange/Companies/CANON/Canon Data Exchange Report/`
- `Reports/DataExchange/Companies/PAPERENTITY/Paper Data Exchange Report/`
- `Reports/Finance/Module/Design Benchmarks/Sample 2/`

## Safe Doc Edits

- Finance docs that still describe `Financial Report/Financial Report.pbip` as the active master should be rewritten to point to `Reports/Finance/Companies/<CODE>/<Actual Report Folder>/`.
- Finance package policy is direct PBIP review. Remove stale `ready.zip` / `package-report.sh` requirements from Finance docs, templates, and memory.
- Template docs should stop implying a synthetic `<ReportTitle> - <CompanyCode>` folder is mandatory and should describe `Companies/<CODE>/<Actual Report Folder>/`.
- Records docs should use lowercase `Records/screenshots`.

## Safe Script Edits

- `Portfolio/scripts/clear-model-cache.ps1` should resolve company PBIP paths from a module manifest when present and remove only `.pbi/cache.abf`.
- `Reports/Finance/Module/scripts/clear-model-cache.ps1` should call the portfolio script from the repo root and support company selection.
- `Reports/Finance/Module/scripts/capture-pages.ps1` should default to real Finance company PBIPs and `Module/Records/screenshots`.
- `.vscode/tasks.json` can keep task entrypoints but should avoid old report-root assumptions.
- `package-report.sh` should not be recreated for Finance unless the policy changes; current Finance done criteria do not require generated package artifacts.

## Safe Moves With Reference Updates

- Placeholder screenshot folders named `Records/Screenshots` can be normalized to `Records/screenshots` where they only contain `.gitkeep`.
- Starter-template screenshot placeholders can be renamed the same way so new modules inherit canonical casing.

## Archive Retention Decisions

Approved 23 September 2026: the three March pre-restore Finance PBIP folders were removed from the working tree. They remain in git history at commit `2ba401a2`. Restore instructions are in `Reports/Finance/Module/Archive/README.md`.

- `Financial Report_pre-restore_20260325_224854/`
- `Financial Report_pre-restore_20260326_174712/`
- `Financial Report_pre-restore_20260326_181746/`

## Current Guardrail Additions

- `Reports/Finance/module.manifest.json` records Finance company PBIP paths, schema/database names, expected pages, protected paths, and direct-PBIP review policy.
- `Portfolio/scripts/validate-structure.ps1` should validate module manifests and active PBIP paths from `Portfolio/Memory/ACTIVE_FOCUS.md`.
