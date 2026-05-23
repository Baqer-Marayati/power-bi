# Handoff: Stock-cover policy — target quantity, velocity blend, and report implementation

**Purpose:** Give the next agent (or developer) a single document to build and implement the agreed stock-cover logic.

**Repository:** `power-bi` (portfolio root).  
**Primary PBIP:** `Reports/Inventory/Companies/CANON/Canon Inventory Report/`

---

## 1. Context

- **Semantic model:** `Canon Inventory Report.SemanticModel`
- **Report:** `Canon Inventory Report.Report`
- **Stock cover grain:** **Item-level** (not warehouse-level unless explicitly changed). Table **`Fact_StockCoverPolicy`** is built from SAP HANA via ODBC (`HANA_B1`), schema **`CANON`**, with sales combined using existing **CANON + filtered ALJAZEERA** invoice/credit logic in the M query.
- **After implementation, update:**  
  `Reports/Inventory/Module/Project Memory/DECISIONS.md`,  
  `Reports/Inventory/Module/Project Memory/CURRENT_STATUS.md`.

---

## 2. Business definitions (must match this spec)

### 2.1 Policy days (by item business type)

| Business type        | Policy days (cover) |
|----------------------|---------------------|
| **B2B**              | **120**             |
| **B2C**              | **90**              |
| **#N/A** or blank    | **60**              |

Source: e.g. `U_BusinessType` on the item row feeding `Fact_StockCoverPolicy`.

### 2.2 Demand signal

- **Demand** = **net customer sales quantity** from **invoices minus credit notes** (`OINV`/`INV1` plus `ORIN`/`RIN1` nets), using the **existing** branch and customer exclusions already coded in **`Fact_StockCoverPolicy`** M / SQL.
- Do **not** change the sales definition without an explicit business decision.

### 2.3 Velocity and target quantity (core change)

**Do not** use a single fixed rolling window as the only driver for target. Implement a **blended daily velocity** from **three lookback windows only**:

| Window      | Meaning                                      | In blend? | Weight   |
|-------------|----------------------------------------------|-----------|----------|
| **90 days** | Net qty sold in last 90 calendar days        | **Yes**   | **35%**  |
| **180 days**| Net qty sold in last 180 calendar days       | **Yes**   | **35%**  |
| **365 days**| Net qty sold in last 365 calendar days       | **Yes**   | **30%**  |
| **30 days** | Optional for **trend / alerts only**         | **No**    | — **must not** be in the blended target formula |

**Daily rates** (per item, as of model refresh date “today”):

- \( r_{90}  = Q_{90}  / 90 \)
- \( r_{180} = Q_{180} / 180 \)
- \( r_{365} = Q_{365} / 365 \)

where \( Q_{90}, Q_{180}, Q_{365} \) are **net** invoiced quantities in those rolling windows.

**Blended daily velocity:**

\[
v = 0.35 \cdot r_{90} + 0.35 \cdot r_{180} + 0.30 \cdot r_{365}
\]

**Target quantity (policy stock point):**

\[
\text{TargetQty} = v \times \text{PolicyDays}
\]

`PolicyDays` = **120**, **90**, or **60** per §2.1.

**Edge cases:**

- If an item has **no sales** in a window, that window’s \( Q \) is **0** (rate 0 for that window).
- Optional later: “low confidence” tier when \( Q_{365} \) is very small — document if added.
- **Cost for valuation:** use **`AvgItemCost` only** (no fallback to sales price). If average cost is missing/zero, **treat unit value as 0** for gap/excess value measures.

### 2.4 Overstock / understock / healthy (quantity and value)

Use **on-hand quantity** at the **same grain as the fact** (item-level total from `OITW` roll-up as in the existing query unless scope changes).

- **Understock qty** / **Suggested reorder** and **Overstock qty** / **Excess** must be **consistent** with **`StockCoverStatus`** and the same **target vs on-hand** rules (including any **0.9 / 1.1** bands in SQL). **Recompute all derived columns** when `TargetQty` changes.
- **Overstock value** ≈ excess qty × **`AvgItemCost`**
- **Understock / missing reorder value** ≈ relevant shortfall qty × **`AvgItemCost`**

