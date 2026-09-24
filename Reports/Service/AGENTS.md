# Agent Guide

This file is the AI entrypoint for the Service Performance Report module.

## Read Order

1. `README.md`
2. `Module/docs/foundation.md`
3. `Module/Project Memory/PROJECT_DNA.md`
4. `Module/Project Memory/DECISIONS.md`
5. `Module/Project Memory/CURRENT_STATUS.md`
6. `Module/Project Memory/NEXT_STEPS.md`
7. `Module/Project Memory/REFERENCE.md`

Then inspect the active project files (`Fabric/` paths are repo-root-relative; edit only the `Fabric/DevelopmentWorkspace/` copy):

- `Fabric/DevelopmentWorkspace/Canon Service Report.pbip`
- `Companies/CANON/config/` — company profile and datasource mapping (existing)

Canon Service is not live. It was removed from Canon Analytics on 24 Sep 2026. The next publish uses `python3 Portfolio/scripts/fabric_release.py publish "Canon Service Report" --create`.

The **Paper Service Report** is parked (not in any workspace) under `Module/Archive/2026-09-24-parked-reports/PAPERENTITY/`.

## Module Rules

- Keep report-specific truth inside this module.
- Put only shared cross-report assets in the portfolio `Portfolio/Shared/` layer.
- Archive historical material explicitly instead of mixing it into active work folders.
- The PBIP lives under `Fabric/DevelopmentWorkspace/`; work directly from PBIP (no zip packaging workflow). After edits, run `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`, commit, and push for Fabric review. Publish only when the user names the report: `python3 Portfolio/scripts/fabric_release.py publish "Canon Service Report" --create` (dry run), then `--apply`.
- Apply the portfolio-wide visual identity from `Portfolio/Shared/Standards/portfolio-visual-identity.md` and `Portfolio/Shared/Standards/portfolio-theme.tokens.json` unless an approved module exception is recorded.
