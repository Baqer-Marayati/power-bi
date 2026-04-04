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

# ── 1. Search for FSMA/SMA in tax codes on INV1 ──
Write-Output "=== INV1 TAX CODES ==="
try {
    $rows = Run-Reader @"
SELECT "TaxCode", COUNT(*) AS cnt, SUM("LineTotal") AS total_revenue
FROM "CANON"."INV1"
GROUP BY "TaxCode"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  TaxCode='{0}': {1} lines, total={2}" -f $row["TaxCode"], $row["cnt"], $row["total_revenue"])
    }
} catch { Write-Output "INV1 TaxCode failed: $($_.Exception.Message)" }

# ── 2. Search for FSMA/SMA specifically ──
Write-Output "`n=== INV1 LINES WITH FSMA/SMA TAX CODE ==="
try {
    $rows = Run-Reader @"
SELECT "TaxCode", "ItemCode", "Dscription", COUNT(*) AS cnt, SUM("LineTotal") AS total, SUM("Quantity") AS qty
FROM "CANON"."INV1"
WHERE UPPER("TaxCode") LIKE '%FSMA%' OR UPPER("TaxCode") LIKE '%SMA%'
GROUP BY "TaxCode", "ItemCode", "Dscription"
ORDER BY total DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Tax={0}, Item={1} ({2}): {3} lines, qty={4}, total={5}" -f $row["TaxCode"], $row["ItemCode"], $row["Dscription"], $row["cnt"], $row["qty"], $row["total"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (no FSMA/SMA tax codes found in INV1)" }
} catch { Write-Output "FSMA search failed: $($_.Exception.Message)" }

# ── 3. Check OCTG (tax code definitions) for FSMA/SMA ──
Write-Output "`n=== OCTG TAX CODES (all) ==="
try {
    $rows = Run-Reader @"
SELECT "Code", "Name", "Rate"
FROM "CANON"."OCTG"
ORDER BY "Code"
"@
    foreach ($row in $rows) {
        Write-Output ("  {0}: {1} (rate={2}%)" -f $row["Code"], $row["Name"], $row["Rate"])
    }
} catch { Write-Output "OCTG failed: $($_.Exception.Message)" }

# ── 4. Search for SV002 (FSMA Contract Income) in invoices ──
Write-Output "`n=== INV1 LINES WHERE ItemCode = 'SV002' (FSMA Contract Income) ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""INV1"" WHERE ""ItemCode"" = 'SV002'"
    Write-Output "SV002 lines in invoices: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader @"
SELECT I."DocEntry", I."ItemCode", I."Dscription", I."Quantity", I."Price", I."LineTotal", I."TaxCode",
       H."CardCode", H."CardName", H."DocDate"
FROM "CANON"."INV1" I
INNER JOIN "CANON"."OINV" H ON I."DocEntry" = H."DocEntry"
WHERE I."ItemCode" = 'SV002'
ORDER BY H."DocDate" DESC
"@
        foreach ($row in $rows[0..19]) {
            Write-Output ("  Invoice {0}: {1} ({2}), qty={3}, price={4}, total={5}, tax={6}, date={7}" -f $row["DocEntry"], $row["CardName"], $row["CardCode"], $row["Quantity"], $row["Price"], $row["LineTotal"], $row["TaxCode"], $row["DocDate"])
        }
    }
} catch { Write-Output "SV002 search failed: $($_.Exception.Message)" }

# ── 5. Search for MPS (MPS Contract Income) in invoices ──
Write-Output "`n=== INV1 LINES WHERE ItemCode = 'MPS' ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""INV1"" WHERE ""ItemCode"" = 'MPS'"
    Write-Output "MPS lines in invoices: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader @"
SELECT I."DocEntry", I."ItemCode", I."Dscription", I."Quantity", I."Price", I."LineTotal", I."TaxCode",
       H."CardCode", H."CardName", H."DocDate"
FROM "CANON"."INV1" I
INNER JOIN "CANON"."OINV" H ON I."DocEntry" = H."DocEntry"
WHERE I."ItemCode" = 'MPS'
ORDER BY H."DocDate" DESC
"@
        foreach ($row in $rows[0..19]) {
            Write-Output ("  Invoice {0}: {1} ({2}), qty={3}, price={4}, total={5}, tax={6}, date={7}" -f $row["DocEntry"], $row["CardName"], $row["CardCode"], $row["Quantity"], $row["Price"], $row["LineTotal"], $row["TaxCode"], $row["DocDate"])
        }
    }
} catch { Write-Output "MPS search failed: $($_.Exception.Message)" }

