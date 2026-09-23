# Prompt (SAP-reachable agent): Canon **Service** report — fill the profitability, SLA & linkage gaps

Use this on the **SAP HANA / Business One** machine that can query schema **`CANON`** through the same ODBC DSN the Canon Power BI models use (e.g. `HANA_B1`; host `hana-vm-107:30013`, tenant DB `HV107C21694P01`). This is a **read-only investigation + targeted extraction** — do **not** change any SAP data, documents, contracts, master data, or settings. Produce CSVs + a README on **Desktop** and paste the folder path back into chat.

---

## 0) Why you are running this

We are building the **Canon Service Performance Report** (PBIP at `Reports/Service/Companies/CANON/Canon Service Report/`). We already have a good 5-month raw export (`~/Desktop/CANON_SAP_Export_2026-06-03/`, 30 tables, 1,079 service calls, 2026-01-04 → 2026-06-03). Analysis of that export confirmed the **call → activity → machine → project** spine is now strong, but **three things block a truthful report** and need data we do **not** yet have:

1. **Per-machine / per-project profitability is impossible** because the **money is not tied to projects or machines**:
   - Service **revenue** lines (`INV1` where `ItemCode IN ('SV001','SV002','SV003','MPS')`) carry a `Project` code on **0%** of `SV002` (FSMA) and `MPS` lines, and only ~14% of `SV001` (Labour). Revenue is **customer-level only**.
   - Parts **cost** (`DLN1`) carries a `Project` on only **~18%** of lines.
   - The direct call→document bridge (`SCL4`) reaches only **43 calls** with parts cost and **16 calls** with revenue (~4% of calls).
   - **427 of 1,079 calls (40%)** are tagged to project `PR-000` "Others" (catch-all), diluting any project view.
2. **SLA reporting is impossible** — `OSCL.respByDate` / `respByTime` (the SLA target columns) are **0% populated**, and SAP's native contract module (`OCTR`) is empty. We have no response/resolution targets per priority.
3. **Labour cannot be costed** — `SCL6` gives rich visit hours, but there is no labour cost rate per engineer/team anywhere we've pulled.

**Your job:** (a) **investigate** whether SAP holds the missing links somewhere we haven't looked (blanket agreements, header-level projects, base-document references, line free-text, meter tables, employee cost fields, SLA config), and (b) **extract** the targeted datasets that let us rebuild the model on a complete project/machine spine. Where SAP genuinely does **not** hold something (likely for SLA targets and labour rates), say so explicitly so we route it to the business as a manual input.

This is a **supplement** to the 2026-06-03 export — do **not** re-dump tables we already have (OSCL, SCL6, OINS, etc.) unless a query below asks for an enriched/joined version.

---

## 1) Environment & conventions

- **DSN / connection:** the same ODBC the Canon Power BI model uses (e.g. `HANA_B1`). Do **not** embed credentials in any output file.
- **Schema:** `"CANON"` — quote identifiers HANA-style: `"CANON"."OINV"`, `"CANON"."INV1"`, etc.
- **SELECT only.** No DDL/DML. No changes to documents, agreements, equipment cards, item groups, or settings.
- **Service revenue items:** `SV001` = Labour Income, `SV002` = FSMA Contract Income (per-page), `SV003` = Warranty COGS, `MPS` = MPS Contract Income (per-page).
- **Service window:** service calls run `2026-01-04`→`2026-06-03`. For financial tables use `"DocDate" >= '2026-01-01'` unless a query says otherwise. Note in the README if a wider window is needed.
- **Time fields** in `OSCL`/`SCL6` are a `date` column + a separate **HHMM integer** time (e.g. `1128` = 11:28).
- **Currency** is IQD; amounts are large integers.
- **Column-name caution:** SAP B1 column names vary slightly by version. **Run the catalog query (I1) FIRST**, then adjust any column name in later queries to match what I1 actually returns. If a referenced column does not exist, note the substitution in the README rather than failing silently.

---

## 2) Output location (Desktop, timestamped)

Create one folder; write **all** CSVs + one README into it:

