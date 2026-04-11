# Decisions

## 2026-04-04 — PAPERENTITY company: remove logos and divider from all report pages

- All PAPERENTITY reports (Paper Financial Report, Paper Sales Report, Paper Service Report, Paper Inventory Report, Paper Data Exchange Report) must have **no top-right logo group** on any page.
- Specifically removed: Aljazeera logo image, Canon logo image, vertical divider shape, and their parent group ("Group 1") from every page.
- 108 visual folders removed across 27 pages.
- The equivalent CANON reports are **not** affected — Canon reports keep their logo group.
- If new pages are added to any PAPERENTITY report, do **not** add the logo/divider group.
- This is a permanent company-level branding decision for PAPERENTITY.

## 2026-03-26 — Color palette switch: teal → navy blue

- Data colors changed from teal/green base palette to a navy-blue base palette matching the approved sample screenshot.
- Primary three: `#1A3C5C` (deep navy), `#2F75B6` (medium blue), `#9DC3E6` (light blue).
- Page background changed from `#F4F7F5` (light greenish-gray) to `#EBF0F7` (cool light blue-gray) on all 7 pages.
- Theme root background/backgroundLight/backgroundNeutral updated to match.
- Visual card backgrounds, borders, typography, layout, and all bindings left untouched.

## Active Project
- Active working projects:
  - `C:\Work\reporting-hub\Reports\Finance\Companies\CANON\Canon Financial Report`
  - `C:\Work\reporting-hub\Reports\Finance\Companies\PAPERENTITY\Paper Financial Report`
- Do not create parallel experiment folders unless explicitly needed.

## Domain Contract Alignment
- Finance now follows the portfolio domain-first contract with dedicated `Core/`, `Companies/`, and `scripts/` areas.
- Company PBIPs under `Companies/` are the active source paths for edits; do not route new work through the older pre-portfolio folder layout.

## Source Of Truth
- The financial PBIP project is the source of truth.
- The older sales-report experiments are not part of the active workflow.

## Server Safety Rule
- This server hosts the production SAP database. Treat every action as production-critical.
- Never modify Windows services, registry, scheduled tasks, firewall rules, execution policies, or system-level configuration.
- Never touch files, folders, ports, or processes outside `C:\Work\reporting-hub`.
- Never install, update, or remove software without explicit user approval in the current conversation.
- Never kill processes that were not launched by the automation scripts in this repo.
- All automation scripts must be read-only and passive (open apps, take screenshots, save files inside the repo).
- When in doubt, ask before acting.

## Delivery Format Rule
- `PBIP` remains the only working source of truth for this project.
- `PBIX` may be produced as a temporary review or transfer snapshot when a single-file handoff is more practical.
- Do not treat a review `PBIX` as the editable master.
- If a `PBIX` is created for review, all real changes must still be made back in the `PBIP` project.
- Use `PBIX` for convenience; use `PBIP` for development truth.
- User review should happen from the packaged export artifact, not from the raw `PBIP` folder.
- After any meaningful report edit that the user is expected to inspect, rebuild `Exports/Server Packages/Financial Report - ready.zip` before asking the user to review.
- Do not rely on the user to manually zip, copy, or package the report after edits. Packaging is part of done-ness.
- Keep zip packaging available every time (`Financial Report - ready.zip`) because it is still needed periodically.
- Use the relevant company PBIP under `Companies/CANON/` or `Companies/PAPERENTITY/` as the local preview working path when validating recent edits between packaging runs.

## Review And Sync Rule
- Treat the user-reviewed Desktop result as the strongest evidence of what Power BI really renders.
- If the user manually adjusts layout in Desktop and approves it, sync that Desktop-generated report definition back into source instead of forcing an older Codex-only grid or pattern.
- Do not assume that a packaged zip and the source PBIP are in sync unless the package was rebuilt after the latest change.
- If a user review screenshot conflicts with what the source files seem to suggest, trust the screenshot as the first debugging signal and verify the artifact chain.

## Project Memory Rule
- `PROJECT_DNA.md` is a living project memory.
- Update it only at meaningful milestones or when an important conclusion changes.
- Do not turn it into a changelog.
- Keep the memory files together inside a dedicated `Project Memory` folder.

