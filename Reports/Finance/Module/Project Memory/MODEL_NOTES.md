# Model Notes

## Main Semantic Model
- `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.SemanticModel/definition/model.tmdl`
- `Reports/Finance/Companies/PAPERENTITY/Paper Financial Report/Paper Financial Report.SemanticModel/definition/model.tmdl`

## Included Core Tables
- `Fact_PNL`
- `Fact_BalanceSheet`
- `Fact_SalesDetail`
- `Dim_Date`
- `Dim_Branch`
- `Dim_SalesType`
- `Dim_CostCenter`
- `Dim_Department`
- `Dim_Account`
- `Dim_BSAccount`
- `Dim_ChartRows`
- `Dim_StatementSummaryRows`
- `_Measures`

## Compatibility Tables Added For Benchmark Repair
- `generalLedgerEntries`
- `glBudgetEntries`
- `customerLedgerEntries`
- `vendorLedgerEntries`
- `purchaseLines`
- `CommitmentDocumentTable`
- `bankAccountLedgerEntries`
- `BudgetVsActualTable`
- `DateTable`
- `DateTableCashflowAPAR`
- `DateTablePreviousCashflow`
- `DateTableProjectedCashflow`
- `CashflowPeriod`
- `DimensionCodeTable`
- `DimensionCode1Slicer`
- `DimensionCode2Slicer`
- `Period`
- `accountingPeriods`
- `AccountCategoryTable`
- `dimensions`
- `dimensionValues`
- `accounts`
- `Last Refresh Date`
- `Feedback`
- `DueCategorySortTable`
- `DueCategorySortTable_AR`

## Important Removals From Active Use
- `DateTableAccountReceivables` and `DateTableAccountPayables` were removed from `model.tmdl` after AR/AP visuals were rewired away from them.
- Avoid reintroducing them unless there is a compelling reason and a safe validation path.
- Their orphaned `.tmdl` files were later removed from disk during cleanup once they were confirmed unreferenced.
- `Dim_Customer.tmdl` and `Dim_Item.tmdl` were also removed from disk during cleanup because they were not included in `model.tmdl` and were not referenced elsewhere in the report project.

## Known Provisional Objects
- `glBudgetEntries` is a compatibility budget derived from GL actuals.
- It is not confirmed native SAP budget logic.
- `bankAccountLedgerEntries` is a compatibility shell, not yet a true bank-ledger movement fact.
- `CommitmentDocumentTable` currently depends on `purchaseLines` and therefore reflects purchase quote/order commitment logic, not a complete enterprise commitment domain.

## Known Semantic Risks
- Power BI previously rejected custom compatibility relationships with invalid column-ID errors.
- Because of that, report-side rewires are currently safer than adding new custom relationships blindly.
- Warning icons in the right-side data pane usually mean invalid semantic expressions, stale references, or helper tables that still need refinement.
- Compatibility layers can create hidden circular dependency paths if tables start aliasing each other's measures across domains.
- AP/cashflow cross-links are especially sensitive because cash, payable, and turnover measures are easy to reference in both directions.
- Date dimensions that derive themselves from fact tables can also create refresh cycles in this hybrid model. `Dim_Date` was changed to a standalone calendar range to avoid a `Fact_SalesDetail` cyclic-reference load blocker.
- `Dim_Date` should remain standalone, but it should not extend far into the future. An overly wide range caused YTD measures to evaluate against empty future periods and blank out multiple KPI cards on the core working pages.
- `DateTable` should also remain standalone. Deriving it from `generalLedgerEntries` made several helper-date tables inherit warning-prone dependencies.
- The cashflow helper date tables are not optional cosmetic tables. Several cashflow visuals apply user-created filters against:
- `DateTablePreviousCashflow[IsInLast6Months_Previous]`
- `DateTableProjectedCashflow[IsInNext6Months]`
- `DateTableCashflowAPAR[IsInLast6Months_PTO]`
- If those helper columns are missing, the visuals fail even if the underlying cashflow measures still exist.
- `LocalDateTable_3a85b0bc-9ebc-4b88-9375-1f1e21803837` is only a formatting/helper table, but its `Month` column must stay aligned with the month-name strings used by the `Profit and Loss` matrix metadata.
- Dynamic `DATATABLE(...)` rows that embed `TODAY()` or `NOW()` are warning-prone in this model. Use `ROW(...)` for single-row dynamic helper tables instead.
- When a compatibility table is only a transformed echo of an SAP-backed fact, derive it directly from the fact if possible. Building compatibility tables on top of other compatibility tables increases warning churn and makes the model harder to reason about.
- `generalLedgerEntries` should not depend back on `glBudgetEntries`. That created the last strong circular-warning pattern because `glBudgetEntries` also references `generalLedgerEntries[ActualSpend]`.
- `accounts[GLAccountIsRowVisible]` is safer when it works directly from `Fact_PNL` and `purchaseLines`. Routing it through `BudgetVsActualTable` made a simple row-visibility check inherit the whole Actual-vs-Budget compatibility layer.
- `accounts` should also derive from real facts, not from `generalLedgerEntries`. Otherwise any lingering warning on `generalLedgerEntries` propagates to `accounts` even when the row-visibility logic is already fixed.
- In this model, volatile `TODAY()` logic inside compatibility tables is more warning-prone than using the latest available posting date from the fact table.