# ── 6. Search for SV001 (Service Labour Income) in invoices ──
Write-Output "`n=== INV1 LINES WHERE ItemCode = 'SV001' (Service Labour Income) ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""INV1"" WHERE ""ItemCode"" = 'SV001'"
    Write-Output "SV001 lines in invoices: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader @"
SELECT I."DocEntry", I."Dscription", I."Quantity", I."Price", I."LineTotal", I."TaxCode",
       H."CardName", H."DocDate"
FROM "CANON"."INV1" I
INNER JOIN "CANON"."OINV" H ON I."DocEntry" = H."DocEntry"
WHERE I."ItemCode" = 'SV001'
ORDER BY H."DocDate" DESC
"@
        foreach ($row in $rows[0..14]) {
            Write-Output ("  Invoice {0}: {1}, qty={2}, price={3}, total={4}, tax={5}, date={6}" -f $row["DocEntry"], $row["CardName"], $row["Quantity"], $row["Price"], $row["LineTotal"], $row["TaxCode"], $row["DocDate"])
        }
    }
} catch { Write-Output "SV001 search failed: $($_.Exception.Message)" }

# ── 7. Search for SV003 (Warranty COGS) in invoices ──
Write-Output "`n=== INV1 LINES WHERE ItemCode = 'SV003' ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""CANON"".""INV1"" WHERE ""ItemCode"" = 'SV003'"
    Write-Output "SV003 lines in invoices: $cnt"
} catch { Write-Output "SV003 search failed: $($_.Exception.Message)" }

# ── 8. All service-related items (groups 172-176) in invoices ──
Write-Output "`n=== ALL SERVICE ITEM GROUPS IN INVOICES ==="
try {
    $rows = Run-Reader @"
SELECT B."ItmsGrpNam", I."ItemCode", I."Dscription", I."TaxCode", 
       COUNT(*) AS lines, SUM(I."LineTotal") AS total_rev
FROM "CANON"."INV1" I
INNER JOIN "CANON"."OITM" M ON I."ItemCode" = M."ItemCode"
INNER JOIN "CANON"."OITB" B ON M."ItmsGrpCod" = B."ItmsGrpCod"
WHERE M."ItmsGrpCod" BETWEEN 172 AND 176
GROUP BY B."ItmsGrpNam", I."ItemCode", I."Dscription", I."TaxCode"
ORDER BY total_rev DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} | {1} ({2}) | tax={3} | {4} lines | total={5}" -f $row["ItmsGrpNam"], $row["ItemCode"], $row["Dscription"], $row["TaxCode"], $row["lines"], $row["total_rev"])
    }
} catch { Write-Output "Service items in invoices failed: $($_.Exception.Message)" }

# ── 9. Search all INV1 where TaxCode contains text (not just numeric) ──
Write-Output "`n=== INV1 NON-NUMERIC TAX CODES (looking for FSMA/SMA labels) ==="
try {
    $rows = Run-Reader @"
SELECT DISTINCT "TaxCode" FROM "CANON"."INV1"
WHERE "TaxCode" IS NOT NULL AND "TaxCode" <> ''
ORDER BY "TaxCode"
"@
    foreach ($row in $rows) {
        Write-Output ("  '{0}'" -f $row["TaxCode"])
    }
} catch { Write-Output "Tax code list failed: $($_.Exception.Message)" }

# ── 10. Check Sales Orders too (ORDR/RDR1) ──
Write-Output "`n=== SALES ORDERS: RDR1 with FSMA/SMA TAX CODES ==="
try {
    $rows = Run-Reader @"
SELECT "TaxCode", COUNT(*) AS cnt, SUM("LineTotal") AS total
FROM "CANON"."RDR1"
WHERE UPPER("TaxCode") LIKE '%FSMA%' OR UPPER("TaxCode") LIKE '%SMA%'
GROUP BY "TaxCode"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  TaxCode='{0}': {1} lines, total={2}" -f $row["TaxCode"], $row["cnt"], $row["total"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (none found)" }
} catch { Write-Output "RDR1 FSMA search failed: $($_.Exception.Message)" }

# ── 11. All RDR1 tax codes ──
Write-Output "`n=== RDR1 ALL TAX CODES ==="
try {
    $rows = Run-Reader @"
SELECT "TaxCode", COUNT(*) AS cnt
FROM "CANON"."RDR1"
GROUP BY "TaxCode"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  '{0}': {1}" -f $row["TaxCode"], $row["cnt"])
    }
} catch { Write-Output "RDR1 tax codes failed: $($_.Exception.Message)" }

