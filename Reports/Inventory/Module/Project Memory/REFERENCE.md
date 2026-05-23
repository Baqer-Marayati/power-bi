# Reference

## Core Paths

- **CANON module PBIP:** `Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.pbip`
- **PAPERENTITY module PBIP:** `Reports/Inventory/Companies/PAPERENTITY/Paper Inventory Report/Paper Inventory Report.pbip`
- **Fabric iteration copy (Git → Fabric sync):** `Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip`
- **Theme file:** `Reports/Inventory/Module/Core/themes/Inventory.PortfolioTheme.json`
- **Portfolio visual identity:** `Portfolio/Shared/Standards/portfolio-visual-identity.md`
- **Portfolio theme tokens:** `Portfolio/Shared/Standards/portfolio-theme.tokens.json`

## CANON report pages (current tab names)

| Order | Page ID | Tab name | Former name |
|-------|---------|----------|-------------|
| 1 | `a1b2c3d4e5f6a7b8c9d0` | Inventory Overview | Executive Summary |
| 2 | `c7d8e9f0a1b2c3d4e5f6` | Stock Value | Inventory Valuation |
| 3 | `f6a7b8c9d0e1f2a3b4c5` | Stock Health | Stock Cover |
| 4 | `a7b8c9d0e1f2a3b4c5d6` | Stock Actions | Reorder Actions |
| 5 | `e5f6a7b8c9d0e1f2a3b4` | Landed Cost | Procurement & landed cost |

Canvas: **1920 × 1080** on all pages. Hidden tooltip: `tt_landed_addon_m01`.

## Data Source

- **System:** SAP Business One on HANA
- **Connection:** ODBC DSN `HANA_B1`
- **Schema:** `CANON`
- **Server:** `hana-vm-107:30013`
- **Database:** `HV107C21694P01`
- **Access:** Read-only

## SAP Tables Used

| Table | Description | Approx. Rows |
|-------|-------------|-------------|
| OITM + OITB | Item Master + Groups | 1,456 |
| OWHS | Warehouses | 19 |
| OITW | Item-Warehouse Stock | 27,664 |
| OIVL | Inventory Valuation Layers | 8,000 |
| OWTR + WTR1 | Inventory Transfers | 336 / 1,177 |
| ODLN + DLN1 | Delivery Notes | 401 / 1,248 |
| OPDN + PDN1 | Goods Receipt PO | 19 / 355 |
| OPOR + POR1 | Purchase Orders | 31 / 373 |
| OIPF + IPF1 + IPF2 + OALC | SAP B1 Landed Cost header, receipt-line allocations, cost lines, and landed-cost codes | Validate on refresh |

## Key Facts

- Currency: IQD (Iraqi Dinar) + some USD purchase orders
- 19 warehouses (mix of physical locations and sales rep warehouses)
- 41 item groups using Canon's B2B/B2C hierarchy
- Data window: Dec 31, 2025 – present
- Total on-hand: ~106,541 units
