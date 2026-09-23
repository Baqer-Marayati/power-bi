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
- `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip`
- `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip`

Live (published) copies, read-only:
- `Fabric/CanonAnalytics/Canon Financial Report.*`
- `Fabric/PaperAnalytics/Paper Financial Report.*`

Primary visual benchmark:
- `Reports/Finance/Module/Design Benchmarks/Sample 2`

Live project brain:
- `Project Memory/`

## Source Of Truth

Use these rules consistently:

- Each active company report is edited in `Fabric/DevelopmentWorkspace/<Report Name>.*`; `Reports/Finance/Companies/<CODE>/` holds company `config/` and `overlays/` only.
- Live copies in `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` are updated only by `python3 Portfolio/scripts/fabric_release.py publish "<Report Name>" --apply` after the user names the report to publish.
- `PBIP` is the development source of truth.
- `PBIX` may be used as a review convenience, but not as the master.
- Finance packaging/review artifact policy is pending the explicit user decision; PBIP remains the development source of truth either way.

## Read Order

Recommended startup sequence:
1. `AGENTS.md`
2. `README.md`
3. `Module/docs/foundation.md`
4. `Module/docs/setup.md`
5. `Module/docs/structure.md`
6. `Module/docs/agent-manual.md`
7. `Module/Project Memory/PROJECT_DNA.md`
8. `Module/Project Memory/DECISIONS.md`
9. `Module/Project Memory/CURRENT_STATUS.md`
10. `Module/Project Memory/MODEL_NOTES.md`
11. `Module/Project Memory/NEXT_STEPS.md`
12. `Module/Project Memory/REFERENCE.md`

## Repository Structure

Top-level meaning inside this module:

- `Companies/` — company settings (`config/`, `overlays/`); report files live under `Fabric/`
- `Module/Design Benchmarks` — visual benchmark and design references
- `Module/Project Memory` — current truth, decisions, technical notes, and handoff continuity
- `Module/docs` — stable onboarding, workflow, and standards documentation
- `Module/scripts` — helper scripts used by the workflow

## Current Environment And Integrations

### Power BI

- Power BI Desktop with PBIP support is required for real validation.
- PBIP and TMDL files can be edited directly, but Desktop validation is still the strongest evidence of what truly renders.

### Git And GitHub

- Git remote:
  - `git@github.com:Baqer-Marayati/reporting-hub.git`
- **Git vs `gh`:** `git push` / `git pull` use your SSH key and can work even when the GitHub **CLI** token is stale. `gh issue`, `gh pr`, and some API features need a valid `gh` login.
- GitHub CLI binary is installed at:
  - `/opt/homebrew/bin/gh`
- **If `gh auth status` reports an invalid keyring token**, re-authenticate once on this Mac (interactive — run in Terminal.app, not inside a non-interactive agent):

```bash
gh auth login -h github.com
```

Follow the prompts (browser login is typical). Then verify:

```bash
gh auth status
```

To discard the broken stored account first (only if login keeps failing):

```bash
gh auth logout -h github.com -u Baqer-Marayati
gh auth login -h github.com
```

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

Current state:
- PBIP remains the development source of truth.
- Review happens in the Fabric Development Workspace after the change is pushed and synced.
- There is no required `package-report.sh` or `ready.zip` step for Finance.

### Skills

Project-specific Codex skills are not stored in this repository.
They live in the user skill directory and are part of the operating environment.

Currently referenced skill location:
- `~/.codex/skills`

Folders present on this Mac (Cursor does not auto-load these; use repo rules + `Project Memory`, or open `SKILL.md` when you need the full workflow text):
- `~/.codex/skills/powerbi-financial-report`
- `~/.codex/skills/powerbi-visual-repair`
- `~/.codex/skills/project-memory-updater`
- `~/.codex/skills/kpi-visual-consistency-agent`
- `~/.codex/skills/model-cleanup-stale-object-agent`

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
- Treat validation as part of done-ness; apply the documented package/review artifact policy once it is resolved.

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
