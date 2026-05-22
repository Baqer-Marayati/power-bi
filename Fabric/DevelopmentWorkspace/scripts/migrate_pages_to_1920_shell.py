#!/usr/bin/env python3
"""Migrate Canon Inventory Report pages 2–5 to match Executive Summary 1920×1080 shell."""

from __future__ import annotations

import copy
import json
import re
import shutil
from pathlib import Path

REPORT_PAGES = Path(__file__).resolve().parents[1] / "Canon Inventory Report.Report/definition/pages"
REF_PAGE = "a1b2c3d4e5f6a7b8c9d0"
TARGET_PAGES = [
    "c7d8e9f0a1b2c3d4e5f6",
    "f6a7b8c9d0e1f2a3b4c5",
    "a7b8c9d0e1f2a3b4c5d6",
    "e5f6a7b8c9d0e1f2a3b4",
]

# Layout from polished Executive Summary (Fabric d34a034+)
OLD_MAIN_X = 188
NEW_MAIN_X = 511.627455595395
OLD_PAGE_W = 1280
OLD_PAGE_H = 960
NEW_PAGE_W = 1920
NEW_PAGE_H = 1080
RIGHT_MARGIN = 48
SX = (NEW_PAGE_W - NEW_MAIN_X - RIGHT_MARGIN) / (OLD_PAGE_W - OLD_MAIN_X)
SY = NEW_PAGE_H / OLD_PAGE_H

SLICER_X = 66.666666666666671
SLICER_W = 404
FIRST_DROPDOWN_Y = 150.37722908093281
DROPDOWN_GAP = 16.851851851851848  # avg gap between stacked dropdowns on ref page
DEFAULT_DROPDOWN_H = 76.5
SEARCH_GAP = 37.14848228059853
ITEM_SEARCH_H = 184
PANEL_X = 55
PANEL_Y = 136.66666666666669
PANEL_W = 428.33333333333337
PANEL_BOTTOM_PAD = 24

HEADER_POS = {
    "x": 511.627455595395,
    "y": 42.314814814814817,
    "width": 695.83892617449658,
    "height": 67.5,
}
BRAND_GROUP_POS = {
    "x": 1492.2449052598247,
    "y": 46.814814814814817,
    "width": 356,
    "height": 63,
}

PAGE_DROPDOWN_SLICERS: dict[str, list[str]] = {
    "c7d8e9f0a1b2c3d4e5f6": ["slicer_warehouse", "slicer_item"],
    "e5f6a7b8c9d0e1f2a3b4": [
        "slicer_year",
        "slicer_quarter",
        "slicer_month",
        "slicer_group_type",
        "slicer_product_type",
        "slicer_segment_type",
        "slicer_item_group",
    ],
    "f6a7b8c9d0e1f2a3b4c5": [
        "slicer_group_type",
        "slicer_product_type",
        "slicer_segment_type",
        "slicer_item_group",
    ],
    "a7b8c9d0e1f2a3b4c5d6": [
        "slicer_group_type",
        "slicer_product_type",
        "slicer_segment_type",
        "slicer_item_group",
        "slicer_stock_status",
    ],
}

PAGE_ITEM_SEARCH: dict[str, str | None] = {
    "c7d8e9f0a1b2c3d4e5f6": "slicer_item_search",
    "e5f6a7b8c9d0e1f2a3b4": None,
    "f6a7b8c9d0e1f2a3b4c5": None,
    "a7b8c9d0e1f2a3b4c5d6": "slicer_item_search",
}

SHELL_NAMES = {
    "panel_filter_dropdowns",
    "brand_group",
    "brand_logo_aj",
    "brand_logo_canon",
    "brand_divider",
}
OLD_SHELL_NAMES = {"logo_aj", "logo_canon", "logo_divider", "logo_group"}


def load_json(path: Path) -> dict:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def save_json(path: Path, data: dict) -> None:
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def deep_merge(dst: dict, src: dict, skip_keys: set[str] | None = None) -> dict:
    skip_keys = skip_keys or set()
    for key, val in src.items():
        if key in skip_keys:
            continue
        if key in dst and isinstance(dst[key], dict) and isinstance(val, dict):
            deep_merge(dst[key], val, skip_keys)
        else:
            dst[key] = copy.deepcopy(val)
    return dst


def literal_str(expr_obj) -> str | None:
    try:
        return expr_obj["expr"]["Literal"]["Value"].strip("'")
    except (KeyError, TypeError):
        return None


