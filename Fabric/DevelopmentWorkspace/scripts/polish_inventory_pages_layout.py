#!/usr/bin/env python3
"""Final layout polish: align pages 2–5 with Executive Summary geometry and card formatting."""

from __future__ import annotations

import copy
import json
from pathlib import Path

REPORT_PAGES = Path(__file__).resolve().parents[1] / "Canon Inventory Report.Report/definition/pages"
MODULE_PAGES = (
    Path(__file__).resolve().parents[3]
    / "Reports/Inventory/Companies/CANON/Canon Inventory Report/Canon Inventory Report.Report/definition/pages"
)
REF_PAGE = "a1b2c3d4e5f6a7b8c9d0"

# Executive Summary reference geometry (1920×1080)
MAIN_X = 511.627455595395
MAIN_RIGHT = 1867.224771031637
MAIN_W = MAIN_RIGHT - MAIN_X
KPI_Y = 152.0  # below page title + subtitle (header ends ~110px)
KPI_H = 103.5
KPI_GAP = 20.617451664430664
CHART_Y = 276.0  # KPI row + gap
CHART_H = 358.40625
CHART_HALF_W = 664.462890625
CHART_RIGHT_X = MAIN_X + CHART_HALF_W + 26.171079756469726
TABLE_Y = 663.0  # chart row + gap
TABLE_H = 381.65625
CONTENT_BOTTOM = 1030.0
EXEC_PANEL_H = 893.33333333333337
HEADER_Z = 23000

PAGE_KPI_ORDER: dict[str, list[str]] = {
    "c7d8e9f0a1b2c3d4e5f6": [
        "kpi_stock_value",
        "kpi_stock_qty",
        "kpi_avg_cost",
        "kpi_item_count",
        "kpi_gr_value",
    ],
    "f6a7b8c9d0e1f2a3b4c5": [
        "kpi_below_reorder",
        "kpi_instock_rate",
        "kpi_avg_age",
        "kpi_out_of_stock",
        "kpi_gr_value",
    ],
    "e5f6a7b8c9d0e1f2a3b4": [
        "kpi_purchase_unit_cost",
        "kpi_addon_pct",
        "kpi_largest_driver",
        "kpi_avg_cogs",
        "kpi_landed_unit",
    ],
}

TABLE_COLUMN_RESTORE: dict[str, str] = {
    "a7b8c9d0e1f2a3b4c5d6": "table_reorder_actions",
    "e5f6a7b8c9d0e1f2a3b4": "table_cost_impact",
}

PAGE_LAYOUTS: dict[str, dict[str, tuple[float, float, float, float]]] = {
    "c7d8e9f0a1b2c3d4e5f6": {
        "kpis": (5, KPI_Y, KPI_H, 0),
        "chart_donut": (MAIN_X, CHART_Y, MAIN_W, CHART_H),
        "matrix_detail": (MAIN_X, TABLE_Y, MAIN_W, TABLE_H),
    },
    "f6a7b8c9d0e1f2a3b4c5": {
        "kpis": (5, KPI_Y, KPI_H, 0),
        "chart_instock_donut": (MAIN_X, CHART_Y, CHART_HALF_W, CHART_H),
        "chart_stock_level": (CHART_RIGHT_X, CHART_Y, CHART_HALF_W, CHART_H),
        "chart_reorder_by_grp": (MAIN_X, TABLE_Y, CHART_HALF_W, TABLE_H),
        "chart_reorder_by_whs": (CHART_RIGHT_X, TABLE_Y, CHART_HALF_W, TABLE_H),
    },
    "a7b8c9d0e1f2a3b4c5d6": {
        "table_reorder_actions": (MAIN_X, KPI_Y, MAIN_W, CONTENT_BOTTOM - KPI_Y),
    },
    "e5f6a7b8c9d0e1f2a3b4": {
        "kpis": (5, KPI_Y, KPI_H, 0),
        "chart_purchase_vs_cogs": (MAIN_X, CHART_Y, CHART_HALF_W, CHART_H),
        "chart_landed_mix": (CHART_RIGHT_X, CHART_Y, CHART_HALF_W, CHART_H),
        "table_cost_impact": (MAIN_X, TABLE_Y, MAIN_W, TABLE_H),
    },
}


def load_json(path: Path) -> dict:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def save_json(path: Path, data: dict) -> None:
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def kpi_slots(count: int) -> list[tuple[float, float]]:
    total_gaps = (count - 1) * KPI_GAP
    card_w = (MAIN_W - total_gaps) / count
    slots: list[tuple[float, float]] = []
    x = MAIN_X
    for _ in range(count):
        slots.append((x, card_w))
        x += card_w + KPI_GAP
    return slots


def measure_query_ref(visual: dict) -> str | None:
    try:
        return visual["query"]["queryState"]["Data"]["projections"][0]["queryRef"]
    except (KeyError, IndexError, TypeError):
        return None


