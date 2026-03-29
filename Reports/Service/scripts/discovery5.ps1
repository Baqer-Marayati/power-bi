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

# ── 1. OSCO - 10 rows - what is it? ──
Write-Output "=== OSCO (10 rows) ==="
try {
    $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSCO"""
    if ($rows.Count -gt 0) {
        Write-Output ("  Columns: " + ($rows[0].Keys -join ", "))
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "OSCO failed: $($_.Exception.Message)" }

# ── 2. OSCP - 32 rows ──
Write-Output "`n=== OSCP (32 rows) ==="
try {
    $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSCP"""
    if ($rows.Count -gt 0) {
        Write-Output ("  Columns: " + ($rows[0].Keys -join ", "))
        foreach ($row in $rows[0..9]) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "OSCP failed: $($_.Exception.Message)" }

# ── 3. OSCS - 4 rows ──
Write-Output "`n=== OSCS (4 rows) - Call Statuses ==="
try {
    $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSCS"""
    if ($rows.Count -gt 0) {
        Write-Output ("  Columns: " + ($rows[0].Keys -join ", "))
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "OSCS failed: $($_.Exception.Message)" }

# ── 4. OSST - 3 rows ──
Write-Output "`n=== OSST (3 rows) ==="
try {
    $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSST"""
    if ($rows.Count -gt 0) {
        Write-Output ("  Columns: " + ($rows[0].Keys -join ", "))
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "OSST failed: $($_.Exception.Message)" }

# ── 5. SCL3 - 108 rows ──
Write-Output "`n=== SCL3 COLUMNS (108 rows) ==="
try {
    $cols = Run-Reader "SELECT COLUMN_NAME, DATA_TYPE_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME = 'SCL3' ORDER BY POSITION"
    foreach ($c in $cols) { Write-Output ("  {0} ({1})" -f $c["COLUMN_NAME"], $c["DATA_TYPE_NAME"]) }
} catch { Write-Output "SCL3 columns failed" }

Write-Output "`n=== SCL3 SAMPLE ==="
try {
    $rows = Run-Reader "SELECT TOP 5 * FROM ""$Schema"".""SCL3"""
    if ($rows.Count -gt 0) {
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "SCL3 sample failed: $($_.Exception.Message)" }

# ── 6. SCL7 - 153 rows ──
Write-Output "`n=== SCL7 COLUMNS (153 rows) ==="
try {
    $cols = Run-Reader "SELECT COLUMN_NAME, DATA_TYPE_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME = 'SCL7' ORDER BY POSITION"
    foreach ($c in $cols) { Write-Output ("  {0} ({1})" -f $c["COLUMN_NAME"], $c["DATA_TYPE_NAME"]) }
} catch { Write-Output "SCL7 columns failed" }

Write-Output "`n=== SCL7 SAMPLE ==="
try {
    $rows = Run-Reader "SELECT TOP 5 * FROM ""$Schema"".""SCL7"""
    if ($rows.Count -gt 0) {
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "SCL7 sample failed: $($_.Exception.Message)" }

# ── 7. OSCL.callType resolved via OSCT ──
Write-Output "`n=== OSCL CALL TYPES VIA OSCT ==="
try {
    $rows = Run-Reader @"
SELECT S."callType", T."Name", COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OSCT" T ON S."callType" = T."callTypeID"
GROUP BY S."callType", T."Name"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  callType={0} ({1}): {2}" -f $row["callType"], $row["Name"], $row["cnt"])
    }
} catch { Write-Output "Call type resolution failed: $($_.Exception.Message)" }

# ── 8. OSCP columns and sample - likely problem types ──
Write-Output "`n=== OSCP FULL CONTENT ==="
try {
    $cols = Run-Reader "SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME = 'OSCP' ORDER BY POSITION"
    Write-Output ("  Columns: " + (($cols | ForEach-Object { $_["COLUMN_NAME"] }) -join ", "))
    $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSCP"" ORDER BY 1"
    foreach ($row in $rows) {
        $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
        Write-Output ("  " + ($vals -join " | "))
    }
} catch { Write-Output "OSCP detail failed: $($_.Exception.Message)" }

# ── 9. Items on service calls linked to parts (via INV1.isSrvCall or DLN1.isSrvCall) ──
Write-Output "`n=== DLN1 LINES LINKED TO SERVICE CALLS ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""DLN1"" WHERE ""isSrvCall"" = 'Y'"
    Write-Output "DLN1 lines flagged as service call: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader @"
SELECT TOP 10 D."DocEntry", D."ItemCode", D."Dscription", D."Quantity", D."Price", D."LineTotal", D."BaseEntry"
FROM "$Schema"."DLN1" D
WHERE D."isSrvCall" = 'Y'
"@
        foreach ($row in $rows) {
            Write-Output ("  Doc {0}: item={1} ({2}), qty={3}, price={4}, total={5}, baseEntry={6}" -f $row["DocEntry"], $row["ItemCode"], $row["Dscription"], $row["Quantity"], $row["Price"], $row["LineTotal"], $row["BaseEntry"])
        }
    }
} catch { Write-Output "DLN1 service link failed: $($_.Exception.Message)" }

Write-Output "`n=== INV1 LINES LINKED TO SERVICE CALLS ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""INV1"" WHERE ""isSrvCall"" = 'Y'"
    Write-Output "INV1 lines flagged as service call: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader @"
SELECT TOP 10 I."DocEntry", I."ItemCode", I."Dscription", I."Quantity", I."Price", I."LineTotal", I."BaseEntry"
FROM "$Schema"."INV1" I
WHERE I."isSrvCall" = 'Y'
"@
        foreach ($row in $rows) {
            Write-Output ("  Doc {0}: item={1} ({2}), qty={3}, price={4}, total={5}, baseEntry={6}" -f $row["DocEntry"], $row["ItemCode"], $row["Dscription"], $row["Quantity"], $row["Price"], $row["LineTotal"], $row["BaseEntry"])
        }
    }
} catch { Write-Output "INV1 service link failed: $($_.Exception.Message)" }

