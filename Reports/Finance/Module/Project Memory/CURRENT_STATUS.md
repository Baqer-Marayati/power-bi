# Current Status

## Date

- Last updated: April 11, 2026

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

## Current Validation Focus

- Reopen the active company PBIPs in Power BI Desktop after meaningful model or visual changes.
- Recheck any remaining semantic warnings on compatibility-heavy tables such as `generalLedgerEntries` and `accounts`.
- Validate page behavior and interactions on the active 10-page shell, especially after changes to shared KPI rows, slicer rails, or transferred AR/AP/cash pages.
- Keep packaging, review artifacts, and screenshot capture aligned with the actual workflow documented in `DECISIONS.md` and `Module/scripts/README.md`.

## Where To Look Next

- `DECISIONS.md` for durable project direction and company-specific constraints.
- `MODEL_NOTES.md` for semantic-model facts, caveats, and known technical risks.
- `NEXT_STEPS.md` for the next recommended validation and build sequence.
