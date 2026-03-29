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

# ── 1. OSCL problemTyp resolved via OSCP ──
Write-Output "=== OSCL PROBLEM TYPES RESOLVED (via OSCP) ==="
try {
    $rows = Run-Reader @"
SELECT S."problemTyp", P."Name" AS problemName, COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OSCP" P ON S."problemTyp" = P."prblmTypID"
WHERE S."problemTyp" IS NOT NULL AND S."problemTyp" <> ''
GROUP BY S."problemTyp", P."Name"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}): {2} calls" -f $row["problemTyp"], $row["problemName"], $row["cnt"])
    }
} catch { Write-Output "Resolved problem types failed: $($_.Exception.Message)" }

# ── 2. OSCL origin resolved via OSCO ──
Write-Output "`n=== OSCL ORIGINS RESOLVED (via OSCO) ==="
try {
    $rows = Run-Reader @"
SELECT S."origin", O."Name" AS originName, COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OSCO" O ON S."origin" = O."originID"
GROUP BY S."origin", O."Name"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  origin={0} ({1}): {2} calls" -f $row["origin"], $row["originName"], $row["cnt"])
    }
} catch { Write-Output "Resolved origins failed: $($_.Exception.Message)" }

# ── 3. OSCL ProSubType - check if there's a lookup table ──
Write-Output "`n=== PROBLEM SUB TYPES LOOKUP ==="
try {
    $rows = Run-Reader "SELECT TABLE_NAME FROM SYS.TABLES WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME LIKE 'OSPS%' ORDER BY TABLE_NAME"
    Write-Output ("  Tables: " + (($rows | ForEach-Object { $_["TABLE_NAME"] }) -join ", "))
} catch { Write-Output "OSPS search failed" }

try {
    $rows = Run-Reader "SELECT TABLE_NAME FROM SYS.TABLES WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME LIKE '%SUB%' ORDER BY TABLE_NAME"
    Write-Output ("  SUB tables: " + (($rows | ForEach-Object { $_["TABLE_NAME"] }) -join ", "))
} catch { Write-Output "SUB search failed" }

# try OSPP (problem sub types)
Write-Output "`n=== OSPP (Problem Sub Types?) ==="
try {
    $cols = Run-Reader "SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS WHERE SCHEMA_NAME = '$Schema' AND TABLE_NAME = 'OSPP' ORDER BY POSITION"
    Write-Output ("  Columns: " + (($cols | ForEach-Object { $_["COLUMN_NAME"] }) -join ", "))
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSPP"""
    Write-Output "  Rows: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader "SELECT * FROM ""$Schema"".""OSPP"""
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "OSPP failed: $($_.Exception.Message)" }

# ── 4. Check the OSCL ProSubType relationship ──
Write-Output "`n=== OSCL ProSubType Distinct Values with Problem Type ==="
try {
    $rows = Run-Reader @"
SELECT S."problemTyp", P."Name", S."ProSubType", COUNT(*) AS cnt
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OSCP" P ON S."problemTyp" = P."prblmTypID"
WHERE S."ProSubType" IS NOT NULL AND S."ProSubType" <> ''
GROUP BY S."problemTyp", P."Name", S."ProSubType"
ORDER BY cnt DESC
"@
    foreach ($row in $rows[0..19]) {
        Write-Output ("  problemTyp={0} ({1}), subType={2}: {3} calls" -f $row["problemTyp"], $row["Name"], $row["ProSubType"], $row["cnt"])
    }
} catch { Write-Output "ProSubType x problemTyp failed: $($_.Exception.Message)" }

# ── 5. Check how OSCL.insID links to OINS ──
Write-Output "`n=== OSCL -> OINS EQUIPMENT CARD LINKAGE ==="
try {
    $rows = Run-Reader @"
SELECT TOP 10 S."callID", S."insID", I."itemCode", I."itemName", I."customer", I."custmrName"
FROM "$Schema"."OSCL" S
INNER JOIN "$Schema"."OINS" I ON S."insID" = I."insID"
WHERE S."insID" IS NOT NULL AND S."insID" > 0
ORDER BY S."callID" DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: insID={1}, item={2}, customer={3}" -f $row["callID"], $row["insID"], $row["itemCode"], $row["custmrName"])
    }
} catch { Write-Output "OSCL->OINS link failed: $($_.Exception.Message)" }

