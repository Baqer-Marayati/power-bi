# Scripts

Mirror an active module such as `Reports/Sales/Module/scripts/`:

- `validate-structure.ps1` — calls `Portfolio/scripts/validate-structure.ps1` with `-Domains @("<MODULE_NAME>")`
- `clear-model-cache.ps1` — after the semantic model exists, call `Portfolio/scripts/clear-model-cache.ps1`; add the module name to the portfolio script’s `-Domain` `ValidateSet` if it is not already listed
- Prefer resolving company PBIP paths from `module.manifest.json` instead of hardcoding report-root paths.

Portfolio automation entry points: `Portfolio/scripts/README.md`.
