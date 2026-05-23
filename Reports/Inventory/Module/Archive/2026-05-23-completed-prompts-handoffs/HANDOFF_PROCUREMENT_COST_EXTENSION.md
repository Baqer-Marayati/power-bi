# Handoff: Extend “Procurement & Suppliers” with purchase cost analytics

**For:** Next agent implementing Power BI (PBIP) work in this repo.  
**Do not treat this file as user-facing product documentation** — it is an implementation brief.

---

## Goal

Extend the existing **Procurement & Suppliers** report page with analytics that answer: **“Are we paying more or less per unit when inventory comes in (by business type, e.g. B2B as a whole), and what drove the change?”**  

Also **reorder report tabs** so **Procurement & Suppliers appears immediately after Reorder Actions** (last in the strip, or wherever Reorder Actions currently sits — the requirement is: *Procurement & Suppliers follows Reorder Actions*).

This is **not** the same as **Average Unit COGS** on sales movements (Executive Summary). Keep purchase-cost logic **inbound / receipt** oriented unless clearly labeled otherwise.

---

## Scope and constraints

- **Module:** `Reports/Inventory/`
- **Company PBIP (source of truth):**  
  `Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.pbip`
- **Mirror:** If portfolio practice requires PAPERENTITY parity, replicate pattern there only after CANON is validated — state in module `CURRENT_STATUS.md` what was done.
- **Read order before edits:** Root `AGENTS.md` → `Reports/Inventory/AGENTS.md` → this file → `Reports/Inventory/Module/Project Memory/CURRENT_STATUS.md` and `DECISIONS.md`.
- **Branding:** Follow existing Inventory / portfolio theme (navy baseline, etc.). Do not introduce ad-hoc palettes that fight the registered theme.
- **Data:** SAP HANA schema **`CANON`** (same as existing model). Reuse `Dim_Date`, `Dim_Item`, `Fact_GoodsReceipt`, `Fact_PurchaseOrder`, and inventory movement facts where appropriate.

---

## Current technical anchors (verify in repo)

- **Goods receipts:** `Fact_GoodsReceipt` — `OPDN` + `PDN1`, fields include `DocDate`, `ItemCode`, `Quantity`, `Price`, `LineTotal`, etc.
- **Purchase orders:** `Fact_PurchaseOrder` — `OPOR` + `POR1`.
- **Sales COGS movement fact (for context only):** `Fact_StockMovement` — `OINM`-based; used for `Total COGS` / `Total Sold Qty` — **do not reuse as the primary “purchase cost” metric** on this extension.
- **Business type:** `Dim_Item[U_BusinessType]`. **Normalize blank:** treat `NULL`/empty string like Power BI and prior analysis: either map to **`#N/A`** or **`(blank)`** consistently so tiny phantom series (blank legend) do not appear. Align with how Executive Summary matrix shows business type.

---

## Metrics to implement (simple definitions)

Deliver **at minimum** the following on the extended page section (KPIs + one primary trend + one detail table). Use **IQD** formatting consistent with existing monetary measures.

### 1) Weighted average inbound unit cost (by month and business type)

**Plain language:** Total inventory dollars posted on **purchase-type inbound movements** divided by total **inbound quantity** for the same slice.

**Suggested grain:** Calendar month × `U_BusinessType` (normalized).

**Implementation note:** The model may need **new measures** and possibly **an enriched fact or DAX bridge** if `Fact_GoodsReceipt` alone does not match the SAP logic used in prior ad-hoc analysis (which also considered `OINM` trans types such as **18** and inbound **20**). The implementing agent MUST reconcile:

- Whether **GRPO-only** (`OPDN`/`PDN1`) is sufficient for stakeholders, **or**
- Whether **inventory valuation movements** (`OINM` with `InQty > 0` and `TransType` in **18, 20** — confirm against SAP B1 in Desktop) are required for parity with finance.

Document the chosen definition in `Reports/Inventory/Module/Project Memory/DECISIONS.md` in one short bullet.

### 2) Month-over-month % change in that weighted average

**Formula:**  
`(ThisMonthAvg - PriorMonthAvg) / PriorMonthAvg`  
Use safe **DIVIDE** semantics; show **BLANK** when prior month is zero/blank.

