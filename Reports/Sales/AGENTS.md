# Agent Guide

## Read Order

1. `README.md`
2. `Module/docs/foundation.md`
3. `Module/Project Memory/PROJECT_DNA.md`
4. `Module/Project Memory/DECISIONS.md`
5. `Module/Project Memory/CURRENT_STATUS.md`
6. `Module/Project Memory/NEXT_STEPS.md`

Then inspect the active project files (per company under `Companies/`):

- `Companies/CANON/Canon Sales Report/Canon Sales Report.pbip`
- `Companies/CANON/Canon Sales Report/Canon Sales Report.SemanticModel/definition/model.tmdl`
- `Companies/CANON/Canon Sales Report/Canon Sales Report.SemanticModel/definition/relationships.tmdl`

`Companies/PAPERENTITY/` holds the **Paper Sales Report** PBIP for the second tenant copy.

## Rules

- Keep Sales-specific live truth inside this module.
- Use `Module/Core/` for shared Sales baseline assets.
- Use `Companies/` for company-specific PBIPs, config, and overlays (CANON + PAPERENTITY).
- Follow the portfolio visual identity (navy-blue palette, shared branding).
- PBIP is the source of truth; work directly from PBIP (no zip packaging workflow).
- Update `Module/Project Memory` after meaningful work.
