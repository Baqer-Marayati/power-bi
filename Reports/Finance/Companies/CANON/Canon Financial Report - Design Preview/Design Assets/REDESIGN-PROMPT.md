# Canon Financial Report — Financial Summary Page Redesign
## Full Implementation Prompt for Cursor Agent

---

## Context

You are working on a **design preview copy** of the Canon Financial Report Power BI PBIP.
**Do NOT touch anything under:**
```
Reports/Finance/Companies/CANON/Canon Financial Report/
```

**All work is in this folder only:**
```
Reports/Finance/Companies/CANON/Canon Financial Report - Design Preview/
```

The PBIP consists of three parts inside that folder:
- `Canon Financial Report.pbip` — project entry point (do not modify)
- `Canon Financial Report.Report/` — all visual/page definitions (this is where you work)
- `Canon Financial Report.SemanticModel/` — data model (do NOT modify this at all)

---

## Target Design

You have two reference mockup images in this same folder (`Design Assets/`):

1. **`target-mockup.png`** — PRIMARY TARGET. Metricalist-inspired design with dark navy sidebar,
   tile slicers, teal accent color, Metricalist-style KPI cards with comparison rows,
   small-caps section headers, ranked bar chart for Sales Type.

2. **`target-mockup-option1-light.png`** — SECONDARY REFERENCE. Clean light version
   showing the slicer bar layout and card proportions.

Study both images before making any changes.

---

## Design System to Implement

### Color Palette
| Role | Color | Hex |
|------|-------|-----|
| Sidebar background | Dark navy | `#1B2A3B` |
| Page background | Very light blue-gray | `#EEF2F7` |
| Card/panel background | White | `#FFFFFF` |
| Primary data color | Medium navy | `#1D3557` |
| Secondary data color | Steel blue | `#3A7ABF` |
| Tertiary data color | Light blue | `#A8C6E8` |
| Accent / active state | Teal | `#17A2B8` |
| Positive indicator | Teal / green | `#17A2B8` |
| Negative indicator | Coral red | `#E63946` |
| Primary text | Dark navy | `#1B2A3B` |
| Secondary text / labels | Medium gray | `#64748B` |
| Subtle borders | Light gray | `#DDE6EF` |

### Typography
- Font: **Segoe UI** throughout
- Weights: Regular and Bold/SemiBold only
- 4 sizes: page title (18pt), section headers (10pt small caps), KPI values (22–24pt bold), labels/axis (9pt)

---

## Step-by-Step Implementation

### STEP 1 — Create the Theme File

Create this file:
```
Canon Financial Report - Design Preview/Canon Financial Report.Report/definition/themes/CanonRedesign.json
```

With this content:

```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/theme/1.0.0/schema.json",
  "name": "CanonRedesign",
  "dataColors": [
    "#1D3557",
    "#3A7ABF",
    "#17A2B8",
    "#A8C6E8",
    "#E63946",
    "#F4A261",
    "#2A9D8F",
    "#E9C46A"
  ],
  "background": "#EEF2F7",
  "foreground": "#1B2A3B",
  "tableAccent": "#17A2B8",
  "visualStyles": {
    "*": {
      "*": {
        "background": [{ "color": { "solid": { "color": "#FFFFFF" } } }],
        "border": [{ "show": true, "color": { "solid": { "color": "#DDE6EF" } } }]
      }
    },
    "slicer": {
      "*": {
        "background": [{ "color": { "solid": { "color": "transparent" } } }],
        "border": [{ "show": false }]
      }
    },
    "cardVisual": {
      "*": {
        "background": [{ "color": { "solid": { "color": "#FFFFFF" } } }],
        "border": [{ "show": true, "color": { "solid": { "color": "#DDE6EF" } } }]
      }
    }
  }
}
```

Then register the theme in:
```
Canon Financial Report.Report/definition/report.json
```
Add or update the `"theme"` property to reference `"CanonRedesign"`.

---

### STEP 2 — Update Page Background

File: `Canon Financial Report.Report/definition/pages/8c1c6f95c0c648c38b4a/page.json`