# ── 6. Check OSCL.U_A_30 (RESPON) ──
Write-Output "`n=== OSCL U_A_30 (RESPON) ==="
try {
    $rows = Run-Reader @"
SELECT "U_A_30", COUNT(*) AS cnt
FROM "$Schema"."OSCL"
WHERE "U_A_30" IS NOT NULL AND "U_A_30" <> 0
GROUP BY "U_A_30"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  RESPON={0}: {1}" -f $row["U_A_30"], $row["cnt"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (none populated)" }
} catch { Write-Output "U_A_30 failed: $($_.Exception.Message)" }

# ── 7. Financial linkage: parts cost from DLN1 via SCL4 ──
Write-Output "`n=== PARTS COST FROM DELIVERY NOTES (SCL4 -> DLN1) ==="
try {
    $rows = Run-Reader @"
SELECT TOP 10 
    S."SrcvCallID",
    D."DocEntry", 
    L."ItemCode", L."Dscription", L."Quantity", L."Price", L."LineTotal"
FROM "$Schema"."SCL4" S
INNER JOIN "$Schema"."ODLN" D ON S."DocAbs" = D."DocEntry"
INNER JOIN "$Schema"."DLN1" L ON D."DocEntry" = L."DocEntry"
WHERE S."PartType" = 'N'
ORDER BY S."SrcvCallID"
"@
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: delivery={1}, item={2} ({3}), qty={4}, price={5}, total={6}" -f $row["SrcvCallID"], $row["DocEntry"], $row["ItemCode"], $row["Dscription"], $row["Quantity"], $row["Price"], $row["LineTotal"])
    }
} catch { Write-Output "Parts cost query failed: $($_.Exception.Message)" }

# ── 8. Service revenue from invoices (SCL4 -> INV1) ──
Write-Output "`n=== SERVICE REVENUE FROM INVOICES (SCL4 -> INV1) ==="
try {
    $rows = Run-Reader @"
SELECT TOP 10
    S."SrcvCallID",
    I."DocEntry",
    L."ItemCode", L."Dscription", L."Quantity", L."Price", L."LineTotal"
FROM "$Schema"."SCL4" S
INNER JOIN "$Schema"."OINV" I ON S."DocAbs" = I."DocEntry"
INNER JOIN "$Schema"."INV1" L ON I."DocEntry" = L."DocEntry"
WHERE S."PartType" = 'I'
ORDER BY S."SrcvCallID"
"@
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: invoice={1}, item={2} ({3}), qty={4}, price={5}, total={6}" -f $row["SrcvCallID"], $row["DocEntry"], $row["ItemCode"], $row["Dscription"], $row["Quantity"], $row["Price"], $row["LineTotal"])
    }
} catch { Write-Output "Service revenue query failed: $($_.Exception.Message)" }

# ── 9. Service-related item groups (Service Labour, FSMA, etc) ──
Write-Output "`n=== SERVICE ITEM GROUPS (Labour, FSMA, etc) ==="
$svcGroups = @(172, 173, 174, 175, 176)
foreach ($g in $svcGroups) {
    try {
        $rows = Run-Reader @"
SELECT B."ItmsGrpCod", B."ItmsGrpNam", M."ItemCode", M."ItemName"
FROM "$Schema"."OITM" M
INNER JOIN "$Schema"."OITB" B ON M."ItmsGrpCod" = B."ItmsGrpCod"
WHERE B."ItmsGrpCod" = $g
"@
        foreach ($row in $rows) {
            Write-Output ("  Group {0} ({1}): {2} - {3}" -f $row["ItmsGrpCod"], $row["ItmsGrpNam"], $row["ItemCode"], $row["ItemName"])
        }
    } catch { Write-Output "Group $g failed" }
}

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DISCOVERY6 COMPLETE ==="
