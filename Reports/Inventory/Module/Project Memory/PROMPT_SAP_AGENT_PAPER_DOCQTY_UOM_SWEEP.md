# Prompt (SAP-reachable agent): Paper **document-quantity UoM sweep** (GR / PO / Transfer / Delivery / Sales / Open SO+PO)

Use this on the **SAP HANA / Business One** machine that can query schema **`PAPERENTITY`** through the same ODBC DSN the Power BI model uses (`HANA_B1`). This is a **read-only investigation** — do **not** change any SAP data, UoM setup, or documents. Produce CSVs + a README and hand the folder path back.

This is a **follow-up** to the landed-cost UoM diagnostic (`Paper_PBIP_LandedUoM_Diag_*`), which **proved** that `IPF1."Quantity"` (and the A/P-invoice lines `PCH1` it is based on) are stored in **mixed units per line** — `TON` lines carry `NumPerMsr = 1000`, `KG` lines carry `NumPerMsr = 1`, and `Quantity × NumPerMsr = InvQty` (kg) on every line. The Power BI model divides quantity by 1000 everywhere, so it is wrong on every ton-booked line.

---

## 0) Why you are running this

The Power BI model pulls **document line quantities** into several fact tables and then divides by 1000 to get tons, assuming everything is kg. We need to know **which other document line tables also contain ton-booked lines** (mixed units) so the model can be corrected in one coordinated pass. We also need to confirm **which inventory-UoM quantity column** each line table exposes (so the fix can switch to it instead of guessing ÷1000).

The five model facts under suspicion and the exact source columns they read today:

| Power BI fact | SAP source | Column read today | Inventory-UoM column to verify |
|---|---|---|---|
| `Fact_GoodsReceipt` | `OPDN`→`PDN1` | `PDN1."Quantity"` | `PDN1."InvQty"`, `PDN1."NumPerMsr"` |
| `Fact_PurchaseOrder` | `OPOR`→`POR1` | `POR1."Quantity"` | `POR1."InvQty"`, `POR1."NumPerMsr"` |
| `Fact_Transfer` | `OWTR`→`WTR1` | `WTR1."Quantity"` | `WTR1."InvQty"`, `WTR1."NumPerMsr"` |
| `Fact_Delivery` | `ODLN`→`DLN1` | `DLN1."Quantity"` | `DLN1."InvQty"`, `DLN1."NumPerMsr"` |
| `Fact_StockCoverPolicy` (sales) | `OINV`→`INV1`, `ORIN`→`RIN1` | `INV1."Quantity"`, `RIN1."Quantity"` | `INV1."InvQty"` / `RIN1."InvQty"`, `*."NumPerMsr"` |
| `Fact_StockCoverPolicy` (open) | `OPOR`→`POR1`, `ORDR`→`RDR1` | `POR1."OpenQty"`, `RDR1."OpenQty"` | `POR1."OpenInvQty"` / `RDR1."OpenInvQty"` (verify name) |

> **Critical compatibility note:** `Fact_StockCoverPolicy` mixes `OITW."OnHand"` (always **kg**) with sales/open quantities in the **same row** and uses hard-coded planning gates (`>= 1000`). If sales / open SO+PO are ton-booked on some lines, the reorder math and BUY/REDUCE/HEALTHY actions are distorted, not just a display number. Treat the sales + open SO/PO findings as the highest priority in your README.

**Your job:** for each table above, quantify how many lines are ton-booked vs kg-booked, confirm the `NumPerMsr`/`InvQty` identity holds, and confirm the exact inventory-UoM column name to switch to. Do **not** propose Power BI edits — deliver evidence + a clear per-table verdict.

---

## 1) Environment & conventions

