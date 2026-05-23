# Prompt: Procurement & Suppliers — Fabric LC enhancement (dual date, broker, closed/open, customs)

Use this document as the **single handoff prompt** for an implementation agent (Cursor Agent + Power BI Desktop validation) extending the **Canon Inventory Report** in the **Fabric Development Workspace** PBIP only.

---

## Recommended model

Use **GPT-5.3 Codex High** or **GPT-5.5 High** for PBIP semantic-model + visual JSON edits. If unavailable, **Claude 4.6 Sonnet High Thinking** for layout and edge-case reasoning. Always validate bindings in Desktop after substantive changes.

---

## Role and goal

You are enriching the **Procurement & Suppliers** page so it matches **how Canon actually uses SAP Business One Landed Costs** — with a **mixed audience** (procurement, logistics, finance, leadership).

The user approved this product direction:

1. **Always show both**: **Paid / received unit** (GRPO-based) **and** **Landed unit** (LC-based), with **Average unit COGS** for sales-side context — with **plain-language definitions** visible on-page.
2. **Date spine toggle**: visuals (trends, MoM bridge, mover table time context) respect **either** Goods Receipt date **or** Landed Cost **posting** date via a deliberate **Analyze by date** UX (toggle, field parameter, or equivalent).
3. **Broker first-class**: **broker** filters and appears beside **supplier** in detail contexts (matching SAP LC header Vendor vs Broker split).
4. **Open vs closed LC**: **default dataset includes Open + Closed LC** rows (match SAP inclusivity); add an **Finance / Official** preset that restricts to **closed only** via **bookmark + button**, so nobody argues about “truth.”
5. **Compact customs block**: KPI strip or slim visual exposing **SAP customs semantics** relevant to LC (projection vs booking), scoped to slice.
6. **Drill hierarchy (recommended)** when adding drill/step-through: **`Landed Cost document` → `Supplier + Broker` → `Item` → Receipt/GR lineage** — mirror SAP LC structure.

Implement in **`Fabric/DevelopmentWorkspace` only.** Do **not** copy back into `Reports/Inventory/Companies/CANON/...` unless explicitly requested after Fabric sign-off.

---

## Repository scope (authoritative paths)

Working PBIP root:

```
Fabric/DevelopmentWorkspace/
```

Artifacts:

```
Fabric/DevelopmentWorkspace/Canon Inventory Report.pbip
Fabric/DevelopmentWorkspace/Canon Inventory Report.Report/
Fabric/DevelopmentWorkspace/Canon Inventory Report.SemanticModel/
```

Target page folder (confirm `pages.json` if id drifts):

```
Fabric/DevelopmentWorkspace/Canon Inventory Report.Report/definition/pages/e5f6a7b8c9d0e1f2a3b4/
```

Display name:

**Procurement & Suppliers**

Read before coding:

```
Reports/Inventory/AGENTS.md
Reports/Inventory/Module/Project Memory/CURRENT_STATUS.md
Reports/Inventory/Module/Project Memory/DECISIONS.md
Reports/Inventory/Module/Project Memory/NEXT_STEPS.md
```

---

## Read order inside the Fabric model (verify before editing)

Inspect current landed-cost scaffold:

```
Fabric/DevelopmentWorkspace/Canon Inventory Report.SemanticModel/definition/tables/Fact_LandedCostAllocation.tmdl
Fabric/DevelopmentWorkspace/Canon Inventory Report.SemanticModel/definition/tables/Fact_GoodsReceipt.tmdl
Fabric/DevelopmentWorkspace/Canon Inventory Report.SemanticModel/definition/tables/_Measures.tmdl
Fabric/DevelopmentWorkspace/Canon Inventory Report.SemanticModel/definition/relationships.tmdl
```

Inspect page visuals (`visuals/*/visual.json`), `page.json` for `visualInteractions`.

---

## User decisions this build must honour (frozen spec)

| Area | Decision |
|------|-----------|
| Audience | Mixed — clarify metrics on-page |
| Paid vs landed | **Both**, always differentiated |
| Date | **Toggle** GR date vs LC posting date |
| Broker | **Must-have** (filter + tables) |
| Open LC rows | **Include all** by default |
| Customs | Small **on-page KPI/visual** strip |
| Default drill grain | **`LC Doc → Supplier+B → Item`** (implementer aligns visuals to this) |

---

## Semantic-model work packages

