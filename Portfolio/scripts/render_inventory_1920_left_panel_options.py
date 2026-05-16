from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


OUT = Path("/Users/baqer/Code/Power BI/Portfolio/Shared/ChatContext/images/inventory-1920-left-panel-renders")
OUT.mkdir(parents=True, exist_ok=True)

W, H = 1920, 1080

COLORS = {
    "bg": "#F8FBFF",
    "panel": "#FFFFFF",
    "panel_alt": "#F2F6FB",
    "border": "#C9D5E3",
    "navy": "#1F4E79",
    "navy_dark": "#163B5E",
    "text": "#2E3A42",
    "muted": "#6E7F8D",
    "grid": "#E8EEF5",
    "teal": "#3BA7A0",
    "orange": "#D99028",
    "red": "#B33A3A",
    "green": "#2F7A4D",
}


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/System/Library/Fonts/Supplemental/Helvetica Bold.ttf" if bold else "/System/Library/Fonts/Supplemental/Helvetica.ttf",
        "/Library/Fonts/Arial Bold.ttf" if bold else "/Library/Fonts/Arial.ttf",
    ]
    for p in candidates:
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            pass
    return ImageFont.load_default()


F = {
    "title": font(31, True),
    "h1": font(25, True),
    "h2": font(19, True),
    "body": font(16),
    "small": font(13),
    "tiny": font(11),
    "kpi": font(31, True),
    "table": font(17),
    "table_b": font(17, True),
}


def rr(d: ImageDraw.ImageDraw, xy, r=16, fill="#FFFFFF", outline=None, width=1):
    d.rounded_rectangle(xy, radius=r, fill=fill, outline=outline, width=width)


def text(d, xy, s, fill=None, f=None, anchor=None):
    d.text(xy, s, fill=fill or COLORS["text"], font=f or F["body"], anchor=anchor)


def line_chart(d, box, series, colors, labels=None, ylabels=None, area=False):
    x0, y0, x1, y1 = box
    plot = (x0 + 45, y0 + 60, x1 - 35, y1 - 55)
    px0, py0, px1, py1 = plot
    for i in range(4):
        y = py0 + (py1 - py0) * i / 3
        d.line((px0, y, px1, y), fill=COLORS["grid"], width=1)
    months = ["Jan", "Feb", "Mar", "Apr", "May"]
    for i, m in enumerate(months):
        x = px0 + (px1 - px0) * i / (len(months) - 1)
        text(d, (x, py1 + 18), m, COLORS["muted"], F["tiny"], "mm")
    all_vals = [v for s in series for v in s]
    mn, mx = min(all_vals), max(all_vals)
    pad = (mx - mn) * 0.12 or 1
    mn -= pad
    mx += pad

    def point(i, v):
        x = px0 + (px1 - px0) * i / 4
        y = py1 - (v - mn) / (mx - mn) * (py1 - py0)
        return x, y

    for s, c in zip(series, colors):
        pts = [point(i, v) for i, v in enumerate(s)]
        if area:
            poly = pts + [(pts[-1][0], py1), (pts[0][0], py1)]
            d.polygon(poly, fill="#C7D7E7")
        d.line(pts, fill=c, width=4, joint="curve")
        for x, y in pts:
            d.ellipse((x - 4, y - 4, x + 4, y + 4), fill=c)
    if labels:
        lx = x0 + 25
        ly = y0 + 38
        for lab, c in zip(labels, colors):
            d.ellipse((lx, ly - 5, lx + 10, ly + 5), fill=c)
            text(d, (lx + 16, ly - 8), lab, COLORS["text"], F["tiny"])
            lx += 132
    if ylabels:
        for i, lab in enumerate(ylabels):
            y = py1 - (py1 - py0) * i / max(len(ylabels) - 1, 1)
            text(d, (x0 + 15, y - 8), lab, COLORS["muted"], F["tiny"])


def kpi_card(d, x, y, w, h, title, value):
    rr(d, (x, y, x + w, y + h), 12, COLORS["panel"], COLORS["border"])
    d.rounded_rectangle((x, y, x + w, y + 7), radius=12, fill=COLORS["navy"])
    text(d, (x + 20, y + 26), title, COLORS["muted"], F["small"])
    text(d, (x + 20, y + 55), value, COLORS["text"], F["kpi"])


