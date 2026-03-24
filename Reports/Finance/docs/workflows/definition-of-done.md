# Definition Of Done (Finance PBIP)

## Purpose

Use this checklist before closing any Finance report task to keep quality and handoff consistent.

## Required Gates

1. Scope is explicit and limited to the requested change.
2. PBIP/TMDL edits are minimal and targeted.
3. Power BI Desktop validation is completed by the operator.
4. No known broken visuals or model load blockers were introduced.
5. `Project Memory` was updated when current truth, decisions, or model caveats changed.
6. Review package was rebuilt when report artifacts changed:
   - `Reports/Finance/scripts/package-report.sh`

## Semantic-Model Gate

For semantic model tasks:

- Prefer MCP-first workflow (`powerbi-modeling-mcp`) when available.
- If MCP is unavailable, use direct TMDL edits with explicit assumptions and stronger manual validation notes.
- Confirm affected measures/relationships/pages still behave as expected after reopen.

## Handoff Gate

Before handoff or PR:

- Summarize what changed and why.
- List residual risk and follow-up items.
- Include validation notes so another operator can reproduce confidence quickly.
