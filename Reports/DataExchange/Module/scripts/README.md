# DataExchange scripts

- `open-report.ps1` — opens `Companies/CANON/Canon Data Exchange Report/Canon Data Exchange Report.pbip` in Power BI Desktop (run after clone or PBIP changes so Desktop reconciles the project).
- `clear-model-cache.ps1` — removes semantic model `cache.abf` for a blank-on-open experience.

There is no `package-report.ps1` or `Exports/Server Packages/` workflow. There is no `validate-structure.ps1` in this folder by default; add one if you want the portfolio structure validator run for DataExchange.
