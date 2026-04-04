# Agent Guide

This file is the AI entrypoint for the Service Performance Report module.

## Read Order

1. `README.md`
2. `Module/docs/foundation.md`
3. `Module/Project Memory/PROJECT_DNA.md`
4. `Module/Project Memory/DECISIONS.md`
5. `Module/Project Memory/CURRENT_STATUS.md`
6. `Module/Project Memory/NEXT_STEPS.md`
7. `Module/Project Memory/REFERENCE.md`

Then inspect the active project files (per company under `Companies/`):

- `Companies/CANON/Canon Service Report/Canon Service Report.pbip`
- `Companies/CANON/config/` — company profile and datasource mapping (existing)

`Companies/PAPERENTITY/` holds the **Paper Service Report** PBIP for the second tenant copy.

## Module Rules

- Keep report-specific truth inside this module.
- Put only shared cross-report assets in the portfolio `Portfolio/Shared/` layer.
- Archive historical material explicitly instead of mixing it into active work folders.
- PBIPs live under `Companies/CANON/` and `Companies/PAPERENTITY/`; work directly from PBIP (no zip packaging workflow).
- Apply the portfolio-wide visual identity from `Portfolio/Shared/Standards/portfolio-visual-identity.md` and `Portfolio/Shared/Standards/portfolio-theme.tokens.json` unless an approved module exception is recorded.