## AP / AR Notes
- AP and AR top cards prove the SAP-backed receivable/payable facts are loading.
- Several broken AP/AR visuals were caused by disconnected due-category helper fields, not by missing SAP data.
- AP / AR detail pages should stay focused on single-table behavior where possible until the broader model is cleaner.
- AP / AR detail pages are safer when they rely on direct ledger columns and measures rather than disconnected helper-date or helper-bucket entities.
- When an AP or AR page already shows valid top-level numbers, assume the business domain exists and investigate visual wiring before assuming SAP data is missing.

## Budget Notes
- Budget visuals can be made to render with compatibility logic.
- True budget reporting still requires a real SAP budget source if the business expects actual budget truth rather than a placeholder.
- Keep compatibility budget logic explicit. A visually working page is not the same thing as a source-of-truth budget implementation.
- The old `Actual vs Budget` dimension-selector path is no longer part of the live page shell. The `dimensions` compatibility table still exists in the model, but the live page no longer depends on that slicer to render.

## Balance Sheet — Profit Period (2026-04)
- SAP's balance sheet report auto-calculates a **Profit Period** line under Capital & Reserves from P&L account postings (the current year's net income/loss). This is not stored in any equity GL account — it's dynamically derived from `GroupMask 4-8` accounts.
- The `Fact_BalanceSheet` SQL was extended with a `UNION ALL` that aggregates P&L journal entries per (month, branch, sales type, department) into a synthetic equity account: `AcctCode = '_PP'`, `AcctName = 'Profit Period'`, `BSSection = 'Equity'`.
- This makes `Total Equity`, `Equity Ratio`, the Balance Sheet Mix donut, and the Largest Accounts bar chart all match SAP automatically — no measure-level patches needed.
- The aggregation keeps data volume low: one row per month×dimension combination rather than duplicating every individual P&L journal line.
- Sign convention is natural: `SUM(Debit - Credit)` for P&L accounts produces positive for loss (reducing equity) and negative for profit (increasing it), which aligns with the BS `Amount` convention.

## Balance Sheet — Sign-aware display (2026-04-07)
- `BS Balance Display` was changed from `ABS([BS Amount])` to a sign-aware `SUMX` that flips the sign for Liabilities and Equity sections: `IF(Section IN {"Liabilities","Equity"}, -SectionAmount, SectionAmount)`.
- **Why:** SAP shows negative values for (a) liability accounts with abnormal debit balances (e.g. AP prepayments), (b) contra-asset accounts (accumulated depreciation), and (c) Profit Period when the company has a loss. The old `ABS()` stripped all sign information, making the report unable to match SAP at the per-account level.
- **Top-level KPI cards are unaffected:** `Total Assets`, `Total Liabilities`, `Total Equity`, `Equity Ratio`, and all Card Display measures continue to return positive values because each uses `KEEPFILTERS(BSSection = ...)` which resolves to a single section in the `SUMX`.
- **Per-account visuals now match SAP:** the Largest BS Accounts bar chart, Balance Sheet Mix donut, and Balance by Department chart will correctly show negative values for contra-assets, abnormal liability balances, and Profit Period losses.
- The `Fact_BalanceSheet[Amount]` column itself is unchanged (`Debit - Credit`); the sign flip is purely in the display measure.

## Currency Notes
- The report should be standardized to Iraqi dinar presentation.
- Benchmark-derived pages still needed explicit format-string conversion because they came in with dollar formatting.
- IQD formatting can cause clipping or crowding on cards that were originally sized for shorter benchmark value strings.

## CANON — ROI page locked-period logic (2026-05-05)
- `accountingPeriods` now imports Canon SAP posting periods from `CANON.OFPR`, including `startingDate`, `endingDate`, and `periodStatus`.
- `[Average Company Capital]` uses account `310101010101` through `[Company Capital]`, samples capital at each of the 12 month-end dates in every selected year, sums those 12 values, and divides by 12. With the current Canon date table, this applies to 2026 only.
- The ROI card measure (`[ROI %]`) is intentionally single-year only: Year must be explicitly filtered to one value, otherwise the card returns blank. For one selected year, it ignores month/quarter/location/sales-type/department slicers, sums `[Net Profit]` only for periods where `periodStatus = "Y"`, and divides by `[Average Company Capital]`.
- The Monthly ROI line chart remains separate through `[Monthly ROI %]`, which annualizes monthly net profit as `DIVIDE([Net Profit], [Average Company Capital], 0) * 12`.
- Desktop validation: user opened `Canon Financial Report.pbip` after the `accountingPeriods` TMDL schema fix and confirmed the ROI behavior is good.

