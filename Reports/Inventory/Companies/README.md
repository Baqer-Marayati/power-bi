# Companies

Use this folder to host company-specific configuration and overlays.

Suggested structure:

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
```

Start from `_template/` and duplicate per company. Report files do not live here: edit `Fabric/DevelopmentWorkspace/<Report Name>.pbip` (with its `.Report/` and `.SemanticModel/` folders) at the repo root. There is no zip packaging or `Exports/Server Packages/` layout under companies.
