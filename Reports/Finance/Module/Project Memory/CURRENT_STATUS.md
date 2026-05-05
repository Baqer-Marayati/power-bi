# Current Status

## Date

- Last updated: May 5, 2026

## Current Source Of Truth

- Primary company PBIP: `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.pbip`
- Second company PBIP: `Reports/Finance/Companies/PAPERENTITY/Paper Financial Report/Paper Financial Report.pbip`
- Active design benchmark: `Reports/Finance/Module/Design Benchmarks/Sample 2`

## Current State

- Finance is the primary production module in the portfolio.
- The report runs from company-specific PBIPs under `Companies/`, not from the older `Reports/Finance/Financial Report/` path.
- The current shell mixes the Sample 2 design language with SAP-backed semantic model logic and later transferred AR/AP/cash pages.
- Durable rules and historical rationale live in `DECISIONS.md` and `MODEL_NOTES.md`; this file is for the current snapshot and next validation focus.

## Active Pages

The active report shell currently contains these 10 pages in `pages.json` order:
1. `Financial summary`
2. `Profit & loss`
3. `Sales & revenue`
4. `Operating expenses`
5. `Balance sheet`
6. `ROI`
7. `Accounts receivable`
8. `Accounts payable`
9. `Collections`
10. `Cash & bank`

## Stable Current Assumptions

- Finance uses company-specific branding behavior: CANON pages keep the logo lockup; PAPERENTITY pages do not.
- Main left-rail slicers remain a shared system; durable ordering and year-floor rules are recorded in `DECISIONS.md` and `LESSONS.md`.
- `Dim_Date` lower bound is intentionally constrained to 2026 for the main report experience.
- The report should open blank until refresh when the cache-stripped handoff flow is used.
- Desktop-approved PBIP output is stronger evidence than speculative JSON-only assumptions.
- CANON ROI page is Desktop-approved with the locked-period annual ROI card and annualized monthly ROI line chart.

## Current Validation Focus

