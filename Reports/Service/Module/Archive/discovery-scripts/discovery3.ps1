param(
    [string]$DSN = "HANA_B1",
    [string]$Schema = "CANON",
    [string]$User = "",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"

if (-not $User) { $User = $env:SAP_HANA_USER }
if (-not $Password) { $Password = $env:SAP_HANA_PASSWORD }
$cs = "DSN=$DSN;"
if ($User -and $Password) { $cs = "DSN=$DSN;UID=$User;PWD=$Password;" }

$conn = New-Object System.Data.Odbc.OdbcConnection($cs)
$conn.Open()
Write-Output "Connected"

function Run-Scalar {
    param([string]$sql)
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $result = $cmd.ExecuteScalar()
    $cmd.Dispose()
    return $result
}

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

# ── 1. SCL6.Technician column (distinct values + OHEM join) ──
Write-Output "`n=== SCL6 TECHNICIAN ASSIGNMENT ==="
try {
    $rows = Run-Reader @"
SELECT S."Technician", E."firstName", E."lastName", E."dept", COUNT(*) AS activities
FROM "$Schema"."SCL6" S
LEFT JOIN "$Schema"."OHEM" E ON S."Technician" = E."empID"
WHERE S."Technician" IS NOT NULL AND S."Technician" <> 0
GROUP BY S."Technician", E."firstName", E."lastName", E."dept"
ORDER BY activities DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Tech {0}: {1} {2} (dept={3}) - {4} activities" -f $row["Technician"], $row["firstName"], $row["lastName"], $row["dept"], $row["activities"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (no non-zero technician values)" }
} catch { Write-Output "SCL6 technician failed: $($_.Exception.Message)" }

# ── 2. OSCL.assignee (primary technician assignment?) ──
Write-Output "`n=== OSCL ASSIGNEE ==="
try {
    $rows = Run-Reader @"
SELECT S."assignee", E."firstName", E."lastName", E."dept", COUNT(*) AS calls
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OHEM" E ON S."assignee" = E."empID"
WHERE S."assignee" IS NOT NULL AND S."assignee" <> -1
GROUP BY S."assignee", E."firstName", E."lastName", E."dept"
ORDER BY calls DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Assignee {0}: {1} {2} (dept={3}) - {4} calls" -f $row["assignee"], $row["firstName"], $row["lastName"], $row["dept"], $row["calls"])
    }
} catch { Write-Output "OSCL assignee failed: $($_.Exception.Message)" }

# ── 3. OSCL.problemTyp ──
Write-Output "`n=== OSCL PROBLEM TYPES (problemTyp) ==="
try {
    $rows = Run-Reader "SELECT ""problemTyp"", COUNT(*) AS CNT FROM ""$Schema"".""OSCL"" GROUP BY ""problemTyp"" ORDER BY CNT DESC"
    foreach ($row in $rows) {
        Write-Output ("  problemTyp '{0}': {1}" -f $row["problemTyp"], $row["CNT"])
    }
} catch { Write-Output "problemTyp failed: $($_.Exception.Message)" }

# ── 4. OSCL.ProSubType (problem sub type) ──
Write-Output "`n=== OSCL PROBLEM SUB TYPES ==="
try {
    $rows = Run-Reader "SELECT ""ProSubType"", COUNT(*) AS CNT FROM ""$Schema"".""OSCL"" GROUP BY ""ProSubType"" ORDER BY CNT DESC"
    foreach ($row in $rows) {
        Write-Output ("  ProSubType '{0}': {1}" -f $row["ProSubType"], $row["CNT"])
    }
} catch { Write-Output "ProSubType failed: $($_.Exception.Message)" }

# ── 5. SCL2 sample data (parts on service calls) ──
Write-Output "`n=== SCL2 PARTS SAMPLE ==="
try {
    $rows = Run-Reader "SELECT TOP 15 ""SrcvCallID"", ""ItemCode"", ""ItemName"", ""TransToTec"", ""Delivered"", ""Returned"", ""Bill"", ""QtyToBill"" FROM ""$Schema"".""SCL2"""
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: item={1} ({2}), toTech={3}, delivered={4}, returned={5}, bill={6}, qtyBill={7}" -f $row["SrcvCallID"], $row["ItemCode"], $row["ItemName"], $row["TransToTec"], $row["Delivered"], $row["Returned"], $row["Bill"], $row["QtyToBill"])
    }
} catch { Write-Output "SCL2 sample failed: $($_.Exception.Message)" }

# ── 6. SCL2 top items by frequency ──
Write-Output "`n=== SCL2 TOP PARTS CONSUMED ==="
try {
    $rows = Run-Reader @"
SELECT "ItemCode", "ItemName", COUNT(*) AS frequency, SUM("TransToTec") AS total_qty
FROM "$Schema"."SCL2"
GROUP BY "ItemCode", "ItemName"
ORDER BY frequency DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}): {2} times, total qty={3}" -f $row["ItemCode"], $row["ItemName"], $row["frequency"], $row["total_qty"])
    }
} catch { Write-Output "SCL2 top parts failed: $($_.Exception.Message)" }

