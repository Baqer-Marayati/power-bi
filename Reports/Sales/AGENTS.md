# Agent Guide

## Read Order

1. `README.md`
2. `docs/foundation.md`
3. `Project Memory/PROJECT_DNA.md`
4. `Project Memory/DECISIONS.md`
5. `Project Memory/CURRENT_STATUS.md`
6. `Project Memory/NEXT_STEPS.md`

Then inspect the active project files:
- `Sales Report/Sales Report.pbip`
- `Sales Report/Sales Report.SemanticModel/definition/model.tmdl`
- `Sales Report/Sales Report.SemanticModel/definition/relationships.tmdl`

## Rules

- Keep Sales-specific live truth inside this module.
- Use `Core/` for shared Sales baseline assets.
- Use `Companies/` for company-specific config and overlays.
- Rebuild package artifacts before review.
- Follow the portfolio visual identity (navy-blue palette, shared branding).
- PBIP is the source of truth; review from packaged artifacts only.
- Update `Project Memory` after meaningful work.