Change the `background.color` value from `#F8FBFF` to `#EEF2F7`.

Also set the `outspacePane` width to `180` (the left slicer rail).

---

### STEP 3 — Add Dark Navy Sidebar Background Shape

Create a new visual file:
```
Canon Financial Report.Report/definition/pages/8c1c6f95c0c648c38b4a/visuals/sidebar_bg/visual.json
```

This is a rectangle shape that covers the entire left sidebar area:

```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "sidebar_bg",
  "position": {
    "x": 0,
    "y": 0,
    "z": -1000,
    "height": 960,
    "width": 180,
    "tabOrder": 0
  },
  "visual": {
    "visualType": "shape",
    "objects": {
      "line": [
        {
          "properties": {
            "lineColor": {
              "solid": { "color": { "expr": { "Literal": { "Value": "'#1B2A3B'" } } } }
            },
            "transparency": { "expr": { "Literal": { "Value": "0D" } } }
          }
        }
      ],
      "fill": [
        {
          "properties": {
            "fillColor": {
              "solid": { "color": { "expr": { "Literal": { "Value": "'#1B2A3B'" } } } }
            },
            "transparency": { "expr": { "Literal": { "Value": "0D" } } },
            "show": { "expr": { "Literal": { "Value": "true" } } }
          }
        }
      ],
      "shapeType": [
        {
          "properties": {
            "shapeType": { "expr": { "Literal": { "Value": "'rectangle'" } } }
          }
        }
      ]
    }
  }
}
```

---

### STEP 4 — Convert Year, Quarter, Month Slicers to Tile Mode

For each of the following slicer visual files, change `"mode"` from `'Dropdown'` to `'Tile'`
and add tile formatting:

| Visual ID | Field |
|-----------|-------|
| `a8d1e5c40b1f4c2fa001` | Year |
| `slicer_quarter` | Quarter |
| `a8d1e5c40b1f4c2fa002` | Month |

In each visual.json, find the `"data"` objects block and change:
```json
"mode": { "expr": { "Literal": { "Value": "'Dropdown'" } } }
```
to:
```json
"mode": { "expr": { "Literal": { "Value": "'Tile'" } } }
```

Also add tile color styling to each slicer's `objects`:
```json
"tiles": [
  {
    "properties": {
      "background": {
        "solid": { "color": { "expr": { "Literal": { "Value": "'#243548'" } } } }
      },
      "selectedColor": {
        "solid": { "color": { "expr": { "Literal": { "Value": "'#17A2B8'" } } } }
      },
      "fontColor": {
        "solid": { "color": { "expr": { "Literal": { "Value": "'#FFFFFF'" } } } }
      },
      "selectedFontColor": {
        "solid": { "color": { "expr": { "Literal": { "Value": "'#FFFFFF'" } } } }
      }
    }
  }
]
```

Reposition and resize slicers to fit the sidebar:

| Visual | x | y | width | height |
|--------|---|---|-------|--------|
| `a8d1e5c40b1f4c2fa001` (Year) | 12 | 260 | 156 | 80 |
| `slicer_quarter` (Quarter) | 12 | 380 | 156 | 60 |
| `a8d1e5c40b1f4c2fa002` (Month) | 12 | 480 | 156 | 100 |
| `a8d1e5c40b1f4c2fa003` (Location) | 12 | 620 | 156 | 32 |
| `a8d1e5c40b1f4c2fa005` (Sales Type) | 12 | 676 | 156 | 32 |
| `a8d1e5c40b1f4c2fa004` (Department) | 12 | 732 | 156 | 32 |

---

### STEP 5 — Update Sidebar Text Labels

For each `label_*` text box in the sidebar, update color to white `#FFFFFF` and change
font to 8pt Segoe UI bold/caps style. Also reposition to match the slicer positions above.

Approximate positions for labels (each is 156×16):

| Label file | New y position | New text content |
|------------|---------------|-----------------|
| `label_year` | 244 | `YEAR` |
| `label_quarter` | 364 | `QUARTER` |
| `label_month` | 464 | `MONTH` |
| `label_location` | 604 | `LOCATION` |
| `label_sales_type` | 660 | `SALES TYPE` |
| `label_department` | 716 | `DEPARTMENT` |

