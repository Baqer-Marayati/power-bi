# Reorder Actions page — modern table only (hand-off prompt)

## Audience

You are implementing **one change** in the Canon Inventory PBIP: replace the main **SKU Reorder and Overstock** table on the **Reorder Actions** page so it **matches the approved mock** (screenshot `Portfolio/Shared/ChatContext/images/1.png`). **Do not** add KPIs, rails, filter chips, or reposition other visuals. **Do not** change page title, logos, slicers, or any non-table visuals. The only deliverable is the **single `tableEx` (Table)** visual.

---

## Scope (strict)

| In scope | Out of scope |
|----------|----------------|
| Edit the existing table visual JSON **or** replace fields/formatting on that visual | New page layout |
| Add DAX **measures** to `_Measures.tmdl` (or `_Measures` table in model) | Changing `Fact_StockCoverPolicy` M script / grain |
| Theme/format the table: header, gridlines, row alt, fonts | Deneb / HTML Content custom visuals (not required) |
| Wire columns exactly as specified | “Improvements” elsewhere on the page |

If anything is ambiguous, **default to pixel parity with the screenshot**, not “better UX.”

---

## Canonical references

| Reference | Path |
|-----------|------|
| Approved visual mock (table only) | `Portfolio/Shared/ChatContext/images/1.png` |
| PBIP project | `Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.pbip` |
| Page to edit | `Canon Inventory Report.Report/definition/pages/a7b8c9d0e1f2a3b4c5d6/` — `displayName`: **Reorder Actions** |
| Existing table visual folder | `.../pages/a7b8c9d0e1f2a3b4c5d6/visuals/table_reorder_actions/` |
| Semantic model — policy table | `Canon Inventory Report.SemanticModel/definition/tables/Fact_StockCoverPolicy.tmdl` |
| Measures | `Canon Inventory Report.SemanticModel/definition/tables/_Measures.tmdl` |

---

## Target table specification (must match screenshot)

### Visual type

- Native **Table** (`visualType`: `tableEx`). **No custom visuals.**

### Column order (left → right)

1. **Action** — SVG image (pill badge). Labels and colors:
   - `SuggestedAction` = **Buy** → pill text **BUY** — red/muted red style (`#9C2C2C` on `#FBEAEA`, border `#E8B5B5`)
   - **Good health** → **HEALTHY** — green (`#1F6240` on `#E4F1EA`, border `#B7D9C4`)
   - **Reduce** → **REDUCE** — amber/brown (`#8A5E0F` on `#FBF1DD`, border `#E8D49A`)
   - **Review non-mover** → **REVIEW** (or **DEAD** if you need four-letter uppercase parity; prefer **REVIEW** for clarity) — grey (`#4A4A4A` on `#EDEDED`, border `#CFCFCF`)
   - **No Action** → **IDLE** — neutral/navy-tinted (`#1F4E79` on `#E6EEF8`, border `#C0D3E8`)

2. **Item** — SVG image: **line 1** bold dark grey `ItemName`; **line 2** smaller muted `ItemCode & " · " & U_BusinessType & " · " & PolicyDays & "d policy"`. Use middle dot `·` as in mock (Unicode). If `U_BusinessType` is blank, substitute `"#N/A"` or field as stored.

3. **Cover** — SVG: horizontal bar (~92×22 px viewBox including label), grey track, **vertical tick** at **100% of target** position, fill width = `MIN(NetAvailable/TargetStockQty, 1.5) / 1.5` of track (same logic as prior design). **Fill color:**
   - `Ratio < 0.9` → `#B33A3A` (red)
   - `Ratio > 1.1` → `#B5811E` (gold/mustard; covers 111% and 533% cases in mock)
   - else → `#2F7A4D` (green)
   Under bar, text **"{0}% of target"** (`FORMAT(Ratio*100,"0")`) in small grey `#6B7785`.

4. **On hand** — numeric: `NetAvailable` (not `TotalQtyAvailable`; mock uses net available after PO/SO). Whole numbers where appropriate: `FORMAT(..., "0")` or `#,0`.

5. **Target** — numeric: `TargetStockQty`. Show **—** when `TargetStockQty` is 0 or blank (dead SKU / no velocity).

6. **Open PO** — numeric display: **—** when `OpenPOQty` = 0 or BLANK; else show quantity.

7. **Velocity** — text: **—** when `SalesVelocityQtyPerDay` = 0; else `FORMAT(SalesVelocityQtyPerDay, "0.00") & " /d"`.

