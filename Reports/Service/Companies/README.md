# Companies

Use this folder to host company-specific configuration and overlays. Report files do not live here: edit `Fabric/DevelopmentWorkspace/Canon Service Report.pbip` at the repo root.

## Active companies

- `CANON/` — primary company; existing `config/` and `overlays/` for **Canon Service Report**

The PAPERENTITY copy (**Paper Service Report**, with its config and overlays) is parked under `Module/Archive/2026-09-24-parked-reports/PAPERENTITY/`.

## Structure

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
```

Start from `_template/` and duplicate per company. Work directly from the PBIP under `Fabric/DevelopmentWorkspace/`; there is no zip packaging step.
