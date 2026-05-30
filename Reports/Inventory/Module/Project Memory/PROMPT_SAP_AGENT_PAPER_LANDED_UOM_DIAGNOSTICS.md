# Prompt (SAP-reachable agent): Paper landed-cost **quantity UoM** diagnostics

Use this on the **SAP HANA / Business One** machine that can query schema **`PAPERENTITY`** through the same ODBC DSN the Power BI model uses (`HANA_B1`). This is a **read-only investigation** — do **not** change any SAP data, UoM setup, or documents. Produce CSVs + a README and hand the folder path back.

---

## 0) Why you are running this

The **Paper Inventory Report** "Shipments" table (Landed Cost page) reads supplier cost and import/handling cost **correctly** (IQD amounts match SAP to the dinar), but the **per-ton** figures and **Qty Received (Tons)** are wrong for *some* landed-cost (LC) documents and right for others:

- "Good" LC docs show Qty in the hundreds/thousands of tons and **Supplier Cost / Ton ≈ 1.0–1.2 million IQD/ton**.
- "Broken" LC docs show **Qty = 0 or 1** and **Supplier Cost / Ton in the 0.86–1.24 *billion* IQD/ton range** — i.e. exactly **1000× too high**.

**Working hypothesis:** the Power BI model pulls `IPF1."Quantity"` as-is and then divides by **1000** everywhere (it assumes every receipt quantity is stored in **kg**). The hypothesis is that the source quantity is in **mixed units** — some items/receipts are stored in **kg** (so ÷1000 → correct tons), and some (e.g. the newer *Folding Board Paper* items `PAP-018`, `PAP-020`, `PAP-021`) are stored in **metric tons** already (so ÷1000 collapses them to ~0 and inflates the unit price 1000×).

**Your job:** prove or disprove this with hard data. Specifically, for every item that appears in a landed-cost document, determine **what unit `IPF1."Quantity"` is actually in** and **what conversion factor to a metric ton** is correct. Do **not** propose Power BI changes — just deliver the evidence and a clear verdict.

---

## 1) Environment & conventions

- **DSN / connection:** ODBC `HANA_B1` (same credentials as the Power BI gateway). Do not embed credentials in any output file.
- **Schema:** `PAPERENTITY` (quote identifiers: `"PAPERENTITY"."OIPF"`, etc.).
- **Mirror the Power BI WHERE clause** so the row population matches the report exactly:
  - `H."DocDate" >= '2024-10-01'`
  - `R."ItemCode" IS NOT NULL AND R."ItemCode" <> ''`
  - `COALESCE(H."Canceled", 'N') <> 'Y'`
- **Tables in play:**
  - `OIPF` = landed-cost header, `IPF1` = landed-cost **receipt lines** (this holds the `Quantity` in question), `IPF2` = landed-cost **cost lines**, `OALC` = landed-cost code master.
  - `OPDN` = GRPO (goods receipt PO) header, `PDN1` = GRPO rows — the receipt lines `IPF1` is based on. `PDN1` usually holds **both** `Quantity` (document UoM) and `InvQty` (inventory UoM), which is the key cross-check.
  - `OITM` = item master (UoM setup), `OUGP` = UoM group, `UGP1` = UoM group conversions, `OUOM` = UoM master (codes/names).
- HANA notes: use `TO_VARCHAR(...)`, `ROUND(x, n)`, and `CASE` as needed. If a column name below does not exist in this B1 version, find the closest equivalent and **note the substitution in the README**.

---

## 2) Output location (Desktop, timestamped)

Create one folder and write **all** CSVs + one README into it:

- **Windows:** `%USERPROFILE%\Desktop\Paper_PBIP_LandedUoM_Diag_<YYYYMMDD_HHMMSS>\`
- **macOS/Linux:** `~/Desktop/Paper_PBIP_LandedUoM_Diag_<YYYYMMDD_HHMMSS>/`

Fallbacks only if Desktop is not writable: Windows `Public\Desktop`, otherwise the user home root — and in that case prefix the folder name with `Desktop_UNAVAILABLE_` and explain in the README. **Never** put credentials in any file.

README filename: `README_Paper_LandedUoM_Diag_<YYYYMMDD>.md`.

---

## 3) Queries to run (save each result as the named CSV)

> Run them in order. If a query is large, you may add `LIMIT`/`TOP` for the *sample* exports (clearly labelled), but the **aggregate/classification** exports must cover the full filtered period.

### Q1 — `01_item_uom_master.csv` (item UoM setup)

For every distinct `ItemCode` that appears in `IPF1` within the filtered period, pull the item-master UoM configuration:

```sql
SELECT DISTINCT
    I."ItemCode",
    I."ItemName",
    I."ItemType",
    I."InvntryUom"      AS "InventoryUomText",
    I."BuyUnitMsr"      AS "PurchaseUomText",
    I."SalUnitMsr"      AS "SalesUomText",
    I."NumInBuy"        AS "ItemsPerPurchaseUnit",
    I."PurFactor1", I."PurFactor2", I."PurFactor3", I."PurFactor4",
    I."BWght1Unit", I."BWeight1"  AS "PurchaseWeightPerUnit",
    I."IWght1Unit", I."IWeight1"  AS "InventoryWeightPerUnit",
    I."UgpEntry"       AS "UomGroupEntry",
    G."UgpCode"        AS "UomGroupCode",
    G."UgpName"        AS "UomGroupName",
    I."IUoMEntry"      AS "InventoryUomEntry",
    I."PUoMEntry"      AS "PurchaseUomEntry"
FROM "PAPERENTITY"."OITM" I
LEFT JOIN "PAPERENTITY"."OUGP" G ON I."UgpEntry" = G."UgpEntry"
WHERE I."ItemCode" IN (
    SELECT DISTINCT R."ItemCode"
    FROM "PAPERENTITY"."OIPF" H
    INNER JOIN "PAPERENTITY"."IPF1" R ON H."DocEntry" = R."DocEntry"
    WHERE H."DocDate" >= '2024-10-01'
      AND R."ItemCode" IS NOT NULL AND R."ItemCode" <> ''
      AND COALESCE(H."Canceled", 'N') <> 'Y'
)
ORDER BY I."ItemCode";
```

> If `IUoMEntry` / `PUoMEntry` / `BWght1Unit` etc. don't exist in this version, drop them and note it. The critical columns are the **inventory/purchase UoM text** and any **UoM group**.

### Q2 — `02_uom_conversions.csv` (UoM group conversion factors)

For the UoM groups used by those items, export the conversion table and the UoM names, so we can see how each group converts to a base unit (and ideally to kg/ton):

```sql
SELECT
    C."UgpEntry",
    G."UgpCode",
    G."UgpName",
    C."UomEntry",
    U."UomCode",
    U."UomName",
    C."BaseQty",
    C."AltQty"