8. **Move qty** — signed integer display:
   - **Buy:** `+` & `SuggestedReorderQty` (only when > 0)
   - **Reduce:** negative `ExcessQty` (e.g. `-195`)
   - **Good health:** **—**
   - **Review non-mover:** negative `ExcessQty` when model sets excess = full `NetAvailable` for no-demand rows; align with `Fact_StockCoverPolicy` logic (`ExcessQty` for `SalesVelocityQtyPerDay = 0` and `NetAvailable > 0`)
   - **No Action:** **—**
   - Font color via **Conditional formatting → Font color** (or CSS in SVG if you use a single SVG column — prefer **numeric measure + CF** for Move qty and **separate label measure** if needed)

   **Color rules (match mock):**
   - Positive (buy): `#B33A3A`
   - Negative (reduce / review liquidation): `#B5811E`
   - Dash / blank: muted grey `#9AA5B5`

9. **IQD impact** — compact text:
   - **Buy:** `SuggestedReorderQty * AvgItemCost`
   - **Reduce:** `ExcessQty * AvgItemCost`
   - **Review non-mover:** use `TotalItemCost` on row (or `NetAvailable * AvgItemCost` — align to business rule; mock shows **M** scale)
   - **Good health / No Action:** **—**
   - Format: if magnitude ≥ 1,000,000 → `FORMAT(value/1000000, "0.0") & " M"`; else scale to K/B as needed. **No** full IQD string with `د.ع` in this column (mock uses **10.9 M** style only).

### Table chrome (format pane)

- **Column header:** background **`#1F4E79`** (portfolio navy), text **white**, **bold**, Segoe UI **11 pt**.
- **Values:** Segoe UI, dark body `#2E3A42` / `#333`.
- **Grid:** **horizontal rules only** — minimal vertical lines (turn off vertical column borders if possible; use row dividers).
- **Alternating rows:** subtle alternate fill `#FFFFFF` / `#F7FAFD`.
- **Title:** set visual title to match mock intent **or** remove default title if the screenshot uses no title on the table chrome — **do not** leave the old long title if it breaks parity; user asked table-only parity with screenshot (screenshot table has no “SKU Reorder…” banner above columns — hide title if present).

### Row grain

- One row per **`Fact_StockCoverPolicy[ItemCode]`** (same as today). Keep sync slicers with rest of page.

---

## Implementation approach (required)

### A. Measures for SVG columns

Add measures to **`_Measures`** (append to `_Measures.tmdl`; follow existing naming/style).

**Row context:** every measure must use `SELECTEDVALUE ( Fact_StockCoverPolicy[ItemCode] )` (and/or verify `HASONEVALUE`) so behavior is defined when multiple items are selected.

**SVG pattern:**

- Return a single text value: `"data:image/svg+xml;utf8," & <svg string>`
- Inside SVG use **single quotes** for attributes to avoid DAX escaping pain.
- **URI encode** where needed: use `SUBSTITUTE ( SUBSTITUTE ( ..., "#", "%23" ), """", "%22" )` only if Desktop render breaks; start without encoding and add if required.
- After adding the measure, set **Data category** to **Image URL** (Column tools) for that measure when placed in the table.

**Suggested measure names** (rename if conflicts; keep one set per column):

| Measure | Role |
|---------|------|
| `Reorder Action Pill SVG` | Action column |
| `Reorder Item Cell SVG` | Item column |
| `Reorder Cover Bar SVG` | Cover column |
| `Reorder On Hand` | On hand (or use column directly) |
| `Reorder Target` | Target with — |
| `Reorder Open PO Display` | Open PO with — |
| `Reorder Velocity Display` | Velocity text |
| `Reorder Move Qty Value` | Numeric for CF / sorting |
| `Reorder Move Qty Label` | Text `+21`, `-195`, `—` |
| `Reorder IQD Impact Label` | `10.9 M` style |

**Pill SVG skeleton** (implement fully with `SWITCH` on `SuggestedAction`):

```dax
Reorder Action Pill SVG =
VAR _Code = SELECTEDVALUE ( Fact_StockCoverPolicy[ItemCode] )
VAR _Act  = SELECTEDVALUE ( Fact_StockCoverPolicy[SuggestedAction] )
VAR _Lbl  =
    SWITCH (
        _Act,
        "Buy", "BUY",
        "Good health", "HEALTHY",
        "Reduce", "REDUCE",
        "Review non-mover", "REVIEW",
        "No Action", "IDLE",
        UPPER ( _Act )
    )
VAR _Colors =
    SWITCH (
        _Act,
        "Buy", "9C2C2C|FBEAEA|E8B5B5",
        "Good health", "1F6240|E4F1EA|B7D9C4",
        "Reduce", "8A5E0F|FBF1DD|E8D49A",
        "Review non-mover", "4A4A4A|EDEDED|CFCFCF",
        "No Action", "1F4E79|E6EEF8|C0D3E8",
        "1F4E79|E6EEF8|C0D3E8"
    )
VAR _Fg = PATHITEM ( _Colors, 1, "|" )
VAR _Bg = PATHITEM ( _Colors, 2, "|" )
VAR _Bd = PATHITEM ( _Colors, 3, "|" )
RETURN
IF (
    ISBLANK ( _Code ),
    BLANK (),
    "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' ...>...</svg>"
)
```

