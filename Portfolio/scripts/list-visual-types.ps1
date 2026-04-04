param($dir)
Get-ChildItem $dir -Directory | ForEach-Object {
    $f = Join-Path $_.FullName 'visual.json'
    if (Test-Path $f) {
        $raw = Get-Content $f -Raw
        $typeMatch = [regex]::Match($raw, '"visualType"\s*:\s*"([^"]+)"')
        $nameMatch = [regex]::Match($raw, '"name"\s*:\s*"([^"]+)"')
        if ($typeMatch.Success) {
            [PSCustomObject]@{
                Folder = $_.Name
                VisualName = $nameMatch.Groups[1].Value
                Type = $typeMatch.Groups[1].Value
            }
        }
    }
} | Format-Table -AutoSize
