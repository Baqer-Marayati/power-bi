# Prompt (SAP-reachable agent): Canon Procurement & Suppliers field audit

Run this prompt on the machine/server that can reach **SAP Business One on SAP HANA** for company schema **`CANON`**. The purpose is **not** to build the Power BI page. The purpose is to pull enough SAP evidence so the PBIP author can decide what fields/measures are truly available for the **Canon Inventory Report > Procurement & Suppliers** page in Fabric.

## Mission

You are a read-only SAP HANA / SAP Business One data analyst agent. Pull metadata, diagnostics, row samples, and model-ready CSV extracts for:

- KPI cards: paid/received unit, landed unit cost, add-on %, largest landed-cost driver, average unit COGS.
- Waterfall: month-over-month landed unit cost walk by real landed-cost categories.
- Mix chart: landed unit cost / landed amount by supplier base, transport, unloading, tax/duty, insurance, other.
- Trend chart: paid unit vs landed unit vs sales-time average unit COGS.
- Detail table: LC document, supplier, broker, item, business type, LC status, category, receipt qty, paid unit, landed unit, add-on, COGS context.

The current Fabric model uses or may use these SAP B1 objects:

- Landed cost: `OIPF`, `IPF1`, `IPF2`, `OALC`
- Goods receipt: `OPDN`, `PDN1`
- Purchase order context: `OPOR`, `POR1`
- Item dimensions: `OITM`, `OITB`
- Sales / COGS context: `OINM` preferred if available, and optionally `OINV`, `INV1`, `ORIN`, `RIN1`, `ODLN`, `DLN1`
- Warehouse / stock context if useful for item validation: `OWHS`, `OITW`

## Hard rules

- Use `SELECT` only. Do not create, update, delete, truncate, or alter anything.
- Use schema `"CANON"` unless the operator explicitly says otherwise.
- Do not save passwords, DSNs, tokens, usernames with passwords, or connection strings in output files.
- Prefer CSV over Excel. Use UTF-8 CSV with headers, comma delimiter, and normal quoting.
- Use ISO dates where possible.
- Use bounded pulls first. The default business date window is `>= '2026-01-01'`, because the current PBIP model is focused on the recent Canon report period.
- If a query times out, split by month or export the raw source tables separately with the same fields.

## Output folder

Save everything on the agent/server machine Desktop:

- Windows: `%USERPROFILE%\Desktop\Canon_Procurement_FieldAudit_<YYYYMMDD_HHMMSS>\`
- macOS/Linux: `~/Desktop/Canon_Procurement_FieldAudit_<YYYYMMDD_HHMMSS>/`

Inside the folder, create:

- `README_Canon_Procurement_FieldAudit.md`
- `sql/` with every SQL query you ran as `.sql`
- `metadata/` for table/column inventory CSVs
- `diagnostics/` for counts, null rates, category profiles, and join tests
- `samples/` for small row samples
- `extracts/` for model-ready or near-model-ready CSVs

When done, report only the full Desktop folder path and any blocker summary. Do not paste secrets.

## 1. Connection proof

Export `metadata/connection_proof.csv`:

```sql
SELECT
    CURRENT_SCHEMA AS CURRENT_SCHEMA,
    CURRENT_USER AS CURRENT_USER,
    SESSION_USER AS SESSION_USER,
    CURRENT_TIMESTAMP AS RUN_AT
FROM DUMMY;
```

## 2. Table existence and full column metadata

Export one CSV per table under `metadata/`, named `<TABLE>_columns.csv`.

Tables to inspect:

```text
OIPF
IPF1
IPF2
OALC
OPDN
PDN1
OPOR
POR1
OITM
OITB
OWHS
OITW
OINM
OINV
INV1
ORIN
RIN1
ODLN
DLN1
```

Use a metadata query similar to:

```sql
SELECT
    TABLE_NAME,
    POSITION,
    COLUMN_NAME,
    DATA_TYPE_NAME,
    LENGTH,
    SCALE,
    IS_NULLABLE,
    DEFAULT_VALUE,
    COMMENTS
FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON'
  AND TABLE_NAME IN (
      'OIPF','IPF1','IPF2','OALC',
      'OPDN','PDN1','OPOR','POR1',
      'OITM','OITB','OWHS','OITW',
      'OINM','OINV','INV1','ORIN','RIN1','ODLN','DLN1'
  )
ORDER BY TABLE_NAME, POSITION;
```

Also export `metadata/key_table_rowcounts.csv`. For very large tables, include both total count if fast and filtered count since `2026-01-01` if a date column exists.

## 3. Landed-cost source availability

Export `diagnostics/landed_cost_header_profile.csv` from `OIPF`.

Include counts, null rates, distinct values, and date ranges for these fields if they exist:

- `DocEntry`, `DocNum`, `DocDate`, `DocDueDate`, `TaxDate`
- `DocStatus`, `OpenForLaC`, `Canceled`
- `CardCode`, `SuppName`
- `AgentCode`, `AgentName`
- `DocCur`, `DocRate`
- `ExpCustom`, `ActCustom`, `ExCustomSC`, `ActCustSC`, `CustDate`, `incCustom`

Suggested query:

```sql
SELECT
    COUNT(*) AS ROWS_TOTAL,
    MIN(H."DocDate") AS MIN_DOC_DATE,
    MAX(H."DocDate") AS MAX_DOC_DATE,
    SUM(CASE WHEN COALESCE(H."Canceled", 'N') = 'Y' THEN 1 ELSE 0 END) AS CANCELED_ROWS,
    SUM(CASE WHEN NULLIF(TRIM(H."CardCode"), '') IS NULL THEN 1 ELSE 0 END) AS BLANK_CARDCODE_ROWS,
    SUM(CASE WHEN NULLIF(TRIM(H."SuppName"), '') IS NULL THEN 1 ELSE 0 END) AS BLANK_SUPPNAME_ROWS,
    SUM(CASE WHEN NULLIF(TRIM(H."AgentCode"), '') IS NULL THEN 1 ELSE 0 END) AS BLANK_AGENTCODE_ROWS,
    SUM(CASE WHEN NULLIF(TRIM(H."AgentName"), '') IS NULL THEN 1 ELSE 0 END) AS BLANK_AGENTNAME_ROWS,
    SUM(CASE WHEN COALESCE(H."ExpCustom", 0) <> 0 OR COALESCE(H."ExCustomSC", 0) <> 0 THEN 1 ELSE 0 END) AS HAS_PROJECTED_CUSTOMS_ROWS,
    SUM(CASE WHEN COALESCE(H."ActCustom", 0) <> 0 OR COALESCE(H."ActCustSC", 0) <> 0 THEN 1 ELSE 0 END) AS HAS_ACTUAL_CUSTOMS_ROWS
FROM "CANON"."OIPF" H
WHERE H."DocDate" >= '2026-01-01';
```

Export `diagnostics/lc_status_values.csv`:

```sql
SELECT
    COALESCE(H."OpenForLaC", '<NULL>') AS OpenForLaC,
    COALESCE(H."DocStatus", '<NULL>') AS DocStatus,
    COALESCE(H."Canceled", '<NULL>') AS Canceled,
    COUNT(*) AS DocCount
FROM "CANON"."OIPF" H
WHERE H."DocDate" >= '2026-01-01'
GROUP BY H."OpenForLaC", H."DocStatus", H."Canceled"
ORDER BY DocCount DESC;
```

## 4. Landed-cost line and category diagnostics

Export `diagnostics/ipf1_basetype_counts.csv`:

```sql
SELECT
    R."BaseType",
    R."OriBDocTyp",
    COUNT(*) AS RowCount,
    COUNT(DISTINCT R."DocEntry") AS LcDocCount,
    MIN(H."DocDate") AS MinLcDate,
    MAX(H."DocDate") AS MaxLcDate
