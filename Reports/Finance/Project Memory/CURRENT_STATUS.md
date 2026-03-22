# Current Status

## Date
- Last updated: March 22, 2026

## Active Project
- `/Users/baqer/Dropbox/Work/PowerBI/Reporting Hub/Reports/Finance/Financial Report`

## Current State
The project is a hybrid:
- report shell and page language come from `Design Benchmarks/Sample 2`
- supported logic is wired to the active SAP-backed semantic model
- unsupported benchmark pages are being repaired in place, not removed

## Live Pages
The active report shell now contains only these 7 pages:
- `Executive Overview`
- `Income Statement`
- `Revenue Insights`
- `Cost Structure`
- `Balance Sheet`
- `Actual vs Budget`
- `Cashflow`

## Removed From Active Report
These pages were physically removed from the report definition during cleanup so the file stays sharper and lighter:
- `Financial Details`
- `Performance Details`
- `Accounts Receivable`
- `Accounts Payable`
- `AR Invoice Details`
- `AP Invoice Details`
- `Commitment Report`
- `Profit and Loss`

## What Was Recently Done
- Moved the finance project into `Reports/Finance` as part of a broader portfolio-style reporting-hub restructure so future department reports can live beside it cleanly without mixing active finance work with cross-report assets.
- Added a root `AGENTS.md` entrypoint plus `docs/agent-manual.md` so outside AI tools or future agents can recover the repo structure, read order, and documentation split without depending on prior chat history.
- Added `docs/foundation.md` as the main high-signal startup file for environment/tooling context, GitHub wiring, skills location, packaging workflow, and automation status.
- Added compatibility tables and measures so broken Sample 2 pages could at least bind to valid semantic objects.
- Removed duplicate-measure load blockers that were preventing the PBIP from opening.
- Cleared leftover benchmark drillthrough filters from `AR Invoice Details` and `AP Invoice Details`.
- Repointed budget slicers from dead placeholder values to the current compatibility budget label.
- Reworked several AP/AR visuals to stop depending on disconnected helper tables.
- Replaced AP/AR bottom-right trend visuals with simpler working cards to avoid invalid helper-date dependencies.
- Converted report-side currency formats from dollar-style strings to IQD presentation.
- Removed `DateTableAccountReceivables` and `DateTableAccountPayables` from `model.tmdl` after rewiring away from them.
- Applied a report-wide polish pass to slicers and KPI cards so dropdown headers fit more cleanly and narrow IQD cards are less likely to clip text.
- Reworked the repeated five-slicer rail on the main working pages to a cleaner pattern with separate text labels above the dropdown boxes, matching the preferred no-background slicer-title direction.
- Standardized the repeated five-slicer rail on the main working pages to a consistent order and spacing: `Year`, `Month`, `Location`, `Department`, `Sales Type`, with separate labels above the dropdown boxes.
- Removed the `vendorLedgerEntries.CashonHand` compatibility alias and rewired the affected cards directly to `bankAccountLedgerEntries.Cashflow_endingCashInHand` to reduce a likely AP/cashflow circular dependency path.
- Performed a safety-first cleanup pass that removed four unreferenced semantic-model table files left on disk from earlier iterations: `DateTableAccountReceivables`, `DateTableAccountPayables`, `Dim_Customer`, and `Dim_Item`.
- Removed local junk files that should not be treated as project assets: `.DS_Store` files and the semantic-model `.pbi/cache.abf`.
- Removed additional local-only PBIP metadata that does not define the report itself: Finder junk files and the semantic-model `.pbi` editor/local settings files.
- Tightened `Dim_Date` from an overly wide standalone calendar (`2018-2035`) to a rolling current-year-bounded range so YTD measures stop evaluating against empty future years while still avoiding the prior `Fact_SalesDetail` cycle.
- Restored missing helper columns on `DateTablePreviousCashflow`, `DateTableProjectedCashflow`, and `DateTableCashflowAPAR` so cashflow visuals no longer point at non-existent boolean filter fields.
- Corrected stale report metadata on `Commitment Report`, including a table visual that still referenced `CommittmentDocumentTable` instead of `CommitmentDocumentTable`.
- Removed a dead `ShowThisBar` filter from an `Actual vs Budget` visual; the page was still carrying a filter against a measure that no longer exists in the semantic model.
- Cleared a stale placeholder `Select dimension` slicer filter from `Actual vs Budget` and corrected a stale `MergeDimensionSlicer` queryRef on `Commitment Report`.
- Aligned the local month helper table used by `Profit and Loss` formatting metadata so it now stores month-name strings instead of month numbers.
- Reworked several warning-prone helper tables to use more stable calculated-table patterns:
- `DateTable` no longer derives its range from `generalLedgerEntries`
- `glBudgetEntries` now derives directly from `Fact_PNL` instead of from `generalLedgerEntries`
- `accountingPeriods` and `Last Refresh Date` no longer use dynamic `DATATABLE(...)` rows
- `CommitmentDocumentTable` now uses a direct `SELECTCOLUMNS` projection instead of an unnecessary one-branch `UNION`
- Qualified a few cross-table measure references explicitly in `glBudgetEntries` and `accounts` to reduce compatibility-model ambiguity.
- Flattened the last known warning-prone compatibility chains:
- `generalLedgerEntries` budget-facing measures now derive directly from `Fact_PNL` instead of calling back into `glBudgetEntries`
- `accounts[GLAccountIsRowVisible]` now evaluates directly from `Fact_PNL` and `purchaseLines` instead of routing through `BudgetVsActualTable`
- `accounts` itself no longer derives from `generalLedgerEntries`; it now builds directly from `Fact_PNL` plus `purchaseLines` so it does not inherit upstream compatibility-table warnings.
- `generalLedgerEntries` no longer carries the unused volatile `TodayLocal` measure, and its helper date flags now anchor to the latest posted SAP date instead of `TODAY()`.
- Applied the approved external-label slicer pattern to the remaining older sidebar/top-right slicer areas on `Commitment Report`, `Actual vs Budget`, and `Profit and Loss` so those pages use the same clean label-above-dropdown treatment as the main working pages.
- Simplified `accounts[GLAccountIsRowVisible]` to a low-risk compatibility filter that only checks for a nonblank display name, removing its remaining cross-table dependency chain.
- Restored missing helper objects on `generalLedgerEntries` that the report still referenced:
- numeric variance/budget percentage measures now use proper percentage `formatString` values instead of text-returning `FORMAT(...)`
- added `PercentRevenueVarianceColorFormat`, `PercentExpenseVarianceColorFormat`, and `PercentCOGSVarianceColorFormat`
- restored the missing compatibility column `'Legend Label'` used by Profit and Loss visual styling metadata
- Normalized the top KPI card typography across all pages with the main left sidebar:
- reduced primary value size from `22D` to `20D`
- switched top-card value and category typography to standard `Segoe UI` so IQD glyphs render with more breathing room and less clipping risk
- Strengthened the top KPI card polish on all main-sidebar pages after the first typography pass was still too tight:
- increased top-row KPI card height from `86` to `92`
- switched KPI value text to `Tahoma` at `18D`, which is safer for mixed Latin + Arabic currency glyph rendering
- Reduced the report shell to the approved 7-page set by removing the non-kept page folders from the report definition and updating `pages.json` to the new visible order.
- Removed no-longer-needed report/model artifacts tied only to deleted pages:
- `CommitmentDocumentTable`
- `DimensionCodeTable`
- `DimensionCode1Slicer`
- `DimensionCode2Slicer`
- `LocalDateTable_3a85b0bc-9ebc-4b88-9375-1f1e21803837`
- `Dim_CostCenter`
- the `Fact_PNL` -> `Dim_CostCenter` relationship
- Restored the small due-category helper tables after verification showed that `customerLedgerEntries` and `vendorLedgerEntries` still reference them internally, even though the AR/AP pages themselves were removed.