- **Windows:** `%USERPROFILE%\Desktop\CANON_Service_Gaps_<YYYYMMDD_HHMMSS>\`
- **macOS/Linux:** `~/Desktop/CANON_Service_Gaps_<YYYYMMDD_HHMMSS>/`

Fallback only if Desktop is not writable: user home root, prefixed `Desktop_UNAVAILABLE_`, explained in README. **Never** put credentials in any file.

README filename: `README_CANON_Service_Gaps_<YYYYMMDD>.md`.

CSV format: UTF-8 (BOM ok), comma-separated, header row first, empty cell = NULL.

---

## 3) PART A — Investigations (run first; they tell us what's possible)

### I1 — `i1_column_catalog.csv` (column catalog for linkage discovery) — RUN FIRST

Dump the column list for every table we need to mine for hidden links:

```sql
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE_NAME, LENGTH, POSITION
FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON'
  AND TABLE_NAME IN (
    'OINV','INV1','ODLN','DLN1','OSCL','OINS','OHEM','OITM','OITB',
    'OAGR','AGR1','OCTR','CTR1','OPRJ','SCL4','SCL6'
  )
ORDER BY TABLE_NAME, POSITION;
```

Then, in the README, **flag candidate linkage columns** — any column whose name contains (case-insensitive): `PROJ`, `INS`, `SERIAL`, `SERIAL NO`, `SN`, `EQUIP`, `AGR`, `BASE`, `CONTRACT`, `CNTR`, or starts with `U_`. These are where a machine/project/contract link could be hiding.

---

### I2 — `i2_service_revenue_linkage_population.csv` (does ANY column tie service revenue to a project/machine/agreement?)

For each service revenue item, count how often each candidate linkage column is populated. **Adjust column names to match I1** (BaseType default in B1 is usually `-1`; AgrNo default is `0`):

```sql
SELECT
    L."ItemCode",
    COUNT(*)                                                                        AS Lines,
    SUM(CASE WHEN L."Project"   IS NOT NULL AND L."Project"   <> ''   THEN 1 ELSE 0 END) AS Has_Line_Project,
    SUM(CASE WHEN H."Project"   IS NOT NULL AND H."Project"   <> ''   THEN 1 ELSE 0 END) AS Has_Header_Project,
    SUM(CASE WHEN H."AgrNo"     IS NOT NULL AND H."AgrNo"     <> 0     THEN 1 ELSE 0 END) AS Has_AgrNo,
    SUM(CASE WHEN L."BaseType"  IS NOT NULL AND L."BaseType"  <> -1    THEN 1 ELSE 0 END) AS Has_BaseDoc,
    SUM(CASE WHEN L."BaseEntry" IS NOT NULL                            THEN 1 ELSE 0 END) AS Has_BaseEntry,
    ROUND(SUM(L."LineTotal"), 0)                                                    AS TotalRevenue
FROM "CANON"."INV1" L
INNER JOIN "CANON"."OINV" H ON L."DocEntry" = H."DocEntry"
WHERE L."ItemCode" IN ('SV001','SV002','SV003','MPS')
  AND H."DocDate" >= '2026-01-01'
GROUP BY L."ItemCode"
ORDER BY L."ItemCode";
```

**This is the single most important query.** If `Has_AgrNo` or `Has_Header_Project` is high, we have found the machine/project link for FSMA revenue. If everything is zero except the customer, confirm that revenue is irretrievably customer-level and we must allocate.

---

### I3 — Blanket / per-page agreements (the most likely home of FSMA & MPS contracts)

`OCTR` (native service contracts) is empty, but **per-page FSMA/MPS deals are very likely stored as blanket agreements** (`OAGR`/`AGR1`), which CAN carry a Project and item lines. Investigate:

```sql
-- existence + sample
SELECT COUNT(*) AS oagr_rows FROM "CANON"."OAGR";
```
```sql
SELECT * FROM "CANON"."OAGR" LIMIT 50;       -- header: AbsId, Descript, CardCode, Project, StartDate, EndDate, Status, AgrType, ...
```
```sql
SELECT * FROM "CANON"."AGR1" LIMIT 200;       -- lines: AbsEntry, ItemCode, Project, PlannedQty/Amount, ...
```
```sql
-- do service invoices reference an agreement? (link OINV.AgrNo -> OAGR.AbsId)
SELECT H."AgrNo",
       COUNT(*)                 AS svc_lines,
       COUNT(DISTINCT H."DocEntry") AS invoices,
       ROUND(SUM(L."LineTotal"),0)  AS total_rev
FROM "CANON"."INV1" L
INNER JOIN "CANON"."OINV" H ON L."DocEntry" = H."DocEntry"
WHERE L."ItemCode" IN ('SV001','SV002','SV003','MPS')
  AND H."DocDate" >= '2026-01-01'
