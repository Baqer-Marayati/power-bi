# Phase 1 — SAP Data Discovery Results

> **Date:** March 29, 2026
> **Schema:** CANON on SAP HANA (`hana-vm-107:30013`, DSN `HANA_B1`)
> **Data range:** January 4, 2026 – March 29, 2026 (~3 months)

---

## Discovery Deliverable Table

| Table | Rows | Usable? | Key Finding | Notes |
|-------|------|---------|-------------|-------|
| **OSCL** | 676 | **Yes** | Main service call / ticket table. 676 calls across 3 months (Jan–Mar 2026). | Assignee, responder, and timing fields well populated. `technician` field nearly empty (3/676) — use `assignee` or SCL6.Technician instead. |
| **SCL1** | 0 | **No** | Empty. Was expected to hold activities — SAP B1 uses this for solution links in this version. | Activities are in SCL6 instead. |
| **SCL2** | 153 | **Yes** | Parts/inventory lines on service calls. ItemCode, ItemName populated. | `TransToTec` quantities are all 0 — quantities likely tracked via linked delivery notes (SCL4→ODLN). Bill flag = "Y" on all. |
| **SCL3** | 108 | **Yes** | Service labour lines. All lines are item SV001 "Service Labour Income". | Quantity/HourFrom/HourTo fields are empty — labour hours likely tracked via SCL6 activity duration instead. |
| **SCL4** | 131 | **Yes** | Linked financial documents: 102 delivery notes (PartType='N') + 29 invoices (PartType='I'). | **Critical join table** for parts cost (→ODLN→DLN1) and service revenue (→OINV→INV1). |
| **SCL5** | 0 | **No** | Empty. Not used in this SAP B1 instance. | — |
| **SCL6** | 794 | **Yes** | **Service call activities** — technician visits with duration, start/end times, check-in/out. | 12 distinct technicians. 558 calls have 1 activity, 118 have 2. `DurType`: H=hours (509), M=minutes (189), D=days (96). Avg duration ~9 units. |
| **SCL7** | 153 | **Marginal** | Address/shipping metadata on service calls. | Low value for reporting — mostly tax/logistics fields. |
| **OCTR** | 0 | **No** | **EMPTY — No service contracts at all.** | FSMA contracts are NOT tracked in SAP's native contract module. See FSMA gap analysis below. |
| **CTR1** | 0 | **No** | Empty (no parent contracts). | — |
| **OINS** | 13,091 | **Yes** | Equipment cards — 13K machines registered. All have customer, itemCode, internalSN. | No `project` column exists. `contract` field = 0 on all records. `manufSN` populated on 10,129/13,091. |
| **OITM** | 1,463 | **Yes** | Item master — machines + parts. | Joins to OITB for classification. |
| **OITB** | 41 | **Yes** | Item groups — 41 groups. **Key to Office vs Production classification.** | See Classification Map below. |
| **OHEM** | 65 | **Yes** | Employees. 16 in Service Department (dept=6), 16 in Sales, 16 in Finance. | 12 active service engineers (position=4), 1 call center (position=19), 2 department placeholders. |
| **OCRD** | 2,510 | **Yes** | Business partners / customers. | Standard dimension table. |
| **OPRJ** | 96 | **Yes** | Projects — 96 records, named per client+machine (e.g., "Amazon Book store VP115", "Blue LinePrintshop C710"). | All Active=Y. Only 1 service call links via BPProjCode. Weak linkage to service calls. |
| **OINV** | 837 | **Yes** | A/R Invoices. 29 linked to service calls via SCL4. | Service revenue source. |
| **INV1** | 2,087 | **Yes** | A/R Invoice lines. Has `isSrvCall` column but 0 rows flagged. | Link via SCL4.DocAbs → OINV.DocEntry → INV1. |
| **OPCH** | 229 | **Partial** | A/P Invoices — parts purchasing. | Not directly linked to calls. Useful for cost analysis at aggregate level. |
| **PCH1** | 1,039 | **Partial** | A/P Invoice lines. | Same as OPCH — indirect linkage. |
| **ODLN** | 421 | **Yes** | Deliveries. 102 linked to service calls via SCL4. | Parts cost source (delivered to service calls). |
| **DLN1** | 1,295 | **Yes** | Delivery lines. Has `isSrvCall` column but 0 flagged. | Link via SCL4.DocAbs → ODLN.DocEntry → DLN1. |