def page_nav_pill(d, x, y, w, h, label, active=False):
    rr(d, (x, y, x + w, y + h), 12, COLORS["navy"] if active else "#FFFFFF", COLORS["border"])
    text(d, (x + 18, y + h / 2 - 9), label, "#FFFFFF" if active else COLORS["text"], F["small"])


def slicer_box(d, x, y, w, h, label, value="All"):
    text(d, (x, y), label, COLORS["text"], F["small"])
    rr(d, (x, y + 22, x + w, y + h), 8, "#FFFFFF", COLORS["border"])
    text(d, (x + 12, y + 36), value, COLORS["muted"], F["small"])
    text(d, (x + w - 20, y + 36), "v", COLORS["muted"], F["small"])


def checkbox(d, x, y, label, checked=False):
    d.rectangle((x, y, x + 14, y + 14), outline=COLORS["border"], fill="#FFFFFF", width=1)
    if checked:
        d.rectangle((x + 2, y + 2, x + 12, y + 12), fill=COLORS["navy"])
        text(d, (x + 7, y + 5), "✓", "#FFFFFF", F["tiny"], "mm")
    text(d, (x + 22, y - 2), label, COLORS["text"], F["tiny"])


def draw_main_content(d, left, top=70, width=None, variant="standard"):
    width = width or W - left - 55
    header_y = top
    text(d, (left, header_y), "Canon Inventory Report", COLORS["text"], F["title"])
    text(d, (left + 420, header_y + 8), "Executive Summary", COLORS["muted"], F["body"])
    text(d, (left + width - 230, header_y + 8), "Fabric Workspace", COLORS["muted"], F["body"])

    gap = 24
    k_w = (width - 3 * gap) / 4
    y = 130
    for i, (label, val) in enumerate([
        ("Total Qty", "103.73K"),
        ("Available Qty", "103.60K"),
        ("Committed Qty", "123.00"),
        ("On Order Qty", "2.81K"),
    ]):
        kpi_card(d, int(left + i * (k_w + gap)), y, int(k_w), 105, label, val)

    cy = 260
    cw = int((width - gap) / 2)
    ch = 315
    rr(d, (left, cy, left + cw, cy + ch), 14, COLORS["panel"], COLORS["border"])
    text(d, (left + 22, cy + 28), "Monthly Total COGS vs Current Total Cost", COLORS["text"], F["body"])
    line_chart(
        d,
        (left + 5, cy + 20, left + cw - 5, cy + ch - 5),
        [[0.63, 0.43, 0.53, 0.59, 0.28], [0.65, 0.44, 0.56, 0.60, 0.29]],
        [COLORS["navy"], "#7FA1BD"],
        ["Total COGS", "Current Total Cost"],
        ["0.2m د.ع", "0.4m د.ع", "0.6m د.ع"],
        True,
    )
    rx = left + cw + gap
    rr(d, (rx, cy, rx + cw, cy + ch), 14, COLORS["panel"], COLORS["border"])
    text(d, (rx + 22, cy + 28), "Average Unit COGS Trend by Business Type", COLORS["text"], F["body"])
    line_chart(
        d,
        (rx + 5, cy + 20, rx + cw - 5, cy + ch - 5),
        [[0.24, 0.235, 0.34, 0.27, 0.35], [0.105, 0.195, 0.155, 0.158, 0.13], [0.032, 0.037, 0.043, 0.037, 0.050]],
        [COLORS["navy"], COLORS["teal"], COLORS["orange"]],
        ["B2B", "B2C", "#N/A"],
        ["0.0M د.ع", "0.2M د.ع", "0.4M د.ع"],
        False,
    )

    ty = 610
    th = 400
    rr(d, (left, ty, left + width, ty + th), 14, COLORS["panel"], COLORS["border"])
    text(d, (left + 22, ty + 24), "Qty and Cost by Business Type", COLORS["text"], F["body"])
    headers = ["Business Type", "Qty", "Item COGS", "Current Item Cost", "Cost Trend"]
    xs = [left + 24, left + width * 0.43, left + width * 0.58, left + width * 0.73, left + width * 0.89]
    for x, h in zip(xs, headers):
        text(d, (int(x), ty + 60), h, COLORS["text"], F["table_b"])
    rows = [
        ("⊞  B2B", "7,140", "269,042.10 د.ع", "277,033.14 د.ع", "▲ +3.0%", COLORS["red"]),
        ("⊞  B2C", "2,918", "147,534.48 د.ع", "153,649.32 د.ع", "▲ +4.1%", COLORS["red"]),
        ("⊞  #N/A", "2,906", "36,145.01 د.ع", "32,841.60 د.ع", "▼ -9.1%", COLORS["green"]),
        ("Total", "12,964", "189,492.46 د.ع", "194,529.76 د.ع", "▲ +2.7%", COLORS["red"]),
    ]
    y0 = ty + 92
    for i, row in enumerate(rows):
        yy = y0 + i * 42
        fill = "#B7C8D8" if i == 3 else ("#F7FAFD" if i % 2 == 0 else "#FFFFFF")
        d.rectangle((left + 18, yy - 8, left + width - 18, yy + 28), fill=fill)
        ff = F["table_b"] if i == 3 else F["table"]
        text(d, (xs[0], yy), row[0], COLORS["text"], ff)
        text(d, (xs[1], yy), row[1], COLORS["text"], ff)
        text(d, (xs[2], yy), row[2], COLORS["text"], ff)
        text(d, (xs[3], yy), row[3], COLORS["text"], ff)
        text(d, (xs[4], yy), row[4], row[5], ff)


