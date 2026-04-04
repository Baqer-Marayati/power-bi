# Current Status

## Date
- Last updated: March 31, 2026

## Active Project
- `C:\Work\reporting-hub\Reports\Sales\Sales Report`

## Current State
- Module activated and PBIP built with full visual layer.
- All 4 pages have: report header, branding lockup, left-rail slicers, KPI card row, charts, and existing matrices repositioned.
- Portfolio visual identity applied: #F8FBFF background, navy-blue palette, C9D5E3 card borders, 1F4E79 drop shadows, Segoe UI/Tahoma typography.
- Pages use 1280x960 FitToWidth with 195px outspace pane, matching Finance report geometry.

## Live Pages
1. **Sales Overview** — 4 KPIs (Sales, COGS, Profit, Margin %), monthly trend combo chart, revenue mix donut, sales matrix
2. **Sales Employees** — 4 KPIs (Sales, Salespeople count, Avg Sales/Person, Margin %), salesperson bar chart, employee matrix
3. **BP Sales** — 4 KPIs (Sales, Active Customers, Avg Sales/Customer, Margin %), customer bar chart, BP matrix
4. **BP Rebate** — 4 KPIs (Target, Actual Sales, Rebate, Achievement %), target vs actual bar chart, quarterly rebate matrix

## Semantic Model
- 13 measures in _Measures: Sales, COGS, Profit, Margin %, Sales/COGS/Profit Card Display, Active BP Count, Active Salesperson Count, Avg Sales per BP, Avg Sales per Salesperson, Total Qty, Rebate Achievement %, Total Target, Total Rebate, Rebate Sales
- 6 tables: SalesFact, DateTable, DimSalesperson, DimBusinessPartner, BP_Rebate_Fact, _Measures
- 4 relationships (Sales→Date, Sales→Salesperson, Sales→BP, Rebate→BP)

## What Is Still Needed
- Desktop validation: open the PBIP in Power BI Desktop and verify all 4 pages render correctly with data.
- Visual polish pass after Desktop review (chart colors, matrix formatting, card value scaling).
- Portfolio theme alignment may need a custom theme file registered in report.json.
- Package script adaptation for the Sales Report.

## Safe Return Points
- `90ac3b2` — baseline PBIP before visual build (4 sparse pages, matrix-only)

## Retained Lessons
- Follow the Finance report patterns exactly for visual JSON structure.
- PBIP visual IDs can be descriptive strings (e.g., `kpi_sales`, `chart_trend`) not just hex.
- Branding lockup requires a visualGroup parent with ScaleMode plus child image/shape visuals.
