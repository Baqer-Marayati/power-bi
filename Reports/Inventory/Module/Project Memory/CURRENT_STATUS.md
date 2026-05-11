# Current Status

## Date

- Last updated: May 11, 2026

## Current Reality

- May 11, 2026 (pm-11) — Extended CANON Inventory **Procurement & Suppliers** with a lower **Purchase unit cost vs realized COGS** section. New measures show weighted paid/received unit cost from positive Goods Receipt PO lines, purchase unit MoM %, receipt-side IQD impact, Average Unit COGS, COGS MoM %, COGS IQD impact, and COGS response gap context. The page now includes a matching KPI row, monthly paid-unit-vs-COGS line chart, and receipt cost mover table; `Procurement & Suppliers` was moved immediately after `Reorder Actions` in `pages.json`. Desktop validation is still required.
- May 11, 2026 (pm-10) — Improved Executive Summary **Average Unit COGS Trend by Business Type** readability. B2B keeps portfolio navy, B2C now uses teal, and `#N/A` now uses amber so the right-side line chart is easier to read when the visible series are close together; markers are disabled and line width is set to 3 so the May point no longer reads like a stray dot.
- May 11, 2026 (pm-9) — Replaced the Executive Summary right-side COGS pie with a balanced line chart: **Average Unit COGS Trend by Business Type**. The chart uses `_Measures[Average Unit COGS] = Total COGS / Total Sold Qty`, Month on the x-axis, and Business Type as the series. The left COGS comparison chart and the new right trend chart now share equal 516×300 sizing.
- May 11, 2026 (pm-8) — Reworked Executive Summary cost logic: `_Measures[Total COGS]` now uses SAP `OINM.CogsVal` for valid non-canceled sales movements, net of credit/return movement types; `_Measures[Current Total Cost]` replaces the old Total Cost label and values the same net sold quantity at current item cost with `LastPurPrc` fallback when current stock/AvgPrice are missing.
- May 11, 2026 (pm-7) — Corrected Executive Summary cost comparison: `_Measures[Total Cost]` now means current item unit cost × sold quantity for the sold item set, so it compares against movement-time `_Measures[Total COGS]` instead of showing total current stock value. The left chart now compares monthly COGS vs current cost, and the right pie now shows Total COGS sold by business type.
- May 11, 2026 (pm-6) — Added cost context back to the CANON Inventory **Executive Summary** matrix. `_Measures[Total Sold Qty]` and `_Measures[Total COGS]` use outbound sales inventory movements (`Fact_StockMovement` trans types 13/15) so date and item/category slicers can filter sold quantity and movement-time COGS. Matrix columns now read: Qty → Total COGS → Total Cost. (The first Total Cost definition was corrected in pm-7.)
- May 11, 2026 (pm-5) — Replaced the CANON Inventory **Executive Summary** page visuals with the Canon Sales Overview layout pattern while keeping Sales untouched. The new Inventory page uses the same left slicer rail, four KPI cards, trend chart, business-type mix chart, and bottom matrix layout, but all bindings are quantity-only Inventory fields/measures (no Sales/COGS/Profit/Margin or IQD/currency visuals).
- May 11, 2026 (pm-4) — Fixed Reorder Actions IQD impact rendering by removing the unsupported conditional `[>=...]` custom format sections from `_Measures[Reorder IQD Impact]`. Power BI was rendering those sections as literal text in table cells; the measure now uses plain numeric `#,0;-#,0;0` formatting and remains numeric for header sorting. IQD impact column width increased to 145D for full values.
- May 11, 2026 (pm-3) — IQD impact column width bumped to 120D and the auto-scale format string switched to standard `#,##0.0` digit pattern (`[>=1B]#,##0.0,,," B";[>=1M]…;[>=1K]…;#,##0`). The previous 95D width was clipping the trailing "K" on 5+ digit values like `145.3 K` so it visually looked like a stray vertical bar; "M" values fit because they were shorter.
- May 11, 2026 (pm-2) — Fixed Reorder Actions sort behaviour: Move qty and IQD impact are now numeric measures (`Reorder Move Qty Value` with `+#,0;-#,0;0`, `Reorder IQD Impact` with conditional `[>=1B]/[>=1M]/[>=1K]` format string for auto-scale). Clicking the column headers now sorts by the actual amount instead of alphabetic text. Cover bar shows "— no target" for non-mover rows (TargetStockQty=0) so a missing fill is no longer mis-read as "0% of target"; ratio is also clamped to ≥0 / ≤150% so weird values can't push the fill outside the track. Dropped the now-unused `Reorder Move Qty Label` and `Reorder IQD Impact Label` text measures.
- May 11, 2026 (pm) — Reorder Actions table re-shaped to 15 columns. Restored the rounded SVG pill on Action (`Reorder Action Pill SVG`, now with an inner `<title>` for accessible name). Item column shows only `ItemName` (bold). `Reorder Cover Bar SVG` track is thicker (12px) and the "% of target" label is now 11pt. Reference fields moved to the right end in this order: Policy → Item Code → Business Type → Group Type → Product Type → Segment Type. The table is wider than the visual frame (~1500px) so it scrolls horizontally inside the 1028px container.
- May 11, 2026 — Reorder Actions table polished: replaced the Action / Item / Move qty SVG image measures with native text columns + measure-driven conditional formatting; Item became a two-line measure with word-wrap on. (Superseded by the 15-column re-shape later the same day — pill restored, Item back to name-only.)
- May 11, 2026 — Reorder Actions table rebuilt as a modern native `tableEx` with Image URL SVG measures (Action pill, two-line Item cell, Cover bar with % of target, colored Move qty); columns matched the original 9-column approved mock.
- `Reports/Inventory` is now an active module with a full PBIP project.
- The PBIP lives at `Reports/Inventory/Inventory Report/Inventory Report.pbip`.
- The semantic model connects to SAP B1 HANA via ODBC DSN `HANA_B1`, querying the `CANON` schema.
- Currency is IQD (Iraqi Dinar), consistent with the Finance module.
- The CANON report now has 8 pages and 11 semantic model tables, including the stock-cover policy table for reorder/overstock analysis.
- The CANON stock-cover policy now uses item-grain blended velocity: 35% 90-day net sales rate, 35% 180-day net sales rate, and 30% 365-day net sales rate, with policy days B2B 120, B2C 90, and other/blank 60.

