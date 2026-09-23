# Quickstart

## Open The Isolated PBIP

- The module is parked. The PBIPs are at `Reports/DataExchange/Module/Archive/2026-09-24-parked-reports/CANON/Canon Data Exchange Report/Canon Data Exchange Report.pbip` and the matching `PAPERENTITY/Paper Data Exchange Report/` folder.
- To use one again, copy it into `Fabric/DevelopmentWorkspace/`, open `Fabric/DevelopmentWorkspace/<Name>.pbip` in Power BI Desktop, and refresh the model.

## Export Destination

- Save exported CSV files to `Shared/Data Drops/incoming/<YYYY-MM-DD>/`.

## Validation

Run from repo root:

```bash
"Shared/Data Drops/scripts/validate-snapshot.sh" <YYYY-MM-DD>
```

If validation passes, the snapshot is ready for assistant analysis.
