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

function Get-Columns {
    param([string]$table)
    $rows = Run-Reader "SELECT COLUMN_NAME, DATA_TYPE_NAME, LENGTH FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME = '$table' ORDER BY POSITION"
    return $rows
}

# ── 1. OSCL actual column names ──
Write-Output "`n=== OSCL COLUMNS ==="
$cols = Get-Columns "OSCL"
foreach ($c in $cols) {
    Write-Output ("  {0} ({1}, len={2})" -f $c["COLUMN_NAME"], $c["DATA_TYPE_NAME"], $c["LENGTH"])
}

# ── 2. SCL1 columns (empty table - check if it exists structurally) ──
Write-Output "`n=== SCL1 COLUMNS ==="
$cols = Get-Columns "SCL1"
foreach ($c in $cols) {
    Write-Output ("  {0} ({1})" -f $c["COLUMN_NAME"], $c["DATA_TYPE_NAME"])
}

# ── 3. SCL6 columns (794 rows - likely the activities table) ──
Write-Output "`n=== SCL6 COLUMNS ==="
$cols = Get-Columns "SCL6"
foreach ($c in $cols) {
    Write-Output ("  {0} ({1})" -f $c["COLUMN_NAME"], $c["DATA_TYPE_NAME"])
}

# ── 4. SCL6 sample data - activities with HandledBy ──
Write-Output "`n=== SCL6 ACTIVITY SAMPLE ==="
try {
    $rows = Run-Reader @"
SELECT TOP 15 "SrcvCallID", "Line", "HandledBy", "StartDate", "EndDate", "StartTime", "EndTime", "Duration", "DurType", "Close"
FROM "$Schema"."SCL6"
ORDER BY "SrcvCallID" DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Call {0} Line {1}: handler={2}, {3} to {4}, dur={5}, type={6}, closed={7}" -f $row["SrcvCallID"], $row["Line"], $row["HandledBy"], $row["StartDate"], $row["EndDate"], $row["Duration"], $row["DurType"], $row["Close"])
    }
} catch { Write-Output "SCL6 sample failed: $($_.Exception.Message)" }

# ── 5. SCL6 distinct HandledBy → OHEM check ──
Write-Output "`n=== SCL6 HANDLED BY -> OHEM ==="
try {
    $rows = Run-Reader @"
SELECT S."HandledBy", E."firstName", E."lastName", E."dept", COUNT(*) AS activities
FROM "$Schema"."SCL6" S
LEFT JOIN "$Schema"."OHEM" E ON S."HandledBy" = E."empID"
WHERE S."HandledBy" IS NOT NULL AND S."HandledBy" <> 0
GROUP BY S."HandledBy", E."firstName", E."lastName", E."dept"
ORDER BY activities DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Handler {0}: {1} {2} (dept={3}) - {4} activities" -f $row["HandledBy"], $row["firstName"], $row["lastName"], $row["dept"], $row["activities"])
    }
} catch { Write-Output "SCL6 handler check failed: $($_.Exception.Message)" }

# ── 6. OINS columns ──
Write-Output "`n=== OINS COLUMNS ==="
$cols = Get-Columns "OINS"
foreach ($c in $cols) {
    Write-Output ("  {0} ({1})" -f $c["COLUMN_NAME"], $c["DATA_TYPE_NAME"])
}

# ── 7. OCTR columns ──
Write-Output "`n=== OCTR COLUMNS ==="
$cols = Get-Columns "OCTR"
foreach ($c in $cols) {
    Write-Output ("  {0} ({1})" -f $c["COLUMN_NAME"], $c["DATA_TYPE_NAME"])
}

# ── 8. OSCL date range ──
Write-Output "`n=== OSCL DATE RANGE ==="
try {
    $rows = Run-Reader @"
SELECT MIN("createDate") AS min_date, MAX("createDate") AS max_date,
       MIN("closeDate") AS min_close, MAX("closeDate") AS max_close
FROM "$Schema"."OSCL"
"@
    if ($rows.Count -gt 0) {
        Write-Output ("  Earliest create: {0}" -f $rows[0]["min_date"])
        Write-Output ("  Latest create: {0}" -f $rows[0]["max_date"])
        Write-Output ("  Earliest close: {0}" -f $rows[0]["min_close"])
        Write-Output ("  Latest close: {0}" -f $rows[0]["max_close"])
    }
} catch { Write-Output "OSCL date range failed: $($_.Exception.Message)" }

# ── 9. OSCL calls by year-month ──
Write-Output "`n=== OSCL CALLS BY YEAR ==="
try {
    $rows = Run-Reader @"
SELECT YEAR("createDate") AS yr, COUNT(*) AS cnt
FROM "$Schema"."OSCL"
GROUP BY YEAR("createDate")
ORDER BY yr
"@
    foreach ($row in $rows) {
        Write-Output ("  {0}: {1} calls" -f $row["yr"], $row["cnt"])
    }
} catch { Write-Output "OSCL by year failed: $($_.Exception.Message)" }