### 3) Optional but strongly recommended: index vs baseline

**Example:** First month in filter context = 100; subsequent months = current avg / baseline × 100.  
Helps executives read “**+8% since Jan**” without mental math.

### 4) Optional diagnostic: “did this receipt push item cost up or down?”

At item × warehouse grain, compare **moving average** style fields from **`OINM`** (e.g. `CalcPrice` before vs after inbound sequence — **verify column availability and ordering** in the tenant). Aggregate to business type with clear rules (e.g. % of inbound lines where `CalcPrice` increased vs decreased, optionally quantity-weighted).

If this is too heavy for v1, add a **stretch** section in `NEXT_STEPS.md` instead of blocking shipment.

---

## UX / layout requirements

- **Extend** `Procurement & Suppliers` — do **not** create a separate new tab unless the single page becomes unusably dense. If two tabs are required, record the exception in `DECISIONS.md` and keep navigation order per below.
- Add a **dedicated section** (visual grouping — background shape or subtitle) titled e.g. **“Purchase unit cost trend”** so it is obvious this is not PO count / GR value only.
- **Page order:** In Power BI, set **Procurement & Suppliers** to appear **immediately after Reorder Actions**. In PBIP this is typically reflected in `definition/pages/pages.json` (or equivalent) — the implementing agent must adjust order there and verify in Desktop.
- **Slicers:** Reuse the same global slicer rail pattern as other Inventory pages where possible (year/quarter/month, business type, group/product/segment as applicable).
- **Detail table:** Top **N** items or **N** receipt lines contributing to the month-over-month change (by absolute delta in extended cost or qty × unit cost — pick one rule and document it).

---

## Edge cases (must handle)

- **Blank `U_BusinessType`:** No invisible series; consistent bucket.
- **Zero or negative quantities** on source rows: exclude or treat per DECISIONS; no divide-by-zero.
- **Currencies / rates:** If multi-currency appears in source tables, either filter to company local / document assumption (likely IQD-only for CANON).
- **One-off mega lines:** Consider footnote or conditional formatting when a single `DocNum` moves the monthly average by >X% (optional v2).

---

## Files the next agent will likely touch

- Report:  
  `Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.Report/definition/pages/e5f6a7b8c9d0e1f2a3b4/` (Procurement & Suppliers — confirm folder id if it changes)
- Page order:  
  `.../Canon Inventory Report.Report/definition/pages.json` (or project-standard equivalent)
- Semantic model:  
  `.../Canon Inventory Report.SemanticModel/definition/tables/_Measures.tmdl`  
  Possibly new calculated table or extended `Fact_*` only if necessary — prefer measures on existing facts unless grain is wrong.
- Memory (after meaningful work):  
  `Reports/Inventory/Module/Project Memory/CURRENT_STATUS.md`  
  `Reports/Inventory/Module/Project Memory/DECISIONS.md` (metric definitions)

---

## Validation checklist (Definition of Done)

1. Open **Canon Inventory Report.pbip** in Power BI Desktop, refresh model.
2. On **Procurement & Suppliers**, confirm new visuals respond to date and business-type slicers.
3. Confirm **tab order**: Reorder Actions → **then** Procurement & Suppliers.
4. Spot-check **SAP** for one month and business type: weighted average inbound unit cost matches within acceptable rounding (document any intentional divergence from raw SQL).
5. Confirm **no duplicate phantom series** in line charts (blank business type).
6. Update **module memory** (`CURRENT_STATUS.md`, and `DECISIONS.md` for metric definitions).

---

## Background: why this exists

Executive Summary **Average Unit COGS** reflects **sales** mix and booked COGS at sale time. Stakeholders also want **purchase / inbound** unit cost pressure and % change over time by **B2B / B2C / N/A**. That belongs with **Procurement & Suppliers**, not buried on Executive Summary.

---

## Explicit non-goals for this task

- Redesign unrelated pages (Stock Cover, Reorder Actions layout overhaul).
- Change SAP extract security or credentials.
- Replace Executive Summary COGS visuals unless explicitly requested in a follow-up.

---

*Prepared as a transfer prompt: extend Procurement & Suppliers with purchase cost analytics; place the page after Reorder Actions; document metric choices in module memory.*
