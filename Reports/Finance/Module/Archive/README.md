# Finance Archive

This folder stores retired or superseded Finance-module material.

Use it for:
- old snapshots
- failed experiments worth preserving
- superseded benchmark variants
- retired exports that still need traceability

Do not leave archived material mixed into the active Finance working folders.

## Snapshot index

On 23 September 2026 the three full pre-restore PBIP copies were removed from the working tree. They are not active reports. Restore them from git history if a comparison is needed:

```bash
git checkout 2ba401a2 -- \
  "Reports/Finance/Module/Archive/Financial Report_pre-restore_20260325_224854" \
  "Reports/Finance/Module/Archive/Financial Report_pre-restore_20260326_174712" \
  "Reports/Finance/Module/Archive/Financial Report_pre-restore_20260326_181746"
```

Commit `2ba401a2` (23 Sep 2026) is the last commit that still contains all three folders. The snapshots themselves are the 25–26 March 2026 restore points:

| Snapshot | What it was |
| --- | --- |
| `Financial Report_pre-restore_20260325_224854/` | Full PBIP nested under `Financial Report/`. |
| `Financial Report_pre-restore_20260326_174712/` | Full PBIP with `.pbip`, `.Report/`, and `.SemanticModel/` at the snapshot root. |
| `Financial Report_pre-restore_20260326_181746/` | Same shape as the 174712 snapshot, taken later the same day. |

The live reports are `Reports/Finance/Companies/CANON/Canon Financial Report/` and `Reports/Finance/Companies/PAPERENTITY/Paper Financial Report/`.