(Use `_Fg` / `_Bg` / `_Bd` in the SVG `fill`, `stroke`, and `text` `fill` attributes. Prefix `#` in the SVG string as needed, e.g. `"#" & _Fg`.)

**Cover bar skeleton:**

- Inputs: `NetAvailable`, `TargetStockQty`
- `VAR _Ratio = DIVIDE ( NetAvail, Target, 0 )`
- Tick at `x = (1/1.5) * trackWidth` for 100% of target when scale max = 150%
- Bar width: `MIN ( _Ratio, 1.5 ) / 1.5 * trackWidth`

**Item cell SVG:**

- `text` element line 1: `ItemName` (truncate long names in SVG with `textLength` or ellipsize in DAX to ~40 chars if overflow)
- Line 2: subline as specified

### B. Edit `table_reorder_actions/visual.json`

- **Remove** all value fields not in the 9-column spec (e.g. old Item Code + Item Name separate, Sold Qty, Policy Days, Open SO, Stock Status, raw Value column, etc.).
- **Add** projections for the nine columns in **exact order** above. Use `nativeQueryRef` / `displayName` matching screenshot headers: **Action**, **Item**, **Cover**, **On hand**, **Target**, **Open PO**, **Velocity**, **Move qty**, **IQD impact**.
- Preserve `name`: `table_reorder_actions` and **do not** change `position` (x/y/w/h) unless the old table was clipped — only expand height if needed for readability; **do not** move x/y to avoid overlapping slicers.
- Set column widths in visual JSON if your schema version supports it so SVG columns render sharp (Action ~80–90px, Item wide, Cover ~120px).

### C. Conditional formatting

- **Move qty:** rules on `Reorder Move Qty Value` — >0 red `#B33A3A`, <0 amber `#B5811E`, else grey.
- **Open PO / Velocity / IQD / Target:** muted grey for `—` if implemented as text (or use blank + “—” string measure).

### D. Validation (must pass before merge)

1. Open PBIP in Power BI Desktop, **refresh** if possible (ODBC).
2. On **Reorder Actions**, compare to `1.png`:
   - Header color and column labels
   - Pill styles for BUY / HEALTHY / REDUCE
   - Cover bar + `% of target` text
   - **GPR-39 Drum** row: On hand **3**, Target **24**, Open PO **4**, Velocity **0.20 /d**, Move **+21**, IQD **10.9 M** (values may differ slightly with live data — structure must match)
3. Slicers still cross-filter **only** this table and behave as before.
4. Export **PDF** quick check: SVG columns render (some Desktop versions need “Image size: Normal”).

---

## Important correction (do not tell stakeholder wrong info)

The mock can be built with the **native Table visual** using **Image URL** measures (inline SVG). **Deneb and HTML Content are optional**, not required. Do not add custom visuals unless org policy already standardizes on Deneb.

---

## Deliverables checklist

- [ ] `_Measures.tmdl` updated with all measures; model builds without errors.
- [ ] `table_reorder_actions/visual.json` updated: exactly **9** columns, correct names/order.
- [ ] Table formatting matches header/alt row spec.
- [ ] No other visuals on page `a7b8c9d0e1f2a3b4c5d6` modified (diff should isolate table + measures).
- [ ] Optional: export screenshot after/before saved under `Reports/Inventory/Module/Records/` (naming convention per module).
- [ ] Update `Reports/Inventory/Module/Project Memory/CURRENT_STATUS.md` one short bullet: “Reorder Actions table → modern SVG table (native)” with date.

---

## Model field cheat sheet (from `Fact_StockCoverPolicy.tmdl`)

| Mock concept | Column / note |
|--------------|----------------|
| On hand (net) | `NetAvailable` |
| Target | `TargetStockQty` |
| Open PO | `OpenPOQty` |
| Velocity | `SalesVelocityQtyPerDay` |
| Buy qty | `SuggestedReorderQty` |
| Reduce qty | `ExcessQty` |
| Action label | `SuggestedAction` |
| Status band | `StockCoverStatus` (do not duplicate in table unless needed) |
| Unit cost | `AvgItemCost` |
| Row value | `TotalItemCost` |
| Business type | `U_BusinessType` |
| Policy days | `PolicyDays` |

---

*End of prompt — file created for hand-off: `Reports/Inventory/Module/Project Memory/REORDER_ACTIONS_TABLE_IMPLEMENTATION_PROMPT.md`*
