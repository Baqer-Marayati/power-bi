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

Write-Output "=== A. All UDFs on OCRD (business partner master) ==="
$rows = Run-Reader @"
SELECT "AliasID", "Descr"
FROM "CANON"."CUFD"
WHERE "TableID" = 'OCRD'
ORDER BY "AliasID"
"@
foreach ($r in $rows) { Write-Output ("  U_{0,-30} {1}" -f $r["AliasID"], $r["Descr"]) }

Write-Output "`n=== B. UDF columns on OCRD that look like 'solution' / 'type' / 'segment' / 'category' ==="
$rows = Run-Reader @"
SELECT "AliasID", "Descr"
FROM "CANON"."CUFD"
WHERE "TableID" = 'OCRD'
  AND (LOWER("AliasID") LIKE '%sol%' OR LOWER("Descr") LIKE '%sol%'
    OR LOWER("AliasID") LIKE '%type%' OR LOWER("Descr") LIKE '%type%'
    OR LOWER("AliasID") LIKE '%segm%' OR LOWER("Descr") LIKE '%segm%'
    OR LOWER("AliasID") LIKE '%categ%' OR LOWER("Descr") LIKE '%categ%')
ORDER BY "AliasID"
"@
foreach ($r in $rows) { Write-Output ("  U_{0,-30} {1}" -f $r["AliasID"], $r["Descr"]) }

$conn.Close(); $conn.Dispose()
Write-Output "`n=== DONE STEP 1 ==="
