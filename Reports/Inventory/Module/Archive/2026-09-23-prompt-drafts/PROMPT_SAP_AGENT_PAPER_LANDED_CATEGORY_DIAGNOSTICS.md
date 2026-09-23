# Prompt (SAP-reachable agent): Paper landed-cost **category mapping** diagnostics

Use this on the **SAP HANA / Business One** machine that can query schema **`PAPERENTITY`** through the same ODBC DSN the Power BI model uses (`HANA_B1`). This is a **read-only investigation** — do **not** change any SAP data, landed-cost setup, or documents. Produce CSVs + a README on **Desktop** and paste the folder path back.

---

## 0) Why you are running this

The **Paper Inventory Report** (Fabric copy: `Paper Inventory Report`, Landed Cost page) groups import add-ons into reporting buckets via keyword rules on SAP landed-cost codes (`OALC` / `IPF2`).

**SAP setup (Administration → Setup → Purchasing → Landed Costs)** shows **4 active codes** for PAPERENTITY:

| Code | Name (as in SAP) | Allocation By | G/L Account |
|------|------------------|---------------|-------------|
| 1 | Customes Fees | Cash Value Before Customs | 1600001 |
| 2 | Shipping Cost | Cash Value Before Customs | 1600002 |
| 3 | Unloade Fees | Cash Value Before Customs | 1600006 |
| 4 | Insurance | Cash Value Before Customs | 1600003 |

**Power BI report (Landed Cost page, closed LC docs only)** currently shows only **three** add-on categories in the charts:

- **Tax / duty** (dominant — matches Customs Fees)
- **Insurance** (small)
- **Other** (second-largest — unexpected)

**Missing from the report:** **Transport** and **Unloading**, which the model *should* produce from codes 2 (Shipping Cost) and 3 (Unloade Fees) via keyword matching.

**Working hypotheses (prove or disprove with data):**

1. Codes **2** and **3** carry **zero** add-on amounts on **closed** landed-cost documents in the report period.
2. Freight/unloading amounts are booked under **different `AlcCode` values** (extra OALC rows, typos, or document-level codes not in the setup screenshot).
3. The Power BI keyword classifier **mis-buckets** some codes into **Other** (name/code text does not match `%shipping%`, `%unload%`, etc.).
4. Amounts exist at document level but **allocation to receipt lines** (IPF1 grain) drops or mis-attributes them.

**Your job:** deliver hard evidence — per `AlcCode`, what SAP holds, what the PBIP keyword logic would classify it as, and where the **"Other"** bucket gets its IQD. Do **not** change Power BI or SAP — only diagnose.

---

## 1) Environment & conventions

- **DSN / connection:** ODBC `HANA_B1` (same as Power BI gateway). Do **not** embed credentials in any output file.
- **Schema:** `"PAPERENTITY"` (quote identifiers: `"PAPERENTITY"."OIPF"`, etc.).
- **Report population filters** (mirror Power BI exactly):
  - `H."DocDate" >= '2024-10-01'`
  - `R."ItemCode" IS NOT NULL AND R."ItemCode" <> ''`
  - `COALESCE(H."Canceled", 'N') <> 'Y'`
- **Report page filter (Landed Cost page):** closed documents only → `COALESCE(H."DocStatus", '') = 'C'` (Power BI column `IsLcClosed = 1`).
- **Tables:**
  - `OALC` — landed-cost code master (setup screenshot)
  - `OIPF` — LC header
  - `IPF1` — LC receipt/item lines (allocation weight grain)
  - `IPF2` — LC cost/add-on lines (`AlcCode`, amounts)
- **Amount column on IPF2:** use `COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0)` — same as the PBIP query.

### PBIP keyword → `ReportingCategory` logic (replicate in SQL)

The Power BI model (`Dim_LandedCostCategory` + `Fact_LandedCostAllocation` CostLines CTE) classifies each add-on line with this **priority order** (first match wins):

```sql
CASE
    WHEN LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%freight%'
      OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%shipping%'
      OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%transport%'
      OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%delivery%'
        THEN 'Transport'
    WHEN LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%unload%'
      OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%handling%'
      OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%terminal%'
        THEN 'Unloading'
    WHEN LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%custom%'
      OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%duty%'
      OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%tax%'
      OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%vat%'
      OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%excise%'
        THEN 'Tax / duty'
    WHEN LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%insurance%'
        THEN 'Insurance'
    ELSE 'Other'
END AS "ReportingCategory"
```

