# Fabric Reports — Unified Layout Standard

Scope: the five reports in `Fabric/DevelopmentWorkspace/`
— **Canon Financial**, **Paper Financial**, **Canon Sales**, **Canon Inventory**, **Paper Inventory**.

Purpose: a single, exact layout/spacing/typography guideline so the five reports follow one
structure. This is a **layout-only** standard — see the guardrail below.

> **GUARDRAIL — no logic changes.** Applying this standard must not add, remove, or change any
> measure, value, number format, field binding, slicer field, visual type, page, or filter.
> Allowed operations are limited to: **move, resize, restyle (font/color/spacing), and delete
> decorative brand images**. Nothing else.

---

## 0. Implementation status — pass 1 (applied)

This pass prioritized the user constraint *"moving is just moving stuff a little bit, resizing a
little bit."* It unified the high-visibility, low-risk dimensions toward the existing dominant
values (minimal movement) rather than the aspirational absolute grid in §3. **No measure, value,
number format, field, slicer field, visual type, page, or filter was changed** (verified by diff:
zero query/measure/projection edits; only `position` + style props changed, plus deletion of
decorative brand images).

**Applied across all five reports:**

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
  All five reports now register the same theme.

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
| Brand logos | **Removed everywhere** (no AlJazeera / Canon / brand-group images or dividers) |
| Header content | **Page title text only**, left-aligned, on the page background — no colored bar |
| Page title source | **Reuse** each page's existing header text; only reposition/restyle it |
| KPI value font | **18 pt** |
| Spacing grid | **24 px gaps / 48 px outer margins** (8-px base unit) |
| Title typeface | **Segoe UI regular** everywhere (no Semibold) |
| Title color | **Single color `#2E3A42`** everywhere |
| Slicer rail | Keep left rail, **width 400 px**, uniform slicer height |
| Theme | **One shared theme** registered in all five reports |
| Minor drift | Auto-normalize sub-pixel / rounding / stray-color drift without per-item approval |
| Rollout | Apply across **all five** in one pass after spec approval |

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
| Header (page title) | `0 → 88` | title text block at `x=48, y=28, h=40` |
| KPI / headline row | `96 → 200` | card height `104` |
| Analysis (charts) | `224 → …` | flexible, 24 px gaps |
| Detail (tables/matrices) | `… → 1032` | flexible, ends at bottom margin |

---

## 4. Header (after logo removal)

- Remove all brand `image` visuals (AlJazeera, Canon, top-right brand group) and the vertical
  `shape` dividers. These are decorative only — safe to delete under the guardrail.
- Keep **one page-title text** per page (reuse the existing header text/shape content).
  - Position: `x = 48`, `y = 28`, width up to `600`, height `40`.
  - Typography: **Segoe UI regular, 20 pt, `#2E3A42`**, left-aligned, no fill, no border.
- No colored header bar, no logos, no subtitle.

> Today Canon reports carry logos and Paper reports do not — removing logos everywhere closes
> that gap and removes the `*_brand_*` / divider position differences entirely.

---

## 5. Left slicer rail

- Rail block occupies `x: 48 → 448` (**width 400**).
- Each slicer is **dropdown** mode, **slicer header hidden**, with a **separate text label** above it
  (existing pattern — keep the labels and slicer fields exactly as they are).
- **Uniform slicer height: 76** for single-select dropdowns. Multi-row/list slicers use a height
  that is a clean multiple (e.g. `184`) but keep the same `x` and `width`.
- Vertical rhythm inside the rail: label height `22`, label→slicer gap `4`, slicer height `76`,
  slicer→next-label gap `16`. First label top at `y = 96`.
- Keep the existing top-to-bottom slicer order per report; do not reorder fields.

---

## 6. KPI / headline cards (`cardVisual`)

- **Row top:** `y = 96`. **Card height:** `104`. **Gap between cards:** `24`.
- **Card width** fills the content zone evenly for `n` cards in the row:
  `width = (1400 − 24 × (n − 1)) / n`

  | n | card width |
  |---|-----------|
  | 4 | 332 |
  | 5 | 260.8 |
  | 6 | 213.3 |
  | 7 | 179.4 |

  First card `x = 472`; each subsequent card `x = previous.x + width + 24`.
