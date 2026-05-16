# Next Steps

## Immediate Priority

1. Open the Fabric-bound `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip` in Power BI Desktop/Fabric and refresh the landed-cost tables after the May 16 semantic correction.
2. Validate that `Fact_LandedCostAllocation` now populates receipt date through `OriBAbsEnt -> OPDN.DocEntry` without requiring `OriBDocTyp = '20'`, and that IPF2 add-ons use booked/local `CostSum` before `CostSumSC`.
3. Spot-check LC 100008: confirm broker `VE-00052`, vendor `VE-00080`, open status, header customs projection/actual = 0, booked customs fees from IPF2/OALC where applicable, and landed-unit total reconcile within rounding.
4. Test the **Analyze by** slicer on **Receipt date** vs **LC posting date**. The May 16 diagnostic pull showed matched receipt and LC dates currently have 0-day delta, so a flat toggle result can be data-truth rather than a visual bug.
5. Create and test the Desktop/Fabric bookmark buttons for **View all LC** and **Finance / Closed LC** if the source-generated LC Status slicer behaves correctly after refresh. The source file currently exposes the status slicer and finance note; bookmark state still needs Desktop authoring/validation.
6. In the app, confirm **Procurement & landed cost** has no missing-custom-visual error, one top KPI row, the metric glossary, Analyze by / Broker / LC Status slicers, the landed-cost mix column chart, the add-on category % of landed trend, and the LC detail table.
7. Test Year × Quarter × Month plus item/category filters on the landed cards, bridge, mix chart, add-on category trend, and detail table.
8. Validate `Fact_StockCoverPolicy` against the SAP Query Manager export (`Stock Report.xlsx`) for sample SKUs.

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
