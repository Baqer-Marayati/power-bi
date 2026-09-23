# PBIP Editing Workflow

## Purpose

Use this workflow when editing an active Finance company PBIP under `Fabric/DevelopmentWorkspace/`.

The goal is to keep PBIP work safe, structured, and easy to verify.

## Source Of Truth

- The editable masters are the company PBIPs:
  - `Fabric/DevelopmentWorkspace/Canon Financial Report.pbip`
  - `Fabric/DevelopmentWorkspace/Paper Financial Report.pbip`
- The PBIP project remains the development source of truth.
- `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/` are read-only live mirrors; do not edit them by hand.
- A `PBIX` may be created temporarily for review or transfer, but it must not replace the PBIP workflow.

## Standard Editing Flow

1. Pull the latest repository changes.
2. Read the current repo docs and relevant `Project Memory` files.
3. Confirm the exact page, visual, table, or measure you intend to change.
4. Inspect the PBIP JSON or TMDL before editing.
5. Make the smallest safe change that addresses the real issue.
6. Run `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`.
7. Update `Project Memory` if current truth changed.
8. Commit and push the change, then Sync and review in the Fabric Development Workspace.
9. Publish only when the user names the report: `python3 Portfolio/scripts/fabric_release.py publish "<Report Name>"` (dry run), then `--apply`, then commit and push the updated live mirror and `Fabric/RELEASES.md`.

## Before Editing

Check these first:
- `README.md`
- `docs/setup.md`
- `Project Memory/CURRENT_STATUS.md`
- `Project Memory/DECISIONS.md`
- `Project Memory/MODEL_NOTES.md`
- `Project Memory/NEXT_STEPS.md`

## Safe Working Rules

- Prefer focused edits over broad speculative changes.
- Inspect the target JSON or TMDL object before assuming the cause.
- Use report-side rewires when they are safer than semantic-model surgery.
- Avoid custom relationship changes unless the need is clear and low-risk.
- Preserve benchmark shell structure unless there is a strong reason to change it.

## Validation Checklist

Before closing the task:
- the PBIP opens cleanly
- the target page or model area renders as expected
- no new broken visuals were introduced
- IQD formatting remains consistent where relevant
- provisional logic is labeled clearly if it still exists

## Git Closing Step

Typical closeout:

```bash
git status
git add .
git commit -m "Describe the change"
git push
```
