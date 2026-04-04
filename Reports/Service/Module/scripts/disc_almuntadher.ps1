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

Write-Output "=== ALMUNTADHER YOUSIF (empID=64) FULL PROFILE ==="

Write-Output ""
Write-Output "--- OHEM record ---"
try {
    $rows = Run-Reader "SELECT ""empID"", ""firstName"", ""lastName"", ""dept"", ""position"", ""Active"", ""startDate"" FROM ""CANON"".""OHEM"" WHERE ""empID"" = 64"
    foreach ($r in $rows) {
        Write-Output ("  empID={0}, name={1} {2}, dept={3}, position={4}, active={5}, start={6}" -f $r["empID"], $r["firstName"], $r["lastName"], $r["dept"], $r["position"], $r["Active"], $r["startDate"])
    }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "--- SAP user account (OUSR) ---"
try {
    $rows = Run-Reader "SELECT ""INTERNAL_K"", ""USER_CODE"", ""U_NAME"", ""DEPARTMENT"", ""E_Mail"" FROM ""CANON"".""OUSR"" WHERE ""INTERNAL_K"" = 64"
    foreach ($r in $rows) {
        Write-Output ("  key={0}, userCode={1}, userName={2}, dept={3}, email={4}" -f $r["INTERNAL_K"], $r["USER_CODE"], $r["U_NAME"], $r["DEPARTMENT"], $r["E_Mail"])
    }
    if ($rows.Count -eq 0) {
        $rows = Run-Reader "SELECT ""INTERNAL_K"", ""USER_CODE"", ""U_NAME"", ""DEPARTMENT"" FROM ""CANON"".""OUSR"" ORDER BY ""INTERNAL_K"""
        Write-Output "  (empID 64 not found directly, all users:)"
        foreach ($r in $rows) {
            Write-Output ("  key={0}, code={1}, name={2}, dept={3}" -f $r["INTERNAL_K"], $r["USER_CODE"], $r["U_NAME"], $r["DEPARTMENT"])
        }
    }
} catch { Write-Output "  OUSR failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "--- Tickets created by empID=64 (userSign=64) ---"
$cnt = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""userSign"" = 64"
Write-Output "  Total tickets created: $cnt / 676"

Write-Output ""
Write-Output "--- Tickets where empID=64 is assignee ---"
$cnt2 = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""assignee"" = 64"
Write-Output "  Assigned to: $cnt2"

Write-Output ""
Write-Output "--- Tickets where empID=64 is responder ---"
$cnt3 = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""responder"" = 64"
Write-Output "  Responder on: $cnt3"

Write-Output ""
Write-Output "--- SCL6 activities for empID=64 ---"
$cnt4 = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""SCL6"" WHERE ""Technician"" = 64"
Write-Output "  SCL6 activities: $cnt4"

$cnt5 = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""SCL6"" WHERE ""HandledBy"" = 64"
Write-Output "  SCL6 HandledBy: $cnt5"

Write-Output ""
Write-Output "--- Tickets created by 64: what callTypes? ---"
try {
    $rows = Run-Reader @"
SELECT S."callType", T."Name", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OSCT" T ON S."callType" = T."callTypeID"
WHERE S."userSign" = 64
GROUP BY S."callType", T."Name"
ORDER BY cnt DESC
"@
    foreach ($r in $rows) {
        Write-Output ("  callType={0} ({1}): {2}" -f $r["callType"], $r["Name"], $r["cnt"])
    }
} catch { Write-Output "  failed" }

Write-Output ""
Write-Output "--- Tickets created by 64: which technicians end up on them (SCL6)? ---"
try {
    $rows = Run-Reader @"
SELECT S."Technician", E."firstName", E."lastName", COUNT(*) AS activities
FROM "CANON"."SCL6" S
INNER JOIN "CANON"."OHEM" E ON S."Technician" = E."empID"
WHERE S."SrcvCallID" IN (SELECT "callID" FROM "CANON"."OSCL" WHERE "userSign" = 64)
AND S."Technician" > 0
GROUP BY S."Technician", E."firstName", E."lastName"
ORDER BY activities DESC
"@
    foreach ($r in $rows) {
        Write-Output ("  Tech {0} ({1} {2}): {3} activities" -f $r["Technician"], $r["firstName"], $r["lastName"], $r["activities"])
    }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "--- Tickets created by 64: which assignees? ---"
try {
    $rows = Run-Reader @"
SELECT S."assignee", E."firstName", E."lastName", D."Name" AS dept, COUNT(*) AS cnt
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OHEM" E ON S."assignee" = E."empID"
LEFT JOIN "CANON"."OUDP" D ON E."dept" = D."Code"
WHERE S."userSign" = 64
AND S."assignee" > 0
GROUP BY S."assignee", E."firstName", E."lastName", D."Name"
ORDER BY cnt DESC
"@
    foreach ($r in $rows) {
        Write-Output ("  Assignee {0} ({1} {2}, {3}): {4}" -f $r["assignee"], $r["firstName"], $r["lastName"], $r["dept"], $r["cnt"])
    }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "--- Tickets created by 64: item groups (machine types)? ---"
try {
    $rows = Run-Reader @"
SELECT B."ItmsGrpNam", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OITM" M ON S."itemCode" = M."ItemCode"
INNER JOIN "CANON"."OITB" B ON M."ItmsGrpCod" = B."ItmsGrpCod"
WHERE S."userSign" = 64
GROUP BY B."ItmsGrpNam"
ORDER BY cnt DESC
"@
    foreach ($r in $rows) {
        Write-Output ("  {0}: {1}" -f $r["ItmsGrpNam"], $r["cnt"])
    }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "--- Compare: tickets created by 72 (Ali Abdulsattar) ---"
try {
    $rows = Run-Reader @"
SELECT B."ItmsGrpNam", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OITM" M ON S."itemCode" = M."ItemCode"
INNER JOIN "CANON"."OITB" B ON M."ItmsGrpCod" = B."ItmsGrpCod"
WHERE S."userSign" = 72
GROUP BY B."ItmsGrpNam"
ORDER BY cnt DESC
"@
    foreach ($r in $rows) {
        Write-Output ("  {0}: {1}" -f $r["ItmsGrpNam"], $r["cnt"])
    }
} catch { Write-Output "  failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "--- Tickets NOT created by 64 or 72 ---"
try {
    $cnt6 = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""OSCL"" WHERE ""userSign"" NOT IN (64, 72)"
    Write-Output "  Tickets created by others: $cnt6"
    if ($cnt6 -gt 0) {
        $rows = Run-Reader "SELECT ""userSign"", COUNT(*) AS cnt FROM ""CANON"".""OSCL"" WHERE ""userSign"" NOT IN (64, 72) GROUP BY ""userSign"""
        foreach ($r in $rows) { Write-Output ("  userSign={0}: {1}" -f $r["userSign"], $r["cnt"]) }
    }
} catch { Write-Output "  failed" }

Write-Output ""
Write-Output "--- Is userSign the SAP USER_CODE or empID? Cross-check ---"
try {
    $rows = Run-Reader "SELECT ""INTERNAL_K"", ""USER_CODE"", ""U_NAME"" FROM ""CANON"".""OUSR"" WHERE ""INTERNAL_K"" IN (64, 72, 80) ORDER BY ""INTERNAL_K"""
    foreach ($r in $rows) {
        Write-Output ("  OUSR key={0}: code={1}, name={2}" -f $r["INTERNAL_K"], $r["USER_CODE"], $r["U_NAME"])
    }
} catch { Write-Output "  OUSR lookup failed: $($_.Exception.Message)" }

Write-Output ""
Write-Output "--- Sample: 5 tickets created by userSign=64 ---"
try {
    $rows = Run-Reader @"
SELECT TOP 5 "callID", "subject", "custmrName", "assignee", "status", "createDate"
FROM "CANON"."OSCL" WHERE "userSign" = 64 ORDER BY "callID" DESC
"@
    foreach ($r in $rows) {
        Write-Output ("  Call {0}: {1} | cust={2} | assignee={3} | status={4} | date={5}" -f $r["callID"], $r["subject"], $r["custmrName"], $r["assignee"], $r["status"], $r["createDate"])
    }
} catch { Write-Output "  failed" }

$conn.Close()
$conn.Dispose()
Write-Output ""
Write-Output "=== DONE ==="
