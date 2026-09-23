# Companies

Use this folder for company-specific configuration and overlays only.

Suggested structure:

```text
Companies/
  <CompanyCode>/
    config/
    overlays/
```

Start from `_template/` and duplicate per company.

The report itself does not go here. Put it in `Fabric/DevelopmentWorkspace/` as `<Name>.pbip`, `<Name>.Report/`, and `<Name>.SemanticModel/`, add it to `Fabric/workspaces.json`, and record the path in `../module.manifest.json` before treating the module as active.
