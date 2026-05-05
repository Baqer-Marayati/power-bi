# Current Status

## Date
- Last updated: May 5, 2026

## Active Project
- `C:\Work\reporting-hub\Reports\Sales\Sales Report`

## Current State
- Module activated and PBIP built with full visual layer.
- Canon PBIP now includes 6 report pages after adding Sales Map.
- Latest Sales Map repair: governorate tooltip Sales % now clears the full map geography row context for its denominator, and the Deneb choropleth fields/viewport are aligned to the high-detail vector layer.
- Existing commercial pages have: report header, branding lockup, left-rail slicers, KPI card row, charts, and existing matrices repositioned.
- Portfolio visual identity applied: #F8FBFF background, navy-blue palette, C9D5E3 card borders, 1F4E79 drop shadows, Segoe UI/Tahoma typography.
- Pages use 1280x960 FitToWidth with 195px outspace pane, matching Finance report geometry.

## Live Pages
1. **Sales Overview** — 4 KPIs (Sales, COGS, Profit, Margin %), monthly trend combo chart, revenue mix donut, sales matrix
2. **Sales Person** — 4 KPIs (Sales, Salespeople count, Avg Sales/Person, Margin %), salesperson bar chart, employee matrix
3. **Business Partner** — 4 KPIs (Sales, Active Customers, Avg Sales/Customer, Margin %), customer bar chart, BP matrix
4. **Sales Map** — Iraq choropleth rendered as a Deneb AppSource visual (`deneb7E15AEF80B9E4D4F8E12924291ECE89A`) using high-detail governorate polygon path marks, not a native `shapeMap` or image/scatter workaround. `Geo_Governorate_Map` stores projected SVG path geometry for all 18 GeoBoundaries ADM1 governorates and feeds Deneb alongside governorate-scoped Sales, Customers, and Sales %. Hovering anywhere inside a governorate should show tooltip data, with no visible circles or hover border expansion. Fill saturation uses a non-linear gradient (#DCEAF6 → #073B72). User-adjusted layout from screenshot 11 is the current target: Deneb map `x=188.33/y=230/w=773.33/h=690`, city table `x=973.33/y=230/w=271.67/h=690`, with left filters, KPI row, and logos/header retained. The previous scatter tooltip layer remains off-canvas for potential re-use.
5. **Commission** — salesperson commission target/sales/achievement tracking
6. **Rebate** — 4 KPIs (Target, Actual Sales, Rebate, Achievement %), target vs actual bar chart, quarterly rebate matrix

## Semantic Model
- _Measures includes base sales/profitability measures plus rebate, commission, Sales Share %, company-sales denominator, and map-specific measures (`Mapped Sales`, `Mapped BP Count`, `Mapped City Count`, `Unmapped Sales`, `Map Bubble Radius`, `Governorate Sales`).
- 9 tables: SalesFact, DateTable, DimSalesperson, DimBusinessPartner, Geo_City_Reference, Geo_Governorate_Map, BP_Rebate_Fact, Commission_Fact, _Measures
- 6 relationships (Sales→Date, Sales→Salesperson, Sales→BP, Rebate→BP, DimBusinessPartner→Geo_City_Reference, Geo_City_Reference→Geo_Governorate_Map)
- `DimBusinessPartner` now includes `GroupCode`, `GroupName`, and normalized `LocationGroupKey` from `OCRD`/`OCRG` for the map layer.

## What Is Still Needed
- Desktop validation: open the PBIP in Power BI Desktop and verify all 6 pages render correctly with data.
- Validate Sales Map choropleth: confirm the Deneb visual renders all 18 Iraqi governorate polygons with crisp geometry, no USA map appears, no circles are visible, hover works anywhere inside each governorate without adding borders, and tooltips show Governorate, Sales, Customers, and non-100% Sales % shares. Shape Map preview settings are no longer required, but the certified Deneb AppSource visual must be available in Desktop/tenant policy.
- Visual polish pass after Desktop review (chart colors, matrix formatting, card value scaling).
- Portfolio theme alignment may need a custom theme file registered in report.json.
- Package script adaptation for the Sales Report.

## Safe Return Points
- `90ac3b2` — baseline PBIP before visual build (4 sparse pages, matrix-only)

## Retained Lessons
- Follow the Finance report patterns exactly for visual JSON structure.
- PBIP visual IDs can be descriptive strings (e.g., `kpi_sales`, `chart_trend`) not just hex.
- Branding lockup requires a visualGroup parent with ScaleMode plus child image/shape visuals.
