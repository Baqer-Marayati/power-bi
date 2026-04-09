# Lessons from screenshots (Cursor + repo)

Short, **durable** notes the assistant adds after reviewing captures in `images/` when you ask to **learn**, **remember**, or **not repeat** a mistake. Future agents can read this file in the same conversation or when you say to follow past screenshot lessons.

## How entries are written

- One **dated** block per batch of screenshots (or per distinct issue).
- **Bullets**: concrete do / don’t — not chatty narrative.
- **Scope tag** at the start of a bullet when useful: `[repo]` | `[cursor]` | `[finance]` | `[general]`.

## Log

### 2026-03-25 — Revenue Insights product tree + Cursor screenshots

- `[cursor]` Chat image upload can reject PNGs; saving captures under `Shared/ChatContext/images/` and asking for the **latest by file time** avoids relying on unsupported attach paths.
- `[finance]` *(Superseded for Revenue Insights — see 2026-03-26.)* A **disconnected** map on the chart axis + bridging measure often evaluates **blank**; materializing a label on the fact fixes that. The **current** axis is **`Item Business Type`** from **`OITM.U_BusinessType`**, not PQ segment maps.
- `[finance]` Any calculated table `.tmdl` must be **`ref table`** in **`model.tmdl`** or it will not load.
- `[repo]` Durable “memory” for assistants is **git-tracked** files (`LESSONS.md`, `Project Memory`, `.cursor/rules`), not model chat state.

### 2026-03-26 — Item business type UDF (Revenue Insights)

- `[finance]` Prefer **SAP item master UDF** (`OITM.U_BusinessType` in SQL; model column **`Item Business Type`**) for B2B/B2C-style revenue breakdowns instead of **manual segment maps** or **item group name** parsing in Power Query.
- `[finance]` Remove unused **calculated map tables** and measures once the visual is rewired to the fact column, to avoid dual sources of truth and refresh overhead.

### 2026-03-27 — PBIP semantic cleanup (measures + helper tables)

- `[finance]` **Verify before deleting measures:** (1) grep `Financial Report.Report/definition` for `_Measures.<name>` / `Property` bindings; (2) grep `Financial Report.SemanticModel` for `[Measure Name]` in **other** tables (e.g. **`Net Revenue LY`** is used by **`generalLedgerEntries`** — do not drop).
- `[finance]` **`Dim_ReportRows`** / **`Dim_KPIRows`** had **no** visual JSON references; they only supported removed statement/KPI measures — safe to delete **with** those measures and **`ref table`** / **diagram** cleanup.
- `[finance]` When two measures have **identical DAX**, keep one implementation and alias the other (e.g. **`Opex by Account`** = `[Opex by Department]`) so behavior stays the same for bound visuals.
- `[finance]` After bulk measure/table removal, **open the PBIP in Desktop** and confirm load + pages; **`en-US`** culture metadata may show stale names until Desktop reconciles.
- `[repo]` Record semantic cleanups in **`Project Memory/MODEL_NOTES.md`** so the next agent does not reintroduce “missing” objects.

### 2026-03-25 — Finance slicer + open-state rules

- `[finance]` The date slicer contract is pinned: `Year` must start at **2026** (no years before 2026 in the slicer).
- `[finance]` On the left slicer rail, **Sales Type must be above Department** (swapped from the previous order).
- `[finance]` The report should open with **no values until refresh**; avoid shipping/keeping semantic-model cache when this behavior is expected.

### 2026-03-26 — Revenue grouping source lock

- `[finance]` Revenue grouping on `Revenue Insights` must use SAP item-master UDF **`OITM.U_BusinessType`** (`Fact_SalesDetail['Item Business Type']`) instead of `ItemGroupName`.

### 2026-03-31 — SAP HANA connectivity + canceled document handling

- `[repo]` SAP HANA credentials are stored in `Shared/SAP Export Pipeline/set_credentials.sh` (env vars `SAP_HANA_USER` / `SAP_HANA_PASSWORD`). The `hdbsql` CLI at `C:\Program Files\sap\hdbclient\hdbsql.exe` works for ad-hoc queries; PowerShell ODBC (`System.Data.Odbc`) hits a protocol-parsing error on this server.
- `[finance]` `[sales]` When querying `OINV`/`ORIN` transactionally, **always filter `T0."CANCELED" = 'N'`**. SAP B1 keeps both the original (`CANCELED='Y'`) and cancellation (`CANCELED='C'`) documents in the same table with positive `LineTotal`. Without the filter, canceled amounts are double-counted. The GL (`OJDT/JDT1`) handles this internally (credit + debit net to zero), so GL-based reports are unaffected.

### 2026-04-09 — PBIP page.json schema limitations

- `[finance]` **`ordinal` is NOT a valid property** in page schema `2.0.0` (PBI Desktop November 2025 / v2.149). Adding it causes a hard load error: *"Property 'ordinal' has not been defined and the schema does not allow additional properties."* Page tab order must be set **manually in Desktop** by dragging tabs; it persists on save.
- `[finance]` Do **not** invent JSON properties based on external schema docs—always verify against the **`$schema` URL version** already in the file or against what Desktop actually writes.