## Pages

1. **Inventory Overview** — KPI cards (Total SKUs, In-Stock, On Hand, Committed, Available, Stock Value), bar charts by warehouse and item group.
2. **Warehouse Distribution** — Warehouse slicer, warehouse detail table, stock comparison chart, monthly transfer trend.
3. **Stock Movements** — Inbound/outbound/net movement KPIs, monthly flow charts, movement breakdown by transaction type.
4. **Product Categories** — Item group slicer, category analysis table, full item catalog.
5. **Procurement** — Open PO count, on-order qty, PO value KPIs, purchase order detail table, goods receipt trend.
6. **Stock Cover Value Exposure** — IQD financial exposure from stock-cover policy: understock reorder value, healthy value, overstock value locked, no-sales stock value, and value distributions by action/status/category.
7. **Reorder Action List** — SKU-level buy/hold/reduce action list with sales velocity, target stock quantity, reorder quantity, and excess quantity.

## Semantic Model Tables

- **Dim_Item** — OITM + OITB (1,456 items, item master with groups)
- **Dim_Warehouse** — OWHS (19 warehouses)
- **Dim_Date** — DAX calculated calendar (Dec 2025 – Dec 2026)
- **Fact_WarehouseStock** — OITW (current stock by item × warehouse)
- **Fact_StockMovement** — OIVL (8,000 inventory valuation layers)
- **Fact_Transfer** — OWTR + WTR1 (336 transfers / 1,177 lines)
- **Fact_Delivery** — ODLN + DLN1 (401 deliveries / 1,248 lines)
- **Fact_GoodsReceipt** — OPDN + PDN1 (19 GRs / 355 lines)
- **Fact_PurchaseOrder** — OPOR + POR1 (31 POs / 373 lines)
- **Fact_StockCoverPolicy** — item-grain CANON policy table from OITW + invoice/credit memo sales history, with 90/180/365-day rolling net-sales quantities and blended target stock quantity
- **_Measures** — DAX measures including stock-cover policy KPIs

## Branding

- Portfolio visual identity inherited from Finance: navy `#1F4E79`, light background `#F8FBFF`, Segoe UI font family.
- KPI cards use white background, border `#C9D5E3`, radius 4, navy top accent shadow.
- Al Jazeera and Canon logos included as registered resources.
- Theme file: `Inventory.PortfolioTheme.json` (generated from `Shared/Standards/portfolio-theme.tokens.json`).

## What Needs Desktop Validation

- Open `Inventory Report.pbip` in Power BI Desktop.
- Confirm ODBC DSN `HANA_B1` connectivity and data load.
- Verify all 12 relationships resolve correctly.
- Check all 5 pages render with proper data.
- Fine-tune visual sizing and layout after live data load.
- Validate the new `Fact_StockCoverPolicy` refresh, relationship to `Dim_Item`, rolling-window sales quantities, blended target quantity, and Stock Cover Value Exposure / Reorder Action List visuals in Power BI Desktop.

## Known Gaps

- AvgPrice returns 0 for many items at aggregate level — Stock Value measure may undercount; OIVL cost layers would be more accurate.
- No slow-moving/dead stock analysis yet (LstSalDate is NULL for all in-stock items).
- Serial number tracking page deferred to future iteration.
- Data window is short (~3 months: Dec 2025 – Mar 2026).
