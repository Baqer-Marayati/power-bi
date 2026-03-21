# Decisions

## Active Project
- Active working project: `/Users/baqer/Dropbox/Work/PowerBI/Al Jazeera Reporting Hub/Financial Report`
- Do not create parallel experiment folders unless explicitly needed.

## Source Of Truth
- The financial PBIP project is the source of truth.
- The older sales-report experiments are not part of the active workflow.

## Delivery Format Rule
- `PBIP` remains the only working source of truth for this project.
- `PBIX` may be produced as a temporary review or transfer snapshot when a single-file handoff is more practical.
- Do not treat a review `PBIX` as the editable master.
- If a `PBIX` is created for review, all real changes must still be made back in the `PBIP` project.
- Use `PBIX` for convenience; use `PBIP` for development truth.

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

## Final Page Set
- As of March 21, 2026, the report is intentionally reduced to 7 live pages only:
- `Executive Overview`
- `Income Statement`
- `Revenue Insights`
- `Cost Structure`
- `Balance Sheet`
- `Actual vs Budget`
- `Cashflow`
- Pages outside that set are no longer part of the active report shell and should not be reintroduced unless explicitly requested.

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

## Semantic Safety Rule
- Be cautious with compatibility aliases that bridge domains in both directions.
- If a compatibility measure creates a circular-feeling dependency path, prefer rewiring the report visual directly to the source table instead of keeping the alias.
- Do not blindly add custom relationships in TMDL when Power BI has already shown invalid-column-ID failures for the same approach.

## Memory Maintenance Rule
- The `Project Memory` folder must be updated whenever the semantic model, page-repair status, benchmark direction, or major assumptions change.
- Future threads should treat memory updates as part of done-ness, not as an optional last step.
- Add new markdown files when they materially improve continuity for later build threads.
- Consolidate durable discoveries into the right memory files instead of letting them remain trapped in chat history.

## Documentation Layer Rule
- Keep a repo-facing documentation layer at the root for GitHub orientation.
- Use `README.md` for a fast repo overview and key links.
- Use `docs/` for stable setup, structure, page-purpose, and data-context documentation.
- Use `docs/workflows/` for repeatable operating procedures.
- Use `docs/standards/` for durable formatting, naming, and layout rules.
- Do not duplicate active status tracking across every doc; current truth still belongs in `Project Memory`.
- Keep `CHANGELOG.md` milestone-level only.

## GitHub Tracking Rule
- Use GitHub Issues as the active task-tracking layer for meaningful repair, model, design, and documentation work.
- Keep labels and milestones aligned to the real project state rather than using GitHub as a generic backlog dump.
- Prefer updating or closing an existing issue over creating duplicate issues for the same active page or model problem.
- The local terminal `gh` workflow is now part of the approved setup, so future GitHub issue management does not need to be done manually in the browser unless account settings or new permissions are involved.

## Rebuild Rule
- If the existing report is resisting design changes, do not spend multiple passes on low-impact theme edits.
- Start from the benchmark report layer and rewire it to the active semantic model instead.
- Rebuild the report shell first, then remap fields and measures page by page.

## Report Swap Rule
- A full report-folder swap is acceptable when the benchmark PBIP is the intended base and the semantic model path is rewired correctly in `definition.pbir`.
- Keep a backup of the prior `.Report` folder before doing a full swap.

## Records Folder
- Store screenshots, templates, references, and inspiration files in `/Users/baqer/Dropbox/Work/PowerBI/Al Jazeera Reporting Hub/Design Benchmarks`.