FROM "CANON"."OIPF" H
INNER JOIN "CANON"."IPF1" R
    ON H."DocEntry" = R."DocEntry"
WHERE H."DocDate" >= '2026-01-01'
  AND COALESCE(H."Canceled", 'N') <> 'Y'
  AND COALESCE(R."ItemCode", '') <> ''
GROUP BY R."BaseType", R."OriBDocTyp"
ORDER BY RowCount DESC;
```

Export `diagnostics/ipf2_landed_cost_code_profile.csv`:

```sql
SELECT
    C."AlcCode",
    COALESCE(A."AlcName", C."AlcCode") AS AlcName,
    A."CostCateg",
    COUNT(*) AS CostLineRows,
    COUNT(DISTINCT C."DocEntry") AS LcDocCount,
    SUM(COALESCE(C."CostSum", 0)) AS Sum_CostSum,
    SUM(COALESCE(C."CostSumSC", 0)) AS Sum_CostSumSC,
    SUM(ABS(COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0))) AS AbsBookedAmount
FROM "CANON"."IPF2" C
LEFT JOIN "CANON"."OALC" A
    ON C."AlcCode" = A."AlcCode"
INNER JOIN "CANON"."OIPF" H
    ON C."DocEntry" = H."DocEntry"
WHERE H."DocDate" >= '2026-01-01'
  AND COALESCE(H."Canceled", 'N') <> 'Y'
GROUP BY C."AlcCode", A."AlcName", A."CostCateg"
ORDER BY AbsBookedAmount DESC;
```

Export `diagnostics/category_bucket_profile.csv`. Use this exact bucketing logic so it can be compared with the current PBIP:

```sql
SELECT
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
    END AS ReportingCategory,
    COUNT(*) AS CostLineRows,
    COUNT(DISTINCT C."DocEntry") AS LcDocCount,
    SUM(COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0)) AS BookedAmount
FROM "CANON"."IPF2" C
LEFT JOIN "CANON"."OALC" A
    ON C."AlcCode" = A."AlcCode"
INNER JOIN "CANON"."OIPF" H
    ON C."DocEntry" = H."DocEntry"
WHERE H."DocDate" >= '2026-01-01'
  AND COALESCE(H."Canceled", 'N') <> 'Y'
GROUP BY
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
    END
ORDER BY BookedAmount DESC;
```

Also export `samples/top_landed_cost_code_rows.csv` with at least 200 rows from `IPF2` joined to `OALC` and `OIPF`, ordered by latest document and largest absolute amount. Include every visible amount/allocation method field from `IPF2` if columns exist, not only `CostSum` and `CostSumSC`.

## 5. Receipt link diagnostics

We need to know whether LC lines really link back to goods receipt rows and which key path works.

Export `diagnostics/lc_to_gr_join_path_comparison.csv` with counts for each candidate path:

- `IPF1.OriBAbsEnt -> OPDN.DocEntry`
- `IPF1.BaseEntry -> OPDN.DocEntry`
- `IPF1.ReceiptDocEntry` if such a field exists
- line match using `OriBLinNum`, `OrigLine`, `BaseRowNum`, and `LineNum` against `PDN1.LineNum`

If dynamic SQL is hard, use explicit queries for known columns. Export samples even if some paths fail.

Export `samples/lc_receipt_join_sample_500.csv`:

```sql
SELECT TOP 500
    H."DocEntry" AS LcDocEntry,
    H."DocNum" AS LcDocNum,
    H."DocDate" AS LcDate,
    H."DocDueDate" AS LcDueDate,
    H."DocStatus",
    H."OpenForLaC",
    H."CardCode" AS HeaderCardCode,
    H."SuppName" AS HeaderSuppName,
    H."AgentCode",
    H."AgentName",
    R."LineNum" AS IpF1LineNum,
    R."BaseType",
    R."OriBDocTyp",
    R."OriBAbsEnt",
    R."OriBLinNum",
    R."BaseEntry",
    R."BaseRowNum",
    R."OrigLine",
    R."ItemCode",
    R."Dscription",
    R."Quantity",
    R."FobValue",
    R."FobnLaC",
    R."LineTotal",
    R."PriceFOB",
    R."TtlExpndSC",
    R."TtlExpndLC",
    R."TtlCostLC",
    GRH."DocEntry" AS GrDocEntry,
    GRH."DocNum" AS GrDocNum,
    GRH."DocDate" AS GrDocDate,
    GRH."CardCode" AS GrCardCode,
    GRH."CardName" AS GrCardName,
    GRL."LineNum" AS GrLineNum,
    GRL."ItemCode" AS GrItemCode,
    GRL."Dscription" AS GrDescription,
    GRL."Quantity" AS GrQuantity,
    GRL."LineTotal" AS GrLineTotal,
    DAYS_BETWEEN(GRH."DocDate", H."DocDate") AS GrToLcDateDeltaDays
