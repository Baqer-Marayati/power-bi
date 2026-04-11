param(
    [string]$RepoRoot = "C:\Work\reporting-hub"
)

$ErrorActionPreference = "Stop"
$runner = Join-Path $RepoRoot "Portfolio\scripts\validate-structure.ps1"
if (!(Test-Path $runner)) { throw "Portfolio structure validator not found: $runner" }

powershell -ExecutionPolicy Bypass -File $runner -RepoRoot $RepoRoot -Domains @("Sales")
