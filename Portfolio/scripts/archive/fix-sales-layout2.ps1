$pagesDir = 'c:\Work\reporting-hub\Reports\Sales\Sales Report\Sales Report.Report\definition\pages'
$utf8NoBom = New-Object System.Text.UTF8Encoding $False

# Named visual position changes: name -> {x, width}
$namedChanges = @{
    'kpi_sales'              = @{ x = 188; width = 251 }
    'kpi_cogs'               = @{ x = 455; width = 251 }
    'kpi_profit'             = @{ x = 722; width = 251 }
    'kpi_margin'             = @{ x = 989; width = 251 }
    'kpi_salesperson_count'  = @{ x = 455; width = 251 }
    'kpi_avg_sales'          = @{ x = 722; width = 251 }
    'kpi_bp_count'           = @{ x = 455; width = 251 }
    'kpi_avg_bp'             = @{ x = 722; width = 251 }
    'kpi_target'             = @{ x = 188; width = 251 }
    'kpi_rebate_sales'       = @{ x = 455; width = 251 }
    'kpi_rebate'             = @{ x = 722; width = 251 }
    'kpi_achievement'        = @{ x = 989; width = 251 }
    'chart_trend'            = @{ x = 188; width = 670 }
    'chart_mix'              = @{ x = 874; width = 366 }
    'chart_top_salespeople'  = @{ x = 188; width = 1052 }
    'chart_top_customers'    = @{ x = 188; width = 1052 }
    'chart_target_vs_actual' = @{ x = 188; width = 1052 }
}

$matrixGuids = @('f6ef055d0a86a7874a04', '88873629742724eb69e8', 'b6f189b1dcd5e970cb69', '37be1d1010a5bea060b7')

$files = Get-ChildItem $pagesDir -Recurse -Filter 'visual.json'
$layoutFixed = 0
$matrixFixed = 0

foreach ($f in $files) {
    $raw = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $modified = $false

    $nameMatch = [regex]::Match($raw, '"name"\s*:\s*"([^"]+)"')
    if (-not $nameMatch.Success) { continue }
    $name = $nameMatch.Groups[1].Value

    # --- KPI cards and charts: update x and width in position block ---
    if ($namedChanges.ContainsKey($name)) {
        $c = $namedChanges[$name]
        $newRaw = $raw
        # Replace x (anchored by following "y")
        $newRaw = [regex]::Replace($newRaw,
            '("x"\s*:\s*)[\d.]+(\s*,[\s\r\n]*"y")',
            "`${1}$($c.x)`${2}")
        # Replace width (anchored by following "tabOrder")
        $newRaw = [regex]::Replace($newRaw,
            '("width"\s*:\s*)[\d.]+(\s*,[\s\r\n]*"tabOrder")',
            "`${1}$($c.width)`${2}")
        if ($newRaw -ne $raw) {
            $raw = $newRaw; $modified = $true; $layoutFixed++
        }
    }

    # --- Matrices: update width and scale columnWidth values ---
    if ($matrixGuids -contains $name) {
        $newRaw = $raw
        # Update position width
        $newRaw = [regex]::Replace($newRaw,
            '("width"\s*:\s*)[\d.]+(\s*,[\s\r\n]*"tabOrder")',
            '${1}1052${2}')
        # Scale explicit columnWidth decimal values (pattern: large floats like 355.26D)
        # These appear as "Value": "NNN.NND" where NNN is > 50 (column widths, not font/margin sizes)
        $newRaw = [regex]::Replace($newRaw, '"Value"\s*:\s*"([\d]{2,4}\.[\d]+)D"', {
            param($m)
            $val = [double]$m.Groups[1].Value
            $scaled = [math]::Round($val * (1052.0 / 848.0), 2)
            '"Value": "' + $scaled + 'D"'
        })
        if ($newRaw -ne $raw) {
            $raw = $newRaw; $modified = $true; $matrixFixed++
        }
    }

    if ($modified) {
        [System.IO.File]::WriteAllText($f.FullName, $raw, $utf8NoBom)
    }
}

Write-Host "Layout/chart visuals fixed: $layoutFixed"
Write-Host "Matrices fixed: $matrixFixed"
