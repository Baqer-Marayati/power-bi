# Scripts

Mirror an active module such as `Reports/Sales/scripts/`:

- `package-report.ps1` — calls repo `scripts/package-report.ps1` with default `-SourceDir` for this module’s PBIP folder
- `validate-structure.ps1` — calls `scripts/validate-structure.ps1` with `-Domains @("<MODULE_NAME>")`
- `archive-prune.ps1` — trim `Exports/Server Packages/archive`
- `clear-model-cache.ps1` — after the semantic model exists, call `scripts/clear-model-cache.ps1`; add the module name to the portfolio script’s `-Domain` `ValidateSet` if it is not already listed

Portfolio automation entry points: repo `scripts/README.md`.
