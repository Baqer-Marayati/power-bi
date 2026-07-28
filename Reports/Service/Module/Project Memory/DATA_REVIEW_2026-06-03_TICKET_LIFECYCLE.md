# Data Review — 2026-06-03: SAP gaps export + ticket-lifecycle study

> Source data: `~/Desktop/CANON_SAP_Export_2026-06-03/` (full 30-table export, 1,079 calls, 2026-01-04→2026-06-03) and the targeted follow-up `~/Desktop/CANON_Service_Gaps_20260603_130924/` (gap investigation + extractions). **No report or model changes were made** during this review.

This document records what the data actually supports for a **Service Department efficiency** report, the stakeholder's answers, and the key finding that **SAP service calls are logged retrospectively** so most time/SLA metrics are not trustworthy yet.

---

## 1. Gap-export verdict (validated against raw CSVs)

The three blockers from the gap export were independently re-checked and confirmed:

| Finding | Evidence | Verdict |
|---|---|---|
| FSMA (`SV002`) & MPS revenue cannot be tied to project/machine/agreement | `i2`: SV002 0/230 project, MPS 0/89; `AgrNo`=0 all | Revenue is **customer-level only** |
| No blanket-agreement module | `i3`: `OAGR`/`AGR1` absent in schema | Agreement route void |
| `PR-000` "Others" not back-fillable | `s2`: **13,251/13,346 machines (99.3%) are PR-000**; only ~95 real projects | Not a tagging gap |
| No SLA targets in SAP | `i4`: `respByDate` 0/1,079; `OCTR` empty | Must be defined by business |
| No labour cost in SAP master | `i5`: `OHEM.salary`=0 for all 14; service items cost 0 | See §2 (payroll) |
| Line cost/profit UDFs (`U_T_COST`,`U_T_PROFT`) | 0% populated | Dead — ignore |

### Positive discovery — true parts cost IS available
- `DLN1.StockValue` (true inventory COGS) is populated on **100%** of part lines; total **≈3.33bn IQD** COGS vs 4.50bn billed (`LineTotal`).
- **335 delivery lines ship at `LineTotal`=0 but carry real COGS (≈55.4M IQD)** — these are FSMA "free" parts. Costing must use **`StockValue`**, not `LineTotal`, or FSMA cost is undercounted.
- Call→document bridge `SCL4` reaches **304 calls (28%)** (not ~4%). `OINV/ODLN.U_ServiceCallID` exist but are 0% populated, so SCL4 is the only working bridge.

---

## 2. Stakeholder answers (interview, 2026-06-03)

| Topic | Answer |
|---|---|
| Report purpose | "Many things" — comprehensive department monitoring & efficiency |
| Audience | **Manager (weekly/monthly review)** + **dispatcher/team-leads (daily ops)** |
| SLA targets | **None defined yet.** Wants ~**1h response** for normal (Low) calls; High-priority target **TBD** |
| Labour cost | **In SAP HR/payroll** (monthly salary) → derive hourly cost. NB: `OHEM.salary` empty in export, so payroll lives in the HR add-on/another table → **needs a targeted pull** |
| FSMA/MPS contract→machine map | **In a separate Excel**, not SAP → stakeholder to provide |
| Page counts (per-page billing) | Engineers enter meter readings on the **service call** (`U_A_*` fields), ~28% coverage |
| Projects | **Created only for production installs**; office/consumer stay `PR-000`. So the ~95 real projects = the **production fleet** (project = client+model). Production margin is project-trackable; office/consumer is customer-level |
| Region | Manage **by region/territory**, BUT SAP `Territory` is only **41/2,698 (1.5%)** filled and `City` is messy free-text → stakeholder chose to **clean up Territory in SAP**, then pull |
| Engineer view | **Head-to-head leaderboard** across everyone (note: Office vs Production do very different work — normalize when comparing) |
| Ticket timing | Stakeholder unsure how ticketing behaves → triggered the lifecycle study (§3) |

---

## 3. KEY FINDING — SAP service calls are a retrospective logbook, not live ticketing

