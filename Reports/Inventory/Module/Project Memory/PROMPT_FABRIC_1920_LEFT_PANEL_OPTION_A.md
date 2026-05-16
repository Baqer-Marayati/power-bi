# Prompt: 1920×1080 + Wide Light Control Panel (Option A) — Fabric Canon Inventory Report

Use this as a single handoff prompt for an implementation agent working in Cursor or Power BI Desktop.

---

## Recommended model

Use **GPT-5.3 Codex High** for this task (PBIP/PBIR JSON, layout math, visual wiring, Git hygiene). If unavailable, use **Claude 4.6 Sonnet High Thinking**.

---

## Role and goal

You are implementing the approved **Option A — Wide Light Control Panel** layout on the **Canon Inventory Report** in the **Fabric Development Workspace** copy.

**Approved visual target (read this image first):**

`Portfolio/Shared/ChatContext/images/inventory-1920-left-panel-renders/option-a-wide-light-control-panel.png`

Build a **1920 × 1080** report canvas with:

1. A **fixed left control panel** (~330–380 px wide) containing **page navigation** and **report filters**.
2. A **main content area** shifted to the right that keeps all existing **KPI / chart / table logic** on **Executive Summary** (same measures, same visual types, same field bindings unless a binding must move into the panel).

The result must use **only Power BI–feasible UI** (native visuals, shapes, text boxes, buttons, page navigator, bookmarks). Do **not** invent custom controls that do not exist in Power BI.

Do **not** copy changes back into `Reports/Inventory/Companies/CANON/...` unless explicitly asked. Do **not** commit or push unless the user explicitly asks.

---

## Repository scope

Only change files under:

`Fabric/DevelopmentWorkspace/`

| Artifact | Path |
|----------|------|
| PBIP | `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip` |
| Report | `Fabric/DevelopmentWorkspace/Canon Inventory Report.Report/` |
| Semantic model | `Fabric/DevelopmentWorkspace/Canon Inventory Report.SemanticModel/` |

---

## Design target — Option A (from render)

### Canvas

| Property | Value |
|----------|--------|
| Width | **1920** px |
| Height | **1080** px |
| Aspect ratio | **16:9** |
| Page background | `#F8FBFF` (match existing report) |

Apply **1920 × 1080** to **every report page** in `definition/pages/*/page.json`. Set `displayOption` appropriately (e.g. `FitToPage` or keep `FitToWidth` only if validated in Desktop; prefer what keeps the layout stable at 1920×1080).

Remove or zero out legacy `outspacePane` width if it conflicts with the new in-canvas left panel (the panel is **on the page**, not the Desktop filter pane).

### Left control panel (white card)

Approximate geometry from the approved render (tune ±10 px in Desktop if needed):

| Element | Approx. position / size |
|---------|-------------------------|
| Panel card | x **28**, y **48**, width **~337**, height **~987** (fills most of page height) |
| Fill | `#FFFFFF` |
| Border | `#C9D5E3`, radius ~16–20 (use shape + background on container visuals) |
| Title | **Control Panel** — Segoe UI Semibold, `#1F4E79`, ~22–26 pt |
| Subtitle | **Page navigation + report filters** — `#6E7F8D`, ~12–13 pt |

**Section: Pages**

- Label: **Pages**
- **Five pill-style navigation entries** as in the render (use **Page navigator** visual configured for vertical list, or **Button** visuals + **bookmarks** / page navigation actions — both are valid; prefer **Page navigator** if it achieves the same look with less maintenance).
- **Active page** = filled navy pill (`#1F4E79`, white text).
- **Inactive pages** = white fill, `#C9D5E3` border, dark text.

**Primary pages to show in the navigator (match render labels; use real `displayName` from `pages.json`):**

| Render label | Actual page `displayName` | Page folder id |
|--------------|---------------------------|----------------|
| Executive Summary | Executive Summary | `a1b2c3d4e5f6a7b8c9d0` |
| Warehouse Distribution | Warehouse Distribution | `b2c3d4e5f6a7b8c9d0e1` |
| Stock Movements | Stock Movements | `c3d4e5f6a7b8c9d0e1f2` |
| Product Categories | **Product Deep Dive** (closest catalog page) | `d4e5f6a7b8c9d0e1f2a3` |
| Procurement | **Procurement & Suppliers** | `e5f6a7b8c9d0e1f2a3b4` |

