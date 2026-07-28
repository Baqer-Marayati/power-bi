# Next Steps

> Phases 1–3 (discovery, model, 5 pages) are built; see `CURRENT_STATUS.md`. The 2026-06-03 data review re-scoped the report toward **department efficiency monitoring** — full findings in `DATA_REVIEW_2026-06-03_TICKET_LIFECYCLE.md`.

## Headline from 2026-06-03 review
- **SAP service calls are logged retrospectively** (50% of tickets created after the work; "responded"="resolved" 92%; "closed" is month-end batch cleanup; "actual" duration = planned). So **response/resolution/SLA metrics are NOT trustworthy yet** — a process fix, not a data gap.
- **Trustworthy now:** call/visit volume, workload balance, callbacks/first-time-fix (same machine, 7-day rule), machine reliability, parts cost via **`StockValue` (COGS)**, data-quality/tagging.
- Profitability stays **customer-level** (FSMA/MPS revenue has no project/machine link); **production** fleet alone is project-trackable.

## Pending stakeholder decision (asked, not yet answered)
- Whether to (a) build now on trustworthy metrics + a data-discipline panel, gating speed/SLA on a process fix, or (b) fix ticketing process first. Default assumption if unspecified: option (a).

## Inputs to collect
- **Business:** SLA targets per priority (Low=1h given; High TBD); FSMA/MPS contract→machine Excel; **labour cost rate** (engineer/team → monthly cost or hourly). Labour rate is **confirmed a business input** — salaries are GL journal entries with no hours (see `SALARY_SAP_FINDINGS_2026-06-03.md`); the payroll pull is ruled out.
- **SAP pull:** customer `Territory` once populated (region dimension).
- **Master data / process:** confirm group 139 → Production (`OITB`); tighten ticketing discipline (log at call time, stamp true fix time, enforce GPS check-out).

## When building (after approval)
1. Switch all cost/margin visuals from `LineTotal` to `StockValue` (true COGS; captures FSMA zero-billed parts).
2. Add a **data-discipline panel** (% tickets logged after work, batch-close rate, check-out coverage, classification fill-rate).
3. Engineer leaderboard: head-to-head per stakeholder, but normalize Office vs Production (different work profiles).
4. Re-screenshot and update memory after Desktop save.
