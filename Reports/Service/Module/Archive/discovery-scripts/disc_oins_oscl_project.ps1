param(
    [string]$User = "",
    [string]$Password = ""
)
$ErrorActionPreference = "Stop"
if ($User -ne "") {
    $cs = "DSN=HANA_B1;UID=$User;PWD=$Password;"
} else {
    $cs = "DSN=HANA_B1;"
}
$conn = New-Object System.Data.Odbc.OdbcConnection($cs)
$conn.Open()

function Run-Reader { param([string]$sql)
    $cmd = $conn.CreateCommand(); $cmd.CommandText = $sql
    $r = $cmd.ExecuteReader(); $rows = @()
    while ($r.Read()) {
        $row = @{}
        for ($i=0; $i -lt $r.FieldCount; $i++) { $row[$r.GetName($i)] = $r.GetValue($i) }
        $rows += $row
    }
    $r.Close(); $cmd.Dispose(); return $rows
}

Write-Output "=== 1. OINS user-defined fields (CUFD) ==="
$rows = Run-Reader @"
SELECT "AliasID", "Descr"
FROM "CANON"."CUFD" WHERE "TableID" = 'OINS' ORDER BY "AliasID"
"@
if ($rows.Count -eq 0) { Write-Output "  (no UDFs defined on OINS)" }
foreach ($row in $rows) {
    Write-Output ("  U_{0} | {1}" -f $row["AliasID"], $row["Descr"])
}

Write-Output "`n=== 2. OINS columns containing 'PRJ', 'PROJ' or starting with 'U_' ==="
$rows = Run-Reader @"
SELECT COLUMN_NAME, DATA_TYPE_NAME, LENGTH FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON' AND TABLE_NAME = 'OINS'
  AND (UPPER(COLUMN_NAME) LIKE '%PRJ%'
    OR UPPER(COLUMN_NAME) LIKE '%PROJ%'
    OR COLUMN_NAME LIKE 'U_%')
ORDER BY POSITION
"@
if ($rows.Count -eq 0) { Write-Output "  (no matching columns)" }
foreach ($row in $rows) {
    Write-Output ("  {0} ({1}, len={2})" -f $row["COLUMN_NAME"], $row["DATA_TYPE_NAME"], $row["LENGTH"])
}

Write-Output "`n=== 3. OINS row counts and project-fill rates ==="
$rows = Run-Reader @"
SELECT COUNT(*) AS total_rows FROM "CANON"."OINS"
"@
foreach ($row in $rows) { Write-Output ("  OINS total rows: {0}" -f $row["total_rows"]) }

# Try to read U_Project / U_PrjCode if such UDFs exist - we'll discover then probe.
$udfCols = (Run-Reader @"
SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON' AND TABLE_NAME = 'OINS' AND COLUMN_NAME LIKE 'U_%'
ORDER BY POSITION
"@) | ForEach-Object { $_["COLUMN_NAME"] }
Write-Output ("  OINS UDF columns present: " + ($udfCols -join ", "))
foreach ($c in $udfCols) {
    try {
        $cnt = Run-Reader ("SELECT COUNT(*) AS filled FROM ""CANON"".""OINS"" WHERE ""$c"" IS NOT NULL AND ""$c"" <> ''")
        Write-Output ("  {0}: filled = {1}" -f $c, $cnt[0]["filled"])
    } catch { Write-Output ("  {0}: probe failed: {1}" -f $c, $_.Exception.Message) }
}

Write-Output "`n=== 4. OINS sample rows showing UDF values ==="
if ($udfCols.Count -gt 0) {
    $colList = ($udfCols | ForEach-Object { "I.""$_""" }) -join ", "
    $sql = "SELECT TOP 15 I.""insID"", I.""customer"", I.""custmrName"", I.""itemCode"", $colList FROM ""CANON"".""OINS"" I WHERE " + (($udfCols | ForEach-Object { "I.""$_"" IS NOT NULL AND I.""$_"" <> ''" }) -join " OR ") + " ORDER BY I.""insID"" DESC"
    try {
        $rows = Run-Reader $sql
        foreach ($row in $rows) {
            $line = "  insID={0} cust={1} ({2}) item={3}" -f $row["insID"], $row["customer"], $row["custmrName"], $row["itemCode"]
            foreach ($c in $udfCols) { $line += "  $c=" + $row[$c] }
            Write-Output $line
        }
        if ($rows.Count -eq 0) { Write-Output "  (no UDF values populated)" }
    } catch { Write-Output ("  sample failed: {0}" -f $_.Exception.Message) }
}

Write-Output "`n=== 5. OSCL project field (BPProjCode) usage ==="
$rows = Run-Reader @"
SELECT
  COUNT(*) AS total_calls,
  COUNT(CASE WHEN "BPProjCode" IS NOT NULL AND "BPProjCode" <> '' THEN 1 END) AS calls_with_project
FROM "CANON"."OSCL"
"@
foreach ($row in $rows) {
    Write-Output ("  OSCL total = {0}; calls with BPProjCode = {1}" -f $row["total_calls"], $row["calls_with_project"])
}

Write-Output "`n=== 6. OSCL distinct BPProjCode values ==="
$rows = Run-Reader @"
SELECT S."BPProjCode", P."PrjName", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OPRJ" P ON S."BPProjCode" = P."PrjCode"
WHERE S."BPProjCode" IS NOT NULL AND S."BPProjCode" <> ''
GROUP BY S."BPProjCode", P."PrjName"
ORDER BY cnt DESC
"@
if ($rows.Count -eq 0) { Write-Output "  (none)" }
foreach ($row in $rows) {
    Write-Output ("  {0} ({1}): {2} calls" -f $row["BPProjCode"], $row["PrjName"], $row["cnt"])
}

Write-Output "`n=== 7. OSCL UDFs - any project-like UDF? ==="
$rows = Run-Reader @"
SELECT "AliasID", "Descr"
FROM "CANON"."CUFD"
WHERE "TableID" = 'OSCL'
  AND (UPPER("Descr") LIKE '%PROJ%' OR UPPER("AliasID") LIKE '%PRJ%' OR UPPER("AliasID") LIKE '%PROJ%')
ORDER BY "AliasID"
"@
if ($rows.Count -eq 0) { Write-Output "  (no project-named UDFs on OSCL)" }
foreach ($row in $rows) { Write-Output ("  U_{0} | {1}" -f $row["AliasID"], $row["Descr"]) }

Write-Output "`n=== 8. OSCL UDF columns + fill rates (full UDF list, project-related or not) ==="
$oscUdfs = (Run-Reader @"
SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON' AND TABLE_NAME = 'OSCL' AND COLUMN_NAME LIKE 'U_%'
ORDER BY POSITION
"@) | ForEach-Object { $_["COLUMN_NAME"] }
Write-Output ("  OSCL UDF columns: " + ($oscUdfs -join ", "))

$conn.Close(); $conn.Dispose()
Write-Output "`n=== DONE ==="
