"""The Coralscatter (OC): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/OC/common.lua (C.R)
and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light): OC common.lua
pandanus = ["#5a3f22", "#80602e", "#a6823c", "#c6a250", "#dcc070", "#efdc9c"]
coir = ["#3a2219", "#56331f", "#744627", "#915c31", "#ac7640", "#c8965a"]
fleece = ["#6a5444", "#8e7660", "#b09a80", "#cdbb9e", "#e4d6bc", "#f4ecd8"]
suede = ["#5a3a26", "#7c5232", "#9e6c40", "#bc8a52", "#d4a868", "#e8c88c"]
flax = ["#33361c", "#4e5424", "#6c742c", "#8c9236", "#b0ac4a", "#d4cc78"]
turtle = ["#1e3a34", "#2a5a48", "#3a7a58", "#529a62", "#78b870", "#acd890"]
ochre = ["#4e1e1a", "#74301f", "#9a4426", "#bc5a2e", "#d67a3c", "#ecaa5e"]
tapa = ["#6a5038", "#8e7050", "#b09468", "#ccb486", "#e2d0a6", "#f2e6c8"]
sea = ["#1a2a4a", "#1e4466", "#246282", "#2f84a0", "#4aa8ba", "#86d0d0"]
hibiscus = ["#5a1638", "#8a2048", "#b83058", "#dc4a68", "#f07a84", "#fcb0a8"]
coral = ["#6a2424", "#9a3a2e", "#c85a3a", "#e87a48", "#f6a060", "#fccc8c"]
gum = ["#2e3a36", "#44564c", "#5e7462", "#7a9278", "#9cb294", "#c4d4b4"]
charcoal = ["#2e2830", "#3e3640", "#504652", "#645a64", "#7a7078", "#968c90"]
oilskin = ["#2e2018", "#44301e", "#5c4224", "#76562e", "#92703c", "#b08c52"]
bamboo = ["#4a4220", "#6a6026", "#8c8030", "#ae9e3e", "#ccbc5a", "#e6d888"]
leafwrap = ["#203a26", "#2c5430", "#3c6e36", "#548a40", "#74a84c", "#a2c86a"]
coconut = ["#2e1c16", "#45291c", "#5e3a24", "#7a4e2e", "#96663a", "#b2824c"]
paua = ["#1e3a5a", "#2a6a8a", "#3aa0a0", "#62c8a8", "#9a7ad0", "#c8f0e0"]
# ---- W.R (gnome-wear/_gw.lua)
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
cloakg = ["#1c3530", "#264a3c", "#335f43", "#45784b", "#5e9452", "#86b464"]
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
canvas = ["#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
steel = ["#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2"]
jay = ["#1e2f63", "#28488e", "#3364b4", "#4688d2", "#6cb0e6", "#bfe6f6"]
yarnA = ["#5c1f2e", "#842a36", "#a8383a", "#c64e40", "#dc6a4a", "#f08e62"]
mwood = ["#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#d89a58", "#ecc088"]   # oiled mangrove: wood, one step lighter
petrel = ["#141f3a", "#1a2a4a", "#1e4466", "#246282", "#2f84a0", "#4aa8ba"]   # sea, one step deeper


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def _lit(c, q):
    return c.get(q) not in (None, INK)


# ======================================================================== FOOTWEAR
def _sandals(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    bot = max(q[1] for q in foot)
    top = min(q[1] for q in foot)
    # flat woven pandanus sole: 2 light rows sticking out 1 px past the foot, diagonal plait, coir edge
    for yy in (bot - 1, bot):
        row = [q[0] for q in foot if q[1] == bot - 1]
        for x in range(min(row) - 1, max(row) + 2):
            c.put(x, yy, pandanus[5] if (x + yy) % 3 else pandanus[3])
    row = [q[0] for q in foot if q[1] == bot - 1]
    for x in range(min(row) - 1, max(row) + 2): c.put(x, bot + 1, coir[1])
    if v == 'front':
        # dark coir toe-thong (V) from the toe to the ankle tie, ankle tie across the top
        P(c, [(cx, bot - 2), (cx - 1, bot - 3), (cx + 1, bot - 3), (cx - 2, bot - 4), (cx + 2, bot - 4)], coir[1])
        for x in range(cx - 3, cx + 4): c.put(x, top + 1, coir[2] if x % 2 else coir[1])
        if k == 1: c.put(cx, bot - 3, fleece[5])   # cowrie on the thong
    elif v == 'back':
        for x in range(cx - 3, cx + 4): c.put(x, top + 1, coir[2] if x % 2 else coir[1])
        P(c, [(cx, bot - 2), (cx, top + 2)], coir[1])
    else:
        P(c, [(cx + 3, bot - 2), (cx + 2, bot - 3), (cx + 1, bot - 4)], coir[1])
        for x in range(cx - 3, cx + 1): c.put(x, top + 1, coir[2] if x % 2 else coir[1])
        if not g['far']: c.put(cx + 3, bot - 3, fleece[5])


def _fleece_boot(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # turned-out fleece cuff: 3 rows, 1 px wider, curly
    for y in range(top - 1, top + 2):
        for x in range(x0 - 1, x1 + 2):
            col = fleece[4] if (x + y) % 3 else fleece[5]
            if y == top + 1: col = fleece[3] if (x + y) % 2 else fleece[2]
            if x == x1 + 1: col = fleece[2]
            c.put(x, y, col)
    # stitched toe seam
    if v == 'front':
        mx = (x0 + x1) // 2
        for y in range(cy - 2, cy + 2, 2): c.put(mx, y, suede[1])
    elif v == 'side':
        for x in range(int(ft['cx']), int(ft['cx']) + 4, 2): c.put(x, cy - 2, suede[1])
    # wattle puff tucked in one cuff
    if (k == 1 and v == 'front') or (v == 'back' and k == 0) or (v == 'side' and not g['far']):
        wx = x1 if v != 'back' else x0
        P(c, [(wx, top - 3), (wx + 1, top - 3), (wx, top - 2), (wx + 1, top - 2)], brass[4]); c.put(wx, top - 3, brass[5]); c.put(wx + 1, top - 2, brass[2])
        c.put(wx - 1, top - 2, cloakg[3])


def _pullons(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # green elastic gusset panel on the outer side (front/back) or mid shaft (side)
    if v == 'side':
        gx = [x0 + 1, x0 + 2]
    else:
        gx = [x0, x0 + 1] if ft['side'] == 'L' else [x1 - 1, x1]
        if v == 'back': gx = [x1 - 1, x1] if ft['side'] == 'L' else [x0, x0 + 1]
    for y in range(top + 1, cy - 1):
        for i, x in enumerate(gx): c.put(x, y, cloakg[3] if (y + i) % 2 else cloakg[2])
    # pull tabs above the rim
    if v == 'side': P(c, [(x0, top - 1), (x1, top - 1)], leather[2])
    else: P(c, [((x0 + x1) // 2, top - 1), ((x0 + x1) // 2, top - 2)], leather[2])
    # stacked heel
    if v == 'side': P(c, [(x0, cy + 2), (x0 + 1, cy + 2), (x0, cy + 3), (x0 + 1, cy + 3)], sole[2])
    else:
        for x in range(x0 + 1, x1): c.put(x, cy + 2, sole[2] if v == 'back' else sole[1])
    # gecko climbing the heel: back view on the left boot, side view on the near boot
    if (v == 'back' and k == 0) or (v == 'side' and not g['far']):
        hx = x0 + 1 if v == 'back' else x0 - 1
        P(c, [(hx, cy - 1), (hx, cy), (hx, cy + 1)], turtle[4]); c.put(hx, cy - 2, turtle[5])
        P(c, [(hx - 1, cy - 1), (hx + 1, cy + 1), (hx + 1, cy)], turtle[3]); c.put(hx, cy + 2, turtle[2])


def _wraps(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # plaited bands: alternate light/dark rows with a 1 px offset weave
    for q in g['foot'] | g['shaft']:
        if not _lit(c, q): continue
        if (q[1] - top) % 3 == 2: c.put(q[0], q[1], flax[1] if c.get(q) in (flax[2], flax[1]) else flax[2])
        elif (q[0] + (q[1] - top) // 3) % 4 == 0: c.put(q[0], q[1], flax[5])
    # crossed coir ties up the shin
    for i, y in enumerate(range(top, cy - 2)):
        a = x0 + (i % (x1 - x0 + 1)); b = x1 - (i % (x1 - x0 + 1))
        c.put(a, y, coir[3]); c.put(b, y, coir[2])
    P(c, [(x0 - 1, top), (x1 + 1, top + 1)], coir[3])   # tie ends
    # red crab on the toe
    if (v == 'front' and k == 1) or (v == 'side' and not g['far']):
        tx = int(ft['cx']) + (1 if v == 'front' else 4)
        P(c, [(tx, cy + 1), (tx + 1, cy + 1)], yarnA[3]); c.put(tx, cy, yarnA[5])
        P(c, [(tx - 1, cy), (tx + 2, cy)], yarnA[2]); c.put(tx + 1, cy, yarnA[4])


def _mclog(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    top = min(q[1] for q in foot)
    # oiled grain streaks
    for q in foot:
        if _lit(c, q) and q[1] == top and q[0] % 4 == 1: c.put(q[0], q[1], mwood[5])   # oiled glint on the rim
    # woven coir strap across the instep (2 rows)
    xs = [q[0] for q in foot if q[1] == top + 1]
    a, z = min(xs), max(xs)
    if v == 'side': a, z = cx - 2, cx + 2
    for x in range(a, z + 1):
        c.put(x, top + 1, coir[3] if x % 2 else coir[2]); c.put(x, top + 2, coir[2] if x % 2 else coir[1])
    bot0 = max(q[1] for q in foot)
    for q in foot:   # carved rim line above the thick sole
        if q[1] == bot0 - 1 and _lit(c, q): c.put(q[0], q[1], mwood[4])
    top += 1
    # raised heel block
    bot = max(q[1] for q in foot)
    if v == 'side':
        for y in (bot, bot + 1): P(c, [(cx - 4, y), (cx - 3, y), (cx - 2, y)], wood[1])
        c.put(cx - 4, bot, wood[3])
    else:
        for x in range(a + 1, z): c.put(x, bot + 1, wood[1])
    # turtle inlay on the strap (shell green)
    if v != 'back' and not g['far']:
        tx = (a + z) // 2
        P(c, [(tx, top), (tx + 1, top), (tx, top + 1), (tx + 1, top + 1)], turtle[3]); c.put(tx, top, turtle[5]); c.put(tx + 1, top + 1, turtle[1])
        c.put(tx + 2, top, turtle[4]); c.put(tx - 1, top + 1, turtle[2])


FOOT = [
    dict(slug='oc-reef-sandals', cat='footwear', shell=pandanus[1:] + pandanus[-1:], upper=pandanus, sole=pandanus[1], rim=None, detail=_sandals),
    dict(slug='oc-gully-fleece-boot', cat='footwear', shell=suede, upper=suede, sole=suede[0], rim=58, half=4, puff=0.5, detail=_fleece_boot),
    dict(slug='oc-drovers-pull-ons', cat='footwear', shell=leather, upper=leather, sole=sole[1], rim=62, half=4, toe=1, detail=_pullons),
    dict(slug='oc-flax-wading-wraps', cat='footwear', shell=flax, upper=flax, sole=flax[0], rim=59, half=4, puff=0.5, detail=_wraps),
    dict(slug='oc-mangrove-clog', cat='footwear', shell=mwood, upper=mwood, sole=wood[0], rim=None, puff=0.5, toe=1, detail=_mclog),
]


# ======================================================================== BACKPACK
def _check(c, m, a, b, s=3):
    for q in m:
        u, w = (q[0] // s) % 2, (q[1] // s) % 2
        c.put(q[0], q[1], a[4] if u == w else b[3])
        if u == w and q[1] % s == 0: c.put(q[0], q[1], a[3])
        if u != w and q[0] % s == 0: c.put(q[0], q[1], b[2])


def _shade_right(c, m, r, n=2):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if q[0] > x1 - n: c.put(q[0], q[1], r[2])
        if q[1] == y1: c.put(q[0], q[1], r[1])


def _frond(c, pts, r=leafwrap):
    for i, (x, y) in enumerate(pts): c.put(x, y, r[3] if i % 2 else r[4])


def flaxbasket_back(c, x, y, g):
    m = poly([(x - 10, y + 1), (x + 9, y + 1), (x + 8, y + 14), (x - 9, y + 14)])
    _check(c, m, flax, pandanus); _shade_right(c, m, flax)
    rimm = rect(x - 10, y, x + 9, y + 1)
    form(c, rimm, pandanus, frac=0.3)
    for xx in range(x - 9, x + 9): c.put(xx, y + 8, pandanus[4] if xx % 2 else pandanus[3])   # plaited band
    for hx in (x - 9, x + 3):   # handle loops over the rim
        P(c, [(hx, y - 1), (hx, y - 2), (hx + 1, y - 3), (hx + 2, y - 3), (hx + 3, y - 2), (hx + 3, y - 1)], flax[3])
        c.put(hx + 1, y - 3, flax[5])
    # curled fern frond poking out of the top
    _frond(c, [(x + 7, y - 1), (x + 7, y - 2), (x + 8, y - 3), (x + 8, y - 4), (x + 9, y - 5), (x + 10, y - 6), (x + 11, y - 6), (x + 11, y - 5)])
    P(c, [(x + 9, y - 3), (x + 7, y - 4), (x + 10, y - 4)], leafwrap[5])


def flaxbasket_side(c, x, y, g):
    m = poly([(x - 8, y + 1), (x, y + 1), (x, y + 14), (x - 6, y + 14)])
    _check(c, m, flax, pandanus); _shade_right(c, m, flax, 1)
    form(c, rect(x - 9, y, x, y + 1), pandanus, frac=0.3)
    for xx in range(x - 8, x): c.put(xx, y + 8, pandanus[4] if xx % 2 else pandanus[3])
    P(c, [(x - 7, y - 1), (x - 7, y - 2), (x - 6, y - 3), (x - 5, y - 3), (x - 4, y - 2), (x - 4, y - 1)], flax[3])
    _frond(c, [(x - 3, y - 1), (x - 3, y - 2), (x - 2, y - 3), (x - 2, y - 4), (x - 1, y - 5), (x, y - 6), (x + 1, y - 6), (x + 1, y - 5)])
    P(c, [(x - 1, y - 3), (x - 3, y - 4)], leafwrap[5])


def _net(c, m, x, y):
    """looped string net: diagonal mesh in ochre / pandanus / turtle bands over a dark interior."""
    x0, y0, x1, y1 = m.bbox()
    band = lambda yy: ochre if (yy - y0) % 9 < 3 else (pandanus if (yy - y0) % 9 < 6 else turtle)
    for q in m:
        if (q[0] + q[1]) % 3 == 0 or (q[0] - q[1]) % 3 == 0:
            r = band(q[1]); c.put(q[0], q[1], r[4] if q[0] < x1 - 3 else r[3])


def stringbag_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 10, 8.5, 6.5) | poly([(x - 5, y + 1), (x + 4, y + 1), (x + 8, y + 8), (x - 9, y + 8)])
    for q in m: c.put(q[0], q[1], coconut[0])
    # coconuts behind the mesh
    for (bx, by) in ((x - 4, y + 11), (x + 3, y + 11), (x, y + 6)):
        form(c, ellipse(bx, by, 3, 2.5) & m, coconut, frac=0.35, hi=[(bx - 2, by - 2)])
    P(c, [(x - 1, y + 5), (x + 1, y + 5), (x, y + 7)], coconut[0])   # three "eyes" on the top coconut
    _net(c, m, x, y)
    # gathered top + head strap going up behind the head
    for xx in range(x - 5, x + 5): c.put(xx, y + 1, ochre[3] if xx % 2 else ochre[2])
    for yy in range(y - 2, y + 1): P(c, [(x - 4, yy), (x + 3, yy)], ochre[3])
    c.put(x, y + 17, ochre[2])   # tassel at the bottom
    c.put(x, y + 18, ochre[4])


def stringbag_side(c, x, y, g):
    m = ellipse(x - 4, y + 10, 4.5, 6.5) | poly([(x - 4, y + 1), (x, y + 1), (x, y + 8), (x - 8, y + 8)])
    for q in m: c.put(q[0], q[1], coconut[0])
    form(c, ellipse(x - 4, y + 11, 3, 2.5) & m, coconut, frac=0.35, hi=[(x - 6, y + 9)])
    P(c, [(x - 5, y + 11), (x - 3, y + 11), (x - 4, y + 13)], coconut[0])
    _net(c, m, x, y)
    for yy in range(y - 2, y + 2): c.put(x - 2, yy, ochre[3])
    c.put(x - 4, y + 17, ochre[2])


def _roll_end(c, cx, cy):
    e = ellipse(cx, cy, 2, 3)
    form(c, e, canvas, frac=0.3)
    P(c, [(cx, cy), (cx + 1, cy - 1), (cx - 1, cy + 1), (cx - 1, cy - 1)], canvas[1])   # spiral
    c.put(cx, cy - 1, canvas[5])


def _billy(c, bx, by, k=0):
    form(c, rect(bx - 2, by, bx + 2, by + 5), steel, frac=0.35, hi=[(bx - 1, by + 1)])
    for xx in range(bx - 2, bx + 3): c.put(xx, by, steel[2])
    P(c, [(bx - 2, by - 1), (bx - 1, by - 2), (bx, by - 2), (bx + 1, by - 2), (bx + 2, by - 1)], steel[1])   # wire bail
    P(c, [(bx + 1, by - 4), (bx + 2, by - 5), (bx + 1, by - 6)], canvas[5])   # steam curl


def swag_back(c, x, y, g):
    roll = rect(x - 11, y + 2, x + 10, y + 8)
    form(c, roll, canvas, frac=0.25, hi=[(x - 8, y + 3), (x - 4, y + 3)])
    for xx in range(x - 10, x + 10, 3): c.put(xx, y + 5, canvas[2])
    _roll_end(c, x - 12, y + 5)
    for sx in (x - 6, x + 5):   # leather straps + buckles
        for yy in range(y + 1, y + 10): c.put(sx, yy, strap[2]); c.put(sx + 1, yy, strap[3])
        P(c, [(sx, y + 4), (sx + 1, y + 4), (sx, y + 6), (sx + 1, y + 6)], brass[4]); c.put(sx + 1, y + 5, brass[2])
    _billy(c, x + 11, y + 9)
    P(c, [(x + 10, y + 7), (x + 11, y + 8)], steel[1])


def swag_side(c, x, y, g):
    e = ellipse(x - 4, y + 5, 3.5, 3.5)
    form(c, e, canvas, frac=0.3)
    P(c, [(x - 4, y + 5), (x - 3, y + 4), (x - 5, y + 4), (x - 5, y + 6), (x - 3, y + 6), (x - 2, y + 5), (x - 6, y + 5)], canvas[1])
    c.put(x - 4, y + 4, canvas[5])
    for yy in range(y + 1, y + 10): c.put(x - 1, yy, strap[2])
    P(c, [(x - 1, y + 9)], brass[4])
    _billy(c, x - 5, y + 11)
    P(c, [(x - 5, y + 9)], steel[1])


def bamboo_back(c, x, y, g):
    for px in (x - 8, x + 7):   # A-frame poles with nodes
        for yy in range(y - 3, y + 19):
            c.put(px, yy, bamboo[4] if (yy - y) % 6 else bamboo[1]); c.put(px + 1, yy, bamboo[2] if (yy - y) % 6 else bamboo[1])
    for by in (y - 2, y + 15):
        for xx in range(x - 7, x + 7): c.put(xx, by, bamboo[4] if xx % 7 else bamboo[1]); c.put(xx, by + 1, bamboo[2])
    bundle = ellipse(x - 0.5, y + 7, 6, 6.5) | rect(x - 6, y + 3, x + 5, y + 11)
    form(c, bundle, leafwrap, frac=0.3, hi=[(x - 4, y + 2)])
    for q in bundle:   # leaf veins
        if (q[0] - q[1]) % 5 == 0 and c.get(q) == leafwrap[3]: c.put(q[0], q[1], leafwrap[2])
    for i in range(-5, 6):   # coir X lashing
        P(c, [(x + i, y + 7 + i), (x - 1 - i, y + 7 + i)], coir[3])
    P(c, [(x - 1, y + 7), (x, y + 7)], coir[1])
    # striped glass float tied on top
    fl = ellipse(x + 8, y - 6, 2.5, 2.5)
    form(c, fl, paua, frac=0.35)
    for q in fl:
        if q[1] == y - 6: c.put(q[0], q[1], sea[2])
    c.put(x + 7, y - 7, paua[5])
    P(c, [(x + 8, y - 3)], coir[3])


def bamboo_side(c, x, y, g):
    for yy in range(y - 3, y + 19):
        c.put(x - 1, yy, bamboo[4] if (yy - y) % 6 else bamboo[1])
    for yy in range(y - 3, y + 19):
        if (yy - y) % 6: c.put(x - 8, yy, bamboo[2])
    for by in (y - 2, y + 15):
        for xx in range(x - 8, x): c.put(xx, by, bamboo[3])
    bundle = ellipse(x - 4.5, y + 7, 3, 6)
    form(c, bundle, leafwrap, frac=0.3)
    for yy in range(y + 2, y + 13, 3): P(c, [(x - 6, yy), (x - 5, yy + 1), (x - 4, yy + 1), (x - 3, yy)], coir[3])
    fl = ellipse(x - 4, y - 5, 2.5, 2.5)
    form(c, fl, paua, frac=0.35)
    for q in fl:
        if q[1] == y - 5: c.put(q[0], q[1], sea[2])
    c.put(x - 5, y - 6, paua[5])


def _possum(c, px, py):
    """sleepy possum head (centre px, py) peeking over the pouch rim."""
    head = ellipse(px, py, 2.5, 2)
    form(c, head, steel, frac=0.3, under=False)
    P(c, [(px - 3, py - 2), (px + 3, py - 2)], charcoal[3]); P(c, [(px - 3, py - 3), (px + 3, py - 3)], charcoal[4])   # ears
    P(c, [(px - 1, py), (px + 1, py)], charcoal[0])   # closed eyes
    c.put(px, py, hibiscus[4])   # nose


DSUEDE = [suede[0], suede[0], suede[1], suede[2], suede[3], suede[4]]


def pouch_back(c, x, y, g):
    body = ellipse(x - 0.5, y + 9, 8.5, 7.5)
    form(c, body, suede, frac=0.3, hi=[(x - 6, y + 4)])
    for xx in range(x - 4, x + 4): c.put(xx, y + 2, strap[2] if xx % 2 else strap[3])   # drawstring
    P(c, [(x + 4, y + 3), (x + 5, y + 4), (x + 5, y + 5)], strap[2]); c.put(x + 5, y + 6, suede[5])
    _possum(c, x - 1, y + 9)
    pouch = ellipse(x - 0.5, y + 13, 6.5, 4.5).rows(y + 10, y + 18)
    form(c, pouch, DSUEDE, frac=0.35, rim=False)
    for q in pouch.top(): c.put(q[0], q[1], suede[5])
    for q in pouch:
        if q[1] == y + 11: c.put(q[0], q[1], suede[0] if abs(q[0] - x + 1) < 3 else suede[1])
        if q[1] == y + 15 and q[0] % 2: c.put(q[0], q[1], suede[3])   # stitch line


def pouch_side(c, x, y, g):
    body = ellipse(x - 4, y + 9, 4.5, 7.5)
    form(c, body, suede, frac=0.3)
    form(c, rect(x - 5, y - 1, x - 2, y + 2), suede, frac=0.3)
    for xx in range(x - 6, x - 1): c.put(xx, y + 2, strap[2])
    pouch = ellipse(x - 7, y + 12, 3, 4).rows(y + 9, y + 17)
    form(c, pouch, suede, frac=0.3, rim=False)
    for q in pouch.top(): c.put(q[0], q[1], suede[4])
    # possum ears + nose over the pouch rim
    P(c, [(x - 9, y + 8), (x - 7, y + 8)], charcoal[4]); P(c, [(x - 9, y + 7), (x - 7, y + 7)], charcoal[3])
    P(c, [(x - 8, y + 8)], steel[4]); c.put(x - 10, y + 8, hibiscus[4])


PACK = [
    dict(slug='oc-flax-basket-pack', cat='backpack', back=flaxbasket_back, side=flaxbasket_side),
    dict(slug='oc-coconut-string-bag', cat='backpack', back=stringbag_back, side=stringbag_side),
    dict(slug='oc-bushmans-swag', cat='backpack', back=swag_back, side=swag_side, front_span=(12, 53)),
    dict(slug='oc-bamboo-frame-pack', cat='backpack', back=bamboo_back, side=bamboo_side),
    dict(slug='oc-pouch-pack', cat='backpack', back=pouch_back, side=pouch_side),
]


# ======================================================================== COAT
def _oil_shine(q, t, g):
    if t == 0 and (q[0] + q[1]) % 4 == 0: return oilskin[5]
    return None


def _oilskin(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    # shoulder capelet
    cape = (ellipse(32.5, 49 + b, 13.5, 4) if v != 'side' else ellipse(32, 49 + b, 9, 4)).rows(46 + b, 52 + b)
    form(c, cape, oilskin, frac=0.35)
    for q in cape.bottom(): c.put(q[0], q[1], oilskin[1])
    for q in cape:
        if q[1] == 48 + b and q[0] % 5 == 1: c.put(q[0], q[1], oilskin[5])
    if v == 'back':   # split back skirt
        for y in range(62, 68): c.put(32 + hs, y + b, INK)
        P(c, [(44, 53 + b), (44, 54 + b)], paua[5]); c.put(44, 55 + b, sea[4])   # raindrop off the capelet
    if v == 'front':
        for y in (61, 63, 65): c.put(33, y + b, brass[4])
        P(c, [(19, 53 + b), (19, 54 + b)], paua[5]); c.put(19, 55 + b, sea[4])
    if v == 'side':
        P(c, [(23, 53 + b), (23, 54 + b)], paua[5]); c.put(23, 55 + b, sea[4])


def _bushcheck(q, t, g):
    a, b2 = (q[0] // 2) % 2, ((q[1] - g['b']) // 2) % 2
    if a and b2: return charcoal[1] if t >= 2 else charcoal[2]
    if a or b2: return yarnA[1] if t >= 2 else yarnA[2]
    return None


def _smock(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        pocket = rect(26, 60 + b, 38, 64 + b)
        form(c, pocket, yarnA, frac=0.3)
        for q in pocket.top(): c.put(q[0], q[1], charcoal[2])
        # fishing fly hooked on the pocket
        P(c, [(36, 59 + b), (37, 58 + b)], brass[4]); c.put(38, 58 + b, sea[4]); c.put(36, 60 + b, steel[4])
    if v == 'back':   # short hood down the back
        hood = ellipse(32.5, 51 + b, 6, 4)
        form(c, hood, yarnA, frac=0.3)
        for q in hood:
            if (q[0] // 2 + q[1] // 2) % 2 == 0 and c.get(q) != yarnA[1]: c.put(q[0], q[1], charcoal[2])
        for q in ellipse(32.5, 50 + b, 3.5, 2): c.put(q[0], q[1], charcoal[0])
    if v == 'side':
        hood = ellipse(25, 50 + b, 3.5, 4)
        form(c, hood, yarnA, frac=0.3)
        pocket = rect(35, 60 + b, 40, 63 + b)
        form(c, pocket, yarnA, frac=0.3)
        for q in pocket.top(): c.put(q[0], q[1], charcoal[2])
        P(c, [(39, 59 + b), (40, 58 + b)], brass[4]); c.put(41, 58 + b, sea[4])
    # ribbed charcoal hem band
    for q in list(c.keys()):
        if (q[0], q[1] + 1) not in c and q[1] > 60 + b and c[q] != INK: c.put(q[0], q[1], charcoal[2] if q[0] % 2 else charcoal[1])


def _tapa(q, t, g):
    y = q[1] - g['b']
    if y in (50, 51, 52) or y in (58, 59, 60):   # rows of stamped triangles
        top = 50 if y < 55 else 58
        dx = (q[0] % 4)
        if y - top >= abs(dx - 1.5) - 0.5: return ochre[3] if t < 2 else ochre[2]
    if y in (55, 63) and q[0] % 3 == 0: return ochre[2]   # dot rows
    if y in (54, 56, 62): return tapa[2] if t < 2 else tapa[1]
    return None


def _barkvest(c, g):
    v, b = g['view'], g['b']
    flower = None
    if v == 'front':
        flower = (42, 54 + b)
        for y in range(59, 64): c.put(32, y + b, coir[3] if y % 2 else coir[2])   # cord ties
        P(c, [(31, 61 + b), (34, 61 + b)], coir[3])
    elif v == 'side': flower = (39, 54 + b)
    if flower:
        fx, fy = flower
        P(c, [(fx - 1, fy), (fx + 1, fy), (fx, fy - 1), (fx, fy + 1)], tapa[5]); c.put(fx + 1, fy + 1, tapa[4])
        c.put(fx, fy, brass[4])


def _quilt(q, t, g):
    y = q[1] - g['b']
    if (q[0] + y) % 4 == 0 or (q[0] - y) % 4 == 0: return sea[2] if t < 2 else sea[1]
    return None


def _jerkin(c, g):
    v, b = g['view'], g['b']
    if v == 'back':   # rope-edged collar at the shoulders
        for x in range(25, 41): c.put(x, 47 + b, canvas[4] if x % 2 else canvas[2])
    if v == 'side':
        for y in range(46, 51): c.put(28, y + b, canvas[4] if y % 2 else canvas[2])
        P(c, [(38, 54 + b), (39, 54 + b)], paua[4]); P(c, [(38, 55 + b), (39, 55 + b)], paua[2]); c.put(38, 54 + b, paua[5])
    if v == 'front':
        for y in (60, 63):   # knotted rope toggles
            P(c, [(31, y + b), (32, y + b), (34, y + b), (35, y + b)], canvas[3]); c.put(33, y + b, canvas[5])
        # paua shell button by the beard
        P(c, [(42, 54 + b), (43, 54 + b)], paua[4]); P(c, [(42, 55 + b), (43, 55 + b)], paua[2]); c.put(42, 54 + b, paua[5]); c.put(43, 55 + b, paua[3])
    # canvas rope hem
    for q in list(c.keys()):
        if (q[0], q[1] + 1) not in c and q[1] > 60 + b and c[q] != INK: c.put(q[0], q[1], canvas[4] if q[0] % 2 else canvas[3])


def _rib(q, t, g):
    if q[0] % 2 == 0: return gum[2] if t < 2 else gum[1]
    return None


def _cardigan(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    # ribbed hem band (2 rows)
    for q in list(c.keys()):
        if c[q] == INK: continue
        if (q[0], q[1] + 1) not in c or (q[0], q[1] + 2) not in c:
            if q[1] > 60 + b: c.put(q[0], q[1], gum[4] if q[0] % 2 else gum[3])
    if v == 'back':   # rolled shawl collar
        for q in ellipse(32.5, 47 + b, 7, 1.5): c.put(q[0], q[1], gum[4] if q[1] < 47 + b else gum[3])
    if v == 'front':
        for px in (24, 37):   # big patch pockets
            pk = rect(px, 60 + b, px + 4, 63 + b)
            form(c, pk, gum, frac=0.3)
        P(c, [(31, 59 + b), (31, 62 + b)], wood[3]); P(c, [(31, 60 + b), (31, 63 + b)], wood[1])   # gum-nut buttons
        P(c, [(38, 59 + b), (39, 58 + b), (40, 57 + b)], leafwrap[4]); c.put(39, 59 + b, leafwrap[2]); c.put(40, 58 + b, leafwrap[3])   # gum leaf
    if v == 'side':
        pk = rect(35, 60 + b, 39, 63 + b)
        form(c, pk, gum, frac=0.3)
        P(c, [(37, 59 + b), (38, 58 + b), (39, 57 + b)], leafwrap[4]); c.put(38, 59 + b, leafwrap[2])


COAT = [
    dict(slug='oc-drovers-oilskin', cat='coat', r=oilskin, hem=3, pattern=_oil_shine, detail=_oilskin),
    dict(slug='oc-bush-check-smock', cat='coat', r=yarnA, pattern=_bushcheck, detail=_smock),
    dict(slug='oc-bark-cloth-vest', cat='coat', r=tapa, sleeves=False, open=2, pattern=_tapa, detail=_barkvest),
    dict(slug='oc-reef-sail-cloth-jerkin', cat='coat', r=sea, puff=1, pattern=_quilt, detail=_jerkin),
    dict(slug='oc-gum-dyed-cardigan', cat='coat', r=gum, open=2, hem=1, pattern=_rib, detail=_cardigan),
]


# ======================================================================== CLOAK
def _fringe(c, m, step, col, n=1, skip_side=False):
    bot = M(q for q in m if (q[0], q[1] + 1) not in m)
    for q in bot:
        if q[0] % step == 0:
            for k in range(1, n + 1): c.put(q[0], q[1] + k, col)


def _frond_cape(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # vertical strands
    for q in m:
        if c.get(q) == INK: continue
        if (q[0] - tl) % 2 == 0: c.put(q[0], q[1], flax[2] if c.get(q) in (flax[2], flax[1]) else flax[4])
    # thatch tiers: a dark ragged line every 5 rows (layer edges)
    for q in m:
        if q[1] > y0 + 2 and (q[1] - y0) % 5 == 0 and v != 'front':
            c.put(q[0], q[1] + ((q[0] + tl) % 2), flax[1])
    # ragged hem: strand tips of uneven length
    bot = M(q for q in m if (q[0], q[1] + 1) not in m)
    for q in bot:
        if (q[0] + tl) % 3 == 0: c.put(q[0], q[1] + 1, flax[3])
        elif (q[0] + tl) % 3 == 1: del c[q]
    # rain bead sliding down one strand
    if v == 'back': P(c, [(28 + tl, 58 + b)], paua[5]); c.put(28 + tl, 59 + b, sea[4])
    if v == 'side': P(c, [(22 + tl, 56 + b)], paua[5]); c.put(22 + tl, 57 + b, sea[4])


def _fleece_mantle(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # round the bottom corners
    for q in list(m):
        if q[1] >= y1 - 1 and (q[0] <= x0 + 1 or q[0] >= x1 - 1): c.pop(q, None)
        if q[1] == y1 and (q[0] <= x0 + 3 or q[0] >= x1 - 3): c.pop(q, None)
    if v != 'front':   # curls
        for q in m:
            if q in c and (q[0] * 2 + q[1] * 3) % 5 == 0 and c[q] not in (fleece[1],): c.put(q[0], q[1], fleece[2])
            elif q in c and (q[0] * 2 + q[1] * 3) % 5 == 1 and c[q] == fleece[3]: c.put(q[0], q[1], fleece[5])
        for q in m:   # suede lining edge at the hem
            if q in c and (q[0], q[1] + 1) not in c: c.put(q[0], q[1], suede[2])
    # prickly burr caught in the curls
    if v == 'back': P(c, [(37, 52 + b), (38, 52 + b), (37, 53 + b), (38, 53 + b)], coconut[3]); P(c, [(36, 52 + b), (39, 53 + b), (38, 51 + b)], coconut[1]); c.put(37, 52 + b, flax[4])
    if v == 'side': P(c, [(24, 52 + b), (25, 52 + b), (24, 53 + b)], coconut[3]); P(c, [(23, 52 + b), (25, 51 + b)], coconut[1])


def _pareo(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # diagonal drape: long on the left, short at the knotted right shoulder
    if v != 'side':
        for q in list(m):
            lim = y1 - (q[0] - x0) * 0.42 if v == 'back' else y1 - (x1 - q[0]) * 0.42
            if q[1] > lim: c.pop(q, None)
        mm = M(q for q in m if q in c)
        for q in mm:   # hem shadow
            if (q[0], q[1] + 1) not in mm: c.put(q[0], q[1], coral[1])
    # big printed blossoms
    for (fx, fy) in ((25, 52), (32, 57), (38, 51), (27, 61), (35, 63), (22, 58)):
        if v == 'side': fx, fy = fx - 2 if fx < 30 else 23, fy
        pts = [(fx, fy - 1), (fx - 1, fy), (fx + 1, fy), (fx, fy + 1)]
        if all((p[0] + tl, p[1] + b) in c and c[(p[0] + tl, p[1] + b)] != INK for p in pts + [(fx, fy)]):
            P(c, [(p[0] + tl, p[1] + b) for p in pts], tapa[5]); c.put(fx + tl, fy + b, hibiscus[3])
    # knot on the shoulder + hibiscus flower tucked in
    if v == 'back':
        kn = ellipse(41.5, 47.5 + b, 2, 1.5); form(c, kn, coral, frac=0.3)
        P(c, [(43, 46 + b), (44, 46 + b), (43, 45 + b), (44, 47 + b), (45, 46 + b)], hibiscus[3]); c.put(44, 46 + b, brass[4]); c.put(43, 45 + b, hibiscus[5])
        P(c, [(42, 49 + b), (43, 50 + b), (43, 51 + b)], coral[2])   # knot tails
    elif v == 'side':
        P(c, [(27, 46 + b), (28, 46 + b), (27, 45 + b), (26, 46 + b), (27, 47 + b)], hibiscus[3]); c.put(27, 46 + b, brass[4]); c.put(26, 45 + b, hibiscus[5])
    else:
        P(c, [(19, 46 + b), (18, 46 + b), (19, 45 + b), (17, 46 + b), (19, 47 + b)], hibiscus[3]); c.put(18, 46 + b, brass[4]); c.put(18, 45 + b, hibiscus[5])


def _poncho(c, g, m, v):
    b, tl = g['b'], g['tail']
    # stripe bands following the hem: cream, dark, cream
    for q in m:
        below = sum(1 for k in range(1, 8) if (q[0], q[1] + k) in m)
        if v == 'front': continue
        if below == 5: c.put(q[0], q[1], tapa[4])
        elif below == 4: c.put(q[0], q[1], charcoal[1])
        elif below == 3: c.put(q[0], q[1], tapa[4] if q[0] % 2 else tapa[3])
    # tasselled fringe under the whole hem
    bot = M(q for q in m if (q[0], q[1] + 1) not in m)
    for q in bot:
        if q[0] % 2 == 0: c.put(q[0], q[1] + 1, tapa[3]); c.put(q[0], q[1] + 2, tapa[2])
    # sand lizard sitting on the fringe
    if v == 'back':
        lx, ly = 36 + tl, max(q[1] for q in bot if q[0] in (35 + tl, 36 + tl, 37 + tl)) if any(q[0] in (35 + tl, 36 + tl, 37 + tl) for q in bot) else 60 + b
        P(c, [(lx - 1, ly), (lx, ly), (lx + 1, ly)], pandanus[4]); c.put(lx + 2, ly - 1, pandanus[3]); c.put(lx - 2, ly + 1, pandanus[2]); c.put(lx - 3, ly + 1, pandanus[2])
        P(c, [(lx, ly + 1), (lx + 1, ly + 1)], pandanus[1]); c.put(lx + 1, ly, pandanus[5])
    if v == 'side':
        lq = min(bot, key=lambda q: q[0])
        lx, ly = lq[0] + 2, lq[1]
        P(c, [(lx, ly), (lx + 1, ly), (lx + 2, ly)], pandanus[4]); c.put(lx + 3, ly - 1, pandanus[3]); c.put(lx - 1, ly + 1, pandanus[2]); c.put(lx + 1, ly + 1, pandanus[1])


def _petrel(c, g, m, v):
    b, tl = g['b'], g['tail']
    # wave-stitched hem: canvas running stitch in a gentle wave 2 rows above the hem
    bot = M(q for q in m if (q[0], q[1] + 1) not in m)
    for q in bot:
        y = q[1] - 2 - (1 if (q[0] + tl) % 4 in (1, 2) else 0)
        if (q[0], y) in c and q[0] % 4 != 3 and v != 'front': c.put(q[0], y, canvas[4])
    if v == 'back':   # pointed hood hanging down the back (hood can't go up: head is untouchable)
        hood = poly([(26, 48 + b), (39, 48 + b), (35, 55 + b), (32.5, 59 + b), (30, 55 + b)])
        form(c, hood, petrel, frac=0.35)
        for q in hood.inner_edge():
            if q[1] > 48 + b: c.put(q[0], q[1], jay[3])
        for q in ellipse(32.5, 50 + b, 3.5, 1.5): c.put(q[0], q[1], petrel[0])
        # shell clasp + seahorse charm at the hood point
        c.put(32, 60 + b, tapa[5]); c.put(33, 60 + b, tapa[4])
        P(c, [(32, 61 + b), (33, 62 + b), (32, 63 + b), (32, 64 + b), (33, 65 + b)], brass[4]); c.put(33, 61 + b, brass[5]); c.put(31, 62 + b, brass[2])
    elif v == 'side':
        hood = poly([(26, 46 + b), (29, 47 + b), (27, 53 + b), (24, 56 + b), (23, 50 + b)])
        form(c, hood, petrel, frac=0.3)
        for q in hood.inner_edge():
            if q[0] >= 26: c.put(q[0], q[1], jay[3])
        c.put(24, 57 + b, tapa[5])
        P(c, [(24, 58 + b), (25, 59 + b), (24, 60 + b), (24, 61 + b), (25, 62 + b)], brass[4]); c.put(25, 58 + b, brass[5])
    else:   # clasp glints at the side of the throat
        P(c, [(46, 46 + b), (47, 46 + b)], tapa[5])


CLOAK = [
    dict(slug='oc-frond-rain-cape', cat='cloak', r=flax, lining=flax, len=62, flare=3, fx0=15, fx1=50, side_back=19, detail=_frond_cape),
    dict(slug='oc-fleece-mantle', cat='cloak', r=fleece, lining=suede, len=56, flare=3, x0=21, x1=44, fx0=15, fx1=50, side_back=20, detail=_fleece_mantle),
    dict(slug='oc-hibiscus-pareo', cat='cloak', r=coral, lining=coral, len=66, flare=3, fx0=15, fx1=50, side_back=19, folds=(26, 33), detail=_pareo),
    dict(slug='oc-red-dust-poncho', cat='cloak', r=ochre, lining=ochre, len=62, flare=4, x0=20, x1=45, hemstyle='diamond', fx0=13, fx1=52, side_back=19, detail=_poncho),
    dict(slug='oc-storm-petrel-hood', cat='cloak', r=petrel, lining=petrel, len=67, flare=3, side_back=18, detail=_petrel),
]

ITEMS = FOOT + PACK + COAT + CLOAK
