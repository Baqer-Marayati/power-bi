# Deferred Service Revenue (Warranty) — SAP B1 Setup Plan

**Owner:** Finance + IT (developer)
**Status:** Draft for accountant + developer review
**Author:** Drafted 2026-05-10
**Scope:** Canon Iraq (CANON schema). Same pattern is reusable for PAPERENTITY, ALJAZEERA.
**Goal:** Replace the current ad-hoc "AP-Invoice-for-cost / AP-Credit-Memo-for-revenue" warranty workflow with a proper IFRS 15-compliant **service-type warranty** mechanism in SAP Business One, so that:

1. Total reported group revenue is **never inflated**.
2. Product revenue and service (warranty) revenue are recognized in the **correct period**.
3. The Sales report and Financial report **reconcile automatically**, with no monthly manual reconciliation.
4. Auditor and tax authority can trace every IQD from sale to recognition.

---

## 1. Accounting framework (the *why*)

### 1.1. Standard applied
**IFRS 15 — Revenue from Contracts with Customers**, paragraphs B28–B33 (warranties).

### 1.2. Warranty classification
IFRS 15 splits warranties into two types:

| Type | Definition | Treatment |
|---|---|---|
| **Assurance-type** | Promise the product will function as advertised. Mandatory factory warranty included in price; customer cannot decline it. | **Not** a separate performance obligation. Accrue **expected cost** at sale (`Dr Warranty Expense / Cr Warranty Provision`). Revenue **not** split. |
| **Service-type** | Service beyond "it works" — extended warranty, planned maintenance, on-site service, parts replacement program. Customer could reasonably buy it separately. | **Separate performance obligation**. **Allocate** part of the transaction price, defer it as a contract liability, recognize over the service period. |

**Decision required from accountants:** Confirm that the warranty Canon Iraq is selling on machines is **service-type**. The fact that the warranty cost flows to the **Service Department** as future revenue, and the indirect-channel pattern in April 2026 was explicitly labeled as a separate revenue stream, strongly indicates service-type.

> The rest of this plan assumes **service-type warranty**. If accountants instead classify it as assurance-type, see Appendix A for the alternative (cost-accrual only) setup.

### 1.3. Allocation method
IFRS 15.74 requires allocating the transaction price based on **relative standalone selling prices**. Since warranty is rarely sold separately at a published list price, Canon Iraq must adopt an **estimation method**. IFRS 15.79 permits three:

1. **Adjusted market assessment** — what would the market charge?
2. **Expected cost plus a margin** — most defensible and audit-friendly.
3. **Residual approach** — only when one component is highly variable.

**Recommendation:** Use **expected cost plus a margin** based on Canon Iraq's own historical warranty claims data:

> `Allocation % = (Expected warranty cost per machine ÷ Average machine selling price) × (1 + service-margin %)`

**Decision required from accountants:**
- Pull 24 months of historical warranty claims (`PCH1` lines on `SV003` and `Warranty COGS`-coded accounts) and divide by historical machine sales by category.
- Choose service-margin (commonly 15–30% on top of cost).
- Set the **allocation %** per product category (printers vs MFPs vs cartridges might differ).
- Document this in an internal accounting policy memo, signed and dated.

**Provisional working assumption** (replace once data is run): **3% of the qualifying product line total, flat across all machine categories.**

### 1.4. Recognition pattern
IFRS 15.B30 requires the deferred portion to be recognized **as the entity satisfies the performance obligation**. Two acceptable patterns:

| Pattern | When to use | Example |
|---|---|---|
| **Straight-line over warranty period** | Customer benefits evenly throughout the period, claims pattern is roughly even | Apple AppleCare, Dell ProSupport |
| **In proportion to expected cost incurrence** | Costs are back-loaded (e.g. machines fail more in year 2–3) | Auto OEMs, heavy equipment |

**Recommendation for Canon Iraq, Phase 1:** **Straight-line over 12 months** starting from invoice date. Simpler to implement, defensible, easy to amend later if claims data shows non-linear pattern.

**Decision required from accountants:** Confirm the warranty period (12 months / 24 months / 36 months / variable per product?).

