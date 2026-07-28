# CANON — How Salaries Are Entered in SAP (labour-cost basis finding)

**Source:** SAP Business One on SAP HANA, schema `CANON` (read-only investigation, 2026-06-03). No SAP data changed.
**Question answered:** How are salaries entered in SAP, and do those records hold employee name, hours, etc.?
**Why it matters:** The Canon Service report needs a **labour cost basis** to cost technician time (`SCL6` visit hours). This documents whether SAP can supply it. **Verdict: it cannot — labour rate is a business input.**

---

## TL;DR (verdict)

- Salaries are **NOT** in the HR/Payroll module and **NOT** on the employee master. They are entered as **manual journal entries** (`OJDT`/`JDT1`) posted to dedicated **salary GL accounts**.
- **Employee name:** present **only as free-text** in the journal memo (and, for advances/settlements, via an `EM-#####` Business-Partner code). Not a structured per-employee field on salary-expense lines.
- **Hours:** **not stored at all.** Journal lines carry monetary amounts only — no quantity/hours/days/rate. Salaries are **monthly lump amounts**.
- **Consequence:** SAP cannot supply a clean per-engineer hourly cost. A labour rate must be **supplied by the business**, or approximated as *monthly salary ÷ standard monthly hours* (salary parsed from journal memos — messy, mixed English/Arabic, partly lump-summed).

---

## 1. Where salaries are NOT

| Path checked | Result |
|---|---|
| HR module `OSAL`, `SAL1` | 0 rows (empty) |
| HR module `OSHR`, `SHR1` | 0 rows (empty) |
| `OHEM.salary` | 0 / 65 populated |
| `OHEM.emplCost` | 0 / 65 |
| `OHEM.CostCenter` | 0 / 65 |
| `OHEM.empCostCur` / `empCostUnt` / `salaryCurr` / `salaryUnit` | unused |

Fields/tables exist but are never filled. Do not rely on them.

## 2. Where salaries ARE — manual journal entries to salary GL accounts

`OJDT` header / `JDT1` lines, posted to (`OACT`):

| Account | Name | Lines | Total (IQD) |
|---|---|---:|---:|
| `620101010101` | Basic Salary (expense) | 145 | 381,911,222 |
| `220101010101` | Payroll Accrual (liability) | 73 | 371,301,922 |
| `610101010124` | Employees Transportation | 167 | 6,644,211 |
| `110401010105` | Employees Advances - Old | 23 | 21,562,500 |
| `110401010113` | Employees Advances - New | 42 | 27,340,500 |
| `620101010107` | Employees End of Service | — | — |

Overwhelmingly **manual journal entries** (`TransType=30`) + outgoing payments (`46`).

## 3. Employees duplicated as Business Partners (`EM-#####`)
- `OCRD.CardCode` pattern `EM-00001…EM-00066`, `CardType='C'`, `GroupCode=129`; names match techs (e.g. `EM-00010 Bilal Tayara`, `EM-00015 Mohammed Altahan`, `EM-00016 Ali Abdulsattar`).
- `EM-` codes appear as `JDT1.ShortName` on **advance/settlement** lines only. Core **Basic Salary** / **Payroll Accrual** expense lines use the GL account code as `ShortName`, **not** the employee → monthly salary expense is **not** structurally per-employee.
- `OCRD.EM-#####` (BP id) ≠ `OHEM.empID`. Any per-employee join must map name→name or be supplied.

## 4. What the records hold
- **Name:** free-text in `JDT1.LineMemo`/`OJDT.Memo`, English + Arabic, inconsistent (e.g. `"Ali Jawad salary for Mar 2026"`, `"راتب الشهر الرابع للموظف علي عبد الستار"`); often lump (`"Salaries of Canon - May 2026"`).
- **Hours:** none — no quantity/hours/days/rate columns. Monthly lump sums.
- **Period:** free-text in memo; `JDT1.RefDate` (month-end posting) is a rough proxy.

## 5. Recommendation for labour-costing
1. Do **not** treat SAP as a source of per-engineer hourly cost.
2. **Preferred:** business supplies a small table — *engineer (or team) → monthly cost or hourly rate* — cost against `SCL6` visit hours.
3. SAP-derived approximation (low confidence): parse Basic Salary memos to named employees, derive hourly = monthly ÷ ~208h. Expect gaps from lump batches/settlements.
4. Flag as a **manual input** in the report data-contract, same category as SLA targets.

## 6. One-line summary
Salaries are hand-keyed manual journal entries to GL accounts (Basic Salary `620101010101`, Payroll Accrual `220101010101`); HR module and employee-master salary fields are empty; entries carry employee name only as free-text memo (sometimes company-lump) and no hours — so a usable technician labour rate must be **provided by the business**, not extracted from SAP.

---

## 7. UPDATE 2026-06-03 — salary extract analyzed (`~/Desktop/CANON_Salary_Labour_20260603_200906/`)

The extract was delivered (all 9 CSVs) and parsed. **Per-engineer salary is confirmed UNRECOVERABLE from SAP:**

- **Monthly payroll is booked as anonymous department/cost-center lumps.** Each "Salaries of Canon - <month>" journal has only ~14 lines for the whole 65-person company, with `ShortName` = the GL account and `LineMemo` = the generic batch title (no employee). Line amounts are department-sized (e.g. **21.6M, 21.4M, 16.4M, 14.3M IQD**), not individual salaries. Net Basic Salary: **381.9M IQD over 5 months** (~84M/month, all staff); fully-loaded comp (incl. Accommodation/Social Security/Transport/Visa) ≈ **419.9M**.
- **Named lines (41) are leavers / final settlements** (Samir Sattar Jabbar, Fathi Younis, Redha Abbas Sajit, Mohammed Sabah, Mustafa Khairallah Al-Obaidi, Ali Jawad…) — none are core current service engineers, **except one** Arabic line: **Ali Abdulsattar (علي عبد الستار) ≈ 2,250,000 IQD/month** (the only individual service-engineer data point).
- **`b6` EM-coded lines are work advances / staff loans, not salary** (accounts "Advances For Work Purposes" / "Employees Advances"); service engineers net ≈ 0 (advances cleared). So they don't yield net pay either.

**Conclusion:** labour rate is a **business input**, full stop. Useful anchors for the business to set it: company avg ≈ **1.3M IQD/month/employee**; one observed engineer ≈ **2.25M/month**; so a service engineer is plausibly **~1.5–2.5M IQD/month**. Minimum needed to proceed: one average monthly (or hourly) cost per service engineer, or per team (Production vs Office). Hourly ≈ monthly ÷ ~176 h (8h × 5d). This is now the **only** input gating the cost-per-visit / labour-efficiency views; all non-labour efficiency metrics are ready to build.
