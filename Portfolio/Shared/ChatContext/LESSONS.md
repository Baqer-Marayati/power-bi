# Lessons from screenshots (Cursor + repo)

Short, **durable** notes the assistant adds after reviewing captures in `images/` when you ask to **learn**, **remember**, or **not repeat** a mistake. Future agents can read this file in the same conversation or when you say to follow past screenshot lessons.

## How entries are written

- One **dated** block per batch of screenshots (or per distinct issue).
- **Bullets**: concrete do / don’t — not chatty narrative.
- **Scope tag** at the start of a bullet when useful: `[repo]` | `[cursor]` | `[finance]` | `[general]`.

## Log

### 2026-05-05 — Canon Sales Map manual layout

- `[sales]` Preserve the user-adjusted Sales Map layout from screenshot 11: keep the left slicer rail and KPI/header band, use a large central Deneb Iraq choropleth, and place the Sales by City table as a tall right-side companion panel.
- `[sales]` Current preferred PBIP positions on `salesmap304934iq01`: `choropleth_iraq_gov` at `x=188.33`, `y=230`, `w=773.33`, `h=690`; `matrix_city_sales` at `x=973.33`, `y=230`, `w=271.67`, `h=690`.
- `[sales]` Do not shrink the map back to the earlier smaller layout or remove the city table when polishing the Deneb map; future changes should preserve this map/table balance unless the user asks otherwise.

### 2026-05-05 — Canon Sales charts, tab order, Deneb registration (user)

- `[sales]` **Sales Person** top visual: switched from **treemap** to **clustered bar chart** titled **Profit by Salesperson**; encode **Profit** only (Sales measure removed from the same axis); default sort **Profit descending**.
- `[sales]` **Business Partner** top visual: switched from **treemap** to **bar chart** titled **Profit by Customer**; encode **Profit** only; sort **Profit descending**; legend/gradient chrome trimmed (legend off where it no longer applies).
- `[sales]` **Tab order** in `pages.json`: **Sales Map** (`salesmap304934iq01`) sits **before Commission** in the bottom tab strip (between Business Partner and Commission). Trust `pageOrder` over memory when describing page sequence.
- `[repo]` `[sales]` Register AppSource visuals used in PBIP: Canon Sales `report.json` includes **`publicCustomVisuals`** for **Deneb** (`deneb7E15AEF80B9E4D4F8E12924291ECE89A`) so the repo documents the dependency for Desktop/tenant policy reviews.

### 2026-05-05 — Power BI Desktop: gallery selection vs canvas visual (screenshot)

- `[cursor]` `[powerbi]` On **Sales Map**, the **Visualization pane can show “Shape map” selected** while the canvas choropleth is a **Deneb** custom visual. Do not diagnose map bindings from the gallery icon alone—select the **on-canvas** visual or read `visualType` in the PBIP `visual.json` (`deneb7E15AEF80B9E4D4F8E12924291ECE89A` vs `shapeMap`).

### 2026-05-05 — Canon Finance ROI and posting periods (user)

- `[finance]` **`accountingPeriods`** is no longer a single-row stub: imported from SAP B1 **`CANON.OFPR`** via ODBC with **start/end dates** and **`periodStatus`** (among other columns). Full behavior is recorded in `Reports/Finance/Module/Project Memory/MODEL_NOTES.md` (ROI section dated 2026-05-05).
- `[finance]` **`[ROI %]`** (annual card) was reworked: for the **selected year(s)** on `Dim_Date`, sum **`[Net Profit]`** only over **locked** posting periods (`periodStatus = "Y"`), with **month/quarter/branch/sales-type/department** filters removed; denominator **`[Company Capital]`** with branch/sales-type/department cleared—no retained-earnings constant in the formula.
- `[finance]` **`[Monthly ROI %]`** line chart: annualize as **`DIVIDE([Net Profit], [Company Capital], 0) * 12`** (explicit annualization factor), separate from the locked-period annual card.

### 2026-04-18 — PBIR visual category swap can silently break aggregations

