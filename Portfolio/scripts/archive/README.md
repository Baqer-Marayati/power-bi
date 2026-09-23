# Archived one-off scripts

These scripts were used during **Sales** layout / query migration and similar one-time passes. They are **not** part of the standard packaging or validation pipeline.

| File | Original role |
|------|----------------|
| `fix-bom.ps1` | Strip UTF-8 BOM from Sales page JSON |
| `fix-card-fill.ps1` | Add `fillCustom` to Sales card visuals |
| `fix-label-precision.ps1` | Adjust Sales KPI `labelPrecision` |
| `fix-logos.ps1` | Copy Finance logos into Sales PBIP and rewrite paths |
| `fix-sales-layout.ps1` / `fix-sales-layout2.ps1` | Sales chart/matrix positions |
| `find-images.ps1` | List large images under Finance report |
| `rewrite-salesfact-query.ps1` (v1–v4) | Iterative `SalesFact.tmdl` ODBC SQL rewrites (**v4** was the last in-tree iteration) |
| `explore-commission.sql` / `explore-commission2.sql` | Ad-hoc HANA exploration |
| `sync-fabric-to-modules.py` | Copied `Fabric/DevelopmentWorkspace` back into the module PBIP copies. Retired 24 Sep 2026 when the module copies were removed; `fabric_release.py` now keeps the live mirrors in `Fabric/CanonAnalytics` and `Fabric/PaperAnalytics`. |

If you need to repeat a similar migration, **copy** the relevant script to a working branch and adapt; do not assume paths or report IDs are still valid.
