# Removes VertiPaq import cache for the Finance PBIP semantic model.
# Delegates to portfolio scripts/clear-model-cache.ps1

param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..\..")).Path
)

$ErrorActionPreference = "Stop"
$runner = Join-Path $RepoRoot "scripts\clear-model-cache.ps1"
if (!(Test-Path -LiteralPath $runner)) { throw "Portfolio script not found: $runner" }

powershell -ExecutionPolicy Bypass -File $runner -Domain Finance -RepoRoot $RepoRoot
