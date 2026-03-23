param(
    [string]$ConfigPath = "Shared/SAP Export Pipeline/config.json",
    [string]$SnapshotDate = "",
    [string]$SchemaVersion = "v1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SnapshotDate)) {
    $SnapshotDate = (Get-Date).ToString("yyyy-MM-dd")
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
    throw "Config file not found: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json

if (-not $config.odbc -or [string]::IsNullOrWhiteSpace($config.odbc.dsn)) {
    throw "Missing 'odbc.dsn' in config. Example: `"odbc`": { `"dsn`": `"HANA_B1`" }"
}

$dsn = [string]$config.odbc.dsn
$companies = $config.companies
$outputBase = [string]$config.output.base_dir
if ([string]::IsNullOrWhiteSpace($outputBase)) {
    $outputBase = "Shared/Data Drops/incoming"
}
if (-not [string]::IsNullOrWhiteSpace([string]$config.output.schema_version)) {
    $SchemaVersion = [string]$config.output.schema_version
}

$user = $env:SAP_HANA_USER
$password = $env:SAP_HANA_PASSWORD
$connectionString = "DSN=$dsn;"
if (-not [string]::IsNullOrWhiteSpace($user) -and -not [string]::IsNullOrWhiteSpace($password)) {
    $connectionString = "DSN=$dsn;UID=$user;PWD=$password;"
}

$datasets = @(
    "bp_master",
    "item_master",
    "ar_open_items",
    "ap_open_items",
    "journal_entries"
)

function Get-QueryPath([string]$dataset) {
    return Join-Path "Shared/SAP Export Pipeline/queries" "$dataset.sql"
}

function New-DataTableFromQuery([System.Data.Odbc.OdbcConnection]$conn, [string]$sql) {
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $sql
    $adapter = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    [void]$adapter.Fill($dt)
    return $dt
}

function Merge-DataTables([System.Data.DataTable]$target, [System.Data.DataTable]$source) {
    foreach ($row in $source.Rows) {
        $newRow = $target.NewRow()
        foreach ($col in $target.Columns) {
            $newRow[$col.ColumnName] = $row[$col.ColumnName]
        }
        [void]$target.Rows.Add($newRow)
    }
}

function Escape-CsvField([string]$value) {
    if ($null -eq $value) { return "" }
    $needsQuotes = $value.Contains(",") -or $value.Contains('"') -or $value.Contains("`n") -or $value.Contains("`r")
    if ($needsQuotes) {
        return '"' + ($value -replace '"', '""') + '"'
    }
    return $value
}

function Write-DataTableCsv([System.Data.DataTable]$table, [string]$path) {
    $dir = Split-Path -Parent $path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $sw = New-Object System.IO.StreamWriter($path, $false, [System.Text.Encoding]::UTF8)
    try {
        $headers = @()
        foreach ($col in $table.Columns) { $headers += $col.ColumnName }
        $sw.WriteLine(($headers | ForEach-Object { Escape-CsvField $_ }) -join ",")

        foreach ($row in $table.Rows) {
            $fields = @()
            foreach ($col in $table.Columns) {
                $val = $row[$col.ColumnName]
                if ($val -is [DateTime]) {
                    $fields += Escape-CsvField($val.ToString("yyyy-MM-ddTHH:mm:ss"))
                } else {
                    $fields += Escape-CsvField([string]$val)
                }
            }
            $sw.WriteLine($fields -join ",")
        }
    } finally {
        $sw.Close()
    }
}

$snapshotDir = Join-Path $outputBase $SnapshotDate
New-Item -ItemType Directory -Path $snapshotDir -Force | Out-Null

$conn = New-Object System.Data.Odbc.OdbcConnection($connectionString)
$writtenFiles = @()

try {
    $conn.Open()
    foreach ($dataset in $datasets) {
        $queryPath = Get-QueryPath $dataset
        if (-not (Test-Path -LiteralPath $queryPath)) {
            throw "Missing query file: $queryPath"
        }
        $queryTemplate = Get-Content -LiteralPath $queryPath -Raw
        $combined = $null

        foreach ($company in $companies) {
            $schema = [string]$company.schema
            $companyCode = [string]$company.company_code
            $sql = $queryTemplate.Replace("{schema}", $schema).Replace("{company_code}", $companyCode)
            $dt = New-DataTableFromQuery $conn $sql
            if ($null -eq $combined) {
                $combined = $dt.Clone()
            }
            Merge-DataTables $combined $dt
        }

        $fileName = "{0}__{1}__{2}.csv" -f $dataset, $SnapshotDate, $SchemaVersion
        $outPath = Join-Path $snapshotDir $fileName
        Write-DataTableCsv $combined $outPath
        $writtenFiles += $fileName
        Write-Host ("Wrote {0} with {1} rows" -f $fileName, $combined.Rows.Count)
    }
}
finally {
    if ($conn.State -ne [System.Data.ConnectionState]::Closed) {
        $conn.Close()
    }
}

$manifestPath = Join-Path $snapshotDir "manifest.md"
$runTs = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
$manifest = @(
    "# Snapshot Manifest",
    "",
    "- Snapshot date: `$SnapshotDate`",
    "- Snapshot owner: `SAP ODBC Export Script`",
    "- Source model/workspace: `SAP B1 HANA via ODBC DSN`",
    "- Schema version: `$SchemaVersion`",
    "- Export run timestamp: `$runTs`",
    "",
    "## Included datasets",
    ""
)
foreach ($f in $writtenFiles) { $manifest += "- `$f`" }
$manifest += @("", "## Notes", "", "- Generated by `export_snapshots_odbc.ps1`.")
$manifest -join "`n" | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Host "Snapshot complete: $snapshotDir"
