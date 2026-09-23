param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
    [string[]]$Domains = @("Finance", "DataExchange", "HR", "Sales", "Service", "Marketing", "Inventory")
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

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
$validatedPbips = @{}

function Join-RepoPath {
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        return [System.IO.Path]::GetFullPath($RelativePath)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $RelativePath))
}

function Get-RepoRelative {
    param([Parameter(Mandatory = $true)][string]$FullPath)
    $full = [System.IO.Path]::GetFullPath($FullPath)
    $root = [System.IO.Path]::GetFullPath($RepoRoot).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar

    if ($full.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $full.Substring($root.Length).Replace([System.IO.Path]::DirectorySeparatorChar, "/")
    }
    return $full
}

function Read-JsonFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Label
    )

    try {
        return Get-Content -LiteralPath $Path -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        $errors.Add("Invalid JSON in ${Label}: $(Get-RepoRelative $Path) - $($_.Exception.Message)")
        return $null
    }
}

function Test-PbipProject {
    param(
        [Parameter(Mandatory = $true)][string]$PbipRelativePath,
        [string]$Source = "active PBIP",
        [object[]]$ExpectedPages = @()
    )

    $pbipFull = Join-RepoPath $PbipRelativePath
    $pbipKey = [System.IO.Path]::GetFullPath($pbipFull).ToLowerInvariant()
    if ($validatedPbips.ContainsKey($pbipKey)) {
        return
    }
    $validatedPbips[$pbipKey] = $true

    if (!(Test-Path -LiteralPath $pbipFull -PathType Leaf)) {
        $errors.Add("Missing ${Source}: $PbipRelativePath")
        return
    }

    $pbipJson = Read-JsonFile -Path $pbipFull -Label "$Source .pbip"
    if ($null -eq $pbipJson) { return }

    $pbipParent = Split-Path -Parent $pbipFull
    $reportArtifacts = @($pbipJson.artifacts | Where-Object { $_.report -and $_.report.path })
    if ($reportArtifacts.Count -ne 1) {
        $errors.Add("Expected exactly one report artifact in ${Source}: $PbipRelativePath")
        return
    }

    $reportFolder = [System.IO.Path]::GetFullPath((Join-Path $pbipParent $reportArtifacts[0].report.path))
    if (!(Test-Path -LiteralPath $reportFolder -PathType Container)) {
        $errors.Add("Missing .Report folder referenced by ${PbipRelativePath}: $(Get-RepoRelative $reportFolder)")
        return
    }

    $pbirPath = Join-Path $reportFolder "definition.pbir"
    if (!(Test-Path -LiteralPath $pbirPath -PathType Leaf)) {
        $errors.Add("Missing definition.pbir for ${PbipRelativePath}: $(Get-RepoRelative $pbirPath)")
        return
    }

    $pbirJson = Read-JsonFile -Path $pbirPath -Label "$Source definition.pbir"
    if ($null -eq $pbirJson) { return }

    $datasetPath = $pbirJson.datasetReference.byPath.path
    if ([string]::IsNullOrWhiteSpace($datasetPath)) {
        $errors.Add("definition.pbir has no datasetReference.byPath.path for ${PbipRelativePath}")
    } else {
        $semanticModelFolder = [System.IO.Path]::GetFullPath((Join-Path $reportFolder $datasetPath))
        if (!(Test-Path -LiteralPath $semanticModelFolder -PathType Container)) {
            $errors.Add("Missing .SemanticModel folder referenced by definition.pbir for ${PbipRelativePath}: $(Get-RepoRelative $semanticModelFolder)")
        }
    }

    $pagesRoot = Join-Path $reportFolder "definition\pages"
    $pagesJsonPath = Join-Path $pagesRoot "pages.json"
    if (!(Test-Path -LiteralPath $pagesJsonPath -PathType Leaf)) {
        $errors.Add("Missing pages.json for ${PbipRelativePath}: $(Get-RepoRelative $pagesJsonPath)")
        return
    }

    $pagesMeta = Read-JsonFile -Path $pagesJsonPath -Label "$Source pages.json"
    if ($null -eq $pagesMeta) { return }

    $pageOrder = @($pagesMeta.pageOrder)
    if ($pageOrder.Count -eq 0) {
        $errors.Add("pages.json has empty pageOrder for ${PbipRelativePath}")
    }

    if ($pagesMeta.activePageName -and ($pageOrder -notcontains $pagesMeta.activePageName)) {
        $errors.Add("pages.json activePageName is not in pageOrder for ${PbipRelativePath}: $($pagesMeta.activePageName)")
    }

    $pageNamesById = @{}
    foreach ($pageId in $pageOrder) {
        $pageFolder = Join-Path $pagesRoot $pageId
        $pageJsonPath = Join-Path $pageFolder "page.json"
        if (!(Test-Path -LiteralPath $pageFolder -PathType Container)) {
            $errors.Add("pageOrder references missing page folder for ${PbipRelativePath}: $pageId")
            continue
        }
        if (!(Test-Path -LiteralPath $pageJsonPath -PathType Leaf)) {
            $errors.Add("Missing page.json for ${PbipRelativePath}: $pageId")
            continue
        }
        $pageJson = Read-JsonFile -Path $pageJsonPath -Label "$Source page.json"
        if ($null -ne $pageJson) {
            $pageNamesById[$pageId] = $pageJson.displayName
        }
    }

    if ($ExpectedPages.Count -gt 0) {
        $expectedIds = @($ExpectedPages | ForEach-Object { $_.id })
        if (($expectedIds -join "|") -ne ($pageOrder -join "|")) {
            $errors.Add("Expected page order mismatch for ${PbipRelativePath}")
        }
        foreach ($expected in $ExpectedPages) {
            if ($pageNamesById.ContainsKey($expected.id) -and $pageNamesById[$expected.id] -ne $expected.displayName) {
                $errors.Add("Expected page displayName mismatch for ${PbipRelativePath}: $($expected.id) expected '$($expected.displayName)' got '$($pageNamesById[$expected.id])'")
            }
        }
    }

    Get-ChildItem -LiteralPath (Join-Path $reportFolder "definition") -Recurse -File -Filter "*.json" -ErrorAction SilentlyContinue |
        ForEach-Object { Read-JsonFile -Path $_.FullName -Label "$Source report definition JSON" | Out-Null }
}

