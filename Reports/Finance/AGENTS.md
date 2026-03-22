# Agent Guide

This report module is structured so a new AI agent can recover finance-project context quickly without reading chat history.

## Start Here

Read these in order:
1. `README.md`
2. `docs/foundation.md`
3. `docs/setup.md`
4. `docs/structure.md`
5. `docs/agent-manual.md`
6. `Project Memory/PROJECT_DNA.md`
7. `Project Memory/DECISIONS.md`
8. `Project Memory/CURRENT_STATUS.md`
9. `Project Memory/MODEL_NOTES.md`
10. `Project Memory/NEXT_STEPS.md`
11. `Project Memory/REFERENCE.md`

Then inspect the active project files:
- `Financial Report/Financial Report.pbip`
- `Financial Report/Financial Report.SemanticModel/definition/model.tmdl`
- `Financial Report/Financial Report.SemanticModel/definition/relationships.tmdl`

## Documentation Split

Use each layer for a different purpose:

- `README.md`
  - fast orientation and key links
- `docs/`
  - stable repository documentation, workflows, and standards
- `Project Memory/`
  - live project truth, active decisions, current state, and handoff context

Do not turn `README.md` or `docs/` into a running status log.
Do not spread live status updates across multiple files when `Project Memory` is the right home.

## Project Brain

The closest thing to a living project brain is the combination of:
- `Project Memory/`
- this module's `AGENTS.md`
- the repo-facing docs in `README.md` and `docs/`

Treat `Project Memory` as the live memory layer.
Treat this file as the universal entrypoint for future AI agents.

## Core Rules

- `Financial Report` is the active editable PBIP source of truth.
- `Design Benchmarks/Sample 2` is the active visual benchmark unless `Project Memory` says otherwise.
- Preserve the Sample 2 shell and CFO-style tone unless the user explicitly changes direction.
- Logic first, styling second.
- Use IQD formatting consistently.
- Treat repeated UI elements such as KPI rows and slicer rails as shared systems.
- Update `Project Memory` after meaningful work.
- Rebuild `Exports/Server Packages/Financial Report - ready.zip` before user review when report files changed.

## Update Discipline

When work changes project reality:
- update `Project Memory/CURRENT_STATUS.md` for current truth
- update `Project Memory/DECISIONS.md` for durable direction or approved constraints
- update `Project Memory/MODEL_NOTES.md` for semantic-model facts and caveats
- update `Project Memory/NEXT_STEPS.md` for the recommended next sequence
- update `README.md` or `docs/` only when stable onboarding or workflow documentation changed

## Goal

Another agent should be able to open this repository, read the files above, and understand:
- what the project is
- where the source of truth lives
- what is working now
- what is provisional
- what to avoid undoing
- what to do next
