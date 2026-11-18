"""Olivewhistle Shore (SE): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/SE/common.lua (R.*)
and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light): SE common.lua
olive = ["#2c3320", "#3f4a26", "#56622e", "#717c36", "#929a48", "#b8bc6a"]
sage = ["#2a3a34", "#3e5446", "#587058", "#768c6c", "#98a886", "#c2caa6"]
lemon = ["#6e4a14", "#a0701a", "#d4a020", "#f0c830", "#fae25a", "#fff4a0"]
terra = ["#5a2a22", "#82382a", "#a84c32", "#c8653c", "#de8650", "#eeac74"]
sea = ["#1c2c5c", "#24467e", "#2e64a2", "#3e86c0", "#62aad6", "#9ad0e6"]
linen = ["#5e5048", "#857464", "#a8977e", "#c8b898", "#e2d6b6", "#f4ecd2"]
jute = ["#4a3420", "#6a4c2c", "#8c6838", "#ac8644", "#c8a45a", "#e2c47c"]
cork = ["#4c2e22", "#6e4430", "#8e5c3c", "#ae7a4e", "#c89a66", "#e0ba84"]
grape = ["#2e1a36", "#46224a", "#62305e", "#803e72", "#9e5a8a", "#c084a8"]
wine = ["#3a1626", "#561e30", "#72283a", "#8e3644", "#aa4c50", "#c66e62"]
fleece = ["#6a5a4c", "#8c7a66", "#ae9c82", "#cabca0", "#e2d8bc", "#f4eed8"]
goat = ["#3e3230", "#5a4842", "#786256", "#967e6a", "#b49c84", "#d0bca2"]
indigo = ["#1a1c40", "#262c5e", "#34407c", "#465a9a", "#6078b4", "#8ca0cc"]
coral = ["#6a1e2a", "#962c34", "#c0403e", "#de5e4c", "#f08466", "#fab094"]
saffron = ["#7a3a14", "#a85618", "#d07a1e", "#ec9e2c", "#f8c04a", "#ffdc80"]
wicker = ["#4e3a22", "#70542e", "#94723c", "#b4904c", "#ceae66", "#e6cc8a"]
leaf = ["#1e3a24", "#2a5230", "#3a6e38", "#4f8c40", "#72aa4e", "#a2cc6a"]
# ---- reused from W.R (gnome-wear/_gw.lua)
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
felt = ["#3a2026", "#552f2c", "#704033", "#8a5239", "#a66a45", "#c48a5a"]
cuffL = ["#4a2a22", "#6b3d2c", "#88523a", "#a26846", "#b98257", "#d0a070"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
steel = ["#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2"]
# ---- derived (item-specific, from the icons)
tan = ["#6e4430", "#8e5c3c", "#ae7a4e", "#c89a66", "#e0ba84", "#f2d6a6"]    # pale treader leather (cork light end)
skin = ["#51302b", "#a8644a", "#c98462", "#f0b98d", "#ffe0bd", "#fff0dc"]   # gnome default skin, for bare feet in sandals


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


# ======================================================================== FOOTWEAR
def _rope(c, g, ft, k):
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    foot = g['foot']
    x0, _, x1, y1 = foot.bbox()
    rx = x1 - (x1 - x0 + 1) * 0.35
    for q in foot:
        if q[1] >= y1 - 1:      # thick coiled jute sole: 2 rows, coil ticks
            col = jute[4] if (q[0] + (q[1] == y1)) % 2 else jute[2]
            if q[1] == y1: col = jute[1] if q[0] % 2 else jute[2]
        elif (q[1] - cy) % 2 == 0:   # sea stripe
            col = sea[2] if q[0] > rx else sea[3]
        else:
            col = linen[3] if q[0] > rx else linen[4]
        c.put(q[0], q[1], col)
    if v != 'back': c.put(int(cx) - 2, y1 - 3, linen[5])
    # ankle ribbon: a sea-blue tie at the top of the foot with a tail
    top = foot.bbox()[1]
    if v == 'side':
        P(c, [(int(cx) - 2, top - 1), (int(cx) - 1, top - 1), (int(cx) - 3, top), (int(cx) - 4, top + 1)], sea[4])
        if not g['far']: P(c, [(int(cx) - 5, top + 1), (int(cx) - 5, top + 2)], coral[4]); c.put(int(cx) - 6, top + 2, coral[2])
    else:
        P(c, [(int(cx) - 1, top - 1), (int(cx), top - 1), (int(cx) + 1, top - 1)], sea[4])
        tx = x1 + 1 if ft['side'] == 'R' else x0 - 1
        P(c, [(tx, top), (tx, top + 1)], sea[3])
        if k == 1 and v == 'front': P(c, [(tx, top + 2), (tx + 1, top + 2)], coral[4]); c.put(tx, top + 3, coral[2])


def _sandal(c, g, ft, k):
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    foot, shaft = g['foot'], g['shaft']
    x0, y0, x1, y1 = foot.bbox()
    for q in foot.bottom(): c.put(q[0], q[1], leather[1])   # leather sole under the bare foot
    for q in foot:
        if (q[0], q[1] + 2) not in foot and (q[0], q[1] + 1) in foot: c.put(q[0], q[1], leather[3] if q[0] < x1 - 2 else leather[2])
    # crossed straps over the instep and laces up the ankle
    for q in foot | shaft:
        if q[1] < y1 - 1 and (q[0] + q[1]) % 4 == 0 or q[1] < y1 - 1 and (q[0] - q[1]) % 4 == 0 and q[1] <= y0 + 1:
            c.put(q[0], q[1], leather[2] if q[0] > x1 - 3 else leather[4])
    for q in shaft:
        if (q[0] + q[1]) % 3 == 0 or (q[0] - q[1]) % 3 == 0: c.put(q[0], q[1], strap[2] if q[0] > g['sx1'] - 2 else strap[4])
    if v != 'back': P(c, [(int(cx) - 1, cy - 1)], leather[3])   # toe loop
    # buckle ring + olive-leaf charm with two olives
    if v == 'side':
        bx, by = int(cx) - 3, cy - 1
        c.put(bx, by, brass[4])
        if not g['far']: P(c, [(bx - 1, by + 1)], sage[4]); P(c, [(bx - 2, by + 1)], olive[1]); c.put(bx - 2, by + 2, olive[2])
    else:
        bx = x1 if ft['side'] == 'R' else x0
        c.put(bx, cy - 1, brass[4])
        if k == 1 and v == 'front':
            P(c, [(bx + 1, cy), (bx + 2, cy - 1)], sage[4]); c.put(bx + 1, cy + 1, olive[1]); c.put(bx + 2, cy, olive[2])


def _corkclog(c, g, ft, k):
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # tall speckled cork sole: lowest 3 rows (plus a row below the foot)
    sole = M(q for q in foot if q[1] >= y1 - 2) | M((x, y1 + 1) for x in range(x0 + 1, x1))
    for q in sole:
        col = cork[3] if q[0] < x1 - 2 else cork[2]
        if q[1] == y1 - 2: col = cork[4] if q[0] < x1 - 2 else cork[3]
        if (q[0] * 5 + q[1] * 3) % 7 == 0: col = cork[1]
        elif (q[0] * 3 + q[1]) % 9 == 0: col = cork[5]
        if q[1] == y1 + 1: col = cork[1]
        c.put(q[0], q[1], col)
    # acorn on a pin on the toe cap
    if v != 'back' and (k == 1 or v == 'side') and not g.get('far'):
        ax = int(cx) + (2 if v == 'side' else 0)
        P(c, [(ax, y0), (ax + 1, y0)], cork[1]); c.put(ax, y0 + 1, olive[4]); c.put(ax + 1, y0 + 1, olive[3])


def _wraps(c, g, ft, k):
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    top, x0, x1 = g['top'], g['sx0'], g['sx1']
    shaft = g['shaft']
    sx = x1 - (x1 - x0 + 1) * 0.35
    for q in shaft:
        if q[1] >= cy - 2: continue
        s = (q[0] + q[1]) % 3
        col = goat[4] if s == 0 else goat[3] if s == 1 else goat[2]
        if q[0] > sx: col = goat[2] if s else goat[1]
        c.put(q[0], q[1], col)
    # cross-gartered leather thongs: an X every 3 rows
    for y in range(top + 1, cy - 2):
        i = (y - top) % 4
        for x in (x0 + i, x1 - i):
            if x0 <= x <= x1: c.put(x, y, strap[2] if x > sx else strap[4])
    for x in range(x0, x1 + 1): c.put(x, top, goat[4] if x % 2 else goat[3])   # rolled top wrap
    # thyme sprig tucked in the top wrap
    if (k == 0 and v != 'side') or (v == 'side' and not g['far']):
        tx = x0 + 1
        P(c, [(tx, top - 1), (tx, top - 2), (tx - 1, top - 3)], leaf[3]); c.put(tx + 1, top - 2, leaf[4])
        P(c, [(tx - 1, top - 4), (tx, top - 3)], grape[5])


def _treaders(c, g, ft, k):
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    foot, shaft = g['foot'], g['shaft']
    x0, y0, x1, y1 = (foot | shaft).bbox()
    rx = x1 - (x1 - x0 + 1) * 0.35
    # grape stain from the sole up to the ankle, ragged top edge
    for q in foot | shaft:
        lim = cy - 1 - (1 if (q[0] * 7) % 3 == 0 else 0) + (1 if q[0] % 4 == 1 else 0)
        if q[1] >= lim and q[1] < y1:
            col = grape[3] if q[0] <= rx else grape[2]
            if q[1] == lim: col = grape[4] if q[0] <= rx else grape[3]
            c.put(q[0], q[1], col)
    for q in foot.bottom(): c.put(q[0], q[1], grape[1])
    # slouch wrinkle
    for x in range(g['sx0'] + 1, g['sx1']):
        if x % 3 == 0: c.put(x, g['top'] + 3, tan[2])
    # one plump grape stuck on the toe
    if v != 'back' and (k == 1 or (v == 'side' and not g['far'])):
        gx = int(cx) + (3 if v == 'side' else 1)
        P(c, [(gx, cy - 1), (gx + 1, cy - 1), (gx, cy)], grape[3]); c.put(gx + 1, cy, grape[2]); c.put(gx, cy - 1, grape[5])


FOOT = [
    dict(slug='se-rope-slips', cat='footwear', shell=linen, sole=jute[1], rim=None, toe=1, detail=_rope),
    dict(slug='se-sunpath-sandals', cat='footwear', shell=skin, upper=skin, sole=leather[1], rim=64, half=3, detail=_sandal),
    dict(slug='se-corkbark-clogs', cat='footwear', shell=terra, sole=cork[1], rim=None, puff=0.5, toe=1, detail=_corkclog),
    dict(slug='se-thyme-hill-wraps', cat='footwear', shell=leather, upper=goat, sole=leather[1], rim=60, half=4, detail=_wraps),
    dict(slug='se-harvest-treaders', cat='footwear', shell=tan, upper=tan, cuff=linen, cuff_rows=2, sole=grape[1], rim=62, half=4, puff=0.5, detail=_treaders),
]


# ======================================================================== BACKPACK
def _shade_right(c, m, r, n=2):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if q[0] > x1 - n: c.put(q[0], q[1], r[2])
        if q[1] == y1: c.put(q[0], q[1], r[1])


def _wicker(c, m, r):
    for q in m:
        c.put(q[0], q[1], r[4] if (q[0] // 2 + q[1] // 2) % 2 else r[3])
        if q[0] % 4 == 0: c.put(q[0], q[1], r[2])   # upright stakes


def _olives(c, pts):
    for x, y, kind in pts:
        if kind == 'l': c.put(x, y, sage[4])
        elif kind == 'L': c.put(x, y, sage[5])
        elif kind == 'd': c.put(x, y, sage[2])
        elif kind == 'o': c.put(x, y, grape[2])
        elif kind == 'O': c.put(x, y, grape[4])
        elif kind == 'g': c.put(x, y, olive[3])


def _snail(c, x, y, face=1):
    P(c, [(x, y), (x + face, y)], terra[4]); P(c, [(x, y + 1), (x + face, y + 1)], terra[2]); c.put(x + face, y, saffron[4])
    P(c, [(x - face, y + 1)], linen[3]); c.put(x - face, y, linen[4])


def creel_back(c, x, y, g):
    m = poly([(x - 8, y + 1), (x + 8, y + 1), (x + 6, y + 16), (x - 6, y + 16)])
    _wicker(c, m, wicker); _shade_right(c, m, wicker)
    rim = rect(x - 9, y - 1, x + 8, y + 1)
    for q in rim: c.put(q[0], q[1], wicker[5] if (q[0] + q[1]) % 3 == 0 else wicker[4] if q[1] < y + 1 else wicker[2])
    # silvery olive branch with dark olives spilling over the rim
    _olives(c, [(x - 6, y - 2, 'l'), (x - 5, y - 3, 'L'), (x - 4, y - 2, 'd'), (x - 3, y - 4, 'l'), (x - 2, y - 3, 'o'), (x - 1, y - 3, 'O'),
                (x, y - 2, 'l'), (x + 1, y - 4, 'L'), (x + 2, y - 3, 'l'), (x + 3, y - 2, 'o'), (x + 4, y - 3, 'd'), (x + 5, y - 4, 'l'),
                (x + 4, y - 2, 'O'), (x - 3, y - 2, 'o'), (x + 9, y, 'l'), (x + 10, y + 1, 'L'), (x + 9, y + 2, 'o')])
    _snail(c, x + 5, y + 9, 1)


def creel_side(c, x, y, g):
    m = poly([(x - 8, y + 1), (x, y + 1), (x, y + 16), (x - 6, y + 16)])
    _wicker(c, m, wicker); _shade_right(c, m, wicker, 1)
    for q in rect(x - 9, y - 1, x, y + 1): c.put(q[0], q[1], wicker[5] if (q[0] + q[1]) % 3 == 0 else wicker[4] if q[1] < y + 1 else wicker[2])
    _olives(c, [(x - 7, y - 2, 'l'), (x - 6, y - 3, 'L'), (x - 5, y - 2, 'o'), (x - 4, y - 3, 'O'), (x - 3, y - 2, 'l'), (x - 2, y - 4, 'L'),
                (x - 8, y - 3, 'd'), (x - 10, y, 'l'), (x - 11, y + 1, 'L'), (x - 10, y + 2, 'o')])
    _snail(c, x - 5, y + 10, -1)


def net_back(c, x, y, g):
    bag = ellipse(x - 0.5, y + 9, 8, 7.5)
    form(c, bag, jute, frac=0.3)
    for cx_, cy_, rr, r in ((x - 4, y + 12, 3, cork), (x + 3, y + 12, 2.5, cork), (x + 2, y + 5, 2.5, lemon), (x - 3, y + 5, 2.5, sea)):
        e = ellipse(cx_, cy_, rr, rr) & bag
        form(c, e, r, frac=0.4, hi=[(int(cx_) - 1, int(cy_) - 1)])
    for q in bag:   # knotted cord mesh
        a, b = (q[0] + q[1]) % 4 == 0, (q[0] - q[1]) % 4 == 0
        if a or b: c.put(q[0], q[1], jute[4] if a and b else jute[1])
    for q in rect(x - 2, y - 1, x + 1, y + 1): c.put(q[0], q[1], jute[3] if q[0] < x else jute[2])   # cinched neck
    for q in line([(x - 2, y - 1), (x - 2, y - 3), (x - 1, y - 4), (x, y - 4), (x + 1, y - 3), (x + 1, y - 1)]): c.put(q[0], q[1], jute[4])
    # silver fish charm hanging from the knot
    P(c, [(x + 2, y + 1), (x + 3, y + 2)], jute[2])
    P(c, [(x + 4, y + 3), (x + 5, y + 3), (x + 6, y + 3)], steel[4]); c.put(x + 5, y + 4, steel[2]); c.put(x + 7, y + 2, steel[3]); c.put(x + 7, y + 4, steel[3])
    c.put(x + 4, y + 3, steel[5])


def net_side(c, x, y, g):
    bag = ellipse(x - 4.5, y + 9, 4.5, 7.5)
    form(c, bag, jute, frac=0.3)
    for cx_, cy_, rr, r in ((x - 5, y + 12, 2.5, cork), (x - 4, y + 5, 2, lemon)):
        form(c, ellipse(cx_, cy_, rr, rr) & bag, r, frac=0.4)
    for q in bag:
        a, b = (q[0] + q[1]) % 4 == 0, (q[0] - q[1]) % 4 == 0
        if a or b: c.put(q[0], q[1], jute[4] if a and b else jute[1])
    for q in rect(x - 5, y - 1, x - 3, y + 1): c.put(q[0], q[1], jute[3])
    for q in line([(x - 4, y - 1), (x - 3, y - 3), (x - 1, y - 3), (x, y - 1)]): c.put(q[0], q[1], jute[4])
    P(c, [(x - 9, y + 2), (x - 10, y + 3), (x - 11, y + 3)], steel[4]); c.put(x - 12, y + 2, steel[3]); c.put(x - 12, y + 4, steel[3]); c.put(x - 10, y + 4, steel[2])


def _amphora(c, cx, y, half=5):
    body = ellipse(cx - 0.5, y + 7, half, 5.5) | poly([(cx - 3, y + 11), (cx + 2, y + 11), (cx, y + 15), (cx - 1, y + 15)])
    neck = rect(cx - 2, y, cx + 1, y + 2)
    lip = rect(cx - 3, y - 1, cx + 2, y - 1)
    form(c, body | neck, terra, frac=0.35, hi=[(cx - 3, y + 4)])
    form(c, lip, terra, frac=0.3, under=False)
    for q in rect(cx - 2, y - 2, cx + 1, y - 2): c.put(q[0], q[1], cork[3] if q[0] < cx else cork[2])   # cork stopper
    return body


def amph_back(c, x, y, g):
    for rx in (x - 8, x + 7):
        form(c, rect(rx, y - 3, rx + 1, y + 17), wood, frac=0.5)
    for yy in (y - 2, y + 7, y + 16): form(c, rect(x - 7, yy, x + 6, yy), wood, frac=0.2, rim=False)
    _amphora(c, x, y)
    for hx in (x - 4, x + 3):   # handles
        P(c, [(hx, y + 1), (hx + (1 if hx > x else -1), y + 2), (hx + (1 if hx > x else -1), y + 3)], terra[2])
    for yy in (y + 4, y + 10):   # rope lashings
        for xx in range(x - 7, x + 7): c.put(xx, yy, jute[4] if xx % 2 else jute[2])
    # lemon-yellow tassel off the stopper
    P(c, [(x + 2, y - 2), (x + 3, y - 1)], jute[3]); P(c, [(x + 4, y), (x + 4, y + 1), (x + 5, y + 1)], lemon[4]); c.put(x + 5, y + 2, lemon[2])


def amph_side(c, x, y, g):
    form(c, rect(x - 1, y - 3, x, y + 17), wood, frac=0.5)
    _amphora(c, x - 6, y, half=4)
    for yy in (y + 4, y + 10):
        for xx in range(x - 10, x + 1): c.put(xx, yy, jute[4] if xx % 2 else jute[2])
    P(c, [(x - 9, y - 2), (x - 10, y - 1)], jute[3]); P(c, [(x - 11, y), (x - 11, y + 1), (x - 12, y + 1)], lemon[4]); c.put(x - 11, y + 2, lemon[2])


def _stripes(c, m, rx):
    _, y0, _, y1 = m.bbox()
    for q in m:
        band = ((q[1] - y0) // 2) % 2
        if q[1] - y0 < 2: band = 1
        r = sea if band == 0 else linen
        col = r[3] if q[0] <= rx else r[2]
        if q[1] == y1: col = r[1]
        c.put(q[0], q[1], col)
    for q in m:
        if (q[0] * 3 + q[1] * 5) % 11 == 0 and q[1] < y1: c.put(q[0], q[1], linen[5] if c.get(q) in (linen[3],) else c.get(q))


def seabag_back(c, x, y, g):
    m = rect(x - 6, y + 1, x + 5, y + 15) - M({(x - 6, y + 1), (x + 5, y + 1), (x - 6, y + 15), (x + 5, y + 15)})
    _stripes(c, m, x + 2)
    for q in m.cols(x - 6, x - 6): c.put(q[0], q[1], c[q] if c[q] in (sea[1], linen[1]) else (sea[4] if c[q] == sea[3] else linen[4]))
    top = poly([(x - 4, y - 3), (x + 3, y - 3), (x + 5, y + 1), (x - 6, y + 1)])
    form(c, top, linen, frac=0.35)
    for xx in range(x - 3, x + 3, 2): c.put(xx, y - 1, linen[2])   # gathers
    for xx in range(x - 4, x + 4): c.put(xx, y, jute[2] if xx % 2 else jute[4])   # drawstring
    # rope shoulder loop on the right side
    for q in line([(x + 4, y - 1), (x + 7, y + 2), (x + 8, y + 7), (x + 7, y + 12), (x + 5, y + 14)]): c.put(q[0], q[1], jute[4] if q[1] % 2 else jute[2])
    # coral starfish tied to the drawstring
    sx, sy = x - 4, y + 2
    P(c, [(sx, sy - 1), (sx - 1, sy), (sx + 1, sy), (sx - 1, sy + 1), (sx + 1, sy + 1)], coral[3]); c.put(sx, sy, coral[5])


def seabag_side(c, x, y, g):
    m = rect(x - 8, y + 1, x, y + 15) - M({(x - 8, y + 1), (x - 8, y + 15)})
    _stripes(c, m, x - 2)
    form(c, poly([(x - 7, y - 3), (x - 1, y - 3), (x, y + 1), (x - 8, y + 1)]), linen, frac=0.35)
    for xx in range(x - 7, x): c.put(xx, y, jute[2] if xx % 2 else jute[4])
    sx, sy = x - 8, y + 2
    P(c, [(sx, sy - 1), (sx - 1, sy), (sx + 1, sy), (sx - 1, sy + 1), (sx + 1, sy + 1)], coral[3]); c.put(sx, sy, coral[5])


def satchel_back(c, x, y, g):
    # strap arcing over the top
    for q in line([(x - 6, y + 4), (x - 5, y), (x - 3, y - 2), (x + 2, y - 2), (x + 4, y), (x + 5, y + 4)], 2): c.put(q[0], q[1], strap[3] if q[1] % 2 else strap[2])
    body = rect(x - 8, y + 4, x + 7, y + 15) - M({(x - 8, y + 4), (x + 7, y + 4), (x - 8, y + 15), (x + 7, y + 15), (x - 7, y + 15), (x + 6, y + 15)})
    form(c, body, leather, frac=0.3, hi=[(x - 6, y + 11)])
    # lemon with a leaf peeking from under the flap, top right
    lm = ellipse(x + 4, y + 3, 2.5, 1.5)
    form(c, lm, lemon, frac=0.3, hi=[(x + 3, y + 2)])
    P(c, [(x + 6, y + 1), (x + 7, y)], leaf[4]); c.put(x + 7, y + 1, leaf[2])
    flap = poly([(x - 8, y + 4), (x + 8, y + 4), (x + 8, y + 9), (x + 4, y + 11), (x - 5, y + 11), (x - 8, y + 9)])
    form(c, flap, leather, frac=0.3)
    for q in flap.bottom(): c.put(q[0], q[1], leather[1])
    for q in flap.inner_edge():   # stitched edge
        if q[1] > y + 4 and (q[0] + q[1]) % 2 == 0 and (q[0], q[1] + 1) in flap: c.put(q[0], q[1], leather[5] if q[0] < x + 4 else leather[3])
    P(c, [(x - 1, y + 10), (x, y + 10), (x - 1, y + 11)], brass[4]); c.put(x, y + 11, brass[2])   # buckle


def satchel_side(c, x, y, g):
    for q in line([(x, y + 4), (x - 1, y), (x, y - 2)], 2): c.put(q[0], q[1], strap[3])
    body = rect(x - 6, y + 4, x, y + 15) - M({(x - 6, y + 4), (x - 6, y + 15)})
    form(c, body, leather, frac=0.25)
    flap = poly([(x - 6, y + 4), (x + 1, y + 4), (x + 1, y + 10), (x - 6, y + 10)])
    form(c, flap, leather, frac=0.25)
    for q in flap.bottom(): c.put(q[0], q[1], leather[1])
    form(c, ellipse(x - 4, y + 3, 2, 1.5), lemon, frac=0.3)
    P(c, [(x - 6, y + 2), (x - 7, y + 1)], leaf[4])
    P(c, [(x - 6, y + 9), (x - 6, y + 10)], brass[4])


PACK = [
    dict(slug='se-olive-creel', cat='backpack', back=creel_back, side=creel_side),
    dict(slug='se-float-net', cat='backpack', back=net_back, side=net_side),
    dict(slug='se-amphora-frame', cat='backpack', back=amph_back, side=amph_side),
    dict(slug='se-sailcloth-seabag', cat='backpack', back=seabag_back, side=seabag_side),
    dict(slug='se-lemon-satchel', cat='backpack', back=satchel_back, side=satchel_side),
]


# ======================================================================== COAT
def _sleeve_band(c, g, r, rows=1, widen=0):
    """paint the lowest `rows` rows of each sleeve with ramp r (cuff / trim); widen = bell sleeve px each side."""
    for s in g['sleeves']:
        x0, y0, x1, y1 = s.bbox()
        band = M(q for q in s if q[1] > y1 - rows)
        if widen:
            for q in list(band):
                for dx in range(1, widen + 1):
                    band.add((q[0] - dx, q[1])); band.add((q[0] + dx, q[1]))
        bx0, _, bx1, _ = band.bbox()
        for q in band: c.put(q[0], q[1], r[2] if q[0] > bx1 - (bx1 - bx0 + 1) * 0.35 else r[4] if q[1] == y1 - rows + 1 else r[3])


def _linen_tex(q, t, g):
    if q[0] % 3 == 0 and (q[1] - g['b']) % 2 == 0 and t < 3: return linen[max(1, 3 - t)]
    return None


def _smock(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    _sleeve_band(c, g, sea, 1)
    if v == 'back':   # square neck trimmed in sea blue
        for x in range(26, 40): c.put(x, 47 + b, sea[3])
    # hem band
    bot = M(q for q in c if (q[0], q[1] + 1) not in c and q[1] >= 63 + b)
    for q in bot: c.put(q[0], q[1], sea[2])
    if v == 'front':   # pocket with the stitched sardine, below the beard
        pk = rect(35, 60 + b, 40, 63 + b)
        form(c, pk, linen, frac=0.3, under=False)
        for x in range(35, 41): c.put(x, 60 + b, sea[3])
        P(c, [(36, 62 + b), (37, 62 + b), (38, 62 + b)], steel[3]); c.put(39, 61 + b, steel[2]); c.put(39, 63 + b, steel[2]); c.put(36, 62 + b, steel[1])
    elif v == 'side':
        pk = rect(36, 59 + b, 40, 62 + b)
        form(c, pk, linen, frac=0.3, under=False)
        for x in range(36, 41): c.put(x, 59 + b, sea[3])
        P(c, [(37, 61 + b), (38, 61 + b)], steel[3]); c.put(39, 60 + b, steel[2]); c.put(39, 62 + b, steel[2])


def _fleece(c, g):
    v, b = g['view'], g['b']
    m = M(c.keys())
    trim = M(q for q in m.inner_edge() if q[1] > 47 + b) | M(q for q in m if (q[0], q[1] + 2) not in m)
    for q in trim: c.put(q[0], q[1], fleece[5] if (q[0] + q[1]) % 3 == 0 else fleece[4] if (q[0] * 2 + q[1]) % 3 else fleece[3])
    if v == 'front':   # fleece-lined front edges, toggle and goat bell on a cord
        for y in range(60 + b, 65 + b):
            for x in (31, 34): c.put(x, y, fleece[4] if (x + y) % 2 else fleece[3])
        P(c, [(32, 60 + b), (33, 60 + b)], wood[4])
        c.put(33, 61 + b, strap[2])
        bell = M({(32, 62 + b), (33, 62 + b), (31, 63 + b), (32, 63 + b), (33, 63 + b), (34, 63 + b)})
        for q in bell: c.put(q[0], q[1], brass[4] if q[0] < 33 else brass[2])
        c.put(32, 64 + b, brass[1]); c.put(32, 62 + b, brass[5])
    elif v == 'side':
        for y in range(59 + b, 65 + b): c.put(41, y, fleece[4] if y % 2 else fleece[3])
        c.put(42, 60 + b, strap[2])
        for q in ((42, 61), (43, 61), (42, 62), (43, 62), (44, 62)): c.put(q[0], q[1] + b, brass[4] if q[0] < 43 else brass[2])
        c.put(42, 61 + b, brass[5])
    elif v == 'back':   # back seam
        for y in range(50 + b, 63 + b): c.put(32, y, felt[2])


def _quilt(q, t, g):
    x, y = q[0], q[1] - g['b']
    if (x + y) % 4 == 0 or (x - y) % 4 == 0: return olive[max(0, 3 - t)] if t < 3 else olive[0]
    return None


def _quiltjacket(c, g):
    v, b = g['view'], g['b']
    _sleeve_band(c, g, wood, 1)   # ribbed cuffs
    if v == 'back':   # stand collar
        for x in range(25, 41): c.put(x, 47 + b, olive[4] if x < 36 else olive[3]); c.put(x, 48 + b, olive[1])
    bot = M(q for q in c if (q[0], q[1] + 1) not in c and q[1] >= 63 + b)
    for q in bot: c.put(q[0], q[1], wood[2])
    if v == 'front':   # wooden toggles below the beard + olive sprig pinned on the right shoulder
        for y in (60, 62): P(c, [(32, y + b), (33, y + b)], wood[4]); c.put(34, y + b, wood[2])
        _olives(c, [(44, 51 + b, 'l'), (45, 50 + b, 'L'), (46, 49 + b, 'l'), (44, 50 + b, 'd'), (45, 52 + b, 'o'), (46, 51 + b, 'O')])
    elif v == 'side':
        for y in (60, 62): P(c, [(40, y + b), (41, y + b)], wood[4])
        ax = 31 + g['p']['arm'] // 2
        _olives(c, [(ax - 1, 50 + b, 'l'), (ax, 49 + b, 'L'), (ax + 1, 48 + b, 'l'), (ax - 1, 49 + b, 'd'), (ax, 51 + b, 'o'), (ax + 1, 50 + b, 'O')])
    elif v == 'back':
        _olives(c, [(19, 51 + b, 'l'), (20, 50 + b, 'L'), (21, 49 + b, 'l'), (21, 51 + b, 'o')])


def _vintner(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    _sleeve_band(c, g, linen, 2)   # linen turned-back cuffs
    if v == 'front':
        for y in (60, 62, 64): c.put(32, y + b, brass[4]); c.put(33, y + b, brass[2])
        lf = M({(24, 64), (25, 64), (23, 65), (24, 65), (25, 65), (26, 65), (24, 66), (25, 66)}).sh(hs, b)
        for q in lf: c.put(q[0], q[1], leaf[4] if q[0] < 25 + hs else leaf[2])
        c.put(24 + hs, 65 + b, leaf[5]); c.put(25 + hs, 67 + b, leaf[1])
    elif v == 'back':   # split back skirt + half belt
        for y in range(62, 68): c.put(32 + hs, y + b, wine[0])
        for x in range(28, 38): c.put(x, 58 + b, wine[1])
        P(c, [(29, 58 + b), (36, 58 + b)], brass[4])
        lf = M({(38, 64), (39, 64), (37, 65), (38, 65), (39, 65), (40, 65), (38, 66), (39, 66)}).sh(hs, b)
        for q in lf: c.put(q[0], q[1], leaf[4] if q[0] < 39 + hs else leaf[2])
    else:
        lf = M({(27, 64), (28, 64), (26, 65), (27, 65), (28, 65), (29, 65), (27, 66), (28, 66)}).sh(hs, b)
        for q in lf: c.put(q[0], q[1], leaf[4] if q[0] < 28 + hs else leaf[2])
        for y in (60, 62): c.put(41, y + b, brass[4])


_STR = [saffron[4], saffron[3], terra[3], linen[4], linen[4], terra[3], saffron[3], saffron[4]]


def _sunstripe(q, t, g):
    if g['view'] == 'side':
        k = (q[1] - g['b']) // 2   # side: stripes read better across the sleeve; keep vertical body stripes too
    k = q[0] // 2
    col = _STR[k % len(_STR)]
    for r in (saffron, terra, linen):
        if col in r:
            i = r.index(col)
            return r[max(0, min(5, i - t + 1))]
    return col


def _suntunic(c, g):
    v, b = g['view'], g['b']
    _sleeve_band(c, g, terra, 2, widen=1)   # wide bell sleeves
    # sea-blue sash
    for q in list(c.keys()):
        if q[1] in (59 + b, 60 + b) and c[q] != INK: c.put(q[0], q[1], sea[3] if q[1] == 59 + b else sea[2])
    if v == 'front':
        P(c, [(35, 61 + b), (35, 62 + b), (36, 63 + b), (34, 61 + b), (34, 62 + b), (33, 63 + b)], sea[3]); c.put(35, 63 + b, sea[1])
        gecko = [(45, 48), (46, 49), (46, 50), (45, 51), (44, 47), (47, 50), (44, 50)]
        for x, y in gecko: c.put(x, y + b, leaf[4])
        c.put(44, 47 + b, leaf[2]); c.put(45, 48 + b, leaf[5]); c.put(47, 50 + b, leaf[2])
    elif v == 'back':
        gecko = [(20, 48), (19, 49), (19, 50), (20, 51), (21, 47), (18, 50), (21, 50)]
        for x, y in gecko: c.put(x, y + b, leaf[4])
        c.put(21, 47 + b, leaf[2]); c.put(20, 48 + b, leaf[5])
        P(c, [(31, 61 + b), (31, 62 + b), (30, 63 + b)], sea[3])
    else:
        P(c, [(25, 61 + b), (25, 62 + b), (24, 63 + b)], sea[3])
        ax = 31 + g['p']['arm'] // 2
        gecko = [(ax - 1, 48), (ax, 49), (ax + 1, 49), (ax + 2, 50), (ax, 50)]
        for x, y in gecko: c.put(x, y + b, leaf[4])
        c.put(ax - 1, 48 + b, leaf[2]); c.put(ax, 49 + b, leaf[5])


COAT = [
    dict(slug='se-net-mender-smock', cat='coat', r=linen, hem=1, pattern=_linen_tex, detail=_smock),
    dict(slug='se-fleece-vest', cat='coat', r=felt, sleeves=False, hem=1, detail=_fleece),
    dict(slug='se-olive-quilt-jacket', cat='coat', r=olive, puff=1, pattern=_quilt, detail=_quiltjacket),
    dict(slug='se-vintner-long-coat', cat='coat', r=wine, hem=3, detail=_vintner),
    dict(slug='se-sun-stripe-tunic', cat='coat', r=saffron, hem=1, pattern=_sunstripe, detail=_suntunic),
]


# ======================================================================== CLOAK
def _feltcape(c, g, m, v):
    b = g['b']
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # felt mottle
        if (q[0] * 7 + q[1] * 3) % 13 == 0 and c.get(q) not in (INK, None): c.put(q[0], q[1], felt[2])
    for q in m:   # stitched hem: dashes 2 rows above the bottom
        if (q[0], q[1] + 2) not in m and (q[0], q[1] + 1) in m and q[0] % 3 != 0: c.put(q[0], q[1], cuffL[5])
    if v == 'back':   # pointed hood lying down the back
        hood = poly([(25, 47 + b), (40, 47 + b), (34, 58 + b), (31, 58 + b)])
        form(c, hood, felt, frac=0.35)
        for q in hood.inner_edge():
            if q[1] > 47 + b: c.put(q[0], q[1], felt[1])
        c.put(32, 59 + b, felt[2]); c.put(33, 59 + b, felt[2])
        # rosemary sprig at the clasp cord on the shoulder
        _rosemary(c, [(40, 48), (41, 47), (42, 46)], b)
    elif v == 'side':
        hood = poly([(24, 47 + b), (29, 47 + b), (26, 56 + b), (24, 55 + b)])
        form(c, hood, felt, frac=0.3)
        _rosemary(c, [(29, 49), (30, 48), (31, 47)], b)
    else:
        _rosemary(c, [(45, 47), (46, 46), (47, 45)], b)


def _rosemary(c, pts, b):
    for i, (x, y) in enumerate(pts):
        c.put(x, y + b, sage[3])
        c.put(x + 1, y + b, sage[5] if i % 2 else sage[4])
    x, y = pts[-1]
    c.put(x + 1, y - 1 + b, indigo[5]); c.put(x - 1, y + b, sage[2])
    c.put(pts[0][0] - 1, pts[0][1] + 1 + b, brass[4])   # clasp


def _lemonshawl(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # woven saffron band one px inside the lower edges
    for q in m:
        if (q[0], q[1] + 1) in m and ((q[0], q[1] + 2) not in m or (q[0] - 1, q[1] + 1) not in m or (q[0] + 1, q[1] + 1) not in m) and q[1] > y0 + 2:
            c.put(q[0], q[1], saffron[3] if (q[0] + q[1]) % 2 else saffron[1])
    # long fringe hanging from the lower edges
    if v != 'front':
        for q in list(m.bottom()):
            if q[1] > y0 + 3 and q[0] % 2 == 0:
                for k in range(1, 3 + (q[0] // 2) % 2):
                    c.put(q[0], q[1] + k, saffron[2] if k < 3 else saffron[1])
    else:
        for q in list(m.bottom()):
            if q[0] % 2 == 0:
                for k in range(1, 3): c.put(q[0], q[1] + k, saffron[2])
    # bee resting on the shawl
    if v == 'back': bx, by = 36 + tl, 53 + b
    elif v == 'side': bx, by = 22 + tl, 53 + b
    else: bx, by = 15 - tl, 52 + b
    P(c, [(bx, by), (bx + 2, by)], lemon[4]); c.put(bx + 1, by, INK); P(c, [(bx, by - 1), (bx + 1, by - 1)], sea[5])


_PON = [terra[3], terra[3], saffron[4], linen[4], olive[4], olive[4], linen[4], saffron[4], terra[2], linen[4]]


def _poncho(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    if v != 'front':
        for q in m:
            if c.get(q) in (INK, None): continue
            col = _PON[(q[1] - b - 46) % len(_PON)]
            for r in (terra, saffron, linen, olive):
                if col in r:
                    i = r.index(col)
                    if q[0] > x1 - (x1 - x0 + 1) * (0.35 if v == 'back' else 0.2): i -= 1
                    if (q[0], q[1] + 1) not in m: i -= 2
                    col = r[max(0, i)]
            if (q[0] + q[1] * 3) % 9 == 0: col = linen[5] if col not in (linen[4], linen[3]) else terra[3]   # woven flecks
            c.put(q[0], q[1], col)
    # corner tassels
    if v != 'side':
        left = min(m, key=lambda q: (q[0], -q[1])); right = max(m, key=lambda q: (q[0], q[1]))
        for t in (left, right):
            P(c, [(t[0], t[1] + 1), (t[0], t[1] + 2)], terra[1]); c.put(t[0], t[1] + 3, saffron[3])
    else:
        t = min((q for q in m if q[1] >= y1 - 1), key=lambda q: q[0])
        P(c, [(t[0], t[1] + 1), (t[0], t[1] + 2)], terra[1]); c.put(t[0], t[1] + 3, saffron[3])
    # gull feather at the neck slit
    if v == 'back': fp = [(37, 48), (38, 47), (39, 46), (40, 45)]
    elif v == 'side': fp = [(26, 48), (25, 47), (24, 46), (23, 45)]
    else: fp = [(46, 46), (47, 45), (48, 44)]
    for i, (x, y) in enumerate(fp): c.put(x, y + b, steel[5] if i < len(fp) - 1 else steel[1])
    x, y = fp[1]; c.put(x + (1 if v != 'side' else -1), y + 1 + b, steel[4])


def _mantle(c, g, m, v):
    b, tl = g['b'], g['tail']
    # scalloped hem: notch every 3rd column on the bottom row, indigo running stitch above
    bot = m.bottom()
    for q in bot:
        if (q[0] - tl) % 3 == 0: c.pop(q, None)
    for q in bot:
        if (q[0], q[1] - 2) in m and (q[0] - tl) % 3 == 1: c.put(q[0], q[1] - 2, indigo[3])
    if v == 'back':   # wide hood lying back on the shoulders
        hood = ellipse(32.5, 51.5 + b, 7.5, 4)
        form(c, hood, linen, frac=0.35)
        inner = ellipse(32.5, 50.5 + b, 5, 2)
        for q in inner: c.put(q[0], q[1], linen[1] if q[1] < 51 + b else linen[2])
        P(c, [(30, 56 + b), (30, 57 + b), (35, 56 + b), (35, 57 + b)], indigo[3])   # hood ties
        sx, sy = 37 + tl, d_mantle_len - 5 + b
    elif v == 'side':
        hood = ellipse(24.5, 50 + b, 3, 4)
        form(c, hood, linen, frac=0.3)
        for q in hood.inner_edge():
            if q[0] >= 26: c.put(q[0], q[1], linen[1])
        sx, sy = 21 + tl, d_mantle_len - 5 + b
    else:
        return
    # small indigo swallow near the hem
    P(c, [(sx, sy), (sx + 1, sy + 1), (sx + 2, sy), (sx + 3, sy - 1), (sx - 1, sy - 1)], indigo[2]); c.put(sx + 1, sy, indigo[4]); c.put(sx + 1, sy + 2, indigo[1])


d_mantle_len = 67


def _capelet(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # round off the hem corners and add soft radial folds
    for q in list(m):
        if q[1] >= y1 - 1 and (q[0] <= x0 + 1 or q[0] >= x1 - 1) and v != 'side': c.pop(q, None)
    if v == 'back':
        for fx in (26, 30, 35, 39):
            for y in range(y0 + 4, y1):
                q = (fx + (y - y0) * (fx - 32) // 12 + (tl if y > y0 + 5 else 0), y)
                if q in c and c[q] != INK: c.put(q[0], q[1], indigo[2])
        for x in range(26, 40): c.put(x, 47 + b, indigo[5] if x < 36 else indigo[4]); c.put(x, 48 + b, indigo[1])   # high collar
        P(c, [(32, 49 + b), (32, 50 + b)], coral[1]); P(c, [(32, 51 + b), (33, 51 + b)], coral[4]); c.put(33, 52 + b, coral[2])   # coral toggle on its cord
    elif v == 'side':
        for x in range(25, 30): c.put(x, 47 + b, indigo[4])
        P(c, [(29, 48 + b), (30, 49 + b)], coral[1]); P(c, [(30, 50 + b), (31, 50 + b)], coral[4]); c.put(31, 51 + b, coral[2])
    for q in m:   # waxed sheen
        if (q[0], q[1] - 1) not in m and q in c and c[q] != INK and v != 'front': c.put(q[0], q[1], indigo[5])


CLOAK = [
    dict(slug='se-shepherd-felt-cape', cat='cloak', r=felt, lining=felt, len=66, flare=5, x0=20, x1=45, fx0=15, fx1=50, side_back=18, detail=_feltcape),
    dict(slug='se-lemon-fringe-shawl', cat='cloak', r=lemon, lining=lemon, len=62, flare=3, x0=18, x1=47, hemstyle='tri', fx0=14, fx1=51, detail=_lemonshawl),
    dict(slug='se-loom-stripe-poncho', cat='cloak', r=terra, lining=terra, len=63, flare=4, x0=19, x1=46, fx0=13, fx1=52, side_back=19, detail=_poncho),
    dict(slug='se-whitewash-mantle', cat='cloak', r=linen, lining=linen, len=d_mantle_len, flare=3, side_back=18, detail=_mantle),
    dict(slug='se-sea-squall-capelet', cat='cloak', r=indigo, lining=indigo, len=55, flare=3, fx0=15, fx1=50, side_back=20, detail=_capelet),
]

ITEMS = FOOT + PACK + COAT + CLOAK