FROM "CANON"."OIPF" H
INNER JOIN "CANON"."IPF1" R
    ON H."DocEntry" = R."DocEntry"
LEFT JOIN "CANON"."OPDN" GRH
    ON COALESCE(NULLIF(R."OriBAbsEnt", 0), R."BaseEntry") = GRH."DocEntry"
LEFT JOIN "CANON"."PDN1" GRL
    ON GRH."DocEntry" = GRL."DocEntry"
   AND COALESCE(NULLIF(R."OriBLinNum", 0), NULLIF(R."OrigLine", 0), NULLIF(R."BaseRowNum", 0), R."LineNum") = GRL."LineNum"
WHERE H."DocDate" >= '2026-01-01'
  AND COALESCE(H."Canceled", 'N') <> 'Y'
  AND COALESCE(R."ItemCode", '') <> ''
ORDER BY H."DocDate" DESC, H."DocEntry" DESC, R."LineNum";
```

Export `diagnostics/receipt_date_vs_lc_date_delta.csv`:

```sql
SELECT
    COUNT(*) AS MatchedRows,
    MIN(DAYS_BETWEEN(GRH."DocDate", H."DocDate")) AS MinDeltaDays,
    MAX(DAYS_BETWEEN(GRH."DocDate", H."DocDate")) AS MaxDeltaDays,
    AVG(DAYS_BETWEEN(GRH."DocDate", H."DocDate")) AS AvgDeltaDays,
    SUM(CASE WHEN GRH."DocDate" = H."DocDate" THEN 1 ELSE 0 END) AS SameDateRows
FROM "CANON"."OIPF" H
INNER JOIN "CANON"."IPF1" R
    ON H."DocEntry" = R."DocEntry"
LEFT JOIN "CANON"."OPDN" GRH
    ON COALESCE(NULLIF(R."OriBAbsEnt", 0), R."BaseEntry") = GRH."DocEntry"
WHERE H."DocDate" >= '2026-01-01'
  AND COALESCE(H."Canceled", 'N') <> 'Y'
  AND GRH."DocDate" IS NOT NULL;
```

## 6. Supplier and broker data quality

Export `diagnostics/supplier_broker_quality.csv`:

```sql
SELECT
    COUNT(*) AS LcLineRows,
    SUM(CASE WHEN NULLIF(TRIM(H."AgentCode"), '') IS NULL THEN 1 ELSE 0 END) AS BlankAgentCodeRows,
    SUM(CASE WHEN NULLIF(TRIM(H."AgentName"), '') IS NULL THEN 1 ELSE 0 END) AS BlankAgentNameRows,
    SUM(CASE WHEN NULLIF(TRIM(COALESCE(GRH."CardName", H."SuppName", R."CardCode")), '') IS NULL THEN 1 ELSE 0 END) AS BlankResolvedSupplierNameRows,
    COUNT(DISTINCT COALESCE(NULLIF(TRIM(H."AgentName"), ''), NULLIF(TRIM(H."AgentCode"), ''), 'Unknown broker')) AS DistinctResolvedBrokers,
    COUNT(DISTINCT COALESCE(NULLIF(TRIM(GRH."CardName"), ''), NULLIF(TRIM(H."SuppName"), ''), NULLIF(TRIM(R."CardCode"), ''), 'Unknown supplier')) AS DistinctResolvedSuppliers
