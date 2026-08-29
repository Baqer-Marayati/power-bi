# Fabric Reports — Unified Layout Standard

Scope: the six reports in `Fabric/DevelopmentWorkspace/`
— **Canon Financial**, **Paper Financial**, **Canon Sales**, **Canon Inventory**, **Paper Inventory**,
**Canon Service** (migrated 2026-08-24 from its original 1280×960 layout).

Purpose: a single, exact layout/spacing/typography guideline so the reports follow one
structure. This is a **layout-only** standard — see the guardrail below.

Sibling standard: `fabric-reports-number-formatting.md` governs how numbers render
(units, decimals, format strings) — established 2026-08-28.

Enforcement: `python3 Portfolio/scripts/audit-report-consistency.py --strict
Fabric/DevelopmentWorkspace` validates both standards and is run by GitHub Actions on every push
and pull request.

> **GUARDRAIL — no logic changes.** Applying this standard must not add, remove, or change any
> measure, value, number format, field binding, slicer field, visual type, page, or filter.
> Allowed operations are limited to: **move, resize, restyle (font/color/spacing), and delete
> decorative brand images**. Nothing else.

---

## 0c. Current enforced contract — typography + KPI rhythm (applied 2026-08-29)

This is the authoritative visual contract when older implementation-history or aspirational-grid
notes below conflict with it:

- **Page header:** aligned with the report-family content frame at `y = 40`; title `Segoe UI`
  regular 20 pt `#2E3A42`; subtitle `Segoe UI` regular 13 pt `#485257`.
- **Visual/card title:** `Segoe UI` regular 12 pt `#2E3A42`.
- **KPI value:** `Segoe UI` regular 18 pt; top row `y = 136`, height 104, exactly 24 px between
  adjacent cards. Each row preserves its established left/right content bounds and divides the
  remaining width equally.
- **Slicer hierarchy:** visible native header is the one deliberate bold exception — `Segoe UI
  Semibold`, 14 pt, bold, `#1F4E79`; item text is 14 pt.
- **Chart typography:** category/value axes, visible data labels, and legends are `Segoe UI`
  regular 9 pt. Axis/legend text color is `#485257`.
- **Tables/matrices:** row headers are body text (`Segoe UI` regular 13 pt); column headers remain
  12 pt bold; values 13 pt; totals/subtotals bold.
- Canon logos remain; Paper reports remain logo-free. Tooltip pages remain out of scope.

The strict audit now enforces these properties directly, including properties that the previous
audit missed (card font family/weight, axes, legends, page headers, row headers, and KPI gaps).

---

## 0b. Implementation status — pass 2 (applied: logos + structural alignment)

Corrects pass 1 and adds the structural frame the screenshot review flagged.

- **Logos restored on all three Canon reports** (Canon Financial / Sales / Inventory) and
  **re-aligned to one canonical top-left lockup**: AlJazeera image `(0,0,164.7×63)`, vertical
  divider `(178,3.78,17.3×50.4)`, Canon image `(191.3,0,164.7×63)`. Canon Sales logos were resized
  up from 124×50 to match. Paper reports stay logo-free (they never had logos).
- **Bottom line unified to 1030** (50 px bottom margin) across the fleet. Financial panels
  moved from 1035 → 1030.