FROM "PAPERENTITY"."UGP1" C
LEFT JOIN "PAPERENTITY"."OUGP" G ON C."UgpEntry" = G."UgpEntry"
LEFT JOIN "PAPERENTITY"."OUOM" U ON C."UomEntry" = U."UomEntry"
WHERE C."UgpEntry" IN (
    SELECT DISTINCT I."UgpEntry"
    FROM "PAPERENTITY"."OITM" I
    WHERE I."ItemCode" IN (
        SELECT DISTINCT R."ItemCode"
        FROM "PAPERENTITY"."OIPF" H
        INNER JOIN "PAPERENTITY"."IPF1" R ON H."DocEntry" = R."DocEntry"
        WHERE H."DocDate" >= '2024-10-01'
          AND R."ItemCode" IS NOT NULL AND R."ItemCode" <> ''
          AND COALESCE(H."Canceled", 'N') <> 'Y'
    )
)
ORDER BY C."UgpEntry", C."UomEntry";
```

### Q3 — `03_ipf1_qty_vs_value_by_line.csv` (the core evidence — per LC receipt line)

This is the most important export. For every `IPF1` line in the filtered period, output the **raw quantity**, the **supplier base amount** (computed with the *same COALESCE chain* the Power BI query uses), and the **implied unit price under each unit assumption**:

```sql
SELECT
    H."DocNum"                                   AS "LcDocNum",
    H."DocEntry"                                 AS "LcDocEntry",
    H."DocDate"                                  AS "LcDate",
    R."LineNum"                                  AS "LcLineNum",
    R."BaseType"                                 AS "SourceBaseType",
    COALESCE(NULLIF(R."OriBAbsEnt", 0), R."BaseEntry")                       AS "ReceiptDocEntry",
    COALESCE(NULLIF(R."OriBLinNum",0), NULLIF(R."OrigLine",0),
             NULLIF(R."BaseRowNum",0), R."LineNum")                          AS "ReceiptLineNum",
    R."ItemCode",
    R."Dscription"                               AS "ItemDescription",
    R."Quantity"                                 AS "Ipf1_Quantity",          -- the value PBI divides by 1000
    R."FobValue", R."FobnLaC", R."LineTotal", R."PriceFOB",
    COALESCE(NULLIF(R."FobValue",0), NULLIF(R."FobnLaC",0),
             NULLIF(R."LineTotal",0), NULLIF(R."PriceFOB" * R."Quantity",0), 0) AS "SupplierBaseAmount",
    -- implied IQD per unit if Quantity is treated as-is (the "raw" unit):
    CASE WHEN R."Quantity" <> 0
         THEN ROUND(COALESCE(NULLIF(R."FobValue",0), NULLIF(R."FobnLaC",0),
                    NULLIF(R."LineTotal",0), NULLIF(R."PriceFOB"*R."Quantity",0),0) / R."Quantity", 2)
    END                                          AS "ImpliedPricePerRawUnit",
    -- implied IQD per ton if PBI divides Quantity by 1000 (current model behaviour):
    CASE WHEN R."Quantity" <> 0
         THEN ROUND(COALESCE(NULLIF(R."FobValue",0), NULLIF(R."FobnLaC",0),
                    NULLIF(R."LineTotal",0), NULLIF(R."PriceFOB"*R."Quantity",0),0) / (R."Quantity"/1000), 2)
    END                                          AS "ImpliedPricePerTon_IfDiv1000"
FROM "PAPERENTITY"."OIPF" H
INNER JOIN "PAPERENTITY"."IPF1" R ON H."DocEntry" = R."DocEntry"
WHERE H."DocDate" >= '2024-10-01'
  AND R."ItemCode" IS NOT NULL AND R."ItemCode" <> ''
  AND COALESCE(H."Canceled", 'N') <> 'Y'
ORDER BY H."DocNum", R."LineNum";
```

> The tell-tale: for **kg-stored** lines, `ImpliedPricePerRawUnit` is small (hundreds/low thousands of IQD per kg) and `ImpliedPricePerTon_IfDiv1000` is ~1.0–1.2M (correct). For **ton-stored** lines, `ImpliedPricePerRawUnit` is ~0.85–1.2M (the real per-ton price) and `ImpliedPricePerTon_IfDiv1000` is ~0.85–1.2 **billion** (1000× wrong).

### Q4 — `04_grpo_qty_crosscheck.csv` (GRPO `Quantity` vs `InvQty` for the same lines)

Join `IPF1` back to its source GRPO row and compare the document quantity to the inventory quantity. If `PDN1` holds both, this tells us directly whether the receipt was booked in tons or kg and what the inventory-UoM value is:

```sql
SELECT
    H."DocNum"            AS "LcDocNum",
    R."ItemCode",
    R."Dscription"        AS "ItemDescription",
    R."Quantity"          AS "Ipf1_Quantity",
    P."DocEntry"          AS "Grpo_DocEntry",
    P."LineNum"           AS "Grpo_LineNum",
    P."Quantity"          AS "Pdn1_Quantity",       -- GRPO qty in document UoM
    P."InvQty"            AS "Pdn1_InvQty",          -- GRPO qty in inventory UoM
    P."UseBaseUn",
    P."NumPerMsr"         AS "Pdn1_ItemsPerUnit",
    P."unitMsr"           AS "Pdn1_UomText",
    P."UomCode"           AS "Pdn1_UomCode",
    U."UomName"           AS "Pdn1_UomName"