## PAPERENTITY — ROI page average-capital logic (2026-05-05)
- `accountingPeriods` now imports Paper SAP posting periods from `PAPERENTITY.OFPR`, including `startingDate`, `endingDate`, and `periodStatus`; ROI year logic starts at `Dim_Date[Year] >= 2024`.
- `[Average Company Capital]` uses `[Company Capital]`, which sums balance-sheet display for **`3000100` only** when the as-of calendar year is **2025 or earlier**, and for **`3000000` + `3000100`** when the as-of year is **2026 or later** (same month-end sampling: 12 month-ends per selected year, averaged). **`SAP BS Company Capital`** now aliases `[Company Capital]` so the SAP equity check uses the same capital-base rule.
- The ROI card (`[ROI %]`) mirrors the Canon locked-period pattern but is intentionally single-year only: when Year is `All`, unselected, or multiple years are selected, the card returns blank to avoid confusing multi-year ROI interpretation. For one selected year, it divides that year's locked-period `[Net Profit]` by that year's `[Average Company Capital]`. If Paper has no `periodStatus = "Y"` rows for the selected year, it falls back to that selected Paper fiscal year so the card does not render blank.
- The Monthly ROI line chart (`[Monthly ROI %]`) remains separate and annualizes monthly net profit as `DIVIDE([Net Profit], [Average Company Capital], 0) * 12`.
- Desktop validation still required: open `Paper Financial Report.pbip`, refresh, and check the ROI card/Monthly ROI chart against SAP period locks and month-end capital snapshots.

## Measure / helper table hygiene (2026-03)
- Removed **unused** calculated tables **`Dim_ReportRows`** and **`Dim_KPIRows`** (no live report visuals referenced them; they only fed removed statement/KPI helper measures).
- Pruned **~25 measures** that had **no report binding** and **no remaining in-model references** (e.g. duplicate branch/location counters, unused LY/YTD-LY helpers that only served the removed statement matrix pattern, `Sales Quantity*`, safe-card aliases, `Leverage Ratio`, `Operating Margin %`, `Net Margin %` base). **`Net Revenue LY`** is **kept** — referenced from **`generalLedgerEntries`** (`RevenueVariance`).
- **`Opex by Account`** now aliases **`[Opex by Department]`** (identical logic; one maintenance path).
- **Open in Desktop after pull** to confirm the model loads and no stale culture metadata warnings appear; `en-US` may still list removed measure names until Desktop re-synchronizes.

## Sales — item business type (Revenue Insights)
- **Revenue Insights** revenue-by-segment bar chart uses **`Fact_SalesDetail[Item Business Type]`** on the category axis and **`Sales Revenue`** in values.
- **`Item Business Type`** is loaded in the **same ODBC query** as the fact: `COALESCE(NULLIF(TRIM(T3."U_BusinessType"), ''), 'Unassigned')` from **`CANON.OITM`** (alias `T3`, already joined on `ItemCode`). This is the **item master user-defined field** for business type (B2B/B2C-style classification maintained in SAP).
- If refresh fails with an unknown column error, confirm the **technical UDF name** on `OITM` in the company database (Customization → UDF may show a different `U_...` code than `U_BusinessType`) and update the SQL in `Fact_SalesDetail.tmdl` only for that identifier.
- Do not reintroduce a **disconnected** mapping table on the chart axis for this visual; source-of-truth for the bucket is **SAP item master**, not a static `DATATABLE` map in the model.

## PAPERENTITY — Balance sheet: largest accounts + SAP equity check (2026-04-11)

