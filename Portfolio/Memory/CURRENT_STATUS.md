# Portfolio Current Status

## Date

- Last updated: August 28, 2026

## Current Reality

- The repository uses a portfolio-style reporting structure instead of a single-report root layout.
- `Reports/Finance` remains the primary production report module and the default deep-work starting point for new agents.
- `Reports/Inventory` is an active Fabric iteration target: CANON Inventory Report management naming and landed-cost work ship via `Fabric/DevelopmentWorkspace/` (May 2026).
- `Reports/DataExchange` is the active isolated exchange workspace for extraction and transfer workflows.
- `Reports/Sales`, `Reports/Service`, and `Reports/Inventory` are active PBIP modules in the repo for both CANON and PAPERENTITY company copies.
- `Reports/HR` and `Reports/Marketing` remain scaffolded modules.
- The portfolio root is reserved for cross-report structure, documentation, shared assets, and report-module orchestration.
- The Mac repo root now lives at `/Users/baqer/Code/Power BI`.
- `History` and `Models` are no longer part of this Git repo; the repo root is now the active Power BI project root only.

## Consistency Audit (Aug 24, 2026)

- New repeatable audit: `Portfolio/scripts/audit-report-consistency.py` extracts layout/design tokens from PBIP report definitions and compares them against `Portfolio/Shared/Standards/fabric-reports-layout-standard.md`.
- Headline findings (Fabric/DevelopmentWorkspace): Canon Service is fully off-standard (1280×960 shell, no radius, Semibold 10pt titles, 167px rail, old logo sizes) and is not published to Canon Analytics; 84 off-canvas parked visuals across the other five reports; KPI gap rhythm varies 15–35.1 px across reports; semantic models use three table-naming generations (Finance legacy camelCase + suffix-Fact, Sales prefix-less, Service/Inventory clean `Dim_`/`Fact_`); measure vocabulary drifts per report (Margin % vs Gross Margin % vs Profit Margin %); only ~35–45% of measures define model-level format strings.
- `REPORT_CATALOG.md` Sales page list is stale vs the live 6-page Fabric report (Sales Map, Salesperson, Customers, Target & Salaries).
- **Resolved same day:** Canon Service Fabric copy migrated to the layout standard (layout-only, zero semantic changes; audit now clean — see `Reports/Service/Module/Project Memory/CURRENT_STATUS.md`). Standard scope is now six reports. Off-canvas cleanup done Aug 24 (94 inert parked visuals removed; 3 wired Paper Inventory reorder slicers kept).
- **Format strings closed (Aug 28):** the "only ~35–45% of measures have format strings" finding was overstated — `INFO.VIEW.MEASURES()[FormatString]` returns null via REST/MCP even for formatted measures; audit format coverage from TMDL, not live metadata. True gap was the two Financial models only: 67 numeric measures each got model-level formats (IQD triple / `#,0` counts / dynamic SWITCH for the mixed-type `Overview KPI Value`). All six models now format every numeric measure; remaining unformatted are text/SVG/date helpers by design. Remaining audit items: measure vocabulary, table-naming documentation.

## Number-Formatting Standard, Phases 1–2 (Aug 28, 2026)

- Fleet-wide KPI number formatting standardized across all six Fabric reports after a 170-card census
  (canvas: `power-bi-number-formatting-standard.canvas.tsx`). Core rule: **the model formats, the
  visual displays** — format strings live in the semantic model; card visuals never use Auto display
  units and never override precision. Big raw-money cards use *fixed* visual units chosen from live
  magnitudes (bn or M); pre-scaled `* Card Display` measures render via their model formats.
