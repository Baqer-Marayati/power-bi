# Portfolio scripts

## Active entry points

| Script | Purpose |
|--------|---------|
| `fabric_release.py` | Release tool: `status` (read-only health of every report), `publish "<Report>"` (dry run; `--apply` to publish), `rollback "<Report>" --to <commit>`. See `Fabric/README.md`. |
| `audit-report-consistency.py` | Layout, typography, and number-format audit. Run `--strict Fabric/DevelopmentWorkspace` before every push. |
| `validate-structure.ps1` | Check module folders, every PBIP in `Fabric/workspaces.json`, and that no report copies sit under `Reports/*/Companies/` |
| `create-report-module.sh` | Scaffold a new module from `../Shared/Templates/report-module-starter` |
| `clear-model-cache.ps1` | Remove `cache.abf` for a domain's Development Workspace semantic model (blank-on-open) |
| `validate-theme-vs-canonical.ps1` | Compare registered `Custom_Theme49412231581938193.json` to `../Shared/Themes/` |
| `list-visual-types.ps1` | Inventory `visualType` values under a report definition tree |
| `test-powerbi-api-readonly.py` | Smoke-test the service principal in `powerbi-api-local.env` (lists workspaces) |

`fabric_release.py` and `test-powerbi-api-readonly.py` read credentials from `powerbi-api-local.env` (gitignored; copy `powerbi-api-local.env.example`).

## Module wrappers

Each contract module should call these from `Reports/<Domain>/Module/scripts/` with the correct `-Domain` / paths. See `Reports/Finance/Module/scripts/` as the reference.

## Archive

One-off migration and fix scripts live in [`archive/`](archive/README.md). They are kept for history, not daily use.