FROM "PAPERENTITY"."OIPF" H
INNER JOIN "PAPERENTITY"."IPF1" R ON H."DocEntry" = R."DocEntry"
LEFT JOIN "PAPERENTITY"."PDN1" P
    ON P."DocEntry" = COALESCE(NULLIF(R."OriBAbsEnt", 0), R."BaseEntry")
   AND P."LineNum"  = COALESCE(NULLIF(R."OriBLinNum",0), NULLIF(R."OrigLine",0),
                                NULLIF(R."BaseRowNum",0), R."LineNum")
LEFT JOIN "PAPERENTITY"."OUOM" U ON P."UomEntry" = U."UomEntry"
WHERE H."DocDate" >= '2024-10-01'
  AND R."ItemCode" IS NOT NULL AND R."ItemCode" <> ''
  AND COALESCE(H."Canceled", 'N') <> 'Y'
ORDER BY H."DocNum", R."LineNum";
```

> If `UomEntry` / `UomCode` / `InvQty` don't exist on `PDN1` in this version, export whatever quantity/UoM columns do exist and note the substitution. The goal is to see, per line, the **document UoM name** and whether `Quantity` ≠ `InvQty`.

### Q5 — `05_item_unit_classification.csv` (verdict per item)

Aggregate Q3 to one row per item and classify it. Use the magnitude of the median implied per-raw-unit price as the discriminator (paper realistically costs on the order of **hundreds of thousands to ~1.2M IQD per metric ton**, i.e. a few hundred IQD per kg):

```sql
SELECT
    R."ItemCode",
    MAX(R."Dscription")                                  AS "ItemDescription",
    COUNT(*)                                             AS "LineCount",
    ROUND(MIN(R."Quantity"), 3)                          AS "MinRawQty",
    ROUND(MAX(R."Quantity"), 3)                          AS "MaxRawQty",
    ROUND(SUM(R."Quantity"), 3)                          AS "SumRawQty",
    ROUND(MEDIAN(
        CASE WHEN R."Quantity" <> 0
             THEN COALESCE(NULLIF(R."FobValue",0), NULLIF(R."FobnLaC",0),
                  NULLIF(R."LineTotal",0), NULLIF(R."PriceFOB"*R."Quantity",0),0) / R."Quantity"
        END), 2)                                         AS "MedianPricePerRawUnit",
    CASE
        WHEN MEDIAN(
            CASE WHEN R."Quantity" <> 0
                 THEN COALESCE(NULLIF(R."FobValue",0), NULLIF(R."FobnLaC",0),
                      NULLIF(R."LineTotal",0), NULLIF(R."PriceFOB"*R."Quantity",0),0) / R."Quantity"
            END) >= 100000 THEN 'LIKELY_TONS (do NOT /1000)'
        WHEN MEDIAN(
            CASE WHEN R."Quantity" <> 0
                 THEN COALESCE(NULLIF(R."FobValue",0), NULLIF(R."FobnLaC",0),
                      NULLIF(R."LineTotal",0), NULLIF(R."PriceFOB"*R."Quantity",0),0) / R."Quantity"
            END) BETWEEN 50 AND 5000 THEN 'LIKELY_KG (/1000 = tons)'
        ELSE 'REVIEW_MANUALLY'
    END                                                  AS "UnitVerdict"
