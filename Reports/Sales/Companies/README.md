# Companies

Company-specific configuration and overlays live here. **CANON** is the primary SAP Business One tenant. Report files do not live here: edit `Fabric/DevelopmentWorkspace/Canon Sales Report.pbip` at the repo root.

## Active companies

- `CANON/` — `config/` and `overlays/` for **Canon Sales Report**

The PAPERENTITY copy (**Paper Sales Report**, with its config and overlays) is parked under `Module/Archive/2026-09-24-parked-reports/PAPERENTITY/`.

## Structure

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
```

Start from `_template/` (if present) and duplicate per company.

There is no zip packaging workflow; work directly from the PBIP under `Fabric/DevelopmentWorkspace/`.
