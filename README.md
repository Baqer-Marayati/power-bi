# Al Jazeera Reporting Hub

This repository is the working home for the Al Jazeera financial reporting project in Power BI.

The project combines:
- an active SAP-backed PBIP report in `Financial Report`
- a living visual benchmark in `Design Benchmarks`
- durable working memory in `Project Memory`

## Repository Purpose

Use this repository to:
- track report and semantic-model changes safely with Git
- keep the project backed up on GitHub
- document the current structure, assumptions, and operating workflow
- preserve continuity between repair, modeling, and design threads

## Active Project

The active editable report is:
- `Financial Report/Financial Report.pbip`

The active benchmark is:
- `Design Benchmarks/Sample 2`

## Working Areas

- `Financial Report`
  - Active PBIP source of truth for report and semantic model work.
- `Design Benchmarks`
  - Living design reference and benchmark shell source.
- `Project Memory`
  - High-signal working memory for current status, decisions, risks, and next steps.
- `docs`
  - Repo-facing documentation for setup, structure, data context, and page intent.
- `.github`
  - Templates for structured pull requests and issue tracking.

## Start Here

If you are continuing work on this project, read these in order:
- [`docs/setup.md`](docs/setup.md)
- [`docs/structure.md`](docs/structure.md)
- [`Project Memory/PROJECT_DNA.md`](Project%20Memory/PROJECT_DNA.md)
- [`Project Memory/CURRENT_STATUS.md`](Project%20Memory/CURRENT_STATUS.md)
- [`Project Memory/DECISIONS.md`](Project%20Memory/DECISIONS.md)
- [`Project Memory/NEXT_STEPS.md`](Project%20Memory/NEXT_STEPS.md)

## Working Rules

- Treat `Financial Report` as the only active editable report.
- Treat `PBIP` as the source of truth; use `PBIX` only as a temporary review copy if needed.
- Use `Design Benchmarks/Sample 2` as the active visual benchmark unless memory says otherwise.
- Update `Project Memory` after meaningful technical or design changes.
- Keep Git commits small and descriptive.
- Treat repeated UI patterns like KPI rows and slicer rails as shared systems; fix them consistently across pages instead of one card or one screenshot at a time.

## Project Documentation

- [`docs/setup.md`](docs/setup.md)
- [`docs/structure.md`](docs/structure.md)
- [`docs/data-sources.md`](docs/data-sources.md)
- [`docs/pages.md`](docs/pages.md)
- [`docs/known-issues.md`](docs/known-issues.md)
- [`docs/glossary.md`](docs/glossary.md)
- [`docs/workflows/pbip-editing.md`](docs/workflows/pbip-editing.md)
- [`docs/workflows/visual-repair-checklist.md`](docs/workflows/visual-repair-checklist.md)
- [`docs/workflows/semantic-model-change-checklist.md`](docs/workflows/semantic-model-change-checklist.md)
- [`docs/standards/naming.md`](docs/standards/naming.md)
- [`docs/standards/currency-formatting.md`](docs/standards/currency-formatting.md)
- [`docs/standards/page-layout-rules.md`](docs/standards/page-layout-rules.md)
- [`CHANGELOG.md`](CHANGELOG.md)

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
- [`Project Memory/CURRENT_STATUS.md`](Project%20Memory/CURRENT_STATUS.md)

Use `Project Memory` for evolving truth.
Use `README` and `docs` for orientation and stable repo documentation.
