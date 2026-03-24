# Data Export Workspace Foundation

## Purpose

This is the fastest high-signal orientation file for the Data Export Workspace module.

## What This Module Should Contain

- the isolated PBIP used for exports: `Data Exchange Report/Data Exchange Report.pbip`
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
