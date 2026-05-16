# Prompt (SAP-reachable agent): Procurement landed-cost diagnostics for Canon PBIP

Use this on the **SAP HANA / Business One** machine that can query schema **`CANON`** (same as Power BI ODBC `HANA_B1`). Goal: prove whether **empty supplier/broker**, **0% add-on**, and **flat landed-cost bridge** are **data truth** or **model/query bugs**.

## Outputs

Write CSVs + one **`README_Canon_Procurement_LC_diag_<YYYYMMDD>.md`** under a dated folder (e.g. `Desktop\Canon_PBIP_DataPull_<timestamp>\`), **no credentials** in files.

## 1) LC header spot-check (DocNum = 100008 if present)

From **`CANON.OIPF`** (landed-cost header), export one row for **`DocNum = 100008`** (or latest open LC if missing):

- `DocEntry`, `DocNum`, `DocDate`, `DocDueDate`, `DocStatus`, `OpenForLaC`, `Canceled`
- `CardCode`, `SuppName`, `AgentCode`, `AgentName`
- `ExpCustom`, `ActCustom`, `ExCustomSC`, `ActCustSC`, `CustDate`, `incCustom`

## 2) Supplier/Broker population on landed-cost allocation grain

Run counts / null rates on **`CANON.OIPF` H** joined to **`CANON.IPF1` R** on **`H.DocEntry = R.DocEntry`** with the **same WHERE** style as the PBIP query (`H.DocDate >= '2026-01-01'`, `R.ItemCode` not blank, `Canceled <> Y`):

- Share of rows where **`COALESCE(R.CardCode, GR.CardCode, H.CardCode)`** is blank  
- Share where **`COALESCE(GR.CardName, H.SuppName, R.CardCode)`** is blank  
- Share where **`H.AgentCode` / `H.AgentName`** are blank  
- Optional: left join **`OPDN` GR** exactly as PBIP (`OriBAbsEnt/BaseEntry`, `OriBDocTyp = '20'`)

Export **50 sample rows**: `LcDocEntry`, `LcDocNum`, `ReceiptDocEntry`, `ReceiptLineNum`, resolved supplier code/name, agent code/name, `ItemCode`.

## 3) Add-on lines (IPF2) vs supplier base

For the same LC docs as section 2:

- Count **`IPF2`** rows per `DocEntry` where `CostSumSC` or `CostSum` ≠ 0  
- Sum **`IPF2`** amounts by landed-cost code (`AlcCode`) joined to **`OALC`** (`AlcName`, `CostCateg`)  
- Confirm **`IPF1`** rows exist for **`BaseType` in (18, 69, 20)** and date range — export **`BaseType` counts** like prior pull

## 4) Category bucket sanity

For top **`AlcCode`** rows by absolute amount, show raw **`AlcName`** + **`CostCateg`** so we can verify keyword buckets (`Transport`, `Tax / duty`, `Insurance`, `Other`) match Canon naming.

## 5) Receipt date vs LC posting date

For sample **`IPF1`** rows tied to **`OPDN`**, compare **`OPDN.DocDate`** vs **`OIPF.DocDate`** — export min/max delta (days) so we know how much the **Analyze by** toggle should move totals.

## Deliverable checklist

- [ ] LC 100008 (or substitute) header export  
- [ ] Supplier/broker null-rate summary + 50-row sample  
- [ ] IPF2 presence / sums by `AlcCode`  
- [ ] `IPF1.BaseType` histogram for filtered period  
- [ ] Short README interpreting whether blanks/zeros are **expected** or **join bugs**

When done, paste the folder path back into chat so the PBIP model can be aligned to findings.
