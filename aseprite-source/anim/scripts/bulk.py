#!/usr/bin/env python3
"""bulk.py: generic 6-frame idle animation for every act-<slug>.png that has no hand-made strip.

Run from anywhere:  python aseprite-source/anim/scripts/bulk.py [--only slug,slug] [--force] [--sheet DIR]
Writes game/assets/img/acts/act-<slug>-anim.png (6 x 144x108 strip, optimised PNG) and skips slugs that
have a pilot strip in aseprite-source/anim/ (never overwritten) unless the strip carries the bulk marker
(see MARK) - so the script is safely re-runnable.  --report prints per-slug effect lists.

Method (same rules as the pilot animlib.lua): every frame is the static picture on its 72x54 grid of 2px
cells with some existing cells MOVED or hidden-and-refilled from the surrounding background colour.
No blending, no new colours (the only extras are the pilot accents in the fallback glint).  The outer 5
cells (the picture frame) are never touched, and frame 1 is always the static picture pixel for pixel.

Effects: gnome breath (upper body stretches 1 cell), cloud drift, flame tip flicker, drifting glints /
ripples / birds (small specks on a uniform background), twinkling plus-sparkles and stars, fallback glint.
Tear guards: a moving object must sit on a uniform background (per-row equal colour either side, or a
uniform 8-ring), otherwise it stays still.
"""
import os, sys, glob, hashlib, io
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
ACTS = os.path.join(REPO, "game", "assets", "img", "acts")
PILOT = os.path.join(REPO, "aseprite-source", "anim")
N = 6
CW, CH = 72, 54
BORDER = 5
ACCENTS = ["#f5cf6a", "#fff3c8", "#fff2b0", "#ffe08a"]


def hexv(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16) << 24) | (int(h[2:4], 16) << 16) | (int(h[4:6], 16) << 8) | 255


def rgb_of(v):
    return (v >> 24) & 255, (v >> 16) & 255, (v >> 8) & 255


def lum(v):
    r, g, b = rgb_of(v)
    return (0.299 * r + 0.587 * g + 0.114 * b) / 255.0


def hsv(v):
    import colorsys
    r, g, b = rgb_of(v)
    return colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)


GNOME = {hexv(h) for h in ["#c0442e", "#8e2e1e", "#2a1a10", "#f0c8a0", "#e08a7a", "#f4eee0", "#cfc6b0",
                           "#4a6e9a", "#34507a", "#d4a27a", "#74462a", "#4a2c1a"]}
HAT = hexv("#c0442e")
DARK_OUTLINE = {hexv("#2a1a10"), hexv("#4a2c1a"), hexv("#74462a"), hexv("#3d2a1c")}


def load_cells(path):
    a = np.array(Image.open(path).convert("RGBA"))
    pix = (a[..., 0].astype(np.uint32) << 24) | (a[..., 1].astype(np.uint32) << 16) | (a[..., 2].astype(np.uint32) << 8) | a[..., 3]
    pix = np.where(a[..., 3] == 0, 0, pix).astype(np.uint32)
    cells = pix[::2, ::2].copy()
    return a, cells


def components(g, pred, conn8=False):
    """connected components of cells where pred(value) is true. returns list of lists of (y,x)."""
    h, w = g.shape
    mask = np.zeros_like(g, dtype=bool)
    for y in range(h):
        for x in range(w):
            if g[y, x] != 0 and pred(g[y, x]):
                mask[y, x] = True
    return label(mask, conn8)


def label(mask, conn8=False):
    h, w = mask.shape
    seen = np.zeros_like(mask)
    out = []
    nb = [(-1, 0), (1, 0), (0, -1), (0, 1)] + ([(-1, -1), (-1, 1), (1, -1), (1, 1)] if conn8 else [])
    for y in range(h):
        for x in range(w):
            if mask[y, x] and not seen[y, x]:
                st = [(y, x)]
                seen[y, x] = True
                comp = []
                while st:
                    cy, cx = st.pop()
                    comp.append((cy, cx))
                    for dy, dx in nb:
                        ny, nx = cy + dy, cx + dx
                        if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not seen[ny, nx]:
                            seen[ny, nx] = True
                            st.append((ny, nx))
                out.append(comp)
    return out


