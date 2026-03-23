param(
    [Parameter(Mandatory = $true)]
    [string]$SnapshotDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SnapshotDir)) {
    throw "Snapshot directory not found: $SnapshotDir"
}

$required = @{
    "bp_master"        = @("company_code","bp_id","bp_type","bp_group","payment_terms","active_flag")
    "item_master"      = @("company_code","item_id","item_group","uom","active_flag")
    "ar_open_items"    = @("company_code","doc_no","bp_id","posting_date","due_date","open_amount_lc","days_overdue")
    "ap_open_items"    = @("company_code","doc_no","bp_id","posting_date","due_date","open_amount_lc","days_overdue")
    "journal_entries"  = @("company_code","journal_no","line_no","posting_date","account_code","debit_lc","credit_lc","user_id")
}

foreach ($dataset in $required.Keys) {
    $match = Get-ChildItem -LiteralPath $SnapshotDir -File | Where-Object { $_.Name -like "$dataset__*__v1.csv" } | Select-Object -First 1
    if ($null -eq $match) {
        throw "Missing dataset file: $dataset"
    }
    $rows = Import-Csv -LiteralPath $match.FullName
    if ($rows.Count -lt 1) {
        throw "$($match.Name): contains no data rows"
    }
    $headers = @()
    if ($rows.Count -gt 0) {
        $headers = $rows[0].PSObject.Properties.Name
    }
    foreach ($col in $required[$dataset]) {
        if ($headers -notcontains $col) {
            throw "$($match.Name): missing required column '$col'"
        }
    }
    Write-Host ("Validated {0}: {1} rows" -f $match.Name, $rows.Count)
}

$manifest = Join-Path $SnapshotDir "manifest.md"
if (-not (Test-Path -LiteralPath $manifest)) {
    throw "manifest.md is missing in $SnapshotDir"
}

Write-Host "Snapshot validation passed: $SnapshotDir"
