#!/usr/bin/env python3
"""
Cross-report layout/styling consistency audit for PBIP report definitions.

Scans one or more `<Name>.Report` folders (PBIR format) and reports, per report:
  - registered theme
  - page sizes / display options / hidden pages
  - title typography (font family, size, color, bold) with usage counts
  - card/visual container styling (border radius/color, shadow color)
  - KPI card rows (geometry, value font sizes)
  - slicer rail geometry (x / width / heights)
  - brand image visuals (logo lockups) and their coordinates
  - per-page bottom line (max y+height) and off-canvas / hidden visuals

Then prints a cross-report comparison of the key design tokens against
Portfolio/Shared/Standards/fabric-reports-layout-standard.md expectations,
plus a NUMBER FORMATTING audit against
Portfolio/Shared/Standards/fabric-reports-number-formatting.md:
  - cards: no Auto display units; percent cards 2dp; bn cards 3dp
  - tables: grid 14 / values 13 / headers 12 bold / bold totals (tooltips exempt)
  - charts: fixed-M labels 1dp, fixed-bn labels 3dp, auto money labels 1dp
  - model: every percent format string is 0.00%-based

Usage:
  python3 audit-report-consistency.py [--strict] <folder-or-.Report-path> [more paths...]
  # e.g. python3 Portfolio/scripts/audit-report-consistency.py Fabric/DevelopmentWorkspace

`--strict` exits non-zero when layout or number-formatting drift is found. It
is intended for CI; the default remains an informational report for humans.
"""

from __future__ import annotations

import json
import re
import sys
from collections import Counter, defaultdict
from pathlib import Path

EXPECTED = {
    "theme": "Custom_Theme49412231581938193.json",
    "title_font": "Segoe UI",
    "title_size": "12",
    "title_color": "#2E3A42",
    "radius": "14",
    "border_color": "#C9D5E3",
    "shadow_color": "#1F4E79",
    "kpi_value_size": "18",
    "kpi_height": 104,
    "rail_width": 400,
    "bottom_line": 1030,
    "canvas": "1920x1080",
}

ALLOWED = {
    # 20pt is the deliberate page-heading tier. Two Sales subtitles use Semibold
    # and navy; both are approved variants, not drift.
    "title_fonts": {"Segoe UI", "Segoe UI Semibold"},
    "title_sizes": {"12", "20"},
    "title_colors": {"#2E3A42", "#1F4E79"},
    "bottom_lines": {1030, 1032},
}


def lit(node):
    """Extract a literal value from a PBIR expression node."""
    try:
        value = node["expr"]["Literal"]["Value"]
    except (KeyError, TypeError):
        try:
            value = node["solid"]["color"]["expr"]["Literal"]["Value"]
        except (KeyError, TypeError):
            return None
    if isinstance(value, str):
        value = value.strip("'")
        for suffix in ("D", "L"):
            if value.endswith(suffix) and value[:-1].replace(".", "").replace("-", "").isdigit():
                value = value[:-1]
    return value


def first_props(obj_list):
    if isinstance(obj_list, list) and obj_list:
        return obj_list[0].get("properties", {})
    return {}


def short_font(name):
    if not name:
        return None
    return name.split(",")[0].replace("''", "'").strip("'").strip()


