"""The Dunewhisper (MENA): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/MENA/common.lua
(C.R.*) and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- region ramps (common.lua, dark -> light)
sand = ["#6e4a34", "#94663f", "#b8874f", "#d4a865", "#e8c886", "#f6e2b0"]
ochre = ["#6a3418", "#9a521c", "#c4761e", "#e09a2c", "#f2bf4a", "#fbe08a"]
indigo = ["#1a1a44", "#24286a", "#2e3a8e", "#3e56ac", "#5a7cc8", "#8eaee0"]
madder = ["#4e1626", "#7a2030", "#a32e36", "#c4443c", "#dc6450", "#ee9070"]
palm = ["#4a3a1e", "#6e5628", "#957a36", "#b89c4a", "#d4bc66", "#ecda96"]
cedar = ["#3a1e18", "#5c2e20", "#7e4228", "#a05a32", "#c07a42", "#dc9e5e"]
copper = ["#4a1e18", "#7a3020", "#a8482a", "#cc6a36", "#e8925a", "#f8c294"]
camel = ["#4e3222", "#74492e", "#98643a", "#b8824a", "#d2a062", "#e8c48a"]
goat = ["#1e1620", "#2e2228", "#3e3030", "#52403a", "#6a5446", "#86705a"]
teal = ["#123a3e", "#185452", "#1f6e66", "#2a8a7a", "#45a892", "#7ccab0"]
gourd = ["#5a2e14", "#8a4a1a", "#b8681e", "#d88c2a", "#eeb04a", "#f8d47e"]
date = ["#2e1218", "#4a1a1e", "#6a2422", "#8a3426", "#a84a30", "#c8683e"]
mint = ["#1c3a26", "#25573a", "#2f7444", "#3f9150", "#62b25e", "#9ad27c"]
turq = ["#16485a", "#1e6e80", "#2896a0", "#3cb8b4", "#6ed6c4", "#b4f0dc"]
rose = ["#5a1838", "#842448", "#ac3658", "#cc5068", "#e47884", "#f4a8a4"]
linen = ["#5a4a3e", "#7e6a56", "#a08a6e", "#c0ac8a", "#dccaa6", "#f2e6c8"]
# ---- shared ramps (_gw.lua W.R)
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
water = ["#2a4a7a", "#3a86b0", "#4fa8c4", "#5fc4c8", "#8fdcd8", "#c8f4ea"]
lining = ["#5a3a2a", "#8a5a36", "#b07a46", "#cf9b5c", "#e6bd7e", "#f6dca6"]
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
# bare foot (rig skin ramp GNOME25_DEFAULT.skin, stretched to 6 tones)
skin = ["#51302b", "#8a5444", "#c98462", "#f0b98d", "#ffe0bd", "#fff0dc"]


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


# ======================================================================== FOOTWEAR
def _dune(c, g, ft, k):
    """saffron backless slipper: curled toe point, insole showing at the heel, a trickle of sand out of the toe."""
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    if v == 'side':
        tip = max(q[0] for q in g['foot'])
        P(c, [(tip + 1, cy - 1), (tip + 1, cy - 2), (tip, cy - 3)], ochre[4]); c.put(tip + 1, cy - 1, ochre[3])
        # backless: insole open at the heel
        P(c, [(int(cx) - 3, cy - 2), (int(cx) - 2, cy - 2), (int(cx) - 1, cy - 2)], lining[4])
        if not g['far']:   # sand pours out of the curled toe and piles at its foot (2 frame flicker)
            s = (g['f'] % 2)
            P(c, [(tip + 2, cy), (tip + 2, cy + 1), (tip + 3, cy + 2), (tip + 2, cy + 2)], sand[4])
            c.put(tip + 2, cy + s, sand[5]); c.put(tip + 3, cy + 1, sand[3])
    else:
        x = int(round(cx))
        if v == 'front':
            P(c, [(x, cy - 3), (x, cy - 4)], ochre[4]); c.put(x, cy - 3, ochre[3])   # toe point curling up
            for q in g['foot']:   # stitch line round the vamp
                if q[1] == cy and abs(q[0] - x) <= 2: c.put(q[0], q[1], ochre[2])
            if k == 1:
                bx = max(q[0] for q in g['foot'] if q[1] == cy + 2)
                P(c, [(bx + 1, cy + 2), (bx + 2, cy + 2), (bx + 1, cy + 1)], sand[4]); c.put(bx + 1, cy + 2, sand[5])
        else:   # back: open heel shows the tan insole
            for xx in range(x - 3, x + 3): c.put(xx, cy - 2, lining[4] if xx < x + 1 else lining[3])
            for xx in range(x - 2, x + 2): c.put(xx, cy - 1, lining[2])


def _palmrope(c, g, ft, k):
    """bare foot on a plaited palm sole; crossed leather straps and a toe loop; a gecko on the sole."""
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    foot = g['foot']
    x0, _, x1, y1 = foot.bbox()
    # plaited sole: 2 rows under the foot, 1 px wider
    for x in range(x0 - 1, x1 + 2):
        c.put(x, y1, palm[4] if (x + (0 if v != 'side' else 1)) % 2 else palm[2])
        c.put(x, y1 + 1, palm[2] if x % 2 else palm[1])
    if v == 'side':
        x = int(cx)
        P(c, [(x - 2, cy - 2), (x - 1, cy - 1), (x, cy), (x + 1, cy + 1)], leather[2])   # strap over the instep
        P(c, [(x - 2, cy), (x - 1, cy - 1), (x + 1, cy - 1)], leather[3])
        P(c, [(x1 - 1, cy), (x1, cy)], leather[2])                                       # toe loop
        P(c, [(x - 3, cy - 1), (x - 3, cy)], leather[1])                                 # heel strap
        if not g['far']:   # gecko along the sole edge, tail curled up the heel
            P(c, [(x - 1, y1 + 2), (x, y1 + 2), (x + 1, y1 + 2), (x + 2, y1 + 2)], mint[4])
            P(c, [(x - 2, y1 + 2), (x - 3, y1 + 1)], mint[3]); c.put(x + 3, y1 + 2, mint[3]); c.put(x + 2, y1 + 2, mint[5])
    else:
        x = int(round(cx))
        if v == 'front':   # X of straps over the instep + toe loop
            P(c, [(x - 3, cy - 2), (x - 2, cy - 1), (x - 1, cy), (x + 3, cy - 2), (x + 2, cy - 1), (x + 1, cy)], leather[2])
            P(c, [(x - 3, cy - 1), (x + 3, cy - 1)], leather[1])
            P(c, [(x, cy + 1), (x, cy)], leather[1])                       # toe loop between the toes
            P(c, [(x - 2, y1 - 1), (x + 2, y1 - 1)], skin[2])               # toe creases
            P(c, [(x, cy + 1), (x, cy + 2)], leather[1])
            if k == 1:   # gecko on the right sole edge
                P(c, [(x1 + 1, y1), (x1 + 2, y1), (x1 + 2, y1 - 1), (x1 + 3, y1 - 2)], mint[4]); c.put(x1 + 1, y1, mint[5])
                c.put(x1 + 2, y1 + 1, mint[3])
        else:
            for xx in range(x0 + 1, x1): c.put(xx, cy - 1, leather[2] if xx % 2 else leather[1])   # heel strap


def _wrap(c, g, ft, k):
    """indigo cloth strips wound round the shin (diagonal bands), tied with cord; turquoise bead on the cord end."""
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    for y in range(top, cy - 2):
        for x in range(x0, x1 + 1):
            ph = (x + y * (1 if v != 'back' else -1)) % 4
            if ph == 0: c.put(x, y, indigo[1] if x >= x1 - 1 else indigo[2])
            elif ph == 1 and x < x1 - 1: c.put(x, y, indigo[4])
    for x in range(x0, x1 + 1): c.put(x, top, indigo[4] if x < x1 - 1 else indigo[3])   # folded top edge
    # criss-cross cord
    mx = (x0 + x1) // 2
    for i, y in enumerate(range(top + 2, cy - 2)):
        d = (i % 4)
        xa = mx - 1 + (d if d < 3 else 1)
        if v == 'side': xa = x0 + 1 + (d if d < 3 else 1)
        c.put(xa, y, strap[4] if i % 2 else strap[3])
    if k == (0 if v != 'side' else 1) and v != 'back' or (v == 'back' and k == 1):
        bx = x0 - 1 if v == 'front' else (x1 + 1 if v == 'back' else x0 - 1)
        P(c, [(bx, top + 2), (bx, top + 3)], strap[3]); c.put(bx, top + 4, turq[4]); c.put(bx, top + 5, turq[2])


def _camelpad(c, g, ft, k):
    """round felt overshoe on a broad dark pad; madder rim; a stitched two-toed footprint on top."""
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    foot = g['foot']
    x0, _, x1, y1 = foot.bbox()
    for x in range(x0, x1 + 1): c.put(x, y1, sole[2] if x < x1 - 1 else sole[1])   # padded sole
    for x in range(x0 + 1, x1): c.put(x, y1 + 1, sole[1])
    # felt flecks
    for q in foot:
        if (q[0] * 5 + q[1] * 3) % 9 == 0 and q[1] < y1: c.put(q[0], q[1], camel[4])
    if v == 'front':
        x = int(round(cx))
        P(c, [(x - 2, cy - 1), (x - 2, cy), (x + 1, cy - 1), (x + 1, cy)], madder[3]); P(c, [(x - 2, cy - 1), (x + 1, cy - 1)], madder[4])
    elif v == 'side':
        x = int(cx)
        P(c, [(x + 1, cy - 2), (x + 2, cy - 2), (x + 4, cy - 1), (x + 5, cy - 1)], madder[3])


def _cedar(c, g, ft, k):
    """bare foot on a tall cedar stilt clog with a woven madder/linen strap; a cedar cone under the strap."""
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    foot = g['foot']
    x0, _, x1, y1 = foot.bbox()
    # platform board: the foot's 2 bottom rows, 1 px proud on each side
    board = M(q for q in foot if q[1] >= y1 - 1) | rect(x0 - 1, y1 - 1, x1 + 1, y1)
    for q in board: c.put(q[0], q[1], cedar[4] if q[1] == y1 - 1 else (cedar[3] if q[0] < x1 - 1 else cedar[2]))
    c.put(x0 - 1, y1, cedar[2]); c.put(x1 + 1, y1 - 1, cedar[3])
    # stilt blocks under the board (heel + toe: gap shows in profile)
    if v == 'side':
        blocks = rect(x0, y1 + 1, x0 + 2, y1 + 2) | rect(x1 - 3, y1 + 1, x1 - 1, y1 + 2)
    else:
        blocks = rect(x0 + 1, y1 + 1, x1 - 1, y1 + 2)
    for q in blocks: c.put(q[0], q[1], cedar[1] if q[1] == y1 + 1 else (cedar[2] if q[0] < x1 - 2 else cedar[1]))
    # striped strap across the top of the foot (2 rows: madder with linen ticks, deep madder)
    sy = cy - 1
    for q in foot:
        if v != 'back' and q[1] == sy: c.put(q[0], q[1], linen[4] if q[0] % 3 == 0 else madder[3])
        if v != 'back' and q[1] == sy + 1: c.put(q[0], q[1], madder[2] if q[0] % 3 else linen[3])
        if v == 'back' and q[1] == sy + 1 and x0 < q[0] < x1: c.put(q[0], q[1], madder[2])
    if not g.get('far') and k == 1 and v != 'back':   # little cedar cone tucked under the strap
        qx = x1 if v == 'front' else int(cx) + 1
        P(c, [(qx, sy - 1), (qx + 1, sy - 1), (qx, sy - 2), (qx + 1, sy - 2)], cedar[3]); c.put(qx + 1, sy - 1, cedar[1]); c.put(qx, sy - 2, cedar[5])


FOOT = [
    dict(slug='mena-dune-slippers', cat='footwear', shell=ochre, sole=sole[1], rim=None, toe=2, detail=_dune),
    dict(slug='mena-palm-rope-sandals', cat='footwear', shell=skin, sole=skin[2], rim=None, detail=_palmrope),
    dict(slug='mena-indigo-wrap-boots', cat='footwear', shell=camel, upper=indigo, sole=sole[1], rim=60, half=4, toe=1, detail=_wrap),
    dict(slug='mena-camel-pad-overshoes', cat='footwear', shell=camel, upper=camel, cuff=madder, cuff_rows=1, sole=sole[0], rim=64, half=4, puff=1, detail=_camelpad),
    dict(slug='mena-cedar-bath-clogs', cat='footwear', shell=skin, sole=cedar[1], rim=None, detail=_cedar),
]


# ======================================================================== BACKPACK
def _shade_right(c, m, r, n=2):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if q[0] > x1 - n: c.put(q[0], q[1], r[2])
        if q[1] == y1: c.put(q[0], q[1], r[1])


def skin_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 9, 10, 6.5)
    form(c, m, leather, frac=0.3, hi=[(x - 6, y + 5), (x - 5, y + 5)])
    # tied-off leg stumps at the lower corners
    for sx in (x - 10, x + 9):
        form(c, rect(sx, y + 12, sx + 1, y + 14), leather, frac=0.5)
        c.put(sx + (1 if sx > x else 0), y + 12, strap[2])
    # harness: band round the belly with two brass rings, shoulder straps up to the top
    for xx in range(x - 10, x + 10): c.put(xx, y + 9, strap[2] if xx < x + 5 else strap[1])
    for rx in (x - 5, x + 4):
        P(c, [(rx - 1, y + 9), (rx + 1, y + 9), (rx, y + 8), (rx, y + 10)], brass[3]); c.put(rx - 1, y + 8, brass[4])
        for yy in range(y - 1, y + 8): c.put(rx, yy, strap[3] if yy < y + 3 else strap[2])
    # wooden spout out of the upper left (neck of the skin), a water drop at its mouth
    form(c, line([(x - 9, y + 6), (x - 11, y + 4)], 2), leather, frac=0.5)
    form(c, rect(x - 13, y + 2, x - 12, y + 3), wood, frac=0.5); c.put(x - 13, y + 2, wood[5])
    c.put(x - 14, y + 3, water[5]); c.put(x - 14, y + 4, water[3])


def skin_side(c, x, y, g):
    m = ellipse(x - 5, y + 9, 5.5, 6.5)
    form(c, m, leather, frac=0.3, hi=[(x - 8, y + 5)])
    form(c, rect(x - 10, y + 12, x - 9, y + 14), leather, frac=0.5)
    for xx in range(x - 10, x + 1): c.put(xx, y + 9, strap[2])
    P(c, [(x - 6, y + 8), (x - 6, y + 10), (x - 7, y + 9), (x - 5, y + 9)], brass[3])
    form(c, line([(x - 4, y + 2), (x - 6, y - 1)], 2), wood, frac=0.5)
    P(c, [(x - 7, y - 2), (x - 6, y - 2)], wood[4])
    c.put(x - 8, y - 1, water[5]); c.put(x - 8, y, water[3])
    for yy in range(y - 1, y + 9): c.put(x, yy, strap[2])


def _weave(c, m, r, sh=0):
    for q in m:
        c.put(q[0], q[1], r[4] if ((q[0] + sh) // 2 + q[1]) % 2 else r[3])


def basket_back(c, x, y, g):
    m = poly([(x - 9, y + 1), (x + 8, y + 1), (x + 5, y + 16), (x - 6, y + 16)])
    _weave(c, m, palm); _shade_right(c, m, palm)
    rim = rect(x - 10, y, x + 9, y + 1)
    form(c, rim, palm, frac=0.25)
    for q in m:   # dyed bands: madder and indigo
        if q[1] == y + 7: c.put(q[0], q[1], madder[3] if q[0] < x + 4 else madder[2])
        if q[1] == y + 12: c.put(q[0], q[1], indigo[3] if q[0] < x + 3 else indigo[2])
    for q in ((x - 7, y + 2), (x - 6, y + 2), (x - 6, y + 3), (x + 2, y + 2), (x - 3, y + 2)):   # dates tumbling over the rim
        c.put(q[0], q[1], date[3] if q[1] == y + 2 else date[2])
    c.put(x - 7, y + 2, date[5]); c.put(x + 2, y + 2, date[5])
    # rope loops at the sides
    for sx, d in ((x - 10, -1), (x + 9, 1)):
        P(c, [(sx, y + 3), (sx + d, y + 4), (sx + d, y + 5), (sx + d, y + 6), (sx + d, y + 7), (sx, y + 8)], linen[3])
    # ripe dates heaped over the rim, a few spilling
    heap = ellipse(x - 0.5, y - 1, 8, 2)
    for q in heap:
        if q[1] <= y - 1:
            c.put(q[0], q[1], date[4] if (q[0] + q[1] * 2) % 3 == 0 else (date[3] if (q[0] + q[1]) % 2 else date[2]))
    for q in ((x - 5, y - 3), (x + 1, y - 3), (x - 2, y - 3), (x + 4, y - 2)): c.put(q[0], q[1], date[5])
    P(c, [(x + 3, y - 4), (x + 4, y - 5), (x + 5, y - 5)], palm[3])   # stalk
    P(c, [(x + 9, y + 2), (x + 9, y + 3)], date[3]); c.put(x + 9, y + 2, date[5])   # one spilling over the side


def basket_side(c, x, y, g):
    m = poly([(x - 9, y + 1), (x, y + 1), (x, y + 16), (x - 6, y + 16)])
    _weave(c, m, palm); _shade_right(c, m, palm, 1)
    form(c, rect(x - 10, y, x, y + 1), palm, frac=0.25)
    for q in m:
        if q[1] == y + 7: c.put(q[0], q[1], madder[3])
        if q[1] == y + 12: c.put(q[0], q[1], indigo[3])
    heap = ellipse(x - 5, y - 1, 4.5, 2)
    for q in heap:
        if q[1] <= y - 1: c.put(q[0], q[1], date[4] if (q[0] + q[1] * 2) % 3 == 0 else date[3] if (q[0] + q[1]) % 2 else date[2])
    P(c, [(x - 7, y - 3), (x - 4, y - 3)], date[5])
    P(c, [(x - 11, y + 2), (x - 11, y + 3)], date[3]); c.put(x - 11, y + 2, date[5])
    for yy in range(y + 2, y + 9): c.put(x, yy, linen[3])


def _kilim(c, m, x, y, w):
    """flat-weave field: indigo top with a diamond row, madder lower with linen pinstripes."""
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        r = q[1] - y0
        if r <= 5:
            col = indigo[3] if q[0] < x1 - 1 else indigo[2]
            dx = (q[0] - x0) % 5
            dd = abs(dx - 2) + abs(r - 3)
            if dd == 1: col = madder[4]
            elif dd == 0: col = ochre[4]
            elif dd == 2 and w > 6: col = ochre[2] if (q[0] + q[1]) % 2 else col
        else:
            col = madder[3] if q[0] < x1 - 1 else madder[2]
            if r in (8, 11): col = linen[4]
            elif r in (9, 12): col = indigo[2]
        c.put(q[0], q[1], col)


def kilim_back(c, x, y, g):
    m = rect(x - 9, y + 1, x + 8, y + 14)
    _kilim(c, m, x, y, 18)
    # flap point over the middle: V of madder edge
    for i in range(0, 4):
        for xx in (x - 1 - i, x + i): c.put(xx, y + 6 + (3 - i), madder[1])
    for q in m.bottom(): c.put(q[0], q[1], madder[1])
    # handle loop on top
    for xx in range(x - 5, x + 5): c.put(xx, y - 1, strap[3])
    P(c, [(x - 6, y), (x + 5, y)], strap[2])
    # brass bell at the flap point (swings with the tail)
    bx = x - 1 + g['tail'] // 2 if g['tail'] < 0 else x
    P(c, [(bx - 1, y + 10), (bx, y + 10), (bx + 1, y + 10), (bx, y + 9)], brass[3]); c.put(bx - 1, y + 10, brass[4]); c.put(bx, y + 11, brass[1])
    # corner tassels
    for tx in (x - 9, x + 8):
        P(c, [(tx, y + 15), (tx, y + 16)], madder[2]); c.put(tx, y + 17, ochre[3])


def kilim_side(c, x, y, g):
    m = rect(x - 4, y + 1, x, y + 14)
    _kilim(c, m, x, y, 5)
    for q in m.bottom(): c.put(q[0], q[1], madder[1])
    P(c, [(x - 5, y + 10), (x - 5, y + 9), (x - 6, y + 10)], brass[3]); c.put(x - 5, y + 11, brass[1]); c.put(x - 6, y + 9, brass[4])
    P(c, [(x - 4, y + 15), (x - 4, y + 16)], madder[2]); c.put(x - 4, y + 17, ochre[3])
    P(c, [(x - 1, y - 1), (x, y - 1), (x - 2, y)], strap[3])


def pot_back(c, x, y, g):
    for ux in (x - 8, x + 7):   # frame uprights
        form(c, rect(ux, y - 4, ux + 1, y + 16), wood, frac=0.5)
    form(c, rect(x - 8, y - 4, x + 8, y - 3), wood, frac=0.2)
    # rolled reed mat across the bottom
    mat = rect(x - 10, y + 13, x + 9, y + 15)
    for q in mat: c.put(q[0], q[1], palm[4] if q[0] % 2 else palm[2])
    for q in mat.top(): c.put(q[0], q[1], palm[5] if q[0] % 2 else palm[3])
    for q in mat.bottom(): c.put(q[0], q[1], palm[1])
    for yy in range(y + 13, y + 16): c.put(x - 11, yy, palm[3] if yy == y + 14 else palm[2])
    c.put(x - 11, y + 14, palm[1])
    # hammered copper pot
    pot = ellipse(x - 0.5, y + 7, 6, 5)
    form(c, pot, copper, frac=0.3, hi=[(x - 4, y + 4), (x - 3, y + 4)])
    for q in pot:
        if (q[0] * 3 + q[1] * 2) % 7 == 0 and c.get(q) == copper[3]: c.put(q[0], q[1], copper[4])
    neck = rect(x - 3, y + 1, x + 2, y + 2)
    form(c, neck, copper, frac=0.3)
    for xx in range(x - 4, x + 4): c.put(xx, y, copper[4] if xx < x + 2 else copper[3])
    for xx in (x - 7, x - 6, x + 5, x + 6): c.put(xx, y + 8, linen[3])
    # mint sprig: a bunch in the pot mouth, one stem leaning out over the left upright
    P(c, [(x, y - 1), (x - 1, y - 1), (x + 1, y - 2), (x - 2, y - 2)], mint[3])
    P(c, [(x - 1, y - 2), (x + 2, y - 3), (x - 3, y - 3), (x, y - 3)], mint[4]); P(c, [(x + 1, y - 3), (x - 2, y - 3)], mint[5])
    P(c, [(x - 4, y + 1), (x - 5, y + 1), (x - 6, y), (x - 7, y - 1)], mint[3])
    P(c, [(x - 8, y - 2), (x - 9, y - 1), (x - 10, y - 2), (x - 9, y - 3)], mint[4]); P(c, [(x - 9, y - 2), (x - 10, y - 3)], mint[5])


def pot_side(c, x, y, g):
    form(c, rect(x - 1, y - 4, x, y + 16), wood, frac=0.5)
    mat = ellipse(x - 4, y + 14, 2.5, 1.5)
    form(c, mat, palm, frac=0.3)
    P(c, [(x - 4, y + 14)], palm[1]); c.put(x - 5, y + 14, palm[2])
    pot = ellipse(x - 6, y + 7, 5, 5)
    form(c, pot, copper, frac=0.3, hi=[(x - 9, y + 4)])
    for q in pot:
        if (q[0] * 3 + q[1] * 2) % 7 == 0 and c.get(q) == copper[3]: c.put(q[0], q[1], copper[4])
    form(c, rect(x - 8, y + 1, x - 4, y + 2), copper, frac=0.3)
    for xx in range(x - 9, x - 2): c.put(xx, y, copper[4])
    P(c, [(x - 6, y - 1), (x - 6, y - 2), (x - 7, y - 3), (x - 5, y - 3)], mint[3])
    P(c, [(x - 8, y - 4), (x - 7, y - 4), (x - 5, y - 4), (x - 4, y - 4), (x - 6, y - 5)], mint[4]); c.put(x - 7, y - 5, mint[5])


def _net(c, m, sh=0):
    for q in m:
        if (q[0] + q[1] + sh) % 4 == 0 or (q[0] - q[1] + sh) % 4 == 0:
            if c.get(q) not in (None, INK): c.put(q[0], q[1], linen[4] if q[1] % 2 else linen[3])


def gourd_back(c, x, y, g):
    big = ellipse(x - 0.5, y + 10, 6.5, 6)
    small = ellipse(x - 0.5, y + 2, 3, 2.5)
    neck = rect(x - 2, y + 3, x + 1, y + 5)
    form(c, big, gourd, frac=0.3, hi=[(x - 5, y + 7), (x - 4, y + 6)])
    form(c, small | neck, gourd, frac=0.3, hi=[(x - 2, y + 1)])
    _net(c, big)
    for xx in range(x - 2, x + 2): c.put(xx, y + 4, linen[3])   # cord tie at the waist
    form(c, rect(x - 1, y - 2, x, y - 1), cedar, frac=0.5)
    # the spare cork-wood stopper dangling on its own string at the left, swinging with the step
    sx = x - 6 + g['tail']
    P(c, [(x - 3, y + 5), (x - 4, y + 6)] + [(x - 5 + (g['tail'] if yy > y + 12 else 0), yy) for yy in range(y + 7, y + 17)], linen[1])
    form(c, rect(sx - 1, y + 17, sx, y + 18), cedar, frac=0.5); c.put(sx - 1, y + 17, cedar[5])


def gourd_side(c, x, y, g):
    big = ellipse(x - 5.5, y + 11, 5.5, 6.5)
    small = ellipse(x - 4.5, y + 2.5, 3, 3)
    form(c, big, gourd, frac=0.3, hi=[(x - 9, y + 7)])
    form(c, small | rect(x - 6, y + 4, x - 3, y + 6), gourd, frac=0.3)
    _net(c, big, 1)
    form(c, rect(x - 5, y - 2, x - 4, y - 1), cedar, frac=0.5)
    sw = g['tail']
    P(c, [(x - 6, y - 1), (x - 7, y), (x - 8, y + 1)], linen[2])
    form(c, rect(x - 10 + sw, y + 2, x - 9 + sw, y + 3), cedar, frac=0.5)
    for yy in range(y + 3, y + 11): c.put(x, yy, linen[3])


PACK = [
    dict(slug='mena-goatskin-waterskin', cat='backpack', back=skin_back, side=skin_side),
    dict(slug='mena-date-palm-basket', cat='backpack', back=basket_back, side=basket_side, y0=49),
    dict(slug='mena-kilim-saddle-bag', cat='backpack', back=kilim_back, side=kilim_side),
    dict(slug='mena-copper-pot-frame', cat='backpack', back=pot_back, side=pot_side, y0=49),
    dict(slug='mena-bottle-gourd-sling', cat='backpack', back=gourd_back, side=gourd_side, y0=49),
]


# ======================================================================== COAT
_STRIPES = (linen, linen, madder, linen, indigo, linen, ochre)


def _loom(q, t, g):
    r = _STRIPES[q[0] % 7]
    return r[max(1, min(5, 4 - t))]


def _vest(c, g):
    v, b = g['view'], g['b']
    if v == 'front':   # tassel off the front corner of the opening
        for y in range(59, 65): c.put(31, y + b, madder[1])   # dark lining edge along the opening
        for y in range(59, 65): c.put(35, y + b, madder[1])
        P(c, [(31, 65 + b), (31, 66 + b)], madder[2]); P(c, [(30, 67 + b), (31, 67 + b), (32, 67 + b)], madder[3]); c.put(31, 68 + b, madder[1])
    elif v == 'side':
        P(c, [(41, 64 + b), (41, 65 + b)], madder[2]); P(c, [(40, 66 + b), (41, 66 + b), (42, 66 + b)], madder[3]); c.put(41, 67 + b, madder[1])


def _braid_pat(q, t, g):
    return None


def _braid(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    m = c.mask()
    # gold cord all round the hem and the cuffs
    for q in m.bottom():
        c.put(q[0], q[1], brass[3] if q[0] % 2 else brass[4])
        if (q[0], q[1] - 1) in m: c.put(q[0], q[1] - 1, brass[1] if q[0] % 2 else brass[2])
    for s in g['sleeves']:
        sm = s & m
        if not sm: continue
        yb = sm.bbox()[3]
        for q in sm:
            if q[1] in (yb - 1, yb - 2): c.put(q[0], q[1], brass[3] if (q[0] + q[1]) % 2 else brass[2])
    if v == 'front':
        for y in range(56, 64): c.put(33, y + b, brass[3] if y % 2 else brass[4])   # front edge cord
        P(c, [(31, 60 + b), (32, 60 + b), (34, 60 + b), (35, 60 + b)], brass[3])     # frog loops
        P(c, [(31, 59 + b), (35, 59 + b), (31, 61 + b), (35, 61 + b)], brass[2])
        # pomegranate button
        P(c, [(33, 61 + b), (34, 61 + b), (33, 62 + b), (34, 62 + b)], madder[3]); c.put(33, 61 + b, madder[5]); c.put(34, 62 + b, madder[1])
        c.put(33, 60 + b, madder[2]); c.put(34, 60 + b, ochre[3])
    elif v == 'back':   # braided knot loop in the middle of the back
        for q in ellipse(32.5, 56 + b, 3, 2.5).inner_edge(): c.put(q[0], q[1], brass[3] if (q[0] + q[1]) % 2 else brass[4])
        for y in range(46, 52): c.put(32 + (y % 2), y + b, brass[3])
    else:
        for y in range(52, 64): c.put(40 if y < 58 else 41, y + b, brass[3] if y % 2 else brass[4])
        P(c, [(41, 60 + b), (42, 60 + b), (41, 61 + b), (42, 61 + b)], madder[3]); c.put(41, 60 + b, madder[5]); c.put(41, 59 + b, ochre[3])


def _robe(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    m = c.mask()
    # wide sleeves: bell cuffs below each arm
    for s, (hx, hy) in zip(g['sleeves'], g['hands']):
        x0, y0, x1, y1 = s.bbox()
        cuff = rect(x0 - 1, y1 - 1, x1 + 1, y1)
        form(c, cuff, linen, frac=0.35)
        for q in cuff.bottom(): c.put(q[0], q[1], sand[2])
    # sand-shadow belt sash
    for q in m:
        if q[1] == 60 + b: c.put(q[0], q[1], sand[3] if q[0] < 40 + hs else sand[2])
        if q[1] == 61 + b: c.put(q[0], q[1], sand[2] if q[0] < 40 + hs else sand[1])
    if v == 'front':   # centre front edge
        for y in range(62, 69): c.put(33 + hs, y + b, linen[2])
        # darkling beetle walking up the hem (steps with the frame)
        bx, by = 39 + hs, 66 + b - (g['f'] % 3 == 0)
        P(c, [(bx, by), (bx + 1, by), (bx, by + 1), (bx + 1, by + 1)], goat[1]); c.put(bx, by, goat[4])
        P(c, [(bx - 1, by), (bx + 2, by + 1), (bx, by - 1)], goat[0])
    elif v == 'side':   # side slit in the long skirt
        for y in range(63, 69): c.put(34 + hs + (1 if y > 65 else 0), y + b, sand[0])
        bx, by = 37 + hs, 66 + b - (g['f'] % 3 == 0)
        P(c, [(bx, by), (bx + 1, by), (bx, by + 1), (bx + 1, by + 1)], goat[1]); c.put(bx, by, goat[4]); c.put(bx + 2, by + 1, goat[0])
    else:
        for y in range(63, 69): c.put(32 + hs, y + b, sand[2])


def _quilt(q, t, g):
    y = q[1] - g['b']
    a, d = (q[0] + y) % 6, (q[0] - y) % 6
    if a == 0 and d == 0: return linen[3] if t < 2 else linen[2]   # stitch knots
    if a == 0 or d == 0: return indigo[1] if t < 2 else indigo[0]
    return None


def _nightcoat(c, g):
    v, b = g['view'], g['b']
    if v == 'front':   # fennec patch on the right front
        patch = rect(40, 58 + b, 43, 61 + b)
        for q in patch: c.put(q[0], q[1], linen[4])
        P(c, [(40, 58 + b), (43, 58 + b)], ochre[3]); P(c, [(41, 58 + b), (42, 58 + b)], linen[5])   # big fennec ears
        P(c, [(40, 59 + b), (43, 59 + b), (41, 59 + b), (42, 59 + b)], sand[4])
        P(c, [(41, 60 + b)], INK); c.put(42, 60 + b, INK)   # eyes
        P(c, [(40, 61 + b), (43, 61 + b)], sand[3]); c.put(41, 61 + b, sand[4]); c.put(42, 61 + b, goat[1])   # muzzle + nose
        for y in range(59, 64): c.put(33, y + b, linen[4] if y % 2 else indigo[0])   # toggles down the front
    elif v == 'back':   # high collar band
        col = rect(23, 46 + b, 42, 47 + b)
        form(c, col, indigo, frac=0.3)
        for q in col.top(): c.put(q[0], q[1], linen[3] if q[0] % 2 else indigo[4])
    else:
        col = rect(26, 45 + b, 30, 47 + b)
        form(c, col, indigo, frac=0.3)
        patch = rect(36, 58 + b, 39, 61 + b)
        for q in patch: c.put(q[0], q[1], sand[4])
        P(c, [(36, 58 + b), (39, 58 + b)], ochre[2]); P(c, [(37, 60 + b), (38, 60 + b)], INK); c.put(38, 61 + b, goat[1])


def _jerkin(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    # short sleeves: drop the lower half of each sleeve so the tunic sleeve shows
    for s, (hx, hy) in zip(g['sleeves'], g['hands']):
        x0, y0, x1, y1 = s.bbox()
        for q in s:
            if q[1] > y0 + 4 and q not in g['torso']: c.pop(q, None)
        for q in s:
            if q[1] == y0 + 4 and q in c: c.put(q[0], q[1], camel[1])
    # belt
    m = c.mask()
    for q in m:
        if q[1] == 60 + b: c.put(q[0], q[1], strap[3] if q[0] < 40 else strap[2])
        if q[1] == 61 + b: c.put(q[0], q[1], strap[2] if q[0] < 40 else strap[1])
    if v == 'front':
        P(c, [(32, 60 + b), (34, 60 + b), (32, 61 + b), (34, 61 + b)], brass[3]); c.put(33, 60 + b, brass[4]); c.put(33, 61 + b, strap[1])
        for px in (23, 41):   # pouches hanging off the belt
            pch = rect(px, 62 + b, px + 2, 64 + b)
            form(c, pch, camel, frac=0.35)
            for xx in range(px, px + 3): c.put(xx, 62 + b, camel[1])
        # brass compass dangling at the right hip
        P(c, [(45, 62 + b), (45, 63 + b)], strap[2])
        P(c, [(44, 64 + b), (45, 64 + b), (46, 64 + b), (44, 65 + b), (46, 65 + b), (45, 66 + b)], brass[3])
        c.put(45, 65 + b, linen[5]); c.put(44, 64 + b, brass[5]); c.put(45, 66 + b, brass[1])
        for y in (56, 58): P(c, [(32, y + b), (34, y + b)], linen[3])
        c.put(33, 57 + b, linen[3])
    elif v == 'back':
        for px in (25, 37):
            pch = rect(px, 62 + b, px + 2, 64 + b)
            form(c, pch, camel, frac=0.35)
    else:
        pch = rect(35, 62 + b, 37, 64 + b)
        form(c, pch, camel, frac=0.35)
        P(c, [(41, 62 + b), (41, 63 + b)], strap[2])
        P(c, [(40, 64 + b), (41, 64 + b), (42, 64 + b), (40, 65 + b), (42, 65 + b), (41, 66 + b)], brass[3]); c.put(41, 65 + b, linen[5]); c.put(40, 64 + b, brass[5])


COAT = [
    dict(slug='mena-loom-stripe-vest', cat='coat', r=linen, sleeves=False, open=4, pattern=_loom, detail=_vest),
    dict(slug='mena-braided-cord-jacket', cat='coat', r=teal, detail=_braid),
    dict(slug='mena-sand-robe-coat', cat='coat', r=linen, hem=4, detail=_robe),
    dict(slug='mena-quilted-night-coat', cat='coat', r=indigo, puff=1, pattern=_quilt, detail=_nightcoat),
    dict(slug='mena-caravan-leather-jerkin', cat='coat', r=camel, hem=1, detail=_jerkin),
]


# ======================================================================== CLOAK
def _wooltex(c, m, r):
    for q in m:
        if (q[0] * 7 + q[1] * 3) % 11 == 0 and c.get(q) == r[3]: c.put(q[0], q[1], r[2])
        elif (q[0] * 5 + q[1] * 2) % 13 == 0 and c.get(q) == r[3]: c.put(q[0], q[1], r[4])


def _hooded(c, g, m, v):
    b, tl = g['b'], g['tail']
    _wooltex(c, m, linen)
    if v == 'back':   # deep pointed hood lying down the back, long tassel at the tip
        hood = poly([(23, 48 + b), (42, 48 + b), (38, 56 + b), (33 + tl, 62 + b), (27, 56 + b)])
        form(c, hood, sand, frac=0.35)
        inner = poly([(26, 48 + b), (39, 48 + b), (33, 54 + b)])
        for q in inner: c.put(q[0], q[1], camel[0] if q[1] > 50 + b else goat[1])
        for q in hood.inner_edge():
            if q not in inner and q[1] > 48 + b: c.put(q[0], q[1], camel[1])
        tx = 33 + tl
        P(c, [(tx, 63 + b), (tx, 64 + b)], camel[1]); P(c, [(tx - 1, 65 + b), (tx, 65 + b), (tx + 1, 65 + b), (tx - 1, 66 + b), (tx, 66 + b), (tx + 1, 66 + b), (tx, 67 + b)], camel[3])
        c.put(tx - 1, 65 + b, camel[4]); P(c, [(tx + 1, 66 + b), (tx, 67 + b)], camel[1])
    elif v == 'side':
        hood = poly([(24, 49 + b), (19, 50 + b), (16 + tl, 58 + b), (21, 59 + b), (24, 55 + b)])
        form(c, hood, sand, frac=0.3)
        for q in hood.inner_edge(): c.put(q[0], q[1], camel[1])
        P(c, [(23, 51 + b), (22, 52 + b), (23, 52 + b)], camel[0])
        tx = 16 + tl
        P(c, [(tx, 59 + b), (tx, 60 + b)], camel[1]); P(c, [(tx - 1, 61 + b), (tx, 61 + b), (tx - 1, 62 + b), (tx, 62 + b), (tx + 1, 61 + b)], camel[3]); P(c, [(tx, 62 + b), (tx - 1, 63 + b)], camel[1])
    else:
        for q in m:   # camel trim on the front edges that show beside the legs
            if (q[0] + 1, q[1]) not in m or (q[0] - 1, q[1]) not in m:
                if q[1] > 52 + b: c.put(q[0], q[1], camel[3])


def _shawl(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # glossy beaten sheen: light streaks running down the folds
    for q in m:
        if (q[0] - q[1] // 3) % 6 == 0 and c.get(q) == indigo[3]: c.put(q[0], q[1], indigo[4])
        if (q[0] - q[1] // 3) % 6 == 1 and c.get(q) == indigo[3] and q[1] % 5 == 0: c.put(q[0], q[1], indigo[5])
    # turquoise woven edge + fringe below the hem
    for q in m.inner_edge():
        if q[1] > y0 + 2: c.put(q[0], q[1], turq[3] if (q[0] + q[1]) % 2 else turq[2])
    for q in m.bottom():
        if q[0] % 2 == 0: c.put(q[0], q[1] + 1, indigo[1])
    if v == 'back':   # barred hoopoe feather tucked in the fold at the right shoulder
        pts = [(28, 57), (27, 56), (26, 55), (25, 54), (24, 53), (23, 52), (22, 51)]
        for i, (x, y) in enumerate(pts): c.put(x, y + b, (sand[2], ochre[4], INK, sand[5], INK, ochre[3], ochre[5])[i])
        P(c, [(23, 51 + b), (22, 52 + b)], ochre[4])
    elif v == 'side':
        pts = [(24, 58), (23, 57), (22, 56), (21, 55), (20, 54), (19, 53)]
        for i, (x, y) in enumerate(pts): c.put(x + tl // 2, y + b, (sand[2], ochre[4], INK, sand[5], INK, ochre[5])[i])


def _palmcape(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # overlapping tiers: dark underside every 4 rows, leaf streaks
        r = q[1] - y0
        if r > 2 and r % 4 == 3: c.put(q[0], q[1], palm[1] if q[0] < x1 - 3 else palm[0])
        elif r > 2 and r % 4 == 0: c.put(q[0], q[1], palm[4] if q[0] % 2 else palm[3])
        elif q[0] % 2 == 0 and c.get(q) == palm[3]: c.put(q[0], q[1], palm[2])
    if v == 'back':   # fresh green frond tip sprouting at the collar
        P(c, [(21, 49 + b), (20, 48 + b), (19, 47 + b)], mint[3])
        P(c, [(18, 47 + b), (19, 46 + b), (21, 47 + b), (18, 45 + b), (20, 46 + b)], mint[4]); c.put(19, 45 + b, mint[5])
    elif v == 'side':
        P(c, [(25, 46 + b), (24, 45 + b), (23, 44 + b)], mint[3]); P(c, [(22, 44 + b), (23, 43 + b), (25, 44 + b)], mint[4]); c.put(22, 43 + b, mint[5])
    else:
        P(c, [(44, 45 + b), (45, 44 + b), (46, 43 + b)], mint[3]); P(c, [(47, 43 + b), (46, 42 + b), (44, 44 + b)], mint[4]); c.put(47, 42 + b, mint[5])
    for q in M(m).top():   # linen binding at the collar
        if v != 'front': c.put(q[0], q[1], linen[4])


def _scallop(m, tl):
    x0, y0, x1, y1 = m.bbox()
    out = M(m)
    for x in range(x0, x1 + 1):
        ph = (x - x0 + tl) % 4
        if ph == 0: out -= M({(x, y1), (x, y1 - 1)})
        elif ph == 3: out -= M({(x, y1)})
    return out


def _mantle(c, g, m, v):
    b, tl = g['b'], g['tail']
    sc = _scallop(m, tl)
    for q in m - sc: c.pop(q, None)
    m = sc
    x0, y0, x1, y1 = m.bbox()
    # madder deep shade bands (vertical stripes of the dye) + fringe under the scallops
    for q in m:
        if (q[0] - x0) % 4 == 1 and c.get(q) == rose[3] and q[1] > y0 + 2: c.put(q[0], q[1], madder[4])
    for q in m.bottom():
        if (q[0] + tl) % 2 == 0: c.put(q[0], q[1] + 1, madder[1])
        c.put(q[0], q[1], madder[2])
    # brass clasp bits at the shoulders + the dried rosebud tucked on the mantle where it shows
    def bud(x, y):
        P(c, [(x, y), (x + 1, y), (x, y + 1), (x + 1, y + 1)], madder[2]); c.put(x, y, rose[4]); c.put(x + 1, y + 1, madder[1])
        P(c, [(x, y + 2), (x + 1, y + 2)], mint[2]); c.put(x + 2, y + 3, mint[1])
    if v == 'back':
        P(c, [(24, 46 + b), (41, 46 + b)], brass[3])
        bud(19 + tl, 50 + b); c.put(21 + tl, 50 + b, brass[4])
    elif v == 'side':
        P(c, [(29, 46 + b), (30, 47 + b)], brass[3]); c.put(30, 46 + b, brass[4])
        bud(18 + tl, 51 + b)
    else:
        bud(49, 50 + b); c.put(48, 49 + b, brass[4])


def _tent(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # hairy weave texture + cream stripes near the hem
        if (q[0] * 3 + q[1] * 5) % 7 == 0 and c.get(q) in (goat[3], goat[2]): c.put(q[0], q[1], goat[4] if q[0] < x1 - 4 else goat[1])
        below = sum(1 for k in range(1, 8) if (q[0], q[1] + k) in m)
        if below in (3, 6): c.put(q[0], q[1], linen[3] if q[0] < x1 - 4 else linen[2])
        if below == 4: c.put(q[0], q[1], madder[2] if q[0] < x1 - 4 else madder[1])
    if v == 'back':
        for y in range(y0 + 3, y1 - 1): c.put(32 + (tl if y > y0 + 10 else 0), y, goat[0])   # centre seam of the joined panels
        pin = line([(26, 55 + b), (37, 51 + b)], 1)
        for i, q in enumerate(sorted(pin)): c.put(q[0], q[1], wood[4] if i % 3 else wood[3])
        P(c, [(37, 50 + b), (38, 50 + b), (38, 51 + b)], wood[5]); c.put(25, 55 + b, wood[2])
        # camel-wool pompom on the lower left corner
        px, py = x0 - 1 + tl, y1
        for q in ellipse(px + 0.5, py + 0.5, 1.5, 1.5): c.put(q[0], q[1], camel[4] if (q[0] + q[1]) % 2 else camel[3])
        c.put(px, py, camel[5])
    elif v == 'side':
        px, py = x0 + tl, y1
        for q in ellipse(px + 0.5, py + 0.5, 1.5, 1.5): c.put(q[0], q[1], camel[4] if (q[0] + q[1]) % 2 else camel[3])
        c.put(px, py, camel[5])
        P(c, [(26, 47 + b), (27, 46 + b), (28, 45 + b)], wood[4])
    else:
        px, py = x1 - 1, y1
        for q in ellipse(px + 0.5, py + 0.5, 1.5, 1.5): c.put(q[0], q[1], camel[4] if (q[0] + q[1]) % 2 else camel[3])


CLOAK = [
    dict(slug='mena-camel-wool-hooded-cape', cat='cloak', r=linen, lining=sand, len=67, flare=4, border=camel, border_rows=1, fx0=16, fx1=49, front_flare=2, side_back=17, folds=(27, 38), detail=_hooded),
    dict(slug='mena-indigo-shawl', cat='cloak', r=indigo, lining=indigo, len=66, flare=3, x0=19, x1=46, hemstyle='tri', fx0=15, fx1=50, side_back=19, detail=_shawl),
    dict(slug='mena-palm-leaf-sun-cape', cat='cloak', r=palm, lining=palm, len=64, flare=5, x0=19, x1=46, hemstyle='points', fx0=13, fx1=52, side_back=17, folds=(), detail=_palmcape),
    dict(slug='mena-rose-madder-mantle', cat='cloak', r=rose, lining=rose, len=56, flare=4, x0=18, x1=47, fx0=14, fx1=51, side_back=19, folds=(28, 37), detail=_mantle),
    dict(slug='mena-goat-hair-tent-cape', cat='cloak', r=goat, lining=goat, len=66, flare=1, x0=20, x1=45, fx0=16, fx1=49, front_flare=1, side_back=20, folds=(26, 39), detail=_tent),
]

ITEMS = FOOT + PACK + COAT + CLOAK
