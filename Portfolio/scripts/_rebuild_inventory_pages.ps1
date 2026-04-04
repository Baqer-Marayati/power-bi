$ErrorActionPreference = 'Stop'
$enc = New-Object System.Text.UTF8Encoding($false)

function wf([string]$p, [string]$c) {
    $d = Split-Path $p -Parent
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }
    [System.IO.File]::WriteAllText($p, $c, $enc)
}

$root = 'c:\Work\reporting-hub\Reports\Inventory\Inventory Report\Inventory Report.Report\definition\pages'

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# VISUAL JSON BUILDERS  (using here-strings â€“ $var interpolated, `$ for literal $)
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function Get-LogoGroup {
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "logo_group",
  "position": {"x": 948.88888888888891,"y": 40,"z": 21000,"height": 50,"width": 267.77777777777777,"tabOrder": 21000},
  "visualGroup": {"displayName": "Logo Group","groupMode": "ScaleMode"}
}
"@
}

function Get-LogoAj {
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "logo_aj",
  "position": {"x": 0,"y": 0,"z": 21000,"height": 50,"width": 123.57142857142858,"tabOrder": 21000},
  "visual": {
    "visualType": "image",
    "objects": {"image": [{"properties": {"sourceFile": {"image": {
      "name": {"expr": {"Literal": {"Value": "'Aljazeera logo.png'"}}},
      "url": {"expr": {"ResourcePackageItem": {"PackageName": "RegisteredResources","PackageType": 1,"ItemName": "Aljazeera_logo5594601849612262.png"}}},
      "scaling": {"expr": {"Literal": {"Value": "'Normal'"}}}}}}}]},
    "drillFilterOtherVisuals": true
  },
  "parentGroupName": "logo_group"
}
"@
}

function Get-LogoCanon {
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "logo_canon",
  "position": {"x": 144.28571428571433,"y": 0,"z": 21000,"height": 50,"width": 123.57142857142858,"tabOrder": 21000},
  "visual": {
    "visualType": "image",
    "objects": {"image": [{"properties": {"sourceFile": {"image": {
      "name": {"expr": {"Literal": {"Value": "'Canon_logo_transparent.png'"}}},
      "url": {"expr": {"ResourcePackageItem": {"PackageName": "RegisteredResources","PackageType": 1,"ItemName": "Canon_logo_transparent4826537244702471.png"}}},
      "scaling": {"expr": {"Literal": {"Value": "'Normal'"}}}}}}}]},
    "drillFilterOtherVisuals": true
  },
  "parentGroupName": "logo_group"
}
"@
}

function Get-HeaderShape([string]$title, [string]$subtitle) {
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "header_shape",
  "position": {"x": 188,"y": 36,"z": 20000,"height": 60,"width": 700,"tabOrder": 0},
  "visual": {
    "visualType": "shape",
    "objects": {"text": [{"properties": {"text": {"expr": {"Literal": {"Value": "'hioj'"}}}},"selector": {"id": "default"}}]},
    "visualContainerObjects": {
      "stylePreset": [{"properties": {"name": {"expr": {"Literal": {"Value": "'Report Header'"}}}}}],
      "title": [{"properties": {
        "text": {"expr": {"Literal": {"Value": "'$title'"}}},
        "fontFamily": {"expr": {"Literal": {"Value": "'''Segoe UI Semibold'', wf_segoe-ui_semibold, helvetica, arial, sans-serif'"}}},
        "bold": {"expr": {"Literal": {"Value": "false"}}}
      }}],
      "subTitle": [{"properties": {"text": {"expr": {"Literal": {"Value": "'$subtitle'"}}}}}]
    },
    "drillFilterOtherVisuals": true
  },
  "howCreated": "InsertVisualButton"
}
"@
}

