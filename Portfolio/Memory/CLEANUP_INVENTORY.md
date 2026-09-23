# Cleanup Inventory

## Date

- Last updated: September 24, 2026

## Purpose

This inventory classifies cleanup candidates before moving, deleting, or consolidating anything. Active PBIP project trios remain protected unless a dedicated migration task updates references and validates in Power BI Desktop.

## Protected No-Touch

- `Fabric/DevelopmentWorkspace/` (Git-connected; do not rename or restructure)
- `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` (written only by `Portfolio/scripts/fabric_release.py`)
- `Fabric/workspaces.json` and `Fabric/RELEASES.md`
- `Reports/Finance/Module/Design Benchmarks/Sample 2/`
- Parked reports under `Reports/{Sales,Service,DataExchange}/Module/Archive/2026-09-24-parked-reports/`

The per-module report copies that used to be listed here were removed on 24 September 2026. They are in git history before that date.

## Safe Doc Edits

- Docs that still point at report copies under `Reports/<Domain>/Companies/<CODE>/<Report>/` should point at `Fabric/DevelopmentWorkspace/<Report>.*` instead.
- Finance package policy is direct PBIP review. Remove stale `ready.zip` / `package-report.sh` requirements from Finance docs, templates, and memory.
- Template docs should describe `Companies/<CODE>/` as config and overlays only, with the report in `Fabric/DevelopmentWorkspace/`.
- Records docs should use lowercase `Records/screenshots`.

## Safe Script Edits

- `Portfolio/scripts/clear-model-cache.ps1` should resolve company PBIP paths from a module manifest when present and remove only `.pbi/cache.abf`.
- `Reports/Finance/Module/scripts/clear-model-cache.ps1` should call the portfolio script from the repo root and support company selection.
- `Reports/Finance/Module/scripts/capture-pages.ps1` should default to the Development Workspace Finance PBIPs and `Module/Records/screenshots`.
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
- `Portfolio/scripts/validate-structure.ps1` validates module manifests, active PBIP paths from `Portfolio/Memory/ACTIVE_FOCUS.md`, every report in `Fabric/workspaces.json` (development and live), and fails if a report copy appears under `Reports/*/Companies/`.
