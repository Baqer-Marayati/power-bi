param(
    [string]$RepoRoot = "C:\Work\reporting-hub"
)

$ErrorActionPreference = "Stop"
$runner = Join-Path $RepoRoot "scripts\validate-structure.ps1"
if (!(Test-Path -LiteralPath $runner)) { throw "Portfolio structure validator not found: $runner" }

powershell -ExecutionPolicy Bypass -File $runner -RepoRoot $RepoRoot -Domains @("Inventory")