GROUP BY H."AgrNo"
ORDER BY total_rev DESC;
```

Save as `i3_oagr_header.csv`, `i3_agr1_lines.csv`, `i3_service_invoice_by_agreement.csv`.
**README:** Do FSMA/MPS contracts live in `OAGR`? Do those agreements carry a `Project` (= client + machine model)? If yes, this is the missing revenue→project link.

---

### I4 — `i4_sla_and_contract_status.csv` (confirm SLA targets are absent)

```sql
SELECT
    COUNT(*)                                                                AS total_calls,
    SUM(CASE WHEN "respByDate" IS NOT NULL THEN 1 ELSE 0 END)               AS has_respByDate,
    SUM(CASE WHEN "respOnDate" IS NOT NULL THEN 1 ELSE 0 END)               AS has_respOnDate,
    SUM(CASE WHEN "resolOnDat" IS NOT NULL THEN 1 ELSE 0 END)               AS has_resolOn
FROM "CANON"."OSCL";
```
```sql
SELECT COUNT(*) AS octr_rows FROM "CANON"."OCTR";   -- expected 0
```

**README:** Confirm `respByDate` is empty and `OCTR` is empty. If both are empty, **state plainly: "SAP holds no SLA targets; the business must supply response/resolution targets per priority (L/M/H)."** Also check (via I1) whether any priority/queue config table carries default response times; if found, export it.

---

### I5 — Labour cost rate (does SAP cost service labour at all?)

```sql
-- service employees, full row, to spot any cost/salary/rate column (adjust to the 14 service empIDs)
SELECT * FROM "CANON"."OHEM"
WHERE "empID" IN (66,67,68,69,70,71,72,73,74,75,76,77,78,80);
```
```sql
-- service item cost (these are non-stock service items; cost is probably 0/empty)
SELECT "ItemCode","ItemName","ItmsGrpCod","AvgPrice","LastPurPrc","StockValue"
FROM "CANON"."OITM"
WHERE "ItemCode" IN ('SV001','SV002','SV003','MPS');
```

Save as `i5_service_employees.csv`, `i5_service_item_cost.csv`.
**README:** Is there any per-employee hourly/daily cost field, or a standard cost on `SV001`? If not, **state: "no labour cost basis in SAP; business must supply an hourly (or per-visit) cost rate per engineer or per team."**

---

## 4) PART B — Targeted extractions (the data we want to load)

### S1 — `s1_call_project_recovery.csv` (RECOVER the 427 "Others" calls) — HIGH VALUE

For every call that is unlinked or tagged `PR-000`, recover the real project **via the machine** (`OINS.U_Project`, which is 100% populated):

```sql
SELECT
    C."callID",
    C."customer",            B."CardName"        AS customer_name,
    C."insID",
    C."itemCode",            C."itemName",
    C."BPProjCode"           AS call_project,
    E."U_Project"            AS machine_project,
    P2."PrjName"             AS machine_project_name,
    C."createDate",          C."status",  C."priority"
FROM "CANON"."OSCL" C
LEFT JOIN "CANON"."OINS" E  ON C."insID"     = E."insID"
LEFT JOIN "CANON"."OPRJ" P2 ON E."U_Project" = P2."PrjCode"
LEFT JOIN "CANON"."OCRD" B  ON C."customer"  = B."CardCode"
WHERE C."BPProjCode" IS NULL OR C."BPProjCode" = '' OR C."BPProjCode" = 'PR-000'
ORDER BY C."createDate";
```

**README:** Of the ~427+25 unlinked calls, how many get a real project recovered from the machine? (This tells us whether we can shrink "Others" dramatically in the model.)

---

### S2 — `s2_project_dimension_enriched.csv` (the project = client + machine-model spine)

```sql
SELECT
    P."PrjCode", P."PrjName", P."Active",
    COUNT(DISTINCT E."insID")    AS machines,
    COUNT(DISTINCT E."customer") AS customers
FROM "CANON"."OPRJ" P
LEFT JOIN "CANON"."OINS" E ON E."U_Project" = P."PrjCode"
GROUP BY P."PrjCode", P."PrjName", P."Active"
ORDER BY machines DESC;
```

---

### S3 — `s3_project_parts_cost.csv` + `s3b_project_revenue_with_project.csv` (money that already carries a project)

Parts cost by project (deliveries, excluding service items):

```sql
SELECT
    L."Project", P."PrjName",
    COUNT(*)                      AS delivery_lines,
    COUNT(DISTINCT H."CardCode")  AS customers,
    ROUND(SUM(L."LineTotal"), 0)  AS total_parts_cost