### LC-Header enrichment (grain: one LC document per row helper or columns on allocation fact)

Expose SAP LC **header facts** engineers need daily:

- **Vendor** (already surfaced via SupplierCode/Name linkage — reconcile naming with SAP Vendor field).
- **Broker** — map from SAP LC header Partner field Canon uses (**verify** SAP column on `CANON"."OIPF"` — Broker is often surfaced as **`AgentCode` / `AgentName`** — confirm in tenant metadata before binding).
- **Closed vs Open** equivalent — **`OIPF`** has fields such as **`OpenForLaC`** / document status patterns; verify exact closed/open rule for Canon and emit a **`Boolean` or categorical** `LcDocumentStatusClosed` usable in slicers. **Never guess** unchecked names; introspect ODBC or SAP client.
- **LC document identifiers** — `DocEntry`, `DocNum`, **`DocDate`** (posting timeline), **`DocDueDate`**, **`DocCur`/`DocRate`** if FX matters.
- **Customs totals** typical on LC header (`ExpCustom`, `ActCustom`, `CustDate`, `incCustom` flags depending on localization) — **verify** populated columns via `COLUMN` metadata or Spotfire-style profile; expose **Actual vs Projected** style pair if Canon uses columns on `OIPF`.
- **`Canceled`** semantics — LC rows should respect cancellation if column exists (`Canceled`/`C`/`N` patterns).

Deliver one of:

- **Path A:** extend **`Fact_LandedCostAllocation`** M-query with **`OIPF` columns** duplicated at row grain (`LOOKUPJOIN`/`join` keyed by LC `DocEntry`) — avoids new relationship complexity.
- **Path B:** new **`Fact_LandedCostDocuments`** grain = LC header + inactive date relationship patterns.

Pick the path with **minimal relationship risk**. Document choice in **`DECISIONS.md`**.

### Dual-date behavior (GR vs LC posting)

Today `Fact_LandedCostAllocation` relates `LcDate → Dim_Date`; `Fact_GoodsReceipt` relates `DocDate → Dim_Date`.

Implementation options (preferred first):

1. **Field parameter** or **Disconnected table “DateSpineChoice” + measures** branching `DATEADD`/filter context rewriting with **TREATAS** / **USERELATIONSHIP** carefully — risky if mishandled; only if proficient.
2. **Two parallel measure sets**: `*_ByGRDate_*` vs `*_ByLcDate_*` + **Legend text** referencing which selector is active; visuals bind to **`SelectedMeasure`** variant — stable but verbose.
3. **Duplicate thin date dims** inactive + `USERELATIONSHIP` in measures — textbook pattern if model already tolerates inactive rels.

**Requirement:** Selecting **Analyze by LC posting** shifts ** landed-cost trends, bridge, mover table land columns, customs strip** appropriately. Selecting **Analyze by GR** shifts **weighted purchase receipt measures** timelines to align receipts; LC measures should **still be visible but explain** inconsistent grain in subtitle if necessary.

Implementer chooses least fragile pattern; justify in **`MODEL_NOTES.md`** or **`DECISIONS.md`** if Inventory module splits those.

### Broker slice table

Either:

- `Dim_Broker` from distinct `AgentCode`/Name filtered non-blank joined to fact, **or**
- Columns on Fact + hidden auto-date table avoidance.

Prefer **broker codes** keyed for slicer stability (**UPPER/TRIM normalization** convention per Finance module precedent).

### “Official closed only” filter

Expose **`IsLcClosed`** (name TBD once SAP meaning confirmed):

- Default slicer:** **Include Open + Closed** (All / both selected).
- **Bookmark `bk_official_finance`:** sets **`IsLcClosed = TRUE`** (or equivalent SAP mapping) plus optional caption textbox **“Finance view · Closed LC only.”**
- Visible **bookmark button** labelled **Finance / Closed LC**.

### Customs mini-block measures

Measures (names illustrative — align with Portfolio naming conventions):

```
[ LC Customs Projected ]   ← map from verified OIPF field(s)
[ LC Customs Actual ]    ← map from verified OIPF field(s)
[ LC Customs Variance ]  ← simple difference blank-safe
```

Respect **`ar-IQ`** currency formatting parity with sibling measures.

---

## Report / UX specification (Fabric page)

### 1. On-page glossary (quiet, executive)

Insert **narrow text box** under KPI subtitle:

