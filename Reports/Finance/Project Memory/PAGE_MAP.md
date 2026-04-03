# Page Map

## Purpose
This file is the page-by-page operating map for the Financial Report PBIP. Use it to understand what each page is for, what domain it depends on, and whether the current issue is mostly report wiring, semantic-model logic, or missing source data.

## Working pages (current 10-page shell)

### Executive Overview
- Purpose: top-level executive summary
- Primary domain: existing SAP-backed summary logic
- Status: working
- Notes: KPI row is a shared component system; branding lockup top-right

### Income Statement
- Purpose: core income statement view
- Primary domain: `Fact_PNL`
- Status: working

### Revenue Insights
- Purpose: revenue analysis
- Primary domain: `Fact_SalesDetail` (`Item Business Type` from SAP item master UDF)
- Status: working

### Cost Structure
- Purpose: cost breakdown and structure
- Primary domain: `Fact_PNL`
- Status: working

### Balance Sheet
- Purpose: balance sheet analysis
- Primary domain: `Fact_BalanceSheet`
- Status: working

### Working Capital Health
- Purpose: AR/AP execution health (outstanding, overdue, due buckets)
- Primary domain: `customerLedgerEntries`, `vendorLedgerEntries`, related dims
- Status: working (validate in Desktop after model changes)

### Profitability Drivers
- Purpose: profitability movement (YTD KPIs, monthly trends)
- Primary domain: `_Measures`, `Dim_Date`
- Status: working (validate in Desktop after model changes)

### Receivables
- Purpose: AR outstanding, aging, customer context
- Primary domain: `ReceivablesFact`, `DimBusinessPartner`
- Status: working

### Collections
- Purpose: collection activity and rates vs AR
- Primary domain: `CollectionsFact`, `DimBusinessPartner`, `Dim_Date`
- Status: working

### Cash Position
- Purpose: cash-on-hand / bank / POS snapshot and breakdown
- Primary domain: `CashPositionFact` (and related measures)
- Status: working

## Deferred benchmark / historical pages

These are **not** in the current `pages.json` order unless explicitly reintroduced:

- `Actual vs Budget` — budget truth still depends on a real SAP budget source when revived
- `Cashflow` — prior compatibility-based cashflow page; not the same story as **Cash Position**
- `Financial Details`, `Performance Details`, `Profit and Loss`, `Accounts Payable`, `AP Invoice Details`, `Accounts Receivable`, `AR Invoice Details`, `Commitment Report`

## Operational rules
- Prefer **`CURRENT_STATUS.md`** and **`DECISIONS.md`** for live layout and palette numbers.
- Prefer report-side rewires before risky model relationships on stable pages.
- Keep currency presentation in **IQD** unless a documented exception exists.
- Do not quietly move deferred pages back into the active shell without an explicit decision.