## What Is Still Broken
- `Actual vs Budget` and `Cashflow` are still compatibility-heavy, but the most obvious stale report-definition issues were removed in the latest pass.
- `Actual vs Budget` still uses provisional compatibility-budget logic rather than a confirmed native SAP budget source.
- `Cashflow` still uses compatibility cashflow logic rather than a true SAP bank-movement fact.
- Some semantic-model warning icons may still remain for compatibility tables such as `generalLedgerEntries` and `accounts`; those need to be rechecked after this cleanup pass in Power BI Desktop.
- Most of the remaining file count is intrinsic to PBIP because pages and visuals are stored as separate definition files; the easy dead weight has now been removed.

## Important User Direction
- Keep the current design direction.
- Logic first, styling second.
- Maintain the Sample 2 shell.
- Project Memory must always be updated after meaningful work.

## Latest Pass
- Reduced duplicated visuals across the kept 7-page report:
- `Income Statement` no longer repeats the `Revenue Mix by Sales Type` donut from `Revenue Insights`; it now uses `Gross Profit Mix by Sales Type`.
- `Executive Overview` no longer repeats the department-opex story from `Cost Structure`; the lower-right chart now shows `Net Revenue by Sales Type`.
- Added dedicated KPI display measures for compact top cards so rendered values can show two decimal places reliably without relying on Power BI's compact-number auto-formatting.
- Rewired the top monetary KPI cards on `Executive Overview`, `Income Statement`, `Revenue Insights`, `Cost Structure`, and `Balance Sheet` to those dedicated display measures.
- After review screenshots showed that card-level precision settings alone were still not enough, the core monetary KPI cards were moved to dedicated numeric `... Card Display` measures with fixed `bn` or `M` scaling and two-decimal format strings.
- `Actual vs Budget` lower-right broken chart was replaced with a stable summary card using `GLTableVariancePct` so the page stops throwing an error in that slot.
- `Cashflow` lower-left broken chart was simplified from a fragile series-and-filter configuration to a direct previous-month cashflow chart using `Cashflow_cashGoingIn_previous` and `Cashflow_cashGoingOut_previous`.
- Replaced the remaining live compact-text KPI display measures on the kept 7 pages so they now render explicit IQD values with two decimals instead of `bn / M` shorthand.
- Removed the inert `Dimension` slicer from `Actual vs Budget` and cleaned the page interaction map so it no longer references deleted or non-existent visual IDs.
- Corrected the stale `CashflowPeriod` query reference on the `Cashflow` page so the page definition is internally consistent again.
- Follow-up screenshots confirmed the old helper-based `KPI Plain` strategy was unsafe and leaked internal captions into the first five pages' top monetary cards, so those legacy helper measures were removed from `_Measures.tmdl`.
- The top monetary cards on `Executive Overview`, `Income Statement`, `Revenue Insights`, `Cost Structure`, and `Balance Sheet` now use an explicit title plus a hidden built-in label, with the card value bound to dedicated numeric `... Card Display` measures.
- Those `... Card Display` measures are limited to the repeated top money cards only. They use fixed unit scaling plus measure-level format strings such as `0.00bn د.ع.‏` or `0.00M د.ع.‏` so the visuals stay valid while still rendering two decimals.
- The remaining top-row percent/count cards on those same five pages were then moved onto the same hidden-label + explicit-title card pattern so the whole KPI row shares one typography system instead of mixing the old label-style cards with the newer monetary cards.
- The intended standard for the first five pages is now: same quiet 9pt title treatment, same non-bold 18pt Tahoma value text, and no visibly heavier percent/count cards sitting next to the monetary cards.
- `Executive Overview`'s `Revenue Mix by Location` donut was adjusted to render all three location labels more reliably.
- Per user direction, `Actual vs Budget` and `Cashflow` are now intentionally left untouched while refinement continues on the first five pages only.
- The report-branding lockup is now implemented on the first five pages only: `Executive Overview`, `Income Statement`, `Revenue Insights`, `Cost Structure`, and `Balance Sheet`.
- The working implementation was learned from the user-edited Desktop PBIP and copied back into the source report rather than being re-guessed from screenshots.
- The safe rendering pattern is now confirmed: two true `image` visuals plus one vertical `shape` divider, grouped together in the top-right header zone and backed by registered image resources in `report.json`.
- The user then made a further manual layout pass directly in Desktop and that edited `Financial Report - ready` file was synced back into the source report as the new approved visual baseline.
- That Desktop pass is now the authoritative source for the current spacing, stretching, and alignment refinements across the core pages, even where it differs from earlier Codex-standardized grid assumptions.
- `Actual vs Budget` and `Cashflow` are still intentionally outside the branding scope for now per user direction.
- Added a dedicated server-transfer export routine:
- generated packages now live in `Exports/Server Packages`
- `./scripts/package-report.sh` rebuilds the stable handoff file `Financial Report - ready.zip`
- those generated zip artifacts are intentionally ignored by Git
- The user reviews report changes from the packaged zip in `Exports/Server Packages`, not from the raw `PBIP` source tree.
- Future validation handoffs should therefore include a fresh run of `./scripts/package-report.sh` whenever a report edit is ready for user inspection.
- A later sync regression corrupted `definition/version.json`, `definition/report.json`, the registered custom theme, shared icon, and both logo image resources with null-byte file contents. Those files were repaired from clean sources, the package was rebuilt, and the report now opens again from the generated zip.
- This repair confirmed that successful packaging alone is not enough as a validation step if registered resources were touched; the packaged contents must also be structurally valid.

## Retained Lessons
- Ask "which artifact is the user actually opening?" before debugging visual differences.
- Prefer Desktop-proven Power BI patterns over speculative JSON-only reconstruction.
- When the user makes approved refinements directly in Desktop, preserve that Desktop result as the new visual baseline.
- Treat packaging, integrity validation, and project-memory updates as part of done-ness, not post-work extras.