**Healthy band:** Keep one definition everywhere (e.g. ±10% around target, or existing 90%/110% factors in SQL) — document in `DECISIONS.md`.

### 2.5 Page semantics

- **Stock Cover Value Exposure:** summary **value** view; status donut = **current stock value by cover status**; **missing reorder value** is **separate** (clear labels — it can exceed current stock value).
- **Reorder Action List:** **operational** SKU-level **quantities** and actions.

---

## 3. Technical implementation checklist

1. **`Fact_StockCoverPolicy` (M / SQL)**  
   - Add rolling-window aggregates: **\( Q_{90}, Q_{180}, Q_{365} \)** per item (net sales, refresh-relative “today”).  
   - Compute **blended \( v \)** and **new `TargetQty` = \( v \times \text{PolicyDays} \)** (prefer **one place** — SQL/M usually best — to avoid drift with DAX).  
   - Update **`PolicyDays`** in SQL: **B2B → 120**, **B2C → 90**, **else → 60**.  
   - Recompute **`TargetStockQty`**, **`StockDifferenceQty`**, **`SuggestedReorderQty`**, **`ExcessQty`**, **`StockCoverStatus`**, **`SuggestedAction`** so they align with the new target and existing band logic.

2. **`_Measures.tmdl`**  
   - Align measures with new columns; **cost-only** for gap/excess value measures; **no** `AvgItemPrice` fallback for those.

3. **Report visuals**  
   - Confirm bindings and titles: status donut = current value by status; gap metrics labeled clearly.

4. **Validation**  
   - 2–3 SKUs: hand-check \( Q_{90}, Q_{180}, Q_{365} \), then \( v \), **TargetQty**, vs model.  
   - Donut slice totals vs total current stock (same grain).

5. **Documentation**  
   - Update **`DECISIONS.md`** with blend, windows, policy days (120/90/60), cost rule, page rules.

---

## 4. Non-goals (unless reopened)

- Warehouse-level policy as default.  
- Purchase orders as primary demand.  
- Average selling price as cost proxy.

---

## 5. Acceptance criteria

- [ ] **TargetQty** = blended velocity × **PolicyDays** with **35% / 35% / 30%** on **90d / 180d / 365d** rates; **30d not in blend**.  
- [ ] **PolicyDays:** B2B **120**, B2C **90**, N/A **60**.  
- [ ] Status and excess/reorder fields **match** the new target and band rules.  
- [ ] Value measures: **`AvgItemCost` only** for gap/excess.  
- [ ] Value Exposure: status donut = **current stock by status**; gap = **separate**.  
- [ ] Reorder list **operational** with updated quantities.  
- [ ] `DECISIONS.md` (+ `CURRENT_STATUS.md` if needed) updated.

---

## 6. Worked examples (sanity check)

**Inputs:**

- \( Q_{90}=360,\ Q_{180}=540,\ Q_{365}=730 \)
- \( r_{90}=4,\ r_{180}=3,\ r_{365}=2 \)
- \( v = 0.35 \cdot 4 + 0.35 \cdot 3 + 0.30 \cdot 2 = 3.05 \) units/day

**Targets by policy:**

| Segment | PolicyDays | TargetQty        |
|---------|------------|------------------|
| B2B     | 120        | \( 3.05 \times 120 = 366 \) |
| B2C     | 90         | \( 3.05 \times 90 = 274.5 \) |
| N/A     | 60         | \( 3.05 \times 60 = 183 \)   |

Compare **on hand** to **TargetQty** for understock/overstock/healthy per §2.4.

---

## 7. SQL hint: PolicyDays case

```sql
CASE
  WHEN U_BusinessType = 'B2B' THEN 120
  WHEN U_BusinessType = 'B2C' THEN 90
  ELSE 60
END AS PolicyDays
```

(Adjust column names to match the actual query.)

---

*End of handoff prompt.*
