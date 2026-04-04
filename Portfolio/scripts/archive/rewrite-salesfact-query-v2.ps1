$file = 'c:\Work\reporting-hub\Reports\Sales\Sales Report\Sales Report.SemanticModel\definition\tables\SalesFact.tmdl'
$utf8NoBom = New-Object System.Text.UTF8Encoding $False

$sql = @'
WITH InvTotals AS (
    SELECT "DocEntry", SUM("LineTotal") AS "SumLineTotal"
    FROM "CANON"."INV1"
    GROUP BY "DocEntry"
),
CrTotals AS (
    SELECT "DocEntry", SUM("LineTotal") AS "SumLineTotal"
    FROM "CANON"."RIN1"
    GROUP BY "DocEntry"
)
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
    COALESCE(T1."LineTotal", 0)
        + CASE
            WHEN TT."SumLineTotal" = 0 OR TT."SumLineTotal" IS NULL THEN 0
            ELSE (COALESCE(T1."LineTotal", 0) * COALESCE(T0."DiscSum", 0) * -1) / TT."SumLineTotal"
          END AS "Sales",
    CASE
        WHEN T1."ItemCode" IS NULL THEN 0
        ELSE COALESCE(T1."LineTotal", 0) - COALESCE(T1."GrssProfit", 0)
    END AS "COGS"
FROM "CANON"."OINV" T0
INNER JOIN "CANON"."INV1" T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN InvTotals TT ON TT."DocEntry" = T0."DocEntry"
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
    (COALESCE(T1."LineTotal", 0)
        + CASE
            WHEN TT."SumLineTotal" = 0 OR TT."SumLineTotal" IS NULL THEN 0
            ELSE (COALESCE(T1."LineTotal", 0) * COALESCE(T0."DiscSum", 0) * -1) / TT."SumLineTotal"
          END
    ) * -1 AS "Sales",
    CASE
        WHEN T1."ItemCode" IS NULL THEN 0
        ELSE (COALESCE(T1."LineTotal", 0) - COALESCE(T1."GrssProfit", 0)) * -1
    END AS "COGS"
FROM "CANON"."ORIN" T0
INNER JOIN "CANON"."RIN1" T1 ON T0."DocEntry" = T1."DocEntry"
LEFT JOIN CrTotals TT ON TT."DocEntry" = T0."DocEntry"
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
    Write-Host "SalesFact query v2 applied:"
    Write-Host "  - Sales = LineTotal with proportional header discount allocation (matches Net Revenue)"
    Write-Host "  - COGS = LineTotal - GrssProfit for items, 0 for non-items"
    Write-Host "  - No warranty, no GL adjustment CTEs"
} else {
    Write-Host "ERROR: Could not find the Odbc.Query line to replace!"
    exit 1
}
