# Agent Manual

## Purpose

This manual explains how to understand and operate inside the Reporting Hub without relying on prior chat history.

Use it as the stable onboarding guide for any AI agent or new collaborator entering the repository.

## What This Repository Is

This is a Power BI financial reporting workspace built around:
- active company PBIP source projects under `Fabric/DevelopmentWorkspace/` (repo root), with read-only live copies in `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/`
- a living design benchmark in `Module/Design Benchmarks`
- a live memory layer in `Module/Project Memory`
- stable onboarding and workflow docs in `Module/docs`

## What To Read First

Recommended order:
1. `AGENTS.md`
2. `README.md`
3. `docs/foundation.md`
4. `docs/setup.md`
5. `docs/structure.md`
6. `Project Memory/PROJECT_DNA.md`
7. `Project Memory/DECISIONS.md`
8. `Project Memory/CURRENT_STATUS.md`
9. `Project Memory/MODEL_NOTES.md`
10. `Project Memory/NEXT_STEPS.md`
11. `Project Memory/REFERENCE.md`

## File-System Mental Model

### `Fabric/DevelopmentWorkspace/<Report Name>.*`

The active editable PBIP projects (repo root, outside this module).

Use this for:
- report definition edits
- semantic-model changes
- page repairs

Current entry points:
- CANON: `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip`
- PAPERENTITY: `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip`

Live copies in `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` are read-only; they are updated only by `Portfolio/scripts/fabric_release.py` when the user names a report to publish.

### `Companies/<CODE>`

Company settings only (`config/`, `overlays/`). No report files.

### `Module/Design Benchmarks`

The visual benchmark and taste reference.

Use this for:
- page shell reference
- design alignment
- screenshot comparison
- replacement benchmark sources if the visual direction evolves

### `Module/Project Memory`

The live project brain.

Use this for:
- current truth
- explicit decisions
- technical caveats
- page-level state
- known data gaps
- next-step sequencing

### `Module/docs`

The stable manual layer.

Use this for:
- setup and orientation
- workflow checklists
- formatting and naming standards
- glossary and durable reference material

## Documentation Rules

Keep each documentation layer focused:

- `README.md`
  - quick repo overview and links
- `AGENTS.md`
  - shortest universal AI entrypoint
- `docs/`
  - stable procedures and standards
- `Project Memory/`
  - live project state and handoff continuity

Avoid duplicating the same status note across all four layers.

## How The Live Brain Stays Current

This repository does not have one magical self-writing file.
Instead, it uses a layered system that can stay accurate if every meaningful task ends with a memory update.

Expected close-out behavior after meaningful work:
1. make the technical or report change
2. validate the result
3. update the relevant `Project Memory` files
4. update stable docs only if the onboarding flow, workflow, or operating rules changed

That means the "brain" is not one document.
It is the combination of:
- current memory
- durable rules
- stable onboarding docs
- the actual PBIP source files

## Current Operating Assumptions

Unless later memory updates replace them:
- each company PBIP under `Fabric/DevelopmentWorkspace/` is the active editable report for that company
- `PBIP` is the development source of truth
- `Module/Design Benchmarks/Sample 2` is the active benchmark
- the report should preserve a CFO / management-report tone
- IQD formatting is the standard

## Update Map

When you learn something new, write it to the right place:

- `Project Memory/CURRENT_STATUS.md`
  - what is true now
- `Project Memory/DECISIONS.md`
  - what has been decided and should not drift
- `Project Memory/MODEL_NOTES.md`
  - model structure, compatibility layers, semantic caveats
- `Project Memory/NEXT_STEPS.md`
  - what should happen next
- `Project Memory/REFERENCE.md`
  - anchor paths, key files, and important reference locations
- `docs/`
  - repeatable workflows and durable standards

## Handoff Standard

An agent should finish work in a state where the next agent can answer these quickly:
- What is the active report?
- What is the visual benchmark?
- Which pages are live?
- Which areas are provisional?
- What changed recently?
- What is the next safest step?

If those answers are missing, the memory layer is incomplete.
