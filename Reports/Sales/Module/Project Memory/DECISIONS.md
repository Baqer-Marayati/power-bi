# Decisions

## Module Scope
- This module is dedicated to Sales reporting.
- Pages: Sales Overview, Sales Employees, BP Sales, BP Rebate.

## Origin Decision (2026-03-31)
- Report derived from the Aljazeera Master Model PBIP.
- Only the 4 sales/commercial pages were kept.
- Non-sales pages (Inventory Valuation, Receivables, Collections, Cash) were intentionally excluded.
- Those excluded pages may be routed to their natural modules (Inventory, Finance) in the future.

## Structure Rule
- Follow the portfolio report-module contract in `Shared/Standards/report-module-contract.md`.

## Delivery Rule
- PBIP is source of truth.
- Review from packaged artifacts.

## Visual Identity Rule
- Adopt the portfolio visual identity from Finance (navy-blue palette, branding lockup).
- IQD currency formatting throughout.

## Data Source Rule
- SAP HANA ODBC to CANON schema (same SAP instance as Finance).
- SalesFact SQL includes A/R Invoice, Credit Memo, warranty, and GL COGS adjustment logic.

## 2026-05-04 — Sales Map geography implementation
- Canon Sales Map uses explicit OCRG geography fields from `OCRD.GroupCode` joined to `OCRG.GroupName`; `OTER` territory remains untouched because it is sparse.
- Superseded 2026-05-05: the final governorate choropleth uses Deneb with high-detail polygon paths. The earlier native scatter-over-PNG approach is retained only as implementation history.
- Bubble centers come from `Geo_City_Reference` WGS84 static city points keyed by normalized `GroupName`; non-location groups remain unmapped until explicitly added.
- The Power BI scatter visual must bind X/Y to coordinate measures (`Map Projected X`, `Map Projected Y`) rather than raw `Lat`/`Lon` columns; otherwise Desktop raises the x/y summarization error.
- The registered Iraq outline resource is PNG for Desktop reliability; the current geometry source is geoBoundaries `IRQ ADM1` (`gbOpen`, 2022, CC0) so the background includes governorate borders.
- The map background and bubble points use the same Web Mercator-style projected coordinates (`Map Projected X`, `Map Projected Y`) so the country shape is not flattened and the bubbles align.
- Bubble radius is driven by `SQRT([Mapped Sales])` to keep area-style encoding aligned with the D3 bubble-map reference. `bubbleScaleFactor: 45` constrains absolute visual size.
- **Alignment fix (2026-05-04):** The PNG must be generated at the *exact* aspect ratio of the visual container (740:650 = 1.13846) with **no pixel margins**. Any margin or ratio mismatch causes systematic bubble displacement because Power BI letterboxes the image while the scatter chart plots across the full container area. Correct approach: expand the Y domain 4% for breathing room, then set X domain = Y_range × (740/650) centred on Iraq, generate PNG filling 0..W × 0..H at that domain, set scatter axis to those same domain values.
- The page-level total uses the report-wide `Sales` measure so it matches other pages; mapped-only values are limited to bubbles/city rows and are paired with an `Unmapped Sales` KPI.
- Source note: geoBoundaries `IRQ ADM1` is CC0; the earlier OSM-only outline was replaced after Desktop review showed the simplified outline was not good enough.

## 2026-05-05 — Sales Map Deneb layout lock
- Preserve the user-adjusted Sales Map page layout from screenshot 11: left slicer rail and KPI/header band remain, the Deneb Iraq choropleth is the large central visual, and the Sales by City table is a tall right-side panel.
- Current preferred PBIP positions: `choropleth_iraq_gov` at `x=188.33`, `y=230`, `w=773.33`, `h=690`; `matrix_city_sales` at `x=973.33`, `y=230`, `w=271.67`, `h=690`.
- Future Deneb/map polish should preserve this map/table balance and must not revert to the earlier smaller map or remove the city table unless explicitly requested.

## 2026-05-05 — Sales share and governorate tooltip fix
- Sales Person and Business Partner matrices use one shared `Sales Share %` measure: row sales divided by `Company Sales`, which removes the matrix row/drill geography and entity filters while preserving the broader report context.
- Sales Map Deneb must bind color/tooltip sales to `Governorate Tooltip Sales`, not the generic `Sales` measure, so each governorate receives a governorate-scoped value before calculating `Governorate Sales % of Total`.
- Deneb remains the preferred high-quality map surface; keep the governorate visual at the locked large layout and viewport dimensions to avoid falling back to raster PNG map quality.
- Hardening: `Company Sales` must clear the full `Geo_Governorate_Map` and `Geo_City_Reference` tables, not only `Governorate`, because Deneb row context also carries `SvgPath`; leaving that path filter active makes the tooltip percentage divide each governorate by itself.
- Keep Deneb's `SvgPath`, Sales, Customers, and SalesPct projections active and align the visual viewport with the locked `773.33 x 690` container so Desktop renders from the high-detail vector layer cleanly.

## Server Safety Rule
- Same as Finance: this server hosts the production SAP database.
- All actions are production-critical. Read-only and passive automation only.
