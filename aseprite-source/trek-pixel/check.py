#!/usr/bin/env python
"""Trek pixel asset checker.

Run:  C:\\Users\\hello\\AppData\\Local\\Python\\pythoncore-3.15-64\\python.exe check.py [--root DIR] [--only NAME ...] [--quiet]

Reads  <root>\\png\\<name>.png  (46 assets), checks them against the specs, then writes
  <root>\\sheets\\trek-mosaic.png        a fake 15x11 map built from the assets
  <root>\\sheets\\trek-<sheet>-combos.png  the 47 composed tiles of each auto-join sheet
  <root>\\sheets\\index.html             contact sheet (image-rendering: pixelated), 42 / 35 / 21 px + 3x3 patches + report
Exit code 1 when any FAIL is reported (WARN and MISSING do not fail the run).
Only Pillow is needed.
"""
import os
import re
import sys
import html
import itertools
from collections import Counter

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))

# ----------------------------------------------------------------------------- asset table
FAMILIES = [
    (1, "Open ground", ["floor-o-1", "floor-o-2", "floor-o-3", "mud-o-1", "mud-o-2", "roots-o-1", "roots-o-2",
                        "blight-o-1", "blight-o-2", "crystal-o"]),
    (2, "Underground ground", ["floor-u-1", "floor-u-2", "floor-u-3", "mud-u", "roots-u", "blight-u", "crystal-u"]),
    (3, "Water and clay", ["chasm-1", "chasm-2", "drained", "clay-wet", "clay-loose", "ripple-pool", "ripple-high"]),
    (4, "Auto-join sheets and wall extras", ["wall-o-auto", "wall-u-auto", "water-auto", "wall-o-deep", "wall-u-deep",
                                             "wallcap-n", "wallcap-s", "wallcap-e", "wallcap-w"]),
    (5, "Bridge and rails", ["bridge-h", "bridge-v", "rail-n", "rail-s", "rail-e", "rail-w"]),
    (6, "Markers", ["token-gold", "token-ember", "me", "foot-h", "foot-v", "bang", "flag"]),
]
SIZES = {"wall-o-auto": (84, 126), "wall-u-auto": (84, 126), "water-auto": (84, 126),
         "wallcap-n": (42, 5), "wallcap-s": (42, 5), "wallcap-e": (5, 42), "wallcap-w": (5, 42),
         "rail-n": (42, 4), "rail-s": (42, 4), "rail-e": (4, 42), "rail-w": (4, 42),
         "token-gold": (34, 34), "token-ember": (34, 34), "me": (38, 40), "foot-h": (12, 12), "foot-v": (12, 12),
         "bang": (24, 24), "flag": (20, 20)}
KIND = {}
for _no, _nm, _names in FAMILIES:
    for n in _names:
        if n.endswith("-auto"):
            KIND[n] = "sheet"
        elif n in ("wall-o-deep", "wall-u-deep"):
            KIND[n] = "deep"
        elif n in ("ripple-pool", "ripple-high"):
            KIND[n] = "ripple"
        elif n.startswith(("wallcap", "bridge", "rail")):
            KIND[n] = "overlay"
        elif _no == 6:
            KIND[n] = "marker"
        else:
            KIND[n] = "ground"
for n in ("bridge-h", "bridge-v"):
    KIND[n] = "overlay"
ALL = [n for _no, _nm, names in FAMILIES for n in names]
assert len(ALL) == 46

RING = {  # expected ring colour (palette.md section 4)
    "floor-o": "#9a6b3f", "crystal-o": "#9a6b3f", "mud-o": "#7a4a1f", "mud-u": "#7a4a1f", "drained": "#7a4a1f",
    "clay-loose": "#7a4a1f", "roots-o": "#7d8a62", "blight-o": "#4e3a8a", "floor-u": "#8a5a30",
    "crystal-u": "#8a5a30", "roots-u": "#4a4632", "blight-u": "#3e2f66", "chasm": "#143645", "clay-wet": "#944c1f"}
APRON = {"wall-o-auto": "#9a6b3f", "wall-u-auto": "#8a5a30", "water-auto": "#7a4a1f"}
GROUPS = {"floor-o": ["floor-o-1", "floor-o-2", "floor-o-3"], "mud-o": ["mud-o-1", "mud-o-2"],
          "roots-o": ["roots-o-1", "roots-o-2"], "blight-o": ["blight-o-1", "blight-o-2"],
          "floor-u": ["floor-u-1", "floor-u-2", "floor-u-3"], "chasm": ["chasm-1", "chasm-2"]}


def ring_expect(name):
    base = re.sub(r"-\d+$", "", name)
    return RING.get(base)


def hex2rgb(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))


def rgb2hex(c):
    return "#%02x%02x%02x" % tuple(c[:3])


