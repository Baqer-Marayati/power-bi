# Quickstart

## Open The Isolated PBIP

- Open `Reports/DataExchange/Data Exchange Report/Data Exchange Report.pbip` in Power BI Desktop.
- Refresh the model.

## Export Destination

- Save exported CSV files to `Shared/Data Drops/incoming/<YYYY-MM-DD>/`.

## Validation

Run from repo root:

```bash
"Shared/Data Drops/scripts/validate-snapshot.sh" <YYYY-MM-DD>
```

If validation passes, the snapshot is ready for assistant analysis.