FROM "CANON"."OIPF" H
INNER JOIN "CANON"."IPF1" R
    ON H."DocEntry" = R."DocEntry"
LEFT JOIN "CANON"."OPDN" GRH
    ON COALESCE(NULLIF(R."OriBAbsEnt", 0), R."BaseEntry") = GRH."DocEntry"
WHERE H."DocDate" >= '2026-01-01'
  AND COALESCE(H."Canceled", 'N') <> 'Y'
  AND COALESCE(R."ItemCode", '') <> '';
```

Export:

- `diagnostics/top_brokers.csv`
- `diagnostics/top_suppliers_landed.csv`
- `samples/unknown_broker_rows_200.csv`

These should show whether `Unknown broker` is a real SAP data issue or a join/model issue.

## 7. Model-ready landed-cost allocation extract

Export `extracts/Fact_LandedCostAllocation_field_audit.csv`.

Use the current PBIP model shape, but include extra raw fields so the PBIP author can fix the semantic model if needed:

```sql
WITH RowBase AS (
    SELECT
        H."DocEntry" AS "LcDocEntry",
        H."DocNum" AS "LcDocNum",
        H."DocDate" AS "LcDate",
        COALESCE(GRH."DocDate", H."DocDate") AS "ReceiptDate",
        H."DocDueDate" AS "LcDueDate",
        H."DocStatus",
        H."OpenForLaC",
        CASE
            WHEN COALESCE(H."OpenForLaC", '') = 'Y' THEN 'Open'
            WHEN COALESCE(H."OpenForLaC", '') = 'N' THEN 'Closed'
            WHEN COALESCE(H."DocStatus", '') = 'O' THEN 'Open'
            WHEN COALESCE(H."DocStatus", '') = 'C' THEN 'Closed'
            ELSE 'Unknown'
        END AS "LcDocumentStatus",
        CASE
            WHEN COALESCE(H."OpenForLaC", '') = 'N' OR COALESCE(H."DocStatus", '') = 'C' THEN 1
            ELSE 0
        END AS "IsLcClosed",
        H."DocCur" AS "DocCurrency",
        H."DocRate",
        H."CardCode" AS "HeaderSupplierCode",
        H."SuppName" AS "HeaderSupplierName",
        NULLIF(TRIM(H."AgentCode"), '') AS "BrokerCode",
        COALESCE(NULLIF(TRIM(H."AgentName"), ''), NULLIF(TRIM(H."AgentCode"), ''), 'Unknown broker') AS "BrokerName",
        H."CustDate" AS "CustomsDate",
        H."incCustom" AS "IncludeCustomsFlag",
        COALESCE(NULLIF(H."ExCustomSC", 0), NULLIF(H."ExpCustom", 0), 0) AS "LcCustomsProjected",
        COALESCE(NULLIF(H."ActCustSC", 0), NULLIF(H."ActCustom", 0), 0) AS "LcCustomsActualHeader",
        COALESCE(NULLIF(R."OriBAbsEnt", 0), R."BaseEntry") AS "ReceiptDocEntry",
        COALESCE(NULLIF(R."OriBLinNum", 0), NULLIF(R."OrigLine", 0), NULLIF(R."BaseRowNum", 0), R."LineNum") AS "ReceiptLineNum",
        R."BaseType" AS "SourceBaseType",
        R."OriBDocTyp",
        COALESCE(R."CardCode", GRH."CardCode", H."CardCode") AS "SupplierCode",
        COALESCE(GRH."CardName", H."SuppName", R."CardCode") AS "SupplierName",
        R."ItemCode",
        R."Dscription" AS "ItemDescription",
        R."Quantity" AS "ReceiptQty",
        R."FobValue",
        R."FobnLaC",
        R."LineTotal",
        R."PriceFOB",
        R."TtlExpndSC",
        R."TtlExpndLC",
        R."TtlCostLC",
        COALESCE(NULLIF(R."FobValue", 0), NULLIF(R."FobnLaC", 0), NULLIF(R."LineTotal", 0), NULLIF(R."PriceFOB" * R."Quantity", 0), 0) AS "SupplierBaseAmount",
        COALESCE(NULLIF(R."TtlExpndSC", 0), NULLIF(R."TtlExpndLC", 0), NULLIF(R."TtlCostLC", 0), NULLIF(R."FobValue", 0), NULLIF(R."Quantity", 0), 1) AS "AllocationWeight",
        SUM(COALESCE(NULLIF(R."TtlExpndSC", 0), NULLIF(R."TtlExpndLC", 0), NULLIF(R."TtlCostLC", 0), NULLIF(R."FobValue", 0), NULLIF(R."Quantity", 0), 1)) OVER (PARTITION BY H."DocEntry") AS "DocAllocationWeight",
        GRH."DocNum" AS "ReceiptDocNum",
        GRH."CardCode" AS "ReceiptSupplierCode",
        GRH."CardName" AS "ReceiptSupplierName"
    FROM "CANON"."OIPF" H
    INNER JOIN "CANON"."IPF1" R
        ON H."DocEntry" = R."DocEntry"
    LEFT JOIN "CANON"."OPDN" GRH
        ON COALESCE(NULLIF(R."OriBAbsEnt", 0), R."BaseEntry") = GRH."DocEntry"
    WHERE R."ItemCode" IS NOT NULL
      AND R."ItemCode" <> ''
      AND COALESCE(H."Canceled", 'N') <> 'Y'
      AND H."DocDate" >= '2026-01-01'
),
CostLines AS (
    SELECT
        C."DocEntry",
        C."LineNum" AS "CostLineNum",
        C."AlcCode" AS "LandedCostCode",
        COALESCE(A."AlcName", C."AlcCode") AS "LandedCostName",
        A."CostCateg",
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
        END AS "ReportingCategory",
        C."OhType" AS "CostAllocationMethod",
        COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0) AS "CostAmount",
        C."CostSum",
        C."CostSumSC"
    FROM "CANON"."IPF2" C
    LEFT JOIN "CANON"."OALC" A
        ON C."AlcCode" = A."AlcCode"
    WHERE COALESCE(NULLIF(C."CostSum", 0), C."CostSumSC", 0) <> 0
)
SELECT
    RB.*,
    'BASE' AS "LandedCostCode",
    'Supplier base' AS "LandedCostName",
    NULL AS "CostCateg",
    'Supplier base' AS "ReportingCategory",
    RB."SupplierBaseAmount" AS "LandedCostAmount",
    RB."SupplierBaseAmount",
    0 AS "AddOnAmount",
    'Base receipt value' AS "CostAllocationMethod",
    NULL AS "CostLineAmountRaw",
    TO_VARCHAR(RB."ReceiptDocEntry") || '-' || TO_VARCHAR(RB."ReceiptLineNum") AS "ReceiptLineKey"
