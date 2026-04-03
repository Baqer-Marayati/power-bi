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
- Token file: `Shared/Standards/portfolio-theme.tokens.json`. Canonical theme JSON copy: `Shared/Themes/Custom_Theme49412231581938193.json` (see `Shared/Themes/README.md`). `Reports/Finance` remains the primary reference implementation for how those tokens appear in a live PBIP.