- **DSN / connection:** ODBC `HANA_B1` (same credentials as the Power BI gateway). **No credentials** in any output file.
- **Schema:** `PAPERENTITY` (quote identifiers: `"PAPERENTITY"."PDN1"`, etc.).
- **Mirror the Power BI WHERE clauses** so row populations match the report exactly:
  - GR / PO / Transfer / Delivery: header `"DocDate" >= '2024-10-01'`, line `"ItemCode"` present (Transfer has no ItemCode filter in the model — keep it unfiltered there but drop blank ItemCodes from the classification).
  - Sales (stock-cover): `OINV`/`ORIN` with `"CANCELED" = 'N'` and `"DocType" = 'I'`, `"DocDate" >= '2024-10-01'`, `ItemCode` present. (`RIN1` is the credit/return side — sign is negative in the model but irrelevant for the unit test.)
  - Open PO / SO: `OPOR`/`ORDR` with `"DocStatus" = 'O'` and line `"LineStatus" = 'O'`, `ItemCode` present (the model applies **no** date filter to open docs — match that).
- **The unit test for every line table** is the same one proven on `IPF1`:
  - `NumPerMsr` (kg per document unit) = **1000** ⇒ line entered in **TON**; = **1** ⇒ entered in **KG** (other values ⇒ flag for manual review).
  - Confirm `Quantity * NumPerMsr = InvQty` (within rounding) on every line.
  - Resolve the line UoM name via `OUOM` (`UomEntry` → `UomCode`/`UomName`) where a UoM-entry column exists.
- HANA notes: `TO_VARCHAR`, `ROUND`, `MEDIAN`, `CASE` are available. If a column (e.g. `InvQty`, `OpenInvQty`, `NumPerMsr`, `UomEntry`) does **not** exist in this B1 version for a given table, **note the substitution** and fall back to the closest equivalent (`UseBaseUn`, `unitMsr` text, item-master inventory UoM, or `Quantity` vs a recomputed inventory qty).

---

## 2) Output location (Desktop, timestamped)

Create one folder; write all CSVs + one README into it:

- **Windows:** `%USERPROFILE%\Desktop\Paper_PBIP_DocQtyUoM_Sweep_<YYYYMMDD_HHMMSS>\`
- **macOS/Linux:** `~/Desktop/Paper_PBIP_DocQtyUoM_Sweep_<YYYYMMDD_HHMMSS>/`

Fallbacks only if Desktop is not writable: Windows `Public\Desktop`, else home root with `Desktop_UNAVAILABLE_` prefixed to the folder name (explain in README). **Never** store credentials.

README filename: `README_Paper_DocQtyUoM_Sweep_<YYYYMMDD>.md`.

---

## 3) Queries to run (save each result as the named CSV)

For each table run **two** exports: a **per-line sample** (for spot-checking) and a **per-table/per-item classification** (full period). Templates below — repeat the pattern for each table, swapping header/line table names and the column list.

### Generic per-line template (adapt table + UoM-entry column name)

```sql
-- Example: Goods Receipt (OPDN/PDN1). Repeat for POR1, WTR1, DLN1, INV1, RIN1.
SELECT
    T0."DocEntry", T0."DocNum", T0."DocDate",
    T1."ItemCode", T1."Dscription" AS "ItemDescription",
    T1."Quantity"                              AS "DocQuantity",
    T1."NumPerMsr",
    T1."InvQty"                                AS "InvQty_kg",
    CASE WHEN T1."NumPerMsr" = 1000 THEN 'TON_stored'
         WHEN T1."NumPerMsr" = 1    THEN 'KG_stored'
         ELSE 'REVIEW' END                     AS "PerLineUnit",
    ROUND(T1."Quantity" * T1."NumPerMsr", 3)   AS "QtyTimesNumPerMsr_check",  -- should equal InvQty_kg
    ROUND(T1."InvQty" / 1000.0, 3)             AS "CorrectTons",
    T1."LineTotal",
    U."UomCode", U."UomName"
FROM "PAPERENTITY"."OPDN" T0
INNER JOIN "PAPERENTITY"."PDN1" T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN  "PAPERENTITY"."OUOM" U  ON T1."UomEntry" = U."UomEntry"
WHERE T0."DocDate" >= '2024-10-01'
  AND T1."ItemCode" IS NOT NULL AND T1."ItemCode" <> ''