FROM RowBase RB
UNION ALL
SELECT
    RB.*,
    CL."LandedCostCode",
    CL."LandedCostName",
    CL."CostCateg",
    CL."ReportingCategory",
    CASE WHEN RB."DocAllocationWeight" <> 0 THEN CL."CostAmount" * RB."AllocationWeight" / RB."DocAllocationWeight" ELSE 0 END AS "LandedCostAmount",
    0 AS "SupplierBaseAmount",
    CASE WHEN RB."DocAllocationWeight" <> 0 THEN CL."CostAmount" * RB."AllocationWeight" / RB."DocAllocationWeight" ELSE 0 END AS "AddOnAmount",
    CL."CostAllocationMethod",
    CL."CostAmount" AS "CostLineAmountRaw",
    TO_VARCHAR(RB."ReceiptDocEntry") || '-' || TO_VARCHAR(RB."ReceiptLineNum") AS "ReceiptLineKey"
FROM RowBase RB
INNER JOIN CostLines CL
    ON RB."LcDocEntry" = CL."DocEntry";
```

If this query fails because one or more columns do not exist, export:

- `extracts/RowBase_available_columns.csv`
- `extracts/CostLines_available_columns.csv`
- `metadata/missing_columns_for_model_ready_extract.csv`

Then describe the missing columns in the README.

## 8. Goods receipt paid-unit extract

Export `extracts/Fact_GoodsReceipt_paid_unit.csv`:

```sql
SELECT
    H."DocEntry",
    H."DocNum",
    H."DocDate",
    H."CardCode",
    H."CardName",
    L."LineNum",
    L."ItemCode",
    L."Dscription",
    L."Quantity",
    L."LineTotal",
    CASE WHEN L."Quantity" <> 0 THEN L."LineTotal" / L."Quantity" ELSE NULL END AS "PaidUnitCost",
    L."Currency",
    L."Rate",
    L."WhsCode",
    L."BaseType",
    L."BaseEntry",
    L."BaseLine"
