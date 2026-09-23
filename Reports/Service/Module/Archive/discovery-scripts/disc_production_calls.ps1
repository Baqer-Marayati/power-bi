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

Write-Output "=== A. Of the 185 production-classified-but-PR-000 cards, how many actually have service calls? ==="
$rows = Run-Reader @"
WITH ProdNoProj AS (
  SELECT I."insID"
  FROM "CANON"."OINS" I
  LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
  LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
  WHERE ($caseSQL) = 'Production'
    AND (I."U_Project" = 'PR-000' OR I."U_Project" IS NULL OR I."U_Project" = '')
)
SELECT
  COUNT(*) AS prod_no_proj_cards,
  COUNT(CASE WHEN sc.cnt > 0 THEN 1 END) AS cards_with_calls,
  COUNT(CASE WHEN sc.cnt IS NULL OR sc.cnt = 0 THEN 1 END) AS cards_without_calls
FROM ProdNoProj p
LEFT JOIN (SELECT "insID", COUNT(*) AS cnt FROM "CANON"."OSCL" GROUP BY "insID") sc
       ON p."insID" = sc."insID"
"@
foreach ($r in $rows) {
    Write-Output ("  total in this bucket={0}; with at least one call={1}; never called={2}" -f $r["prod_no_proj_cards"],$r["cards_with_calls"],$r["cards_without_calls"])
}

Write-Output "`n=== B. Same 185 bucket: list the few that DO have calls (likely missed-tagging cases) ==="
$rows = Run-Reader @"
WITH ProdNoProj AS (
  SELECT I."insID", I."customer", I."custmrName", I."itemCode", I."itemName"
  FROM "CANON"."OINS" I
  LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
  LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
  WHERE ($caseSQL) = 'Production'
    AND (I."U_Project" = 'PR-000' OR I."U_Project" IS NULL OR I."U_Project" = '')
)
SELECT p."insID", p."customer", p."custmrName", p."itemCode", p."itemName", sc.cnt AS service_calls
FROM ProdNoProj p
INNER JOIN (SELECT "insID", COUNT(*) AS cnt FROM "CANON"."OSCL" GROUP BY "insID") sc
       ON p."insID" = sc."insID"
ORDER BY sc.cnt DESC
"@
foreach ($r in $rows) {
    Write-Output ("  insID={0,5}  calls={1,3}  cust={2}  item={3} ({4})" -f $r["insID"],$r["service_calls"],$r["custmrName"],$r["itemCode"],$r["itemName"])
}

Write-Output "`n=== C. Final headline: cards & calls under each definition ==="
$rows = Run-Reader @"
SELECT 'A. Equipment cards: item-group rule = Production' AS metric, COUNT(*) AS value
FROM "CANON"."OINS" I
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
WHERE ($caseSQL) = 'Production'
UNION ALL
SELECT 'B. Equipment cards: project rule = Production (real PRJ)', COUNT(*)
FROM "CANON"."OINS" I
WHERE I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000'
UNION ALL
SELECT 'C. Service calls hitting item-group Production', COUNT(*)
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OINS" I ON S."insID" = I."insID"
LEFT JOIN "CANON"."OITM" IT ON I."itemCode" = IT."ItemCode"
LEFT JOIN "CANON"."OITB" G  ON IT."ItmsGrpCod" = G."ItmsGrpCod"
WHERE ($caseSQL) = 'Production'
UNION ALL
SELECT 'D. Service calls hitting project-rule Production machines', COUNT(*)
FROM "CANON"."OSCL" S
INNER JOIN "CANON"."OINS" I ON S."insID" = I."insID"
WHERE I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000'
UNION ALL
SELECT 'E. Service calls with real BPProjCode (call-level)', COUNT(*)
FROM "CANON"."OSCL" S
WHERE S."BPProjCode" IS NOT NULL AND S."BPProjCode" <> '' AND S."BPProjCode" <> 'PR-000'
UNION ALL
SELECT 'F. Calls (machine OR call has real project)', COUNT(*)
FROM "CANON"."OSCL" S
LEFT JOIN "CANON"."OINS" I ON S."insID" = I."insID"
WHERE (I."U_Project" IS NOT NULL AND I."U_Project" <> '' AND I."U_Project" <> 'PR-000')
   OR (S."BPProjCode" IS NOT NULL AND S."BPProjCode" <> '' AND S."BPProjCode" <> 'PR-000')
"@
foreach ($r in $rows) { Write-Output ("  {0,-65} {1,6}" -f $r["metric"],$r["value"]) }

$conn.Close(); $conn.Dispose()
Write-Output "`n=== DONE ==="
