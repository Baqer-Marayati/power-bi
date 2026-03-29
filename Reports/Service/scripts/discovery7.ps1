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
SELECT CAST(S."problemTyp" AS INTEGER) AS ptype, P."Name", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OSCP" P ON CAST(S."problemTyp" AS INTEGER) = P."prblmTypID"
WHERE S."problemTyp" IS NOT NULL AND S."problemTyp" <> ''
GROUP BY CAST(S."problemTyp" AS INTEGER), P."Name"
ORDER BY cnt DESC
"@
    $rows = Run-Reader $sql
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}): {2} calls" -f $row["ptype"], $row["Name"], $row["cnt"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

Write-Output "`n=== PROBLEM SUBTYPES WITH PARENT ==="
try {
    $sql = @"
SELECT CAST(S."problemTyp" AS INTEGER) AS ptype, P."Name" AS problemName,
       CAST(S."ProSubType" AS INTEGER) AS subtype, COUNT(*) AS cnt
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OSCP" P ON CAST(S."problemTyp" AS INTEGER) = P."prblmTypID"
WHERE S."problemTyp" IS NOT NULL AND S."problemTyp" <> ''
  AND S."ProSubType" IS NOT NULL AND S."ProSubType" <> ''
GROUP BY CAST(S."problemTyp" AS INTEGER), P."Name", CAST(S."ProSubType" AS INTEGER)
ORDER BY cnt DESC
"@
    $rows = Run-Reader $sql
    foreach ($row in $rows[0..19]) {
        Write-Output ("  Problem={0} ({1}), SubType={2}: {3} calls" -f $row["ptype"], $row["problemName"], $row["subtype"], $row["cnt"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

Write-Output "`n=== OSCL CALLS BY MONTH ==="
try {
    $sql = @"
SELECT TO_VARCHAR("createDate", 'YYYY-MM') AS ym, COUNT(*) AS cnt
FROM "CANON"."OSCL"
GROUP BY TO_VARCHAR("createDate", 'YYYY-MM')
ORDER BY ym
"@
    $rows = Run-Reader $sql
    foreach ($row in $rows) {
        Write-Output ("  {0}: {1} calls" -f $row["ym"], $row["cnt"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

Write-Output "`n=== OSCL CALLS WITH NO EQUIPMENT LINK ==="
try {
    $sql = @"
SELECT COUNT(*) AS cnt FROM "CANON"."OSCL" WHERE ("insID" IS NULL OR "insID" <= 0) AND COALESCE("itemCode",'') = ''
"@
    $rows = Run-Reader $sql
    Write-Output ("  Calls with neither insID nor itemCode: {0} / 676" -f $rows[0]["cnt"])
} catch { Write-Output "Failed: $($_.Exception.Message)" }

Write-Output "`n=== ASSIGNEE DEPT BREAKDOWN ==="
try {
    $sql = @"
SELECT D."Name" AS deptName, COUNT(*) AS cnt
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OHEM" E ON S."assignee" = E."empID"
INNER JOIN "CANON"."OUDP" D ON E."dept" = D."Code"
WHERE S."assignee" IS NOT NULL AND S."assignee" <> -1
GROUP BY D."Name"
ORDER BY cnt DESC
"@
    $rows = Run-Reader $sql
    foreach ($row in $rows) {
        Write-Output ("  {0}: {1} calls" -f $row["deptName"], $row["cnt"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DONE ==="
