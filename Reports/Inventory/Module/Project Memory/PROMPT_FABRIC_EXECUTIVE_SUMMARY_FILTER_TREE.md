# Prompt: Build Executive Summary filter tree in Fabric copy

Use this as a single handoff prompt for an implementation agent working in Cursor or Power BI Desktop.

---

## Recommended model

Use **GPT-5.3 Codex High** for this task. The work is mostly precise PBIP/PBIR JSON editing, visual replacement, source-control hygiene, and validation. If that model is not available, use **Claude 4.6 Sonnet High Thinking** as the fallback for careful layout reasoning.

---

## Role and goal

You are implementing the approved **Filter Tree** design on the **Executive Summary** page of the **Canon Inventory Report** in the **Fabric Development Workspace copy**.

The user selected this render as the target:

`Portfolio/Shared/ChatContext/images/inventory-filter-concept-1-tree.png`

Build a single modern, searchable, tree-style filter panel that replaces the current stack of separate left-side slicers on **Executive Summary** only.

The final UX should feel like:

- A compact white card in the left filter rail.
- Header: **Filter Tree**
- Search box: **Search item, warehouse, status...**
- Selected chips at the top.
- Expandable sections:
  - **Time**
  - **Customer Mix**
  - **Product**
  - **Location**
  - **Stock**
  - **Items**
- Clear visual selection state using Canon navy/blue, aligned with the report theme.

Do **not** modify other pages unless you must inspect them for consistency. Do **not** copy changes back into `Reports/Inventory/Companies/CANON/...` unless explicitly asked. This is a Fabric-bound iteration.

---

## Repository scope

Only change files under:

`Fabric/DevelopmentWorkspace/`

Target PBIP:

`Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip`

Target report folder:

`Fabric/DevelopmentWorkspace/Canon Inventory Report.Report/`

Target semantic model folder:

`Fabric/DevelopmentWorkspace/Canon Inventory Report.SemanticModel/`

Target page:

`Fabric/DevelopmentWorkspace/Canon Inventory Report.Report/definition/pages/a1b2c3d4e5f6a7b8c9d0/`

Page display name:

**Executive Summary**

---

## Current Executive Summary slicer inventory

The current page uses individual slicers in the left rail:

| Visual name | Field | Current position |
|-------------|-------|------------------|
| `slicer_year` | `Dim_Date[Year]` | x `24`, y `140`, w `136`, h `32` |
| `slicer_quarter` | `Dim_Date[Quarter]` | x `24`, y `208`, w `136`, h `32` |
| `slicer_month` | `Dim_Date[MonthName]` | x `24`, y `276`, w `136`, h `32` |
| `slicer_salestype` | `Dim_Item[U_BusinessType]` | x `24`, y `344`, w `136`, h `32` |
| `slicer_salesdept` | `Dim_Item[U_GroupType]` | x `24`, y `412`, w `136`, h `32` |
| `slicer_bptype` | `Dim_Item[U_ProductType]` | x `24`, y `480`, w `136`, h `32` |
| `slicer_bpclass` | `Dim_Item[U_SegmentType]` | x `24`, y `548`, w `136`, h `32` |
| `slicer_item_search` | item search visual | x `18`, y `596`, w `150`, h `148` |

There are matching label textboxes:

- `label_year`
- `label_quarter`
- `label_month`
- `label_salestype`
- `label_salesdept`
- `label_bptype`
- `label_bpclass`

The existing report content starts at roughly x `188`, so keep the filter panel inside the left rail and do not overlap KPI/chart/table visuals.

---

## Required replacement strategy

### Preferred implementation

Use a **free** Power BI slicer/filter visual capable of a hierarchical tree with search. Recommended:

**HierarchySlicer / Hierarchy Slicer by DataScenarios**

Why:

- Free visual.
- Supports hierarchy-style filtering.
- Supports expand/collapse patterns.
- Supports search.
- Suitable replacement for many small slicers in one long panel.

If this visual is unavailable in the tenant or cannot be represented safely in PBIP source, stop and report the blocker before substituting another visual.

### Acceptable fallback

If Hierarchy Slicer cannot be installed or saved properly:

1. Use native Power BI slicers styled together inside one white card, with section headers to simulate the tree panel.
2. Preserve the same UX structure and visual grouping.
3. Document that it is a native approximation, not the custom hierarchy visual.

