# Agent Guide

## Read Order

1. `README.md`
2. `Module/docs/foundation.md`
3. `Module/Project Memory/PROJECT_DNA.md`
4. `Module/Project Memory/DECISIONS.md`
5. `Module/Project Memory/CURRENT_STATUS.md`
6. `Module/Project Memory/NEXT_STEPS.md`

Then inspect the active project files (repo-root-relative; edit only the `Fabric/DevelopmentWorkspace/` copy):

- `Fabric/DevelopmentWorkspace/Canon Sales Report.pbip`
- `Fabric/DevelopmentWorkspace/Canon Sales Report.SemanticModel/definition/model.tmdl`
- `Fabric/DevelopmentWorkspace/Canon Sales Report.SemanticModel/definition/relationships.tmdl`

The live copy is a read-only mirror in `Fabric/CanonAnalytics/Canon Sales Report.*`, written only by `Portfolio/scripts/fabric_release.py`.

The **Paper Sales Report** is parked (not in any workspace) under `Module/Archive/2026-09-24-parked-reports/PAPERENTITY/`.

## Rules

- Keep Sales-specific live truth inside this module.
- Use `Module/Core/` for shared Sales baseline assets.
- Use `Companies/` for company-specific config and overlays (CANON); report files live under `Fabric/`.
- Follow the portfolio visual identity (navy-blue palette, shared branding).
- PBIP is the source of truth; work directly from PBIP (no zip packaging workflow). After edits, run `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`, commit, and push for Fabric review. Publish only when the user names the report: `python3 Portfolio/scripts/fabric_release.py publish "Canon Sales Report"` (dry run), then `--apply`.
- Update `Module/Project Memory` after meaningful work.
