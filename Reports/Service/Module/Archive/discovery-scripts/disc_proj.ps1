param(
    [string]$User = "",
    [string]$Password = ""
)
$ErrorActionPreference = "Stop"
$cs = "DSN=HANA_B1;UID=$User;PWD=$Password;"
$conn = New-Object System.Data.Odbc.OdbcConnection($cs)
$conn.Open()

function Run-Reader {
    param([string]$sql)
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $reader = $cmd.ExecuteReader()
    $rows = @()
    while ($reader.Read()) {
        $row = @{}
        for ($i = 0; $i -lt $reader.FieldCount; $i++) {
            $row[$reader.GetName($i)] = $reader.GetValue($i)
        }
        $rows += $row
    }
    $reader.Close()
    $cmd.Dispose()
    return $rows
}

function Run-Scalar {
    param([string]$sql)
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $result = $cmd.ExecuteScalar()
    $cmd.Dispose()
    return $result
}

Write-Output "=== OINS UDFs ==="
$rows = Run-Reader "SELECT COLUMN_NAME, DATA_TYPE_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME='CANON' AND TABLE_NAME='OINS' AND COLUMN_NAME LIKE 'U_%' ORDER BY POSITION"
foreach ($r in $rows) { Write-Output ("  {0} ({1})" -f $r["COLUMN_NAME"], $r["DATA_TYPE_NAME"]) }

Write-Output ""
Write-Output "=== OINS UDF DEFINITIONS ==="
try {
    $rows = Run-Reader "SELECT ""AliasID"", ""Descr"" FROM ""CANON"".""CUFD"" WHERE ""TableID"" = 'OINS' ORDER BY ""AliasID"""
    foreach ($r in $rows) { Write-Output ("  U_{0}: {1}" -f $r["AliasID"], $r["Descr"]) }
    if ($rows.Count -eq 0) { Write-Output "  (none)" }
} catch { Write-Output "  CUFD failed" }

Write-Output ""
Write-Output "=== INV1 PROJECT COLUMN ==="
$rows = Run-Reader "SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME='CANON' AND TABLE_NAME='INV1' AND UPPER(COLUMN_NAME) LIKE '%PROJ%' ORDER BY POSITION"
foreach ($r in $rows) { Write-Output ("  {0}" -f $r["COLUMN_NAME"]) }

