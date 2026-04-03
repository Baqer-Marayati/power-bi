param(
    [string]$CompanyCode = "GLOBAL",
    [string]$ReportName = "Service Report",
    [string]$SourceDir = "",
    [string]$RepoRoot = "C:\Work\reporting-hub"
)

$ErrorActionPreference = "Stop"
$runner = Join-Path $RepoRoot "scripts\package-report.ps1"
if (!(Test-Path $runner)) { throw "Portfolio packager script not found: $runner" }
if ([string]::IsNullOrWhiteSpace($SourceDir)) {
    $SourceDir = Join-Path $RepoRoot "Reports\Service\Service Report"
}

powershell -ExecutionPolicy Bypass -File $runner `
    -Domain "Service" `
    -ReportName $ReportName `
    -SourceDir $SourceDir `
    -CompanyCode $CompanyCode `
    -RepoRoot $RepoRoot
