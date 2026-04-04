# Decisions

## 2026-03-29 -- Phase 1 Discovery Decisions

### Data source mapping (plan vs actual)

| Plan assumed | Actual source | Decision |
|-------------|--------------|----------|
| SCL1 = Activities | **SCL6** = Activities | Use SCL6 for technician visits, duration, check-in/out |
| SCL5 = Parts consumed | **SCL2** (part list) + **DLN1 via SCL4** (cost) | SCL2 for what parts; DLN1 for cost values |
| OCTR/CTR1 = Contract revenue | **INV1 where ItemCode='SV002'/'MPS'** | FSMA/MPS revenue from regular invoices, not contracts module |
| OSCL.technician = primary tech | **SCL6.Technician** (field) + **OSCL.assignee** (coordinator) | SCL6.Technician for performance metrics; OSCL.assignee for call ownership |
| OINS.project = project link | **INV1.Project / DLN1.Project** | No project on equipment cards; project lives on financial document lines |

### Technician team classification

Hard-coded by empID (no SAP field for team):
- Production Service: 66, 67, 68, 69, 70, 71
- Office Service: 72, 73, 74, 75, 76, 77, 78
- Call Center: 80
- Exclude: 115, 117 (placeholders), and all non-dept-6 assignees

### Machine classification

Group prefix logic:
- `B2B - IPS*` = Production
- `B2B - DS Copier*` = Office
- `B2C*` = Consumer/Office
- Group 139 (#N/A) = **Production** (stakeholder confirmed; contains imagePRESS, varioPRINT, COLORADO)

### FSMA revenue model

- SV002 = FSMA per-page revenue (qty = page count, price = rate per page)
- SV001 = Labour income (flat fee per visit)
- MPS = MPS per-page revenue
- TaxCode FSMA/SMA on parts = delivered under contract at zero/reduced cost
- Revenue is at customer level, not per-machine (SV002 lines have no Project code)

### Machine profitability: per customer per machine (stakeholder decision)

- Show profitability at customer x machine level, not just customer
- FSMA revenue (SV002) must be allocated from customer level down to individual machines
- Allocation method: proportional to service call volume or counter readings per machine
- Cost side: already per-project via DLN1.Project and per-call via SCL4 linkage

### Ticket creation mapping (userSign -> OUSR, NOT OHEM)

OSCL.userSign maps to OUSR.INTERNAL_K, not to OHEM.empID:
- userSign=64 -> OUSR "Yamam Nabil" (AJZ09) -- creates 68% of tickets (production)
- userSign=72 -> OUSR "Office Service Department" (AJZ17, shared account) -- creates 32% (office)

Yamam's empID in OHEM is 80 (not 64). empID 64 in OHEM = Almuntadher Yousif (Sales, unrelated).

### Exclusions

- Non-service-dept assignees excluded from technician views
- empID 115, 117 excluded (phantom records)
- Yamam Nabil (empID 80) IS measurable via OUSR -- include her ticket creation KPIs on Ticket Operations page
