# Agent Guide

This report module is structured so a new AI agent can recover finance-project context quickly without reading chat history.

## Start Here

Read these in order:
1. `README.md`
2. `Module/docs/foundation.md`
3. `Module/docs/setup.md`
4. `Module/docs/structure.md`
5. `Module/docs/agent-manual.md`
6. `Module/docs/workflows/mcp-operating-policy.md`
7. `Module/docs/workflows/definition-of-done.md`
8. `Module/Project Memory/PROJECT_DNA.md`
9. `Module/Project Memory/DECISIONS.md`
10. `Module/Project Memory/CURRENT_STATUS.md`
11. `Module/Project Memory/MODEL_NOTES.md`
12. `Module/Project Memory/NEXT_STEPS.md`
13. `Module/Project Memory/REFERENCE.md`

Then inspect the active project files (each company has its own PBIP under `Companies/<CODE>/`):

**CANON (primary reference layout):**
- `Companies/CANON/Canon Financial Report/Canon Financial Report.pbip`
- `Companies/CANON/Canon Financial Report/Canon Financial Report.SemanticModel/definition/model.tmdl`
- `Companies/CANON/Canon Financial Report/Canon Financial Report.SemanticModel/definition/relationships.tmdl`

**PAPERENTITY** uses the same folder shape with `PAPERENTITY` in paths and schema references (see `Companies/PAPERENTITY/`).

## Documentation Split

Use each layer for a different purpose:

- `README.md`
  - fast orientation and key links
- `Module/docs/`
  - stable repository documentation, workflows, and standards
- `Module/Project Memory/`
  - live project truth, active decisions, current state, and handoff context

Do not turn `README.md` or `Module/docs/` into a running status log.
Do not spread live status updates across multiple files when `Module/Project Memory` is the right home.

## Project Brain

The closest thing to a living project brain is the combination of:
- `Module/Project Memory/`
- this module's `AGENTS.md`
- the repo-facing docs in `README.md` and `Module/docs/`

Treat `Module/Project Memory` as the live memory layer.
Treat this file as the universal entrypoint for future AI agents.

## Core Rules

- Editable report work happens in **PBIP** under `Companies/<CompanyCode>/` (e.g. CANON, PAPERENTITY). Open the actual company PBIP path documented in this file and the module README rather than guessing a folder pattern.
- `Module/Design Benchmarks/Sample 2` is the active visual benchmark unless `Project Memory` says otherwise.
- Preserve the Sample 2 shell and CFO-style tone unless the user explicitly changes direction.
- Logic first, styling second.
- Use IQD formatting consistently.
- Treat repeated UI elements such as KPI rows and slicer rails as shared systems.
- For semantic-model tasks, use MCP-first workflow via `powerbi-modeling-mcp` when available.
- Update `Module/Project Memory` after meaningful work.
- For local Desktop cache issues, use `Module/scripts/clear-model-cache.ps1` as documented in `Module/scripts/README.md`.
- Close work against `Module/docs/workflows/definition-of-done.md`.

## Update Discipline

When work changes project reality:
- update `Module/Project Memory/CURRENT_STATUS.md` for current truth
- update `Module/Project Memory/DECISIONS.md` for durable direction or approved constraints
- update `Module/Project Memory/MODEL_NOTES.md` for semantic-model facts and caveats
- update `Module/Project Memory/NEXT_STEPS.md` for the recommended next sequence
- update `README.md` or `Module/docs/` only when stable onboarding or workflow documentation changed

## Goal

Another agent should be able to open this repository, read the files above, and understand:
- what the project is
- where the source of truth lives
- what is working now
- what is provisional
- what to avoid undoing
- what to do next