**Expected mapping for the 4 setup codes:**

| AlcCode | AlcName | Expected bucket |
|---------|---------|-----------------|
| 1 | Customes Fees | Tax / duty (`custom`) |
| 2 | Shipping Cost | Transport (`shipping`) |
| 3 | Unloade Fees | Unloading (`unload`) |
| 4 | Insurance | Insurance |

---

## 2) Output location (Desktop, timestamped)

Create one folder and write **all** CSVs + one README into it:

- **Windows:** `%USERPROFILE%\Desktop\Paper_PBIP_LandedCategory_Diag_<YYYYMMDD_HHMMSS>\`
- **macOS/Linux:** `~/Desktop/Paper_PBIP_LandedCategory_Diag_<YYYYMMDD_HHMMSS>/`

Fallbacks only if Desktop is not writable: Windows `Public\Desktop`, otherwise user home root — prefix folder with `Desktop_UNAVAILABLE_` and explain in README. **Never** put credentials in any file.

README filename: `README_Paper_LandedCategory_Diag_<YYYYMMDD>.md`.

---

## 3) Queries to run (save each result as the named CSV)

Run in order. Aggregates must cover the **full filtered period**; samples may be capped but must be labelled.

### Q1 — `01_oalc_master_all_codes.csv` (full landed-cost code master)

Export **every** row from `"PAPERENTITY"."OALC"` (not just the 4 setup codes). Include at minimum:

- `AlcCode`, `AlcName`, `CostCateg` (if present), allocation account fields if available
- Replicate the **ReportingCategory** CASE above as a computed column `PbipReportingCategory`
- Flag whether each code is one of setup codes **1–4**

```sql
SELECT
    T0."AlcCode",
    T0."AlcName",
    T0."CostCateg",
    CASE
        WHEN LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%freight%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%shipping%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%transport%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%delivery%' THEN 'Transport'
        WHEN LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%unload%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%handling%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%terminal%' THEN 'Unloading'
        WHEN LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%custom%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%duty%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%tax%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%vat%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%excise%' THEN 'Tax / duty'
        WHEN LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%insurance%' THEN 'Insurance'
        ELSE 'Other'
    END AS "PbipReportingCategory",
    CASE WHEN T0."AlcCode" IN ('1','2','3','4') THEN 'Y' ELSE 'N' END AS "IsSetupCode1to4"
FROM "PAPERENTITY"."OALC" T0
ORDER BY T0."AlcCode";
```

> Note any **extra** OALC codes beyond 1–4 — these may feed the **Other** bar in Power BI.

---

### Q2 — `02_ipf2_amounts_by_alccode_all_lc.csv` (document-level add-ons, all LC docs in period)

Sum IPF2 amounts by landed-cost code for LC headers in the report date window (**before** closed filter):

```sql
SELECT
    C."AlcCode",
    COALESCE(A."AlcName", C."AlcCode") AS "AlcName",
    A."CostCateg",
    COUNT(*) AS "Ipf2LineCount",
    COUNT(DISTINCT C."DocEntry") AS "LcDocCount",
    ROUND(SUM(COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0)), 2) AS "TotalCostAmount",
    ROUND(SUM(CASE WHEN COALESCE(H."DocStatus", '') = 'C'
                   THEN COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0) ELSE 0 END), 2) AS "TotalCostAmount_ClosedOnly",
    ROUND(SUM(CASE WHEN COALESCE(H."DocStatus", '') <> 'C'
                   THEN COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0) ELSE 0 END), 2) AS "TotalCostAmount_OpenOnly"
FROM "PAPERENTITY"."IPF2" C
INNER JOIN "PAPERENTITY"."OIPF" H ON C."DocEntry" = H."DocEntry"
LEFT JOIN "PAPERENTITY"."OALC" A ON C."AlcCode" = A."AlcCode"
WHERE H."DocDate" >= '2024-10-01'
  AND COALESCE(H."Canceled", 'N') <> 'Y'
  AND COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0) <> 0