# ── 7. OSCL.BPProjCode — project link on service call ──
Write-Output "`n=== OSCL.BPProjCode (Project Link) ==="
try {
    $cnt_total = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"""
    $cnt_proj = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE COALESCE(""BPProjCode"",'') <> ''"
    Write-Output "Calls with BPProjCode: $cnt_proj / $cnt_total"
    
    if ($cnt_proj -gt 0) {
        $rows = Run-Reader @"
SELECT S."BPProjCode", P."PrjName", COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OPRJ" P ON S."BPProjCode" = P."PrjCode"
WHERE S."BPProjCode" IS NOT NULL AND S."BPProjCode" <> ''
GROUP BY S."BPProjCode", P."PrjName"
ORDER BY cnt DESC
"@
        foreach ($row in $rows) {
            Write-Output ("  Project {0} ({1}): {2} calls" -f $row["BPProjCode"], $row["PrjName"], $row["cnt"])
        }
    }
} catch { Write-Output "BPProjCode failed: $($_.Exception.Message)" }

# ── 8. OSCL.OwnerCode — service call owner ──
Write-Output "`n=== OSCL OWNER CODE ==="
try {
    $rows = Run-Reader @"
SELECT S."OwnerCode", E."firstName", E."lastName", E."dept", COUNT(*) AS calls
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OHEM" E ON S."OwnerCode" = E."empID"
WHERE S."OwnerCode" IS NOT NULL AND S."OwnerCode" <> -1
GROUP BY S."OwnerCode", E."firstName", E."lastName", E."dept"
ORDER BY calls DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Owner {0}: {1} {2} (dept={3}) - {4} calls" -f $row["OwnerCode"], $row["firstName"], $row["lastName"], $row["dept"], $row["calls"])
    }
} catch { Write-Output "OwnerCode failed: $($_.Exception.Message)" }

# ── 9. OSCL.responder — responder ──
Write-Output "`n=== OSCL RESPONDER ==="
try {
    $rows = Run-Reader @"
SELECT S."responder", E."firstName", E."lastName", E."dept", COUNT(*) AS calls
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OHEM" E ON S."responder" = E."empID"
WHERE S."responder" IS NOT NULL AND S."responder" <> -1
GROUP BY S."responder", E."firstName", E."lastName", E."dept"
ORDER BY calls DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Responder {0}: {1} {2} (dept={3}) - {4} calls" -f $row["responder"], $row["firstName"], $row["lastName"], $row["dept"], $row["calls"])
    }
} catch { Write-Output "responder failed: $($_.Exception.Message)" }

# ── 10. SCL6 duration stats (different approach) ──
Write-Output "`n=== SCL6 DURATION STATS ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""SCL6"""
    $dur_cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""SCL6"" WHERE ""Duration"" > 0"
    $avg_dur = Run-Scalar "SELECT AVG(""Duration"") FROM ""$Schema"".""SCL6"" WHERE ""Duration"" > 0"
    $max_dur = Run-Scalar "SELECT MAX(""Duration"") FROM ""$Schema"".""SCL6"" WHERE ""Duration"" > 0"
    $min_dur = Run-Scalar "SELECT MIN(""Duration"") FROM ""$Schema"".""SCL6"" WHERE ""Duration"" > 0"
    Write-Output "  Total activities: $cnt"
    Write-Output "  With duration > 0: $dur_cnt"
    Write-Output "  Avg duration: $avg_dur"
    Write-Output "  Min duration: $min_dur"
    Write-Output "  Max duration: $max_dur"
} catch { Write-Output "Duration stats failed: $($_.Exception.Message)" }

# ── 11. SCL6 DurType values ──
Write-Output "`n=== SCL6 DUR TYPE VALUES ==="
try {
    $rows = Run-Reader "SELECT ""DurType"", COUNT(*) AS CNT FROM ""$Schema"".""SCL6"" GROUP BY ""DurType"" ORDER BY CNT DESC"
    foreach ($row in $rows) {
        Write-Output ("  DurType '{0}': {1}" -f $row["DurType"], $row["CNT"])
    }
} catch { Write-Output "DurType failed: $($_.Exception.Message)" }

# ── 12. OSCL U_ user-defined fields sample ──
Write-Output "`n=== OSCL UDF VALUES ==="
$udfs = @("U_A_5", "U_A_12", "U_A15", "U_A_20", "U_A_21")
foreach ($udf in $udfs) {
    try {
        $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""$udf"" IS NOT NULL AND CAST(""$udf"" AS VARCHAR) <> '' AND CAST(""$udf"" AS VARCHAR) <> '0'"
        Write-Output "  $udf populated: $cnt / 676"
        if ($cnt -gt 0 -and $cnt -le 20) {
            $rows = Run-Reader "SELECT DISTINCT ""$udf"" FROM ""$Schema"".""OSCL"" WHERE ""$udf"" IS NOT NULL AND CAST(""$udf"" AS VARCHAR) <> '' AND CAST(""$udf"" AS VARCHAR) <> '0'"
            $vals = ($rows | ForEach-Object { $_[$udf] }) -join ", "
            Write-Output "    Values: $vals"
        } elseif ($cnt -gt 20) {
            $rows = Run-Reader "SELECT ""$udf"", COUNT(*) AS CNT FROM ""$Schema"".""OSCL"" WHERE ""$udf"" IS NOT NULL AND CAST(""$udf"" AS VARCHAR) <> '' AND CAST(""$udf"" AS VARCHAR) <> '0' GROUP BY ""$udf"" ORDER BY CNT DESC"
            foreach ($row in $rows[0..4]) {
                Write-Output ("    '{0}': {1}" -f $row[$udf], $row["CNT"])
            }
        }
    } catch { Write-Output "  $udf failed: $($_.Exception.Message)" }
}

