# Design system (portfolio)

This folder holds **cross-report** design guidance that is not a single JSON theme file.

## Authoritative sources

| Topic | Location |
|-------|----------|
| Colors, KPI card grammar, chart palette | `Shared/Standards/portfolio-visual-identity.md` |
| Machine-readable tokens | `Shared/Standards/portfolio-theme.tokens.json` |
| Canvas size, slicer rail, zoning, interactions | `Shared/Standards/page-layout-spec.md` |
| Module contract (folders, packaging) | `Shared/Standards/report-module-contract.md` |
| Live reference implementation | `Reports/Finance/Financial Report/` (PBIP) |
| PBIP editing workflow | `Reports/Finance/docs/standards/page-layout-rules.md` |

## What belongs here

- Short **composition** notes (e.g. “KPI row + left rail + detail table”) that apply to **multiple** modules.
- Links to **benchmark** PBIPs under module `Design Benchmarks/` folders.

## What does not belong here

- Per-module **status** or **sprint** notes — use that module’s `Project Memory/`.
- Large binaries or screenshots — use module `Records/` or `Shared/ChatContext/images/` per chat rules.
