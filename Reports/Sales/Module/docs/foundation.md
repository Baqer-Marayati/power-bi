# Sales Foundation

## Active Source of Truth

- PBIP: `Fabric/DevelopmentWorkspace/Canon Sales Report.pbip` (repo root)
- Open in Power BI Desktop for development; review in the Fabric Development Workspace after sync.
- Live copy (read-only): `Fabric/CanonAnalytics/Canon Sales Report.*`

## Data Source

- SAP HANA ODBC connection to `CANON` schema on SAP Business One
- Same SAP instance as the Finance report

## Semantic Model

Tables:
- `SalesFact` — Line-level sales from A/R Invoices + Credit Memos + warranty + GL COGS adjustments
- `DimSalesperson` — Salesperson dimension from `OSLP`
- `DimBusinessPartner` — Business partner dimension from `OCRD`
- `BP_Rebate_Fact` — Rebate tracking by business partner
- `DateTable` — Date dimension
- `_Measures` — Sales, COGS, Profit, Margin %

Key columns on `SalesFact`:
- `BusinessType`, `U_GroupType`, `U_ProductType`, `U_SegmentType` — from SAP item master UDFs
- `SalesPerson`, `SalesDept`, `SalesType` — from SAP salesperson master
- `CardCode`, `CardName` — business partner

## Design Reference

- Follow portfolio visual identity from Finance report
- Navy-blue palette, IQD currency formatting, CFO/management-report tone
- See `Portfolio/Memory/SHARED_STANDARDS.md` for cross-report branding rules

## Packaging

- Work from `Fabric/DevelopmentWorkspace/` and review in the Fabric Development Workspace.
- There is no zip packaging workflow for Sales; publish with `Portfolio/scripts/fabric_release.py` when the user names the report.

## Currency

- Iraqi dinar (IQD) formatting throughout
