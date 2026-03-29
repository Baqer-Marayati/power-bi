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

# ── 1. Problem type lookup (OSPT - Service Problem Types) ──
Write-Output "`n=== OSPT - SERVICE PROBLEM TYPES ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSPT"""
    Write-Output "OSPT rows: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSPT"" ORDER BY ""Code"""
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "OSPT not found: $($_.Exception.Message)" }

# ── 2. Problem sub type lookup (OSPST or similar) ──
Write-Output "`n=== OSPS - SERVICE PROBLEM SUB TYPES ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSPS"""
    Write-Output "OSPS rows: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSPS"""
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "OSPS not found, trying alternatives..." }

# try OSPB
try {
    $rows = Run-Reader "SELECT TABLE_NAME FROM SYS.TABLES WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME LIKE 'OSP%'"
    Write-Output "  Tables matching OSP*: $(($rows | ForEach-Object { $_['TABLE_NAME'] }) -join ', ')"
} catch { Write-Output "  OSP* search failed" }

# ── 3. Call type lookup (OSCT) ──
Write-Output "`n=== OSCT - SERVICE CALL TYPES ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCT"""
    Write-Output "OSCT rows: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSCT"""
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "OSCT not found: $($_.Exception.Message)" }

# ── 4. Call origin lookup (OSCN) ──
Write-Output "`n=== OSCN - SERVICE CALL ORIGINS ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCN"""
    Write-Output "OSCN rows: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSCN"""
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "OSCN not found: $($_.Exception.Message)" }