Also include remaining report pages in the navigator if the visual supports it (do not hide real pages): **Inventory Valuation**, **Stock Cover**, **Reorder Actions** — order per `pages.json` `pageOrder`.

**Section: Filters**

- Label: **Filters**
- Four **native dropdown slicers** (mode Dropdown, header hidden or minimal), stacked vertically with consistent width (~276 px inside panel):

| Slicer label (UI) | Field |
|-------------------|--------|
| Year | `Dim_Date[Year]` |
| Quarter | `Dim_Date[Quarter]` |
| Business Type | `Dim_Item[U_BusinessType]` |
| Product Type | `Dim_Item[U_ProductType]` |

Default display: **All** where applicable; Year may show **2026** when data window is 2026-only.

**Panel footer actions (feasible patterns):**

| Button label | Implementation |
|--------------|----------------|
| **Clear all** | **Bookmark** that clears slicer selections on the page (or report-level clear pattern documented in PBIP if used elsewhere in repo) |
| **Help / notes** | **Button** + bookmark to a notes shape/text box, or static textbox with help copy — no external URLs required |

Do **not** use fake “Apply” unless you implement real bookmark behavior.

### Main content area (shifted right)

Approximate **main content origin**: x **~405**, usable width **~1465** (1920 − panel − right margin).

**Executive Summary** (`a1b2c3d4e5f6a7b8c9d0`) — preserve these visuals and bindings:

| Visual | Type | Measures / fields (do not change logic) |
|--------|------|----------------------------------------|
| `kpi_sales` | cardVisual | `_Measures[Total On Hand]` — title **Total Qty** |
| `kpi_cogs` | cardVisual | Available Qty measure (existing binding) |
| `kpi_profit` | cardVisual | Committed Qty measure (existing binding) |
| `kpi_margin` | cardVisual | On Order Qty measure (existing binding) |
| `chart_trend` | areaChart | `Total COGS`, `Current Total Cost` by `Dim_Date[MonthName]` |
| `chart_mix` | lineChart | `Average Unit COGS` by month, series `Dim_Item[U_BusinessType]` |
| `f6ef055d0a86a7874a04` | pivotTable | Business Type hierarchy + qty/COGS/cost/trend columns |
| Brand logos / header | image, shape, textbox | Keep; fix header title (below) |

**Header fix on Executive Summary:**

- `header_shape` (or equivalent) must say **Executive Summary**, not “Inventory Overview”.
- Subtitle may stay inventory-themed or match module copy; do not leave wrong page title.

**Layout transform (starting point for PBIP positions):**

Current canvas is **1280 × 960**; old main content starts ~**x = 188**.

For each main-area visual (x ≥ 180), apply:

- `new_x = old_x + 217`  (because 405 − 188 = 217)
- `new_y = round(old_y * 1.125)`  (1080 / 960)
- `new_width = round(old_width * 1.5)`  (1920 / 1280) for widths that should scale with canvas
- `new_height = round(old_height * 1.125)` for heights

Re-balance KPI row gaps and chart/table widths in Desktop if the proportional scale causes overlap. **Do not overlap** the left panel.

**Remove from Executive Summary** (after panel works):

- Legacy left-rail slicers: `slicer_year`, `slicer_quarter`, `slicer_month`, `slicer_salestype`, `slicer_salesdept`, `slicer_bptype`, `slicer_bpclass`, `slicer_item_search`
- Matching labels: `label_year`, `label_quarter`, `label_month`, `label_salestype`, `label_salesdept`, `label_bptype`, `label_bpclass`

Filters in the panel **replace** those controls for Executive Summary. If Month / Group Type / Segment Type / Item search are still required for parity with prior behavior, add them **inside the panel below Product Type** using **native slicers** only — do not break the Option A layout hierarchy.

---

## Other report pages

For **each** non–Executive Summary page:

1. Set canvas to **1920 × 1080**.
2. Add the **same left control panel shell** (Pages + Filters). Filters may be **page-appropriate** (reuse Year/Quarter/Business Type/Product Type where they filter that page; hide slicers that do not apply only if confirmed by existing page bindings).
3. Shift existing main visuals right using the same **+217 px** (or re-layout in Desktop) so nothing sits under the panel.
4. Do **not** delete page-specific analysis visuals.

---

