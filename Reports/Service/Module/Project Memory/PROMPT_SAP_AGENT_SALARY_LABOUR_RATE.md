# Prompt (SAP-reachable agent): Canon **Service** — extract salary/labour data for a technician cost rate

Use this on the **SAP HANA / Business One** machine that can query schema **`CANON`** through the same ODBC DSN the Canon Power BI models use (e.g. `HANA_B1`; host `hana-vm-107:30013`, tenant DB `HV107C21694P01`). This is a **read-only extraction** — do **not** change any SAP data, journals, master data, or settings. Produce CSVs + a README on **Desktop** and paste the folder path back into chat.

---

## 0) Why you are running this

The **Canon Service Performance Report** needs a **labour cost basis** to cost technician visit time (`SCL6` hours). A prior investigation (`SALARY_SAP_FINDINGS_2026-06-03.md`) established that:

- SAP's HR/Payroll module (`OSAL`/`SAL1`/`OSHR`/`SHR1`) is **empty**, and `OHEM.salary` / `OHEM.emplCost` are **0 on all employees**.
- Salaries are posted as **manual journal entries** (`OJDT`/`JDT1`) to salary GL accounts (primarily **Basic Salary `620101010101`** and **Payroll Accrual `220101010101`**).
- Employee names appear **only as free-text** in the journal memos (English + Arabic), sometimes as company **lump sums**; the structured `EM-#####` business-partner code appears mainly on **advance/settlement** lines. **No hours/quantity are stored.**

**Your job:** export the salary journal data (raw, plus a monthly summary) and the two employee mapping tables, so the analyst can attribute monthly salary to the 14 service staff and derive an approximate hourly rate. **Do not attempt to parse Arabic names or compute rates** — just deliver clean, complete SELECT extracts; the analyst will parse them.

This is a **supplement** — do not re-dump service tables already exported on 2026-06-03.

---

## 1) Environment & conventions

- **DSN / connection:** the same ODBC the Canon Power BI model uses (e.g. `HANA_B1`). Do **not** embed credentials in any output file.
- **Schema:** `"CANON"` — quote identifiers HANA-style: `"CANON"."JDT1"`, etc.
- **SELECT only.** No DDL/DML. No changes to journals, accounts, BPs, or employees.
- **Currency** is IQD.
- **Salary GL accounts (known):** Basic Salary `620101010101`, Payroll Accrual `220101010101`, Employees End of Service `620101010107`, Employees Transportation `610101010124`, Employees Advances Old `110401010105`, Employees Advances New `110401010113`. **Note:** `2201…` is the **liability/credit** side — do not double-count with the `6201…` expense.
- **Window:** salaries observed `2026-01-31 → 2026-05-31`. Pull **all** rows on these accounts regardless of date (small volume); the analyst will window to Jan–May 2026.
- **Column-name caution:** SAP B1 column names vary slightly by version. **Run A1 (column catalog) FIRST**, then adjust any column name below to match. If a column does not exist, note the substitution in the README rather than failing silently.

---

## 2) Output location (Desktop, timestamped)

Create one folder; write **all** CSVs + one README into it:

- **Windows:** `%USERPROFILE%\Desktop\CANON_Salary_Labour_<YYYYMMDD_HHMMSS>\`
- **macOS/Linux:** `~/Desktop/CANON_Salary_Labour_<YYYYMMDD_HHMMSS>/`

Fallback only if Desktop is not writable: user home root, prefixed `Desktop_UNAVAILABLE_`, explained in README. **Never** put credentials in any file.

README filename: `README_CANON_Salary_Labour_<YYYYMMDD>.md`.
CSV format: UTF-8 (BOM ok), comma-separated, header row first, empty cell = NULL. **Preserve Arabic text** in memos (UTF-8).

---

## 3) PART A — Investigations (run first)

### A1 — `a1_column_catalog.csv` (column catalog) — RUN FIRST

```sql
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE_NAME, LENGTH, POSITION
FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON'
  AND TABLE_NAME IN ('OJDT','JDT1','OACT','OCRD','OHEM')
ORDER BY TABLE_NAME, POSITION;
```

**README:** confirm `JDT1` has **no** quantity/hours/days/rate column (only `Debit`/`Credit` monetary). Adjust later column names to match this catalog (e.g. `Line_ID` vs `LineNum`, `ShortName`, `LineMemo`).

### A2 — `a2_employee_expense_accounts.csv` (find ALL salary-type accounts, not just the 6)

```sql
SELECT "AcctCode", "AcctName", "FatherNum", "Postable"
FROM "CANON"."OACT"
WHERE "AcctCode" LIKE '6201%'
   OR "AcctCode" LIKE '2201%'
   OR "AcctCode" LIKE '1104%'
   OR LOWER("AcctName") LIKE '%salary%'
   OR LOWER("AcctName") LIKE '%payroll%'
   OR LOWER("AcctName") LIKE '%wage%'
   OR LOWER("AcctName") LIKE '%employee%'
   OR "AcctName" LIKE '%راتب%'
   OR "AcctName" LIKE '%رواتب%'
   OR "AcctName" LIKE '%أجور%'
   OR "AcctName" LIKE '%الموظف%'
ORDER BY "AcctCode";
```

**README:** list any salary/allowance/bonus/end-of-service accounts **beyond** the 6 known codes. If found, **add their codes** to the `IN (...)` lists in B1/B3 before running those.

---

## 4) PART B — Extractions

### B1 — `b1_salary_journal_lines_all.csv` (raw — the master extract)

```sql
SELECT H."TransId", H."RefDate", H."DueDate", H."TransType", H."Memo" AS "JournalMemo",
       L."Line_ID", L."Account", A."AcctName",
       L."ShortName", L."LineMemo", L."Debit", L."Credit", L."Ref1", L."Ref2"
