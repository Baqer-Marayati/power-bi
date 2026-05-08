# Next Steps

## Immediate Priority

1. Open `Canon Inventory Report.pbip` in Power BI Desktop to validate connectivity and data load.
2. Confirm all relationships load without errors.
3. Validate `Fact_StockCoverPolicy` against the SAP Query Manager export (`Stock Report.xlsx`) for sample SKUs.
4. Adjust Stock Cover Health and Reorder Action List visual sizes based on actual data rendering.
5. Review KPI card values against SAP data for accuracy.

## Near-Term Improvements

1. Add Stock Value calculation using OIVL cost layers instead of AvgPrice (more accurate).
2. Add a conditional formatting rule to highlight "#N/A" item group in the category page.
3. Add warehouse type classification (physical location vs. sales rep) to Dim_Warehouse.
4. Extend slow/no-sales stock analysis from the new stock-cover policy table.
5. Add drill-through from Warehouse page to item-level detail.

## Future Pages

1. **Serial Number Tracking** — when serial data (OSRN, 6,349 entries) is mature enough for dedicated reporting.
2. **Stock Aging** — once sale date derivation is available from ODLN/OIVL.

## Packaging

- Work and review directly from the active company PBIP. There is no zip packaging workflow for Inventory.
