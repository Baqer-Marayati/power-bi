# Handoff: Executive Summary — Qty and Cost by Business Type (design + logic)

Use this as the **single build spec** for an agent. Do not improvise business rules; match the Canvas mock for visuals.

---

## What to tell the agent (short)

Paste this one block first, then point at this file:

```
Implement the Executive Summary cost table per HANDOFF_EXECUTIVE_SUMMARY_COST_TABLE.md in Reports/Inventory/Module/Project Memory/. Match the Canvas at ~/.cursor/projects/c-Work-Microsoft-Platform-power-bi/canvases/canon-cost-trend-table-preview.canvas.tsx for Cost Trend pill design. Add sold-qty-weighted current unit cost for groups; wire Cost Trend % and the Current Item Cost column to that logic. No PBIP changes until you’ve read the full handoff and validated DAX in Desktop.
```

(Adjust the Canvas path if the agent’s workspace root differs.)

---

## 1. Context and goal

**Report (PBIP):**  
`Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.pbip`

**Page:** Executive Summary

**Visual:** Matrix titled **“Qty and Cost by Business Type”**  
(Locate under `Canon Inventory Report.Report/definition/pages/a1b2c3d4e5f6a7b8c9d0/visuals/` — confirm folder name for `f6ef055d0a86a7874a04` or current matrix.)

**Design reference (must match look & feel):**  
Cursor Canvas: `canvases/canon-cost-trend-table-preview.canvas.tsx` under the user’s Cursor project folder (e.g. `~/.cursor/projects/<workspace>/canvases/`).

Open that Canvas beside the report while building. **Cost Trend** should read like the mock: **pill badge**, **readable vs row text**, **red = cost up**, **green = cost down**, **grey = flat**, **icon + percentage**, no microscopic glyphs.

**Product goal:**

1. Drill path: Business Type → (optional) Group Type → Product Type → Segment Type → Item Name → Item Code (keep existing hierarchy unless product says otherwise).
2. **Per item:** Clear increase / decrease / flat vs realized COGS.
3. **Per group (B2B, B2C, subgroups):** Same story **for the group as a whole**, with a **defensible** definition: **weight by sold quantity**.

---

## 2. Column layout (final)

| Column | Measure / field | Notes |
|--------|-----------------|--------|
| Rows | Existing `Dim_Item` hierarchy | Keep expansion/sort unless broken. |
| **Qty** | `[Total Sold Qty]` | Keep. |
| **Item COGS** | `[Average Unit COGS]` | Realized average cost per unit sold in context. |
| **Current Item Cost** | **New:** `[Sold Weighted Avg Current Unit Cost]` (or alias for table display) | Must match the “current” side of the trend at **every** grain (item and group). |
| **Cost Trend** | `[Cost Trend %]` + **SVG or Deneb** per §5 | Match Canvas pill. |

Do **not** show group-level “current cost” that uses stock-weighted logic while the trend uses sold-weighted logic.

---

## 3. DAX logic (implement exactly; validate in Desktop)

### 3.1 Realized cost per unit (any grain)

`[Average Unit COGS]` = `DIVIDE([Total COGS], [Total Sold Qty])` — already sales-weighted at group level.

### 3.2 Current cost per unit — **sold-qty weighted** (any grain)

**`[Sold Weighted Avg Current Unit Cost]`:**

```dax
Sold Weighted Avg Current Unit Cost =
VAR Q = [Total Sold Qty]
RETURN
    IF (
        ISBLANK ( Q ) || Q = 0,
        BLANK (),
        DIVIDE (
            SUMX (
                VALUES ( Dim_Item[ItemCode] ),
                CALCULATE ( [Total Sold Qty] ) * CALCULATE ( [Current Item Unit Cost] )
            ),
            Q
        )
    )
```

- Reuse existing `[Current Item Unit Cost]` inside the iterator; fix iteration if evaluation context is wrong.

### 3.3 Cost trend % (any grain)

```dax
Cost Trend % =
VAR Realized = [Average Unit COGS]
VAR Current  = [Sold Weighted Avg Current Unit Cost]
RETURN
    IF (
        ISBLANK ( Realized ) || Realized = 0 || ISBLANK ( Current ),
        BLANK (),
        DIVIDE ( Current - Realized, Realized )
    )
```

- **Positive** → current cost for the **sold mix** is **higher** than realized (pressure up → **red** in UI).
- **Negative** → **lower** (**green**).
- **~0** → **flat** (**grey**).

### 3.4 Current Item Cost column

Bind the matrix column to **`[Sold Weighted Avg Current Unit Cost]`** (with same IQD formatting as other cost columns). At single-item grain, this should align with per-item current unit cost.

---

## 4. Cost Trend visual (match Canvas)

1. Legible at matrix text size — not a tiny SVG.
2. Colors **baked into** rendering (SVG `ImageUrl` or Deneb); do not rely on pivotTable conditional font color as the only correctness path.
3. Pill: icon + bold percent; min width so cells do not show `...`.
4. Tune `imageHeight`, `rowPadding`, column width — **no** 80px row monsters; **no** unreadable stamps.

**Total row:** Show trend only if mathematically consistent; otherwise BLANK — confirm in Desktop.

---

## 5. Files to touch

1. `Canon Inventory Report.SemanticModel/definition/tables/_Measures.tmdl` — new/changed measures; remove orphaned measures after grep.
2. Executive Summary matrix `visual.json` — field bindings, grid/image/column widths, header styling.
3. `Reports/Inventory/Module/Project Memory/CURRENT_STATUS.md` — dated summary.
4. Optional: `DECISIONS.md` — one line: group trend uses sold-qty-weighted current vs Average Unit COGS.

---

## 6. Slicers / filters

Keep existing slicers. Re-validate **`Total Sold Qty > 0`** visual filter after measure changes.

---

## 7. Validation checklist (Desktop)

- Single item: sold-weighted current ≈ `[Current Item Unit Cost]`; trend sign makes sense.
- B2B row: spot-check; heavy sellers should dominate.
- No ellipsis in Cost Trend; colors red/green/grey as specified; header black like other columns.
- Refresh / no model errors.

---

## 8. Non-goals

- Do not use stock-value ÷ on-hand as the **group** “current cost” for this table without explicit sign-off.
- Do not change unrelated pages unless required.

---

## 9. Stakeholder one-liner

**We compare realized cost per unit sold to what those same sold units would cost today at each SKU’s current unit cost, weighted by sold quantity — at item and group rows — and show the gap as a clear pill.**