GROUP BY C."AlcCode", COALESCE(A."AlcName", C."AlcCode"), A."CostCateg"
ORDER BY ABS("TotalCostAmount_ClosedOnly") DESC;
```

Join Q1's `PbipReportingCategory` in the README (or add it as a column via subquery/CTE).

---

### Q3 — `03_ipf2_amounts_by_reporting_category_closed.csv` (what Power BI *should* show)

Same population as Q2 but **closed only**, rolled up to `ReportingCategory`:

```sql
WITH CostLines AS (
    SELECT
        C."DocEntry",
        C."AlcCode",
        COALESCE(A."AlcName", C."AlcCode") AS "AlcName",
        COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0) AS "CostAmount",
        CASE
            WHEN LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%freight%'
              OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%shipping%'
              OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%transport%'
              OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%delivery%' THEN 'Transport'
            WHEN LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%unload%'
              OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%handling%'
              OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%terminal%' THEN 'Unloading'
            WHEN LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%custom%'
              OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%duty%'
              OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%tax%'
              OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%vat%'
              OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%excise%' THEN 'Tax / duty'
            WHEN LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%insurance%' THEN 'Insurance'
            ELSE 'Other'
        END AS "ReportingCategory"
    FROM "PAPERENTITY"."IPF2" C
    INNER JOIN "PAPERENTITY"."OIPF" H ON C."DocEntry" = H."DocEntry"
    LEFT JOIN "PAPERENTITY"."OALC" A ON C."AlcCode" = A."AlcCode"
    WHERE H."DocDate" >= '2024-10-01'
      AND COALESCE(H."Canceled", 'N') <> 'Y'
      AND COALESCE(H."DocStatus", '') = 'C'
      AND COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0) <> 0
)
SELECT
    "ReportingCategory",
    COUNT(DISTINCT "DocEntry") AS "LcDocCount",
    COUNT(*) AS "Ipf2LineCount",
    ROUND(SUM("CostAmount"), 2) AS "TotalDocumentLevelCost"
FROM CostLines
GROUP BY "ReportingCategory"
ORDER BY ABS("TotalDocumentLevelCost") DESC;
```

**Compare this total (~2.65bn IQD expected for Import & Handling)** to the report KPI **Import & Handling Costs: 2.65bn**.

---

### Q4 — `04_other_bucket_detail_closed.csv` (breakdown of "Other")

All IPF2 lines classified as **Other** on **closed** docs — this explains the unexpected second bar:

```sql
SELECT
    H."DocNum",
    H."DocEntry",
    H."DocDate",
    C."LineNum" AS "CostLineNum",
    C."AlcCode",
    COALESCE(A."AlcName", C."AlcCode") AS "AlcName",
    A."CostCateg",
    COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0) AS "CostAmount",
    C."OhType" AS "CostAllocationMethod"
FROM "PAPERENTITY"."IPF2" C
INNER JOIN "PAPERENTITY"."OIPF" H ON C."DocEntry" = H."DocEntry"
LEFT JOIN "PAPERENTITY"."OALC" A ON C."AlcCode" = A."AlcCode"
WHERE H."DocDate" >= '2024-10-01'
  AND COALESCE(H."Canceled", 'N') <> 'Y'
  AND COALESCE(H."DocStatus", '') = 'C'
  AND COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0) <> 0
  AND NOT (
        LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%freight%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%shipping%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%transport%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%delivery%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%unload%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%handling%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%terminal%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%custom%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%duty%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%tax%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%vat%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '') || ' ' || COALESCE(A."CostCateg", '')) LIKE '%excise%'
        OR LOWER(COALESCE(A."AlcName", '') || ' ' || COALESCE(C."AlcCode", '')) LIKE '%insurance%'
      )
