# Scripts

Automation scripts for the Finance module.

Current scripts:
- `capture-pages.ps1` for full-page screenshot capture. By default it reads **how many pages** to click from `…Report/definition/pages/pages.json` next to the PBIP (fallback: 10). Override with `-PageCount` if needed.
- `package-report.sh` for packaging review artifact generation (legacy shell flow, strips model cache by default; set `KEEP_MODEL_CACHE=1` to include cached values).
- `package-report.ps1` Windows-first wrapper for portfolio packager (strips model cache by default; use `-KeepModelCache` only when explicitly needed). It also mirrors the fresh zip to both:
  - `Exports/Server Packages/latest/Financial Report - ready.zip`
  - `Exports/Server Packages/Financial Report - ready.zip`
- `validate-artifact-state.ps1` guardrail check that verifies canonical source path, latest zip status, model cache presence, and warns if an extracted package PBIP could be opened by mistake.
- `archive-prune.ps1` rolling archive retention wrapper.

Planned additions:
- `validate-structure.ps1` (module structure checks)