ORDER BY T0."DocNum", T1."LineNum";
```

Save as:
- `01_gr_pdn1_lines.csv` (OPDN/PDN1)
- `03_po_por1_lines.csv` (OPOR/POR1)
- `05_transfer_wtr1_lines.csv` (OWTR/WTR1 — note `WTR1` may use `FromWhsCod`/`WhsCode`; no header `DocDate` filter mismatch — keep the model's `DocDate >= '2024-10-01'`)
- `07_delivery_dln1_lines.csv` (ODLN/DLN1)
- `09_sales_inv1_lines.csv` (OINV/INV1, `CANCELED='N' AND DocType='I'`)
- `10_sales_rin1_lines.csv` (ORIN/RIN1, `CANCELED='N' AND DocType='I'`)

### Generic per-table/per-item classification template

```sql
-- Example for PDN1. Repeat per table.
SELECT
    T1."ItemCode",
    MAX(T1."Dscription")                                            AS "ItemDescription",
    COUNT(*)                                                        AS "LineCount",
    SUM(CASE WHEN T1."NumPerMsr" = 1000 THEN 1 ELSE 0 END)          AS "TonStoredLines",
    SUM(CASE WHEN T1."NumPerMsr" = 1    THEN 1 ELSE 0 END)          AS "KgStoredLines",
    SUM(CASE WHEN T1."NumPerMsr" NOT IN (1,1000) THEN 1 ELSE 0 END) AS "ReviewLines",
    ROUND(SUM(T1."InvQty") / 1000.0, 3)                            AS "CorrectTons_Total",
    ROUND(SUM(T1."Quantity") / 1000.0, 3)                          AS "CurrentModelTons_RawDiv1000",
    CASE
        WHEN SUM(CASE WHEN T1."NumPerMsr" = 1000 THEN 1 ELSE 0 END) > 0
         AND SUM(CASE WHEN T1."NumPerMsr" = 1    THEN 1 ELSE 0 END) > 0 THEN 'MIXED'
        WHEN SUM(CASE WHEN T1."NumPerMsr" = 1000 THEN 1 ELSE 0 END) > 0 THEN 'ALL_TONS'
        WHEN SUM(CASE WHEN T1."NumPerMsr" = 1    THEN 1 ELSE 0 END) > 0 THEN 'ALL_KG'
        ELSE 'REVIEW' END                                          AS "UnitVerdict"
FROM "PAPERENTITY"."OPDN" T0
INNER JOIN "PAPERENTITY"."PDN1" T1 ON T0."DocEntry" = T1."DocEntry"
WHERE T0."DocDate" >= '2024-10-01'
  AND T1."ItemCode" IS NOT NULL AND T1."ItemCode" <> ''
GROUP BY T1."ItemCode"
ORDER BY "UnitVerdict", T1."ItemCode";
```

Save as:
- `02_gr_item_classification.csv`
- `04_po_item_classification.csv`
- `06_transfer_item_classification.csv`
- `08_delivery_item_classification.csv`
- `11_sales_item_classification.csv` (UNION INV1 + RIN1 on `ItemCode`, or two blocks — your choice, label clearly)

### Open SO / Open PO (the stock-cover planning inputs) — `12_open_po_so_lines.csv` + `13_open_po_so_classification.csv`

These use `OpenQty`, not `Quantity`, and need an **open inventory qty** column. Verify the exact name in this B1 version (`OpenInvQty` is typical; if absent, compute `OpenQty * NumPerMsr`).

```sql
-- Open PO lines
SELECT 'OpenPO' AS "Source", B."ItemCode",
       B."OpenQty", B."NumPerMsr",
       B."OpenInvQty"                              AS "OpenInvQty_kg",      -- verify column exists
       ROUND(B."OpenQty" * B."NumPerMsr", 3)       AS "OpenQtyTimesNumPerMsr_check",
       CASE WHEN B."NumPerMsr" = 1000 THEN 'TON_stored'
            WHEN B."NumPerMsr" = 1    THEN 'KG_stored' ELSE 'REVIEW' END AS "PerLineUnit"
