param(
    [string]$CompanyCode = "GLOBAL",
    [string]$ReportName = "Inventory Report",
    [string]$SourceDir = "",
    [string]$RepoRoot = "C:\Work\reporting-hub"
)

$ErrorActionPreference = "Stop"
$runner = Join-Path $RepoRoot "scripts\package-report.ps1"
if (!(Test-Path -LiteralPath $runner)) { throw "Portfolio packager script not found: $runner" }
if ([string]::IsNullOrWhiteSpace($SourceDir)) {
    $SourceDir = Join-Path $RepoRoot "Reports\Inventory\Inventory Report"
}

powershell -ExecutionPolicy Bypass -File $runner `
    -Domain "Inventory" `
    -ReportName $ReportName `
    -SourceDir $SourceDir `
    -CompanyCode $CompanyCode `
    -RepoRoot $RepoRoot
