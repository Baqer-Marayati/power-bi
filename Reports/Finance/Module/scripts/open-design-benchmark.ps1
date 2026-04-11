# Opens the Finance design benchmark PBIP (Wiise Sample 2) in Power BI Desktop.
# Run from repo root: powershell -File Reports/Finance/Module/scripts/open-design-benchmark.ps1

$ErrorActionPreference = "Stop"
$pbip = Join-Path $PSScriptRoot "..\Design Benchmarks\Sample 2\Wiise Financial Dashboards-2.pbip"
$pbip = (Resolve-Path -LiteralPath $pbip).Path

if (!(Test-Path -LiteralPath $pbip)) {
    throw "PBIP not found: $pbip"
}

Write-Host "Opening: $pbip"

if ($IsWindows) {
    $pbiExe = "C:\Program Files\Microsoft Power BI Desktop\bin\PBIDesktop.exe"
    if (!(Test-Path -LiteralPath $pbiExe)) {
        throw "Power BI Desktop not found at $pbiExe"
    }
    Start-Process -FilePath $pbiExe -ArgumentList "`"$pbip`""
}
else {
    Start-Process -FilePath "open" -ArgumentList @("-a", "Microsoft Power BI Desktop", $pbip)
}
