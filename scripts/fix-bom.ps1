# Strip UTF-8 BOM from all visual.json files in the Sales report pages folder
$pagesDir = 'c:\Work\reporting-hub\Reports\Sales\Sales Report\Sales Report.Report\definition\pages'
$utf8NoBom = New-Object System.Text.UTF8Encoding $False

$files = Get-ChildItem $pagesDir -Recurse -Filter '*.json'
$fixed = 0

foreach ($f in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    # UTF-8 BOM is 0xEF, 0xBB, 0xBF
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $text = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
        [System.IO.File]::WriteAllText($f.FullName, $text, $utf8NoBom)
        $fixed++
        Write-Host "Fixed BOM: $($f.Name)  [$($f.DirectoryName.Split('\')[-2])]"
    }
}

Write-Host ""
Write-Host "Total files with BOM fixed: $fixed"
