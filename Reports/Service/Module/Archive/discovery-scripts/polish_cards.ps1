$noBom = [System.Text.UTF8Encoding]::new($false)
$base = "C:\Work\reporting-hub\Reports\Service\Service Report\Service Report.Report\definition\pages"

function card($page,$name,$x,$y,$z,$w,$h,$tab,$measure,$title) {
    $json = @"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x": $x, "y": $y, "z": $z, "height": $h, "width": $w, "tabOrder": $tab},
  "visual": {
    "visualType": "cardVisual",
    "query": {
      "queryState": {
        "Data": {
          "projections": [{"field": {"Measure": {"Expression": {"SourceRef": {"Entity": "_Measures"}}, "Property": "$measure"}}, "queryRef": "_Measures.$measure", "nativeQueryRef": "$measure"}]
        }
      }
    },
    "objects": {
      "label": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}, "selector": {"id": "default"}}],
      "value": [{"properties": {"fontSize": {"expr": {"Literal": {"Value": "20D"}}}, "bold": {"expr": {"Literal": {"Value": "false"}}}, "labelDisplayUnits": {"expr": {"Literal": {"Value": "0D"}}}}, "selector": {"metadata": "_Measures.$measure"}}]
    },
    "visualContainerObjects": {
      "background": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}, "color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#FFFFFF'"}}}}}, "transparency": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "border": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}, "color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#E6ECE8'"}}}}}}}],
      "dropShadow": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}, "color": {"solid": {"color": {"expr": {"Literal": {"Value": "'#1F4E79'"}}}}}, "position": {"expr": {"Literal": {"Value": "'Outer'"}}}, "preset": {"expr": {"Literal": {"Value": "'Custom'"}}}, "angle": {"expr": {"Literal": {"Value": "270D"}}}, "shadowDistance": {"expr": {"Literal": {"Value": "4D"}}}, "shadowBlur": {"expr": {"Literal": {"Value": "0D"}}}, "transparency": {"expr": {"Literal": {"Value": "0D"}}}, "shadowSpread": {"expr": {"Literal": {"Value": "0D"}}}}}],
      "title": [{"properties": {"show": {"expr": {"Literal": {"Value": "true"}}}, "text": {"expr": {"Literal": {"Value": "'$title'"}}}, "fontFamily": {"expr": {"Literal": {"Value": "'''Segoe UI'', wf_segoe-ui_normal, helvetica, arial, sans-serif'"}}}, "fontSize": {"expr": {"Literal": {"Value": "10D"}}}, "fontColor": {"solid": {"color": {"expr": {"Literal": {"Value": "'#2E3A42'"}}}}}}}],
      "visualHeader": [{"properties": {"show": {"expr": {"Literal": {"Value": "false"}}}}}]
    },
    "drillFilterOtherVisuals": true
  }
}
"@
    $path = "$base\$page\visuals\$name\visual.json"
    [System.IO.File]::WriteAllText($path, $json, $noBom)
}

# ─── PAGE 1 — Service Overview ─────────────────────────────────────────────
card "svc_p01_overview" "svc_p1_card_calls"   184 100 0 262 116 5000 "Total Service Calls"       "Total Calls"
card "svc_p01_overview" "svc_p1_card_open"    454 100 0 262 116 6000 "Open Calls"                "Open Calls"
card "svc_p01_overview" "svc_p1_card_resolve" 724 100 0 262 116 7000 "Avg Resolution Time (hrs)" "Avg Resolution (hrs)"
card "svc_p01_overview" "svc_p1_card_ftfr"    994 100 0 278 116 8000 "First-Time Fix Rate %"     "First-Time Fix Rate"

# ─── PAGE 2 — Technician Performance ──────────────────────────────────────
card "svc_p02_techperf" "svc_p2_card_acts"  184 100 0 262 116 5000 "Total Activities"         "Total Activities"
card "svc_p02_techperf" "svc_p2_card_hours" 454 100 0 262 116 6000 "Total Labor Hours"        "Total Labor Hours"
card "svc_p02_techperf" "svc_p2_card_cpt"   724 100 0 262 116 7000 "Calls per Technician"     "Calls / Technician"
card "svc_p02_techperf" "svc_p2_card_hrpc"  994 100 0 278 116 8000 "Avg Labor Hours per Call" "Avg Hrs / Call"

# ─── PAGE 3 — Machine Profitability ───────────────────────────────────────
card "svc_p03_profitab" "svc_p3_card_fsma"   184 100 0 262 116 5000 "FSMA Revenue"          "FSMA Revenue"
card "svc_p03_profitab" "svc_p3_card_cost"   454 100 0 262 116 6000 "Total Parts Cost"       "Total Parts Cost"
card "svc_p03_profitab" "svc_p3_card_profit" 724 100 0 262 116 7000 "Net Profit per Machine" "Net Profit / Machine"
card "svc_p03_profitab" "svc_p3_card_margin" 994 100 0 278 116 8000 "Profit Margin %"        "Profit Margin %"

# ─── PAGE 4 — Parts & Faults (replaced FSMA Parts Cost → Avg Response Time)
card "svc_p04_partsflt" "svc_p4_card_lines"   184 100 0 262 116 5000 "Parts Lines Delivered"    "Parts Lines"
card "svc_p04_partsflt" "svc_p4_card_cost"    454 100 0 262 116 6000 "Total Parts Cost"          "Total Parts Cost"
card "svc_p04_partsflt" "svc_p4_card_avgcost" 724 100 0 262 116 7000 "Avg Parts Cost per Call"   "Avg Cost / Call"
card "svc_p04_partsflt" "svc_p4_card_fsma"    994 100 0 278 116 8000 "Avg Response Time (hrs)"   "Avg Response Time (hrs)"

# ─── PAGE 5 — Client View ─────────────────────────────────────────────────
card "svc_p05_clients" "svc_p5_card_mpc"    184 100 0 262 116 3000 "Machines per Client"   "Machines / Client"
card "svc_p05_clients" "svc_p5_card_cpc"    454 100 0 262 116 4000 "Calls per Client"       "Calls / Client"
card "svc_p05_clients" "svc_p5_card_profit" 724 100 0 262 116 5000 "Client Profitability"   "Client Profitability"
card "svc_p05_clients" "svc_p5_card_rev"    994 100 0 278 116 6000 "Total Service Revenue"  "Total Revenue"

Write-Output "All 20 cards polished."
