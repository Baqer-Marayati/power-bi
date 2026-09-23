param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Finance", "Sales", "Service", "Inventory")]
    [string]$Domain,
    [ValidateSet("ALL", "CANON", "PAPERENTITY")]
    [string]$CompanyCode = "ALL",
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

function Join-RepoPath {
    param([Parameter(Mandatory = $true)][string]$RelativePath)
    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        return [System.IO.Path]::GetFullPath($RelativePath)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $RelativePath))
}

function Get-PbipEntriesFromManifest {
    param([Parameter(Mandatory = $true)][string]$DomainName)

    $manifestPath = Join-RepoPath "Reports/$DomainName/module.manifest.json"
    if (!(Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        return @()
    }

    $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return @($manifest.companies | ForEach-Object {
        [pscustomobject]@{
            CompanyCode = $_.code
            PbipPath = $_.pbipPath
        }
    })
}

function Get-PbipEntriesFromFallback {
    param([Parameter(Mandatory = $true)][string]$DomainName)

    $dev = "Fabric/DevelopmentWorkspace"
    $fallback = @{
        Finance = @(
            @{ CompanyCode = "CANON"; PbipPath = "$dev/Canon Financial Report.pbip" },
            @{ CompanyCode = "PAPERENTITY"; PbipPath = "$dev/Paper Financial Report.pbip" }
        )
        Sales = @(
            @{ CompanyCode = "CANON"; PbipPath = "$dev/Canon Sales Report.pbip" }
        )
        Service = @(
            @{ CompanyCode = "CANON"; PbipPath = "$dev/Canon Service Report.pbip" }
        )
        Inventory = @(
            @{ CompanyCode = "CANON"; PbipPath = "$dev/Canon Inventory Report.pbip" },
            @{ CompanyCode = "PAPERENTITY"; PbipPath = "$dev/Paper Inventory Report.pbip" }
        )
    }

    return @($fallback[$DomainName] | ForEach-Object { [pscustomobject]$_ })
}

function Resolve-SemanticModelFolder {
    param([Parameter(Mandatory = $true)][string]$PbipPath)

    $pbipFull = Join-RepoPath $PbipPath
    if (!(Test-Path -LiteralPath $pbipFull -PathType Leaf)) {
        throw "PBIP not found: $PbipPath"
    }

    $pbipJson = Get-Content -LiteralPath $pbipFull -Raw -Encoding UTF8 | ConvertFrom-Json
    $reportArtifact = @($pbipJson.artifacts | Where-Object { $_.report -and $_.report.path } | Select-Object -First 1)
    if ($reportArtifact.Count -eq 0) {
        throw "No report artifact found in PBIP: $PbipPath"
    }

    $pbipParent = Split-Path -Parent $pbipFull
    $reportFolder = [System.IO.Path]::GetFullPath((Join-Path $pbipParent $reportArtifact[0].report.path))
    $pbirPath = Join-Path $reportFolder "definition.pbir"
    if (Test-Path -LiteralPath $pbirPath -PathType Leaf) {
        $pbirJson = Get-Content -LiteralPath $pbirPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $datasetPath = $pbirJson.datasetReference.byPath.path
        if (![string]::IsNullOrWhiteSpace($datasetPath)) {
            return [System.IO.Path]::GetFullPath((Join-Path $reportFolder $datasetPath))
        }
    }

    $pbipStem = [System.IO.Path]::GetFileNameWithoutExtension($pbipFull)
    return Join-Path $pbipParent "$pbipStem.SemanticModel"
}

$entries = @(Get-PbipEntriesFromManifest -DomainName $Domain)
if ($entries.Count -eq 0) {
    $entries = @(Get-PbipEntriesFromFallback -DomainName $Domain)
}

if ($CompanyCode -ne "ALL") {
    $entries = @($entries | Where-Object { $_.CompanyCode -eq $CompanyCode })
}

if ($entries.Count -eq 0) {
    throw "No PBIP entries found for Domain=$Domain CompanyCode=$CompanyCode"
}

foreach ($entry in $entries) {
    $semanticModelFolder = Resolve-SemanticModelFolder -PbipPath $entry.PbipPath
    $cache = Join-Path $semanticModelFolder ".pbi\cache.abf"
    $cacheForCheck = $cache -replace '/', '\'

    if ($cacheForCheck -notlike "*\.SemanticModel\.pbi\cache.abf") {
        throw "Refusing to remove unexpected cache path: $cache"
    }

    if (Test-Path -LiteralPath $cache -PathType Leaf) {
        Remove-Item -LiteralPath $cache -Force
        Write-Host "Removed $Domain/$($entry.CompanyCode): $cache"
    } else {
        Write-Host "No cache.abf for $Domain/$($entry.CompanyCode) at $cache (already clean)."
    }
}