# ── 13. OINS.contract field ──
Write-Output "`n=== OINS CONTRACT FIELD ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OINS"" WHERE ""contract"" IS NOT NULL AND ""contract"" <> 0"
    Write-Output "Equipment with contract: $cnt / 13091"
} catch { Write-Output "OINS contract failed: $($_.Exception.Message)" }

# ── 14. OSCL.itemGroup cross-reference ──
Write-Output "`n=== OSCL CALLS BY ITEM GROUP ==="
try {
    $rows = Run-Reader @"
SELECT B."ItmsGrpCod", B."ItmsGrpNam", COUNT(*) AS calls
FROM "$Schema"."OSCL" S
INNER JOIN "$Schema"."OITM" M ON S."itemCode" = M."ItemCode"
INNER JOIN "$Schema"."OITB" B ON M."ItmsGrpCod" = B."ItmsGrpCod"
GROUP BY B."ItmsGrpCod", B."ItmsGrpNam"
ORDER BY calls DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Group {0} ({1}): {2} calls" -f $row["ItmsGrpCod"], $row["ItmsGrpNam"], $row["calls"])
    }
} catch { Write-Output "OSCL by item group failed: $($_.Exception.Message)" }

# ── 15. Service call -> linked documents detail ──
Write-Output "`n=== SCL4 LINKED DOC TYPES ==="
try {
    $rows = Run-Reader @"
SELECT S."PartType", S."ObjectType", COUNT(*) AS CNT
FROM "$Schema"."SCL4" S
GROUP BY S."PartType", S."ObjectType"
ORDER BY CNT DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  PartType={0}, ObjectType={1}: {2}" -f $row["PartType"], $row["ObjectType"], $row["CNT"])
    }
} catch { Write-Output "SCL4 doc types failed: $($_.Exception.Message)" }

# ── 16. OSCL time fields check ──
Write-Output "`n=== OSCL TIME FIELDS ==="
try {
    $cnt_create_time = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""createTime"" IS NOT NULL AND ""createTime"" > 0"
    $cnt_close_time = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""closeTime"" IS NOT NULL AND ""closeTime"" > 0"
    $cnt_resp_on = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""respOnDate"" IS NOT NULL"
    $cnt_resolOn = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""resolOnDat"" IS NOT NULL"
    Write-Output "  createTime populated: $cnt_create_time / 676"
    Write-Output "  closeTime populated: $cnt_close_time / 676"
    Write-Output "  respOnDate populated: $cnt_resp_on / 676"
    Write-Output "  resolOnDat populated: $cnt_resolOn / 676"
} catch { Write-Output "Time fields failed: $($_.Exception.Message)" }

# ── 17. OSCL Queue values ──
Write-Output "`n=== OSCL QUEUE VALUES ==="
try {
    $rows = Run-Reader "SELECT ""Queue"", COUNT(*) AS CNT FROM ""$Schema"".""OSCL"" WHERE COALESCE(""Queue"",'') <> '' GROUP BY ""Queue"" ORDER BY CNT DESC"
    foreach ($row in $rows) {
        Write-Output ("  Queue '{0}': {1}" -f $row["Queue"], $row["CNT"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (no queues)" }
} catch { Write-Output "Queue failed: $($_.Exception.Message)" }

# ── 18. SCL6 multiple activities per call ──
Write-Output "`n=== SCL6 ACTIVITIES PER CALL ==="
try {
    $rows = Run-Reader @"
SELECT acts, COUNT(*) AS calls FROM (
    SELECT "SrcvCallID", COUNT(*) AS acts FROM "$Schema"."SCL6" GROUP BY "SrcvCallID"
) GROUP BY acts ORDER BY acts
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} activities: {1} calls" -f $row["acts"], $row["calls"])
    }
} catch { Write-Output "Activities per call failed: $($_.Exception.Message)" }

# ── 19. OSCL.createDate min/max workaround ──
Write-Output "`n=== OSCL DATE RANGE (workaround) ==="
try {
    $min = Run-Scalar "SELECT TOP 1 ""createDate"" FROM ""$Schema"".""OSCL"" ORDER BY ""createDate"" ASC"
    $max = Run-Scalar "SELECT TOP 1 ""createDate"" FROM ""$Schema"".""OSCL"" ORDER BY ""createDate"" DESC"
    Write-Output "  Earliest: $min"
    Write-Output "  Latest: $max"
} catch { Write-Output "Date range failed: $($_.Exception.Message)" }

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DISCOVERY3 COMPLETE ==="
