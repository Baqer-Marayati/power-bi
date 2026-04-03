$pages = 'c:\Work\reporting-hub\Reports\Sales\Sales Report\Sales Report.Report\definition\pages'
$utf8NoBom = New-Object System.Text.UTF8Encoding $False

$fixes = @(
    @{ file = '0e570507214b44393b37\visuals\kpi_salesperson_count\visual.json'; from = '"2L"'; to = '"0L"' },
    @{ file = 'e20254fdaeba942d5c2c\visuals\kpi_bp_count\visual.json';          from = '"2L"'; to = '"0L"' },
    @{ file = '0e570507214b44393b37\visuals\kpi_avg_sales\visual.json';          from = '"0L"'; to = '"2L"' },
    @{ file = 'e20254fdaeba942d5c2c\visuals\kpi_avg_bp\visual.json';             from = '"0L"'; to = '"2L"' },
    @{ file = '4f0fbaa5695c60b3416c\visuals\kpi_achievement\visual.json';        from = '"1L"'; to = '"2L"' }
)

foreach ($fix in $fixes) {
    $path = Join-Path $pages $fix.file
    $raw = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    # Replace labelPrecision value specifically: "Value": "NL" → "Value": "ML"
    $new = [regex]::Replace($raw,
        '("labelPrecision"[\s\S]*?"Value"\s*:\s*)' + [regex]::Escape($fix.from),
        '${1}' + $fix.to,
        [System.Text.RegularExpressions.RegexOptions]::Singleline)
    [System.IO.File]::WriteAllText($path, $new, $utf8NoBom)
    Write-Host "Fixed: $($fix.file)"
}
