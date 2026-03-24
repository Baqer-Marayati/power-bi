# Next Actions (Only Manual Part)

Everything is prepared. The only remaining step is to replace header-only CSV files with real exports from Power BI.

## Replace These Files

- `bp_master__2026-03-22__v1.csv`
- `item_master__2026-03-22__v1.csv`
- `ar_open_items__2026-03-22__v1.csv`
- `ap_open_items__2026-03-22__v1.csv`
- `journal_entries__2026-03-22__v1.csv`

## Rules

- Keep exactly the same file names.
- Keep header columns unchanged.
- Save as UTF-8 CSV.
- Keep date formats as ISO where possible.

## Validate After Export

From repo root:

```bash
"Shared/Data Drops/scripts/validate-snapshot.sh" 2026-03-22
```

When validation passes, tell the assistant: `snapshot 2026-03-22 ready`.