def transform_content_position(pos: dict) -> None:
    x, y, w, h = pos["x"], pos["y"], pos["width"], pos["height"]
    if x >= OLD_MAIN_X - 8:
        pos["x"] = NEW_MAIN_X + (x - OLD_MAIN_X) * SX
        pos["width"] = w * SX
    pos["y"] = y * SY
    pos["height"] = h * SY


def dropdown_slots(count: int) -> list[tuple[float, float]]:
    slots: list[tuple[float, float]] = []
    y = FIRST_DROPDOWN_Y
    for _ in range(count):
        slots.append((y, DEFAULT_DROPDOWN_H))
        y += DEFAULT_DROPDOWN_H + DROPDOWN_GAP
    return slots


def compute_panel_height(last_bottom: float) -> float:
    return last_bottom + PANEL_BOTTOM_PAD - PANEL_Y


def apply_dropdown_slicer_style(target: dict, template: dict, y: float, height: float, header_text: str) -> None:
    keep_query = copy.deepcopy(target["visual"].get("query"))
    keep_name = target["name"]
    keep_tab = target["position"].get("tabOrder")
    keep_z = target["position"].get("z")

    target["visual"] = copy.deepcopy(template["visual"])
    target["name"] = keep_name
    if keep_query:
        target["visual"]["query"] = keep_query

    target["position"]["x"] = SLICER_X
    target["position"]["y"] = y
    target["position"]["width"] = SLICER_W
    target["position"]["height"] = height
    if keep_tab is not None:
        target["position"]["tabOrder"] = keep_tab
    if keep_z is not None:
        target["position"]["z"] = keep_z

    header = target["visual"]["objects"].get("header", [{}])[0]
    props = header.setdefault("properties", {})
    props["show"] = {"expr": {"Literal": {"Value": "true"}}}
    props["text"] = {"expr": {"Literal": {"Value": f"'{header_text}'"}}}


def apply_item_search_style(target: dict, template: dict, y: float) -> None:
    keep_query = copy.deepcopy(target["visual"].get("query"))
    keep_name = target["name"]
    keep_tab = target["position"].get("tabOrder")
    keep_z = target["position"].get("z")

    target["visual"] = copy.deepcopy(template["visual"])
    target["name"] = keep_name
    if keep_query:
        target["visual"]["query"] = keep_query

    target["position"]["x"] = SLICER_X
    target["position"]["y"] = y
    target["position"]["width"] = SLICER_W
    target["position"]["height"] = ITEM_SEARCH_H
    if keep_tab is not None:
        target["position"]["tabOrder"] = keep_tab
    if keep_z is not None:
        target["position"]["z"] = keep_z


def slicer_header_from_label(page_dir: Path, slicer_name: str, slicer_data: dict) -> str:
    label_map = {
        "slicer_warehouse": "label_warehouse",
        "slicer_item": "label_item",
        "slicer_year": "label_year",
        "slicer_quarter": "label_quarter",
        "slicer_month": "label_month",
        "slicer_group_type": "label_group_type",
        "slicer_product_type": "label_product_type",
        "slicer_segment_type": "label_segment_type",
        "slicer_item_group": "label_item_group",
        "slicer_stock_status": "label_stock_status",
    }
    label_name = label_map.get(slicer_name)
    if label_name:
        label_path = page_dir / "visuals" / label_name / "visual.json"
        if label_path.exists():
            label = load_json(label_path)
            txt = (
                label.get("visual", {})
                .get("visualContainerObjects", {})
                .get("title", [{}])[0]
                .get("properties", {})
                .get("text", {})
            )
            s = literal_str(txt)
            if s:
                return s

    hdr = slicer_data.get("visual", {}).get("objects", {}).get("header", [{}])[0]
    s = literal_str(hdr.get("properties", {}).get("text", {}))
    if s:
        return s
    return slicer_name.replace("slicer_", "").replace("_", " ").title()


def apply_kpi_style(target: dict, template: dict) -> None:
    title_text = None
    vco = target.get("visual", {}).get("visualContainerObjects", {})
    if vco.get("title"):
        title_text = literal_str(vco["title"][0].get("properties", {}).get("text", {}))

    keep_query = copy.deepcopy(target["visual"].get("query"))
    keep_name = target["name"]
    keep_pos = copy.deepcopy(target["position"])
    keep_tab = keep_pos.get("tabOrder")
    keep_z = keep_pos.get("z")

    target["visual"] = copy.deepcopy(template["visual"])
    target["name"] = keep_name
    target["position"] = keep_pos
    if keep_query:
        target["visual"]["query"] = keep_query

    if title_text:
        target["visual"]["visualContainerObjects"]["title"][0]["properties"]["text"] = {
            "expr": {"Literal": {"Value": f"'{title_text}'"}}
        }

    transform_content_position(target["position"])
    if keep_tab is not None:
        target["position"]["tabOrder"] = keep_tab
    if keep_z is not None:
        target["position"]["z"] = keep_z