# ── 10. OSCL UDF counter fields analysis ──
Write-Output "`n=== OSCL COUNTER FIELDS (U_A15=BK, U_A_20=C, U_A_21=M, etc) ==="
try {
    $cnt_15 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A15"" IS NOT NULL AND ""U_A15"" <> 0"
    $cnt_20 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_20"" IS NOT NULL AND ""U_A_20"" <> 0"
    $cnt_21 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_21"" IS NOT NULL AND ""U_A_21"" <> 0"
    $cnt_22 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_22"" IS NOT NULL AND ""U_A_22"" <> 0"
    $cnt_23 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_23"" IS NOT NULL AND ""U_A_23"" <> 0"
    $cnt_24 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_24"" IS NOT NULL AND ""U_A_24"" <> 0"
    $cnt_25 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_25"" IS NOT NULL AND ""U_A_25"" <> 0"
    $cnt_26 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_26"" IS NOT NULL AND ""U_A_26"" <> 0"
    $cnt_27 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_27"" IS NOT NULL AND ""U_A_27"" <> 0"
    $cnt_28 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_28"" IS NOT NULL AND ""U_A_28"" <> 0"
    $cnt_29 = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE ""U_A_29"" IS NOT NULL AND ""U_A_29"" <> 0"
    Write-Output "  U_A15 (BK): $cnt_15 / 676"
    Write-Output "  U_A_20 (C): $cnt_20 / 676"
    Write-Output "  U_A_21 (M): $cnt_21 / 676"
    Write-Output "  U_A_22 (Y): $cnt_22 / 676"
    Write-Output "  U_A_23 (Small BW): $cnt_23 / 676"
    Write-Output "  U_A_24 (Large BW): $cnt_24 / 676"
    Write-Output "  U_A_25 (Small Color): $cnt_25 / 676"
    Write-Output "  U_A_26 (Large Color): $cnt_26 / 676"
    Write-Output "  U_A_27 (Total Small): $cnt_27 / 676"
    Write-Output "  U_A_28 (Total Large): $cnt_28 / 676"
    Write-Output "  U_A_29 (Total): $cnt_29 / 676"
} catch { Write-Output "Counter fields failed: $($_.Exception.Message)" }

# ── 11. Calls with multiple activities in SCL6 (check if different technicians) ──
Write-Output "`n=== MULTI-ACTIVITY CALLS WITH DIFFERENT TECHNICIANS ==="
try {
    $rows = Run-Reader @"
SELECT "SrcvCallID", COUNT(DISTINCT "Technician") AS distinct_techs, COUNT(*) AS activities
FROM "$Schema"."SCL6"
WHERE "Technician" IS NOT NULL AND "Technician" <> 0
GROUP BY "SrcvCallID"
HAVING COUNT(*) > 1
ORDER BY distinct_techs DESC, activities DESC
"@
    Write-Output "  Calls with multiple activities: $($rows.Count)"
    foreach ($row in $rows[0..9]) {
        Write-Output ("  Call {0}: {1} activities, {2} distinct techs" -f $row["SrcvCallID"], $row["activities"], $row["distinct_techs"])
    }
} catch { Write-Output "Multi-activity check failed: $($_.Exception.Message)" }

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DISCOVERY5 COMPLETE ==="
