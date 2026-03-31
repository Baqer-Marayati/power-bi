Get-ChildItem 'c:\Work\reporting-hub\Reports\Finance\Financial Report' -Recurse -File |
    Where-Object { $_.Extension -match '\.(png|jpg|jpeg|gif|bmp|webp)' } |
    Select-Object FullName, Length |
    Sort-Object Length -Descending |
    Select-Object -First 30
