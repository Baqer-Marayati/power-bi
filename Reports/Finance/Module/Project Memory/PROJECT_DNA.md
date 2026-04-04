# Project DNA

## Purpose
This is a Power BI financial reporting project for management reporting, centered on executive overview, P&L, revenue, cost, balance sheet, working capital, profitability, receivables, collections, and cash reporting.

## Active project (source of truth)
Use this folder as the active working project (paths are repo-relative; adjust drive if your clone differs):

- `Reports/Finance/Financial Report/`

Do not create parallel experiment folders unless explicitly needed.

## Design reference
Use the files inside:

- `Reports/Finance/Module/Design Benchmarks/`

`Design Benchmarks` is a living visual benchmark, not a fixed snapshot.

The report should stay aligned to the latest valid benchmark in `Design Benchmarks`, especially in:
- background color and surface treatment
- spacing and layout rhythm
- slicer and KPI card styling
- chart color palette
- overall CFO / management-report tone

As of March 20, 2026, `Design Benchmarks/Sample 2` is the active benchmark and strongest design reference.
Use it as the baseline report shell, not just as inspiration.

Portfolio-wide tokens and layout contracts also live under `Shared/Standards/` (`portfolio-visual-identity.md`, `page-layout-spec.md`, `portfolio-theme.tokens.json`).

## Main pages
The active working set in `pages.json` includes **10** pages:

1. `Executive Overview`
2. `Income Statement`
3. `Revenue Insights`
4. `Cost Structure`
5. `Balance Sheet`
6. `Working Capital Health`
7. `Profitability Drivers`
8. `Receivables`
9. `Collections`
10. `Cash Position`

Older benchmark-only pages (`Actual vs Budget`, `Cashflow`, and others listed in `PAGE_MAP.md`) remain **historical or deferred** unless explicitly reactivated.

## Design rules
- Preserve the active benchmark's page shell, surface treatment, and spacing system unless newer records clearly replace it.
- Keep spacing disciplined and avoid crowded layouts.
- Prefer refinement of the existing structure over random redesign.
- Maintain a CFO / management-report tone rather than a flashy dashboard style.
- Keep hierarchy clear: filters first, KPIs second, analysis visuals third, detailed statement/table last.

## Taste learned so far
- The preferred visual direction is calm, structured, and executive-facing rather than decorative.
- The user prefers a clean report canvas with strong framing, restrained color, and clear page zoning.
- KPI cards should feel balanced and legible before they feel dramatic.
- Slicers work better as a left-rail control system than as scattered controls across the page.
- The preferred slicer treatment is a clean label above a simple dropdown box, not a crowded combined control.
- Visual polish should feel intentional and quiet; if a layout move calls attention to itself, it is probably too much.
- Sample 2 is not just an inspiration image set; it is the closest expression of the taste we are trying to preserve.

## Source of truth
The financial PBIP project is the source of truth.

## Lessons learned
- The old sales-report redesign attempts felt mechanical and should not be reused as the design base.
- Direct PBIP editing is useful, but only when guided by a clear visual reference.
- The correct design language already exists in the financial project and in the benchmark records.
- Future work should focus on consistency, structure, and polish rather than inventing a new style.
- Theme-only or light PBIP JSON nudges are not enough when old visuals already contain strong local formatting.
- Failed image-shell overlays should not be reused; Power BI Desktop did not accept them reliably and they caused placeholder issues.
- The more effective path is to start from the strongest benchmark PBIP and wire it to the active semantic model.
- `Design Benchmarks/Sample 2` proved materially better than screenshots alone because it exposes the real report shell, theme, page rhythm, and visual object settings.
- Small formatting tweaks alone often do not meaningfully change a Power BI page when the visuals already carry strong local formatting.
- Structural changes inside the report definition are often more effective than theme nudges when trying to make the UI actually look different.
- Layout polish should be treated as pattern work, not screenshot work: repeated slicers, KPI cards, and containers should be fixed as systems.
- Left-rail slicers need spacing rhythm, ordering, and label treatment to feel finished; changing only font size is usually not enough.
- IQD formatting changes can affect card fit and should be considered part of layout polish, not only data formatting.

## Current direction
The report shell is aligned to Sample 2 while running on the Al Jazeera SAP semantic model. Extension pages (working capital, profitability, AR/collections/cash) follow the same visual language.

The semantic-model strategy remains:
1. keep the Sample 2 shell discipline where it applies
2. preserve valid SAP-backed facts and relationships
3. create compatibility aliases only where needed
4. prefer safe report rewires over fragile custom relationships
5. replace provisional compatibility logic with real SAP-backed facts over time

## Working method learned so far
The most effective working pattern for this project is:
1. read Project Memory first
2. inspect the relevant PBIP page and visual JSON
3. decide whether the issue is report wiring, model logic, or missing source truth
4. fix the safest layer first
5. reopen the PBIP and verify with screenshots
6. update Project Memory before closing the thread

For file handoff and review:
1. keep the **PBIP** project as the editable master
2. create a **PBIX** only when a lighter single-file review copy is useful
3. review from the **PBIX** if needed
4. continue all actual development in the **PBIP**

This project responds better to deliberate, evidence-based passes than to broad speculative rewrites.

## Next priority
1. Keep the **10** active pages stable: regression-check slicer interactions and IQD formatting after any model change.
2. Use `Design Benchmarks/Sample 2` and `Shared/Standards/page-layout-spec.md` when adding or reshaping pages.
3. If reviving deferred benchmark pages, document the decision in `DECISIONS.md` and `PAGE_MAP.md` first.

## Working rule for future threads
When a new agent thread starts:
1. open this file first
2. open the other files in `Project Memory`: `DECISIONS.md` and `REFERENCE.md`
3. inspect `Financial Report`
4. re-check `Design Benchmarks` before making visual decisions
5. update the memory files when the benchmark changes meaningfully
6. read `CURRENT_STATUS.md`, `MODEL_NOTES.md`, and `NEXT_STEPS.md` before deep model edits
7. treat the KPI row and left rail on the five core finance pages as **systems**, not one-off formatting tasks
