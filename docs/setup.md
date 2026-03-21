# Setup

## Purpose

This document explains how to open and work with the active Power BI project in this repository.

## Required Tools

- Power BI Desktop with PBIP support
- Git
- A GitHub account with repository access

## Active Working File

Open this file as the active project:
- `Financial Report/Financial Report.pbip`

## Important Related Paths

- Semantic model:
  - `Financial Report/Financial Report.SemanticModel/definition`
- Report pages:
  - `Financial Report/Financial Report.Report/definition/pages`
- Benchmark reference:
  - `Design Benchmarks/Sample 2`
- Working memory:
  - `Project Memory`

## Recommended Start Sequence

1. Pull the latest changes from GitHub.
2. Read `README.md`.
3. Read the key files inside `Project Memory`.
4. Open `Financial Report/Financial Report.pbip`.
5. Verify the target page or model area before editing.
6. Make focused changes.
7. Reopen and validate in Power BI.
8. Update `Project Memory` if the work changed current reality.
9. Commit and push the changes.

## Validation Expectations

Before closing a work session:
- the PBIP should open cleanly
- the targeted page or model change should be verified
- broken visuals should be explicitly noted if still unresolved
- memory should reflect any durable change in status or direction

## Git Basics

Useful commands:

```bash
git status
git pull
git add .
git commit -m "Describe the change"
git push
```
