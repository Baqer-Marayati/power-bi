#!/usr/bin/env python3
"""Final layout polish: align pages 2–5 with Executive Summary geometry and card formatting."""

from __future__ import annotations

import json
from pathlib import Path

REPORT_PAGES = Path(__file__).resolve().parents[1] / "Canon Inventory Report.Report/definition/pages"
REF_PAGE = "a1b2c3d4e5f6a7b8c9d0"

# Executive Summary reference geometry (1920×1080)
MAIN_X = 511.627455595395
MAIN_RIGHT = 1867.224771031637
MAIN_W = MAIN_RIGHT - MAIN_X
KPI_Y = 136.81481481481484
KPI_H = 103.5
KPI_GAP = 20.617451664430664
CHART_Y = 260.625
CHART_H = 358.40625
CHART_HALF_W = 664.462890625
CHART_RIGHT_X = MAIN_X + CHART_HALF_W + 26.171079756469726
TABLE_Y = 648.28125
TABLE_H = 381.65625
CONTENT_BOTTOM = 1030.0
EXEC_PANEL_H = 893.33333333333337

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


def polish_table_objects(objects: dict, ref_objects: dict, container_width: float) -> None:
    ref_grid = ref_objects.get("grid", [{}])[0].get("properties", {})
    grid = objects.setdefault("grid", [{}])
    if not grid:
        grid.append({})
    props = grid[0].setdefault("properties", {})
    if "textSize" in ref_grid:
        props["textSize"] = ref_grid["textSize"]
    if "rowPadding" in ref_grid:
        props["rowPadding"] = ref_grid["rowPadding"]

    column_widths = objects.get("columnWidth")
    if not column_widths:
        return
    total = 0.0
    parsed: list[tuple[dict, float]] = []
    for entry in column_widths:
        raw = entry.get("properties", {}).get("value", {}).get("expr", {}).get("Literal", {}).get("Value", "0D")
        try:
            val = float(str(raw).rstrip("D"))
        except ValueError:
            val = 0.0
        parsed.append((entry, val))
        total += val
    if total <= 0:
        return
    scale = container_width / total
    for entry, val in parsed:
        entry["properties"]["value"] = {
            "expr": {"Literal": {"Value": f"{val * scale}D"}}
        }


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

    panel_path = visuals_dir / "panel_filter_dropdowns" / "visual.json"
    if panel_path.exists():
        panel = load_json(panel_path)
        panel["position"]["height"] = EXEC_PANEL_H
        save_json(panel_path, panel)

    kpi_names = sorted(p.name for p in visuals_dir.iterdir() if p.is_dir() and p.name.startswith("kpi_"))
    if "kpis" in layout:
        count = int(layout["kpis"][0])
        slots = kpi_slots(count)
        for idx, name in enumerate(kpi_names[:count]):
            path = visuals_dir / name / "visual.json"
            if not path.exists():
                continue
            data = load_json(path)
            x, w = slots[idx]
            set_position(data, x, KPI_Y, w, KPI_H)
            fix_kpi_card(data)
            save_json(path, data)

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
            polish_table_objects(data["visual"].get("objects", {}), ref_table_objects, geom[2])
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
