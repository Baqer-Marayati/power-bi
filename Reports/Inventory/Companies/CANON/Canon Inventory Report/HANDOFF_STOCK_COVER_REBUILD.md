# Handoff Prompt — Canon Inventory Report: Stock-Cover Policy Rebuild

> **Audience:** the next AI coding agent (or human developer) implementing this change.
> **Authoritative:** all decisions below have been confirmed with the business owner. Do **not** re-debate them.
> **One pass:** make every change in this document in a single pass, then validate. Do not stop halfway.

---

## 1. Mission

Replace the `Fact_StockCoverPolicy` logic in the Canon Inventory Report so that the "Over-Stock" headline (currently 3.0B IQD out of 5.3B total stock value, ~57%) reflects reality instead of an over-reactive forecast. After your changes, the same KPIs and the page-8 reorder action list must still render — just with corrected numbers — and the "Reorder Action List" table must surface two new transparency columns (Open PO Qty, Open SO Qty).

You are NOT redesigning the visuals. You are NOT adding new pages. You are NOT touching any other report module. Stay strictly inside the Canon Inventory Report.

---

## 2. Background context (read this carefully)

### Business setup
- **CANON** = the live operational SAP B1 schema. Cut-over date **2026-01-01**. All current stock, POs, SOs, sales live here.
- **ALJAZEERA** = legacy schema. After 2026-01-01 it is no longer used for the Canon-line inventory business. It is kept only as **historical sales reference** so we have enough demand history for the 180- and 365-day velocity windows.
- **No ALJAZEERA stock or pipeline** is operational. Ignore `ALJAZEERA.OITW`, `ALJAZEERA.OPOR`, `ALJAZEERA.ORDR` entirely.
- ALJAZEERA still has 3 customer cards that represent **internal branch-to-branch sales** and must be excluded from real demand: `CUS0001159`, `CUS0001091`, `JAZC000345`. The current M already excludes these — keep them excluded.
- The 12 OBPL branches in ALJAZEERA do **NOT** all need to be excluded — only the 3 cardcodes above. Do not add others, even if names look "internal".

### What's wrong with the current report
- Velocity uses a 35/35/30 weighted MA over 90/180/365 days, applied uniformly. This over-weights short-term silence on lumpy B2B copier consumables.
- "Available" stock is the raw `OITW.OnHand`, ignoring open POs (incoming) and open SOs (already promised).
- Cover policy days (120/90/60) are used as if they were "cover-on-shelf" but the business actually intends them as **total replenishment horizon** (cash-out → on-shelf → buffer).
- 365-day window is divided by literal 365 even when the item only has a few months of history → newer SKUs look perpetually over-stocked.
- ALJAZEERA sales after the 2026-01-01 cut-over leak into demand (they are junk/test data and must be filtered).