def option_a():
    img = Image.new("RGB", (W, H), COLORS["bg"])
    d = ImageDraw.Draw(img)
    # Wide light control center: feasible with shapes, buttons, native slicers, and Power BI page buttons.
    rr(d, (28, 48, 365, 1035), 20, COLORS["panel"], COLORS["border"])
    text(d, (58, 78), "Control Panel", COLORS["navy"], F["h1"])
    text(d, (58, 108), "Page navigation + report filters", COLORS["muted"], F["small"])
    text(d, (58, 155), "Pages", COLORS["text"], F["h2"])
    pages = ["Executive Summary", "Warehouse Distribution", "Stock Movements", "Product Categories", "Procurement"]
    for i, p in enumerate(pages):
        page_nav_pill(d, 58, 190 + i * 52, 276, 38, p, i == 0)
    text(d, (58, 485), "Filters", COLORS["text"], F["h2"])
    slicer_box(d, 58, 525, 276, 72, "Year", "2026")
    slicer_box(d, 58, 615, 276, 72, "Quarter", "All")
    slicer_box(d, 58, 705, 276, 72, "Business Type", "All")
    slicer_box(d, 58, 795, 276, 72, "Product Type", "All")
    rr(d, (58, 910, 178, 956), 12, COLORS["navy"], None)
    text(d, (92, 924), "Clear all", "#FFFFFF", F["small"])
    rr(d, (192, 910, 334, 956), 12, "#FFFFFF", COLORS["border"])
    text(d, (225, 924), "Help / notes", COLORS["text"], F["small"])
    draw_main_content(d, 405, 45, 1465)
    img.save(OUT / "option-a-wide-light-control-panel.png")


def option_b():
    img = Image.new("RGB", (W, H), COLORS["bg"])
    d = ImageDraw.Draw(img)
    # Dark icon dock + separate filter card: feasible with icon buttons, shapes, native slicers.
    d.rectangle((0, 0, 106, H), fill=COLORS["navy_dark"])
    text(d, (53, 64), "CI", "#FFFFFF", font(26, True), "mm")
    icons = ["⌂", "▦", "⇄", "◉", "₯", "⚙"]
    for i, ic in enumerate(icons):
        cy = 150 + i * 86
        active = i == 0
        d.ellipse((28, cy - 26, 78, cy + 24), fill="#FFFFFF" if active else "#244D72")
        text(d, (53, cy - 7), ic, COLORS["navy"] if active else "#DDE8F2", font(19, True), "mm")
    text(d, (53, 1018), "Fabric", "#DDE8F2", F["tiny"], "mm")
    rr(d, (132, 48, 445, 1035), 20, COLORS["panel"], COLORS["border"])
    text(d, (162, 78), "Executive Summary", COLORS["navy"], F["h2"])
    text(d, (162, 105), "Focused filters", COLORS["muted"], F["small"])
    text(d, (162, 158), "Time", COLORS["text"], F["h2"])
    checkbox(d, 162, 198, "2026", True)
    checkbox(d, 162, 228, "Q1", False)
    checkbox(d, 162, 258, "Q2", False)
    checkbox(d, 162, 288, "Apr", False)
    text(d, (162, 355), "Customer Mix", COLORS["text"], F["h2"])
    checkbox(d, 162, 394, "B2B", False)
    checkbox(d, 162, 424, "B2C", False)
    checkbox(d, 162, 454, "#N/A", False)
    text(d, (162, 522), "Product", COLORS["text"], F["h2"])
    slicer_box(d, 162, 560, 245, 70, "Group Type", "All")
    slicer_box(d, 162, 650, 245, 70, "Product Type", "All")
    text(d, (162, 780), "Item Search", COLORS["text"], F["h2"])
    rr(d, (162, 817, 407, 855), 8, "#F8FBFF", COLORS["border"])
    text(d, (176, 827), "Search item code or name", COLORS["muted"], F["tiny"])
    checkbox(d, 162, 878, "0002912551", False)
    checkbox(d, 162, 908, "0002944890", False)
    checkbox(d, 162, 938, "0022998020", False)
    draw_main_content(d, 485, 45, 1375)
    img.save(OUT / "option-b-icon-nav-plus-filter-card.png")


