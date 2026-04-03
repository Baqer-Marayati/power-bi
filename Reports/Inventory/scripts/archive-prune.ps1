param(
    [int]$Keep = 20,
    [string]$RepoRoot = "C:\Work\reporting-hub"
)

$ErrorActionPreference = "Stop"
$runner = Join-Path $RepoRoot "scripts\archive-prune.ps1"
$archiveDir = Join-Path $RepoRoot "Reports\Inventory\Exports\Server Packages\archive"
if (!(Test-Path -LiteralPath $runner)) { throw "Portfolio archive-prune script not found: $runner" }

powershell -ExecutionPolicy Bypass -File $runner -ArchiveDir $archiveDir -Keep $Keep
