# Semantic Model Change Checklist

## Purpose

Use this checklist when editing TMDL or changing the semantic model that supports the report.

## When To Use

Use this for:
- measure additions or rewrites
- compatibility table creation or cleanup
- relationship changes
- column or table renames
- format-string changes
- source-truth replacements for provisional logic

## Change Sequence

1. Confirm the business requirement.
2. Identify the exact tables, measures, or relationships involved.
3. Check whether a report-side rewire would be safer.
4. Change only the model objects needed.
5. Reopen the PBIP immediately after the model edit.
6. Validate the affected pages and warnings.
7. Update `Project Memory` with any durable model truth.

## Safety Rules

- Prefer real SAP-backed facts over compatibility layers when practical.
- Avoid risky relationship experimentation unless clearly justified.
- Be careful with compatibility objects that depend on other compatibility objects.
- Keep provisional logic clearly identifiable.
- Treat format-string edits as layout-sensitive, not cosmetic only.

## Verification Checks

After a model change, verify:
- the PBIP still opens
- no duplicate-measure or load blockers were introduced
- warning icons did not appear on core tables unexpectedly
- the target visuals bind correctly
- IQD formatting is still correct and readable

## Model Files To Check

- `Financial Report/Financial Report.SemanticModel/definition/model.tmdl`
- `Financial Report/Financial Report.SemanticModel/definition/relationships.tmdl`
- `Financial Report/Financial Report.SemanticModel/definition/tables/`

## Escalation Rule

If a model change introduces instability, stabilize the PBIP first before continuing layout polish or broad follow-up edits.