def audit_report(report_dir: Path) -> dict:
    definition = report_dir / "definition"
    result = {
        "name": report_dir.name.replace(".Report", ""),
        "theme": None,
        "pages": [],
        "title_fonts": Counter(),
        "title_sizes": Counter(),
        "title_colors": Counter(),
        "title_bold": Counter(),
        "radius": Counter(),
        "border_colors": Counter(),
        "shadow_colors": Counter(),
        "kpi_value_sizes": Counter(),
        "visual_types": Counter(),
        "images": [],
        "offcanvas": [],
        "hidden_visuals": 0,
    }

    report_json = definition / "report.json"
    if report_json.exists():
        rj = json.loads(report_json.read_text())
        theme = rj.get("themeCollection", {}).get("customTheme", {})
        result["theme"] = theme.get("name")

    pages_meta = {}
    pages_json = definition / "pages" / "pages.json"
    if pages_json.exists():
        pages_meta = json.loads(pages_json.read_text())
    page_order = pages_meta.get("pageOrder", [])

    for page_id in page_order:
        page_dir = definition / "pages" / page_id
        page_file = page_dir / "page.json"
        if not page_file.exists():
            continue
        pj = json.loads(page_file.read_text())
        page = {
            "id": page_id,
            "display": pj.get("displayName", page_id),
            "size": f'{pj.get("width")}x{pj.get("height")}',
            "displayOption": pj.get("displayOption"),
            "hidden": pj.get("visibility") == "HiddenInViewMode",
            "kpi_rows": [],
            "slicers": [],
            "bottom": 0,
            "n_visuals": 0,
        }
        cards = []
        for visual_file in sorted(page_dir.glob("visuals/*/visual.json")):
            vj = json.loads(visual_file.read_text())
            pos = vj.get("position", {})
            x, y = pos.get("x", 0), pos.get("y", 0)
            w, h = pos.get("width", 0), pos.get("height", 0)
            visual = vj.get("visual", {})
            vtype = visual.get("visualType") or ("group" if "visualGroup" in vj else "?")
            result["visual_types"][vtype] += 1
            page["n_visuals"] += 1

            if vj.get("isHidden"):
                result["hidden_visuals"] += 1
            if x < -50 or y < -50:
                result["offcanvas"].append(f'{page["display"]}:{vj.get("name")}')
                continue
            page["bottom"] = max(page["bottom"], y + h)

            vco = visual.get("visualContainerObjects", {})
            title = first_props(vco.get("title"))
            if title:
                font = short_font(lit(title.get("fontFamily")))
                if font:
                    result["title_fonts"][font] += 1
                size = lit(title.get("fontSize"))
                if size:
                    result["title_sizes"][size] += 1
                color = lit(title.get("fontColor"))
                if color:
                    result["title_colors"][color] += 1
                bold = lit(title.get("bold"))
                if bold:
                    result["title_bold"][bold] += 1
            border = first_props(vco.get("border"))
            radius = lit(border.get("radius")) if border else None
            if radius:
                result["radius"][radius] += 1
            bcolor = lit(border.get("color")) if border else None
            if bcolor:
                result["border_colors"][bcolor] += 1
            shadow = first_props(vco.get("dropShadow"))
            scolor = lit(shadow.get("color")) if shadow else None
            if scolor:
                result["shadow_colors"][scolor] += 1

            if vtype in ("cardVisual", "card"):
                value_props = first_props(visual.get("objects", {}).get("value")) or first_props(
                    visual.get("objects", {}).get("labels")
                )
                vsize = lit(value_props.get("fontSize")) if value_props else None
                if vsize:
                    result["kpi_value_sizes"][vsize] += 1
                cards.append((x, y, w, h))
            elif vtype == "slicer":
                page["slicers"].append((round(x), round(w), round(h)))
            elif vtype == "image":
                result["images"].append(
                    f'{page["display"]}: ({round(x,1)},{round(y,1)},{round(w,1)}x{round(h,1)})'
                )

        # group KPI cards into rows by y
        rows = defaultdict(list)
        for x, y, w, h in cards:
            rows[round(y / 8) * 8].append((x, w, h))
        for row_y, row_cards in sorted(rows.items()):
            row_cards.sort()
            gaps = [
                round(row_cards[i + 1][0] - (row_cards[i][0] + row_cards[i][1]), 1)
                for i in range(len(row_cards) - 1)
            ]
            heights = sorted({round(c[2]) for c in row_cards})
            page["kpi_rows"].append(
                {"y": row_y, "n": len(row_cards), "h": heights, "gaps": gaps}
            )
        result["pages"].append(page)
    return result


IQD = "د.ع"
CHART_TYPES = {
    "columnChart", "barChart", "lineChart", "areaChart", "clusteredColumnChart",
    "clusteredBarChart", "stackedColumnChart", "stackedBarChart", "donutChart",
    "pieChart", "lineClusteredColumnComboChart", "lineStackedColumnComboChart",
    "hundredPercentStackedColumnChart",
}


