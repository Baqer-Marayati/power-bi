# Finance Report Module

This module is the working home for the Al Jazeera financial reporting project in Power BI inside the larger Reporting Hub portfolio.

The project combines:
- active SAP-backed PBIP reports under `Companies/<CompanyCode>/` (see below)
- a living visual benchmark in `Module/Design Benchmarks`
- durable working memory in `Module/Project Memory`

## Repository Purpose

Use this repository to:
- track report and semantic-model changes safely with Git
- keep the project backed up on GitHub
- document the current structure, assumptions, and operating workflow
- preserve continuity between repair, modeling, and design threads

## Active Project

Each company has its own PBIP under `Companies/<CODE>/`. Open the `.pbip` in Power BI Desktop for that company.

- **CANON:** `Companies/CANON/Canon Financial Report/Canon Financial Report.pbip`
- **PAPERENTITY:** `Companies/PAPERENTITY/Paper Financial Report/Paper Financial Report.pbip` (schema references use PAPERENTITY instead of CANON)

The active benchmark is:
- `Module/Design Benchmarks/Sample 2`

## Working Areas

- `Companies`
  - One folder per company code; each contains its own PBIP (`.pbip`, `.Report`, `.SemanticModel` with a `- <CODE>` suffix).
- `Module/` — container for module internals:
  - `Module/Core` — shared domain baseline for cross-company Finance reporting assets; company-agnostic material belongs here first.
  - `Module/Design Benchmarks` — living design reference and benchmark shell source.
  - `Module/Project Memory` — high-signal working memory for current status, decisions, risks, and next steps.
  - `Module/docs` — repo-facing documentation for setup, structure, data context, and page intent.
  - `Module/scripts` — capture, model-cache, and structure helpers for this module (see `Module/scripts/README.md`).
- `.github`
  - Templates for structured pull requests and issue tracking.

## Start Here

If you are continuing work on this project, read these in order:
- [`AGENTS.md`](AGENTS.md)
- [`Module/docs/foundation.md`](Module/docs/foundation.md)
- [`Module/docs/setup.md`](Module/docs/setup.md)
- [`Module/docs/structure.md`](Module/docs/structure.md)
- [`Module/docs/agent-manual.md`](Module/docs/agent-manual.md)
- [`Module/Project Memory/PROJECT_DNA.md`](Module/Project%20Memory/PROJECT_DNA.md)
- [`Module/Project Memory/CURRENT_STATUS.md`](Module/Project%20Memory/CURRENT_STATUS.md)
- [`Module/Project Memory/DECISIONS.md`](Module/Project%20Memory/DECISIONS.md)
- [`Module/Project Memory/NEXT_STEPS.md`](Module/Project%20Memory/NEXT_STEPS.md)

## Working Rules

- Treat the relevant company PBIP under `Companies/<CODE>/` as the editable source of truth for that company.
- Treat **PBIP** as the development master; use **PBIX** only as a temporary review or transfer snapshot if needed, and merge real changes back into PBIP.
- Use `Module/Design Benchmarks/Sample 2` as the active visual benchmark unless memory says otherwise.
- Use `Module/scripts/clear-model-cache.ps1` when Desktop shows stale cached model behavior after Git pulls (see `Module/scripts/README.md`).
- Update `Module/Project Memory` after meaningful technical or design changes.
- Keep Git commits small and descriptive.
- Treat repeated UI patterns like KPI rows and slicer rails as shared systems; fix them consistently across pages instead of one card or one screenshot at a time.

## Project Documentation

- [`AGENTS.md`](AGENTS.md)
- [`Module/docs/foundation.md`](Module/docs/foundation.md)
- [`Module/docs/setup.md`](Module/docs/setup.md)
- [`Module/docs/agent-manual.md`](Module/docs/agent-manual.md)
- [`Module/docs/structure.md`](Module/docs/structure.md)
- [`Module/docs/data-sources.md`](Module/docs/data-sources.md)
- [`Module/docs/pages.md`](Module/docs/pages.md)
- [`Module/docs/known-issues.md`](Module/docs/known-issues.md)
- [`Module/docs/glossary.md`](Module/docs/glossary.md)
- [`Module/docs/workflows/pbip-editing.md`](Module/docs/workflows/pbip-editing.md)
- [`Module/docs/workflows/visual-repair-checklist.md`](Module/docs/workflows/visual-repair-checklist.md)
- [`Module/docs/workflows/semantic-model-change-checklist.md`](Module/docs/workflows/semantic-model-change-checklist.md)
- [`Module/docs/standards/naming.md`](Module/docs/standards/naming.md)
- [`Module/docs/standards/currency-formatting.md`](Module/docs/standards/currency-formatting.md)
- [`Module/docs/standards/page-layout-rules.md`](Module/docs/standards/page-layout-rules.md)
- [`Module/CHANGELOG.md`](Module/CHANGELOG.md)

## Git Workflow

Typical workflow:

```bash
git status
git add .
git commit -m "Describe the change"
git push
```

## Current State

The current live state of the project is maintained in:
- [`Module/Project Memory/CURRENT_STATUS.md`](Module/Project%20Memory/CURRENT_STATUS.md)

Use `Module/Project Memory` for evolving truth.
Use `AGENTS.md` for AI onboarding.
Use `README` and `Module/docs` for orientation and stable repo documentation.