### 1.5. Tax treatment (Iraq)
- VAT on the bundled sale: applied to the **full transaction price** at the point of sale, irrespective of the IFRS 15 split. The split is purely a financial-reporting reclassification on the credit side; AR and VAT-output are unaffected.
- Income tax: deferred service revenue is **not** taxable until recognized to the P&L (matching principle). Confirm with Canon Iraq's tax advisor.

**Decision required from accountants:** Confirm with tax advisor that deferred-revenue treatment matches Iraqi income tax filing requirements.

---

## 2. Chart of Accounts additions

Add the following GL accounts, following the existing 12-digit Canon CoA pattern. Group numbers reference `OACT.GroupMask`.

| New AcctCode | AcctName | Group | Type | Purpose |
|---|---|---|---|---|
| `220101010120` | Deferred Service Revenue — Direct | 2 (Liab) | Balance Sheet | Holds carved-out warranty pool from direct-channel sales |
| `220101010121` | Deferred Service Revenue — Indirect | 2 (Liab) | Balance Sheet | Same, indirect channel |
| *(existing)* `450101010107` | Service Revenue External | 4 (Rev) | P&L | Where amortized warranty revenue lands. **Already exists.** |
| *(existing)* `550101010106` | Warranty COGS | 5 (COGS) | P&L | Where actual warranty service costs land. **Already exists.** |
| `220101010122` | Warranty Cost Accrual *(only if assurance-type — see §1.2)* | 2 (Liab) | Balance Sheet | For the assurance-type alternative; not used in Phase 1 |

Why two deferred-revenue accounts (Direct vs Indirect)? It mirrors the existing `BusinessType` / `SalesType` segmentation in the model and makes the channel split visible on the balance sheet without UDF gymnastics. It also matches the April 2026 entry's "In-Direct Dept." labeling.

**Action for accountants:** review and approve account codes before IT creates them in B1.

---

## 3. SAP B1 master data setup

### 3.1. Item Group

Create a new **Item Group**: `WARRANTY-SERVICES`.