FROM "CANON"."DLN1" L
INNER JOIN "CANON"."ODLN" H ON L."DocEntry" = H."DocEntry"
LEFT JOIN  "CANON"."OPRJ" P ON L."Project"  = P."PrjCode"
WHERE L."Project" IS NOT NULL AND L."Project" <> ''
  AND L."ItemCode" NOT IN ('SV001','SV002','SV003','MPS')
  AND H."DocDate" >= '2026-01-01'
GROUP BY L."Project", P."PrjName"
ORDER BY total_parts_cost DESC;
```

Revenue lines that DO carry a project (mostly `SV001`):

```sql
SELECT
    L."Project", P."PrjName", L."ItemCode",
    COUNT(*) AS lines, ROUND(SUM(L."LineTotal"),0) AS total_rev
FROM "CANON"."INV1" L
INNER JOIN "CANON"."OINV" H ON L."DocEntry" = H."DocEntry"
LEFT JOIN  "CANON"."OPRJ" P ON L."Project"  = P."PrjCode"
WHERE L."Project" IS NOT NULL AND L."Project" <> ''
  AND L."ItemCode" IN ('SV001','SV002','SV003','MPS')
  AND H."DocDate" >= '2026-01-01'
GROUP BY L."Project", P."PrjName", L."ItemCode"
ORDER BY total_rev DESC;
```

---

### S4 — `s4_service_revenue_line_detail.csv` (mine descriptions/refs for machine identity) — HIGH VALUE

Full service-revenue line detail. The line **`Dscription`** and any UDFs may name the machine model/serial, and `BaseType`/`BaseEntry` may trace to a source order/agreement. This is how we may recover per-machine FSMA revenue even without a Project code:

```sql
SELECT
    H."DocNum", H."DocEntry", H."DocDate",
    H."CardCode", B."CardName",
    H."AgrNo"    AS agreement_no,
    H."Project"  AS header_project,
    L."LineNum", L."ItemCode", L."Dscription",
    L."Quantity", L."Price", L."LineTotal",
    L."Project"  AS line_project,
    L."BaseType", L."BaseEntry", L."BaseLine"
FROM "CANON"."INV1" L
INNER JOIN "CANON"."OINV" H ON L."DocEntry" = H."DocEntry"
LEFT JOIN  "CANON"."OCRD" B ON H."CardCode" = B."CardCode"
WHERE L."ItemCode" IN ('SV001','SV002','SV003','MPS')
  AND H."DocDate" >= '2026-01-01'
ORDER BY H."DocDate", H."DocNum", L."LineNum";
```

**README:** Sample 10–20 `SV002`/`MPS` descriptions — do they contain a machine model or serial? If yes, we can parse per-machine revenue. Also: for `SV002`/`MPS`, is `Quantity` the page count and `Price` the per-page rate? Confirm.

---

### S5 — `s5_counter_readings.csv` + meter-table investigation (cost-per-page basis)

Clean export of meter/counter readings captured on calls, joined to machine + project:

```sql
SELECT
    C."callID", C."customer", C."insID", C."itemName", C."BPProjCode",
    C."createDate",
    C."U_A15"  AS counter_bk,
    C."U_A_20" AS counter_cyan,
    C."U_A_21" AS counter_magenta,
    C."U_A_22" AS counter_yellow,
    C."U_A_23" AS small_bw, C."U_A_24" AS large_bw,
    C."U_A_25" AS small_color, C."U_A_26" AS large_color,
    C."U_A_27" AS total_small, C."U_A_28" AS total_large,
    C."U_A_29" AS total_counter
FROM "CANON"."OSCL" C
WHERE C."U_A_29" IS NOT NULL OR C."U_A_23" IS NOT NULL
ORDER BY C."createDate";
```

Then **investigate** whether a dedicated meter/counter history table exists (use I1 + a name scan):

```sql
SELECT TABLE_NAME FROM SYS.TABLES
WHERE SCHEMA_NAME = 'CANON'
  AND (UPPER(TABLE_NAME) LIKE '%MTR%' OR UPPER(TABLE_NAME) LIKE '%METER%'
       OR UPPER(TABLE_NAME) LIKE '%COUNT%' OR UPPER(TABLE_NAME) LIKE '%READ%')
ORDER BY TABLE_NAME;
```

**README:** Note that `U_A15`/`U_A_20..22` cap at 100 (likely toner-level %, not page counts) while `U_A_23..29` are true page counts. Confirm. Is there a fuller meter source than these ~18%-populated UDFs?

---

### S6 — `s6_group139_items.csv` (confirm the "#N/A" production reclassification)

```sql
SELECT
    I."ItemCode", I."ItemName", I."ItmsGrpCod", G."ItmsGrpNam",
    COUNT(DISTINCT E."insID") AS machines
