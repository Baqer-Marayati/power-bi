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

Write-Output "=== A. U_SolutionType distinct values across ALL customers in CANON.OCRD ==="
$rows = Run-Reader @"
SELECT
  CASE WHEN "U_SolutionType" IS NULL OR "U_SolutionType" = '' THEN '(empty)' ELSE "U_SolutionType" END AS sol,
  COUNT(*) AS clients
FROM "CANON"."OCRD"
WHERE "CardType" = 'C'
GROUP BY CASE WHEN "U_SolutionType" IS NULL OR "U_SolutionType" = '' THEN '(empty)' ELSE "U_SolutionType" END
ORDER BY clients DESC
"@
foreach ($r in $rows) { Write-Output ("  {0,-30} clients={1,5}" -f $r["sol"], $r["clients"]) }

Write-Output "`n=== B. U_SolutionType among customers WITH at least one service call ==="
$rows = Run-Reader @"
SELECT
  CASE WHEN C."U_SolutionType" IS NULL OR C."U_SolutionType" = '' THEN '(empty)' ELSE C."U_SolutionType" END AS sol,
  COUNT(DISTINCT C."CardCode") AS clients,
  COUNT(S."callID") AS calls
FROM "CANON"."OCRD" C
LEFT JOIN "CANON"."OSCL" S ON S."customer" = C."CardCode"
WHERE C."CardType" = 'C' AND S."callID" IS NOT NULL
GROUP BY CASE WHEN C."U_SolutionType" IS NULL OR C."U_SolutionType" = '' THEN '(empty)' ELSE C."U_SolutionType" END
ORDER BY calls DESC
"@
foreach ($r in $rows) { Write-Output ("  {0,-30} clients={1,5}  calls={2,5}" -f $r["sol"], $r["clients"], $r["calls"]) }

Write-Output "`n=== C. Cross-tab: U_SolutionType (BP) vs MachineClass new-rule (Equipment with project) ==="
$rows = Run-Reader @"
SELECT
  CASE WHEN C."U_SolutionType" IS NULL OR C."U_SolutionType" = '' THEN '(empty)' ELSE C."U_SolutionType" END AS sol,
  CASE
    WHEN I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000' THEN 'Production'
    WHEN G."ItmsGrpNam" LIKE 'B2B - DS Copier%' THEN 'Office'
    WHEN G."ItmsGrpNam" LIKE 'B2C%' THEN 'Consumer'
    ELSE 'Other'
  END AS machine_class,
  COUNT(*) AS machines
FROM "CANON"."OINS" I
LEFT JOIN "CANON"."OCRD" C ON C."CardCode" = I."customer"
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
GROUP BY
  CASE WHEN C."U_SolutionType" IS NULL OR C."U_SolutionType" = '' THEN '(empty)' ELSE C."U_SolutionType" END,
  CASE
    WHEN I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000' THEN 'Production'
    WHEN G."ItmsGrpNam" LIKE 'B2B - DS Copier%' THEN 'Office'
    WHEN G."ItmsGrpNam" LIKE 'B2C%' THEN 'Consumer'
    ELSE 'Other'
  END
ORDER BY sol, machine_class
"@
foreach ($r in $rows) { Write-Output ("  sol={0,-25} mclass={1,-12} machines={2,5}" -f $r["sol"], $r["machine_class"], $r["machines"]) }

Write-Output "`n=== D. Coverage: customers with at least 1 call -- how many have SolutionType filled? ==="
$rows = Run-Reader @"
SELECT
  COUNT(DISTINCT C."CardCode") AS total_active_clients,
  COUNT(DISTINCT CASE WHEN C."U_SolutionType" IS NOT NULL AND C."U_SolutionType" <> '' THEN C."CardCode" END) AS clients_with_sol,
  COUNT(DISTINCT CASE WHEN C."U_SolutionType" IS NULL OR C."U_SolutionType" = ''        THEN C."CardCode" END) AS clients_without_sol
FROM "CANON"."OCRD" C
INNER JOIN "CANON"."OSCL" S ON S."customer" = C."CardCode"
WHERE C."CardType" = 'C'
"@
foreach ($r in $rows) {
    Write-Output ("  total active (with calls): {0}" -f $r["total_active_clients"])
    Write-Output ("  with SolutionType filled : {0}" -f $r["clients_with_sol"])
    Write-Output ("  without SolutionType     : {0}" -f $r["clients_without_sol"])
}

Write-Output "`n=== E. Sample 25 customers WITHOUT SolutionType but WITH calls ==="
$rows = Run-Reader @"
SELECT C."CardCode", C."CardName", COUNT(S."callID") AS calls
FROM "CANON"."OCRD" C
INNER JOIN "CANON"."OSCL" S ON S."customer" = C."CardCode"
WHERE C."CardType" = 'C' AND (C."U_SolutionType" IS NULL OR C."U_SolutionType" = '')
GROUP BY C."CardCode", C."CardName"
ORDER BY calls DESC
"@
foreach ($r in $rows[0..24]) { Write-Output ("  {0,-12} {1,-50} calls={2,4}" -f $r["CardCode"], $r["CardName"], $r["calls"]) }
Write-Output ("`n  (total such customers: {0})" -f $rows.Count)

$conn.Close(); $conn.Dispose()
Write-Output "`n=== DONE ==="
