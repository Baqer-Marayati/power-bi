# Opens the Data Exchange PBIP in Power BI Desktop (same idea as Inventory clear-cache-and-open).
# Run from repo root or this folder: powershell -File Reports/DataExchange/scripts/open-report.ps1

$ErrorActionPreference = "Stop"
$pbip = Join-Path $PSScriptRoot "..\Data Exchange Report\Data Exchange Report.pbip"
$pbip = (Resolve-Path -LiteralPath $pbip).Path

if (!(Test-Path -LiteralPath $pbip)) {
    throw "PBIP not found: $pbip"
}

$pbiExe = "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
if (!(Test-Path -LiteralPath $pbiExe)) {
    throw "Power BI Desktop not found at $pbiExe"
}

Write-Host "Opening: $pbip"
Start-Process -FilePath $pbiExe -ArgumentList "`"$pbip`""
