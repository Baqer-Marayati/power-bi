# Next Steps

## Immediate Priority
1. Reopen the PBIP after each semantic-model pass and capture screenshots of the remaining broken pages.
2. Recheck whether the right-pane warnings for `generalLedgerEntries` and `accounts` are gone after the latest cleanup pass.
3. Preserve the user-approved Desktop layout baseline on the 5 core finance pages and reuse it consistently instead of reintroducing older card variants or superseded Codex-only geometry assumptions.
4. Preserve the now-confirmed branding pattern on the first five pages: grouped `image + divider shape + image` lockup backed by registered resources in `report.json`.
5. If `Actual vs Budget` or legacy `Cashflow` benchmark pages are revived, extend branding using the same Desktop-proven lockup pattern and document the decision in `DECISIONS.md` / `PAGE_MAP.md`.
6. Reopen `Working Capital Health` and confirm the AR/AP rewires render cleanly (cards, due-bucket slicers, and detail table) without stale compatibility filters.
7. Reopen `Profitability Drivers` and confirm the profitability rewires render cleanly (YTD KPI cards and both monthly trend charts) with expected interactions.
8. Keep the root `README`, `docs/`, and GitHub templates aligned with any future project-direction changes so repository onboarding does not drift away from `Project Memory`.
9. Keep GitHub issues current as work advances so later threads can pick up from issue state instead of reconstructing priorities from chat.
10. Keep `AGENTS.md` and `docs/agent-manual.md` aligned with `Project Memory` whenever the project structure, read order, or operating rules change.
11. Keep `docs/foundation.md` aligned with the real environment whenever GitHub auth state, toolchain assumptions, automation availability, or packaging behavior changes.

## Page-Specific Guidance

### Working Capital Health
- Keep the page centered on AR/AP execution health (outstanding, overdue, and due-bucket behavior), not on compatibility budget storytelling.
- Prefer direct `customerLedgerEntries` / `vendorLedgerEntries` bindings over reintroducing `BudgetVsActualTable` dependencies.
- If any legacy budget-card leftovers still appear in Desktop, continue replacing them with AR/AP-focused visuals in place.

### Profitability Drivers
- Keep the page centered on profitability movement explanations (monthly trend and YTD outcome), not on compatibility cashflow projections.
- Prefer `_Measures` profitability fields and `Dim_Date` monthly grain.
- Validate axis sorting, label clarity, and interactions in Desktop after rewiring from cashflow helper-date tables.

## New Pages Validation
- Open the PBIP in Desktop and refresh to validate the 3 new pages: `Receivables`, `Collections`, `Cash Position`.
- Confirm `ReceivablesFact`, `CollectionsFact`, `CashPositionFact`, and `DimBusinessPartner` tables load cleanly.
- Verify slicer interactions filter the pivot tables and KPI cards correctly on Receivables and Collections pages.
- Verify Cash Position charts and detail table render with correct account balances.
- Fine-tune layout spacing, card typography, and chart formatting in Desktop if needed.
- After validation, rebuild `Exports/Server Packages/Financial Report - ready.zip`.

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
