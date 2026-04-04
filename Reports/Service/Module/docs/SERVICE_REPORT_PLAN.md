# Service Performance Report — Full Build Plan

> **Purpose of this document:** This is a self-contained handoff plan. Give it to an agent that has access to the SAP HANA semantic model (CANON schema) and the PBIP workspace. The agent should follow Phases 1–4 in order.

---

## Business Context

The Service department has **two teams**:

| Team | Scope | Machine Type |
|------|-------|-------------|
| **Office Service** | Maintains office-class machines at client sites | Printers, copiers, MFPs — smaller units, high quantity |
| **Production Service** | Maintains production-class machines at client sites | High-volume / industrial print & finishing equipment — large units, fewer but high-value |

Production machines are sold as **projects** in SAP (each client/site = a project). Many machines are covered under **FSMA (Full Service Maintenance Agreement)** contracts — fixed-fee service agreements where profitability depends on actual service cost vs. contract revenue.

### What the stakeholder wants to see

- **Employee efficiency**: per technician, per team (office vs production) — who is performing, who is lagging.
- **Machine profitability**: per individual machine, per client — is each machine making or losing money? Especially for FSMA-covered units.
- **Cost vs revenue per machine**: how much was spent (parts, labor, travel) vs how much was earned (contract revenue, billable service).
- **Parts consumption**: which parts are consumed most, which machines eat the most parts, cost trends.
- **Fault analysis**: most common fault types, repeat faults, fault frequency per machine model.
- **Ticket operations**: call volume, response time, resolution time, aging, backlog, SLA compliance.
- **360-degree service view**: everything above unified so a manager can drill from department → team → technician → client → machine → individual ticket.

---

## Phase 1 — SAP Data Discovery

**Goal:** Identify every relevant SAP B1 table and field in the CANON schema that feeds the report. Do not build anything yet — just map the data landscape.

### Tables to investigate

The following SAP B1 tables (and their likely HANA view equivalents) are the primary candidates. Query each one, check row counts, inspect key columns, and note any that are empty or unused.

#### Service Calls (the ticket system)

| SAP Table | Description | Key fields to check |
|-----------|-------------|-------------------|
| `OSCL` | Service Calls — header | `callID`, `customer`, `itemCode`, `manufSN`, `internalSN`, `technession` (assigned technician), `status`, `priority`, `callType`, `origin`, `problemType`, `createDate`, `createTime`, `closeDate`, `closeTime`, `resolution`, `subject`, `contractID`, `insID` (equipment card) |
| `SCL1` | Service Call Activities | `callID`, `actType`, `actDate`, `startTime`, `endTime`, `assignee`, `duration` |
| `SCL2` | Service Call Solutions | `callID`, `solution`, `solverID` |
| `SCL4` | Service Call Expenses | `callID`, `expenseType`, `amount`, `currency` |
| `SCL5` | Service Call Inventory (parts used) | `callID`, `itemCode`, `quantity`, `price`, `lineTotal` |
| `SCL6` | Service Call BOM / linked documents | Links to delivery, invoice, etc. |

#### Service Contracts (FSMA and others)

| SAP Table | Description | Key fields to check |
|-----------|-------------|-------------------|
| `OCTR` | Service Contracts — header | `contractID`, `custCode`, `startDate`, `endDate`, `contractType`, `totalAmount`, `status`, `renewalType` |
| `CTR1` | Service Contract Lines | `contractID`, `itemCode`, `manufSN`, `internalSN`, `insID`, `lineTotal`, `coverageType` |

#### Equipment / Installed Base

| SAP Table | Description | Key fields to check |
|-----------|-------------|-------------------|
| `OINS` | Customer Equipment Cards | `insID`, `itemCode`, `manufSN`, `internalSN`, `customer`, `custmrName`, `statusOfSr`, `deliverDate`, `installDate`, `location`, `street`, `project` |

#### Items (machines + parts)

| SAP Table | Description | Key fields to check |
|-----------|-------------|-------------------|
| `OITM` | Item Master | `ItemCode`, `ItemName`, `ItmsGrpCod` (item group), `ItemType`, `FirmCode` (manufacturer) |
| `OITB` | Item Groups | `ItmsGrpCod`, `ItmsGrpNam` — **this is critical for classifying machines as Office vs Production and identifying parts vs machines** |

