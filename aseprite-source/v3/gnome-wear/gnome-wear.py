#!/usr/bin/env python3
"""gnome-wear: five fixed-colour wearable layers for the 2.5D gnome rig (game/assets/img/gnome25).

Views front, back, side (side = facing RIGHT); each layer is a 512x80 strip, 8 frames of 64x80
(idle 1-2, walk 3-8), lined up with gnome-dir.lua (same frame tables, bob, arm swing, feet).
Layers (stack per gnome25.php GNOME25_WEAR_AFTER):
  wboots  Flood Boots     after boots   tall waxed green boots, rolled tan cuff     quirk: red repair patch
  gloves  Work Gloves     after skin    tan leather, stitched darker cuff           quirk: patched knuckle on one glove
  cape    Travel Cloak    first (front) / after tunic (back, side)                  quirk: wooden toggle + darned patch
  brim    Wayfarer's Hat  after hat     brown felt brim + plum band over the hat    quirk: a gold feather
  pack    Trail Pack      first (front) / after tunic (back, side)  canvas + rolled red blanket  quirk: sky-blue patch
Outline: 1 px ink #2b1c26 only where the wearable meets empty space (or the ground shadow); where it
meets the gnome it gets its own deep tone instead. Hard pixels only.
Run: python3 gnome-wear.py [outdir]   (reads the base rig from game/assets/img/gnome25)
"""
import math, os, sys
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
BASE = os.path.join(ROOT, 'game', 'assets', 'img', 'gnome25')
OUT = sys.argv[1] if len(sys.argv) > 1 else HERE
W, H, N = 64, 80, 8
INK = '#2b1c26'
floor, ceil = math.floor, math.ceil

# ---------------------------------------------------------------- ramps (fixed colours, Hearth Pop family)
MOSS = dict(hi='#b9dc78', lt='#8cc05c', base='#68a24e', sh='#437f47', dp='#2a5945', xd='#1f3f3a')
TOGGLE = dict(hi='#e8b982', base='#b97a4a', sh='#864c33', dp='#51302b')
WELLY = dict(spec='#d4f0b0', hi='#7fc07a', lt='#58a36a', base='#3c8458', sh='#2c6550', dp='#1f4440')
CUFF = dict(hi='#f2d6a0', base='#d9b076', sh='#ad7f4e')
LEATHER = dict(hi='#f6d9a4', lt='#e6bd80', base='#cf9c5f', sh='#a3713f', dp='#6e4529')
FELT = dict(hi='#c99a6c', lt='#ab7a52', base='#8d5d3d', sh='#6c4232', dp='#4a2c28')
BAND = dict(hi='#a8456a', base='#7d2c5e', dp='#4f1c42')
FEATHER = dict(hi='#fff4d6', lt='#ffe38a', base='#f5b82e', sh='#d98322', dp='#8f4a1f')
CANVAS = dict(hi='#ece4c8', lt='#d3c7a2', base='#b3a57e', sh='#877a5c', dp='#5b5142')   # oat canvas, a touch grey so it parts from the gold scarf
STRAP = dict(hi='#d69a62', base='#a96a40', sh='#7c4a31', dp='#51302b')
BLANKET = dict(hi='#b9a2ea', base='#8a6fd0', sh='#5a459e', dp='#35295f', st='#ffe38a')   # dusk wool, gold stripe
PATCH = dict(base='#8bc4ea', sh='#5f9ad0')
BUCKLE = dict(hi='#ffe38a', base='#d9a33a')

# ---------------------------------------------------------------- frame tables (copied from gnome-dir.lua)
IDLE = [dict(bob=0), dict(bob=1, pdy=1)]
FB = [dict(bob=0, ly=0, ry=-1, arm=-2, hb=0, braid=0, tail=0, pdy=0, hem=0),
      dict(bob=-1, ly=0, ry=-2, arm=-1, hb=-1, braid=-1, tail=-1, pdy=0, hem=-1),
      dict(bob=0, ly=0, ry=-3, arm=0, hb=-1, braid=-1, tail=-1, pdy=1, hem=0),
      dict(bob=0, ly=-1, ry=0, arm=2, hb=0, braid=0, tail=0, pdy=0, hem=0),
      dict(bob=-1, ly=-2, ry=0, arm=1, hb=1, braid=1, tail=1, pdy=0, hem=1),
      dict(bob=0, ly=-3, ry=0, arm=0, hb=1, braid=1, tail=1, pdy=1, hem=0)]
