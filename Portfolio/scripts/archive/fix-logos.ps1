$financeRes = 'c:\Work\reporting-hub\Reports\Finance\Financial Report\Financial Report.Report\StaticResources\RegisteredResources'
$salesRes   = 'c:\Work\reporting-hub\Reports\Sales\Sales Report\Sales Report.Report\StaticResources\RegisteredResources'
$pagesDir   = 'c:\Work\reporting-hub\Reports\Sales\Sales Report\Sales Report.Report\definition\pages'
$utf8NoBom  = New-Object System.Text.UTF8Encoding $False

# 1. Copy transparent PNGs from Finance to Sales
Copy-Item (Join-Path $financeRes 'Aljazeera_logo5594601849612262.png')          $salesRes -Force
Copy-Item (Join-Path $financeRes 'Canon_logo_transparent4826537244702471.png')  $salesRes -Force
Write-Host 'Copied transparent logo PNGs to Sales RegisteredResources'

# 2. Update brand_logo_aj on all 4 pages
$ajFiles = Get-ChildItem $pagesDir -Recurse -Filter 'visual.json' |
    Where-Object { $_.DirectoryName -like '*brand_logo_aj*' }

foreach ($f in $ajFiles) {
    $raw = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $new = $raw `
        -replace 'Aljazeera37141862457449826\.png', 'Aljazeera_logo5594601849612262.png' `
        -replace "'Aljazeera\.png'", "'Aljazeera logo.png'"
    [System.IO.File]::WriteAllText($f.FullName, $new, $utf8NoBom)
    Write-Host "Updated AJ logo: $($f.FullName)"
}

# 3. Update brand_logo_canon on all 4 pages
$canonFiles = Get-ChildItem $pagesDir -Recurse -Filter 'visual.json' |
    Where-Object { $_.DirectoryName -like '*brand_logo_canon*' }

foreach ($f in $canonFiles) {
    $raw = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $new = $raw `
        -replace 'Canon_RGB_XL8667947472239197\.jpg', 'Canon_logo_transparent4826537244702471.png' `
        -replace "'Canon_RGB_XL\.jpg'", "'Canon_logo_transparent.png'"
    [System.IO.File]::WriteAllText($f.FullName, $new, $utf8NoBom)
    Write-Host "Updated Canon logo: $($f.FullName)"
}

Write-Host ''
Write-Host 'Done. Sales RegisteredResources now contains:'
Get-ChildItem $salesRes -File | Select-Object Name, Length