#### Employees / Technicians

| SAP Table | Description | Key fields to check |
|-----------|-------------|-------------------|
| `OHEM` | Employees | `empID`, `firstName`, `lastName`, `dept`, `position`, `branch`, `status` |

#### Business Partners (Clients)

| SAP Table | Description | Key fields to check |
|-----------|-------------|-------------------|
| `OCRD` | Business Partners | `CardCode`, `CardName`, `GroupCode`, `Territory`, `City` |

#### Projects

| SAP Table | Description | Key fields to check |
|-----------|-------------|-------------------|
| `OPRJ` | Projects | `PrjCode`, `PrjName`, `ValidFrom`, `ValidTo`, `Status` |

#### Financial documents linked to service

| SAP Table | Description | Why |
|-----------|-------------|-----|
| `OINV` / `INV1` | A/R Invoices | Service-related billing — tie back via service call or contract |
| `OPCH` / `PCH1` | A/P Invoices | Parts purchasing cost |
| `ODLN` / `DLN1` | Deliveries | Parts delivered to service calls |

### Discovery tasks

For each table above:

1. **Check existence** — `SELECT COUNT(*) FROM CANON.<table>` — skip if zero rows.
2. **Sample rows** — `SELECT TOP 20 * FROM CANON.<table>` — understand the actual data shape.
3. **Check field population** — are key columns actually populated or always null?
4. **Identify classification fields** — which item groups map to "Office machines" vs "Production machines" vs "Parts"? This is essential. Check `OITB` and how `OITM.ItmsGrpCod` is used.
5. **Check contract usage** — are FSMA contracts stored in `OCTR`? What `contractType` values exist?
6. **Check technician assignment** — how are technicians linked to calls? Is it `OSCL.technician` or through activities in `SCL1`?
7. **Check project linkage** — do production machine equipment cards (`OINS`) reference projects (`OPRJ`)? How?
8. **Check call types** — what values exist in `OSCL.callType`, `OSCL.problemType`, `OSCL.origin`? These become slicer/filter dimensions.

### Discovery deliverable

Produce a table like this:

```
| Table | Rows | Usable? | Key finding | Notes |
|-------|------|---------|-------------|-------|
| OSCL  | 12340 | Yes    | Main ticket table, technician in col X | ... |
| SCL5  | 8700  | Yes    | Parts consumption per call | ... |
| OCTR  | 45    | Yes    | FSMA contracts found in type "F" | ... |
| ...   | ...   | ...    | ... | ... |
```

Also produce a **classification map**: which item groups = Office machines, which = Production machines, which = spare parts. This will be confirmed with the stakeholder later.

---

## Phase 2 — Semantic Model Design

**Goal:** Design the star-schema semantic model in TMDL for the PBIP project, based on what Phase 1 discovered.

### Proposed fact tables

| Fact table | Source | Grain | Purpose |
|------------|--------|-------|---------|
| `ServiceCalls` | `OSCL` + key columns from related tables | One row per service call | Core ticket fact — volumes, times, status |
| `ServiceCallParts` | `SCL5` | One row per part line per call | Parts consumption and cost |
| `ServiceCallActivities` | `SCL1` | One row per activity per call | Technician time, labor hours |
| `ServiceCallExpenses` | `SCL4` | One row per expense line per call | Travel, misc costs |
| `ContractRevenue` | `OCTR` + `CTR1` | One row per contract line | FSMA and other contract revenue |

### Proposed dimension tables

| Dimension | Source | Purpose |
|-----------|--------|---------|
| `DimDate` | Generated or shared portfolio date table | Standard date dimension with fiscal periods |
| `DimEmployee` | `OHEM` | Technicians — name, department, team (Office/Production) |
| `DimCustomer` | `OCRD` | Clients — name, location, territory |
| `DimEquipment` | `OINS` | Installed machines — serial, model, install date, location, project link |
| `DimItem` | `OITM` + `OITB` | Items — machines and parts, with group classification |
| `DimProject` | `OPRJ` | Projects — for production machine client linkage |
| `DimServiceCallType` | Derived from `OSCL` distinct values | Call type, problem type, origin, priority |

### Key relationships