- **Slicer rail is full-height** to the 1030 line on every page (fixed sidebar, even when slicers
  don't fill it).
- **Vertical gaps normalized to 24 px** for normal-range gaps (10–45 px). Large/intentional gaps on
  sparse pages (e.g. ROI's ~512 px) were left untouched.
- **Content overhang clamped to 1030**; short pages left short (no stretching), per decision.
  - Side effect: Canon Sales had tight 17 px gaps; widening to 24 + holding the 1030 line trimmed
    each page's bottom visual ~13 px.
- Verified: 0 data-visual overlaps, 0 out-of-bounds, 0 query/measure/field changes.

---

## 0. Implementation status — pass 1 (applied)

This pass prioritized the user constraint *"moving is just moving stuff a little bit, resizing a
little bit."* It unified the high-visibility, low-risk dimensions toward the existing dominant
values (minimal movement) rather than the aspirational absolute grid in §3. **No measure, value,
number format, field, slicer field, visual type, page, or filter was changed** (verified by diff:
zero query/measure/projection edits; only `position` + style props changed, plus deletion of
decorative brand images).

**Applied across the report fleet:**

- **Typography unified:** all visual/card titles → **Segoe UI** regular (Semibold removed),
  size **12** (collapsed 10/11/13/14), color **`#2E3A42`** (collapsed `#1F4E79`/`#223430`).
  Page/section header titles kept at **20**.
- **KPI value** font → **18** (Paper Financial 21 → 18).
- **Border radius** → **14** (12 → 14); stray border color `#E2EAE6` → `#C9D5E3`.
- **KPI cards:** height unified to **104**; each KPI row's inter-card **gaps evened** (kept the
  row's left start and right edge, equal gaps); row tops aligned.
- **Slicer rail:** slicer width → **400**, single-row slicer height → **76**, slicer x snapped to
  each page's column (removes intra-report jitter). Left page margin (~55) preserved as-is since it
  was already uniform; the rail was **not** translated (avoids creating a new left-margin gap).
- **Brand logos removed everywhere:** 66 decorative `image`/`shape`/group visuals deleted
  (AlJazeera + Canon logos, vertical dividers, brand groups). Page-title header shapes kept.
- **Theme consolidated:** both Inventory reports switched from `InventoryPortfolioTheme…json` to
  the shared `Custom_Theme49412231581938193.json` (the two files were byte-identical except name).
  All six reports now register the same theme.

**Residuals intentionally left for a follow-up pass (need visual review; higher reflow risk):**

- **Body content frame** still differs slightly between families: content-left **520** (Financial)
  vs **511–512** (Sales/Inventory); right margin **~64** (Financial) vs **~53** (Sales/Inventory).
  This is an 8–11 px difference, imperceptible when viewing one report at a time. Unifying it
  requires reflowing every chart/table (an X-axis affine), which carries cascade risk and exceeds
  "move a little bit"; deferred.
- **Inter-chart gaps** (between non-KPI visuals) were not globally evened — only KPI rows were.
- A few **20 pt** section-header titles exist in Paper Financial / Inventory that the others lack;
  left as-is to avoid shrinking intentional section labels.

The §3–§9 numbers below remain the **aspirational target**; pass 1 moved the reports much closer to
each other without forcing those exact absolutes.

---

> **Supersedes / reconciles** the older `page-layout-spec.md` (which still describes a
> `1280×960 / FitToWidth` canvas and `radius 4 / title 10`). The live Fabric reports are
> `1920×1080 / FitToPage` with `radius 14 / title 12`. This document is the target state for the
> five Fabric reports; once adopted, fold the deltas back into `page-layout-spec.md`,
> `portfolio-visual-identity.md`, and `portfolio-theme.tokens.json`.

---

## 1. Design decisions (locked with the user)

| Topic | Decision |
|------|----------|
| Reference | Fresh standard (not copied from one report), anchored to the common 1920×1080 base |
| Page frame | **Full-bleed header** at top; body content inset by the outer margin |
| Brand logos | **Kept on Canon reports** (AlJazeera + Canon top-left lockup, unified size/position); Paper reports remain logo-free. *(Superseded the initial "remove everywhere" choice after review.)* |
| Header content | **Page title text only**, left-aligned, on the page background — no colored bar |
| Page title source | **Reuse** each page's existing header text; only reposition/restyle it |
| KPI value font | **18 pt** |
| Spacing grid | **24 px gaps / 48 px outer margins** (8-px base unit) |
| Title typeface | **Segoe UI regular** everywhere (no Semibold) |
| Title color | **Single color `#2E3A42`** everywhere |
| Slicer rail | Keep left rail, **width 400 px**, uniform slicer height |
| Theme | **One shared theme** registered in all six reports |
| Minor drift | Auto-normalize sub-pixel / rounding / stray-color drift without per-item approval |
| Rollout | Apply across the **full Fabric fleet** in one pass after spec approval |

---

## 2. Canvas (all main pages)

| Setting | Value |
|--------|-------|
| `width` × `height` | `1920 × 1080` |
| `displayOption` | `FitToPage` |
| Page background | `#F8FBFF` |
| Native filter pane (`outspacePane.width`) | `195`, collapsed |

Auxiliary tooltip pages (`380×210`, `ActualSize`) in the Inventory reports are out of scope and unchanged.

---

## 3. The grid

- **Base unit:** 8 px. All positions/sizes snap to multiples of 8 where practical.
- **Outer margins:** `left = 48`, `right = 48`, `bottom = 48`.
- **Gap between any two adjacent visuals:** `24` (horizontal and vertical).
- **Usable content rectangle:** `x: 48 → 1872` (width 1824), `y: 96 → 1032` (height 936).

### Horizontal zones

| Zone | x-range | Width |
|------|---------|-------|
| Left slicer rail | `48 → 448` | `400` |
| Rail → content gap | `448 → 472` | `24` |
| Main content | `472 → 1872` | `1400` |

### Vertical zones

| Zone | y-range | Height |
|------|---------|--------|
| Header (page title) | `0 → 112` | title text block aligned to content frame at `y=40` |
| KPI / headline row | `136 → 240` | card height `104` |
| Analysis (charts) | `264 → …` | flexible, 24 px gaps |
| Detail (tables/matrices) | `… → 1032` | flexible, ends at bottom margin |

---

## 4. Header

- Keep **one page-title text** per page (reuse the existing header text/shape content).
  - Position: align to the report-family content frame, `y = 40`.
  - Typography: **Segoe UI regular, 20 pt, `#2E3A42`**, left-aligned, no fill, no border.
- Subtitle: **Segoe UI regular, 13 pt, `#485257`**.
- Canon pages keep the approved AlJazeera/Canon lockup. Paper pages stay logo-free.

---

## 5. Left slicer rail

- Slicer controls are **400 px** wide. The established family anchors are `x = 75` for Financial
  and `x = 67–68` for Sales/Inventory/Service; do not introduce intra-page jitter.
- Each slicer is **dropdown** mode with a visible native header.
- Header: `Segoe UI Semibold`, 14 pt, bold, `#1F4E79`.
- Item text: 14 pt.
- **Uniform slicer height: 76** for single-select dropdowns. Multi-row/list slicers use a height
  that is a clean multiple (e.g. `184`) but keep the same `x` and `width`.
- Keep a consistent vertical rhythm within each rail; do not reorder controls or fields.
- Keep the existing top-to-bottom slicer order per report; do not reorder fields.

---

## 6. KPI / headline cards (`cardVisual`)

- **Row top:** `y = 136`. **Card height:** `104`. **Gap between cards:** `24`.
- **Card width** divides the report family's established left/right row span evenly:
  `width = (row span − 24 × (n − 1)) / n`. Preserve the row's outer bounds.
- **Surface:** fill `#FFFFFF`, border `#C9D5E3`, **corner radius 14**.
- **Top accent** via drop shadow (not a separate shape): color `#1F4E79`, position `Outer`,
  angle `270`, distance `4`, blur `0`, spread `0`, transparency `0`.
- **Title:** Segoe UI regular, **12 pt**, `#2E3A42`, shown.
- **Value:** Segoe UI regular, **18 pt**, not bold. Number format/display units follow the sibling
  number-formatting standard.

---

## 7. Charts, tables, slicers (analysis & detail zones)

- Align visual edges to the report-family content frame and shared row baselines.
- Maintain the **24 px gap** between neighbors and between a visual and the page margins.
- Visual container: fill `#FFFFFF`, border `#C9D5E3`, **corner radius 14**, inner padding 16
  (inherited from theme).
- Titles follow the typography rules in §8. Do not change the visual type or its fields.

---

## 8. Typography

| Role | Family | Size | Color | Weight |
|------|--------|------|-------|--------|
| Page title (header) | Segoe UI | 20 | `#2E3A42` | regular |
| Page subtitle | Segoe UI | 13 | `#485257` | regular |
| Visual / card title | Segoe UI | 12 | `#2E3A42` | regular |
| KPI value | Segoe UI | 18 | (measure default) | regular |
| Axis / data labels | Segoe UI | 9 | `#485257` | regular |
| Chart legend | Segoe UI | 9 | `#485257` | regular |
| Matrix row header | Segoe UI | 13 | (palette default) | regular |
| Slicer header | Segoe UI Semibold | 14 | `#1F4E79` | bold |
| Slicer item | Segoe UI | 14 | `#2E3A42` | regular |

- Eliminate `Segoe UI Semibold` usages except the deliberate slicer-header hierarchy.
- Collapse title sizes `10 / 13 / 14 / 20` (where used as visual titles) → `12`; keep `20` only for the page-title header.
- Collapse title colors `#1F4E79` and `#223430` → `#2E3A42`.

---

## 9. Color tokens

| Token | Value |
|-------|-------|
| Page background | `#F8FBFF` |
| Card / visual surface | `#FFFFFF` |
| Border | `#C9D5E3` (normalize stray `#E2EAE6`) |
| Primary text | `#2E3A42` |
| Brand navy (accent shadow / palette) | `#1F4E79` |
| Categorical palette | unchanged (theme `dataColors`) |

---

## 10. Theme consolidation

- The two custom themes (`Custom_Theme4941…json` used by Financial+Sales, and
  `InventoryPortfolioTheme…json` used by both Inventory reports) are **byte-identical except the
  `name` field**. Standardize on the single canonical copy
  `Portfolio/Shared/Themes/Custom_Theme49412231581938193.json`.
- Register that one theme in all six reports' `definition/report.json` (`themeCollection.customTheme`)
  and update the matching `StaticResources/RegisteredResources/` file; drop the duplicate
  `InventoryPortfolioTheme…json`.
- Align the theme's default card corner radius to `14` so new visuals inherit the standard.

---

## 11. Report-family variants

- Financial reports use the established `x ≈ 520` content frame and slicers at `x = 75`.
- Sales, Inventory, and Service use the established `x ≈ 512` content frame and slicers at
  `x = 67–68`.
- These are deliberate family anchors inside one visual system, not free-form page exceptions.
- Canon pages keep the shared logo lockup; Paper pages remain logo-free.

---

## 12. Acceptance checks (after applying)

- All six reports: `1920×1080`, `FitToPage`, bg `#F8FBFF`, one shared theme registered.
- Family content frames and 400px slicer rails stay internally aligned; bottom line is
  `1030 ± 2px`.
- KPI rows: top `y=136`, height `104`, equal `24` gaps, radius `14`.
- Canon brand lockups remain consistent; Paper has none.
- Page titles `20 pt`, subtitles `13 pt`, visual titles `12 pt`, KPI values `18 pt`, and
  axes/data labels/legends `9 pt`; all are regular Segoe UI except bold Semibold slicer headers.
- Diff review confirms **only** position/size/format/branding-image changes — no field, measure,
  value, format-string, slicer-field, or visual-type changes.