def option_c():
    img = Image.new("RGB", (W, H), COLORS["bg"])
    d = ImageDraw.Draw(img)
    # Slim page navigator + wide soft filter rail. Feasible with page navigator/buttons + native slicers/list slicers.
    rr(d, (24, 40, 120, 1040), 22, COLORS["navy"], None)
    text(d, (72, 82), "CANON", "#FFFFFF", F["small"], "mm")
    navs = [("ES", True), ("WH", False), ("MV", False), ("PR", False), ("PO", False)]
    for i, (n, active) in enumerate(navs):
        y = 155 + i * 82
        rr(d, (45, y, 99, y + 54), 16, "#FFFFFF" if active else "#2B628F", None)
        text(d, (72, y + 17), n, COLORS["navy"] if active else "#E8F1F8", F["small"], "mm")
    rr(d, (145, 40, 405, 1040), 22, "#FFFFFF", COLORS["border"])
    text(d, (172, 76), "Filter Tree", COLORS["navy"], F["h1"])
    text(d, (172, 108), "Native slicer rail", COLORS["muted"], F["small"])
    rr(d, (172, 150, 378, 190), 8, "#F8FBFF", COLORS["border"])
    text(d, (186, 160), "Search item, category...", COLORS["muted"], F["tiny"])
    text(d, (172, 235), "Selected", COLORS["text"], F["h2"])
    x = 172
    for chip in ["2026", "B2B", "Apr"]:
        rr(d, (x, 270, x + 58, 300), 15, COLORS["navy"], None)
        text(d, (x + 16, 278), chip, "#FFFFFF", F["tiny"])
        x += 68
    text(d, (172, 350), "▾ Time", COLORS["text"], F["h2"])
    checkbox(d, 178, 390, "Year > 2026", True)
    checkbox(d, 178, 420, "Quarter > All", False)
    checkbox(d, 178, 450, "Month > All", False)
    text(d, (172, 512), "▾ Product Mix", COLORS["text"], F["h2"])
    checkbox(d, 178, 552, "Business Type > All", False)
    checkbox(d, 178, 582, "Group Type > All", False)
    checkbox(d, 178, 612, "Product Type > All", False)
    checkbox(d, 178, 642, "Segment Type > All", False)
    text(d, (172, 710), "▾ Items", COLORS["text"], F["h2"])
    checkbox(d, 178, 750, "0002912551", False)
    checkbox(d, 178, 780, "0002944890", False)
    checkbox(d, 178, 810, "0022998020", False)
    rr(d, (172, 938, 265, 982), 12, COLORS["navy"], None)
    text(d, (199, 951), "Apply", "#FFFFFF", F["small"])
    rr(d, (283, 938, 378, 982), 12, "#FFFFFF", COLORS["border"])
    text(d, (307, 951), "Clear", COLORS["text"], F["small"])
    draw_main_content(d, 445, 45, 1425)
    img.save(OUT / "option-c-slim-nav-tree-filter-rail.png")


if __name__ == "__main__":
    option_a()
    option_b()
    option_c()
    print("Wrote:")
    for p in sorted(OUT.glob("option-*.png")):
        print(p)
