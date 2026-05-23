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

Five CANON pages (management-friendly tab names as of May 2026):

1. **Inventory Overview** — quantities, unit-cost trend, quantity & cost by business type
2. **Stock Value** — current stock worth by category
3. **Stock Health** — overstock / understock / slow-dead stock vs policy
4. **Stock Actions** — item-level buy, hold, reduce list
5. **Landed Cost** — closed import documents: supplier cost, import & handling, shipments detail

Label vocabulary and user exceptions: `DECISIONS.md` (2026-05-22 naming section).
