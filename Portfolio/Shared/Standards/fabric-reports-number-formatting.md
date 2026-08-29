# Fabric reports — number formatting standard

Scope: the six reports in `Fabric/DevelopmentWorkspace/` — **Canon Financial**, **Paper Financial**,
**Canon Sales**, **Canon Inventory**, **Paper Inventory**, **Canon Service** — and, by extension, any
module copy synced from them. Established 2026-08-28 after the fleet-wide formatting passes.

Sibling standard: `fabric-reports-layout-standard.md` (geometry/typography of containers). This
document governs **how numbers render** — units, decimals, format strings, and the mechanism that
produces them.

## Principle: the model formats, the visual displays

- Every numeric measure carries a **static `formatString` in TMDL**. Visuals never compensate for a
  missing model format.
- Visuals only choose **display units and decimal places** (`labelDisplayUnits`, `labelPrecision`).
  They never re-suffix, re-scale in DAX, or bind scaled helper measures.
- No DAX scaling helpers for display. The `* Card Display` measures (÷1e6 / ÷1e9 with suffix
  formats) are **retired from all visuals** — nothing may bind them. They still exist in the
  Financial/Sales models pending deliberate deletion.
- Dynamic format strings (`formatStringDefinition`) are **off limits** — all six models sit at
  compatibility level 1567; the feature needs 1601+. Do not bump one model alone.

## Model format strings (TMDL)

| Kind | formatString | Example render |
|---|---|---|
| Money (raw IQD) | `#,0\ "د.ع.‏";-#,0\ "د.ع.‏";#,0\ "د.ع.‏"` | `1,234,567 د.ع.` |
| Money, bn-suffixed (legacy, chart-feeding) | `#,0.00"bn د.ع.‏"` 3-section | `5.89bn د.ع.` |
| Money, M-suffixed (legacy, chart-feeding) | `#,0"M د.ع.‏"` 3-section | `511M د.ع.` |
| Percent | `0.00%` (signed `+0.00%;-0.00%` and glyph `"▲ "+0.00%;…` variants keep their signs/glyphs) | `16.43%` |
| Count | `#,0` | `1,905` |
| Flag / binary helper | `0` | `1` |
| Ratio / hours / per-unit non-money | `0.0` (unit named in the measure/visual title) | `3.2` |

Rules:
- Currency suffix is always the Arabic **`د.ع.‏`** (with RLM), lowercase **`bn`** / uppercase **`M`**
  for scaled legacy formats. Never `Bn`, `IQD`, or bare numbers for money.
- Every percent format is `0.00%`-based — two decimals, model-wide, no exceptions.
- Text/SVG/date helper measures are exempt from format strings.

## KPI cards (`cardVisual`)

- **Money totals** bind the **raw** measure with `labelDisplayUnits = 1000000000D` (Billions) and
  `labelPrecision = 3L` → `5.886bn د.ع.` everywhere. Three decimals = million resolution.
- **Exact-IQD exemptions** — `labelDisplayUnits = 1D` (None), no precision override — for values
  where bn would render 0.000:
  - per-unit / average cards: *Avg Cost, Landed Cost/Unit, Procurement KPI Add-On Per Unit,
    Avg Collection per Txn, Avg Sales per Salesperson, Avg Sales per BP, Avg Parts Cost per Call*
  - the four cash cards on both Financial reports (*Cash in Bank / on Hand / in POS / Total Cash*)
- **Percent cards** carry `labelPrecision = 2L` **explicitly**. A card with unset precision renders
  0 decimals — it does NOT inherit the measure's format string (tables/charts do inherit).
- **`labelDisplayUnits = 0D` (Auto) is banned on cards.** Auto stacks a K/M/bn prefix on top of any
  suffix already in the format string (the "1.21KM د.ع." bug).
- Card value typography: `fontSize 18D`, not bold (per the layout standard).

## Measure vocabulary (2026-08-28 alignment)

- Percent measures always end in **`%`** — never "Percentage" spelled out, never a bare name
  (`In-Stock Rate %`, not `In-Stock Rate`).
- Plain **`Gross / Operating / Net Margin %`** are reserved for the **GL-based P&L margins**
  (Financial reports only).
- Margins computed from domain documents are named **`<Domain> Margin %`**: `Sales Margin %`
  (sales docs — the same number in Canon Financial and Canon Sales), `Service Margin %`
  (service revenue vs parts cost). Visible labels (card titles, column headers) use the same
  name as the measure — one concept, one name, fleet-wide.

## Tables & matrices (`pivotTable` / `tableEx`)

Converged on the Financial pattern (2026-08-28):
- grid `textSize 14D`, `rowPadding 2D`
- values `fontSize 13D`, font `Segoe UI`
- column headers `fontSize 12D`, `Segoe UI`, **bold** (header colors follow each report's palette —
  color is a design choice, not drift)
- totals/subtotals **bold** (`subTotals.bold` on matrices, `total.bold` on tables)
- Numbers inside tables inherit the **model format** — no unit/precision overrides in table values.
- Exception: compact **tooltip** tables (e.g. Inventory `table_tooltip_addon_breakdown`, 380×210)
  keep their small grid.

## Charts (data labels & axes)

- Money data labels, fixed **M** units → `labelPrecision 1L` (`510.7M`).
- Money data labels, fixed **bn** units → `labelPrecision 3L` (`1.610bn`, matches cards).
- Money data labels on **Auto** units (all-money charts) → `labelPrecision 1L`.
- Fixed-M value axes → `labelPrecision 1L` (`50.0M` ticks).
- **Percent value-axis ticks stay 0dp** — ticks are round gridline numbers, not readings.
- Percent/count data labels inherit the model format; no overrides.
- Charts bind raw measures (or plain column aggregations). Never suffixed helper measures — Auto
  units on a suffixed format reproduces the KM bug.

## Enforcement

`Portfolio/scripts/audit-report-consistency.py` polices this standard (NUMBER FORMATTING section):
Auto-unit cards, percent cards without 2dp, bn cards without 3dp, table typography drift,
fixed-unit chart labels missing the required precision, and non-`0.00%` percent model formats.
Run it after any report/model edit. Use `--strict` to return a non-zero exit code on formatting
or layout drift; GitHub Actions uses that mode:

```bash
python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace
```

## Editing gotchas (hard-won)

- Preserve **CRLF** line endings when scripting TMDL edits (Service models are CRLF; naive
  `write_text` rewrites the whole file).
- Preserve **17-digit float precision** when scripting `visual.json` edits (Power BI writes full
  `repr`; use a raw-preserving float shim or the whole file diffs).
- Only ever touch `formatString:` lines in TMDL and `objects` blocks in `visual.json`; queries,
  `filterConfig`, DAX expressions, and positions must be byte-identical after a formatting pass.
