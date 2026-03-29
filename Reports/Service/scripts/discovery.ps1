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
Write-Output "Connected to $DSN / $Schema"

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

# ── 1. Row counts ──
$tables = @(
    'OSCL','SCL1','SCL2','SCL4','SCL5','SCL6',
    'OCTR','CTR1',
    'OINS',
    'OITM','OITB',
    'OHEM',
    'OCRD',
    'OPRJ',
    'OINV','INV1',
    'OPCH','PCH1',
    'ODLN','DLN1'
)

Write-Output "`n=== ROW COUNTS ==="
foreach ($t in $tables) {
    try {
        $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""$t"""
        Write-Output ("{0}: {1}" -f $t, $cnt)
    } catch {
        Write-Output ("{0}: ERROR - {1}" -f $t, $_.Exception.Message)
    }
}

# ── 2. OITB Item Groups ──
Write-Output "`n=== OITB ITEM GROUPS ==="
try {
    $rows = Run-Reader "SELECT ""ItmsGrpCod"", ""ItmsGrpNam"" FROM ""$Schema"".""OITB"" ORDER BY ""ItmsGrpCod"""
    foreach ($row in $rows) {
        Write-Output ("{0}: {1}" -f $row["ItmsGrpCod"], $row["ItmsGrpNam"])
    }
} catch { Write-Output "OITB failed: $($_.Exception.Message)" }

# ── 3. OCTR Contract Types ──
Write-Output "`n=== OCTR CONTRACT TYPES ==="
try {
    $rows = Run-Reader "SELECT ""ContractType"", COUNT(*) AS CNT FROM ""$Schema"".""OCTR"" GROUP BY ""ContractType"" ORDER BY CNT DESC"
    foreach ($row in $rows) {
        Write-Output ("Type '{0}': {1} contracts" -f $row["ContractType"], $row["CNT"])
    }
} catch {
    Write-Output "ContractType query failed, trying columns: $($_.Exception.Message)"
    try {
        $rows = Run-Reader "SELECT TOP 1 * FROM ""$Schema"".""OCTR"""
        if ($rows.Count -gt 0) {
            Write-Output ("Columns: " + ($rows[0].Keys -join ", "))
        }
    } catch { Write-Output "OCTR column listing also failed" }
}

# ── 4. OCTR Status ──
Write-Output "`n=== OCTR STATUS ==="
try {
    $rows = Run-Reader "SELECT ""Status"", COUNT(*) AS CNT FROM ""$Schema"".""OCTR"" GROUP BY ""Status"""
    foreach ($row in $rows) {
        Write-Output ("Status '{0}': {1}" -f $row["Status"], $row["CNT"])
    }
} catch { Write-Output "OCTR Status failed: $($_.Exception.Message)" }

# ── 5. OSCL Key Field Population ──
Write-Output "`n=== OSCL KEY FIELD POPULATION ==="
try {
    $fields = @(
        @{name="technician"; cond='"technician" IS NOT NULL AND "technician" <> -1'},
        @{name="itemCode"; cond='COALESCE("itemCode",'''') <> '''''},
        @{name="manufSN"; cond='COALESCE("manufSN",'''') <> '''''},
        @{name="internalSN"; cond='COALESCE("internalSN",'''') <> '''''},
        @{name="insID"; cond='"insID" IS NOT NULL AND "insID" <> -1'},
        @{name="contractID"; cond='"contractID" IS NOT NULL AND "contractID" <> -1'},
        @{name="subject"; cond='COALESCE("subject",'''') <> '''''},
        @{name="resolution"; cond='"resolution" IS NOT NULL AND "resolution" <> -1'}
    )
    $total = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"""
    Write-Output "Total calls: $total"
    foreach ($f in $fields) {
        $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OSCL"" WHERE $($f.cond)"
        Write-Output ("  {0}: {1} / {2}" -f $f.name, $cnt, $total)
    }
} catch { Write-Output "OSCL field check failed: $($_.Exception.Message)" }

# ── 6. OSCL call types, problem types, origins, priorities, statuses ──
$dimensions = @(
    @{label="CALL TYPES"; col="callType"},
    @{label="PROBLEM TYPES"; col="problemType"},
    @{label="ORIGIN"; col="origin"},
    @{label="PRIORITY"; col="priority"},
    @{label="STATUS"; col="status"}
)

foreach ($dim in $dimensions) {
    Write-Output ("`n=== OSCL {0} ===" -f $dim.label)
    try {
        $rows = Run-Reader "SELECT ""$($dim.col)"", COUNT(*) AS CNT FROM ""$Schema"".""OSCL"" GROUP BY ""$($dim.col)"" ORDER BY CNT DESC"
        foreach ($row in $rows) {
            Write-Output ("  '{0}': {1}" -f $row[$dim.col], $row["CNT"])
        }
    } catch { Write-Output "  Failed: $($_.Exception.Message)" }
}

# ── 7. Technician assignment ──
Write-Output "`n=== TECHNICIAN ASSIGNMENT ==="
try {
    $oscl_techs = Run-Scalar "SELECT COUNT(DISTINCT ""technician"") FROM ""$Schema"".""OSCL"" WHERE ""technician"" IS NOT NULL AND ""technician"" <> -1"
    Write-Output "Distinct technicians in OSCL.technician: $oscl_techs"
} catch { Write-Output "OSCL technician count failed: $($_.Exception.Message)" }

try {
    $scl1_assignees = Run-Scalar "SELECT COUNT(DISTINCT ""assignee"") FROM ""$Schema"".""SCL1"" WHERE ""assignee"" IS NOT NULL AND ""assignee"" <> -1"
    Write-Output "Distinct assignees in SCL1.assignee: $scl1_assignees"
} catch { Write-Output "SCL1 assignee count failed: $($_.Exception.Message)" }

# Sample OSCL technician values
Write-Output "`n=== OSCL SAMPLE TECHNICIAN VALUES ==="
try {
    $rows = Run-Reader "SELECT TOP 10 ""callID"", ""technician"", ""customer"", ""status"" FROM ""$Schema"".""OSCL"" WHERE ""technician"" IS NOT NULL AND ""technician"" <> -1"
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: tech={1}, customer={2}, status={3}" -f $row["callID"], $row["technician"], $row["customer"], $row["status"])
    }
} catch { Write-Output "Sample tech failed: $($_.Exception.Message)" }

# ── 8. OINS key fields + project linkage ──
Write-Output "`n=== OINS KEY FIELD POPULATION ==="
try {
    $total = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OINS"""
    Write-Output "Total equipment cards: $total"
    $flds = @(
        @{name="project"; cond='COALESCE("project",'''') <> '''''},
        @{name="customer"; cond='COALESCE("customer",'''') <> '''''},
        @{name="itemCode"; cond='COALESCE("itemCode",'''') <> '''''},
        @{name="manufSN"; cond='COALESCE("manufSN",'''') <> '''''},
        @{name="internalSN"; cond='COALESCE("internalSN",'''') <> '''''}
    )
    foreach ($f in $flds) {
        $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""OINS"" WHERE $($f.cond)"
        Write-Output ("  {0}: {1} / {2}" -f $f.name, $cnt, $total)
    }
} catch { Write-Output "OINS field check failed: $($_.Exception.Message)" }

# ── 9. OPRJ sample ──
Write-Output "`n=== OPRJ SAMPLE ==="
try {
    $rows = Run-Reader "SELECT TOP 15 ""PrjCode"", ""PrjName"", ""ValidFrom"", ""ValidTo"", ""Active"" FROM ""$Schema"".""OPRJ"""
    foreach ($row in $rows) {
        Write-Output ("  {0}: {1} ({2} to {3}) Active={4}" -f $row["PrjCode"], $row["PrjName"], $row["ValidFrom"], $row["ValidTo"], $row["Active"])
    }
} catch { Write-Output "OPRJ sample failed: $($_.Exception.Message)" }

# ── 10. OHEM departments and positions ──
Write-Output "`n=== OHEM DEPARTMENTS ==="
try {
    $rows = Run-Reader "SELECT ""dept"", COUNT(*) AS CNT FROM ""$Schema"".""OHEM"" WHERE ""dept"" IS NOT NULL AND ""dept"" <> -1 GROUP BY ""dept"" ORDER BY CNT DESC"
    foreach ($row in $rows) { Write-Output ("  dept {0}: {1} employees" -f $row["dept"], $row["CNT"]) }
} catch { Write-Output "OHEM dept failed: $($_.Exception.Message)" }

Write-Output "`n=== OHEM POSITIONS ==="
try {
    $rows = Run-Reader "SELECT ""position"", COUNT(*) AS CNT FROM ""$Schema"".""OHEM"" WHERE ""position"" IS NOT NULL AND ""position"" <> -1 GROUP BY ""position"" ORDER BY CNT DESC"
    foreach ($row in $rows) { Write-Output ("  position {0}: {1} employees" -f $row["position"], $row["CNT"]) }
} catch { Write-Output "OHEM position failed: $($_.Exception.Message)" }

# ── 11. OCTR sample contracts ──
Write-Output "`n=== OCTR SAMPLE (recent 10) ==="
try {
    $rows = Run-Reader "SELECT TOP 10 ""ContractID"", ""CstmrCode"", ""CstmrName"", ""StartDate"", ""EndDate"", ""ContractType"", ""Status"" FROM ""$Schema"".""OCTR"" ORDER BY ""ContractID"" DESC"
    foreach ($row in $rows) {
        Write-Output ("  Contract {0}: customer={1} ({2}), type={3}, status={4}, {5} to {6}" -f $row["ContractID"], $row["CstmrCode"], $row["CstmrName"], $row["ContractType"], $row["Status"], $row["StartDate"], $row["EndDate"])
    }
} catch { Write-Output "OCTR sample failed: $($_.Exception.Message)" }

# ── 12. CTR1 key fields ──
Write-Output "`n=== CTR1 KEY FIELDS ==="
try {
    $total = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""CTR1"""
    Write-Output "Total contract lines: $total"
    $flds = @(
        @{name="ItemCode"; cond='COALESCE("ItemCode",'''') <> '''''},
        @{name="ManufSN"; cond='COALESCE("ManufSN",'''') <> '''''},
        @{name="InternalSN"; cond='COALESCE("InternalSN",'''') <> '''''},
        @{name="insID"; cond='"insID" IS NOT NULL AND "insID" <> -1'}
    )
    foreach ($f in $flds) {
        $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""CTR1"" WHERE $($f.cond)"
        Write-Output ("  {0}: {1} / {2}" -f $f.name, $cnt, $total)
    }
} catch { Write-Output "CTR1 field check failed: $($_.Exception.Message)" }

# ── 13. SCL1 activity types ──
Write-Output "`n=== SCL1 ACTIVITY TYPES ==="
try {
    $rows = Run-Reader "SELECT ""ActType"", COUNT(*) AS CNT FROM ""$Schema"".""SCL1"" GROUP BY ""ActType"" ORDER BY CNT DESC"
    foreach ($row in $rows) { Write-Output ("  ActType {0}: {1}" -f $row["ActType"], $row["CNT"]) }
} catch { Write-Output "SCL1 ActType failed: $($_.Exception.Message)" }

# ── 14. SCL5 sample — parts on calls ──
Write-Output "`n=== SCL5 SAMPLE ==="
try {
    $rows = Run-Reader "SELECT TOP 10 * FROM ""$Schema"".""SCL5"""
    if ($rows.Count -gt 0) {
        Write-Output ("  Columns: " + ($rows[0].Keys -join ", "))
        foreach ($row in $rows) {
            $vals = $row.Keys | ForEach-Object { "$_=$($row[$_])" }
            Write-Output ("  " + ($vals -join " | "))
        }
    }
} catch { Write-Output "SCL5 sample failed: $($_.Exception.Message)" }

# ── 15. SCL4 expenses ──
Write-Output "`n=== SCL4 EXPENSES ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""SCL4"""
    Write-Output "SCL4 rows: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader "SELECT TOP 5 * FROM ""$Schema"".""SCL4"""
        if ($rows.Count -gt 0) {
            Write-Output ("  Columns: " + ($rows[0].Keys -join ", "))
        }
    }
} catch { Write-Output "SCL4 failed: $($_.Exception.Message)" }

# ── 16. SCL6 linked docs ──
Write-Output "`n=== SCL6 LINKED DOCS ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""SCL6"""
    Write-Output "SCL6 rows: $cnt"
    if ($cnt -gt 0) {
        $rows = Run-Reader "SELECT TOP 5 * FROM ""$Schema"".""SCL6"""
        if ($rows.Count -gt 0) {
            Write-Output ("  Columns: " + ($rows[0].Keys -join ", "))
        }
    }
} catch { Write-Output "SCL6 failed: $($_.Exception.Message)" }

