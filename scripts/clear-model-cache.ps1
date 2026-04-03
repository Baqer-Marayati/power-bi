param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Finance", "Sales", "Service", "Inventory", "DataExchange")]
    [string]$Domain,
    [string]$RepoRoot = $(Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

$relativeCache = @{
    Finance      = "Reports\Finance\Financial Report\Financial Report.SemanticModel\.pbi\cache.abf"
    Sales        = "Reports\Sales\Sales Report\Sales Report.SemanticModel\.pbi\cache.abf"
    Service      = "Reports\Service\Service Report\Service Report.SemanticModel\.pbi\cache.abf"
    Inventory    = "Reports\Inventory\Inventory Report\Inventory Report.SemanticModel\.pbi\cache.abf"
    DataExchange = "Reports\DataExchange\Data Exchange Report\Data Exchange Report.SemanticModel\.pbi\cache.abf"
}

$cache = Join-Path $RepoRoot $relativeCache[$Domain]
if (Test-Path -LiteralPath $cache) {
    Remove-Item -LiteralPath $cache -Force
    Write-Host "Removed: $cache"
} else {
    Write-Host "No cache.abf at $cache (already clean)."
}