def fix_kpi_card(data: dict) -> None:
    query_ref = measure_query_ref(data["visual"])
    value_props = {
        "fontSize": {"expr": {"Literal": {"Value": "18D"}}},
        "bold": {"expr": {"Literal": {"Value": "false"}}},
        "labelDisplayUnits": {"expr": {"Literal": {"Value": "0D"}}},
        "labelPrecision": {"expr": {"Literal": {"Value": "2L"}}},
    }
    entries = [{"properties": dict(value_props), "selector": {"id": "default"}}]
    if query_ref:
        entries.insert(0, {"properties": dict(value_props), "selector": {"metadata": query_ref}})
    data["visual"]["objects"]["value"] = entries

    title = data["visual"]["visualContainerObjects"]["title"][0]["properties"]
    title["fontSize"] = {"expr": {"Literal": {"Value": "12D"}}}
    title["bold"] = {"expr": {"Literal": {"Value": "false"}}}


def column_width_value(entry: dict) -> float | None:
    props = entry.get("properties", {})
    if "value" not in props:
        return None
    raw = props["value"].get("expr", {}).get("Literal", {}).get("Value")
    if raw is None:
        return None
    try:
        return float(str(raw).rstrip("D"))
    except ValueError:
        return None


def scale_column_widths(column_widths: list[dict], container_width: float) -> list[dict]:
    restored = copy.deepcopy(column_widths)
    positive: list[tuple[dict, float]] = []
    for entry in restored:
        val = column_width_value(entry)
        if val is not None and val > 0:
            positive.append((entry, val))
    if not positive:
        return restored
    total = sum(v for _, v in positive)
    scale = container_width / total
    for entry, val in positive:
        entry["properties"]["value"] = {
            "expr": {"Literal": {"Value": f"{val * scale}D"}}
        }
    return restored


def restore_table_columns(page_id: str, visual_name: str, container_width: float) -> list[dict] | None:
    module_path = MODULE_PAGES / page_id / "visuals" / visual_name / "visual.json"
    if not module_path.exists():
        return None
    module = load_json(module_path)
    column_widths = module["visual"].get("objects", {}).get("columnWidth")
    if not column_widths:
        return None
    return scale_column_widths(column_widths, container_width)


def polish_table_grid(objects: dict, ref_objects: dict) -> None:
    ref_grid = ref_objects.get("grid", [{}])[0].get("properties", {})
    grid = objects.setdefault("grid", [{}])
    if not grid:
        grid.append({})
    props = grid[0].setdefault("properties", {})
    if "textSize" in ref_grid:
        props["textSize"] = ref_grid["textSize"]
    if "rowPadding" in ref_grid:
        props["rowPadding"] = ref_grid["rowPadding"]


def set_position(data: dict, x: float, y: float, w: float, h: float) -> None:
    pos = data["position"]
    pos["x"] = x
    pos["y"] = y
    pos["width"] = w
    pos["height"] = h


def polish_page(page_id: str, ref_table_objects: dict) -> None:
    page_dir = REPORT_PAGES / page_id
    layout = PAGE_LAYOUTS[page_id]
    visuals_dir = page_dir / "visuals"

    header_path = visuals_dir / "header_shape" / "visual.json"
    if header_path.exists():
        header = load_json(header_path)
        header["position"]["z"] = HEADER_Z
        save_json(header_path, header)

    panel_path = visuals_dir / "panel_filter_dropdowns" / "visual.json"
    if panel_path.exists():
        panel = load_json(panel_path)
        panel["position"]["height"] = EXEC_PANEL_H
        save_json(panel_path, panel)

    if "kpis" in layout:
        order = PAGE_KPI_ORDER.get(page_id, [])
        count = int(layout["kpis"][0])
        slots = kpi_slots(count)
        for idx, name in enumerate(order[:count]):
            path = visuals_dir / name / "visual.json"
            if not path.exists():
                print(f"  WARN missing {name} on {page_id}")
                continue
            data = load_json(path)
            x, w = slots[idx]
            set_position(data, x, KPI_Y, w, KPI_H)
            fix_kpi_card(data)
            save_json(path, data)

    restore_name = TABLE_COLUMN_RESTORE.get(page_id)
    restored_columns = None
    if restore_name:
        restored_columns = restore_table_columns(page_id, restore_name, MAIN_W)

    for name, geom in layout.items():
        if name == "kpis":
            continue
        path = visuals_dir / name / "visual.json"
        if not path.exists():
            print(f"  WARN missing {name} on {page_id}")
            continue
        data = load_json(path)
        set_position(data, *geom)
        vtype = data["visual"].get("visualType")
        if vtype in ("pivotTable", "tableEx"):
            objects = data["visual"].setdefault("objects", {})
            polish_table_grid(objects, ref_table_objects)
            if name == restore_name and restored_columns is not None:
                objects["columnWidth"] = restored_columns
            elif vtype == "pivotTable" and name == "matrix_detail":
                existing = objects.get("columnWidth")
                if existing:
                    objects["columnWidth"] = scale_column_widths(existing, geom[2])
            if data["position"].get("z", 0) < 9000:
                data["position"]["z"] = 9000
        save_json(path, data)

    print(f"  polished {page_id}")


def main() -> None:
    ref_table = load_json(REPORT_PAGES / REF_PAGE / "visuals/f6ef055d0a86a7874a04/visual.json")
    ref_objects = ref_table["visual"].get("objects", {})
    for page_id in PAGE_LAYOUTS:
        polish_page(page_id, ref_objects)
    print("Done.")


if __name__ == "__main__":
    main()