- **Surface:** fill `#FFFFFF`, border `#C9D5E3`, **corner radius 14**.
- **Top accent** via drop shadow (not a separate shape): color `#1F4E79`, position `Outer`,
  angle `270`, distance `4`, blur `0`, spread `0`, transparency `0`.
- **Title:** Segoe UI regular, **12 pt**, `#2E3A42`, shown.
- **Value:** Segoe UI regular, **18 pt**, not bold. (Number format / display units unchanged.)

---

## 7. Charts, tables, slicers (analysis & detail zones)

- Snap every visual's `x/y/width/height` to the grid; align edges to the rail line (`472`),
  the right margin (`1872`), and shared row baselines.
- Maintain the **24 px gap** between neighbors and between a visual and the page margins.
- Visual container: fill `#FFFFFF`, border `#C9D5E3`, **corner radius 14**, inner padding 16
  (inherited from theme).
- Titles follow the typography rules in §8. Do not change the visual type or its fields.

---

## 8. Typography

| Role | Family | Size | Color | Weight |
|------|--------|------|-------|--------|
| Page title (header) | Segoe UI | 20 | `#2E3A42` | regular |
| Visual / card title | Segoe UI | 12 | `#2E3A42` | regular |
| KPI value | Segoe UI | 18 | (measure default) | regular |
| Axis / data labels | Segoe UI | 9 | `#485257` | regular |

- Eliminate `Segoe UI Semibold` usages → `Segoe UI`.
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
- Register that one theme in all five reports' `definition/report.json` (`themeCollection.customTheme`)
  and update the matching `StaticResources/RegisteredResources/` file; drop the duplicate
  `InventoryPortfolioTheme…json`.
- Align the theme's default card corner radius to `14` so new visuals inherit the standard.

---

## 11. Per-report change summary (what each must move toward)

Current measured state → required normalization:

- **Canon Financial** — content already full-bleed (`L=0,T=0`); right gap `50`→`48`; KPI gaps are
  inconsistent (`15 / 18 / 20.8 / 35.1`) → uniform `24`; card height `104` (keep); remove logos.
- **Paper Financial** — currently inset (`L=55,T=40`) → adopt full-bleed header + 48 margins;
  right gap `63`→`48`; KPI value font `21`→`18`; KPI gaps → `24`; no logos present (good).
- **Canon Sales** — content start `~511`→`472`; rail width `403`→`400`; KPI gaps uneven
  (`18.3/26.7/16.7`) → `24`; card height `103`→`104`; title color `#1F4E79`→`#2E3A42`; remove logos.
- **Canon Inventory** — switch theme to shared file; content start `~511`→`472`; rail width
  `403/404`→`400`; slicer heights `75/78/80`→`76`; radius `12`→`14`; border `#E2EAE6`→`#C9D5E3`;
  card height `103`→`104`; remove logos.
- **Paper Inventory** — switch theme to shared file; currently inset (`L=55,T=42`) → full-bleed +
  48 margins; right gap `53`→`48`; rail width `403/404`→`400`; slicer heights → `76`;
  radius `12`→`14`; card height `103`→`104`; no logos present (good).

---

## 12. Acceptance checks (after applying)

- All five reports: `1920×1080`, `FitToPage`, bg `#F8FBFF`, one shared theme registered.
- Outer margins `48` on left/right/bottom on every main page; inter-visual gaps `24`.
- Slicer rail at `x=48`, width `400`, content starts at `x=472`.
- KPI rows: top `y=96`, height `104`, equal `24` gaps, radius `14`.
- No brand `image` or divider `shape` visuals remain.
- Title typeface = Segoe UI (no Semibold); visual titles `12 pt`; titles colored `#2E3A42`.
- Diff review confirms **only** position/size/format/branding-image changes — no field, measure,
  value, format-string, slicer-field, or visual-type changes.
