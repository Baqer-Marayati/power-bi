# Reference

## Working files (repo-relative)

Main PBIPs:

- `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.pbip`
- `Reports/Finance/Companies/PAPERENTITY/Paper Financial Report/Paper Financial Report.pbip`

Primary semantic model:

- `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.SemanticModel/definition/model.tmdl`

Primary relationships:

- `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.SemanticModel/definition/relationships.tmdl`

Primary report pages:

- `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.Report/definition/pages/`

GitHub repository (remote may vary by fork):

- `https://github.com/Baqer-Marayati/reporting-hub`

## Visual benchmark
Use the files inside:

- `Reports/Finance/Module/Design Benchmarks/`

This folder is the living design reference for the project.

## Active benchmark
Current primary benchmark:

- `Reports/Finance/Module/Design Benchmarks/Sample 2`

Use `Sample 2` as the active design source for:

- page shell and canvas treatment
- header system
- KPI card rhythm
- slicer placement
- chart spacing and composition
- overall report tone

## Visual principles
- Keep spacing disciplined.
- Avoid crowded pages.
- Preserve a professional CFO / management-report tone.
- Keep layout hierarchy clear: filters, KPIs, analysis, detail.
- Prefer benchmark accuracy over style experimentation.
- Prefer starting from a benchmark shell over trying to force an old shell to match.

## Records maintenance
- Re-check `Design Benchmarks` before major layout, color, or style decisions.
- Prefer newer screenshots and templates when they clearly reflect the latest taste.
- When the benchmark changes, refresh this file so it reflects the latest visual direction.

## Current priority pages
All **10** pages in `pages.json` are in the active operating set:

`Financial summary`, `Profit & loss`, `Sales & revenue`, `Operating expenses`, `Balance sheet`, `ROI`, `Accounts receivable`, `Accounts payable`, `Collections`, `Cash & bank`.

Deferred / historical pages are listed in `PAGE_MAP.md`.

## Memory files
Read these first in future threads:

- `Reports/Finance/Module/Project Memory/PROJECT_DNA.md`
- `Reports/Finance/Module/Project Memory/DECISIONS.md`
- `Reports/Finance/Module/Project Memory/CURRENT_STATUS.md`
- `Reports/Finance/Module/Project Memory/MODEL_NOTES.md`
- `Reports/Finance/Module/Project Memory/NEXT_STEPS.md`
- `Reports/Finance/Module/Project Memory/PAGE_MAP.md`
- `Reports/Finance/Module/Project Memory/DATA_GAPS.md`
- `Reports/Finance/Module/Project Memory/POWERBI_PATTERNS.md`

## Repository documentation
Use these repo-facing docs for fast orientation before dropping into detailed memory:

- `Reports/Finance/AGENTS.md`
- `Reports/Finance/README.md`
- `Reports/Finance/Module/docs/foundation.md`
- `Reports/Finance/Module/docs/agent-manual.md`
- `Reports/Finance/Module/docs/setup.md`
- `Reports/Finance/Module/docs/structure.md`
- `Reports/Finance/Module/docs/data-sources.md`
- `Reports/Finance/Module/docs/pages.md`
- `Reports/Finance/Module/docs/known-issues.md`
- `Reports/Finance/Module/docs/glossary.md`
- `Reports/Finance/Module/docs/workflows/pbip-editing.md`
- `Reports/Finance/Module/docs/workflows/visual-repair-checklist.md`
- `Reports/Finance/Module/docs/workflows/semantic-model-change-checklist.md`
- `Reports/Finance/Module/docs/standards/naming.md`
- `Reports/Finance/Module/docs/standards/currency-formatting.md`
- `Reports/Finance/Module/docs/standards/page-layout-rules.md`
- `Reports/Finance/Module/CHANGELOG.md`

Use `AGENTS.md` for AI onboarding and read order.
Use `docs/foundation.md` for the broad operating foundation and tool/integration context.
Use `README` and `docs` for repo orientation.
Use `Project Memory` for live project truth and handoff context.

## GitHub tracking
GitHub issue tracking is part of the active operating setup.

Local tooling may include `gh`, `jq`, and `ffmpeg` depending on environment.

Confirm a healthy login with `gh auth status` before relying on Issues/PR commands.

## Learning focus
Use Project Memory to preserve:

- project taste and design direction
- what is real vs provisional in the model
- how PBIP and TMDL changes behave in practice
- what repair methods have proven safe or risky
- the user's preferred way of working

## Durable Guidance
Use `Project Memory` and repo-tracked rules as the durable instruction layer for future agents.
Do not rely on external skill folders or chat history being present on the machine in use.
