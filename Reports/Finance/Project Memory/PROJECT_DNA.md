# Project DNA

## Purpose
This is a Power BI financial reporting project for management reporting, centered on executive overview, income statement, revenue insights, cost structure, balance sheet reporting, and controlled recovery of a small number of remaining benchmark pages.

## Active Project
Use this folder as the active working project:
- `/Users/baqer/Dropbox/Work/PowerBI/Reporting Hub/Reports/Finance/Financial Report`

Do not create parallel experiment folders unless explicitly needed.

## Design Reference
Use the files inside:
- `/Users/baqer/Dropbox/Work/PowerBI/Reporting Hub/Reports/Finance/Design Benchmarks`

`Design Benchmarks` is a living visual benchmark, not a fixed snapshot.
It may receive new screenshots, templates, inspirations, and updated design references over time.

The report should stay aligned to the latest valid benchmark in `Design Benchmarks`, especially in:
- background color and surface treatment
- spacing and layout rhythm
- slicer and KPI card styling
- chart color palette
- overall CFO / management-report tone

As of March 20, 2026, `Design Benchmarks/Sample 2` is the active benchmark and strongest design reference.
Use it as the baseline report shell, not just as inspiration.

## Main Pages
The active working set currently includes:
- `Executive Overview`
- `Income Statement`
- `Revenue Insights`
- `Cost Structure`
- `Balance Sheet`

The report also retains two active recovery pages:
- `Actual vs Budget`
- `Cashflow`

Other benchmark-shell pages remain historical or deferred unless the user explicitly reactivates them.

## Design Rules
- Preserve the active benchmark's page shell, surface treatment, and spacing system unless newer records clearly replace it.
- Keep spacing disciplined and avoid crowded layouts.
- Prefer refinement of the existing structure over random redesign.
- Maintain a CFO / management-report tone rather than a flashy dashboard style.
- Keep hierarchy clear: filters first, KPIs second, analysis visuals third, detailed statement/table last.

## Taste Learned So Far
- The preferred visual direction is calm, structured, and executive-facing rather than decorative.
- The user prefers a clean report canvas with strong framing, restrained color, and clear page zoning.
- KPI cards should feel balanced and legible before they feel dramatic.
- Slicers work better as a left-rail control system than as scattered controls across the page.
- The preferred slicer treatment is a clean label above a simple dropdown box, not a crowded combined control.
- Visual polish should feel intentional and quiet; if a layout move calls attention to itself, it is probably too much.
- Sample 2 is not just an inspiration image set; it is the closest expression of the taste we are trying to preserve.

## Source Of Truth
The financial PBIP project is the source of truth.
The earlier sales-report experiments are no longer part of the active workflow.

## Lessons Learned
- The old sales-report redesign attempts felt mechanical and should not be reused as the design base.
- Direct PBIP editing is useful, but only when guided by a clear visual reference.
- The correct design language already exists in the financial project and in the benchmark records.
- Future work should focus on consistency, structure, and polish rather than inventing a new style.
- Trying to gradually restyle the legacy `Financial Report` report produced weak visual change and wasted time.
- Theme-only or light PBIP JSON nudges are not enough when old visuals already contain strong local formatting.
- Failed image-shell overlays should not be reused; Power BI Desktop did not accept them reliably and they caused placeholder issues.
- The more effective path is to start from the strongest benchmark PBIP and wire it to the active semantic model.
- `Design Benchmarks/Sample 2` proved materially better than screenshots alone because it exposes the real report shell, theme, page rhythm, and visual object settings.
- Small formatting tweaks alone often do not meaningfully change a Power BI page when the visuals already carry strong local formatting.
- Structural changes inside the report definition are often more effective than theme nudges when trying to make the UI actually look different.
- Layout polish should be treated as pattern work, not screenshot work: repeated slicers, KPI cards, and containers should be fixed as systems.
- Left-rail slicers need spacing rhythm, ordering, and label treatment to feel finished; changing only font size is usually not enough.
- IQD formatting changes can affect card fit and should be considered part of layout polish, not only data formatting.

## Current Direction
The goal is now to rebuild the report from the active benchmark shell rather than incrementally polishing the old layout.
The report should become visually identical or as close as possible to `Design Benchmarks/Sample 2`, while running on the Al Jazeera SAP semantic model.

The work sequence should be:
1. use the benchmark report shell
2. attach it to the active semantic model
3. remap visuals, measures, and fields to the SAP model
4. then polish page-by-page

As of March 22, 2026, the report is in a hybrid but much narrower state:
- the five core finance pages are visually stable and run on SAP-backed logic
- the top KPI row on those five pages is now a shared, stabilized pattern
- `Actual vs Budget` and `Cashflow` remain the main recovery pages because they still depend on compatibility or provisional logic
- older benchmark-shell pages remain in project history, but are not part of the active operating queue

The current semantic-model recovery strategy is:
1. keep the Sample 2 shell
2. preserve valid SAP pages
3. create compatibility aliases only where needed
4. prefer safe report rewires over fragile custom relationships
5. replace provisional compatibility logic with real SAP-backed facts over time

## Working Method Learned So Far
The most effective working pattern for this project is:
1. read Project Memory first
2. inspect the relevant PBIP page and visual JSON
3. decide whether the issue is report wiring, model logic, or missing source truth
4. fix the safest layer first
5. reopen the PBIP and verify with screenshots
6. update Project Memory before closing the thread

For file handoff and review:
1. keep the `PBIP` project as the editable master
2. create a `PBIX` only when a lighter single-file review copy is useful
3. review from the `PBIX` if needed
4. continue all actual development in the `PBIP`

This project responds better to deliberate, evidence-based passes than to broad speculative rewrites.

## Next Priority
Refine these pages first:
1. `Executive Overview`
2. `Income Statement`
3. `Revenue Insights`
4. `Cost Structure`
5. `Balance Sheet`

Use `Design Benchmarks/Sample 2` as the benchmark for all five.

Current repair priority for the remaining broken benchmark pages is:
1. `Actual vs Budget`
2. `Cashflow`

## Working Rule For Future Threads
When a new Codex thread starts:
1. open this file first
2. open the other files in `Project Memory`: `DECISIONS.md` and `REFERENCE.md`
3. inspect `Financial Report`
4. re-check `Design Benchmarks` before making visual decisions
5. update the memory files when the benchmark changes meaningfully
6. read `CURRENT_STATUS.md`, `MODEL_NOTES.md`, and `NEXT_STEPS.md` before touching broken benchmark pages
7. treat the KPI row on the five core finance pages as one system, not five separate formatting tasks
