param(
    [string]$User = "",
    [string]$Password = ""
)
$ErrorActionPreference = "Stop"
$cs = "DSN=HANA_B1;UID=$User;PWD=$Password;"
$conn = New-Object System.Data.Odbc.OdbcConnection($cs)
$conn.Open()

function Run-Reader { param([string]$sql)
    $cmd = $conn.CreateCommand(); $cmd.CommandText = $sql
    $r = $cmd.ExecuteReader(); $rows = @()
    while ($r.Read()) {
        $row = @{}
        for ($i=0; $i -lt $r.FieldCount; $i++) { $row[$r.GetName($i)] = $r.GetValue($i) }
        $rows += $row
    }
    $r.Close(); $cmd.Dispose(); return $rows
}

Write-Output "=== OINS.U_Project fill rate ==="
$rows = Run-Reader @"
SELECT
  COUNT(*) AS total_equipment,
  COUNT(CASE WHEN "U_Project" IS NOT NULL AND "U_Project" <> '' THEN 1 END) AS any_value,
  COUNT(CASE WHEN "U_Project" IS NOT NULL AND "U_Project" <> '' AND "U_Project" <> 'PR-000' THEN 1 END) AS real_project,
  COUNT(CASE WHEN "U_Project" = 'PR-000' THEN 1 END) AS pr_000_unassigned,
  COUNT(CASE WHEN "U_Project" IS NULL OR "U_Project" = '' THEN 1 END) AS blank
FROM "CANON"."OINS"
"@
foreach ($r in $rows) {
    Write-Output ("  total={0}  any value={1}  real project (<>PR-000)={2}  PR-000={3}  blank/null={4}" -f $r["total_equipment"],$r["any_value"],$r["real_project"],$r["pr_000_unassigned"],$r["blank"])
}

Write-Output "`n=== OINS.U_Project distribution (top 30 codes by equipment count) ==="
$rows = Run-Reader @"
SELECT I."U_Project", P."PrjName", COUNT(*) AS equipment_count
FROM "CANON"."OINS" I
LEFT JOIN "CANON"."OPRJ" P ON I."U_Project" = P."PrjCode"
GROUP BY I."U_Project", P."PrjName"
ORDER BY equipment_count DESC
"@
foreach ($r in $rows[0..29]) {
    Write-Output ("  {0,-8} {1,5} cards   ({2})" -f $r["U_Project"], $r["equipment_count"], $r["PrjName"])
}

Write-Output "`n=== OINS.U_Project fill rate split by machine class ==="
$rows = Run-Reader @"
SELECT
  CASE
    WHEN G."ItmsGrpNam" LIKE 'B2B - IPS%' THEN 'Production'
    WHEN G."ItmsGrpNam" = '#N/A' THEN 'Production'
    WHEN G."ItmsGrpCod" = 139 THEN 'Production'
    WHEN G."ItmsGrpNam" LIKE 'B2B - DS Copier%' THEN 'Office'
    WHEN G."ItmsGrpNam" LIKE 'B2C%' THEN 'Consumer'
    ELSE 'Other'
  END AS MachineClass,
  COUNT(*) AS total,
  COUNT(CASE WHEN I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000' THEN 1 END) AS real_project,
  COUNT(CASE WHEN I."U_Project" = 'PR-000' THEN 1 END) AS pr_000,
  COUNT(CASE WHEN I."U_Project" IS NULL OR I."U_Project" = '' THEN 1 END) AS blank
FROM "CANON"."OINS" I
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G ON IT."ItmsGrpCod" = G."ItmsGrpCod"
GROUP BY
  CASE
    WHEN G."ItmsGrpNam" LIKE 'B2B - IPS%' THEN 'Production'
    WHEN G."ItmsGrpNam" = '#N/A' THEN 'Production'
    WHEN G."ItmsGrpCod" = 139 THEN 'Production'
    WHEN G."ItmsGrpNam" LIKE 'B2B - DS Copier%' THEN 'Office'
    WHEN G."ItmsGrpNam" LIKE 'B2C%' THEN 'Consumer'
    ELSE 'Other'
  END
ORDER BY total DESC
"@
foreach ($r in $rows) {
    Write-Output ("  {0,-12} total={1,5}  real_project={2,5}  PR-000={3,5}  blank={4,5}" -f $r["MachineClass"],$r["total"],$r["real_project"],$r["pr_000"],$r["blank"])
}

Write-Output "`n=== OSCL.BPProjCode fill rate ==="
$rows = Run-Reader @"
SELECT
  COUNT(*) AS total_calls,
  COUNT(CASE WHEN "BPProjCode" IS NOT NULL AND "BPProjCode" <> '' THEN 1 END) AS any_value,
  COUNT(CASE WHEN "BPProjCode" IS NOT NULL AND "BPProjCode" <> '' AND "BPProjCode" <> 'PR-000' THEN 1 END) AS real_project,
  COUNT(CASE WHEN "BPProjCode" = 'PR-000' THEN 1 END) AS pr_000,
  COUNT(CASE WHEN "BPProjCode" IS NULL OR "BPProjCode" = '' THEN 1 END) AS blank
FROM "CANON"."OSCL"
"@
foreach ($r in $rows) {
    Write-Output ("  total={0}  any value={1}  real project (<>PR-000)={2}  PR-000={3}  blank/null={4}" -f $r["total_calls"],$r["any_value"],$r["real_project"],$r["pr_000"],$r["blank"])
}

Write-Output "`n=== OSCL.BPProjCode fill rate over time (by month) ==="
$rows = Run-Reader @"
SELECT
  TO_VARCHAR("createDate",'YYYY-MM') AS yearmonth,
  COUNT(*) AS total,
  COUNT(CASE WHEN "BPProjCode" IS NOT NULL AND "BPProjCode" <> '' THEN 1 END) AS any_value,
  COUNT(CASE WHEN "BPProjCode" IS NOT NULL AND "BPProjCode" <> '' AND "BPProjCode" <> 'PR-000' THEN 1 END) AS real_project
FROM "CANON"."OSCL"
GROUP BY TO_VARCHAR("createDate",'YYYY-MM')
ORDER BY yearmonth
"@
foreach ($r in $rows) {
    Write-Output ("  {0}  total={1,4}  any={2,4}  real={3,4}" -f $r["yearmonth"],$r["total"],$r["any_value"],$r["real_project"])
}

Write-Output "`n=== Equipment <-> OSCL project agreement (do they match?) ==="
$rows = Run-Reader @"
SELECT
  COUNT(*) AS calls_with_equip,
  COUNT(CASE WHEN S."BPProjCode" IS NOT NULL AND S."BPProjCode" <> '' AND I."U_Project" IS NOT NULL AND I."U_Project" <> '' THEN 1 END) AS both_have_value,
  COUNT(CASE WHEN S."BPProjCode" = I."U_Project" AND S."BPProjCode" IS NOT NULL AND S."BPProjCode" <> '' THEN 1 END) AS exactly_match,
  COUNT(CASE WHEN S."BPProjCode" <> I."U_Project" AND S."BPProjCode" IS NOT NULL AND S."BPProjCode" <> '' AND I."U_Project" IS NOT NULL AND I."U_Project" <> '' THEN 1 END) AS mismatch
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OINS" I ON S."insID" = I."insID"
"@
foreach ($r in $rows) {
    Write-Output ("  calls with equipment match: {0}; both have project value: {1}; exact match: {2}; conflict: {3}" -f $r["calls_with_equip"],$r["both_have_value"],$r["exactly_match"],$r["mismatch"])
}

$conn.Close(); $conn.Dispose()
Write-Output "`n=== DONE ==="