- Model side (formatString lines only, zero DAX changes): Financial M-suffix formats gained a
  thousands separator and dropped false decimals (`#,0"M د.ع.‏"` — fixes Canon's comma-less "1174M"),
  bn formats now `#,0.00"bn د.ع.‏"`; Financial counts `0` → `#,0` (Departments/Accounts/BS
  Accounts/AR Customer Count/DPO); Sales "Bn" → "bn"; Service money measures (12) gained the IQD
  suffix (previously bare numbers — only report without currency); Service percents 0.0% → 0.00%
  (fleet standard is 2dp); Service `#,##0` cosmetically normalized to `#,0`.
- Report side (165 card visual.json files; `objects.value` only): Auto display units eliminated,
  precision overrides removed, all card values normalized to 18px regular (Paper ROI was 21px — the
  "bold" look; Inventory legacy 21px-bold defaults cleared). Three deliberate rebinds, display-only:
  both Financial ROI "Net Revenue" cards now bind `Net Revenue Card Display` (bn, matching P&L), and
  Sales "Unmapped Sales" binds the raw measure at fixed Millions (was a bn display measure rendering
  128M as "0.13Bn").
- Verified: TMDL diffs are 100% formatString lines; all 165 visual diffs touch only `objects.value`
  except the three rebinds; filterConfig/queries byte-identical otherwise. Service TMDL is CRLF —
  edits must preserve line endings or Fabric sees a whole-file rewrite.
- Known data issue (not formatting): Canon Financial `ROI %` returns blank at all-years scope
  (Paper returns a value) — capital-base measure needs investigation.
- **Superseding money rule (same day, user decision):** all money **total** KPI cards fleet-wide
  render in **billions with 3 decimals** ("5.886bn د.ع.") via one uniform card mechanism — raw
  measure + fixed Billions display units + precision 3. 65 cards updated, 28 display-only rebinds
  from `* Card Display` helpers back to raw measures (helpers are now unbound by cards; retire in a
  later cleanup). Exemptions render exact IQD: per-unit/average cards (Avg Cost, Landed Cost/Unit,
  Avg Collection per Txn, Avg Sales per SP/BP, Avg Parts Cost per Call) and the four cash cards on
  both Financial reports (Paper genuinely holds ~66K in bank — bn would show 0.000). Zero model
  changes in this pass; tables/charts keep exact model formats. Percent cards stay 2dp.
- **Percent sweep completed (same day):** all 60 remaining sub-2dp percent formats normalized to
  two decimals model-wide — Financial `generalLedgerEntries` budget/variance measures (0.0%),
  Sales payout measures (0%), Inventory MoM/landed-cost measures (0.0%, signed `+0.0%;-0.0%` and
  glyph `▲ +0.0%` variants kept their signs/glyphs). Every percent measure in all six models is now
  `0.00%`-based. Deliberate exception: chart *axis tick* precision stays 0dp (e.g. Landed Cost value
  axes) — ticks are round gridline numbers, not values.
- **Phase 3 closed (same day):** (1) all 21 non-tooltip tables/matrices converged on the Financial
  typography pattern — grid 14 / rowPadding 2 / values 13 Segoe UI / headers 12 bold / bold totals;
  colors and alignment per-report, untouched; Inventory 380×210 tooltip table exempt. (2) 22 money
  charts normalized: fixed-M labels 1dp, fixed-bn labels 3dp (card-aligned), auto-unit all-money
  labels 1dp, fixed-M value axes 1dp; percent axis ticks stay 0dp. (3) Standard codified in
  `Portfolio/Shared/Standards/fabric-reports-number-formatting.md`; `audit-report-consistency.py`
  gained a NUMBER FORMATTING section (Auto-unit cards, percent-card 2dp, bn-card 3dp, table
  typography, chart label precision, non-0.00% model percents) — fleet audits 0 violations; the
  pre-standard `Reports/Service` module copy correctly flags 24, proving detection.
- Formatting standardization is **done**. Follow-ups closed same day (later pass):
  1. **`* Card Display` helpers retired** — 43 measures deleted (19 per Financial model, 5 Sales)
     plus 6 dangling Q&A linguistic entities in the Sales culture file, after proof of non-use.
  2. **Measure vocabulary aligned** — Sales `Margin %` → `Sales Margin %` (visible "Gross Margin %"
     labels in Sales followed; plain GL margins stay Financial-only), Service `Profit Margin %` →
     `Service Margin %`, Sales `... Gross Margin Percentage` ×2 → `... %`, Inventory
     `In-Stock Rate` → `In-Stock Rate %` (both). Rule codified in the number-formatting standard.
  3. **Canon `ROI %` fixed** — blank Year row in `Dim_Date` doubled `Average Company Capital` at
     all-years scope (18.48bn vs 9.24bn) and the `ISFILTERED` guard hid Canon's only data year;
     both measures now iterate non-blank years, guard is "exactly one year in scope" (Paper
     semantics). Single-year values verified unchanged live (0.78% for 2026).
- Remaining: publish Canon Service to production (user action in Fabric).

## Current Routing

- Use `REPORT_CATALOG.md` as the authoritative module-status map.
- Use `ACTIVE_FOCUS.md` as the fastest current-project routing file and canonical PBIP path map.
- Treat module `README.md`, `AGENTS.md`, and `Module/Project Memory/` as the next layer of truth after portfolio memory.

## Active Environments (Dual-Workstation Setup)

- Mac development workspace:
  - Cursor + GitHub + repo path: `/Users/baqer/Code/Power BI`
- Windows server execution workspace:
  - Cursor + GitHub + repo path: `C:\Work\reporting-hub` (Git Bash path: `/c/Work/reporting-hub`)
- GitHub `main` is the shared source of truth across both environments.

## Working Method In Use

- Primary model is dual-copy sync:
  1. Pull before work on whichever machine is active.
  2. Commit and push from that machine.
  3. Pull on the other machine before continuing.
- The server is now in a validated, clean sync state after rebase conflict resolution and push/pull reconciliation.
- Local server-only secret files are intentionally excluded from tracking:
  - `../Shared/SAP Export Pipeline/config.json`
  - `../Shared/SAP Export Pipeline/set_credentials.sh`

## Immediate Meaning

- Future department reports should be added under `Reports/`.
- Shared standards and reusable assets should be added under `Portfolio/Shared/`.
- Cross-report planning and architecture should be recorded in `Portfolio/Memory/`.
- Portfolio-level exported data snapshots for assistant analysis remain under `Portfolio/Shared/Data Drops/` (cross-report scope, not Finance-only).

## New Portfolio Onboarding Layer

- Added first-encounter onboarding doc for agents and new contributors:
  - `../docs/first-encounter.md`
- Added deterministic agent operating playbook:
  - `../docs/agent-operating-playbook.md`
- Added AI retrieval index for generic model uploads:
  - `../docs/ai-index.md`
- Added portfolio contribution guide:
  - `../CONTRIBUTING.md`
- Added GitHub CI guardrail for structure enforcement:
  - `.github/workflows/validate-structure.yml`
- Added GitHub CI guardrail for markdown link health:
  - `.github/workflows/validate-doc-links.yml`
- Updated root navigation docs to reflect current multi-domain reality and contract-first workflow:
  - `README.md`
  - `AGENTS.md`
  - `../docs/foundation.md`
  - `../docs/portfolio-architecture.md`
  - `../docs/structure.md`