- The **Balance sheet** page keeps the **Canon-style** visual **`Largest Balance Sheet Accounts`**: **`Dim_BSAccount[AcctName]`** on the category axis and **`[BS Balance Display]`** (all balance-sheet accounts by name, sorted by balance). This is the **detailed per-account** view; it matches the **Canon** page pattern.
- A **second** compact bar chart (**`SAP equity check (capital base / 3000500 / FY P&L)`**, visual id `c9d1e5c40b1f4c2fa010`) sits **under** the largest-accounts bar. It uses calculated table **`SAP_BS_Line`** plus **`SAP BS Line Amount`** so **capital base**, **retained earnings**, and **profit period (FY P&L net)** can be reconciled to SAP without replacing the main account list.
- **Maintenance:** SAP account codes and the FY rule live in **`_Measures.tmdl`** / **`SAP_BS_Line.tmdl`**. If fiscal year is not calendar Jan–Dec, replace the `DATE ( YEAR ( AsOf ), 1, 1 )` start in **`SAP BS Profit Period PL`** with the company’s fiscal-year start rule.
- **Validate in Desktop:** Reopen `Paper Financial Report.pbip`, refresh, set **`Dim_Date`** to the same as-of as SAP, and compare the small three-bar visual to SAP **Capital**, **Retained earnings**, and **Profit period**.

## PAPERENTITY — Balance sheet: as-of behavior (2026-04-18)

- `[BS Amount]` was changed from a plain `SUM ( Fact_BalanceSheet[Amount] )` to a **point-in-time / as-of** pattern that ignores the lower bound of the date slicers and walks the GL up to the maximum date in the current filter context:

  ```dax
  BS Amount =
  VAR MaxDate = MAX ( 'Dim_Date'[Date] )
  RETURN
      CALCULATE (
          SUM ( 'Fact_BalanceSheet'[Amount] ),
          REMOVEFILTERS ( 'Dim_Date' ),
          'Fact_BalanceSheet'[PostingDate] <= MaxDate
      )
  ```

