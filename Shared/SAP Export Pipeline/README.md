# SAP Export Pipeline (Read-Only)

This pipeline extracts read-only SAP Business One data and writes snapshot files for assistant analysis.

## Scope

- Source: SAP Business One on HANA (recommended via ODBC DSN)
- Access: read-only queries only
- Companies: `ALJAZEERA`, `CANON`, `PAPERENTITY`
- Excluded: `CANON_TEST...`
- Output lane: `Shared/Data Drops/incoming/<YYYY-MM-DD>/`
- Preferred execution path: Windows ODBC script (outputs CSV automatically)

## Datasets Exported

- `bp_master`
- `item_master`
- `ar_open_items`
- `ap_open_items`
- `journal_entries`

## Security

- No writes to SAP.
- Credentials are read from environment variables.
- Do not commit credentials into config files.

## Quick Start (Windows, minimal manual)

1. Copy config template:

```bat
copy "Shared\SAP Export Pipeline\config.template.json" "Shared\SAP Export Pipeline\config.json"
```

2. Update `Shared\SAP Export Pipeline\config.json`:
- `odbc.dsn` should match your working DSN (often `HANA_B1`)
- keep companies as configured

3. Run once from repo root (`C:\Work\reporting-hub`):

```bat
Shared\SAP Export Pipeline\run_export.bat 2026-03-22
```

4. Credentials behavior:
- If `SAP_HANA_USER` and `SAP_HANA_PASSWORD` env vars are set, script uses them.
- If not set, script tries DSN-saved credentials (`DSN=<your dsn>` only).
- You can set env vars manually when needed.

## Optional: direct PowerShell commands

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "Shared/SAP Export Pipeline/scripts/export_snapshots_odbc.ps1" -ConfigPath "Shared/SAP Export Pipeline/config.json" -SnapshotDate "2026-03-22"
powershell -NoProfile -ExecutionPolicy Bypass -File "Shared/SAP Export Pipeline/scripts/validate_snapshot_ps.ps1" -SnapshotDir "Shared/Data Drops/incoming/2026-03-22"
```

## Notes

- This path avoids Python/HDB client auth troubleshooting in Git Bash.
- Output file names follow:
  - `<dataset>__<YYYY-MM-DD>__v1.csv`
- If you still want the Python/parquet route, existing scripts remain under:
  - `scripts/export_snapshots.py`
  - `scripts/validate_snapshot.py`
