"""The Monsoon Tangle (SEA): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/SEA/common.lua
(C.R.*) and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light)
pandan = ["#3b3a1e", "#5a5a26", "#7d7a30", "#a39a3c", "#c8b850", "#e6d67a"]
straw = ["#4e3420", "#7a5228", "#a6772f", "#c99a40", "#e2bc5c", "#f4dc8c"]
rattan = ["#5a3418", "#8a5420", "#b47a2a", "#d29a3a", "#e8bc56", "#f8dc8a"]
indigo = ["#18183c", "#22265a", "#2e3c7c", "#3e5698", "#5c78b6", "#8aa2d2"]
wax = ["#6a7698", "#94a0bc", "#b8c2d4", "#d8dcd8", "#ece6d4", "#f6f0dc"]
leaf = ["#173a26", "#1f5a2c", "#2c7a32", "#40983a", "#64b848", "#a0dc6c"]
jade = ["#1e3e3a", "#2a5e52", "#3c7e68", "#5aa080", "#86c49e", "#c0e6c4"]
clay = ["#4a2018", "#72321e", "#9a4a26", "#be6632", "#da8a48", "#f0b26c"]
olive = ["#22261a", "#343a22", "#4a522c", "#646c36", "#808a44", "#a6ae60"]
sage = ["#2a3a32", "#3c5444", "#547056", "#6e8c68", "#8eaa80", "#b8cc9e"]
mango = ["#7a2e14", "#a84a18", "#d06e1c", "#ec9422", "#f8b83a", "#ffdc72"]
mint = ["#3e5e5a", "#5a807a", "#7aa49a", "#9cc4b4", "#c0dece", "#e2f2e4"]
soga = ["#2e1a14", "#4a2a1c", "#6a3e24", "#8c5630", "#b0743e", "#d49a5a"]
mudrub = ["#1e2a2a", "#2c3e3a", "#3e564c", "#56705e", "#728c70", "#9cb08c"]
gecko = ["#3e4a1e", "#5c6e24", "#7e9230", "#a2b440", "#c6d45e", "#e4ec9a"]
petal = ["#8a5a4a", "#c08a6a", "#e2bc96", "#f2dcbc", "#fbead0", "#fff4d6"]
hibis = ["#5a1428", "#8a1e34", "#b8283c", "#dc3c48", "#f2645a", "#ff9a7e"]
orchid = ["#3c1840", "#62245e", "#8a3484", "#b450a8", "#d47cc6", "#f0b4e2"]
king = ["#14305a", "#1c4a8a", "#2468b4", "#2e8ad4", "#4cb0ea", "#9adcf6"]
cream = "#f2e2b8"
# shared _gw.lua ramps
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
felt = ["#3a2026", "#552f2c", "#704033", "#8a5239", "#a66a45", "#c48a5a"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
canvas = ["#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0"]
blanket = ["#5a1e30", "#86283a", "#ad3a3c", "#cc5544", "#e2744e", "#f39a62"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
yarnA = ["#5c1f2e", "#842a36", "#a8383a", "#c64e40", "#dc6a4a", "#f08e62"]


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def D(c, d, ox=0, oy=0):
    """paint a dict {(x, y): col} with an offset"""
    for (x, y), col in d.items(): c.put(x + ox, y + oy, col)


# ======================================================================== FOOTWEAR
def _stilt(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    # two tall teak blocks under the footboard
    xs = (cx - 3, cx + 1) if v != 'side' else (cx - 3, cx + 2)
    for bx in xs:
        for y in (cy + 3, cy + 4, cy + 5):
            c.put(bx, y, wood[4] if y == cy + 3 else wood[3]); c.put(bx + 1, y, wood[2] if y < cy + 5 else wood[1])
    # footboard edge: a lit plank row
    for q in g['foot']:
        if q[1] == cy + 2: c.put(q[0], q[1], wood[4] if q[0] < cx + 2 else wood[3])
    # red cloth strap over the instep
    for q in g['foot']:
        if q[1] in (cy - 1, cy) and (v != 'side' or cx - 1 <= q[0] <= cx + 2):
            c.put(q[0], q[1], blanket[4] if q[1] == cy - 1 else blanket[2])
    # tree frog riding the toe of the near/right clog
    if k == 1 and v == 'front':
        D(c, {(cx - 1, cy - 2): leaf[4], (cx, cy - 2): leaf[3], (cx + 1, cy - 2): leaf[4], (cx - 1, cy - 3): leaf[5], (cx + 1, cy - 3): leaf[5],
              (cx, cy - 3): INK})
    if k == 1 and v == 'side':
        D(c, {(cx + 3, cy - 2): leaf[4], (cx + 4, cy - 2): leaf[3], (cx + 3, cy - 3): leaf[5], (cx + 4, cy - 3): INK, (cx + 2, cy - 2): leaf[2]})


def _sandal(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    # plaited pandan strips: diagonal two-tone weave on the upper body of the sandal
    for q in foot:
        if q[1] <= cy and (q[0] - q[1]) % 3 == 0 and c.get(q) in (pandan[3], pandan[4]):
            c.put(q[0], q[1], pandan[2])
    # straw-coloured woven sole edge (2 rows)
    for q in foot:
        if q[1] in (cy + 1, cy + 2): c.put(q[0], q[1], (straw[4] if q[0] % 2 else straw[3]) if q[1] == cy + 1 else straw[2])
    # leather cross straps
    if v == 'front':
        for d_ in (-2, -1, 0, 1, 2):
            c.put(cx + d_, cy - 1 + abs(d_) // 2, strap[2] if d_ < 1 else strap[1])
        c.put(cx, cy, strap[2])
    elif v == 'side':
        P(c, [(cx, cy - 1), (cx + 1, cy), (cx + 2, cy - 1)], strap[3])
        P(c, [(cx - 3, cy - 2), (cx - 3, cy - 3), (cx - 2, cy - 3)], strap[2])   # heel loop
    else:
        for x in range(cx - 2, cx + 2): c.put(x, cy - 2, strap[2])                  # heel loop seen from behind
    # frangipani blossom on the front strap cross
    if k == 1 and v == 'front':
        D(c, {(cx - 1, cy - 2): petal[5], (cx + 1, cy - 2): petal[4], (cx, cy - 3): petal[5], (cx, cy - 1): petal[3], (cx, cy - 2): brass[4]})
    if k == 1 and v == 'side':
        D(c, {(cx, cy - 2): petal[5], (cx + 2, cy - 2): petal[4], (cx + 1, cy - 3): petal[5], (cx + 1, cy - 2): brass[4]})


def _ikat(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # wound cloth: diagonal rust/cream ikat bands up the shin
    for q in g['shaft']:
        if q[1] < top + 2 or q[1] > cy - 2: continue
        r = (q[1] - top - 2 + (q[0] % 2)) % 4      # one rust zigzag band per 4 rows
        if r == 0: c.put(q[0], q[1], yarnA[4] if q[0] < x1 - 1 else yarnA[2])
        elif r == 2 and q[0] % 2 == 0: c.put(q[0], q[1], wax[4] if q[0] < x1 - 1 else wax[2])
    # beaded tie cord dangling from the cuff
    tx = x1 if v != 'back' else x0
    if v == 'side': tx = x0
    if (v == 'front' and k == 1) or (v == 'back' and k == 0) or (v == 'side' and k == 1):
        P(c, [(tx, top + 2), (tx, top + 3)], wax[4]); c.put(tx, top + 4, brass[4]); c.put(tx, top + 5, yarnA[3])
    # dragonfly resting on the back wrap's tie
    if v == 'back' and k == 0:
        x = x0 + 2
        D(c, {(x, top + 2): jade[4], (x, top + 3): jade[3], (x, top + 4): jade[2], (x, top + 5): jade[2],
              (x - 1, top + 2): mint[5], (x + 1, top + 2): mint[5], (x - 1, top + 3): mint[4], (x + 1, top + 3): mint[4], (x, top + 1): INK})
    if v == 'side' and k == 0:
        x = x0 + 1
        D(c, {(x, top + 2): jade[4], (x + 1, top + 2): jade[3], (x + 2, top + 2): jade[2], (x, top + 1): mint[5], (x + 1, top + 1): mint[4]})


def _rattan(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # woven split cane: 2px over-under on the shaft
    for q in g['shaft']:
        if q[1] < top + 1 or q[1] > cy - 2: continue
        lit = q[0] < x1 - 1
        c.put(q[0], q[1], (rattan[4] if lit else rattan[3]) if ((q[0] // 2) + q[1]) % 2 else (rattan[3] if lit else rattan[2]))
    for x in range(x0, x1 + 1): c.put(x, top, rattan[2])   # wrapped rim
    # leather heel
    if v == 'side':
        P(c, [(x0, cy), (x0, cy + 1), (x0 + 1, cy + 1)], leather[1])
    # cord laces up the front
    if v == 'front':
        mx = (x0 + x1) // 2
        for y in range(top + 1, cy - 1, 2): P(c, [(mx, y), (mx + 1, y)], canvas[4])
    # gecko climbing the side of the near boot
    if v == 'side' and k == 1:
        x = x1 - 1
        D(c, {(x, top + 1): gecko[4], (x, top + 2): gecko[3], (x, top + 3): gecko[3], (x, top + 4): gecko[2], (x - 1, top + 5): gecko[2],
              (x - 1, top + 2): gecko[4], (x + 1, top + 3): gecko[4], (x + 1, top + 1): INK})
    if v == 'front' and k == 1:
        x = x1
        D(c, {(x, top + 1): gecko[4], (x, top + 2): gecko[3], (x, top + 3): gecko[2], (x - 1, top + 4): gecko[2], (x - 1, top + 2): gecko[4]})


def _paddle(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    if v == 'side':
        a, z = cx - 7, cx + 8
    else:
        a, z = (cx - 5, cx + 4) if ft['side'] == 'L' else (cx - 4, cx + 5)
    # wide ribbed rubber paddle under the slipper
    for x in range(a, z + 1):
        c.put(x, cy + 2, mudrub[4] if x < z - 2 else mudrub[3])
        c.put(x, cy + 3, mudrub[2] if x % 2 else mudrub[1])
    P(c, [(a, cy + 1), (z, cy + 1)], mudrub[3])   # upturned rims
    # brass buckle on the slipper strap
    for q in g['foot']:
        if q[1] == cy - 1: c.put(q[0], q[1], felt[1])
    c.put(cx, cy - 1, brass[4]); c.put(cx + 1 if v == 'side' else cx, cy - 1, brass[3] if v == 'side' else brass[4])
    # mudskipper peeking over the front edge of the near paddle
    if k == 1 and v == 'front':
        D(c, {(z - 1, cy + 1): mudrub[5], (z - 2, cy + 1): mudrub[4], (z - 1, cy): INK, (z - 2, cy): mudrub[5]})
    if k == 1 and v == 'side':
        D(c, {(z, cy + 1): mudrub[5], (z - 1, cy + 1): mudrub[4], (z, cy): INK, (z - 1, cy): mudrub[5], (z + 1, cy + 1): mudrub[3]})


FOOT = [
    dict(slug='sea-paddy-stilt-clogs', cat='footwear', shell=wood, sole=wood[1], rim=None, toe=1, detail=_stilt),
    dict(slug='sea-pandan-sandals', cat='footwear', shell=pandan, sole=straw[1], rim=None, toe=1, detail=_sandal),
    dict(slug='sea-ikat-leech-wraps', cat='footwear', shell=leather, upper=indigo, cuff=yarnA, cuff_rows=2, sole=sole[1], rim=60, half=4, detail=_ikat),
    dict(slug='sea-rattan-trail-boot', cat='footwear', shell=leather, upper=rattan, sole=sole[0], rim=62, half=4, toe=1, detail=_rattan),
    dict(slug='sea-mudflat-paddles', cat='footwear', shell=felt, sole=felt[0], rim=None, detail=_paddle),
]


# ======================================================================== BACKPACK
def _rambutan(c, x, y):
    for q in ellipse(x, y, 1, 1): c.put(q[0], q[1], hibis[3] if q[0] <= x and q[1] <= y else hibis[2])
    c.put(x - 1, y - 1, hibis[5])
    P(c, [(x - 2, y - 1), (x + 2, y), (x, y - 2)], leaf[3])   # green-tipped hairs


def basket_back(c, x, y, g):
    y += 4
    m = poly([(x - 9, y + 1), (x + 8, y + 1), (x + 6, y + 14), (x - 7, y + 14)])
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        sh = q[0] > x1 - 3
        col = (rattan[4] if not sh else rattan[3]) if q[1] % 2 else (rattan[3] if not sh else rattan[2])
        if (q[0] - x) % 3 == 0: col = rattan[2] if not sh else rattan[1]
        if q[1] == y1: col = rattan[1]
        c.put(q[0], q[1], col)
    for rx in (_ for _ in []): pass
    for _rx in range(3): pass
    for x_, y_ in [(x - 6, y - 1), (x - 1, y - 2), (x + 4, y - 1)]: _rambutan(c, x_, y_)
    rim = rect(x - 10, y, x + 9, y + 1)
    for q in rim: c.put(q[0], q[1], rattan[1] if (q[0] + q[1]) % 3 == 0 else (rattan[4] if q[1] == y else rattan[3]))
    for sx in (x - 5, x + 3):   # leather shoulder loops
        for yy in range(y + 2, y + 12): c.put(sx, yy, strap[2]); c.put(sx + 1, yy, strap[1])


def basket_side(c, x, y, g):
    m = poly([(x - 8, y + 1), (x, y + 1), (x, y + 16), (x - 6, y + 16)])
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        col = rattan[4] if q[1] % 2 else rattan[3]
        if (q[0] - x) % 3 == 0: col = rattan[2]
        if q[1] == y1: col = rattan[1]
        c.put(q[0], q[1], col)
    _rambutan(c, x - 5, y - 1); _rambutan(c, x - 2, y - 2)
    for q in rect(x - 9, y, x, y + 1): c.put(q[0], q[1], rattan[1] if (q[0] + q[1]) % 3 == 0 else (rattan[4] if q[1] == y else rattan[3]))
    for yy in range(y + 2, y + 14): c.put(x - 1, yy, strap[2])


def _pole(c, px, y0, y1, w=2):
    for yy in range(y0, y1 + 1):
        node = (yy - y0) % 5 == 4
        c.put(px, yy, pandan[1] if node else pandan[4])
        if w > 1: c.put(px + 1, yy, pandan[1] if node else pandan[2])


def _cup(c, x, y):
    c.put(x, y, canvas[4]); c.put(x, y + 1, canvas[4])
    for q in ellipse(x, y + 3, 1.5, 1).rows(y + 3, y + 4): c.put(q[0], q[1], clay[4] if q[0] < x else clay[2])
    P(c, [(x - 1, y + 2), (x, y + 2), (x + 1, y + 2)], petal[4])


def ladder_back(c, x, y, g):
    sack = rect(x - 6, y + 2, x + 5, y + 13)
    form(c, sack, indigo, frac=0.3)
    for i in range(12):   # cord cross
        c.put(x - 6 + i, y + 2 + i, wax[4]); c.put(x + 5 - i, y + 2 + i, wax[4] if i < 6 else wax[2])
    _pole(c, x - 9, y - 2, y + 17); _pole(c, x + 7, y - 2, y + 17)
    for by in (y + 1, y + 14):
        for xx in range(x - 7, x + 7 + (3 if by > y + 1 else 0)): c.put(xx, by, pandan[4] if xx < x + 4 else pandan[3])
        for xx in range(x - 7, x + 7): c.put(xx, by + 1, pandan[1])
    mat = rect(x - 10, y - 3, x + 9, y - 1)
    form(c, mat, straw, frac=0.3)
    for xx in range(x - 10, x + 10, 3): c.put(xx, y - 2, straw[2])
    P(c, [(x - 10, y - 2)], straw[1])
    _cup(c, x + 10, y + 13)   # dangles from the lower crossbar end, below the scarf and hand


def ladder_side(c, x, y, g):
    sack = rect(x - 7, y + 2, x - 2, y + 13)
    form(c, sack, indigo, frac=0.3)
    for i in range(6): c.put(x - 7 + i, y + 4 + i, wax[4])
    _pole(c, x - 1, y - 2, y + 17)
    for by in (y + 1, y + 14):
        for xx in range(x - 4, x): c.put(xx, by, pandan[3])
    roll = ellipse(x - 3, y - 2, 2, 1.5)
    form(c, roll, straw, frac=0.3)
    P(c, [(x - 3, y - 2), (x - 4, y - 2)], straw[1]); c.put(x - 3, y - 3, straw[5])   # rolled-mat spiral end
    _cup(c, x - 9, y + 8)


def _batik(c, m, y):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        r = q[1] - y
        if r % 6 == 0 and (q[0] % 4) in (0, 1): c.put(q[0], q[1], wax[3])
        elif r % 6 == 1 and (q[0] % 4) in (2, 3): c.put(q[0], q[1], wax[3])
        elif r % 6 == 3 and q[0] % 3 == 0: c.put(q[0], q[1], wax[4] if q[0] < x1 - 3 else wax[2])


def bundle_back(c, x, y, g):
    for ex, s in ((x - 4, -1), (x + 3, 1)):   # knotted ears
        ear = poly([(ex - 2, y + 3), (ex + 2, y + 3), (ex + 3 * s, y - 3), (ex + 3 * s - s * 2, y - 3)])
        form(c, ear, indigo, frac=0.3)
    m = ellipse(x - 0.5, y + 10, 9, 7)
    form(c, m, indigo, frac=0.3, hi=[(x - 6, y + 5)])
    _batik(c, m, y)
    for q in ellipse(x - 0.5, y + 3, 2, 1.5): c.put(q[0], q[1], indigo[2] if q[1] > y + 3 else indigo[4])
    for q in line([(x - 9, y + 6), (x + 8, y + 14)], 2): c.put(q[0], q[1], blanket[3] if q[1] % 2 else blanket[2])
    ox, oy = x - 6, y + 6   # orchid tucked under the sling where it crosses the bundle
    D(c, {(ox, oy): orchid[5], (ox + 1, oy): orchid[4], (ox - 1, oy + 1): orchid[4], (ox, oy + 1): brass[4], (ox + 1, oy + 1): orchid[3],
          (ox, oy + 2): orchid[2], (ox + 2, oy + 1): orchid[3], (ox - 1, oy - 1): leaf[3]})


def bundle_side(c, x, y, g):
    ear = poly([(x - 6, y + 3), (x - 2, y + 3), (x - 6, y - 3), (x - 8, y - 2)])
    form(c, ear, indigo, frac=0.3)
    m = ellipse(x - 5, y + 10, 5, 7)
    form(c, m, indigo, frac=0.3)
    _batik(c, m, y)
    for q in line([(x - 1, y + 2), (x - 6, y + 16)], 1): c.put(q[0], q[1], blanket[3])
    D(c, {(x - 4, y + 2): orchid[4], (x - 3, y + 2): brass[4], (x - 4, y + 3): orchid[3], (x - 3, y + 1): orchid[5]})


def _tiers(c, x, y, widths, side=False):
    for i, hw in enumerate(widths):
        ty = y + i * 4
        r = straw if i % 2 == 0 else pandan
        a, z = (x - hw, x) if side else (x - hw, x + hw - 1)
        for xx in range(a, z + 1):
            depth = 4 + (1 if (xx - a) % 2 == 0 else 0) + (1 if (xx - a) % 4 == 1 else 0)
            for yy in range(ty, ty + depth):
                col = r[4] if yy == ty else (r[3] if xx < z - 2 else r[2])
                if (xx % 2 == 0) and yy > ty: col = r[2] if xx < z - 2 else r[1]
                if yy == ty + depth - 1: col = r[1]
                c.put(xx, yy, col)


def _snail(c, x, y):
    for q in ellipse(x, y, 2, 2): c.put(q[0], q[1], clay[5] if (q[0] < x and q[1] < y) else (clay[4] if q[0] <= x or q[1] <= y else clay[3]))
    P(c, [(x, y), (x + 1, y), (x, y - 1)], clay[1])   # spiral
    P(c, [(x - 3, y + 3), (x - 2, y + 3), (x - 1, y + 3), (x, y + 3), (x + 1, y + 3), (x + 2, y + 3)], petal[3]); P(c, [(x - 3, y + 2), (x - 4, y + 1)], petal[4])
    c.put(x - 4, y, INK)


def thatch_back(c, x, y, g):
    form(c, rect(x - 1, y - 4, x, y - 1), straw, frac=0.5)
    c.put(x - 1, y - 5, straw[5])
    _tiers(c, x, y, (3, 6, 8, 10))
    _snail(c, x + 4, y + 8)


def thatch_side(c, x, y, g):
    form(c, rect(x - 2, y - 4, x - 1, y - 1), straw, frac=0.5)
    _tiers(c, x, y, (3, 5, 7, 8), side=True)
    _snail(c, x - 6, y + 6)


def jar_back(c, x, y, g):
    jar = ellipse(x - 0.5, y + 9, 8, 7) | rect(x - 3, y - 1, x + 2, y + 2)
    form(c, jar, jade, frac=0.3, hi=[(x - 5, y + 5), (x - 6, y + 6)])
    for xx in range(x - 3, x + 3): c.put(xx, y - 1, jade[4] if xx < x + 1 else jade[2])
    for q in jar:   # rope-net sling over the lower body
        if q[1] > y + 8 and ((q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0): c.put(q[0], q[1], canvas[4] if q[0] < x + 4 else canvas[2])
    for sx in (x - 6, x + 5):
        for yy in range(y + 2, y + 10): c.put(sx, yy, canvas[3])
    form(c, rect(x - 2, y - 3, x + 1, y - 2), wood, frac=0.3)   # cork
    D(c, {(x - 1, y - 4): leaf[3], (x - 1, y - 5): leaf[3], (x - 2, y - 6): leaf[4], (x - 3, y - 6): leaf[5], (x, y - 6): leaf[4], (x + 1, y - 6): leaf[3]})
    for q in line([(x - 7, y + 14), (x - 10, y + 13)], 1): c.put(q[0], q[1], pandan[4])   # bamboo spout (left: scarf hangs right)
    c.put(x - 10, y + 14 + g['f'] % 3, king[4])


def jar_side(c, x, y, g):
    jar = ellipse(x - 5, y + 9, 5, 7) | rect(x - 7, y - 1, x - 4, y + 2)
    form(c, jar, jade, frac=0.3, hi=[(x - 8, y + 5)])
    for q in jar:
        if q[1] > y + 8 and ((q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0): c.put(q[0], q[1], canvas[4])
    form(c, rect(x - 7, y - 3, x - 4, y - 2), wood, frac=0.3)
    D(c, {(x - 6, y - 4): leaf[3], (x - 6, y - 5): leaf[3], (x - 7, y - 6): leaf[4], (x - 8, y - 6): leaf[5], (x - 5, y - 6): leaf[4]})
    for q in line([(x - 10, y + 11), (x - 12, y + 10)], 1): c.put(q[0], q[1], pandan[4])
    c.put(x - 12, y + 11 + g['f'] % 3, king[4])


PACK = [
    dict(slug='sea-rattan-back-basket', cat='backpack', back=basket_back, side=basket_side),
    dict(slug='sea-bamboo-ladder-pack', cat='backpack', back=ladder_back, side=ladder_side),
    dict(slug='sea-batik-bundle', cat='backpack', back=bundle_back, side=bundle_side),
    dict(slug='sea-nipa-thatch-pack', cat='backpack', back=thatch_back, side=thatch_side),
    dict(slug='sea-water-jar-pack', cat='backpack', back=jar_back, side=jar_side),
]


# ======================================================================== COAT
def _smock_pat(q, t, g):
    y = q[1] - g['b']
    if (y + (0, 1, 1, 0)[q[0] % 4]) % 5 == 0: return wax[3] if t < 2 else wax[1]
    if y % 5 == 3 and q[0] % 4 == 2: return wax[4] if t < 2 else wax[2]
    return None


def _flare_sleeves(c, g, r):
    for s in g['sleeves']:
        x0, y0, x1, y1 = s.bbox()
        for y in (y1 - 1, y1):
            row = [q[0] for q in s if q[1] == y]
            if row: c.put(min(row) - 1, y, r[2]); c.put(max(row) + 1, y, r[1])


def _hibiscus(c, x, y):
    D(c, {(x, y): wax[5], (x + 1, y): wax[4], (x + 2, y): wax[4], (x, y + 1): hibis[4], (x + 1, y + 1): hibis[3], (x + 2, y + 1): wax[4],
          (x, y + 2): wax[4], (x + 1, y + 2): hibis[2], (x + 2, y + 2): wax[3]})


def _smock(c, g):
    v, b, a = g['view'], g['b'], g['p']['arm']
    _flare_sleeves(c, g, indigo)
    if v == 'front': _hibiscus(c, 44, 50 + b - a)
    elif v == 'back': _hibiscus(c, 19, 50 + b + a)
    else: _hibiscus(c, 30 + a // 2, 50 + b)


def _vest_pat(q, t, g):
    if ((q[0] // 2) + ((q[1] - g['b']) // 2)) % 2: return straw[max(1, 4 - t)]
    return None


def _vest(c, g):
    v, b = g['view'], g['b']
    m = c.mask()
    for q in m.inner_edge(): c.put(q[0], q[1], soga[2])   # dark bound edges
    if v == 'front':
        for px in (24, 37):
            for q in rect(px, 59 + b, px + 4, 62 + b): c.put(q[0], q[1], pandan[2] if q[1] > 59 + b else soga[2])
        D(c, {(40, 58 + b): hibis[3], (40, 57 + b): hibis[4], (41, 56 + b): hibis[3], (41, 55 + b): leaf[3]})
    elif v == 'side':
        for q in rect(35, 59 + b, 39, 62 + b): c.put(q[0], q[1], pandan[2] if q[1] > 59 + b else soga[2])
        D(c, {(38, 58 + b): hibis[3], (38, 57 + b): hibis[4], (39, 56 + b): hibis[3], (39, 55 + b): leaf[3]})


def _ikat_pat(q, t, g):
    y = (q[1] - g['b']) % 6
    if y == 0: return indigo[max(1, 3 - t // 2)]
    if y in (2, 4) and q[0] % 4 == 1: return brass[4] if t < 2 else brass[2]
    if y == 3 and q[0] % 4 in (0, 1, 2): return wax[4] if t < 2 else wax[2]
    return None


def _tassel(c, x, y):
    P(c, [(x, y), (x + 1, y)], brass[3]); c.put(x, y + 1, brass[2])
    P(c, [(x - 1, y + 2), (x, y + 2), (x + 1, y + 2)], brass[4]); P(c, [(x - 1, y + 3), (x + 1, y + 3)], brass[2]); c.put(x, y + 3, brass[3])


def _wrap(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        for q in line([(41, 58 + b), (30, 64 + b)], 1):
            if q in c: c.put(q[0], q[1], indigo[1])
        _tassel(c, 43 + hs, 62 + b)
    elif v == 'back':
        _tassel(c, 21 + hs, 62 + b)
    else:
        _tassel(c, 40 + hs, 62 + b)


def _quilt(q, t, g):
    y = q[1] - g['b']
    if (q[0] + y) % 4 == 0 or (q[0] - y) % 4 == 0: return sage[max(0, 3 - t)]
    return None


def _fluff(c, x, y):
    D(c, {(x, y): petal[5], (x + 1, y): petal[4], (x, y - 1): petal[4], (x + 1, y - 1): petal[5], (x + 2, y - 1): petal[3], (x + 1, y - 2): petal[5]})


def _puffer(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        for y in (59, 61, 63): P(c, [(32, y + b), (33, y + b)], soga[4])
        _fluff(c, 45, 50 + b - g['p']['arm'])
    elif v == 'back':
        for q in rect(27, 46 + b, 38, 47 + b): c.put(q[0], q[1], sage[4] if q[1] == 46 + b else sage[2])
        _fluff(c, 18, 50 + b + g['p']['arm'])
    else:
        _fluff(c, 24, 50 + b)


def _crab(c, x, y, flip=False):
    s = -1 if flip else 1
    D(c, {(x, y): hibis[3], (x + s, y): hibis[4], (x + 2 * s, y): hibis[3], (x, y + 1): hibis[2], (x + 2 * s, y + 1): hibis[2],
          (x + s, y - 1): INK, (x + 3 * s, y - 1): mango[4], (x + 4 * s, y - 1): mango[5], (x + 3 * s, y): mango[3], (x + 4 * s, y): mango[3]})


def _oilcloth(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        for y in (59, 61, 63, 65): c.put(33, y + b, brass[4]); c.put(34, y + b, brass[2])
        for px in (24, 37):
            for x in range(px, px + 5): c.put(x, 61 + b, olive[1]); c.put(x, 62 + b, olive[4] if x < px + 3 else olive[3])
        _crab(c, 22 + hs, 66 + b)
    elif v == 'back':
        for q in rect(27, 46 + b, 38, 47 + b): c.put(q[0], q[1], olive[4] if q[1] == 46 + b else olive[2])
        for y in range(62, 67): c.put(32 + hs, y + b, olive[1])
        _crab(c, 43 + hs, 66 + b, flip=True)
    else:
        for x in range(34, 39): c.put(x, 61 + b, olive[1])
        _crab(c, 24 + hs, 66 + b)


COAT = [
    dict(slug='sea-indigo-batik-smock', cat='coat', r=indigo, hem=1, pattern=_smock_pat, detail=_smock),
    dict(slug='sea-pandan-weave-vest', cat='coat', r=pandan, sleeves=False, open=2, pattern=_vest_pat, detail=_vest),
    dict(slug='sea-ikat-wrap-jacket', cat='coat', r=yarnA, pattern=_ikat_pat, detail=_wrap),
    dict(slug='sea-kapok-puffer', cat='coat', r=sage, puff=1, pattern=_quilt, detail=_puffer),
    dict(slug='sea-mangrove-oilcloth', cat='coat', r=olive, hem=3, detail=_oilcloth),
]


# ======================================================================== CLOAK
def _frond(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # four shaggy tiers + straw streaks
        r = q[1] - y0
        if r > 2 and (r + (q[0] % 2)) % 5 == 0: c.put(q[0], q[1], straw[1])
        elif q[0] % 3 == 1 and r > 2 and c.get(q) != straw[1]: c.put(q[0], q[1], straw[2] if c.get(q) != straw[4] else straw[3])
    b = g['b']
    if v == 'back':     # kingfisher perched on the left shoulder, facing out
        bird = {(21, 48): king[4], (20, 48): king[4], (19, 48): sole[1], (18, 48): sole[1], (22, 49): king[3], (21, 49): mango[4], (20, 49): mango[3],
                (23, 50): king[1], (22, 50): king[2], (21, 47): king[5]}
    elif v == 'side':   # perched on the back of the cape
        bird = {(23, 48): king[4], (24, 48): king[4], (25, 48): sole[1], (26, 48): sole[1], (22, 49): king[3], (23, 49): mango[4], (24, 49): mango[3],
                (21, 50): king[1], (22, 50): king[2], (23, 47): king[5]}
    else:
        bird = {(18, 45): king[4], (19, 45): king[4], (17, 45): sole[1], (16, 45): sole[1], (19, 46): king[3], (18, 46): mango[4], (20, 46): king[2]}
        P(c, [(31, 46 + b), (34, 46 + b)], blanket[3])
    for (x, y), col in bird.items(): c.put(x, y + b, col)


def _banana(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    b, tl, f = g['b'], g['tail'], g['f']
    if v == 'back':
        mid = 32
        for q in m:
            dx = q[0] - mid - (tl if q[1] > y0 + 10 else 0)
            if dx in (0, 1): c.put(q[0], q[1], pandan[5] if dx == 0 else pandan[4])
            elif (q[1] - y0 - abs(dx) // 2) % 3 == 0: c.put(q[0], q[1], leaf[2])
        hood = poly([(24, 46 + b), (41, 46 + b), (34, 60 + b), (31, 60 + b)])
        form(c, hood, leaf, frac=0.35)
        for q in hood.inner_edge(): c.put(q[0], q[1], leaf[5] if q[0] < 33 else leaf[1])   # glossy curled rim
        for q in ellipse(32.5, 51 + b, 3.5, 1.5): c.put(q[0], q[1], leaf[0])                # hood opening
        for q in hood:
            if q[0] in (32, 33) and q[1] > 53 + b: c.put(q[0], q[1], pandan[5] if q[0] == 32 else pandan[4])
        c.put(32 + g['tail'], 62 + b + f % 3, king[5]); c.put(32 + g['tail'], 63 + b + f % 3, king[3])
    elif v == 'side':
        for q in m:
            if (q[1] + q[0]) % 3 == 0 and q[1] > y0 + 2: c.put(q[0], q[1], leaf[2])
        hood = poly([(23, 44 + b), (28, 45 + b), (27, 53 + b), (22, 55 + b), (21, 50 + b)])
        form(c, hood, leaf, frac=0.3)
        c.put(21, 56 + b + f % 3, king[5]); c.put(21, 57 + b + f % 3, king[3])


def _batik_shawl(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    b = g['b']
    for q in m:
        if (q[0] + 2 * q[1]) % 9 == 0: c.put(q[0], q[1], soga[4])          # wax crackle
        if q[0] % 5 == 2 and (q[1] - b) % 4 == 1 and q[1] > y0 + 1: c.put(q[0], q[1], cream)
        if q[0] % 5 in (1, 3) and (q[1] - b) % 4 == 1 and q[1] > y0 + 1: c.put(q[0], q[1], soga[1])
    for q in m.bottom():   # fringe
        if q[0] % 2 == 0: c.put(q[0], q[1] + 1, soga[3])
    if v == 'back':
        bx, by = max(m, key=lambda q: (q[1], -abs(q[0] - 32)))
        D(c, {(bx - 2, by - 3): leaf[4], (bx - 1, by - 3): leaf[3], (bx + 1, by - 3): leaf[3], (bx + 2, by - 3): leaf[4],
              (bx - 2, by - 2): leaf[3], (bx - 1, by - 2): INK, (bx, by - 3): INK, (bx, by - 2): INK, (bx + 1, by - 2): INK, (bx + 2, by - 2): leaf[3]})
    elif v == 'side':
        bx, by = min((q for q in m if q[1] >= y1 - 1), key=lambda q: q[0])
        D(c, {(bx, by - 2): leaf[4], (bx + 1, by - 2): INK, (bx + 2, by - 2): leaf[3], (bx + 1, by - 3): INK, (bx, by - 3): leaf[3], (bx + 2, by - 3): leaf[4]})


def _net(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    b, f = g['b'], g['f']
    for q in m:   # fine mesh: light holes on a mint grid
        if q[0] % 2 and q[1] % 2 and q[1] > y0 + 1: c.put(q[0], q[1], mint[5] if q[0] < x1 - 4 else mint[4])
    for q in m.bottom():   # wooden bead weights
        if q[0] % 3 == 0: c.put(q[0], q[1] + 1, wood[3]); c.put(q[0], q[1] + 2, wood[1])
    glow = brass[5] if f % 2 else brass[4]
    if v == 'back':
        for q in rect(23, 46 + b, 42, 47 + b): c.put(q[0], q[1], pandan[4] if q[1] == 46 + b else pandan[2])
        D(c, {(39, 58 + b): glow, (38, 58 + b): brass[3], (40, 58 + b): brass[3], (39, 57 + b): brass[3], (39, 59 + b): mango[3]})
    elif v == 'side':
        for q in rect(25, 46 + b, 28, 47 + b): c.put(q[0], q[1], pandan[4] if q[1] == 46 + b else pandan[2])
        D(c, {(22, 57 + b): glow, (21, 57 + b): brass[3], (23, 57 + b): brass[3], (22, 56 + b): brass[3], (22, 58 + b): mango[3]})


def _pitcher(c, x, y):
    P(c, [(x, y), (x, y + 1)], strap[2]); c.put(x, y + 2, wood[4])
    D(c, {(x - 1, y + 3): hibis[3], (x, y + 3): hibis[4], (x + 1, y + 3): hibis[3], (x - 1, y + 4): gecko[4], (x, y + 4): gecko[3], (x + 1, y + 4): gecko[2],
          (x - 1, y + 5): gecko[3], (x, y + 5): hibis[2], (x + 1, y + 5): gecko[2], (x, y + 6): gecko[1]})


def _poncho(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    b, tl = g['b'], g['tail']
    for q in m:   # stitched seams
        if v == 'back' and q[0] == 32 + (tl if q[1] > y0 + 10 else 0) and q[1] % 2 == 0 and q[1] > y0 + 8: c.put(q[0], q[1], mango[1])
        if v != 'front' and (q[0], q[1] + 2) not in m and (q[0], q[1] + 1) in m and q[0] % 2: c.put(q[0], q[1], mango[1])
    if v == 'back':
        hood = ellipse(32.5, 50 + b, 6, 3)
        form(c, hood, mango, frac=0.35)
        for x in (29, 32, 35): c.put(x, 51 + b, mango[1])
        _pitcher(c, 32 + tl, 54 + b)
    elif v == 'side':
        hood = ellipse(25, 50 + b, 3, 3.5)
        form(c, hood, mango, frac=0.3)
        _pitcher(c, 23 + tl, 54 + b)


CLOAK = [
    dict(slug='sea-palm-frond-rain-cape', cat='cloak', r=straw, lining=straw, len=62, flare=4, x0=21, x1=44, hemstyle='points', fx0=15, fx1=50, side_back=19, detail=_frond),
    dict(slug='sea-banana-leaf-hood', cat='cloak', r=leaf, lining=leaf, len=66, flare=3, hemstyle='points', side_back=19, detail=_banana),
    dict(slug='sea-batik-shawl', cat='cloak', r=soga, lining=soga, len=64, flare=3, x0=19, x1=46, hemstyle='tri', fx0=15, fx1=50, detail=_batik_shawl),
    dict(slug='sea-net-veil-mantle', cat='cloak', r=mint, lining=mint, len=66, flare=4, side_back=19, detail=_net),
    dict(slug='sea-monsoon-poncho', cat='cloak', r=mango, lining=mango, len=64, flare=5, x0=20, x1=45, hemstyle='diamond', fx0=13, fx1=52, detail=_poncho),
]

ITEMS = FOOT + PACK + COAT + CLOAK
