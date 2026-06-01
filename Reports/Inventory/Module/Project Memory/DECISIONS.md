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

## 2026-05-31 — Films 125 150-day policy override

- **`Films 125`** (*Blue Ray Printing Roll 125 Films*) added to `PolicyFilm150ItemCodes` for **150-day** `PolicyDays` (was default **60** under `#N/A` business type).

## 2026-05-24 — Film item 150-day policy override

- Nine **#N/A** film SKUs (`NP-C-0710*` PG variants) use an **item-level 150-day** `PolicyDays` override in `Fact_StockCoverPolicy`; all other `#N/A`/blank items remain **60 days**. B2B **150** and B2C **120** defaults unchanged.
- Override list is maintained in the M query (`PolicyFilm150ItemCodes`); target qty, cover status, reorder/excess, and Stock Health / Reorder Actions all recompute from the new target on refresh.

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
- LC **closed** for reporting = SAP **Closed Document** checkbox only: `OIPF.DocStatus = 'C'`. `IsLcClosed` and `LcDocumentStatus` follow that field. **`OpenForLaC`** is a separate landed-cost workflow flag (still open for allocation) and must **not** drive the closed-document filter. Procurement page filter: `IsLcClosed = 1`. Reconcile doc counts and totals to SAP after each semantic refresh.
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
- **Detail table (*LC Doc → Receipt Line → Supplier + Broker → Item Code + Item*)** — Most rows show **Unknown broker** in screenshots; add a broker data-quality treatment (filter, grouped “Unknown”, or on-page note) so the table does not imply false precision. Keep LC Status / Analyze-by behavior consistent with the glossary note (**Open + Closed LC default**; **Closed** for official finance view).

## 2026-05-22 — Management-friendly page and label naming (CANON Inventory)

Approved **display labels only** (measure/column names in the semantic model unchanged unless explicitly requested). Applied in **Fabric/DevelopmentWorkspace** and **Reports/Inventory/Companies/CANON** for parity; pushed to `main` (`265fea0`–`c7deb2e`).

### Navigation (page tabs)

| Page ID | Old tab name | Approved tab name |
|---------|--------------|-------------------|
| `a1b2c3d4e5f6a7b8c9d0` | Executive Summary | **Inventory Overview** |
| `c7d8e9f0a1b2c3d4e5f6` | Inventory Valuation | **Stock Value** |
| `f6a7b8c9d0e1f2a3b4c5` | Stock Cover | **Stock Health** |
| `a7b8c9d0e1f2a3b4c5d6` | Reorder Actions | **Stock Actions** |
| `e5f6a7b8c9d0e1f2a3b4` | Procurement & landed cost | **Landed Cost** |

Hidden tooltip page `tt_landed_addon_m01` — no rename.

### User exceptions (do not “improve” away)

- **Stock Health:** keep **Overstock Value** and **Overstock Value by Product Type** — do **not** rename to “Excess Stock”.
- **Stock Actions:** keep **Open PO**, **Open SO**, and **Stock Status** slicer label; **Move qty** → **Recommended quantity**.
- **Landed Cost / Shipments table:** keep **LC Doc** column header.

### Landed Cost KPI and table vocabulary

- **Supplier Cost** — supplier invoice total (was “Total purchase (IQD)”).
- **Import & Handling Costs** — freight, duty, insurance, unloading, etc. (was “Total add-ons (IQD)”). **Not** the same as total landed cost.
- **Import Cost Share %** — import ÷ (supplier + import); headline KPI and monthly mix chart logic.
- **Largest Import Cost** — top add-on category + amount.
- **Import Cost per Unit** — import ÷ receipt qty.
- **Shipments** — table title (was “Top landed-cost lines…”).
- Table column **Import Cost % of Supplier** — import ÷ supplier only (different denominator from Import Cost Share %).

Do **not** rename “Import & Handling Costs” to **Total Landed Cost** — that would mislabel a partial amount.

### Naming principles for future Inventory label work

- Page tab ↔ page header should match.
- Drop redundant “(IQD)” on cards when numbers are already IQD-formatted.
- Prefer plain language for management; keep SAP field names (**LC Doc**, **Open PO/SO**) when the team uses them daily.
- When renaming in PBIR JSON, avoid apostrophes in `Literal` values (invalid JSON); use “is not” instead of “isn’t”.

## 2026-05-27 — PAPER Inventory unit standard

- PAPERENTITY inventory UOM is **KG** in SAP; business-facing Paper Inventory quantities should be shown as **tons** (`raw SAP qty / 1000`).
- Management labels should say **(Tons)** for quantities and **/ Ton** for quantity-based costs; raw kg should only appear in audit/drill-through contexts with an explicit `Raw Quantity (kg)` label.
- Paper `Reorder IQD Impact` must multiply raw kg quantities by `AvgItemCost` (IQD/kg), while visible Stock Actions quantities remain displayed in tons.
- Paper stock-cover logic keeps a **1-ton materiality threshold** for planning actions, but low-demand zero-stock rows must **not** be labeled Healthy. They are classified as `Low demand - no stock` with `Review slow mover`; positive sub-ton targets display as `<1` ton instead of being hidden as no target.

## 2026-06-01 — PAPER 100-day policy and 24-ton minimum SKU order

- PAPERENTITY stock-cover policy target is **100 days**.
- Paper quantities remain displayed in **tons**, but the semantic model still calculates in raw SAP **kg**.
- For `Buy` recommendations, `Fact_StockCoverPolicy[SuggestedReorderQty]` must respect the business minimum order per SKU: if the calculated shortage is positive but below **24 tons** (`24,000 kg`), recommend **24 tons**. Larger shortages keep the calculated shortage quantity.
- Keep the minimum-order rule embedded in **Recommended Qty (Tons)**. Do **not** expose a separate **MOQ Extra (Tons)** column in Stock Actions; it was too confusing for business users.