### Confirmed business decisions (locked)
| Topic | Decision |
|---|---|
| Stock & pipeline scope | **CANON only** (`OITW`, `OPOR`/`POR1`, `ORDR`/`RDR1`) |
| Sales scope | **CANON sales (DocDate ≥ 2026-01-01) UNION ALJAZEERA sales (DocDate < 2026-01-01)**, with 3-cardcode exclusion still applied to ALJAZEERA |
| Cut-over date | **2026-01-01** (hardcode it) |
| ALJAZEERA after cut-over | Fully stopped — exclude all rows with `DocDate >= 2026-01-01` |
| OWTR (warehouse transfers) | **Skip entirely** — already reflected in `OITW.OnHand` |
| Tolerance bands | Keep the existing ±10% (don't redesign safety stock yet) |
| Lead-time per item / MOQ / strategic flag | **Out of scope this round.** Will come in a later round when the buyer-supplied CSV exists |
| Policy days | **B2B = 150, B2C = 120, anything else (incl. blanks/`#N/A`) = 60** |
| Velocity weights | Channel-specific (see §6.4 below) |
| Effective-days normalization | Required (see §6.4) |

---

## 3. Files you will touch

You may only modify these. Do not modify anything else.

1. `Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.SemanticModel/definition/tables/Fact_StockCoverPolicy.tmdl`
   — full M `partition` rewrite (and add 2 new columns: `OpenPOQty`, `OpenSOQty`, `NetAvailable`). Keep all existing column names so visual references don't break.

2. `Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.Report/definition/pages/a7b8c9d0e1f2a3b4c5d6/visuals/table_reorder_actions/visual.json`
   — append two projections (`OpenPOQty`, `OpenSOQty`) and corresponding `columnWidth` / `columnFormatting` entries.

Do not edit page 7 (`f6a7b8c9d0e1f2a3b4c5`) — its KPIs/charts already reference the same columns and will auto-update.

---

## 4. SAP HANA connection (for validation only — not for the model itself)

The model's `Odbc.Query("dsn=HANA_B1", ...)` connection is already defined in the existing M. **Do not change the DSN string.** It is the same `HANA_B1` ODBC DSN used today.

For your own validation queries (Python `hdbcli`), use:
```
HOST = hana-vm-107
PORT = 30013
TENANT_DB = HV107C21694P01
USERNAME = SYSTEM3
PASSWORD = 03262026Thursday!
Schema: CANON (and ALJAZEERA for legacy sales only)
```

---

## 5. Reference SKU for end-to-end validation

Use **`0481C002BA`** ("C-EXV 51 Black Toner") throughout. Known values from HANA at the time of writing:

- B2B item; CANON.OITW: 104 units on hand, 16,386,101.16 IQD avg-cost value
- Lifetime sales (CANON+ALJAZEERA, 3 cards excluded): 57 units, 10,962,250 IQD
- First-sale date: 2024-10-16; last-sale date: 2025-12-30 → 440 days "alive"
- Rolling sales windows (as of today): 90d = 0, 180d = 13, 365d = 27
- No open POs, no open SOs

Expected after rebuild (B2B weights 15/35/50, policy 150 d, with effective-days normalization — note: since the item has > 365 d of life, the 365-window denominator stays 365):

```
V90  = 0 / 90  = 0
V180 = 13/180  = 0.072222
V365 = 27/365  = 0.073973
Velocity = 0.15*0 + 0.35*0.072222 + 0.50*0.073973 = 0.062264 qty/day
Target   = 0.062264 * 150 = 9.34 units
NetAvail = 104 + 0 - 0    = 104
ExcessQty = 104 - 9.34    = 94.66
StockCoverStatus  = "Over Stock"
SuggestedAction   = "Reduce"
Value = 94.66 * (16386101.16 / 104) = ~14.92 M IQD
```

If your implementation does not produce numbers within rounding distance of these, stop and debug before continuing.

---

## 6. Detailed implementation spec

### 6.1 The `partition` body — full structure

Replace the current `partition Fact_StockCoverPolicy = m` block with one new HANA SQL Source query plus the M post-processing pipeline below. Keep the same `mode: import`.

#### 6.1.1 Single HANA SQL `Source` (the heavy lifting)

The existing M splits into a `Source` query and a `RollingSource` query then merges in M. **Consolidate into one SQL** so HANA does the join. Structure (pseudocode of the SQL CTEs):

```
WITH
  -- 1) Lifetime sales (qty/COGS/value) - CANON live + ALJAZEERA legacy
  SalesLines AS (
      -- CANON OINV (DocDate >= '2026-01-01')
      SELECT B."ItemCode", A."DocDate",
             B."Quantity"            AS Qty,
             B."StockValue"          AS COGS,
             B."LineTotal"           AS SalesValue
      FROM "CANON"."OINV" A JOIN "CANON"."INV1" B ON A."DocEntry"=B."DocEntry"
      WHERE A."CANCELED"='N' AND A."DocType"='I'
        AND IFNULL(B."ItemCode",'')<>''
        AND A."DocDate" >= '2026-01-01'
      UNION ALL
      -- CANON ORIN (returns)
      SELECT B."ItemCode", A."DocDate",
             B."Quantity" * -1, B."StockValue" * -1, B."LineTotal" * -1
      FROM "CANON"."ORIN" A JOIN "CANON"."RIN1" B ON A."DocEntry"=B."DocEntry"
      WHERE A."CANCELED"='N' AND A."DocType"='I'
        AND IFNULL(B."ItemCode",'')<>''
        AND A."DocDate" >= '2026-01-01'
      UNION ALL
      -- ALJAZEERA OINV legacy (DocDate < '2026-01-01'), 3-card exclusion
      SELECT B."ItemCode", A."DocDate",
             B."Quantity", B."StockValue", B."LineTotal"
      FROM "ALJAZEERA"."OINV" A JOIN "ALJAZEERA"."INV1" B ON A."DocEntry"=B."DocEntry"
      WHERE A."CANCELED"='N' AND A."DocType"='I'
        AND IFNULL(B."ItemCode",'')<>''
        AND A."DocDate" < '2026-01-01'
        AND A."CardCode" NOT IN ('CUS0001159','CUS0001091','JAZC000345')
      UNION ALL
      -- ALJAZEERA ORIN legacy
      SELECT B."ItemCode", A."DocDate",
             B."Quantity" * -1, B."StockValue" * -1, B."LineTotal" * -1
      FROM "ALJAZEERA"."ORIN" A JOIN "ALJAZEERA"."RIN1" B ON A."DocEntry"=B."DocEntry"
      WHERE A."CANCELED"='N' AND A."DocType"='I'
        AND IFNULL(B."ItemCode",'')<>''
        AND A."DocDate" < '2026-01-01'
        AND A."CardCode" NOT IN ('CUS0001159','CUS0001091','JAZC000345')
  ),
  Sales AS (
      SELECT "ItemCode",
             SUM(Qty) AS TotalQtySold,
             SUM(COGS) AS TotalCOGS,
             SUM(SalesValue) AS TotalItemSales,
             MIN("DocDate") AS MinDocDate,
             MAX("DocDate") AS MaxDocDate
      FROM SalesLines
      GROUP BY "ItemCode"
  ),
  Rolling AS (
      SELECT "ItemCode",
             SUM(CASE WHEN "DocDate" >= ADD_DAYS(CURRENT_DATE, -90 ) THEN Qty ELSE 0 END) AS SalesQty90Days,
             SUM(CASE WHEN "DocDate" >= ADD_DAYS(CURRENT_DATE, -180) THEN Qty ELSE 0 END) AS SalesQty180Days,
             SUM(CASE WHEN "DocDate" >= ADD_DAYS(CURRENT_DATE, -365) THEN Qty ELSE 0 END) AS SalesQty365Days
      FROM SalesLines
      GROUP BY "ItemCode"
  ),
  -- 2) Stock (CANON only)
  Stock AS (
      SELECT W."ItemCode",
             SUM(W."OnHand")                       AS TotalQtyAvailable,
             SUM(W."OnHand" * W."AvgPrice")        AS TotalAvgCostValue
      FROM "CANON"."OITW" W
      GROUP BY W."ItemCode"
  ),
  -- 3) Open Purchase Orders (CANON, header AND line both open)
  OpenPO AS (
      SELECT B."ItemCode", SUM(B."OpenQty") AS OpenPOQty
      FROM "CANON"."OPOR" A JOIN "CANON"."POR1" B ON A."DocEntry"=B."DocEntry"
      WHERE A."DocStatus"='O' AND B."LineStatus"='O'
        AND IFNULL(B."ItemCode",'')<>''
      GROUP BY B."ItemCode"
  ),
  -- 4) Open Sales Orders (CANON, header AND line both open)
  OpenSO AS (
      SELECT B."ItemCode", SUM(B."OpenQty") AS OpenSOQty
      FROM "CANON"."ORDR" A JOIN "CANON"."RDR1" B ON A."DocEntry"=B."DocEntry"
      WHERE A."DocStatus"='O' AND B."LineStatus"='O'
        AND IFNULL(B."ItemCode",'')<>''
      GROUP BY B."ItemCode"
  ),
  -- 5) Master row: every inventory item in CANON.OITM
  Base AS (
      SELECT
          COALESCE(I."U_BusinessType",'#N/A') AS U_BusinessType,
          COALESCE(I."U_GroupType",   '#N/A') AS U_GroupType,
          COALESCE(I."U_ProductType", '#N/A') AS U_ProductType,
          COALESCE(I."U_SegmentType", '#N/A') AS U_SegmentType,
          I."ItemCode", I."ItemName",
          COALESCE(ST.TotalQtyAvailable,0)    AS TotalQtyAvailable,
          CASE WHEN COALESCE(ST.TotalQtyAvailable,0)=0 THEN 0
               ELSE COALESCE(ST.TotalAvgCostValue,0)/ST.TotalQtyAvailable END AS AvgItemCost,
          COALESCE(ST.TotalAvgCostValue,0)    AS TotalItemCost,
          COALESCE(S.TotalQtySold,0)          AS TotalQtySold,
          CASE WHEN COALESCE(S.TotalQtySold,0)=0 THEN 0
               ELSE COALESCE(S.TotalItemSales,0)/S.TotalQtySold END AS AvgItemPrice,
          CASE WHEN COALESCE(S.TotalQtySold,0)=0 THEN 0
               WHEN DAYS_BETWEEN(S.MinDocDate, S.MaxDocDate) <= 0 THEN 1
               ELSE DAYS_BETWEEN(S.MinDocDate, S.MaxDocDate) END AS SellingDurationDays,
          S.MinDocDate                        AS FirstSaleDate,
          DAYS_BETWEEN(S.MinDocDate, CURRENT_DATE) AS DaysSinceFirstSale,
          COALESCE(R.SalesQty90Days, 0)       AS SalesQty90Days,
          COALESCE(R.SalesQty180Days,0)       AS SalesQty180Days,
          COALESCE(R.SalesQty365Days,0)       AS SalesQty365Days,
          COALESCE(PO.OpenPOQty,0)            AS OpenPOQty,
          COALESCE(SO.OpenSOQty,0)            AS OpenSOQty
      FROM "CANON"."OITM" I
      LEFT JOIN Sales   S  ON S."ItemCode"  = I."ItemCode"
      LEFT JOIN Rolling R  ON R."ItemCode"  = I."ItemCode"
      LEFT JOIN Stock   ST ON ST."ItemCode" = I."ItemCode"
      LEFT JOIN OpenPO  PO ON PO."ItemCode" = I."ItemCode"
      LEFT JOIN OpenSO  SO ON SO."ItemCode" = I."ItemCode"
      WHERE I."InvntItem" = 'Y'
  )
SELECT * FROM Base
```

> **Important:** the SQL must be embedded as a single string literal in `Odbc.Query("dsn=HANA_B1", "...")`. All double-quotes inside become `""` (M-style escaping). Newlines become `#(lf)`. Match the existing file's style exactly.

#### 6.1.2 M post-processing on top of `Source`

```text
let
    Source = Odbc.Query("dsn=HANA_B1", "<the SQL above, escaped>"),

    // ---- Effective denominator per window (item-life-aware) ----
    AddEffDays = Table.AddColumn(Source, "EffDays365",
        each let d = if [DaysSinceFirstSale] = null then 0 else [DaysSinceFirstSale]
             in if d < 1 then 1 else (if d > 365 then 365 else d), Int64.Type),
    AddEffDays180 = Table.AddColumn(AddEffDays, "EffDays180",
        each let d = [DaysSinceFirstSale] in if d = null or d < 1 then 1 else (if d > 180 then 180 else d), Int64.Type),
    AddEffDays90  = Table.AddColumn(AddEffDays180, "EffDays90",
        each let d = [DaysSinceFirstSale] in if d = null or d < 1 then 1 else (if d > 90 then 90 else d), Int64.Type),

    // ---- Per-window velocities ----
    AddV90  = Table.AddColumn(AddEffDays90,  "SalesVelocity90Days",  each [SalesQty90Days]  / [EffDays90],  type number),
    AddV180 = Table.AddColumn(AddV90,        "SalesVelocity180Days", each [SalesQty180Days] / [EffDays180], type number),
    AddV365 = Table.AddColumn(AddV180,       "SalesVelocity365Days", each [SalesQty365Days] / [EffDays365], type number),

    // ---- Channel policy days ----
    AddPolicy = Table.AddColumn(AddV365, "PolicyDays",
        each if [U_BusinessType] = "B2B" then 150
             else if [U_BusinessType] = "B2C" then 120
             else 60, Int64.Type),

    // ---- Channel weights with history-aware fallback ----
    // Returns the blended velocity for the item.
    AddBlend = Table.AddColumn(AddPolicy, "SalesVelocityQtyPerDay", each
        let
            life = if [DaysSinceFirstSale] = null then 0 else [DaysSinceFirstSale],
            // pick base weights by channel
            w = if [U_BusinessType] = "B2B" then [w90=0.15, w180=0.35, w365=0.50]
                else if [U_BusinessType] = "B2C" then [w90=0.25, w180=0.45, w365=0.30]
                else [w90=0.40, w180=0.35, w365=0.25],
            // life-based fallback: < 180 d → use V90 only; 180–365 d → fold w365 into w180
            adj = if life < 180 then [w90=1, w180=0, w365=0]
                  else if life < 365 then [w90=w[w90], w180=w[w180]+w[w365], w365=0]
                  else w
        in
            adj[w90]*[SalesVelocity90Days] + adj[w180]*[SalesVelocity180Days] + adj[w365]*[SalesVelocity365Days],
        type number),

    // ---- Net available, target, status, action (NOTE: based on NetAvailable now) ----
    AddNetAvail = Table.AddColumn(AddBlend, "NetAvailable",
        each [TotalQtyAvailable] + [OpenPOQty] - [OpenSOQty], type number),

    AddTarget = Table.AddColumn(AddNetAvail, "TargetStockQty",
        each [SalesVelocityQtyPerDay] * Number.From([PolicyDays]), type number),

    AddDiff = Table.AddColumn(AddTarget, "StockDifferenceQty",
        each [NetAvailable] - [TargetStockQty], type number),

    AddReorder = Table.AddColumn(AddDiff, "SuggestedReorderQty", each
        if [SalesVelocityQtyPerDay] = 0 then 0
        else if [NetAvailable] < [TargetStockQty] * 0.9 then [TargetStockQty] - [NetAvailable]
        else 0, type number),

    AddExcess = Table.AddColumn(AddReorder, "ExcessQty", each
        if [SalesVelocityQtyPerDay] = 0 and [NetAvailable] > 0 then [NetAvailable]
        else if [NetAvailable] > [TargetStockQty] * 1.1 then [NetAvailable] - [TargetStockQty]
        else 0, type number),

    AddStatus = Table.AddColumn(AddExcess, "StockCoverStatus", each
        if [SalesVelocityQtyPerDay] = 0 and [NetAvailable] > 0 then "No Sales Stock"
        else if [SalesVelocityQtyPerDay] = 0 then "No Sales / No Stock"
        else if [NetAvailable] < [TargetStockQty] * 0.9 then "Under Stock"
        else if [NetAvailable] > [TargetStockQty] * 1.1 then "Over Stock"
        else "Equal / Healthy", type text),

    AddAction = Table.AddColumn(AddStatus, "SuggestedAction", each
        if [SalesVelocityQtyPerDay] = 0 and [NetAvailable] > 0 then "Dead"
        else if [SalesVelocityQtyPerDay] = 0 then "No Action"
        else if [NetAvailable] < [TargetStockQty] * 0.9 then "Buy"
        else if [NetAvailable] > [TargetStockQty] * 1.1 then "Reduce"
        else "Good health", type text),

    // ---- Drop helper columns we don't expose to the model ----
    Final = Table.RemoveColumns(AddAction,
        {"EffDays90","EffDays180","EffDays365","FirstSaleDate","DaysSinceFirstSale"})
in
    Final
```

### 6.2 New columns to add to the table-level TMDL

In `Fact_StockCoverPolicy.tmdl`, add (alongside the existing columns) — these MUST exist so the visual can reference them:

```tmdl
column OpenPOQty
    dataType: double
    formatString: #,0.00
    lineageTag: cc000000-0000-0000-0000-000000000029
    summarizeBy: sum
    sourceColumn: OpenPOQty
    annotation SummarizationSetBy = Automatic

column OpenSOQty
    dataType: double
    formatString: #,0.00
    lineageTag: cc000000-0000-0000-0000-000000000030
    summarizeBy: sum
    sourceColumn: OpenSOQty
    annotation SummarizationSetBy = Automatic

column NetAvailable
    dataType: double
    formatString: #,0.00
    lineageTag: cc000000-0000-0000-0000-000000000031
    summarizeBy: sum
    sourceColumn: NetAvailable
    annotation SummarizationSetBy = Automatic
```

Use fresh `lineageTag` GUIDs that don't collide with existing ones (the existing ones end in 0001..0028).

### 6.3 Existing columns to KEEP (do not rename, do not change `lineageTag`)
All existing columns stay (visuals reference them). They will simply receive different *values*:
`U_BusinessType`, `U_GroupType`, `U_ProductType`, `U_SegmentType`, `ItemCode`, `ItemName`, `TotalQtyAvailable`, `AvgItemCost`, `TotalItemCost`, `TotalQtySold`, `AvgItemPrice`, `SellingDurationDays`, `PolicyDays`, `SalesVelocityQtyPerDay`, `TargetStockQty`, `StockDifferenceQty`, `SuggestedReorderQty`, `ExcessQty`, `StockCoverStatus`, `SuggestedAction`, `Value` (calculated, DAX), `SalesQty90Days`, `SalesQty180Days`, `SalesQty365Days`, `SalesVelocity90Days`, `SalesVelocity180Days`, `SalesVelocity365Days`.

### 6.4 The `Value` calculated column

**Do NOT modify the DAX of the `Value` column.** It already branches on `StockCoverStatus` (Under Stock → SuggestedReorderQty × AvgItemCost; Over Stock → ExcessQty × AvgItemCost; etc.). Since both `ExcessQty` and `SuggestedReorderQty` now derive from `NetAvailable`, the `Value` column will automatically reflect the correction. Only the `StockCoverStatus = "Over Stock"` string was already supported.

> **Action note about action labels:** the legacy SQL produced `"Buy"/"Hold"/"Hold / Reduce"/"No Action"/"Review / Reduce"`. The current M overwrites those with `"Buy"/"Reduce"/"Good health"/"No Action"/"Dead"`. The DAX `Value` column's SWITCH only looks at `StockCoverStatus`, never at `SuggestedAction`, so action label changes are safe. Keep the M label set above (`Dead`, `No Action`, `Buy`, `Reduce`, `Good health`) — they are what the slicer on page 8 already filters on.

### 6.5 Page 8 visual update — `table_reorder_actions/visual.json`

Add two new projections at the end of the `Values.projections` array (after `SuggestedAction`):

```json
{
  "field": {
    "Aggregation": {
      "Expression": {
        "Column": {
          "Expression": { "SourceRef": { "Entity": "Fact_StockCoverPolicy" } },
          "Property": "OpenPOQty"
        }
      },
      "Function": 0
    }
  },
  "queryRef": "Sum(Fact_StockCoverPolicy.OpenPOQty)",
  "nativeQueryRef": "Open PO Qty",
  "displayName": "Open PO Qty"
},
{
  "field": {
    "Aggregation": {
      "Expression": {
        "Column": {
          "Expression": { "SourceRef": { "Entity": "Fact_StockCoverPolicy" } },
          "Property": "OpenSOQty"
        }
      },
      "Function": 0
    }
  },
  "queryRef": "Sum(Fact_StockCoverPolicy.OpenSOQty)",
  "nativeQueryRef": "Open SO Qty",
  "displayName": "Open SO Qty"
}
```

Then add matching `columnWidth` entries (≈82D each), `columnFormatting` entries (Center alignment, `labelPrecision: 2L`) following the pattern of `Sum(Fact_StockCoverPolicy.TotalQtyAvailable)` already in the file.

Place the two new columns **between `Target Qty` and `Stock Status`** so the table reads logically: Item Code · Item Name · Available · Sold · Policy Days · Target · **Open PO** · **Open SO** · Status · Value · Action.

Do not change `position`, `objects.title`, sort, or visual-container styling.

---

## 7. Validation steps (mandatory before declaring done)

1. **Unit-level math check (Python `hdbcli`)**: re-run the SQL above for `0481C002BA` and compute the M post-processing in Python. Confirm the seven numbers match the expected values in §5 within 0.5% rounding.
2. **TMDL parses**: run `pbi-tools` *if available*; otherwise open the PBIP in Power BI Desktop and confirm the model loads with no errors.
3. **Refresh the model in Power BI Desktop** (you cannot do this from CLI). Ask the user to do this and report back.
4. **Eyeball the table on page 8**: locate `0481C002BA`. Confirm the 11 columns render and the values are within rounding of expected.
5. **Headline numbers — capture before/after**:
   - Sum of `Value` where `StockCoverStatus = "Over Stock"` (current report = 3.0B)
   - Sum of `TotalItemCost` (current report = 5.3B)
   - Count of items per `StockCoverStatus`
   - Count of items per `SuggestedAction`
   Report the deltas to the user. The "Over Stock" total *should* drop materially; if it goes UP, you have a bug.
6. **Spot-check 5 more SKUs** spanning each `StockCoverStatus` bucket and confirm their numbers reconcile to the SQL.
7. **Lint**: run `ReadLints` on the two edited files. Fix anything you introduced. Pre-existing lints not from your changes can be left.

---

## 8. Things you must NOT do

- Do not change the DSN string `dsn=HANA_B1`. The user's gateway/refresh service depends on it.
- Do not edit any file outside the two listed in §3.
- Do not introduce new tables, new measures, new pages, new visuals.
- Do not modify the `Value` DAX column.
- Do not touch `relationships.tmdl`, `model.tmdl`, `culture.tmdl`, or any other report-level definition.
- Do not "improve" the OWTR situation in code — it is intentionally out of scope.
- Do not add safety stock / lead-time / strategic-flag logic. That is a future round.
- Do not commit. Stop after validation and let the user run git themselves.

---

## 9. Deliverables to the user when you finish

A short message containing:
1. Confirmation that all changes in §6 are applied.
2. The expected vs. actual numbers for `0481C002BA` (table from §5).
3. The before/after headline numbers from validation step §7.5.
4. A list of any anomalies you noticed during spot-checking.
5. A note for the user to (a) refresh the PBIP, (b) sanity-check page 7 KPIs, (c) commit when satisfied.

---

## 10. If you hit an unexpected blocker

- **Missing column** in HANA tables (e.g. SAP B1 version differs): query `SYS.TABLE_COLUMNS` to find the equivalent and document the substitution. Don't invent column names.
- **HANA SQL error** on the consolidated query: simplify by reverting to two `Odbc.Query` calls (live + rolling) and merging in M, like the current file does. Document why.
- **Lineage tag collision**: pick another GUID. The existing model uses `cc000000-0000-0000-0000-0000000000NN`; use `0029`, `0030`, `0031` per the spec.
- **Anything ambiguous in this spec**: stop and ask the user. Do not guess on business logic.

---

## 11. Quick recap of the math (one screen)

```
PolicyDays:  B2B=150, B2C=120, else=60
Velocity windows w (90/180/365):
   B2B:  0.15 / 0.35 / 0.50
   B2C:  0.25 / 0.45 / 0.30
   else: 0.40 / 0.35 / 0.25
History fallback:
   life<180d → use V90 only (w=1/0/0)
   180≤life<365 → fold w365 into w180 (B2B becomes 0.15/0.85/0)
   life≥365  → use base weights
EffDaysN = clamp(DaysSinceFirstSale, 1..N)
VelocityN = SalesQtyN / EffDaysN
SalesVelocityQtyPerDay = w90·V90 + w180·V180 + w365·V365
TargetStockQty = SalesVelocityQtyPerDay × PolicyDays
NetAvailable = OnHand + OpenPOQty − OpenSOQty
StockDifferenceQty = NetAvailable − TargetStockQty
SuggestedReorderQty = (Vel>0 AND NetAvail < Target·0.9) ? Target − NetAvail : 0
ExcessQty           = (Vel=0 AND NetAvail>0) ? NetAvail
                    : (NetAvail > Target·1.1) ? NetAvail − Target : 0
StockCoverStatus    = ... (see §6.1.2)
SuggestedAction     = ... (see §6.1.2)
Value               = (existing DAX, unchanged)
```

---

End of handoff.