FROM "CANON"."OPDN" H
INNER JOIN "CANON"."PDN1" L
    ON H."DocEntry" = L."DocEntry"
WHERE H."DocDate" >= '2026-01-01'
  AND COALESCE(H."CANCELED", 'N') <> 'Y'
  AND COALESCE(L."ItemCode", '') <> ''
ORDER BY H."DocDate", H."DocEntry", L."LineNum";
```

Also export `diagnostics/goods_receipt_paid_unit_profile.csv` grouped by month and supplier:

```sql
SELECT
    TO_VARCHAR(H."DocDate", 'YYYY-MM') AS YearMonth,
    H."CardCode",
    H."CardName",
    COUNT(*) AS ReceiptLines,
    SUM(L."Quantity") AS ReceiptQty,
    SUM(L."LineTotal") AS ReceiptValue,
    CASE WHEN SUM(L."Quantity") <> 0 THEN SUM(L."LineTotal") / SUM(L."Quantity") ELSE NULL END AS WeightedPaidUnit
FROM "CANON"."OPDN" H
INNER JOIN "CANON"."PDN1" L
    ON H."DocEntry" = L."DocEntry"
WHERE H."DocDate" >= '2026-01-01'
  AND COALESCE(H."CANCELED", 'N') <> 'Y'
  AND COALESCE(L."ItemCode", '') <> ''
  AND L."Quantity" > 0
GROUP BY TO_VARCHAR(H."DocDate", 'YYYY-MM'), H."CardCode", H."CardName"
ORDER BY YearMonth, ReceiptValue DESC;
```

## 9. Item dimension fields needed for slicers/table

Export `extracts/Dim_Item_procurement_context.csv` from `OITM` joined to `OITB`.

Include these fields if they exist:

- `ItemCode`, `ItemName`, `ItmsGrpCod`, group name from `OITB`
- `U_BusinessType`, `U_GroupType`, `U_ProductType`, `U_SegmentType`
- `InvntItem`, `SellItem`, `PrchseItem`, `validFor`, `frozenFor`
- `AvgPrice`, `LastPurPrc`

Also export `diagnostics/item_custom_field_null_rates.csv` for the custom fields above.

## 10. Sales-time COGS extract/profile

The page compares procurement-time unit costs against sales-time average COGS. Pull enough data to verify the COGS measure.

First, confirm whether `OINM` exists and which cost/quantity columns are populated. Export `metadata/OINM_columns.csv` and `diagnostics/oinm_cogs_column_profile.csv`.

If `OINM` has the expected movement fields, export `extracts/Fact_StockMovement_cogs_context.csv` using the same sales movement logic as the PBIP if known. At minimum include:

- Posting date
- Item code
- Warehouse
- Transaction type
- In quantity / out quantity
- COGS value or transaction value field
- Document references

If the PBIP's exact COGS logic cannot be reproduced, export monthly item-level summaries:

```sql
SELECT
    TO_VARCHAR(M."DocDate", 'YYYY-MM') AS YearMonth,
    M."ItemCode",
    M."Warehouse",
    M."TransType",
    COUNT(*) AS MovementRows,
    SUM(COALESCE(M."OutQty", 0)) AS OutQty,
    SUM(COALESCE(M."CogsVal", 0)) AS CogsValue,
    CASE WHEN SUM(COALESCE(M."OutQty", 0)) <> 0 THEN SUM(COALESCE(M."CogsVal", 0)) / SUM(COALESCE(M."OutQty", 0)) ELSE NULL END AS AverageUnitCOGS