## Design Direction
- Use `Design Benchmarks` as the visual benchmark.
- Use the strongest available benchmark PBIP as the design base when a full benchmark file exists.
- Prefer benchmark-led rebuild over trying to slowly restyle heavily formatted legacy visuals.
- Preserve a CFO / management-report tone and avoid flashy dashboard styling.
- Treat repeated layout elements such as slicer rails and KPI rows as reusable patterns that should be standardized across pages.
- A shared branding lockup is now part of the approved design system for the first five core finance pages: transparent `Al Jazeera Machinery` logo, thin vertical separator, and transparent `Canon` logo in the top-right header zone.
- Match the user-approved placement rather than improvising: keep the lockup inside the white page canvas with visible top/right breathing room and do not push it flush against the page edge.
- The approved implementation method is the Power BI Desktop-generated pattern from the user-reviewed working file: registered image resources plus a grouped `image + divider shape + image` lockup on each target page.
- Apply that branding lockup only when explicitly appropriate for the page set in scope; as of March 22, 2026 it is intentionally applied to the first five pages and intentionally not yet applied to `Working Capital Health` or `Profitability Drivers`.

## Records Benchmark Rule
- `Design Benchmarks` is a living benchmark folder.
- New screenshots, templates, and taste changes may override older visual assumptions.
- Before major design work, re-check `Design Benchmarks`.
- If the benchmark changes meaningfully, update `REFERENCE.md` and `PROJECT_DNA.md`.

## Active Benchmark
- As of March 20, 2026, `Design Benchmarks/Sample 2` is the active benchmark.
- It should be treated as the baseline report shell for layout, theme, and visual language.
- Screenshots are useful, but a benchmark PBIP is materially better and should be preferred whenever available.

## Logic Before Styling
- Priority is logic first, styling second.
- Keep the current Sample 2 visual direction unless a later benchmark update replaces it.
- Do not spend time on cosmetic tuning while benchmark pages still have broken bindings, missing measures, or invalid semantic objects.

## Broken Page Rule
- Broken Sample 2 pages are to be kept and repaired, not deleted.
- If a benchmark page is visually correct but semantically broken, preserve the shell and rewire the bindings to SAP-backed facts and measures.
- Prefer report-side rewires and safe semantic-model aliases before attempting risky custom relationship additions.

## Revenue Insights — Item business type rule
- **Revenue by item business type** on **Revenue Insights** groups revenue by **`Fact_SalesDetail[Item Business Type]`**, sourced from SAP **`OITM.U_BusinessType`** (item master UDF) in the sales-detail SQL, with blank UDF values coalesced to **`Unassigned`**. The chart axis binds that column with **`Sales Revenue`**; do not replace this with a static in-model segment map unless product explicitly requests it.

## Revenue Grouping Source Lock (2026-03-26)
- Keep `Revenue Insights` category grouping on `Fact_SalesDetail[Item Business Type]` (from `OITM.U_BusinessType`), not `ItemGroupName`.

## Final Page Set
- As of April 1, 2026, the report contains 10 live pages:
- `Financial summary`
- `Profit & loss`
- `Sales & revenue`
- `Operating expenses`
- `Balance sheet`
- `ROI`
- `Accounts receivable`
- `Accounts payable`
- `Collections`
- `Cash & bank`
- Pages outside that set are no longer part of the active report shell and should not be reintroduced unless explicitly requested.
- The last 3 pages were transferred from the Aljazeera Master Model and adapted to the Financial Report design system.

## Slicer And Open-State Contract (2026-03-25)
- `Dim_Date` slicer years are intentionally constrained to start at `2026`.
- Main left-rail order uses `Sales Type` above `Department` (swapped from earlier order).
- Default handoff/open behavior is blank until refresh: package/report flow should strip semantic-model cache unless explicitly overridden.

## Conformed Slicer Dimension Rule
- Sidebar slicers (`Year/Quarter/Month/Location/Sales Type/Department`) must remain bound to conformed dimensions that cover all relevant facts, not single-fact subsets.
- Keep dimension keys normalized (`UPPER(TRIM(...))`) in source extracts and use deterministic one-row-per-code dimension outputs to avoid post-refresh filter drift.

## SAP Domain Rule
- Assume anything needed from SAP is available unless proven otherwise.
- Do not wait for the user to hand-build AR, AP, cashflow, commitment, or budget domains manually.
- It is acceptable to derive new SAP-backed fact tables directly from SAP Business One tables when needed.

## Budget Rule
- As of March 20, 2026, native SAP budget is not yet confirmed inside the semantic model.
- The current `glBudgetEntries` layer is a compatibility placeholder, not confirmed real budget.
- Budget visuals may be wired temporarily for layout continuity, but they should be clearly treated as provisional until a real SAP budget source is implemented.

## Currency Rule
- All report pages should use Iraqi dinar presentation consistently.
- If a benchmark page or imported visual still uses dollar formatting, convert it to IQD formatting during repair.
- Do not leave the first page set in IQD and the benchmark-derived page set in USD.
- Treat IQD formatting as both a business rule and a layout rule, because the suffix affects visual fit and card balance.

