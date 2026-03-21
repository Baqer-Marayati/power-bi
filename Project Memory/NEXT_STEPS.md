# Next Steps

## Immediate Priority
1. Reopen the PBIP after each semantic-model pass and capture screenshots of the remaining broken pages.
2. Recheck whether the right-pane warnings for `generalLedgerEntries` and `accounts` are gone after the latest cleanup pass.
3. Preserve the now-working KPI-row pattern on the 5 core finance pages and reuse it consistently instead of reintroducing older card variants.
4. Reopen `Actual vs Budget` and confirm the page is stable after the dimension-slicer removal and interaction cleanup.
5. Reopen `Cashflow` and confirm the corrected `CashflowPeriod` binding and lower-section cards/charts render without stale errors.
6. Keep the root `README`, `docs/`, and GitHub templates aligned with any future project-direction changes so repository onboarding does not drift away from `Project Memory`.
7. Keep GitHub issues current as work advances so later threads can pick up from issue state instead of reconstructing priorities from chat.

## Page-Specific Guidance

### Actual vs Budget
- Treat current budget as compatibility-only.
- Keep the page working, but do not represent the current logic as confirmed SAP budget truth.
- Watch for stale visual-level filters and benchmark placeholder defaults before assuming the measures are wrong.
- The page no longer needs the old `Dimension` slicer in the current live shell unless a future redesign deliberately brings back a dimension-driven comparison visual.

### Cashflow
- Current page can be stabilized with compatibility logic.
- If the business later wants true bank cash movement, build a real SAP-backed bank/cash fact.
- The existing cashflow visuals depend on helper-date flags; keep those helper columns in place unless the visuals are explicitly rewired away from them.
- The `CashflowPeriod` slicer should be treated as suspect if screenshots still show no effect; its report binding was stale and was corrected in the latest pass, but the business logic behind it is still lightweight.

## Future SAP Buildouts
- Native budget domain
- True bank / cash movement fact

## Done Criteria For Future Threads
- PBIP opens cleanly.
- The targeted page renders without broken visuals.
- Currency formatting is consistent in IQD.
- Shared repeated UI systems such as KPI rows and slicer rails remain internally consistent after the change.
- Project Memory is updated before the thread is considered done.
