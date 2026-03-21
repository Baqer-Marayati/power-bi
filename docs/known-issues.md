# Known Issues

## Purpose

This file is a quick repository-facing summary of important current risks, provisional areas, and checks to keep in mind.

For exact live truth, defer to `Project Memory/CURRENT_STATUS.md`.

## Current Watch Areas

### `Actual vs Budget`
- keep the page working, but treat current budget logic as compatibility-led unless native SAP-backed truth is confirmed
- watch for stale filters and placeholder benchmark bindings before blaming measures

### `Cashflow`
- current page is serviceable, but some logic is still lighter-weight than a full native cash movement build
- treat helper-date logic and slicer behavior as areas to recheck after related edits

### Semantic Model Stability
- compatibility layers should not silently become permanent source-of-truth substitutes
- helper tables that depend on other weak compatibility tables are a recurring risk pattern

### Currency And Layout Coupling
- IQD formatting can change visual fit
- any currency-formatting edit should trigger a layout recheck on KPI cards and dense visuals

## Operational Risks

- broad TMDL changes can destabilize the PBIP if done without immediate verification
- benchmark-shell visuals may carry hidden filters or stale bindings
- duplicated business stories across pages can weaken page clarity

## How To Use This File

- use it as a quick scan before starting work
- promote durable discoveries into `Project Memory`
- remove or rewrite entries when the risk is no longer current
