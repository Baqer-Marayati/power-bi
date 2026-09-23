param([string]$User="", [string]$Password="")
$ErrorActionPreference="Stop"
$cs = "DSN=HANA_B1;UID=$User;PWD=$Password;"
$conn = New-Object System.Data.Odbc.OdbcConnection($cs)
$conn.Open()
function Run-Reader { param([string]$sql)
    $cmd=$conn.CreateCommand(); $cmd.CommandText=$sql
    $r=$cmd.ExecuteReader(); $rows=@()
    while ($r.Read()) {
        $row=@{}; for ($i=0;$i-lt$r.FieldCount;$i++){ $row[$r.GetName($i)]=$r.GetValue($i) }
        $rows += $row
    }
    $r.Close(); $cmd.Dispose(); return $rows
}

Write-Output "=== A. Distinct customers who OWN a project-tagged production machine ==="
$rows = Run-Reader @"
SELECT COUNT(DISTINCT I."customer") AS distinct_clients
FROM "CANON"."OINS" I
WHERE I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000'
"@
foreach ($r in $rows) { Write-Output ("  Owners of the 72 production machines: {0} distinct clients" -f $r["distinct_clients"]) }

Write-Output "`n=== B. Distinct customers who HAVE A SERVICE CALL on a production machine ==="
$rows = Run-Reader @"
SELECT COUNT(DISTINCT S."customer") AS distinct_clients
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OINS" I ON S."insID" = I."insID"
WHERE I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000'
"@
foreach ($r in $rows) { Write-Output ("  Customers with calls on production machines: {0} distinct clients" -f $r["distinct_clients"]) }

Write-Output "`n=== C. Distinct customers under each MachineClass (using new rule) ==="
$rows = Run-Reader @"
SELECT
  CASE
    WHEN I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000' THEN 'Production'
    WHEN G."ItmsGrpNam" LIKE 'B2B - DS Copier%' THEN 'Office'
    WHEN G."ItmsGrpNam" LIKE 'B2C%' THEN 'Consumer'
    ELSE 'Other'
  END AS MachineClass,
  COUNT(DISTINCT S."customer") AS distinct_customers,
  COUNT(*) AS calls
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OINS" I ON S."insID" = I."insID"
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
GROUP BY CASE
    WHEN I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000' THEN 'Production'
    WHEN G."ItmsGrpNam" LIKE 'B2B - DS Copier%' THEN 'Office'
    WHEN G."ItmsGrpNam" LIKE 'B2C%' THEN 'Consumer'
    ELSE 'Other'
  END
ORDER BY calls DESC
"@
foreach ($r in $rows) { Write-Output ("  {0,-12} customers={1,4}  calls={2,4}" -f $r["MachineClass"], $r["distinct_customers"], $r["calls"]) }

Write-Output "`n=== D. Top 30 customers who own production machines ==="
$rows = Run-Reader @"
SELECT I."customer", I."custmrName",
       COUNT(DISTINCT I."insID") AS prod_machines,
       COUNT(DISTINCT I."U_Project") AS distinct_projects
FROM "CANON"."OINS" I
WHERE I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000'
GROUP BY I."customer", I."custmrName"
ORDER BY prod_machines DESC
"@
foreach ($r in $rows[0..29]) { Write-Output ("  {0,-10} {1,-50} machines={2,3} projects={3,2}" -f $r["customer"], $r["custmrName"], $r["prod_machines"], $r["distinct_projects"]) }

Write-Output ("`n  Total distinct customer rows above: " + $rows.Count)

Write-Output "`n=== E. The 337 production calls - what customer codes appear? (Top 30) ==="
$rows = Run-Reader @"
SELECT S."customer", S."custmrName", COUNT(*) AS calls
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OINS" I ON S."insID" = I."insID"
WHERE I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000'
GROUP BY S."customer", S."custmrName"
ORDER BY calls DESC
"@
foreach ($r in $rows[0..29]) { Write-Output ("  {0,-10} {1,-50} calls={2,3}" -f $r["customer"], $r["custmrName"], $r["calls"]) }
Write-Output ("`n  Total distinct customers in production calls: " + $rows.Count)

$conn.Close(); $conn.Dispose()
Write-Output "`n=== DONE ==="
