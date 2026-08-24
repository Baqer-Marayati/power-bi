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
Portfolio/Shared/Standards/fabric-reports-layout-standard.md expectations.

Usage:
  python3 audit-report-consistency.py <folder-or-.Report-path> [more paths...]
  # e.g. python3 Portfolio/scripts/audit-report-consistency.py Fabric/DevelopmentWorkspace
"""

from __future__ import annotations

import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

EXPECTED = {
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


def fmt_counter(counter: Counter, expected=None) -> str:
    parts = []
    for value, count in counter.most_common():
        flag = "" if expected is None or str(value) == expected else " (!)"
        parts.append(f"{value}\u00d7{count}{flag}")
    return ", ".join(parts) or "-"


def main() -> int:
    roots = sys.argv[1:] or ["Fabric/DevelopmentWorkspace"]
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
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