```
ServiceCalls → DimDate (on create date)
ServiceCalls → DimEmployee (on assigned technician)
ServiceCalls → DimCustomer (on customer code)
ServiceCalls → DimEquipment (on equipment card ID)
ServiceCalls → DimItem (on item code — the machine being serviced)
ServiceCallParts → DimItem (on part item code)
ServiceCallParts → ServiceCalls (on call ID)
ServiceCallActivities → ServiceCalls (on call ID)
ServiceCallActivities → DimEmployee (on assignee)
ContractRevenue → DimCustomer (on customer code)
ContractRevenue → DimEquipment (on equipment card / serial)
DimEquipment → DimProject (on project code)
DimEquipment → DimItem (on machine item code)
```

### Key measures to define

#### Volume & Operations
- `Total Service Calls`
- `Open Calls`
- `Closed Calls`
- `Calls This Month / Quarter / Year`
- `Avg Calls per Day`

#### Response & Resolution Time
- `Avg Response Time (hrs)` — create → first activity
- `Avg Resolution Time (hrs)` — create → close
- `Median Resolution Time`
- `SLA Compliance %` (if SLA targets are defined)
- `First-Time Fix Rate %` — calls closed with single visit

#### Employee Efficiency
- `Calls per Technician`
- `Avg Resolution Time per Technician`
- `Labor Hours per Technician`
- `Parts Cost per Technician`
- `Revenue per Technician` (if billable)
- `First-Time Fix Rate per Technician`
- `Utilization Rate` — labor hours / available hours

#### Machine Profitability (the FSMA view)
- `Total Cost per Machine` = parts cost + labor cost + expense cost
- `Total Revenue per Machine` = contract revenue (FSMA) + billable service revenue
- `Net Profit per Machine` = revenue − cost
- `Profit Margin % per Machine`
- `Cost per Call per Machine`
- `Avg Calls per Machine`
- `Machine ROI` (over contract period)

#### Parts & Faults
- `Total Parts Consumed`
- `Parts Cost Total`
- `Top N Parts by Consumption`
- `Top N Parts by Cost`
- `Most Common Fault Types`
- `Repeat Fault Rate` — same machine, same fault type within X days
- `Parts per Call (avg)`

#### Client View
- `Machines per Client`
- `Calls per Client`
- `Cost per Client`
- `Revenue per Client`
- `Client Profitability`

---

## Phase 3 — Report Pages

**Goal:** Build the PBIP report with these pages. Apply the portfolio visual identity theme.

### Page 1: Service Overview

**Purpose:** Executive summary — one screen, key numbers, trends.

| Visual | Content |
|--------|---------|
| KPI cards row | Total Calls · Open Calls · Avg Response Time · Avg Resolution Time · First-Time Fix Rate |
| Trend line chart | Calls over time (monthly), split by Office vs Production |
| Donut or bar | Calls by status (Open / In Progress / Closed) |
| Donut or bar | Calls by priority |
| Bar chart | Calls by team (Office vs Production) |
| Table or bar | Top 5 clients by call volume |

**Slicers:** Date range, Team (Office/Production), Technician, Client.

### Page 2: Employee Performance

**Purpose:** Compare technician efficiency across both teams.

| Visual | Content |
|--------|---------|
| KPI cards | Avg Calls/Tech · Avg Resolution Time · First-Time Fix Rate · Utilization Rate |
| Matrix / table | Technician × Calls Handled × Avg Resolution Time × First-Time Fix Rate × Parts Cost × Labor Hours |
| Bar chart | Calls per technician (sorted descending) |
| Scatter plot | Resolution time vs calls handled (identify outliers) |
| Bar chart | Labor hours per technician |

**Slicers:** Date range, Team, Department.

### Page 3: Machine Profitability

**Purpose:** The FSMA money question — is each machine making or losing money?

| Visual | Content |
|--------|---------|
| KPI cards | Total Machines Under Contract · Profitable Machines · Loss-Making Machines · Avg Margin % |
| Table (the core) | Machine (serial/model) × Client × Contract Revenue × Total Cost (parts + labor + expenses) × Net Profit × Margin % — conditional formatting: green = profit, red = loss |
| Waterfall or stacked bar | Cost breakdown per machine: parts vs labor vs expenses vs revenue |
| Bar chart | Top 10 most profitable machines · Bottom 10 (biggest losses) |
| Scatter | Revenue vs Cost per machine (above/below break-even line) |

