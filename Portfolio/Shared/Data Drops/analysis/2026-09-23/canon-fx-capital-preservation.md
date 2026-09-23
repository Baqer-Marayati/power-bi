# Canon Iraq — capital, inventory and margins against the dollar (2026 YTD)

Revision 2, 23 September 2026, for Canon (Al Jazeera) management. Companion canvas: `canon-fx-capital-preservation.canvas.tsx`.
Revision 1 (same morning) used online rates only; this revision adds SAP's own rate table, its dollar ledger, the rate on
every document, dollar cost per item and the price lists.

## Inputs

| Model | Workspace / dataset | Used for |
|---|---|---|
| Canon Financial Report | Development Workspace `b1e83d9b-1d75-4fdf-9fad-98318bf9147a`, refreshed 23 Sep ~15:00 | `Fact_ExchangeRate` (ORTT), `Dim_CompanyCurrency` (OADM), `Fact_GLCurrencyMonthly` (JDT1 in LC/SC/FC), `Fact_FxDocument`, `Fact_PurchaseLineFx`, `Fact_ItemPrice` |
| Canon Financial Report | Canon Analytics `7e404446-60d0-40d6-895a-9bdfb5213f7c`, refreshed 23 Sep 08:00 | `Fact_BalanceSheet`, `Fact_PNL`, `PayablesFact`, `Fact_SalesDetail` |
| Canon Inventory Report | Canon Analytics `1d4d7a8c-f9ca-431d-8e7b-10188f7f9f78` | `InventoryValuation`, `Fact_StockMovement`, `Fact_LandedCostAllocation`, Cost Trend measures |

Market rates: Shafaq News / Iraqi News Baghdad Al-Kifah surveys; CBI bulletins. Amounts in IQD millions (M) unless stated.
P&L: eight complete months Jan–Aug 2026 (September partial, opex not posted). Balance sheet: 23 Sep 2026.
SAP local currency = IQD; system currency = USD.

---

## 1. Which exchange rate to depend on

**SAP and the online market rate are the same rate.** The accountant enters the Baghdad morning rate into `ORTT` each day.
On 15 sampled dates the difference never exceeded 1% (largest: 6 Sep, SAP 1,548 vs shops 1,563; 20 Sep, 1,590 vs 1,600).
Today both read 1,570 (shops sell 1,575).

| SAP monthly average 2026 | Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| USD/IQD | 1,478 | 1,513 | 1,551 | 1,541 | 1,533 | 1,551 | 1,523 | 1,533 | 1,563 |
| Low–high | 1,430–1,530 | 1,484–1,550 | 1,540–1,560 | 1,526–1,550 | 1,524–1,538 | 1,531–1,570 | 1,502–1,550 | 1,509–1,550 | 1,540–1,590 |

Decision: **use SAP's table as the company reference rate** (auditable, drives the dollar ledger) and publish it weekly beside the
Al-Kifah close so Sales and Finance quote the same number. Moving today's rate from 1,570 to 1,575 changes equity by $20k — the
choice between the two sources does not change any conclusion below. Two hygiene fixes: a blank (0) entry on 21 Dec 2025, and
the EUR rate, which was set to USD-type values (1,504.8 / 1,531.2) on several days.

**The real fork is official 1,320 versus market**, and it is decided by how each purchase is paid — see section 2.

---

## 2. Five different dollars inside SAP

| Where | Rate used | Amount | Meaning |
|---|---:|---|---|
| MID / Canon Middle East USD invoices and goods receipts (Jan, Mar; small items Apr–Aug) | **1,320** | $0.97M received | Official CBI ceiling. The Feb payment of **$472,769 to Canon ME was made at 1,320** — the January shipment genuinely went through the official channel (≈99M IQD saved vs market). No 1,320 payment was found for the March invoices ($437k–456k): Finance to confirm settlement. |
| ATIC FZCO (UAE) invoices, receipts, payments (Apr–Aug) | 1,512–1,554 | $1.71M invoiced, $1.63M paid | Market rate of the day. 57% of 2026 POs. |
| All dinar documents → dollar ledger | SAP daily | — | Revenue/opex/tax translate at 1,498–1,555 by month. |
| Opening balances 31 Dec 2025 (stock 5,736M, retained earnings, partner loan) | **1,430** | Stock $4.01M | SAP rate that day. |
| Company Capital | **1,500** | $7,700,839 → $6,161,442 | Original capital and the April reduction ($1,539,397) both at exactly 1,500. |
| Canon ME EUR invoices (€57k) | 1,505–1,531 | — | USD-type rates on euros; EUR/IQD was ~1,780–1,840. Cost understated ≈15% on these lines (~13M). |