SD = [dict(bob=0, nx=4, nl=0, fx=-4, fl=0, arm=-3, hb=0, pdy=0, braid=0, tail=0, hem=0),
      dict(bob=-1, nx=2, nl=0, fx=-3, fl=-2, arm=-2, hb=0, pdy=0, braid=0, tail=-1, hem=-1),
      dict(bob=0, nx=-1, nl=0, fx=1, fl=-3, arm=0, hb=1, pdy=1, braid=-1, tail=-1, hem=0),
      dict(bob=0, nx=-4, nl=0, fx=4, fl=0, arm=3, hb=0, pdy=0, braid=0, tail=0, hem=0),
      dict(bob=-1, nx=-3, nl=-2, fx=2, fl=0, arm=2, hb=0, pdy=0, braid=0, tail=-1, hem=-1),
      dict(bob=0, nx=1, nl=-3, fx=-1, fl=0, arm=0, hb=1, pdy=1, braid=-1, tail=-1, hem=0)]
FRAMES = {'front': IDLE + FB, 'back': IDLE + FB, 'side': IDLE + SD}
# cloth sway for cape and pack: lags the body by one frame (idle: still)
SWAY = [0, 0, 0, -1, -1, 0, 1, 1]

# ---------------------------------------------------------------- masks (same rasterisation as hp.lua)
def ellipse(cx, cy, rx, ry):
    m = set()
    for y in range(floor(cy - ry - 1), ceil(cy + ry + 1) + 1):
        for x in range(floor(cx - rx - 1), ceil(cx + rx + 1) + 1):
            if ((x - cx) / (rx + .5)) ** 2 + ((y - cy) / (ry + .5)) ** 2 <= 1: m.add((x, y))
    return m

def rect(x0, y0, x1, y1): return {(x, y) for y in range(y0, y1 + 1) for x in range(x0, x1 + 1)}

def rrect(x0, y0, x1, y1, r):
    m = set()
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            cx = cy = None
            if x < x0 + r: cx = x0 + r
            elif x > x1 - r: cx = x1 + 1 - r
            if y < y0 + r: cy = y0 + r
            elif y > y1 - r: cy = y1 + 1 - r
            if cx is None or cy is None or (x + .5 - cx) ** 2 + (y + .5 - cy) ** 2 <= r * r: m.add((x, y))
    return m

def poly(pts):
    m = set()
    xs = [p[0] for p in pts]; ys = [p[1] for p in pts]
    for y in range(floor(min(ys)), ceil(max(ys)) + 1):
        for x in range(floor(min(xs)), ceil(max(xs)) + 1):
            px, py, inside = x + .5, y + .5, False
            j = len(pts) - 1
            for i in range(len(pts)):
                a, b = pts[i], pts[j]
                if (a[1] > py) != (b[1] > py) and px < (b[0] - a[0]) * (py - a[1]) / (b[1] - a[1]) + a[0]: inside = not inside
                j = i
            if inside: m.add((x, y))
    return m

def line(pts, w=1):
    m, lo = set(), (w - 1) // 2
    def stamp(x, y):
        for dy in range(w):
            for dx in range(w):
                if not (w >= 4 and dx in (0, w - 1) and dy in (0, w - 1)): m.add((x - lo + dx, y - lo + dy))
    if len(pts) == 1: stamp(floor(pts[0][0] + .5), floor(pts[0][1] + .5))
    for a, b in zip(pts, pts[1:]):
        n = max(abs(b[0] - a[0]), abs(b[1] - a[1]), 1)
        for s in range(n + 1): stamp(floor(a[0] + (b[0] - a[0]) * s / n + .5), floor(a[1] + (b[1] - a[1]) * s / n + .5))
    return m

N4 = ((1, 0), (-1, 0), (0, 1), (0, -1))
def edge(m): return {p for p in m if any((p[0] + dx, p[1] + dy) not in m for dx, dy in N4)}

