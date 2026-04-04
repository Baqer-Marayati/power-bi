param(
    [string]$RepoRoot = "C:\Work\reporting-hub"
)

$ErrorActionPreference = "Stop"
$runner = Join-Path $RepoRoot "scripts\clear-model-cache.ps1"
if (!(Test-Path -LiteralPath $runner)) { throw "Portfolio script not found: $runner" }

powershell -ExecutionPolicy Bypass -File $runner -Domain DataExchange -RepoRoot $RepoRoot