> **Paid/received unit** — average from goods receipt PO lines · **Landed unit** — per SAP Landed Costs (supplier + freight/duty/fees allocations) · **Average unit COGS** — booked cost on outbound sales movements.

Tune wording once measures formally named.

### 2. Analyze-by-date control

- **Title:** `Analyze by:`  
- **Control:** segmented control buttons **two-state** (**Receipt date** vs **LC posting date**) wired to bookmarks that flip disconnected slicers / sync slicer field / field parameter backing table — **implementer proofs least fragile.**

All **time-relative landed visuals** subtitles must mirror choice: e.g., bridge title suffix “*(dates = LC posting)*” dynamically OR static pair of bookmarks syncing textbox.

### 3. Broker

- **`slicer_broker`** (multi-select dropdown, left rail stacked after Segment Type unless layout demands row on top ribbon).
- Extend **`table_cost_impact`** (or equivalent mover table):

  | Add column |
  |-----------|
  | Broker (AgentName) |

- Wire **`visualInteractions`** so broker filters KPIs/charts/tables coherently; avoid orphan visuals.

### 4. Closed / Open inclusivity & Finance preset

**Default browsing:** no hidden exclusion of Open LC docs.

Artifacts:

| Artifact | Behaviour |
|---------|-----------|
| `slicer_lc_document_status` (optional) | All / Closed / Open — defaults **All**. |
| `btn_view_all_lc` bookmark | restores All + restores **Analyze date** bookmark pair default if grouped. |
| `btn_finance_closed` bookmark | **Closed LC only**, optional neutral background tone on caption. |

If slicer duplication confuses ops, collapses **`Closed filter`** into **Finance button-only** UX — acceptable if documented.

### 5. Customs strip

Create **thin container** beside KPI cluster or stacked under KPI row (`height` ≤ existing card height guidelines):

Suggested trio **cards**:

1. Customs — Projected (**IQD**)  
2. Customs — Actual (**IQD**)  
3. Variance or **Δ%** (**blank-safe**)

If Actual always blank historically, degrade to duo + explanatory caption “No actual customs postings in period.” Document data truth in **`CURRENT_STATUS.md`**.

### 6. mover / detail enrichment

Ensure **Supplier** table shows:

- **`LcDocNum`** (or string `LC-100008` format if preferred) column(s)
- Tooltip or expand width for **Posting date** duplication if Analyze-by toggle on LC mode

### 7. Visual hygiene

- Harmonize **fonts** `#2E3A42` captions, KPI shadow pattern **navy top accent**.
- Maintain **IQD suffix** parity.
- Re-run **`json.loads` parity check** on edited visual JSON dirs.

---

## Validation checklist (Definition of Done)

1. Refresh PBIP Fabric model against **SAP HANA** — no PQ errors **OIPF/IPF1/IPF2** additions.
2. **Spot-check LC 100008** (user example): broker **VE-00052**, vendor **VE-00080**, customs/fees totals **ballpark** reconcile (orders of magnitude sanity).
3. **Toggle** Receipt vs LC date — bridge + mix chart timestamps shift meaningfully OR documented why flat.
4. **Finance Closed** preset — KPI cards + landed visuals exclude open LC subset.
5. **Broker slicer** — filters table rows + at least downstream landed visuals verified.
6. **Customs KPIs** — non-zero when SAP shows values; blanks acceptable with caption.
7. **No orphaned `visualInteractions`** after new visuals IDs.
8. Update **`CURRENT_STATUS.md`**, **`DECISIONS.md`** (date-spine mechanic, Closed rule, Customs fields mapped), **`NEXT_STEPS.md`** residual risks.

---

## Explicit non-goals (do not silently expand scope)

- Rebuild unrelated Inventory pages Executive Summary layouts.
- Add AppSource custom visuals needing tenant admin approval unless user approves.
- Hard-code broker/vendor codes (**VE-*****`) into DAX filters — analytic only via data.
- Change Finance Portfolio PBIPs.

---

## Handoff completeness rule

Finish only when Fabric PBIP renders with **dual metrics clarity**, **date toggle wired**, **broker filter**, **customs KPI strip populated or honestly blank-captioned**, and **finance bookmark** tested in **Power BI Desktop** preview — then push guidance to **`NEXT_STEPS.md`** for Service/Fabric parity testing.

---

*Prepared May 2026 — Procurement & Suppliers Landed Cost Fabric enhancement prompt.*