function Get-Label([string]$name, [int]$y, [string]$text) {
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x": 24,"y": $y,"z": 16500,"height": 18,"width": 136,"tabOrder": 3500},
  "visual": {
    "visualType": "textbox",
    "objects": {"general": [{"properties": {"paragraphs": [{"textRuns": [{"value": ""}]}]}}]},
    "visualContainerObjects": {
      "title": [{"properties": {
        "show": {"expr": {"Literal": {"Value": "true"}}},
        "text": {"expr": {"Literal": {"Value": "'$text'"}}},
        "fontSize": {"expr": {"Literal": {"Value": "10D"}}},
        "fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#223430'"}}}}},
        "fontFamily": {"expr": {"Literal": {"Value": "'''Segoe UI Semibold'', wf_segoe-ui_semibold, helvetica, arial, sans-serif'"}}}
      }}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function Get-Slicer([string]$name, [int]$y, [string]$entity, [string]$prop) {
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x": 24,"y": $y,"z": 8500,"height": 32,"width": 136,"tabOrder": 1500},
  "visual": {
    "visualType": "slicer",
    "query": {"queryState": {"Values": {"projections": [{"field": {"Column": {"Expression": {"SourceRef": {"Entity": "$entity"}},"Property": "$prop"}},"queryRef": "$entity.$prop","nativeQueryRef": "$prop","active": true}]}}},
    "objects": {
      "data": [{"properties": {"mode": {"expr": {"Literal": {"Value": "'Dropdown'"}}}}}],
      "header": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "selection": [{"properties": {"singleSelect": {"expr": {"Literal": {"Value": "false"}}},"selectAllCheckboxEnabled": {"expr": {"Literal": {"Value": "false"}}}}}],
      "general": [{"properties": {}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function Get-KpiCard([string]$name, [int]$x, [int]$y, [int]$w, [string]$measure, [string]$title) {
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x": $x,"y": $y,"z": 0,"height": 92,"width": $w,"tabOrder": 11000},
  "visual": {
    "visualType": "cardVisual",
    "query": {"queryState": {"Data": {"projections": [{"field": {"Measure": {"Expression": {"SourceRef": {"Entity": "_Measures"}},"Property": "$measure"}},"queryRef": "_Measures.$measure","nativeQueryRef": "$measure"}]}}},
    "objects": {
      "label": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}},"selector": {"id": "default"}}],
      "value": [{"properties": {"fontSize": {"expr": {"Literal": {"Value": "18D"}}},"bold": {"expr": {"Literal": {"Value": "false"}}},"labelDisplayUnits": {"expr": {"Literal": {"Value": "0D"}}},"labelPrecision": {"expr": {"Literal": {"Value": "2L"}}}},"selector": {"metadata": "_Measures.$measure"}}]
    },
    "visualContainerObjects": {
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#E6ECE8'"}}}}}}}],
      "visualHeader": [{"properties": {"background": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}},"border": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}}}}],
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"text": {"expr": {"Literal": {"Value": "'$title'"}}},"fontFamily": {"expr": {"Literal": {"Value": "'''Segoe UI'', wf_segoe-ui_normal, helvetica, arial, sans-serif'"}}},"fontSize": {"expr": {"Literal": {"Value": "10D"}}},"fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#2E3A42'"}}}}}}}],
      "dropShadow": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#1F4E79'"}}}}},"position": {"expr": {"Literal": {"Value": "'Outer'"}}},"preset": {"expr": {"Literal": {"Value": "'Custom'"}}},"angle": {"expr": {"Literal": {"Value": "270D"}}},"shadowDistance": {"expr": {"Literal": {"Value": "4D"}}},"shadowBlur": {"expr": {"Literal": {"Value": "0D"}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}},"shadowSpread": {"expr": {"Literal": {"Value": "0D"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function Get-YProjections([string[]]$measures, [string[]]$displayNames) {
    $parts = @()
    for ($i = 0; $i -lt $measures.Length; $i++) {
        $m = $measures[$i]; $dn = $displayNames[$i]
        $parts += @"
{"field": {"Measure": {"Expression": {"SourceRef": {"Entity": "_Measures"}},"Property": "$m"}},"queryRef": "_Measures.$m","nativeQueryRef": "$dn"}
"@
    }
    return ($parts -join ",")
}

