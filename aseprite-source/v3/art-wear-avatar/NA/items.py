"""The Maplewold (NA): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/NA/common.lua (N.*)
and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light)
maple = ["#5e1c2a", "#8a2632", "#b33a36", "#d4553c", "#ea7a4a", "#f8a86a"]
dkcheck = ["#2e2030", "#3a2a3a", "#4a3846", "#5c4854", "#715a64", "#8a7078"]
birch = ["#5a5050", "#7e746c", "#a89e90", "#cbc2b0", "#e4dcc8", "#f4eedc"]
snow = ["#5a6a8e", "#7c90b4", "#a2b8d4", "#c4d8ea", "#dfecf4", "#f2f8f6"]
gold = ["#6a3e1a", "#9a5e1e", "#c88428", "#e6aa3a", "#f6cc5a", "#ffe8a0"]
navy = ["#1a1e3e", "#252c5a", "#323e78", "#425696", "#5a74b4", "#86a2d2"]
aurora = ["#1d4a48", "#24705a", "#2e9a6a", "#48c07a", "#7ade8a", "#b8f2a8"]
slicker = ["#6a4a12", "#9a6e18", "#c89a22", "#e6c030", "#f6dc52", "#fff2a0"]
slate = ["#283846", "#36506a", "#46688a", "#5c84a8", "#7ea4c4", "#b0cce0"]
knit = ["#6a5a48", "#8e7c64", "#b0a084", "#cdbfa0", "#e4d8bc", "#f6eedc"]
duck = ["#2e3424", "#434a30", "#5a623c", "#727a4a", "#8e955c", "#b0b47a"]
wheat = ["#5e4426", "#86622e", "#a8823c", "#c6a050", "#dcbc6a", "#f0d894"]
rubber = ["#2a1c22", "#3a2830", "#4c363a", "#604846", "#785c52", "#927262"]
pine = ["#16302a", "#1f4636", "#2a5e40", "#3a784a", "#529456", "#7cb46a"]
lining = ["#5a3a2a", "#8a5a36", "#b07a46", "#cf9b5c", "#e6bd7e", "#f6dca6"]
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
jay = ["#1e2f63", "#28488e", "#3364b4", "#4688d2", "#6cb0e6", "#bfe6f6"]
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
canvas = ["#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
steel = ["#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2"]
autumn = ["#6e2a1c", "#a8401e", "#d8602a", "#ee8434", "#f8a848", "#ffd27a"]
cloakg = ["#1c3530", "#264a3c", "#335f43", "#45784b", "#5e9452", "#86b464"]


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


# ======================================================================== FOOTWEAR
def _snowboots(c, g, ft, k):
    top, x0, x1, cy = g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    v = g['view']
    # rubber lower shell climbs 1 row up the shaft
    for x in range(x0, x1 + 1): c.put(x, cy - 3, rubber[2] if x < x1 - 2 else rubber[1])
    # red check cuff (2 rows, 1px check with dark)
    for x in range(x0, x1 + 1):
        c.put(x, top, maple[4] if x % 2 else maple[3])
        c.put(x, top + 1, maple[2] if x % 2 else dkcheck[1])
    if v == 'front':      # laces up the front
        mx = (x0 + x1) // 2
        for y in range(top + 2, cy - 3): c.put(mx, y, lining[4] if y % 2 else lining[2])
        if k == 1: P(c, [(mx + 1, top + 3), (mx + 2, top + 4)], maple[3]); c.put(mx + 1, top + 4, maple[1])   # maple tag
    elif v == 'side':
        for y in range(top + 2, cy - 3): c.put(x1, y, lining[4] if y % 2 else lining[2])
        if g['far'] is False: P(c, [(x1 + 1, top + 3)], maple[3])


def _clog(c, g, ft, k):
    v, cy, cx = g['view'], int(ft['cy']), ft['cx']
    top = g['top']
    # birch band round the heel/ankle: 2 rows of white bark with ink lenticels
    for y in (top, top + 1):
        for x in range(g['sx0'], g['sx1'] + 1):
            c.put(x, y, birch[4] if y == top else birch[3])
    for x in range(g['sx0'] + 1, g['sx1'], 3): c.put(x, top + 1, birch[0])
    for x in range(g['sx0'] + 2, g['sx1'], 4): c.put(x, top, birch[1])
    # carved grain on the wooden toe
    if v != 'back': P(c, [(int(cx) - 1, cy), (int(cx) + 1, cy)], wood[2])
    if k == 1 and v != 'back': P(c, [(g['sx1'] + 1, top), (g['sx1'] + 1, top - 1)], birch[5])   # bark curl peeling off


def _snowshoe(c, g, ft, k):
    v, cx, cy = g['view'], ft['cx'], ft['cy']
    if v == 'side':
        frame = ellipse(cx + 0.5, cy + 2, 8, 1.5)
        frame |= line([(cx - 8, cy + 2), (cx - 11, cy + 2)], 1)     # tail of the shoe
    else:
        frame = ellipse(cx + (-1 if ft['side'] == 'L' else 1), cy + 2, 5.5, 1.5)
    inner = M(q for q in frame if all((q[0] + dx, q[1] + dy) in frame for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))))
    for q in frame: c.put(q[0], q[1], wood[4] if q[1] < cy + 2 else wood[2])
    for q in inner: c.put(q[0], q[1], canvas[4] if (q[0] + q[1]) % 2 else canvas[1])   # lattice
    # the small leather shoe on top of it
    shoe = g['foot']
    form(c, M(q for q in shoe if q[1] <= cy + 1), leather, frac=0.35)
    # strap over the toe
    for x in range(int(cx) - 2, int(cx) + 3): c.put(x, int(cy) - 1, strap[1])
    if k == 1 and v != 'back': P(c, [(int(cx) + 1, int(cy) - 3), (int(cx) + 2, int(cy) - 3), (int(cx) + 2, int(cy) - 2)], snow[5])


def _prairie(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # pull tabs: 1px loops above the rim at both sides
    for x in (x0 + 1, x1 - 1): c.put(x, top - 1, leather[2])
    if v == 'side': c.put(x1, top - 1, leather[2])
    # wheat-ear stitch: brass ticks up the shaft side
    sx = x0 + 2 if v != 'side' else x0 + 2
    if v != 'back' or True:
        for i, y in enumerate(range(top + 1, cy - 2)):
            c.put(sx + (i % 2), y, brass[4] if i % 2 else brass[3])
    # heel block
    if v == 'side': P(c, [(x0, cy + 2), (x0 + 1, cy + 2), (x0, cy + 3), (x0 + 1, cy + 3)], sole[1])
    else:
        for x in range(x0 + 1, x1): c.put(x, cy + 2, sole[1])


def _slippers(c, g, ft, k):
    v, top, cy = g['view'], g['top'], int(ft['cy'])
    # quilt lines across the puffy down
    for q in list(c.keys()):
        pass
    for q in g['foot'] | g['shaft']:
        if q[1] in (cy - 1, top + 3) and c.get(q) not in (None, INK): c.put(q[0], q[1], slate[2])
    # knitted cuff with ribs
    for x in range(g['sx0'], g['sx1'] + 1):
        for y in (top, top + 1):
            c.put(x, y, knit[4] if x % 2 else knit[3])
    if k == 0 and v != 'side':   # loon feather tucked in the cuff
        x = g['sx0'] + 1
        P(c, [(x, top - 1), (x - 1, top - 2), (x - 1, top - 3)], dkcheck[0]); P(c, [(x, top - 2)], snow[5]); P(c, [(x - 2, top - 3)], snow[4])
    if k == 1 and v == 'side':
        x = g['sx0'] + 1
        P(c, [(x, top - 1), (x - 1, top - 2), (x - 2, top - 3)], dkcheck[0]); P(c, [(x - 1, top - 3)], snow[5])


FOOT = [
    dict(slug='na-sugarbush-snow-boots', cat='footwear', shell=rubber, upper=leather[1:] + leather[-1:], sole=sole[0], rim=60, half=4, detail=_snowboots),
    dict(slug='na-birchwood-clog', cat='footwear', shell=wood, upper=birch, sole=wood[0], rim=64, half=4, puff=0.5, toe=1, detail=_clog),
    dict(slug='na-lakeland-snowshoe', cat='footwear', shell=leather, upper=leather, sole=leather[1], rim=None, detail=_snowshoe),
    dict(slug='na-prairie-stitch-boots', cat='footwear', shell=leather, upper=leather, sole=sole[1], rim=62, half=4, toe=1, detail=_prairie),
    dict(slug='na-loon-down-slippers', cat='footwear', shell=slate, upper=slate, sole=slate[0], rim=63, half=4, puff=1, detail=_slippers),
]


# ======================================================================== BACKPACK
def _weave(c, m, r):
    for q in m:
        c.put(q[0], q[1], r[4] if (q[0] // 2 + q[1]) % 2 else r[3])


def _shade_right(c, m, r, n=2):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if q[0] > x1 - n: c.put(q[0], q[1], r[2])
        if q[1] == y1: c.put(q[0], q[1], r[1])


def basket_back(c, x, y, g, mir=False):
    m = poly([(x - 9, y), (x + 8, y), (x + 6, y + 15), (x - 7, y + 15)])
    _weave(c, m, lining); _shade_right(c, m, lining)
    lid = rect(x - 9, y - 1, x + 8, y + 1)
    form(c, lid, strap, frac=0.3)
    for yy in range(y + 2, y + 11): c.put(x, yy, strap[2]); c.put(x - 1, yy, strap[3])
    P(c, [(x - 1, y + 6), (x, y + 6)], brass[4]); P(c, [(x - 1, y + 7), (x, y + 7)], brass[2])
    # fern frond under the lid, top left
    P(c, [(x - 7, y - 2), (x - 8, y - 3), (x - 9, y - 4), (x - 10, y - 5)], pine[3]); P(c, [(x - 7, y - 3), (x - 9, y - 5), (x - 8, y - 2)], pine[5])


def basket_side(c, x, y, g):
    m = poly([(x - 7, y), (x, y), (x, y + 15), (x - 5, y + 15)])
    _weave(c, m, lining); _shade_right(c, m, lining, 1)
    form(c, rect(x - 8, y - 1, x, y + 1), strap, frac=0.3)
    P(c, [(x - 8, y + 6), (x - 8, y + 7)], brass[4])
    P(c, [(x - 6, y - 2), (x - 7, y - 3), (x - 8, y - 4), (x - 9, y - 5)], pine[3]); P(c, [(x - 6, y - 3), (x - 8, y - 5)], pine[5])


def _log(c, x0, x1, y, r=birch):
    for xx in range(x0, x1 + 1):
        c.put(xx, y, r[5] if xx % 4 else r[4]); c.put(xx, y + 1, r[3] if xx % 5 != 2 else r[0]); c.put(xx, y + 2, r[2])
    P(c, [(x0, y), (x0, y + 1), (x0, y + 2)], wood[4]); c.put(x0, y + 1, wood[2])   # end grain


def firewood_back(c, x, y, g):
    for rx in (x - 7, x + 6):
        form(c, rect(rx, y - 4, rx + 1, y + 16), wood, frac=0.5)
    for yy in (y - 3, y + 15): form(c, rect(x - 7, yy, x + 7, yy), wood, frac=0.2, rim=False)
    for i, ly in enumerate((y, y + 4, y + 8)):
        _log(c, x - 10 + (i % 2), x + 9 - (i % 2), ly)
    for rx in (x - 4, x + 3):   # rope lashings
        for yy in range(y, y + 12): c.put(rx, yy, canvas[4] if yy % 2 else canvas[2])
    P(c, [(x, y + 16), (x, y + 17)], strap[1]); form(c, rect(x - 1, y + 18, x + 1, y + 20), wood, frac=0.4)   # pinecone


def firewood_side(c, x, y, g):
    form(c, rect(x - 1, y - 4, x, y + 16), wood, frac=0.5)
    for i, ly in enumerate((y, y + 4, y + 8)):
        e = ellipse(x - 4, ly + 1.5, 2.5, 1.5)
        for q in e: c.put(q[0], q[1], wood[4] if (q[0] - x) % 2 else wood[3])
        P(c, [(x - 4, ly + 1), (x - 4, ly + 2)], wood[1])
        for xx in range(x - 7, x - 6): pass
    for yy in range(y, y + 12): c.put(x - 3, yy, canvas[4] if yy % 2 else canvas[2])
    P(c, [(x - 1, y + 17), (x - 1, y + 18)], strap[1]); form(c, rect(x - 2, y + 19, x, y + 21), wood, frac=0.4)


def portage_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 8, 9.5, 8) | rect(x - 9, y + 4, x + 8, y + 13)
    form(c, m, duck, frac=0.3, hi=[(x - 6, y + 2)])
    flap = poly([(x - 8, y + 1), (x + 7, y + 1), (x + 6, y + 7), (x - 7, y + 7)])
    form(c, flap, duck, frac=0.3)
    for q in flap.bottom(): c.put(q[0], q[1], duck[1])
    for sx in (x - 4, x + 3):
        for yy in range(y + 4, y + 13): c.put(sx, yy, strap[2])
        P(c, [(sx, y + 8)], brass[4]); P(c, [(sx - 1, y + 8), (sx + 1, y + 8)], brass[2])
    for xx in range(x - 3, x + 3): c.put(xx, y - 1, strap[2])   # head strap loop over the top
    P(c, [(x - 4, y), (x + 3, y)], strap[2])
    P(c, [(x + 4, y + 3), (x + 5, y + 3)], autumn[3]); c.put(x + 5, y + 2, jay[4])   # fishing fly on the flap


def portage_side(c, x, y, g):
    m = ellipse(x - 4, y + 8, 4.5, 8)
    form(c, m, duck, frac=0.3)
    for yy in range(y + 3, y + 8): c.put(x - 8, yy, duck[1])
    for yy in range(y + 4, y + 13): c.put(x - 6, yy, strap[2])
    c.put(x - 6, y + 8, brass[4])
    P(c, [(x - 2, y - 1), (x - 1, y - 2), (x, y - 2)], strap[2])


def bucket_back(c, x, y, g):
    m = rect(x - 7, y + 1, x + 6, y + 15)
    form(c, m, wood, frac=0.3)
    for sx in range(x - 5, x + 6, 3):
        for yy in range(y + 2, y + 15): c.put(sx, yy, wood[2] if sx < x + 3 else wood[1])
    for hy in (y + 3, y + 12):
        for xx in range(x - 7, x + 7): c.put(xx, hy, steel[4] if xx < x + 3 else steel[2])
    lid = rect(x - 8, y - 1, x + 7, y)
    form(c, lid, wood, frac=0.3)
    P(c, [(x - 1, y - 2), (x, y - 2)], wood[3])
    # spout on the side + amber drop
    P(c, [(x + 7, y + 6), (x + 8, y + 6), (x + 9, y + 6)], steel[3]); c.put(x + 9, y + 7, steel[1])
    P(c, [(x + 9, y + 8), (x + 9, y + 9)], gold[3]); c.put(x + 9, y + 8, gold[5])


def bucket_side(c, x, y, g):
    m = rect(x - 8, y + 1, x, y + 15)
    form(c, m, wood, frac=0.25)
    for sx in range(x - 6, x, 3):
        for yy in range(y + 2, y + 15): c.put(sx, yy, wood[2])
    for hy in (y + 3, y + 12):
        for xx in range(x - 8, x + 1): c.put(xx, hy, steel[4] if xx < x - 2 else steel[2])
    form(c, rect(x - 9, y - 1, x, y), wood, frac=0.3)
    P(c, [(x - 9, y + 6), (x - 10, y + 6), (x - 11, y + 6)], steel[3])
    P(c, [(x - 11, y + 7), (x - 11, y + 8)], gold[3]); c.put(x - 11, y + 7, gold[5])


def tob_back(c, x, y, g):
    board = rect(x - 5, y - 3, x + 4, y + 17)
    form(c, board, wood, frac=0.3)
    for sx in (x - 2, x + 1):
        for yy in range(y - 3, y + 18): c.put(sx, yy, wood[2])
    bundle = rect(x - 8, y + 3, x + 7, y + 11)
    for q in bundle:   # red plaid bundle
        a, b = (q[0] - x) % 4 < 1, (q[1] - y) % 4 < 1
        c.put(q[0], q[1], dkcheck[1] if a and b else (maple[2] if a or b else maple[3]))
    for q in bundle.top(): c.put(q[0], q[1], maple[4])
    for xx in range(x - 8, x + 8): c.put(xx, y + 7, canvas[4] if xx % 2 else canvas[2])
    # curl peeking over the left shoulder + bell
    P(c, [(x - 6, y - 4), (x - 7, y - 5), (x - 8, y - 6)], wood[3]); P(c, [(x - 9, y - 5), (x - 9, y - 4)], brass[4])


def tob_side(c, x, y, g):
    board = rect(x - 2, y - 2, x - 1, y + 17)
    form(c, board, wood, frac=0.5)
    curl = line([(x - 1, y - 2), (x - 2, y - 6), (x - 4, y - 9), (x - 7, y - 10), (x - 9, y - 9), (x - 9, y - 7), (x - 7, y - 6)], 2)
    form(c, curl, wood, frac=0.3)
    bundle = rect(x - 9, y + 3, x - 3, y + 11)
    for q in bundle:
        a, b = (q[0] - x) % 4 < 1, (q[1] - y) % 4 < 1
        c.put(q[0], q[1], dkcheck[1] if a and b else (maple[2] if a or b else maple[3]))
    for xx in range(x - 9, x - 2): c.put(xx, y + 7, canvas[4] if xx % 2 else canvas[2])
    P(c, [(x - 6, y - 5), (x - 5, y - 5), (x - 6, y - 4), (x - 5, y - 4)], brass[4]); c.put(x - 5, y - 4, brass[2])


PACK = [
    dict(slug='na-splint-pack-basket', cat='backpack', back=basket_back, side=basket_side),
    dict(slug='na-firewood-pack-frame', cat='backpack', back=firewood_back, side=firewood_side),
    dict(slug='na-portage-sack', cat='backpack', back=portage_back, side=portage_side),
    dict(slug='na-sap-run-bucket', cat='backpack', back=bucket_back, side=bucket_side),
    dict(slug='na-toboggan-pack', cat='backpack', back=tob_back, side=tob_side),
]


# ======================================================================== COAT
def _check(q, t, g):
    a, b = (q[0] // 2) % 2, ((q[1] + g['b']) // 2) % 2
    if a and b: return dkcheck[2 - min(t, 2) // 2] if t < 3 else dkcheck[0]
    if a or b: return maple[max(1, 2 - (t >= 2))] if t else maple[3]
    return None


def _jacket(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        for y in (60, 62): P(c, [(32 + 0, y + b), (33, y + b)], wood[4])
        P(c, [(41, 54 + b), (42, 54 + b), (43, 54 + b)], dkcheck[0])   # pocket flap beside the beard
        c.put(42, 53 + b, wood[5])   # shaving curl
    if v == 'side':
        P(c, [(39, 52 + b), (40, 52 + b), (41, 52 + b)], dkcheck[0]); c.put(40, 51 + b, wood[5])


def _baffles(q, t, g):
    if (q[1] - g['b']) % 3 == 0: return gold[2] if t < 2 else gold[1]
    return None


def _vest(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        e = ellipse(41.5, 55 + b, 1.5, 1.5)
        for q in e: c.put(q[0], q[1], pine[4] if q[1] < 55 + b else pine[3])
        c.put(41, 54 + b, snow[4])
        for y in range(59, 64): c.put(32, y + b, wood[3])
    elif v == 'side':
        e = ellipse(38.5, 55 + b, 1.5, 1.5)
        for q in e: c.put(q[0], q[1], pine[4])
        c.put(38, 54 + b, snow[4])


def _duster(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    # shoulder cape: a lit band over the shoulders/upper arms
    if v != 'side':
        cape = ellipse(32.5, 49 + b, 13.5, 4).rows(46 + b, 52 + b)
        form(c, cape, wheat, frac=0.35)
        for q in cape.bottom(): c.put(q[0], q[1], wheat[1])
    else:
        cape = ellipse(32, 49 + b, 9, 4).rows(46 + b, 52 + b)
        form(c, cape, wheat, frac=0.3)
        for q in cape.bottom(): c.put(q[0], q[1], wheat[1])
    if v == 'back':   # split back hem
        for y in range(63, 67): c.put(32 + hs, y + b, INK)
    if v == 'front':
        P(c, [(42, 48 + b), (43, 47 + b), (44, 46 + b)], gold[4]); c.put(44, 45 + b, gold[5])   # wheat stalk in the buttonhole
        for y in (61, 63, 65): c.put(33, y + b, wood[4])


def _rib(q, t, g):
    if q[0] % 2 == 0 and t < 3: return knit[max(1, 3 - t - 1 + 1)] if t else knit[3]
    return None


def _cardigan_pat(q, t, g):
    y = q[1] - g['b']
    if 60 <= y <= 62:   # pine knit band
        x = q[0] % 4
        tree = (y == 60 and x == 1) or (y == 61 and x in (0, 1, 2)) or (y == 62 and x == 1)
        return cloakg[3] if tree else knit[4]
    return _rib(q, t, g)


def _cardigan(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        for y in (59, 61, 63): P(c, [(31, y + b), (34, y + b)], wood[4])
        P(c, [(38, 65 + b), (38, 66 + b)], knit[4])   # loose yarn end
    elif v == 'back':
        P(c, [(40, 65 + b), (40, 66 + b), (41, 67 + b)], knit[4])
    else:
        P(c, [(41, 64 + b), (42, 65 + b), (42, 66 + b)], knit[4])


def _parka(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        pouch = rect(28, 59 + b, 37, 63 + b)
        form(c, pouch, navy, frac=0.3)
        for q in pouch.top(): c.put(q[0], q[1], navy[1])
        # snow ruff peeking at the shoulders behind the beard
        for x0 in (19, 44):
            for q in ellipse(x0 + 0.5, 45.5 + b, 1.8, 1.3): c.put(q[0], q[1], snow[4] if (q[0] + q[1]) % 2 else snow[3])
    if v == 'back':   # hood down the back: ruffed rim
        hood = ellipse(32.5, 51 + b, 6.5, 4.5)
        form(c, hood, navy, frac=0.3)
        inner = ellipse(32.5, 50 + b, 4, 2.5)
        for q in hood - inner:
            if q[1] >= 49 + b: c.put(q[0], q[1], snow[4] if (q[0] + q[1]) % 2 else snow[3])
        for q in inner: c.put(q[0], q[1], navy[1])
    if v == 'side':
        hood = ellipse(25, 50 + b, 3.5, 4.5)
        form(c, hood, navy, frac=0.3)
        for q in hood:
            if q[0] >= 27: c.put(q[0], q[1], snow[4] if (q[0] + q[1]) % 2 else snow[3])
    # drawcord at the hem + snowflake toggle
    hem_y = 64 + b + 1
    if v != 'side':
        for x in range(21 + hs, 45 + hs): c.put(x, hem_y, snow[2] if x % 2 else snow[3])
        if v == 'front': P(c, [(43 + hs, hem_y + 1), (43 + hs, hem_y + 2)], snow[3]); c.put(43 + hs, hem_y + 3, snow[5])
    else:
        for x in range(23 + hs, 43 + hs): c.put(x, hem_y, snow[2] if x % 2 else snow[3])
        P(c, [(40, hem_y + 1), (40, hem_y + 2), (39, hem_y + 2), (41, hem_y + 2)], snow[5])


COAT = [
    dict(slug='na-lumber-check-jacket', cat='coat', r=maple, pattern=_check, detail=_jacket),
    dict(slug='na-goldenrod-down-vest', cat='coat', r=gold, sleeves=False, puff=1, pattern=_baffles, detail=_vest),
    dict(slug='na-prairie-duster', cat='coat', r=wheat, hem=2, detail=_duster),
    dict(slug='na-lodge-cardigan', cat='coat', r=knit, open=2, pattern=_cardigan_pat, detail=_cardigan),
    dict(slug='na-frostline-parka', cat='coat', r=navy, hem=1, detail=_parka),
]


# ======================================================================== CLOAK
def _mantle(c, g, m, v):
    if v == 'back':   # seed helicopter pinned at the back collar? (clasp is at the throat: front only, hidden) -> leaf vein
        pass


def _poncho(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    # two dark bands following the hem
    for q in m:
        below = sum(1 for k in range(1, 6) if (q[0], q[1] + k) in m)
        if below in (3, 4) and v != 'front': c.put(q[0], q[1], dkcheck[2] if below == 3 else maple[1] if False else dkcheck[3])
    # corner tassels
    if v != 'side':
        left = min(m, key=lambda q: (q[0], -q[1])); right = max(m, key=lambda q: (q[0], q[1]))
        for t in (left, right):
            P(c, [(t[0], t[1] + 1), (t[0], t[1] + 2)], dkcheck[1]); c.put(t[0], t[1] + 3, dkcheck[3])
        bot = max(m, key=lambda q: q[1])
        P(c, [(bot[0], bot[1] + 1), (bot[0], bot[1] + 2)], dkcheck[1])
    else:
        bot = min((q for q in m if q[1] >= y1 - 1), key=lambda q: q[0])
        P(c, [(bot[0], bot[1] + 1), (bot[0], bot[1] + 2)], dkcheck[1])
    # chickadee on the shoulder
    b = g['b']
    if v == 'back':
        bird = {(44, 45): dkcheck[0], (45, 45): dkcheck[0], (44, 46): snow[5], (45, 46): birch[3], (46, 46): birch[2], (47, 46): dkcheck[1], (43, 46): lining[4]}
    elif v == 'side':
        bird = {(24, 44): dkcheck[0], (25, 44): dkcheck[0], (24, 45): snow[5], (25, 45): birch[3], (23, 45): birch[2], (22, 45): dkcheck[1], (26, 45): lining[4]}
    else:
        bird = {(18, 45): dkcheck[0], (19, 45): dkcheck[0], (18, 46): birch[3], (19, 46): snow[5], (17, 46): birch[2], (16, 46): dkcheck[1]}
    for (x, y), col in bird.items(): c.put(x, y + b, col)


def _aurora_hood(c, g, m, v):
    b = g['b']
    if v == 'back':
        hood = poly([(26, 49 + b), (39, 49 + b), (34, 56 + b), (31, 56 + b)])
        form(c, hood, navy, frac=0.35)
        for q in hood.inner_edge():
            if q[1] > 49 + b: c.put(q[0], q[1], aurora[4] if (q[0] + q[1]) % 3 else aurora[3])
        c.put(32, 57 + b, aurora[5])
    elif v == 'side':
        hood = ellipse(24.5, 50 + b, 3, 4)
        form(c, hood, navy, frac=0.3)
        for q in hood.inner_edge(): c.put(q[0], q[1], aurora[4])


def _slicker(c, g, m, v):
    b = g['b']
    if v == 'back':
        hood = ellipse(32.5, 51.5 + b, 6, 3.5)
        form(c, hood, slicker, frac=0.35)
        brim = rect(25, 55 + b, 40, 55 + b)
        for q in brim: c.put(q[0], q[1], slicker[2])
        for q in rect(26, 56 + b, 39, 56 + b): c.put(q[0], q[1], jay[2])
        P(c, [(32, 57 + b), (33, 57 + b)], steel[4]); c.put(34, 57 + b, steel[2])   # fish charm on the hood toggle
    elif v == 'side':
        hood = ellipse(24, 50 + b, 3, 4)
        form(c, hood, slicker, frac=0.3)
        for y in range(46, 55): c.put(21, y + b, slicker[2])
    elif v == 'front':
        for q in m:   # lining flicks at the hem
            if (q[0], q[1] + 1) not in m: c.put(q[0], q[1], jay[3])


def _shawl(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    for q in m.inner_edge():
        if q[1] > y0 + 2: c.put(q[0], q[1], cloakg[5] if (q[0] + q[1]) % 2 else cloakg[4])
    if v != 'front':
        bot = max(m, key=lambda q: (q[1], -abs(q[0] - 32)))
        bx, by = bot
        P(c, [(bx, by + 1)], knit[2])
        form(c, rect(bx - 1, by + 2, bx + 1, by + 4), wood, frac=0.4)
        c.put(bx, by + 5, wood[1])
    # needle texture
    for q in m:
        if (q[0] * 3 + q[1] * 2) % 7 == 0 and c.get(q) not in (INK,): c.put(q[0], q[1], cloakg[2])


CLOAK = [
    dict(slug='na-maple-mantle', cat='cloak', r=maple, lining=maple, len=55, flare=3, hemstyle='points', border=autumn, border_rows=2, fx0=15, fx1=50, side_back=19, detail=_mantle),
    dict(slug='na-birch-poncho', cat='cloak', r=birch, lining=birch, len=63, flare=4, x0=20, x1=45, hemstyle='diamond', fx0=13, fx1=52, detail=_poncho, side_back=19),
    dict(slug='na-northern-lights-cloak', cat='cloak', r=navy, lining=navy, len=67, flare=3, border=aurora, border_rows=2, border_sides=True, front_wide=2, detail=_aurora_hood, side_back=18),
    dict(slug='na-harbour-slicker-cape', cat='cloak', r=slicker, lining=slicker, len=61, flare=3, front_wide=3, detail=_slicker),
    dict(slug='na-pine-needle-shawl', cat='cloak', r=cloakg, lining=cloakg, len=63, flare=3, x0=19, x1=46, hemstyle='tri', fx0=15, fx1=50, detail=_shawl),
]

ITEMS = FOOT + PACK + COAT + CLOAK
