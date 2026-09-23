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

# ── 1. OINS: find project-related columns we might have missed ──
Write-Output "=== OINS COLUMNS CONTAINING 'prj', 'proj', 'prg', 'code' ==="
try {
    $rows = Run-Reader @"
SELECT COLUMN_NAME, DATA_TYPE_NAME, LENGTH FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON' AND TABLE_NAME = 'OINS'
AND (UPPER(COLUMN_NAME) LIKE '%PRJ%' OR UPPER(COLUMN_NAME) LIKE '%PROJ%' 
     OR UPPER(COLUMN_NAME) LIKE '%U_%')
ORDER BY POSITION
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1}, len={2})" -f $row["COLUMN_NAME"], $row["DATA_TYPE_NAME"], $row["LENGTH"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

# ── 2. Check ALL OINS UDFs ──
Write-Output "`n=== OINS USER-DEFINED FIELDS ==="
try {
    $rows = Run-Reader @"
SELECT "AliasID", "Descr" FROM "CANON"."CUFD" WHERE "TableID" = 'OINS' ORDER BY "AliasID"
"@
    foreach ($row in $rows) {
        Write-Output ("  U_{0}: {1}" -f $row["AliasID"], $row["Descr"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (none)" }
} catch { Write-Output "CUFD OINS failed: $($_.Exception.Message)" }

# ── 3. Check OSCL UDFs we haven't explored ──
Write-Output "`n=== OSCL UDF DESCRIPTIONS REFRESHER ==="
try {
    $rows = Run-Reader @"
SELECT "AliasID", "Descr" FROM "CANON"."CUFD" WHERE "TableID" = 'OSCL' ORDER BY "AliasID"
"@
    foreach ($row in $rows) {
        Write-Output ("  U_{0}: {1}" -f $row["AliasID"], $row["Descr"])
    }
} catch { Write-Output "Failed" }

# ── 4. Production machines (IPS groups + group 139) with equipment cards - check project-like fields ──
Write-Output "`n=== PRODUCTION MACHINE EQUIPMENT CARDS (sample) ==="
try {
    $rows = Run-Reader @"
SELECT TOP 20 I."insID", I."itemCode", I."itemName", I."customer", I."custmrName", 
    I."manufSN", I."internalSN", I."status",
    M."ItmsGrpCod"
FROM "CANON"."OINS" I
INNER JOIN "CANON"."OITM" M ON I."itemCode" = M."ItemCode"
WHERE M."ItmsGrpCod" IN (138, 139, 141, 148, 152, 156)
ORDER BY I."insID" DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  insID={0} | group={1} | item={2} ({3}) | cust={4} | SN={5}" -f $row["insID"], $row["ItmsGrpCod"], $row["itemCode"], $row["itemName"], $row["custmrName"], $row["manufSN"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

# ── 5. OPRJ: full project list with more detail ──
Write-Output "`n=== OPRJ ALL PROJECTS ==="
try {
    $rows = Run-Reader @"
SELECT "PrjCode", "PrjName", "ValidFrom", "ValidTo", "Active" 
FROM "CANON"."OPRJ" ORDER BY "PrjCode"
"@
    foreach ($row in $rows) {
        Write-Output ("  {0}: {1} | {2} to {3} | active={4}" -f $row["PrjCode"], $row["PrjName"], $row["ValidFrom"], $row["ValidTo"], $row["Active"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

# ── 6. OPRJ columns ──
Write-Output "`n=== OPRJ ALL COLUMNS ==="
try {
    $rows = Run-Reader @"
SELECT COLUMN_NAME, DATA_TYPE_NAME FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON' AND TABLE_NAME = 'OPRJ' ORDER BY POSITION
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1})" -f $row["COLUMN_NAME"], $row["DATA_TYPE_NAME"])
    }
} catch { Write-Output "Failed" }

# ── 7. Check if there's a project-equipment link table ──
Write-Output "`n=== TABLES WITH 'PRJ' IN NAME ==="
try {
    $rows = Run-Reader @"
SELECT TABLE_NAME FROM SYS.TABLES 
WHERE SCHEMA_NAME = 'CANON' AND UPPER(TABLE_NAME) LIKE '%PRJ%'
ORDER BY TABLE_NAME
"@
    foreach ($row in $rows) {
        $cnt = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""$($row['TABLE_NAME'])"""
        Write-Output ("  {0}: {1} rows" -f $row["TABLE_NAME"], $cnt)
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

# ── 8. Check INV1 for project code on FSMA lines ──
Write-Output "`n=== INV1 PROJECT CODES ON FSMA LINES ==="
try {
    $rows = Run-Reader @"
SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON' AND TABLE_NAME = 'INV1'
AND (UPPER(COLUMN_NAME) LIKE '%PRJ%' OR UPPER(COLUMN_NAME) LIKE '%PROJ%' OR UPPER(COLUMN_NAME) LIKE '%PROJECT%')
ORDER BY POSITION
"@
    Write-Output ("  Project columns in INV1: " + (($rows | ForEach-Object { $_["COLUMN_NAME"] }) -join ", "))
} catch { Write-Output "Failed" }

try {
    $rows = Run-Reader @"
SELECT I."Project", P."PrjName", COUNT(*) AS cnt, SUM(I."LineTotal") AS total
FROM "CANON"."INV1" I
LEFT JOIN "CANON"."OPRJ" P ON I."Project" = P."PrjCode"
WHERE I."ItemCode" = 'SV002'
AND I."Project" IS NOT NULL AND I."Project" <> ''
GROUP BY I."Project", P."PrjName"
ORDER BY total DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Project {0} ({1}): {2} lines, total={3}" -f $row["Project"], $row["PrjName"], $row["cnt"], $row["total"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (no project codes on SV002 lines)" }
} catch { Write-Output "INV1 project on FSMA failed: $($_.Exception.Message)" }

# also check non-SV002 for project
try {
    $rows = Run-Reader @"
SELECT I."Project", P."PrjName", COUNT(*) AS cnt
FROM "CANON"."INV1" I
LEFT JOIN "CANON"."OPRJ" P ON I."Project" = P."PrjCode"
WHERE I."Project" IS NOT NULL AND I."Project" <> ''
GROUP BY I."Project", P."PrjName"
ORDER BY cnt DESC
"@
    Write-Output "`n  ALL INV1 lines with Project code:"
    foreach ($row in $rows[0..19]) {
        Write-Output ("  Project {0} ({1}): {2} lines" -f $row["Project"], $row["PrjName"], $row["cnt"])
    }
} catch { Write-Output "INV1 all projects failed: $($_.Exception.Message)" }

# ── 9. Check OINV header for project code ──
Write-Output "`n=== OINV HEADER PROJECT CODES ==="
try {
    $rows = Run-Reader @"
SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON' AND TABLE_NAME = 'OINV'
AND (UPPER(COLUMN_NAME) LIKE '%PRJ%' OR UPPER(COLUMN_NAME) LIKE '%PROJ%' OR UPPER(COLUMN_NAME) LIKE '%PROJECT%')
ORDER BY POSITION
"@
    Write-Output ("  Project columns in OINV: " + (($rows | ForEach-Object { $_["COLUMN_NAME"] }) -join ", "))
} catch { Write-Output "Failed" }

try {
    $rows = Run-Reader @"
SELECT H."Project", P."PrjName", COUNT(*) AS cnt
FROM "CANON"."OINV" H
LEFT JOIN "CANON"."OPRJ" P ON H."Project" = P."PrjCode"
WHERE H."Project" IS NOT NULL AND H."Project" <> ''
GROUP BY H."Project", P."PrjName"
ORDER BY cnt DESC
"@
    foreach ($row in $rows[0..19]) {
        Write-Output ("  Project {0} ({1}): {2} invoices" -f $row["Project"], $row["PrjName"], $row["cnt"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (no project codes on invoices)" }
} catch { Write-Output "OINV project failed: $($_.Exception.Message)" }

# ── 10. Check OSCL for project linkage ──
Write-Output "`n=== OSCL SERVICE CALLS WITH BPProjCode ==="
try {
    $rows = Run-Reader @"
SELECT S."BPProjCode", P."PrjName", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OPRJ" P ON S."BPProjCode" = P."PrjCode"
WHERE S."BPProjCode" IS NOT NULL AND S."BPProjCode" <> ''
GROUP BY S."BPProjCode", P."PrjName"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Project {0} ({1}): {2} calls" -f $row["BPProjCode"], $row["PrjName"], $row["cnt"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (none)" }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

# ── 11. Yamam Nabil investigation ──
Write-Output "`n=== YAMAM NABIL (empID=80) — TICKET DISTRIBUTION ROLE ==="
try {
    $rows = Run-Reader @"
SELECT 'OSCL.assignee' AS field, COUNT(*) AS cnt FROM "CANON"."OSCL" WHERE "assignee" = 80
UNION ALL
SELECT 'OSCL.responder', COUNT(*) FROM "CANON"."OSCL" WHERE "responder" = 80
UNION ALL
SELECT 'OSCL.technician', COUNT(*) FROM "CANON"."OSCL" WHERE "technician" = 80
UNION ALL
SELECT 'OSCL.OwnerCode', COUNT(*) FROM "CANON"."OSCL" WHERE "OwnerCode" = 80
UNION ALL
SELECT 'OSCL.respAssign', COUNT(*) FROM "CANON"."OSCL" WHERE "respAssign" = 80
UNION ALL
SELECT 'SCL6.Technician', COUNT(*) FROM "CANON"."SCL6" WHERE "Technician" = 80
UNION ALL
SELECT 'SCL6.HandledBy', COUNT(*) FROM "CANON"."SCL6" WHERE "HandledBy" = 80
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} = {1}" -f $row["field"], $row["cnt"])
    }
} catch { Write-Output "Yamam investigation failed: $($_.Exception.Message)" }

# Check userSign (who created the call)
Write-Output "`n=== OSCL CREATED BY (userSign) — WHO CREATES TICKETS ==="
try {
    $rows = Run-Reader @"
SELECT S."userSign", E."firstName", E."lastName", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OHEM" E ON S."userSign" = E."empID"
GROUP BY S."userSign", E."firstName", E."lastName"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  userSign={0} ({1} {2}): {3} calls created" -f $row["userSign"], $row["firstName"], $row["lastName"], $row["cnt"])
    }
} catch { Write-Output "userSign failed: $($_.Exception.Message)" }

# Check userSign2 (who last modified)
Write-Output "`n=== OSCL LAST MODIFIED BY (userSign2) ==="
try {
    $rows = Run-Reader @"
SELECT S."userSign2", E."firstName", E."lastName", COUNT(*) AS cnt
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OHEM" E ON S."userSign2" = E."empID"
GROUP BY S."userSign2", E."firstName", E."lastName"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  userSign2={0} ({1} {2}): {3} calls modified" -f $row["userSign2"], $row["firstName"], $row["lastName"], $row["cnt"])
    }
} catch { Write-Output "userSign2 failed: $($_.Exception.Message)" }

# ── 12. DLN1 project codes on service-related deliveries ──
Write-Output "`n=== DLN1 PROJECT CODES ON SERVICE DELIVERIES ==="
try {
    $rows = Run-Reader @"
SELECT COLUMN_NAME FROM SYS.TABLE_COLUMNS
WHERE SCHEMA_NAME = 'CANON' AND TABLE_NAME = 'DLN1'
AND (UPPER(COLUMN_NAME) LIKE '%PRJ%' OR UPPER(COLUMN_NAME) LIKE '%PROJ%' OR UPPER(COLUMN_NAME) LIKE '%PROJECT%')
ORDER BY POSITION
"@
    Write-Output ("  Project columns in DLN1: " + (($rows | ForEach-Object { $_["COLUMN_NAME"] }) -join ", "))
} catch { Write-Output "Failed" }

try {
    $rows = Run-Reader @"
SELECT D."Project", P."PrjName", COUNT(*) AS lines, SUM(D."LineTotal") AS total
FROM "CANON"."DLN1" D
LEFT JOIN "CANON"."OPRJ" P ON D."Project" = P."PrjCode"
WHERE D."Project" IS NOT NULL AND D."Project" <> ''
GROUP BY D."Project", P."PrjName"
ORDER BY total DESC
"@
    foreach ($row in $rows[0..19]) {
        Write-Output ("  Project {0} ({1}): {2} lines, total={3}" -f $row["Project"], $row["PrjName"], $row["lines"], $row["total"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (none)" }
} catch { Write-Output "DLN1 project failed: $($_.Exception.Message)" }

# ── 13. Production machine equipment cards with their customers ──
Write-Output "`n=== PRODUCTION MACHINES BY CUSTOMER (equipment cards) ==="
try {
    $rows = Run-Reader @"
SELECT I."customer", I."custmrName", COUNT(*) AS machines,
    COUNT(DISTINCT I."itemCode") AS distinct_models
FROM "CANON"."OINS" I
INNER JOIN "CANON"."OITM" M ON I."itemCode" = M."ItemCode"
WHERE M."ItmsGrpCod" IN (138, 139, 141, 148, 152, 156)
GROUP BY I."customer", I."custmrName"
ORDER BY machines DESC
"@
    foreach ($row in $rows[0..24]) {
        Write-Output ("  {0} ({1}): {2} machines, {3} models" -f $row["customer"], $row["custmrName"], $row["machines"], $row["distinct_models"])
    }
} catch { Write-Output "Failed: $($_.Exception.Message)" }

# ── 14. Try matching OPRJ project names to OINS customer names ──
Write-Output "`n=== OPRJ PROJECT NAMES vs OINS CUSTOMERS (fuzzy match attempt) ==="
try {
    $rows = Run-Reader @"
SELECT P."PrjCode", P."PrjName",
    (SELECT COUNT(*) FROM "CANON"."OINS" I 
     INNER JOIN "CANON"."OITM" M ON I."itemCode" = M."ItemCode"
     WHERE M."ItmsGrpCod" IN (138, 139, 141, 148, 152, 156)
     AND UPPER(I."custmrName") LIKE '%' || UPPER(LEFT(P."PrjName", 5)) || '%') AS possible_matches
FROM "CANON"."OPRJ" P
WHERE P."Active" = 'Y'
ORDER BY P."PrjCode"
"@
    foreach ($row in $rows[0..24]) {
        Write-Output ("  {0}: {1} - matches: {2}" -f $row["PrjCode"], $row["PrjName"], $row["possible_matches"])
    }
} catch { Write-Output "Fuzzy match failed: $($_.Exception.Message)" }

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DONE ==="
