# Reference

## Core paths

- Module root: `Reports/Service/`
- PBIP project: `Reports/Service/Service Report/Service Report.pbip`
- Report definition: `Reports/Service/Service Report/Service Report.Report/definition/`
- Semantic model: `Reports/Service/Service Report/Service Report.SemanticModel/definition/`
- Company config: `Reports/Service/Companies/CANON/config/`

## Portfolio standards

- Report module contract: `Shared/Standards/report-module-contract.md`
- Visual identity: `Shared/Standards/portfolio-visual-identity.md`
- Page layout contract: `Shared/Standards/page-layout-spec.md`
- Theme tokens: `Shared/Standards/portfolio-theme.tokens.json`
- Canonical theme JSON (copy target): `Shared/Themes/Custom_Theme49412231581938193.json`

## Data source

- Platform: SAP HANA (ODBC)
- Schema: CANON

## Automation (module)

- Package: `Reports/Service/Module/scripts/package-report.ps1` (defaults to this module’s PBIP folder)
- Clear model cache: `Reports/Service/Module/scripts/clear-model-cache.ps1`
- Structure check: `Reports/Service/Module/scripts/validate-structure.ps1`
