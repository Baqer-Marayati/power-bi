param(
    [string]$RepoRoot = $(Split-Path -Parent $PSScriptRoot),
    [string[]]$Domains = @("Finance", "HR", "Sales", "Service", "Marketing", "Inventory")
)

$ErrorActionPreference = "Stop"

$requiredPaths = @(
    "README.md",
    "AGENTS.md",
    "docs",
    "Project Memory",
    "Core",
    "Companies",
    "scripts",
    "Exports",
    "Records",
    "Archive"
)

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

foreach ($domain in $Domains) {
    $domainRoot = Join-Path (Join-Path $RepoRoot "Reports") $domain
    if (!(Test-Path $domainRoot)) {
        $errors.Add("Missing domain folder: Reports/$domain")
        continue
    }

    foreach ($rel in $requiredPaths) {
        $path = Join-Path $domainRoot $rel
        if (!(Test-Path $path)) {
            $errors.Add("Missing required path: Reports/$domain/$rel")
        }
    }

    $recordsRoot = Join-Path $domainRoot "Records"
    if (Test-Path $recordsRoot) {
        $recordDirNames = @(Get-ChildItem -Path $recordsRoot -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
        $hasLowerScreenshots = $recordDirNames | Where-Object { $_ -ceq "screenshots" }
        $hasUpperScreenshots = $recordDirNames | Where-Object { $_ -ceq "Screenshots" }

        if ($hasLowerScreenshots -and $hasUpperScreenshots) {
            $warnings.Add("Casing drift in ${domain}: both Records/screenshots and Records/Screenshots exist.")
        } elseif ($hasUpperScreenshots -and -not $hasLowerScreenshots) {
            $warnings.Add("Non-canonical casing in ${domain}: use Records/screenshots (lowercase) instead of Records/Screenshots.")
        }
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "Warnings:"
    $warnings | ForEach-Object { Write-Host " - $_" }
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Structure validation FAILED:"
    $errors | ForEach-Object { Write-Host " - $_" }
    exit 1
}

Write-Host "Structure validation passed for domains: $($Domains -join ', ')"
