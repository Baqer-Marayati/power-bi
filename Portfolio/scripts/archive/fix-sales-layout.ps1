Set-Location 'c:\Work\reporting-hub\Reports\Sales\Sales Report\Sales Report.Report\definition\pages'

$visuals = Get-ChildItem -Recurse -Filter 'visual.json'

$chartHeightFixed = 0
$matrixFixed = 0
$borderFixed = 0

foreach ($f in $visuals) {
    $raw = Get-Content $f.FullName -Raw
    $changed = $false

    # Chart height fix: 270 -> 300 (only for chart visual types)
    if ($raw -match '"visualType":\s*"(barChart|lineClusteredColumnComboChart|donutChart|clusteredBarChart)"') {
        $newRaw = $raw -replace '"height":\s*270,', '"height": 300,'
        if ($newRaw -ne $raw) { $raw = $newRaw; $changed = $true; $chartHeightFixed++ }
    }

    # Matrix position fix: y:520 -> 545, height:420 -> 395
    if ($raw -match '"visualType":\s*"pivotTable"') {
        $newRaw = $raw -replace '"y":\s*520,', '"y": 545,'
        if ($newRaw -ne $raw) { $raw = $newRaw; $changed = $true }
        $newRaw = $raw -replace '"height":\s*420,', '"height": 395,'
        if ($newRaw -ne $raw) { $raw = $newRaw; $changed = $true; $matrixFixed++ }
    }

    # Border color: #C9D5E3 -> #E6ECE8 (Finance standard)
    $newRaw = $raw -replace "'#C9D5E3'", "'#E6ECE8'"
    if ($newRaw -ne $raw) { $raw = $newRaw; $changed = $true; $borderFixed++ }

    if ($changed) {
        Set-Content $f.FullName $raw -NoNewline
    }
}

Write-Host "Charts height fixed: $chartHeightFixed"
Write-Host "Matrices repositioned: $matrixFixed"
Write-Host "Border colors updated: $borderFixed"
