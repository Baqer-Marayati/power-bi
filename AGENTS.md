# Agent Guide

This is the portfolio-level entrypoint for AI agents working in this repository.

## Read Order

Start here:
1. `README.md`
2. `docs/foundation.md`
3. `docs/portfolio-architecture.md`
4. `docs/structure.md`
5. `docs/first-encounter.md`
6. `docs/agent-operating-playbook.md`
7. `docs/ai-index.md`
8. `Shared/Standards/report-module-contract.md`
9. `Portfolio Memory/REPORT_CATALOG.md`
10. `Portfolio Memory/CURRENT_STATUS.md`
11. `Portfolio Memory/DECISIONS.md`

If the user refers to **screenshot lessons** or the **ChatContext** workflow, also read `Shared/ChatContext/LESSONS.md` (durable notes from past captures).

Then choose the report module you are actually working on.

For the current finance report:
1. `Reports/Finance/README.md`
2. `Reports/Finance/AGENTS.md`
3. `Reports/Finance/docs/foundation.md`
4. `Reports/Finance/Project Memory/PROJECT_DNA.md`
5. `Reports/Finance/Project Memory/DECISIONS.md`
6. `Reports/Finance/Project Memory/CURRENT_STATUS.md`
7. `Reports/Finance/Project Memory/NEXT_STEPS.md`

## Hierarchy Rules

- Treat the repository root as the portfolio layer.
- Treat each folder inside `Reports/` as a self-contained report module.
- Treat `Shared/` as reusable cross-report material.
- Treat `Portfolio Memory/` as cross-report truth.
- Treat archive folders as history, not as active work surfaces.

## Module Reality

Active production module:
- `Reports/Finance`

Active exchange module:
- `Reports/DataExchange`

Scaffolded (not yet fully active) modules:
- `Reports/HR`
- `Reports/Sales`
- `Reports/Service`
- `Reports/Marketing`

Do not assume a scaffolded module is active until `Portfolio Memory/REPORT_CATALOG.md` marks it Active.

## Cursor / VS Code workspace

- Agent rules: `.cursor/rules/` (`reporting-hub-portfolio.mdc` always applies; Finance rules apply under `Reports/Finance/` and `**/*.tmdl`).
- Tasks: **Terminal → Run Task** (or **Tasks: Run Task**) — e.g. **Finance: Package report (ready.zip)**, **Portfolio: Scaffold new report module**.
- Shared editor defaults: `.vscode/settings.json`, `.editorconfig`.