### Additional lookup tables discovered

| Table | Rows | Purpose |
|-------|------|---------|
| OSCT | 2 | Call types: 1=Direct, 2=Indirect |
| OSCP | 32 | Problem types: Main body, Full machine, POD, Paper unit, Laser, ITB, Ink tank, etc. |
| OSCO | 10 | Call origins: Telephone, E-Mail, Web, WhatsApp message/call, Walk-in, individual names |
| OSCS | 4 | Call statuses: -3=Open, -2=Pending, -1=Closed, 1=Canceled |
| OUDP | 7+ | Departments: Service, Sales, Finance, Administration, IT, HR, Legal |
| OHPS | 25 | Positions: Service Engineer (4), Call Center (19), Key Account Manager (9), etc. |

---

## Machine Classification Map

### Proposed Office Machine Groups

| Group Code | Group Name | Equipment Cards | Service Calls | Classification |
|-----------|-----------|----------------|--------------|---------------|
| 142 | B2B - DS Copier \ Office Copier / CG - Office Colour | 750 | 24 | **Office** |
| 143 | B2B - DS Copier \ Office Copier / CX - Office Service | 0 | 0 | **Office** (service items) |
| 144 | B2B - DS Copier \ DS Copier Accessories | 1 | 1 | **Office** (accessories) |
| 147 | B2B - DS Copier \ Office Copier (VLP) / PH - PP Light B&W | 49 | 9 | **Office** |
| 150 | B2B - DS Copier \ Dims / EM - DIMS | 4,226 | 23 | **Office** |
| 162 | B2B - DS Copier \ Office Copier / GF - Office SOHO Service | 0 | 0 | **Office** |
| 163 | B2B - DS Copier \ Office Copier (VLP) / PY - PP Light Service | 0 | 0 | **Office** |
| 165 | B2B - DS Copier \ Office Copier / CF - Office B&W | 1,068 | 35 | **Office** |
| 166 | B2B - DS Copier \ Office Copier (VLP) / PI - PP Light Colour | 0 | 0 | **Office** |
| 167 | B2B - DS Copier \ Output Management / FX - OM Software Sales | 0 | 0 | **Office** |
| 170 | B2B - DS Copier \ Paper / FW - 3rd Party Solutions | 0 | 0 | **Office** |
| 171 | B2B - DS Copier \ Office Copier / BF - Office SOHO | 0 | 0 | **Office** |

### Proposed Production Machine Groups

| Group Code | Group Name | Equipment Cards | Service Calls | Classification |
|-----------|-----------|----------------|--------------|---------------|
| 138 | B2B - IPS \ LFP / BR - LFP - BU | 159 | 46 | **Production** |
| 141 | B2B - IPS \ Prod Sol Copier / PX - Prod Sol Service | 0 | 0 | **Production** |
| 145 | B2B - IPS \ WFP / SH - WFP Service TDS | 0 | 0 | **Production** |
| 146 | B2B - IPS \ WFP / SF - WFP Sales TDS | 2 | 1 | **Production** |
| 148 | B2B - IPS \ IPS Accessories | 5 | 30 | **Production** (accessories) |
| 152 | B2B - IPS \ Prod Sol Copier / PG - Prod Sol Colour | 9 | 20 | **Production** |
| 156 | B2B - IPS \ Prod Sol Copier / SD - DP Sales | 5 | 0 | **Production** |
| 157 | B2B - IPS \ WFP / SA - WFP Sales DGS R2R | 0 | 0 | **Production** |
| 158 | B2B - IPS \ WFP / SB - WFP Service DGS R2R | 0 | 0 | **Production** |
| 161 | B2B - IPS \ WFP / SQ - WFP Service DGS | 0 | 0 | **Production** |
| 164 | B2B - IPS \ RP / DF - RP Service | 0 | 0 | **Production** |
| 168 | B2B - IPS \ Prod Sol Copier / PF - Prod Sol B&W | 0 | 0 | **Production** |
| 169 | B2B - IPS \ Prod Sol Copier / SJ - DP Service | 0 | 0 | **Production** |

