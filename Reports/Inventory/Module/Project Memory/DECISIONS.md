# Decisions

## Purpose

Use this file for approved directions and durable constraints in the Inventory Report module.

## 2026-03-27

- Start the Inventory report by creating and stabilizing module structure before building report pages.
- Keep this module's folder contract and operating style aligned with `Reports/Finance` where applicable.
- Use `Inventory Report` as the initial working title unless business naming changes later.
- Inherit the portfolio unified theme and branding style from the Finance baseline (backgrounds, chart palettes, KPI styling, and overall visual language).

## 2026-03-27 — PBIP Build

- PBIP created with 5 pages and full SAP HANA ODBC semantic model targeting `CANON` schema.
- Star schema design: 3 dimension tables (Item, Warehouse, Date) + 6 fact tables (WarehouseStock, StockMovement, Transfer, Delivery, GoodsReceipt, PurchaseOrder).
- 24 DAX measures in `_Measures` table covering stock position, movements, transfers, deliveries, and procurement.
- Logos (Al Jazeera + Canon) and theme copied from Finance registered resources to maintain brand consistency.
- IQD currency formatting applied to monetary measures using `ar-IQ` culture hint.
- Stock Value measure uses `AvgPrice` from OITM as interim approach; OIVL cost layers recommended for future accuracy.
- `Dim_Date` is a DAX calculated calendar (Dec 2025 – Dec 2026) to match the SAP data window.
