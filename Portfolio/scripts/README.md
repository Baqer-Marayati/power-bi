# Portfolio scripts

## Active entry points

| Script | Purpose |
|--------|---------|
| `create-report-module.sh` | Scaffold a new module from `../Shared/Templates/report-module-starter` |
| `validate-structure.ps1` | Check required folders for listed domains (contract modules) |
| `clear-model-cache.ps1` | Remove `cache.abf` for a domain’s semantic model (blank-on-open) |
| `validate-theme-vs-canonical.ps1` | Compare registered `Custom_Theme49412231581938193.json` to `../Shared/Themes/` |
| `list-visual-types.ps1` | Inventory `visualType` values under a report definition tree |

## Module wrappers

Each contract module should call these from `Reports/<Domain>/Module/scripts/` with the correct `-Domain` / paths. See `Reports/Finance/Module/scripts/` as the reference.

## Archive

One-off migration and fix scripts live in [`archive/`](archive/README.md). They are kept for history, not daily use.