def bbox(comp):
    ys = [c[0] for c in comp]
    xs = [c[1] for c in comp]
    return min(xs), min(ys), max(xs), max(ys)  # x0,y0,x1,y1


def inside(y, x, pad=0):
    return BORDER + pad <= x < CW - BORDER - pad and BORDER + pad <= y < CH - BORDER - pad


def seed_of(slug, salt=""):
    return int(hashlib.md5((slug + salt).encode()).hexdigest()[:8], 16)


# ------------------------------------------------------------------ effects (each returns a function frames->None or None)
class Scene:
    def __init__(self, slug, cells):
        self.slug = slug
        self.g = cells
        self.protect = np.zeros(cells.shape, dtype=bool)  # cells that other effects must not touch
        self.effects = []  # (name, fn(frame_cells, i))
        self.rng = np.random.RandomState(seed_of(slug) & 0x7fffffff)

    def protect_box(self, x0, y0, x1, y1):
        self.protect[max(0, y0):y1 + 1, max(0, x0):x1 + 1] = True


BREATH = [0, 0, 1, 1, 0, 0]


def find_gnomes(sc, relaxed=False):
    g = sc.g
    out = []
    for comp in components(g, lambda v: v == HAT):
        x0, y0, x1, y1 = bbox(comp)
        w, h = x1 - x0 + 1, y1 - y0 + 1
        if relaxed:
            top = sum(1 for (y, x) in comp if y == y0)
            ok = 5 <= w <= 11 and 4 <= h <= 9 and y0 >= 6 and len(comp) >= 14 and top <= 3
        else:
            ok = 7 <= w <= 11 and 5 <= h <= 9 and y0 >= 6 and len(comp) >= 18
        if ok and x0 >= BORDER - 1 and x1 <= CW - BORDER:
            out.append((x0, y0, x1, y1))
    return out


def add_breath(sc, split_off=None):
    gnomes = find_gnomes(sc) or find_gnomes(sc, True)
    if not gnomes:
        return 0
    g = sc.g
    prepared = []
    for (x0, y0, x1, y1) in gnomes:
        bx0, bx1 = max(BORDER, x0 - 2), min(CW - BORDER - 1, x1 + 3)
        so = split_off or (y1 - y0 + 1) + int(round(7 * (x1 - x0 + 1) / 7.0))
        top, split = y0 - 1, min(CH - BORDER - 2, y0 + so)
        # mask: gnome-colour cells connected to the hat inside the box (rows top..split)
        gm = np.zeros(g.shape, dtype=bool)
        inbox = np.zeros(g.shape, dtype=bool)
        for y in range(top, split + 1):
            for x in range(bx0, bx1 + 1):
                if g[y, x] in GNOME:
                    inbox[y, x] = True
        seeds = [c for c in components(g, lambda v: v == HAT) if bbox(c) == (x0, y0, x1, y1)]
        stack = list(seeds[0])
        for (y, x) in stack:
            gm[y, x] = True
        while stack:
            cy, cx = stack.pop()
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    ny, nx = cy + dy, cx + dx
                    if 0 <= ny < CH and 0 <= nx < CW and inbox[ny, nx] and not gm[ny, nx]:
                        gm[ny, nx] = True
                        stack.append((ny, nx))
        # moved: mask cells in rows top..split-1 go up 1; row split stays (stretch)
        cells = [(y, x) for y in range(top, split + 1) for x in range(bx0, bx1 + 1) if gm[y, x]]
        if len(cells) < 40 or top - 1 < BORDER:
            continue
        # tear guard: the cell above every top-edge mask cell must be uniform-ish background (no foreground
        # object directly over the hat) - require that the cell above isn't a dark outline from other objects
        prepared.append((gm, top, split, bx0, bx1))
        sc.protect_box(bx0 - 1, top - 2, bx1 + 1, split + 2)
    if not prepared:
        return 0

    def fn(f, i):
        d = BREATH[i]
        if not d:
            return
        for gm, top, split, bx0, bx1 in prepared:
            src = f.copy()
            moved = [(y, x) for y in range(top, split + 1) for x in range(bx0, bx1 + 1) if gm[y, x]]
            for (y, x) in moved:
                if y == split:
                    continue
                # vacated: take the colour of the cell below if that is not itself a gnome cell, else background above
                below = src[y + 1, x] if (y + 1 < CH) else 0
                if gm[y + 1, x] if y + 1 < CH else False:
                    # below is a gnome cell that will move into (y,x): nothing to fill
                    continue
                f[y, x] = below
            for (y, x) in moved:
                if y == split:
                    # split row also copies up (stretch)
                    pass
                f[y - 1, x] = src[y, x]
    sc.effects.append(("breath", fn))
    return len(prepared)


