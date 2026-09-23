# Data Export Workspace Foundation

## Purpose

This is the fastest high-signal orientation file for the Data Export Workspace module.

## What This Module Should Contain

- the isolated PBIPs used for exports (currently parked under `Module/Archive/2026-09-24-parked-reports/`; a revived report is edited in `Fabric/DevelopmentWorkspace/`)
- report-specific docs
- report-specific memory
- report-specific exports, records, and archives

## What To Document Here

Use this file for:
- source-of-truth path
- benchmark choice
- environment/tooling assumptions specific to this report
- packaging or delivery rules specific to this report

Do not turn this file into a running changelog.

## Key Rule

- This module is for export operations only.
- The live Finance report in `Reports/Finance` must remain untouched by export-related experimentation.
