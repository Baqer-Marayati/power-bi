# Next Steps

## Immediate Priority

1. Open `Inventory Report.pbip` in Power BI Desktop to validate connectivity and data load.
2. Confirm all relationships load without errors.
3. Adjust visual sizes and positions based on actual data rendering.
4. Review KPI card values against SAP data for accuracy.

## Near-Term Improvements

1. Add Stock Value calculation using OIVL cost layers instead of AvgPrice (more accurate).
2. Add a conditional formatting rule to highlight "#N/A" item group in the category page.
3. Add warehouse type classification (physical location vs. sales rep) to Dim_Warehouse.
4. Implement slow-moving/dead stock analysis by deriving last sale date from ODLN transaction history.
5. Add drill-through from Warehouse page to item-level detail.

## Future Pages

1. **Serial Number Tracking** — when serial data (OSRN, 6,349 entries) is mature enough for dedicated reporting.
2. **Stock Aging** — once sale date derivation is available from ODLN/OIVL.

## Packaging

- After Desktop validation, create `Exports/Server Packages/` folder and build a `ready.zip` package for review, following the Finance module pattern.
