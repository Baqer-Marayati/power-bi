# Prompt: (edit title — SAP agent / Fabric UI / PBIP)

Use this where: **(e.g. SAP HANA B1 `CANON` schema / Fabric dev workspace / Canon PBIP in repo)**.

## Context

- Report / model: **Canon Inventory Report** PBIP (Fabric sync path vs `Reports/Inventory/Companies/CANON/` as needed).
- What we already know:
  - **(paste constraints, dates, DocNum examples, known slicers/measures, etc.)**

## Goal

Prove or deliver: **(one sentence — e.g. “landed cost bridge matches source” / “new filter hub layout” / “measure X matches SAP export”).**

## Outputs

**Default save location:** Desktop folder `Canon_PBIP_<workstream>_<YYYYMMDD_HHMM>/` (see `PROMPT_SAP_AGENT_PROCUREMENT_LANDED_DIAGNOSTICS.md` for full Desktop rules if this is a data pull).

Produce:

- **`README_<short>_<YYYYMMDD>.md`** — assumptions, SQL or steps, interpretation, **no secrets**.
- **`(list CSVs or artifacts)`** — e.g. extracts, screenshots list, PBIP file paths changed.

## Instructions

1. **(Step 1 — e.g. replicate PBIP filter grain in SQL / open page in Fabric / diff measure DAX).**
2. **(Step 2.)**
3. **(Step 3.)**

## Guardrails

- Do **not** paste credentials, connection strings, or tokens into files or chat.
- If results differ from PBIP, capture **grain** (dims, filters, date table) and **measure definition** in the README.

## Deliverable checklist

- [ ] Outputs saved to agreed folder (prefer Desktop — see Outputs).
- [ ] README with findings vs hypothesis.
- [ ] Paths / PR / Fabric sync note for whoever updates the semantic model or report.

When done, paste the **full output folder path** (or repo paths + branch) back into chat for PBIP/model alignment.
