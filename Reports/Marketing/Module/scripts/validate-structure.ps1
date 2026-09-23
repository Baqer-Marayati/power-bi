param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")).Path
)

$ErrorActionPreference = "Stop"
$runner = Join-Path $RepoRoot "Portfolio\scripts\validate-structure.ps1"
if (!(Test-Path $runner)) { throw "Portfolio structure validator not found: $runner" }

powershell -ExecutionPolicy Bypass -File $runner -RepoRoot $RepoRoot -Domains @("Marketing")