### Group 139 (#N/A) — NEEDS RECLASSIFICATION

| Group Code | Group Name | Equipment Cards | Service Calls | Classification |
|-----------|-----------|----------------|--------------|---------------|
| 139 | #N/A | 69 | **256** | **Production** (should be reclassified) |

This is the **biggest service call driver** (256/676 = 38% of all calls). The items in group 139 are major production machines:
- imagePRESS C910 Series MFP — 162 calls
- imagePRESS V1350 — 21 calls
- imagePRESS Server B6000 — 16 calls
- imagePRESS V1000 — 16 calls
- varioPRINT DP Line Engine — 13 calls
- COLORADO 1650 Printer — 6 calls
- imagePRESS C165 — 4 calls

**Stakeholder action needed:** Confirm these belong under Production and ideally reclassify in SAP.

### Consumer (B2C) Groups

| Group Code | Group Name | Equipment Cards | Service Calls |
|-----------|-----------|----------------|--------------|
| 149 | B2C - Laser SFP | 1,981 | 16 |
| 151 | B2C - IJ MFP | 48 | 0 |
| 155 | B2C - Laser MFP | 3,572 | 7 |
| 159 | B2C - IJ SFP | 361 | 3 |
| 160 | B2C - Scanners | 786 | 0 |
| 180 | B2C - Business IJ Hardware | 0 | 0 |

### Service-Specific Item Groups

| Group Code | Group Name | Items |
|-----------|-----------|-------|
| 172 | Service Labour | SV001 "Service Labour Income" |
| 173 | FSMA Contract | SV002 "FSMA Contract Income" |
| 174 | Transportation fees | (empty) |
| 175 | MPS Contract | MPS "MPS Contract Income" |
| 176 | Warranty COGS | SV003 "Warranty of Machines Sold" |
| 177 | * | (catch-all) |
| 178 | Fixed Assets | (non-service) |

---

## Special Attention Findings

### 1. Machine Classification (Office vs Production)

**How it works:** `OITM.ItmsGrpCod` → `OITB.ItmsGrpNam`.
- **"B2B - DS Copier"** prefix = Office machines
- **"B2B - IPS"** prefix = Production machines
- **"B2C"** prefix = Consumer machines (may overlap with Office servicing)

**Gap:** Group 139 ("#N/A") contains the most-serviced production machines (imagePRESS, varioPRINT, COLORADO) and accounts for 38% of all service calls. It must be mapped to Production.

**Recommendation:** Build classification in the semantic model with a CASE statement:
```
CASE
  WHEN group LIKE 'B2B - IPS%' THEN 'Production'
  WHEN group LIKE 'B2B - DS Copier%' THEN 'Office'
  WHEN group LIKE 'B2C%' THEN 'Consumer/Office'
  WHEN group = '#N/A' THEN 'Production'  -- confirmed by item names
  ELSE 'Other'
END
```

### 2. FSMA Contracts — NOT in OCTR

**Finding:** OCTR is completely empty. OINS.contract is 0 on all equipment. CTR1 has no rows.

**However:** Item group 173 = "FSMA Contract" with item SV002 "FSMA Contract Income". This means FSMA revenue is likely invoiced as regular A/R invoices (OINV) with line item SV002 — not tracked through SAP's service contract module.

**Implication for Phase 2:**
- The plan's `ContractRevenue` fact table cannot source from OCTR/CTR1.
- Instead, FSMA revenue must be extracted from `INV1` lines where `ItemCode = 'SV002'` (FSMA Contract Income) or `ItemCode = 'MPS'` (MPS Contract Income).
- We lose per-machine contract assignment (OCTR would have linked contracts to individual equipment cards). Revenue will be at the customer/invoice level unless the invoice lines carry equipment serial numbers.

