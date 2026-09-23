# Core

This folder is reserved for Finance domain baseline assets shared across companies.

Resolved layout:
- Active editable PBIPs live under `Fabric/DevelopmentWorkspace/` at the repo root (not under `Core/` or `Companies/`).
- New shared assets should be placed in `Core/` first when they are company-agnostic.
- Company-specific schema, branding, and environment differences belong in `Companies/<CODE>/config` or `Companies/<CODE>/overlays`.

Good candidates for this folder:
- shared Finance semantic-model patterns
- reusable page/slicer/KPI layout notes
- compatibility-layer retirement maps
- company-agnostic report snippets or standards

Use `Reports/Finance/module.manifest.json` for executable company path metadata. Keep `Core/` focused on reusable Finance baseline material, not active PBIP copies.
