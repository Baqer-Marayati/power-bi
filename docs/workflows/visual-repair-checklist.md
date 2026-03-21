# Visual Repair Checklist

## Purpose

Use this checklist when a page or visual is broken, blank, misbound, or rendering the wrong story.

## Repair Sequence

1. Confirm the exact failing page and visual.
2. Read the page and visual JSON.
3. Identify the bound fields, measures, filters, and interactions.
4. Check whether the issue is report-side or model-side.
5. Fix the safest layer first.
6. Reopen the PBIP and verify with screenshots.

## Common Failure Types

- stale benchmark binding
- deleted or renamed measure
- dead field well reference
- invalid visual-level filter
- broken drillthrough carryover
- disconnected helper table dependency
- missing SAP-backed truth
- formatting/layout that hides valid content

## Report-Side Checks

Look for:
- invalid field references in visual JSON
- stale page or visual IDs
- leftover benchmark filters
- interaction mappings that still reference deleted visuals
- category labels or titles fighting each other
- slicer bindings pointing to provisional or dead columns

## Model-Side Checks

Look for:
- renamed or missing measures
- compatibility objects that should be temporary only
- relationships that no longer match the visual logic
- helper tables depending on other weak compatibility layers
- currency-format measures that are inconsistent with live report rules

## Preferred Fix Order

Use this order unless there is a clear reason not to:

1. remove stale report wiring
2. rebind the visual to valid existing semantic objects
3. simplify the visual if the original benchmark pattern is too fragile
4. add compatibility logic only if there is no safe direct source yet
5. revisit design polish only after the logic is stable

## Done Criteria

- the visual renders
- the visual tells the intended business story
- no avoidable compatibility workaround was left hidden
- the page remains consistent with benchmark layout rules
- the issue is reflected in `Project Memory` if it changed project truth
