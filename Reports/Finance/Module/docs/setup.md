# Setup

## Purpose

This document explains how to open and work with the active Power BI project in this repository.

## Required Tools

- Power BI Desktop with PBIP support
- Git
- A GitHub account with repository access
- `gh` for GitHub CLI workflows when authenticated
- `jq` for JSON inspection when needed
- `ffmpeg` for media utilities when needed

For the broader operating foundation, toolchain status, and integration notes, read `docs/foundation.md`.

## Active Working File

Open the company PBIP you are working on in Power BI Desktop for edits:
- CANON: `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip`
- PAPERENTITY: `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip`

The normal review path is Sync and review in the Fabric Development Workspace after the change is pushed.

## Important Related Paths

- Semantic model:
  - `Fabric/DevelopmentWorkspace/<Report Name>.SemanticModel/definition`
- Report pages:
  - `Fabric/DevelopmentWorkspace/<Report Name>.Report/definition/pages`
- Live (published) copies, read-only:
  - `Fabric/CanonAnalytics/Canon Financial Report.*`
  - `Fabric/PaperAnalytics/Paper Financial Report.*`
- Benchmark reference:
  - `Reports/Finance/Module/Design Benchmarks/Sample 2`
- Working memory:
  - `Reports/Finance/Module/Project Memory`

## Recommended Start Sequence

1. Pull the latest changes from GitHub.
2. Read `README.md`.
3. Read the key files inside `Project Memory`.
4. Open the target company PBIP under `Fabric/DevelopmentWorkspace/`.
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

`git` over SSH can work while the GitHub **CLI** token is expired. If you use `gh` for Issues or PRs, confirm `gh auth status` is healthy; if not, follow **Git And GitHub** in `docs/foundation.md`.
