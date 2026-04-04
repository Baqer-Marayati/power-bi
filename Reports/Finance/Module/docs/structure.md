# Repository Structure

## Top-Level Layout

### `Financial Report`

The active PBIP project and source of truth for development.

Contains:
- report definition files
- semantic-model TMDL files
- local Power BI metadata excluded by `.gitignore`

### `Design Benchmarks`

Living benchmark and visual reference area.

Use this folder for:
- benchmark PBIP shells
- screenshots
- reference themes
- inspiration or replacement design records

### `Project Memory`

Operational memory for continuity across work sessions.

Key files:
- `PROJECT_DNA.md`
- `CURRENT_STATUS.md`
- `DECISIONS.md`
- `MODEL_NOTES.md`
- `NEXT_STEPS.md`
- `REFERENCE.md`
- `PAGE_MAP.md`
- `DATA_GAPS.md`
- `POWERBI_PATTERNS.md`

### `docs`

Stable documentation for repository onboarding and structure.

Use this folder for:
- setup instructions
- architecture and structure summaries
- page-purpose summaries
- data-context notes that help orient future work
- repeatable workflows
- stable standards
- glossary and quick-scan issue summaries

### `.github`

Workflow templates for disciplined issue and PR tracking.

### `CHANGELOG.md`

High-level milestone record only.
Do not turn it into a detailed diary of every micro-edit.

## Documentation Split

Use each layer for a different purpose:

- `AGENTS.md`
  - universal AI entrypoint and read order
- `docs/foundation.md`
  - broad operating foundation, tooling, integrations, and startup context
- `README.md`
  - quick orientation and links
- `docs/`
  - stable repo-facing documentation
- `Project Memory/`
  - active truth, decisions, current state, and handoff context

Recommended substructure inside `docs/`:
- `workflows/`
  - repeated operating procedures and checklists
- `standards/`
  - naming, formatting, and layout rules
- root `docs/*.md`
  - orientation docs such as setup, pages, known issues, and glossary

## Source Of Truth Rules

- The active editable report is `Financial Report`.
- `PBIP` is the development source of truth.
- `PBIX` can be created temporarily for review but must not replace the PBIP workflow.
- `Design Benchmarks/Sample 2` is the active design benchmark unless memory states otherwise.
- `AGENTS.md` should stay aligned with `README.md`, `docs/`, and `Project Memory` so new agents can recover context quickly.