## PBIP Editing Rule
- PBIP report JSON can be edited directly when the visual pattern is understood and the change is deliberate.
- Report-side visual rewires are generally safer than semantic relationship experimentation.
- Broad style improvements should be applied as repeated-pattern fixes, not isolated screenshot patches.
- If a styling issue survives a basic size tweak, prefer structural changes such as moving titles outside controls or standardizing repeated geometry.
- Do not keep guessing at a Power BI structure that has not yet been proven in a real Desktop-generated file. When possible, create or inspect one known-good example in Desktop first, then replicate that pattern exactly.

## KPI Row Rule
- Treat the top KPI row on the first five pages as a shared component, not as isolated cards.
- Do not mix the older `labels/categoryLabels` card style with the newer hidden-label + explicit-title pattern on adjacent KPI cards.
- Monetary KPI cards may use dedicated numeric `... Card Display` measures when Power BI ignores compact-number precision settings.
- Percent and count cards in the same row should keep the same visual structure and typography even if they continue to bind directly to the base measure.
- If a future tweak threatens card stability, prefer preserving the current unified KPI-row pattern over chasing one-off formatting tricks.

## Semantic Safety Rule
- Be cautious with compatibility aliases that bridge domains in both directions.
- If a compatibility measure creates a circular-feeling dependency path, prefer rewiring the report visual directly to the source table instead of keeping the alias.
- Do not blindly add custom relationships in TMDL when Power BI has already shown invalid-column-ID failures for the same approach.

## Memory Maintenance Rule
- The `Project Memory` folder must be updated whenever the semantic model, page-repair status, benchmark direction, or major assumptions change.
- Future threads should treat memory updates as part of done-ness, not as an optional last step.
- Add new markdown files when they materially improve continuity for later build threads.
- Consolidate durable discoveries into the right memory files instead of letting them remain trapped in chat history.
- Capture both positive patterns and failure modes. In this project, avoiding repeated mistakes is as important as recording what worked.

## Documentation Layer Rule
- Keep a repo-facing documentation layer at the root for GitHub orientation.
- Keep a root `AGENTS.md` file as the shortest cross-agent onboarding entrypoint.
- Keep `docs/foundation.md` as the main operating-foundation file for tools, integrations, environment facts, and startup context.
- Use `README.md` for a fast repo overview and key links.
- Use `docs/agent-manual.md` for the stable AI/operator manual.
- Use `docs/` for stable setup, structure, page-purpose, and data-context documentation.
- Use `docs/workflows/` for repeatable operating procedures.
- Use `docs/standards/` for durable formatting, naming, and layout rules.
- Do not duplicate active status tracking across every doc; current truth still belongs in `Project Memory`.
- Keep `CHANGELOG.md` milestone-level only.
- Keep `AGENTS.md`, `README.md`, `docs/`, and `Project Memory` aligned so another agent can recover context without chat history.

## GitHub Tracking Rule
- Use GitHub Issues as the active task-tracking layer for meaningful repair, model, design, and documentation work.
- Keep labels and milestones aligned to the real project state rather than using GitHub as a generic backlog dump.
- Prefer updating or closing an existing issue over creating duplicate issues for the same active page or model problem.
- The local terminal `gh` workflow is now part of the approved setup, so future GitHub issue management does not need to be done manually in the browser unless account settings or new permissions are involved.
- GitHub commits and pushes should happen proactively at natural milestones, not only when explicitly requested.
- Do not commit every tiny iteration, but do commit after meaningful successful work such as:
- a stable report repair
- an approved visual/layout milestone
- a recovered package/openability fix
- a meaningful model or documentation pass
- Use judgment: keep history useful and clean, and avoid both over-committing noise and under-committing important progress.

## Rebuild Rule
- If the existing report is resisting design changes, do not spend multiple passes on low-impact theme edits.
- Start from the benchmark report layer and rewire it to the active semantic model instead.
- Rebuild the report shell first, then remap fields and measures page by page.

## Report Swap Rule
- A full report-folder swap is acceptable when the benchmark PBIP is the intended base and the semantic model path is rewired correctly in `definition.pbir`.
- Keep a backup of the prior `.Report` folder before doing a full swap.

## Receivables / Collections / Cash Position Layout
- Receivables table (`recv_table`) height: **630px** (user-adjusted from 700).
- Receivables page uses 6 KPI percentage cards (Future, 0-30, 30-60, 60-90, 90-120, 120+) at 158px wide, aligned with table width.
- Collections page: table on left (520px), two stacked charts on right (trend line on top, type bar on bottom, each 344px tall).
- Cash Position page: bar + donut charts on top row, "Debit vs Credit by Type" clustered column chart at bottom (replaces old Account Detail table).
- Cash Position bar chart: zoom slider disabled (user preference).

## Records Folder
- Store screenshots, templates, references, and inspiration files in `Reports/Finance/Module/Design Benchmarks` or `Reports/Finance/Module/Records/` as appropriate for the artifact type and workflow.