**Stakeholder question:** How are FSMA contracts tracked? Is there a separate system, spreadsheet, or SAP customization? Can we get a list of which machines are under FSMA?

### 3. Technician Assignment (OSCL.technician vs SCL6)

**Finding:**
- `OSCL.technician` — only 3 out of 676 calls have this populated. **Not usable as primary technician field.**
- `OSCL.assignee` — populated on all 676 calls, but includes non-Service dept people:
  - Service Dept: 448 calls (Ali Abdulsattar=215, Abdullah Abbas=76, Mohammed Altahan=65, Mustafa Khudhair=47, Murtadha Sadiq=45)
  - Sales Dept: 158 calls (Azhar Hazim=116, Asawar Yaqoub=24, Almuntadher Yousif=18)
  - Finance Dept: 70 calls (Eyas Jamal=70)
- `OSCL.responder` — similar pattern to assignee.
- `SCL6.Technician` — 794 activities across 12 distinct technicians, all in Service Dept (dept=6). **This is the real field technician assignment.**

**Recommendation:**
- Use `SCL6.Technician` for actual field technician who performed the work.
- Use `OSCL.assignee` as the "call owner/coordinator" (may include dispatchers from Sales/Finance).
- The Employee Performance page should primarily use SCL6.Technician.

**Service Department Technicians (dept=6):**

| empID | Name | SCL6 Activities | OSCL Assignee |
|-------|------|----------------|--------------|
| 71 | Mohammed Altahan | 131 | 65 |
| 75 | Farouk Khadir | 85 | — |
| 67 | Murtadha Sadiq | 83 | 45 |
| 76 | Bilal Abdulkarim | 79 | — |
| 70 | Younis Sattar | 72 | — |
| 69 | Mustafa Khudhair | 67 | 47 |
| 66 | Bilal Tayara | 61 | — |
| 77 | Mohammed Abduljabbar | 50 | — |
| 73 | Ahmed Abduljabbar | 50 | — |
| 68 | Abdullah Abbas | 49 | 76 |
| 74 | Mohammed Abdulsattar | 39 | — |
| 72 | Ali Abdulsattar | 26 | 215 |
| 80 | Yamam Nabil (Call Center) | — | — |

Note: Ali Abdulsattar (empID=72) is the top assignee (215 calls) but has only 26 SCL6 activities — likely a dispatcher/coordinator who assigns calls but rarely goes to the field.

### 4. Equipment-to-Project Linkage

**Finding:** OINS has **no `project` column**. The plan expected `OINS.project` → `OPRJ.PrjCode`, but this field does not exist.

- `OSCL.BPProjCode` exists but only 1 out of 676 calls has it populated.
- OPRJ has 96 projects, named by client+machine model (e.g., "Amazon Book store VP115", "Blue LinePrintshop C710").
- OINS.contract = 0 on all equipment.

**Implication:** There is no systematic equipment→project linkage in the data. The project concept exists in SAP (96 records) but is not connected to service calls or equipment cards.

**Stakeholder question:** Are projects used for production machine tracking? If so, how should we link equipment to projects — by customer name matching, or is there another relationship?

---

## OSCL Dimension Values

### Call Types (OSCT)
| Code | Name | Count |
|------|------|-------|
| (blank) | Unclassified | 362 |
| 1 | Direct | 260 |
| 2 | Indirect | 54 |

### Problem Types (OSCP) — Top 10
| Code | Name | Count |
|------|------|-------|
| (blank) | Unclassified | 380 |
| 1 | Main body | 173 |
| 4 | Consumable parts | 21 |
| 17 | New Installation | 16 |
| 9 | Laser unit | 10 |
| 19 | Service (general) | 7 |
| 14 | Main board | 6 |
| 2 | Full machine | 6 |
| 7 | Ink tank | 5 |
| 6 | Paper unit | 5 |

