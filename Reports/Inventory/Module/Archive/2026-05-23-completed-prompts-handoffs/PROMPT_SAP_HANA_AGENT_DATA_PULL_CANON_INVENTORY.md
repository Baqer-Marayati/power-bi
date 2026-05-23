# Agent prompt — SAP B1 / HANA data pull for Canon Inventory (Power BI PBIP)

Run this agent **on the machine that can reach SAP HANA** (e.g. Cloudiax Windows / RDP).  
Credentials are supplied by the operator **only in that secure session**. Do **not** store passwords in scripts committed to Git.

---

## Role

You are a database analyst agent with **read-only SQL** access to **SAP Business One on SAP HANA**. The goal is validating and extending the **Canon Inventory Report** semantic model: goods receipts, purchase orders, stock, sales/COGS, and **landed cost** linkage.

**Rules**

- `SELECT` only (no DDL/DML).
- Assume company schema **`"CANON"`** unless the operator specifies otherwise.
- **Never** echo passwords into summaries, file names, zips, or logs.

---

## Output folder (Windows Desktop)

```powershell
$base = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Canon_PBIP_DataPull_YYYYMMDD_HHMM'
New-Item -ItemType Directory -Force -Path $base | Out-Null
```

Replace `YYYYMMDD_HHMM` with the actual timestamp. Put **all** deliverables under `$base`.

---

## 1 — Connection proof

Run something like:

```sql
SELECT CURRENT_SCHEMA, SESSION_USER FROM DUMMY;
```

Record which schema maps to the company DB for all following queries.

---

## 2 — Schema inventory (“what exists”)

Confirm these SAP B1 objects exist under the company schema and export **column metadata** as CSV (`<TABLE>_columns.csv`) with column name, ordinal position, and data type if practical:

**Purchasing / receipts:** `OPDN`, `PDN1`, `OPOR`, `POR1`

**Landed costs:** `OIPF`, `IPF1`, `IPF2`, `OALC`

**Master / dims:** `OITM`, `OITB`, `OWHS`, `OITW`

**Sales / returns (COGS-side in model):** `OINV`, `INV1`, `ORIN`, `RIN1`

**Deliveries / transfers (inventory model):** `ODLN`, `DLN1`, `OWTR`, `WTR1`

**Movement / ledger tables** referenced by **`Fact_StockMovement`** (inspect source query targets if not obvious).

Export **`key_tables_rowcounts.csv`**: table name plus row counts. For huge tables use **bounded counts** (`WHERE DocDate >= ...`) and document the predicate instead of blocking on full `COUNT(*)`.

---

## 3 — Landed-cost profiling (CSV extracts)

Produce validation extracts (full export only if modest row volume):

- From **`IPF2`** joined to **`OALC`**: distinct `AlcCode`, `AlcName`, categorization-related fields (`CostCateg`, etc.), and variance of amount columns (`CostSum`, `CostSumSC`, …).
- From **`IPF1`**: counts grouped by **`BaseType`**; date range; highlight rows where **`BaseType = 20`** (goods receipt).
- **Join path check:** land cost **`OIPF` / `IPF1`** linked to **`OPDN` / `PDN1`** via `BaseEntry`, `OrigLine`, `DocEntry`, `LineNum` as the semantic model expects. Export a **spot-check** sample (e.g. latest 500 rows or stratified sample) showing keys align.

---

## 4 — Bulk exports aligned with the Power BI semantic model

Export as **UTF-8 CSV with header**, comma-delimited, RFC4180-style quoting, dates as **ISO `yyyy-mm-dd`** where possible.

| Output file | Content |
|-------------|---------|
| `Fact_GoodsReceipt.csv` | **`OPDN` + `PDN1`**, `DocDate >= '2026-01-01'`, non-blank `ItemCode`, include **`LineNum`**. |
| `Fact_LandedCostAllocation_flat.csv` | Prefer the same logic as the model CTEs (`RowBase`, `CostLines`, `UNION ALL` base vs allocated). If one query times out, export **`rowbase.csv`**, **`costlines.csv`**, and a short note on how to combine. |
| `Fact_PurchaseOrder.csv` | **`OPOR` + `POR1`**, same date filter as model. |
| `Dim_Item_core.csv` | **`OITM` + `OITB`**, `InvntItem = 'Y'`, columns used in report dimensions. |
| `Fact_WarehouseStock_or_InventorySnapshot.csv` | **`OITW`** + item/warehouse filters as in model (warehouses: Dora, Erbil, Sadoon, Showroom Ilwea). |
| `Fact_StockMovement.csv` (and related) | Match **`Fact_StockMovement`** partition SQL and date filter; **split by month** if too large. |

**Format choice**

- Use **CSV** for large or wide tables; Excel has row limits (~1M).  
- **`.xlsx`** only for small masters (e.g. compact `OALC` extract).  
- Split huge results: `*_part01.csv`, `*_part02.csv`, etc.

---

## 5 — README

Write **`README_Canon_PBIP_pull.md`** in the same folder with:

- Host / database / tenant identifiers only (**no** secrets).  
- Tables missing or renamed vs the list above.  
- Row counts per output file and **exact** `WHERE` clauses.  
- Columns the model depends on that are **mostly NULL** (e.g. `FobValue`, `PriceFOB`, `TtlExpndSC`, `TtlExpndLC`, `OhType`).  
- Queries that timed out and suggested narrower windows.

---

## 6 — Security housekeeping

After exports, advise the operator to delete any scratch files containing credentials. Never zip plaintext passwords alongside data.

---

## One-line elevator summary

Agent on SAP-reachable VM: discovery CSVs + model-aligned **`OPDN`/`PDN1`**, **`OIPF`/`IPF1`/`IPF2`/`OALC`**, purchases, items, stock, movement outputs to **`Desktop\\Canon_PBIP_DataPull_*`**, **`README`**, no secrets in artifacts.
