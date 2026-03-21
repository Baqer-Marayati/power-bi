# Data Sources

## Current Model Direction

The active report is intended to run on the Al Jazeera SAP-backed semantic model.

The project is in a hybrid state:
- core live pages are wired to SAP-backed logic
- some benchmark-derived pages may still rely on provisional compatibility objects during repair

## Primary Technical Source

The semantic-model definition lives in:
- `Financial Report/Financial Report.SemanticModel/definition`

Core files:
- `model.tmdl`
- `relationships.tmdl`
- table definitions under `tables/`

## Business Context

The report covers management financial reporting areas such as:
- executive overview
- income statement / P&L
- revenue insights
- cost structure
- balance sheet
- budget and cashflow views where available

## Important Notes

- SAP-backed logic should be preferred over provisional compatibility logic whenever practical.
- Compatibility tables or measures may exist temporarily to keep benchmark-shell pages working.
- Currency presentation should follow IQD formatting rules across the report.

## Deeper Technical Notes

For live technical truth, use:
- `Project Memory/MODEL_NOTES.md`
- `Project Memory/DATA_GAPS.md`
- `Project Memory/CURRENT_STATUS.md`