function Get-BarChart([string]$name, [int]$x, [int]$y, [int]$w, [int]$h, [string]$catEntity, [string]$catProp, [string[]]$measures, [string[]]$dispNames, [string]$title) {
    $yProj = Get-YProjections $measures $dispNames
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x": $x,"y": $y,"z": 6000,"height": $h,"width": $w,"tabOrder": 17000},
  "visual": {
    "visualType": "clusteredBarChart",
    "query": {"queryState": {
      "Category": {"projections": [{"field": {"Column": {"Expression": {"SourceRef": {"Entity": "$catEntity"}},"Property": "$catProp"}},"queryRef": "$catEntity.$catProp","nativeQueryRef": "$catProp","active": true}]},
      "Y": {"projections": [$yProj]}
    }},
    "objects": {
      "legend": [{"properties": {"showTitle": {"expr": {"Literal": {"Value": "false"}}},"position": {"expr": {"Literal": {"Value": "'TopCenter'"}}},"labelColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#5C6B66'"}}}}}}}],
      "labels": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "valueAxis": [{"properties": {"showAxisTitle": {"expr": {"Literal": {"Value": "false"}}},"labelDisplayUnits": {"expr": {"Literal": {"Value": "1000D"}}},"labelPrecision": {"expr": {"Literal": {"Value": "0L"}}},"labelColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#6F7C78'"}}}}}}}]
    },
    "visualContainerObjects": {
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#E2EAE6'"}}}}}}}],
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"text": {"expr": {"Literal": {"Value": "'$title'"}}},"fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#223430'"}}}}},"fontSize": {"expr": {"Literal": {"Value": "16D"}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"showFocusModeButton": {"expr": {"Literal": {"Value": "true"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function Get-ColChart([string]$name, [int]$x, [int]$y, [int]$w, [int]$h, [string]$catEntity, [string]$catProp, [string[]]$measures, [string[]]$dispNames, [string]$title) {
    $yProj = Get-YProjections $measures $dispNames
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x": $x,"y": $y,"z": 6000,"height": $h,"width": $w,"tabOrder": 17000},
  "visual": {
    "visualType": "clusteredColumnChart",
    "query": {"queryState": {
      "Category": {"projections": [{"field": {"Column": {"Expression": {"SourceRef": {"Entity": "$catEntity"}},"Property": "$catProp"}},"queryRef": "$catEntity.$catProp","nativeQueryRef": "$catProp","active": true}]},
      "Y": {"projections": [$yProj]}
    },
    "sortDefinition": {"sort": [{"field": {"Column": {"Expression": {"SourceRef": {"Entity": "Dim_Date"}},"Property": "MonthNo"}},"direction": "Ascending"}]}
    },
    "objects": {
      "legend": [{"properties": {"showTitle": {"expr": {"Literal": {"Value": "false"}}},"position": {"expr": {"Literal": {"Value": "'TopCenter'"}}},"labelColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#5C6B66'"}}}}}}}],
      "labels": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "valueAxis": [{"properties": {"showAxisTitle": {"expr": {"Literal": {"Value": "false"}}},"labelDisplayUnits": {"expr": {"Literal": {"Value": "1000D"}}},"labelPrecision": {"expr": {"Literal": {"Value": "0L"}}},"labelColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#6F7C78'"}}}}}}}]
    },
    "visualContainerObjects": {
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#E2EAE6'"}}}}}}}],
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"text": {"expr": {"Literal": {"Value": "'$title'"}}},"fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#223430'"}}}}},"fontSize": {"expr": {"Literal": {"Value": "16D"}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"showFocusModeButton": {"expr": {"Literal": {"Value": "true"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function Get-DonutChart([string]$name, [int]$x, [int]$y, [int]$w, [int]$h, [string]$catEntity, [string]$catProp, [string]$measure, [string]$title) {
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x": $x,"y": $y,"z": 8000,"height": $h,"width": $w,"tabOrder": 19000},
  "visual": {
    "visualType": "donutChart",
    "query": {"queryState": {
      "Category": {"projections": [{"field": {"Column": {"Expression": {"SourceRef": {"Entity": "$catEntity"}},"Property": "$catProp"}},"queryRef": "$catEntity.$catProp","nativeQueryRef": "$catProp","active": true}]},
      "Y": {"projections": [{"field": {"Measure": {"Expression": {"SourceRef": {"Entity": "_Measures"}},"Property": "$measure"}},"queryRef": "_Measures.$measure","nativeQueryRef": "$measure"}]}
    },
    "sortDefinition": {"sort": [{"field": {"Measure": {"Expression": {"SourceRef": {"Entity": "_Measures"}},"Property": "$measure"}},"direction": "Descending"}]}
    },
    "objects": {
      "legend": [{"properties": {"showTitle": {"expr": {"Literal": {"Value": "false"}}},"position": {"expr": {"Literal": {"Value": "'RightCenter'"}}},"labelColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#5C6B66'"}}}}}}}],
      "labels": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"labelDisplayUnits": {"expr": {"Literal": {"Value": "1000D"}}},"labelPrecision": {"expr": {"Literal": {"Value": "0L"}}},"fontSize": {"expr": {"Literal": {"Value": "9D"}}}}}],
      "dataPoint": [{"properties": {}}]
    },
    "visualContainerObjects": {
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#E2EAE6'"}}}}}}}],
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"text": {"expr": {"Literal": {"Value": "'$title'"}}},"fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#223430'"}}}}},"fontSize": {"expr": {"Literal": {"Value": "16D"}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"showFocusModeButton": {"expr": {"Literal": {"Value": "true"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function Get-PageJson([string]$pageId, [string]$displayName, [string[]]$slicers, [string[]]$dataVisuals) {
    $interactions = @()
    foreach ($s in $slicers) {
        foreach ($t in $dataVisuals) {
            $interactions += "    {`"source`": `"$s`", `"target`": `"$t`", `"type`": `"DataFilter`"}"
        }
    }
    $intJson = $interactions -join ",`n"
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.0.0/schema.json",
  "name": "$pageId",
  "displayName": "$displayName",
  "displayOption": "FitToWidth",
  "height": 960,
  "width": 1280,
  "objects": {
    "outspacePane": [{"properties": {"width": {"expr": {"Literal": {"Value": "195L"}}}}}],
    "background": [{"properties": {"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#F8FBFF'"}}}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}}}}]
  },
  "visualInteractions": [
$intJson
  ]
}
"@
}

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# HELPERS: write common chrome + date slicers
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
function Write-Chrome([string]$pageDir, [string]$title, [string]$subtitle) {
    wf "$pageDir\visuals\logo_group\visual.json"   (Get-LogoGroup)
    wf "$pageDir\visuals\logo_aj\visual.json"      (Get-LogoAj)
    wf "$pageDir\visuals\logo_canon\visual.json"   (Get-LogoCanon)
    wf "$pageDir\visuals\header_shape\visual.json" (Get-HeaderShape $title $subtitle)
}

