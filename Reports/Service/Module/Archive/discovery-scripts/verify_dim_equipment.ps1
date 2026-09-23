param([string]$User="", [string]$Password="")
$ErrorActionPreference="Stop"
$cs = "DSN=HANA_B1;UID=$User;PWD=$Password;"
$conn = New-Object System.Data.Odbc.OdbcConnection($cs)
$conn.Open()
function Run-Reader { param([string]$sql)
    $cmd=$conn.CreateCommand(); $cmd.CommandText=$sql
    $r=$cmd.ExecuteReader(); $rows=@()
    while ($r.Read()) {
        $row=@{}; for ($i=0;$i-lt$r.FieldCount;$i++){ $row[$r.GetName($i)]=$r.GetValue($i) }
        $rows += $row
    }
    $r.Close(); $cmd.Dispose(); return $rows
}

$sql = @"
SELECT
  E."insID" AS "EquipmentKey",
  E."customer" AS "CustomerCode",
  E."itemCode" AS "ItemCode",
  E."itemName" AS "ItemName",
  E."manufSN" AS "ManufacturerSN",
  E."internalSN" AS "InternalSN",
  E."instLction" AS "InstallLocation",
  CASE E."status"
    WHEN 'A' THEN 'Active'
    WHEN 'I' THEN 'Inactive'
    WHEN 'R' THEN 'Returned'
    ELSE E."status"
  END AS "Status",
  E."U_Project" AS "ProjectCode",
  CASE WHEN E."U_Project" IS NOT NULL AND E."U_Project" <> '' AND E."U_Project" <> 'PR-000' THEN 'Yes' ELSE 'No' END AS "HasProject",
  CASE
    WHEN G."ItmsGrpNam" LIKE 'B2B - IPS%' THEN 'Production'
    WHEN G."ItmsGrpNam" = '#N/A' THEN 'Production'
    WHEN G."ItmsGrpCod" = 139 THEN 'Production'
    WHEN E."U_Project" IS NOT NULL AND E."U_Project" <> '' AND E."U_Project" <> 'PR-000' THEN 'Production'
    WHEN G."ItmsGrpNam" LIKE 'B2B - DS Copier%' THEN 'Office'
    WHEN G."ItmsGrpNam" LIKE 'B2C%' THEN 'Consumer'
    WHEN G."ItmsGrpCod" IN (172,173,174,175,176,177) THEN 'Service'
    ELSE 'Other'
  END AS "MachineClass",
  CASE
    WHEN G."ItmsGrpNam" LIKE 'B2B - IPS%' THEN 'Production'
    WHEN G."ItmsGrpNam" = '#N/A' THEN 'Production'
    WHEN G."ItmsGrpCod" = 139 THEN 'Production'
    WHEN G."ItmsGrpNam" LIKE 'B2B - DS Copier%' THEN 'Office'
    WHEN G."ItmsGrpNam" LIKE 'B2C%' THEN 'Consumer'
    WHEN G."ItmsGrpCod" IN (172,173,174,175,176,177) THEN 'Service'
    ELSE 'Other'
  END AS "ItemGroupClass"
FROM "CANON"."OINS" E
LEFT JOIN "CANON"."OITM" I ON E."itemCode" = I."ItemCode"
LEFT JOIN "CANON"."OITB" G ON I."ItmsGrpCod" = G."ItmsGrpCod"
"@

Write-Output "=== A. Validate query (column count + row count) ==="
$rows = Run-Reader ("SELECT COUNT(*) AS rowcount FROM (" + $sql + ")")
foreach ($r in $rows) { Write-Output ("  Total rows produced: {0}" -f $r["rowcount"]) }

Write-Output "`n=== B. MachineClass distribution under new rule ==="
$rows = Run-Reader ("SELECT ""MachineClass"", COUNT(*) AS cards FROM (" + $sql + ") GROUP BY ""MachineClass"" ORDER BY cards DESC")
foreach ($r in $rows) { Write-Output ("  {0,-12} {1,6}" -f $r["MachineClass"], $r["cards"]) }

Write-Output "`n=== C. ItemGroupClass distribution (legacy) ==="
$rows = Run-Reader ("SELECT ""ItemGroupClass"", COUNT(*) AS cards FROM (" + $sql + ") GROUP BY ""ItemGroupClass"" ORDER BY cards DESC")
foreach ($r in $rows) { Write-Output ("  {0,-12} {1,6}" -f $r["ItemGroupClass"], $r["cards"]) }

Write-Output "`n=== D. Untagged Production Machines (the data-quality bucket) ==="
$rows = Run-Reader ("SELECT COUNT(*) AS untagged FROM (" + $sql + ") WHERE ""ItemGroupClass"" = 'Production' AND ""MachineClass"" <> 'Production'")
foreach ($r in $rows) { Write-Output ("  Untagged production machines: {0}" -f $r["untagged"]) }

Write-Output "`n=== E. HasProject distribution ==="
$rows = Run-Reader ("SELECT ""HasProject"", COUNT(*) AS cards FROM (" + $sql + ") GROUP BY ""HasProject""")
foreach ($r in $rows) { Write-Output ("  {0,-4} {1,6}" -f $r["HasProject"], $r["cards"]) }

$conn.Close(); $conn.Dispose()
Write-Output "`n=== DONE ==="