ORDER BY ABS(COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0)) DESC;
```

Also produce **`04b_other_summary_by_alccode.csv`**: group Q4 by `AlcCode` / `AlcName` with sums.

---

### Q5 — `05_setup_codes_1_to_4_closed_amounts.csv` (direct answer: are Shipping & Unloading zero?)

Focus on setup codes only:

```sql
SELECT
    C."AlcCode",
    COALESCE(A."AlcName", C."AlcCode") AS "AlcName",
    COUNT(DISTINCT C."DocEntry") AS "LcDocCount",
    COUNT(*) AS "Ipf2LineCount",
    ROUND(SUM(COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0)), 2) AS "TotalCostAmount_Closed",
    MIN(H."DocDate") AS "MinLcDate",
    MAX(H."DocDate") AS "MaxLcDate"
FROM "PAPERENTITY"."IPF2" C
INNER JOIN "PAPERENTITY"."OIPF" H ON C."DocEntry" = H."DocEntry"
LEFT JOIN "PAPERENTITY"."OALC" A ON C."AlcCode" = A."AlcCode"
WHERE H."DocDate" >= '2024-10-01'
  AND COALESCE(H."Canceled", 'N') <> 'Y'
  AND COALESCE(H."DocStatus", '') = 'C'
  AND C."AlcCode" IN ('1','2','3','4')
GROUP BY C."AlcCode", COALESCE(A."AlcName", C."AlcCode")
ORDER BY C."AlcCode";
```

Include rows for codes 2 and 3 even if **zero** (LEFT JOIN from a VALUES list if needed).

---

### Q6 — `06_allocated_addon_by_category_closed.csv` (receipt-line grain — matches PBIP allocation)

Replicate PBIP allocation: distribute each document-level IPF2 cost across IPF1 lines by `AllocationWeight / DocAllocationWeight`. Export sums by `ReportingCategory` for **closed** docs with non-blank items.

Use the same `RowBase` + `CostLines` CTE structure as in `Fact_LandedCostAllocation.tmdl` (Fabric copy: `Fabric/DevelopmentWorkspace/Paper Inventory Report.SemanticModel/`). At minimum:

- `RowBase`: OIPF + IPF1, date/cancel/item filters, `AllocationWeight`, window sum `DocAllocationWeight`
- `CostLines`: IPF2 + OALC + ReportingCategory CASE
- Final SELECT: `SUM(CostAmount * AllocationWeight / DocAllocationWeight)` grouped by `ReportingCategory`

Also export **`06b_allocated_addon_by_alccode.csv`** (same logic, group by `AlcCode`).

**Sanity check:** sum of allocated add-ons ≈ **2,650,239,524 IQD** (report screenshot total Import & Handling).

---

### Q7 — `07_lc_doc_list_closed.csv` (shipments table grain)

One row per closed LC doc in period (matches Shipments table):

```sql
SELECT
    H."DocNum" AS "LcDocNum",
    H."DocEntry",
    H."DocDate",
    MIN(COALESCE(GRH."DocDate", H."DocDate")) AS "ReceiptDate",
    COUNT(DISTINCT R."ItemCode") AS "ItemCount",
    ROUND(SUM(COALESCE(NULLIF(R."FobValue",0), NULLIF(R."FobnLaC",0),
             NULLIF(R."LineTotal",0), NULLIF(R."PriceFOB"*R."Quantity",0),0)), 2) AS "SupplierBaseAmount",
    ROUND(SUM(COALESCE(NULLIF(R."InvQty",0), R."Quantity", 0)), 3) AS "ReceiptQtyRaw"
FROM "PAPERENTITY"."OIPF" H
INNER JOIN "PAPERENTITY"."IPF1" R ON H."DocEntry" = R."DocEntry"
LEFT JOIN "PAPERENTITY"."OPDN" GRH
    ON COALESCE(NULLIF(R."OriBAbsEnt", 0), R."BaseEntry") = GRH."DocEntry"
WHERE H."DocDate" >= '2024-10-01'
  AND R."ItemCode" IS NOT NULL AND R."ItemCode" <> ''
  AND COALESCE(H."Canceled", 'N') <> 'Y'
  AND COALESCE(H."DocStatus", '') = 'C'
