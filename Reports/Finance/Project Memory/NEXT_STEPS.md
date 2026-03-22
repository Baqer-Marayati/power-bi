# Next Steps

## Immediate Priority
1. Reopen the PBIP after each semantic-model pass and capture screenshots of the remaining broken pages.
2. Recheck whether the right-pane warnings for `generalLedgerEntries` and `accounts` are gone after the latest cleanup pass.
3. Preserve the user-approved Desktop layout baseline on the 5 core finance pages and reuse it consistently instead of reintroducing older card variants or superseded Codex-only geometry assumptions.
4. Preserve the now-confirmed branding pattern on the first five pages: grouped `image + divider shape + image` lockup backed by registered resources in `report.json`.
5. When the user is ready, extend the approved branding direction deliberately to `Actual vs Budget` and `Cashflow` by copying the same Desktop-proven pattern rather than inventing a new one.
6. Reopen `Actual vs Budget` and confirm the page is stable after the dimension-slicer removal and interaction cleanup.
7. Reopen `Cashflow` and confirm the corrected `CashflowPeriod` binding and lower-section cards/charts render without stale errors.
8. Keep the root `README`, `docs/`, and GitHub templates aligned with any future project-direction changes so repository onboarding does not drift away from `Project Memory`.
9. Keep GitHub issues current as work advances so later threads can pick up from issue state instead of reconstructing priorities from chat.
10. Keep `AGENTS.md` and `docs/agent-manual.md` aligned with `Project Memory` whenever the project structure, read order, or operating rules change.
11. Keep `docs/foundation.md` aligned with the real environment whenever GitHub auth state, toolchain assumptions, automation availability, or packaging behavior changes.

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
- If report definitions or registered resources were touched, validate that those files are still structurally readable before packaging.
- Rebuild `Exports/Server Packages/Financial Report - ready.zip` before review.
- If the thread reached a meaningful stable milestone, use judgment and push the source changes to GitHub as part of close-out.
- Project Memory is updated before the thread is considered done.