# ── 10. OINS key fields (with correct column names once known) ──
Write-Output "`n=== OINS FIELD POPULATION (corrected) ==="
try {
    $total = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OINS"""
    Write-Output "Total equipment: $total"
    
    $checkFields = @("customer", "custmrName", "itemCode", "manufSN", "internalSN", "insID")
    foreach ($f in $checkFields) {
        try {
            $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OINS"" WHERE ""$f"" IS NOT NULL AND CAST(""$f"" AS VARCHAR) <> ''"
            Write-Output ("  {0}: {1} / {2}" -f $f, $cnt, $total)
        } catch {
            Write-Output ("  {0}: failed - {1}" -f $f, $_.Exception.Message)
        }
    }
} catch { Write-Output "OINS check failed: $($_.Exception.Message)" }

# ── 11. OINS sample with all non-null columns ──
Write-Output "`n=== OINS SAMPLE (10 rows) ==="
try {
    $rows = Run-Reader "SELECT TOP 10 ""insID"", ""itemCode"", ""customer"", ""custmrName"", ""manufSN"", ""internalSN"", ""status"" FROM ""$Schema"".""OINS"" ORDER BY ""insID"" DESC"
    foreach ($row in $rows) {
        Write-Output ("  insID={0}, item={1}, cust={2} ({3}), mfSN={4}, intSN={5}, status={6}" -f $row["insID"], $row["itemCode"], $row["customer"], $row["custmrName"], $row["manufSN"], $row["internalSN"], $row["status"])
    }
} catch { Write-Output "OINS sample failed: $($_.Exception.Message)" }

# ── 12. SCL4 columns ──
Write-Output "`n=== SCL4 COLUMNS ==="
$cols = Get-Columns "SCL4"
foreach ($c in $cols) {
    Write-Output ("  {0} ({1})" -f $c["COLUMN_NAME"], $c["DATA_TYPE_NAME"])
}

# ── 13. SCL4 sample ──
Write-Output "`n=== SCL4 SAMPLE ==="
try {
    $rows = Run-Reader "SELECT TOP 10 ""SrcvCallID"", ""Line"", ""DocNumber"", ""PartType"", ""DocPstDate"", ""DocAbs"" FROM ""$Schema"".""SCL4"""
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: line={1}, docNum={2}, partType={3}, docDate={4}, docAbs={5}" -f $row["SrcvCallID"], $row["Line"], $row["DocNumber"], $row["PartType"], $row["DocPstDate"], $row["DocAbs"])
    }
} catch { Write-Output "SCL4 sample failed: $($_.Exception.Message)" }

# ── 14. SCL2 columns and sample ──
Write-Output "`n=== SCL2 COLUMNS ==="
$cols = Get-Columns "SCL2"
foreach ($c in $cols) {
    Write-Output ("  {0} ({1})" -f $c["COLUMN_NAME"], $c["DATA_TYPE_NAME"])
}

# ── 15. Position names via different approach ──
Write-Output "`n=== POSITION NAMES ==="
try {
    $rows = Run-Reader "SELECT ""posID"", ""name"" FROM ""$Schema"".""OHPS"" ORDER BY ""posID"""
    foreach ($row in $rows) {
        Write-Output ("  {0}: {1}" -f $row["posID"], $row["name"])
    }
} catch { Write-Output "OHPS failed: $($_.Exception.Message)" }

# ── 16. SCL6 ActualDur stats ──
Write-Output "`n=== SCL6 DURATION STATS ==="
try {
    $rows = Run-Reader @"
SELECT 
    COUNT(*) AS total_activities,
    SUM(CASE WHEN "Duration" > 0 THEN 1 ELSE 0 END) AS has_duration,
    SUM(CASE WHEN "ActualDur" > 0 THEN 1 ELSE 0 END) AS has_actual_dur,
    AVG(CASE WHEN "Duration" > 0 THEN "Duration" ELSE NULL END) AS avg_duration,
    AVG(CASE WHEN "ActualDur" > 0 THEN "ActualDur" ELSE NULL END) AS avg_actual_dur
FROM "$Schema"."SCL6"
"@
    $r = $rows[0]
    Write-Output ("  Total: {0}, HasDuration: {1}, HasActualDur: {2}" -f $r["total_activities"], $r["has_duration"], $r["has_actual_dur"])
    Write-Output ("  AvgDuration: {0}, AvgActualDur: {1}" -f $r["avg_duration"], $r["avg_actual_dur"])
} catch { Write-Output "SCL6 duration stats failed: $($_.Exception.Message)" }

# ── 17. Check if service calls link to financial docs ──
Write-Output "`n=== SERVICE CALL -> FINANCIAL DOC LINKAGE ==="
try {
    $rows = Run-Reader @"
SELECT "PartType", COUNT(*) AS CNT 
FROM "$Schema"."SCL4"
GROUP BY "PartType"
ORDER BY CNT DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  PartType {0}: {1}" -f $row["PartType"], $row["CNT"])
    }
} catch { Write-Output "SCL4 PartType failed: $($_.Exception.Message)" }

# ── 18. Service technicians by dept 6 ──
Write-Output "`n=== SERVICE DEPT EMPLOYEES ==="
try {
    $rows = Run-Reader @"
SELECT "empID", "firstName", "lastName", "position", "Active"
FROM "$Schema"."OHEM"
WHERE "dept" = 6
ORDER BY "empID"
"@
    foreach ($row in $rows) {
        Write-Output ("  ID={0}: {1} {2}, position={3}, active={4}" -f $row["empID"], $row["firstName"], $row["lastName"], $row["position"], $row["Active"])
    }
} catch { Write-Output "Service employees failed: $($_.Exception.Message)" }

# ── 19. Check if OSCL has U_ user-defined fields for problem type ──
Write-Output "`n=== OSCL USER-DEFINED FIELDS (U_*) ==="
try {
    $rows = Run-Reader "SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME = 'OSCL' AND COLUMN_NAME LIKE 'U_%' ORDER BY POSITION"
    foreach ($row in $rows) {
        Write-Output ("  {0}" -f $row["COLUMN_NAME"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (none)" }
} catch { Write-Output "UDF check failed: $($_.Exception.Message)" }

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DISCOVERY2 COMPLETE ==="