All labels: x=12, width=156, height=16.

For each label visual.json, in the `paragraphs[0].runs[0]` section:
- Set `fontColor` to `#8AAFC8` (light blue for sidebar labels)
- Set `fontSize` to `8` 
- Set `bold` to `true`

---

### STEP 6 — Restyle KPI Cards

The five KPI card visuals are:

| Visual ID | KPI |
|-----------|-----|
| `b8d1e5c40b1f4c2fa001` | Net Revenue |
| `b8d1e5c40b1f4c2fa003` | Gross Profit |
| `b8d1e5c40b1f4c2fa005` | Operating Profit |
| `b8d1e5c40b1f4c2fa006` | Net Profit |
| `b8d1e5c40b1f4c2fa004` | Gross Margin % |

**Reposition all KPI cards** — shift them right to start at x=196 (just past the 180px sidebar):

| Visual | New x | y | width | height |
|--------|-------|---|-------|--------|
| `b8d1e5c40b1f4c2fa001` | 196 | 68 | 200 | 100 |
| `b8d1e5c40b1f4c2fa003` | 408 | 68 | 200 | 100 |
| `b8d1e5c40b1f4c2fa005` | 620 | 68 | 200 | 100 |
| `b8d1e5c40b1f4c2fa006` | 832 | 68 | 200 | 100 |
| `b8d1e5c40b1f4c2fa004` | 1044 | 68 | 220 | 100 |

For each card, in the `objects` section update:
- `value.fontSize` → `"22D"`
- `value.bold` → `"true"`
- `value.fontColor` → solid color `#1B2A3B`
- `label.show` → `"true"` (turn on the label/title)
- `label.fontSize` → `"9D"`
- `label.fontColor` → solid color `#64748B`
- Card background → white `#FFFFFF`
- Border → enabled, color `#DDE6EF`

---

### STEP 7 — Restyle and Reposition Charts

All four charts need to be shifted right and down to accommodate the sidebar and KPI cards.
The KPI cards now end at y=168 (y=68 + height=100). Add 12px gap → charts start at y=180.
Charts start at x=196. Chart area width = 1084px (1280 - 196 - 0).

**New positions:**

| Visual ID | Type | New x | New y | New width | New height |
|-----------|------|-------|-------|-----------|------------|
| `c8d1e5c40b1f4c2fa001` | clusteredBarChart (Revenue/COGS) | 196 | 184 | 556 | 364 |
| `c8d1e5c40b1f4c2fa002` | clusteredColumnChart (Op/Net Profit) | 764 | 184 | 516 | 364 |
| `c8d1e5c40b1f4c2fa003` | donutChart (Location Mix) | 196 | 560 | 416 | 388 |
| `c8d1e5c40b1f4c2fa004` | **Convert to barChart** (Sales Type) | 624 | 560 | 656 | 388 |

For `c8d1e5c40b1f4c2fa004`:
- Change `visualType` from `"pieChart"` to `"clusteredBarChart"`
- This creates the ranked horizontal bar chart as shown in the mockup

For all charts, update `objects` to set:
- Chart background: white `#FFFFFF`  
- Plot area background: transparent
- Data colors: follow the palette (primary `#1D3557`, secondary `#3A7ABF`, teal `#17A2B8`)
- Title font: 10pt bold `#1B2A3B`
- Axis label font: 9pt `#64748B`

---

### STEP 8 — Update Section Title Text Labels for Charts

Add a text box visual above each chart card showing its section title in small-caps style.
Each text box: height=20, x matching the chart, y = chart_y - 22.

Example for the bar chart section title (create new visual file `label_chart_revenue`):
```json
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "label_chart_revenue",
  "position": { "x": 196, "y": 162, "z": 5000, "height": 20, "width": 556, "tabOrder": 2000 },
  "visual": {
    "visualType": "textbox",
    "objects": {
      "general": [{ "properties": { "paragraphs": [{ "runs": [{ "value": "REVENUE, COGS & GROSS PROFIT", "textStyle": { "fontFamily": "Segoe UI", "fontSize": "9pt", "bold": true, "color": { "solid": { "color": "#1B2A3B" } } } }] }] } }]
    }
  }
}
```
Create similar labels for the other three charts.