- **Administration → Setup → Inventory → Item Groups → Add.**
- Set default GL accounts (under "Set G/L Accounts By: Item Group"):
  - **Revenue Account** = `220101010120 Deferred Service Revenue — Direct` (will be overridden per-item where needed)
  - **Sales Returns Account** = same
  - **COGS Account** = leave blank (non-stock items don't post COGS)

### 3.2. Service Items (non-stock)

Create two **non-stock service items** (in OITM with `InvntItem='N'`, `SalesItem='Y'`, `PrchseItem='N'`):

| ItemCode | ItemName | Item Group | Sales GL Account |
|---|---|---|---|
| `WARRANTY-SVC-DIR` | Warranty Service — Direct Channel (Deferred) | `WARRANTY-SERVICES` | `220101010120` Deferred Service Revenue — Direct |
| `WARRANTY-SVC-IND` | Warranty Service — Indirect Channel (Deferred) | `WARRANTY-SERVICES` | `220101010121` Deferred Service Revenue — Indirect |

Important properties for each:

- `InvntItem = 'N'` (non-stock)
- `SalesItem = 'Y'`
- `PrchseItem = 'N'`
- `MngMethod = 'N'` (no inventory management)
- Tax code: same as machine sales (so VAT calculates correctly on the full bundled invoice)
- UDFs to add at Item-master level:
  - `U_WarrantyMonths` (numeric, default 12)
  - `U_WarrantyAllocPct` (numeric, default 3.0) — used by the FMS/SDK that auto-generates the line

### 3.3. Existing machine items — add a flag

Add a new UDF on `OITM`:
- `U_HasServiceWarranty` (Y/N, default 'N')

Set this flag to `'Y'` on every item that should auto-trigger a warranty service line (printers, MFPs, copiers, etc.). This is what the FMS/SDK will read.

### 3.4. User-Defined Table for the warranty contract subledger

Create UDT `@WARRANTY_CONTRACTS`:

| Field | Type | Purpose |
|---|---|---|
| `Code` (PK) | Auto-string (`WC0000001`...) | Contract ID |
| `U_BaseDocType` | string ('OINV'/'ORIN') | Source document type |
| `U_BaseDocEntry` | int | Source DocEntry |
| `U_BaseLineNum` | int | Source line on the AR invoice |
| `U_CardCode` | string | Customer |
| `U_ProductItemCode` | string | Machine sold |
| `U_ProductQty` | numeric | Qty |
| `U_SaleDate` | date | `OINV.DocDate` |
| `U_DeferredOriginal` | numeric | Original deferred amount at sale |
| `U_AmortMonths` | int | e.g. 12 |
| `U_AmortStartDate` | date | First month of recognition (= month of sale) |
| `U_AmortEndDate` | date | Last month |
| `U_CumRecognized` | numeric | Running total recognized |
| `U_RemainingBalance` | numeric | `U_DeferredOriginal - U_CumRecognized` |
| `U_Channel` | string ('DIR'/'IND') | Direct vs Indirect |
| `U_Status` | string ('Active'/'Cancelled'/'Completed') | Lifecycle |
| `U_LastRecognizedPeriod` | string ('YYYY-MM') | Idempotency key for monthly batch |

Permissions: Finance has full access. Sales has read-only. IT-batch user has insert/update. Nobody has delete.

---

## 4. Document workflow — what happens at sale

### 4.1. Manual workflow (Phase 1 — works today, no dev required)

When a salesperson creates an AR Invoice for a qualifying machine (e.g. a printer):

1. Enter the machine line normally (e.g. printer, qty 1, price 1,000,000).
2. Add a second line:
   - `ItemCode` = `WARRANTY-SVC-DIR` (or `WARRANTY-SVC-IND` for indirect channel)
   - `Qty` = 1
   - `UnitPrice` = `3% × 1,000,000` = 30,000 IQD
3. Reduce the machine line price by 30,000 → 970,000.
4. Total invoice to customer = unchanged at 1,000,000 IQD + VAT.

**Resulting GL entry from B1:**

```
Dr  AR (1102…)                            1,000,000
    Cr  Sales Revenue — Machines (45..)         970,000
    Cr  Deferred Service Revenue — Direct (220101010120)   30,000
    Cr  VAT Output                              (per Iraqi VAT rate)
```

This is **already correct** the moment the invoice is added — no end-of-month adjustment needed for the carve-out.

### 4.2. Automated workflow (Phase 2 — recommended)

Add a **Formatted Search (FMS)** or small **B1 SDK add-on** that:

1. On AR Invoice **before-add** event, scans every line.
2. For each line where the item has `OITM.U_HasServiceWarranty = 'Y'`:
   - Computes `warranty_amt = LineTotal × (item.U_WarrantyAllocPct / 100)`
   - Reduces the parent line's `UnitPrice` by `warranty_amt / Qty`
   - Appends a new line:
     - ItemCode: `WARRANTY-SVC-DIR` or `WARRANTY-SVC-IND` based on `OCRD.U_PartnerType` of the customer (Direct vs Indirect)
     - Qty: 1
     - UnitPrice: `warranty_amt`
     - LineRemarks: `"Warranty for line "+BaseLine+", "+months+" months"` (audit hint)
3. Net invoice total stays identical — the salesperson sees the same number.

This eliminates human error and keeps the salesperson's UX unchanged. **Strongly recommended** before going live.

### 4.3. AR Credit Memo path (returns / cancellations)
- When an AR Credit Memo references a base AR Invoice, the FMS/SDK must apply the **same logic** in reverse: for each warranty line on the base, compute the proportional portion to credit and add a `WARRANTY-SVC-*` line to the credit memo.
- The monthly batch (§5) detects credit memos and reverses the corresponding `@WARRANTY_CONTRACTS` rows accordingly (see §5.4).

---

## 5. Period-end recognition (the recurring amortization)

This is the developer's main custom job. There are two acceptable implementations.

### 5.1. Subledger registration on AR Invoice add (developer task)

A B1 add-on or SDK script (recommended: **B1 Service Layer batch + scheduled task**) listens for AR Invoice **after-add** events. For each invoice line where `INV1.ItemCode IN ('WARRANTY-SVC-DIR','WARRANTY-SVC-IND')`:

- Insert a new row into `@WARRANTY_CONTRACTS`:
  - `U_BaseDocType` = 'OINV'
  - `U_BaseDocEntry` / `U_BaseLineNum` from the line
  - `U_DeferredOriginal` = `INV1.LineTotal`
  - `U_AmortMonths` = `OITM.U_WarrantyMonths` (default 12)
  - `U_AmortStartDate` = first day of the month of `OINV.DocDate`
  - `U_AmortEndDate` = last day of (`AmortStartDate + U_AmortMonths - 1`)
  - `U_CumRecognized` = 0
  - `U_RemainingBalance` = `U_DeferredOriginal`
  - `U_Channel` = 'DIR' or 'IND' (from item code)
  - `U_Status` = 'Active'

For AR Credit Memos referencing a base AR Invoice with warranty lines: insert a paired row with negative `U_DeferredOriginal` linked to the original contract via `U_BaseDocEntry` so the monthly batch nets it.

### 5.2. Monthly recognition batch (the core scheduled job)

Run on the **last business day of every month** (or first business day of the next).

**Pseudocode:**

```
batch_period := CURRENT YYYY-MM
foreach contract in @WARRANTY_CONTRACTS where U_Status = 'Active':
    if contract.U_LastRecognizedPeriod >= batch_period:
        continue  -- idempotency: already recognized this month
    monthly_amount := contract.U_DeferredOriginal / contract.U_AmortMonths
    -- guard: don't recognize beyond original
    if contract.U_CumRecognized + monthly_amount > contract.U_DeferredOriginal:
        monthly_amount := contract.U_DeferredOriginal - contract.U_CumRecognized
    add to JE_batch[contract.U_Channel] += monthly_amount
    contract.U_CumRecognized += monthly_amount
    contract.U_RemainingBalance := contract.U_DeferredOriginal - contract.U_CumRecognized
    contract.U_LastRecognizedPeriod := batch_period
    if contract.U_RemainingBalance = 0 and now > contract.U_AmortEndDate:
        contract.U_Status := 'Completed'

post one Manual JE per channel:
    Dr Deferred Service Revenue — Direct      (sum DIR)
        Cr Service Revenue External                (sum DIR)
    Dr Deferred Service Revenue — Indirect    (sum IND)
        Cr Service Revenue External                (sum IND)
    JE memo: "Warranty amortization YYYY-MM (auto)"
    JE Ref1: "WARRANTY-AMORT-YYYY-MM"
```

The JE is **a single manual JE per channel per month**, with the per-contract detail in `@WARRANTY_CONTRACTS`. This keeps GL clean (one JE per channel per month) and the subledger keeps the audit detail.

### 5.3. Implementation options for the batch (developer choice)

| Option | Tech | Pros | Cons |
|---|---|---|---|
| A | **B1 Service Layer + Node.js / Python scheduled task** running on Canon's app server | Cleanest, modern. Same auth as B1. Re-runnable. | Requires SL setup if not already in use. |
| B | **B1 SDK (DI API) console app** scheduled via Windows Task Scheduler | Familiar to most B1 devs, full DI API access | Heavier, harder to deploy. |
| C | **PowerShell script using ODBC + DI API** | Reuses existing infra (already used by `Portfolio/Shared/SAP Export Pipeline`). Easy to schedule. | Less modern, can be brittle. |

**Recommendation: Option A** if Service Layer is available. **Option B** otherwise. Avoid Option C for a financial control.

### 5.4. Reversals / cancellations

Two cases:

1. **Customer returns the machine** → AR Credit Memo against the original AR Invoice → Phase 2 add-on copies warranty line proportionally → `@WARRANTY_CONTRACTS` gets a paired negative row → next monthly batch nets it. If the entire amount is returned and not yet fully recognized, the negative row's monthly amortization mirrors the positive one and they cancel out cleanly going forward, **plus** a one-time "catch-up" entry on the credit-memo date reverses everything previously recognized for that contract:
   - `Dr Service Revenue External / Cr Deferred Service Revenue` for `U_CumRecognized`, then close both rows (`Status = 'Cancelled'`).

2. **Mid-period contract cancellation without credit memo** (rare, manual) → Finance issues a manual JE and updates `@WARRANTY_CONTRACTS.U_Status = 'Cancelled'` directly.

---

## 6. Reconciliation control (mandatory)

At every month-end, after the batch runs, **automatically** verify:

```
SELECT SUM(U_RemainingBalance) FROM @WARRANTY_CONTRACTS WHERE U_Status='Active'
                                ≡
SUM(JDT1 balance on accounts 220101010120 + 220101010121) at period-end
```

If they don't match, the batch must **fail loud** (email Finance, no JE posted that month) and someone investigates. This is the most important control — it tells you the subledger and GL agree.

A small SQL view should be created and exposed in the Financial report as a **"Deferred Service Revenue Rollforward"** matrix:

| Channel | Opening Balance | + Sold This Month | − Recognized This Month | − Cancelled | Closing Balance |
|---|---|---|---|---|---|
| Direct | … | … | … | … | … |
| Indirect | … | … | … | … | … |

---

## 7. Migration / cutover plan

### 7.1. Decision: prospective or retroactive?

**Recommendation: prospective from a clean cutover date** (e.g. **2026-06-01**), with an explicit one-time JE to clean up April 2026's incorrect entries.

Retroactive restatement of Q1 2026 is only required if the auditor demands it; usually a prospective adoption with disclosure in the next financial-statement notes is acceptable for an internal correction of this size.

### 7.2. April 2026 cleanup JE (manual, one-time)

The April entries today are:

- AP Invoice `TransId 8337` → `Dr Warranty COGS 4,471,894.57 / Cr AP IQD 4,471,894.57`
- AP Credit Memo `TransId 8339` → `Dr Service Revenue External 4,471,894.57 / Cr AP IQD 4,471,894.57`

Net effect on GL today: P&L has +4,471,894.57 service revenue and +4,471,894.57 warranty COGS, net P&L impact = 0. AP IQD net = 0. **Functionally the GL is balanced**, but the wrong accounts are inflated and the Sales report doesn't see the revenue side.

**Decision for accountants:** Two options:

| Option | What it does | When to use |
|---|---|---|
| **Leave as-is** | Net P&L = 0, balance is correct, just the **Sales-vs-Financial reconciliation** for April carries a documented variance | If auditor does not require a clean restatement |
| **Reclassify** | Manual JE: `Dr Service Revenue External 4,471,894.57 / Cr Warranty COGS 4,471,894.57` to **net both legs to zero**, then redocument the indirect-channel warranty going forward via the new mechanism | If you want a clean April |

Phase 2 (going forward) sets up the new mechanism so the situation does not recur.

### 7.3. Open warranty obligations from prior sales (Dec 2025 – May 2026)
Before go-live, accountants must decide whether to recognize a **catch-up deferred liability** for machines sold in the past 6–12 months that still have warranty period remaining. Two options:

- **Catch-up at go-live**: estimate (machine sales × 3% × remaining warranty months / 12) and post a JE: `Dr Retained Earnings / Cr Deferred Service Revenue` (or `Dr Service Revenue External / Cr Deferred Service Revenue` if within current year). This is the technically correct treatment if the policy is being applied to existing contracts.
- **Prospective only**: only new sales from go-live carry the deferred-revenue mechanic; previously sold machines continue under the old (cost-as-incurred) model until their warranty period naturally expires.

**Recommendation:** **Prospective only.** Simpler, no estimation risk, auditor-friendly. Document the choice in the policy memo.

---

## 8. Reporting model changes

### 8.1. Sales report (`Reports/Sales/Companies/CANON/.../SalesFact.tmdl`)

Modify the `SalesFact` Power Query so that lines with `ItemCode IN ('WARRANTY-SVC-DIR','WARRANTY-SVC-IND')` are:

- **Excluded** from the `Sales` measure (otherwise they'd inflate the Sales report by 3% and that's exactly the inflation we want to avoid).
- Tagged `BusinessType = 'Warranty Deferred'`, `BPType = 'Warranty'`.

Concretely, in the existing `SELECT … FROM OINV/INV1 …` Power Query, add to the `WHERE` clause:

```sql
AND L."ItemCode" NOT IN ('WARRANTY-SVC-DIR','WARRANTY-SVC-IND')
```

(Or include them with a separate `BusinessType` and let users slice them out.)

The **warranty AP UNION block** (the `OPCH/PCH1 ItemCode='SV003'` part) **stays** for now, because the actual warranty *cost* is still booked via AP Invoice when service work is done. Long-term, once the service department is also issuing internal service-completion documents, that part of the model can be revisited.

### 8.2. Financial report (`Reports/Finance/Companies/CANON/.../Fact_PNL.tmdl`)

The existing Power Query already pulls all `OACT.GroupMask IN (4,5,6,7,8)` accounts, so the new `220...` (Group 2) deferred-revenue accounts **won't** appear in `Fact_PNL`. That's correct — they're balance-sheet, not P&L.

**New Balance Sheet visual:** add a "Deferred Service Revenue" line item to the existing balance-sheet page if one exists (or create one), pulling from the new accounts. This needs a separate fact for balance-sheet movement, which the Finance module may already have.

**New rollforward visual** (recommended): a matrix showing opening / + sold / − recognized / closing per channel per month, sourced directly from `@WARRANTY_CONTRACTS` via a new Power Query partition.

### 8.3. Service report (`Reports/Service/...`)

The Service report should now read its revenue from `Service Revenue External (450101010107)` in the GL, which will properly grow each month as the recurring batch posts. **No structural change needed**, but verify the Service report measures don't double-count by also including the AP-Credit-Memo route (which goes away in the new model).

---

## 9. Governance & controls

| Control | Owner | Frequency |
|---|---|---|
| Sub-ledger to GL reconciliation (§6) | IT batch + Finance review | Monthly |
| Recurring JE review and approval | Finance Manager | Monthly |
| Policy review (% allocation, period) | Accountants + auditor | Annually |
| Actuals vs. accrual analysis (claims experience) | Service Dept + Finance | Quarterly |
| Master-data changes (new warranty items, % overrides) | IT under change control | Ad-hoc |
| AR Credit Memo proper handling | Sales + IT add-on | Per event |
| Year-end auditor walkthrough | Finance Manager | Annual |

---

## 10. Roles & responsibilities

| Role | Responsibilities |
|---|---|
| **Chief Accountant** | Approve §1.2 classification, §1.3 allocation %, §1.4 period, §1.5 tax position, §7 cutover decisions. Sign accounting policy memo. |
| **Tax Advisor** | Confirm Iraqi income tax treatment of deferred revenue. |
| **External Auditor** | Optional: pre-go-live concurrence. Required: review at first year-end after go-live. |
| **B1 Developer** | §2 GL accounts, §3 master data, §3.4 UDT, §4.2 FMS/SDK, §5 monthly batch, §6 reconciliation control. |
| **Finance Manager** | Daily/monthly oversight, approve recurring JE, run reconciliation control. |
| **Sales Operations** | Train salespeople (only relevant if Phase 2 add-on is **not** built — Phase 2 makes it invisible to sales). |
| **Service Manager** | Validate the recognized service revenue makes sense vs. claim activity. |
| **BI / Reporting** | §8 changes to Sales / Finance / Service reports. |

---

## 11. Phased rollout plan

### Phase 0 — Preparation (1–2 weeks)
- [ ] Accountants finalize the §1 policy decisions in writing.
- [ ] Tax advisor confirms §1.5.
- [ ] External auditor briefed (if applicable).
- [ ] IT creates a sandbox B1 environment cloned from production.

### Phase 1 — Foundation (2–3 weeks)
- [ ] Create GL accounts (§2) — sandbox first, then production.
- [ ] Create item group + service items (§3.1, §3.2) — sandbox first.
- [ ] Create UDFs on `OITM` (§3.3).
- [ ] Create UDT `@WARRANTY_CONTRACTS` (§3.4).
- [ ] Manual workflow (§4.1) tested by Finance using two or three real-life test invoices in the sandbox.
- [ ] Verify resulting GL is exactly as expected (§4.1 specimen JE).

### Phase 2 — Automation (3–4 weeks)
- [ ] Develop FMS or SDK add-on for the AR-Invoice line append (§4.2).
- [ ] Develop `@WARRANTY_CONTRACTS` insertion on after-add (§5.1).
- [ ] Develop the monthly batch (§5.2 + §5.3).
- [ ] Develop the reconciliation control (§6).
- [ ] Implement AR Credit Memo path (§4.3, §5.4).
- [ ] End-to-end test in sandbox: 30+ invoices over 3 simulated months, verify subledger == GL at every month-end.

### Phase 3 — Reporting (1–2 weeks)
- [ ] Update `SalesFact` Power Query (§8.1).
- [ ] Add Balance Sheet "Deferred Service Revenue" line + rollforward visual (§8.2).
- [ ] Verify Service report (§8.3).

### Phase 4 — Cutover (1 day)
- [ ] Final accountant sign-off.
- [ ] Production deployment of GL accounts, items, UDT, UDFs, add-on, batch.
- [ ] Train Finance team on month-end batch + reconciliation procedure.
- [ ] Post April 2026 cleanup JE if option B was chosen (§7.2).
- [ ] Go-live announcement.

### Phase 5 — Stabilization (3 months post-go-live)
- [ ] First three monthly batches reviewed line-by-line by Finance Manager.
- [ ] Reconciliation control results filed with month-end close packet.
- [ ] First quarterly actuals-vs-accrual review.

---

## 12. Decisions checklist (for accountants, before Phase 1 starts)

| # | Decision | Status |
|---|---|---|
| D1 | Warranty classification: service-type? (§1.2) | ☐ |
| D2 | Allocation %: flat 3% or per-category? Specific values? (§1.3) | ☐ |
| D3 | Recognition pattern: straight-line? (§1.4) | ☐ |
| D4 | Warranty period: 12 months? Variable? (§1.4) | ☐ |
| D5 | Iraqi income tax treatment confirmed (§1.5) | ☐ |
| D6 | GL account codes (§2) approved | ☐ |
| D7 | Cutover date | ☐ |
| D8 | April 2026: leave as-is or reclassify? (§7.2) | ☐ |
| D9 | Open contracts catch-up: prospective only? (§7.3) | ☐ |
| D10 | Auditor pre-concurrence requested? | ☐ |

Once D1–D10 are answered in writing, IT can begin Phase 1.

---

## Appendix A — Alternative: assurance-type warranty (cost-accrual only)

If accountants determine the warranty is **assurance-type** rather than service-type, the setup is much simpler:

- **No** carve-out at sale. Product revenue = full 1,000,000.
- **At sale**, accrue expected cost: `Dr Warranty Expense (a 6x or 5x account) / Cr Warranty Provision (220101010122)`.
- **When actual claims happen** (your current `SV003` AP Invoice flow): `Dr Warranty Provision / Cr AP`.
- **Quarterly true-up**: compare provision balance to expected outstanding obligations; adjust provision.

This **does not need** the UDT, the recurring batch, or the Sales-report change. It only needs the new provision account and a quarterly review.

The trade-off: it gives less granular service-department revenue visibility and may not match how Canon Iraq is contractually selling the warranty to customers.

---

## Appendix B — Specimen full lifecycle of a single sale

A printer sold 2026-06-15 for 1,000,000 IQD with 3% / 12-month warranty.

**Day of sale (2026-06-15):**
```
Dr  AR — Customer X                        1,000,000
    Cr  Sales Revenue — Machines (45..)         970,000
    Cr  Deferred Service Revenue — DIR (220101010120)  30,000
    Cr  VAT Output                              (per rate)
```
`@WARRANTY_CONTRACTS` row inserted: `WC0000123, OINV, …, DeferredOriginal=30,000, AmortMonths=12, Start=2026-06-01, End=2027-05-31, CumRecognized=0, Remaining=30,000, Channel=DIR, Status=Active`

**End of June 2026 (first amortization):**
```
Dr  Deferred Service Revenue — DIR  2,500
    Cr  Service Revenue External (45..07)   2,500
```
Contract: `CumRecognized=2,500, Remaining=27,500, LastRecognizedPeriod=2026-06`

**End of every month thereafter** (2026-07 through 2027-05): the same 2,500 entry repeats.

**End of May 2027 (last amortization):**
```
Dr  Deferred Service Revenue — DIR  2,500
    Cr  Service Revenue External         2,500
```
Contract: `CumRecognized=30,000, Remaining=0, Status=Completed`

Total recognized: 30,000. Matches `DeferredOriginal`. Subledger and GL agree throughout. Sales report shows 970,000 in June 2026. Service report shows 2,500/month for 12 months. Group total revenue across all reports = 1,000,000 — exactly the original sale price, never inflated.

---

**End of plan.**

When all D1–D10 decisions are answered, this document becomes the executable spec. Update `Reports/Finance/Module/Project Memory/DECISIONS.md` and `MODEL_NOTES.md` as each phase completes.
