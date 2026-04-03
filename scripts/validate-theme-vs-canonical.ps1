param(
    [switch]$All,
    [ValidateSet("Finance", "Sales", "Service", "DataExchange")]
    [string]$Domain,
    [string]$RepoRoot = $(Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"
$canonical = Join-Path $RepoRoot "Shared\Themes\Custom_Theme49412231581938193.json"
if (!(Test-Path -LiteralPath $canonical)) {
    throw "Canonical theme missing: $canonical"
}

function Get-Sha256([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

$canonicalHash = Get-Sha256 $canonical
Write-Host "Canonical SHA256: $canonicalHash" -ForegroundColor Cyan
Write-Host "  $canonical"
Write-Host ""

$themeName = "Custom_Theme49412231581938193.json"
$paths = @()

# Only active PBIP report roots (excludes Archive/, Exports/, Design Benchmarks/, etc.)
$activeRelative = @{
    Finance      = "Reports\Finance\Financial Report\Financial Report.Report\StaticResources\RegisteredResources\$themeName"
    Sales        = "Reports\Sales\Sales Report\Sales Report.Report\StaticResources\RegisteredResources\$themeName"
    Service      = "Reports\Service\Service Report\Service Report.Report\StaticResources\RegisteredResources\$themeName"
    DataExchange = "Reports\DataExchange\Data Exchange Report\Data Exchange Report.Report\StaticResources\RegisteredResources\$themeName"
}

if ($All) {
    $paths = foreach ($rel in $activeRelative.Values) {
        $p = Join-Path $RepoRoot $rel
        if (Test-Path -LiteralPath $p) { $p }
    }
} elseif ($Domain) {
    $p = Join-Path $RepoRoot $activeRelative[$Domain]
    if (Test-Path -LiteralPath $p) { $paths = @($p) }
} else {
    throw "Specify -All or -Domain (Finance|Sales|Service|DataExchange)."
}

$exit = 0
foreach ($p in $paths) {
    if (!(Test-Path -LiteralPath $p)) {
        Write-Host "[MISS] $p" -ForegroundColor Yellow
        $exit = 1
        continue
    }
    $h = Get-Sha256 $p
    if ($h -eq $canonicalHash) {
        Write-Host "[OK]   $p" -ForegroundColor Green
    } else {
        Write-Host "[DIFF] $p" -ForegroundColor Yellow
        Write-Host "       module SHA256: $h"
        $exit = 2
    }
}

if ($paths.Count -eq 0) {
    Write-Host "No registered theme files found for the requested scope."
}

exit $exit