FROM "PAPERENTITY"."OPOR" A JOIN "PAPERENTITY"."POR1" B ON A."DocEntry" = B."DocEntry"
WHERE A."DocStatus" = 'O' AND B."LineStatus" = 'O' AND IFNULL(B."ItemCode",'') <> ''
UNION ALL
-- Open SO lines
SELECT 'OpenSO' AS "Source", B."ItemCode",
       B."OpenQty", B."NumPerMsr",
       B."OpenInvQty"                              AS "OpenInvQty_kg",
       ROUND(B."OpenQty" * B."NumPerMsr", 3)       AS "OpenQtyTimesNumPerMsr_check",
       CASE WHEN B."NumPerMsr" = 1000 THEN 'TON_stored'
            WHEN B."NumPerMsr" = 1    THEN 'KG_stored' ELSE 'REVIEW' END AS "PerLineUnit"
FROM "PAPERENTITY"."ORDR" A JOIN "PAPERENTITY"."RDR1" B ON A."DocEntry" = B."DocEntry"
WHERE A."DocStatus" = 'O' AND B."LineStatus" = 'O' AND IFNULL(B."ItemCode",'') <> '';
```

For `13_open_po_so_classification.csv`, aggregate the above per `Source` + `ItemCode` with `TonStoredLines` / `KgStoredLines` / `CorrectTons (OpenInvQty/1000)` / `CurrentModelTons (OpenQty/1000)` / `UnitVerdict`.

### Stock-cover row reconciliation — `14_stockcover_unit_consistency.csv`

This is the payoff query. For each item, put the **planning inputs side by side in their current vs corrected units**, so we can see the kg-vs-ton clash inside a single stock-cover row:

```sql
SELECT
    I."ItemCode",
    I."ItemName",
    -- on hand: always kg
    ROUND(COALESCE(ST."OnHand_kg",0) / 1000.0, 3)            AS "OnHand_Tons",
    -- sales 90d: current model treats /1000; corrected uses InvQty
    ROUND(COALESCE(SA."SalesQty90_raw",0) / 1000.0, 3)       AS "Sales90_CurrentModelTons",
    ROUND(COALESCE(SA."SalesInvQty90_kg",0) / 1000.0, 3)     AS "Sales90_CorrectTons",
    -- open PO / SO
    ROUND(COALESCE(PO."OpenPO_raw",0) / 1000.0, 3)           AS "OpenPO_CurrentModelTons",
    ROUND(COALESCE(PO."OpenPOInv_kg",0) / 1000.0, 3)         AS "OpenPO_CorrectTons",
    ROUND(COALESCE(SO."OpenSO_raw",0) / 1000.0, 3)           AS "OpenSO_CurrentModelTons",
    ROUND(COALESCE(SO."OpenSOInv_kg",0) / 1000.0, 3)         AS "OpenSO_CorrectTons"
FROM "PAPERENTITY"."OITM" I
LEFT JOIN ( SELECT W."ItemCode", SUM(W."OnHand") AS "OnHand_kg"
            FROM "PAPERENTITY"."OITW" W GROUP BY W."ItemCode" ) ST ON ST."ItemCode" = I."ItemCode"
LEFT JOIN ( SELECT B."ItemCode",
                   SUM(CASE WHEN A."DocDate" >= ADD_DAYS(CURRENT_DATE,-90) THEN B."Quantity" ELSE 0 END) AS "SalesQty90_raw",
                   SUM(CASE WHEN A."DocDate" >= ADD_DAYS(CURRENT_DATE,-90) THEN B."InvQty"   ELSE 0 END) AS "SalesInvQty90_kg"
            FROM "PAPERENTITY"."OINV" A JOIN "PAPERENTITY"."INV1" B ON A."DocEntry"=B."DocEntry"
            WHERE A."CANCELED"='N' AND A."DocType"='I' AND IFNULL(B."ItemCode",'')<>''
            GROUP BY B."ItemCode" ) SA ON SA."ItemCode" = I."ItemCode"