32 total problem types defined, 31 with at least 1 call.

### Origins (OSCO)
| Code | Name | Count |
|------|------|-------|
| (blank) | Unclassified | 373 |
| -2 | Telephone | 197 |
| 1 | WhatsApp message | 83 |
| 4 | Call from Ali Sattar | 13 |
| 2 | WhatsApp call | 4 |
| 7 | Call from Bilal Karim | 3 |
| 3 | Walk-in customer | 1 |
| 5–6 | Named individuals | 2 |

### Statuses (OSCS)
| Code | Name | Count |
|------|------|-------|
| -1 | Closed | 654 |
| -3 | Open | 22 |
| -2 | Pending | 0 |
| 1 | Canceled | 0 |

### Priority
| Code | Count |
|------|-------|
| L (Low) | 624 |
| H (High) | 40 |
| M (Medium) | 12 |

### Calls by Month
| Month | Count |
|-------|-------|
| 2026-01 | 183 |
| 2026-02 | 288 |
| 2026-03 | 205 |

---

## OSCL User-Defined Fields (UDFs)

| Column | Description | Populated | Notes |
|--------|-------------|-----------|-------|
| U_A_5 | "Accepted" | 676/676 | YES=404, Undefaend=272. Possibly call acceptance status. |
| U_A_12 | "Remarks From The engineer" | 9/676 | Free-text technician notes. Sparse. |
| U_A15 | "BK" (Black counter) | 152/676 | Meter/counter reading at time of call. |
| U_A_20 | "C" (Cyan counter) | 139/676 | Counter reading. |
| U_A_21 | "M" (Magenta counter) | 139/676 | Counter reading. |
| U_A_22 | "Y" (Yellow counter) | 139/676 | Counter reading. |
| U_A_23 | "Small BW" | 112/676 | Page count. |
| U_A_24 | "Large BW" | 103/676 | Page count. |
| U_A_25 | "Small Color" | 99/676 | Page count. |
| U_A_26 | "Large Color" | 92/676 | Page count. |
| U_A_27 | "Total Small" | 89/676 | Page count. |
| U_A_28 | "Total Large" | 88/676 | Page count. |
| U_A_29 | "Total" | 159/676 | Total counter/pages. |
| U_A_30 | "RESPON" | 0/676 | Not populated. |

**Value for Phase 2:** Counter readings (U_A15–U_A_29) on ~20% of calls enable cost-per-page analysis for production machines. Include these as optional measures.

---

## Timing Fields

OSCL has rich timing data:
- `createDate` + `createTime` — 676/676 populated. Time stored as HHMM integer (e.g., 1128 = 11:28).
- `closeDate` + `closeTime` — 654/676 (all closed calls).
- `respOnDate` + `respOnTime` — 675/676 (response timestamp).
- `resolOnDat` + `resolOnTim` — 675/676 (resolution timestamp).
- `respByDate` + `respByTime` — SLA target timestamps (population not checked but column exists).

This enables: Avg Response Time, Avg Resolution Time, SLA compliance calculations.

---

## Financial Document Linkage

### How parts cost reaches service calls

```
OSCL.callID → SCL4.SrcvCallID (PartType='N') → SCL4.DocAbs = ODLN.DocEntry → DLN1 (line items with price, quantity, total)
```

102 delivery notes linked to calls. Sample: toner, drums, rollers, entire machines.

### How service revenue reaches service calls

```
OSCL.callID → SCL4.SrcvCallID (PartType='I') → SCL4.DocAbs = OINV.DocEntry → INV1 (line items with price, quantity, total)
```

29 invoices linked to calls. Sample: parts (toner, drums, spare parts), SV001 "Service Labour Income".

### FSMA revenue path (proposed)

Since OCTR is empty, FSMA revenue should be found in:
```
INV1.ItemCode = 'SV002' (FSMA Contract Income) → OINV (customer, date, total)
```

This gives us FSMA revenue per customer per invoice, not per machine.

---

