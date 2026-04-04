# Data Drops

This folder is the portfolio-level landing zone for exported Power BI snapshot files used for assistant-led analysis.

## Channels

- Local channel (this folder): fastest iteration for immediate analysis.
- GitHub channel: mirror each snapshot set to a private repository for traceable history.

## Recommended Layout

- `Shared/Data Drops/spec/`
  - Export specifications and data dictionary templates.
- `Shared/Data Drops/incoming/<YYYY-MM-DD>/`
  - Raw snapshot files for a given run date.
- `Shared/Data Drops/analysis/<YYYY-MM-DD>/`
  - Diagnostics output and recommendation reports produced from that snapshot.

## Fast Start (Automated Setup)

From repo root:

```bash
chmod +x "Shared/Data Drops/scripts/init-snapshot.sh" "Shared/Data Drops/scripts/validate-snapshot.sh"
"Shared/Data Drops/scripts/init-snapshot.sh" 2026-03-22
```

This creates:
- dated incoming folder
- `manifest.md`
- `data_dictionary.csv`
- starter CSV files with required headers

After replacing those CSVs with real Power BI exports, validate:

```bash
"Shared/Data Drops/scripts/validate-snapshot.sh" 2026-03-22
```

## GitHub Mirroring Pattern

- Use a private repository dedicated to exported snapshots.
- Keep this branch model:
  - `main`: approved snapshot history
  - `staging`: incoming snapshot review before promotion to `main`
- Commit cadence:
  - one commit per snapshot date
  - include both data files and manifest

## Required Files Per Snapshot

Inside `incoming/<YYYY-MM-DD>/`, include:
- dataset CSV files following naming convention
- `manifest.md`
- `data_dictionary.csv` (or a stable pointer to versioned dictionary)

## Safety Rules

- Assistant analysis is read-only on exported files.
- Do not place credentials in this folder.
- Keep repository and branch protections aligned with internal policy.

## Automated Export Option

If you want direct read-only extraction from SAP HANA without manual visual export, use:

- `Shared/SAP Export Pipeline/README.md`

That pipeline writes snapshots directly into this folder structure.
