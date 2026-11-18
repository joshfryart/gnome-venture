"""Birchbramble Steppe (EE): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/EE/common.lua
(C.R.*) and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- region ramps (common.lua)
birch = ["#4a4048", "#6e6466", "#9a8e88", "#c2b8a8", "#ddd4c0", "#f2ecd8"]
linen = ["#6a5a5a", "#8e8078", "#b2a696", "#d0c6b0", "#e6dec8", "#f6f0dc"]
fgrey = ["#34303e", "#4e4a58", "#6a6672", "#878290", "#a6a0aa", "#c6c0c4"]
straw = ["#5e3e1e", "#86602a", "#ae8836", "#cead4e", "#e6cc6e", "#f6e6a2"]
wicker = ["#4e2a1c", "#723e22", "#98582c", "#bc7838", "#d89a4c", "#eec070"]
fleece = ["#6a5650", "#8e7a6c", "#b0a08a", "#ccbea2", "#e2d8bc", "#f4eed8"]
plum = ["#2a1a32", "#3e2646", "#55345a", "#6c4670", "#865c86", "#a87aa2"]
redl = ["#4e1a22", "#741f2a", "#9a2c30", "#b8443a", "#d0604a", "#e88a64"]
storm = ["#262e46", "#36425e", "#4a5a78", "#627692", "#8496ae", "#b0c2d4"]
leaf = ["#1e3a2a", "#2a5634", "#3a7440", "#4f924a", "#72b05a", "#a8d27c"]
# ---- shared ramps (_gw.lua W.R)
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
ember = ["#5e1c33", "#8a2a3d", "#b52e3f", "#d23c3c", "#e8573f", "#ff8a5c"]
jay = ["#1e2f63", "#28488e", "#3364b4", "#4688d2", "#6cb0e6", "#bfe6f6"]
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
cloakg = ["#1c3530", "#264a3c", "#335f43", "#45784b", "#5e9452", "#86b464"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
canvas = ["#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
yarnA = ["#5c1f2e", "#842a36", "#a8383a", "#c64e40", "#dc6a4a", "#f08e62"]
yarnB = ["#1d4048", "#285e62", "#357c78", "#46998c", "#68b8a2", "#a2dcc0"]
autumn = ["#6e2a1c", "#a8401e", "#d8602a", "#ee8434", "#f8a848", "#ffd27a"]
# skin tones of the default gnome (rig.DEFAULT skin) as a 6-ramp, for the bare toes in the sandals
toes = ["#51302b", "#a8644c", "#c98462", "#f0b98d", "#ffe0bd", "#fff0dc"]


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def _paint(c, m, fn):
    """recolour the pixels of mask m already on the canvas (not ink) with fn(q, old) -> colour or None"""
    for q in m:
        old = c.get(q)
        if old is None or old == INK: continue
        col = fn(q, old)
        if col: c.put(q[0], q[1], col)


# ======================================================================== FOOTWEAR
def _birchweave(c, g, ft, k):
    v, top, cy, cx = g['view'], g['top'], int(ft['cy']), int(ft['cx'])
    # diagonal plait of bark strips over the boat-shaped shoe
    _paint(c, M(q for q in g['foot'] if q[1] < cy + 2 and q[1] >= cy - 1),
           lambda q, o: birch[2] if (q[0] + q[1]) % 3 == 0 else (birch[5] if (q[0] - q[1]) % 3 == 0 and o != birch[2] else None))
    # bark rim of the shoe (top of the boat)
    for q in g['foot'].top():
        if q[1] >= cy - 2 and q not in g['shaft']: c.put(q[0], q[1], birch[4])
    for x in range(g['sx0'], g['sx1'] + 1): c.put(x, cy - 2, birch[1] if x % 2 else birch[2])
    # linen foot-wrap with crossed cords
    _paint(c, M(q for q in g['shaft'] if q[1] < cy - 2), lambda q, o: strap[2] if (q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0 else None)
    if v == 'front' and k == 0:   # cord ends trailing on the outer side
        P(c, [(g['sx0'] - 1, top + 2), (g['sx0'] - 1, top + 3), (g['sx0'] - 2, top + 4)], strap[2])
    if v == 'side' and not g['far']:
        P(c, [(g['sx0'] - 1, top + 2), (g['sx0'] - 2, top + 3)], strap[2])
    # quirk: a green birch leaf caught in the lattice
    if k == 1 and v != 'back':
        lx = cx + (1 if v == 'front' else 3)
        P(c, [(lx, cy), (lx + 1, cy - 1)], leaf[4]); c.put(lx + 1, cy, leaf[2])


def _felt(c, g, ft, k):
    v, top, cy, cx = g['view'], g['top'], int(ft['cy']), int(ft['cx'])
    x0, x1 = g['sx0'], g['sx1']
    # pressed-felt mottling
    _paint(c, g['foot'] | g['shaft'], lambda q, o: (fgrey[2] if o in (fgrey[3], fgrey[4]) else None) if (q[0] * 7 + q[1] * 5) % 11 == 0 else None)
    # soft top edge, a tone lighter
    for x in range(x0, x1 + 1): c.put(x, top, fgrey[5] if x < x1 - 1 else fgrey[4])
    # stitched leather heel patch
    if v == 'back':
        for q in rect(x0 + 2, cy - 2, x1 - 2, cy): c.put(q[0], q[1], leather[3] if q[1] < cy else leather[2])
        P(c, [(x0 + 2, cy - 2), (x1 - 2, cy - 2)], leather[5])
    elif v == 'side':
        for q in rect(x0, cy - 2, x0 + 1, cy + 1): c.put(q[0], q[1], leather[3] if q[0] == x0 + 1 else leather[2])
        c.put(x0 + 1, cy - 2, leather[5])
    # quirk: red wool pompom on the front cuff
    if v == 'front':
        mx = (x0 + x1) // 2
        P(c, [(mx, top + 2)], ember[5]); P(c, [(mx + 1, top + 2), (mx, top + 3), (mx - 1, top + 2)], ember[4]); P(c, [(mx + 1, top + 3), (mx, top + 4)], ember[2])
    elif v == 'side' and not g['far']:
        P(c, [(x1, top + 1)], ember[5]); P(c, [(x1 + 1, top + 1), (x1, top + 2)], ember[3]); c.put(x1 + 1, top + 2, ember[1])


def _moccasin(c, g, ft, k):
    v, top, cy, cx = g['view'], g['top'], int(ft['cy']), int(ft['cx'])
    x0, x1 = g['sx0'], g['sx1']
    # gathered ankle: puckers + thong lace
    for x in range(x0, x1 + 1):
        c.put(x, top, strap[1] if x % 2 else strap[3])
        if x % 2 == 0: c.put(x, top + 1, leather[2])
    foot = g['foot']
    if v == 'side':   # toe turned up to a point
        tx = max(q[0] for q in foot)
        P(c, [(tx, cy - 2), (tx + 1, cy - 2)], leather[4]); c.put(tx + 1, cy - 3, leather[5]); c.put(tx, cy - 1, leather[3])
        for xx in range(cx, tx): c.put(xx, cy - 1, leather[2] if xx % 2 else leather[3])   # vamp seam
    elif v == 'front':
        P(c, [(cx, cy - 1), (cx, cy)], leather[2]); c.put(cx, cy - 2, leather[5])   # vamp seam + toe tip
    # quirk: a red poppy tucked into the ankle lace
    if (v == 'front' and k == 1) or (v == 'side' and not g['far']):
        px = x1 - 1 if v == 'front' else x1
        P(c, [(px, top - 1), (px + 1, top)], ember[4]); P(c, [(px, top), (px + 1, top - 1)], ember[3]); c.put(px, top, sole[0])
        c.put(px - 1, top, leaf[3])


def _rider(c, g, ft, k):
    v, top, cy, cx = g['view'], g['top'], int(ft['cy']), int(ft['cx'])
    x0, x1 = g['sx0'], g['sx1']
    for x in range(x0, x1 + 1): c.put(x, top + 2, redl[0])   # fold line under the turned-down top
    glint = brass[5] if g['f'] % 3 == 0 else brass[4]
    if v == 'side':
        tx = max(q[0] for q in g['foot'])
        c.put(tx, cy - 1, redl[5])
        # stacked wooden heel + brass horseshoe plate
        for q in rect(x0, cy + 1, x0 + 1, cy + 2): c.put(q[0], q[1], wood[3] if q[1] == cy + 1 else wood[2])
        P(c, [(x0, cy + 3), (x0 + 1, cy + 3)], brass[2]); c.put(x0, cy + 3, glint)
        for y in range(top + 4, cy - 2): c.put(x1, y, redl[2])   # seam
    elif v == 'back':
        for x in range(x0 + 1, x1): c.put(x, cy + 1, wood[3])
        P(c, [(x0 + 1, cy + 2), (x1 - 1, cy + 2)], brass[3]); P(c, [(cx, cy + 2)], glint); c.put(cx - 1 if k == 0 else cx + 1, cy + 2, brass[2])
        for y in range(top + 4, cy - 1): c.put(cx, y, redl[2])   # back seam
    else:
        c.put(cx - 1, cy - 1, redl[5])


def _sandal(c, g, ft, k):
    v, cy, cx = g['view'], int(ft['cy']), int(ft['cx'])
    foot = g['foot']
    x0, _, x1, y1 = foot.bbox()
    # thick plaited straw sole (2 rows, 1 px wider than the foot)
    for y in (y1 - 1, y1):
        for x in range(x0 - 1, x1 + 2):
            if (x, y) in foot or (x, y - 1) in foot or (x - 1, y) in foot or (x + 1, y) in foot:
                c.put(x, y, straw[1] if y == y1 else (straw[4] if (x // 2 + y) % 2 else straw[3]))
    # toe ticks (front)
    if v == 'front':
        for x in range(cx - 2, cx + 3, 2): c.put(x, y1 - 2, toes[2])
    # two crossed leather straps
    if v == 'side':
        tx = x1
        for i in range(4):
            c.put(cx - 2 + i, cy - 2 + i if cy - 2 + i < y1 - 1 else y1 - 2, strap[3] if i % 2 else strap[2])
            c.put(cx + 2 - i, cy - 2 + i if cy - 2 + i < y1 - 1 else y1 - 2, strap[2])
        for y in range(cy - 4, cy - 1): c.put(cx - 2, y, strap[2])   # ankle strap rising
    else:
        for i in range(4):
            yy = min(cy - 2 + i, y1 - 2)
            c.put(cx - 2 + i, yy, strap[3]); c.put(cx + 1 - i, yy, strap[2])
        for x in range(x0, x1 + 1): c.put(x, cy - 3, strap[2] if x % 2 else strap[3])   # ankle tie
    # quirk: sunflower-seed charm on the toe strap
    if (v == 'front' and k == 1) or (v == 'side' and not g['far']):
        sx = (x1 + 1) if v == 'front' else (cx + 3)
        sy = cy - 2 if v == 'front' else cy - 3
        c.put(sx, sy, strap[1]); P(c, [(sx, sy + 1), (sx + 1, sy + 1)], sole[0]); c.put(sx, sy + 2, birch[4]); c.put(sx + 1, sy + 2, sole[1])


FOOT = [
    dict(slug='ee-birchweave-shoes', cat='footwear', shell=birch, upper=linen, sole=birch[0], rim=62, half=4, toe=1, detail=_birchweave),
    dict(slug='ee-snowdrift-felt-boots', cat='footwear', shell=fgrey, upper=fgrey, sole=fgrey[0], rim=59, half=4, puff=0.5, detail=_felt),
    dict(slug='ee-poppy-hide-moccasins', cat='footwear', shell=leather, upper=leather, sole=leather[1], rim=64, half=4, toe=2, detail=_moccasin),
    dict(slug='ee-riders-red-boots', cat='footwear', shell=redl, upper=redl, sole=wood[1], rim=58, half=3, toe=1,
         cuff=redl[1:] + ["#f4a880"], cuff_rows=2, detail=_rider),
    dict(slug='ee-sunflower-straw-sandals', cat='footwear', shell=toes, upper=toes, sole=straw[1], rim=None, detail=_sandal),
]


# ======================================================================== BACKPACK
def _shade_right(c, m, r, n=2):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if q[0] > x1 - n: c.put(q[0], q[1], r[2] if c.get(q) not in (r[1], r[0]) else r[0])
        if q[1] == y1: c.put(q[0], q[1], r[1])


def _bark_check(c, m, ox, oy):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        gx, gy = (q[0] - ox) % 3, (q[1] - oy) % 3
        if gx == 2 or gy == 2: col = birch[2]
        else: col = birch[5] if (gx == 0 and gy == 0) else birch[4]
        if q[0] > x1 - 2: col = birch[1] if col == birch[2] else birch[2]
        c.put(q[0], q[1], col)


def _mushroom(c, mx, my):
    cap = ellipse(mx, my, 2.5, 1.2)
    form(c, cap, ember, frac=0.35)
    P(c, [(mx - 1, my - 1), (mx + 1, my)], linen[5])
    P(c, [(mx, my + 2), (mx, my + 3)], linen[4]); c.put(mx + 1, my + 2, linen[2])


def pester_back(c, x, y, g):
    body = rect(x - 7, y + 1, x + 6, y + 17)
    _bark_check(c, body, x, y)
    for xx in range(x - 7, x + 7):   # wooden base band
        c.put(xx, y + 16, wood[3] if xx < x + 4 else wood[2]); c.put(xx, y + 17, wood[1])
    form(c, rect(x - 8, y - 1, x + 7, y), linen, frac=0.3)   # cream lid
    for xx in range(x - 8, x + 8): c.put(xx, y + 1, wood[2] if xx < x + 5 else wood[1])   # lid band
    form(c, rect(x - 1, y - 3, x, y - 2), wood, frac=0.5)   # lid peg
    for sx in (x - 5, x + 4): P(c, [(sx, y - 2), (sx, y - 3)], strap[2])   # straps over the shoulders
    _mushroom(c, x - 8, y - 1)


def pester_side(c, x, y, g):
    body = rect(x - 9, y + 1, x - 1, y + 17)
    _bark_check(c, body, x, y)
    for xx in range(x - 9, x): c.put(xx, y + 16, wood[3]); c.put(xx, y + 17, wood[1])
    form(c, rect(x - 10, y - 1, x, y), linen, frac=0.3)
    for xx in range(x - 10, x + 1): c.put(xx, y + 1, wood[2])
    form(c, rect(x - 6, y - 3, x - 5, y - 2), wood, frac=0.5)
    P(c, [(x, y + 2), (x + 1, y + 3), (x + 1, y + 6)], strap[2])
    _mushroom(c, x - 10, y - 1)


def _sunflower(c, fx, fy):
    for q in ellipse(fx, fy, 2.8, 2.8): c.put(q[0], q[1], brass[4] if (q[0] + q[1]) % 2 else brass[3])
    for q in ellipse(fx, fy, 1.4, 1.4): c.put(q[0], q[1], wood[1] if (q[0] + q[1]) % 2 else wood[0])
    c.put(int(fx) - 1, int(fy) - 1, wood[3])


def basket_back(c, x, y, g):
    m = poly([(x - 11, y + 1), (x + 10, y + 1), (x + 7, y + 15), (x - 8, y + 15)])
    for q in m:   # horizontal ribs over upright stakes
        col = wicker[4] if (q[1] - y) % 2 else wicker[3]
        if (q[0] - x) % 3 == 0 and (q[1] - y) % 2 == 0: col = wicker[2]
        c.put(q[0], q[1], col)
    _shade_right(c, m, wicker, 3)
    form(c, rect(x - 12, y - 1, x + 11, y), wicker, frac=0.3)   # thick rim
    for xx in range(x - 12, x + 12, 2): c.put(xx, y, wicker[2])
    for sx in (-1, 1):   # rope loops at the sides
        bx = x - 13 if sx < 0 else x + 12
        P(c, [(bx, y + 1), (bx + sx * 0, y + 2), (bx - sx, y + 3), (bx - sx, y + 4)], canvas[4])
    P(c, [(x + 3, y - 2), (x + 4, y - 3), (x + 4, y - 4), (x + 5, y - 5)], straw[3])   # wheat stalks
    P(c, [(x + 5, y - 6), (x + 5, y - 7), (x + 6, y - 6)], straw[5])
    _sunflower(c, x - 4, y - 3)
    P(c, [(x - 8, y - 1), (x - 7, y - 2)], leaf[4])


def basket_side(c, x, y, g):
    m = poly([(x - 11, y + 1), (x, y + 1), (x, y + 15), (x - 7, y + 15)])
    for q in m:
        col = wicker[4] if (q[1] - y) % 2 else wicker[3]
        if (q[0] - x) % 3 == 0 and (q[1] - y) % 2 == 0: col = wicker[2]
        c.put(q[0], q[1], col)
    _shade_right(c, m, wicker, 2)
    form(c, rect(x - 12, y - 1, x, y), wicker, frac=0.3)
    P(c, [(x + 1, y + 1), (x + 1, y + 2), (x + 1, y + 5)], canvas[4])
    _sunflower(c, x - 7, y - 3)
    P(c, [(x - 3, y - 2), (x - 3, y - 4), (x - 2, y - 5)], straw[3]); c.put(x - 2, y - 6, straw[5])


_BEE = [(0, 0), (1, -1), (2, 0), (1, 1), (0, 0), (-1, -1), (0, 1), (1, 0)]


def _skep(c, cx, cy, rx, ry, flat):
    m = M(q for q in ellipse(cx, cy, rx, ry) if q[1] <= flat)
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        col = straw[4] if (q[1] - y0) % 2 == 0 else straw[3]
        if q[0] > x1 - (x1 - x0 + 1) * 0.3: col = straw[2] if col == straw[3] else straw[3]
        if q[1] == y1: col = straw[1]
        c.put(q[0], q[1], col)
    P(c, [(x0 + 2, y0 + 1), (x0 + 1, y0 + 2)], straw[5])
    return m


def frame_back(c, x, y, g):
    for lx, d in ((x - 4, -1), (x + 3, 1)):   # A-frame rails
        rail = line([(lx, y - 6), (lx + d * 6, y + 18)], 2)
        form(c, rail, wood, frac=0.5, under=False)
    form(c, rect(x - 4, y - 4, x + 3, y - 3), wood, frac=0.3)
    form(c, rect(x - 10, y + 15, x + 9, y + 16), wood, frac=0.2)
    _skep(c, x - 0.5, y + 8, 7, 7, y + 14)
    # cloth tied over the hole + its tie
    form(c, rect(x - 2, y + 11, x + 1, y + 14), canvas, frac=0.3, under=False)
    for q in line([(x - 6, y + 4), (x + 6, y + 10)]): c.put(q[0], q[1], strap[2]) if q in c and c[q] in straw else None
    bx, by = _BEE[g['f'] - 1]
    P(c, [(x - 11 - bx, y + 5 + by)], brass[4]); c.put(x - 12 - bx, y + 5 + by, strap[0]); c.put(x - 11 - bx, y + 4 + by, steel_wing)


steel_wing = "#e4ecf2"


def frame_side(c, x, y, g):
    form(c, line([(x - 1, y - 6), (x - 1, y + 18)], 2), wood, frac=0.5, under=False)
    _skep(c, x - 6, y + 8, 5, 7, y + 14)
    form(c, rect(x - 9, y + 15, x, y + 16), wood, frac=0.2)
    form(c, rect(x - 11, y + 11, x - 10, y + 14), canvas, frac=0.3, under=False)
    bx, by = _BEE[g['f'] - 1]
    P(c, [(x - 14 - bx, y + 1 + by)], brass[4]); c.put(x - 15 - bx, y + 1 + by, strap[0]); c.put(x - 14 - bx, y + by, steel_wing)


def _flatweave(c, m, ox):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        ry = q[1] - y0
        col = yarnA[3]
        if ry in (0, y1 - y0): col = yarnA[1]
        elif ry in (6,): col = straw[3]
        else:
            band_c = y0 + 3 if ry < 6 else y0 + 9
            dx = abs((q[0] - ox) % 5 - 2); dy = abs(q[1] - band_c)
            d = dx + dy
            col = yarnB[4] if d == 0 else straw[4] if d == 1 else yarnA[1] if d == 2 else yarnA[3]
        if q[0] == x1 and col == yarnA[3]: col = yarnA[2]
        c.put(q[0], q[1], col)


def satchel_back(c, x, y, g):
    m = rect(x - 8, y + 1, x + 7, y + 13)
    _flatweave(c, m, x - 8)
    for q in line([(x - 6, y + 1), (x - 4, y - 2), (x + 3, y - 2), (x + 5, y + 1)]): c.put(q[0], q[1], strap[3])
    for i, xx in enumerate(range(x - 7, x + 8, 2)):   # tassels, one teal among rust
        r = yarnB if xx == x + 1 else yarnA
        P(c, [(xx, y + 14), (xx, y + 15)], r[3]); c.put(xx, y + 16, r[2])


def satchel_side(c, x, y, g):
    m = rect(x - 7, y + 1, x - 1, y + 13)
    _flatweave(c, m, x - 7)
    P(c, [(x - 2, y), (x - 1, y - 1), (x, y - 1), (x + 1, y)], strap[3])
    for xx in (x - 7, x - 5, x - 3, x - 1):
        r = yarnB if xx == x - 3 else yarnA
        P(c, [(xx, y + 14), (xx, y + 15)], r[3]); c.put(xx, y + 16, r[2])


def _fleece_tex(c, m):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        o = c.get(q)
        if (q[0] + 2 * q[1]) % 5 == 0: c.put(q[0], q[1], fleece[2] if o != fleece[4] else fleece[3])
        elif (q[0] * 3 + q[1]) % 7 == 0 and q[0] < x1 - 2: c.put(q[0], q[1], fleece[5])


def drawsack_back(c, x, y, g):
    body = ellipse(x - 0.5, y + 10, 8.5, 7)
    form(c, body, fleece, frac=0.3)
    _fleece_tex(c, body)
    base = M(q for q in body if q[1] >= y + 14)
    form(c, base, leather, frac=0.3, rim=False)
    for q in base.top(): c.put(q[0], q[1], leather[4])
    neck = rect(x - 3, y + 1, x + 2, y + 3)
    for q in neck: c.put(q[0], q[1], fleece[4] if q[0] % 2 else fleece[2])
    for q in rect(x - 4, y - 1, x + 3, y): c.put(q[0], q[1], fleece[5] if q[0] % 2 else fleece[4])
    for xx in range(x - 3, x + 3): c.put(xx, y + 2, strap[2])
    # brass bell on the cord
    P(c, [(x - 4, y + 3), (x - 5, y + 4)], strap[2])
    P(c, [(x - 6, y + 5), (x - 5, y + 5)], brass[4]); P(c, [(x - 6, y + 6)], brass[3]); c.put(x - 5, y + 6, brass[2]); c.put(x - 6, y + 5, brass[5])


def drawsack_side(c, x, y, g):
    body = ellipse(x - 5, y + 10, 5, 7)
    form(c, body, fleece, frac=0.3)
    _fleece_tex(c, body)
    base = M(q for q in body if q[1] >= y + 14)
    form(c, base, leather, frac=0.3, rim=False)
    for q in rect(x - 7, y + 1, x - 3, y + 3): c.put(q[0], q[1], fleece[4] if q[0] % 2 else fleece[2])
    for q in rect(x - 8, y - 1, x - 2, y): c.put(q[0], q[1], fleece[5] if q[0] % 2 else fleece[4])
    for xx in range(x - 7, x - 2): c.put(xx, y + 2, strap[2])
    P(c, [(x - 8, y + 3), (x - 9, y + 4)], strap[2])
    P(c, [(x - 10, y + 5), (x - 9, y + 5)], brass[4]); c.put(x - 10, y + 6, brass[3]); c.put(x - 9, y + 6, brass[2]); c.put(x - 10, y + 5, brass[5])


PACK = [
    dict(slug='ee-birchbark-pester', cat='backpack', back=pester_back, side=pester_side),
    dict(slug='ee-harvest-wicker-basket', cat='backpack', back=basket_back, side=basket_side),
    dict(slug='ee-beekeepers-frame', cat='backpack', back=frame_back, side=frame_side),
    dict(slug='ee-flat-weave-satchel', cat='backpack', back=satchel_back, side=satchel_side),
    dict(slug='ee-fleece-drawsack', cat='backpack', back=drawsack_back, side=drawsack_side),
]


# ======================================================================== COAT
def _trim(c, g, rows, r, sleeves=True, hem=True):
    """fleece/stitch trim: the last `rows` rows of every column of the coat (hem) and of each sleeve (cuffs)."""
    m = M(q for q, col in c.items() if col != INK)
    out = M()
    if hem:
        out |= M(q for q in m if any((q[0], q[1] + k) not in m for k in range(1, rows + 1)) and q[1] >= 60 + g['b'])
    if sleeves:
        for s in g['sleeves']:
            sm = s & m
            out |= M(q for q in sm if any((q[0], q[1] + k) not in sm for k in range(1, rows + 1)))
    for q in out: c.put(q[0], q[1], r(q) if callable(r) else r)
    return out


def _fleece_col(q):
    return fleece[5] if (q[0] + 2 * q[1]) % 3 == 0 else fleece[4] if (q[0] + q[1]) % 2 else fleece[3]


def _longcoat(c, g):
    v, b = g['view'], g['b']
    _trim(c, g, 2, _fleece_col)
    if v == 'front':
        for x0 in (19, 44):   # fleece collar showing at the shoulders beside the beard
            for q in ellipse(x0 + 0.5, 46.5 + b, 2, 1.5): c.put(q[0], q[1], _fleece_col(q))
        for y in (60, 63): P(c, [(32, y + b), (33, y + b)], wood[4]); c.put(33, y + b, wood[2])   # toggles
        P(c, [(41, 55 + b), (42, 54 + b)], ember[4]); P(c, [(42, 55 + b)], brass[4]); P(c, [(43, 55 + b), (42, 56 + b)], ember[3])   # stitched flower
    elif v == 'back':
        for q in rect(24, 46 + b, 41, 48 + b): c.put(q[0], q[1], _fleece_col(q))
        for y in range(56, 66): c.put(32 + (g['hem'] if y > 62 else 0), y + b, leather[2])   # back seam
    else:
        for q in ellipse(26, 49 + b, 3, 2.5): c.put(q[0], q[1], _fleece_col(q))
        P(c, [(39, 54 + b), (40, 53 + b)], ember[4]); c.put(40, 54 + b, brass[4]); P(c, [(41, 54 + b), (40, 55 + b)], ember[3])


def _vest_pat(q, t, g):
    return None


def _vest(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    thread = [yarnA[4], brass[4], yarnB[4], yarnA[3], leaf[4], brass[3]]
    if v == 'front':
        for i, y in enumerate(range(58, 65)):   # flower-and-leaf embroidery down both front edges
            for x in (30, 35):
                if (x, y + b) in c and c[(x, y + b)] != INK: c.put(x, y + b, thread[(i + x) % 6] if i % 2 == 0 else leaf[3])
        # embroidered sunflower on the pocket
        P(c, [(24, 60 + b), (26, 60 + b), (24, 62 + b), (26, 62 + b)], brass[3]); P(c, [(25, 60 + b), (24, 61 + b), (26, 61 + b), (25, 62 + b)], brass[4])
        c.put(25, 61 + b, wood[1])
    elif v == 'back':   # vine along the hem
        for x in range(21 + hs, 45 + hs):
            y = 62 + b + (1 if x % 4 < 2 else 0)
            if (x, y) in c and c[(x, y)] != INK: c.put(x, y, leaf[3] if x % 4 else yarnA[4])
    else:
        for y in range(56, 65, 2): c.put(41, y + b, thread[y % 6])
        P(c, [(35, 60 + b), (37, 60 + b), (35, 62 + b), (37, 62 + b)], brass[3]); P(c, [(36, 60 + b), (35, 61 + b), (37, 61 + b), (36, 62 + b)], brass[4])
        c.put(36, 61 + b, wood[1])


def _xstitch(q):
    return ember[3] if (q[0] + q[1]) % 2 == 0 else linen[4]


def _smock(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    _trim(c, g, 2, _xstitch)
    # woven blue sash at the waist
    sy = 60 + b
    for q in list(c.keys()):
        if q[1] in (sy, sy + 1) and c[q] != INK and q[0] not in range(0, 0):
            if any(q in s for s in g['sleeves']) and v != 'side': continue
            c.put(q[0], q[1], jay[4] if q[1] == sy else jay[2])
    if v == 'front':   # sash knot + tassels at the right hip
        P(c, [(41, sy), (42, sy)], jay[5])
        P(c, [(41, sy + 2), (41, sy + 3), (43, sy + 2), (43, sy + 3)], jay[3]); P(c, [(41, sy + 4), (43, sy + 4)], ember[3])
    elif v == 'back':
        for q in rect(25, 46 + b, 40, 47 + b):   # stitched collar band
            if q in c: c.put(q[0], q[1], _xstitch(q))
        P(c, [(23, sy + 2), (23, sy + 3), (25, sy + 2), (25, sy + 3)], jay[3]); P(c, [(23, sy + 4), (25, sy + 4)], ember[3])
    else:
        P(c, [(27, sy + 2), (27, sy + 3), (29, sy + 2), (29, sy + 3)], jay[3]); P(c, [(27, sy + 4), (29, sy + 4)], ember[3])


def _quilt(q, t, g):
    if q[0] % 3 == 0: return autumn[max(0, 2 - t // 2 - (1 if t >= 2 else 0))]
    return None


def _steppe(c, g):
    v, b = g['view'], g['b']
    _trim(c, g, 1, strap[3], sleeves=True, hem=True)
    sl = g['sleeves'][-1] if v != 'side' else g['sleeves'][0]
    if v == 'back': sl = g['sleeves'][0]
    # teal patch on the elbow
    x0, y0, x1, y1 = sl.bbox()
    patch = M(q for q in sl if y0 + 2 <= q[1] <= y0 + 4 and x0 + 1 <= q[0] <= x1 - 1) & c.mask()
    for q in patch: c.put(q[0], q[1], yarnB[4] if (q[0] + q[1]) % 3 else yarnB[3])
    for q in patch.top(): c.put(q[0], q[1], yarnB[5])
    if v == 'front':   # wrap front: diagonal edge strap with a brass toggle
        for q in line([(41, 57 + b), (34, 64 + b)]): c.put(q[0], q[1], strap[3]); c.put(q[0] + 1, q[1], strap[1])
        c.put(38, 60 + b, brass[4])
    elif v == 'back':
        for q in rect(25, 46 + b, 40, 47 + b): c.put(q[0], q[1], strap[3] if q[1] == 46 + b else strap[2])   # stand collar
    else:
        for q in rect(26, 48 + b, 29, 49 + b): c.put(q[0], q[1], strap[3])
        for y in range(56, 64): c.put(40, y + b, strap[2])


def _cable(q, t, g):
    y = q[1] - g['b']
    if y >= 63: return cloakg[2] if q[0] % 2 else None      # ribbed hem
    m = q[0] % 6
    if m == 0: return cloakg[max(1, 2 - t // 2)]
    if m in (2, 3) and (y + (m == 3)) % 3 == 0: return cloakg[5] if t < 2 else cloakg[3]
    return None


def _hedgehog(c, x, y):
    P(c, [(x, y), (x + 1, y - 1), (x + 2, y), (x + 1, y)], wood[1]); P(c, [(x, y + 1), (x + 1, y + 1), (x + 2, y + 1)], wood[2])
    c.put(x + 1, y - 1, wood[3]); c.put(x + 3, y + 1, linen[4]); c.put(x + 4, y + 1, sole[0])


def _cardigan(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        for y in (59, 61, 63): P(c, [(31, y + b), (34, y + b)], wood[4])
        _hedgehog(c, 39, 55 + b)
    elif v == 'side':
        _hedgehog(c, 36, 54 + b)


COAT = [
    dict(slug='ee-sheepskin-longcoat', cat='coat', r=leather, hem=3, detail=_longcoat),
    dict(slug='ee-stitched-felt-vest', cat='coat', r=plum, sleeves=False, open=2, detail=_vest),
    dict(slug='ee-red-stitch-linen-smock', cat='coat', r=linen, hem=2, detail=_smock),
    dict(slug='ee-quilted-steppe-coat', cat='coat', r=autumn, puff=1, pattern=_quilt, detail=_steppe),
    dict(slug='ee-hedgehog-knit-cardigan', cat='coat', r=cloakg, open=2, pattern=_cable, detail=_cardigan),
]


# ======================================================================== CLOAK
def _shaggy(c, g, m, v):
    b = g['b']
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # long-pile tufts: vertical strands
        o = c.get(q)
        if (q[0] * 5 + (q[1] // 3) * 3) % 4 == 0: c.put(q[0], q[1], fleece[2] if o in (fleece[3], fleece[4]) else fleece[1])
        elif (q[0] * 3 + q[1]) % 9 == 0: c.put(q[0], q[1], fleece[5])
    if v == 'back':
        for xx in range(29, 37): c.put(xx, 46 + b, strap[2])   # cord tie
        bx, by = 37 + g['tail'], 58 + b
    elif v == 'side':
        bx, by = 21 + g['tail'], 59 + b
    else:
        return
    # quirk: bramble burr with a blackberry
    P(c, [(bx, by), (bx + 1, by - 1), (bx + 1, by + 1)], leaf[3]); c.put(bx + 1, by, leaf[1])
    P(c, [(bx - 1, by + 1), (bx, by + 2)], plum[1]); c.put(bx - 1, by + 2, plum[0]); c.put(bx - 1, by + 1, plum[4])


def _poppy(c, px, py):
    for q in ((px, py), (px + 1, py), (px, py + 1), (px + 1, py + 1)): c.put(q[0], q[1], ember[3])
    c.put(px, py, ember[5]); c.put(px - 1, py + 1, ember[4]); c.put(px + 2, py, ember[2]); c.put(px + 1, py + 1, sole[0])
    c.put(px, py + 2, cloakg[4])


def _shawl(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # tiny dot texture
        if (q[0] * 2 + q[1] * 3) % 11 == 0: c.put(q[0], q[1], jay[4])
    if v == 'back':
        for px, py in ((27, 53), (36, 52), (31, 59), (24, 49), (40, 48)): _poppy(c, px + (tl if py > 55 else 0), py + b)
        # ladybird on the edge
        lx, ly = 41 + tl, 56 + b
    elif v == 'side':
        for px, py in ((22, 52), (24, 59)): _poppy(c, px + (tl if py > 55 else 0), py + b)
        lx, ly = 19 + tl, 56 + b
    else:
        lx = None
    # fringe below the hem (every other column)
    for q in m.bottom():
        if q[0] % 2 == 0: P(c, [(q[0], q[1] + 1)], ember[2]); c.put(q[0], q[1] + 2, ember[1])
    if lx is not None:
        P(c, [(lx, ly), (lx + 1, ly)], ember[4]); c.put(lx, ly + 1, ember[3]); c.put(lx + 1, ly + 1, sole[0]); c.put(lx + 2, ly, sole[0])


def _birch_mantle(c, g, m, v):
    b, tl = g['b'], g['tail']
    for q in m:   # bark dashes
        if (q[0] * 7 + q[1] * 3) % 17 == 0 and (q[0] + 1, q[1]) in m: c.put(q[0], q[1], birch[0]); c.put(q[0] + 1, q[1], birch[1])
    if v == 'back':   # peaked hood lying down the back
        hood = poly([(26, 48 + b), (40, 48 + b), (34, 58 + b), (32, 58 + b)])
        form(c, hood, birch, frac=0.35)
        for q in hood.inner_edge(): c.put(q[0], q[1], birch[2] if q[1] > 48 + b else birch[4])
        c.put(30, 51 + b, birch[0]); c.put(35, 53 + b, birch[0])
        tx, ty = 33, 59 + b
    elif v == 'side':
        hood = poly([(22, 47 + b), (27, 47 + b), (27, 55 + b), (22, 58 + b)])
        form(c, hood, birch, frac=0.3)
        for q in hood.inner_edge(): c.put(q[0], q[1], birch[2])
        tx, ty = 22, 59 + b
    else:
        return
    # quirk: catkin dangling from the hood tip (sways with the walk)
    sw = (tl + 1) // 2
    P(c, [(tx, ty), (tx + sw, ty + 1)], leaf[2]); P(c, [(tx + sw, ty + 2), (tx + sw, ty + 3)], straw[4]); c.put(tx + sw, ty + 4, straw[2])


def _wheat(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # wide gold / rust stripes counted up from the hem
        below = 0
        while (q[0], q[1] + below + 1) in m: below += 1
        band = below % 8
        if band in (2, 3): c.put(q[0], q[1], yarnA[3] if band == 2 else yarnA[4])
        elif band == 5: c.put(q[0], q[1], yarnB[3])
        elif (q[0] + q[1]) % 4 == 0 and band not in (0,): c.put(q[0], q[1], straw[2] if c.get(q) == straw[3] else c.get(q))
    for q in m.bottom():   # fringe all round the hem
        if q[0] % 2 == 0: c.put(q[0], q[1] + 1, straw[2]); c.put(q[0], q[1] + 2, straw[1])
    # quirk: a wheat ear tucked at the neck
    if v == 'back':
        P(c, [(39, 47 + b), (40, 46 + b), (41, 45 + b)], straw[3]); P(c, [(42, 44 + b), (42, 43 + b), (43, 43 + b)], straw[5]); c.put(43, 44 + b, straw[4])
    elif v == 'side':
        P(c, [(25, 47 + b), (24, 46 + b), (23, 45 + b)], straw[3]); P(c, [(22, 44 + b), (22, 43 + b), (21, 43 + b)], straw[5]); c.put(21, 44 + b, straw[4])


def _fur(q):
    return autumn[5] if (q[0] * 3 + q[1]) % 5 == 0 else autumn[4] if (q[0] + q[1]) % 2 else autumn[3]


def _fox(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # storm-blue wool: hem binding
    for q in m.bottom(): c.put(q[0], q[1], jay[3])
    if v == 'back':
        collar = M(q for q in ellipse(32.5, 48 + b, 13, 4.5) if q[1] >= 46 + b)
        collar -= M(q for q in collar if q[1] == max(p[1] for p in collar if p[0] == q[0]) and q[0] % 3 == 1)
    elif v == 'side':
        collar = ellipse(25.5, 49 + b, 4.5, 4)
    else:
        collar = M(q for q in ellipse(32.5, 47 + b, 17, 4) if q[1] >= 44 + b)
    for q in collar: c.put(q[0], q[1], _fur(q))
    for q in collar.bottom(): c.put(q[0], q[1], autumn[1])
    # quirk: amber bead clasp on the cord
    if v == 'back':
        P(c, [(32, 52 + b), (33, 52 + b)], strap[2]); P(c, [(32, 53 + b), (33, 53 + b)], brass[3]); c.put(32, 53 + b, brass[5]); c.put(33, 54 + b, brass[1]); c.put(32, 54 + b, brass[2])
    elif v == 'side':
        P(c, [(28, 52 + b)], strap[2]); P(c, [(28, 53 + b), (29, 53 + b)], brass[3]); c.put(28, 53 + b, brass[5]); c.put(28, 54 + b, brass[2])


CLOAK = [
    dict(slug='ee-shaggy-shepherd-cape', cat='cloak', r=fleece, lining=fleece, len=66, flare=5, x0=20, x1=45, hemstyle='points', fx0=14, fx1=51, side_back=17, detail=_shaggy),
    dict(slug='ee-poppy-field-shawl', cat='cloak', r=jay, lining=jay, len=63, flare=3, x0=19, x1=46, hemstyle='tri', fx0=15, fx1=50, detail=_shawl),
    dict(slug='ee-birch-hooded-mantle', cat='cloak', r=birch, lining=birch, len=66, flare=3, border=birch, border_rows=1, side_back=18, detail=_birch_mantle),
    dict(slug='ee-wheatfield-poncho', cat='cloak', r=straw, lining=straw, len=62, flare=4, x0=20, x1=45, hemstyle='diamond', fx0=13, fx1=52, side_back=19, detail=_wheat),
    dict(slug='ee-fox-collar-capelet', cat='cloak', r=storm, lining=storm, len=56, flare=3, fx0=15, fx1=50, side_back=20, detail=_fox),
]

ITEMS = FOOT + PACK + COAT + CLOAK
