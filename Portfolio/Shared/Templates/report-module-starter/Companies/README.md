# Companies

Use this folder to host company-specific configuration, overlays, and PBIP projects.

Suggested structure:

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
    <ReportTitle> - <CompanyCode>/
      <ReportTitle> - <CompanyCode>.pbip
      <ReportTitle> - <CompanyCode>.Report/
      <ReportTitle> - <CompanyCode>.SemanticModel/
    Records/screenshots/    # optional; module-level Records/ is also valid
```

Start from `_template/` and duplicate per company.
