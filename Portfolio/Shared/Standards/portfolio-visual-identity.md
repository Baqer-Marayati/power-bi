# Portfolio Visual Identity

This file defines the shared visual identity that should be reused across all report modules.

## Baseline Source

- Reference implementation: `Reports/Finance`
- Applies to all modules unless an approved exception is documented.

## Required Shared Theme Areas

- Page background and canvas colors
- Chart/series categorical palette
- Positive/negative and variance color semantics
- KPI card styling (background, border, typography hierarchy)
- Slicer and panel styling
- Title/subtitle and label typography conventions

## Canonical Token Source

- **Shared canonical copy (for diff / propagation):** `Shared/Themes/Custom_Theme49412231581938193.json` (see `Shared/Themes/README.md`)
- Theme resource (live PBIP registration): `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.Report/StaticResources/RegisteredResources/Custom_Theme49412231581938193.json`
- Report registration: `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.Report/definition/report.json`
- Page/card implementation reference:
  - `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.Report/definition/pages/*/page.json`
  - `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.Report/definition/pages/*/visuals/*/visual.json`

## Canonical Theme Tokens (Finance-derived)

- **Primary chart palette (in order):**
  - `#1F4E79`
  - `#5B8DB8`
  - `#9CC3E6`
  - `#C5DCEF`
  - `#2E6DA4`
  - `#7AADCE`
  - `#163A5C`
  - `#3D7DB5`
  - `#AACFE8`
  - `#DDE9F5`
- **Page background:** `#F8FBFF`
- **Theme background (brand):** `#1F4E79`
- **Background neutral:** `#D6E8F5`
- **KPI card background:** `#FFFFFF`
- **KPI card border:** `#C9D5E3`
- **Primary text:** `#2E3A42` (page labels/titles in active report)
- **Semantic colors:** good `#6AA312`, neutral `#BB8F06`, bad `#C13737`

## Canonical KPI Card Style

- Border radius: `4`
- Value text: size `18`, not bold
- Title text: size `10`, Segoe UI family
- Top accent line style (implemented via drop shadow):
  - color `#1F4E79`
  - position `Outer`
  - angle `270`
  - distance `4`
  - blur `0`
  - spread `0`
  - transparency `0`

## Adoption Rule

- New modules must adopt this identity before adding module-specific styling.
- Module-specific deviations require a documented decision in that module memory.

## Implementation Notes

- Use `Shared/Standards/portfolio-theme.tokens.json` as the machine-readable source when creating or adjusting report themes.
- If legacy visuals in Finance still carry older one-off colors, treat the token set in this file as the target state for normalization.
