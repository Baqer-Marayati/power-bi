# Page Map

## Purpose
This file is the page-by-page operating map for the Financial Report PBIP. Use it to understand what each page is for, what domain it depends on, and whether the current issue is mostly report wiring, semantic-model logic, or missing source data.

## Working Pages

### Executive Overview
- Purpose: top-level executive summary
- Primary domain: existing SAP-backed summary logic
- Status: working
- Notes: keep current shell and KPI rhythm; treat the KPI row as a shared component system

### Income Statement
- Purpose: core income statement view
- Primary domain: `Fact_PNL`
- Status: working
- Notes: preserve current SAP-backed logic and current KPI-row pattern

### Revenue Insights
- Purpose: revenue analysis
- Primary domain: `Fact_SalesDetail`
- Status: working
- Notes: serves as a good reference for stable sales-domain visuals

### Cost Structure
- Purpose: cost breakdown and structure
- Primary domain: `Fact_PNL`
- Status: working
- Notes: already aligned with the current shell

### Balance Sheet
- Purpose: balance sheet analysis
- Primary domain: `Fact_BalanceSheet`
- Status: working
- Notes: use as a stable reference for SAP-backed balance logic

## Pages In Active Repair

### Actual vs Budget
- Purpose: compare actuals with budget and variance
- Primary domain: `glBudgetEntries`, `BudgetVsActualTable`, `generalLedgerEntries`
- Status: active recovery page
- Main issue type: mixed report rewiring plus placeholder budget logic
- Notes: page can be stabilized, but true budget truth still depends on a real SAP budget source

### Cashflow
- Purpose: cash-in / cash-out and short-term projection page
- Primary domain: `bankAccountLedgerEntries`, cashflow helper dates
- Status: active recovery page
- Main issue type: compatibility-table limitations and helper-date wiring
- Notes: current cashflow logic is compatibility-based, not a true bank-ledger build

## Deferred Or Historical Pages
- `Financial Details`
- `Performance Details`
- `Profit and Loss`
- `Accounts Payable`
- `AP Invoice Details`
- `Accounts Receivable`
- `AR Invoice Details`
- `Commitment Report`

These pages remain part of project history and benchmark context, but they are not in the active operating queue unless the user explicitly reintroduces them.

## Operational Rules
- Do not delete the active-repair pages.
- Keep the Sample 2 structure unless the user requests otherwise.
- Prefer report-side rewires before risky model relationships.
- Keep all currency presentation in `IQD`.
- Do not quietly move deferred pages back into active repair.
