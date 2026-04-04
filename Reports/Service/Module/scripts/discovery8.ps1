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

Write-Output "=== PROBLEM TYPES RESOLVED ==="
try {
    $sql = @"
SELECT S."problemTyp", P."Name", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OSCP" P ON S."problemTyp" = P."prblmTypID"
WHERE S."problemTyp" > 0
GROUP BY S."problemTyp", P."Name"
ORDER BY cnt DESC
"@
    $rows = Run-Reader $sql
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}): {2} calls" -f $row["problemTyp"], $row["Name"], $row["cnt"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

Write-Output "`n=== PROBLEM SUBTYPES WITH PARENT ==="
try {
    $sql = @"
SELECT S."problemTyp", P."Name" AS problemName, S."ProSubType", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OSCP" P ON S."problemTyp" = P."prblmTypID"
WHERE S."problemTyp" > 0 AND S."ProSubType" > 0
GROUP BY S."problemTyp", P."Name", S."ProSubType"
ORDER BY cnt DESC
"@
    $rows = Run-Reader $sql
    foreach ($row in $rows[0..24]) {
        Write-Output ("  ProbType={0} ({1}), SubType={2}: {3}" -f $row["problemTyp"], $row["problemName"], $row["ProSubType"], $row["cnt"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

Write-Output "`n=== OSCL ASSIGNEE who is NOT in Service Dept ==="
try {
    $sql = @"
SELECT S."assignee", E."firstName", E."lastName", D."Name" AS deptName, COUNT(*) AS cnt
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OHEM" E ON S."assignee" = E."empID"
INNER JOIN "CANON"."OUDP" D ON E."dept" = D."Code"
WHERE S."assignee" > 0 AND E."dept" <> 6
GROUP BY S."assignee", E."firstName", E."lastName", D."Name"
ORDER BY cnt DESC
"@
    $rows = Run-Reader $sql
    foreach ($row in $rows) {
        Write-Output ("  {0} {1} (dept={2}): {3} calls" -f $row["firstName"], $row["lastName"], $row["deptName"], $row["cnt"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

Write-Output "`n=== CALLS WITH NEITHER insID NOR itemCode ==="
try {
    $sql = @"
SELECT COUNT(*) AS cnt FROM "CANON"."OSCL"
WHERE ("insID" IS NULL OR "insID" <= 0)
  AND ("itemCode" IS NULL OR "itemCode" = '')
"@
    $rows = Run-Reader $sql
    Write-Output ("  Count: {0} / 676" -f $rows[0]["cnt"])
} catch { Write-Output "Failed: $($_.Exception.Message)" }

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DONE ==="
