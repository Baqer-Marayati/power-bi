# Next Steps

## Immediate Priority

1. Open the Fabric-bound `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip` in Power BI Desktop/Fabric and refresh the landed-cost tables after the May 16 source correction.
2. Validate the corrected SAP B1 landed-cost query against CANON HANA using the populated `IPF1.BaseType` values from the data pull (`18` and `69`), plus `IPF1.OriBAbsEnt`, `IPF1.OriBLinNum`, `TtlExpndSC/TtlExpndLC`, `IPF2.CostSumSC/CostSum`, and `OALC.CostCateg`.
3. Sample a landed-cost document and confirm `Landed unit = supplier base + SAP landed add-ons` within rounding; inspect `_Measures[Landed Bridge Residual]`, especially Customs Fees, Shipping Cost, Unloade Fees, and Insurance.
4. In the app, confirm **Procurement & Suppliers** has no missing-custom-visual error, one top KPI row, the tightened slicer rail, the landed-cost mix column chart, and the paid/landed/COGS trend.
5. Test Year × Quarter × Month plus item/category slicers on the new landed cards, bridge, mix chart, paid-unit/landed-unit/COGS line chart, and detail table.
6. Validate `Fact_StockCoverPolicy` against the SAP Query Manager export (`Stock Report.xlsx`) for sample SKUs.

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
