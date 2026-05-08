# Current Status

## Date

- Last updated: May 9, 2026

## Current Reality

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
