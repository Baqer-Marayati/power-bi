# Shared DAX patterns

Reusable measure and modeling patterns observed across portfolio reports (especially Finance). Copy and adapt into each module’s `_Measures` or table fragments; keep module-specific names consistent with bound visuals.

## Money KPI cards

**Pattern:** Keep the measure in real IQD. Bind the card to that raw measure. Set the card to fixed Billions and 3 decimal places so a total reads like `5.886bn`. Format strings stay on the measure. The card does not use Auto display units and does not override precision.

**Retired:** `… Card Display` helpers that divided by a million or a billion. They were removed from the Fabric financial and Canon Sales models on 28 August 2026. Do not add them back.

**Still present, and still in use:** Paper Sales binds three of those helpers on KPI cards. Both Data Exchange models still contain the older Finance set. Leave those until a dedicated parity pass. Deleting them would change those reports.

**Reference:** `Portfolio/Shared/Standards/fabric-reports-number-formatting.md` and `Reports/Finance/Module/Project Memory/MODEL_NOTES.md`.

## Time intelligence (YTD / prior year)

**Pattern:** Centralize `Dim_Date` relationships on `PostingDate` (or the module’s canonical date column). Use `SAMEPERIODLASTYEAR`, `DATESYTD`, or parallel period helpers with explicit **date table** marking in the model.

**Risk:** Avoid circular dependencies between fact tables and helper calculated tables; verify in Power BI Desktop after measure changes.

## Canceled SAP documents (transactional tables)

When querying SAP B1 invoice-style tables (`OINV`, `ORIN`, etc.) directly, **filter `CANCELED = 'N'`** so cancellations are not double-counted. GL-based facts typically net correctly without this filter.

**Reference:** `Portfolio/Shared/ChatContext/LESSONS.md` (2026-03-31).

## AR / aging buckets

**Pattern:** Bucket labels + sort keys (physical or calculated sort tables) so matrix and chart legends stay ordered (Current, 30, 60, …). Reuse Finance `Receivables` / `Collections` pages as structural references.

## Contributing new patterns

Add a short subsection here when a pattern is **used in more than one module** or is **required for portfolio consistency**. Keep one-off experiment DAX in module `Project Memory` or `MODEL_NOTES.md` until it stabilizes.