## Styling tokens (Canon / portfolio)

| Token | Value |
|-------|--------|
| Canvas background | `#F8FBFF` |
| Panel fill | `#FFFFFF` |
| Border | `#C9D5E3` |
| Primary / accent | `#1F4E79` |
| Body text | `#2E3A42` |
| Muted text | `#6E7F8D` |
| Font | Segoe UI (match existing report) |
| KPI card | White fill, `#C9D5E3` border, navy top accent shadow (match existing `kpi_*` styling) |

---

## Implementation steps

### 1. Inspect (no edits yet)

- Read `Portfolio/Shared/ChatContext/images/inventory-1920-left-panel-renders/option-a-wide-light-control-panel.png`.
- Read `Fabric/DevelopmentWorkspace/Canon Inventory Report.Report/definition/pages/pages.json` and every `page.json`.
- Inventory Executive Summary `visual.json` files and positions.
- Confirm `git status`; do not revert unrelated user changes.

### 2. Resize all pages

- Update every `page.json`: `width: 1920`, `height: 1080`.

### 3. Build control panel on Executive Summary

- Add panel container (shape with background + border).
- Add title/subtitle textboxes.
- Add **Page navigator** (or buttons) for pages.
- Add four dropdown slicers with fields above.
- Add **Clear all** / **Help / notes** buttons with real bookmark or text behavior.
- Set `drillFilterOtherVisuals: true` on slicers so main visuals filter.

### 4. Reflow Executive Summary main visuals

- Apply transform rules; fix header title.
- Verify KPI row, two charts, and matrix fit without clipping.

### 5. Remove legacy left slicers on Executive Summary

- Delete obsolete visual folders or hide only if deletion is unsafe.
- Remove orphaned references in `page.json` (`visualInteractions` if any).

### 6. Roll out panel + reflow to other pages

- Repeat panel shell + main-area shift per page.
- Keep page-specific content intact.

### 7. Validate

- JSON validity on all edited files.
- No orphaned visual names in page metadata.
- Desktop validation checklist (user): open PBIP, Executive Summary at 1920×1080, page nav works, slicers filter KPIs/charts/table, no overlap with panel.

---

## Validation checklist

### Canvas

- [ ] All pages are **1920 × 1080**.
- [ ] Executive Summary matches Option A: wide white **Control Panel** on the left, main content on the right.

### Control panel

- [ ] Title **Control Panel** and subtitle **Page navigation + report filters**.
- [ ] **Pages** section with pill-style navigation; current page highlighted in navy.
- [ ] **Filters**: Year, Quarter, Business Type, Product Type (native dropdown slicers).
- [ ] **Clear all** and **Help / notes** use feasible Power BI actions (bookmarks / text), not decorative-only buttons.

### Executive Summary content

- [ ] Four KPIs, two charts, matrix unchanged in **measure logic**.
- [ ] Header says **Executive Summary**.
- [ ] Old left-rail slicers/labels removed from Executive Summary.
- [ ] Selecting Year / Business Type filters main visuals without errors.

### Scope & hygiene

- [ ] Changes only under `Fabric/DevelopmentWorkspace/`.
- [ ] No semantic model measure changes unless blocker (document if needed).
- [ ] No commit/push unless user asks.

---

## Explicit non-goals

- Do not implement Option B (icon dock) or Option C (slim nav + tree rail).
- Do not use AI mockup-only UI (fake chips, fake single-tree search across unrelated tables) unless built from real slicer/page navigator/bookmark behavior.
- Do not edit `Reports/Inventory/Companies/CANON/...` in this pass.
- Do not change KPI/chart/table **DAX measures** for layout work.

---

## One-line kickoff sentence

Build **Option A (wide light control panel)** on the Fabric **Canon Inventory Report** at **1920×1080** by following `Reports/Inventory/Module/Project Memory/PROMPT_FABRIC_1920_LEFT_PANEL_OPTION_A.md` and the approved render `Portfolio/Shared/ChatContext/images/inventory-1920-left-panel-renders/option-a-wide-light-control-panel.png`: left **Control Panel** with page navigation + Year/Quarter/Business Type/Product Type filters, main Executive Summary visuals shifted right with all existing KPI/chart/table logic preserved, then roll the same panel shell to other pages—**Fabric/DevelopmentWorkspace/** only; no commit unless asked.

---

End of prompt file.
