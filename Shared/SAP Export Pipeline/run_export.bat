@echo off
setlocal

REM Run from repo root, or adjust ROOT below.
set ROOT=%~dp0..\..\..
pushd "%ROOT%"

if "%1"=="" (
  for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set SNAPSHOT_DATE=%%I
) else (
  set SNAPSHOT_DATE=%1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "Shared/SAP Export Pipeline/scripts/export_snapshots_odbc.ps1" -ConfigPath "Shared/SAP Export Pipeline/config.json" -SnapshotDate "%SNAPSHOT_DATE%"
if errorlevel 1 (
  echo Export failed.
  popd
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "Shared/SAP Export Pipeline/scripts/validate_snapshot_ps.ps1" -SnapshotDir "Shared/Data Drops/incoming/%SNAPSHOT_DATE%"
if errorlevel 1 (
  echo Validation failed.
  popd
  exit /b 1
)

echo Done. Snapshot date: %SNAPSHOT_DATE%
popd
exit /b 0