Write-Output ""
Write-Output "=== INV1 SV002 LINES WITH PROJECT ==="
try {
    $rows = Run-Reader "SELECT I.""Project"", P.""PrjName"", COUNT(*) AS cnt, SUM(I.""LineTotal"") AS total FROM ""CANON"".""INV1"" I LEFT JOIN ""CANON"".""OPRJ"" P ON I.""Project"" = P.""PrjCode"" WHERE I.""ItemCode"" = 'SV002' AND I.""Project"" IS NOT NULL AND I.""Project"" <> '' GROUP BY I.""Project"", P.""PrjName"" ORDER BY total DESC"
    foreach ($r in $rows) { Write-Output ("  Project {0} ({1}): {2} lines, total={3}" -f $r["Project"], $r["PrjName"], $r["cnt"], $r["total"]) }
    if ($rows.Count -eq 0) { Write-Output "  (no project on SV002 lines)" }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "=== ALL INV1 LINES WITH PROJECT CODE ==="
try {
    $rows = Run-Reader "SELECT I.""Project"", P.""PrjName"", COUNT(*) AS cnt, SUM(I.""LineTotal"") AS total FROM ""CANON"".""INV1"" I LEFT JOIN ""CANON"".""OPRJ"" P ON I.""Project"" = P.""PrjCode"" WHERE I.""Project"" IS NOT NULL AND I.""Project"" <> '' GROUP BY I.""Project"", P.""PrjName"" ORDER BY cnt DESC"
    foreach ($r in $rows[0..29]) { Write-Output ("  {0} ({1}): {2} lines, total={3}" -f $r["Project"], $r["PrjName"], $r["cnt"], $r["total"]) }
    if ($rows.Count -eq 0) { Write-Output "  (none)" }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "=== DLN1 LINES WITH PROJECT ==="
try {
    $rows = Run-Reader "SELECT D.""Project"", P.""PrjName"", COUNT(*) AS cnt, SUM(D.""LineTotal"") AS total FROM ""CANON"".""DLN1"" D LEFT JOIN ""CANON"".""OPRJ"" P ON D.""Project"" = P.""PrjCode"" WHERE D.""Project"" IS NOT NULL AND D.""Project"" <> '' GROUP BY D.""Project"", P.""PrjName"" ORDER BY cnt DESC"
    foreach ($r in $rows[0..29]) { Write-Output ("  {0} ({1}): {2} lines, total={3}" -f $r["Project"], $r["PrjName"], $r["cnt"], $r["total"]) }
    if ($rows.Count -eq 0) { Write-Output "  (none)" }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "=== OINV INVOICES WITH PROJECT ==="
try {
    $rows = Run-Reader "SELECT H.""Project"", P.""PrjName"", COUNT(*) AS cnt FROM ""CANON"".""OINV"" H LEFT JOIN ""CANON"".""OPRJ"" P ON H.""Project"" = P.""PrjCode"" WHERE H.""Project"" IS NOT NULL AND H.""Project"" <> '' GROUP BY H.""Project"", P.""PrjName"" ORDER BY cnt DESC"
    foreach ($r in $rows[0..19]) { Write-Output ("  {0} ({1}): {2} invoices" -f $r["Project"], $r["PrjName"], $r["cnt"]) }
    if ($rows.Count -eq 0) { Write-Output "  (none)" }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "=== OPRJ ALL PROJECTS ==="
try {
    $rows = Run-Reader "SELECT ""PrjCode"", ""PrjName"", ""ValidFrom"", ""ValidTo"", ""Active"" FROM ""CANON"".""OPRJ"" ORDER BY ""PrjCode"""
    foreach ($r in $rows) { Write-Output ("  {0}: {1} | active={2}" -f $r["PrjCode"], $r["PrjName"], $r["Active"]) }
} catch { Write-Output "  failed" }

Write-Output ""
Write-Output "=== OPRJ COLUMNS ==="
$rows = Run-Reader "SELECT COLUMN_NAME, DATA_TYPE_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME='CANON' AND TABLE_NAME='OPRJ' ORDER BY POSITION"
foreach ($r in $rows) { Write-Output ("  {0} ({1})" -f $r["COLUMN_NAME"], $r["DATA_TYPE_NAME"]) }

Write-Output ""
Write-Output "=== PRODUCTION EQUIPMENT BY CUSTOMER ==="
try {
    $rows = Run-Reader "SELECT I.""customer"", I.""custmrName"", COUNT(*) AS machines FROM ""CANON"".""OINS"" I INNER JOIN ""CANON"".""OITM"" M ON I.""itemCode"" = M.""ItemCode"" WHERE M.""ItmsGrpCod"" IN (138, 139, 141, 148, 152, 156) GROUP BY I.""customer"", I.""custmrName"" ORDER BY machines DESC"
    foreach ($r in $rows[0..24]) { Write-Output ("  {0} ({1}): {2}" -f $r["customer"], $r["custmrName"], $r["machines"]) }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "=== TABLES WITH PRJ IN NAME ==="
try {
    $rows = Run-Reader "SELECT TABLE_NAME FROM SYS.TABLES WHERE SCHEMA_NAME='CANON' AND TABLE_NAME LIKE '%PRJ%' ORDER BY TABLE_NAME"
    foreach ($r in $rows) {
        $cnt = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""$($r['TABLE_NAME'])"""
        Write-Output ("  {0}: {1} rows" -f $r["TABLE_NAME"], $cnt)
    }
} catch { Write-Output "  failed" }

$conn.Close()
$conn.Dispose()
Write-Output ""
Write-Output "=== DONE ==="
