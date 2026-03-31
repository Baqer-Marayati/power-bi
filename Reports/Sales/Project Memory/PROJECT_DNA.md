# Project DNA

## Purpose

Sales analysis report for Al Jazeera Machinery, covering sales performance, salesperson productivity, business partner sales activity, and BP rebate tracking. Designed as an operational/commercial complement to the CFO-focused Finance report.

## Active Project

Use this folder as the active working project:
- `C:\Work\reporting-hub\Reports\Sales\Sales Report`

Do not create parallel experiment folders unless explicitly needed.

## Origin

This report was derived from the Aljazeera Master Model PBIP, keeping only the 4 sales/commercial pages and their supporting semantic model tables. Non-sales pages (Inventory Valuation, Receivables, Collections, Cash) were removed during initial setup.

## Pages

1. **Sales Overview** — Top-line KPIs (Sales, COGS, Profit, Margin %), overall sales trends
2. **Sales Employees** — Salesperson-level performance breakdown
3. **BP Sales** — Business partner sales analysis with drill-down
4. **BP Rebate** — Rebate tracking by business partner

## Data Source

- SAP HANA ODBC to CANON schema (SAP Business One)
- `SalesFact` covers A/R Invoices, A/R Credit Memos, warranty provisions (SV003), and G/L COGS adjustments
- Item-level segmentation via SAP UDFs: `U_BusinessType`, `U_GroupType`, `U_ProductType`, `U_SegmentType`
- Salesperson data from `OSLP` with `U_SalesDept` and `U_SalesType`

## Design Direction

- Follow the portfolio visual identity established by the Finance report
- Navy-blue palette, IQD currency formatting, executive-facing tone
- The report should feel like it belongs in the same portfolio as the Financial Report

## Source of Truth

- PBIP is the editable source of truth
- Review from packaged artifacts, not raw PBIP folders