def uniform_bg_rows(g, comp, color):
    """per-row contiguous run with equal bg colour on both sides; returns {y:(lx,rx,bg)} or None"""
    rows = {}
    for (y, x) in comp:
        rows.setdefault(y, []).append(x)
    out = {}
    for y, xs in rows.items():
        lx, rx = min(xs), max(xs)
        if rx - lx + 1 != len(xs):
            return None
        if lx - 2 < 0 or rx + 2 >= CW:
            return None
        L, R = g[y, lx - 1], g[y, rx + 1]
        L2, R2 = g[y, lx - 2], g[y, rx + 2]
        if L != R or L == 0 or L2 != R2 or L == color:
            return None
        out[y] = (lx, rx, int(L))
    return out


def add_clouds(sc):
    g = sc.g
    LIGHT = lambda v: lum(v) > 0.88
    prepared = []
    for comp in components(g, LIGHT):
        # single-colour requirement
        cols = {int(g[y, x]) for (y, x) in comp}
        if len(cols) != 1:
            continue
        x0, y0, x1, y1 = bbox(comp)
        w, h = x1 - x0 + 1, y1 - y0 + 1
        if w < 8 or h > 8 or y0 > 24 or y0 < BORDER or x0 < BORDER + 2 or x1 > CW - BORDER - 3:
            continue
        col = cols.pop()
        rows = uniform_bg_rows(g, comp, col)
        if rows is None:
            continue
        # need uniform sky: ring colours must be light-blue-ish or any uniform background; reject if bg is dark fixtures
        bgcols = {v[2] for v in rows.values()}
        if any(hsv(c)[2] < 0.55 for c in bgcols):
            # dark (night) background: a moon/cloud is fine, but skip if bg is very dark brown wood
            if any(DARK_OUTLINE & {c} for c in bgcols):
                continue
        prepared.append((rows, col, (x0, y0, x1, y1), len(prepared)))
    if not prepared:
        return 0
    patt = [0, 0, 1, 1, 1, 0]

    def fn(f, i):
        d = patt[i]
        if not d:
            return
        for rows, col, bb, k in prepared:
            sgn = 1 if k % 2 == 0 else -1
            for y, (lx, rx, bg) in rows.items():
                if sgn > 0:
                    f[y, lx] = bg
                    f[y, rx + 1] = col
                else:
                    f[y, rx] = bg
                    f[y, lx - 1] = col
    for rows, col, bb, k in prepared:
        sc.protect_box(bb[0] - 2, bb[1] - 1, bb[2] + 2, bb[3] + 1)
    sc.effects.append(("cloud", fn))
    return len(prepared)


def is_fire(v):
    h, s, vv = hsv(v)
    return (h <= 0.16 or h >= 0.98) and s >= 0.65 and vv >= 0.8