# ----------------------------------------------------------------------------- helpers
def getpx(im):
    """Pixel list, avoiding the deprecated getdata() on new Pillow."""
    return im.get_flattened_data() if hasattr(im, "get_flattened_data") else im.getdata()


class Img:
    """RGBA image with fast tuple access."""

    def __init__(self, im):
        self.im = im.convert("RGBA")
        self.w, self.h = self.im.size
        self.px = list(getpx(self.im))

    def at(self, x, y):
        return self.px[y * self.w + x]

    def col(self, x):
        return [self.px[y * self.w + x] for y in range(self.h)]

    def row(self, y):
        return self.px[y * self.w:(y + 1) * self.w]


def eq_ratio(a, b):
    n = len(a)
    return sum(1 for i in range(n) if a[i] == b[i]) / n if n else 1.0


def luma(c):
    return 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]


def opaque(c):
    return c[3] == 255


def patch(tiles, cols, rows):
    """tiles: list of Img in row-major order -> Image."""
    w, h = tiles[0].w, tiles[0].h
    out = Image.new("RGBA", (w * cols, h * rows), (0, 0, 0, 0))
    for i, t in enumerate(tiles):
        out.paste(t.im, ((i % cols) * w, (i // cols) * h))
    return out


def seam_ratios(a, b_right, c_below=None):
    """Pixel-pair equality across a|b (a's right col vs b's left col) and a over c (a's bottom row vs c's top row)."""
    h = eq_ratio(a.col(a.w - 1), b_right.col(0))
    v = eq_ratio(a.row(a.h - 1), (c_below or b_right).row(0))
    return h, v


class Report:
    def __init__(self):
        self.items = {n: [] for n in ALL}   # name -> [(level, text)]

    def add(self, name, level, text):
        self.items[name].append((level, text))

    def status(self, name):
        lv = [l for l, _ in self.items[name]]
        if "MISSING" in lv:
            return "MISSING"
        if "FAIL" in lv:
            return "FAIL"
        if "WARN" in lv:
            return "WARN"
        return "OK"


# ----------------------------------------------------------------------------- auto-join composition
def combos47():
    seen = {}
    for N, E, S, W, ne, se, sw, nw in itertools.product([0, 1], repeat=8):
        key = (N, E, S, W, ne and N and E, se and S and E, sw and S and W, nw and N and W)
        key = tuple(int(bool(v)) for v in key)
        seen[key] = 1
    out = sorted(seen)
    assert len(out) == 47, len(out)
    return out


ISO = {"TL": (0, 0), "TR": (1, 0), "BL": (0, 1), "BR": (1, 1)}
INNER = {"TL": (2, 0), "TR": (3, 0), "BL": (2, 1), "BR": (3, 1)}
INTERIOR = {"TL": (1, 3), "TR": (2, 3), "BL": (1, 4), "BR": (2, 4)}
CORNER = {"TL": (0, 2), "TR": (3, 2), "BL": (0, 5), "BR": (3, 5)}
SIDEEDGE = {"TL": (0, 3), "TR": (3, 3), "BL": (0, 4), "BR": (3, 4)}      # horizontal side empty (left or right edge)
VERTEDGE = {"TL": (1, 2), "TR": (2, 2), "BL": (1, 5), "BR": (2, 5)}      # vertical side empty (top or bottom edge)
QUADS = {"TL": ("N", "W", "NW", 0, 0), "TR": ("N", "E", "NE", 21, 0), "BL": ("S", "W", "SW", 0, 21), "BR": ("S", "E", "SE", 21, 21)}


def quarter(sheet, qx, qy):
    return sheet.im.crop((qx * 21, qy * 21, qx * 21 + 21, qy * 21 + 21))


def compose(sheet, key):
    N, E, S, W, ne, se, sw, nw = key
    m = dict(N=N, E=E, S=S, W=W, NE=ne, SE=se, SW=sw, NW=nw)
    out = Image.new("RGBA", (42, 42), (0, 0, 0, 0))
    allempty = not (N or E or S or W)
    for q, (a, b, d, ox, oy) in QUADS.items():
        va, vb, vd = m[a], m[b], m[d]
        if va and vb:
            qq = INTERIOR[q] if vd else INNER[q]
        elif va and not vb:
            qq = SIDEEDGE[q]
        elif vb and not va:
            qq = VERTEDGE[q]
        else:
            qq = ISO[q] if allempty else CORNER[q]
        out.paste(quarter(sheet, *qq), (ox, oy))
    return out


def combo_name(key):
    N, E, S, W, ne, se, sw, nw = key
    s = "".join(c for c, v in zip("NESW", (N, E, S, W)) if v) or "-"
    d = "".join(c for c, v in zip(("ne", "se", "sw", "nw"), (ne, se, sw, nw)) if v)
    return s + ("+" + d if d else "")


# ----------------------------------------------------------------------------- the checks
def check_common(R, name, im, palette):
    exp = SIZES.get(name, (42, 42))
    if (im.w, im.h) != exp:
        R.add(name, "FAIL", f"size {im.w}x{im.h}, expected {exp[0]}x{exp[1]}")
    semi = sum(1 for c in im.px if 0 < c[3] < 255)
    if semi:
        R.add(name, "FAIL", f"{semi} semi-transparent pixels")
    bw = sum(1 for c in im.px if opaque(c) and c[:3] in ((0, 0, 0), (255, 255, 255)))
    if bw:
        R.add(name, "FAIL", f"{bw} pure black/white pixels")
    cols = Counter(c[:3] for c in im.px if opaque(c))
    if len(cols) > 16 and KIND[name] not in ("sheet",):
        R.add(name, "WARN", f"{len(cols)} colours (more than 16)")
    if palette:
        off = Counter({c: n for c, n in cols.items() if rgb2hex(c) not in palette})
        if off:
            tot = sum(off.values())
            top = ", ".join(f"{rgb2hex(c)}x{n}" for c, n in off.most_common(3))
            R.add(name, "WARN", f"{tot} px not in palette.md ({top})")
    return cols


def ring_pixels(im, t=3):
    for y in range(im.h):
        for x in range(im.w):
            if x < t or y < t or x >= im.w - t or y >= im.h - t:
                yield im.at(x, y)


def check_ground(R, name, im, cols):
    if any(not opaque(c) for c in im.px):
        edge_tr = sum(1 for c in ring_pixels(im, 1) if not opaque(c))
        R.add(name, "FAIL", f"transparent pixels in ground tile ({edge_tr} on the edge)")
        return
    ring = list(ring_pixels(im))
    mode, cnt = Counter(c[:3] for c in ring).most_common(1)[0]
    share = cnt / len(ring)
    ex = ring_expect(name)
    if ex and rgb2hex(mode) != ex:
        R.add(name, "FAIL", f"ring colour {rgb2hex(mode)} != expected {ex}")
    if share < 0.85:
        R.add(name, "FAIL", f"outer 3px ring only {share:.0%} base colour (need >= 85%)")
    elif share < 0.97:
        R.add(name, "WARN", f"outer 3px ring {share:.0%} base colour (designed crossings?)")
    if len(cols) < 4 and name not in ("chasm-1", "chasm-2"):
        R.add(name, "WARN", f"only {len(cols)} colours: tile looks flat")
    t = patch([im] * 9, 3, 3)
    p = Img(t)
    hs = [eq_ratio([p.at(41 + 42 * k, y) for y in range(42 * j, 42 * j + 42)],
                   [p.at(42 + 42 * k, y) for y in range(42 * j, 42 * j + 42)]) for k in (0, 1) for j in range(3)]
    vs = [eq_ratio([p.at(x, 41 + 42 * k) for x in range(42 * j, 42 * j + 42)],
                   [p.at(x, 42 + 42 * k) for x in range(42 * j, 42 * j + 42)]) for k in (0, 1) for j in range(3)]
    worst = min(hs + vs)
    if worst < 0.80:
        R.add(name, "FAIL", f"3x3 patch seam match {worst:.0%} (need >= 80%)")
    elif worst < 0.92:
        R.add(name, "WARN", f"3x3 patch seam match {worst:.0%}")


def check_variants(R, imgs):
    for g, names in GROUPS.items():
        have = [n for n in names if n in imgs and KIND[n] == "ground" and imgs[n].w == 42 and imgs[n].h == 42]
        for a, b in itertools.permutations(have, 2):
            A, B = imgs[a], imgs[b]
            h = eq_ratio(A.col(41), B.col(0))
            v = eq_ratio(A.row(41), B.row(0))
            if min(h, v) < 0.80:
                R.add(a, "FAIL", f"variant swap seam with {b}: {min(h, v):.0%} (need >= 80%)")
            elif min(h, v) < 0.92:
                R.add(a, "WARN", f"variant swap seam with {b}: {min(h, v):.0%}")


def margin_ok(im, m):
    for y in range(im.h):
        for x in range(im.w):
            if (x < m or y < m or x >= im.w - m or y >= im.h - m) and im.at(x, y)[3]:
                return False
    return True


def check_overlay(R, name, im, imgs):
    n_op = sum(1 for c in im.px if c[3])
    if not n_op:
        R.add(name, "FAIL", "empty image")
        return
    frac = n_op / len(im.px)
    if name in ("bridge-h",):
        if any(im.at(x, y)[3] for x in (0, 41) for y in range(42)):
            R.add(name, "FAIL", "columns x=0 and x=41 must be transparent (2 px plank gap across the tile line)")
        if frac > 0.95:
            R.add(name, "WARN", "no transparent gaps between planks")
    if name in ("bridge-v",):
        if any(im.at(x, y)[3] for y in (0, 41) for x in range(42)):
            R.add(name, "FAIL", "rows y=0 and y=41 must be transparent (2 px plank gap across the tile line)")
        if frac > 0.95:
            R.add(name, "WARN", "no transparent gaps between planks")
    if name.startswith("rail"):
        if frac < 0.99:
            R.add(name, "FAIL", f"rail beam must be fully opaque ({frac:.0%} opaque)")
    if name.startswith("wallcap"):
        xs = [x for y in range(im.h) for x in range(im.w) if im.at(x, y)[3]]
        ys = [y for y in range(im.h) for x in range(im.w) if im.at(x, y)[3]]
        if name in ("wallcap-n", "wallcap-s"):
            if (min(xs), max(xs)) != (6, 35):
                R.add(name, "FAIL", f"cap spans x{min(xs)}..{max(xs)}, expected x6..35")
        else:
            if (min(ys), max(ys)) != (6, 35):
                R.add(name, "FAIL", f"cap spans y{min(ys)}..{max(ys)}, expected y6..35")
        if frac > 0.85:
            R.add(name, "WARN", "cap fills almost the whole strip")


def check_caps(R, imgs):
    pairs = [("wallcap-n", 0, "wallcap-s", 4, "row"), ("wallcap-e", 4, "wallcap-w", 0, "col")]
    thread = {hex2rgb("#f5cf6a"), hex2rgb("#e8a317")}
    for a, ia, b, ib, kind in pairs:
        if a in imgs and b in imgs:
            A, B = imgs[a], imgs[b]
            la = A.row(ia) if kind == "row" else A.col(ia)
            lb = B.row(ib) if kind == "row" else B.col(ib)
            oa = [i for i, c in enumerate(la) if c[3]]
            ob = [i for i, c in enumerate(lb) if c[3]]
            if oa != ob:
                R.add(a, "FAIL", f"seam line span differs from {b}")
            ta = [i for i, c in enumerate(la) if c[3] and c[:3] in thread]
            tb = [i for i, c in enumerate(lb) if c[3] and c[:3] in thread]
            if ta != tb:
                R.add(a, "FAIL", f"stitch positions differ from {b} ({len(ta)} vs {len(tb)} thread pixels)")
            if not ta:
                R.add(a, "WARN", "no thread stitch on the seam line")


def check_sheet(R, name, sheet, imgs, sheetsdir):
    if any(not opaque(c) for c in sheet.px):
        R.add(name, "FAIL", "transparent pixels in auto-join sheet")
        return
    for (iq, cq) in [((0, 0), (0, 2)), ((1, 0), (3, 2)), ((0, 1), (0, 5)), ((1, 1), (3, 5))]:
        if list(getpx(quarter(sheet, *iq))) != list(getpx(quarter(sheet, *cq))):
            R.add(name, "FAIL", f"iso quarter {iq} is not a pixel copy of corner quarter {cq}")
    ground = hex2rgb(APRON[name])
    ref = {"wall-o-auto": "floor-o-1", "wall-u-auto": "floor-u-1", "water-auto": "mud-o-1"}[name]
    if ref in imgs and imgs[ref].w == 42:
        ring = Counter(c[:3] for c in ring_pixels(imgs[ref])).most_common(1)[0][0]
        if ring != ground:
            R.add(name, "WARN", f"apron {rgb2hex(ground)} differs from the drawn {ref} ring {rgb2hex(ring)}; using the drawn ring")
            ground = ring
    combos = combos47()
    worst_apron = (1.0, "")
    worst_line = (9.0, "")
    worst_self = (1.0, "")
    out = Image.new("RGBA", (42 * 12 + 13, 42 * 4 + 5), (60, 60, 60, 255))
    tiles = {}
    for i, key in enumerate(combos):
        t = compose(sheet, key)
        tiles[key] = Img(t)
        out.paste(t, (1 + (i % 12) * 43, 1 + (i // 12) * 43))
    for key, T in tiles.items():
        N, E, S, W, ne, se, sw, nw = key
        cn = combo_name(key)
        # apron on empty sides + inner corner notches
        regions = []
        if not N: regions.append([(x, y) for y in range(3) for x in range(42)])
        if not S: regions.append([(x, y) for y in range(39, 42) for x in range(42)])
        if not W: regions.append([(x, y) for x in range(3) for y in range(42)])
        if not E: regions.append([(x, y) for x in range(39, 42) for y in range(42)])
        notch = {"NE": (N and E and not ne, 39, 0), "SE": (S and E and not se, 39, 39),
                 "SW": (S and W and not sw, 0, 39), "NW": (N and W and not nw, 0, 0)}
        for k, (on, ox, oy) in notch.items():
            if on:
                regions.append([(ox + x, oy + y) for y in range(3) for x in range(3)])
        for reg in regions:
            r = sum(1 for x, y in reg if T.at(x, y)[:3] == ground and T.at(x, y)[3] == 255) / len(reg)
            if r < worst_apron[0]:
                worst_apron = (r, cn)
        # quarter-line continuity: adjacent-equal ratio on the line vs. the tile baseline
        def base_v():
            xs = [x for x in range(3, 38) if x not in (19, 20, 21)]
            return sum(eq_ratio(T.col(x), T.col(x + 1)) for x in xs) / len(xs)

        def base_h():
            ys = [y for y in range(3, 38) if y not in (19, 20, 21)]
            return sum(eq_ratio(T.row(y), T.row(y + 1)) for y in ys) / len(ys)
        dv = base_v() - eq_ratio(T.col(20), T.col(21))
        dh = base_h() - eq_ratio(T.row(20), T.row(21))
        d = max(dv, dh)
        if d > worst_line[0] or worst_line[0] == 9.0:
            worst_line = (d, cn)
        if E and W and (nw, sw) == (ne, se):
            r = eq_ratio(T.col(41), T.col(0))
            if r < worst_self[0]:
                worst_self = (r, cn + " (E-W)")
        if N and S and (nw, ne) == (sw, se):
            r = eq_ratio(T.row(41), T.row(0))
            if r < worst_self[0]:
                worst_self = (r, cn + " (N-S)")
    out.save(os.path.join(sheetsdir, "trek-%s-combos.png" % name.replace("-auto", "")))
    if worst_apron[0] < 0.90:
        R.add(name, "FAIL", f"apron does not match ground {rgb2hex(ground)} on an empty side: {worst_apron[0]:.0%} in combo {worst_apron[1]}")
    elif worst_apron[0] < 1.0:
        R.add(name, "WARN", f"apron {worst_apron[0]:.0%} in combo {worst_apron[1]}")
    if worst_line[0] > 0.30:
        R.add(name, "FAIL", f"quarter line stands out by {worst_line[0]:.0%} in combo {worst_line[1]}")
    elif worst_line[0] > 0.20:
        R.add(name, "WARN", f"quarter line stands out by {worst_line[0]:.0%} in combo {worst_line[1]}")
    if worst_self[0] < 0.75:
        R.add(name, "FAIL", f"run tile does not self-tile: {worst_self[0]:.0%} in combo {worst_self[1]}")
    elif worst_self[0] < 0.90:
        R.add(name, "WARN", f"run tile self-tile {worst_self[0]:.0%} in combo {worst_self[1]}")
    return tiles


def check_deep(R, name, im, imgs, tiles_by_sheet):
    if any(not opaque(c) for c in im.px):
        R.add(name, "FAIL", "transparent pixels in deep wall tile")
        return
    h = eq_ratio(im.col(41), im.col(0))
    v = eq_ratio(im.row(41), im.row(0))
    if min(h, v) < 0.75:
        R.add(name, "FAIL", f"deep tile self-seam {min(h, v):.0%} (need >= 75%)")
    sheet = "wall-o-auto" if "-o-" in name else "wall-u-auto"
    full = (1, 1, 1, 1, 1, 1, 1, 1)
    T = tiles_by_sheet.get(sheet, {}).get(full)
    if T:
        h2 = eq_ratio(im.col(41), T.col(0))
        v2 = eq_ratio(im.row(41), T.row(0))
        if min(h2, v2) < 0.5:
            R.add(name, "WARN", f"seam against {sheet} interior {min(h2, v2):.0%}")
        la = sum(luma(c) for c in im.px) / len(im.px)
        lb = sum(luma(c) for c in T.px) / len(T.px)
        if la >= lb - 2:
            R.add(name, "WARN", f"deep tile (luma {la:.0f}) is not darker than the {sheet} interior ({lb:.0f})")


def check_marker(R, name, im):
    n_op = sum(1 for c in im.px if c[3])
    if not n_op:
        R.add(name, "FAIL", "empty image")
        return
    if name.startswith("token"):
        centre = [im.at(x, y)[:3] for y in range(9, 25) for x in range(9, 25)
                  if not ((x in (9, 24) and y in (9, 24)))]
        mode, cnt = Counter(centre).most_common(1)[0]
        if cnt / len(centre) < 0.90:
            R.add(name, "FAIL", f"central 16x16 must be flat cream (only {cnt / len(centre):.0%} one colour)")
        if im.at(0, 0)[3] or im.at(33, 0)[3] or im.at(0, 33)[3] or im.at(33, 33)[3]:
            R.add(name, "WARN", "token corner pixel is opaque")
    if name == "me":
        shadow = hex2rgb("#4a2c1a")
        bottom = [im.at(x, y) for y in (38, 39) for x in range(38) if im.at(x, y)[3]]
        if not bottom:
            R.add(name, "WARN", "no ground shadow in rows 38..39")
        elif sum(1 for c in bottom if c[:3] == shadow) / len(bottom) < 0.95:
            R.add(name, "WARN", "ground shadow rows are not flat umber2 (#4a2c1a)")


# ----------------------------------------------------------------------------- mosaic
MAP = ["###############",
       "###...m#...kl.#",
       "###c..r#.....b#",
       "#..ww..#..^=^.#",
       "#..wW..#.C^=^l#",
       "#.^^^.m#..^=^.#",
       "#.===..#.d.k.l#",
       "#.^^^.b#..b!>e#",
       "#.g..bb#...####",
       "#.ff.@.#.F.####",
       "###############"]
assert len(MAP) == 11 and all(len(r) == 15 for r in MAP), [len(r) for r in MAP]


def build_mosaic(imgs, tiles_by_sheet):
    def get(n):
        return imgs.get(n)

    def placeholder(w, h, label=""):
        im = Image.new("RGBA", (w, h), (176, 74, 200, 255))
        for y in range(h):
            for x in range(w):
                if (x + y) % 6 < 2:
                    im.putpixel((x, y), (120, 40, 150, 255))
        return im

    def tile(n, w=42, h=42):
        i = get(n)
        return i.im if i and (i.w, i.h) == (w, h) else placeholder(w, h)

    def style(x):
        return "o" if x <= 7 else "u"

    def hsh(x, y, k=0):
        return ((x * 73856093) ^ (y * 19349663) ^ (k * 83492791)) & 0xffff

    def ch(x, y):
        if 0 <= x < 15 and 0 <= y < 11:
            return MAP[y][x]
        return "#"                      # outside the map counts as wall

    def mass_of(x, y, kinds):
        return int(ch(x, y) in kinds)

    out = Image.new("RGBA", (15 * 42, 11 * 42), (0, 0, 0, 255))

    def key_for(x, y, kinds):
        m = lambda dx, dy: mass_of(x + dx, y + dy, kinds)
        N, E, S, W = m(0, -1), m(1, 0), m(0, 1), m(-1, 0)
        return (N, E, S, W, int(m(1, -1) and N and E), int(m(1, 1) and S and E), int(m(-1, 1) and S and W), int(m(-1, -1) and N and W))

    def auto(sheet, x, y, kinds):
        s = get(sheet)
        if not s or (s.w, s.h) != (84, 126):
            return placeholder(42, 42)
        return compose(s, key_for(x, y, kinds))

    def ground(c, x, y):
        s = style(x)
        v = hsh(x, y)
        if c == "." or c in "g e @ f F ! >".split():
            return tile("floor-%s-%d" % (s, 1 + v % 3))
        if c == "m":
            return tile("mud-o-%d" % (1 + v % 2)) if s == "o" else tile("mud-u")
        if c == "r":
            return tile("roots-%s" % ("o-%d" % (1 + v % 2) if s == "o" else "u"))
        if c == "b":
            return tile("blight-%s" % ("o-%d" % (1 + v % 2) if s == "o" else "u"))
        if c in "cC":
            return tile("crystal-%s" % s)
        if c == "^" or c == "=":
            return tile("chasm-%d" % (1 + v % 2))
        if c == "d":
            return tile("drained")
        if c == "k":
            return tile("clay-wet")
        if c == "l":
            return tile("clay-loose")
        return placeholder(42, 42)

    for y in range(11):
        for x in range(15):
            c = MAP[y][x]
            px_, py_ = x * 42, y * 42
            if c == "#":
                s = style(x)
                allwall = all(ch(x + dx, y + dy) == "#" and (style(x + dx) == s or not (0 <= x + dx < 15))
                              for dx in (-1, 0, 1) for dy in (-1, 0, 1))
                t = tile("wall-%s-deep" % s) if allwall else auto("wall-%s-auto" % s, x, y, "#")
                t = t.copy()
                for dx, dy, cap, pos in ((0, -1, "wallcap-n", (0, 0)), (0, 1, "wallcap-s", (0, 37)),
                                         (-1, 0, "wallcap-w", (0, 0)), (1, 0, "wallcap-e", (37, 0))):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < 15 and 0 <= ny < 11 and ch(nx, ny) == "#" and style(nx) != s:
                        cp = get(cap)
                        if cp:
                            t.alpha_composite(cp.im, pos)
                out.paste(t, (px_, py_))
            elif c in "wW":
                t = auto("water-auto", x, y, "wW").copy()
                rp = get("ripple-high" if c == "W" else "ripple-pool")
                if rp:
                    t.alpha_composite(rp.im, (0, 0))
                out.paste(t, (px_, py_))
            elif c == "=":
                t = ground("^", x, y).copy()
                vert = ch(x - 1, y) == "^" or ch(x + 1, y) == "^"
                br = get("bridge-v" if vert else "bridge-h")
                if br:
                    t.alpha_composite(br.im, (0, 0))
                for dx, dy, rn, pos in ((0, -1, "rail-n", (0, 0)), (0, 1, "rail-s", (0, 38)),
                                        (-1, 0, "rail-w", (0, 0)), (1, 0, "rail-e", (38, 0))):
                    if ch(x + dx, y + dy) == "^":
                        r = get(rn)
                        if r:
                            t.alpha_composite(r.im, pos)
                out.paste(t, (px_, py_))
            else:
                t = ground(c, x, y).copy()
                mk = {"g": ("token-gold", 4, 4), "e": ("token-ember", 4, 4), "@": ("me", 2, 0),
                      "f": ("foot-h", 15, 15), "F": ("foot-v", 15, 15), "!": ("bang", 17, 1), ">": ("flag", 11, 11)}.get(c)
                if mk:
                    m = get(mk[0])
                    if m:
                        t.alpha_composite(m.im, (mk[1], mk[2]))
                out.paste(t, (px_, py_))
    return out


# ----------------------------------------------------------------------------- html
CSS = """
:root{--bg:#f4f0e0;--fg:#2b2b2b;--card:#fffaf0;--line:#c9b48a}
@media (prefers-color-scheme:dark){:root{--bg:#1d1812;--fg:#f1ead8;--card:#2a2118;--line:#5a4630}}
body{margin:0;padding:16px;background:var(--bg);color:var(--fg);font:14px/1.4 system-ui,sans-serif}
h1{font-size:20px}h2{font-size:16px;margin:28px 0 8px;border-bottom:1px solid var(--line)}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:12px}
.card{background:var(--card);border:1px solid var(--line);border-radius:8px;padding:10px}
.card h3{margin:0 0 6px;font-size:13px;word-break:break-all}
img,.px{image-rendering:pixelated}
.tr{background-image:linear-gradient(45deg,#8886 25%,transparent 25%,transparent 75%,#8886 75%),linear-gradient(45deg,#8886 25%,transparent 25%,transparent 75%,#8886 75%);background-size:8px 8px;background-position:0 0,4px 4px}
.row{display:flex;gap:10px;align-items:flex-end;flex-wrap:wrap;margin-bottom:6px}
.row figure{margin:0;font-size:11px;text-align:center}
.patch{display:grid;grid-template-columns:repeat(3,42px)}
.patch img{width:42px;height:42px;display:block}
.b{display:inline-block;padding:1px 7px;border-radius:9px;font-size:11px;color:#fff}
.OK{background:#2f7a35}.WARN{background:#b07a10}.FAIL{background:#a8241f}.MISSING{background:#777}
ul{margin:4px 0 0;padding-left:16px;font-size:12px}li.FAIL{color:#d6322b}li.WARN{color:#b07a10}li.MISSING{color:#888}
.big{max-width:100%;overflow:auto}
"""


def write_html(path, R, imgs, summary):
    o = ['<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Trek tiles contact sheet</title><style>' + CSS + '</style></head><body>']
    o.append("<h1>Trek pixel tiles</h1><p>%s</p>" % html.escape(summary))
    o.append('<h2>Fake map (15 x 11 tiles)</h2><div class="big"><img src="trek-mosaic.png" width="1260" alt="mosaic" style="image-rendering:pixelated"> </div>')
    for no, nm, names in FAMILIES:
        o.append("<h2>Family %d: %s</h2><div class=\"grid\">" % (no, html.escape(nm)))
        for n in names:
            im = imgs.get(n)
            st = R.status(n)
            o.append('<div class="card"><h3>trek-%s <span class="b %s">%s</span></h3>' % (n, st, st))
            src = "../png/trek-%s.png" % n
            if im:
                w, h = im.w, im.h
                kind = KIND[n]
                if kind == "sheet":
                    o.append('<div class="row"><figure><img class="px tr" src="%s" width="%d" height="%d"><br>2x</figure></div>' % (src, w * 2, h * 2))
                    o.append('<div class="row"><figure><img class="px" src="trek-%s-combos.png" width="%d"><br>47 composed tiles (1x)</figure></div>' % (n.replace("-auto", ""), 12 * 43 + 13))
                else:
                    sizes = [(w, h, "1x"), (round(w * 35 / 42), round(h * 35 / 42), "35"), (round(w * 21 / 42), round(h * 21 / 42), "21"), (w * 4, h * 4, "4x")]
                    o.append('<div class="row">')
                    for sw, sh, lb in sizes:
                        o.append('<figure><img class="px tr" src="%s" width="%d" height="%d"><br>%s</figure>' % (src, max(1, sw), max(1, sh), lb))
                    o.append("</div>")
                    if kind == "ground":
                        o.append('<div class="row"><figure><div class="patch">%s</div>3x3 tiled</figure></div>' % (("<img class='px' src='%s'>" % src) * 9))
            o.append("<ul>")
            for lv, tx in R.items[n]:
                o.append('<li class="%s">%s</li>' % (lv, html.escape(tx)))
            o.append("</ul></div>")
        o.append("</div>")
    o.append("</body></html>")
    with open(path, "w", encoding="utf8", newline="\n") as fh:
        fh.write("\n".join(o))


# ----------------------------------------------------------------------------- main
def main(argv):
    root = HERE
    only = None
    quiet = False
    i = 1
    while i < len(argv):
        if argv[i] == "--root":
            root = os.path.abspath(argv[i + 1]); i += 2
        elif argv[i] == "--only":
            only = set(); i += 1
            while i < len(argv) and not argv[i].startswith("--"):
                only.add(argv[i].replace("trek-", "", 1) if argv[i].startswith("trek-") else argv[i]); i += 1
        elif argv[i] == "--quiet":
            quiet = True; i += 1
        else:
            print("unknown argument", argv[i]); return 2
    pngdir = os.path.join(root, "png")
    sheetsdir = os.path.join(root, "sheets")
    os.makedirs(sheetsdir, exist_ok=True)
    palette = set()
    pp = os.path.join(HERE, "palette.md")
    if os.path.exists(pp):
        palette = {h.lower() for h in re.findall(r"`(#[0-9a-fA-F]{6})`", open(pp, encoding="utf8").read())}
    R = Report()
    imgs = {}
    for n in ALL:
        f = os.path.join(pngdir, "trek-%s.png" % n)
        if not os.path.exists(f):
            R.add(n, "MISSING", "png\\trek-%s.png not found" % n)
            continue
        try:
            imgs[n] = Img(Image.open(f))
        except Exception as e:  # noqa
            R.add(n, "FAIL", "cannot read: %s" % e)
    tiles_by_sheet = {}
    for n, im in imgs.items():
        if only and n not in only:
            continue
        cols = check_common(R, n, im, palette)
        k = KIND[n]
        if (im.w, im.h) != SIZES.get(n, (42, 42)):
            continue
        if k == "ground":
            check_ground(R, n, im, cols)
        elif k in ("overlay", "ripple"):
            if k == "ripple":
                if not margin_ok(im, 3):
                    R.add(n, "FAIL", "opaque pixels within 3 px of the edge")
                if not any(c[3] for c in im.px):
                    R.add(n, "FAIL", "empty image")
            else:
                check_overlay(R, n, im, imgs)
        elif k == "marker":
            check_marker(R, n, im)
    for n in ("wall-o-auto", "wall-u-auto", "water-auto"):
        if n in imgs and (imgs[n].w, imgs[n].h) == (84, 126) and (not only or n in only):
            tiles_by_sheet[n] = check_sheet(R, n, imgs[n], imgs, sheetsdir) or {}
        elif n in imgs and (imgs[n].w, imgs[n].h) == (84, 126):
            tiles_by_sheet[n] = {k: Img(compose(imgs[n], k)) for k in combos47()}
    for n in ("wall-o-deep", "wall-u-deep"):
        if n in imgs and (imgs[n].w, imgs[n].h) == (42, 42) and (not only or n in only):
            check_deep(R, n, imgs[n], imgs, tiles_by_sheet)
    if not only:
        check_variants(R, imgs)
        check_caps(R, imgs)
    mosaic = build_mosaic(imgs, tiles_by_sheet)
    mosaic.save(os.path.join(sheetsdir, "trek-mosaic.png"))
    cnt = Counter(R.status(n) for n in ALL)
    summary = "OK %d, WARN %d, FAIL %d, MISSING %d of 46 assets." % (cnt["OK"], cnt["WARN"], cnt["FAIL"], cnt["MISSING"])
    write_html(os.path.join(sheetsdir, "index.html"), R, imgs, summary)
    for n in ALL:
        st = R.status(n)
        if quiet and st in ("OK", "MISSING"):
            continue
        print("%-8s trek-%s" % (st, n))
        for lv, tx in R.items[n]:
            if lv != "MISSING":
                print("          %s: %s" % (lv, tx))
    print(summary)
    print("wrote", os.path.join(sheetsdir, "trek-mosaic.png"), "and", os.path.join(sheetsdir, "index.html"))
    return 1 if cnt["FAIL"] else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
