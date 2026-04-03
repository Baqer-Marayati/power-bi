param(
    [string]$RepoRoot = "C:\Work\reporting-hub"
)

$ErrorActionPreference = "Stop"

$sourcePbip = Join-Path $RepoRoot "Reports\Finance\Financial Report\Financial Report.pbip"
$modelCache = Join-Path $RepoRoot "Reports\Finance\Financial Report\Financial Report.SemanticModel\.pbi\cache.abf"
$latestZip = Join-Path $RepoRoot "Reports\Finance\Exports\Server Packages\latest\Financial Report - ready.zip"
$legacyZip = Join-Path $RepoRoot "Reports\Finance\Exports\Server Packages\Financial Report - ready.zip"
$extractedLatestPbip = Join-Path $RepoRoot "Reports\Finance\Exports\Server Packages\latest\Financial Report - ready\Financial Report\Financial Report.pbip"
$reportPagesRoot = Join-Path $RepoRoot "Reports\Finance\Financial Report\Financial Report.Report\definition\pages"
$dimDateTmdl = Join-Path $RepoRoot "Reports\Finance\Financial Report\Financial Report.SemanticModel\definition\tables\Dim_Date.tmdl"

$hasErrors = $false

function Write-Ok([string]$Message) {
    Write-Host "[OK]  $Message" -ForegroundColor Green
}