LEFT JOIN ( SELECT B."ItemCode", SUM(B."OpenQty") AS "OpenPO_raw", SUM(B."OpenInvQty") AS "OpenPOInv_kg"
            FROM "PAPERENTITY"."OPOR" A JOIN "PAPERENTITY"."POR1" B ON A."DocEntry"=B."DocEntry"
            WHERE A."DocStatus"='O' AND B."LineStatus"='O' AND IFNULL(B."ItemCode",'')<>''
            GROUP BY B."ItemCode" ) PO ON PO."ItemCode" = I."ItemCode"
LEFT JOIN ( SELECT B."ItemCode", SUM(B."OpenQty") AS "OpenSO_raw", SUM(B."OpenInvQty") AS "OpenSOInv_kg"
            FROM "PAPERENTITY"."ORDR" A JOIN "PAPERENTITY"."RDR1" B ON A."DocEntry"=B."DocEntry"
            WHERE A."DocStatus"='O' AND B."LineStatus"='O' AND IFNULL(B."ItemCode",'')<>''
            GROUP BY B."ItemCode" ) SO ON SO."ItemCode" = I."ItemCode"
WHERE I."InvntItem" = 'Y'
ORDER BY I."ItemCode";
```

> Flag any item where `*_CurrentModelTons` and `*_CorrectTons` differ by ~1000× — those are the rows where the reorder engine is silently mixing kg and tons.

---

## 4) README content (write `README_Paper_DocQtyUoM_Sweep_<YYYYMMDD>.md`)

State, per table, in plain language:

1. **Per-table verdict** — does it contain ton-booked (`NumPerMsr = 1000`) lines? Give `TonStoredLines / KgStoredLines / ReviewLines` and the `MIXED / ALL_TONS / ALL_KG` item counts for: **GR, PO, Transfer, Delivery, Sales (INV1+RIN1), Open PO, Open SO**.
2. **Identity check** — does `Quantity × NumPerMsr = InvQty` (and `OpenQty × NumPerMsr = OpenInvQty`) hold on every line? Note any exceptions.
3. **Inventory-UoM column confirmation** — confirm the exact column name to switch each fact to (`InvQty`, `OpenInvQty`, or a substitute), per table. This is what the Power BI fix will use.
4. **Stock-cover clash** — from `14_*`, list items where on-hand (kg) is combined with ton-booked sales/open qty, i.e. where `NetAvailable`, `TargetStockQty`, and the `>= 1000` planning gates are corrupted. Call out any item whose **suggested action would likely change** once units are reconciled.
5. **Tonnage impact per table** — current-model tons vs corrected tons, and the % the model is dropping (same style as the landed-cost README: it was dropping ~38% / 5,807 t on landed cost).
6. **Column substitutions / review rows** — any missing columns, non-(1/1000) `NumPerMsr` values, or rows needing manual eyeballing.

Do **not** include connection strings, usernames, or passwords anywhere.

---

## 5) Deliverable checklist

- [ ] `01_gr_pdn1_lines.csv` / `02_gr_item_classification.csv`
- [ ] `03_po_por1_lines.csv` / `04_po_item_classification.csv`
- [ ] `05_transfer_wtr1_lines.csv` / `06_transfer_item_classification.csv`
- [ ] `07_delivery_dln1_lines.csv` / `08_delivery_item_classification.csv`
- [ ] `09_sales_inv1_lines.csv` / `10_sales_rin1_lines.csv` / `11_sales_item_classification.csv`
- [ ] `12_open_po_so_lines.csv` / `13_open_po_so_classification.csv`
- [ ] `14_stockcover_unit_consistency.csv`
- [ ] `README_Paper_DocQtyUoM_Sweep_<YYYYMMDD>.md` with the 6-point interpretation above

When finished, **paste the full Desktop folder path** (the `Paper_PBIP_DocQtyUoM_Sweep_<timestamp>` directory) back into chat so the Power BI model can be corrected across all affected facts in one pass.
