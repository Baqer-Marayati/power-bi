# Reference

## Core Paths

- **Active PBIP:** `Reports/Inventory/Inventory Report/Inventory Report.pbip`
- **Report artifact:** `Reports/Inventory/Inventory Report/Inventory Report.Report/`
- **Semantic model:** `Reports/Inventory/Inventory Report/Inventory Report.SemanticModel/`
- **Theme file:** `Reports/Inventory/Module/Core/themes/Inventory.PortfolioTheme.json`
- **Portfolio visual identity:** `Shared/Standards/portfolio-visual-identity.md`
- **Portfolio theme tokens:** `Shared/Standards/portfolio-theme.tokens.json`

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

## Key Facts

- Currency: IQD (Iraqi Dinar) + some USD purchase orders
- 19 warehouses (mix of physical locations and sales rep warehouses)
- 41 item groups using Canon's B2B/B2C hierarchy
- Data window: Dec 31, 2025 – present
- Total on-hand: ~106,541 units
