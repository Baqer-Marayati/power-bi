# Contributing

## Purpose

This repository is managed as a disciplined working project for the Al Jazeera Power BI financial report.

The goal is to make changes safely, document them clearly, and keep the PBIP project stable.

## Core Workflow

1. Read `README.md` and the relevant docs in `docs/`.
2. Read the current truth in `Project Memory/`.
3. Confirm the target page, visual, model object, or documentation area.
4. Make the smallest safe change.
5. Reopen and validate in Power BI when applicable.
6. Update `Project Memory` if the change affects current truth.
7. Commit with a clear message and push.

## Source Of Truth

- `Financial Report/Financial Report.pbip` is the active editable master.
- `PBIX` may be used temporarily for review, but not as the development source of truth.
- `Design Benchmarks/Sample 2` is the active benchmark shell unless project memory says otherwise.

## Change Expectations

- Prefer safe report-side rewires over risky model experimentation when that solves the problem.
- Keep compatibility logic clearly identifiable if it is provisional.
- Preserve IQD formatting consistency.
- Preserve the benchmark-led executive design direction.

## Documentation Expectations

- Use `README.md` for quick orientation.
- Use `docs/` for stable workflows and standards.
- Use `Project Memory/` for active status, decisions, and technical truth.

## Issue Tracking

Use GitHub Issues for:
- page repair work
- semantic-model changes
- documentation follow-up
- design and benchmark-alignment tasks