function Write-DateSlicers([string]$pageDir) {
    wf "$pageDir\visuals\label_quarter\visual.json"  (Get-Label "label_quarter"  188 "Quarter")
    wf "$pageDir\visuals\slicer_quarter\visual.json" (Get-Slicer "slicer_quarter" 208 "Dim_Date" "Quarter")
    wf "$pageDir\visuals\label_month\visual.json"    (Get-Label "label_month"    258 "Month")
    wf "$pageDir\visuals\slicer_month\visual.json"   (Get-Slicer "slicer_month"  278 "Dim_Date" "MonthName")
}

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# PAGE 1 â€“ INVENTORY OVERVIEW
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$p1 = "$root\a1b2c3d4e5f6a7b8c9d0"
if (Test-Path "$p1\visuals") { Remove-Item "$p1\visuals" -Recurse -Force }

Write-Chrome $p1 "Inventory Overview" "Monitor total stock levels, value, and availability across all warehouses and item groups."
Write-DateSlicers $p1
wf "$p1\visuals\label_warehouse\visual.json"   (Get-Label   "label_warehouse"   328 "Warehouse")
wf "$p1\visuals\slicer_warehouse\visual.json"  (Get-Slicer  "slicer_warehouse"  348 "Dim_Warehouse" "WhsName")

wf "$p1\visuals\kpi_total_skus\visual.json"   (Get-KpiCard "kpi_total_skus"    188 120 184 "Total SKUs"      "Total SKUs")
wf "$p1\visuals\kpi_instock_skus\visual.json" (Get-KpiCard "kpi_instock_skus"  399 120 184 "In-Stock SKUs"   "In-Stock SKUs")
wf "$p1\visuals\kpi_on_hand\visual.json"      (Get-KpiCard "kpi_on_hand"       610 120 184 "Total On Hand"   "Total On Hand")
wf "$p1\visuals\kpi_available\visual.json"    (Get-KpiCard "kpi_available"     821 120 184 "Total Available" "Total Available")
wf "$p1\visuals\kpi_stock_value\visual.json"  (Get-KpiCard "kpi_stock_value"  1032 120 184 "Stock Value"     "Stock Value")

wf "$p1\visuals\chart_whs_bar\visual.json" (Get-BarChart "chart_whs_bar" 188 236 502 216 `
    "Dim_Warehouse" "WhsName" @("Total On Hand","Total Committed") @("On Hand","Committed") `
    "On Hand and Committed by Warehouse")

