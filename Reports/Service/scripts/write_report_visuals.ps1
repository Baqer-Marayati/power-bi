$base = "Reports\Service\Service Report\Service Report.Report\definition\pages"

$noBom = [System.Text.UTF8Encoding]::new($false)
function Write-Visual($page, $name, $json) {
    $path = Join-Path (Get-Location) "$base\$page\visuals\$name\visual.json"
    [System.IO.File]::WriteAllText($path, $json, $noBom)
}

function card($name,$x,$y,$z,$w,$h,$entity,$measure,$title,$tab) {
@"
{
  "$("$")schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x":$x,"y":$y,"z":$z,"height":$h,"width":$w,"tabOrder":$tab},
  "visual": {
    "visualType": "cardVisual",
    "query": {"queryState": {"Data": {"projections": [{"field": {"Measure": {"Expression": {"SourceRef": {"Entity": "$entity"}},"Property": "$measure"}},"queryRef": "$entity.$measure","nativeQueryRef": "$measure"}]}}},
    "objects": {
      "label": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "value": [{"properties": {"fontSize": {"expr": {"Literal": {"Value": "20D"}}},"bold": {"expr": {"Literal": {"Value": "false"}}},"labelDisplayUnits": {"expr": {"Literal": {"Value": "0D"}}}}}]
    },
    "visualContainerObjects": {
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#E6ECE8'"}}}}}}},{"properties": {"radius": {"expr": {"Literal": {"Value": "4D"}}}}}],
      "dropShadow": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#1F4E79'"}}}}},"position": {"expr": {"Literal": {"Value": "'Outer'"}}},"preset": {"expr": {"Literal": {"Value": "'Custom'"}}},"angle": {"expr": {"Literal": {"Value": "270D"}}},"shadowDistance": {"expr": {"Literal": {"Value": "4D"}}},"shadowBlur": {"expr": {"Literal": {"Value": "0D"}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}},"shadowSpread": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"text": {"expr": {"Literal": {"Value": "'$title'"}}},"fontFamily": {"expr": {"Literal": {"Value": "'''Segoe UI'', wf_segoe-ui_normal, helvetica, arial, sans-serif'"}}},"fontSize": {"expr": {"Literal": {"Value": "10D"}}},"fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#2E3A42'"}}}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function colchart($name,$x,$y,$z,$w,$h,$catEnt,$catProp,$measure,$title,$tab,$sortProp) {
    $sortBlock = ""
    if ($sortProp) { $sortBlock = ',"sortDefinition":{"sort":[{"field":{"Column":{"Expression":{"SourceRef":{"Entity":"' + $catEnt + '"}},"Property":"' + $sortProp + '"}},"direction":"Ascending"}]}' }
@"
{
  "$("$")schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x":$x,"y":$y,"z":$z,"height":$h,"width":$w,"tabOrder":$tab},
  "visual": {
    "visualType": "clusteredColumnChart",
    "query": {"queryState": {"Category": {"projections": [{"field": {"Column": {"Expression": {"SourceRef": {"Entity": "$catEnt"}},"Property": "$catProp"}},"queryRef": "$catEnt.$catProp","nativeQueryRef": "$catProp","active": true}]},"Y": {"projections": [{"field": {"Measure": {"Expression": {"SourceRef": {"Entity": "_Measures"}},"Property": "$measure"}},"queryRef": "_Measures.$measure","nativeQueryRef": "$measure"}]}}$sortBlock},
    "objects": {
      "labels": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "valueAxis": [{"properties": {"showAxisTitle": {"expr": {"Literal": {"Value": "false"}}},"labelColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#6F7C78'"}}}}}}}],
      "categoryAxis": [{"properties": {"showAxisTitle": {"expr": {"Literal": {"Value": "false"}}},"labelColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#6F7C78'"}}}}}}},{"properties": {"wordWrap": {"expr": {"Literal": {"Value": "false"}}}}}]
    },
    "visualContainerObjects": {
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#E2EAE6'"}}}}}}}],
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"text": {"expr": {"Literal": {"Value": "'$title'"}}},"fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#223430'"}}}}},"fontSize": {"expr": {"Literal": {"Value": "12D"}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function barchart($name,$x,$y,$z,$w,$h,$catEnt,$catProp,$measure,$title,$tab) {
@"
{
  "$("$")schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x":$x,"y":$y,"z":$z,"height":$h,"width":$w,"tabOrder":$tab},
  "visual": {
    "visualType": "clusteredBarChart",
    "query": {"queryState": {"Category": {"projections": [{"field": {"Column": {"Expression": {"SourceRef": {"Entity": "$catEnt"}},"Property": "$catProp"}},"queryRef": "$catEnt.$catProp","nativeQueryRef": "$catProp","active": true}]},"Y": {"projections": [{"field": {"Measure": {"Expression": {"SourceRef": {"Entity": "_Measures"}},"Property": "$measure"}},"queryRef": "_Measures.$measure","nativeQueryRef": "$measure"}]}}},
    "objects": {
      "labels": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "valueAxis": [{"properties": {"showAxisTitle": {"expr": {"Literal": {"Value": "false"}}},"labelColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#6F7C78'"}}}}}}}],
      "categoryAxis": [{"properties": {"showAxisTitle": {"expr": {"Literal": {"Value": "false"}}},"labelColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#6F7C78'"}}}}}}}]
    },
    "visualContainerObjects": {
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#E2EAE6'"}}}}}}}],
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"text": {"expr": {"Literal": {"Value": "'$title'"}}},"fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#223430'"}}}}},"fontSize": {"expr": {"Literal": {"Value": "12D"}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function donut($name,$x,$y,$z,$w,$h,$catEnt,$catProp,$measure,$title,$tab) {
@"
{
  "$("$")schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x":$x,"y":$y,"z":$z,"height":$h,"width":$w,"tabOrder":$tab},
  "visual": {
    "visualType": "donutChart",
    "query": {"queryState": {"Category": {"projections": [{"field": {"Column": {"Expression": {"SourceRef": {"Entity": "$catEnt"}},"Property": "$catProp"}},"queryRef": "$catEnt.$catProp","nativeQueryRef": "$catProp","active": true}]},"Y": {"projections": [{"field": {"Measure": {"Expression": {"SourceRef": {"Entity": "_Measures"}},"Property": "$measure"}},"queryRef": "_Measures.$measure","nativeQueryRef": "$measure"}]}}},
    "objects": {
      "labels": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}}}],
      "legend": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"position": {"expr": {"Literal": {"Value": "'Bottom'"}}},"showTitle": {"expr": {"Literal": {"Value": "false"}}}}}]
    },
    "visualContainerObjects": {
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}},"transparency": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#E2EAE6'"}}}}}}}],
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"text": {"expr": {"Literal": {"Value": "'$title'"}}},"fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#223430'"}}}}},"fontSize": {"expr": {"Literal": {"Value": "12D"}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function slicer($name,$x,$y,$z,$w,$h,$entity,$prop,$tab) {
@"
{
  "$("$")schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x":$x,"y":$y,"z":$z,"height":$h,"width":$w,"tabOrder":$tab},
  "visual": {
    "visualType": "slicer",
    "query": {"queryState": {"Values": {"projections": [{"field": {"Column": {"Expression": {"SourceRef": {"Entity": "$entity"}},"Property": "$prop"}},"queryRef": "$entity.$prop","nativeQueryRef": "$prop","active": true}]}}},
    "objects": {
      "data": [{"properties": {"mode": {"expr": {"Literal": {"Value": "'Dropdown'"}}}}}],
      "header": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "selection": [{"properties": {"singleSelect": {"expr": {"Literal": {"Value": "false"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function lbl($name,$x,$y,$z,$w,$h,$text,$tab) {
@"
{
  "$("$")schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x":$x,"y":$y,"z":$z,"height":$h,"width":$w,"tabOrder":$tab},
  "visual": {
    "visualType": "textbox",
    "objects": {"general": [{"properties": {"paragraphs": [{"textRuns": [{"value": ""}]}]}}]},
    "visualContainerObjects": {
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}},"text": {"expr": {"Literal": {"Value": "'$text'"}}},"fontSize": {"expr": {"Literal": {"Value": "10D"}}},"fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#223430'"}}}}},"fontFamily": {"expr": {"Literal": {"Value": "'''Segoe UI Semibold'', wf_segoe-ui_semibold, helvetica, arial, sans-serif'"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

function hdr($name,$ptitle,$sub,$x,$y,$z,$w,$h,$tab) {
@"
{
  "$("$")schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x":$x,"y":$y,"z":$z,"height":$h,"width":$w,"tabOrder":$tab},
  "visual": {
    "visualType": "shape",
    "objects": {"text": [{"properties": {"text": {"expr": {"Literal": {"Value": "''"}}}},"selector": {"id": "default"}}]},
    "visualContainerObjects": {
      "stylePreset": [{"properties": {"name": {"expr": {"Literal": {"Value": "'Report Header'"}}}}}],
      "title": [{"properties": {"text": {"expr": {"Literal": {"Value": "'$ptitle'"}}},"fontFamily": {"expr": {"Literal": {"Value": "'''Segoe UI Semibold'', wf_segoe-ui_semibold, helvetica, arial, sans-serif'"}}},"bold": {"expr": {"Literal": {"Value": "false"}}}}}],
      "subTitle": [{"properties": {"text": {"expr": {"Literal": {"Value": "'$sub'"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
}

# ═══════════ PAGE 1 — Service Overview ═══════════
$p = "svc_p01_overview"
Write-Visual $p "svc_p1_header"       (hdr   "svc_p1_header"       "Service Overview"        "Service call volumes, response times, and machine performance at a glance."        184 0   20000 1088 92  20000)
Write-Visual $p "svc_p1_lbl_month"    (lbl   "svc_p1_lbl_month"    8  102 19000 167 16 "Month"        1000)
Write-Visual $p "svc_p1_slicer_month" (slicer "svc_p1_slicer_month" 8  120 19000 167 36 "Dim_Date"    "YearMonth"   2000)
Write-Visual $p "svc_p1_lbl_class"    (lbl   "svc_p1_lbl_class"    8  164 19000 167 16 "Machine Type" 3000)
Write-Visual $p "svc_p1_slicer_class" (slicer "svc_p1_slicer_class" 8  182 19000 167 36 "Dim_Item"    "MachineClass" 4000)
Write-Visual $p "svc_p1_card_calls"   (card  "svc_p1_card_calls"   184 100 0 262 116 "_Measures" "Total Service Calls"       "Total Calls"          5000)
Write-Visual $p "svc_p1_card_open"    (card  "svc_p1_card_open"    454 100 0 262 116 "_Measures" "Open Calls"                "Open Calls"           6000)
Write-Visual $p "svc_p1_card_resolve" (card  "svc_p1_card_resolve" 724 100 0 262 116 "_Measures" "Avg Resolution Time (hrs)" "Avg Resolution (hrs)" 7000)
Write-Visual $p "svc_p1_card_ftfr"    (card  "svc_p1_card_ftfr"    994 100 0 278 116 "_Measures" "First-Time Fix Rate %"     "First-Time Fix Rate"  8000)
Write-Visual $p "svc_p1_col_month"    (colchart "svc_p1_col_month"    184 228 6000 668 264 "Dim_Date"         "YearMonth"    "Total Service Calls"       "Calls by Month"          9000  "YearMonthSort")
Write-Visual $p "svc_p1_donut_status" (donut    "svc_p1_donut_status" 860 228 6000 412 264 "Fact_ServiceCalls" "StatusName"  "Total Service Calls"       "By Call Status"          10000)
Write-Visual $p "svc_p1_bar_class"    (barchart "svc_p1_bar_class"    184 504 6000 536 264 "Dim_Item"         "MachineClass" "Total Service Calls"       "Calls by Machine Type"   11000)
Write-Visual $p "svc_p1_bar_priority" (barchart "svc_p1_bar_priority" 728 504 6000 544 264 "Fact_ServiceCalls" "Priority"    "Total Service Calls"       "Calls by Priority"       12000)
Write-Visual $p "svc_p1_bar_resp"     (colchart "svc_p1_bar_resp"     184 780 6000 1088 172 "Dim_Date"        "YearMonth"    "Avg Resolution Time (hrs)" "Avg Resolution Time by Month (hrs)" 13000 "YearMonthSort")
Write-Output "Page 1 done"

# ═══════════ PAGE 2 — Technician Performance ═══════════
$p = "svc_p02_techperf"
Write-Visual $p "svc_p2_header"       (hdr   "svc_p2_header"       "Technician Performance"  "Field engineer activity, labor hours, and efficiency metrics."                    184 0   20000 1088 92  20000)
Write-Visual $p "svc_p2_lbl_team"     (lbl   "svc_p2_lbl_team"     8  102 19000 167 16 "Team"         1000)
Write-Visual $p "svc_p2_slicer_team"  (slicer "svc_p2_slicer_team"  8  120 19000 167 36 "Dim_Employee" "Team"      2000)
Write-Visual $p "svc_p2_lbl_month"    (lbl   "svc_p2_lbl_month"    8  164 19000 167 16 "Month"        3000)
Write-Visual $p "svc_p2_slicer_month" (slicer "svc_p2_slicer_month" 8  182 19000 167 36 "Dim_Date"    "YearMonth" 4000)
Write-Visual $p "svc_p2_card_acts"    (card  "svc_p2_card_acts"    184 100 0 262 116 "_Measures" "Total Activities"         "Total Activities"      5000)
Write-Visual $p "svc_p2_card_hours"   (card  "svc_p2_card_hours"   454 100 0 262 116 "_Measures" "Total Labor Hours"        "Total Labor Hours"     6000)
Write-Visual $p "svc_p2_card_cpt"     (card  "svc_p2_card_cpt"     724 100 0 262 116 "_Measures" "Calls per Technician"     "Calls / Technician"    7000)
Write-Visual $p "svc_p2_card_hrpc"    (card  "svc_p2_card_hrpc"    994 100 0 278 116 "_Measures" "Avg Labor Hours per Call" "Avg Hrs / Call"        8000)
Write-Visual $p "svc_p2_bar_tech_acts" (barchart "svc_p2_bar_tech_acts" 184 228 6000 536 264 "Dim_Employee" "EmployeeName" "Total Activities"         "Activities by Technician"  9000)
Write-Visual $p "svc_p2_bar_tech_hrs"  (barchart "svc_p2_bar_tech_hrs"  728 228 6000 544 264 "Dim_Employee" "EmployeeName" "Total Labor Hours"         "Labor Hours by Technician" 10000)
Write-Visual $p "svc_p2_bar_team"      (barchart "svc_p2_bar_team"      184 504 6000 536 264 "Dim_Employee" "Team"         "Total Activities"          "Activities by Team"        11000)
Write-Visual $p "svc_p2_bar_ftfr"      (barchart "svc_p2_bar_ftfr"      728 504 6000 544 264 "Dim_Employee" "EmployeeName" "First-Time Fix Rate %"     "First-Time Fix Rate %"     12000)
Write-Visual $p "svc_p2_col_month"     (colchart "svc_p2_col_month"     184 780 6000 1088 172 "Dim_Date"    "YearMonth"    "Total Activities"          "Activities Trend by Month" 13000 "YearMonthSort")
Write-Output "Page 2 done"

# ═══════════ PAGE 3 — Machine Profitability ═══════════
$p = "svc_p03_profitab"
Write-Visual $p "svc_p3_header"        (hdr   "svc_p3_header"        "Machine Profitability"   "FSMA revenue allocated per customer per machine, vs parts cost."                  184 0   20000 1088 92  20000)
Write-Visual $p "svc_p3_lbl_class"     (lbl   "svc_p3_lbl_class"     8  102 19000 167 16 "Machine Type" 1000)
Write-Visual $p "svc_p3_slicer_class"  (slicer "svc_p3_slicer_class"  8  120 19000 167 36 "Dim_Item"    "MachineClass"  2000)
Write-Visual $p "svc_p3_lbl_cust"      (lbl   "svc_p3_lbl_cust"      8  164 19000 167 16 "Customer"     3000)
Write-Visual $p "svc_p3_slicer_cust"   (slicer "svc_p3_slicer_cust"   8  182 19000 167 36 "Dim_Customer" "CustomerName" 4000)
Write-Visual $p "svc_p3_card_fsma"     (card  "svc_p3_card_fsma"     184 100 0 262 116 "_Measures" "FSMA Revenue"           "FSMA Revenue"         5000)
Write-Visual $p "svc_p3_card_cost"     (card  "svc_p3_card_cost"     454 100 0 262 116 "_Measures" "Total Parts Cost"        "Total Parts Cost"      6000)
Write-Visual $p "svc_p3_card_profit"   (card  "svc_p3_card_profit"   724 100 0 262 116 "_Measures" "Net Profit per Machine"  "Net Profit / Machine"  7000)
Write-Visual $p "svc_p3_card_margin"   (card  "svc_p3_card_margin"   994 100 0 278 116 "_Measures" "Profit Margin %"         "Profit Margin %"       8000)
Write-Visual $p "svc_p3_bar_profit"    (barchart "svc_p3_bar_profit"    184 228 6000 536 264 "Dim_Customer"      "CustomerName" "Net Profit per Machine"     "Net Profit by Customer"        9000)
Write-Visual $p "svc_p3_bar_revcost"   (barchart "svc_p3_bar_revcost"   728 228 6000 544 264 "Dim_Customer"      "CustomerName" "FSMA Revenue Allocated"      "Revenue Allocated by Customer" 10000)
Write-Visual $p "svc_p3_donut_revtype" (donut    "svc_p3_donut_revtype" 184 504 6000 536 264 "Fact_ServiceRevenue" "RevenueType" "Total Service Revenue"      "Revenue by Type"               11000)
Write-Visual $p "svc_p3_bar_costcall"  (barchart "svc_p3_bar_costcall"  728 504 6000 544 264 "Dim_Equipment"     "ItemName"     "Total Parts Cost"            "Parts Cost by Machine Model"   12000)
Write-Visual $p "svc_p3_col_trend"     (colchart "svc_p3_col_trend"     184 780 6000 1088 172 "Dim_Date"         "YearMonth"    "FSMA Revenue Allocated"      "Allocated Revenue Trend"       13000 "YearMonthSort")
Write-Output "Page 3 done"

# ═══════════ PAGE 4 — Parts & Faults ═══════════
$p = "svc_p04_partsflt"
Write-Visual $p "svc_p4_header"       (hdr   "svc_p4_header"       "Parts and Faults"        "Parts consumption, cost, and fault type breakdown."                               184 0   20000 1088 92  20000)
Write-Visual $p "svc_p4_lbl_month"    (lbl   "svc_p4_lbl_month"    8  102 19000 167 16 "Month"        1000)
Write-Visual $p "svc_p4_slicer_month" (slicer "svc_p4_slicer_month" 8  120 19000 167 36 "Dim_Date"    "YearMonth"    2000)
Write-Visual $p "svc_p4_lbl_class"    (lbl   "svc_p4_lbl_class"    8  164 19000 167 16 "Machine Type" 3000)
Write-Visual $p "svc_p4_slicer_class" (slicer "svc_p4_slicer_class" 8  182 19000 167 36 "Dim_Item"    "MachineClass" 4000)
Write-Visual $p "svc_p4_card_lines"   (card  "svc_p4_card_lines"   184 100 0 262 116 "_Measures" "Parts Lines Delivered"    "Parts Lines"         5000)
Write-Visual $p "svc_p4_card_cost"    (card  "svc_p4_card_cost"    454 100 0 262 116 "_Measures" "Total Parts Cost"          "Total Parts Cost"    6000)
Write-Visual $p "svc_p4_card_avgcost" (card  "svc_p4_card_avgcost" 724 100 0 262 116 "_Measures" "Avg Parts Cost per Call"   "Avg Cost / Call"     7000)
Write-Visual $p "svc_p4_card_fsma"    (card  "svc_p4_card_fsma"    994 100 0 278 116 "_Measures" "FSMA Parts Cost"           "FSMA Parts Cost"     8000)
Write-Visual $p "svc_p4_bar_parts"    (barchart "svc_p4_bar_parts"    184 228 6000 536 264 "Fact_ServiceParts"  "Description"       "Total Parts Cost"        "Top Parts by Cost"          9000)
Write-Visual $p "svc_p4_bar_faults"   (barchart "svc_p4_bar_faults"   728 228 6000 544 264 "Dim_ProblemType"    "ProblemTypeName"   "Total Service Calls"     "Calls by Fault Type"        10000)
Write-Visual $p "svc_p4_col_cost"     (colchart "svc_p4_col_cost"     184 504 6000 536 264 "Dim_Date"           "YearMonth"         "Total Parts Cost"        "Parts Cost Trend"           11000 "YearMonthSort")
Write-Visual $p "svc_p4_donut_rev"    (donut    "svc_p4_donut_rev"    728 504 6000 544 264 "Fact_ServiceRevenue" "RevenueType"      "Total Service Revenue"   "Revenue by Type"            12000)
Write-Visual $p "svc_p4_bar_custcost" (barchart "svc_p4_bar_custcost" 184 780 6000 1088 172 "Dim_Customer"      "CustomerName"      "Total Parts Cost"        "Parts Cost by Customer"     13000)
Write-Output "Page 4 done"

# ═══════════ PAGE 5 — Client View ═══════════
$p = "svc_p05_clients"
Write-Visual $p "svc_p5_header"       (hdr   "svc_p5_header"       "Client View"             "Per-client call volumes, revenue, and profitability."                             184 0   20000 1088 92  20000)
Write-Visual $p "svc_p5_lbl_month"    (lbl   "svc_p5_lbl_month"    8  102 19000 167 16 "Month"   1000)
Write-Visual $p "svc_p5_slicer_month" (slicer "svc_p5_slicer_month" 8  120 19000 167 36 "Dim_Date" "YearMonth" 2000)
Write-Visual $p "svc_p5_card_mpc"     (card  "svc_p5_card_mpc"     184 100 0 262 116 "_Measures" "Machines per Client"    "Machines / Client"    3000)
Write-Visual $p "svc_p5_card_cpc"     (card  "svc_p5_card_cpc"     454 100 0 262 116 "_Measures" "Calls per Client"       "Calls / Client"       4000)
Write-Visual $p "svc_p5_card_profit"  (card  "svc_p5_card_profit"  724 100 0 262 116 "_Measures" "Client Profitability"   "Client Profitability" 5000)
Write-Visual $p "svc_p5_card_rev"     (card  "svc_p5_card_rev"     994 100 0 278 116 "_Measures" "Total Service Revenue"  "Total Revenue"        6000)
Write-Visual $p "svc_p5_bar_calls"    (barchart "svc_p5_bar_calls"   184 228 6000 536 264 "Dim_Customer" "CustomerName" "Total Service Calls"    "Top Customers by Call Volume"    7000)
Write-Visual $p "svc_p5_bar_rev"      (barchart "svc_p5_bar_rev"     728 228 6000 544 264 "Dim_Customer" "CustomerName" "Total Service Revenue"  "Top Customers by Revenue"        8000)
Write-Visual $p "svc_p5_bar_profit"   (barchart "svc_p5_bar_profit"  184 504 6000 536 264 "Dim_Customer" "CustomerName" "Client Profitability"   "Top Customers by Profitability"  9000)
Write-Visual $p "svc_p5_bar_mach"     (barchart "svc_p5_bar_mach"    728 504 6000 544 264 "Dim_Customer" "CustomerName" "Machines per Client"    "Machines per Customer"           10000)
Write-Visual $p "svc_p5_col_trend"    (colchart "svc_p5_col_trend"   184 780 6000 1088 172 "Dim_Date"    "YearMonth"    "Total Service Calls"    "Calls Trend by Month"            11000 "YearMonthSort")
Write-Output "Page 5 done"
Write-Output "All pages complete."
