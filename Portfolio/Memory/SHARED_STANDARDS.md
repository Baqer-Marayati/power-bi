# Shared Standards

## Purpose

Use this file to record standards that should apply across more than one report module.

Examples:
- shared color systems
- naming rules
- date logic conventions
- reusable KPI conventions
- layout standards that should travel across departments

As of March 22, 2026, most detailed standards still live inside the Finance module and can be promoted here later when reuse becomes real.

## 2026-03-27 - Portfolio Visual Identity Standard

- All report modules must use one unified visual identity derived from the Finance report baseline.
- This includes:
  - page/background colors
  - chart and series color palette
  - KPI card styling
  - typography and visual hierarchy patterns
  - common spacing and layout rhythm where practical
- New modules (for example `Reports/Inventory`) should inherit this standard from the start, before custom styling.
- Any intentional deviation must be documented in that module's `Project Memory/DECISIONS.md` with a business reason.
- Token file: `../Shared/Standards/portfolio-theme.tokens.json`. Canonical theme JSON copy: `../Shared/Themes/Custom_Theme49412231581938193.json` (see `../Shared/Themes/README.md`). `Reports/Finance` remains the primary reference implementation for how those tokens appear in a live PBIP.

## 2026-08-28 - Number Formatting Standard (six Fabric reports)

- All number rendering across the six `Fabric/DevelopmentWorkspace/` reports follows
  `../Shared/Standards/fabric-reports-number-formatting.md`: the model formats (static TMDL
  format strings — IQD money, `0.00%` percents, `#,0` counts), the visual displays (money-total
  cards fixed bn + 3dp, exact-IQD exemptions, percent cards explicit 2dp, table typography
  14/13/12-bold/bold-totals, money chart labels M→1dp / bn→3dp).
- Enforced by the NUMBER FORMATTING section of `../scripts/audit-report-consistency.py`.
- Sibling layout standard: `../Shared/Standards/fabric-reports-layout-standard.md`.