def parse_model_formats(model_dir: Path):
    """Return (money measure names, percent measure names, bad percent formats)."""
    money, percent, bad_pct = set(), set(), []
    tables_dir = model_dir / "definition" / "tables"
    if not tables_dir.is_dir():
        return money, percent, bad_pct
    for tmdl in tables_dir.glob("*.tmdl"):
        owner = None
        for line in tmdl.read_bytes().decode("utf-8", errors="replace").splitlines():
            m = re.match(r"\tmeasure\s+(?:'(.*?)'|(\S+))", line)
            if m:
                owner = m.group(1) or m.group(2)
            if "formatString:" in line and owner:
                fmt = line.split("formatString:", 1)[1].strip()
                if IQD in fmt:
                    money.add(owner)
                if "%" in fmt:
                    percent.add(owner)
                    if "0.00%" not in fmt:
                        bad_pct.append(f"{owner}: {fmt}")
    return money, percent, bad_pct


def merged_lit(obj_list, key):
    """First literal value for `key` across selector-less entries of a PBIR object."""
    for entry in obj_list or []:
        if "selector" in entry:
            continue
        value = lit(entry.get("properties", {}).get(key))
        if value is not None:
            return value
    return None


def audit_formatting(report_dir: Path) -> list[str]:
    """Violations of the number-formatting standard for one report."""
    violations = []
    model_dir = report_dir.parent / report_dir.name.replace(".Report", ".SemanticModel")
    money, percent, bad_pct = parse_model_formats(model_dir)
    for fmt in bad_pct:
        violations.append(f"model: percent format not 0.00%-based — {fmt}")

    for visual_file in sorted((report_dir / "definition" / "pages").glob("*/visuals/*/visual.json")):
        vj = json.loads(visual_file.read_text())
        visual = vj.get("visual", {})
        vtype = visual.get("visualType")
        name = vj.get("name", visual_file.parent.name)
        objects = visual.get("objects", {})

        fields = [
            p.get("queryRef", "")
            for bucket in visual.get("query", {}).get("queryState", {}).values()
            for p in bucket.get("projections", [])
        ]
        measures = {f.split(".", 1)[1] for f in fields if "." in f and "(" not in f}

        if vtype == "cardVisual":
            # card formatting lives in selector entries ({"id": "default"} or per-measure)
            entries = [
                (lit(e.get("properties", {}).get("labelDisplayUnits")),
                 lit(e.get("properties", {}).get("labelPrecision")))
                for e in objects.get("value", []) or []
            ]
            for units, prec in entries:
                if units == "0":
                    violations.append(f"card {name}: Auto display units (banned — KM bug)")
                if measures & money and units == "1000000000" and prec != "3":
                    violations.append(f"card {name}: bn card precision {prec} != 3")
            if measures and measures <= percent and entries and not any(
                prec == "2" for _, prec in entries
            ):
                violations.append(f"card {name}: percent card precision != 2")
        elif vtype in ("pivotTable", "tableEx") and "tooltip" not in name:
            grid = merged_lit(objects.get("grid"), "textSize")
            vals = merged_lit(objects.get("values"), "fontSize")
            hdr_size = merged_lit(objects.get("columnHeaders"), "fontSize")
            hdr_bold = merged_lit(objects.get("columnHeaders"), "bold")
            tot_key = "subTotals" if vtype == "pivotTable" else "total"
            tot_bold = merged_lit(objects.get(tot_key), "bold")
            for label, got, want in (("grid size", grid, "14"), ("values size", vals, "13"),
                                     ("header size", hdr_size, "12"), ("header bold", hdr_bold, "true"),
                                     ("totals bold", tot_bold, "true")):
                if got != want:
                    violations.append(f"table {name}: {label} {got} != {want}")
        elif vtype in CHART_TYPES:
            labels = objects.get("labels")
            if merged_lit(labels, "show") == "true":
                units = merged_lit(labels, "labelDisplayUnits")
                prec = merged_lit(labels, "labelPrecision")
                if units == "1000000" and prec != "1":
                    violations.append(f"chart {name}: M-unit labels precision {prec} != 1")
                elif units == "1000000000" and prec != "3":
                    violations.append(f"chart {name}: bn-unit labels precision {prec} != 3")
                elif units in (None, "0") and measures and measures <= money and prec != "1":
                    violations.append(f"chart {name}: auto-unit money labels precision {prec} != 1")
    return violations