FROM "CANON"."OINM" M
WHERE M."DocDate" >= '2026-01-01'
  AND M."TransType" IN (13, 14, 15, 16)
GROUP BY TO_VARCHAR(M."DocDate", 'YYYY-MM'), M."ItemCode", M."Warehouse", M."TransType"
ORDER BY YearMonth, M."ItemCode", M."Warehouse", M."TransType";
```

If column names differ, adapt using discovered metadata and document the exact replacements in the README.

## 11. LC document spot checks

Export `samples/lc_doc_100008_full_trace.csv` for `OIPF.DocNum = 100008` if it exists. If not, choose:

1. Latest LC document with nonzero `IPF2` amount.
2. Latest open LC document.
3. Latest closed LC document.

For the selected LC documents, include:

- Header fields from `OIPF`
- All item lines from `IPF1`
- All cost lines from `IPF2` plus `OALC`
- Any matched `OPDN` / `PDN1` receipt rows
- Resolved supplier and broker
- Calculated supplier base amount, add-on amount, landed amount, and landed unit cost

Also export `samples/lc_doc_reconciliation_10_docs.csv` with 10 recent LC documents showing:

- `LcDocNum`
- `LcDate`
- `LcStatus`
- `SupplierName`
- `BrokerName`
- `ReceiptQty`
- `SupplierBaseAmount`
- `AddOnAmount`
- `LandedCostAmount`
- `AddOnPctOfLanded`
- category amounts: Supplier base, Transport, Unloading, Tax / duty, Insurance, Other

## 12. Page-readiness diagnostics

Create these final CSVs under `diagnostics/`:

- `page_kpi_monthly_summary.csv`: monthly paid unit, landed unit, add-on %, average unit COGS.
- `page_landed_category_monthly_summary.csv`: monthly landed amount and landed unit contribution by category.
- `page_landed_bridge_mom_candidate.csv`: prior month landed unit, current month landed unit, and category deltas by month.
- `page_detail_table_candidate.csv`: one row per LC doc / supplier / broker / item / category with the proposed table fields.
- `blank_or_zero_fields_for_page.csv`: columns/measures that are mostly blank or zero and should not be used prominently.

These do not need to match final Power BI measure names exactly. They are for data truth review.

## 13. README requirements

Write `README_Canon_Procurement_FieldAudit.md` with:

- Exact folder path.
- SAP server/company/schema name, but no secrets.
- Date/time of pull.
- Which tables existed and which were missing.
- Row counts by output file.
- Exact date filters.
- Any queries that failed or timed out.
- Columns that are missing from the prompt but similar alternatives exist.
- Whether landed add-ons exist by category, especially Transport, Unloading, Tax / duty, Insurance, and Other.
- Whether broker is genuinely blank/unknown or a join issue.
- Whether LC status is reliable from `OpenForLaC` / `DocStatus`.
- Whether receipt date differs materially from LC posting date.
- Whether the page should show a landed-cost category mix, or whether the data is mostly Supplier base plus one/few add-ons.
- Any recommendation for which fields are safe for the Fabric page and which should be hidden.

## Final handoff message

When complete, tell the operator:

```text
Done. The data pull folder is:
<full Desktop path>

Main README:
<full path to README_Canon_Procurement_FieldAudit.md>

Important blockers:
<none / short list>
```

The operator will copy the whole folder and provide it back to the Power BI PBIP agent.
