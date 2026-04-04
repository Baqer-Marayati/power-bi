# <REPORT_TITLE> Module

This module is the working home for the <REPORT_TITLE> report inside the larger Reporting Hub portfolio.

## Purpose

Use this module for:
- report-specific PBIP work (per company under `Companies/<CODE>/`)
- report-specific project memory
- department-specific documentation
- records and archives as needed

## Expected Working Areas

- `Companies/<CODE>/` — config, overlays, and `/<REPORT_TITLE> - <CODE>/` (PBIP + `.Report` / `.SemanticModel`)
- `Module/` — container for module internals:
  - `Module/docs/`
  - `Module/Project Memory/`
  - `Module/Core/` (shared baseline assets, not company PBIPs)
  - `Module/scripts/`
  - `Module/Records/`
  - `Module/Archive/`

## Start Here

Read these in order:
- [`AGENTS.md`](AGENTS.md)
- [`Module/docs/foundation.md`](Module/docs/foundation.md)
- [`Module/Project Memory/PROJECT_DNA.md`](Module/Project%20Memory/PROJECT_DNA.md)
- [`Module/Project Memory/DECISIONS.md`](Module/Project%20Memory/DECISIONS.md)
- [`Module/Project Memory/CURRENT_STATUS.md`](Module/Project%20Memory/CURRENT_STATUS.md)

When authoring a new PBIP, see [`Module/docs/pbip-snippets/README.md`](Module/docs/pbip-snippets/README.md) for starter `page.json` and links to portfolio standards.

## Source Of Truth

- The PBIP under `Companies/<CODE>/<REPORT_TITLE> - <CODE>/` is the editable source of truth for that company.
- Work and review in Power BI Desktop from that PBIP; do not rely on a separate zip packaging step.