# ── 17. SCL2 solutions ──
Write-Output "`n=== SCL2 SOLUTIONS ==="
try {
    $cnt = Run-Scalar "SELECT COUNT(*) FROM ""$Schema"".""SCL2"""
    Write-Output "SCL2 rows: $cnt"
} catch { Write-Output "SCL2 failed: $($_.Exception.Message)" }

# ── 18. OINS-to-OPRJ cross-check ──
Write-Output "`n=== OINS PROJECT LINKAGE (equipment with projects) ==="
try {
    $rows = Run-Reader @"
SELECT TOP 15
    I."insID", I."itemCode", I."customer", I."custmrName", I."project",
    P."PrjName"
FROM "$Schema"."OINS" I
LEFT JOIN "$Schema"."OPRJ" P ON I."project" = P."PrjCode"
WHERE I."project" IS NOT NULL AND I."project" <> ''
ORDER BY I."insID" DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Equip {0}: item={1}, customer={2}, project={3} ({4})" -f $row["insID"], $row["itemCode"], $row["custmrName"], $row["project"], $row["PrjName"])
    }
} catch { Write-Output "OINS-OPRJ linkage failed: $($_.Exception.Message)" }

# ── 19. Item group distribution for machines with equipment cards ──
Write-Output "`n=== ITEM GROUPS FOR EQUIPMENT CARDS ==="
try {
    $rows = Run-Reader @"
SELECT B."ItmsGrpNam", B."ItmsGrpCod", COUNT(*) AS CNT
FROM "$Schema"."OINS" I
INNER JOIN "$Schema"."OITM" M ON I."itemCode" = M."ItemCode"
INNER JOIN "$Schema"."OITB" B ON M."ItmsGrpCod" = B."ItmsGrpCod"
GROUP BY B."ItmsGrpNam", B."ItmsGrpCod"
ORDER BY CNT DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Group {0} ({1}): {2} equipment cards" -f $row["ItmsGrpCod"], $row["ItmsGrpNam"], $row["CNT"])
    }
} catch { Write-Output "Item group distribution failed: $($_.Exception.Message)" }

