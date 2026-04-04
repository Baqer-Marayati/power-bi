# Companies

Use this folder to host company-specific configuration and overlays.

## Active companies

- `CANON/` — primary company; **Canon Service Report** PBIP and existing `config/`
- `PAPERENTITY/` — **Paper Service Report** PBIP for the second tenant copy

## Structure

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
    <ReportName> - <CompanyCode>/
      <ReportName> - <CompanyCode>.pbip
      ...
```

Start from `_template/` and duplicate per company. Work directly from PBIP; there is no zip packaging step.