- **Critical detail — filter on Fact's PostingDate, not Dim_Date.** `Dim_Date` is bounded (`CALENDAR(DATE(2024,1,1), …)` — see `Dim_Date.tmdl`), but `Fact_BalanceSheet` has historical postings that pre-date 2024. Those Fact rows have **no matching `Dim_Date` row** and are dropped by the relationship if the filter is expressed on `Dim_Date[Date]`. First attempt used `'Dim_Date'[Date] <= MaxDate` and produced the symptom: only the ~16 accounts with postings in the 2024+ range showed on the **Largest BS Accounts** bar after picking Year=2026. Fixed by filtering directly on `'Fact_BalanceSheet'[PostingDate] <= MaxDate`, which bypasses the Dim_Date range and picks up all historical postings.
- **Why:** The original measure summed only the **movements within** the selected date slice (e.g. picking March 2026 produced March's delta, not the balance as of March 31). This made every Balance sheet KPI and bar chart disagree with SAP, which always reports balances cumulatively from inception to a cutoff.
- **Ripple:** All downstream BS measures (`BS Balance Display`, `Total Assets`, `Total Liabilities`, `Total Equity`, `Equity Ratio`, `Leverage Ratio`, all `Total ... Card Display` cards) chain through `[BS Amount]`, so they automatically inherit the as-of behavior — no per-visual edits.
- **Non-date filters preserved.** Branch, Department, SalesType, BSSection, AcctName all still narrow the result correctly because only `Dim_Date` is removed.
- **Synthetic `_PP` (Profit Period) rows** still work — they're posted on `LAST_DAY` per month, so they're picked up correctly as the cutoff advances.
- **Quarter slicer + "Quarter" label removed from the BS page** (`slicer_quarter`, `label_quarter` under page `5e7c9a1d4b3f6e8c2a10`). Year + Month are sufficient for an as-of cutoff and avoid the confusing "Q2 only" interpretation. The shared left-rail Quarter slicer is still present on the other pages (P&L, Sales, Operating expenses, Financial summary, ROI).

## PAPERENTITY — Balance sheet: SAP-style single date slicer + per-day `_PP` (2026-04-18, follow-up)

- **Slicer rail rebuilt to mirror SAP's Balance Sheet UX.** SAP B1's BS asks for a single "Posting Date To" cutoff and renders a snapshot at that date. To match that exactly, the BS-page Year + Month slicers were collapsed into **one date slicer in `'Before'` mode** bound to `Dim_Date[Date]`:
  - Visual `a9d1e5c40b1f4c2fa001` (was Year, mode `Dropdown`, projection `Dim_Date[Year]`) → **As-of date slicer**, mode `'Before'`, projection `Dim_Date[Date]`, format `yyyy-MM-dd`. Position unchanged (x=24, y=140, h=32, w=136).
  - `label_year` text changed from `Year` → `As of`.
  - Old Month slicer `a9d1e5c40b1f4c2fa002` and `label_month` deleted (folders removed).
  - Result: a single calendar input that drives `MAX(Dim_Date[Date])` directly into `[BS Amount]`'s as-of cutoff, with no implicit lower bound and no month-grain rounding. Default (no selection) shows snapshot at end of `Dim_Date` calendar = 31 Dec of `YEAR(TODAY())`.
- **`Fact_BalanceSheet` Power Query overhauled for the `_PP` (Profit Period) block.** Two long-standing bugs were fixed so the BS balances at any cutoff inside the currently-open fiscal year, not just at month-ends within the calendar year:
  1. **Per-day stamping.** `LAST_DAY(MIN(T0."RefDate"))` → `T0."RefDate"`, and the `GROUP BY YEAR, MONTH` collapsed into `GROUP BY T0."RefDate"`. `_PP` rows now exist on every posting date with P&L activity, so a mid-month cutoff (e.g. 15 Apr) picks up the month-to-date P&L exactly.
  2. **Dynamic open-FY filter.** The static `AND YEAR(T0."RefDate") = YEAR(CURRENT_DATE)` predicate was replaced with an SAP-aware subquery that detects the latest closed fiscal year via the period-end-closing journals (`OJDT.TransType = -3` posting to `JDT1.Account = '3000500'` Retained Earnings):

     ```sql
     AND YEAR(T0."RefDate") > (
       SELECT COALESCE(MAX(YEAR(T0i."RefDate") - 1), 0)
       FROM "PAPERENTITY"."OJDT" T0i
       INNER JOIN "PAPERENTITY"."JDT1" T1i ON T0i."TransId" = T1i."TransId"
       WHERE T0i."TransType" = -3 AND T1i."Account" = '3000500'
     )
     ```

     SAP B1's PEC for FY N posts on 1 Jan of FY N+1 with `TransType = -3`, debiting/crediting all P&L accounts and routing the net through the Clearing account into Retained Earnings. So `MAX(YEAR(PEC.RefDate)) - 1` = latest fully-closed FY; the condition emits `_PP` rows only for FYs strictly above that. Today (2026-04-18, PEC for FY25 already booked on 2026-01-01), `_PP` is emitted for 2026 only — matching SAP's runtime behavior.
- **Verified against SAP at four cutoffs.** New `Fact_BalanceSheet` SQL run end-to-end via DSN `HANA_B1`:

  | Cutoff      | Assets        | Liabilities    | Equity (incl. `_PP`) | Σ |
  | ----------- | ------------- | -------------- | -------------------- | --- |
  | 2026-12-31  | 4,539,178,295 | −1,757,027,718 | −2,782,150,577       | 0 |
  | 2026-04-15  | 4,539,178,295 | −1,757,027,718 | −2,782,150,577       | 0 |
  | 2026-03-31  | 4,538,392,742 | −1,757,027,718 | −2,781,365,024       | 0 |
  | 2025-12-31  | 4,508,270,579 | −1,728,741,507 | −2,468,268,480       | +311,260,592 |

  The 2025-12-31 residual equals exactly FY25 P&L. Expected and documented: at that historical moment FY25 was open and PP would have shown −311M, but PEC for FY25 has since been posted (1 Jan 2026), so `last_closed_fy` is now 2025 and the per-day `_PP` filter excludes 2025. Pre-baked `_PP` cannot be cutoff-aware about closure history without more model work (next bullet).
- **Known limit — historical cutoffs that span post-cutoff closures.** If a user picks a date in a fiscal year that was open at that moment but has since been closed, the BS will be off by exactly that year's P&L net. For PAPERENTITY this only affects 2025-and-earlier cutoffs. The fix when (if) historical accuracy matters is to drop synthetic `_PP` rows entirely and compute Profit Period as a DAX measure that consults a small `Fact_PEC` lookup (FY → ClosingPostDate) to determine the open FY at the cutoff. Out of scope for this iteration; current setup is correct for all "as of today / month-end this year" workflows.
- **Hardcoded for PAPERENTITY.** The PEC subquery hardcodes `'3000500'` (Retained Earnings GL) and `TransType = -3`. CANON's PEC GL and TransType may differ; before porting this fix to `Reports/Finance/Companies/CANON/Canon Financial Report/...`, run the same diagnostic SQL on `CANON.OJDT` to confirm the PEC pattern, then mirror the change.

## PAPERENTITY — Balance sheet: cutoff-aware `_PP` via PEC reversal rows (2026-04-18, second follow-up)

The previous "per-day `_PP` for current-FY only" implementation matched SAP at the latest cutoffs but failed for **historical cutoffs that span a post-cutoff closure** (the user's screenshot pair: cutoff 2025-08-31, missing FY25 YTD profit period of IQD 335,472,659.87). Root cause was that the open-FY filter was decided once, at refresh time, against `MAX(YEAR(PEC.RefDate)) − 1`, so only FY26 rows were emitted into `_PP` at all — every cutoff in 2025 inherited zero `_PP`.

This was fixed entirely in `Fact_BalanceSheet`'s Power Query M, with no DAX, relationship, or visual changes. The `_PP` UNION block was replaced by **two SQL sub-blocks** that together net to "open-FY P&L at the chosen cutoff" for *any* historical date, by relying on the same SAP PEC convention to do the cancellation as data instead of as a refresh-time filter:

1. **Per-day `_PP` rows for every P&L posting date in history** (no year filter):

   ```sql
   SELECT T0."RefDate" AS "PostingDate", …, '_PP' AS "AcctCode", 'Profit Period' AS "AcctName",
          3 AS "GroupMask", 'Equity' AS "BSSection",
          SUM(COALESCE(T1."Debit",0) - COALESCE(T1."Credit",0)) AS "Amount",
          NULL, NULL, NULL, NULL, NULL, NULL  -- branch/sales-type/dept dims intentionally NULL
   FROM "PAPERENTITY"."OJDT" T0
   INNER JOIN "PAPERENTITY"."JDT1" T1 ON T0."TransId" = T1."TransId"
   INNER JOIN "PAPERENTITY"."OACT" T2 ON T1."Account" = T2."AcctCode"
   WHERE T2."GroupMask" IN (4,5,6,7,8) AND T0."TransType" >= 0
   GROUP BY T0."RefDate"
   ```

2. **One PEC-reversal row per closed FY**, dated at that FY's PEC posting date, with `Amount = −(FY P&L)`:

   ```sql
   SELECT PEC."PEC_DATE" AS "PostingDate", …, '_PP', 'Profit Period', 3, 'Equity',
          -FY_PL."PL" AS "Amount", NULL × 6
   FROM (per-FY P&L net) FY_PL
   INNER JOIN (per-FY MIN(PEC RefDate) for TransType=-3, Account='3000500') PEC
     ON FY_PL."FY" = PEC."FY"
   ```

At any cutoff `X`, cumulative `SUM(_PP.Amount) WHERE PostingDate ≤ X` equals exactly the YTD P&L of the FY that was open at `X`, because every closed FY's per-day rows are perfectly cancelled by its own reversal row (which lives on the PEC posting date, i.e. the first day of the next FY). End-to-end SAP reconciliation:

| Cutoff      | Assets        | Liabilities    | Equity (incl. `_PP`) | Σ | `_PP` net | Open FY YTD (SAP) |
| ----------- | ------------- | -------------- | -------------------- | --- | --- | --- |
| 2024-12-31  | 5,206,342,493 | −3,255,721,653 | −1,950,620,840       | 0 | +24,335,001 | FY24 YTD = +24.3M |
| 2025-08-31  | 7,716,291,928 | −4,912,550,788 | −2,803,741,140       | 0 | −335,472,660 | FY25 YTD Aug = +335.5M (loss → equity sign +) ✅ matches SAP |
| 2025-12-31  | 4,508,270,579 | −1,728,741,507 | −2,779,529,072       | 0 | −311,260,592 | FY25 full = +311.3M loss |
| 2026-03-31  | 4,538,392,742 | −1,757,027,718 | −2,781,365,024       | 0 | −1,835,952 | FY26 YTD Q1 |
| 2026-04-15  | 4,539,178,295 | −1,757,027,718 | −2,782,150,577       | 0 | −2,621,506 | FY26 YTD = matches SAP |
| 2026-12-31  | 4,539,178,295 | −1,757,027,718 | −2,782,150,577       | 0 | −2,621,506 | (no future activity) |

All six cutoffs balance to 0 — the Σ residual that previously appeared at 2025-12-31 (the documented "historical limit") is gone. Total row count post-rebuild: 2,246. Sum of all `Amount` from inception = 0.00.

Side benefits and constraints:

- **Dimensions on `_PP` are NULL by design.** A SAP balance sheet is not a per-branch / per-department concept; collapsing dims to NULL keeps both blocks (P&L row and reversal row) net cleanly under any branch/sales-type/dept filter that doesn't exist on the BS page. The current PAPERENTITY BS page has only the `As of` date slicer (no other dim filters), so NULL dims on `_PP` never get stripped out by an active filter. If a future BS page adds a branch slicer, this design assumption breaks and `_PP` would silently disappear under that slicer — at that point either drop the new slicer or migrate `_PP` to a DAX measure.
- **No DAX, model, or visual changes.** `[BS Amount]`, `[BS Balance Display]`, `[Total Equity]`, `Dim_BSAccount`, and the BS-page visuals are all untouched. Risk surface is limited to the one `Fact_BalanceSheet` partition source.
- **Still hardcoded for PAPERENTITY's PEC pattern** (`TransType = -3`, `Account = '3000500'`). Before porting to CANON, re-validate with the same SAP query (`SELECT YEAR(RefDate)-1, MIN(RefDate) FROM OJDT JOIN JDT1 WHERE TransType=-3 AND Account=…`) — if CANON's RE GL is different, swap the literal.
- **Refresh dependency unchanged.** Reversal rows appear automatically the moment SAP posts a new PEC; no manual intervention needed at year-end. Just refresh the dataset after PEC.

The previous note's "Known limit — historical cutoffs that span post-cutoff closures" is now resolved by this approach. Leaving the older note in place above as historical context for why this redesign happened.
- **Verified against SAP (PAPERENTITY, 2026-04-15) — section totals.** Assets 4,539,178,295 IQD, Liabilities −1,757,027,718 IQD, Equity −2,779,529,072 IQD; residual +2,621,506 = YTD 2026 P&L (loss); BS balances to exactly 0 once `_PP` is added. Top-15 accounts and contra-asset (`1700022 Furniture Accumulated Depreciation = −2,596,216`) all reconcile.
- **Verified expected post-fix bar count.** Chart of accounts has 72 BS accounts, but only 26 have ever posted; only 18 have non-zero balance at 2026-04-15. With the synthetic `_PP` Equity row, the **Largest Accounts** bar should show ~19 bars at typical 2026 cutoffs (up from 16 with the old broken measure: 15 with 2026 movements + 1 `_PP`).

## CANON — Balance sheet ported to PAPERENTITY pattern (2026-04-18)

The full PAPERENTITY Balance-sheet rebuild (per-day `_PP` + PEC-reversal rows + as-of `[BS Amount]` + single "As of" date slicer) was ported to `Reports/Finance/Companies/CANON/Canon Financial Report/`. SAP-validated; all six cutoffs balance to zero.

**Data layer (`Canon Financial Report.SemanticModel/definition/tables/Fact_BalanceSheet.tmdl`):** Replaced the old `_PP` UNION block (per-month, current-FY-only, with branch/sales-type/dept dims) with the same two SQL sub-blocks used in PAPERENTITY:
1. Per-day P&L net for **all** posting dates (no year filter), `WHERE T2."GroupMask" IN (4,5,6,7,8) AND T0."TransType" >= 0`, dims set to `NULL`.
2. PEC-reversal rows joined on `OJDT.TransType = -3` posting to `JDT1.Account = '310101010107'` (CANON's Retained Earnings GL — verified via SAP, see below).

**Measure (`_Measures.tmdl`):** `[BS Amount]` rewritten identically to PAPERENTITY's as-of form (`MAX(Dim_Date[Date])`, `REMOVEFILTERS('Dim_Date')`, filter `Fact_BalanceSheet[PostingDate] <= MaxDate`).

**BS page slicer rail (`Canon Financial Report.Report/.../pages/5e7c9a1d4b3f6e8c2a10/`):** Collapsed to a single "As of" date slicer mirroring SAP B1's "Posting Date To" UX:
- Visual `a9d1e5c40b1f4c2fa001` (was Year `Dropdown` on `Dim_Date[Year]`) → date slicer in `'Before'` mode bound to `Dim_Date[Date]`, with a `general.filter` ComparisonKind=3 + `datetime'2026-04-01T00:00:00'` literal so Desktop persists the cutoff and renders "Before" instead of "Between".
- `label_year` text `Year` → `As of`.
- **Deleted:** Month slicer `a9d1e5c40b1f4c2fa002`, Quarter slicer `slicer_quarter`, Location slicer `a9d1e5c40b1f4c2fa003`, Department slicer `a9d1e5c40b1f4c2fa004`, Sales Type slicer `a9d1e5c40b1f4c2fa005`, plus their five labels (`label_month`, `label_quarter`, `label_location`, `label_department`, `label_sales_type`). All 38 stale `visualInteractions` entries pointing at those eight removed sources were also stripped from `page.json`, leaving only the 8 interactions from `a9d1e5c40b1f4c2fa001` (As-of date) to the four KPI cards (`b9d1e5c40b1f4c2fa001/2/3/4`), the Largest Accounts / Mix / Sections charts (`c9d1e5c40b1f4c2fa001/2/3`), and the BS Balance card (`d9d1e5c40b1f4c2fa005`).

**The dim slicers were dropped intentionally (Path A).** The new `_PP` row carries `NULL` for branch/sales-type/dept; if the user filtered on any of those dims, the entire `_PP` Equity row would be silently excluded and the BS would no longer balance. Dropping the three dim slicers makes CANON's BS page exactly match SAP B1's BS UX (single posting-date cutoff, no per-branch / per-dept partition) and matches PAPERENTITY's final shape. If a future requirement needs branch-level BS reporting, migrate `_PP` to a DAX measure first; do not re-add the dim slicers with the current data shape.

**CANON's PEC pattern as of 2026-04-18.** SAP returned **zero** rows for `WHERE TransType = -3` against `CANON.OJDT`/`JDT1` — CANON has not yet executed its first Period-End Closing. RE GL `310101010107` was confirmed via the SAP chart of accounts as the closure target. The PEC-reversal sub-block produces zero rows today (the `INNER JOIN` to `PEC` finds no matches), but the Power Query is **already correct** for the moment SAP posts CANON's first PEC: the next refresh will automatically emit the FY24 (or whichever is the first closed year) reversal row and the BS will continue to balance at all historical cutoffs without any code change. Until then, CANON is in the equivalent of PAPERENTITY's "everything is the open FY" regime, and the per-day sub-block alone correctly reflects cumulative P&L from inception → cutoff for every date.

**SAP-verified reconciliation (CANON, all six cutoffs Σ = 0 IQD):**

| Cutoff      | Assets         | Liabilities    | Equity (incl. `_PP`) | Σ |
| ----------- | -------------- | -------------- | -------------------- | --- |
| 2025-12-31  | 14,541,385,866 | −2,113,000,760 | −12,428,385,106      | 0 |
| 2026-01-31  | 13,982,578,381 | −1,558,530,812 | −12,424,047,569      | 0 |
| 2026-02-28  | 13,262,143,050 |   −872,732,843 | −12,389,410,207      | 0 |
| 2026-03-31  | 13,392,229,628 |   −990,968,877 | −12,401,260,751      | 0 |
| 2026-04-15  | 13,741,959,440 | −1,260,603,675 | −12,481,355,765      | 0 |
| 2026-12-31  | 13,749,052,836 | −1,260,829,925 | −12,488,222,911      | 0 |

**Validation in Desktop:** open `Canon Financial Report.pbip`, refresh, change the **As of** date on the BS page, and confirm Total Assets + Total Liabilities + Total Equity (with the synthetic `Profit Period` row) sum to 0 at any cutoff. Hide the "BS Amount" card column for `_PP` if the section total is preferred to the per-account row breakdown — same as PAPERENTITY.

## PBIP / Semantic Handling Notes
- Visual JSON changes are often the fastest safe route for layout and binding repairs.
- Slicer polish can require structural report changes, not just font-size changes.
- The approved shared slicer pattern is:
- external text label
- hidden native slicer header
- white dropdown box with subtle `#DCE5E0` border
- compact height around `32`
- no extra panel/chrome unless the page truly needs it
- If a Power BI Desktop load error appears after a semantic-model change, treat it as higher priority than surface-level page polish.
- When a semantic issue makes the PBIP unstable, back out risky model patterns before continuing visual cleanup.
- Stale benchmark metadata frequently survives in `queryRef`, `metadata`, and visual-level filters even when the `Entity` binding has already been corrected. `Commitment Report` and `Actual vs Budget` both demonstrated this.
- Red warning icons in the right-side data pane often come from a small set of foundational helper tables. Clean the shared foundations first; downstream warnings may disappear without touching every visual.
- For compact KPI cards, report-side `labelPrecision` and `labelDisplayUnits` are not always enough to change the rendered `bn / M` text. If Power BI keeps ignoring those settings, use dedicated numeric `... Card Display` measures with fixed scaling and bind only the repeated top money cards to them.
- The older helper `... KPI` / `... KPI Plain` layer was retired from `_Measures.tmdl` because it leaked internal captions in live Desktop rendering.
- Card caption text should not rely on helper measure display names. The safer current pattern for the repeated top monetary cards is: bind to a dedicated numeric `... Card Display` measure, hide the built-in label, and set the visible caption through `visualContainerObjects.title`.
- More specifically for these `cardVisual` objects: the current safe combination is `objects.label.show = false`, `objects.value` bound to the scaled numeric display measure, and an explicit title in the standard grey 9pt style. That avoids both the old duplicated-caption leak and the ignored compact-number precision behavior.
- That same structural pattern is now preferred for the remaining top-row percent/count KPI cards too. Even when the card still binds directly to the base measure, use `objects.label.show = false`, render the number via `objects.value`, and set the business caption through `visualContainerObjects.title` so the whole KPI row stays visually unified.
- Power BI may still round scaled card measures back to whole `bn` / `M` units unless the card value object itself also sets `labelDisplayUnits = 0D` and `labelPrecision = 2L`.
- If a page has had visuals deleted during cleanup, recheck `page.json` and remove stale `visualInteractions` entries as part of the same pass. `Actual vs Budget` kept dead interaction references long after the underlying visuals were gone.
- Stale `queryRef` typos can survive even when the bound `Entity` and `Property` are correct. `CashflowPeriod` on the live `Cashflow` page demonstrated that these should be cleaned proactively instead of assuming Power BI will normalize them.