wf "$p1\visuals\chart_grp_bar\visual.json" (Get-BarChart "chart_grp_bar" 714 236 502 216 `
    "Dim_Item" "ItemGroup" @("Total On Hand","Stock Value") @("On Hand","Stock Value") `
    "On Hand and Stock Value by Item Group")

wf "$p1\visuals\chart_whs_donut\visual.json" (Get-DonutChart "chart_whs_donut" 188 492 502 220 `
    "Dim_Warehouse" "WhsName" "Total On Hand" "Stock Distribution by Warehouse")

wf "$p1\visuals\chart_movement_col\visual.json" (Get-ColChart "chart_movement_col" 714 492 502 220 `
    "Dim_Date" "YearMonth" @("Inbound Qty","Outbound Qty") @("Inbound","Outbound") `
    "Monthly Stock Movements")

$p1_sl = @("slicer_quarter","slicer_month","slicer_warehouse")
$p1_dv = @("kpi_total_skus","kpi_instock_skus","kpi_on_hand","kpi_available","kpi_stock_value","chart_whs_bar","chart_grp_bar","chart_whs_donut","chart_movement_col")
wf "$p1\page.json" (Get-PageJson "a1b2c3d4e5f6a7b8c9d0" "Inventory Overview" $p1_sl $p1_dv)
Write-Host "Page 1 done."

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# PAGE 2 â€“ WAREHOUSE DISTRIBUTION
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$p2 = "$root\b2c3d4e5f6a7b8c9d0e1"
if (Test-Path "$p2\visuals") { Remove-Item "$p2\visuals" -Recurse -Force }

Write-Chrome $p2 "Warehouse Distribution" "Compare stock levels, availability, and transfer activity across each warehouse location."
Write-DateSlicers $p2
wf "$p2\visuals\label_warehouse\visual.json"   (Get-Label  "label_warehouse"   328 "Warehouse")
wf "$p2\visuals\slicer_warehouse\visual.json"  (Get-Slicer "slicer_warehouse"  348 "Dim_Warehouse" "WhsName")

wf "$p2\visuals\kpi_on_hand\visual.json"   (Get-KpiCard "kpi_on_hand"   188 120 184 "Total On Hand"   "Total On Hand")
wf "$p2\visuals\kpi_committed\visual.json" (Get-KpiCard "kpi_committed" 399 120 184 "Total Committed" "Total Committed")
wf "$p2\visuals\kpi_available\visual.json" (Get-KpiCard "kpi_available" 610 120 184 "Total Available" "Total Available")
wf "$p2\visuals\kpi_on_order\visual.json"  (Get-KpiCard "kpi_on_order"  821 120 184 "Total On Order"  "Total On Order")

wf "$p2\visuals\chart_whs_compare\visual.json" (Get-BarChart "chart_whs_compare" 188 236 1028 216 `
    "Dim_Warehouse" "WhsName" @("Total On Hand","Total Committed","Total Available") @("On Hand","Committed","Available") `
    "On Hand, Committed and Available by Warehouse")

wf "$p2\visuals\chart_stock_trend\visual.json" (Get-ColChart "chart_stock_trend" 188 492 502 220 `
    "Dim_Date" "YearMonth" @("Total On Hand","Total Available") @("On Hand","Available") `
    "Stock Trend by Month")

wf "$p2\visuals\chart_transfer_trend\visual.json" (Get-ColChart "chart_transfer_trend" 714 492 502 220 `
    "Dim_Date" "YearMonth" @("Transfer Qty") @("Transfer Qty") `
    "Transfer Activity by Month")

$p2_sl = @("slicer_quarter","slicer_month","slicer_warehouse")
$p2_dv = @("kpi_on_hand","kpi_committed","kpi_available","kpi_on_order","chart_whs_compare","chart_stock_trend","chart_transfer_trend")
wf "$p2\page.json" (Get-PageJson "b2c3d4e5f6a7b8c9d0e1" "Warehouse Distribution" $p2_sl $p2_dv)
Write-Host "Page 2 done."

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# PAGE 3 â€“ STOCK MOVEMENTS
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$p3 = "$root\c3d4e5f6a7b8c9d0e1f2"
if (Test-Path "$p3\visuals") { Remove-Item "$p3\visuals" -Recurse -Force }

Write-Chrome $p3 "Stock Movements" "Analyze inbound, outbound, and net stock movements by month, item group, and transaction type."
Write-DateSlicers $p3
wf "$p3\visuals\label_item_group\visual.json"   (Get-Label  "label_item_group"   328 "Item Group")
wf "$p3\visuals\slicer_item_group\visual.json"  (Get-Slicer "slicer_item_group"  348 "Dim_Item" "ItemGroup")

wf "$p3\visuals\kpi_inbound\visual.json"   (Get-KpiCard "kpi_inbound"   188 120 184 "Inbound Qty"    "Inbound Qty")
wf "$p3\visuals\kpi_outbound\visual.json"  (Get-KpiCard "kpi_outbound"  399 120 184 "Outbound Qty"   "Outbound Qty")
wf "$p3\visuals\kpi_net_mvt\visual.json"   (Get-KpiCard "kpi_net_mvt"   610 120 184 "Net Movement"   "Net Movement")
wf "$p3\visuals\kpi_mvt_count\visual.json" (Get-KpiCard "kpi_mvt_count" 821 120 184 "Movement Count" "Movement Count")

wf "$p3\visuals\chart_monthly_flow\visual.json" (Get-ColChart "chart_monthly_flow" 188 236 1028 216 `
    "Dim_Date" "YearMonth" @("Inbound Qty","Outbound Qty","Net Movement") @("Inbound","Outbound","Net") `
    "Monthly Inbound vs Outbound Flow")

wf "$p3\visuals\chart_by_type\visual.json" (Get-BarChart "chart_by_type" 188 492 502 220 `
    "Fact_StockMovement" "TransTypeName" @("Inbound Qty","Outbound Qty") @("Inbound","Outbound") `
    "Movement by Transaction Type")

wf "$p3\visuals\chart_net_trend\visual.json" (Get-ColChart "chart_net_trend" 714 492 502 220 `
    "Dim_Date" "YearMonth" @("Net Movement") @("Net Movement") `
    "Net Movement Trend")

$p3_sl = @("slicer_quarter","slicer_month","slicer_item_group")
$p3_dv = @("kpi_inbound","kpi_outbound","kpi_net_mvt","kpi_mvt_count","chart_monthly_flow","chart_by_type","chart_net_trend")
wf "$p3\page.json" (Get-PageJson "c3d4e5f6a7b8c9d0e1f2" "Stock Movements" $p3_sl $p3_dv)
Write-Host "Page 3 done."

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# PAGE 4 â€“ PRODUCT CATEGORIES
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$p4 = "$root\d4e5f6a7b8c9d0e1f2a3"
if (Test-Path "$p4\visuals") { Remove-Item "$p4\visuals" -Recurse -Force }

Write-Chrome $p4 "Product Categories" "Deep-dive into item groups â€” stock concentration, value mix, and availability breakdown by category."
Write-DateSlicers $p4
wf "$p4\visuals\label_item_group\visual.json"   (Get-Label  "label_item_group"   328 "Item Group")
wf "$p4\visuals\slicer_item_group\visual.json"  (Get-Slicer "slicer_item_group"  348 "Dim_Item" "ItemGroup")

wf "$p4\visuals\kpi_total_skus\visual.json"    (Get-KpiCard "kpi_total_skus"    188 120 184 "Total SKUs"    "Total SKUs")
wf "$p4\visuals\kpi_instock_skus\visual.json"  (Get-KpiCard "kpi_instock_skus"  399 120 184 "In-Stock SKUs" "In-Stock SKUs")
wf "$p4\visuals\kpi_distinct_skus\visual.json" (Get-KpiCard "kpi_distinct_skus" 610 120 184 "Distinct SKUs" "Distinct SKUs")
wf "$p4\visuals\kpi_stock_value\visual.json"   (Get-KpiCard "kpi_stock_value"   821 120 184 "Stock Value"   "Stock Value")

wf "$p4\visuals\chart_grp_value\visual.json" (Get-BarChart "chart_grp_value" 188 236 1028 216 `
    "Dim_Item" "ItemGroup" @("Stock Value","Total On Hand") @("Stock Value","On Hand") `
    "Stock Value and On Hand by Item Group")

wf "$p4\visuals\chart_grp_donut\visual.json" (Get-DonutChart "chart_grp_donut" 188 492 502 220 `
    "Dim_Item" "ItemGroup" "Stock Value" "Stock Value Mix by Item Group")