FROM "CANON"."JDT1" L
JOIN "CANON"."OJDT" H ON L."TransId" = H."TransId"
LEFT JOIN "CANON"."OACT" A ON L."Account" = A."AcctCode"
WHERE L."Account" IN ('620101010101','220101010101','620101010107',
                      '610101010124','110401010105','110401010113')
   -- + any extra salary accounts found in A2
ORDER BY H."RefDate", H."TransId", L."Line_ID";
```

### B2 — `b2_basic_salary_lines.csv` (the core for per-engineer attribution)

```sql
SELECT H."TransId", H."RefDate", H."TransType", H."Memo" AS "JournalMemo",
       L."ShortName", L."LineMemo", L."Debit", L."Credit"
FROM "CANON"."JDT1" L
JOIN "CANON"."OJDT" H ON L."TransId" = H."TransId"
WHERE L."Account" = '620101010101'
ORDER BY H."RefDate", H."TransId";
```

> This is the actual **monthly salary expense**. The analyst will match each line's `LineMemo`/`JournalMemo` (English + Arabic) to the 14 service staff. Keep Arabic intact.

### B3 — `b3_salary_summary_by_account_month.csv` (sanity check / totals)

```sql
SELECT L."Account", A."AcctName",
       TO_VARCHAR(H."RefDate",'YYYY-MM') AS "ym",
       COUNT(*) AS "lines",
       ROUND(SUM(L."Debit"),0)  AS "total_debit",
       ROUND(SUM(L."Credit"),0) AS "total_credit"
FROM "CANON"."JDT1" L
JOIN "CANON"."OJDT" H ON L."TransId" = H."TransId"
LEFT JOIN "CANON"."OACT" A ON L."Account" = A."AcctCode"
WHERE L."Account" IN ('620101010101','220101010101','620101010107',
                      '610101010124','110401010105','110401010113')
GROUP BY L."Account", A."AcctName", TO_VARCHAR(H."RefDate",'YYYY-MM')
ORDER BY L."Account", "ym";
```

### B4 — `b4_employee_business_partners.csv` (name → EM- code)

```sql
SELECT "CardCode", "CardName", "GroupCode", "Balance"
FROM "CANON"."OCRD"
WHERE "CardCode" LIKE 'EM-%'
ORDER BY "CardCode";
```

### B5 — `b5_employees_all.csv` (name → empID, to map to SCL6 visits)

Pull **all** employees (not just service) so memo names can be disambiguated:

```sql
SELECT "empID", "firstName", "middleName", "lastName", "dept", "position", "Active"
FROM "CANON"."OHEM"
ORDER BY "empID";
```

### B6 — `b6_employee_coded_lines.csv` (structured per-employee lines, where they exist)

Lines that DO carry an `EM-#####` code (advances/settlements/payments) — the cleanest per-person signal:

```sql
SELECT H."TransId", H."RefDate", H."TransType", H."Memo" AS "JournalMemo",
       L."Account", A."AcctName", L."ShortName", L."LineMemo", L."Debit", L."Credit"
FROM "CANON"."JDT1" L
JOIN "CANON"."OJDT" H ON L."TransId" = H."TransId"
LEFT JOIN "CANON"."OACT" A ON L."Account" = A."AcctCode"
WHERE L."ShortName" LIKE 'EM-%'
ORDER BY L."ShortName", H."RefDate";
```

---

## 5) README content (`README_CANON_Salary_Labour_<YYYYMMDD>.md`)

1. **Totals:** Basic Salary (`620101010101`) total and per-month (from B3); number of journals; date range.
2. **Coverage:** roughly how many Basic Salary lines name **one person** vs are **company lump sums** (`"Salaries of Canon - <month>"`) — eyeball a sample, no need to parse fully.
3. **Extra accounts:** any salary/allowance accounts found in A2 beyond the 6 known; note if added to B1/B3.
4. **Confirm:** `JDT1` has no hours/quantity column (from A1).
5. **Column substitutions:** any column names that differ from this prompt.
6. **Note:** `2201…` accrual is the liability side — flag so the analyst doesn't double-count with `6201…` expense.

Do **not** include connection strings, usernames, or passwords.

---

## 6) Deliverable checklist

- [ ] `a1_column_catalog.csv`
- [ ] `a2_employee_expense_accounts.csv`
- [ ] `b1_salary_journal_lines_all.csv`
- [ ] `b2_basic_salary_lines.csv`
- [ ] `b3_salary_summary_by_account_month.csv`
- [ ] `b4_employee_business_partners.csv`
- [ ] `b5_employees_all.csv`
- [ ] `b6_employee_coded_lines.csv`
- [ ] `README_CANON_Salary_Labour_<YYYYMMDD>.md`

When finished, **paste the full Desktop folder path** (`CANON_Salary_Labour_<timestamp>`) back into chat so the analyst can attribute salary to the service technicians and derive an hourly labour rate for the Service report.

---

## 7) Security

- **SELECT only.** No DDL/DML, no changes to journals/accounts/master data.
- No credentials in CSVs, README, or chat pastebacks.
- Preserve Arabic memo text (UTF-8). Delete any scratch scripts that contain passwords.

---

**One-line summary:** Read-only SAP agent on schema `CANON`: export the salary **journal** data (`OJDT`/`JDT1` on Basic Salary `620101010101` + related employee-expense accounts), a monthly summary, and the employee mapping tables (`OCRD` `EM-%`, `OHEM`) to `~/Desktop/CANON_Salary_Labour_<timestamp>` — raw extracts only, keep Arabic, no secrets — so the analyst can derive a technician hourly labour rate.