- `[repo]` In a PBIR `visual.json`, the row/category `Entity` must be a **dimension key column** if any of the visual's measures aggregate from a fact that isn't connected to that entity. Switching from a related dim (e.g. `Dim_Customer.CustomerName`) to a denormalized **string in another fact** (`Fact_ServiceCalls.CustomerName`) makes those measures return the **grand total on every row**, because the string is not a relationship key. Symptom: every customer's bar shows the same length.
- `[repo]` Fix the inverse problem (slicer doesn't reach a related dim through a single-direction many-to-one chain) with a **visual-level filter measure** (e.g. `[Total Service Calls] > 0`) in PBIR `filterConfig`, **not** by reassigning the visual's category. Bidirectional cross-filter on `Fact → Dim` is risky: it usually creates an ambiguous date-path with `Dim_Date` and breaks model load.
- `[repo]` Before changing a visual's category column, list the visual's measures and confirm every measure either (a) lives in the same fact as the new category, or (b) is reachable from the new category through an active relationship. If neither, leave the category on the dim.
- `[repo]` `Fact_ServiceRevenue` and `Fact_ServiceParts` in the **Service** model have **no relationship to `Dim_Equipment`**. A `MachineClass` slicer therefore cannot filter revenue/parts via the equipment path; it can only filter `Fact_ServiceCalls` and (via `EquipmentKey`) `Fact_ServiceActivities`.

### 2026-03-25 — Revenue Insights product tree + Cursor screenshots

- `[cursor]` Chat image upload can reject PNGs; saving captures under `Shared/ChatContext/images/` and asking for the **latest by file time** avoids relying on unsupported attach paths.
- `[finance]` *(Superseded for Revenue Insights — see 2026-03-26.)* A **disconnected** map on the chart axis + bridging measure often evaluates **blank**; materializing a label on the fact fixes that. The **current** axis is **`Item Business Type`** from **`OITM.U_BusinessType`**, not PQ segment maps.
- `[finance]` Any calculated table `.tmdl` must be **`ref table`** in **`model.tmdl`** or it will not load.
- `[repo]` Durable “memory” for assistants is **git-tracked** files (`LESSONS.md`, `Project Memory`, `.cursor/rules`), not model chat state.

### 2026-03-26 — Item business type UDF (Revenue Insights)

- `[finance]` Prefer **SAP item master UDF** (`OITM.U_BusinessType` in SQL; model column **`Item Business Type`**) for B2B/B2C-style revenue breakdowns instead of **manual segment maps** or **item group name** parsing in Power Query.
- `[finance]` Remove unused **calculated map tables** and measures once the visual is rewired to the fact column, to avoid dual sources of truth and refresh overhead.

### 2026-03-27 — PBIP semantic cleanup (measures + helper tables)

- `[finance]` **Verify before deleting measures:** (1) grep `Financial Report.Report/definition` for `_Measures.<name>` / `Property` bindings; (2) grep `Financial Report.SemanticModel` for `[Measure Name]` in **other** tables (e.g. **`Net Revenue LY`** is used by **`generalLedgerEntries`** — do not drop).
- `[finance]` **`Dim_ReportRows`** / **`Dim_KPIRows`** had **no** visual JSON references; they only supported removed statement/KPI measures — safe to delete **with** those measures and **`ref table`** / **diagram** cleanup.
- `[finance]` When two measures have **identical DAX**, keep one implementation and alias the other (e.g. **`Opex by Account`** = `[Opex by Department]`) so behavior stays the same for bound visuals.
- `[finance]` After bulk measure/table removal, **open the PBIP in Desktop** and confirm load + pages; **`en-US`** culture metadata may show stale names until Desktop reconciles.
- `[repo]` Record semantic cleanups in **`Project Memory/MODEL_NOTES.md`** so the next agent does not reintroduce “missing” objects.

### 2026-03-25 — Finance slicer + open-state rules

- `[finance]` The date slicer contract is pinned: `Year` must start at **2026** (no years before 2026 in the slicer).
- `[finance]` On the left slicer rail, **Sales Type must be above Department** (swapped from the previous order).
- `[finance]` The report should open with **no values until refresh**; avoid shipping/keeping semantic-model cache when this behavior is expected.

### 2026-03-26 — Revenue grouping source lock

- `[finance]` Revenue grouping on `Revenue Insights` must use SAP item-master UDF **`OITM.U_BusinessType`** (`Fact_SalesDetail['Item Business Type']`) instead of `ItemGroupName`.

### 2026-03-31 — SAP HANA connectivity + canceled document handling

- `[repo]` SAP HANA credentials are stored in `Shared/SAP Export Pipeline/set_credentials.sh` (env vars `SAP_HANA_USER` / `SAP_HANA_PASSWORD`). The `hdbsql` CLI at `C:\Program Files\sap\hdbclient\hdbsql.exe` works for ad-hoc queries; PowerShell ODBC (`System.Data.Odbc`) hits a protocol-parsing error on this server.
- `[finance]` `[sales]` When querying `OINV`/`ORIN` transactionally, **always filter `T0."CANCELED" = 'N'`**. SAP B1 keeps both the original (`CANCELED='Y'`) and cancellation (`CANCELED='C'`) documents in the same table with positive `LineTotal`. Without the filter, canceled amounts are double-counted. The GL (`OJDT/JDT1`) handles this internally (credit + debit net to zero), so GL-based reports are unaffected.

### 2026-04-09 — PBIP page.json schema limitations

- `[finance]` **`ordinal` is NOT a valid property** in page schema `2.0.0` (PBI Desktop November 2025 / v2.149). Adding it causes a hard load error: *"Property 'ordinal' has not been defined and the schema does not allow additional properties."* Page tab order must be set **manually in Desktop** by dragging tabs; it persists on save.
- `[finance]` Do **not** invent JSON properties based on external schema docs—always verify against the **`$schema` URL version** already in the file or against what Desktop actually writes.

### 2026-04-14 — SAP HANA direct ODBC (Canon tenant)

- `[repo]` For **ad-hoc ODBC** from PowerShell (and to mirror **HANA Studio**), use **direct** connection parameters — not only `DSN=HANA_B1` — when the DSN is wrong or incomplete for this host.
- `[repo]` **Working pattern** (SSL off): `Driver={HDBODBC};ServerNode=hana-vm-107:<SQL_PORT>;DatabaseName=<TENANT>;UID=SYSTEM3;PWD=<secret>;Encrypt=FALSE;`
- `[repo]` **SQL port:** use **`30041` first**; **`30044`** is the documented alternate if the first fails from a given network.
- `[repo]` **Tenant database name** (not the B1 company schema): **`HV107C21694P01`**. After connect, use schema **`CANON`** for tables (e.g. `"CANON"."OPRJ"`).
- `[repo]` **Never** commit passwords or paste them into tracked docs; use env vars (e.g. `SAP_HANA_USER` / `SAP_HANA_PASSWORD`), Studio credential storage, or team secret management. Rotate if exposed in chat.

### 2026-04-18 — Pre-baked SAP "Profit Period" must include PEC-reversal rows for true cutoff symmetry

- `[finance]` A pre-baked **synthetic Profit Period (`_PP`) row** in `Fact_BalanceSheet` that uses a *refresh-time* "open fiscal year" filter (e.g. `WHERE YEAR(RefDate) > MAX(YEAR(PEC.RefDate)) - 1`) is **historically broken**. It only ever emits rows for the FY that is open *today*, so any cutoff date in a previously-open-but-now-closed FY shows zero `_PP` and the BS is off by exactly that FY's P&L net (PAPERENTITY screenshot 2025-08-31 missing IQD 335,472,659.87).
- `[finance]` The **correct SQL pattern** (no DAX needed) is two UNION sub-blocks: (1) per-day `_PP` rows for **every** P&L posting in history (no year filter), and (2) one **PEC-reversal row per closed FY** at that FY's PEC posting date with `Amount = -SUM(FY P&L)`. Cumulative `SUM` of `_PP` at any cutoff `X` then equals exactly the YTD P&L of the FY that was open at `X`, because every closed FY's per-day rows are perfectly cancelled by their own reversal row. SAP's PEC convention (`OJDT.TransType = -3`, posting to Retained Earnings) is exactly the trigger you need to date the reversal row correctly.
- `[finance]` **Validation discipline:** when fixing a "snapshot at cutoff" model, always reconcile at **multiple cutoffs spanning at least one fiscal-year boundary** (e.g. last-FY-mid-year, last-FY-end, current-FY-mid, current-FY-end). A single "cutoff = today" pass will hide the historical bug.
- `[finance]` **Dimension trade-off for synthetic rows:** if the page has no per-branch / per-department slicers (true for SAP-style BS), **set those dim columns to `NULL` on `_PP` rows** so the per-day row and its reversal cancel cleanly under any future filter. Carrying real dims on the per-day rows but `NULL` on the reversal row breaks the cancellation as soon as a dim filter is applied. If a future page requires per-dim Profit Period, migrate `_PP` from data to a DAX measure that consults a `Fact_PEC` lookup.
- `[finance]` **PEC pattern is per-company.** PAPERENTITY uses `TransType = -3` to GL `'3000500'` Retained Earnings. CANON or any new company must be re-validated with `SELECT YEAR(RefDate)-1, MIN(RefDate) FROM OJDT JOIN JDT1 WHERE TransType=-3 AND Account=<RE GL> GROUP BY YEAR(RefDate)-1` before the same fix is ported.
- `[cursor]` `[powerbi]` **PBIR date-slicer `mode='Before'` literal in `objects.data[]` is unreliable in Desktop** (mirrors Microsoft samples Issue #84). The literal saves correctly to JSON but Desktop tends to render the slicer in default `Between` mode anyway. The data-side `[BS Amount]` cumulative-as-of math is independent of the slicer's render mode, so the BS values are always correct; the cosmetic fix is for the user to flip the slicer to `Before` once via the slicer's calendar-icon dropdown in Desktop and save the PBIP. A future PBIR-only fix is to set the slicer's actual filter state via `objects.general[].properties.filter.filter` with a `Comparison` condition (`ComparisonKind` = LessThanOrEqual) — Power BI then auto-renders in `Before` mode based on the existing filter shape.

### 2026-04-11 — Reporting Hub pathing and durable guidance refresh

- `[repo]` Future agents should route through `Portfolio/Memory/ACTIVE_FOCUS.md` before guessing active project paths; several modules use real business folder names instead of a synthetic `<ReportName> - <CompanyCode>` pattern.
- `[finance]` The live Finance source-of-truth paths are under `Reports/Finance/Companies/CANON/Canon Financial Report/` and `Reports/Finance/Companies/PAPERENTITY/Paper Financial Report/`, not the older `Reports/Finance/Financial Report/` layout.
- `[repo]` When a “current status” file turns into a long changelog, move durable rules into `DECISIONS.md` / `MODEL_NOTES.md` and restore `CURRENT_STATUS.md` to a short current snapshot.
- `[repo]` The portfolio has standardized on `Reports/<Domain>/Module/...`; validators, templates, CI, and docs should all match that layout.