## Gaps, Surprises & Risks

### Critical Gaps

1. **No service contracts (OCTR/CTR1)** — Machine Profitability page as designed requires contract-to-machine assignment. Without OCTR, we can't attribute FSMA revenue to individual machines. Must ask stakeholder how FSMA contracts are tracked.

2. **No equipment-to-project linkage** — The `OINS.project` column does not exist. OSCL.BPProjCode is used on 1 call. The Client/Project page needs an alternative approach, possibly matching by customer code.

3. **Group 139 ("#N/A") misclassification** — 256 calls (38%) are against machines in group #N/A. These are all production machines (imagePRESS, varioPRINT). The semantic model must map this group explicitly. Ideally SAP should be corrected.

4. **SCL2 quantities are all 0** — Parts are listed on calls but have no quantity data. Actual parts cost must come from linked delivery notes (DLN1) via SCL4.

### Moderate Gaps

5. **OSCL.technician nearly empty** — Must use SCL6.Technician as primary technician source, which means technician assignment is at the activity level, not the call level. Calls without activities (676 - 558 = 118 calls have no SCL6 row? Actually 676 calls, 794 activities across 558+118=676 calls) — need to verify.

6. **55% of calls have blank callType** — 362/676 unclassified. Direct vs Indirect distinction is incomplete.

7. **56% of calls have blank problemTyp** — 380/676 unclassified. Fault analysis will be limited.

8. **55% of calls have blank origin** — 373/676. Call source analysis incomplete.

9. **30% of calls have no itemCode or equipment card** — 205/676 calls have no machine linked. Some are labeled "WRONG TICKET" or generic requests.

10. **Only 3 months of data** — The dataset starts Jan 4, 2026. No historical depth for year-over-year trends.

### Positive Surprises

11. **Counter/meter readings exist** — UDFs U_A15–U_A_29 provide BK/C/M/Y and page count readings on ~20% of calls. Enables cost-per-page analysis.

12. **Financial linkage works** — SCL4 successfully links calls to delivery notes (parts cost) and invoices (service revenue). Machine profitability can be calculated at the call level for calls that have linked documents.

13. **SCL6 activity data is rich** — Duration, start/end times, check-in/out with GPS coordinates (lat/long). Enables utilization and travel analysis.

14. **Service items defined** — SV001 (Labour Income), SV002 (FSMA Income), SV003 (Warranty COGS), MPS (MPS Income) provide clear revenue classification.

---

## Recommendations for Phase 2

1. **Drop `ContractRevenue` fact table** — replace with FSMA revenue extracted from INV1 where ItemCode IN ('SV002', 'MPS').

2. **Use SCL6 as primary activity/technician source** — not SCL1.

3. **Use SCL4 as the bridge to financial documents** — not direct SCL5 (empty).

4. **Build classification in the model** — CASE statement mapping item group codes/names to Office/Production/Consumer, with explicit handling of group 139 = Production.

5. **SCL2 for parts list, DLN1 for parts cost** — SCL2 tells you what parts were on a call; DLN1 (via SCL4) tells you the cost.

6. **Include counter readings** — U_A15–U_A_29 as optional columns on the ServiceCalls fact for cost-per-page analysis.

7. **Accept call-level (not machine-level) profitability** — until FSMA contract-to-machine linkage is resolved with stakeholder.

---

## Stakeholder Answers (Round 1)

Answers received March 29, 2026:

1. **FSMA/SMA contracts** are per-page agreements. The client pays monthly based on page counts (A4/A3, B&W/color at different rates). In return they receive ink, spare parts, and service. Revenue is invoiced using item SV002 "FSMA Contract Income" (96 lines, 35.6M IQD). Parts delivered under FSMA use TaxCode='FSMA' (at zero cost to client) or TaxCode='SMA'. Labour is tracked via SV001 "Service Labour Income" (262 lines, 22.3M IQD). MPS contracts use item 'MPS' (26 lines, 9.1M IQD).

