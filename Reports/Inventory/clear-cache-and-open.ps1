# Run this script before opening the Inventory report to ensure it starts blank.
# Double-click or: right-click → Run with PowerShell

$cache = Join-Path $PSScriptRoot "Inventory Report\Inventory Report.SemanticModel\.pbi\cache.abf"
$pbip  = Join-Path $PSScriptRoot "Inventory Report\Inventory Report.pbip"

if (Test-Path $cache) {
    Remove-Item $cache -Force
    Write-Host "Cache cleared." -ForegroundColor Green
} else {
    Write-Host "No cache found — already clean." -ForegroundColor Gray
}

Write-Host "Opening report..." -ForegroundColor Cyan
Start-Process $pbip
