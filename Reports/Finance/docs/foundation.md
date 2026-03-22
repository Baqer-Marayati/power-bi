# Finance Foundation

## Purpose

This is the single best starting file for an AI agent or new operator who needs the majority of the practical Finance-module context in one place.

Use this file to understand:
- what this module is
- where the source of truth lives
- which supporting tools and integrations exist
- which environment facts are currently true
- where to look next for deeper detail

This file should stay high-signal and practical.
It should summarize the operating foundation, not duplicate every note in `Project Memory`.

## Project Identity

Module:
- `Reports/Finance`

Primary purpose:
- Power BI financial reporting project for Al Jazeera management reporting

Active editable report:
- `Financial Report/Financial Report.pbip`

Primary visual benchmark:
- `Design Benchmarks/Sample 2`

Live project brain:
- `Project Memory/`

## Source Of Truth

Use these rules consistently:

- `Financial Report` is the only active editable report.
- `PBIP` is the development source of truth.
- `PBIX` may be used as a review convenience, but not as the master.
- User review should happen from the packaged export artifact when report edits are ready for inspection.

## Read Order

Recommended startup sequence:
1. `AGENTS.md`
2. `README.md`
3. `docs/foundation.md`
4. `docs/setup.md`
5. `docs/structure.md`
6. `docs/agent-manual.md`
7. `Project Memory/PROJECT_DNA.md`
8. `Project Memory/DECISIONS.md`
9. `Project Memory/CURRENT_STATUS.md`
10. `Project Memory/MODEL_NOTES.md`
11. `Project Memory/NEXT_STEPS.md`
12. `Project Memory/REFERENCE.md`

## Repository Structure

Top-level meaning inside this module:

- `Financial Report`
  - active PBIP source files
- `Design Benchmarks`
  - visual benchmark and design references
- `Project Memory`
  - current truth, decisions, technical notes, and handoff continuity
- `docs`
  - stable onboarding, workflow, and standards documentation
- `Exports/Server Packages`
  - generated review/export artifacts
- `scripts`
  - helper scripts used by the workflow

## Current Environment And Integrations

### Power BI

- Power BI Desktop with PBIP support is required for real validation.
- PBIP and TMDL files can be edited directly, but Desktop validation is still the strongest evidence of what truly renders.

### Git And GitHub

- Git remote:
  - `git@github.com:Baqer-Marayati/reporting-hub.git`
- GitHub CLI binary is installed at:
  - `/opt/homebrew/bin/gh`
- Current local `gh` authentication status:
  - installed, but the saved token is currently invalid and needs re-authentication before GitHub issue operations can be trusted

### Local Helper Tools

Installed command-line tools currently verified:
- `gh`
- `jq`
- `ffmpeg`

Paths currently verified:
- `/opt/homebrew/bin/gh`
- `/opt/homebrew/bin/jq`
- `/opt/homebrew/bin/ffmpeg`

### Packaging Workflow

Packaging script:
- `scripts/package-report.sh`

Behavior:
- rebuilds `Exports/Server Packages/Financial Report - ready.zip`
- packages the full `Financial Report` folder for review or server transfer

Rule:
- after meaningful report edits, regenerate the package before asking for user review

### Skills

Project-specific Codex skills are not stored in this repository.
They live in the user skill directory and are part of the operating environment.

Currently referenced skill location:
- `~/.codex/skills`

Project-relevant skills currently documented in `Project Memory/REFERENCE.md`:
- `powerbi-financial-report`
- `project-memory-updater`
- `powerbi-visual-repair`
- `kpi-visual-consistency-agent`
- `model-cleanup-stale-object-agent`

Important note:
- other AI tools such as Claude or Cursor will not automatically use Codex skills unless separately given equivalent instructions

### Automations

Current local state checked on March 22, 2026:
- no `~/.codex/automations` folder was present
- no local Codex automation setup was detected from that standard path

That means:
- do not assume an automation layer exists for this project right now
- if automation is introduced later, document it here and in `Project Memory/REFERENCE.md`

## Stable Rules Every Agent Should Know

- Preserve the Sample 2 shell unless the user explicitly changes design direction.
- Keep a CFO / management-report tone.
- Logic first, styling second.
- Use IQD formatting consistently.
- Treat repeated UI elements such as KPI rows and slicer rails as shared systems.
- Update `Project Memory` after meaningful work.
- Treat packaging and validation as part of done-ness.

## Where To Document What

Use the right file for the right kind of truth:

- `docs/foundation.md`
  - the broad operating foundation, toolchain, integrations, and startup context
- `docs/setup.md`
  - stable setup instructions and required tools
- `docs/agent-manual.md`
  - detailed operator guidance and documentation logic
- `Project Memory/REFERENCE.md`
  - anchor paths, concrete references, and environment facts worth preserving
- `Project Memory/CURRENT_STATUS.md`
  - current live reality, especially anything that may drift
- `Project Memory/DECISIONS.md`
  - approved directions and durable constraints

## Maintenance Rule

When any of these change, update this file:
- active source-of-truth path
- benchmark choice
- GitHub remote or auth expectations
- installed helper tools relied on by the workflow
- packaging routine
- automation availability
- skill-location assumptions

This file should remain short enough to scan quickly, but complete enough to give another agent a strong start.