# ── 12. Search for FSMA/SMA in item descriptions across all invoice lines ──
Write-Output "`n=== INV1 LINES WITH FSMA/SMA IN DESCRIPTION ==="
try {
    $rows = Run-Reader @"
SELECT I."ItemCode", I."Dscription", I."TaxCode", COUNT(*) AS cnt, SUM(I."LineTotal") AS total
FROM "CANON"."INV1" I
WHERE UPPER(I."Dscription") LIKE '%FSMA%' OR UPPER(I."Dscription") LIKE '%SMA%'
   OR UPPER(I."ItemCode") LIKE '%FSMA%' OR UPPER(I."ItemCode") LIKE '%SMA%'
GROUP BY I."ItemCode", I."Dscription", I."TaxCode"
ORDER BY total DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Item={0} ({1}), tax={2}: {3} lines, total={4}" -f $row["ItemCode"], $row["Dscription"], $row["TaxCode"], $row["cnt"], $row["total"])
    }
    if ($rows.Count -eq 0) { Write-Output "  (none found)" }
} catch { Write-Output "FSMA description search failed: $($_.Exception.Message)" }

# ── 13. OINV header-level fields that might flag FSMA ──
Write-Output "`n=== OINV COLUMNS WITH 'type' or 'code' ==="
try {
    $rows = Run-Reader @"
SELECT COLUMN_NAME, DATA_TYPE_NAME FROM SYS.TABLE_COLUMNS 
WHERE SCHEMA_NAME = 'CANON' AND TABLE_NAME = 'OINV' 
AND (UPPER(COLUMN_NAME) LIKE '%TYPE%' OR UPPER(COLUMN_NAME) LIKE '%TAX%' OR UPPER(COLUMN_NAME) LIKE '%FSMA%' OR UPPER(COLUMN_NAME) LIKE '%SMA%' OR UPPER(COLUMN_NAME) LIKE '%CONTRACT%')
ORDER BY POSITION
"@
    foreach ($row in $rows) {
        Write-Output ("  {0} ({1})" -f $row["COLUMN_NAME"], $row["DATA_TYPE_NAME"])
    }
} catch { Write-Output "OINV columns failed: $($_.Exception.Message)" }

# ── 14. Check delivery notes for FSMA/SMA ──
Write-Output "`n=== DLN1 ALL TAX CODES ==="
try {
    $rows = Run-Reader @"
SELECT "TaxCode", COUNT(*) AS cnt
FROM "CANON"."DLN1"
GROUP BY "TaxCode"
ORDER BY cnt DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  '{0}': {1}" -f $row["TaxCode"], $row["cnt"])
    }
} catch { Write-Output "DLN1 tax codes failed: $($_.Exception.Message)" }

# ── 15. Full technician list for user classification ──
Write-Output "`n=== ALL SERVICE DEPT TECHNICIANS (dept=6) ==="
try {
    $rows = Run-Reader @"
SELECT E."empID", E."firstName", E."lastName", E."position", P."name" AS positionName, E."Active",
    (SELECT COUNT(*) FROM "CANON"."SCL6" S WHERE S."Technician" = E."empID") AS scl6_activities,
    (SELECT COUNT(*) FROM "CANON"."OSCL" S WHERE S."assignee" = E."empID") AS oscl_assigned
FROM "CANON"."OHEM" E
LEFT JOIN "CANON"."OHPS" P ON E."position" = P."posID"
WHERE E."dept" = 6
ORDER BY E."empID"
"@
    foreach ($row in $rows) {
        Write-Output ("  ID={0} | {1} {2} | position={3} | active={4} | SCL6 activities={5} | OSCL assigned={6}" -f $row["empID"], $row["firstName"], $row["lastName"], $row["positionName"], $row["Active"], $row["scl6_activities"], $row["oscl_assigned"])
    }
} catch { Write-Output "Technician list failed: $($_.Exception.Message)" }

# ── 16. Also list non-service-dept people who appear as assignees ──
Write-Output "`n=== NON-SERVICE DEPT ASSIGNEES ==="
try {
    $rows = Run-Reader @"
SELECT E."empID", E."firstName", E."lastName", D."Name" AS deptName, E."Active",
    (SELECT COUNT(*) FROM "CANON"."OSCL" S WHERE S."assignee" = E."empID") AS oscl_assigned
FROM "CANON"."OHEM" E
INNER JOIN "CANON"."OUDP" D ON E."dept" = D."Code"
WHERE E."dept" <> 6
AND E."empID" IN (SELECT DISTINCT "assignee" FROM "CANON"."OSCL" WHERE "assignee" > 0)
ORDER BY oscl_assigned DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  ID={0} | {1} {2} | dept={3} | active={4} | assigned={5} calls" -f $row["empID"], $row["firstName"], $row["lastName"], $row["deptName"], $row["Active"], $row["oscl_assigned"])
    }
} catch { Write-Output "Non-service assignees failed: $($_.Exception.Message)" }

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DONE ==="