# ---------------------------------------------------------------- base rig (to know where the gnome is)
_cache = {}
def base_layer(view, name):
    k = (view, name)
    if k not in _cache: _cache[k] = Image.open(os.path.join(BASE, f'{view}-{name}.png')).convert('RGBA')
    return _cache[k]

def base_mask(view, f, names):
    m = set()
    for n in names:
        im = base_layer(view, n); px = im.load()
        for y in range(H):
            for x in range(W):
                if px[f * W + x, y][3] > 0: m.add((x, y))
    return m

BODY = ['outline', 'boots', 'tunic', 'scarf', 'skin', 'beard', 'face', 'hat', 'trim']

# ---------------------------------------------------------------- shading helper
def form(px, m, r, frac=0.33, off=2, hi_rows=1, deep_bottom=True, keys=('hi', 'base', 'sh', 'dp')):
    """paint m: base; right `frac` of each row and the down-right offset edge -> shade; top-left rim -> hi; bottom -> deep."""
    hi, base, sh, dp = (r[k] for k in keys)
    rows = {}
    for x, y in m:
        a = rows.setdefault(y, [x, x]); a[0] = min(a[0], x); a[1] = max(a[1], x)
    for x, y in m:
        t = rows[y]; c = base
        if (x - t[0] + .5) / (t[1] - t[0] + 1) > 1 - frac or (x + off, y + off) not in m: c = sh
        elif (x - 1, y - hi_rows) not in m and (x, y - 1) not in m: c = hi
        if deep_bottom and (x, y + 1) not in m: c = dp
        px[(x, y)] = c
    return m

def finish(px, view, f, deep, body=None, ink_over=()):
    """outline: ring around the layer -> ink where empty/shadow; layer edge touching the gnome -> `deep` on its lower/right side."""
    body = body if body is not None else base_mask(view, f, BODY)
    m = set(px)
    ring = {(x + dx, y + dy) for x, y in m for dx, dy in N4} - m
    for p in ring:
        if p not in body and 0 <= p[0] < W and 0 <= p[1] < H: px[p] = INK
    for p in ink_over:   # base pixels that must be hidden (e.g. old clog peeking past the new boot)
        if p not in m: px[p] = INK
    return px

def to_cell(px):
    im = Image.new('RGBA', (W, H), (0, 0, 0, 0)); d = im.load()
    for (x, y), c in px.items():
        if 0 <= x < W and 0 <= y < H: d[x, y] = tuple(int(c[i:i + 2], 16) for i in (1, 3, 5)) + (255,)
    return im

# ================================================================ FLOOD BOOTS
def welly(px, x, dy, side=False, far=False, patch=False):
    """one tall waxed boot; x = clog centre as in gnome-dir (side: toe to the right)."""
    if side:
        foot = ellipse(x + 0.5, 68 + dy, 4, 2)
        shaft = rect(floor(x - 3 + .5), 57 + dy, floor(x + 1 + .5), 67 + dy)
        cuff = rect(floor(x - 4 + .5), 64 + dy, floor(x + 2 + .5), 65 + dy)
    else:
        foot = ellipse(x, 68 + dy, 4, 2)
        shaft = rect(floor(x - 3 + .5), 57 + dy, floor(x + 3 + .5), 67 + dy)
        cuff = rect(floor(x - 4 + .5), 64 + dy, floor(x + 4 + .5), 65 + dy)
    body = foot | shaft
    frac = 0.55 if far else 0.36
    form(px, body, WELLY, frac=frac, off=1, keys=('hi', 'base', 'sh', 'dp'))
    # waxed shine: a lit stripe down the left of the shaft and a specular on the toe
    sx = min(p[0] for p in shaft)
    for y in range(66 + dy, 68 + dy): px[(sx + 1, y)] = WELLY['lt']
    fx0 = min(p[0] for p in foot if p[1] == 68 + dy)
    px[(fx0 + 1, 67 + dy)] = WELLY['spec'] if not far else WELLY['hi']
    if not far: px[(fx0 + 2, 67 + dy)] = WELLY['hi']
    # sole: deep row, a second row when lifted
    for p in foot:
        if (p[0], p[1] + 1) not in foot: px[p] = WELLY['dp']
        if dy <= -2 and (p[0], p[1] + 2) not in foot and (p[0], p[1] + 1) in foot and abs(p[0] - x) < 3: px[p] = WELLY['dp']
    # rolled cuff (tan lining turned out): top row lit, lower row base, right end shade, ridge
    x0 = min(p[0] for p in cuff); x1 = max(p[0] for p in cuff)
    for (cx, cy) in cuff:
        c = CUFF['hi'] if cy == 64 + dy else CUFF['base']
        if cx >= x1 - (2 if far else 1): c = CUFF['sh']
        if cx == x0 and cy == 64 + dy: c = CUFF['base']
        px[(cx, cy)] = c
    if patch:   # red rubber repair patch on the shaft
        px[(sx + 3, 66 + dy)] = '#e8493b'; px[(sx + 4, 66 + dy)] = '#b52e3f'
    return body | cuff

