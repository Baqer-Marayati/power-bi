# Current Status

## Date
- Last updated: March 24, 2026

## Active Project
- `C:\Work\reporting-hub\Reports\Finance\Financial Report`

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
- `Working Capital Health`
- `Profitability Drivers`

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
- `Working Capital Health` still needs Desktop validation for final visual readability because the page shell was repurposed in place from the older `Actual vs Budget` geometry.
- `Profitability Drivers` still needs Desktop validation for label clarity and interaction behavior after replacing cashflow bindings with profitability measures.
- The legacy provisional budget/cashflow compatibility objects still exist in the model, but the two live page narratives are now moving toward AR/AP working-capital analysis and profitability-driver analysis.
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
- Reworked the old `Actual vs Budget` page shell into `Working Capital Health` by rewiring its main cards/slicers/table to AR/AP-oriented objects (`customerLedgerEntries`, `vendorLedgerEntries`, and due-bucket helpers) so the page is no longer centered on the prior budget-compatibility narrative.
- Reworked the old `Cashflow` page shell into `Profitability Drivers` by rewiring core cards and lead charts to stable `_Measures` profitability objects (`Net Revenue`, `Gross Profit`, `Operating Profit`, `Net Profit`, and YTD card-display measures).
- Follow-up visual consistency pass normalized both repurposed pages to the same base canvas system as the first five pages (`1280x960`, `outspacePane` width `195`, and the standard page background color) so the report no longer has oversized trailing white space.
- Added the same grouped top-right branding lockup (Al Jazeera logo + vertical divider + Canon logo) to both `Working Capital Health` and `Profitability Drivers` so header branding now matches the first five pages.
- Updated both repurposed pages' report-header titles/subtitles and KPI-row placement to align more closely with the first-five-page template geometry while preserving the new working-capital and profitability logic direction.
- Removed a stale `BudgetVsActualTable` visual-level filter that was still attached to the `Working Capital Health` AP Outstanding card, which could block values and contribute to inconsistent card behavior.
- Replaced the hidden/off-canvas cleanup strategy with a tiny in-canvas parking strategy for obsolete visuals (`x/y=2`, `1x1`) on both repurposed pages to prevent page-width expansion and layout side effects.
- Tightened `Working Capital Health` top KPI readability by normalizing the narrow AP card widths and reducing top-card value font size from `16D` to `14D` on the first four KPI cards.
- Rewired `Profitability Drivers` top KPI cards to stable display measures (`Net Revenue Card Display`, `Sales Gross Profit YTD Card Display`, `Operating Expenses Card Display`, `Net Margin %`) so cards render with reliable visible values in default context.
- Reverted temporary in-canvas parking of obsolete visuals on `Working Capital Health` and `Profitability Drivers` back to true off-canvas placement after Desktop review showed top-left visual error UI (`See details` / `Fix`) resurfacing.
- Added three non-blank-safe profitability card measures in `_Measures.tmdl`: `Gross Profit Safe Card Display`, `Operating Profit Safe Card Display`, and `Net Profit Safe Card Display` (each uses `COALESCE(...,0)` before scaling) to prevent `--` outputs on top cards.
- Rewired `Profitability Drivers` top KPI cards back to profitability titles (`Gross Profit`, `Operating Profit`, `Net Profit`) using those new safe display measures.
- Updated those safe profitability card measures to raw IQD output (no million scaling) so low-but-real values do not collapse visually to `0M` on `Profitability Drivers`.
- Root-cause correction on `Profitability Drivers`: rewired top profitability KPI cards to the same known-working YTD display-measure family used on `Income Statement` (`Gross Profit YTD Card Display`, `Operating Profit YTD Card Display`, `Net Profit YTD Card Display`) and updated titles accordingly.
- Removed stale carry-over hard filters from both profitability trend charts (`IsInLast6Months_Previous` and `IsInNext6Months`) so chart/card behavior no longer depends on old cashflow helper flags.
- Performed a minimal stale-visual cleanup on the two repurposed pages:
- `Working Capital Health`: removed four off-canvas legacy `BudgetVsActualTable` card visuals and their remaining `visualInteractions` targets, and removed one overlapping top-left filler shape.
- `Profitability Drivers`: removed one orphan textbox/title overlay that sat on top of the main chart area.
- Built an automated screenshot-capture workflow (`scripts/capture-pages.ps1`) that opens the PBIP in Power BI Desktop, clicks each page tab in sequence, and saves per-page PNG screenshots to `Records/screenshots/`. This provides a visual feedback loop for layout validation without manual intervention.
- The script uses Win32 `mouse_event` to click page tabs (Ctrl+PageDown does not navigate pages in PBI Desktop authoring view).
- First successful automated capture confirmed: pages 1-5 render correctly; `Working Capital Health` (page 6) is functional but has sparse right-side layout; `Profitability Drivers` (page 7) still shows "--" for 3 of 4 top KPIs and mostly empty charts, indicating the YTD display measures are not returning data in the default filter context.
- Root-cause fix on `Profitability Drivers`: deleted an off-canvas slicer (`e3072552c68bd01f571a`) that was hardcoded to `Dim_Date.Year = 2021`, which was filtering three of the four top KPI cards to a year with no data. Also deleted three other off-canvas junk visuals (shape, action button, refresh card) and removed all associated `visualInteractions`. Resized the two oversized bottom cards (`Net Margin %` and `Selected Reporting Period`) from ~327px to 140px height.
- Layout and cleanup pass on `Working Capital Health`: deleted 11 off-canvas junk visuals (including a `budgetName` slicer hardcoded to `SAP Derived Budget`), cleaned all stale `visualInteractions`, resized the 581x406 `AR Overdue %` card to 581x145, repositioned the AP/AR due-bucket slicers and labels below it, moved the customer slicer up from Y=667 to Y=502 for a tighter layout, and added label-hidden + border styling to the AR Overdue % card.
- Follow-up refinement per user review: further tightened `Working Capital Health` right-side control alignment (AP/AR due-bucket labels and slicers on one row, customer selector widened and aligned beneath) to remove any residual overlap risk at preview zoom levels; updated `Selected Period Label` measure logic so `Profitability Drivers` period display is clamped to the valid data horizon starting in 2026 (`Jan 2026 - Dec 2026` in current context).
- Hard reset pass on `Working Capital Health`: removed lingering legacy container/background layers (`visualGroup` + old panel shapes) that were masking as overlap/structure issues; then cleaned interactions that still referenced those deleted layers.
- Removed hardcoded default filters from page-6 due-bucket/customer slicers so the page no longer opens in a pre-filtered state that can hide expected records.
- Fixed `DSO` and `DPO` clipping by applying explicit card value styling (hidden built-in labels, fixed 14D value font, top alignment, and slightly taller card height) so values render fully and consistently.
- Hard reset pass on `Profitability Drivers` date logic: added dedicated `2026+` profitability measures and rebound both monthly charts plus margin card to those measures; disabled `showAll` on category axes so pre-2026 empty months are not drawn.
- Validation discipline updated: every targeted page fix now requires a full 7-page screenshot run, then focused review of the target pages from that set before packaging.
- `Income Statement` management block upgraded from a static `pivotTable` to a more visual combo chart (`lineClusteredColumnComboChart`) so the area now shows a clearer management-performance story: columns for `Current Period`, `YTD`, and `YTD LY` by statement row, plus a `Variance %` trend line.
- `Revenue Insights` item-group visual was redesigned to a segment-aware view using the user-provided B2B/B2C product tree logic: added `Dim_ItemSegmentMap` (calculated table) and a new mapped measure `Sales Revenue (Segment Mapped)` with `TREATAS` so the visual now reads as `Revenue by Product Tree (B2B/B2C)` instead of a flat item-group ranking.

## Retained Lessons
- Ask "which artifact is the user actually opening?" before debugging visual differences.
- Prefer Desktop-proven Power BI patterns over speculative JSON-only reconstruction.
- When the user makes approved refinements directly in Desktop, preserve that Desktop result as the new visual baseline.
- Treat packaging, integrity validation, and project-memory updates as part of done-ness, not post-work extras.
- PBI Desktop's Ctrl+PageDown keyboard shortcut does not work for page tab navigation in authoring view; mouse clicks on the tab strip are the only reliable method for automated page switching.
- Automated screenshot capture via Win32 API is a viable and safe alternative to Power Automate Desktop for the visual feedback loop; no PAD flow was needed.
- If a page appears unchanged to the user, first verify the review artifact timestamp and rebuild `Financial Report - ready.zip` before making additional edits.
- For repurposed PBIP pages, visual overlap symptoms are often caused by stale grouping/container visuals and slicer defaults, not only by `x/y` positions of visible visuals.
