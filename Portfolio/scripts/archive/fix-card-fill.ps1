Set-Location 'c:\Work\reporting-hub\Reports\Sales\Sales Report\Sales Report.Report\definition\pages'

$visuals = Get-ChildItem -Recurse -Filter 'visual.json'
$fixed = 0

foreach ($f in $visuals) {
    $raw = Get-Content $f.FullName -Raw
    # Only touch cardVisual files that don't already have fillCustom
    if ($raw -match '"visualType":\s*"cardVisual"' -and $raw -notmatch '"fillCustom"') {
        # Parse as JSON, add fillCustom to objects, write back
        $json = $raw | ConvertFrom-Json
        $fillCustomProp = [PSCustomObject]@{
            properties = [PSCustomObject]@{
                show = [PSCustomObject]@{
                    expr = [PSCustomObject]@{
                        Literal = [PSCustomObject]@{ Value = "false" }
                    }
                }
                transparency = [PSCustomObject]@{
                    expr = [PSCustomObject]@{
                        Literal = [PSCustomObject]@{ Value = "100D" }
                    }
                }
            }
        }
        $json.visual.objects | Add-Member -NotePropertyName 'fillCustom' -NotePropertyValue @($fillCustomProp) -Force
        $out = $json | ConvertTo-Json -Depth 50 -Compress
        Set-Content $f.FullName $out -NoNewline
        $fixed++
    }
}
Write-Host "fillCustom added to: $fixed card visuals"
