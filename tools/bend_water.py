"""Ponds and lakes of a region, read from its picture game/assets/img/scenes/map-<CODE>.png (blue water pixels), for tools/gen_bendy_trail_proto.py --variety.
Streams are not read (they are thin and the pictures draw them inconsistently); Maplewold's streams are hand-derived in tools/maplewold_waterways.py.
region_ponds(code) -> [{x, y, r}] in the 480 x 270 region frame (r = about the pond's radius). Crystals and other small blue things are filtered by shape."""
import colorsys, functools, math, os, random, zlib
from PIL import Image
from region_waterways import HAND
HERE = os.path.dirname(os.path.abspath(__file__)); REPO = os.path.dirname(HERE)

def is_river_blue(r, g, b):
    """Looser than is_water: darker teal rivers too (hue 165..215, saturated, not too dark)."""
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    return 165 <= h * 360 <= 215 and s >= 0.4 and v >= 0.3

def is_water(r, g, b):
    """Water blue: hue 170..225, saturated and bright (snow, stone and shadow are grey-blue: low saturation or dark)."""
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    return 170 <= h * 360 <= 225 and s >= 0.45 and v >= 0.6

@functools.lru_cache(maxsize=None)
def _components(code, loose=False):
    """(bodies, thin) of a region picture: all water-blue components, each as dict(n, w, h, fill, cx, cy, pix)."""
    f = os.path.join(REPO, "game", "assets", "img", "scenes", f"map-{code}.png")
    if not os.path.isfile(f): return []
    im = Image.open(f).convert("RGB"); W, H = im.size
    pts = {(x, y) for y in range(H) for x in range(W) if (is_river_blue if loose else is_water)(*im.getpixel((x, y)))}
    if loose and len(pts) > 0.05 * W * H: return []     # a picture whose ground is water-coloured (the Coralscatter): no rivers can be told apart
    gap = 4 if loose else 2          # dotted rivers: join pixels up to 4 apart
    seen, out = set(), []
    for p in sorted(pts):
        if p in seen: continue
        st, c = [p], []; seen.add(p)
        while st:
            q = st.pop(); c.append(q)
            for dx in range(-gap, gap + 1):
                for dy in range(-gap, gap + 1):
                    n = (q[0] + dx, q[1] + dy)
                    if n in pts and n not in seen: seen.add(n); st.append(n)
        xs = [q[0] for q in c]; ys = [q[1] for q in c]; w, h = max(xs) - min(xs) + 1, max(ys) - min(ys) + 1
        out.append(dict(n=len(c), w=w, h=h, fill=len(c) / (w * h), cx=sum(xs) / len(c), cy=sum(ys) / len(c), pix=c))
    return out

def _is_pond(c):
    return c["n"] >= 25 and ((0.65 <= c["w"] / c["h"] <= 2.0 and 0.25 <= c["fill"] <= 0.8) or (c["n"] >= 150 and 0.3 <= c["w"] / c["h"] <= 3.5))

