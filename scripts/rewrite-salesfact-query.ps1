$file = 'c:\Work\reporting-hub\Reports\Sales\Sales Report\Sales Report.SemanticModel\definition\tables\SalesFact.tmdl'
$utf8NoBom = New-Object System.Text.UTF8Encoding $False

$sql = @'
SELECT
    T0."DocDate" AS "DocDate",
    COALESCE(C."U_PartnerType", 'Unknown') AS "BPType",
    T0."CardCode" AS "CardCode",
    T0."CardName" AS "CardName",
    T0."SlpCode" AS "SlpCode",
    COALESCE(S."SlpName", 'Unassigned') AS "SalesPerson",
    COALESCE(S."U_SalesDept", 'Unassigned') AS "SalesDept",
    COALESCE(S."U_SalesType", 'Unassigned') AS "SalesType",
    CASE WHEN T1."ItemCode" IS NULL THEN 'Non-Item' ELSE COALESCE(NULLIF(TRIM(I."U_BusinessType"), ''), 'Unassigned') END AS "BusinessType",
    CASE WHEN T1."ItemCode" IS NULL THEN 'Non-Item' ELSE COALESCE(I."U_GroupType", 'Unassigned') END AS "U_GroupType",
    CASE WHEN T1."ItemCode" IS NULL THEN 'Non-Item' ELSE COALESCE(I."U_ProductType", 'Unassigned') END AS "U_ProductType",
    CASE WHEN T1."ItemCode" IS NULL THEN 'Non-Item' ELSE COALESCE(I."U_SegmentType", 'Unassigned') END AS "U_SegmentType",
    COALESCE(T1."ItemCode", '(No Item)') AS "ItemCode",
    COALESCE(I."ItemName", T1."Dscription", 'Unknown') AS "ItemName",
    COALESCE(T1."Quantity", 0) AS "Qty",
    COALESCE(T1."LineTotal", 0) AS "Sales",
    COALESCE(T1."LineTotal", 0) - COALESCE(T1."GrssProfit", 0) AS "COGS"
FROM "CANON"."OINV" T0
INNER JOIN "CANON"."INV1" T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN "CANON"."OCRD" C ON C."CardCode" = T0."CardCode"
LEFT JOIN "CANON"."OITM" I ON I."ItemCode" = T1."ItemCode"
LEFT JOIN "CANON"."OSLP" S ON S."SlpCode" = T0."SlpCode"
UNION ALL
SELECT
    T0."DocDate" AS "DocDate",
    COALESCE(C."U_PartnerType", 'Unknown') AS "BPType",
    T0."CardCode" AS "CardCode",
    T0."CardName" AS "CardName",
    T0."SlpCode" AS "SlpCode",
    COALESCE(S."SlpName", 'Unassigned') AS "SalesPerson",
    COALESCE(S."U_SalesDept", 'Unassigned') AS "SalesDept",
    COALESCE(S."U_SalesType", 'Unassigned') AS "SalesType",
    CASE WHEN T1."ItemCode" IS NULL THEN 'Non-Item' ELSE COALESCE(NULLIF(TRIM(I."U_BusinessType"), ''), 'Unassigned') END AS "BusinessType",
    CASE WHEN T1."ItemCode" IS NULL THEN 'Non-Item' ELSE COALESCE(I."U_GroupType", 'Unassigned') END AS "U_GroupType",
    CASE WHEN T1."ItemCode" IS NULL THEN 'Non-Item' ELSE COALESCE(I."U_ProductType", 'Unassigned') END AS "U_ProductType",
    CASE WHEN T1."ItemCode" IS NULL THEN 'Non-Item' ELSE COALESCE(I."U_SegmentType", 'Unassigned') END AS "U_SegmentType",
    COALESCE(T1."ItemCode", '(No Item)') AS "ItemCode",
    COALESCE(I."ItemName", T1."Dscription", 'Unknown') AS "ItemName",
    COALESCE(T1."Quantity", 0) * -1 AS "Qty",
    COALESCE(T1."LineTotal", 0) * -1 AS "Sales",
    (COALESCE(T1."LineTotal", 0) - COALESCE(T1."GrssProfit", 0)) * -1 AS "COGS"
FROM "CANON"."ORIN" T0
INNER JOIN "CANON"."RIN1" T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN "CANON"."OCRD" C ON C."CardCode" = T0."CardCode"
LEFT JOIN "CANON"."OITM" I ON I."ItemCode" = T1."ItemCode"
LEFT JOIN "CANON"."OSLP" S ON S."SlpCode" = T0."SlpCode";
'@

$sqlEscaped = ($sql.TrimEnd()) -replace '"', '""'
$sqlEscaped = $sqlEscaped -replace "`r`n", '#(lf)' -replace "`n", '#(lf)'

$newSourceLine = "`t`t`t`t    Source = Odbc.Query(""dsn=HANA_B1"", ""$sqlEscaped"")"

$lines = [System.IO.File]::ReadAllLines($file, [System.Text.Encoding]::UTF8)
$newLines = [System.Collections.ArrayList]::new()
$replaced = $false

foreach ($line in $lines) {
    if ($line -match '^\s+Source = Odbc\.Query\(') {
        [void]$newLines.Add($newSourceLine)
        $replaced = $true
    } else {
        [void]$newLines.Add($line)
    }
}

if ($replaced) {
    [System.IO.File]::WriteAllLines($file, $newLines.ToArray(), $utf8NoBom)
    Write-Host "SalesFact query rewritten successfully."
    Write-Host "Old: complex CTEs with StockValue, warranty, GL adjustments, discount allocation"
    Write-Host "New: simple OINV/INV1 + ORIN/RIN1 using LineTotal and GrssProfit (matches Finance)"
} else {
    Write-Host "ERROR: Could not find the Odbc.Query line to replace!"
    exit 1
}