Do not use paid visuals or unlicensed visuals.

---

## Fields the filter tree must cover

The new panel must cover all current Executive Summary slicer fields and include item search:

### Time

- `Dim_Date[Year]`
- `Dim_Date[Quarter]`
- `Dim_Date[MonthName]`

Expected values from the model:

- Year: `2026`
- Quarter: `Q1`, `Q2`, `Q3`, `Q4`
- Month: `Jan`, `Feb`, `Mar`, `Apr`, `May`, `Jun`, `Jul`, `Aug`, `Sep`, `Oct`, `Nov`, `Dec`

### Customer Mix

- `Dim_Item[U_BusinessType]`

Known values visible in the report:

- `B2B`
- `B2C`
- `#N/A`

### Product

- `Dim_Item[U_GroupType]`
- `Dim_Item[U_ProductType]`
- `Dim_Item[U_SegmentType]`

Known values visible in the report:

- Group Type: `FSMA Contract`, `Service Labour`, `MPS Contract`, `Warranty`, `Non-Item`, `Unassigned`
- Product Type: `DS Copier`
- Segment Type: `Unassigned`, `hioj`

### Location

If possible on Executive Summary, add warehouse filtering too:

- Prefer `Dim_Warehouse[WhsName]` if relationships allow it to filter the Executive Summary visuals.
- Known warehouse values: `Dora`, `Erbil`, `Sadoon`, `Showroom Ilwea`

If warehouse filtering does not affect Executive Summary visuals because of relationship design, do not hack measures. Either omit Location on this page or add it only after confirming model relationships. Document the decision.

### Stock

If possible on Executive Summary, add stock status filtering too:

- `Fact_StockCoverPolicy[StockCoverStatus]`

Known values:

- `Healthy`
- `Under Stock`
- `Over Stock`
- `No demand - QTY available`
- `No demand - Zero QTY available`

If this field does not filter Executive Summary visuals correctly, do not force unrelated relationships. Document the limitation and leave Stock for pages where stock-cover facts are used.

### Items

Item search should use:

- Prefer `Dim_Item[ItemSearch]` if present.
- Otherwise use `Dim_Item[ItemCode]` and `Dim_Item[ItemName]` if the visual supports multiple hierarchy/search fields.

Known sample item values from the current report render:

- `0002912551`
- `0002944890`
- `0022998020`

---

## Visual design requirements

Match the selected render:

`Portfolio/Shared/ChatContext/images/inventory-filter-concept-1-tree.png`

Use these design tokens:

| Element | Value |
|---------|-------|
| Page background | `#F8FBFF` |
| Filter card fill | `#FFFFFF` |
| Border | `#C9D5E3` |
| Primary accent | `#1F4E79` |
| Body text | `#2E3A42` |
| Muted text | blue-gray / gray consistent with existing theme |
| Font | Segoe UI or the report’s existing default |

Panel target:

- x: around `18` to `24`
- y: around `96` to `112`
- width: around `145` to `160`
- height: use available rail height down to the item search area, but stay inside the page canvas.

The card may be slightly taller than the old stacked slicers if it remains inside the left rail. Do not move the main KPI/chart/table visuals unless absolutely required.

Recommended visible structure:

1. Header text: **Filter Tree**
2. Small subtitle: **One searchable hierarchy slicer**
3. Search input area: **Search item, warehouse, status...**
4. Selected chips row showing examples when selected.
5. Tree sections with checkboxes or expand/collapse carets.
6. Bottom buttons or actions if supported:
   - **Apply**
   - **Clear all**

If the visual cannot show buttons, rely on the visual’s native clear/search affordances.

---

## Implementation steps

### 1. Back up and inspect

Before editing:

- Check `git status`.
- Confirm any unrelated user changes and do not revert them.
- Inspect the current Executive Summary page JSON and all current slicer visual JSON files.
- Confirm whether the report already includes the Hierarchy Slicer custom visual bundle or similar custom visual resources.

### 2. Add or configure the tree visual

Preferred:

- Add one hierarchy slicer visual named something like:
  - `filter_tree_executive_summary`
- Bind the fields in this conceptual order:
  1. `Dim_Date[Year]`
  2. `Dim_Date[Quarter]`
  3. `Dim_Date[MonthName]`
  4. `Dim_Item[U_BusinessType]`
  5. `Dim_Item[U_GroupType]`
  6. `Dim_Item[U_ProductType]`
  7. `Dim_Item[U_SegmentType]`
  8. `Dim_Item[ItemSearch]`