FROM "CANON"."OITM" I
LEFT JOIN "CANON"."OITB" G ON I."ItmsGrpCod" = G."ItmsGrpCod"
LEFT JOIN "CANON"."OINS" E ON E."itemCode"   = I."ItemCode"
WHERE I."ItmsGrpCod" = 139
GROUP BY I."ItemCode", I."ItemName", I."ItmsGrpCod", G."ItmsGrpNam"
ORDER BY machines DESC;
```

**README:** List the items so the stakeholder can confirm group 139 (`#N/A`) = Production (imagePRESS / varioPRINT / COLORADO) and, ideally, fix the group name in SAP.

---

### S7 — `s7_classification_fillrate_by_month.csv` (data-quality governance)

```sql
SELECT
    TO_VARCHAR("createDate", 'YYYY-MM')                                       AS ym,
    COUNT(*)                                                                  AS calls,
    SUM(CASE WHEN "callType"   IS NOT NULL AND "callType"   <> '' THEN 1 ELSE 0 END) AS has_calltype,
    SUM(CASE WHEN "problemTyp" IS NOT NULL AND "problemTyp" <> '' THEN 1 ELSE 0 END) AS has_problemtype,
    SUM(CASE WHEN "origin"     IS NOT NULL AND "origin"     <> '' THEN 1 ELSE 0 END) AS has_origin
FROM "CANON"."OSCL"
GROUP BY TO_VARCHAR("createDate", 'YYYY-MM')
ORDER BY ym;
```

---

## 5) README content (`README_CANON_Service_Gaps_<YYYYMMDD>.md`)

Write in plain language, leading with the verdicts that unblock the report:

1. **Revenue→machine/project verdict (from I2/I3/S4):** Can FSMA/MPS/Labour revenue be tied to a project or machine? Via which mechanism — `OAGR` agreement, header `Project`, base document, or line description? Or is it confirmed **customer-level only**?
2. **"Others" recovery (S1):** how many of the 427 `PR-000` calls get a real project from the machine.
3. **Project-level money (S3):** how much parts cost and revenue already carries a project code.
4. **SLA verdict (I4):** confirm no SLA targets in SAP → list exactly what the business must provide (targets per priority).
5. **Labour cost verdict (I5):** confirm no labour rate in SAP → what the business must provide.
6. **Counters (S5):** is there a fuller meter source than the OSCL UDFs?
7. **Group 139 (S6):** item list for reclassification confirmation.
8. **Column substitutions:** any column names that differ from this prompt (from I1).
9. **Open business questions** for the stakeholder, separated into "answerable from SAP once X is fixed" vs "must be supplied manually."

Do **not** include connection strings, usernames, or passwords.

---

## 6) Deliverable checklist

- [ ] `i1_column_catalog.csv`
- [ ] `i2_service_revenue_linkage_population.csv`
- [ ] `i3_oagr_header.csv`, `i3_agr1_lines.csv`, `i3_service_invoice_by_agreement.csv`
- [ ] `i4_sla_and_contract_status.csv`
- [ ] `i5_service_employees.csv`, `i5_service_item_cost.csv`
- [ ] `s1_call_project_recovery.csv`
- [ ] `s2_project_dimension_enriched.csv`
- [ ] `s3_project_parts_cost.csv`, `s3b_project_revenue_with_project.csv`
- [ ] `s4_service_revenue_line_detail.csv`
- [ ] `s5_counter_readings.csv` (+ meter-table scan result)
- [ ] `s6_group139_items.csv`
- [ ] `s7_classification_fillrate_by_month.csv`
- [ ] `README_CANON_Service_Gaps_<YYYYMMDD>.md`

When finished, **paste the full Desktop folder path** (`CANON_Service_Gaps_<timestamp>`) back into chat so the Canon Service semantic model can be rebuilt on a complete project/machine spine.

---

## 7) Security

- **SELECT only.** No DDL/DML, no changes to documents/agreements/master data/settings.
- No credentials in CSVs, README, or chat pastebacks.
- Delete any scratch scripts that contain passwords.

---

**One-line summary:** Read-only SAP agent on schema `CANON`: prove whether FSMA/MPS/Labour **revenue** can be tied to a **project/machine** (check `OAGR` agreements, header `Project`, base docs, line text), recover the 427 `PR-000` calls via `OINS.U_Project`, extract project-level cost, and confirm that **SLA targets** and **labour cost rates** are absent in SAP → export CSVs + README to `~/Desktop/CANON_Service_Gaps_<timestamp>`, no secrets.
