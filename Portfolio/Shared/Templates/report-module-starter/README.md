# <REPORT_TITLE> Module

This module is the working home for the <REPORT_TITLE> report inside the larger Reporting Hub portfolio.

## Purpose

Use this module for:
- report-specific docs and scripts (the PBIP itself lives in `Fabric/DevelopmentWorkspace/`)
- report-specific project memory
- department-specific documentation
- records and archives as needed

## Expected Working Areas

- `module.manifest.json` — module/company machine-readable path and policy map
- `Companies/<CODE>/` — company config and overlays
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

- `Fabric/DevelopmentWorkspace/<Name>.pbip` is the editable source of truth for each company's report.
- Review in the Fabric Development Workspace after a Git sync, and publish with `Portfolio/scripts/fabric_release.py` (see `Fabric/README.md`).
- Generated package/review artifacts are optional per module policy and must not replace PBIP as the development source.
