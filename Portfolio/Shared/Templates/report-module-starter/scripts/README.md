# Scripts

Mirror an active module such as `Reports/Sales/Module/scripts/`:

- `validate-structure.ps1` — calls `scripts/validate-structure.ps1` with `-Domains @("<MODULE_NAME>")`
- `clear-model-cache.ps1` — after the semantic model exists, call `scripts/clear-model-cache.ps1`; add the module name to the portfolio script’s `-Domain` `ValidateSet` if it is not already listed

Portfolio automation entry points: repo `scripts/README.md`.