GROUP BY H."DocNum", H."DocEntry", H."DocDate"
ORDER BY H."DocNum";
```

Optional: add per-doc add-on total from IPF2 for cross-check.

---

### Q8 — `08_keyword_match_proof.csv` (prove classifier hits for codes 1–4)

For each setup code, show the **exact lowercase concatenated string** the classifier tests and which branch fires:

```sql
SELECT
    T0."AlcCode",
    T0."AlcName",
    T0."CostCateg",
    LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) AS "MatchString_NameCode",
    LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) AS "MatchString_WithCostCateg",
    CASE
        WHEN LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%freight%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%shipping%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%transport%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%delivery%' THEN 'Transport'
        WHEN LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%unload%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%handling%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%terminal%' THEN 'Unloading'
        WHEN LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%custom%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%duty%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%tax%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%vat%'
          OR LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '') || ' ' || COALESCE(T0."CostCateg", '')) LIKE '%excise%' THEN 'Tax / duty'
        WHEN LOWER(COALESCE(T0."AlcName", '') || ' ' || COALESCE(T0."AlcCode", '')) LIKE '%insurance%' THEN 'Insurance'
        ELSE 'Other'
    END AS "PbipReportingCategory"
FROM "PAPERENTITY"."OALC" T0
WHERE T0."AlcCode" IN ('1','2','3','4')
ORDER BY T0."AlcCode";
```

Confirm explicitly:

- Code 1 **Customes Fees** → `Tax / duty`
- Code 2 **Shipping Cost** → `Transport`
- Code 3 **Unloade Fees** → `Unloading`
- Code 4 **Insurance** → `Insurance`

If Q8 says Transport/Unloading but Q3/Q5 show zero amounts, the issue is **data booking**, not keywords.

---

## 4) README content (`README_Paper_LandedCategory_Diag_<YYYYMMDD>.md`)

Write in plain language:

1. **Executive verdict** — Why does Power BI show **Tax/duty + Insurance + Other** but not **Transport/Unloading**? Pick one primary cause:
   - zero amounts on codes 2/3,
   - misclassification into Other,
   - extra OALC codes,
   - allocation/query mismatch.

2. **OALC master vs setup screenshot** — Are there codes beyond 1–4? List them with amounts.

3. **Closed-period totals by ReportingCategory** (Q3 vs Q6) — document-level vs allocated-to-lines; note any gap vs **2.65bn IQD**.

4. **"Other" bucket autopsy** (Q4) — which `AlcCode`/names drive it? Are Shipping/Unloading amounts hiding here?

5. **Setup codes 1–4 table** (Q5) — amount per code; explicitly state codes 2 and 3 totals.

6. **Keyword classifier proof** (Q8) — confirm expected buckets for the 4 SAP names.

7. **Recommended fix direction for Power BI team** (evidence only, no SAP changes):
   - e.g. "map by `AlcCode` not keywords", "rename OALC", "book freight under code 2", etc.

8. **Column substitutions** — any B1/HANA column names that differ from this prompt.

Do **not** include connection strings, usernames, or passwords.

---

## 5) Deliverable checklist

- [ ] `01_oalc_master_all_codes.csv`
- [ ] `02_ipf2_amounts_by_alccode_all_lc.csv`
- [ ] `03_ipf2_amounts_by_reporting_category_closed.csv`
- [ ] `04_other_bucket_detail_closed.csv`
- [ ] `04b_other_summary_by_alccode.csv`
- [ ] `05_setup_codes_1_to_4_closed_amounts.csv`
- [ ] `06_allocated_addon_by_category_closed.csv`
- [ ] `06b_allocated_addon_by_alccode.csv`
- [ ] `07_lc_doc_list_closed.csv`
- [ ] `08_keyword_match_proof.csv`
- [ ] `README_Paper_LandedCategory_Diag_<YYYYMMDD>.md`

When finished, **paste the full Desktop folder path** (`Paper_PBIP_LandedCategory_Diag_<timestamp>`) back into chat so the Fabric `Paper Inventory Report` model can be aligned to the findings.

---

## 6) Security

- **SELECT only.** No DDL/DML.
- No credentials in CSVs, README, or chat pastebacks.
- Advise operator to delete any scratch scripts that contain passwords.

---

**One-line summary:** SAP agent on PAPERENTITY: prove why Paper Inventory landed-cost charts show **Other** instead of **Transport/Unloading**; export OALC + IPF2 + allocated category totals to **Desktop\Paper_PBIP_LandedCategory_Diag_***, README, no secrets.