Analysis of every `OSCL` timestamp vs the `SCL6` activity records (scripts run 2026-06-03):

1. **50% of tickets are created AFTER the work happened.** First activity precedes ticket creation on **544/1,079 calls**, by a median of **~48h** (avg 108h, max 1,223h). `create` = data-entry time, not call time.
2. **"Responded" = "Resolved".** `respOnDate`==`resolOnDat` on **92%** of calls — one combined stamp, not two stages.
3. **"Assigned" is instant** (median 0 min after create) — captures no dispatch delay.
4. **"Closed" is month-end batch cleanup** — e.g. 59 closed on May 31, 57 on Apr 20, 44 on Jun 1; groups closed at the same minute, often months after creation. Useless for timing.
5. **"Actual" duration is fake** — `ActualDur` == planned `Duration` on **96%** of visits.
6. **Only partial honest signal:** GPS check-in on 653 visits, but check-**out** on only **303/1,243 (24%)**.

### Reliable-vs-not metric inventory

| Metric | Trustworthy now? | Reason |
|---|---|---|
| Response time / SLA / fix time | **No** | retrospective logging; respOn=resolOn; batch close |
| Engineer "actual hours" / utilization | **No** | ActualDur = planned estimate |
| Call/visit **volume** & **workload balance** | **Yes** | counts are solid |
| **Visits-per-call → callbacks / first-time-fix** (same machine, 7-day rule) | **Yes** | activity + machine links reliable |
| **Machine/model reliability** (repeat breakers; ~24% repeat) | **Yes** | machine link 98% |
| **Parts consumption & true cost (COGS via StockValue)** | **Yes** | 100% populated |
| **Tagging/data quality** (callType/problemType/origin ~50% blank; Jan 16%→later ~68%) | **Yes** | directly measurable |

**Implication:** the productivity / workload / reliability / cost half of "efficiency" is fully buildable now. The speed/SLA half is blocked by a **process behavior** (retrospective logging, batch closing), not by missing data. A report can even **expose** that behavior as a data-discipline KPI to drive the fix.

---

## 4. Proposed direction (NOT yet approved by stakeholder)

Build the efficiency report in two layers:
- **Layer 1 — trustworthy now:** department scorecard (volume, backlog by count), workload balance per engineer, callbacks/first-time-fix (7-day rule), machine reliability, parts cost (StockValue), and a **data-discipline panel** (% tickets logged after work, batch-close rate, check-out coverage, classification fill-rate).
- **Layer 2 — gated on a process fix:** response/resolution/SLA, once tickets are logged live and closed at true completion (or GPS check-out is enforced).

Costing switch for any cost/margin visual: use **`StockValue` (COGS)**, not `LineTotal`.

Production profitability can use the **project** spine (client+model); office/consumer stays **customer-level** with allocation, clearly labelled as an estimate.

---

## 5. What is still needed (and from where)

**Business inputs (SAP will not provide):**
- SLA response/resolution targets per priority (Low=1h; High TBD).
- FSMA/MPS contract→machine mapping (the Excel).
- **Labour cost rate** — engineer (or team) → monthly cost / hourly rate. **Confirmed** a business input: salaries are hand-keyed GL journal entries (Basic Salary `620101010101`), name only as free-text memo, **no hours** — see `SALARY_SAP_FINDINGS_2026-06-03.md`. The earlier "payroll pull" idea is **ruled out**.

**Targeted SAP pull still worthwhile:**
- **Customer `Territory`** once the stakeholder populates it (region dimension).

**Master-data / process fixes (operational, not a pull):**
- Re-tag production equipment from `PR-000` if office machines should ever be project-tracked (stakeholder says by-design, so likely leave).
- Fix `OITB` group **139 ("#N/A") → Production** name (19 items carry machines: varioPRINT, imagePRESS V1350/V1000/C165, etc.).
- **Ticketing discipline:** log the ticket at call time; stamp the real fix time; always GPS check-out. This is the unlock for all speed/SLA metrics.
