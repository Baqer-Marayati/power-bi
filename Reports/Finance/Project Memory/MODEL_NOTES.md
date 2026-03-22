# Model Notes

## Main Semantic Model
- `/Users/baqer/Dropbox/Work/PowerBI/Reporting Hub/Reports/Finance/Financial Report/Financial Report.SemanticModel/definition/model.tmdl`

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
- `Dim_ReportRows`
- `Dim_KPIRows`
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

## Currency Notes
- The report should be standardized to Iraqi dinar presentation.
- Benchmark-derived pages still needed explicit format-string conversion because they came in with dollar formatting.
- IQD formatting can cause clipping or crowding on cards that were originally sized for shorter benchmark value strings.

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
