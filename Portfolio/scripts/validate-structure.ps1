param(
    [string]$RepoRoot = $(Split-Path -Parent $PSScriptRoot),
    [string[]]$Domains = @("Finance", "DataExchange", "HR", "Sales", "Service", "Marketing", "Inventory")
)

$ErrorActionPreference = "Stop"

$requiredModulePaths = @(
    "README.md",
    "AGENTS.md",
    "Companies",
    "Module",
    "Module\docs",
    "Module\Project Memory",
    "Module\Core",
    "Module\scripts",
    "Module\Records",
    "Module\Archive"
)

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

foreach ($domain in $Domains) {
    $domainRoot = Join-Path (Join-Path $RepoRoot "Reports") $domain
    if (!(Test-Path $domainRoot)) {
        $errors.Add("Missing domain folder: Reports/$domain")
        continue
    }

    foreach ($rel in $requiredModulePaths) {
        $path = Join-Path $domainRoot $rel
        if (!(Test-Path $path)) {
            $errors.Add("Missing required path: Reports/$domain/$rel")
        }
    }

    $recordsRoot = Join-Path $domainRoot "Module\Records"
    if (Test-Path $recordsRoot) {
        $recordDirs = @(Get-ChildItem -Path $recordsRoot -Directory -ErrorAction SilentlyContinue)
        $recordDirNames = @($recordDirs | Select-Object -ExpandProperty Name)
        $matchingScreenshots = @($recordDirs | Where-Object { $_.Name -ieq "screenshots" })
        $hasLowerScreenshots = $recordDirNames | Where-Object { $_ -ceq "screenshots" }
        $hasUpperScreenshots = $recordDirNames | Where-Object { $_ -ceq "Screenshots" }

        if ($hasLowerScreenshots -and $hasUpperScreenshots) {
            $warnings.Add("Casing drift in ${domain}: both Module/Records/screenshots and Module/Records/Screenshots exist.")
        } elseif ($hasUpperScreenshots -and -not $hasLowerScreenshots) {
            $onlyGitkeepPlaceholder = $false
            if ($matchingScreenshots.Count -eq 1) {
                $contents = @(Get-ChildItem -Path $matchingScreenshots[0].FullName -Force -ErrorAction SilentlyContinue)
                $onlyGitkeepPlaceholder = (
                    $contents.Count -eq 1 -and
                    $contents[0].Name -eq ".gitkeep"
                )
            }

            if (-not $onlyGitkeepPlaceholder) {
                $warnings.Add("Non-canonical casing in ${domain}: use Module/Records/screenshots (lowercase) instead of Module/Records/Screenshots.")
            }
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
