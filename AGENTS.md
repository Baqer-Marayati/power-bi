# Agent Guide

This is the portfolio-level entrypoint for AI agents working in this repository.

## Read Order

Start here:
1. `README.md`
2. `Portfolio/docs/foundation.md`
3. `Portfolio/docs/portfolio-architecture.md`
4. `Portfolio/docs/structure.md`
5. `Portfolio/docs/first-encounter.md`
6. `Portfolio/docs/agent-operating-playbook.md`
7. `Portfolio/docs/ai-index.md`
8. `Portfolio/Shared/Standards/report-module-contract.md`
9. `Portfolio/Memory/REPORT_CATALOG.md`
10. `Portfolio/Memory/ACTIVE_FOCUS.md`
11. `Portfolio/Memory/CURRENT_STATUS.md`
12. `Portfolio/Memory/DECISIONS.md`

If the user refers to **screenshot lessons** or the **ChatContext** workflow, also read `Portfolio/Shared/ChatContext/LESSONS.md` (durable notes from past captures).

Then choose the report module you are actually working on.

For the current finance report:
1. `Reports/Finance/README.md`
2. `Reports/Finance/AGENTS.md`
3. `Reports/Finance/Module/docs/foundation.md`
4. `Reports/Finance/Module/Project Memory/PROJECT_DNA.md`
5. `Reports/Finance/Module/Project Memory/DECISIONS.md`
6. `Reports/Finance/Module/Project Memory/CURRENT_STATUS.md`
7. `Reports/Finance/Module/Project Memory/NEXT_STEPS.md`

## Hierarchy Rules

- Treat the repository root as the portfolio layer.
- Treat each folder inside `Reports/` as a self-contained report module.
- Treat `Portfolio/Shared/` as reusable cross-report material.
- Treat `Portfolio/Memory/` as cross-report truth.
- Treat archive folders as history, not as active work surfaces.

## Module Reality

Authoritative status: **`Portfolio/Memory/REPORT_CATALOG.md`**.

Active production module:
- `Reports/Finance`

Active exchange module:
- `Reports/DataExchange`

Additional active modules (PBIP + model in repo):
- `Reports/Sales`
- `Reports/Service`
- `Reports/Inventory`

Scaffolded (contract layout, no PBIP yet):
- `Reports/HR`
- `Reports/Marketing`

Do not treat a module as active for delivery until `Portfolio/Memory/REPORT_CATALOG.md` marks it Active.

Default deep-work starting point:
- `Portfolio/Memory/ACTIVE_FOCUS.md`

## Cursor / VS Code workspace

- Agent rules: `.cursor/rules/` (`reporting-hub-portfolio.mdc` always applies; Finance rules apply under `Reports/Finance/` and `**/*.tmdl`).
- Tasks: **Terminal → Run Task** (or **Tasks: Run Task**) — e.g. **DataExchange**: open the company PBIP in Power BI Desktop; **Finance: Open design benchmark (Wiise Sample 2) in Power BI Desktop** for the canonical benchmark PBIP; **Finance** / **Sales** / **Service** / **Inventory**: clear semantic model cache; **Portfolio: Validate custom themes vs Portfolio/Shared/Themes**, **Portfolio: Scaffold new report module**, and shared scripts (structure validation) as needed. See `Portfolio/docs/first-encounter.md` (section 9) for GitHub clone, MCP template (`.cursor/mcp.json.example`), and skills/plugins expectations.
- Shared editor defaults: `.vscode/settings.json`, `.editorconfig`.
