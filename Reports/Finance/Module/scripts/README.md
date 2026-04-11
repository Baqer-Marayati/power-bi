# Scripts

Automation scripts for the Finance module.

Current scripts:
- `capture-pages.ps1` — full-page screenshot capture. By default it reads **how many pages** to click from `…Report/definition/pages/pages.json` next to the PBIP (fallback: 10). Override with `-PageCount` if needed.
- `clear-model-cache.ps1` — removes cached semantic-model artifacts under a PBIP folder so Power BI Desktop reloads the model from source after Git changes.
- `open-design-benchmark.ps1` — opens `Design Benchmarks/Sample 2/Wiise Financial Dashboards-2.pbip` in Power BI Desktop (Windows: `PBIDesktop.exe`; macOS: `open -a "Microsoft Power BI Desktop"`).
- `validate-structure.ps1` — module structure checks.

Planned additions:
- Extend `validate-structure.ps1` or add companion checks as the module layout evolves.
