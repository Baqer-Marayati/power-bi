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
