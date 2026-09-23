# Finance Review Workflow

## Purpose

Finance review happens in the Fabric Development Workspace after the edited PBIP is pushed and synced. There is no required `ready.zip` package or `package-report.sh` step.

## Active PBIP Entry Points

- CANON: `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip`
- PAPERENTITY: `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip`

## Routine

1. Finish report edits in the relevant PBIP under `Fabric/DevelopmentWorkspace/`.
2. Validate report definitions and semantic-model paths with `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`.
3. Commit and push; the user syncs the Fabric Development Workspace (or opens the PBIP in Power BI Desktop when local validation is needed).
4. Refresh and review the affected pages/visuals.
5. Capture screenshots when review evidence is needed.
6. Update Project Memory if current truth, decisions, or caveats changed.
7. When the user names the report to publish, run `python3 Portfolio/scripts/fabric_release.py publish "<Report Name>"` (dry run), then `--apply`, and commit and push the updated live mirror (`Fabric/CanonAnalytics/` or `Fabric/PaperAnalytics/`) and `Fabric/RELEASES.md`.

## Notes

- PBIP remains the development source of truth.
- `PBIX` may still be created as a temporary review or transfer snapshot when explicitly needed, but it must not become the editable master.
- Generated package artifacts are not part of Finance done criteria.