def add_flames(sc):
    """flame flicker: the 1-2 cell wide tips of a flame component (fire colours) drop one cell on the beat,
    refilled from the background cell above the tip.  Skips if that background is not uniform per tip."""
    g = sc.g
    prepared = []
    for comp in components(g, is_fire):
        x0, y0, x1, y1 = bbox(comp)
        w, h = x1 - x0 + 1, y1 - y0 + 1
        n = len(comp)
        if h < 4 or w > 16 or n < 8 or n > 400 or y0 < BORDER + 2 or y1 > CH - BORDER - 1 or x0 < BORDER + 1 or x1 > CW - BORDER - 2:
            continue
        if sc.protect[y0:y1 + 1, x0:x1 + 1].any():
            continue
        cset = set(comp)
        rows = {}
        for (y, x) in comp:
            rows.setdefault(y, []).append(x)
        hues = [hsv(int(g[y, x]))[0] for (y, x) in comp]
        if len({int(g[y, x]) for (y, x) in comp}) < 2 or not any(t <= 0.1 or t >= 0.98 for t in hues):
            continue  # a flame has at least two fire tones (red/orange, yellow core)
        wid = max(rows, key=lambda r: len(rows[r]))
        if wid < y0 + h * 0.4 or len(rows[y0]) > 3:
            continue  # tapered: widest part in the lower half, narrow tip
        tips = []
        for (y, x) in comp:
            if y > y0 + 4 or (y - 1, x) in cset:
                continue
            if len(rows[y]) > 4:
                continue
            # exposed top edge, and the column continues below
            if (y + 1, x) not in cset:
                continue
            up = int(g[y - 1, x])
            if up == 0 or is_fire(up) or up in GNOME and up != hexv("#2a1a10") and lum(up) > 0.9:
                continue
            tips.append((y, x, up))
        # tip cells must be a thin crown: <= 30% of the flame
        if not tips or len(tips) > max(3, int(0.3 * n)):
            continue
        # each filled colour must be the same bg as the cell beside the tip row (uniform sky or outline)
        prepared.append(tips)
        sc.protect_box(x0 - 1, y0 - 1, x1 + 1, y1 + 1)
    if not prepared:
        return 0
    patt = [0, 1, 0, 1, 1, 0]

    def fn(f, i):
        if not patt[i]:
            return
        for tips in prepared:
            for (y, x, up) in tips:
                f[y, x] = up
    sc.effects.append(("flame", fn))
    return len(prepared)


def ring_cells(comp, h=CH, w=CW):
    s = set(comp)
    r = set()
    for (y, x) in comp:
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                p = (y + dy, x + dx)
                if p not in s and 0 <= p[0] < h and 0 <= p[1] < w:
                    r.add(p)
    return r


PLUS = {(0, 1), (1, 0), (1, 1), (1, 2), (2, 1)}


def small_comps(g, maxn=12):
    """single-colour 4-connected components of at most maxn cells, inside the picture (not frame)."""
    h, w = g.shape
    done = np.zeros(g.shape, dtype=bool)
    out = []
    for y in range(BORDER + 1, CH - BORDER - 1):
        for x in range(BORDER + 1, CW - BORDER - 1):
            if done[y, x] or g[y, x] == 0:
                continue
            col = g[y, x]
            st = [(y, x)]
            done[y, x] = True
            comp = []
            big = False
            while st:
                cy, cx = st.pop()
                comp.append((cy, cx))
                if len(comp) > maxn:
                    big = True
                for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                    ny, nx = cy + dy, cx + dx
                    if 0 <= ny < h and 0 <= nx < w and not done[ny, nx] and g[ny, nx] == col:
                        done[ny, nx] = True
                        if not big:
                            st.append((ny, nx))
            if not big:
                out.append((int(col), comp))
    return out


