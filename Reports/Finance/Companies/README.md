# Companies

Company-specific Finance settings: each code under this folder holds its `config/` and `overlays/` only. The report and semantic-model files live under `Fabric/` at the repo root. CANON uses the `Canon Financial Report` naming; **PAPERENTITY** uses `Paper Financial Report`.

## Current companies

| Code | Editable PBIP (open in Power BI Desktop) | Live copy (read-only) |
|------|------------------------------------------|-----------------------|
| **CANON** | `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip` | `Fabric/CanonAnalytics/Canon Financial Report.*` |
| **PAPERENTITY** | `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip` | `Fabric/PaperAnalytics/Paper Financial Report.*` |

The PAPERENTITY report follows CANON’s layout with schema references adjusted from CANON to PAPERENTITY.

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

PBIP is the development source of truth. Finance review happens by syncing and reviewing in the Fabric Development Workspace; there is no required `ready.zip` or package artifact step. Live copies are updated only by `Portfolio/scripts/fabric_release.py`.