function Test-ModuleManifest {
    param([Parameter(Mandatory = $true)][string]$Domain)

    $manifestRel = "Reports/$Domain/module.manifest.json"
    $manifestPath = Join-RepoPath $manifestRel
    if (!(Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        return
    }

    $manifest = Read-JsonFile -Path $manifestPath -Label "$Domain module manifest"
    if ($null -eq $manifest) { return }

    $companies = @($manifest.companies)
    if ($companies.Count -eq 0) {
        if ($manifest.module.status -ne "scaffolded") {
            $errors.Add("Module manifest has no companies: $manifestRel")
        }
        return
    }

    foreach ($company in $companies) {
        if ([string]::IsNullOrWhiteSpace($company.code)) {
            $errors.Add("Module manifest company missing code: $manifestRel")
        }
        if ([string]::IsNullOrWhiteSpace($company.pbipPath)) {
            $errors.Add("Module manifest company missing pbipPath: $manifestRel")
            continue
        }

        Test-PbipProject -PbipRelativePath $company.pbipPath -Source "$Domain manifest $($company.code)" -ExpectedPages @($manifest.expectedPages)

        foreach ($pathProperty in @("reportFolder", "semanticModelFolder", "configPath")) {
            $manifestPathValue = $company.$pathProperty
            if (![string]::IsNullOrWhiteSpace($manifestPathValue)) {
                $resolved = Join-RepoPath $manifestPathValue
                if (!(Test-Path -LiteralPath $resolved)) {
                    $errors.Add("Module manifest $pathProperty does not exist for $Domain/$($company.code): $manifestPathValue")
                }
            }
        }
    }

    foreach ($protectedPath in @($manifest.protectedPaths)) {
        if (![string]::IsNullOrWhiteSpace($protectedPath)) {
            $resolvedProtectedPath = Join-RepoPath $protectedPath
            if (!(Test-Path -LiteralPath $resolvedProtectedPath)) {
                $errors.Add("Protected path in module manifest does not exist: $protectedPath")
            }
        }
    }
}

foreach ($domain in $Domains) {
    $domainRoot = Join-RepoPath "Reports/$domain"
    if (!(Test-Path -LiteralPath $domainRoot -PathType Container)) {
        $errors.Add("Missing domain folder: Reports/$domain")
        continue
    }

    foreach ($rel in $requiredModulePaths) {
        $path = Join-Path $domainRoot $rel
        if (!(Test-Path -LiteralPath $path)) {
            $errors.Add("Missing required path: Reports/$domain/$rel")
        }
    }

    $recordsRoot = Join-Path $domainRoot "Module\Records"
    if (Test-Path -LiteralPath $recordsRoot -PathType Container) {
        $recordDirs = @(Get-ChildItem -LiteralPath $recordsRoot -Directory -ErrorAction SilentlyContinue)
        $recordDirNames = @($recordDirs | Select-Object -ExpandProperty Name)
        $hasLowerScreenshots = $recordDirNames | Where-Object { $_ -ceq "screenshots" }
        $hasUpperScreenshots = $recordDirNames | Where-Object { $_ -ceq "Screenshots" }

        if ($hasLowerScreenshots -and $hasUpperScreenshots) {
            $warnings.Add("Casing drift in ${domain}: both Module/Records/screenshots and Module/Records/Screenshots exist.")
        } elseif ($hasUpperScreenshots -and -not $hasLowerScreenshots) {
            $warnings.Add("Non-canonical casing in ${domain}: use Module/Records/screenshots (lowercase) instead of Module/Records/Screenshots.")
        }
    }

    Test-ModuleManifest -Domain $domain
}

$activeFocusPath = Join-RepoPath "Portfolio/Memory/ACTIVE_FOCUS.md"
if (Test-Path -LiteralPath $activeFocusPath -PathType Leaf) {
    $activeFocusText = Get-Content -LiteralPath $activeFocusPath -Raw -Encoding UTF8
    $pbipMatches = [regex]::Matches($activeFocusText, '`([^`]+\.pbip)`')
    foreach ($match in $pbipMatches) {
        Test-PbipProject -PbipRelativePath $match.Groups[1].Value -Source "ACTIVE_FOCUS PBIP"
    }
} else {
    $errors.Add("Missing active focus file: Portfolio/Memory/ACTIVE_FOCUS.md")
}

$workspacesPath = Join-RepoPath "Fabric/workspaces.json"
if (Test-Path -LiteralPath $workspacesPath -PathType Leaf) {
    $workspaces = Read-JsonFile -Path $workspacesPath -Label "Fabric workspace manifest"
    if ($null -ne $workspaces) {
        $devFolder = $workspaces.development.folder
        $listed = @{}
        foreach ($property in $workspaces.reports.PSObject.Properties) {
            $name = $property.Name
            $entry = $property.Value
            $listed[$name] = $true
            Test-PbipProject -PbipRelativePath "$devFolder/$name.pbip" -Source "Development Workspace PBIP"
            $liveTarget = $workspaces.live.($entry.live)
            if ($null -eq $liveTarget) {
                $errors.Add("Fabric/workspaces.json: '$name' points at unknown live workspace '$($entry.live)'")
                continue
            }
            if ($entry.liveReportId) {
                Test-PbipProject -PbipRelativePath "$($liveTarget.folder)/$name.pbip" -Source "live mirror PBIP"
            }
        }
        Get-ChildItem -LiteralPath (Join-RepoPath $devFolder) -Filter "*.pbip" -File -ErrorAction SilentlyContinue | ForEach-Object {
            $stem = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
            if (-not $listed.ContainsKey($stem)) {
                $warnings.Add("$devFolder/$($_.Name) is not listed in Fabric/workspaces.json, so it cannot be published")
            }
        }
    }
} else {
    $errors.Add("Missing Fabric workspace manifest: Fabric/workspaces.json")
}

foreach ($domain in $Domains) {
    $companiesRoot = Join-RepoPath "Reports/$domain/Companies"
    if (Test-Path -LiteralPath $companiesRoot -PathType Container) {
        Get-ChildItem -LiteralPath $companiesRoot -Recurse -Filter "*.pbip" -File -ErrorAction SilentlyContinue | ForEach-Object {
            $errors.Add("Report copy under Companies (reports live in Fabric/ only): $(Get-RepoRelative $_.FullName)")
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
Write-Host "Validated PBIP projects: $($validatedPbips.Count)"
