# Agent Guide

This file is the AI entrypoint for the Data Export Workspace module.

## Read Order

1. `README.md`
2. `docs/foundation.md`
3. `Project Memory/PROJECT_DNA.md`
4. `Project Memory/DECISIONS.md`
5. `Project Memory/CURRENT_STATUS.md`
6. `Project Memory/NEXT_STEPS.md`
7. `Project Memory/REFERENCE.md`

## Module Rules

- Keep export-workflow truth inside this module.
- This module exists to avoid touching `Reports/Finance` during export setup.
- Put shared cross-report data-drop assets in `Shared/Data Drops/`.
- Archive historical material explicitly instead of mixing it into active work folders.