def add_weather(sc):
    """rain / snow: scenes with many tiny light specks (1 cell wide, 1-3 tall) in sky-like surroundings.
    Rain streaks fall 1-2 cells on a 3-step loop, snowflakes float 1-2 cells down and back.  Vacated cells take
    the colour of the cell above the particle, so banded skies stay banded; a particle only moves when the cells
    it moves into are background (the colour just below it)."""
    g = sc.g
    parts = []
    for col, comp in small_comps(g, 4):
        x0, y0, x1, y1 = bbox(comp)
        bw, bh = x1 - x0 + 1, y1 - y0 + 1
        if bw > 1 or bh > 3 or not (inside(y0, x0, 3) and inside(y1, x1, 3)):
            continue
        if sc.protect[y0:y1 + 1, x0:x1 + 1].any():
            continue
        rc = {int(g[p]) for p in ring_cells(comp)} - {col}
        if len(rc) > 2 or len(rc) == 0 or 0 in rc:
            continue
        if any(lum(col) - lum(c) < 0.1 for c in rc):
            continue
        # ring colours must be background-like (no dark outlines: those mean a drawn object)
        if any(c in DARK_OUTLINE for c in rc):
            continue
        if lum(col) < 0.5 or hsv(col)[1] > 0.4 or min(lum(c) for c in rc) < 0.25:
            continue  # precipitation is pale and falls through a daylight/dusk background (dark = stars)
        parts.append((comp, col, rc, bh, x0, y0, y1))
    if len(parts) < 16:
        return 0
    xs_ = np.array([p[4] for p in parts])
    if xs_.max() - xs_.min() < 36 or sum(1 for b in range(6) if ((xs_ - BORDER) // 11 == b).sum() >= 2) < 4:
        return 0
    ys_ = np.array([p[5] for p in parts])
    if (ys_ >= 30).mean() < 0.25 or (ys_ < 24).mean() < 0.2:
        return 0  # stars / sparkles confined to one band, not precipitation
    rain = np.mean([p[3] for p in parts]) >= 1.6
    maxd = 2
    keep = []
    for comp, col, rc, bh, x0, y0, y1 in parts:
        up = int(g[y0 - 1, x0])
        below = [int(g[y1 + k, x0]) for k in range(1, maxd + 1)]
        d = 0
        for k in range(1, maxd + 1):
            if below[k - 1] in rc:
                d = k
            else:
                break
        if d == 0 or up not in rc:
            continue
        keep.append((x0, y0, y1, col, up, d))
    if len(keep) < 10:
        return 0
    keep = keep[:120]
    for (x0, y0, y1, col, up, d) in keep:
        sc.protect[y0:y1 + 1, x0] = True
    rain_p = [0, 1, 2, 0, 1, 2]
    snow_p = [0, 1, 1, 2, 1, 0]

    def fn(f, i):
        moves = []
        for k, (x0, y0, y1, col, up, d) in enumerate(keep):
            m = rain_p[i] if rain else (snow_p[i] if k % 2 else (0, 0, 1, 1, 0, 0)[i])
            m = min(m, d)
            if m:
                moves.append((x0, y0, y1, col, up, m))
        for (x0, y0, y1, col, up, m) in moves:
            for y in range(y0, min(y1, y0 + m - 1) + 1):
                f[y, x0] = up
        for (x0, y0, y1, col, up, m) in moves:
            for y in range(y0 + m, y1 + m + 1):
                f[y, x0] = col
    sc.effects.append(("weather", fn))
    return len(keep)


def add_specks(sc, maxn=14):
    """sparkle-plus twinkles and small glints/specks on a uniform background."""
    g = sc.g
    plus_list, glints, twinkles = [], [], []
    comps = []
    # single-colour components
    h, w = g.shape
    done = np.zeros(g.shape, dtype=bool)
    for y in range(BORDER + 1, CH - BORDER - 1):
        for x in range(BORDER + 1, CW - BORDER - 1):
            if done[y, x] or g[y, x] == 0:
                continue
            col = g[y, x]
            st = [(y, x)]
            done[y, x] = True
            comp = []
            big = False
            while st:
                cy, cx = st.pop()
                comp.append((cy, cx))
                if len(comp) > 12:
                    big = True
                for dy, dx in ((-1, 0), (1, 0), (0, -1), (0, 1)):
                    ny, nx = cy + dy, cx + dx
                    if 0 <= ny < h and 0 <= nx < w and not done[ny, nx] and g[ny, nx] == col:
                        done[ny, nx] = True
                        if not big:
                            st.append((ny, nx))
            if not big:
                comps.append((int(col), comp))
    steam = []
    for col, comp in comps:
        x0, y0, x1, y1 = bbox(comp)
        if not (inside(y0, x0, 3) and inside(y1, x1, 3)):
            continue
        if sc.protect[y0:y1 + 1, x0:x1 + 1].any():
            continue
        if col in DARK_OUTLINE or (col in GNOME and lum(col) < 0.2):
            continue
        ring = ring_cells(comp)
        rc = {int(g[p]) for p in ring}
        norm = {(y - y0, x - x0) for (y, x) in comp}
        if norm == PLUS:
            if lum(col) < 0.45 and hsv(col)[1] < 0.3:
                continue
            box = [int(g[y, x]) for y in range(y0 - 1, y1 + 2) for x in range(x0 - 1, x1 + 2) if (y - y0, x - x0) not in PLUS]
            vals, cnt = np.unique(box, return_counts=True)
            if len(vals) <= 2 and cnt.max() >= 0.8 * len(box):
                plus_list.append((y0, x0, col, int(vals[cnt.argmax()])))
            continue
        if len(rc) != 1:
            continue
        bg = rc.pop()
        if bg == 0 or bg == col:
            continue
        # isolation: everything within 2 cells of the speck is bg (keeps text, dotted patterns and details still)
        iso = all(int(g[y, x]) in (bg, col) for y in range(y0 - 2, y1 + 3) for x in range(x0 - 2, x1 + 3))
        if not iso:
            continue
        win = g[max(0, y0 - 5):y1 + 6, max(0, x0 - 5):x1 + 6]
        if np.isin(win, [bg, col]).mean() < 0.9 or (win == col).sum() > len(comp) + 2:
            continue  # not a lone speck (net / dotted pattern / text)
        bw, bh = x1 - x0 + 1, y1 - y0 + 1
        dl = lum(col) - lum(bg)
        sat = hsv(col)[1]
        if len(comp) > 10 or bw > 6 or bh > 3:
            if dl > 0.12 and lum(col) > 0.8 and 10 < len(comp) <= 40 and bw <= 8 and bh <= 10 and y0 > 14:
                steam.append((comp, col, bg))
            continue
        if abs(dl) < 0.12 and sat < 0.35:
            continue
        # outline-ish / eyes: skip dark specks except on light sky-ish bg in the upper part (birds)
        if dl < 0 and not (y0 < 20 and lum(bg) > 0.6) and sat < 0.35:
            continue
        if lum(bg) < 0.3 and dl > 0:
            twinkles.append((comp, col, bg))
        else:
            glints.append((comp, col, bg))
    r = sc.rng
    r.shuffle(glints)
    glints = glints[:maxn]
    r.shuffle(twinkles)
    twinkles = twinkles[:10]
    r.shuffle(plus_list)
    plus_list = plus_list[:8]
    r.shuffle(steam)
    steam = steam[:4]
    if not (glints or twinkles or plus_list or steam):
        return 0
    drift = [[0, 1, 1, 0, -1, -1], [0, 0, 1, 1, 0, 0], [0, -1, -1, 0, 1, 1], [0, 0, -1, -1, 0, 0]]
    tw = [[1, 1, 0, 0, 1, 1], [1, 0, 0, 1, 1, 1], [0, 1, 1, 1, 0, 0], [1, 1, 1, 0, 0, 1]]
    pl = [[2, 2, 1, 0, 1, 2], [1, 2, 2, 1, 0, 1], [0, 1, 2, 2, 1, 0], [2, 1, 0, 1, 2, 2]]

    rise = [0, 0, 1, 1, 1, 0]

    def fn(f, i):
        for k, (comp, col, bg) in enumerate(steam):
            if rise[i]:
                for (y, x) in comp:
                    f[y, x] = bg
                for (y, x) in comp:
                    f[y - 1, x] = col
        for k, (comp, col, bg) in enumerate(glints):
            d = drift[k % 4][i]
            if d:
                for (y, x) in comp:
                    f[y, x] = bg
                for (y, x) in comp:
                    f[y, x + d] = col
        for k, (comp, col, bg) in enumerate(twinkles):
            if not tw[k % 4][i]:
                for (y, x) in comp:
                    f[y, x] = bg
        for k, (y0, x0, col, bg) in enumerate(plus_list):
            st = pl[k % 4][i]
            if st == 2:
                continue
            for (dy, dx) in PLUS:
                if (dy, dx) == (1, 1) and st == 1:
                    continue
                oy, ox = {(0, 1): (-1, 1), (2, 1): (3, 1), (1, 0): (1, -1), (1, 2): (1, 3)}.get((dy, dx), (dy, dx))
                f[y0 + dy, x0 + dx] = g[y0 + oy, x0 + ox] if (dy, dx) != (1, 1) else bg
    sc.effects.append(("specks", fn))
    return len(glints) + len(twinkles) + len(plus_list) + len(steam)


def add_glint(sc):
    """fallback: a gentle accent glint sweeping over an existing light/gold cell cluster (frame 1 untouched)."""
    g = sc.g
    cand = []
    for comp in components(g, lambda v: lum(v) > 0.55 and (hsv(v)[1] > 0.35 or lum(v) > 0.9), conn8=False):
        x0, y0, x1, y1 = bbox(comp)
        if len(comp) < 2 or len(comp) > 60:
            continue
        if not (inside(y0, x0, 1) and inside(y1, x1, 1)):
            continue
        if sc.protect[y0:y1 + 1, x0:x1 + 1].any():
            continue
        cand.append(comp)
    if not cand:
        return 0
    sc.rng.shuffle(cand)
    cand = sorted(cand[:12], key=lambda c: -len(c))[:3]
    accent = hexv(ACCENTS[1])

    def fn(f, i):
        if i in (0, 5):
            return
        for k, comp in enumerate(cand):
            cs = sorted(comp)
            idx = ((i - 1) + k) % len(cs) if len(cs) > 1 else 0
            y, x = cs[idx]
            f[y, x] = accent
    sc.effects.append(("glint", fn))
    return len(cand)


def build(slug, pixels, cells, report):
    sc = Scene(slug, cells)
    info = {}
    info["breath"] = add_breath(sc)
    info["cloud"] = add_clouds(sc)
    info["flame"] = add_flames(sc)
    info["weather"] = add_weather(sc)
    info["specks"] = add_specks(sc)
    n_nongnome = info["cloud"] + info["flame"] + info["specks"] + info["weather"]
    if n_nongnome == 0 and info["breath"] == 0:
        info["glint"] = add_glint(sc)
    elif n_nongnome == 0:
        info["glint"] = add_glint(sc)
    frames = []
    for i in range(N):
        f = cells.copy()
        if i:
            for name, fn in sc.effects:
                fn(f, i)
        frames.append(f)
    # compose pixel frames: static pixels with changed cells repainted
    out = []
    for i, f in enumerate(frames):
        a = pixels.copy()
        if i:
            ch = np.argwhere(f != cells)
            for (cy, cx) in ch:
                v = f[cy, cx]
                if not (BORDER <= cx < CW - BORDER and BORDER <= cy < CH - BORDER):
                    continue
                if v == 0:
                    rgba = (0, 0, 0, 0)
                else:
                    rgba = (int(v >> 24) & 255, int(v >> 16) & 255, int(v >> 8) & 255, 255)
                a[cy * 2:cy * 2 + 2, cx * 2:cx * 2 + 2] = rgba
        out.append(a)
    return out, info


def save_strip(frames, path):
    h, w = frames[0].shape[:2]
    strip = np.concatenate(frames, axis=1)
    im = Image.fromarray(strip, "RGBA")
    im.save(path, optimize=True)


def main():
    args = sys.argv[1:]
    only = None
    force = "--force" in args
    sheet = None
    if "--only" in args:
        only = set(args[args.index("--only") + 1].split(","))
    pilots = {os.path.basename(p)[4:-len("-anim.aseprite")] for p in glob.glob(os.path.join(PILOT, "act-*-anim.aseprite"))}
    stats = {"animated": 0, "fallback": 0, "static_only": 0}
    log = []
    for p in sorted(glob.glob(os.path.join(ACTS, "act-*.png"))):
        b = os.path.basename(p)
        if b.endswith("-anim.png"):
            continue
        slug = b[4:-4]
        if slug in pilots:
            continue
        if only and slug not in only:
            continue
        pixels, cells = load_cells(p)
        frames, info = build(slug, pixels, cells, None)
        save_strip(frames, os.path.join(ACTS, "act-%s-anim.png" % slug))
        main_eff = sum(info.get(k, 0) for k in ("breath", "cloud", "flame", "specks", "weather"))
        key = "animated" if main_eff else ("fallback" if info.get("glint") else "static_only")
        stats[key] += 1
        log.append((slug, info))
    print(stats)
    if "--report" in args:
        for s, i in log:
            print(s, i)


if __name__ == "__main__":
    main()
