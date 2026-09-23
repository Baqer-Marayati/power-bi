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

# Helper SQL fragment: current MachineClass CASE
$caseSQL = @"
CASE
  WHEN G."ItmsGrpNam" LIKE 'B2B - IPS%' THEN 'Production'
  WHEN G."ItmsGrpNam" = '#N/A' THEN 'Production'
  WHEN G."ItmsGrpCod" = 139 THEN 'Production'
  WHEN G."ItmsGrpNam" LIKE 'B2B - DS Copier%' THEN 'Office'
  WHEN G."ItmsGrpNam" LIKE 'B2C%' THEN 'Consumer'
  ELSE 'Other'
END
"@

Write-Output "=== A. Equipment cards: current MachineClass vs U_Project status ==="
$rows = Run-Reader @"
SELECT
  $caseSQL AS CurrentClass,
  CASE
    WHEN I."U_Project" IS NULL OR I."U_Project" = '' THEN 'Blank'
    WHEN I."U_Project" = 'PR-000' THEN 'PR-000'
    ELSE 'RealProject'
  END AS ProjectStatus,
  COUNT(*) AS cards
FROM "CANON"."OINS" I
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
GROUP BY $caseSQL,
  CASE WHEN I."U_Project" IS NULL OR I."U_Project" = '' THEN 'Blank'
       WHEN I."U_Project" = 'PR-000' THEN 'PR-000'
       ELSE 'RealProject' END
ORDER BY CurrentClass, ProjectStatus
"@
foreach ($r in $rows) { Write-Output ("  {0,-10} | {1,-12} | {2,6}" -f $r["CurrentClass"], $r["ProjectStatus"], $r["cards"]) }

Write-Output "`n=== B. The 6 Office-classified machines that DO have a real project ==="
$rows = Run-Reader @"
SELECT I."insID", I."customer", I."custmrName", I."itemCode", I."itemName",
       I."U_Project", P."PrjName", G."ItmsGrpCod", G."ItmsGrpNam"
FROM "CANON"."OINS" I
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
LEFT JOIN "CANON"."OPRJ" P  ON I."U_Project" = P."PrjCode"
WHERE I."U_Project" NOT IN ('','PR-000') AND I."U_Project" IS NOT NULL
  AND ($caseSQL) <> 'Production'
ORDER BY I."U_Project"
"@
foreach ($r in $rows) {
    Write-Output ("  insID={0} cust={1} item={2} ({3}) | U_Project={4} ({5}) | itmGrp={6} {7}" -f $r["insID"], $r["customer"], $r["itemCode"], $r["itemName"], $r["U_Project"], $r["PrjName"], $r["ItmsGrpCod"], $r["ItmsGrpNam"])
}

Write-Output "`n=== C. The 185 Production-classified machines with PR-000 (no project assigned) ==="
$rows = Run-Reader @"
SELECT I."itemCode", I."itemName", G."ItmsGrpCod", G."ItmsGrpNam", COUNT(*) AS cards
FROM "CANON"."OINS" I
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
WHERE ($caseSQL) = 'Production' AND (I."U_Project" = 'PR-000' OR I."U_Project" IS NULL OR I."U_Project" = '')
GROUP BY I."itemCode", I."itemName", G."ItmsGrpCod", G."ItmsGrpNam"
ORDER BY cards DESC
"@
foreach ($r in $rows[0..19]) {
    Write-Output ("  {0,5} cards | item={1,-15} {2,-40} | grp={3} {4}" -f $r["cards"], $r["itemCode"], $r["itemName"], $r["ItmsGrpCod"], $r["ItmsGrpNam"])
}

Write-Output "`n=== D. Service calls: current MachineClass (via equipment) vs OSCL.BPProjCode ==="
$rows = Run-Reader @"
SELECT
  COALESCE($caseSQL, 'NoEquipment') AS CurrentClass,
  CASE
    WHEN S."BPProjCode" IS NULL OR S."BPProjCode" = '' THEN 'Blank'
    WHEN S."BPProjCode" = 'PR-000' THEN 'PR-000'
    ELSE 'RealProject'
  END AS CallProjectStatus,
  COUNT(*) AS calls
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OINS" I ON S."insID" = I."insID"
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
GROUP BY COALESCE($caseSQL,'NoEquipment'),
         CASE WHEN S."BPProjCode" IS NULL OR S."BPProjCode" = '' THEN 'Blank'
              WHEN S."BPProjCode" = 'PR-000' THEN 'PR-000'
              ELSE 'RealProject' END
ORDER BY CurrentClass, CallProjectStatus
"@
foreach ($r in $rows) { Write-Output ("  {0,-12} | {1,-12} | {2,6}" -f $r["CurrentClass"], $r["CallProjectStatus"], $r["calls"]) }

Write-Output "`n=== E. Calls with real BPProjCode whose equipment is NOT classified Production ==="
$rows = Run-Reader @"
SELECT
  COALESCE($caseSQL,'NoEquipment') AS CurrentClass,
  COUNT(*) AS calls
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OINS" I ON S."insID" = I."insID"
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
WHERE S."BPProjCode" NOT IN ('','PR-000') AND S."BPProjCode" IS NOT NULL
  AND COALESCE($caseSQL,'NoEquipment') <> 'Production'
GROUP BY COALESCE($caseSQL,'NoEquipment')
ORDER BY calls DESC
"@
foreach ($r in $rows) { Write-Output ("  {0,-12} | {1,6} calls" -f $r["CurrentClass"], $r["calls"]) }

Write-Output "`n=== F. Calls classified Production today but BPProjCode is blank/PR-000 ==="
$rows = Run-Reader @"
SELECT
  CASE WHEN S."BPProjCode" IS NULL OR S."BPProjCode" = '' THEN 'Blank' ELSE 'PR-000' END AS Status,
  COUNT(*) AS calls
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OINS" I ON S."insID" = I."insID"
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
WHERE ($caseSQL) = 'Production'
  AND (S."BPProjCode" IS NULL OR S."BPProjCode" = '' OR S."BPProjCode" = 'PR-000')
GROUP BY CASE WHEN S."BPProjCode" IS NULL OR S."BPProjCode" = '' THEN 'Blank' ELSE 'PR-000' END
"@
foreach ($r in $rows) { Write-Output ("  {0,-8} {1,5}" -f $r["Status"], $r["calls"]) }

Write-Output "`n=== G. Item-group breakdown of equipment that has any real U_Project ==="
$rows = Run-Reader @"
SELECT G."ItmsGrpCod", G."ItmsGrpNam", COUNT(*) AS cards
FROM "CANON"."OINS" I
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
WHERE I."U_Project" NOT IN ('','PR-000') AND I."U_Project" IS NOT NULL
GROUP BY G."ItmsGrpCod", G."ItmsGrpNam"
ORDER BY cards DESC
"@
foreach ($r in $rows) { Write-Output ("  grp={0,4} {1,-50} cards={2}" -f $r["ItmsGrpCod"], $r["ItmsGrpNam"], $r["cards"]) }

$conn.Close(); $conn.Dispose()
Write-Output "`n=== DONE ==="