**Slicers:** Date range, Team (Office/Production), Client, Contract status (Active/Expired), Machine model/group.

### Page 4: Parts & Fault Analysis

**Purpose:** Operational intelligence — what breaks, what gets consumed.

| Visual | Content |
|--------|---------|
| KPI cards | Total Parts Used · Total Parts Cost · Avg Parts per Call · Unique Fault Types |
| Bar chart | Top 15 parts by quantity consumed |
| Bar chart | Top 15 parts by cost |
| Bar chart | Most common fault/problem types |
| Table | Machine model × Avg faults/month × Most common fault × Avg parts cost per call |
| Trend line | Parts cost over time |

**Slicers:** Date range, Team, Machine model/group, Part item group.

### Page 5: Client & Project View

**Purpose:** Per-client service health — especially for production clients where each client = a project.

| Visual | Content |
|--------|---------|
| KPI cards | Total Clients Served · Machines in Field · Active Contracts · Client Profitability (avg) |
| Table | Client × Machines × Calls × Avg Response Time × Total Cost · Total Revenue · Net P&L |
| Bar chart | Top clients by call volume |
| Bar chart | Top clients by profitability (and bottom) |
| Drill-through | Click a client → see their machines, call history, contract details |

**Slicers:** Date range, Team, Territory/City.

### Page 6: Ticket Operations (Call Center View)

**Purpose:** Operational pulse — aging, backlog, response discipline.

| Visual | Content |
|--------|---------|
| KPI cards | Open Tickets Now · Avg Age of Open Tickets · Tickets Opened Today/This Week · Avg Response Time |
| Table | Open tickets list: Call ID × Client × Machine × Age (days) × Priority × Assigned Tech × Status |
| Histogram or bar | Ticket age buckets (0–1 day, 1–3, 3–7, 7–14, 14+) |
| Line chart | Response time trend (weekly avg) |
| Bar chart | Calls by origin (phone, email, portal, etc.) |
| Heat map | Call volume by day-of-week × hour (if time data exists) |

**Slicers:** Date range, Priority, Status, Technician.

---

## Phase 4 — Validation & Iteration

After building:

1. **Cross-check totals** — do service call counts match what users see in SAP?
2. **Verify classifications** — confirm Office vs Production machine grouping with stakeholder.
3. **Validate FSMA logic** — make sure contract revenue is correctly attributed to individual machines.
4. **Screenshot capture** — full screenshot pass of all pages.
5. **Package** — produce review artifact.
6. **Update Project Memory** — record what was built, what data sources are used, any gaps found.

---

## Open Questions for Stakeholder (ask before or during build)

1. **Machine classification**: What are the exact SAP item group names/codes for Office machines vs Production machines? (Phase 1 discovery can propose candidates, but stakeholder should confirm.)
2. **FSMA contract type**: What contract type code in SAP represents FSMA? Are there other contract types to include?
3. **SLA targets**: Are there defined SLA response/resolution time targets? If so, what are they (by priority)?
4. **Labor cost calculation**: Is technician labor costed at a standard hourly rate? If so, what rate? Or is it tracked differently?
5. **Billable vs non-billable**: Are some service calls billable (outside contract) while others are covered by FSMA? How is this distinguished in SAP?
6. **Team assignment**: Is the Office vs Production team split tracked on the employee record (`OHEM.dept` or similar) or determined by the machine type on each call?
7. **Currency**: All in IQD, or are there USD transactions?
8. **Date range**: What historical depth is needed? Last 1 year? 2 years? All time?

---

## How to Use This Document

**If you are an AI agent** receiving this plan:

1. Start with **Phase 1**. Query every table listed. Produce the discovery deliverable.
2. Share discovery findings with the stakeholder (or the orchestrating agent) before proceeding.
3. Adapt Phase 2 based on what actually exists in the data — some tables may be empty, some fields unused.
4. Build Phase 3 pages in PBIP format within `Reports/Service/`.
5. The semantic model should use SAP HANA ODBC DirectQuery or Import (match whatever Finance and Inventory use).
6. Apply the portfolio theme from `Shared/Standards/`.
7. After build, execute Phase 4.

**If you are a human** using this plan: follow the same sequence. Phase 1 can be done with a SQL client against SAP HANA directly.
