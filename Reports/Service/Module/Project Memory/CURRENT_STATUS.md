# Current Status

## Date
- Last updated: August 24, 2026

## Fabric copy migrated to the unified layout standard (2026-08-24)
- `Fabric/DevelopmentWorkspace/Canon Service Report.Report` was migrated **layout-only** to
  `Portfolio/Shared/Standards/fabric-reports-layout-standard.md` (it was the last off-standard report):
  canvas 1280×960 FitToWidth → **1920×1080 FitToPage**; KPI cards to the shared row
  (y=136.7, h=104, w=323.3, gaps 20.6); slicers into the standard rail (x=67, w=400, h=76) with the
  sibling dropdown+header styling; new full-height `panel_filter_rail` shape per page; brand lockup
  rescaled to the canonical group geometry (164.7×63 logos, group at 1514,46.7); containers unified
  (radius 14, border #C9D5E3, title Segoe UI 12 #2E3A42, KPI value 18, shadow #1F4E79 270°/4);
  charts remapped into the 513–1868 content zone, bottom line 1030; document schemas bumped to
  visualContainer 2.9.0 / page 2.1.0 to match Canon Inventory.
- The 9 standalone slicer label textboxes (`svc_p*_lbl_*`) were **deleted**; their text moved into the
  slicers' built-in headers (sibling pattern). "Machine Type" header kept — those slicers bind
  `Dim_Item.MachineClass`, so the label is correct for this copy.
- **Zero semantic changes**: all query/filterConfig/visualType blocks verified byte-identical pre/post.
- **Divergence resolved (same day):** after the user approved the migrated layout in Fabric, the module
  PBIP (`Reports/Service/Companies/CANON/...`) was found to be a stale mid-May snapshot — the Fabric
  copy (created 2026-06-03) had newer report queries (e.g. real Client View revenue/profit bars replacing
  the parked dupes, 2-slicer rail instead of year/quarter/month stacks) and a newer semantic model.
  The module `.Report` definition, `StaticResources`, and `.SemanticModel` definition were synced
  wholesale from the approved Fabric copy. `Fabric/DevelopmentWorkspace/` remains the iteration surface;
  treat the module copy as a mirror of the last approved Fabric state.
- Superseded by the sync: the April 18 module-side notes below describe the pre-June copy; the live
  report/model state is the Fabric copy.

## Active Project
- Service Performance Report — module activated with CANON company config.
- Live PBIP: `Reports/Service/Companies/CANON/Canon Service Report/Canon Service Report.pbip`.

## Current State
- **Phase 1 (SAP Data Discovery) COMPLETE.** Full results in `docs/PHASE1_DISCOVERY.md`.
- **Phase 2 (Semantic Model Design) COMPLETE.**
- **Phase 3 (Report Pages) COMPLETE.** 5 pages built as PBIR JSON under `Canon Service Report.Report/definition/pages/`.
- **Phase 4 (Validation / discrepancy fix-up) IN PROGRESS** — see "Recent fixes" below. Stakeholder confirmed: profitability is per customer per machine (FSMA revenue allocated proportionally to call volume).

## Recent fixes (2026-04-18)
- **Page 4 duplicate visual fixed:** `svc_p4_donut_rev` was a clone of `svc_p4_bar_parts` ("Top Parts by Cost"); converted to a real `donutChart` titled "Revenue by Type" against `Fact_ServiceRevenue.RevenueType` × `[Total Service Revenue]`.
- **Customer-list "all bars equal length" fixed** (Pages 3 / 4 / 5): added a visual-level `filterConfig` of `[_Measures.Total Service Calls] > 0` to `svc_p3_bar_profit`, `svc_p3_bar_revcost`, `svc_p4_bar_custcost`, and the `svc_p5_bar_calls` pivot. Category column kept as `Dim_Customer.CustomerName` per the 2026-04-18 DECISIONS entry.
- **`(Blank)` fault-type bar fixed:** `Dim_ProblemType` Power Query now `UNION ALL`-s a synthetic `(0, 'Unclassified')` row from `DUMMY` so calls with NULL `prblmTyp` (which the fact coalesces to `0`) join cleanly.
- **`FSMA Parts Cost` card no longer shows `--`:** measure now ends with `... ) + 0` so it returns `0` instead of BLANK when no parts have `TaxCode IN { "FSMA", "SMA" }`.
- **Page 5 cleanup:** deleted off-canvas duplicates `svc_p5_bar_profit` and `svc_p5_bar_rev` (both were parked at `x=-2000, y=-2000, h=0, w=0`); their measures already live in `svc_p5_bar_calls` (Client Summary pivot).
- **Slicer label "Customer Type"** now consistent across pages 1, 3, 4 (`Dim_Customer.CustomerType` from `OCRD.U_SolutionType`). The old "Machine Type" label in screenshots `Portfolio/Shared/ChatContext/images/1.png` and `2.png` is stale — re-screenshot after next Desktop save.

## Semantic Model Structure

### Dimensions (7 tables)
| Table | Source | Key Column |
|-------|--------|-----------|
| Dim_Date | DAX CALENDAR | Date |
| Dim_Employee | OHEM (14 service staff) | EmployeeKey |
| Dim_Customer | OCRD (customers only) | CustomerCode |
| Dim_Item | OITM + OITB with MachineClass | ItemCode |
| Dim_Equipment | OINS + OITB with MachineClass | EquipmentKey |
| Dim_Project | OPRJ | ProjectCode |
| Dim_ProblemType | OSCP + synthetic (0,'Unclassified') | ProblemTypeID |

### Facts (4 tables)
| Table | Source | Grain | Key Columns |
|-------|--------|-------|------------|
| Fact_ServiceCalls | OSCL + OSCT + OSCO | Per call | CallID, CreateDate, ResponseHours, ResolutionHours |
| Fact_ServiceActivities | SCL6 + OSCL | Per technician visit | CallID, TechnicianKey, DurationHours |
| Fact_ServiceParts | SCL4 → ODLN → DLN1 | Per delivery line per call | CallID, ItemCode, LineTotal, ProjectCode |
| Fact_ServiceRevenue | OINV → INV1 (service items) | Per invoice line | CustomerCode, ItemCode, LineTotal, RevenueType |

### Key Design Decisions
- **No fact-to-fact relationships.** Activities and Parts denormalize CustomerCode/EquipmentKey from OSCL for independent dimension joins.
- **FSMA revenue allocation** via DAX: customer's SV002 revenue × (machine call count / customer total calls).
- **Machine classification** via CASE on OITB group names: IPS→Production, DS Copier→Office, B2C→Consumer, #N/A (group 139)→Production.
- **Technician teams** hardcoded by empID in Dim_Employee SQL: 66-71=Production, 72-78=Office, 80=Call Center.
- **Resolution/Response hours** calculated in SQL using SECONDS_BETWEEN on HANA date+time fields.
- **Customer-list visuals** filter via `[Total Service Calls] > 0` measure filter (visual-level), not by switching the category off `Dim_Customer.CustomerName` — see 2026-04-18 DECISIONS.

### Measures (_Measures table)
- **Volume:** Total Service Calls, Open/Closed Calls, Avg Calls per Day, Calls This Month
- **Time:** Avg Response Time, Avg Resolution Time, Median Resolution Time, First-Time Fix Rate %
- **Employee:** Total Activities, Total Labor Hours, Avg Labor Hours per Call, Calls per Technician
- **Cost:** Total Parts Cost, FSMA Parts Cost (returns 0, not BLANK), Avg Parts Cost per Call
- **Revenue:** Total Service Revenue, FSMA Revenue, MPS Revenue, Labour Revenue
- **Profitability:** FSMA Revenue Allocated, MPS Revenue Allocated, Total Revenue Allocated, Net Profit per Machine, Profit Margin %
- **Client:** Machines per Client, Calls per Client, Client Profitability
- **Data quality:** Production Machines (Tagged), Untagged Production Machines, Untagged Production Calls, Project Tag Coverage %

## Report Pages (Phase 3)

| Page | Display Name | Visuals |
|------|-------------|---------|
| svc_p01_overview | Service Overview | 4 KPI cards, calls-by-month column chart, by-status donut, by-customer-type bar, by-priority bar, avg resolution trend |
| svc_p02_techperf | Technician Performance | 4 KPI cards, activities/hrs by technician bar, by-team bar, first-time-fix bar, activities trend |
| svc_p03_profitab | Machine Profitability | 4 KPI cards, net profit/customer bar, allocated revenue bar, revenue-by-type donut, cost-by-model bar, trend |
| svc_p04_partsflt | Parts & Faults | 4 KPI cards, top-parts-by-cost bar, calls-by-fault-type bar, parts-cost trend, **revenue-by-type donut (fixed)**, cost-by-customer bar |
| svc_p05_clients  | Client View | 4 KPI cards, Client Summary pivot, machines-per-customer bar, calls trend |

Each page: 1280×960, Finance-matching color palette (#F8FBFF bg, #FFFFFF cards, #1F4E79 shadow), left 184px slicer sidebar.

## Known open items
- **Slicer rail still inconsistent across pages.** Page 2 has Team slicer instead of Customer Type; Page 5 has Customer slicer instead of Customer Type. Decide if these should be unified or are intentional per-page contexts.
- **`Dim_Equipment.MachineClass` vs `ItemGroupClass` divergence.** `MachineClass` only marks IPS-group machines as Production when they have `U_Project` set. `Untagged Production Machines` / `Untagged Production Calls` measures expose the gap; the 8th item in the 2026-04-18 discrepancy review is to align the two CASE expressions or document the gap on the slicer label.
- **`Dim_Item.MachineClass` has a `Service` bucket (groups 172..177) that `Dim_Equipment.MachineClass` lacks** — same concept, two source-of-truth columns.
- **`Net Profit per Machine`** subtracts unallocated `[Total Parts Cost]` from per-machine-allocated revenue. Customer-row totals reconcile, but a future per-equipment drill won't match SAP. Allocation of cost per equipment is the long-term fix.
- **Inactive bothDirections relationship** `Dim_Equipment.ProjectCode → Dim_Project.ProjectCode` (`aa000005-0001-4000-c005-000000000002`) is dormant; if ever activated via `USERELATIONSHIP`, it will create an ambiguous date path. Either delete or annotate.

## Immediate Next
- Open `Canon Service Report.pbip` in Power BI Desktop, refresh, and re-screenshot Pages 3/4/5 to confirm:
  1. Page 4 right-mid cell shows the new "Revenue by Type" donut.
  2. Page 4 "Calls by Fault Type" no longer has a `(Blank)` bar.
  3. Page 4 "FSMA Parts Cost" card shows a numeric value (or `0 د.ع.`).
  4. Pages 3 / 4 / 5 customer-list bars now vary in length (not all the same).
  5. Page 5 has no off-canvas duplicates.
- Save the new screenshots into `Portfolio/Shared/ChatContext/images/` and update `LESSONS.md` if anything new surfaces.