def audit_layout(audit: dict) -> list[str]:
    """Actionable violations of the shared Fabric layout standard."""
    violations = []
    if audit["theme"] != EXPECTED["theme"]:
        violations.append(f'theme {audit["theme"]!r} != {EXPECTED["theme"]!r}')

    for page in audit["pages"]:
        if page["hidden"]:
            continue
        if page["size"] != EXPECTED["canvas"] or page["displayOption"] != "FitToPage":
            violations.append(
                f'page {page["display"]}: canvas {page["size"]}/{page["displayOption"]} '
                f'!= {EXPECTED["canvas"]}/FitToPage'
            )
        if round(page["bottom"]) not in ALLOWED["bottom_lines"]:
            violations.append(
                f'page {page["display"]}: bottom line {round(page["bottom"])} '
                f'not in {sorted(ALLOWED["bottom_lines"])}'
            )
        for row in page["kpi_rows"]:
            if row["y"] <= 200 and row["h"] != [EXPECTED["kpi_height"]]:
                violations.append(
                    f'page {page["display"]}: top KPI height {row["h"]} '
                    f'!= [{EXPECTED["kpi_height"]}]'
                )
        for x, width, _ in page["slicers"]:
            # Paper Inventory keeps three wired support slicers parked to the
            # right of the canvas. They are not part of the visible rail.
            if x <= 1920 and width != EXPECTED["rail_width"]:
                violations.append(
                    f'page {page["display"]}: slicer width {width} '
                    f'!= {EXPECTED["rail_width"]}'
                )

    checks = (
        ("title font", audit["title_fonts"], ALLOWED["title_fonts"]),
        ("title size", audit["title_sizes"], ALLOWED["title_sizes"]),
        ("title color", audit["title_colors"], ALLOWED["title_colors"]),
        ("border color", audit["border_colors"], {EXPECTED["border_color"]}),
        ("shadow color", audit["shadow_colors"], {EXPECTED["shadow_color"]}),
        ("KPI value size", audit["kpi_value_sizes"], {EXPECTED["kpi_value_size"]}),
    )
    for label, values, allowed in checks:
        unexpected = sorted(str(value) for value in values if str(value) not in allowed)
        if unexpected:
            violations.append(
                f'{label}: unexpected value(s) {unexpected}; allowed {sorted(allowed)}'
            )

    bad_radius = []
    for value in audit["radius"]:
        try:
            matches = float(value) == float(EXPECTED["radius"])
        except (TypeError, ValueError):
            matches = False
        if not matches:
            bad_radius.append(str(value))
    bad_radius.sort()
    if bad_radius:
        violations.append(f'border radius: unexpected value(s) {bad_radius}; expected 14')
    if audit["offcanvas"]:
        violations.append(f'off-canvas visual(s): {audit["offcanvas"]}')
    return violations


def fmt_counter(counter: Counter, expected=None) -> str:
    parts = []
    for value, count in counter.most_common():
        flag = "" if expected is None or str(value) == expected else " (!)"
        parts.append(f"{value}\u00d7{count}{flag}")
    return ", ".join(parts) or "-"


