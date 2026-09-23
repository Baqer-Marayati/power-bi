# Prompt: Native Input slicer — Item search (Canon Inventory Report)

Single handoff prompt for an agent or developer implementing a **free, native** item search control on the Canon Inventory PBIP.

---

## Goal

Replace OKVIZ Smart Filter Pro (or any unlicensed custom visual) with a **native Power BI Input slicer / Text slicer** bound to:

**`Dim_Item[ItemSearch]`**

The control must provide a typed search experience for item code and item name, fit neatly in the **left filter rail**, and **sync** across these pages:

- **Executive Summary**
- **Reorder Actions**
- **Inventory Valuation**

**Repository scope (only place to change):**  
`Reports/Inventory/Companies/CANON/Canon Inventory Report/`

Do **not** change Paper Inventory, other modules, portfolio docs (unless module contract requires), **net available** behavior, **reorder velocity per-day** measures, or unrelated layout.

---

## Why this option

OKVIZ Smart Filter Pro may work after manual install but can be **unlicensed** in some tenants. The native **Input slicer** is the recommended free replacement because it is:

- Built into Power BI Desktop  
- License-free  
- Syncable via standard **Sync slicers**  
- Safe for PBIP source control  
- Visually good when formatted as a compact search card  
- Suited to substring search over `Dim_Item[ItemSearch]` (code + name in one field)

---

## Required UX

Create **one** item search control in the left filter rail on **each** target page.

| Element        | Value |
|----------------|-------|
| Title          | `Item search` |
| Placeholder / hint | `Type item code or name` |
| Filter operator | **`Contains any`** (OR across typed pills) |
| Field          | **`Dim_Item[ItemSearch]`** |

**Expected behavior:**

- User types a partial item code or partial item name.  
- User confirms (Enter / apply per Desktop UX).  
- Value appears as a **removable pill**.  
- Multiple values use **`Contains any`** (OR semantics).  
- Selection **syncs** when navigating between the three pages.

**Example values for validation:**

- `NPG-67 Toner Black`  
- `C-EXV 59 Cyan`  
- `IR-ADV 4525 Drum Unit`

Also spot-check partial tokens: `NPG-67`, `C-EXV`, `Drum`, `Toner`.

---

## Visual design

Match Canon Inventory / portfolio tone:

| Token        | Value |
|--------------|-------|
| Canvas       | `#F8FBFF` |
| Card fill    | white |
| Border       | `#C9D5E3` |
| Title accent | `#1F4E79` |
| Body text    | `#2E3A42` |
| Font         | Segoe UI |

**Layout:**

- Same **left rail** as Year / Quarter / Month / Business Type / Group Type / Product Type / Segment Type.  
- **Width** aligned with existing slicers.  
- **Height** sufficient for title, hint, operator, pills, and clear — avoid a ~32px-tall box; target roughly **120–170px** depending on page density.  
- Do not overlap main canvas or crowd logos.  
- If the rail is tight, tighten spacing on **lower** slicers rather than shrinking the search card into unreadable strips.

---

## Model prerequisites (verify, change only if broken)

1. **`Dim_Item[ItemSearch]`** exists and combines code + name (e.g. `ItemCode & " · " & ItemName`).  
2. **Sort** on `ItemCode` if used for predictable ordering.  
3. **Relationships** so `Dim_Item` filters facts and **Inventory Valuation** (e.g. `InventoryValuation[ItemCode]` → `Dim_Item[ItemCode]`).  
4. **Do not alter** measure definitions for:  
   - **`Reorder On Hand`** / net available  
   - **`Reorder Velocity Display`** (per day)  
   - Other reorder measures except **broken references** after visual swap.

---

## Remove legacy / broken visuals

1. Remove any visual with:  
   `visualType`: **`SmartFilterProByOKViz00000000000000000000000000000000`**  
2. Delete failed **CustomVisuals** bundle if present:  
   `Canon Inventory Report.Report/CustomVisuals/SmartFilterProByOKViz00000000000000000000000000000000/`  
3. Remove orphaned **visualInteractions** in `page.json` that pointed only at deleted visuals.  
4. Preserve warehouse and other slicer interactions.

---

## Implementation steps (Power BI Desktop)

**PBIP path:**  
`Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.pbip`

1. **Executive Summary**  
   - Add native **Input slicer** (or **Text slicer** per your build naming).  
   - Bind **`Dim_Item[ItemSearch]`**.  
   - Operator: **Contains any**.  
   - Polish title, border, font sizes to match rail.  

2. **Reorder Actions**  
   - Same field and formatting.  
   - Confirm **reorder table** receives the filter (fix `visualInteractions` only if this page overrides defaults and blocks the slicer).

3. **Inventory Valuation**  
   - Same field and formatting.  
   - Confirm KPIs, donut, matrix respond (fix **relationships** if needed, not DAX hacks).

4. **Sync slicers**  
   - Sync all three item search visuals on **`Dim_Item[ItemSearch]`**.  
   - Use existing group naming if present; suggested group: **`ItemSearch`**.  
   - **Selection must persist** across the three pages.

5. **Save** the PBIP from Desktop so PBIR JSON is coherent.

---

## PBIR hygiene (after save)

Confirm in source:

- [ ] No remaining OKVIZ Smart Filter Pro `visualType` on target pages.  
- [ ] No broken `CustomVisuals/SmartFilterPro...` folder.  
- [ ] Three pages have native input/text slicer on **`Dim_Item.ItemSearch`**.  
- [ ] **Sync** metadata present and consistent.  
- [ ] No duplicate conflicting item filters unless intentional.  
- [ ] `page.json` has no orphaned **DataFilter** rows.

---

## Validation checklist

**Desktop**

- [ ] Type on Executive Summary → visuals filter.  
- [ ] Navigate to Reorder Actions → **same search persists**, table filters.  
- [ ] Navigate to Inventory Valuation → **same search persists**, KPIs/matrix filter.  
- [ ] Clear search → all pages unfiltered.  
- [ ] Substring search works on code and name (via `ItemSearch` string).

**Model**

- [ ] `ItemSearch` populated.  
- [ ] Valuation filters via `Dim_Item` where applicable.  
- [ ] Reorder measures **unchanged** in meaning.

**Scope**

- [ ] Changes only under **`Reports/Inventory/Companies/CANON/Canon Inventory Report/`**.

---

## Explicit non-goals

- Do not use OKVIZ Smart Filter Pro or other **paid / unlicensed** custom visuals for this task.  
- Do not redesign unrelated pages.  
- Do not touch Paper Inventory or other companies.  
- Do not add Deneb for this unless stakeholders explicitly accept custom build and different parity.  
- Do not change velocity/net-available measure logic.

---

## One-line kickoff (paste to agent)

Implement a **native Power BI Input slicer** on **`Dim_Item[ItemSearch]`** for **Executive Summary**, **Reorder Actions**, and **Inventory Valuation**, **synced** (`Contains any`), replacing OKVIZ — follow **`Reports/Inventory/Module/Project Memory/PROMPT_NATIVE_INPUT_SLICER_ITEM_SEARCH_CANON_INVENTORY.md`**; scope **`Reports/Inventory/Companies/CANON/Canon Inventory Report/`** only; leave **net available** and **per-day velocity** measures unchanged.

---

End of prompt file.