def apply_chart_table_shell(target: dict, template_vco: dict) -> None:
    keep_query = copy.deepcopy(target["visual"].get("query"))
    keep_name = target["name"]
    keep_pos = copy.deepcopy(target["position"])
    keep_visual_type = target["visual"]["visualType"]
    keep_objects = copy.deepcopy(target["visual"].get("objects", {}))
    keep_tab = keep_pos.get("tabOrder")
    keep_z = keep_pos.get("z")

    title_text = None
    vco = target.get("visual", {}).get("visualContainerObjects", {})
    if vco.get("title"):
        title_text = literal_str(vco["title"][0].get("properties", {}).get("text", {}))

    if "visualContainerObjects" not in target["visual"]:
        target["visual"]["visualContainerObjects"] = {}
    deep_merge(target["visual"]["visualContainerObjects"], copy.deepcopy(template_vco))

    target["visual"]["visualType"] = keep_visual_type
    target["visual"]["objects"] = keep_objects
    target["visual"]["query"] = keep_query
    target["name"] = keep_name
    target["position"] = keep_pos

    if title_text and target["visual"]["visualContainerObjects"].get("title"):
        target["visual"]["visualContainerObjects"]["title"][0]["properties"]["text"] = {
            "expr": {"Literal": {"Value": f"'{title_text}'"}}
        }

    transform_content_position(target["position"])
    if keep_tab is not None:
        target["position"]["tabOrder"] = keep_tab
    if keep_z is not None:
        target["position"]["z"] = keep_z


def apply_header_style(target: dict, ref_header: dict) -> None:
    title_text = literal_str(
        target.get("visual", {})
        .get("visualContainerObjects", {})
        .get("title", [{}])[0]
        .get("properties", {})
        .get("text", {})
    )
    subtitle_text = literal_str(
        target.get("visual", {})
        .get("visualContainerObjects", {})
        .get("subTitle", [{}])[0]
        .get("properties", {})
        .get("text", {})
    )

    keep_name = target["name"]
    keep_z = target["position"].get("z")
    keep_tab = target["position"].get("tabOrder")

    target["visual"] = copy.deepcopy(ref_header["visual"])
    target["name"] = keep_name
    target["position"] = copy.deepcopy(HEADER_POS)
    if keep_z is not None:
        target["position"]["z"] = keep_z
    if keep_tab is not None:
        target["position"]["tabOrder"] = keep_tab

    if title_text:
        target["visual"]["visualContainerObjects"]["title"][0]["properties"]["text"] = {
            "expr": {"Literal": {"Value": f"'{title_text}'"}}
        }
    if subtitle_text and target["visual"]["visualContainerObjects"].get("subTitle"):
        target["visual"]["visualContainerObjects"]["subTitle"][0]["properties"]["text"] = {
            "expr": {"Literal": {"Value": f"'{subtitle_text}'"}}
        }


def update_page_json(page_path: Path) -> None:
    data = load_json(page_path)
    data["width"] = NEW_PAGE_W
    data["height"] = NEW_PAGE_H
    data["displayOption"] = "FitToPage"
    data["$schema"] = "https://developer.microsoft.com/json-schemas/fabric/item/report/definition/page/2.1.0/schema.json"
    save_json(page_path, data)


