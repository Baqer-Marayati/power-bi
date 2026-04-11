# Companies

Use this folder to host company-specific configuration and overlays.

Suggested structure:

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
    <ActualReportFolder>/
      <ActualReportFolder>.pbip
      ...
```

Start from `_template/` and duplicate per company. Use the real report folder name for that company, then work directly from PBIP; there is no zip packaging or `Exports/Server Packages/` layout under companies.