# ── 20. OHEM - resolve dept/position IDs to names ──
Write-Output "`n=== OHEM DEPARTMENT NAMES ==="
try {
    $rows = Run-Reader @"
SELECT D."Code", D."Name", COUNT(*) AS CNT
FROM "$Schema"."OHEM" E
INNER JOIN "$Schema"."OUDP" D ON E."dept" = D."Code"
GROUP BY D."Code", D."Name"
ORDER BY CNT DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Dept {0} ({1}): {2} employees" -f $row["Code"], $row["Name"], $row["CNT"])
    }
} catch { Write-Output "OHEM dept names failed: $($_.Exception.Message)" }

Write-Output "`n=== OHEM POSITION NAMES ==="
try {
    $rows = Run-Reader @"
SELECT P."Code", P."Name", COUNT(*) AS CNT
FROM "$Schema"."OHEM" E
INNER JOIN "$Schema"."OHPS" P ON E."position" = P."Code" 
GROUP BY P."Code", P."Name"
ORDER BY CNT DESC
"@
    foreach ($row in $rows) {
        Write-Output ("  Position {0} ({1}): {2}" -f $row["Code"], $row["Name"], $row["CNT"])
    }
} catch { Write-Output "OHEM position names failed: $($_.Exception.Message)" }

# ── 21. OSCL date range ──
Write-Output "`n=== OSCL DATE RANGE ==="
try {
    $rows = Run-Reader "SELECT MIN(""createDate"") AS min_date, MAX(""createDate"") AS max_date FROM ""$Schema"".""OSCL"""
    Write-Output ("  Earliest call: {0}" -f $rows[0]["min_date"])
    Write-Output ("  Latest call: {0}" -f $rows[0]["max_date"])
} catch { Write-Output "OSCL date range failed: $($_.Exception.Message)" }

# ── 22. OSCL.technician -> OHEM join check ──
Write-Output "`n=== OSCL TECHNICIAN -> OHEM NAME CHECK ==="
try {
    $rows = Run-Reader @"
SELECT TOP 10 S."callID", S."technician", E."firstName", E."lastName", E."dept"
FROM "$Schema"."OSCL" S
LEFT JOIN "$Schema"."OHEM" E ON S."technician" = E."empID"
WHERE S."technician" IS NOT NULL AND S."technician" <> -1
"@
    foreach ($row in $rows) {
        Write-Output ("  Call {0}: techID={1}, name={2} {3}, dept={4}" -f $row["callID"], $row["technician"], $row["firstName"], $row["lastName"], $row["dept"])
    }
} catch { Write-Output "Technician name check failed: $($_.Exception.Message)" }

$conn.Close()
$conn.Dispose()
Write-Output "`n=== DISCOVERY COMPLETE ==="
