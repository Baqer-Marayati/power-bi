# Removes VertiPaq import cache for Service semantic models in Fabric/DevelopmentWorkspace.
# Delegates to Portfolio/scripts/clear-model-cache.ps1

param(
    [ValidateSet("ALL", "CANON", "PAPERENTITY")]
    [string]$CompanyCode = "ALL",
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
)

$ErrorActionPreference = "Stop"
$runner = Join-Path $RepoRoot "Portfolio\scripts\clear-model-cache.ps1"
if (!(Test-Path -LiteralPath $runner)) { throw "Portfolio script not found: $runner" }

powershell -ExecutionPolicy Bypass -File $runner -Domain Service -CompanyCode $CompanyCode -RepoRoot $RepoRoot
