# PBIP authoring snippets

Use these **non-authoritative** fragments when creating a new PBIP or adding pages. Always open the project in **Power BI Desktop** after JSON edits.

## Files

| File | Use |
|------|-----|
| [`page-shell.example.json`](page-shell.example.json) | Starting point for `definition/pages/<pageId>/page.json` (canvas, background, outspace) |

## Full references

- Portfolio layout contract: `Shared/Standards/page-layout-spec.md`
- Live reference: `Reports/Finance/Companies/CANON/Canon Financial Report/Canon Financial Report.Report/definition/pages/` (and the parallel `PAPERENTITY` path when relevant)
- Theme: copy `Shared/Themes/Custom_Theme49412231581938193.json` into `…/StaticResources/RegisteredResources/` and register in `definition/report.json` (see Finance `report.json`).

## After scaffolding

1. Add your module’s domain to `scripts/clear-model-cache.ps1` `ValidateSet` **when** you have a semantic model path, or call the portfolio script with a one-off path (see `Reports/Finance/Module/scripts/clear-model-cache.ps1`).
2. Add `validate-structure.ps1` / `clear-model-cache.ps1` under `scripts/` mirroring other active modules.
3. Update `Portfolio/Memory/REPORT_CATALOG.md`.
