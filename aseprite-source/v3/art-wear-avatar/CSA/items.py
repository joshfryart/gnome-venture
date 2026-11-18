"""Spicepeak (CSA): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/CSA/common.lua (C.R.*)
and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light)
madder = ["#4a1424", "#6e1e2c", "#962a32", "#b83c38", "#d65a44", "#ec8a5e"]
saffron = ["#6a3a12", "#9a5a14", "#c8801a", "#e8a524", "#f6c84a", "#fde68a"]
indigo = ["#16183e", "#1f2a5e", "#2c3f82", "#3d58a2", "#5a7cc0", "#8eaedc"]
feltc = ["#5e5048", "#857565", "#a89a84", "#c8bca2", "#e0d6bc", "#f2ead2"]
yak = ["#2e1c18", "#45291f", "#5e3a28", "#7a4e34", "#966746", "#b2865e"]
bamboo = ["#4e3a18", "#76582a", "#9c7a38", "#bf9c4c", "#d8bb68", "#ecd890"]
copper = ["#4a1e18", "#7a3320", "#a84e2a", "#c86c38", "#e2925a", "#f4bc88"]
turq = ["#14504e", "#1e7a70", "#2ea08e", "#4cc0a6", "#7edcc0", "#bff2de"]
palm = ["#4a3e1a", "#6c5c22", "#8e7c2e", "#ae9a3e", "#c8b55a", "#e2d282"]
leaf = ["#1c3a22", "#265430", "#33703a", "#468c44", "#62a850", "#94c870"]
char = ["#221c26", "#2f2832", "#403840", "#544a50", "#6a5e62", "#867876"]
plum = ["#3a1e3a", "#56294e", "#743a62", "#924e74", "#ae6a88", "#cc92a6"]
crocus = ["#35295f", "#5a459e", "#8a6fd0", "#b69ae8", "#d6c4f6", "#efe4ff"]
goose = ["#3a3a44", "#55556a", "#76768a", "#9a9aac", "#c0c0cc", "#e2e2ea"]
lining = ["#5a3a2a", "#8a5a36", "#b07a46", "#cf9b5c", "#e6bd7e", "#f6dca6"]
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
water = ["#2a4a7a", "#3a86b0", "#4fa8c4", "#5fc4c8", "#8fdcd8", "#c8f4ea"]
ember = ["#5e1c33", "#8a2a3d", "#b52e3f", "#d23c3c", "#e8573f", "#ff8a5c"]
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
canvas = ["#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
steel = ["#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2"]
yarnB = ["#1d4048", "#285e62", "#357c78", "#46998c", "#68b8a2", "#a2dcc0"]
skin = ["#51302b", "#a8644a", "#c98462", "#f0b98d", "#ffe0bd", "#fff0dc"]   # bare foot (rig skin ramp, 6 tones)


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def _h(x, y, s=0):
    return ((x * 73856093) ^ (y * 19349663) ^ (s * 83492791)) % 97 / 97.0


# ======================================================================== FOOTWEAR
def _curltoe(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    if v == 'side':
        # gold running stitch along the vamp
        for x in range(cx - 1, cx + 4, 2): c.put(x, cy - 2, brass[4])
        tx = cx + 5   # toe tip curls up and back
        P(c, [(tx, cy), (tx + 1, cy - 1), (tx + 1, cy - 2), (tx + 1, cy - 3), (tx, cy - 4)], madder[4] if not g['far'] else madder[2])
        c.put(tx + 1, cy, madder[2])
        if not g['far']:
            P(c, [(tx - 1, cy - 4), (tx - 1, cy - 3)], saffron[5]); c.put(tx - 1, cy - 2, saffron[3])   # tassel
    else:
        for x in range(cx - 3, cx + 3, 2): c.put(x, cy - 1, brass[4])
        if v == 'front':   # the curl rises in front of the instep, tassel at the tip
            P(c, [(cx, cy - 2), (cx, cy - 3), (cx, cy - 4)], madder[4]); c.put(cx + 1, cy - 4, madder[2])
            c.put(cx, cy - 5, madder[3]); c.put(cx - 1, cy - 5, saffron[5]); c.put(cx - 1, cy - 4, saffron[3])
        else:
            for x in range(cx - 3, cx + 4): c.put(x, cy + 1, lining[3])   # tan sole showing at the heel


def _feltboots(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # madder spiral applique on the shin
    if v != 'back' and not g['far']:
        mx = (x0 + x1) // 2 if v == 'front' else x0 + 2
        sp = [(mx, top + 2), (mx + 1, top + 2), (mx + 2, top + 2), (mx - 1, top + 3), (mx + 2, top + 3), (mx - 1, top + 4), (mx + 1, top + 4),
              (mx, top + 5), (mx + 1, top + 5)]
        P(c, sp, madder[3]); c.put(mx, top + 2, madder[4]); c.put(mx - 1, top + 3, madder[4])
    # shaggy yak-wool tuft out of the top
    for x in range(x0, x1 + 1):
        c.put(x, top, yak[3] if x % 2 else yak[4]); c.put(x, top + 1, feltc[4])
        c.put(x, top - 1, yak[4] if x % 3 else yak[2])
        if x % 2 == 1: c.put(x, top - 2, yak[5] if x < x1 - 1 else yak[3])
    # felt texture flecks
    for q in g['shaft'] | g['foot']:
        if _h(*q) < 0.08 and c.get(q) not in (None, INK): c.put(q[0], q[1], feltc[2])


def _sandals(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # thick tan sole under the toes
    for x in range(x0, x1 + 1):
        if (x, y1) in foot: c.put(x, y1, leather[3]); c.put(x, y1 + 1, leather[1])
    if v == 'back':
        for x in range(x0 + 1, x1): c.put(x, y0 + 1, madder[2])   # heel strap
        return
    if v == 'front':
        # crossed madder straps (V) and the braided toe ring
        for i in range(3):
            c.put(cx - 2 + i, cy - 2 + i, madder[3] if i % 2 else madder[4]); c.put(cx + 2 - i, cy - 2 + i, madder[3] if i % 2 else madder[4])
        c.put(cx, cy + 1, brass[4])
        if k == 1:   # red chili hooked through the strap
            P(c, [(cx + 3, cy - 1), (cx + 4, cy), (cx + 4, cy + 1)], ember[3]); c.put(cx + 3, cy - 2, leaf[4]); c.put(cx + 4, cy, ember[5])
    else:
        for i, x in enumerate(range(cx - 1, cx + 3)): c.put(x, cy - 2 + (i // 2), madder[3 + (i % 2)])
        c.put(cx + 3, cy, brass[4])
        if not g['far']:
            P(c, [(cx + 1, cy - 3), (cx, cy - 4), (cx - 1, cy - 4)], ember[3]); c.put(cx + 2, cy - 3, leaf[4]); c.put(cx, cy - 4, ember[5])


def _stilts(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # bare foot on a wooden plank: plank = bottom 2 rows (1 px wider), jute strap across the instep
    for x in range(x0 - 1, x1 + 2):
        c.put(x, y1 - 1, wood[4] if x < x1 else wood[3]); c.put(x, y1, wood[2])
    for x in range(x0 + 1, x1):
        c.put(x, y0 + 1, bamboo[4] if x % 2 else bamboo[3])
    if v == 'side':
        for tx in (x0, x1 - 1):   # two tall teeth
            for yy in (y1 + 1, y1 + 2): c.put(tx, yy, wood[3]); c.put(tx + 1, yy, wood[2])
        if not g['far']:   # snail riding the front tooth
            P(c, [(x1 + 1, y1), (x1 + 2, y1), (x1 + 1, y1 + 1)], saffron[4]); c.put(x1 + 2, y1 + 1, saffron[1])
            P(c, [(x1 + 1, y1 + 2), (x1 + 2, y1 + 2), (x1 + 3, y1 + 2)], feltc[4]); c.put(x1 + 3, y1 + 1, feltc[5])
    else:
        for x in range(x0 + 1, x1):   # front tooth seen face-on
            c.put(x, y1 + 1, wood[3] if x < x1 - 1 else wood[2]); c.put(x, y1 + 2, wood[1] if x < x1 - 1 else wood[0])
        if v == 'front' and k == 1:
            P(c, [(x1, y1 + 1), (x1 + 1, y1 + 1), (x1, y1 + 2)], saffron[4]); c.put(x1 + 1, y1 + 2, saffron[1])
            P(c, [(x1 - 1, y1 + 3), (x1, y1 + 3), (x1 + 1, y1 + 3), (x1 + 2, y1 + 3)], feltc[4]); c.put(x1 + 2, y1 + 2, feltc[5])


def _hidewrap(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    cols = [yarnB[3], saffron[4], madder[3], saffron[4]]
    for y in range(top + 1, cy - 2):
        for x in range(x0, x1 + 1):
            if (x, y) in g['shaft']:
                band = cols[((y - top) + (x - x0) // 3) % 4]
                if x >= x1 - 1: band = {yarnB[3]: yarnB[1], saffron[4]: saffron[2], madder[3]: madder[1]}.get(band, band)
                c.put(x, y, band)
    for x in range(x0, x1 + 1): c.put(x, cy - 2, strap[2])   # cord tied at the ankle
    if not g['far'] and v != 'back':
        px = x1 + 1 if v == 'front' and ft['side'] == 'R' or v == 'side' else x0 - 1
        P(c, [(px, cy - 2), (px, cy - 1)], strap[3])
        P(c, [(px, cy), (px + (1 if px > x1 else -1), cy)], saffron[4]); c.put(px, cy + 1, saffron[2])   # pom-pom


FOOT = [
    dict(slug='csa-curl-toe-slippers', cat='footwear', shell=madder, upper=madder, sole=lining[2], rim=None, toe=2, detail=_curltoe),
    dict(slug='csa-felted-snow-boots', cat='footwear', shell=feltc, upper=feltc, sole=sole[1], rim=61, half=4, puff=0.5, detail=_feltboots),
    dict(slug='csa-toe-ring-sandals', cat='footwear', shell=skin, upper=skin, sole=leather[2], rim=None, detail=_sandals),
    dict(slug='csa-stilt-clogs', cat='footwear', shell=skin, upper=skin, sole=wood[2], rim=None, toe=1, detail=_stilts),
    dict(slug='csa-wrapped-hide-boots', cat='footwear', shell=yak, upper=yak, sole=yak[0], rim=58, half=4, toe=1, detail=_hidewrap),
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


def _chilies(c, cells):
    for i, (x, y) in enumerate(cells):
        c.put(x, y, ember[3 + (i % 3 == 0)] if i % 2 else ember[2])
    for i, (x, y) in enumerate(cells):
        if i % 4 == 1: c.put(x, y - 1, leaf[4])


def cone_back(c, x, y, g):
    m = poly([(x - 9, y), (x + 9, y), (x + 2, y + 15), (x - 2, y + 15)])
    _weave(c, m, bamboo); _shade_right(c, m, bamboo)
    for xx in range(x - 9, x + 9): c.put(xx, y, strap[2] if xx < x + 5 else strap[1])   # rim band
    heap = ellipse(x - 0.5, y - 1, 8, 2.2).rows(y - 4, y - 1)
    _chilies(c, sorted(heap))
    for q in heap:
        if (q[0] + q[1]) % 3 == 0: c.put(q[0], q[1], ember[4])
    P(c, [(x + 10, y + 1), (x + 10, y + 2), (x + 11, y + 3)], ember[3]); c.put(x + 9, y, leaf[4]); c.put(x + 10, y + 1, ember[5])   # tumbling chili


def cone_side(c, x, y, g):
    m = poly([(x - 9, y), (x + 1, y), (x - 1, y + 15), (x - 4, y + 15)])
    _weave(c, m, bamboo); _shade_right(c, m, bamboo, 1)
    for xx in range(x - 9, x + 1): c.put(xx, y, strap[2])
    heap = ellipse(x - 4, y - 1, 4.5, 2).rows(y - 3, y - 1)
    _chilies(c, sorted(heap))
    P(c, [(x - 10, y + 1), (x - 11, y + 2), (x - 11, y + 3)], ember[3]); c.put(x - 10, y, leaf[4])


def _ikat(c, m, ox):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        c.put(q[0], q[1], indigo[3] if (q[0] + q[1]) % 7 else indigo[4])
    for cxx in range(x0 + 3, x1 - 1, 5):
        for cyy in (y0 + 7,):
            for dy in range(-2, 3):
                for dx in range(-2 + abs(dy), 3 - abs(dy)):
                    q = (cxx + dx, cyy + dy)
                    if q in m:
                        col = saffron[4] if abs(dx) + abs(dy) <= 1 else madder[3]
                        if abs(dx) + abs(dy) == 2 and (q[1] % 2): col = madder[4]   # blurred ikat edge
                        c.put(q[0], q[1], col)
            c.put(cxx, cyy, madder[2])


def satchel_back(c, x, y, g):
    for xx, yy in line([(x - 5, y + 1), (x - 4, y - 2), (x + 3, y - 2), (x + 4, y + 1)], 1): c.put(xx, yy, strap[2])   # handle
    body = rect(x - 8, y + 1, x + 7, y + 13)
    _ikat(c, body, 0)
    _shade_right(c, body, indigo, 2)
    flap = poly([(x - 8, y + 1), (x + 8, y + 1), (x + 8, y + 5), (x, y + 7), (x - 8, y + 5)])
    form(c, flap, indigo, frac=0.25)
    for q in flap.bottom(): c.put(q[0], q[1], saffron[3] if q[0] % 2 else saffron[4])
    c.put(x, y + 7, brass[4])
    for tx in (x - 8, x + 7):   # corner tassels
        P(c, [(tx, y + 14), (tx, y + 15)], madder[3]); c.put(tx, y + 16, saffron[4])
    form(c, ellipse(x - 6, y + 6, 1.6, 1.6), madder, frac=0.4, hi=[(x - 7, y + 5)]); c.put(x - 6, y + 3, saffron[3])   # pomegranate


def satchel_side(c, x, y, g):
    body = rect(x - 6, y + 1, x, y + 13)
    form(c, body, indigo, frac=0.3)
    for yy in range(y + 3, y + 13, 3): c.put(x - 3, yy, saffron[4]); c.put(x - 4, yy + 1, madder[3])
    for yy in range(y + 1, y + 6): c.put(x - 6, yy, indigo[1]); c.put(x - 7, yy, indigo[2])
    P(c, [(x - 6, y + 14), (x - 6, y + 15)], madder[3]); c.put(x - 6, y + 16, saffron[4])
    form(c, ellipse(x - 6, y, 1.6, 1.6), madder, frac=0.4, hi=[(x - 7, y - 1)]); c.put(x - 6, y - 3, saffron[3])


def porter_back(c, x, y, g):
    for a, b in (((x - 3, y - 3), (x - 9, y + 15)), ((x + 2, y - 3), (x + 8, y + 15))):
        for q in line([a, b], 2): c.put(q[0], q[1], wood[3] if q[0] < x else wood[2])
    for xx in range(x - 8, x + 8): c.put(xx, y + 13, wood[2])
    # copper pot
    pot = ellipse(x - 0.5, y + 9, 6, 4.5) | rect(x - 3, y + 3, x + 2, y + 5)
    form(c, pot, copper, frac=0.35, hi=[(x - 4, y + 7), (x - 3, y + 6)])
    for xx in range(x - 4, x + 4): c.put(xx, y + 3, copper[5] if xx % 2 else copper[4])
    for xx in range(x - 7, x + 7, 2): c.put(xx, y + 9, canvas[4])   # rope
    # ladle hooked on the pot handle
    P(c, [(x - 7, y + 4), (x - 8, y + 5), (x - 9, y + 6), (x - 10, y + 7), (x - 10, y + 8)], wood[4]); P(c, [(x - 10, y + 9), (x - 11, y + 9), (x - 11, y + 10)], wood[2])
    # rolled striped rug on top
    rug = rect(x - 14, y - 3, x + 13, y + 0)
    for q in rug:
        col = [madder[3], feltc[4], madder[3], feltc[4], saffron[3]][(q[0] - x) % 5]
        if q[1] == y: col = {madder[3]: madder[1], feltc[4]: feltc[2], saffron[3]: saffron[1]}[col]
        elif q[1] == y - 3: col = {madder[3]: madder[4], feltc[4]: feltc[5], saffron[3]: saffron[4]}[col]
        c.put(q[0], q[1], col)
    for yy in range(y - 3, y + 1): c.put(x - 14, yy, feltc[2]); c.put(x + 13, yy, madder[1])


def porter_side(c, x, y, g):
    for q in line([(x - 1, y - 3), (x - 1, y + 15)], 2): c.put(q[0], q[1], wood[3])
    pot = ellipse(x - 6, y + 9, 4, 4.5) | rect(x - 7, y + 3, x - 4, y + 5)
    form(c, pot, copper, frac=0.3, hi=[(x - 8, y + 7)])
    for xx in range(x - 9, x - 1, 2): c.put(xx, y + 9, canvas[4])
    rug = ellipse(x - 3, y - 2, 2.5, 2.5)
    for q in rug: c.put(q[0], q[1], madder[3] if (abs(q[0] - x + 3) + abs(q[1] - y + 2)) % 2 else feltc[4])
    c.put(x - 3, y - 2, madder[1])
    P(c, [(x - 10, y + 4), (x - 11, y + 5), (x - 11, y + 6), (x - 11, y + 7)], wood[4]); P(c, [(x - 11, y + 8), (x - 12, y + 8)], wood[2])


def bundle_back(c, x, y, g):
    blob = ellipse(x - 0.5, y + 9, 9, 6.5)
    form(c, blob, indigo, frac=0.3, hi=[(x - 6, y + 5)])
    for q in blob:
        if (q[0] % 3 == 0) and (q[1] % 3 == 0) and c.get(q) != indigo[1]: c.put(q[0], q[1], feltc[4])
    for xx in range(x - 8, x + 8):
        if (xx, y + 13) in blob: c.put(xx, y + 13, madder[3])
    # two knot ears + knot
    for ear in (poly([(x - 2, y + 2), (x - 11, y - 1), (x - 11, y + 1), (x - 2, y + 5)]), poly([(x + 1, y + 2), (x + 10, y - 1), (x + 10, y + 1), (x + 1, y + 5)])):
        form(c, ear, indigo, frac=0.4)
    form(c, ellipse(x - 0.5, y + 3, 2, 1.5), indigo, frac=0.4)
    # cinnamon stick out of the knot
    for q in line([(x - 1, y + 3), (x - 5, y)], 1): c.put(q[0], q[1], copper[3])
    c.put(x - 5, y, copper[1]); c.put(x - 3, y + 2, copper[4])


def bundle_side(c, x, y, g):
    blob = ellipse(x - 4, y + 9, 4.5, 6.5)
    form(c, blob, indigo, frac=0.3)
    for q in blob:
        if (q[0] % 3 == 0) and (q[1] % 3 == 0) and c.get(q) != indigo[1]: c.put(q[0], q[1], feltc[4])
    form(c, poly([(x - 3, y + 3), (x - 6, y - 3), (x - 7, y - 2), (x - 5, y + 3)]), indigo, frac=0.4)
    for q in line([(x - 3, y + 2), (x - 1, y - 3)], 1): c.put(q[0], q[1], copper[3])


def tins_back(c, x, y, g):
    for i in range(3):
        t = rect(x - 6, y + 1 + i * 5, x + 5, y + 4 + i * 5)
        form(c, t, brass, frac=0.3, hi=[(x - 4, y + 2 + i * 5)])
        for xx in range(x - 6, x + 6): c.put(xx, y + 5 + i * 5, copper[2] if xx < x + 3 else copper[1])
        for xx in range(x - 4, x + 4, 2): c.put(xx, y + 3 + i * 5, saffron[1])
    form(c, rect(x - 5, y, x + 4, y), copper, frac=0.3)
    for sx in (x - 7, x + 6):   # side clip bars + handle
        for yy in range(y - 2, y + 15): c.put(sx, yy, steel[3] if sx < x else steel[2])
    for xx in range(x - 7, x + 7): c.put(xx, y - 3, steel[4] if xx < x + 3 else steel[2])
    c.put(x, y - 1, brass[4])
    P(c, [(x - 9, y - 1), (x - 10, y - 2), (x - 10, y - 3), (x - 9, y - 4), (x - 9, y - 5), (x - 10, y - 6)], feltc[5])   # steam curl


def tins_side(c, x, y, g):
    for i in range(3):
        form(c, rect(x - 8, y + 1 + i * 5, x - 1, y + 4 + i * 5), brass, frac=0.3)
        for xx in range(x - 8, x): c.put(xx, y + 5 + i * 5, copper[2])
    for yy in range(y - 2, y + 15): c.put(x - 9, yy, steel[3])
    for xx in range(x - 9, x): c.put(xx, y - 3, steel[4])
    P(c, [(x - 10, y - 1), (x - 11, y - 2), (x - 11, y - 3), (x - 10, y - 4), (x - 10, y - 5), (x - 11, y - 6)], feltc[5])


PACK = [
    dict(slug='csa-chili-cone-basket', cat='backpack', back=cone_back, side=cone_side, y0=52, front_lift=6),
    dict(slug='csa-ikat-saddle-satchel', cat='backpack', back=satchel_back, side=satchel_side),
    dict(slug='csa-porters-frame-pack', cat='backpack', back=porter_back, side=porter_side, y0=50),
    dict(slug='csa-block-print-bundle', cat='backpack', back=bundle_back, side=bundle_side, y0=50),
    dict(slug='csa-stacked-tin-pack', cat='backpack', back=tins_back, side=tins_side),
]


# ======================================================================== COAT
_STR = [madder, saffron, yarnB, saffron]


def _ikat_stripes(q, t, g):
    r = _STR[(q[0] // 2) % 4]
    col = r[max(1, min(5, 4 - t))]
    if q[1] % 3 == 0 and (q[0] % 2): col = r[max(1, min(5, 3 - t))]   # blurred ikat edges
    return col


def _robe(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    for q in list(c.keys()):   # lining edge binding along the long hem
        if q[1] >= 66 + b and (q[0], q[1] + 1) not in c: c.put(q[0], q[1], lining[3])
    if v == 'front':
        P(c, [(41, 50 + b), (42, 49 + b), (43, 50 + b)], crocus[3]); c.put(42, 50 + b, crocus[5]); c.put(42, 51 + b, saffron[4]); P(c, [(41, 52 + b), (42, 52 + b)], leaf[3])
        for y in range(60, 66): c.put(32, y + b, lining[3])   # front edge binding
    elif v == 'side':
        P(c, [(31, 51 + b), (32, 50 + b), (33, 51 + b)], crocus[3]); c.put(32, 51 + b, crocus[5]); P(c, [(32, 52 + b)], leaf[3])


def _kantha(q, t, g):
    y = q[1] - g['b']
    pr = [plum, yarnB, saffron, madder, feltc][int(_h(q[0] // 4, y // 4, 3) * 5)]
    if y % 2 == 0 and q[0] % 2 == 0: return feltc[5] if t < 2 else feltc[3]   # running stitch rows
    return pr[max(1, min(5, 4 - t))]


def _vest(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        form(c, ellipse(42, 56 + b, 1.5, 1.5), wood, frac=0.4, hi=[(41, 55 + b)]); c.put(42, 56 + b, wood[1])   # walnut button
    elif v == 'side':
        form(c, ellipse(36, 56 + b, 1.5, 1.5), wood, frac=0.4, hi=[(35, 55 + b)]); c.put(36, 56 + b, wood[1])


def _fleece_pat(q, t, g):
    y = q[1] - g['b']
    if y >= 63: return feltc[5] if (q[0] + y) % 2 else feltc[3]
    return None


def _fleece(c, g):
    v, b = g['view'], g['b']
    # fleece cuffs on every sleeve bottom
    for s in g['sleeves']:
        y1 = max(q[1] for q in s)
        for q in s:
            if q[1] >= y1 - 1: c.put(q[0], q[1], feltc[5] if (q[0] + q[1]) % 2 else feltc[3])
    # collar of curly fleece round the shoulders
    if v == 'back':
        col = ellipse(32.5, 48 + b, 12.5, 2.5).rows(46 + b, 50 + b)
    elif v == 'front':
        col = ellipse(19.5, 48 + b, 3, 2) | ellipse(45.5, 48 + b, 3, 2)
    else:
        col = ellipse(30, 49 + b, 4, 2)
    for q in col: c.put(q[0], q[1], feltc[5] if (q[0] + q[1]) % 2 else feltc[4] if q[1] < 48 + b else feltc[3])
    if v == 'front':
        P(c, [(33, 60 + b)], turq[4]); P(c, [(34, 60 + b), (33, 61 + b)], turq[3]); c.put(34, 61 + b, turq[1])   # turquoise toggle under the beard
        P(c, [(32, 60 + b), (35, 60 + b)], strap[1])
    elif v == 'side':
        P(c, [(39, 59 + b)], turq[4]); c.put(40, 59 + b, turq[2])


def _smock_pat(q, t, g):
    y = q[1] - g['b']
    if y <= 52 or (g['view'] == 'side' and y <= 53):   # madder yoke
        col = madder[max(1, min(5, 4 - t))]
        if (q[0] % 4 == 1 and y % 3 == 0): col = steel[4]
        elif (q[0] % 4 in (0, 2) and y % 3 == 0) or (q[0] % 4 == 1 and y % 3 in (1, 2)): col = saffron[3]
        return col
    if q[0] % 2 == 0: return indigo[max(1, min(5, 3 - t))]   # pleats
    return None


def _smock(c, g):
    v, b = g['view'], g['b']
    sp = {'front': (43, 51), 'back': (33, 51), 'side': (29, 51)}[v]
    x, y = sp[0], sp[1] + b
    c.put(x, y, steel[5]); P(c, [(x - 1, y - 1), (x + 1, y + 1)], saffron[5])   # sparkle
    if v == 'front':
        for xx in range(41, 47): c.put(xx, 53 + b, saffron[4] if xx % 2 else madder[1])


def _wrap(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        for q in line([(42, 57 + b), (29, 66 + b)], 1):   # crossover edge, madder trim
            if q in c: c.put(q[0], q[1], madder[3])
        for q in line([(42, 58 + b), (30, 66 + b)], 1):
            if q in c and c[q] != madder[3]: c.put(q[0], q[1], saffron[1])
        P(c, [(21, 59 + b), (20, 60 + b), (20, 61 + b), (21, 62 + b), (21, 63 + b), (20, 64 + b)], madder[4])   # side ties
        P(c, [(22, 59 + b), (22, 60 + b), (23, 61 + b), (22, 62 + b)], madder[2])
        P(c, [(42, 51 + b), (43, 50 + b), (43, 51 + b), (44, 50 + b)], leaf[4]); c.put(42, 52 + b, leaf[2]); c.put(44, 49 + b, leaf[5])   # tea leaf
    elif v == 'side':
        for q in line([(38, 52 + b), (40, 64 + b)], 1):
            if q in c: c.put(q[0], q[1], madder[3])
        P(c, [(34, 60 + b), (34, 61 + b), (35, 62 + b), (35, 63 + b), (34, 64 + b)], madder[4])
        P(c, [(29, 52 + b), (30, 51 + b), (30, 52 + b)], leaf[4]); c.put(31, 51 + b, leaf[5])
    else:
        P(c, [(44 + hs, 59 + b), (45 + hs, 60 + b), (45 + hs, 61 + b), (46 + hs, 62 + b)], madder[4])
    for q in list(c.keys()):
        if q[1] >= 66 + b and (q[0], q[1] + 1) not in c: c.put(q[0], q[1], madder[2])


COAT = [
    dict(slug='csa-ikat-robe-coat', cat='coat', r=madder, hem=3, pattern=_ikat_stripes, detail=_robe),
    dict(slug='csa-kantha-patch-vest', cat='coat', r=plum, sleeves=False, pattern=_kantha, detail=_vest),
    dict(slug='csa-fleece-collar-jacket', cat='coat', r=yak, hem=1, pattern=_fleece_pat, detail=_fleece),
    dict(slug='csa-mirror-work-smock', cat='coat', r=indigo, pattern=_smock_pat, detail=_smock),
    dict(slug='csa-turmeric-wrap-coat', cat='coat', r=saffron, hem=3, detail=_wrap),
]


# ======================================================================== CLOAK
def _palm(c, g, m, v):
    b, tl = g['b'], g['tail']
    if v == 'front':
        return
    # replace the template drape with a rounded leaf shell
    c.clear()
    if v == 'back':
        sh = ellipse(32.5 + tl * 0.5, 56 + b, 13, 11).rows(45 + b, 64 + b)
    else:
        sh = ellipse(25 + tl * 0.5, 55 + b, 7, 10).rows(45 + b, 64 + b)
        sh = M(q for q in sh if q[0] <= 30)
    x0, y0, x1, y1 = sh.bbox()
    form(c, sh, palm, frac=0.3)
    for q in sh:   # overlapping leaf rows: every 3rd row a shadowed scallop edge, a lit row above it
        r = (q[1] - y0) % 3
        if r == 2: c.put(q[0], q[1], palm[1] if q[0] % 4 else palm[2])
        elif r == 0 and q[1] > y0 and q[0] < x1 - 3: c.put(q[0], q[1], palm[4])
        if (q[0] - x0) % 5 == 0 and r == 1: c.put(q[0], q[1], palm[2])   # leaf ribs
    for q in sh.bottom(): c.put(q[0], q[1], bamboo[2])   # bamboo binding
    for dx, dy in ((-6, 6), (5, 9), (-2, 13)) if v == 'back' else ((-3, 5), (-4, 12)):
        q = (int((x0 + x1) / 2) + dx, y0 + dy)
        if q in sh: c.put(q[0], q[1], water[5]); c.put(q[0], q[1] + 1, water[3])
    # frog sitting on the shoulder of the shell
    fx, fy = (x1 - 6, y0) if v == 'back' else (x0 + 2, y0 + 1)
    frog = {(fx, fy - 1): leaf[4], (fx + 1, fy - 1): leaf[4], (fx + 2, fy - 1): leaf[3], (fx, fy - 2): leaf[5], (fx + 2, fy - 2): leaf[4],
            (fx + 1, fy): leaf[2], (fx, fy): leaf[2], (fx + 2, fy): leaf[1]}
    for (x, y), col in frog.items(): c.put(x, y, col)
    c.put(fx, fy - 2, INK if False else leaf[5])


def _shawl(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    # woven border: madder + teal bands two rows in from the edges
    for q in m:
        inside = all((q[0] + dx, q[1] + dy) in m for dx in (-2, 2) for dy in (0, 2))
        near = all((q[0] + dx, q[1] + dy) in m for dx in (-1, 1) for dy in (0, 1))
        if near and not inside and q[1] > y0 + 2: c.put(q[0], q[1], madder[3] if (q[0] + q[1]) % 2 else yarnB[3])
    # long fringe under the hem
    for q in m.bottom():
        if q[0] % 2 == 0 and v != 'front':
            P(c, [(q[0], q[1] + 1), (q[0], q[1] + 2)], feltc[3]); c.put(q[0], q[1] + 3, feltc[2])
    # tiny moth resting on the fold
    if v == 'back':
        mx, my = 30, y0 + 5
        P(c, [(mx, my), (mx + 2, my), (mx, my + 1), (mx + 2, my + 1)], lining[2]); c.put(mx + 1, my, yak[1]); c.put(mx + 1, my + 1, yak[2])
    elif v == 'side':
        mx, my = x0 + 4, y0 + 7
        P(c, [(mx, my), (mx + 1, my), (mx, my + 1)], lining[2]); c.put(mx + 1, my + 1, yak[1])


def _shepherd(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    b = g['b']
    for q in m:   # felt mottle
        if _h(*q) < 0.07: c.put(q[0], q[1], char[4])
    if v == 'back':
        for sx in (24, 40):   # spiral stitching on the squared shoulders
            sp = [(sx - 1, 52 + b), (sx, 52 + b), (sx + 1, 52 + b), (sx + 1, 53 + b), (sx + 1, 54 + b), (sx, 54 + b), (sx - 1, 54 + b), (sx - 1, 53 + b), (sx, 53 + b)]
            P(c, sp[:-1], feltc[4]); c.put(sx, 53 + b, char[1])
        for y in range(57 + b, y1 + 1): c.put(32 + g['tail'], y, feltc[3] if y % 2 else char[1])   # stitched centre seam
        P(c, [(38, 47 + b), (39, 47 + b)], strap[3]); form(c, rect(39, 48 + b, 40, 49 + b), brass, frac=0.5, hi=[(39, 48 + b)]); c.put(40, 50 + b, brass[0])   # bell
    elif v == 'side':
        for y in range(y0 + 6, y1, 2): c.put(x0 + 4 + g['tail'], y, feltc[3])
        P(c, [(28, 47 + b)], strap[3]); form(c, rect(28, 48 + b, 29, 49 + b), brass, frac=0.5, hi=[(28, 48 + b)])


_BANDS = [madder, saffron, yarnB, indigo, saffron, madder, feltc]


def _poncho(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    b = g['b']
    if v != 'front':
        for q in m:
            r = _BANDS[((q[1] - b - 46) // 2) % len(_BANDS)]
            t = 3 if q[0] < x1 - (x1 - x0) * 0.3 else 2
            if (q[0], q[1] + 1) not in m: t = 1
            c.put(q[0], q[1], r[t])
        for q in m.bottom():   # knotted fringe
            if q[0] % 2: P(c, [(q[0], q[1] + 1)], feltc[3]); c.put(q[0], q[1] + 2, feltc[2])
        for q in m.top(): c.put(q[0], q[1], yak[3])   # neck binding
    # barred goose feather tucked into the neck
    if v == 'back':
        pts = [(41, 50), (42, 49), (42, 48), (43, 47), (43, 46), (44, 45)]
    elif v == 'side':
        pts = [(26, 50), (25, 49), (25, 48), (24, 47), (24, 46), (23, 45)]
    else:
        return
    for i, (x, y) in enumerate(pts): c.put(x, y + b, goose[1] if i % 2 else goose[4])
    nx = 1 if v == 'back' else -1
    for i, (x, y) in enumerate(pts[1:4]): c.put(x + nx, y + b, goose[0] if i % 2 else goose[3])


def _indigo_hood(c, g, m, v):
    b, tl = g['b'], g['tail']
    if v == 'front':
        return
    for q in m:   # resist-dyed dot rows
        if q[0] % 3 == 1 and (q[1] - b) % 3 == 0 and c.get(q) not in (indigo[1],): c.put(q[0], q[1], feltc[4])
    if v == 'back':
        hood = poly([(26, 48 + b), (39, 48 + b), (35, 55 + b), (33 + tl, 59 + b), (31, 55 + b)])
        form(c, hood, indigo, frac=0.35)
        for q in hood.inner_edge():
            if q[1] <= 50 + b: c.put(q[0], q[1], madder[3])
        px, py = 33 + tl, 59 + b
    else:
        hood = poly([(28, 47 + b), (23, 48 + b), (21 + tl, 55 + b), (25, 54 + b), (27, 51 + b)])
        form(c, hood, indigo, frac=0.3)
        for q in hood.inner_edge():
            if q[0] >= 27: c.put(q[0], q[1], madder[3])
        px, py = 21 + tl, 55 + b
    # green parakeet perched on the hood point
    bird = {(px, py - 1): leaf[4], (px + 1, py - 1): leaf[4], (px, py - 2): leaf[5], (px + 1, py - 2): leaf[3], (px + 2, py - 2): ember[4],
            (px - 1, py): leaf[2], (px - 2, py + 1): leaf[1], (px, py): leaf[3]}
    for (x, y), col in bird.items(): c.put(x, y, col)


CLOAK = [
    dict(slug='csa-palm-leaf-rain-hood', cat='cloak', r=palm, lining=palm, len=63, flare=2, x0=20, x1=45, fx0=15, fx1=50, detail=_palm),
    dict(slug='csa-fine-wool-shawl', cat='cloak', r=feltc, lining=feltc, len=63, flare=3, x0=19, x1=46, hemstyle='tri', fx0=15, fx1=50, detail=_shawl),
    dict(slug='csa-felt-shepherd-cape', cat='cloak', r=char, lining=char, len=66, flare=1, x0=18, x1=47, fx0=14, fx1=51, front_flare=1, side_back=20, folds=(27, 37), detail=_shepherd),
    dict(slug='csa-striped-yak-poncho', cat='cloak', r=madder, lining=saffron, len=64, flare=4, x0=20, x1=45, hemstyle='diamond', fx0=13, fx1=52, detail=_poncho, side_back=19),
    dict(slug='csa-indigo-dot-cloak', cat='cloak', r=indigo, lining=madder, len=67, flare=3, front_wide=2, side_back=18, detail=_indigo_hood),
]

ITEMS = FOOT + PACK + COAT + CLOAK
