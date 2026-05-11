# Decisions

## Purpose

Use this file for approved directions and durable constraints in the Inventory Report module.

## 2026-03-27

- Start the Inventory report by creating and stabilizing module structure before building report pages.
- Keep this module's folder contract and operating style aligned with `Reports/Finance` where applicable.
- Use `Inventory Report` as the initial working title unless business naming changes later.
- Inherit the portfolio unified theme and branding style from the Finance baseline (backgrounds, chart palettes, KPI styling, and overall visual language).

## 2026-03-27 — PBIP Build

- PBIP created with 5 pages and full SAP HANA ODBC semantic model targeting `CANON` schema.
- Star schema design: 3 dimension tables (Item, Warehouse, Date) + 6 fact tables (WarehouseStock, StockMovement, Transfer, Delivery, GoodsReceipt, PurchaseOrder).
- 24 DAX measures in `_Measures` table covering stock position, movements, transfers, deliveries, and procurement.
- Logos (Al Jazeera + Canon) and theme copied from Finance registered resources to maintain brand consistency.
- IQD currency formatting applied to monetary measures using `ar-IQ` culture hint.
- Stock Value measure uses `AvgPrice` from OITM as interim approach; OIVL cost layers recommended for future accuracy.
- `Dim_Date` is a DAX calculated calendar (Dec 2025 – Dec 2026) to match the SAP data window.

## 2026-05-08 — CANON stock-cover policy

- Added quantity-based stock-cover policy for CANON inventory: B2B targets 120 days, B2C targets 90 days, and `#N/A`/blank targets 60 days.
- Policy status is based on stock quantity versus sales velocity, not stock value; stock value remains secondary impact context only.
- Sales velocity is calculated from SAP invoice quantity net of credit memo quantity (`OINV/INV1` minus `ORIN/RIN1`) across the same CANON + filtered ALJAZEERA branch logic used by the saved SAP stock analysis query.
- Target stock quantity uses blended daily velocity from refresh-relative windows: 35% of 90-day net sales rate, 35% of 180-day net sales rate, and 30% of 365-day net sales rate; the 30-day window is not part of target calculation.
- Existing SAP planning fields (`ReorderPnt`, `ReorderQty`, `MinLevel`, `MaxLevel`, `LeadTime`, warehouse min/max) are not used for this version because they are largely unpopulated in CANON.
- Healthy band remains the SQL/M policy band: under stock below 90% of target, over stock above 110% of target, otherwise equal/healthy.
- Reworked the former Stock Cover Health page into **Stock Cover Value Exposure** so it shows IQD impact from the quantity-based policy, while the Reorder Action List remains the detailed quantity/action page.
- Stock-cover value measures use average item cost only: overstock value = excess quantity × average cost, understock value = suggested reorder quantity × average cost, and healthy/no-sales value = current stock quantity/value at average cost. Item status remains based on quantity cover versus 120/90/60 policy and blended sales velocity.
- Stock Cover Value Exposure should separate **current stock value by cover status** from **missing reorder value**; the status donut uses current stock value so no status slice exceeds total current stock value.

## 2026-05-09 — Stock-cover suggested actions (labels)

`Fact_StockCoverPolicy.SuggestedAction` uses this vocabulary (same 90%/110% bands as `StockCoverStatus` for buy/over/healthy; **Dead** when blended velocity is zero):

- **Buy** — On-hand below 90% of target; replenishment suggested.
- **Reduce** — On-hand above 110% of target; trim or stop buying.
- **Good health** — On-hand between 90% and 110% of target.
- **Dead** — On-hand with **no net sales in the 90/180/365-day windows** (blended velocity = 0); non-moving / obsolescence risk.
- **No Action** — No on-hand and no demand in those windows; nothing to reorder or clear.

## 2026-05-11 — Executive Summary COGS definitions

- **Total COGS** means SAP actual booked cost for valid sales inventory movements: `OINM.CogsVal`, excluding canceled sales documents and netting credit/return movement types.
- **Current Total Cost** means the same net sold quantity valued at current item cost. Current cost prefers selected-warehouse stock value/on-hand, then item `AvgPrice`, then item `LastPurPrc`; only items with no valid fallback remain zero.
- For cost direction over time, use **Average Unit COGS** (`Total COGS / Total Sold Qty`) rather than Current Total Cost. Current Total Cost is a present-day valuation applied to sold quantity, while Average Unit COGS shows the realized sale-time cost trend.
