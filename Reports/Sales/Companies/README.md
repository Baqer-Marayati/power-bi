# Companies

Company-specific PBIP copies and configuration live here. **CANON** is the primary SAP Business One tenant; **PAPERENTITY** is a second copy for alternate datasource / branding work.

## Active companies

- `CANON/` — `Canon Sales Report/Canon Sales Report.pbip`
- `PAPERENTITY/` — `Paper Sales Report/Paper Sales Report.pbip`

## Structure

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
    <ActualReportFolder>/
      <ActualReportFolder>.pbip
      ...
```

Start from `_template/` (if present) and duplicate per company.

There is no zip packaging workflow; use the real company report folder name and work directly from the PBIP folders.