def draw_wboots(view, f, p):
    px = {}
    old = base_mask(view, f, ['boots'])
    if view == 'side':
        far = welly(px, 31 + p.get('fx', -2), p.get('fl', 0), side=True, far=True)
        near_px = {}
        near = welly(near_px, 33 + p.get('nx', 2), p.get('nl', 0), side=True, patch=True)
        # near boot over far boot: a deep seam where they touch
        for q in near:
            if any((q[0] + dx, q[1] + dy) in far and (q[0] + dx, q[1] + dy) not in near for dx, dy in N4) and near_px[q] not in (CUFF['hi'], CUFF['base'], CUFF['sh']):
                near_px[q] = WELLY['dp']
        px.update(near_px)
    else:
        welly(px, 27, p.get('ly', 0), patch=(view == 'front'))
        welly(px, 37.5, p.get('ry', 0))
    return finish(px, view, f, WELLY['dp'], ink_over=old)

# ================================================================ WORK GLOVES
def glove(px, hx, hy, thumb, fr=0.35, patch=False, back=False):
    hand = ellipse(hx, hy, 2.5, 2)
    if thumb: hand.add((hx + thumb * 3, hy))
    hx0 = floor(hx)
    cuffy = floor(hy) - 3
    cuff = rect(floor(hx - 3 + .5), cuffy, floor(hx + 3 + .5), cuffy + 1)
    form(px, hand, LEATHER, frac=fr, off=1, keys=('hi', 'base', 'sh', 'dp'))
    xs = sorted({q[0] for q in hand});
    # knuckle row hint + light top-left
    for q in hand:
        if q[1] == floor(hy) + 1 and px[q] == LEATHER['base'] and not back: px[q] = LEATHER['lt']
    c0 = min(q[0] for q in cuff); c1 = max(q[0] for q in cuff)
    for (cx, cy) in cuff:
        c = LEATHER['sh'] if cy == cuffy + 1 else LEATHER['lt']
        if cx == c1: c = LEATHER['dp'] if cy == cuffy + 1 else LEATHER['sh']
        if cx == c0 and cy == cuffy: c = LEATHER['hi']
        px[(cx, cy)] = c
    for cx in range(c0 + 1, c1, 2): px[(cx, cuffy + 1)] = LEATHER['hi']   # stitched cuff: cream-tan dashes
    if patch:
        px[(hx0, floor(hy))] = STRAP['sh']; px[(hx0 + 1, floor(hy))] = STRAP['sh']
    return hand | cuff

def draw_gloves(view, f, p):
    px = {}
    b = -p.get('bob', 0)
    if view == 'side':
        ad = p.get('arm', 0)
        glove(px, 31 + ad, 57.5 + b, 1, fr=0.4, patch=True)
    else:
        la, ra = p.get('arm', 0), -p.get('arm', 0)
        bk = view == 'back'
        glove(px, 20, 57 + b + la, 0 if bk else 1, fr=0.3, patch=not bk, back=bk)
        glove(px, 45, 57 + b + ra, 0 if bk else -1, fr=0.5, patch=bk, back=bk)
    return finish(px, view, f, LEATHER['dp'])

