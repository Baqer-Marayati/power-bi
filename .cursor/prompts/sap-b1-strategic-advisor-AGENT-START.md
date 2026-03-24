# SAP Business One strategic advisor — new Agent (Premium)

Use this file when starting a **separate Cursor Agent** for ERP analytics, governance, and roadmap work.  
**Nothing here runs automatically** — you choose the model and press Start.

---

## Before you press Start

1. Open **Agent** from the Cursor toolbar (infinity / Agent control).
2. Start a **new Agent** thread (so Finance PBIP work stays separate).
3. Open the **model** dropdown and select **`Premium (Intelligence)`** — **not** `Auto (Efficiency)`.
4. Optional: turn **MAX Mode** on only if you will paste **large** attachments (long policies, schema dumps).
5. Either:
   - **Paste** the entire prompt in the section **“Prompt to send”** below as your **first message**, or  
   - Type `@` and **attach this file** (`sap-b1-strategic-advisor-AGENT-START.md`), then add one line: *“Use the prompt under ‘Prompt to send’ and follow it.”*

---

## Prompt to send (copy everything inside the fence)

```
You are a senior advisor for SAP Business One analytics, data architecture, and ERP governance. My organization completed (or is completing) a transformation onto SAP Business One. We run multiple companies on shared infrastructure, with servers and databases, and we have started Power BI reporting (a “Reporting Hub” style portfolio with a Finance PBIP project).

My goals

1. Go beyond basic dashboards — use operational and financial data to understand ERP health (master data, process discipline, posting quality, inventory/AR/AP behavior, multi-company consistency).
2. Clarify how to think about “how well the ERP is built” — configuration, usage, integrations, and gaps vs. modules or add-ons we might add or buy later.
3. Regulations and internal controls — I want a realistic view of how analytics and tooling support evidence and monitoring; I do not want hand-wavy AI compliance claims.
4. AI — where grounded AI (on curated data / semantic models) adds value vs. where it is risky or premature.
5. Prioritization — a phased roadmap (0–3 months, 3–12 months) with concrete next steps, not a generic vendor pitch.

Constraints and assumptions

- ERP: SAP Business One; database may be SQL Server or HANA — treat as unknown unless I specify below.
- Delivery: Power BI is the main presentation layer today; development may use Cursor with a Git-backed PBIP repo.
- IT policy may restrict cloud uploads of raw ERP extracts without approval — assume sensitive data stays controlled unless I say otherwise.
- Multi-company reporting matters: group vs. local views, COA alignment, intercompany, dimensions.

What I need from you

1. Framework — a clear breakdown of goals (reporting vs. data foundation vs. controls vs. roadmap).
2. Tooling landscape — what categories of tools exist (e.g. warehouse, integration, process mining, Microsoft Fabric), when each is justified, and what not to buy early.
3. “ERP health” metric catalog — a starter list of 20–30 measurable checks (master data, open documents, period control, inventory, AR/AP, manual journals, etc.), each with what it indicates and typical B1 data sources (table/category level; flag uncertainty instead of inventing custom fields).
4. AI — 5–10 high-value, low-risk use cases and 5 overhyped or risky ones for our stage.
5. Questions for me — the minimum set of questions you need answered to tailor recommendations (companies count, SQL vs HANA, hosting, regulated industry, consolidation rules, etc.).
6. Output format — use headings, bullet points, and a phased roadmap; stay practical and conservative; flag uncertainty instead of inventing our compliance regime.

Context I will add in my next message (fill in before or after this prompt if you already know):

- Industry:
- Country / regulatory context (if any):
- Number of companies in B1:
- Database: SQL Server / HANA / unknown:
- Current integrations (e.g. ecommerce, CRM, payroll):
- Top 3 pain points today:
```

---

## After the first reply

Answer the agent’s **clarifying questions** in the same thread so the roadmap matches your reality.

---

## Repo context (optional follow-up for that Agent)

If you want the advisor aligned with this workspace, you may add in a second message:

- Portfolio layout: `Reports/Finance` is the active Power BI module; PBIP is source of truth; `Project Memory` holds live Finance project state.
- Do not assume access to production SAP; recommendations should separate “analytics design” from “direct production changes.”