If the chosen visual cannot combine unrelated hierarchy levels cleanly, use grouped section visuals inside one card:

- One compact hierarchy/date slicer for Time.
- One compact hierarchy slicer for Business/Product classifications.
- One compact searchable item slicer.
- Place them visually inside one shared white background/card so the result still appears as one filter panel.

### 3. Replace old slicers on Executive Summary only

Remove or hide the old individual controls on **Executive Summary**:

- `label_year`
- `slicer_year`
- `label_quarter`
- `slicer_quarter`
- `label_month`
- `slicer_month`
- `label_salestype`
- `slicer_salestype`
- `label_salesdept`
- `slicer_salesdept`
- `label_bptype`
- `slicer_bptype`
- `label_bpclass`
- `slicer_bpclass`
- `slicer_item_search`

Prefer deletion if the replacement is fully working. If deletion is risky, set old visuals hidden only if PBIR supports it cleanly, but avoid duplicate visible filters.

Do not remove:

- KPI cards
- charts
- matrix/pivot table
- logos
- header
- main content visuals

### 4. Interactions

Ensure the new filter tree filters the Executive Summary visuals:

- `kpi_sales`
- `kpi_cogs`
- `kpi_profit`
- `kpi_margin`
- `chart_trend`
- `chart_mix`
- `f6ef055d0a86a7874a04` (pivot table)

If `page.json` uses explicit `visualInteractions`, update it so the new visual sends `DataFilter` interactions to these targets. Remove orphaned interaction entries pointing to deleted old slicers.

### 5. Model changes

Avoid semantic model changes unless strictly needed.

Allowed verification:

- Confirm `Dim_Item[ItemSearch]` exists.
- Confirm `Dim_Date` fields exist.
- Confirm relevant relationships if adding Warehouse or Stock Status.

Do not alter DAX measures or table queries unless a missing relationship/field is a true blocker and the user approves the model change.

### 6. Save and validate

After changes:

- Save the PBIP in a way that preserves coherent PBIR JSON.
- Run a source-level check for:
  - orphaned visuals
  - broken visual paths
  - references to deleted slicer visual names in `page.json`
  - invalid JSON
- If Power BI Desktop/Fabric validation is available, open the report and test the page.

---

## Validation checklist

### Visual

- [ ] Executive Summary shows one unified left-side filter panel inspired by `inventory-filter-concept-1-tree.png`.
- [ ] Old separate slicers are no longer visible.
- [ ] Header says **Filter Tree**.
- [ ] Search affordance is visible.
- [ ] Sections are readable and compact.
- [ ] Styling matches Canon Inventory report colors.
- [ ] No main visuals are overlapped or moved out of alignment.

### Filtering

- [ ] Selecting `2026` filters the page without errors.
- [ ] Selecting `Q2` and a month such as `Apr` filters the page without errors.
- [ ] Selecting `B2B` / `B2C` filters the charts and table.
- [ ] Selecting product classification values filters the page.
- [ ] Item search/filter works for item code/name where supported.
- [ ] Warehouse and Stock Status are included only if they filter correctly; otherwise the limitation is documented.

### Source hygiene

- [ ] Changes are confined to `Fabric/DevelopmentWorkspace/`.
- [ ] Executive Summary `page.json` has no orphaned `visualInteractions`.
- [ ] Removed visual folders are actually removed if deletion was chosen.
- [ ] No unrelated report pages were changed.
- [ ] No semantic-model measure logic changed.

---

## Explicit non-goals

- Do not edit the canonical module PBIP under `Reports/Inventory/Companies/CANON/`.
- Do not edit Paper Inventory.
- Do not redesign other report pages.
- Do not change KPI/chart/table measures.
- Do not commit or push unless the user explicitly asks.
- Do not use paid or unlicensed custom visuals.

---

## One-line kickoff sentence

Build the approved **Filter Tree** on **Executive Summary** in `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip`, replacing the current separate left-side slicers with one searchable hierarchy-style filter panel based on `Portfolio/Shared/ChatContext/images/inventory-filter-concept-1-tree.png`, while keeping changes scoped to `Fabric/DevelopmentWorkspace/` and preserving all existing KPI/chart/table logic.

---

End of prompt file.
