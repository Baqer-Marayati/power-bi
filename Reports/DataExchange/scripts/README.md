# DataExchange scripts

- `open-report.ps1` — launches **Data Exchange Report.pbip** in Power BI Desktop (use after clone or PBIP changes so Desktop reconciles the project).
- `package-report.ps1` — zips `Data Exchange Report/` via portfolio `scripts/package-report.ps1` into `Exports/Server Packages/`.
- `clear-model-cache.ps1` — removes semantic model `cache.abf` for a blank-on-open experience.

There is no `validate-structure.ps1` here: this module intentionally omits some contract folders (`Core`, `Companies`) so the portfolio structure validator is not applied by default.
