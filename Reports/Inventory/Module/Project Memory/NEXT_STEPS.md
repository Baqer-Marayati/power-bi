# Next Steps

## Immediate Priority

1. Open `Canon Inventory Report.pbip` in Power BI Desktop to validate connectivity and data load.
2. Confirm all relationships load without errors.
3. Validate `Fact_StockCoverPolicy` against the SAP Query Manager export (`Stock Report.xlsx`) for sample SKUs.
4. Adjust Stock Cover Health and Reorder Action List visual sizes based on actual data rendering.
5. Review KPI card values against SAP data for accuracy.

## Near-Term Improvements

1. Validate the new Procurement & Suppliers purchase-unit-cost section in Power BI Desktop: refresh, slicer behavior, tab order, and one month/business-type spot check against SAP receipt lines.
2. Reconcile whether OINM inbound valuation (`TransValue / InQty` for purchase-type inbound movements) should be added later as a finance diagnostic beside the GRPO paid-unit metric.
3. Add Stock Value calculation using OIVL cost layers instead of AvgPrice (more accurate).
4. Add a conditional formatting rule to highlight "#N/A" item group in the category page.
5. Add warehouse type classification (physical location vs. sales rep) to Dim_Warehouse.
6. Extend slow/no-sales stock analysis from the new stock-cover policy table.
7. Add drill-through from Warehouse page to item-level detail.

## Future Pages

1. **Serial Number Tracking** — when serial data (OSRN, 6,349 entries) is mature enough for dedicated reporting.
2. **Stock Aging** — once sale date derivation is available from ODLN/OIVL.

## Packaging

- Work and review directly from the active company PBIP. There is no zip packaging workflow for Inventory.
