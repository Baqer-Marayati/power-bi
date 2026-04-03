# Shared DAX patterns

Reusable measure and modeling patterns observed across portfolio reports (especially Finance). Copy and adapt into each module’s `_Measures` or table fragments; keep module-specific names consistent with bound visuals.

## Card display measures

**Problem:** Card visuals sometimes ignore or fight format strings for large IQD values.

**Pattern:** Create a dedicated display measure (example naming: `[Net Revenue Card Display]`) that returns a **pre-formatted string** or uses `FORMAT` / scaling logic agreed for that page. Bind the **card value** to the display measure and **hide** the card’s built-in data label if it duplicates or conflicts.

**Reference:** `Reports/Finance/Project Memory/MODEL_NOTES.md` (KPI / formatting notes).

## Time intelligence (YTD / prior year)

**Pattern:** Centralize `Dim_Date` relationships on `PostingDate` (or the module’s canonical date column). Use `SAMEPERIODLASTYEAR`, `DATESYTD`, or parallel period helpers with explicit **date table** marking in the model.

**Risk:** Avoid circular dependencies between fact tables and helper calculated tables; verify in Power BI Desktop after measure changes.

## Canceled SAP documents (transactional tables)

When querying SAP B1 invoice-style tables (`OINV`, `ORIN`, etc.) directly, **filter `CANCELED = 'N'`** so cancellations are not double-counted. GL-based facts typically net correctly without this filter.

**Reference:** `Shared/ChatContext/LESSONS.md` (2026-03-31).

## AR / aging buckets

**Pattern:** Bucket labels + sort keys (physical or calculated sort tables) so matrix and chart legends stay ordered (Current, 30, 60, …). Reuse Finance `Receivables` / `Collections` pages as structural references.

## Contributing new patterns

Add a short subsection here when a pattern is **used in more than one module** or is **required for portfolio consistency**. Keep one-off experiment DAX in module `Project Memory` or `MODEL_NOTES.md` until it stabilizes.