wf "$p4\visuals\chart_avail_bar\visual.json" (Get-BarChart "chart_avail_bar" 714 492 502 220 `
    "Dim_Item" "ItemGroup" @("Total On Hand","Total Available","Total Committed") @("On Hand","Available","Committed") `
    "Availability Breakdown by Item Group")

$p4_sl = @("slicer_quarter","slicer_month","slicer_item_group")
$p4_dv = @("kpi_total_skus","kpi_instock_skus","kpi_distinct_skus","kpi_stock_value","chart_grp_value","chart_grp_donut","chart_avail_bar")
wf "$p4\page.json" (Get-PageJson "d4e5f6a7b8c9d0e1f2a3" "Product Categories" $p4_sl $p4_dv)
Write-Host "Page 4 done."

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# PAGE 5 â€“ PROCUREMENT
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$p5 = "$root\e5f6a7b8c9d0e1f2a3b4"
if (Test-Path "$p5\visuals") { Remove-Item "$p5\visuals" -Recurse -Force }

Write-Chrome $p5 "Procurement and Replenishment" "Track purchase orders, goods receipts, and replenishment pipeline to ensure stock continuity."
Write-DateSlicers $p5
wf "$p5\visuals\label_item_group\visual.json"   (Get-Label  "label_item_group"   328 "Item Group")
wf "$p5\visuals\slicer_item_group\visual.json"  (Get-Slicer "slicer_item_group"  348 "Dim_Item" "ItemGroup")