def main() -> int:
    strict = "--strict" in sys.argv[1:]
    roots = [arg for arg in sys.argv[1:] if arg != "--strict"] or ["Fabric/DevelopmentWorkspace"]
    report_dirs = []
    for root in roots:
        path = Path(root)
        if path.name.endswith(".Report"):
            report_dirs.append(path)
        else:
            report_dirs.extend(sorted(path.glob("**/*.Report")))
    if not report_dirs:
        print("No .Report folders found.", file=sys.stderr)
        return 1

    audits = [audit_report(d) for d in report_dirs]
    layouts = {a["name"]: audit_layout(a) for a in audits}
    formatting = {d: audit_formatting(d) for d in report_dirs}

    for a in audits:
        print(f'\n=== {a["name"]} ===')
        print(f'theme: {a["theme"]}')
        sizes = Counter(f'{p["size"]}/{p["displayOption"]}' for p in a["pages"] if not p["hidden"])
        print(f'canvas: {fmt_counter(sizes)}   pages: {sum(1 for p in a["pages"] if not p["hidden"])} visible'
              f' + {sum(1 for p in a["pages"] if p["hidden"])} hidden')
        print(f'title font: {fmt_counter(a["title_fonts"], EXPECTED["title_font"])}')
        print(f'title size: {fmt_counter(a["title_sizes"], EXPECTED["title_size"])}')
        print(f'title color: {fmt_counter(a["title_colors"], EXPECTED["title_color"])}')
        print(f'border radius: {fmt_counter(a["radius"], EXPECTED["radius"])}')
        print(f'border color: {fmt_counter(a["border_colors"], EXPECTED["border_color"])}')
        print(f'shadow color: {fmt_counter(a["shadow_colors"], EXPECTED["shadow_color"])}')
        print(f'KPI value size: {fmt_counter(a["kpi_value_sizes"], EXPECTED["kpi_value_size"])}')
        print(f'images (logos): {len(a["images"])}')
        for img in a["images"][:6]:
            print(f'   {img}')
        if len(a["images"]) > 6:
            print(f'   ... and {len(a["images"]) - 6} more')
        print(f'off-canvas visuals: {len(a["offcanvas"])} {a["offcanvas"][:4]}')
        for p in a["pages"]:
            if p["hidden"]:
                continue
            kpi = "; ".join(
                f'y={r["y"]} n={r["n"]} h={r["h"]} gaps={r["gaps"]}' for r in p["kpi_rows"]
            )
            slicer_x = sorted({s[0] for s in p["slicers"]})
            slicer_w = sorted({s[1] for s in p["slicers"]})
            print(f'  page "{p["display"]}" [{p["size"]}] visuals={p["n_visuals"]}'
                  f' bottom={round(p["bottom"])}')
            if kpi:
                print(f'     KPI: {kpi}')
            if p["slicers"]:
                print(f'     slicers: n={len(p["slicers"])} x={slicer_x} w={slicer_w}'
                      f' h={sorted({s[2] for s in p["slicers"]})}')

    print("\n=== CROSS-REPORT TOKEN COMPARISON ===")
    print(f'{"report":<28}{"theme":<38}{"radius":<12}{"title size":<12}{"KPI size":<10}{"canvas"}')
    for a in audits:
        sizes = Counter(f'{p["size"]}' for p in a["pages"] if not p["hidden"])
        canvas = sizes.most_common(1)[0][0] if sizes else "-"
        radius = "/".join(str(v) for v, _ in a["radius"].most_common()) or "-"
        tsize = "/".join(str(v) for v, _ in a["title_sizes"].most_common()) or "-"
        ksize = "/".join(str(v) for v, _ in a["kpi_value_sizes"].most_common()) or "-"
        print(f'{a["name"]:<28}{str(a["theme"]):<38}{radius:<12}{tsize:<12}{ksize:<10}{canvas}')

    print("\n=== NUMBER FORMATTING AUDIT ===")
    total = 0
    for report_dir in report_dirs:
        violations = formatting[report_dir]
        total += len(violations)
        status = "OK" if not violations else f"{len(violations)} violation(s)"
        print(f'{report_dir.name.replace(".Report", ""):<28}{status}')
        for violation in violations:
            print(f"   {violation}")
    print(f"total formatting violations: {total}")

    print("\n=== STRICT LAYOUT AUDIT ===")
    layout_total = 0
    for audit in audits:
        violations = layouts[audit["name"]]
        layout_total += len(violations)
        status = "OK" if not violations else f"{len(violations)} violation(s)"
        print(f'{audit["name"]:<28}{status}')
        for violation in violations:
            print(f"   {violation}")
    print(f"total layout violations: {layout_total}")

    if strict and (total or layout_total):
        print(
            f"\nSTRICT AUDIT FAILED: {layout_total} layout + {total} formatting violation(s)",
            file=sys.stderr,
        )
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
