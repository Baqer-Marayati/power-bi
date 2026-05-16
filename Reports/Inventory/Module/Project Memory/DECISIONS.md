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

## 2026-05-11 — Procurement purchase-cost and COGS comparison

- **Paid / received unit** on Procurement & Suppliers uses Goods Receipt PO receipt lines: positive `Fact_GoodsReceipt[LineTotal] / Fact_GoodsReceipt[Quantity]` from `OPDN/PDN1`.
- The page compares that inbound purchase-cost trend with **Average Unit COGS** from sales/outbound movements, but keeps the two definitions separate because receipt cost can affect realized COGS with timing and valuation lag.
- Blank `Dim_Item[U_BusinessType]` values are normalized to `#N/A` in the CANON item dimension query so business-type slicers and trend series do not show unlabeled phantom buckets.

## 2026-05-15 — Procurement landed-cost extension

- **Landed unit cost** must come from SAP B1 Landed Cost allocation data, not inferred from GRPO paid line totals. The Fabric iteration uses standard SAP B1 LC tables (`OIPF`, `IPF1`, `IPF2`, `OALC`) as the source contract.
- `Fact_GoodsReceipt` keeps the paid/received unit story from `OPDN/PDN1`, now including `PDN1.LineNum` so landed-cost rows can reconcile at receipt-line grain.
- Landed-cost categories are reported through `Dim_LandedCostCategory`: `Supplier base`, `Transport`, `Unloading`, `Tax / duty`, and `Other`. Actual SAP landed-cost codes remain visible through the dimension and are bucketed by code/name/category keywords.
- Because live CANON HANA metadata was not reachable from this Mac, the LC query must be validated in Power BI Desktop/Fabric refresh against the actual CANON schema before treating the landed values as signed off.

## 2026-05-16 — Procurement landed-cost source correction and layout rule

- Do **not** assume CANON landed-cost rows are `IPF1.BaseType = 20`. The May 16 pull showed the populated IPF1 rows under base types `18` and `69`; the Fabric query should use `OIPF` + `IPF1` as the landed-cost document truth and use `IPF1` original-base fields/fallbacks rather than filtering to GRPO-only joins.
- `Insurance` is a landed-cost reporting category for CANON because `OALC/IPF2` contains a material Insurance landed-cost code; keep it separate from generic `Other`.
- Procurement & Suppliers should keep one top KPI row like sibling Inventory pages. If landed-cost analytics need more context, add it in the bridge, trend, and detail table rather than adding a second KPI-card row.

## 2026-05-16 — Fabric Procurement LC enhanced controls

- For the Fabric-only Procurement & Suppliers pass, use **Path A**: duplicate verified `OIPF` header attributes onto `Fact_LandedCostAllocation` rather than adding a separate LC-header fact table or relationship chain.
- Broker is sourced from verified `OIPF.AgentCode` / `OIPF.AgentName` metadata and exposed directly on the landed-cost allocation fact for the Broker slicer and detail table.
- LC status uses verified `OIPF.OpenForLaC` first (`Y` = Open, `N` = Closed) with `OIPF.DocStatus` as a fallback display/status signal. Treat this as source-schema aligned but still requiring Desktop/Fabric refresh validation against live CANON data.
- Customs mini-block uses verified `OIPF.ExCustomSC`/`ExpCustom` for projected customs and `OIPF.ActCustSC`/`ActCustom` for actual customs, summed once per LC document in DAX to avoid allocation-row duplication.
- The date toggle is a disconnected `DateSpineChoice` table. Landed measures branch between `Fact_LandedCostAllocation[LcDate]` and `Fact_LandedCostAllocation[ReceiptDate]` with `TREATAS`; receipt date falls back to LC posting date when no GRPO date is available from the current source path.
- SAP diagnostics on May 16 proved Canon's populated LC allocation rows use `IPF1.BaseType`/`OriBDocTyp` patterns `18` and `69`, with zero matches when OPDN is joined through a hard `OriBDocTyp = '20'` predicate. The Fabric query must not require `OriBDocTyp = '20'` for receipt-date lookup.
- For booked landed add-ons, prefer `IPF2.CostSum` (local/booked amount) over `IPF2.CostSumSC`; `CostSumSC` is only a fallback. The visible customs actual should come from IPF2/OALC `Tax / duty` booked lines, while OIPF header customs remains a projection/reference signal.

## 2026-05-12 — Executive Summary sold-mix cost trend

- The **Qty and Cost by Business Type** table compares realized **Average Unit COGS** with **Sold Weighted Avg Current Unit Cost**. Group rows use sold-quantity weighting across SKUs, not stock-value/on-hand weighting, so the displayed **Current Item Cost** and **Cost Trend** describe the same sold mix at every drill grain.

## 2026-05-16 — Procurement & Suppliers: KPI strip and chart UX (screenshot review)

### Single KPI row (approved meanings)

Keep **one** headline card row only. Each card in plain language:

- **Paid / Received Unit** — Average supplier price per unit when goods are received (GRPO / receipt-line basis).
- **Landed Unit Cost** — Average full unit cost in warehouse: supplier base plus freight, duty, insurance, handling, and other allocated LC add-ons.
- **Add-On % of Landed** — Share of landed cost that is add-ons vs supplier base (logistics/tax burden at a glance).
- **Largest Driver** — The landed-cost category that contributes most to landed unit cost under current filters. Must resolve to a **named category** (and optional value); do **not** leave a permanent blank/`--` placeholder.
- **Average Unit COGS** — Average booked unit cost on outbound sales (`Total COGS / sold qty` story); comparable in spirit to procurement unit costs but **different grain and timing** than receipt landed cost.

### Second-row customs cards

- **Remove** the three-card strip (**Header Customs Projection**, **Booked Customs Fees**, **Customs Gap**) from the page layout while values are empty or untrusted — empty KPI tiles read as broken reporting.
- If customs reconciliation becomes production-ready, prefer **one** optional KPI or **detail/table + waterfall** context rather than reintroducing a second full card row.

### Other visuals (recommended polish)

- **Waterfall (*Why Did Landed Unit Cost Change?*)** — State **what moves** (e.g. month vs prior month or vs walk start) in title/subtitle so it matches **Analyze by**. Use the **same category colors** as the stacked mix chart (single legend mental model).
- **Stacked columns (*Landed Cost Mix by Month*)** — Keep category order stable (e.g. supplier base first or consistent stack order); avoid dense data labels unless needed for finance sign-off.
- **Line chart (*Add-on category % of landed by month*)** — The middle landed-cost trend should show add-on reporting categories over time, with one comparable Y-axis: **category add-on amount as % of total landed cost**. Exclude **Supplier base** from this visual, and keep the old **Top driver share %** out of the chart because it compresses the smaller operational category trends. Use distinct fixed colors by category and keep tooltips short: category %, add-on IQD in millions, and MoM pp change.
- **Detail table (*LC Doc → Supplier + Broker → Item*)** — Most rows show **Unknown broker** in screenshots; add a broker data-quality treatment (filter, grouped “Unknown”, or on-page note) so the table does not imply false precision. Keep LC Status / Analyze-by behavior consistent with the glossary note (**Open + Closed LC default**; **Closed** for official finance view).
