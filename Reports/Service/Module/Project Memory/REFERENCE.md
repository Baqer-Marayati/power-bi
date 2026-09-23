# Reference

## Core paths

- Module root: `Reports/Service/`
- PBIP project (CANON tenant): `Reports/Service/Companies/CANON/Canon Service Report/Canon Service Report.pbip`
- PBIP project (PAPERENTITY tenant): `Reports/Service/Companies/PAPERENTITY/Paper Service Report/Paper Service Report.pbip`
- Report definition (CANON): `Reports/Service/Companies/CANON/Canon Service Report/Canon Service Report.Report/definition/`
- Semantic model (CANON): `Reports/Service/Companies/CANON/Canon Service Report/Canon Service Report.SemanticModel/definition/`
- Company config: `Reports/Service/Companies/CANON/config/`

## Portfolio standards

- Report module contract: `Portfolio/Shared/Standards/report-module-contract.md`
- Visual identity: `Portfolio/Shared/Standards/portfolio-visual-identity.md`
- Page layout contract: `Portfolio/Shared/Standards/page-layout-spec.md`
- Theme tokens: `Portfolio/Shared/Standards/portfolio-theme.tokens.json`
- Canonical theme JSON (copy target): `Portfolio/Shared/Themes/Custom_Theme49412231581938193.json`

## Data source

- Platform: SAP HANA (ODBC, DSN `HANA_B1`)
- Tenant database: `HV107C21694P01`
- Schema: `CANON`
- Direct ODBC pattern (per `Portfolio/Shared/ChatContext/LESSONS.md` 2026-04-14):
  `Driver={HDBODBC};ServerNode=hana-vm-107:30041;DatabaseName=HV107C21694P01;UID=...;PWD=...;Encrypt=FALSE;`

## Automation (module)

- Review: direct from the active company PBIP; no zip packaging workflow
- Clear model cache: `Reports/Service/Module/scripts/clear-model-cache.ps1`
- Structure check: `Reports/Service/Module/scripts/validate-structure.ps1`
- Archived discovery probes (not part of the report): `Reports/Service/Module/Archive/discovery-scripts/`
