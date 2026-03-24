# Lessons from screenshots (Cursor + repo)

Short, **durable** notes the assistant adds after reviewing captures in `images/` when you ask to **learn**, **remember**, or **not repeat** a mistake. Future agents can read this file in the same conversation or when you say to follow past screenshot lessons.

## How entries are written

- One **dated** block per batch of screenshots (or per distinct issue).
- **Bullets**: concrete do / don’t — not chatty narrative.
- **Scope tag** at the start of a bullet when useful: `[repo]` | `[cursor]` | `[finance]` | `[general]`.

## Log

### 2026-03-25 — Revenue Insights product tree + Cursor screenshots

- `[cursor]` Chat image upload can reject PNGs; saving captures under `Shared/ChatContext/images/` and asking for the **latest by file time** avoids relying on unsupported attach paths.
- `[finance]` **Revenue by Product Tree** must not depend on a **disconnected** map dimension on the chart axis plus a measure that reads that filter context; evaluation often goes **blank for every category**. Prefer a **materialized label on the fact** (`Fact_SalesDetail[Product Tree Label]` in Power Query) and bind the visual to that column with **`Sales Revenue`**.
- `[finance]` Every calculated table fragment (e.g. `Dim_ItemSegmentMap.tmdl`) must be listed in **`model.tmdl`** (`ref table …`) or it will not load.
- `[finance]` SAP **`ItmsGrpNam`** / `ItemGroupName` may be a **long path** (e.g. prefixes + `\` + leaf), not an exact match to map `ProductTypeRaw`. Use **exact match first**, then **longest substring match** on `ProductTypeRaw`, then fall back to raw string; map blank / `#N/A` to a readable bucket (e.g. **Unassigned**). Keep the PQ **`SegmentMap` `#table`** aligned with `Dim_ItemSegmentMap` when the business mapping changes.
- `[repo]` Durable “memory” for assistants is **git-tracked** files (`LESSONS.md`, `Project Memory`, `.cursor/rules`), not model chat state.