FROM "PAPERENTITY"."OIPF" H
INNER JOIN "PAPERENTITY"."IPF1" R ON H."DocEntry" = R."DocEntry"
WHERE H."DocDate" >= '2024-10-01'
  AND R."ItemCode" IS NOT NULL AND R."ItemCode" <> ''
  AND COALESCE(H."Canceled", 'N') <> 'Y'
GROUP BY R."ItemCode"
ORDER BY "UnitVerdict", R."ItemCode";
```

> If HANA rejects `MEDIAN`, use `AVG` and note it. The thresholds are heuristics — anything landing in `REVIEW_MANUALLY` should be eyeballed against Q1/Q4.

### Q6 — `06_total_tonnage_reconciliation.csv` (impact summary)

One-row-per-`UnitVerdict` summary so we can quantify how much tonnage the current ÷1000 model is losing. Join Q5's verdict back to the lines and sum:

- `SUM(Quantity)` raw, `SUM(Quantity)/1000` (current model tons), and the **corrected** tons (raw for ton-items, raw/1000 for kg-items).
- Also give the total `SupplierBaseAmount` per bucket.

You can implement this as a CTE wrapping Q5's classification, or compute it in the export script from `03_*.csv` + `05_*.csv`. Either is fine — just make the three tonnage totals explicit.

### Q7 — `07_lc28_spot_check.csv` (named spot-check)

Export the raw `IPF1` lines for the LC doc shown in the screenshots (`PAP-020`, `PAP-018`, `PAP-021` "Folding Board Paper") — filter `R."ItemCode" IN ('PAP-018','PAP-020','PAP-021')` (and/or the LC `DocNum` for that shipment) and include `Quantity`, `FobValue`, `LineTotal`, `TtlExpndSC`, `TtlExpndLC` so we can hand-verify: SAP showed qty `49.98 / 99.981 / 99.617` and base values `42,882,840 / 85,783,698 / 85,471,386`.

---

## 4) README content (write `README_Paper_LandedUoM_Diag_<YYYYMMDD>.md`)

Include, in plain language:

1. **Verdict on the hypothesis** — is `IPF1."Quantity"` stored in **mixed units** (some kg, some tons)? Yes/No, with the count of items in each bucket from Q5.
2. **The exact discriminator** — is the split driven by the item's **inventory UoM** (Q1), the **UoM group** (Q2), or the **GRPO document UoM** (Q4)? State which column reliably separates ton-items from kg-items, and give the kg→ton conversion factor for each (ideally from `IWeight1`/UoM conversions rather than a guessed 1000).
3. **List the affected items** (e.g. `PAP-018/020/021` + any others flagged `LIKELY_TONS`) and the items that are correctly kg.
4. **Tonnage impact** from Q6 — how many real tons the current model is dropping, and the corrected grand total.
5. **Any column substitutions** you had to make vs the SQL above, and any rows that landed in `REVIEW_MANUALLY`.
6. **Recommended normalization key** — the single source column (or join) the Power BI Power Query should use to convert every `ReceiptQty` to metric tons *consistently*, so the model can stop hard-dividing by 1000. (Just the recommendation + evidence — do not change SAP.)

Do **not** include connection strings, usernames, or passwords anywhere.

---

## 5) Deliverable checklist

- [ ] `01_item_uom_master.csv`
- [ ] `02_uom_conversions.csv`
- [ ] `03_ipf1_qty_vs_value_by_line.csv`
- [ ] `04_grpo_qty_crosscheck.csv`
- [ ] `05_item_unit_classification.csv`
- [ ] `06_total_tonnage_reconciliation.csv`
- [ ] `07_lc28_spot_check.csv`
- [ ] `README_Paper_LandedUoM_Diag_<YYYYMMDD>.md` with the 6-point interpretation above

When finished, **paste the full Desktop folder path** (the `Paper_PBIP_LandedUoM_Diag_<timestamp>` directory) back into chat so the Power BI model can be aligned to the findings.
