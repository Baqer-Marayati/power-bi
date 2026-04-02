# Project DNA

## Purpose

The Inventory Report provides visibility into Canon Iraq's stock levels, warehouse distribution, product category breakdown, stock movement trends, and procurement pipeline — all sourced from SAP Business One on HANA.

## Intended Audience

- Operations management
- Warehouse supervisors
- Procurement team
- Executive leadership (summary view)

## Enduring Visual Identity Rule

- Inventory must follow the portfolio visual identity baseline from Finance:
  - `Shared/Standards/portfolio-visual-identity.md`
  - `Shared/Standards/portfolio-theme.tokens.json`
- Navy `#1F4E79` brand color, `#F8FBFF` canvas, `#2E3A42` titles, Segoe UI font family.
- KPI cards: white background, border `#C9D5E3`, radius 4, navy top accent shadow.
- Al Jazeera and Canon logos on every page.

## Core Working Method

- PBIP is the editable source of truth.
- Power BI Desktop is required for validation (ODBC data load, relationships, visuals).
- Changes should be committed to Git and synced across workstations.
- Module memory files (`Project Memory/`) must be updated after meaningful work.
- Review artifacts should be packaged and placed in `Exports/`.

## Data Source

- SAP Business One on HANA, ODBC DSN `HANA_B1`, schema `CANON`.
- Read-only access. No writes to SAP.

## Report Structure

Five pages:
1. Inventory Overview (dashboard landing page)
2. Warehouse Distribution (per-warehouse analysis)
3. Stock Movements (inbound/outbound flow)
4. Product Categories (item group breakdown)
5. Procurement (purchase orders and goods receipts)
