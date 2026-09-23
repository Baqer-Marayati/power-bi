# Prompt: Implement OKVIZ Smart Filter Pro “Item search” (Canon Inventory Report)

Use this as a single handoff prompt for whoever builds it (you, another agent, or a developer in Power BI Desktop).

---

## Role and goal

You are implementing **OKVIZ Smart Filter Pro** as the **primary item search/filter control** on the **Canon Inventory** PBIP, replacing the current **native slicer on `Dim_Item[ItemSearch]`** (list/search style) that users dislike. The target UX is **fast search** over **item code and/or item name** in one place, aligned with the approved visual direction: **search box + optional advanced matching**, **compact layout**, **synced across pages**.

**Repository path (only place to change):**  
`Reports/Inventory/Companies/CANON/Canon Inventory Report/`  
(PBIP report under `Canon Inventory Report.Report\` and semantic model under `Canon Inventory Report.SemanticModel\` as already structured.)

Do **not** modify Paper Inventory, other modules, or portfolio docs unless the repo’s module contract explicitly requires a catalog update (prefer not to expand scope).

---

## Product and licensing (read first)

1. **Install from AppSource:** **Smart Filter Pro by OKVIZ** (not the free “Smart Filter” unless Pro is unavailable).
2. **Confirm licensing** for your tenant (Desktop, Service, Report Server as applicable). AppSource may show **“Not available in selected billing region”**; if so, document the blocker and fall back only after explicit approval.
3. **Feature parity:** Per OKVIZ’s public comparison, **Search/Filter modes, sync slicers, bookmarks, themes, copy/paste** are **Pro** capabilities; the free visual is **not** a substitute if you need **sync slicers** and **advanced modes**.
4. **Documentation:** Use OKVIZ docs for **Search mode**, **Filter mode** (wildcard/advanced query), **sync slicers**, and **performance** (Filter mode avoids loading all distinct values into memory, which matters for large item masters).

---

## Semantic model prerequisites (verify, add only if missing)

These should already exist from prior work; **do not change measure logic** for reorder unless explicitly required:

1. **`Dim_Item[ItemSearch]`**  
   - Formula concept: concatenate **code** and **name** (e.g. `ItemCode & " · " & ItemName`).  
   - **Stable sort** (e.g. `SortByColumn` on `ItemCode`) so dropdown/search lists sort predictably.
2. **Relationships** so filtering **`Dim_Item`** affects all relevant visuals:  
   - Facts already relate to **`Dim_Item[ItemCode]`**.  
   - **Inventory valuation** grain: ensure **`InventoryValuation[ItemCode]` → `Dim_Item[ItemCode]`** exists if the valuation page must respect item filters (many-to-one).
3. **Do not alter** the definitions of:  
   - **`Reorder On Hand`** / net available behavior.  
   - **`Reorder Velocity Display`** (keep **per day**, not monthly).  
   - Other reorder measures except as needed for **broken references** after visual replacement.

If anything is ambiguous, **inspect relationships and a sample page’s field usage** in Desktop before editing TMDL.

---

## Report implementation (Power BI Desktop)

### A. Remove or retire the old control

On **Executive Summary**, **Reorder Actions**, and **Inventory Valuation**:

1. Identify visuals named like **`slicer_item_search`** / **`label_item_search`** (or any native **slicer** bound to **`Dim_Item[ItemSearch]`**).
2. **Delete** those visuals (or hide them only if deletion is risky, but prefer deletion to avoid duplicate filters).
3. **Clean up** `page.json` **visualInteractions** that referenced only the removed slicer so you do not leave orphaned **DataFilter** rows.
4. Preserve interactions for **warehouse** and other slicers; only remove what targeted the old item-search slicer specifically.

### B. Add Smart Filter Pro (three pages)

For **each** of these pages, insert **one** Smart Filter Pro visual:

| Page | Purpose |
|------|---------|
| Executive Summary | Item scoping for CEO-style views |
| Reorder Actions | Find SKUs in the reorder table context |
| Inventory Valuation | Find items in valuation matrix/KPIs |

**Binding strategy (choose one and document in commit notes):**

- **Recommended:** Bind **one field** — **`Dim_Item[ItemSearch]`** — so one typed query searches the combined string (code and name appear together).
- **Alternative (only if product allows multi-field well):** Bind **`Dim_Item[ItemCode]`** and **`Dim_Item[ItemName]`** in the same visual and configure **AND/OR** per OKVIZ options so users can search code OR name explicitly.  
Prefer **single `ItemSearch`** unless dual-field is clearly better after testing.

### C. Mode selection (critical UX decision)

Pick the default mode based on **dataset size** and **how users type**:

1. **Search mode (Pro)**  
   - Use when you want **autocomplete**, “typeahead,” and a **classic search bar** feel.  
   - Good when **`ItemSearch`** cardinality is high but users expect **pick from suggestions**.
2. **Filter mode (Pro)**  
   - Use when the item list is **very large** and you want **query-style** filtering (wildcards, quotes, exclusions) with **performance** that does not require loading all values into the slicer memory (see OKVIZ Filter mode docs).  
   - Good for **power users** and **heavy models**.

**Default recommendation for inventory SKU search:** start with **Search mode**; if performance or usability testing fails on large catalogs, switch default to **Filter mode** and train users on wildcard syntax.

Expose a **short note in the report** (small textbox near the visual, optional): e.g. “Tip: use * wildcard / quotes for exact” **only if** you use Filter mode defaults.

### D. Sync slicers across pages (required)

1. Configure **Sync slicers** so **all three** Smart Filter Pro visuals share the **same field** (`Dim_Item[ItemSearch]` or the chosen fields) and **sync selection** when navigating between **Executive Summary**, **Reorder Actions**, and **Inventory Valuation**.
2. Match **sync group** naming convention already used in the PBIP if applicable; after Desktop save, verify **PBIR JSON** still reflects synced slicer metadata consistently (do not hand-edit unless you know the exact `syncGroup` schema).

### E. Cross-filtering behavior

1. With **`drillFilterOtherVisuals`** / default interactions, Smart Filter Pro should **filter other visuals** on each page.
2. **Reorder Actions page:** ensure the **reorder table** still receives the filter (add **visual interaction** only if the page uses explicit `visualInteractions` overrides that blocked the new visual).
3. **Inventory Valuation:** ensure **KPIs**, **donut**, and **matrix** respond. If they do not, trace **relationships** (especially **`InventoryValuation` → `Dim_Item`**) and fix the model, not hacks in DAX.

### F. Layout and formatting

1. **Placement:** left filter rail consistent with the report (`outspacePane` width ~195px theme in existing `page.json`); size the Smart Filter Pro to **full rail width** and **adequate height** for search UX (avoid a 32px-tall box; give vertical room if list/dropdown needs it).
2. **Title:** use **“Item search”** (or **“Item lookup”**) matching portfolio tone.
3. **Theme:** align fonts/colors with **InventoryPortfolioTheme** where possible (navy header tone `#1F4E79` family, Segoe UI).
4. **Mobile layout:** if **mobile layout** is defined for this PBIP, replicate the visual placement and test.

---

## Validation checklist (must pass before handoff)

**Model**

- [ ] `Dim_Item[ItemSearch]` present and populated (sample rows show both code and name).
- [ ] Relationships allow **Dim_Item** to filter **Inventory Valuation** visuals when applicable.
- [ ] Reorder measures **unchanged** in meaning: **net available**, **velocity per day**.

**Report**

- [ ] Old native **`ItemSearch`** slicers removed on all three pages.
- [ ] Smart Filter Pro present on **Executive Summary**, **Reorder Actions**, **Inventory Valuation**.
- [ ] **Sync slicers** works: select on page A, navigate to B/C and **selection persists**.
- [ ] Typing finds items by **substring of code** and **substring of name** (because `ItemSearch` includes both).
- [ ] Large-model behavior acceptable (no excessive load; acceptable query time).
- [ ] No duplicate item filters (no second conflicting slicer on the same field unless intentional).

**Repo hygiene**

- [ ] Changes confined to **`Reports/Inventory/Companies/CANON/Canon Inventory Report/`**.
- [ ] PBIP saved from Desktop so JSON is coherent; no orphaned visuals in `definition/pages/**/visuals/`.

---

## Deliverables

1. Updated PBIP with **three** Smart Filter Pro visuals and **sync** configured.
2. Short note in **Inventory module project memory** (only if your process requires it) naming: **OKVIZ Smart Filter Pro**, **bound field(s)**, **mode**, and any **licensing** constraint discovered.
3. If Pro unavailable: stop and report **blocker** rather than silently substituting the free visual and losing **sync** / **modes**.

---

## Explicit non-goals

- Do not redesign unrelated pages or charts.
- Do not change **Paper Inventory** or other companies.
- Do not replace OKVIZ with **Deneb** for this task unless Pro is blocked and stakeholders accept **custom engineering** and **weaker native “search slicer” parity**.

---

## Reference mockup (UX target)

The visual style should feel like the approved concept: **compact card**, **search-first**, optional **advanced matching affordances** if using Filter mode; **autocomplete list** if using Search mode — see project asset **`canon-search-option-okviz-smart-filter-pro.png`** (saved under the Cursor project assets path for this workspace when generated).

---

## One-line kickoff (paste to the agent)

Implement **OKVIZ Smart Filter Pro** on **`Dim_Item[ItemSearch]`** for **Executive Summary**, **Reorder Actions**, and **Inventory Valuation**, **synced across pages**, replacing the native `ItemSearch` slicers—follow the full checklist in **`Reports/Inventory/Module/Project Memory/PROMPT_OKVIZ_SMART_FILTER_PRO_CANON_INVENTORY.md`**; scope **`Reports/Inventory/Companies/CANON/Canon Inventory Report/`** only and leave **net available** and **per-day velocity** measures unchanged.

---

End of prompt file.
