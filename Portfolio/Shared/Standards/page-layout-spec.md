# Portfolio page layout specification

Machine-oriented companion to [`portfolio-visual-identity.md`](portfolio-visual-identity.md) and [`portfolio-theme.tokens.json`](portfolio-theme.tokens.json). Use this when scaffolding new PBIP pages or aligning visuals across modules.

## Canvas

| Setting | Value | Notes |
|--------|--------|--------|
| `width` | `1280` | Standard report width |
| `height` | `960` | Standard report height (export-only pages may differ) |
| `displayOption` | `FitToWidth` | |
| Page background | `#F8FBFF` | `objects.background` on `page.json` |
| Outspace pane width | `195L` | Left filter gutter (`outspacePane.width`) where used |

## Left rail — date and entity slicers (Finance core pages)

**Order (top → bottom):** Year → Quarter → Month → Location → Sales Type → Department.

- Slicers use **dropdown** mode; **hide the slicer header** and place a **separate text label** visual above each slicer.
- **Year slicer:** do not expose calendar years before **2026** (see `Project Memory` / `LESSONS.md`).

**Reference positions** (Finance five core pages — adjust per page if Desktop reflows; treat as regression checks, not laws):

| Control | Label `y` | Slicer `y` (typical) |
|---------|-----------|----------------------|
| Quarter | `188` | `208` |
| Sales Type | `392` | `412` |
| Department | `460` | `480` |

## Zoning (top → bottom)

1. **Filters** — left rail (and any page-level header filters).
2. **KPI row** — top money / headline measures.
3. **Analysis** — charts and breakdown visuals.
4. **Detail** — matrices, statements, or drill tables.

## KPI cards (`cardVisual`)

See [`portfolio-visual-identity.md`](portfolio-visual-identity.md) and `kpiCard` in [`portfolio-theme.tokens.json`](portfolio-theme.tokens.json). Prefer:

- Hidden built-in value label when using dedicated **`… Card Display`** measures for IQD / compact formatting.
- Top accent via **drop shadow** (not a separate shape): color `#1F4E79`, Outer, angle `270`, distance `4`, blur `0`, spread `0`.

## Branding lockup (header)

Pattern used on Finance and several modules: **two registered logo `image` visuals + vertical `shape` divider**, often grouped in a **`visualGroup`** (top-right). Register assets in `definition/report.json` `resourcePackages`.

## Visual interactions

Prefer **slicer → data visual** (`DataFilter` / `DataFilter` equivalents). Avoid wiring slicers to **labels, shapes, or decorative images**.

## Naming conventions (suggested)

| Prefix / pattern | Role |
|------------------|------|
| `label_*` | Text above a slicer or section |
| `slicer_*` | Dropdown (or list) filter |
| `*_header` / `*_brand_*` | Page title or logos |
| Domain prefix (`recv_*`, `coll_*`, `cash_*`, `svc_*`, …) | Per-page families for AR / collections / cash / service |

## Module-specific drift

- **Inventory** may use a **different registered theme filename** while keeping the same token values as this spec.
- **Service** pages may omit `outspacePane` in `page.json` while keeping ~`184px` content inset; validate in Desktop.

## Canonical references

- Finance implementation: `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.Report/definition/pages/`
- Finance standards: `Reports/Finance/Module/docs/standards/page-layout-rules.md`