- **PAPERENTITY:** After pull, open `Paper Financial Report.pbip` and validate the **Balance sheet** page: **Largest Balance Sheet Accounts** (all `Dim_BSAccount` names) plus the **SAP equity check** three-bar visual vs SAP (same as-of date): **3000100**, **3000500**, FY **`[Net Profit]`** through **`MAX(Dim_Date[Date])`**.
- **PAPERENTITY (2026-04-18):** `[BS Amount]` is now an **as-of** measure (cumulative through `MAX(Dim_Date[Date])`, ignoring the date slicer lower bound). Validate by changing the **As of** date on the BS page and confirming **Total Assets**, **Total Liabilities**, **Total Equity**, the **Largest Accounts** bar, and the **Mix** donut all match SAP at the corresponding cutoff date.
- **PAPERENTITY (2026-04-18, follow-up — SAP-style cutoff UI + per-day `_PP`):** The BS page slicer rail was rebuilt to mirror SAP's "Posting Date To" UX. **Year, Month, Quarter slicers all removed**; one **`As of` date slicer** in **`'Before'`** mode bound to **`Dim_Date[Date]`** drives the cutoff (visual `a9d1e5c40b1f4c2fa001` + `label_year`). The shared left-rail Year/Quarter/Month slicers are still present on every other page (P&L, Sales, Operating expenses, Financial summary, ROI). At the same time, `Fact_BalanceSheet`'s **`_PP` (Profit Period) Power Query was overhauled** to (a) emit one row **per posting date** instead of per month-end, and (b) auto-detect the open fiscal year via SAP's period-end-closing journals (`OJDT.TransType = -3` posting to `JDT1.Account = '3000500'`) instead of hardcoding `YEAR = YEAR(CURRENT_DATE)`. **SAP-verified at 4 cutoffs:** 2026-12-31 / 2026-04-15 / 2026-03-31 all balance to 0; 2025-12-31 has a residual = exact FY25 P&L (expected: FY25 was open at that moment but has since been closed by PEC; pre-baked `_PP` cannot be cutoff-aware without further model work — this is documented). **Validate in Desktop:** open `Paper Financial Report.pbip`, refresh, pick a date in the BS `As of` slicer, and confirm Assets ≈ Liabilities + Equity (with `_PP` row) at any 2026 date including mid-month. See **`MODEL_NOTES.md` → "Balance sheet: SAP-style single date slicer + per-day `_PP` (2026-04-18, follow-up)"** for the SQL change and the historical-cutoff caveat.
- **PAPERENTITY (2026-04-18, second follow-up — fully cutoff-aware `_PP` via PEC reversal rows):** The "historical cutoff" caveat above is **resolved**. `Fact_BalanceSheet`'s `_PP` UNION block was rebuilt as **two SQL sub-blocks**: (1) per-day P&L net for *every* posting date in history (no year filter), and (2) one **PEC-reversal row** per closed FY (dated at that FY's PEC posting date, `Amount = −(FY P&L net)`). At any cutoff `X`, every closed FY's per-day rows are exactly cancelled by their own reversal row, leaving only the open FY's YTD as the cumulative `_PP` total. **SAP-verified at 6 cutoffs (2024-12-31, 2025-08-31, 2025-12-31, 2026-03-31, 2026-04-15, 2026-12-31): all balance to Σ = 0**, including the screenshot case 2025-08-31 where `_PP` now correctly shows IQD +335,472,659.87 = SAP's "Profit Period" exactly. No DAX, model, or visual changes; the entire fix is in `Fact_BalanceSheet.tmdl` Power Query. `_PP` rows now carry `NULL` branch/sales-type/dept dims (BS is a corporate concept, page has no dim filters anyway). The previous note's `Validate at 2025-08-31` test now passes — open `Paper Financial Report.pbip`, refresh, set `As of = 2025-08-31`, and confirm Total Equity now includes the `Profit Period` row at +335,472,659.87.
- **CANON (2026-04-18 — Path A port from PAPERENTITY):** The same Balance-sheet rebuild was applied to `Reports/Finance/Companies/CANON/Canon Financial Report/`: `Fact_BalanceSheet` now uses the per-day + PEC-reversal `_PP` SQL pattern (RE GL `310101010107`, `TransType = -3`); `[BS Amount]` rewritten to as-of via `Fact_BalanceSheet[PostingDate] <= MAX(Dim_Date[Date])`; and the BS page slicer rail collapsed to a **single "As of" date slicer** in `'Before'` mode (deleted Year/Month/Quarter slicers + Location/Sales Type/Department dim slicers + all six labels + 38 stale `visualInteractions` entries). CANON has no PEC postings yet (FY24 not closed in SAP), so the reversal sub-block currently emits zero rows — by design, the per-day sub-block alone reconciles. **SAP-verified at 6 cutoffs (2025-12-31, 2026-01-31, 2026-02-28, 2026-03-31, 2026-04-15, 2026-12-31): all balance to Σ = 0**. Validate in Desktop: open `Canon Financial Report.pbip`, refresh, change the **As of** date, and confirm Assets + Liabilities + Equity (with the new `Profit Period` row) net to zero at any cutoff. See **`MODEL_NOTES.md` → "CANON — Balance sheet ported to PAPERENTITY pattern (2026-04-18)"** for the full diff and reconciliation table.
- Reopen the active company PBIPs in Power BI Desktop after meaningful model or visual changes.
- Recheck any remaining semantic warnings on compatibility-heavy tables such as `generalLedgerEntries` and `accounts`.
- Validate page behavior and interactions on the active 10-page shell, especially after changes to shared KPI rows, slicer rails, or transferred AR/AP/cash pages.
- Keep packaging, review artifacts, and screenshot capture aligned with the actual workflow documented in `DECISIONS.md` and `Module/scripts/README.md`.

## Repository Cleanup Guardrails

- Finance now has a machine-readable module manifest at `Reports/Finance/module.manifest.json` with CANON/PAPERENTITY PBIP paths, schema names, expected page metadata, and protected paths.
- Repo structure validation now checks active PBIP paths from `Portfolio/Memory/ACTIVE_FOCUS.md`, `.pbip` report references, `definition.pbir` semantic-model references, `pages.json`, and report-definition JSON parseability.
- Finance archive snapshots under `Reports/Finance/Module/Archive/` are indexed and retained in Git pending an explicit retention decision.
- Finance review now happens directly from the active company PBIP; no `ready.zip` or `package-report.sh` step is required. PBIP remains the development source of truth.

## Where To Look Next

- `DECISIONS.md` for durable project direction and company-specific constraints.
- `MODEL_NOTES.md` for semantic-model facts, caveats, and known technical risks.
- `NEXT_STEPS.md` for the next recommended validation and build sequence.