wf "$p5\visuals\kpi_open_po\visual.json"  (Get-KpiCard "kpi_open_po"  188 120 184 "Open PO Count"  "Open Purchase Orders")
wf "$p5\visuals\kpi_on_order\visual.json" (Get-KpiCard "kpi_on_order" 399 120 184 "Total On Order"  "Qty On Order")
wf "$p5\visuals\kpi_po_value\visual.json" (Get-KpiCard "kpi_po_value" 610 120 184 "PO Value"        "Total PO Value")
wf "$p5\visuals\kpi_gr_qty\visual.json"   (Get-KpiCard "kpi_gr_qty"   821 120 184 "GR Qty"          "Goods Received Qty")

wf "$p5\visuals\chart_po_trend\visual.json" (Get-ColChart "chart_po_trend" 188 236 1028 216 `
    "Dim_Date" "YearMonth" @("PO Value","GR Qty") @("PO Value","GR Qty") `
    "Purchase Orders and Goods Receipts by Month")

wf "$p5\visuals\chart_gr_col\visual.json" (Get-ColChart "chart_gr_col" 188 492 502 220 `
    "Dim_Date" "YearMonth" @("GR Qty","PO Qty") @("GR Qty","PO Qty") `
    "GR Qty vs PO Qty Trend")

wf "$p5\visuals\chart_po_by_grp\visual.json" (Get-BarChart "chart_po_by_grp" 714 492 502 220 `
    "Dim_Item" "ItemGroup" @("PO Value","Open PO Count") @("PO Value","Open POs") `
    "Procurement by Item Group")

$p5_sl = @("slicer_quarter","slicer_month","slicer_item_group")
$p5_dv = @("kpi_open_po","kpi_on_order","kpi_po_value","kpi_gr_qty","chart_po_trend","chart_gr_col","chart_po_by_grp")
wf "$p5\page.json" (Get-PageJson "e5f6a7b8c9d0e1f2a3b4" "Procurement" $p5_sl $p5_dv)
Write-Host "Page 5 done."

# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
# BOM STRIP
# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$allFiles = Get-ChildItem -Path $root -Recurse -File -Include "*.json"
$fixed = 0
foreach ($f in $allFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $content = [System.IO.File]::ReadAllText($f.FullName)
        [System.IO.File]::WriteAllText($f.FullName, $content, $enc)
        $fixed++
    }
}
Write-Host "BOM strip: $fixed file(s) corrected."
Write-Host ""
Write-Host "=== Summary ==="
foreach ($pg in @("a1b2c3d4e5f6a7b8c9d0","b2c3d4e5f6a7b8c9d0e1","c3d4e5f6a7b8c9d0e1f2","d4e5f6a7b8c9d0e1f2a3","e5f6a7b8c9d0e1f2a3b4")) {
    $cnt = (Get-ChildItem "$root\$pg\visuals" -Recurse -Filter "visual.json" -ErrorAction SilentlyContinue).Count
    Write-Host "  $pg : $cnt visuals"
}
