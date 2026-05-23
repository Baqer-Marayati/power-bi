# Agent brief: Canon Inventory Report — Open SO column + item search slicer

## Goal

Implement two UX changes **only** in the **Canon Inventory** PBIP:

1. **Reorder Actions** table: add an **Open SO** column **immediately after** **Open PO**, consistent with existing Open PO presentation (dash when zero/blank).
2. **Executive Summary**, **Reorder Actions**, and **Inventory Valuation** pages: add a **single synced item search slicer** that lets users find items by **code or name** in one place.

Do **not** change Paper Inventory or any other report/module.

## Scope lock

- **In scope:** `Reports/Inventory/Companies/CANON/Canon Inventory Report/` only (PBIP + semantic model under that tree).
- **Out of scope:** Canon Sales/Service/Finance/etc., `Companies/PAPERENTITY/**`, portfolio docs unless required by repo rules for traceability.
- **Do not change:** Meaning of **“on hand” / net available** on Reorder Actions (`Reorder On Hand` uses `Fact_StockCoverPolicy[NetAvailable]`). **Do not convert velocity to “per month”** — keep **per day** as today (`Reorder Velocity Display`).

## Context from the model (read before editing)

- **Open SO source:** `Fact_StockCoverPolicy[OpenSOQty]` (already populated from SAP open SO lines in the fact’s Power Query).
- **Open PO display pattern:** measure **`Reorder Open PO Display`** in `_Measures.tmdl` — uses `SELECTEDVALUE(Fact_StockCoverPolicy[OpenPOQty])`, dash when blank/zero.
- **Reorder table grain:** rows tie to **`Fact_StockCoverPolicy`** (via relationships to **`Dim_Item`**).
- **Item dimension:** `Dim_Item` has `ItemCode`, `ItemName`; relate slicer filtering through **`Dim_Item`** so visuals stay consistent with existing relationships (`Fact_StockCoverPolicy.ItemCode` → `Dim_Item.ItemCode`, etc.).

## Semantic model tasks

1. **`Dim_Item` calculated column for search**  
   - Add something like **`ItemSearch`** = concatenation of code and name (e.g. `ItemCode & " · " & ItemName` or similar delimiter).  
   - Purpose: one slicer field supports search across both identifiers.  
   - Consider: sort (`SortByColumn`), hide from default fields if the module prefers tidy field lists (optional; match existing conventions in this PBIP).

2. **`_Measures` — Open SO display measure**  
   - Add **`Reorder Open SO Display`** (or equivalent name matching **`Reorder Open PO Display`**) reading **`Fact_StockCoverPolicy[OpenSOQty]`**, same dash-when-zero/blank behavior.

## Report (PBIP) tasks

1. **Reorder Actions page — matrix/table**  
   - Insert **Open SO** column **directly after** **Open PO** using the new display measure (or equivalent).  
   - Match formatting/alignment with **Open PO** column.

2. **Three pages — slicer**  
   - **Pages:** Executive Summary, Reorder Actions, Inventory Valuation.  
   - Add **one slicer per page** on **`Dim_Item[ItemSearch]`** (or the chosen column), **Search** enabled.  
   - **Sync slicers** across these three pages so selection carries when navigating.  
   - Placement: consistent header/slicer pane per existing report layout (don’t break mobile layout if defined).

## Validation checklist

- Pick an item with **non-zero Open SO** (if available in dev data): Open SO column shows quantity; Open PO unchanged.
- Pick an item with **zero Open SO**: shows dash (same rule as Open PO).
- **Net available / velocity:** unchanged from current behavior.
- Search slicer: typing part of **code** or **name** finds item; filter applies on **all three** pages when synced.
- Confirm **no edits** under `Companies/PAPERENTITY/` or other modules.

## Repo/process notes

- Follow **`Reports/Inventory/AGENTS.md`** read order if substantive module edits need grounding.
- Prefer minimal diffs; mirror naming/format patterns already in **`Canon Inventory Report.SemanticModel`**.

---

## One-line kickoff for the user

Implement **only** in **`Reports/Inventory/Companies/CANON/Canon Inventory Report/`**: (1) add **`Reorder Open SO Display`** and an **`Dim_Item`** **`ItemSearch`** column; (2) on **Reorder Actions**, add **Open SO** after **Open PO**; (3) on **Executive Summary**, **Reorder Actions**, and **Inventory Valuation**, add a synced **search slicer** on **`ItemSearch`**; leave **net available** and **per-day velocity** unchanged; do **not** touch any other report.

Full instructions: **`Reports/Inventory/Module/Project Memory/HANDOFF_CANON_OPEN_SO_AND_ITEM_SEARCH_SLICER.md`**.
