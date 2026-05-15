# Next Steps

## Immediate Priority

1. Open the Fabric-bound `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip` in Power BI Desktop and refresh the new landed-cost tables.
2. Validate the standard SAP B1 landed-cost query fields against CANON HANA (`OIPF/IPF1/IPF2/OALC`), especially `IPF1.OrigLine`, `TtlExpndSC/TtlExpndLC`, `IPF2.CostSumSC/CostSum`, and `OALC.CostCateg`.
3. Sample a landed-cost document and confirm `Landed unit = supplier base + SAP landed add-ons` within rounding; inspect `_Measures[Landed Bridge Residual]`.
4. Test Year × Quarter × Month plus item/category slicers on the new landed cards, bridge, mix chart, paid-unit-vs-COGS line chart, and detail table.
5. Validate `Fact_StockCoverPolicy` against the SAP Query Manager export (`Stock Report.xlsx`) for sample SKUs.

## Near-Term Improvements

1. Reconcile whether OINM inbound valuation (`TransValue / InQty` for purchase-type inbound movements) should be added later as a finance diagnostic beside the GRPO paid-unit and true landed-unit metrics.
2. Add Stock Value calculation using OIVL cost layers instead of AvgPrice (more accurate).
3. Add a conditional formatting rule to highlight "#N/A" item group in the category page.
4. Add warehouse type classification (physical location vs. sales rep) to Dim_Warehouse.
5. Extend slow/no-sales stock analysis from the new stock-cover policy table.
6. Add drill-through from Warehouse page to item-level detail.

## Future Pages

1. **Serial Number Tracking** — when serial data (OSRN, 6,349 entries) is mature enough for dedicated reporting.
2. **Stock Aging** — once sale date derivation is available from ODLN/OIVL.

## Packaging

- Work and review directly from the active company PBIP. There is no zip packaging workflow for Inventory.
