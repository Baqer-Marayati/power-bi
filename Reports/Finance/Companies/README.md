# Companies

Company-specific Finance reporting: each code under this folder has its own PBIP (report + semantic model). CANON uses the `Canon Financial Report` naming; **PAPERENTITY** uses the `Paper Financial Report` folder and `Paper Financial Report.pbip` entry point.

## Current companies

| Code | PBIP path (open in Power BI Desktop) |
|------|--------------------------------------|
| **CANON** | `CANON/Canon Financial Report/Canon Financial Report.pbip` |
| **PAPERENTITY** | `PAPERENTITY/Paper Financial Report/Paper Financial Report.pbip` |

The PAPERENTITY copy mirrors CANON’s layout with schema references adjusted from CANON to PAPERENTITY.

## Optional per-company extras

You may still use config-first patterns under a company folder when needed:

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
    Records/screenshots/
```

Prefer config-first. Use overlays only when configuration cannot satisfy the requirement.

There is **no** zip packaging step; work and review directly from the PBIP in Desktop.