# ================================================================ TRAVEL CLOAK
def cloak_shade(px, m, frac=0.3):
    rows = {}
    for x, y in m:
        a = rows.setdefault(y, [x, x]); a[0] = min(a[0], x); a[1] = max(a[1], x)
    for x, y in m:
        t = rows[y]; u = (x - t[0] + .5) / (t[1] - t[0] + 1)
        c = MOSS['base']
        if u < 0.22: c = MOSS['lt']
        if u > 1 - frac: c = MOSS['sh']
        if (x, y + 1) not in m: c = MOSS['dp']
        px[(x, y)] = c

def draw_cape(view, f, p):
    px = {}
    b = -p.get('bob', 0); s = SWAY[f]
    if view == 'back':
        la, ra = p.get('arm', 0), -p.get('arm', 0)
        m = poly([(21, 45 + b), (44, 45 + b), (46 + s, 66 + b), (19 + s, 66 + b)])
        m |= ellipse(32.5 + s, 66 + b, 11, 1)   # rounded hem bottom
        m -= ellipse(20, 52 + b + la, 3, 4.5); m -= ellipse(45, 52 + b + ra, 3, 4.5)
        m = {q for q in m if q[1] <= 66 + b}
        cloak_shade(px, m, 0.3)
        # two soft folds swinging with the hem
        for fx, top in ((28, 53), (37, 51)):
            for y in range(top + b, 66 + b):
                x = fx + (s if y > 59 + b else 0)
                if (x, y) in m and (x, y + 1) in m: px[(x, y)] = MOSS['sh'];
                if (x - 1, y) in m and (x - 1, y + 1) in m and y > top + b + 1: px[(x - 1, y)] = MOSS['lt'] if x < 33 else MOSS['base']
        # shoulder light under the scarf + one specular-ish sheen
        for x in range(23, 30):
            if (x, 50 + b) in m: px[(x, 50 + b)] = MOSS['hi']
        # darned patch (quirk): a lighter square with deep corner tacks
        for y in range(56, 59):
            for x in range(23 + s, 26 + s):
                if (x, y + b) in m: px[(x, y + b)] = MOSS['lt']
        for q in ((23 + s, 56), (25 + s, 56), (23 + s, 58), (25 + s, 58)):
            if (q[0], q[1] + b) in m: px[(q[0], q[1] + b)] = MOSS['dp']
    elif view == 'front':
        # behind the body: only the flared sides and the shoulder line peek out
        m = poly([(18, 45 + b), (47, 45 + b), (50 + s, 62 + b), (48 + s, 65 + b), (17 + s, 65 + b), (15 + s, 62 + b)])
        rows = {}
        for x, y in m:
            a = rows.setdefault(y, [x, x]); a[0] = min(a[0], x); a[1] = max(a[1], x)
        for x, y in m:
            t = rows[y]; c = MOSS['sh']
            if x <= t[0] + 1: c = MOSS['lt'] if x == t[0] + 1 else MOSS['base']   # left outer edge catches the light
            if x >= t[1] - 1: c = MOSS['dp']
            if (x, y + 1) not in m: c = MOSS['dp']
            if y >= 63 + b and t[0] + 1 < x < t[1] - 1 and (x, y + 1) in m: c = MOSS['xd']   # inside of the cloak, deep in shadow
            px[(x, y)] = c
        # the hem shows the lighter inner lining on the left
        for y in range(58 + b, 66 + b):
            q = (rows[y][0] + 2, y) if y in rows else None
            if q and q in m: px[q] = MOSS['base']
    else:  # side: a drape hanging behind, the near arm swings in front of it
        t = p.get('tail', 0)
        ad = p.get('arm', 0)
        m = poly([(22, 44 + b), (30, 45 + b), (29, 55 + b), (28 + t, 66 + b), (14 + t, 65 + b), (16 + t, 57 + b), (19, 48 + b)])
        sleeve = line([(31, 48 + b), (31 + ad // 2, 52 + b), (31 + ad, 55 + b)], 5)
        m -= sleeve; m -= ellipse(31 + ad, 57.5 + b, 2.5, 2)
        rows = {}
        for x, y in m:
            a = rows.setdefault(y, [x, x]); a[0] = min(a[0], x); a[1] = max(a[1], x)
        for x, y in m:
            r = rows[y]; u = (x - r[0] + .5) / (r[1] - r[0] + 1)
            c = MOSS['base']
            if u < 0.25: c = MOSS['lt']
            if u > 0.7: c = MOSS['sh']
            if (x, y + 1) not in m: c = MOSS['dp']
            px[(x, y)] = c
        # folds: diagonal lines toward the trailing hem
        for k, (x0, y0) in enumerate(((22, 52), (25, 55))):
            for i in range(9):
                q = (x0 - (i * (2 + t * (1 if k else 0))) // 6 + (t if i > 5 else 0), y0 + i + b)
                if q in m and (q[0], q[1] + 1) in m: px[q] = MOSS['sh']
        for x in range(19, 25):
            if (x, 49 + b) in m and (x, 48 + b) in m: px[(x, 49 + b)] = MOSS['hi']
        # wooden toggle at the shoulder (quirk), on a short cord
        tx, ty = 26, 50 + b
        px[(tx + 1, ty - 1)] = TOGGLE['sh']
        for q, c in (((tx, ty), TOGGLE['hi']), ((tx + 1, ty), TOGGLE['base']), ((tx, ty + 1), TOGGLE['base']), ((tx + 1, ty + 1), TOGGLE['sh']), ((tx, ty + 2), TOGGLE['dp']), ((tx + 1, ty + 2), TOGGLE['dp'])):
            px[q] = c
    return finish(px, view, f, MOSS['dp'])

# ================================================================ WAYFARER'S HAT (brim + band + feather)
def draw_brim(view, f, p):
    px = {}
    b = -p.get('bob', 0)
    hat = base_mask(view, f, ['hat'])
    cx, cy = 32.5, 33.5 + b
    brim = ellipse(cx, cy, 17.5, 3.5)
    def front_curve(x): return cy - 0.5 + 2.5 * math.sqrt(max(0.0, 1 - ((x - cx) / 10.5) ** 2))
    vis = set()
    for (x, y) in brim:
        if abs(x + .5 - cx - .5) <= 10.5 and y < front_curve(x) and (x, y) in hat: continue   # behind the cone
        vis.add((x, y))
    for (x, y) in hat:   # the hat's own scalloped edge must not peek out under the felt brim
        if y >= cy and (x, y) not in vis: vis.add((x, y)); brim.add((x, y))
    for (x, y) in vis:
        top = (x, y - 1) not in brim
        bot = (x, y + 1) not in brim
        u = (x - 14.5) / 36.0
        c = FELT['base']
        if u < 0.3: c = FELT['lt']
        if u > 0.72: c = FELT['sh']
        if top and u < 0.62: c = FELT['hi'] if u < 0.4 else FELT['lt']
        if bot: c = FELT['dp']
        if (x, y + 2) not in brim and not bot and y > cy: c = FELT['sh'] if u < 0.6 else FELT['dp']   # turned-down front rim
        px[(x, y)] = c
    # band: two rows on the cone just above where it meets the brim
    band = set()
    for x in range(22, 44):
        yb = floor(front_curve(x) + .5)
        for y in (yb - 1, yb - 2):
            if (x, y) in hat and (x, y) not in vis: band.add((x, y))
    for (x, y) in band:
        c = BAND['base']
        if (x, y - 1) not in band: c = BAND['hi'] if x < 30 else BAND['base']
        if (x, y + 1) not in band or x > 39: c = BAND['dp']
        px[(x, y)] = c
    # feather tucked in the band (quirk); front: viewer's left, back: viewer's right, side: toward the back
    bx = {'front': 23, 'back': 42, 'side': 24}[view]
    d = -1 if view in ('front', 'side') else 1
    by = floor(front_curve(bx) + .5) - 2
    lean = (p.get('hb', 0) if view != 'front' else -p.get('hb', 0)) * d   # the plume tip lags like the hat tip
    WID = [0, 0, 1, 1, 2, 2, 2, 2, 1, 1, 0]
    for t in range(len(WID)):
        c0 = bx + d * (t * 0.35 + 0.03 * t * t) + (lean * d if t >= 8 and lean > 0 else 0)
        qx, y = floor(c0 + .5), by - t
        for k in range(-WID[t], WID[t] + 1):
            x = qx + k
            lit = (k < 0)                                  # light from the upper left
            c = FEATHER['hi'] if lit and k == -1 else FEATHER['lt'] if lit else FEATHER['base'] if k <= 1 else FEATHER['sh']
            if k == 0: c = FEATHER['sh'] if t < 7 else FEATHER['lt']   # quill
            if t in (5, 8) and k != 0: c = FEATHER['dp'] if k > 0 else FEATHER['sh']   # barred like a pheasant plume
            px[(x, y)] = c
        if t < 2: px[(qx, y)] = FEATHER['dp']
    return finish(px, view, f, FELT['dp'])

# ================================================================ TRAIL PACK
def blanket(px, m, stripes):
    rows = {}
    for x, y in m:
        a = rows.setdefault(y, [x, x]); a[0] = min(a[0], x); a[1] = max(a[1], x)
    ys = sorted({q[1] for q in m}); y0, y1 = ys[0], ys[-1]
    for x, y in m:
        c = BLANKET['base']
        if y == y0 or (x, y - 1) not in m: c = BLANKET['hi']
        if y >= y1 - 1: c = BLANKET['sh']
        if (x, y + 1) not in m: c = BLANKET['dp']
        if x in stripes: c = BLANKET['st'] if y < y1 - 1 else CANVAS['lt']
        px[(x, y)] = c

def canvas_body(px, m, frac=0.3):
    rows = {}
    for x, y in m:
        a = rows.setdefault(y, [x, x]); a[0] = min(a[0], x); a[1] = max(a[1], x)
    for x, y in m:
        t = rows[y]; u = (x - t[0] + .5) / (t[1] - t[0] + 1)
        c = CANVAS['base']
        if u < 0.2: c = CANVAS['lt']
        if u > 1 - frac: c = CANVAS['sh']
        if (x, y + 1) not in m: c = CANVAS['dp']
        px[(x, y)] = c

def draw_pack(view, f, p):
    px = {}
    b = -p.get('bob', 0); s = SWAY[f]
    if view == 'back':
        x0, x1 = 26 + s, 39 + s
        bag = rrect(x0, 48 + b, x1, 58 + b, 3)
        canvas_body(px, bag, 0.3)
        # leather flap with a curved lower edge
        flap = {(x, y) for (x, y) in bag if y <= 51 + b + (1 if x0 + 3 <= x <= x1 - 3 else 0)}
        for (x, y) in flap:
            c = STRAP['base']
            if x < x0 + 4 or (x, y - 1) not in flap: c = STRAP['hi']
            if x > x1 - 3: c = STRAP['sh']
            if (x, y + 1) not in flap: c = STRAP['dp']
            px[(x, y)] = c
        # two little straps with brass buckles
        for sx in (x0 + 3, x1 - 3):
            for y in range(52 + b, 56 + b):
                if (sx, y) in bag and (sx, y) not in flap: px[(sx, y)] = STRAP['base'] if sx < x1 - 3 else STRAP['sh']
            px[(sx, 54 + b)] = BUCKLE['hi'] if sx < x1 - 3 else BUCKLE['base']
        # sky-blue patch (quirk), bottom middle, with two tack stitches
        for q in ((31 + s, 55 + b), (32 + s, 55 + b), (33 + s, 55 + b), (31 + s, 56 + b), (32 + s, 56 + b), (33 + s, 56 + b)):
            px[q] = PATCH['base']
        px[(33 + s, 56 + b)] = PATCH['sh']; px[(31 + s, 55 + b)] = '#e4f6ff'
        # rolled blanket under the pack, tied with two leather straps
        roll = rrect(23 + s, 58 + b, 42 + s, 62 + b, 2)
        blanket(px, roll, {30 + s, 35 + s})
        for x in (26 + s, 39 + s):
            for y in range(58 + b, 63 + b):
                if (x, y) in roll: px[(x, y)] = STRAP['base'] if y < 62 + b else STRAP['dp']
        for y in range(59 + b, 62 + b): px[(23 + s, y)] = BLANKET['sh']
        px[(24 + s, 60 + b)] = BLANKET['st']   # the roll's spiral end
    elif view == 'front':
        # behind the body: only the pack's top corners peek over the shoulders, with the strap tops
        bag = rrect(18 + s, 44 + b, 47 + s, 57 + b, 3)
        canvas_body(px, bag, 0.3)
        for (x, y) in bag:
            if y == 44 + b: px[(x, y)] = STRAP['hi'] if x < 32 else STRAP['base']   # flap edge over the top
            if y == 45 + b: px[(x, y)] = STRAP['base'] if x < 32 else STRAP['sh']
    else:  # side: the pack on the back (left), roll end below, strap over the shoulder
        t = p.get('tail', 0); ad = p.get('arm', 0)
        sx = t   # pack swings a pixel behind
        bag = rrect(14 + sx, 47 + b, 25, 58 + b, 4)
        canvas_body(px, bag, 0.15)
        for (x, y) in bag:     # leather flap over the top, curved edge
            if y <= 50 + b + (1 if x <= 19 + sx else 0):
                c = STRAP['base'] if x > 16 + sx else STRAP['hi']
                if (x, y - 1) not in bag: c = STRAP['hi']
                if y == 50 + b + (1 if x <= 19 + sx else 0): c = STRAP['dp']
                px[(x, y)] = c
        px[(17 + sx, 52 + b)] = STRAP['base']; px[(17 + sx, 53 + b)] = BUCKLE['hi']
        pocket = rrect(14 + sx, 54 + b, 18 + sx, 58 + b, 1)
        for (x, y) in pocket:
            c = CANVAS['lt'] if x < 17 + sx else CANVAS['base']
            if (x, y + 1) not in pocket: c = CANVAS['dp']
            elif x == 18 + sx: c = CANVAS['sh']
            if y == 54 + b: c = CANVAS['hi'] if x < 17 + sx else CANVAS['lt']
            px[(x, y)] = c
        for q, c in (((21 + sx, 53 + b), PATCH['base']), ((22 + sx, 53 + b), PATCH['base']), ((21 + sx, 54 + b), PATCH['base']), ((22 + sx, 54 + b), PATCH['sh'])):
            px[q] = c
        roll = ellipse(19.5 + sx, 61 + b, 3, 2)
        for (x, y) in roll:
            c = BLANKET['base']
            if (x, y - 1) not in roll or (x - 1, y) not in roll: c = BLANKET['hi']
            if (x + 1, y) not in roll or (x, y + 1) not in roll: c = BLANKET['dp']
            px[(x, y)] = c
        cxr = floor(19.5 + sx)
        px[(cxr, 61 + b)] = BLANKET['dp']; px[(cxr + 1, 61 + b)] = BLANKET['sh']; px[(cxr - 1, 61 + b)] = BLANKET['sh']; px[(cxr - 1, 60 + b)] = BLANKET['sh']   # rolled-up spiral, not a flower
        # strap: shoulder down behind the arm
        strap = line([(29, 48 + b), (27, 53 + b), (25, 57 + b)], 2)
        strap -= line([(31, 48 + b), (31 + ad // 2, 52 + b), (31 + ad, 55 + b)], 5)
        strap -= ellipse(31 + ad, 57.5 + b, 2.5, 2)
        for q in strap: px[q] = STRAP['base'] if q[0] % 2 == 0 else STRAP['sh']
    return finish(px, view, f, CANVAS['dp'])

LAYERS = {'wboots': draw_wboots, 'gloves': draw_gloves, 'cape': draw_cape, 'brim': draw_brim, 'pack': draw_pack}

def build(view, layer):
    strip = Image.new('RGBA', (W * N, H), (0, 0, 0, 0))
    for f, p in enumerate(FRAMES[view]):
        strip.paste(to_cell(LAYERS[layer](view, f, p)), (f * W, 0))
    return strip

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    only = sys.argv[2:] or list(LAYERS)
    for view in ('front', 'back', 'side'):
        for layer in only:
            build(view, layer).save(os.path.join(OUT, f'{view}-{layer}.png'))
    print('gnome-wear:', ', '.join(only), '->', OUT)