2. **Technician classification (confirmed by stakeholder):**
   - **Production Service:** empID 66-71 (Bilal Tayara, Murtadha Sadiq, Abdullah Abbas, Mustafa Khudhair, Younis Sattar, Mohammed Altahan)
   - **Office Service:** empID 72-78 (Ali Abdulsattar, Ahmed Abduljabbar, Mohammed Abdulsattar, Farouk Khadir, Bilal Abdulkarim, Mohammed Abduljabbar, Omar Sultan)
   - **Call Center (dispatcher):** empID 80 (Yamam Nabil) -- distributes tickets to engineers
   - **Exclude:** empID 115, 117 (department placeholders, zero activity)

3. **Non-service assignees (Azhar Hazim, Eyas Jamal, Asawar Yaqoub, Almuntadher Yousif)** are irrelevant to the service report. Exclude from technician views.

4. **Group 139 (#N/A)** contains production machines. Map as Production in the report.

5. **Project linkage exists** on financial documents: `INV1.Project` and `DLN1.Project` carry OPRJ project codes. 96 projects exist, each named as "Client + Machine Model" (e.g., "Amazon Book store VP115"). However, FSMA revenue lines (SV002) do NOT carry project codes -- they are linked by customer code only. Equipment cards (OINS) do not have a project field.

---

## FSMA/SMA Revenue Model (discovered)

### Revenue streams in invoices

| Item Code | Group | Description | Lines | Total (IQD) | Billing model |
|-----------|-------|-------------|-------|-------------|--------------|
| SV002 | 173 (FSMA Contract) | FSMA Contract Income | 96 | 35,625,684 | Per-page: qty = pages, price = rate/page |
| SV001 | 172 (Service Labour) | Service Labour Income | 262 | 22,275,872 | Per-visit: flat fee per service call |
| MPS | 175 (MPS Contract) | MPS Contract Income | 26 | 9,118,165 | Per-page (same model as FSMA) |
| SV003 | 176 (Warranty COGS) | Warranty of Machines Sold | 0 | 0 | Not yet invoiced |

### FSMA cost absorption

Parts delivered under FSMA are flagged with special tax codes:

| Tax Code | Invoice Lines | Delivery Lines | Total (IQD) | Meaning |
|----------|--------------|----------------|-------------|---------|
| FSMA | 9 | 9 | 0 | Parts at zero cost (fully covered by contract) |
| SMA | 7 | 5 | 5,225,255 | Parts billed/valued under SMA |

### FSMA revenue-to-machine linkage

- SV002 invoice lines do **not** carry a Project code. Revenue is at customer level only.
- Parts/supplies delivery lines (DLN1) **do** carry Project codes linking to specific machines.
- For machine-level profitability: match SV002 revenue to customer, then allocate across that customer's production machines (or show at customer level).

---

## Project Linkage (discovered)

### How projects work

Each OPRJ record = one client + one machine model (e.g., "Platinume printshop 30 M", "Amazon Book store VP115"). 96 projects exist, all active.

### Where project codes appear

| Table | Column | Usage | Lines with project |
|-------|--------|-------|--------------------|
| INV1 | Project | Parts/supplies invoiced to a project | ~300+ lines |
| DLN1 | Project | Parts/supplies delivered to a project | ~300+ lines |
| OSCL | BPProjCode | Service call linked to a project | 1 call (barely used) |
| OINS | (none) | Equipment cards have no project field | N/A |
| OINV | Project | Invoice header project | needs verification |

### Top projects by delivery volume (parts cost)

| Project | Name | DLN1 Lines | Total Cost (IQD) |
|---------|------|-----------|-----------------|
| PR-067 | Three Tesla | 20 | 15,345,000 |
| PR-089 | Platinume printshop 30 M | 18 | 8,806,512 |
| PR-088 | Direct Platform Company | 5 | 5,063,500 |
| PR-095 | Harem hospital | 7 | 3,304,800 |
| PR-069 | Al-Ameriya Center | 5 | 3,000,000 |
| PR-091 | Al-Yazn Printing Press | 12 | 2,794,995 |
| PR-070 | Zuhal center | 4 | 2,520,000 |

### Equipment card to project connection

OINS has no project field and no UDFs. The link is indirect:
1. OPRJ.PrjName contains client name + machine model
2. OINS has customer + itemCode (machine model)
3. Financial documents (INV1, DLN1) carry Project codes

For Phase 2, the semantic model should join through customer code and optionally through project code on financial lines.

---

## Yamam Nabil (Call Center) -- Investigation

**IMPORTANT:** `OSCL.userSign` maps to `OUSR.INTERNAL_K` (SAP user account), NOT to `OHEM.empID`. The cross-check revealed:

| userSign | OUSR.INTERNAL_K | SAP User | Tickets Created |
|----------|----------------|----------|----------------|
| 64 | 64 | **Yamam Nabil** (AJZ09) | 459 (68%) |
| 72 | 72 | **Office Service Department** (AJZ17, shared account) | 217 (32%) |

Yamam IS the primary ticket creator. She is very active in SAP -- she creates 68% of all tickets, almost all of which are for production machines. The remaining 32% are created through a shared "Office Service Department" account.

Yamam's OHEM empID is 80 (not 64). empID 64 in OHEM = Almuntadher Yousif (Sales). The confusion arose from mismatching the userSign→OUSR join with empID→OHEM join.

### Yamam's measurable KPIs
- **Tickets created:** 459 in 3 months (~5/day)
- **Machine types:** Primarily production machines (group #N/A = imagePRESS, IPS, LFP)
- **Distribution pattern:** Routes to all 6 production technicians + occasionally office techs
- **Potential metrics:** tickets created per day, time-to-create, distribution volume per technician, callType/problemType fill rate

### Ticket creation roles
- **Yamam Nabil** (OUSR AJZ09): Production service dispatcher -- creates production tickets
- **Office Service Dept** (OUSR AJZ17, shared account): Office service ticket creation -- likely used by office team members

---

## Technician Classification (confirmed)

| empID | Name | Team | Role | SCL6 Activities |
|-------|------|------|------|----------------|
| 66 | Bilal Tayara | **Production** | Service Engineer | 61 |
| 67 | Murtadha Sadiq | **Production** | Service Engineer | 83 |
| 68 | Abdullah Abbas | **Production** | Service Engineer | 49 |
| 69 | Mustafa Khudhair | **Production** | Service Engineer | 67 |
| 70 | Younis Sattar | **Production** | Service Engineer | 72 |
| 71 | Mohammed Altahan | **Production** | Service Engineer | 131 |
| 72 | Ali Abdulsattar | **Office** | Service Engineer / Coordinator | 26 field + 215 dispatched |
| 73 | Ahmed Abduljabbar | **Office** | Service Engineer | 50 |
| 74 | Mohammed Abdulsattar | **Office** | Service Engineer | 39 |
| 75 | Farouk Khadir | **Office** | Service Engineer | 85 |
| 76 | Bilal Abdulkarim | **Office** | Service Engineer | 79 |
| 77 | Mohammed Abduljabbar | **Office** | Service Engineer | 50 |
| 78 | Omar Sultan | **Office** | Service Engineer | 0 (new) |
| 80 | Yamam Nabil | **Call Center** | Ticket Dispatcher | 0 (not in SAP data) |

Note: This classification is hardcoded by empID, not derived from any SAP field. If team assignment changes, the mapping must be updated in the semantic model.

---

## Remaining Open Questions

1. **SLA targets:** Are there defined response/resolution time targets per priority?
2. **Labor cost rate:** Is there a standard hourly rate per technician for costing labor?
3. **Counter readings:** Should we track cost-per-page metrics? The data exists on ~20% of calls.
4. **Blank classification fields:** 55%+ of calls lack callType, problemTyp, origin. Is this a training/adoption issue, or acceptable?
5. **FSMA per-machine allocation:** SV002 revenue is at customer level. Should we allocate it equally across that customer's machines, or show profitability at customer level only?
