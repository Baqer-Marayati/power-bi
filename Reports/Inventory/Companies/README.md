# Companies

Use this folder to host company-specific configuration and overlays.

Suggested structure:

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
    <ReportName> - <CompanyCode>/
      <ReportName> - <CompanyCode>.pbip
      ...
```

Start from `_template/` and duplicate per company. Work directly from PBIP; there is no zip packaging or `Exports/Server Packages/` layout under companies.
