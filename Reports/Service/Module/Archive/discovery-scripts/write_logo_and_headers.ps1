$noBom = [System.Text.UTF8Encoding]::new($false)
$base = "C:\Work\reporting-hub\Reports\Service\Service Report\Service Report.Report\definition\pages"

function WV($page, $name, $json) {
    $path = "$base\$page\visuals\$name\visual.json"
    [System.IO.File]::WriteAllText($path, $json, $noBom)
}

# ─── Logo Group (parent container, same on every page) ───────────────────────
$logoGroup = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "svc_logo_group",
  "position": {"x": 948.88888888888891, "y": 40, "z": 21000, "height": 50, "width": 267.77777777777777, "tabOrder": 21000},
  "visualGroup": {"displayName": "Logo Group", "groupMode": "ScaleMode"}
}
'@

# ─── Canon Logo ───────────────────────────────────────────────────────────────
$canonLogo = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "svc_logo_canon",
  "position": {"x": 144.28571428571433, "y": 0, "z": 22000, "height": 50, "width": 123.57142857142858, "tabOrder": 22000},
  "visual": {
    "visualType": "image",
    "objects": {
      "image": [{
        "properties": {
          "sourceFile": {
            "image": {
              "name": {"expr": {"Literal": {"Value": "'Canon_logo_transparent.png'"}}},
              "url": {"expr": {"ResourcePackageItem": {"PackageName": "RegisteredResources", "PackageType": 1, "ItemName": "Canon_logo_transparent4826537244702471.png"}}},
              "scaling": {"expr": {"Literal": {"Value": "'Normal'"}}}
            }
          }
        }
      }]
    },
    "drillFilterOtherVisuals": true
  },
  "parentGroupName": "svc_logo_group"
}
'@

# ─── Aljazeera Logo ───────────────────────────────────────────────────────────
$alLogo = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "svc_logo_al",
  "position": {"x": 0, "y": 0, "z": 21000, "height": 50, "width": 123.57142857142858, "tabOrder": 21000},
  "visual": {
    "visualType": "image",
    "objects": {
      "image": [{
        "properties": {
          "sourceFile": {
            "image": {
              "name": {"expr": {"Literal": {"Value": "'Aljazeera logo.png'"}}},
              "url": {"expr": {"ResourcePackageItem": {"PackageName": "RegisteredResources", "PackageType": 1, "ItemName": "Aljazeera_logo5594601849612262.png"}}},
              "scaling": {"expr": {"Literal": {"Value": "'Normal'"}}}
            }
          }
        }
      }]
    },
    "drillFilterOtherVisuals": true
  },
  "parentGroupName": "svc_logo_group"
}
'@

# ─── Divider ──────────────────────────────────────────────────────────────────
$divider = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "svc_logo_divider",
  "position": {"x": 134.46428571428567, "y": 3.1547619047619051, "z": 23000, "height": 40, "width": 12.916666666666668, "tabOrder": 23000},
  "visual": {
    "visualType": "shape",
    "objects": {
      "shape": [{"properties": {}}],
      "rotation": [{"properties": {"shapeAngle": {"expr": {"Literal": {"Value": "0L"}}}}}],
      "outline": [{"properties": {"lineColor": {"solid": {"color": {"expr": {"ThemeDataColor": {"ColorId": 1, "Percent": 0.1}}}}},"weight": {"expr": {"Literal": {"Value": "0.5D"}}}}, "selector": {"id": "default"}}]
    },
    "visualContainerObjects": {
      "stylePreset": [{"properties": {"name": {"expr": {"Literal": {"Value": "'Divider - Vertical'"}}}}}]
    },
    "drillFilterOtherVisuals": true
  },
  "parentGroupName": "svc_logo_group",
  "howCreated": "InsertVisualButton"
}
'@

# ─── Updated Header Shape (explicit title show + white color) ─────────────────
function hdr($name,$ptitle,$sub,$x,$y,$z,$w,$h,$tab) {
@"
{
  "`$schema": "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/visualContainer/2.4.0/schema.json",
  "name": "$name",
  "position": {"x":$x,"y":$y,"z":$z,"height":$h,"width":$w,"tabOrder":$tab},
  "visual": {
    "visualType": "shape",
    "objects": {"text": [{"properties": {"text": {"expr": {"Literal": {"Value": "''"}}}},"selector": {"id": "default"}}]},
    "visualContainerObjects": {
      "stylePreset": [{"properties": {"name": {"expr": {"Literal": {"Value": "'Report Header'"}}}}}],
      "title": [{"properties": {
        "show": {"expr": {"Literal": {"Value": "true"}}},
        "text": {"expr": {"Literal": {"Value": "'$ptitle'"}}},
        "fontFamily": {"expr": {"Literal": {"Value": "'''Segoe UI Semibold'', wf_segoe-ui_semibold, helvetica, arial, sans-serif'"}}},
        "bold": {"expr": {"Literal": {"Value": "false"}}},
        "fontSize": {"expr": {"Literal": {"Value": "20D"}}}
      }}],
      "subTitle": [{"properties": {
        "show": {"expr": {"Literal": {"Value": "true"}}},
        "text": {"expr": {"Literal": {"Value": "'$sub'"}}}
      }}]
    },
    "drillFilterOtherVisuals": true
  },
  "howCreated": "InsertVisualButton"
}
"@
}

$pages = @{
  "svc_p01_overview" = @{ name="svc_p1_header"; title="Service Overview";        sub="Service call volumes, response times, and machine performance at a glance." }
  "svc_p02_techperf" = @{ name="svc_p2_header"; title="Technician Performance";  sub="Field engineer activity, labor hours, and efficiency metrics." }
  "svc_p03_profitab" = @{ name="svc_p3_header"; title="Machine Profitability";   sub="FSMA revenue allocated per customer per machine, vs parts cost." }
  "svc_p04_partsflt" = @{ name="svc_p4_header"; title="Parts and Faults";        sub="Parts consumption, cost, and fault type breakdown." }
  "svc_p05_clients"  = @{ name="svc_p5_header"; title="Client View";             sub="Per-client call volumes, revenue, and profitability." }
}

foreach ($page in $pages.Keys) {
    $info = $pages[$page]
    # Write updated header shape
    WV $page $info.name (hdr $info.name $info.title $info.sub 184 0 20000 756 92 20000)
    # Write logo visuals (same for every page)
    WV $page "svc_logo_group"   $logoGroup
    WV $page "svc_logo_canon"   $canonLogo
    WV $page "svc_logo_al"      $alLogo
    WV $page "svc_logo_divider" $divider
    Write-Output "  $page done"
}

# ─── Re-encode report.json as UTF-8 no-BOM ────────────────────────────────────
$rj = "C:\Work\reporting-hub\Reports\Service\Service Report\Service Report.Report\definition\report.json"
[System.IO.File]::WriteAllText($rj, [System.IO.File]::ReadAllText($rj), $noBom)

Write-Output "All headers and logos written."
