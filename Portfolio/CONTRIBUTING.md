# Contributing

This is the portfolio-level contribution guide for `reporting-hub`.

## Before You Start

1. Read `README.md`.
2. Read `AGENTS.md`.
3. Read `docs/first-encounter.md`.
4. Confirm task scope: portfolio-level or one domain module.

## Scope Rules

- Portfolio-level changes (standards, templates, architecture docs) stay in `Portfolio/`: `docs/`, `Shared/`, or `Memory/`.
- Domain-specific changes stay in `Reports/<Domain>/`.
- Do not mix unrelated domains in one change unless explicitly required.

## Source of Truth Rules

- Edit PBIP source files in the domain module.
- Treat packaged zip files as review artifacts, not editable masters.
- Keep live status in `Project Memory/CURRENT_STATUS.md` for the affected scope.

## Required Validation

For structural changes:
- Run `scripts/validate-structure.ps1`.

For report-content changes:
1. run screenshot capture workflow,
2. review target pages from latest capture set,
3. rebuild package artifact,
4. update memory docs.

## Naming and Structure

- Follow `Shared/Standards/report-module-contract.md`.
- Keep screenshot folder casing canonical: `Records/screenshots`.
- Keep archive names meaningful (date + subject + status).

## Commit Hygiene

- Keep commits scoped and readable.
- Prefer minimal diffs for PBIP/TMDL and JSON-like files.
- Avoid broad refactors when a small targeted fix works.
- Do not commit secrets or machine-local credentials.

## Pull Request Checklist

- [ ] Scope is clear and limited.
- [ ] Structure validation passed.
- [ ] Any report change has updated evidence/package flow.
- [ ] Memory docs updated where project truth changed.
- [ ] No secrets or accidental binary noise were added.