---

### STEP 9 — Update Header Area

The header logos (images at x=0 and x=144) and the header shape should be updated:

1. The two logo images: keep their current image bindings, but resize:
   - Al Jazeera logo (`ddeb8095ec02c8e0889d`): x=8, y=8, width=100, height=36
   - Divider shape (`99e2945f7f0a56baa921`): x=112, y=10, width=2, height=32
   - Canon logo (`712fe860d7624baeec6b`): x=118, y=10, width=56, height=32

2. The white rounded-rectangle background behind the logos should remain — make sure
   it covers x=4 to x=178, y=4 to y=50 (fill white, rounded).

3. The header shape `2ad649c3a5ab0c650550` (the title area): update fill color to `#1B2A3B` (dark navy).

4. The title text box `ddcc26fde44df8da70ba`: set to show "Financial Summary" in white 18pt bold,
   with subtitle "Track revenue, margin, location mix and operating performance at a glance."
   in `#8AAFC8` at 9pt.

---

### STEP 10 — Add Teal Active State Bar in Sidebar

Add a thin teal rectangle to visually indicate the active page in the sidebar:
```
visual name: sidebar_active_bar
x: 0, y: 200, z: 100, width: 4, height: 32
fill color: #17A2B8
```

---

## What NOT to Modify

- `Canon Financial Report.SemanticModel/` — do not touch any model files
- `Canon Financial Report.pbip` — do not modify
- Any page other than `Financial summary` (page ID: `8c1c6f95c0c648c38b4a`)
- The data bindings/query sections inside each visual — only change `position` and `objects`
- The `b8d1e5c40b1f4c2fa002` card visual (it is currently off-canvas, leave it)

---

## Verification Checklist

After making all changes:

1. Open `Canon Financial Report - Design Preview/Canon Financial Report.pbip`
   in Power BI Desktop on your machine.

2. Navigate to the **Financial Summary** page.

3. Confirm:
   - [ ] Page background is light blue-gray (not white)
   - [ ] Left sidebar is dark navy
   - [ ] Year/Quarter/Month slicers appear as tile/button style
   - [ ] Location/Sales Type/Department appear as dropdown slicers
   - [ ] All 5 KPI cards are visible and styled (white card, colored label)
   - [ ] Revenue/COGS bar chart appears in top-left
   - [ ] Operating/Net Profit column chart in top-right
   - [ ] Location donut chart bottom-left
   - [ ] Sales Type **horizontal bar chart** (NOT pie chart) bottom-right
   - [ ] All text is readable (not too small, not clipped)

4. If Power BI Desktop shows a "broken visual" for the converted pie→bar chart,
   you may need to re-add the field binding manually (drag `Net Revenue` from
   the `_Measures` table onto the chart's Value field).

---

## Notes on Slicer Tile Styling

Power BI's tile slicer color properties have inconsistent JSON key names across versions.
If the `tiles` object approach above does not apply colors, try the following alternative
property names in the `objects` block of each slicer:

```json
"data": [{ "properties": { "mode": { "expr": { "Literal": { "Value": "'Tile'" } } } } }],
"items": [{
  "properties": {
    "background": { "solid": { "color": { "expr": { "Literal": { "Value": "'#243548'" } } } } },
    "fontColor": { "solid": { "color": { "expr": { "Literal": { "Value": "'#FFFFFF'" } } } } },
    "outline": { "expr": { "Literal": { "Value": "'None'" } } }
  }
}]
```

The selected tile teal highlight (`#17A2B8`) is most reliably set via the custom theme file
(already included in Step 1).

---

## Reference Images

Both reference images are in this folder:
- `Design Assets/target-mockup.png` — the Metricalist-inspired primary target
- `Design Assets/target-mockup-option1-light.png` — clean light layout reference

Read both images at the start of your session before beginning implementation.
