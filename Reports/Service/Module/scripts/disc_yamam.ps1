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

Write-Output "=== YAMAM NABIL (empID=80) PRESENCE ==="
$checks = @(
    @{label="OSCL.assignee=80"; sql="SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""assignee"" = 80"},
    @{label="OSCL.responder=80"; sql="SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""responder"" = 80"},
    @{label="OSCL.technician=80"; sql="SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""technician"" = 80"},
    @{label="OSCL.OwnerCode=80"; sql="SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""OwnerCode"" = 80"},
    @{label="OSCL.respAssign=80"; sql="SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""respAssign"" = 80"},
    @{label="SCL6.Technician=80"; sql="SELECT COUNT(*) FROM ""CANON"".""SCL6"" WHERE ""Technician"" = 80"},
    @{label="SCL6.HandledBy=80"; sql="SELECT COUNT(*) FROM ""CANON"".""SCL6"" WHERE ""HandledBy"" = 80"},
    @{label="OSCL.userSign=80"; sql="SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""userSign"" = 80"},
    @{label="OSCL.userSign2=80"; sql="SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""userSign2"" = 80"}
)
foreach ($c in $checks) {
    $cnt = Run-Scalar $c.sql
    Write-Output ("  {0}: {1}" -f $c.label, $cnt)
}

Write-Output ""
Write-Output "=== WHO CREATES TICKETS (userSign) ==="
try {
    $rows = Run-Reader "SELECT S.""userSign"", E.""firstName"", E.""lastName"", E.""dept"", COUNT(*) AS cnt FROM ""CANON"".""OSCL"" S LEFT JOIN ""CANON"".""OHEM"" E ON S.""userSign"" = E.""empID"" GROUP BY S.""userSign"", E.""firstName"", E.""lastName"", E.""dept"" ORDER BY cnt DESC"
    foreach ($r in $rows) {
        Write-Output ("  userSign={0} ({1} {2}, dept={3}): {4} calls" -f $r["userSign"], $r["firstName"], $r["lastName"], $r["dept"], $r["cnt"])
    }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "=== WHO LAST MODIFIED TICKETS (userSign2) ==="
try {
    $rows = Run-Reader "SELECT S.""userSign2"", E.""firstName"", E.""lastName"", E.""dept"", COUNT(*) AS cnt FROM ""CANON"".""OSCL"" S LEFT JOIN ""CANON"".""OHEM"" E ON S.""userSign2"" = E.""empID"" GROUP BY S.""userSign2"", E.""firstName"", E.""lastName"", E.""dept"" ORDER BY cnt DESC"
    foreach ($r in $rows) {
        Write-Output ("  userSign2={0} ({1} {2}, dept={3}): {4} calls" -f $r["userSign2"], $r["firstName"], $r["lastName"], $r["dept"], $r["cnt"])
    }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "=== empID 115 and 117 PRESENCE ==="
$checks2 = @(
    @{label="OSCL.assignee=115"; sql="SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""assignee"" = 115"},
    @{label="OSCL.assignee=117"; sql="SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""assignee"" = 117"},
    @{label="SCL6.Technician=115"; sql="SELECT COUNT(*) FROM ""CANON"".""SCL6"" WHERE ""Technician"" = 115"},
    @{label="SCL6.Technician=117"; sql="SELECT COUNT(*) FROM ""CANON"".""SCL6"" WHERE ""Technician"" = 117"}
)
foreach ($c in $checks2) {
    $cnt = Run-Scalar $c.sql
    Write-Output ("  {0}: {1}" -f $c.label, $cnt)
}

$conn.Close()
$conn.Dispose()
Write-Output ""
Write-Output "=== DONE ==="