def migrate_page(page_id: str, ref_dir: Path, dropdown_tpl: dict, search_tpl: dict, kpi_tpl: dict, chart_vco: dict, table_vco: dict, ref_header: dict) -> None:
    page_dir = REPORT_PAGES / page_id
    visuals_dir = page_dir / "visuals"

    update_page_json(page_dir / "page.json")

    # Remove old labels and logo shell
    for child in list(visuals_dir.iterdir()):
        if not child.is_dir():
            continue
        name = child.name
        if name.startswith("label_") or name in OLD_SHELL_NAMES:
            shutil.rmtree(child)

    # Copy reference shell visuals if missing
    for shell in SHELL_NAMES:
        src = ref_dir / "visuals" / shell
        dst = visuals_dir / shell
        if src.exists():
            if dst.exists():
                shutil.rmtree(dst)
            shutil.copytree(src, dst)

    # Panel height based on slicer stack
    dropdown_names = PAGE_DROPDOWN_SLICERS[page_id]
    slots = dropdown_slots(len(dropdown_names))
    last_bottom = slots[-1][0] + slots[-1][1] if slots else FIRST_DROPDOWN_Y

    item_search_name = PAGE_ITEM_SEARCH.get(page_id)
    if item_search_name:
        search_y = last_bottom + SEARCH_GAP
        last_bottom = search_y + ITEM_SEARCH_H
    else:
        search_y = None

    panel_path = visuals_dir / "panel_filter_dropdowns" / "visual.json"
    if panel_path.exists():
        panel = load_json(panel_path)
        panel["position"]["x"] = PANEL_X
        panel["position"]["y"] = PANEL_Y
        panel["position"]["width"] = PANEL_W
        panel["position"]["height"] = compute_panel_height(last_bottom)
        save_json(panel_path, panel)

    brand_group_path = visuals_dir / "brand_group" / "visual.json"
    if brand_group_path.exists():
        bg = load_json(brand_group_path)
        bg["position"] = copy.deepcopy(BRAND_GROUP_POS)
        bg["position"]["z"] = bg["position"].get("z", 24000)
        save_json(brand_group_path, bg)

    # Style dropdown slicers
    for idx, slicer_name in enumerate(dropdown_names):
        slicer_path = visuals_dir / slicer_name / "visual.json"
        if not slicer_path.exists():
            print(f"  WARN missing slicer {slicer_name} on {page_id}")
            continue
        data = load_json(slicer_path)
        y, h = slots[idx]
        header = slicer_header_from_label(page_dir, slicer_name, data)
        apply_dropdown_slicer_style(data, dropdown_tpl, y, h, header)
        save_json(slicer_path, data)

    if item_search_name and search_y is not None:
        search_path = visuals_dir / item_search_name / "visual.json"
        if search_path.exists():
            data = load_json(search_path)
            apply_item_search_style(data, search_tpl, search_y)
            save_json(search_path, data)

    # Migrate remaining visuals
    for child in visuals_dir.iterdir():
        if not child.is_dir():
            continue
        name = child.name
        vpath = child / "visual.json"
        if not vpath.exists():
            continue
        data = load_json(vpath)

        if name == "header_shape":
            apply_header_style(data, ref_header)
            save_json(vpath, data)
            continue

        if name in SHELL_NAMES or name in PAGE_DROPDOWN_SLICERS[page_id] or name == item_search_name:
            continue

        vtype = data.get("visual", {}).get("visualType", "")
        pos = data.get("position", {})
        x = pos.get("x", 0)

        if name.startswith("kpi_") and vtype == "cardVisual":
            apply_kpi_style(data, kpi_tpl)
            save_json(vpath, data)
        elif vtype in ("areaChart", "lineChart", "clusteredColumnChart", "donutChart", "pieChart", "barChart"):
            apply_chart_table_shell(data, chart_vco)
            save_json(vpath, data)
        elif vtype in ("pivotTable", "tableEx"):
            apply_chart_table_shell(data, table_vco)
            save_json(vpath, data)
        elif x >= OLD_MAIN_X - 8 and name not in OLD_SHELL_NAMES:
            transform_content_position(pos)
            save_json(vpath, data)

    print(f"  migrated {page_id}")


def main() -> None:
    ref_dir = REPORT_PAGES / REF_PAGE
    dropdown_tpl = load_json(ref_dir / "visuals/slicer_year/visual.json")
    search_tpl = load_json(ref_dir / "visuals/slicer_item_search/visual.json")
    kpi_tpl = load_json(ref_dir / "visuals/kpi_sales/visual.json")
    chart_vco = load_json(ref_dir / "visuals/chart_trend/visual.json")["visual"]["visualContainerObjects"]
    table_vco = load_json(ref_dir / "visuals/f6ef055d0a86a7874a04/visual.json")["visual"]["visualContainerObjects"]
    ref_header = load_json(ref_dir / "visuals/header_shape/visual.json")

    print(f"Content scale SX={SX:.4f} SY={SY:.4f}")
    for page_id in TARGET_PAGES:
        migrate_page(page_id, ref_dir, dropdown_tpl, search_tpl, kpi_tpl, chart_vco, table_vco, ref_header)
    print("Done.")


if __name__ == "__main__":
    main()