def _centre_line(pix, bins=7):
    """A drawn river as a polyline: pixels projected on their main axis (PCA), the median point of each bin along it, in order along the axis."""
    n = len(pix); mx = sum(p[0] for p in pix) / n; my = sum(p[1] for p in pix) / n
    sxx = sum((p[0] - mx) ** 2 for p in pix); syy = sum((p[1] - my) ** 2 for p in pix); sxy = sum((p[0] - mx) * (p[1] - my) for p in pix)
    ang = 0.5 * math.atan2(2 * sxy, sxx - syy); ax, ay = math.cos(ang), math.sin(ang)
    proj = sorted(((p[0] - mx) * ax + (p[1] - my) * ay, p) for p in pix); lo, hi = proj[0][0], proj[-1][0]
    out = []
    for b in range(bins):
        grp = [q for t, q in proj if lo + (hi - lo) * b / bins <= t <= lo + (hi - lo) * (b + 1) / bins]
        if grp: out.append([sorted(q[0] for q in grp)[len(grp) // 2], sorted(q[1] for q in grp)[len(grp) // 2]])
    return out

def region_rivers(code):
    """Drawn rivers and brooks (thin water components with a long reach): [polyline [[x, y], ...]] in picture order (flow direction decided by region_streams)."""
    return [_centre_line(c["pix"], 9) for c in _components(code, True) if c["n"] >= 40 and max(c["w"], c["h"]) >= 35 and c["fill"] < 0.3 and max(c["w"], c["h"]) >= 1.4 * min(c["w"], c["h"])]

def region_streams(code, frame=(480, 270)):
    """The region's water ways, upstream -> downstream: [{name, kind, wide, pts}] (Maplewold 'NA' = the hand-derived network of tools/maplewold_waterways.py).
    Drawn rivers keep their own line; their downstream end is the one nearer to a bigger water body or the map edge, and a derived connector runs on to it.
    Ponds get an outlet to the nearest bigger body within 120 units (none: a closed pond)."""
    if code in HAND:      # hand-drawn (tools/region_waterways.py)
        return [dict(name=f"{code}-{n}", kind="hand", wide=w, pts=[list(map(float, p)) for p in pts]) for n, w, pts in HAND[code]["streams"]]
    if code == "NA":
        import maplewold_waterways as MW
        return [dict(name=k, kind=v["kind"], wide=k in ("hub-river", "mid-outlet", "bridge-brook"), pts=v["pts"]) for k, v in MW.WATER.items() if "pts" in v]
    bodies = sorted(region_ponds(code), key=lambda b: -b["r"]); out = []
    def target(pt, exclude=None):
        cands = [((b["x"], b["y"]), b["r"], "body") for b in bodies if b is not exclude]
        cands += [((pt[0], 0), 0, "edge"), ((pt[0], frame[1]), 0, "edge"), ((0, pt[1]), 0, "edge"), ((frame[0], pt[1]), 0, "edge")]
        return min(cands, key=lambda c: math.dist(pt, c[0]) - c[1])
    for i, line in enumerate(region_rivers(code)):
        if len(line) < 2: continue
        a, b = line[0], line[-1]; ta, tb = target(a), target(b)
        if math.dist(a, ta[0]) - ta[1] < math.dist(b, tb[0]) - tb[1]: line, b, tb = line[::-1], a, ta
        pts = [list(map(float, p)) for p in line]
        if math.dist(b, tb[0]) - tb[1] > 6: pts.append([tb[0][0], tb[0][1]])
        out.append(dict(name=f"{code}-river-{i + 1}", kind="drawn", wide=False, pts=pts))
    for k, bd in enumerate(bodies):
        bigger = [o for o in bodies if o["r"] > bd["r"] and math.dist((o["x"], o["y"]), (bd["x"], bd["y"])) <= 120]
        if bigger and bd["r"] <= 12:
            o = min(bigger, key=lambda o: math.dist((o["x"], o["y"]), (bd["x"], bd["y"])))
            out.append(dict(name=f"{code}-outlet-{k + 1}", kind="derived", wide=False, pts=[[bd["x"], bd["y"]], [(bd["x"] + o["x"]) / 2 + 5, (bd["y"] + o["y"]) / 2 - 4], [o["x"], o["y"]]]))
    return out

@functools.lru_cache(maxsize=None)
def region_ponds(code):
    """Ponds and lakes of a region: [{x, y, r}] in the 480 x 270 frame (r = about the radius). Crystals, snow and stone are not water-blue; thin streams are not ponds."""
    out = [dict(x=round(c["cx"]), y=round(c["cy"]), r=max(2, round((c["w"] + c["h"]) / 4))) for c in _components(code) if _is_pond(c)]
    for x, y, r in HAND.get(code, {}).get("ponds", []):      # ponds the colour reader cannot see (oases, odd colours), unless one is read there already
        if not any(math.hypot(o["x"] - x, o["y"] - y) < 10 for o in out): out.append(dict(x=x, y=y, r=r))
    return out


# ---- streams through a section ----
W, H = 30, 18

def seg_cross(a, b, c, d):
    """Intersection of segments ab and cd: (t along ab, u along cd) or None."""
    r = (b[0] - a[0], b[1] - a[1]); s = (d[0] - c[0], d[1] - c[1]); den = r[0] * s[1] - r[1] * s[0]
    if abs(den) < 1e-9: return None
    t = ((c[0] - a[0]) * s[1] - (c[1] - a[1]) * s[0]) / den; u = ((c[0] - a[0]) * r[1] - (c[1] - a[1]) * r[0]) / den
    return (t, u) if 0 <= t <= 1 and 0 <= u <= 1 else None

def crossings(fine, n, streams, per=40):
    """Per section (n sections, `per` fine points each along the route curve `fine`): the streams the curve crosses: {name, t (0..1 along the section), dir (unit flow vector), wide}."""
    out = [[] for _ in range(n)]
    for i in range(len(fine) - 1):
        sec = min(n - 1, i // per); a, b = fine[i], fine[i + 1]
        for st in streams:
            for p, q in zip(st["pts"], st["pts"][1:]):
                x = seg_cross(a, b, p, q)
                if not x: continue
                dx, dy = q[0] - p[0], q[1] - p[1]; L = math.hypot(dx, dy); t = ((i % per) + x[0]) / per
                if any(c["name"] == st["name"] and abs(c["t"] - t) < 0.2 for c in out[sec]): continue
                out[sec].append(dict(name=st["name"], t=t, dir=[round(dx / L, 3), round(dy / L, 3)], wide=bool(st.get("wide"))))
    return out

def stream_ops(line, c, key, wide=None):
    """Ops and a note for a stream crossing a section: a meandering water line through the road tile (moved up to 8 along the road to where it meets the road most squarely),
    along the stream's own direction (region axes = grid axes), 1 tile wide (2 for a river), rough ford and one shallow away from the road. c = a crossing dict."""
    dx, dy = c["dir"]; i0 = round(min(0.85, max(0.15, c["t"])) * (len(line) - 1))
    def along(k):      # how much a stream through road tile k would run along the road (1 = parallel)
        a, b = line[max(0, k - 2)], line[min(len(line) - 1, k + 2)]; L = math.hypot(b[0] - a[0], b[1] - a[1]) or 1
        return abs((b[0] - a[0]) * dx + (b[1] - a[1]) * dy) / L
    idx = min((k for k in range(max(4, i0 - 8), min(len(line) - 4, i0 + 9))), key=lambda k: (round(along(k), 1), abs(k - i0)))
    px, py = line[idx]
    wide = c.get("wide", False) if wide is None else wide
    rg = random.Random(zlib.crc32(f"{key}|{c['name']}".encode())); ph = rg.uniform(0, 6.3)
    cells, pts, ops = [], [], []
    for k in range(-90, 91):
        s = k * 0.5; off = 1.3 * math.sin(s / 5.0 + ph)
        x = px + dx * s - dy * off; y = py + dy * s + dx * off; cx, cy = round(x), round(y)
        if not (1 <= cx <= W - 2 and 1 <= cy <= H - 2): continue
        if (cx, cy) not in cells: cells.append((cx, cy)); pts.append([cx, cy])
        if wide:
            q = (round(x - dy), round(y + dx))
            if q not in cells and 1 <= q[0] <= W - 2 and 1 <= q[1] <= H - 2: cells.append(q)
    ops.append(("r", px, py, 2))
    ops += [("w", x, y, 0) for x, y in cells]
    ops.append(("r", px, py, 1))
    for fi in (len(pts) // 4,):                       # shallows: a second, rough crossing so the banks are not cut off from each other
        if pts and abs(pts[fi][0] - px) + abs(pts[fi][1] - py) > 6: ops.append(("r", pts[fi][0], pts[fi][1], 0))
    fl = ("E" if dx > 0.5 else "W" if dx < -0.5 else "") if abs(dx) > abs(dy) * 0.5 else ""
    fl = ("S" if dy > 0.5 else "N" if dy < -0.5 else "") + fl
    return ops, dict(name=c["name"], flow=fl, pts=pts, cross=[px, py], wide=wide), (px, py, dx, dy)

if __name__ == "__main__":
    import json, sys
    if "--write" in sys.argv:
        codes = ["NA", "CA", "CB", "SA", "NWE", "SE", "EE", "MENA", "WCA", "ESA", "CSA", "EA", "SEA", "OC"]
        out = os.path.join(REPO, "claude", "bend-prototype-v2", "waterways.json")
        json.dump({c: {"ponds": region_ponds(c), "streams": region_streams(c)} for c in codes}, open(out, "w"), indent=1); print("wrote", out); sys.exit(0)
    for code in sys.argv[1:] or ["NA", "CA", "CB", "SA", "NWE", "SE", "EE", "MENA", "WCA", "ESA", "CSA", "EA", "SEA", "OC"]: print(code, region_ponds(code))
