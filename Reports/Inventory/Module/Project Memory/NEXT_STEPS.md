# Next Steps

## Immediate Priority

1. Open the Fabric-bound `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip` in Power BI Desktop/Fabric and refresh the landed-cost tables after the enhanced OIPF header additions.
2. Validate the corrected SAP B1 landed-cost query against CANON HANA using populated `IPF1.BaseType` values (`18` and `69`), `IPF1.OriBAbsEnt`, `IPF1.OriBLinNum`, `TtlExpndSC/TtlExpndLC`, `IPF2.CostSumSC/CostSum`, `OALC.CostCateg`, and the new `OIPF.AgentCode/AgentName`, `OpenForLaC`, `DocStatus`, `ExCustomSC`, `ActCustSC`, `ExpCustom`, `ActCustom`, `CustDate`, and `incCustom` fields.
3. Spot-check LC 100008: confirm broker `VE-00052`, vendor `VE-00080`, open/closed status, customs values, and landed-unit total reconcile within rounding.
4. Test the **Analyze by** slicer on **Receipt date** vs **LC posting date**. Confirm landed cards, bridge, mix, customs strip, and detail table shift as expected; document any flat results caused by receipt-date fallback for non-GRPO landed-cost rows.
5. Create and test the Desktop/Fabric bookmark buttons for **View all LC** and **Finance / Closed LC** if the source-generated LC Status slicer behaves correctly after refresh. The source file currently exposes the status slicer and finance note; bookmark state still needs Desktop authoring/validation.
6. In the app, confirm **Procurement & Suppliers** has no missing-custom-visual error, one top KPI row, the metric glossary, Analyze by / Broker / LC Status slicers, customs mini-cards, the landed-cost mix column chart, and the paid/landed/COGS trend.
7. Test Year × Quarter × Month plus item/category/broker/status slicers on the new landed cards, bridge, mix chart, paid-unit/landed-unit/COGS line chart, customs strip, and detail table.
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
