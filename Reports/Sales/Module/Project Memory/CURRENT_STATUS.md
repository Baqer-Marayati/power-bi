# Current Status

## Date

- Last updated: September 24, 2026

## Current source of truth

- Sep 24, 2026 — repo restructured to mirror the workspaces: edit `Fabric/DevelopmentWorkspace/`, the live copy is in `Fabric/CanonAnalytics/`, publish with `Portfolio/scripts/fabric_release.py`. Module report copies were removed; the Paper Sales copy was parked under `Reports/Sales/Module/Archive/2026-09-24-parked-reports/PAPERENTITY/`.
- Canon PBIP (edit): `Fabric/DevelopmentWorkspace/Canon Sales Report.pbip`
- Canon live copy (read-only): `Fabric/CanonAnalytics/Canon Sales Report.*`
- Paper PBIP (parked): `Reports/Sales/Module/Archive/2026-09-24-parked-reports/PAPERENTITY/Paper Sales Report/Paper Sales Report.pbip`
- Paper Sales is not in any Fabric workspace.

## Canon (23 Sep 2026)

- Production, the Development Workspace, and the module PBIP are the same report. The user synced Canon Sales from the Development Workspace to Canon Analytics, then the module copy was mirrored from `Fabric/DevelopmentWorkspace` with 0 drift. Module `.pbip` and `.platform` identity files were kept.
- Shell: **1920×1080 FitToPage**, six pages in this order: Sales Overview, Sales Map, Salesperson, Customers, Target & Salaries, Rebate.
- Shared fleet layout and number standards apply. The sales-document profitability measure and visible labels are **Sales Margin %**. `Monthly Salary Gross Margin %` and `Quarter Commission Gross Margin %` use the percent suffix.
- Scaled `* Card Display` helpers are deleted on Canon. Money total cards bind raw measures.
- `SalesFact` includes SAP remarks, line text, and lead-source trace fields from 19 Sep. Those columns stay empty until the production model refreshes.
- Sales Map is a Deneb choropleth of 18 Iraqi governorates (`Geo_Governorate_Map`), not a Shape Map. Rebate has a Salesmen slicer from SAP `OCRD.SlpCode` / `OSLP.SlpName`.

## Paper

- Last substantive update was 14 May 2026. It is an older copy.
- Three KPI cards still bind `Sales Card Display`, `COGS Card Display`, and `Profit Card Display`. Leave those measures in place. Removing them would change the Paper Sales report.

## Semantic model (Canon)

- Tables: SalesFact, DateTable, DimSalesperson, DimBusinessPartner, DimBusinessPartnerSalesperson, Geo_City_Reference, Geo_Governorate_Map, BP_Rebate_Fact, Commission_Fact, _Measures.
- Relationships cover sales to date, salesperson, and business partner; rebate to business partner and salesperson assignment; business partner to city; city to governorate.
- `DimBusinessPartner` includes `GroupCode`, `GroupName`, and `LocationGroupKey` from `OCRD` / `OCRG`.