Year-to-date, USD goods receipts total **$2.70M booked at an average 1,462**; at the market average (~1,532) they would have cost
190M IQD more. Goods booked at 1,320 or 1,430 enter the moving average cheaply, which is why dinar COGS is low and the 20.7%
gross margin looks healthy: average unit cost in the seven warehouses fell 6.5% Jan→Sep while the dollar rose 10%.

Two unbooked items: (1) `Partener Loan (L.G) Mr.Ali` is **USD 544,222** carried at 1,430 = 778M; at 1,570 it is 855M — a 77M
loss not yet booked. The 80.6M "Dollar exchange rate difference" provision may be covering this rather than inventory; confirm.
(2) The EUR invoice rates above.

---

## 3. Three views of the same eight months

| Month | Revenue | GP (dinar) | Net profit — dinar books | Net profit — SAP dollar ledger ($k) | FX provision | Replacement gap | Net at replacement cost |
|---|---:|---:|---:|---:|---:|---:|---:|
| Jan | 797.6 | 159.8 | −4.3 | −12.9 | — | −40.5 | −44.8 |
| Feb | 557.9 | 122.6 | −34.6 | −27.9 | — | −14.0 | −48.6 |
| Mar | 687.6 | 162.2 | 11.9 | 0.4 | — | −53.1 | −41.2 |
| Apr | 801.9 | 204.9 | 72.2 | 40.4 | 19.5 | −36.2 | 55.5 |
| May | 768.2 | 167.0 | 36.6 | 22.9 | 15.1 | −16.3 | 35.4 |
| Jun | 736.6 | 132.5 | −20.4 | −19.3 | 23.0 | −21.5 | −18.9 |
| Jul | 972.3 | 156.1 | 11.1 | 11.5 | 5.0 | −28.1 | −12.0 |
| Aug | 691.3 | 139.5 | −14.4 | −9.5 | 17.9 | −1.6 | 1.9 |
| **Jan–Aug** | **6,013.4** | **1,244.6 (20.7%)** | **58.0** | **+5.8** | **80.6** | **−211.4** | **−72.7** |

- **Dinar books:** 58.0M profit (0.97% of revenue).
- **SAP dollar ledger (system currency, transaction-date rates):** revenue $3.93M, COGS $3.11M, opex $0.68M, tax $0.15M,
  **net +$5.8k**. The dinar profit translates to ≈$38k; the difference is the exchange-difference account, ≈0 in dinar but
  **−$43k in dollars** — the realised cost of holding dinar receivables and cash while the dollar rose. SAP's own books already
  say the year is break-even in dollars.
- **Replacement cost:** the Inventory model's Cost Trend gives a 211M gap (+4.5% of COGS); re-costing each item at its latest USD
  price × 1,570 × 3.95% landed gives +6.1% on matched stock, ≈291M on Jan–Aug COGS. Real result **−73M to −152M IQD**. The
  80.6M provision (Apr–Aug only) covers a quarter to a third of it.

---

## 4. Capital and equity in dollars