function Write-Warn([string]$Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Err([string]$Message) {
    Write-Host "[ERR] $Message" -ForegroundColor Red
    $script:hasErrors = $true
}

Write-Host "Finance artifact validation" -ForegroundColor Cyan
Write-Host "RepoRoot: $RepoRoot"
Write-Host ""

if (Test-Path -LiteralPath $sourcePbip) {
    Write-Ok "Canonical source PBIP exists: $sourcePbip"
} else {
    Write-Err "Canonical source PBIP missing: $sourcePbip"
}

if (Test-Path -LiteralPath $modelCache) {
    $cacheItem = Get-Item -LiteralPath $modelCache
    Write-Warn ("Model cache exists ({0} bytes): {1}" -f $cacheItem.Length, $modelCache)
    Write-Warn "User preference is blank-on-open behavior. Remove cache or package without -KeepModelCache."
} else {
    Write-Ok "Model cache is absent. Report will open blank until refresh (expected behavior)."
}

if (Test-Path -LiteralPath $latestZip) {
    $item = Get-Item -LiteralPath $latestZip
    Write-Ok ("Latest review zip: {0} ({1} bytes, {2})" -f $item.FullName, $item.Length, $item.LastWriteTime)
} else {
    Write-Err "Missing latest review zip: $latestZip"
}

if (Test-Path -LiteralPath $legacyZip) {
    $item = Get-Item -LiteralPath $legacyZip
    Write-Ok ("Legacy mirror zip: {0} ({1} bytes, {2})" -f $item.FullName, $item.Length, $item.LastWriteTime)
} else {
    Write-Warn "Legacy mirror zip is missing: $legacyZip"
}

if (Test-Path -LiteralPath $extractedLatestPbip) {
    Write-Warn "Extracted PBIP exists under latest package path. Do not edit/open this copy for development."
    Write-Warn "Use source: $sourcePbip"
} else {
    Write-Ok "No extracted PBIP found under latest package path."
}

if (Test-Path -LiteralPath $dimDateTmdl) {
    $dimDateText = Get-Content -LiteralPath $dimDateTmdl -Raw
    if ($dimDateText -match "DATE\s*\(\s*2026\s*,\s*1\s*,\s*1\s*\)") {
        Write-Ok "Dim_Date lower bound is 2026 (expected)."
    } else {
        Write-Warn "Dim_Date lower bound is not pinned to 2026."
    }
} else {
    Write-Err "Dim_Date definition not found: $dimDateTmdl"
}

$corePages = @(
    "8c1c6f95c0c648c38b4a",
    "15cbf3db06debabb9b66",
    "9a4d1c7b5e3f8a2c6d11",
    "4b2e9d0a7c6f4e1b8a2d",
    "5e7c9a1d4b3f6e8c2a10"
)

foreach ($pageId in $corePages) {
    $pageVisuals = Join-Path $reportPagesRoot "$pageId\visuals"
    $quarterSlicer = Join-Path $pageVisuals "slicer_quarter\visual.json"
    $quarterLabel = Join-Path $pageVisuals "label_quarter\visual.json"

    if (!(Test-Path -LiteralPath $quarterSlicer)) {
        Write-Err "Missing quarter slicer on core page: $pageId"
        continue
    }
    if (!(Test-Path -LiteralPath $quarterLabel)) {
        Write-Err "Missing quarter label on core page: $pageId"
        continue
    }

    try {
        $slicerObj = Get-Content -LiteralPath $quarterSlicer -Raw | ConvertFrom-Json
        $labelObj = Get-Content -LiteralPath $quarterLabel -Raw | ConvertFrom-Json
        $slicerY = [int]$slicerObj.position.y
        $labelY = [int]$labelObj.position.y
        if ($slicerY -ne 208 -or $labelY -ne 188) {
            Write-Warn "Quarter rail position drift on $pageId (label=$labelY, slicer=$slicerY). Expected 188/208."
        } else {
            Write-Ok "Quarter slicer present and positioned correctly on $pageId"
        }
    } catch {
        Write-Err "Failed to parse quarter slicer/label JSON on ${pageId}: $($_.Exception.Message)"
    }
}

# Validate Sales Type / Department swap order (Sales Type above Department)
foreach ($pageId in $corePages) {
    $pageVisuals = Join-Path $reportPagesRoot "$pageId\visuals"
    $salesLabel = Join-Path $pageVisuals "label_sales_type\visual.json"
    $deptLabel = Join-Path $pageVisuals "label_department\visual.json"
    $salesSlicer = Join-Path $pageVisuals "slicer_sales_type\visual.json"
    $deptSlicer = Join-Path $pageVisuals "slicer_department\visual.json"

    if ((Test-Path -LiteralPath $salesLabel) -and (Test-Path -LiteralPath $deptLabel)) {
        try {
            $salesY = [int]((Get-Content -LiteralPath $salesLabel -Raw | ConvertFrom-Json).position.y)
            $deptY = [int]((Get-Content -LiteralPath $deptLabel -Raw | ConvertFrom-Json).position.y)
            if ($salesY -ne 392 -or $deptY -ne 460) {
                Write-Warn "Sales/Department label order drift on $pageId (sales=$salesY, dept=$deptY). Expected 392/460."
            } else {
                Write-Ok "Sales/Department label order is correct on $pageId"
            }
        } catch {
            Write-Err "Failed to parse sales/department labels on ${pageId}: $($_.Exception.Message)"
        }
    }

    if ((Test-Path -LiteralPath $salesSlicer) -and (Test-Path -LiteralPath $deptSlicer)) {
        try {
            $salesSY = [int]((Get-Content -LiteralPath $salesSlicer -Raw | ConvertFrom-Json).position.y)
            $deptSY = [int]((Get-Content -LiteralPath $deptSlicer -Raw | ConvertFrom-Json).position.y)
            if ($salesSY -ne 412 -or $deptSY -ne 480) {
                Write-Warn "Sales/Department slicer order drift on $pageId (sales=$salesSY, dept=$deptSY). Expected 412/480."
            } else {
                Write-Ok "Sales/Department slicer order is correct on $pageId"
            }
        } catch {
            Write-Err "Failed to parse sales/department slicers on ${pageId}: $($_.Exception.Message)"
        }
    }
}

# Additional working pages: page shell present (canvas background); slicer rail may use domain-specific names
$extensionPageIds = @(
    "b432b363b07a4f448e59",
    "12baa519c64e5f8a0fa4",
    "a1f2b3c4d5e6f7a8b9c0",
    "b2f3c4d5e6f7a8b9c1d0",
    "c3f4d5e6f7a8b9c1d2e0"
)

foreach ($pageId in $extensionPageIds) {
    $pageJson = Join-Path $reportPagesRoot "$pageId\page.json"
    if (!(Test-Path -LiteralPath $pageJson)) {
        Write-Err "Missing page.json for extension page: $pageId"
        continue
    }
    try {
        $raw = Get-Content -LiteralPath $pageJson -Raw
        if ($raw -notmatch "#F8FBFF") {
            Write-Warn "Extension page $pageId: expected page background #F8FBFF not found in page.json (verify manually)."
        } else {
            Write-Ok "Extension page present with expected canvas color token: $pageId"
        }
    } catch {
        Write-Err "Failed to read page.json for ${pageId}: $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "Recommended usage:" -ForegroundColor Cyan
Write-Host "1) Edit in:  $sourcePbip"
Write-Host "2) Review from zip: $latestZip"
Write-Host ""

if ($hasErrors) {
    exit 1
}

exit 0
