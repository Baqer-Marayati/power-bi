# Currency Formatting Standard

## Purpose

This project should present financial values consistently in IQD unless a documented exception exists.

## Core Rule

- Do not leave mixed USD-style formatting on benchmark-derived visuals when the business truth is IQD.
- Treat IQD formatting as both a business rule and a layout rule.

## Why It Matters

- business correctness depends on the right currency presentation
- card widths and visual balance change when the format changes
- compact shorthand can hide the real value scale if used carelessly

## Preferred Presentation

- show IQD consistently across report pages
- prefer explicit values with two decimals when the business-facing design needs them
- avoid relying blindly on Power BI compact `bn / M` style shorthand

## Practical Rules

- after format changes, recheck KPI card fit and label spacing
- confirm the value still reads cleanly on the page
- ensure benchmark-derived pages do not silently retain dollar-format strings
- if a special-case currency display is needed, document why

## Validation

After touching currency formatting:
- recheck the top KPI cards
- recheck narrow cards and dense tables
- confirm the page still matches the expected executive reporting tone

## Source Of Truth

For live project-specific formatting reality, also read:
- `Project Memory/DECISIONS.md`
- `Project Memory/CURRENT_STATUS.md`
- `Project Memory/POWERBI_PATTERNS.md`