| | USD |
|---|---:|
| Company Capital (SAP system currency, exact) | **$6.161M** (was $7.701M before the April reduction of $1.539M) |
| Equity 31 Dec 2025, adjusted (10,119M after removing 2,309M partners' drawings) @ SAP 1,430 | $7.076M |
| … same at first-import rate 1,480 | $6.837M |
| Equity 23 Sep 2026 (10,084M) @ 1,570 | **$6.423M** |
| Change from 31 Dec (SAP rate) | **−$653k (−9.2%)**: currency −$631k, operations −$22k (profit +94M, prior-period −129M) |
| Change from first import (1,480) | −$414k (−6.1%) |
| Equity in SAP's dollar ledger (historical rates) | $6.986M — includes a $278k opening-balance artifact and dinar assets frozen at 1,430; not a market value; $563k above the market figure |
| Tangible equity (ex 1,800M goodwill) @ 1,570 | $5.28M — $0.88M below the capital line |
| Rate at which total equity = capital | ≈1,637 (Sep peak 1,590–1,600) |

Pace since 31 Dec: ≈ −$72k a month of currency erosion against ≈ +$0.7k a month of dollar profit. The April capital reduction
was the netting of the partners' drawings account — a shareholder decision, not a loss; all comparisons above remove it from
December so they are like-for-like.

---

## 5. Inventory as an asset

| | |
|---|---|
| Stock incl. goods in transit, 31 Dec → 23 Sep | 6,571M → 4,891M (**−25.6%** in dinar) |
| Same in dollars at the SAP rate of each date | $4.60M → $3.12M (**−32%**) |
| Units in the 7 valuation warehouses | roughly flat (~100.9k → ~100.4k) |
| Average unit cost, Jan → Sep | **−6.5%** while USD rose 10% (1,320 / 1,430 intake) |
| Stock by rate on last 2026 USD receipt | 1,320: 129M · ~1,510: 580M · ~1,530–1,540: 1,419M · ~1,550: 394M · no 2026 USD receipt (opening @1,430, local): 2,183M |
| Replacement vs book on matched stock (54% of value) | **+6.1%** (B2B +6.6%, B2C +3.3%); the unmatched 46% is opening stock at 1,430 — under-costed by more |

The stock did not gain value. It was sold down and what remains is under-costed relative to what it will cost to replace.

| Business type | Stock at book | At replacement | Reseller **list** margin at book | Realised margin Jan–Sep |
|---|---:|---:|---:|---:|
| B2B | 2,201.9 | 2,346.4 | 34.3% | 18.2% (discounts absorb 16 pts) |
| B2C | 315.1 | 325.5 | **−1.5%** | 3.6% |
| Parts / unclassified | 16.0 | 16.8 | 50.3% | 49.0% |

Largest items (Reseller list vs replacement at 1,570 + landed): imageRUNNER C3326i (233M stock) margin 14.6% at book → 9.8% at
replacement; DR-C230 18.5% → 9.6%; C-EXV 64 Black 27% → 12.6%; **T01 toners 5% → ≈0.7%; T01 Black −1.2%; C-EXV 65 Black
listed below its own book cost (−16%)**. The price lists also contain placeholder values (2 / 2.5 IQD) on live items.

---

## 6. Exposure (book values, 23 Sep, corrected for the USD loan)

| Position | M IQD | USD @1,570 | If the dollar rises |
|---|---:|---:|---|
| Net long dinar (cash 975 + receivables 1,687 + other 277 − dinar liabilities 586) | **2,353** | **$1.50M** | loses dollar value 1-for-1 |
| Hard-currency assets (cash/bank 605, transit 174, supplier prepayments 629, USD receivables 261) | 1,668 | $1.06M | dinar gain, dollar-neutral |
| USD liabilities (partner loan $544k, AT Group $13k) — book / at 1,570 | −797 / −875 | $0.56M | dinar loss, partly offsets the above |
| Inventory at dinar cost | 4,718 | $3.00M | neutral only if prices follow the rate |
| Fixed assets + goodwill | 2,116 | $1.35M | illiquid |

Sensitivity from 1,570: +1% → −$15k on the dinar position, +47M to replace stock, +54M on a year of purchases; +5% → −$75k /
+236M / +270M; +10% → −$150k / +472M / +540M. Cycle: DIO 240 days, DSO 72 days, dinar cash 226 days of opex.

---

## 7. Decisions

### Scenario A — official-rate access can be repeated (1,320 on Canon ME direct invoices)
January proves it is possible. Every $1M routed through the bank at 1,320 instead of ATIC at ~1,550 saves ≈230M IQD — more than
a year of current profit for every $250k. **This is the largest lever available.**
- Ask the bank which Canon Middle East invoices qualify under platform rules and the 1 Oct advance-duty mechanism (Decision 413/2026).
- Route the maximum share directly from Canon ME rather than via ATIC.
- Book those goods at their true 1,320 cost but **price them off the market rate** — keep the saving in the margin.
- KPI: share of import dollars bought at 1,320 vs market, monthly. Target > 50%.

### Scenario B — everything bought at market (the ATIC reality Apr–Sep)
Cost base 1,530–1,570 and rising; margins at replacement ≈15% B2B, negative B2C; the dollar ledger will keep showing zero.
- USD master price list; company rate every Sunday = SAP rate + buffer (1% cash, 2.5–3% credit), reset mid-week on a ±1% move.
- Quote validity 5–7 days; dinar indexation clauses on contracts > 30 days ✱; service contracts with semi-annual resets ✱.
- B2C repriced weekly with a 10% floor or delisted.
- KPI: replacement-cost gross margin monthly; equity at market rate; net dinar position.

### Treasury — both scenarios
- Convert collections within 48–72 hours; hold dinar for 3–4 weeks of dinar outflows plus tax/customs due (975M today is 7+ months of opex).
- DSO 72 → ≤45 days (30-day terms, early-payment discount funded from the credit buffer, dollar-equivalent credit limits).
- DIO 240 → ~150 days (ATIC buffer stock in Jebel Ali, monthly shipments; liquidate the ~0.9bn no-sales stock). Removes ≈2.4bn from the exposed window.
- No new USD debt. Revalue the existing USD 544k partner loan (77M) and establish what the provision was meant to cover.
- Buy dollars on dips — SAP's table shows the windows (Jul 1,502–1,510).

### Measurement and books — both scenarios
- Use SAP's dollar ledger every month; add equity at today's rate, net dinar position, replacement-cost margin (Cost Trend %), DSO, DIO.
- Replace the ad-hoc provision with a formula booked every month including Q1: (stock + dinar receivables + dinar cash − dinar
  liabilities) × monthly change in the SAP rate, released as stock is sold, plus revaluation of the USD loan. Move it out of the
  "Tax" section. Jan–Aug ≈250–300M vs 80.6M booked.
- Rate-table hygiene: EUR rate, blank 21 Dec entry, re-cost the €57k euro invoices. Price-list hygiene: remove placeholders,
  derive every dinar price from the USD list.
- 2027 target: equity ≥ $6.2M at market rate **and** a positive dollar-ledger profit.

✱ contract/regulatory questions — confirm with counsel against CBI anti-dollarisation rules. Selling in dollars is not proposed.

### How soft-currency markets do it (Egypt, Turkey, Nigeria, Lebanon, Argentina)
Hard-currency master price list; published internal rate reviewed weekly with a trigger for large moves; quote validity 24 h–7 days;
indexation/escalation clauses in local-currency contracts; cash price vs credit price; conversion of collections within days;
deposits on large orders; buffer stock only for fast movers; borrowing in local currency; a hard-currency management P&L beside the
statutory one. Where a preferential official rate exists (Egypt and Nigeria before 2023; Iraq now), the winners maximise compliant
access to it and do not give the saving away in price.

---

## 8. Limits

- Development model refreshed a few hours after the production model used for the balance sheet (September classes 4–8 differ by ~8M; immaterial to Jan–Aug).
- Item matching covers 54% of stock value; unmatched stock is mostly opening stock at 1,430 (under-costed by more).
- Replacement = last USD unit price × 1,570 × 3.95% landed; customs may be higher on specific HS lines.
- Reseller list prices are before discounts; realised margins from `Fact_SalesDetail`.
- The March 1,320 invoices' settlement path, and the purpose of the 80.6M provision, need confirmation from Finance.
- CANON only; PAPERENTITY out of scope.
