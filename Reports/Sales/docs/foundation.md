# Sales Foundation

## Active Source of Truth

- PBIP: `Sales Report/Sales Report.pbip`
- Open in Power BI Desktop for development.

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
- See `Portfolio Memory/SHARED_STANDARDS.md` for cross-report branding rules

## Packaging

- Package script: `scripts/package-report.ps1`
- Output: `Exports/Server Packages/Sales Report - ready.zip`

## Currency

- Iraqi dinar (IQD) formatting throughout