# ── 5. All service-related lookup tables ──
Write-Output "`n=== ALL SERVICE LOOKUP TABLES ==="
try {
    $rows = Run-Reader "SELECT TABLE_NAME FROM SYS.TABLES WHERE SCHEMA_NAME = '$Schema' AND (TABLE_NAME LIKE 'OSC%' OR TABLE_NAME LIKE 'SCL%' OR TABLE_NAME LIKE 'OSP%' OR TABLE_NAME LIKE 'OSST%') ORDER BY TABLE_NAME"
    foreach ($row in $rows) {
        $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""$($row['TABLE_NAME'])"""
        Write-Output ("  {0}: {1} rows" -f $row["TABLE_NAME"], $cnt)
    }
} catch { Write-Output "Lookup table scan failed: $($_.Exception.Message)" }

# ── 6. OSCL with resolved problem type names ──
Write-Output "`n=== OSCL PROBLEM TYPES RESOLVED ==="
try {
    $rows = Run-Reader @"
SELECT S."problemTyp", P."Name" AS problemName, COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OSPT" P ON S."problemTyp" = P."Code"
WHERE S."problemTyp" IS NOT NULL AND S."problemTyp" <> ''
GROUP BY S."problemTyp", P."Name"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}): {2} calls" -f $row["problemTyp"], $row["problemName"], $row["cnt"])
    }
} catch { Write-Output "Resolved problem types failed: $($_.Exception.Message)" }

# ── 7. OSCL with resolved call type names ──
Write-Output "`n=== OSCL CALL TYPES RESOLVED ==="
try {
    $rows = Run-Reader @"
SELECT S."callType", T."Name" AS typeName, COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OSCT" T ON S."callType" = T."Code"
WHERE S."callType" IS NOT NULL
GROUP BY S."callType", T."Name"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}): {2} calls" -f $row["callType"], $row["typeName"], $row["cnt"])
    }
} catch { Write-Output "Resolved call types failed: $($_.Exception.Message)" }

# ── 8. OSCL.ProSubType resolved ──
Write-Output "`n=== OSCL PROBLEM SUB TYPES RESOLVED ==="
try {
    $rows = Run-Reader @"
SELECT S."ProSubType", P."Name" AS subTypeName, COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OSPS" P ON S."ProSubType" = P."Code"
WHERE S."ProSubType" IS NOT NULL AND S."ProSubType" <> ''
GROUP BY S."ProSubType", P."Name"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}): {2} calls" -f $row["ProSubType"], $row["subTypeName"], $row["cnt"])
    }
} catch { Write-Output "Resolved sub types failed: $($_.Exception.Message)" }

# ── 9. OSCL origin resolved ──
Write-Output "`n=== OSCL ORIGINS RESOLVED ==="
try {
    $rows = Run-Reader @"
SELECT S."origin", O."Name" AS originName, COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OSCN" O ON S."origin" = O."Code"
GROUP BY S."origin", O."Name"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}): {2} calls" -f $row["origin"], $row["originName"], $row["cnt"])
    }
} catch { Write-Output "Resolved origins failed: $($_.Exception.Message)" }

# ── 10. OSCL.U_A_5 - likely warranty or similar ──
Write-Output "`n=== OSCL.U_A_5 cross with item groups ==="
try {
    $rows = Run-Reader @"
SELECT S."U_A_5", COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
GROUP BY S."U_A_5"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  U_A_5={0}: {1}" -f $row["U_A_5"], $row["cnt"])
    }
} catch { Write-Output "U_A_5 analysis failed: $($_.Exception.Message)" }

# ── 11. UDF field names from CUFD ──
Write-Output "`n=== USER-DEFINED FIELD DEFINITIONS (OSCL) ==="
try {
    $rows = Run-Reader @"
SELECT "AliasID", "Descr", "TableID"
FROM "$Schema"."CUFD" 
WHERE "TableID" = 'OSCL'
ORDER BY "AliasID"
"@
    foreach ($row in $rows) {
        Write-Output ("  {0}: {1} (table={2})" -f $row["AliasID"], $row["Descr"], $row["TableID"])
    }
} catch { Write-Output "CUFD query failed: $($_.Exception.Message)" }

# ── 12. UDF field names from CUFD for SCL6 ──
Write-Output "`n=== USER-DEFINED FIELD DEFINITIONS (SCL6) ==="
try {
    $rows = Run-Reader @"
SELECT "AliasID", "Descr", "TableID"
FROM "$Schema"."CUFD" 
WHERE "TableID" = 'SCL6'
ORDER BY "AliasID"
"@
    foreach ($row in $rows) {
        Write-Output ("  {0}: {1}" -f $row["AliasID"], $row["Descr"])
    }
} catch { Write-Output "SCL6 CUFD failed: $($_.Exception.Message)" }

# ── 13. How many calls have items in group 139 (#N/A) - what are those items? ──
Write-Output "`n=== GROUP 139 (#N/A) ITEMS ON SERVICE CALLS ==="
try {
    $rows = Run-Reader @"
SELECT M."ItemCode", M."ItemName", COUNT(*) AS calls
FROM "$Schema"."OSCL" S
INNER JOIN "$Schema"."OITM" M ON S."itemCode" = M."ItemCode"
WHERE M."ItmsGrpCod" = 139
GROUP BY M."ItemCode", M."ItemName"
ORDER BY calls DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}): {2} calls" -f $row["ItemCode"], $row["ItemName"], $row["calls"])
    }
} catch { Write-Output "Group 139 items failed: $($_.Exception.Message)" }

# ── 14. Calls WITHOUT itemCode - what do they have? ──
Write-Output "`n=== CALLS WITHOUT ITEM CODE ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE COALESCE(""itemCode"",'') = ''"
    Write-Output "Calls with no itemCode: $cnt / 676"
    if ($cnt -gt 0) {
        $rows = Run-Reader @"
SELECT TOP 10 "callID", "subject", "customer", "custmrName", "manufSN", "insID"
FROM "$Schema"."OSCL"
WHERE COALESCE("itemCode",'') = ''
ORDER BY "callID" DESC
"@
        foreach ($row in $rows) {
            Write-Output ("  Call {0}: subject={1}, cust={2}, sn={3}, insID={4}" -f $row["callID"], $row["subject"], $row["custmrName"], $row["manufSN"], $row["insID"])
        }
    }
} catch { Write-Output "No-item calls failed: $($_.Exception.Message)" }

# ── 15. Financial docs linked to service calls via SCL4 ──
Write-Output "`n=== SCL4 -> OINV DETAIL (PartType I = Invoice) ==="
try {
    $rows = Run-Reader @"
SELECT TOP 10 S."SrcvCallID", S."DocAbs", I."DocTotal", I."CardCode", I."CardName"
FROM "$Schema"."SCL4" S
INNER JOIN "$Schema"."OINV" I ON S."DocAbs" = I."DocEntry"
WHERE S."PartType" = 'I'
"@
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: Invoice DocEntry={1}, total={2}, customer={3}" -f $row["SrcvCallID"], $row["DocAbs"], $row["DocTotal"], $row["CardName"])
    }
} catch { Write-Output "SCL4->OINV failed: $($_.Exception.Message)" }

Write-Output "`n=== SCL4 -> ODLN DETAIL (PartType N = Delivery) ==="
try {
    $rows = Run-Reader @"
SELECT TOP 10 S."SrcvCallID", S."DocAbs", D."DocTotal", D."CardCode", D."CardName"
FROM "$Schema"."SCL4" S
INNER JOIN "$Schema"."ODLN" D ON S."DocAbs" = D."DocEntry"
WHERE S."PartType" = 'N'
"@
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: Delivery DocEntry={1}, total={2}, customer={3}" -f $row["SrcvCallID"], $row["DocAbs"], $row["DocTotal"], $row["CardName"])
    }
} catch { Write-Output "SCL4->ODLN failed: $($_.Exception.Message)" }

# ── 16. Check if INV1/DLN1 lines link back to service calls ──
Write-Output "`n=== INV1 LINES LINKED TO SERVICE CALLS ==="
try {
    $rows = Run-Reader "SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME = 'INV1' AND (COLUMN_NAME LIKE '%Srvc%' OR COLUMN_NAME LIKE '%Call%' OR COLUMN_NAME LIKE '%Base%') ORDER BY POSITION"
    Write-Output "  Relevant INV1 columns: $(($rows | ForEach-Object { $_['COLUMN_NAME'] }) -join ', ')"
} catch { Write-Output "INV1 columns failed: $($_.Exception.Message)" }

try {
    $rows = Run-Reader "SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME = 'DLN1' AND (COLUMN_NAME LIKE '%Srvc%' OR COLUMN_NAME LIKE '%Call%' OR COLUMN_NAME LIKE '%Base%') ORDER BY POSITION"
    Write-Output "  Relevant DLN1 columns: $(($rows | ForEach-Object { $_['COLUMN_NAME'] }) -join ', ')"
} catch { Write-Output "DLN1 columns failed: $($_.Exception.Message)" }

# ── 17. Sample OSCL with all timing fields ──
Write-Output "`n=== OSCL TIMING SAMPLE ==="
try {
    $rows = Run-Reader @"
SELECT TOP 5 "callID", "createDate", "createTime", "closeDate", "closeTime", 
    "respOnDate", "respOnTime", "resolOnDat", "resolOnTim", "respByDate", "resolDate"
FROM "$Schema"."OSCL"
WHERE "closeDate" IS NOT NULL
ORDER BY "callID" DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: created={1} t={2}, closed={3} t={4}, respOn={5} t={6}, resolOn={7} t={8}" -f $row["callID"], $row["createDate"], $row["createTime"], $row["closeDate"], $row["closeTime"], $row["respOnDate"], $row["respOnTime"], $row["resolOnDat"], $row["resolOnTim"])
    }
} catch { Write-Output "Timing sample failed: $($_.Exception.Message)" }

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DISCOVERY4 COMPLETE ==="
