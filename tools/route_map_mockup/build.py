#!/usr/bin/env python3
"""Builds the two route-map mockup pages from the bendy prototype (claude/bend-prototype/route-<id>.json) and today's 22 x 7 maps.
    python3 tools/route_map_mockup/build.py [out_dir]       (default: the current folder; writes route_board.html and master.html)
Needs: php (tools/map_layout.php), Pillow, and the prototype files (python3 tools/gen_bendy_trail_proto.py --all).
Data per route: the road curve on the region frame (from the layout), today's rows (22 x 7), the new sections (30 x 18: rows, road corners, entry, exit,
heading, tokens, landmarks, and where each sits when the sections are joined end to end). The master page also gets a small picture per section.
Templates: route_board.tpl.html, master.tpl.html (the text __DATA__ is replaced by the JSON). Region positions on the world map: region_pos.json."""
import base64, io, json, os, sys
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools"))
import gen_bendy_trail_proto as G
from gen_trail_maps import parse
OUT = sys.argv[1] if len(sys.argv) > 1 else "."
SCN = os.path.join(REPO, "game", "assets", "img", "scenes")
W, H, TILE_PX = G.W, G.H, 6
ART_LAND = {"grassland": "grassland", "forest": "forest", "coast": "coast", "tundra": "tundra", "rainforest": "forest", "wetland": "forest", "island": "coast", "desert": "coast", "mountain": "tundra"}
PAL = {"grassland": {"floor": "#b9c97a", "rough": "#9fb25f", "wall": "#4d7b3a"}, "forest": {"floor": "#a9b484", "rough": "#8c9b69", "wall": "#2f5a35"},
       "coast": {"floor": "#e4d4a2", "rough": "#d0bd86", "wall": "#6e8791"}, "tundra": {"floor": "#e7eff3", "rough": "#cdd9e2", "wall": "#7b96aa"}}
TOK = {"road": "#7a4a1e", "S": "#2f7fd6", "9": "#e8782a", "F": "#f0c32e", "E": "#d3302f", "L": "#ffffff"}
SIDE = {"E": (1, 0), "W": (-1, 0), "S": (0, 1), "N": (0, -1)}

def jpeg(path, q=70, size=None):
    im = Image.open(path).convert("RGB")
    if size: im = im.resize(size, Image.LANCZOS)
    b = io.BytesIO(); im.save(b, "JPEG", quality=q); return "data:image/jpeg;base64," + base64.b64encode(b.getvalue()).decode()

def corners(cells):
    """The turning points of a stair-step path, as [x, y] cell coordinates."""
    out = [cells[0]]
    for a, b, c in zip(cells, cells[1:], cells[2:]):
        if (b[0] - a[0], b[1] - a[1]) != (c[0] - b[0], c[1] - b[1]): out.append(b)
    return [list(p) for p in out + [cells[-1]]]

def section_png(land, s):
    """A small picture of a section: one 6 px square a tile, road line as a dot trail, tokens and landmarks in their colours."""
    p = PAL[ART_LAND[land]]; rgb = lambda h: tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))
    cols = [p["floor"], p["rough"], p["wall"], TOK["road"], TOK["S"], TOK["9"], TOK["F"], TOK["E"], TOK["L"]]
    im = Image.new("P", (W * TILE_PX, H * TILE_PX)); im.putpalette(sum((list(rgb(c)) for c in cols), []))
    px = im.load(); T = TILE_PX
    def box(x, y, i, a=0, b=None):
        b = T if b is None else b
        for yy in range(y * T + a, y * T + b):
            for xx in range(x * T + a, x * T + b): px[xx, yy] = i
    for y, row in enumerate(s["rows"]):
        for x, c in enumerate(row): box(x, y, 2 if c == "#" else 1 if c == "," else 0)
    for x, y in s["line"]: box(x, y, 3, 2, 4)
    for y, row in enumerate(s["rows"]):
        for x, c in enumerate(row):
            if c in "S9FE": box(x, y, {"S": 4, "9": 5, "F": 6, "E": 7}[c], 1, 5)
    for x, y, *_ in s.get("landmarks", []): box(x, y, 8, 1, 5)
    b = io.BytesIO(); im.save(b, "PNG", optimize=True, bits=4); return "data:image/png;base64," + base64.b64encode(b.getvalue()).decode()

def build():
    src, info = G.load_sources(), {rid: (grp, endk) for grp, rid, _f, _t, _l, _s, endk in parse()}
    pos = json.load(open(os.path.join(HERE, "region_pos.json")))
    names = {c: n for n, c in G.region_codes().items()}
    regs = {}
    for x in G.layout():
        regs[x["code"]] = {"code": x["code"], "name": names[x["code"]], "wx": pos[x["code"]]["wx"], "wy": pos[x["code"]]["wy"], "town": x["town"],
                           "stops": [{k: s[k] for k in ("name", "x", "y", "kind", "type")} for s in x["stops"]], "exits": x["exits"], "routes": []}
    master = {c: [] for c in regs}
    for rid in sorted(info):
        grp, endk = info[rid]; r = src[rid]; bp = json.load(open(os.path.join(REPO, "claude", "bend-prototype", f"route-{rid}.json")))
        home, away = G.group_regions(grp)
        path, kind, code = G.region_path(rid, r["from"], r["to"], home, away)
        curve = [[round(p[0], 1), round(p[1], 1)] for p in path]
        off, secs, line = (0, 0), [], []
        for s in bp["sections"]:
            cells = [(off[0] + a, off[1] + b) for a, b in s["line"]]
            line += cells
            secs.append({"rows": s["rows"], "corners": corners([tuple(c) for c in s["line"]]), "entry": s["entry"], "exit": s["exit"], "heading": s["heading"],
                         "tokens": s["tokens"], "landmarks": s["landmarks"], "ox": off[0], "oy": off[1], "feature": s.get("feature", "")})
            dx, dy = SIDE[s["exit"]["side"]]; off = (off[0] + dx * W, off[1] + dy * H)
        base = {"id": rid, "from": r["from"], "to": r["to"], "land": r["land"], "boss": bp["boss"], "kind": kind, "curve": curve}
        regs[code]["routes"].append({**base, "feat": [s.get("feature", "") for s in r["sections"]], "old": [s["rows"] for s in r["sections"]], "new": secs})
        master[code].append({**base, "line": corners(line), "secs": [{"png": section_png(r["land"], bp["sections"][i]), "ox": secs[i]["ox"], "oy": secs[i]["oy"]} for i in range(len(secs))]})
    maps = {c: jpeg(os.path.join(SCN, f"map-{c}.png")) for c in regs}
    board = {"pal": PAL, "artland": ART_LAND, "tok": TOK, "regions": [{**R, "map": maps[c]} for c, R in regs.items()]}
    world = {"pal": PAL, "world": jpeg(os.path.join(SCN, "map-world.png"), 72, (1000, 563)), "frame": [480, 270],
             "regions": [{k: R[k] for k in ("code", "name", "wx", "wy", "town", "stops")} | {"map": maps[c], "routes": master[c]} for c, R in regs.items()]}
    for tpl, data, out in (("route_board.tpl.html", board, "route_board.html"), ("master.tpl.html", world, "master.html")):
        html = open(os.path.join(HERE, tpl), encoding="utf-8").read().replace("__DATA__", json.dumps(data, separators=(",", ":")))
        open(os.path.join(OUT, out), "w", encoding="utf-8").write(html); print(out, round(len(html) / 1e6, 2), "MB")

if __name__ == "__main__": build()
