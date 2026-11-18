"""Mistmoor (NWE): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/NWE/common.lua (R.*)
and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light. Plain craft only: wool, waxed cloth, wicker, birch bark, rush, wood."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light): common.lua
birch = ["#4a3e44", "#6e6468", "#9a9096", "#c4bcb8", "#e2dccf", "#f6f0e0"]
fleece = ["#6c5848", "#8e7a64", "#b4a084", "#d2c2a2", "#eadcbc", "#fbf1d8"]
heather = ["#3e1f45", "#5e2f63", "#83457f", "#a65f98", "#c784b2", "#e6b2d0"]
tweed = ["#33302a", "#4a4636", "#636044", "#7e7a54", "#9a966a", "#bdb88a"]
wax = ["#22281c", "#333c26", "#475230", "#5e6a3a", "#7a8648", "#a2ac66"]
feltgrey = ["#3a3a4a", "#525466", "#6c6f80", "#8a8e9c", "#acb0ba", "#d0d4d8"]
woad = ["#1c2a48", "#26406a", "#335a88", "#4a78a4", "#6e9ac0", "#a4c4dc"]
tanbark = ["#4e1e1c", "#702c22", "#94402a", "#b65a34", "#d27a44", "#eaa060"]
straw = ["#4e3a1c", "#74572a", "#9a7a36", "#bf9e48", "#dcc062", "#f2de90"]
eider = ["#2a3440", "#3c4a58", "#526474", "#6c8090", "#90a4b0", "#bccad0"]
mustard = ["#4a3410", "#74501a", "#a07224", "#c8962e", "#e2b844", "#f4d872"]
mist = ["#2e3440", "#434c5a", "#5c6676", "#788294", "#9ca4b2", "#c6ccd4"]
wicker = ["#4a2e1a", "#6e4624", "#966232", "#b88244", "#d4a45a", "#ecc884"]
peat = ["#22161a", "#33221f", "#463026", "#5a3e2e", "#704e38", "#8a6446"]
rope = ["#4e3a26", "#6e5434", "#8e7046", "#ae8e5c", "#c8aa74", "#e2c896"]
moss = ["#24544a", "#2e6b45", "#3f9150", "#5eab55", "#7cc35a", "#c4e07a"]
berry = ["#5e1428", "#8a1e30", "#b82a34", "#d84038", "#ee6a4a", "#ff9a72"]
frog = ["#1e4430", "#2a6038", "#3c8040", "#58a048", "#80c058", "#b8e07a"]
# ---- _gw.lua W.R
felt = ["#3a2026", "#552f2c", "#704033", "#8a5239", "#a66a45", "#c48a5a"]
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
canvas = ["#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
steel = ["#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2"]
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
yarnA = ["#5c1f2e", "#842a36", "#a8383a", "#c64e40", "#dc6a4a", "#f08e62"]
jay = ["#1e2f63", "#28488e", "#3364b4", "#4688d2", "#6cb0e6", "#bfe6f6"]
CREAM = fleece[5]


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def _front_k(g, k):
    """the foot the quirk sits on: the right foot in front/back, the near foot in side view"""
    return k == 1


# ======================================================================== FOOTWEAR
def _alder(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    # carved grain: a darker gouge line along the wood
    for q in foot:
        if q[1] == cy + 1 and c.get(q) not in (None, INK) and (q[0] + k) % 3 == 0: c.put(q[0], q[1], wood[2])
    # stitched leather instep band (2 rows) with cream stitch dots
    y0 = cy - 2
    for q in foot:
        if q[1] in (y0, y0 + 1) and (v != 'side' or q[0] >= cx - 1):
            c.put(q[0], q[1], strap[3] if q[1] == y0 else strap[2])
    xs = sorted(q[0] for q in foot if q[1] == y0 + 1 and (v != 'side' or q[0] >= cx - 1))
    for x in xs[1:-1:2]: c.put(x, y0 + 1, fleece[4])
    # moss tuft on the toe of one clog
    if _front_k(g, k) and v != 'back':
        if v == 'side':
            tx, ty = cx + 4, cy - 1
            P(c, [(tx, ty), (tx + 1, ty), (tx, ty - 1)], moss[3]); P(c, [(tx + 1, ty - 1)], moss[5]); c.put(tx - 1, ty, moss[1])
        else:
            tx, ty = cx + 1, cy + 1
            P(c, [(tx, ty), (tx + 1, ty), (tx + 1, ty - 1)], moss[3]); c.put(tx, ty - 1, moss[5]); c.put(tx + 2, ty, moss[1])


def _brogue(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    cx = int(ft['cx'])
    # drain holes punched along the toe cap
    if v != 'back':
        for q in g['foot']:
            if q[1] == cy and (q[0] + k) % 2 == 0 and (v != 'side' or q[0] > cx) and c.get(q) not in (None, INK): c.put(q[0], q[1], leather[1])
    else:
        for x in range(x0 + 1, x1, 2): c.put(x, cy - 1, leather[1])
    # long cream laces criss-crossed up the ankle (onto the shin above the shoe)
    lx = (x0 + x1) // 2 if v == 'front' else (x1 if v == 'side' else None)
    if lx is not None:
        ys = range(top - 3, cy - 1)
        for y in ys:   # tall hide tongue behind the laces
            for x in ((lx - 1, lx, lx + 1) if v == 'front' else (lx - 1, lx)):
                c.put(x, y, leather[3] if x < lx + 1 else leather[2])
        for i, y in enumerate(ys):
            if v == 'front':
                if i % 2: c.put(lx, y, CREAM)
                else: c.put(lx - 1, y, fleece[3]); c.put(lx + 1, y, CREAM)
            else:
                c.put(lx - (i % 2), y, CREAM if i % 2 else fleece[3])
    else:   # back: the laces wrap round the heel
        for x in range(x0 + 1, x1): c.put(x, top - 1, CREAM if x % 2 else fleece[3])
    # heather sprig pushed through the laces
    if _front_k(g, k) and v != 'back':
        hx = (lx + 2) if v == 'front' else lx + 1
        P(c, [(hx, top - 1), (hx + 1, top - 2)], moss[2])
        P(c, [(hx + 1, top - 3), (hx + 2, top - 3)], heather[4]); c.put(hx + 2, top - 4, heather[5]); c.put(hx + 1, top - 4, heather[3])


def _feltboot(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # felt speckle
    for q in g['shaft'] | g['foot']:
        if (q[0] * 5 + q[1] * 3) % 7 == 0 and c.get(q) not in (None, INK, feltgrey[1]): c.put(q[0], q[1], feltgrey[2])
    # folded-down cuff: lighter 2 rows, a dark fold line under it
    for x in range(x0 - 1, x1 + 2):
        c.put(x, top, feltgrey[5] if x < x1 else feltgrey[4])
        c.put(x, top + 1, feltgrey[4] if x < x1 else feltgrey[3])
        c.put(x, top + 2, feltgrey[1])
    # knitted band of little diamonds (rust yarn) on the cuff
    for x in range(x0 - 1, x1 + 2):
        ph = (x - x0) % 4
        if ph == 1: c.put(x, top, yarnA[3])
        if ph in (0, 2): c.put(x, top + 1, yarnA[3])
    # sheep button carved in wood on the outer side of one boot
    if _front_k(g, k) and v != 'back':
        bx = x1 if v == 'front' else x1 - 1
        by = top + 4
        P(c, [(bx - 1, by), (bx, by), (bx - 1, by + 1), (bx, by + 1)], CREAM); c.put(bx + 1, by, wood[2]); c.put(bx, by + 1, fleece[3])
        P(c, [(bx - 1, by + 2), (bx, by + 2)], wood[1])


def _barkslip(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # checker weave of birch-bark strips (2 px squares), keep sole row
    for q in foot:
        if q[1] >= y1 or c.get(q) == INK: continue
        a = ((q[0] - x0) // 2 + (q[1] - y0) // 2) % 2
        col = birch[4] if a else birch[2]
        if q[0] > x1 - 2: col = birch[3] if a else birch[1]
        if q[1] == y0: col = birch[5] if a else birch[3]
        c.put(q[0], q[1], col)
    # dark bark lenticel ticks + the slipper opening
    if v == 'front':
        P(c, [(cx - 1, y0 + 1), (cx, y0 + 1), (cx + 1, y0 + 1)], strap[0]); c.put(cx, y0 + 2, strap[1])
    elif v == 'side':
        P(c, [(cx - 3, y0 + 1), (cx - 2, y0 + 1), (cx - 1, y0 + 1), (cx, y0 + 1)], strap[0])
    else:
        for x in range(x0 + 2, x1 - 1): c.put(x, y0 + 1, strap[1])
    for q in foot.bottom(): c.put(q[0], q[1], strap[1])
    # red ladybird walking on one toe
    if _front_k(g, k) and v != 'back':
        lx, ly = (cx + 4, cy) if v == 'side' else (cx + 1, cy + 1)
        P(c, [(lx, ly), (lx + 1, ly)], berry[3]); c.put(lx, ly - 1, berry[5]); c.put(lx + 1, ly - 1, INK)


def _gaiter(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # herringbone: zigzag columns in the tweed
    for q in g['shaft']:
        if q[1] > cy - 2 or c.get(q) == INK: continue
        col_dark = q[0] > x1 - 2
        zig = ((q[1] + q[0]) % 2) if (q[0] // 2) % 2 else ((q[1] - q[0]) % 2)
        c.put(q[0], q[1], (tweed[2] if zig else tweed[3]) if col_dark else (tweed[3] if zig else tweed[4]))
    for x in range(x0, x1 + 1): c.put(x, top, tweed[5] if x < x1 - 1 else tweed[4])
    # three buckled straps on the outer side
    bx = {'front': x1 if ft['side'] == 'R' else x0, 'back': x0 if ft['side'] == 'R' else x1, 'side': x1}[v]
    for y in (top + 1, top + 3, cy - 2):
        if v != 'side':
            P(c, [(bx, y), (bx - 1 if bx == x1 else bx + 1, y)], strap[2])
        c.put(bx, y, brass[4] if v != 'back' else brass[2])
    # strap under the instep
    for q in g['foot']:
        if q[1] == cy - 1 and abs(q[0] - (x0 + x1) // 2) <= 1: c.put(q[0], q[1], strap[1])
    # little snail climbing the front of one gaiter
    if _front_k(g, k) and v != 'back':
        sx = (x0 + x1) // 2 - 1 if v == 'front' else x1
        sy = top + 3
        P(c, [(sx, sy), (sx + 1, sy), (sx, sy + 1), (sx + 1, sy + 1)], wicker[4]); c.put(sx + 1, sy + 1, wicker[2]); c.put(sx, sy, wicker[5])
        P(c, [(sx - 1, sy + 2), (sx, sy + 2), (sx + 1, sy + 2)], feltgrey[4]); c.put(sx + 2, sy + 1, feltgrey[4])


FOOT = [
    dict(slug='nwe-alder-clogs', cat='footwear', shell=wood, upper=wood, sole=wood[0], rim=None, puff=0.5, toe=1, detail=_alder),
    dict(slug='nwe-drain-brogues', cat='footwear', shell=leather, upper=leather, sole=sole[1], rim=65, half=4, toe=1, detail=_brogue),
    dict(slug='nwe-felted-fleece-boots', cat='footwear', shell=feltgrey, upper=feltgrey, sole=feltgrey[0], rim=60, half=4, puff=0.5, detail=_feltboot),
    dict(slug='nwe-birch-bark-slippers', cat='footwear', shell=birch, upper=birch, sole=strap[1], rim=None, toe=1, detail=_barkslip),
    dict(slug='nwe-herringbone-gaiters', cat='footwear', shell=leather, upper=tweed, sole=sole[1], rim=59, half=4, detail=_gaiter),
]


# ======================================================================== BACKPACK
def _weave(c, m, r, x0=0):
    for q in m:
        a = ((q[0] - x0) // 2 + q[1]) % 2
        c.put(q[0], q[1], r[4] if a else r[3])


def _shade_right(c, m, r, n=2):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if q[0] > x1 - n: c.put(q[0], q[1], r[2])
        if q[1] == y1: c.put(q[0], q[1], r[1])


def _peat_bricks(c, x0, x1, y):
    """stacked dark peat bricks above a rim at row y (two courses)"""
    for row, (ya, off) in enumerate(((y - 2, 0), (y - 4, 2))):
        for xx in range(x0 + row, x1 + 1 - row):
            for yy in (ya, ya + 1):
                seam = (xx - x0 + off) % 5 == 0
                c.put(xx, yy, peat[1] if seam else (peat[4] if yy == ya and xx < x1 - 3 else peat[3]))


def _wren(c, x, y):
    """a tiny brown wren on a rim at (x, y) facing left, cocked tail up-right"""
    P(c, [(x, y), (x + 1, y), (x + 2, y)], wicker[2]); P(c, [(x, y - 1), (x + 1, y - 1)], wicker[3])
    c.put(x - 1, y - 1, wicker[4]); c.put(x - 1, y - 2, wicker[3]); c.put(x - 2, y - 1, brass[3])   # head + beak
    P(c, [(x + 3, y - 1), (x + 3, y - 2)], wicker[1]); c.put(x + 1, y, fleece[3])


def creel_back(c, x, y, g):
    m = poly([(x - 10, y + 1), (x + 9, y + 1), (x + 6, y + 14), (x - 7, y + 14)])
    _weave(c, m, wicker); _shade_right(c, m, wicker)
    # seen a little from above: peat bricks stacked inside the open top, a lit willow rim in front of them
    _peat_bricks(c, x - 9, x + 8, y + 5)
    for xx in range(x - 9, x + 9): c.put(xx, y + 5, wicker[5] if xx % 2 else wicker[4]); c.put(xx, y + 6, wicker[2])
    for xx in range(x - 10, x + 10): c.put(xx, y, wicker[4] if xx % 2 else wicker[3])
    P(c, [(x - 11, y + 3), (x - 12, y + 3), (x - 13, y + 3)], wicker[2])   # willow perch sticking out of the weave
    _wren(c, x - 12, y + 2)


def creel_side(c, x, y, g):
    m = poly([(x - 8, y + 1), (x, y + 1), (x, y + 14), (x - 5, y + 14)])
    _weave(c, m, wicker); _shade_right(c, m, wicker, 1)
    for xx in range(x - 8, x + 1):
        c.put(xx, y, wicker[5] if xx % 2 else wicker[4]); c.put(xx, y + 1, wicker[2])
    _peat_bricks(c, x - 7, x, y)
    _wren(c, x - 6, y - 1)
    for yy in range(y + 3, y + 12): c.put(x - 9 + (yy % 2 == 0) * 0, yy, rope[3] if yy % 2 else rope[1])   # rope handle loop


def _beads(c, pts):
    for (x, y) in pts:
        c.put(x, y, jay[5]); c.put(x, y + 1, jay[3])


def rolltop_back(c, x, y, g):
    m = rect(x - 7, y + 1, x + 6, y + 17) - M({(x - 7, y + 17), (x + 6, y + 17)})
    form(c, m, wax, frac=0.3, hi=[(x - 5, y + 3)])
    roll = rect(x - 8, y - 2, x + 7, y)
    form(c, roll, wax, frac=0.3)
    for xx in range(x - 8, x + 8): c.put(xx, y - 1, wax[2])
    for sx in (x - 8, x + 7):   # leather clips at the roll ends
        P(c, [(sx, y - 3), (sx, y - 2), (sx, y - 1), (sx, y), (sx, y + 1), (sx, y + 2)], leather[2]); c.put(sx, y - 3, leather[4])
    for yy in range(y - 2, y + 15): c.put(x - 1, yy, leather[3]); c.put(x, yy, leather[2])   # buckle strap
    P(c, [(x - 2, y + 8), (x - 1, y + 8), (x, y + 8), (x + 1, y + 8), (x - 2, y + 9), (x + 1, y + 9), (x - 2, y + 10), (x - 1, y + 10), (x, y + 10), (x + 1, y + 10)], brass[4])
    c.put(x + 1, y + 10, brass[2]); c.put(x - 1, y + 9, leather[2]); c.put(x, y + 9, leather[1])
    _beads(c, [(x - 5, y + 6), (x + 3, y + 4), (x - 4, y + 12), (x + 4, y + 13), (x + 2, y + 1)])


def rolltop_side(c, x, y, g):
    m = rect(x - 7, y + 1, x, y + 17) - M({(x - 7, y + 17)})
    form(c, m, wax, frac=0.25)
    form(c, rect(x - 8, y - 2, x, y), wax, frac=0.3)
    for xx in range(x - 8, x + 1): c.put(xx, y - 1, wax[2])
    P(c, [(x - 8, y - 3), (x - 8, y - 2), (x - 8, y - 1), (x - 8, y), (x - 8, y + 1)], leather[2])
    for yy in range(y + 2, y + 15): c.put(x - 4, yy, leather[2])
    P(c, [(x - 5, y + 8), (x - 4, y + 8), (x - 3, y + 8), (x - 5, y + 9), (x - 3, y + 9)], brass[4])
    _beads(c, [(x - 6, y + 5), (x - 2, y + 11), (x - 6, y + 13), (x - 2, y + 3)])


def _bee(c, x, y, f):
    dy = -1 if f % 2 else 0   # hovering
    P(c, [(x, y + dy), (x + 2, y + dy)], brass[4]); c.put(x + 1, y + dy, INK); c.put(x - 1, y + dy, INK)
    P(c, [(x, y - 1 + dy), (x + 1, y - 1 + dy)], jay[5])


def _heather_bundle(c, m):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        r = (q[0] * 7 + q[1] * 3) % 5
        col = heather[4] if r == 0 else heather[3] if r in (1, 2) else heather[2]
        if q[1] == y0 or (q[0], q[1] - 1) not in m: col = heather[5] if q[0] % 2 else heather[4]
        if q[1] >= y1 - 1: col = moss[1] if q[0] % 2 else wood[2]   # stems
        if q[0] > x1 - 2 and q[1] < y1 - 1: col = heather[2]
        c.put(q[0], q[1], col)


def heather_back(c, x, y, g):
    for rx in (x - 8, x + 7):
        form(c, rect(rx, y - 4, rx + 1, y + 17), wood, frac=0.5)
    for ry in (y - 3, y + 11, y + 15):
        for xx in range(x - 7, x + 7): c.put(xx, ry, wood[3] if ry != y + 15 else wood[2])
    bundle = ellipse(x - 0.5, y + 3, 9.5, 5) - rect(x - 12, y + 9, x + 12, y + 20)
    _heather_bundle(c, bundle)
    P(c, [(x - 11, y + 6), (x - 12, y + 7), (x + 10, y + 6), (x + 11, y + 7)], wood[3])   # sticks poking out
    for xx in range(x - 9, x + 9): c.put(xx, y + 5, rope[4] if xx % 2 else rope[2])          # rope lashing
    _bee(c, x + 13, y - 3, g['f'])


def heather_side(c, x, y, g):
    form(c, rect(x - 1, y - 4, x, y + 17), wood, frac=0.5)
    for ry in (y + 11, y + 15): c.put(x - 2, ry, wood[3])
    bundle = ellipse(x - 5, y + 3, 4.5, 5) - rect(x - 12, y + 9, x + 2, y + 20)
    _heather_bundle(c, bundle)
    P(c, [(x - 10, y + 2), (x - 11, y + 1)], wood[3])
    for yy in range(y - 1, y + 8): c.put(x - 5, yy, rope[4] if yy % 2 else rope[2])
    _bee(c, x - 10, y - 4, g['f'])


def _bark_weave(c, m):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        a = ((q[0] - x0) // 3 + (q[1] - y0) // 3) % 2
        col = birch[4] if a else birch[3]
        if (q[0] - x0) % 3 == 2 or (q[1] - y0) % 3 == 2: col = birch[2]
        if q[0] > x1 - 2: col = birch[2] if a else birch[1]
        if (q[0] * 3 + q[1]) % 11 == 0: col = birch[0]   # bark lenticel
        c.put(q[0], q[1], col)
    for q in m.bottom(): c.put(q[0], q[1], birch[1])


def _rowan(c, x, y):
    P(c, [(x, y), (x + 1, y), (x, y + 1), (x + 1, y + 1), (x + 2, y + 1), (x + 1, y + 2)], berry[3])
    c.put(x, y, berry[5]); c.put(x + 2, y + 1, berry[1]); c.put(x + 1, y + 2, berry[2])
    P(c, [(x + 2, y - 1), (x + 3, y - 2)], moss[3]); c.put(x + 3, y - 1, moss[4])


def barkbox_back(c, x, y, g):
    _bark_weave(c, rect(x - 8, y + 2, x + 7, y + 16))
    lid = rect(x - 9, y - 1, x + 8, y + 1)
    form(c, lid, birch, frac=0.3)
    for xx in range(x - 9, x + 9): c.put(xx, y + 1, strap[2])
    P(c, [(x - 1, y + 2), (x, y + 2), (x - 1, y + 3), (x, y + 3)], strap[3])   # lid catch
    for sx in (x - 5, x + 4): P(c, [(sx, y - 2), (sx + 1, y - 2)], strap[2])   # shoulder loops over the top
    for yy in range(y + 1, y + 4): c.put(x - 9, yy, rope[4])   # tie off the lid
    _rowan(c, x - 11, y + 4)


def barkbox_side(c, x, y, g):
    _bark_weave(c, rect(x - 8, y + 2, x, y + 16))
    form(c, rect(x - 9, y - 1, x, y + 1), birch, frac=0.3)
    for xx in range(x - 9, x + 1): c.put(xx, y + 1, strap[2])
    for yy in range(y - 2, y + 8): c.put(x + 1, yy, strap[2])
    _rowan(c, x - 9, y - 3)


def _fleece_cloud(c, m):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        col = fleece[4]
        if (q[0], q[1] - 1) not in m or (q[0] - 1, q[1]) not in m: col = fleece[5]
        if q[0] > x1 - (x1 - x0) * 0.3: col = fleece[3]
        if (q[0] * 2 + q[1] * 3) % 5 == 0: col = fleece[2] if col == fleece[3] else fleece[3]   # curls
        if (q[0], q[1] + 1) not in m: col = fleece[1]
        c.put(q[0], q[1], col)


def fleece_back(c, x, y, g):
    m = ellipse(x - 5, y + 4, 5, 4) | ellipse(x + 4, y + 3, 5, 4) | ellipse(x, y + 9, 7, 5) | ellipse(x - 8, y + 10, 4, 3.5) | ellipse(x + 7, y + 11, 4, 4) | ellipse(x - 2, y + 15, 5, 2.5)
    # knitting needles (behind the fleece, poking out top right)
    for i, ny in enumerate((y + 4, y + 7)):   # needles poking out to the right
        for s in range(8): c.put(x + 6 + s, ny - s // 2, wood[4] if s % 2 else wood[3])
        c.put(x + 14, ny - 4, berry[3]); c.put(x + 13, ny - 4, berry[4])
    _fleece_cloud(c, m)
    for s in range(-8, 9):   # cross of rope
        c.put(x + s, y + 8 + s // 2, rope[4] if s % 2 else rope[2])
        c.put(x + s, y + 8 - s // 2, rope[4] if s % 2 else rope[2])
    c.put(x, y + 8, rope[1])
    ball = ellipse(x + 8, y + 15, 1.5, 1.5)   # blue yarn ball
    for q in ball: c.put(q[0], q[1], woad[4] if (q[0] + q[1]) % 2 else woad[3])
    c.put(x + 9, y + 16, woad[1]); c.put(x + 7, y + 14, woad[5])


def fleece_side(c, x, y, g):
    m = ellipse(x - 5, y + 5, 5, 5) | ellipse(x - 4, y + 11, 6, 5)
    for s in range(9): c.put(x - 6 + s // 2, y + 3 - s, wood[4] if s % 2 else wood[3])
    c.put(x - 2, y - 6, berry[3])
    _fleece_cloud(c, m)
    for yy in range(y + 1, y + 16): c.put(x - 5 + (yy - y) // 6, yy, rope[4] if yy % 2 else rope[2])
    for q in ellipse(x - 9, y + 15, 1.5, 1.5): c.put(q[0], q[1], woad[4] if (q[0] + q[1]) % 2 else woad[3])
    c.put(x - 10, y + 14, woad[5])


PACK = [
    dict(slug='nwe-peat-creel', cat='backpack', back=creel_back, side=creel_side, y0=50),
    dict(slug='nwe-waxed-roll-top', cat='backpack', back=rolltop_back, side=rolltop_side, y0=49),
    dict(slug='nwe-heather-frame', cat='backpack', back=heather_back, side=heather_side, y0=49),
    dict(slug='nwe-bark-box-pack', cat='backpack', back=barkbox_back, side=barkbox_side, y0=50),
    dict(slug='nwe-fleece-bundle', cat='backpack', back=fleece_back, side=fleece_side),
]


# ======================================================================== COAT
def _cable(q, t, g):
    x, y = q[0], q[1] - g['b']
    ph = x % 5
    if ph == 0: return fleece[max(1, 2 - (t >= 2))]                 # purl gutter
    if ph in (2, 3):                                                 # the cable: crossing every 4 rows
        s = y % 4
        if (s == 0 and ph == 2) or (s == 2 and ph == 3): return fleece[min(5, 5 - t)]
        if s in (1, 3): return fleece[max(1, 3 - t)]
    return None


def _cablecoat(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        for y in (61, 64): P(c, [(30, y + b), (31, y + b)], wood[4]); c.put(31, y + b, wood[2])   # toggles on the opening
        pk = rect(39, 61 + b, 43, 64 + b)
        form(c, pk, fleece, frac=0.3)
        P(c, [(40, 62 + b), (41, 62 + b), (42, 63 + b), (40, 63 + b)], woad[3]); c.put(42, 62 + b, woad[4]); c.put(40, 62 + b, woad[1])   # knitted fish patch
    elif v == 'side':
        pk = rect(35 + hs, 60 + b, 39 + hs, 63 + b)
        form(c, pk, fleece, frac=0.3)
        P(c, [(36 + hs, 61 + b), (37 + hs, 61 + b), (38 + hs, 62 + b), (36 + hs, 62 + b)], woad[3]); c.put(38 + hs, 61 + b, woad[4])
    else:   # back: a ribbed hem band
        for x in range(19 + hs, 47 + hs):
            if c.get((x, 66 + b)) not in (None, INK): c.put(x, 66 + b, fleece[2] if x % 2 else fleece[3])


def _field(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    for s in g['sleeves']:   # brown cord cuffs
        bot = max(q[1] for q in s)
        for q in s:
            if q[1] >= bot - 1: c.put(q[0], q[1], felt[3] if q[1] == bot - 1 else felt[2])
    if v == 'front':
        for x0 in (23, 37):   # two bellows pockets below the beard
            pk = rect(x0, 60 + b, x0 + 5, 64 + b)
            form(c, pk, wax, frac=0.3)
            for x in range(x0, x0 + 6): c.put(x, 60 + b, wax[1])
            c.put(x0 + 2, 61 + b, brass[3])
        for x0, y0 in ((43, 46), (19, 47)):   # cord collar points at the shoulders
            P(c, [(x0, y0 + b), (x0 + 1, y0 + b), (x0 + 2, y0 + 1 + b), (x0, y0 + 1 + b), (x0 + 1, y0 + 1 + b)], felt[4]); c.put(x0 + 1, y0 + 1 + b, felt[2])
        P(c, [(46, 47 + b), (47, 46 + b)], berry[4]); c.put(47, 47 + b, brass[4]); c.put(46, 46 + b, jay[4])   # fishing fly on the collar
    elif v == 'back':
        for x in range(17, 48):
            if (x, 48 + b) in c and c[(x, 48 + b)] != INK and (x < 22 or x > 43): c.put(x, 48 + b, felt[3])
        for x in range(21 + hs, 45 + hs): c.put(x, 58 + b, wax[1] if x % 6 else wax[2])   # back yoke seam / game pocket
    else:
        for x in range(41, 44): c.put(x, 61 + b, wax[1])
        sl = g['sleeves'][0]
        top = min(sl, key=lambda q: (q[1], -q[0]))
        P(c, [(top[0] + 1, top[1] + 1), (top[0] + 2, top[1])], berry[4]); c.put(top[0] + 2, top[1] + 1, brass[4]); c.put(top[0] + 1, top[1], jay[4])


def _herring(q, t, g):
    x, y = q[0], q[1]
    zig = ((y + x) % 2) if (x // 2) % 2 else ((y - x) % 2)
    if zig: return tweed[max(1, 3 - t)]
    return None


def _waistcoat(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        for y in (60, 62, 64): P(c, [(32, y + b)], brass[4]); c.put(33, y + b, brass[2])
        for x0 in (24, 38): P(c, [(x, 61 + b) for x in range(x0, x0 + 4)], tweed[0])    # welt pockets
        P(c, [(39, 60 + b), (40, 60 + b)], strap[3]); c.put(39, 59 + b, strap[2]); P(c, [(39, 61 + b), (40, 61 + b)], wood[4])   # acorn
        for y in range(63, 65): c.put(32, y + b, tweed[1])
    elif v == 'back':
        for x in range(23, 43): c.put(x, 59 + b, tweed[1]); c.put(x, 60 + b, tweed[2])   # back belt
        P(c, [(32, 59 + b), (33, 59 + b), (32, 60 + b), (33, 60 + b)], brass[4]); c.put(33, 60 + b, brass[2])
    else:
        for x in range(37, 41): c.put(x + hs, 61 + b, tweed[0])
        P(c, [(38 + hs, 60 + b), (39 + hs, 60 + b)], strap[3]); c.put(38 + hs, 59 + b, strap[2]); P(c, [(38 + hs, 61 + b), (39 + hs, 61 + b)], wood[4])


def _smock_pat(q, t, g):
    if (q[0] * 2 + q[1]) % 9 == 0 and t < 3: return tanbark[2]   # sailcloth slub
    return None


def _smock(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        pouch = poly([(26, 60 + b), (39, 60 + b), (40, 65 + b), (25, 65 + b)])
        form(c, pouch, tanbark, frac=0.3, rim=False)
        for q in pouch.top(): c.put(q[0], q[1], tanbark[1])
        for y in range(61, 65): c.put(32, y + b, tanbark[2])
        P(c, [(31, 60 + b), (30, 61 + b), (34, 60 + b), (35, 61 + b)], canvas[4]); P(c, [(30, 62 + b), (35, 62 + b)], canvas[2])   # drawstring ends
        P(c, [(44, 48 + b), (45, 47 + b), (46, 46 + b), (47, 45 + b)], CREAM); P(c, [(45, 48 + b), (46, 47 + b)], mist[4]); c.put(47, 46 + b, mist[3])   # gull feather
    elif v == 'side':
        pouch = rect(36 + hs, 60 + b, 41 + hs, 64 + b)
        form(c, pouch, tanbark, frac=0.3, rim=False)
        for q in pouch.top(): c.put(q[0], q[1], tanbark[1])
        P(c, [(44, 51 + b), (45, 50 + b), (46, 49 + b), (47, 48 + b)], CREAM); P(c, [(45, 51 + b), (46, 50 + b)], mist[4])
    else:
        for x in range(21 + hs, 45 + hs):   # hem stitching
            if c.get((x, 64 + b)) not in (None, INK): c.put(x, 64 + b, tanbark[2] if x % 2 else tanbark[4])
        P(c, [(17, 47 + b), (18, 46 + b), (19, 45 + b)], CREAM); c.put(18, 47 + b, mist[4])


def _diamond(q, t, g):
    x, y = q[0], q[1] - g['b']
    if (x + y) % 6 == 0 or (x - y) % 6 == 0: return eider[max(1, 2 - (t >= 2))]
    if (x + y) % 6 == 1 and t < 2: return eider[5]
    return None


def _eider(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        for x0 in (18, 43):   # high collar beside the beard, woad lining showing
            for q in rect(x0, 45 + b, x0 + 3, 47 + b): c.put(q[0], q[1], eider[4] if q[1] < 47 + b else eider[2])
            P(c, [(x0 + (3 if x0 < 30 else 0), 45 + b), (x0 + (3 if x0 < 30 else 0), 46 + b)], woad[3])
        sl = g['sleeves'][1]
        q = max(sl, key=lambda p: (p[0], -p[1]))
        P(c, [(q[0] + 1, q[1] - 1), (q[0] + 2, q[1] - 2)], CREAM); c.put(q[0] + 1, q[1] - 2, eider[5])   # feather escaping a seam
    elif v == 'back':
        for x in range(18, 48):
            if c.get((x, 47 + b)) not in (None, INK) and (x < 21 or x > 44): c.put(x, 47 + b, woad[3])
        sl = g['sleeves'][0]
        q = min(sl, key=lambda p: (p[0], -p[1]))
        P(c, [(q[0] - 1, q[1] - 1), (q[0] - 2, q[1] - 2)], CREAM); c.put(q[0] - 1, q[1] - 2, eider[5])
    else:
        sl = g['sleeves'][0]
        q = max(sl, key=lambda p: (p[1], p[0]))
        P(c, [(q[0] + 1, q[1] - 2), (q[0] + 2, q[1] - 3)], CREAM); c.put(q[0] + 2, q[1] - 2, eider[5])


COAT = [
    dict(slug='nwe-cable-knit-long-coat', cat='coat', r=fleece, hem=3, open=2, pattern=_cable, detail=_cablecoat),
    dict(slug='nwe-waxed-field-jacket', cat='coat', r=wax, hem=1, detail=_field),
    dict(slug='nwe-tweed-waistcoat', cat='coat', r=tweed, sleeves=False, pattern=_herring, detail=_waistcoat),
    dict(slug='nwe-tanbark-smock', cat='coat', r=tanbark, hem=2, puff=1, pattern=_smock_pat, detail=_smock),
    dict(slug='nwe-eiderdown-coat', cat='coat', r=eider, puff=1, hem=1, pattern=_diamond, detail=_eider),
]


# ======================================================================== CLOAK
def _shawl(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # knit purl speckle
        if (q[0] * 3 + q[1] * 2) % 5 == 0 and c.get(q) not in (INK, heather[1]): c.put(q[0], q[1], heather[4] if q[0] < (x0 + x1) / 2 else heather[2])
    # fringe: strands hanging off every other bottom pixel
    for q in m.bottom():
        if (q[0] + g['tail']) % 2 == 0:
            n = 2 if (q[0] // 2) % 2 else 3
            for k in range(1, n + 1): c.put(q[0], q[1] + k, heather[2] if k < n else heather[3])
    if v == 'back':   # leaf-shaped wooden shawl pin at the top right
        b = g['b']
        P(c, [(40, 51 + b), (41, 50 + b), (42, 50 + b), (43, 49 + b)], wood[4]); P(c, [(41, 51 + b), (42, 51 + b)], wood[2]); c.put(39, 52 + b, wood[1])
        c.put(44, 48 + b, wood[3])
    elif v == 'side':
        b = g['b']
        P(c, [(24, 50 + b), (25, 49 + b), (26, 49 + b)], wood[4]); c.put(25, 50 + b, wood[2]); c.put(23, 51 + b, wood[1])


def _raincape(c, g, m, v):
    b, tl, f = g['b'], g['tail'], g['f']
    x0, y0, x1, y1 = m.bbox()
    if v == 'back':
        for q in m:   # oilcloth panel seams
            if q[0] in (25 + tl, 40 + tl) and q[1] > y0 + 5 and (q[0] + 1, q[1]) in m: c.put(q[0], q[1], mustard[2])
        hood = ellipse(32.5, 51 + b, 6.5, 4) | poly([(28, 53 + b), (37, 53 + b), (35 + tl, 59 + b), (34 + tl, 59 + b)])
        form(c, hood, mustard, frac=0.35)
        inner = ellipse(32.5, 50 + b, 4, 2)
        for q in inner: c.put(q[0], q[1], mustard[1])
        for q in hood.bottom(): c.put(q[0], q[1], mustard[1])
        P(c, [(33 + tl, 60 + b), (34 + tl, 60 + b)], wood[4]); c.put(34 + tl, 60 + b, wood[2])   # toggle on the hood tip
    elif v == 'side':
        hood = ellipse(24.5, 50 + b, 3, 4) | poly([(22, 52 + b), (26, 52 + b), (21 + tl, 57 + b)])
        form(c, hood, mustard, frac=0.3)
        for y in range(47, 54): c.put(26, y + b, mustard[1])
    # raindrop rolling off the hem (falls a pixel per frame, loops)
    if v != 'front':
        bx = x1 - 1 if v == 'back' else x0 + 1
        hemq = [q for q in m if q[0] == bx]
        if hemq:
            hy = max(q[1] for q in hemq)
            d = (f - 1) % 4
            c.put(bx, hy + 1 + d, jay[4]); c.put(bx, hy + 2 + d, jay[3]); c.put(bx, hy + 1 + d, jay[5] if d == 0 else jay[4])
    else:
        hemq = [q for q in m if q[0] == x1 - 2]
        if hemq:
            hy = max(q[1] for q in hemq); d = (f - 1) % 4
            P(c, [(x1 - 2, hy + 1 + d)], jay[5]); c.put(x1 - 2, hy + 2 + d, jay[3])


def _sheepskin(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    tl = g['tail']
    # shaggy lumpy hem: pop pixels to make curl lumps
    for q in list(m):
        if q[1] >= y1 - 1 and (q[0] + tl) % 4 in (0,) : c.pop(q, None)
        if q[1] == y1 and (q[0] + tl) % 4 == 1: c.pop(q, None)
    for q in m:   # curls
        if q not in c: continue
        r = (q[0] * 2 + q[1] * 3) % 5
        if r == 0: c.put(q[0], q[1], fleece[2] if c[q] in (fleece[2], fleece[3]) else fleece[3])
        elif r == 2 and c[q] == fleece[3]: c.put(q[0], q[1], fleece[4])
    b = g['b']
    if v == 'back':   # brown burr in the curls
        bx, by = 39, 53 + b
        P(c, [(bx, by), (bx + 1, by), (bx, by + 1), (bx + 1, by + 1)], strap[2]); c.put(bx, by, strap[4])
        P(c, [(bx - 1, by - 1), (bx + 2, by - 1), (bx - 1, by + 2), (bx + 2, by + 2)], strap[1])
    elif v == 'side':
        bx, by = 24, 53 + b
        P(c, [(bx, by), (bx + 1, by), (bx, by + 1), (bx + 1, by + 1)], strap[2]); c.put(bx, by, strap[4])
        P(c, [(bx - 1, by - 1), (bx + 2, by - 1), (bx - 1, by + 2)], strap[1])
        P(c, [(27, 47 + b), (28, 48 + b), (28, 49 + b)], leather[2])   # leather thong at the neck


def _thatch(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    tl, b = g['tail'], g['b']
    tiers = list(range(y0 + 4, y1 + 1, 5))
    for q in m:
        if c.get(q) == INK: continue
        col = straw[4] if q[0] % 2 else straw[3]
        if q[0] > x1 - (x1 - x0) * 0.3: col = straw[3] if q[0] % 2 else straw[2]
        if v == 'side' and q[0] < x0 + 3: col = straw[2]
        for ty in tiers:   # tier edge: ragged ends of the rush bundles
            if q[1] == ty: col = straw[1] if (q[0] + tl) % 2 else straw[2]
            if q[1] == ty - 1 and (q[0] + tl) % 3 == 0: col = straw[2]
            if q[1] == ty + 1: col = straw[5] if q[0] % 2 else straw[4]
        c.put(q[0], q[1], col)
    for q in m.bottom():
        if (q[0] + tl) % 2: c.put(q[0], q[1] + 1, straw[2])
    # little green frog sitting on a tier
    ty = tiers[1] if len(tiers) > 1 else tiers[0]
    fx = (x1 - 6) if v == 'back' else (x0 + 4) if v == 'side' else None
    if fx is not None:
        P(c, [(fx, ty - 1), (fx + 1, ty - 1), (fx + 2, ty - 1), (fx, ty - 2), (fx + 1, ty - 2)], frog[3])
        c.put(fx + 2, ty - 2, frog[5]); c.put(fx + 2, ty - 3, frog[4]); c.put(fx + 2, ty - 2, INK)
        c.put(fx - 1, ty - 1, frog[1]); c.put(fx, ty - 1, frog[2])
    if v == 'side':
        P(c, [(27, 47 + b), (27, 48 + b), (26, 49 + b)], rope[4])


def _woad(c, g, m, v):
    b, tl = g['b'], g['tail']
    if v == 'back':
        hood = ellipse(32.5, 52 + b, 7, 5)
        form(c, hood, mist, frac=0.35)
        inner = ellipse(32.5, 51 + b, 4.5, 2.5)
        for q in hood - inner:
            if q[1] >= 50 + b and q not in hood.bottom(): c.put(q[0], q[1], woad[3] if (q[0] + q[1]) % 4 else woad[4])
        for q in inner: c.put(q[0], q[1], mist[1])
        for q in hood.bottom(): c.put(q[0], q[1], woad[1])
        mx, my = 36, 54 + b   # pale moth resting on the hood
    elif v == 'side':
        hood = ellipse(24.5, 51 + b, 3, 4.5)
        form(c, hood, mist, frac=0.3)
        for q in hood:
            if q[0] >= 27: c.put(q[0], q[1], woad[3])
        mx, my = 22, 51 + b
    else:
        return
    P(c, [(mx, my), (mx + 2, my)], fleece[4]); P(c, [(mx, my + 1), (mx + 2, my + 1)], fleece[3]); c.put(mx + 1, my, fleece[1]); c.put(mx + 1, my + 1, fleece[1])
    c.put(mx, my, CREAM)


CLOAK = [
    dict(slug='nwe-heather-shawl', cat='cloak', r=heather, lining=heather, len=64, flare=3, x0=19, x1=46, hemstyle='tri', fx0=15, fx1=50, detail=_shawl),
    dict(slug='nwe-mustard-rain-cape', cat='cloak', r=mustard, lining=mustard, len=60, flare=5, x0=20, x1=45, front_wide=3, fx0=14, fx1=51, side_back=19, folds=(), detail=_raincape),
    dict(slug='nwe-sheepskin-mantle', cat='cloak', r=fleece, lining=fleece, len=56, flare=2, x0=19, x1=46, fx0=14, fx1=51, side_back=21, folds=(), detail=_sheepskin),
    dict(slug='nwe-rush-thatch-cape', cat='cloak', r=straw, lining=straw, len=64, flare=6, x0=23, x1=42, fx0=16, fx1=49, side_back=17, folds=(), detail=_thatch),
    dict(slug='nwe-woad-mist-cloak', cat='cloak', r=mist, lining=mist, len=68, flare=3, border=woad, border_rows=2, border_sides=True, side_back=18, detail=_woad),
]

ITEMS = FOOT + PACK + COAT + CLOAK
