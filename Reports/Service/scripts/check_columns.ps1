$connStr = "dsn=HANA_B1;UID=SYSTEM;PWD=A-rxiJ5X-KBC-q56"
$conn = New-Object System.Data.Odbc.OdbcConnection($connStr)
$conn.Open()

function Run-Reader($sql) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $rdr = $cmd.ExecuteReader()
    while ($rdr.Read()) {
        $vals = @()
        for ($i = 0; $i -lt $rdr.FieldCount; $i++) { $vals += $rdr.GetValue($i) }
        Write-Output ($vals -join " | ")
    }
    $rdr.Close()
}

Write-Output "=== SCL6 columns ==="
Run-Reader "SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME='CANON' AND TABLE_NAME='SCL6' ORDER BY POSITION"

Write-Output ""
Write-Output "=== OINS columns (inst/location related) ==="
Run-Reader "SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME='CANON' AND TABLE_NAME='OINS' AND (COLUMN_NAME LIKE '%nst%' OR COLUMN_NAME LIKE '%ocation%' OR COLUMN_NAME LIKE '%loc%') ORDER BY POSITION"

Write-Output ""
Write-Output "=== OINS all columns ==="
Run-Reader "SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME='CANON' AND TABLE_NAME='OINS' ORDER BY POSITION"

$conn.Close()
