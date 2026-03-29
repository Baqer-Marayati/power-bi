# Current Status

## Date
- Last updated: March 29, 2026

## Active Project
- Service Performance Report -- module activated with CANON company config.

## Current State
- **Phase 1 (SAP Data Discovery) COMPLETE.** Full results in `docs/PHASE1_DISCOVERY.md`.
- **Phase 2 (Semantic Model Design) COMPLETE.** PBIP project created at `Service Report/Service Report.pbip`.
- **Phase 3 (Report Pages) COMPLETE.** 5 pages built as PBIP JSON under `Service Report.Report/definition/pages/`.
- Stakeholder confirmed: profitability should be per customer per machine (FSMA revenue allocated proportionally to call volume).

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
| Dim_ProblemType | OSCP | ProblemTypeID |

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

### Measures (_Measures table)
- **Volume:** Total Service Calls, Open/Closed Calls, Avg Calls per Day, Calls This Month
- **Time:** Avg Response Time, Avg Resolution Time, Median Resolution Time, First-Time Fix Rate %
- **Employee:** Total Activities, Total Labor Hours, Avg Labor Hours per Call, Calls per Technician
- **Cost:** Total Parts Cost, FSMA Parts Cost, Avg Parts Cost per Call
- **Revenue:** Total Service Revenue, FSMA Revenue, MPS Revenue, Labour Revenue
- **Profitability:** FSMA Revenue Allocated, MPS Revenue Allocated, Total Revenue Allocated, Net Profit per Machine, Profit Margin %
- **Client:** Machines per Client, Calls per Client, Client Profitability
- **Dispatcher:** Tickets Created Today, Avg Tickets per Day

## Report Pages (Phase 3)

| Page | Display Name | Visuals |
|------|-------------|---------|
| svc_p01_overview | Service Overview | 4 KPI cards, calls-by-month column chart, by-status donut, by-machine-type bar, by-priority bar, avg resolution trend |
| svc_p02_techperf | Technician Performance | 4 KPI cards, activities/hrs by technician bar, by-team bar, first-time-fix bar, activities trend |
| svc_p03_profitab | Machine Profitability | 4 KPI cards, net profit/customer bar, allocated revenue bar, revenue-by-type donut, cost-by-model bar, trend |
| svc_p04_partsflt | Parts & Faults | 4 KPI cards, top-parts-by-cost bar, calls-by-fault-type bar, parts-cost trend, revenue-type donut, cost-by-customer bar |
| svc_p05_clients  | Client View | 4 KPI cards, top customers by calls/revenue/profitability/machines bars, calls trend |

Each page: 1280×960, Finance-matching color palette (#F8FBFF bg, #FFFFFF cards, #1F4E79 shadow), left 184px slicer sidebar.

## Immediate Next
- Open `Service Report.pbip` in Power BI Desktop — pages should now load with all visuals.
- Adjust any visual sizes or ordering interactively in Desktop.
- Add custom theme JSON if brand colors diverge from the base theme.
