param([string]$User="", [string]$Password="")
$ErrorActionPreference="Stop"
$cs = "DSN=HANA_B1;UID=$User;PWD=$Password;"
$conn = New-Object System.Data.Odbc.OdbcConnection($cs)
$conn.Open()
$cmd = $conn.CreateCommand()
$cmd.CommandText = @"
SELECT
  CASE WHEN "CustomerType" IS NULL OR "CustomerType" = '' THEN '(Blank)' ELSE "CustomerType" END AS ct,
  COUNT(*) AS clients
FROM (
  SELECT
    C."CardCode" AS "CustomerCode",
    C."CardName" AS "CustomerName",
    CASE WHEN C."U_SolutionType" IS NULL OR C."U_SolutionType" = '' THEN NULL ELSE C."U_SolutionType" END AS "CustomerType"
  FROM "CANON"."OCRD" C
  WHERE C."CardType" = 'C'
)
GROUP BY CASE WHEN "CustomerType" IS NULL OR "CustomerType" = '' THEN '(Blank)' ELSE "CustomerType" END
ORDER BY clients DESC
"@
$r = $cmd.ExecuteReader()
while ($r.Read()) { Write-Output ("  {0,-15} clients={1,5}" -f $r["ct"], $r["clients"]) }
$r.Close(); $cmd.Dispose(); $conn.Close()
