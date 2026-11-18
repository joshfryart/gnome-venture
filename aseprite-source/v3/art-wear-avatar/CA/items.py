"""Maizehollow (CA): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/CA/common.lua (R.*),
art-wear-concepts/CA/cloak.lua (ixtle) and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light)
cochi = ["#4a1426", "#741c34", "#9e2440", "#c4304a", "#e05a5e", "#f4908a"]
indigo = ["#1a1e44", "#232d66", "#2f4288", "#3f5ca8", "#5f80c4", "#94b0dc"]
maize = ["#6a4214", "#9a6418", "#c88c22", "#e8b234", "#f6d25a", "#fcec9a"]
agave = ["#1c3a40", "#285650", "#3a7462", "#56927a", "#7cb096", "#b0d4b6"]
straw = ["#5a3e22", "#7e5c32", "#a07c44", "#c09c5a", "#d8bc78", "#ecd8a0"]
clay = ["#4e2018", "#76301e", "#9c4426", "#bc5c32", "#d47a46", "#e8a06a"]
cotton = ["#7a6a5a", "#9c8a74", "#bcab90", "#d6c8aa", "#ebe0c4", "#f8f0dc"]
sage = ["#3a4234", "#56604a", "#76805e", "#97a078", "#b8be94", "#dadcb4"]
marig = ["#7a2c10", "#b04a10", "#dc6e14", "#f49422", "#fcb83a", "#ffdc78"]
turq = ["#14444c", "#1c6670", "#22888c", "#30aaa4", "#5ccaba", "#a0e8d6"]
cacao = ["#2e1a18", "#46261e", "#603426", "#7a4630", "#94603e", "#b07e54"]
copper = ["#4a2018", "#743222", "#a04a2a", "#c46a38", "#e09050", "#f4bc7c"]
jade = ["#163a26", "#1e5630", "#2a743a", "#3c9446", "#5cb456", "#9cd67a"]
bougain = ["#4a1240", "#701a5a", "#982474", "#bc3a8e", "#d862aa", "#f09ac8"]
ixtle = ["#4a4a38", "#686a4e", "#8a8c66", "#aaab80", "#c8c89c", "#e2e0bc"]
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
steel = ["#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2"]


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def shade_of(c, q, r):
    """index of the colour at q in ramp r (or 3)."""
    col = c.get(q)
    return r.index(col) if col in r else 3


def restripe(c, m, r_from, r_to, rows):
    """recolour pixels of m whose row is in rows from ramp r_from to r_to, keeping the lit/shade index."""
    for q in m:
        if q[1] in rows:
            i = shade_of(c, q, r_from)
            c.put(q[0], q[1], r_to[i])


# ======================================================================== FOOTWEAR
def _huarache(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # woven strap lattice over the upper, a light sole edge and a dark tread
    for q in foot:
        if q[1] >= y1 - 1: continue
        if (q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0:
            c.put(q[0], q[1], strap[2] if q[0] < x1 - 2 else strap[1])
    for q in foot.bottom():
        c.put(q[0], q[1] - 1, leather[5] if q[0] < x1 - 2 else leather[4])
        c.put(q[0], q[1], sole[1])
    if v == 'back':   # heel strap + brass buckle
        for x in range(x0 + 1, x1): c.put(x, y0 + 1, strap[2])
        c.put(x1 - 1 if ft['side'] == 'L' else x0 + 1, y0 + 1, maize[4])
    elif v == 'side':
        P(c, [(x0, y0 + 1), (x0 + 1, y0)], strap[2]); c.put(x0, y0 + 2, maize[4])
        if not g['far']: P(c, [(x1 - 2, y0 + 1)], turq[4]); c.put(x1 - 3, y0 + 1, turq[2])   # bead on the toe strap
    else:
        if k == 0: c.put(cx, y0 + 1, turq[4]); c.put(cx + 1, y0 + 1, turq[2]); c.put(cx, y0, turq[5])
        side_x = x1 if ft['side'] == 'R' else x0
        c.put(side_x, cy - 1, maize[4])   # buckle of the heel strap


def _tooled(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # boot mouth: dark top row
    for x in range(x0, x1 + 1): c.put(x, top, leather[1])
    for x in range(x0 + 1, x1): c.put(x, top + 1, leather[4] if x < x1 - 2 else leather[3])
    # stamped vine: a wavy cacao line with leaf dots down the shaft and across the toe
    mx = (x0 + x1) // 2 if v != 'side' else x0 + 2
    for i, y in enumerate(range(top + 2, cy)):
        dx = (0, 1, 0, -1)[i % 4]
        c.put(mx + dx, y, cacao[3])
        if i % 4 == 1: c.put(mx + dx + 1, y - 1, cacao[4])
        if i % 4 == 3: c.put(mx + dx - 1, y - 1, cacao[4])
    # stacked heel
    if v == 'side':
        for yy in (cy + 1, cy + 2): P(c, [(x0, yy), (x0 + 1, yy)], wood[3] if yy == cy + 1 else wood[1])
        c.put(x0 - 1, cy + 1, wood[2])
    elif v == 'back':
        for x in range(x0 + 2, x1 - 1): c.put(x, cy + 1, wood[3]); c.put(x, cy + 2, wood[1])
    # gecko peeking out of one boot top
    gk = (k == 0) if v != 'side' else (k == 1)
    if gk:
        if v == 'side':
            P(c, [(x1 - 1, top - 2), (x1 + 1, top - 2)], jade[4]); c.put(x1, top - 2, jade[0])
            P(c, [(x1 - 2, top - 1), (x1 + 2, top - 1)], jade[3]); P(c, [(x1 - 1, top - 1), (x1, top - 1), (x1 + 1, top - 1)], jade[4])
        elif v == 'front':
            P(c, [(x0, top - 2), (x0 + 1, top - 2)], jade[5]); c.put(x0 + 1, top - 2, jade[0]); c.put(x0, top - 3, jade[4])
            P(c, [(x0 - 1, top - 1), (x0 + 2, top - 1)], jade[3]); P(c, [(x0, top - 1), (x0 + 1, top - 1)], jade[4])
        else:   # tail curling over the rim
            P(c, [(x1 - 1, top - 1), (x1, top - 1), (x1 + 1, top), (x1 + 1, top + 1)], jade[3])


def _wraps(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    shaft = g['shaft']
    # spiral wrap: diagonal dark seams
    for q in shaft:
        if q[1] <= top or q[1] > cy - 2: continue
        if (q[0] - q[1]) % 3 == 0:
            i = shade_of(c, q, indigo)
            c.put(q[0], q[1], indigo[max(0, i - 2)])
    # folded top band
    for x in range(x0, x1 + 1): c.put(x, top, indigo[5] if x < x1 - 2 else indigo[4])
    # red cord spiralling down: two turns, one direction
    w = x1 - x0
    for x in range(x0, x1 + 1):
        for y0c in (top + 1, top + 5):
            y = y0c + (x - x0) * 3 // max(1, w)
            if y < cy - 1: c.put(x, y, cochi[4] if x < x1 - 2 else cochi[3])
    # cord ends dangling at the outer side
    ox = x0 - 1 if (ft['side'] in ('L', 'far')) else x1 + 1
    if v == 'side': ox = x1 + 1
    P(c, [(ox, top + 1), (ox, top + 2)], cochi[3]); c.put(ox, top + 3, cochi[4])
    # leaf-cutter ant marching up the cord with a leaf scrap
    if (k == 1) and v != 'back':
        ax = x0 + w // 2
        ay = top + 5 + (ax - x0) * 3 // max(1, w)
        P(c, [(ax, ay), (ax + 1, ay)], cacao[0]); c.put(ax, ay - 1, jade[4]); c.put(ax + 1, ay - 2, jade[5]); c.put(ax, ay - 2, jade[3])


def _ixtle(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # braided fibre: herringbone ticks
    for q in foot:
        if q[1] >= y1: continue
        i = shade_of(c, q, straw)
        if (q[0] + 2 * q[1]) % 4 == 0: c.put(q[0], q[1], straw[min(5, i + 1)])
        elif (q[0] - 2 * q[1]) % 4 == 2: c.put(q[0], q[1], straw[max(1, i - 1)])
    # rope sole: twisted
    for q in foot.bottom():
        c.put(q[0], q[1], straw[1] if q[0] % 2 else straw[0])
    # opening of the slip-on (front/back: dark top lip)
    if v == 'back':
        for x in range(x0 + 2, x1 - 1): c.put(x, y0 + 1, straw[1])
    # cochineal pompom on the toe
    if v == 'front':
        px, py = cx - (1 if ft['side'] == 'L' else 0), y0 + 1
        P(c, [(px, py)], cochi[5]); P(c, [(px + 1, py)], cochi[3]); P(c, [(px, py + 1)], cochi[3]); P(c, [(px + 1, py + 1)], cochi[2])
    elif v == 'side':
        px, py = x1, y0 + 1
        P(c, [(px, py)], cochi[4]); P(c, [(px + 1, py)], cochi[3]); P(c, [(px, py + 1)], cochi[2]); P(c, [(px + 1, py + 1)], cochi[1])
        if g['far']:
            for q in [(px, py), (px + 1, py), (px, py + 1), (px + 1, py + 1)]: c.put(q[0], q[1], cochi[2])


def _platform(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    far = g['far']
    # lower half of the shoe = carved wood platform, 1 px wider and 1 row deeper
    plat = M(q for q in foot if q[1] >= cy) | rect(x0, cy, x1, y1 + 1)
    if v == 'side': plat |= rect(x0 - 1, cy + 1, x1, y1 + 1)
    wr = [wood[0]] + wood[:5] if far else wood
    for q in plat:
        col = wr[3] if q[0] < x1 - 2 else wr[2]
        if q[1] == cy: col = wr[4] if q[0] < x1 - 2 else wr[3]
        if q[1] == y1 + 1: col = wr[1]
        c.put(q[0], q[1], col)
    for x in range(x0 + 1, x1, 2): c.put(x, cy + 1, clay[4] if not far else clay[3])   # carved/painted dot row
    # woven palm band over the top: 1 px checker
    for q in foot:
        if q[1] < cy:
            i = shade_of(c, q, straw)
            c.put(q[0], q[1], straw[min(5, i + 1)] if (q[0] + q[1]) % 2 else straw[max(1, i - 1)])
    # a sprout growing from a crack in one heel
    if v == 'side' and k == 1:
        P(c, [(x0 - 1, cy), (x0 - 2, cy - 1)], jade[3]); P(c, [(x0 - 3, cy - 2), (x0 - 1, cy - 2)], jade[5]); c.put(x0, cy + 1, wood[0])
    elif v == 'front' and k == 0:
        P(c, [(x0 - 1, cy), (x0 - 2, cy - 1)], jade[3]); P(c, [(x0 - 3, cy - 2), (x0 - 1, cy - 2)], jade[5])
    elif v == 'back' and k == 0:
        P(c, [(cx, cy), (cx, cy - 1)], jade[3]); P(c, [(cx - 1, cy - 2), (cx + 1, cy - 2)], jade[5]); c.put(cx, cy + 1, wood[0])


FOOT = [
    dict(slug='ca-lattice-huaraches', cat='footwear', shell=leather, upper=leather, sole=sole[1], rim=None, toe=1, detail=_huarache),
    dict(slug='ca-tooled-ankle-boots', cat='footwear', shell=leather, upper=leather, sole=sole[1], rim=62, half=4, toe=1, detail=_tooled),
    dict(slug='ca-indigo-leg-wraps', cat='footwear', shell=strap, upper=indigo, sole=sole[1], rim=60, half=4, detail=_wraps),
    dict(slug='ca-ixtle-slippers', cat='footwear', shell=straw, upper=straw, sole=straw[0], rim=None, puff=1, toe=1, detail=_ixtle),
    dict(slug='ca-market-platform-clogs', cat='footwear', shell=straw, upper=straw, sole=wood[1], rim=None, toe=1, detail=_platform),
]


# ======================================================================== BACKPACK
def _lash(c, x, y):
    c.put(x, y, straw[4]); c.put(x + 1, y + 1, straw[2]); c.put(x + 1, y, straw[3]); c.put(x, y + 1, straw[1])


def frame_back(c, x, y, g):
    # tumpline headband arching up towards the forehead (the head is drawn over it)
    tump = line([(x - 7, y - 3), (x - 6, y - 6), (x - 3, y - 8), (x + 2, y - 8), (x + 5, y - 6), (x + 6, y - 3)], 2)
    form(c, tump, cochi, frac=0.3)
    for rx in (x - 8, x + 6):
        form(c, rect(rx, y - 3, rx + 1, y + 17), wood, frac=0.5)
    for ry in (y - 1, y + 13):
        form(c, rect(x - 7, ry, x + 6, ry + 1), wood, frac=0.25)
    # clay jar on the lower shelf
    body = ellipse(x - 0.5, y + 8, 4.5, 3.5)
    form(c, body, clay, frac=0.35, hi=[(x - 3, y + 6), (x - 3, y + 7)])
    form(c, rect(x - 2, y + 2, x + 1, y + 4), clay, frac=0.4)
    for xx in range(x - 3, x + 3): c.put(xx, y + 2, clay[4] if xx < x + 1 else clay[2])
    for xx in range(x - 4, x + 4, 2): c.put(xx, y + 9, maize[3])
    for rx in (x - 8, x + 6):
        for ry in (y - 1, y + 13): _lash(c, rx, ry)
    # parrot feather tucked into the top-left lashing
    P(c, [(x - 9, y - 2), (x - 10, y - 3)], cochi[3]); P(c, [(x - 11, y - 4), (x - 10, y - 4)], cochi[4])
    P(c, [(x - 12, y - 5), (x - 11, y - 5)], jade[4]); c.put(x - 13, y - 6, jade[3]); c.put(x - 12, y - 6, jade[5])


def frame_side(c, x, y, g):
    tump = line([(x, y - 3), (x + 2, y - 6), (x + 5, y - 8)], 2)
    form(c, tump, cochi, frac=0.3)
    form(c, rect(x - 10, y - 3, x - 9, y + 17), wood, frac=0.5)
    form(c, rect(x - 1, y - 3, x, y + 17), wood, frac=0.5)
    for ry in (y - 1, y + 13): form(c, rect(x - 9, ry, x - 1, ry + 1), wood, frac=0.25)
    body = ellipse(x - 5, y + 8, 3.5, 3.5)
    form(c, body, clay, frac=0.35, hi=[(x - 7, y + 6)])
    form(c, rect(x - 6, y + 2, x - 4, y + 4), clay, frac=0.4)
    for xx in range(x - 8, x - 1, 2): c.put(xx, y + 9, maize[3])
    for rx in (x - 10, x - 1):
        for ry in (y - 1, y + 13): _lash(c, rx, ry)
    P(c, [(x - 11, y - 2), (x - 12, y - 3)], cochi[3]); P(c, [(x - 13, y - 4), (x - 12, y - 4)], cochi[4])
    P(c, [(x - 14, y - 5), (x - 13, y - 5)], jade[4]); c.put(x - 15, y - 6, jade[3]); c.put(x - 14, y - 6, jade[5])


def _net(c, m, base):
    """maize cobs behind an open-knot fibre net: lit sack, cob bumps, a coarse diagonal net with knots."""
    x0, y0, x1, y1 = m.bbox()
    form(c, m, maize, frac=0.35, hi=[(x0 + 3, y0 + 3), (x0 + 4, y0 + 3)])
    for q in m:   # cob bumps: lighter kernels in the middle of each net cell
        if (q[0] + q[1]) % 4 == 2 and (q[0] - q[1]) % 4 == 2 and (q[0], q[1] + 1) in m:
            c.put(q[0], q[1], maize[5] if q[0] < x0 + (x1 - x0) * 0.6 else maize[4])
    for q in m:
        if (q[0] * 5 + q[1] * 3) % 23 == 0: c.put(q[0], q[1], jade[3]); c.put(q[0] + 1, q[1], jade[2])
    for q in m:
        if (q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0:
            c.put(q[0], q[1], straw[2] if q[0] < x0 + (x1 - x0) * 0.6 else straw[1])
            if (q[0] + q[1]) % 4 == 0 and (q[0] - q[1]) % 4 == 0: c.put(q[0], q[1], straw[0])   # knots


def netbag_back(c, x, y, g):
    # cob poking out of the top with a silk tuft
    cob = line([(x - 7, y + 4), (x - 12, y - 1)], 3)
    for q in cob: c.put(q[0], q[1], maize[4] if (q[0] + q[1]) % 2 else maize[3])
    for q in cob:
        if (q[0] + 1, q[1]) not in cob: c.put(q[0], q[1], maize[2])
    P(c, [(x - 14, y - 3), (x - 13, y - 3), (x - 14, y - 2)], cotton[5]); c.put(x - 15, y - 4, maize[5])
    P(c, [(x - 6, y + 2), (x - 7, y + 1), (x - 10, y + 4), (x - 11, y + 3)], jade[4]); c.put(x - 6, y + 1, jade[3])
    sack = ellipse(x - 0.5, y + 9, 9, 8) | poly([(x - 6, y + 1), (x + 5, y + 1), (x + 8, y + 5), (x - 9, y + 5)])
    _net(c, sack, maize)
    # drawstring gather + carrying loop
    for xx in range(x - 5, x + 5): c.put(xx, y + 1, straw[2] if xx % 2 else straw[4])
    loop = line([(x - 5, y + 1), (x - 6, y - 2), (x - 4, y - 4), (x - 2, y - 2), (x - 2, y + 1)], 1)
    for q in loop: c.put(q[0], q[1], straw[3])


def netbag_side(c, x, y, g):
    cob = rect(x - 5, y - 5, x - 3, y + 2)
    for q in cob: c.put(q[0], q[1], maize[4] if (q[0] + q[1]) % 2 else maize[3])
    P(c, [(x - 4, y - 6), (x - 5, y - 7), (x - 3, y - 7)], cotton[5]); c.put(x - 4, y - 7, maize[5])
    P(c, [(x - 6, y), (x - 2, y + 1)], jade[4])
    sack = ellipse(x - 5, y + 9, 5.5, 8) | rect(x - 9, y + 1, x - 1, y + 5)
    _net(c, sack, maize)
    for xx in range(x - 8, x): c.put(xx, y + 1, straw[2] if xx % 2 else straw[4])


def _plait(c, m, r):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        lit = (q[0] // 2 + q[1]) % 2
        i = 4 if lit else 3
        if q[0] > x1 - (x1 - x0 + 1) * 0.3: i -= 1
        if q[1] == y1: i = 1
        if q[0] == x0: i = min(5, i + 1)
        c.put(q[0], q[1], r[i])


def basket_back(c, x, y, g):
    for sx, dx in ((x - 8, -1), (x + 7, 1)):   # shoulder cords looping out at the sides
        cord = line([(sx, y + 4), (sx + 2 * dx, y + 8), (sx + 2 * dx, y + 12), (sx, y + 14)], 1)
        for q in cord: c.put(q[0], q[1], strap[3] if dx < 0 else strap[2])
    body = rect(x - 7, y + 3, x + 6, y + 15)
    _plait(c, body, straw)
    for xx in range(x - 7, x + 7):   # marigold band with red dashes
        c.put(xx, y + 9, marig[4] if xx < x + 3 else marig[3])
        c.put(xx, y + 10, (cochi[3] if xx % 3 == 0 else marig[3]) if xx < x + 3 else (cochi[2] if xx % 3 == 0 else marig[2]))
    lid = poly([(x - 9, y + 3), (x + 9, y + 3), (x + 2, y - 3), (x - 2, y - 3)])
    form(c, lid, straw, frac=0.35)
    for q in lid:
        if (q[0] - q[1]) % 3 == 0 and q[1] < y + 2: c.put(q[0], q[1], straw[2])
    for xx in range(x - 9, x + 9): c.put(xx, y + 3, straw[1])
    form(c, rect(x - 1, y - 5, x, y - 4), strap, frac=0.5)
    # hummingbird perched on the lid rim
    P(c, [(x - 7, y + 1), (x - 8, y + 1)], jade[4]); c.put(x - 9, y + 2, jade[2]); c.put(x - 10, y + 2, jade[1])
    c.put(x - 6, y, jade[5]); c.put(x - 7, y, jade[3]); c.put(x - 6, y + 1, cochi[4]); c.put(x - 5, y, cacao[0])


def basket_side(c, x, y, g):
    body = rect(x - 8, y + 3, x - 1, y + 15)
    _plait(c, body, straw)
    for xx in range(x - 8, x):
        c.put(xx, y + 9, marig[4]); c.put(xx, y + 10, cochi[3] if xx % 3 == 0 else marig[3])
    lid = poly([(x - 10, y + 3), (x + 1, y + 3), (x - 3, y - 3), (x - 6, y - 3)])
    form(c, lid, straw, frac=0.35)
    for xx in range(x - 10, x + 1): c.put(xx, y + 3, straw[1])
    form(c, rect(x - 5, y - 5, x - 4, y - 4), strap, frac=0.5)
    for q in line([(x, y + 4), (x + 1, y + 2)], 1): c.put(q[0], q[1], strap[2])
    # hummingbird on the lid, facing back
    P(c, [(x - 9, y + 1), (x - 8, y + 1)], jade[4]); c.put(x - 7, y + 2, jade[2])
    c.put(x - 10, y, jade[5]); c.put(x - 9, y, jade[3]); c.put(x - 10, y + 1, cochi[4]); c.put(x - 11, y, cacao[0])


def _stripes(c, m, y):
    """backstrap stripes on a cochineal ground: by row."""
    x0, y0, x1, y1 = m.bbox()
    tmp = C(); form(tmp, m, cochi, frac=0.35)
    for q, col in tmp.items():
        i = cochi.index(col)
        k = (q[1] - y) % 7
        if k == 0: col = indigo[min(5, i)]
        elif k == 1: col = cotton[min(5, i + 1)] if (q[0] % 3) else marig[min(5, i)]
        elif k == 2: col = indigo[min(5, i)]
        c.put(q[0], q[1], col)


def bundle_back(c, x, y, g):
    body = ellipse(x - 0.5, y + 8, 9.5, 6) | rect(x - 9, y + 4, x + 8, y + 11)
    for side in (-1, 1):   # knotted corners sticking up
        ex = x - 0.5 + side * 4
        ear = poly([(ex - 2, y + 5), (ex + 2, y + 5), (ex + side * 5, y - 2), (ex + side * 3, y - 3)])
        form(c, ear, cochi, frac=0.4)
        for q in ear:
            if (q[0] - side * q[1]) % 4 == 0: c.put(q[0], q[1], indigo[3])
    _stripes(c, body, y + 5)
    for xx in range(x - 8, x + 8):   # little fringe on the bottom edge
        if xx % 2 == 0: c.put(xx, y + 15, cotton[3])
    knot = ellipse(x - 0.5, y + 4, 2.5, 2)
    form(c, knot, cochi, frac=0.35, hi=[(x - 2, y + 3)])
    # marigold tucked in the knot
    fx, fy = x + 1, y + 2
    P(c, [(fx, fy - 1), (fx - 1, fy), (fx + 1, fy), (fx, fy + 1)], marig[4]); c.put(fx - 1, fy - 1, marig[5]); c.put(fx + 1, fy + 1, marig[2])
    c.put(fx, fy, marig[1]); c.put(fx + 1, fy - 1, marig[3])


def bundle_side(c, x, y, g):
    body = ellipse(x - 5, y + 8, 5, 6) | rect(x - 9, y + 4, x - 1, y + 11)
    ear = poly([(x - 7, y + 5), (x - 3, y + 5), (x - 10, y - 2), (x - 8, y - 3)])
    form(c, ear, cochi, frac=0.4)
    for q in ear:
        if (q[0] + q[1]) % 4 == 0: c.put(q[0], q[1], indigo[3])
    _stripes(c, body, y + 5)
    knot = ellipse(x - 4, y + 4, 2, 2)
    form(c, knot, cochi, frac=0.35)
    fx, fy = x - 3, y + 2
    P(c, [(fx, fy - 1), (fx - 1, fy), (fx + 1, fy), (fx, fy + 1)], marig[4]); c.put(fx - 1, fy - 1, marig[5]); c.put(fx, fy, marig[1])


def _gourd(c, gx, y, flip=False):
    top = ellipse(gx, y + 3, 1.5, 1.5)
    bot = ellipse(gx, y + 9, 3, 4)
    form(c, top | bot, maize, frac=0.4, hi=[(gx - 2, y + 7), (gx - 1, y + 2)])
    for xx in range(gx - 3, gx + 4): c.put(xx, y + 6, strap[1])   # strap round the waist of the gourd
    P(c, [(gx, y), (gx, y + 1)], cacao[3]); c.put(gx, y, cacao[4])   # stopper


def water_back(c, x, y, g):
    pack = rect(x - 6, y + 1, x + 5, y + 15)
    form(c, pack, leather, frac=0.3)
    flap = poly([(x - 6, y + 1), (x + 6, y + 1), (x + 6, y + 6), (x, y + 9), (x - 6, y + 6)])
    form(c, flap, leather, frac=0.3)
    for q in flap.bottom(): c.put(q[0], q[1], leather[1])
    # stamped copper diamond on the flap
    P(c, [(x - 1, y + 3), (x - 2, y + 4), (x, y + 4), (x - 1, y + 5)], copper[3]); c.put(x - 1, y + 4, copper[5])
    for xx in (x - 4, x + 3): c.put(xx, y + 2, copper[4])
    _gourd(c, x - 9, y + 2); _gourd(c, x + 8, y + 2)
    # little clay cup hanging from a hook under the pack
    P(c, [(x - 1, y + 16), (x - 1, y + 17)], copper[4])
    form(c, rect(x - 3, y + 18, x + 1, y + 20), clay, frac=0.35)
    for xx in range(x - 3, x + 2): c.put(xx, y + 18, clay[1] if xx in (x - 2, x - 1, x) else clay[4])


def water_side(c, x, y, g):
    pack = rect(x - 6, y + 1, x - 1, y + 15)
    form(c, pack, leather, frac=0.3)
    for yy in range(y + 1, y + 7): c.put(x - 6, yy, leather[1])
    _gourd(c, x - 6, y + 3)
    P(c, [(x - 2, y + 16), (x - 2, y + 17)], copper[4])
    form(c, rect(x - 4, y + 18, x, y + 20), clay, frac=0.35)
    for xx in range(x - 3, x): c.put(xx, y + 18, clay[1])


PACK = [
    dict(slug='ca-carrier-frame', cat='backpack', back=frame_back, side=frame_side),
    dict(slug='ca-maize-net-bag', cat='backpack', back=netbag_back, side=netbag_side),
    dict(slug='ca-palm-basket-pack', cat='backpack', back=basket_back, side=basket_side, y0=49),
    dict(slug='ca-loom-cloth-bundle', cat='backpack', back=bundle_back, side=bundle_side, y0=49),
    dict(slug='ca-dry-spell-water-pack', cat='backpack', back=water_back, side=water_side),
]


# ======================================================================== COAT
def _cuffs(c, g, r, rows=2, band=None):
    """recolour the bottom `rows` rows of each sleeve with ramp r (keeping tone)."""
    for s in g['sleeves']:
        s2 = M(q for q in s if q not in g['torso'] or g['view'] == 'side')
        if not s2: continue
        y1 = s2.bbox()[3]
        for q in s2:
            if y1 - rows < q[1] <= y1 and q in c:
                i = 4 if q[0] < s2.bbox()[0] + 2 else 3
                if q[1] == y1: i -= 1
                c.put(q[0], q[1], r[i])


def _hem_band(c, g, r, rows=1):
    m = c.mask()
    for q in m:
        if all((q[0], q[1] + k) not in m for k in range(rows, rows + 1)) and (q[0], q[1] + rows) not in m:
            pass
    bot = M(q for q in m if (q[0], q[1] + 1) not in m and q[1] > 58 + g['b'])
    for q in bot:
        for k in range(rows):
            if (q[0], q[1] - k) in m: c.put(q[0], q[1] - k, r[3] if k else r[2])


def _flower(c, x, y, ramp, centre):
    P(c, [(x, y - 1), (x - 1, y), (x + 1, y), (x, y + 1)], ramp[4]); c.put(x, y, centre)


def _smock_pat(q, t, g):
    return None


def _smock(c, g):
    v, b = g['view'], g['b']
    _cuffs(c, g, cochi, 2)
    # red hem border with marigold dots
    m = c.mask()
    for q in m:
        if (q[0], q[1] + 1) not in m and q[1] > 60 + b:
            c.put(q[0], q[1], cochi[2]); c.put(q[0], q[1] - 1, marig[4] if q[0] % 3 == 0 else cochi[3])
    if v == 'back':   # square embroidered yoke
        yk = rect(26, 49 + b, 39, 54 + b)
        for q in yk.inner_edge(): c.put(q[0], q[1], cochi[3] if q[0] < 37 else cochi[2])
        for i, fx in enumerate((28, 32, 36)):
            _flower(c, fx, 51 + b + (i % 2), (cochi, marig, jade)[i] if i != 2 else bougain, maize[5] if i != 1 else cochi[3])
        P(c, [(30, 53 + b), (34, 52 + b)], jade[3])
        # needle stuck in the yoke trailing red thread
        P(c, [(38, 50 + b), (39, 49 + b), (40, 48 + b)], steel[4]); c.put(41, 47 + b, steel[2])
        P(c, [(38, 51 + b), (39, 52 + b), (39, 53 + b), (40, 54 + b), (40, 55 + b)], cochi[3])
    elif v == 'front':   # yoke corners beside the beard + needle on the right shoulder
        for fx, fy in ((22, 49), (43, 49)):
            _flower(c, fx, fy + b, cochi, maize[5])
        P(c, [(42, 47 + b), (43, 46 + b)], cochi[3])
        P(c, [(44, 51 + b), (45, 50 + b), (46, 49 + b)], steel[4]); c.put(47, 48 + b, steel[2])
        P(c, [(44, 52 + b), (45, 53 + b), (45, 54 + b)], cochi[3])
    else:
        _flower(c, 30, 50 + b, cochi, maize[5]); _flower(c, 35, 51 + b, marig, cochi[3])
        P(c, [(33, 49 + b), (34, 48 + b)], steel[4]); P(c, [(33, 50 + b), (32, 51 + b), (32, 52 + b)], cochi[3])


def _pleats(q, t, g):
    if q[0] % 3 == 0 and q[1] > 47 + g['b']:
        return sage[max(1, 3 - t)] if t < 3 else sage[0]
    return None


def _pocket(c, x0, y0, x1, y1):
    for x in range(x0, x1 + 1): c.put(x, y0, sage[1]); c.put(x, y1, sage[1])
    for y in range(y0, y1 + 1): c.put(x0, y, sage[1]); c.put(x1, y, sage[1])
    for x in range(x0 + 1, x1): c.put(x, y0 + 1, sage[4])


def _pod(c, x, y):
    e = ellipse(x, y, 1, 2)
    form(c, e, cacao, frac=0.4, hi=[(x - 1, y - 1)])
    c.put(x, y, cacao[2]); c.put(x, y - 3, jade[2])


def _shirtjacket(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        _pocket(c, 24, 60 + b, 28, 63 + b); _pocket(c, 37, 60 + b, 41, 63 + b)
        _pod(c, 39, 59 + b)
        for y in (61, 63): c.put(33, y + b, cacao[4])   # buttons
        P(c, [(22, 47 + b), (23, 48 + b)], sage[5]); P(c, [(43, 47 + b), (42, 48 + b)], sage[5])   # collar points
    elif v == 'side':
        _pocket(c, 34, 59 + b, 38, 62 + b)
        _pod(c, 36, 58 + b)
        P(c, [(36, 47 + b), (37, 48 + b), (35, 48 + b)], sage[5])
    else:
        for x in range(22, 44): c.put(x, 50 + b, sage[1]) if (x, 50 + b) in c else None   # yoke seam
        for x in (24, 29, 36, 41): c.put(x, 64 + b, cacao[4]) if (x, 64 + b) in c else None


def _vest_pat(q, t, g):
    # tooled vine stamps
    if (q[0] * 2 + q[1] * 3) % 9 == 0 and t < 3 and 49 + g['b'] < q[1] < 63 + g['b']: return leather[max(1, 2 - (t >= 2))]
    return None


def _vest(c, g):
    v, b = g['view'], g['b']
    m = c.mask()
    bot_y = max(q[1] for q in m)
    # fringe: the last 2 rows become strands
    for q in list(m):
        if q[1] >= bot_y - 1:
            if q[0] % 2: c.pop(q, None)
            else: c.put(q[0], q[1], leather[2] if q[1] == bot_y else leather[3])
    # copper studs along the row above the fringe
    for q in m:
        if q[1] == bot_y - 2 and q[0] % 3 == 0: c.put(q[0], q[1], copper[5])
        if q[1] == bot_y - 3: c.put(q[0], q[1], leather[1])
    if v != 'back':   # studs on the lapels / armhole
        for y in range(50, 60, 3):
            for x in ((21, 44) if v == 'front' else (30,)):
                if (x, y + b) in c: c.put(x, y + b, copper[5])
    # small copper bell on a fringe strand
    if v == 'front':
        bx = 40
        c.put(bx, bot_y + 1, copper[2]); P(c, [(bx - 1, bot_y + 2), (bx, bot_y + 2)], copper[4]); P(c, [(bx - 1, bot_y + 3), (bx, bot_y + 3), (bx + 1, bot_y + 3)], copper[3])
        c.put(bx + 1, bot_y + 2, copper[2])
    elif v == 'side':
        bx = 38
        c.put(bx, bot_y + 1, copper[2]); P(c, [(bx - 1, bot_y + 2), (bx, bot_y + 2)], copper[4]); P(c, [(bx - 1, bot_y + 3), (bx, bot_y + 3), (bx + 1, bot_y + 3)], copper[3])
    else:
        bx = 25
        c.put(bx, bot_y + 1, copper[2]); P(c, [(bx - 1, bot_y + 2), (bx, bot_y + 2)], copper[4]); P(c, [(bx - 1, bot_y + 3), (bx, bot_y + 3), (bx + 1, bot_y + 3)], copper[3])


def _quilt(q, t, g):
    y = q[1] - g['b']
    if (q[0] + y) % 4 == 0 or (q[0] - y) % 4 == 0:
        return cochi[max(1, 3 - t - 1)] if t < 3 else cochi[0]
    return None


def _boll(c, x, y):
    for q in ellipse(x, y, 1.5, 1.2): c.put(q[0], q[1], cotton[5] if (q[0] + q[1]) % 2 else cotton[4])
    c.put(x - 1, y + 1, cotton[3]); c.put(x + 1, y + 1, cacao[3])


def _quiltcoat(c, g):
    v, b = g['view'], g['b']
    _cuffs(c, g, cotton, 2)
    m = c.mask()
    for q in m:   # cream hem band
        if (q[0], q[1] + 1) not in m and q[1] > 60 + b:
            c.put(q[0], q[1], cotton[2]); c.put(q[0], q[1] - 1, cotton[4] if q[0] < 40 else cotton[3])
    if v == 'front':
        _boll(c, 22, 47 + b)
        for y in (61,): c.put(33, y + b, cotton[4])
    elif v == 'side':
        _boll(c, 27, 47 + b)
    else:
        for x in range(23, 43):
            if (x, 48 + b) in c: c.put(x, 48 + b, cotton[4] if x < 38 else cotton[3])
        _boll(c, 40, 47 + b)


def _twill(q, t, g):
    y = q[1] - g['b']
    if 59 <= y <= 61:   # striped woven sash
        return (cochi[3], cotton[4], cochi[3])[y - 59] if q[0] % 4 else maize[4]
    if (q[0] + q[1]) % 4 == 0 and t in (1, 2): return indigo[2] if t == 1 else indigo[1]
    return None


def _monarch(c, x, y, flip=False):
    s = -1 if flip else 1
    P(c, [(x - s, y - 1), (x - 2 * s, y - 1), (x + s, y - 1), (x + 2 * s, y - 1)], marig[4])
    P(c, [(x - s, y), (x + s, y)], marig[3]); P(c, [(x - 2 * s, y), (x + 2 * s, y)], cacao[0])
    c.put(x, y - 1, cacao[0]); c.put(x, y, cacao[0])
    P(c, [(x - s, y + 1), (x + s, y + 1)], marig[2])


def _fieldjacket(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        for y in (62, 64): P(c, [(32, y + b), (34, y + b)], maize[4]); c.put(33, y + b, maize[2])   # toggles
        for y in range(62 + b, 67 + b): c.put(42 + hs, y, cochi[3] if y % 2 else cochi[4])   # sash end
        P(c, [(41 + hs, 67 + b), (43 + hs, 67 + b)], cochi[2])
        _monarch(c, 45, 46 + b)
    elif v == 'side':
        for y in range(62 + b, 67 + b): c.put(26 + hs, y, cochi[3] if y % 2 else cochi[4])
        P(c, [(25 + hs, 67 + b), (27 + hs, 67 + b)], cochi[2])
        _monarch(c, 31, 46 + b)
    else:
        for y in range(62 + b, 67 + b): c.put(23 + hs, y, cochi[3] if y % 2 else cochi[4])
        P(c, [(22 + hs, 67 + b), (24 + hs, 67 + b)], cochi[2])
        _monarch(c, 20, 47 + b, True)


COAT = [
    dict(slug='ca-bloom-smock', cat='coat', r=cotton, hem=1, puff=1, detail=_smock),
    dict(slug='ca-pleated-shirt-jacket', cat='coat', r=sage, hem=1, pattern=_pleats, detail=_shirtjacket),
    dict(slug='ca-fringed-leather-vest', cat='coat', r=leather, sleeves=False, hem=2, open=2, pattern=_vest_pat, detail=_vest),
    dict(slug='ca-quilted-cotton-coat', cat='coat', r=cochi, puff=1, hem=1, pattern=_quilt, detail=_quiltcoat),
    dict(slug='ca-indigo-field-jacket', cat='coat', r=indigo, hem=1, pattern=_twill, detail=_fieldjacket),
]


# ======================================================================== CLOAK
def _below(m, q, n=8):
    k = 0
    while k < n and (q[0], q[1] + k + 1) in m: k += 1
    return k


def _band(c, m, ks, r, view):
    """recolour pixels whose distance to the hem is in ks with ramp r (lit left, shade right)."""
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if _below(m, q) in ks:
            i = 3 if q[0] < x1 - (x1 - x0 + 1) * 0.35 else 2
            if q[0] == x0 or (q[0] - 1, q[1]) not in m: i = 4
            c.put(q[0], q[1], r[i])


def _poncho(c, g, m, v):
    b, tl = g['b'], g['tail']
    _band(c, m, (1, 2), indigo, v); _band(c, m, (3,), maize, v); _band(c, m, (5,), cotton, v); _band(c, m, (6,), maize, v)
    x0, y0, x1, y1 = m.bbox()
    if v == 'back':   # stepped diamond centre
        cx, cy = 32 + (tl if tl > 0 else 0), 54 + b
        for dy in range(-4, 5):
            for dx in range(-4, 5):
                d = abs(dx) + abs(dy)
                if d <= 4 and (cx + dx, cy + dy) in m:
                    c.put(cx + dx, cy + dy, (maize[5], indigo[2], maize[4], indigo[3], cotton[3])[d])
    # fringe
    for q in m.bottom():
        if q[0] % 2 == 0 and q[1] >= y1 - 1:
            c.put(q[0], q[1] + 1, maize[3]); c.put(q[0], q[1] + 2, maize[2])
    # bougainvillea blossom caught in the fringe
    if v != 'front':
        bx = x0 + 3 if v == 'back' else x0 + 2
        by = max(q[1] for q in m if q[0] == bx) + 1
        P(c, [(bx, by), (bx + 1, by + 1), (bx - 1, by + 1)], bougain[4]); c.put(bx, by + 1, bougain[5]); c.put(bx, by + 2, bougain[2])
        c.put(bx + 2, by, jade[3])


def _rebozo(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    # ikat broken stripes
    for q in m:
        if q[1] > y0 + 1 and (q[1] - y0) % 3 == 1 and (q[0] + (q[1] // 3) * 2) % 5 < 3:
            i = 4 if q[0] < x1 - (x1 - x0 + 1) * 0.35 else 3
            c.put(q[0], q[1], cotton[i] if (q[0] + q[1]) % 7 else cochi[4])
    # knotted net just above the lower edges
    for q in m:
        k = _below(m, q, 4)
        if k in (1, 2) and (q[0] + q[1]) % 2 == 0: c.put(q[0], q[1], agave[1])
    # long fringe on the lower edges
    strands = [q for q in m.bottom() if q[0] % 2 == 0]
    for q in strands:
        for k in range(1, 4): c.put(q[0], q[1] + k, agave[2] if k < 3 else agave[1])
    # seed-pod rattle bead on one strand
    if strands and v != 'front':
        q = min(strands, key=lambda p: (p[0] if v == 'side' else abs(p[0] - (x0 + 6))))
        P(c, [(q[0], q[1] + 4), (q[0], q[1] + 5)], cacao[4]); c.put(q[0] + 1, q[1] + 5, cacao[2])


def _palmcape(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        r = (q[1] - y0) % 4
        i = shade_of(c, q, straw)
        if r == 3 and (q[0] % 2 == 0 or q[1] == y1): c.put(q[0], q[1], straw[1])         # shingle shadow (ragged)
        elif r == 0 and q[1] > y0: c.put(q[0], q[1], straw[min(5, i + 1)])
        elif q[0] % 3 == 0: c.put(q[0], q[1], straw[max(1, i - 1)])                     # leaf veins
    # peaked collar ridge
    if v == 'back':
        for q in m.top(): c.put(q[0], q[1], straw[5] if q[0] < 38 else straw[4])
    # red-eyed tree frog sheltering at the hem
    if v == 'back':
        fx, fy = x1 - 5, y1 - 1
    elif v == 'side':
        fx, fy = x0 + 3, y1 - 1
    else:
        return
    P(c, [(fx, fy), (fx + 1, fy), (fx + 2, fy)], jade[4]); P(c, [(fx - 1, fy + 1), (fx + 3, fy + 1)], jade[3])
    c.put(fx, fy - 1, cochi[4]); c.put(fx + 2, fy - 1, cochi[4]); c.put(fx + 1, fy + 1, jade[2])


def _mantle(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # asymmetric: knotted high on one shoulder, hem slanting down to a hanging corner
    if v == 'back':
        cut = M(q for q in m if q[1] > y1 - (q[0] - x0) * 0.45 + 1)
    elif v == 'front':
        cut = M(q for q in m if q[1] > y1 - (x1 - q[0]) * 0.45 + 1)
    else:
        cut = M()
    for q in cut: c.pop(q, None)
    mm = m - cut
    for q in mm.bottom(): c.put(q[0], q[1], ixtle[1])
    # open weave
    for q in mm:
        if q[0] % 3 == 0 and q[1] % 3 == 0: c.put(q[0], q[1], ixtle[1])
        elif (q[0] + q[1]) % 3 == 1 and (q[0] * 7 + q[1] * 3) % 5 == 0: c.put(q[0], q[1], ixtle[5])
    # frayed hem
    for q in mm.bottom():
        if q[0] % 2 == 0: c.put(q[0], q[1] + 1, ixtle[2])
        if q[0] % 4 == 0: c.put(q[0], q[1] + 2, ixtle[1])
    # knot + prickly-pear blossom on the shoulder
    if v == 'back':
        kx, ky = 41, 48 + b
    elif v == 'side':
        kx, ky = 27, 48 + b
    else:
        return
    form(c, ellipse(kx, ky, 1.5, 1.2), ixtle, frac=0.4)
    P(c, [(kx + 1, ky - 2), (kx, ky - 1), (kx + 2, ky - 1), (kx + 1, ky)], maize[4]); c.put(kx + 1, ky - 1, marig[3]); c.put(kx, ky - 2, maize[5])
    c.put(kx + 1, ky + 1, jade[3])


def _sunhood(c, g, m, v):
    b = g['b']
    if v == 'back':
        hood = poly([(25, 48 + b), (40, 48 + b), (35, 56 + b), (32.5, 60 + b), (30, 56 + b)])
        form(c, hood, cotton, frac=0.35)
        for q in hood.inner_edge(): c.put(q[0], q[1], cochi[3] if q[1] > 49 + b else cochi[2])
        for x in range(26, 40):   # red-lined opening along the top
            if (x, 49 + b) in hood: c.put(x, 49 + b, cochi[1])
        # dragonfly resting on the hood
        P(c, [(36, 52 + b), (36, 53 + b), (36, 54 + b), (36, 55 + b)], turq[2]); c.put(36, 51 + b, turq[4])
        P(c, [(35, 52 + b), (37, 52 + b), (34, 53 + b), (38, 53 + b)], turq[5])
    elif v == 'side':
        hood = poly([(28, 46 + b), (22, 46 + b), (20, 53 + b), (23, 56 + b), (27, 52 + b)])
        form(c, hood, cotton, frac=0.3)
        for q in hood.inner_edge():
            if q[0] >= 26: c.put(q[0], q[1], cochi[3])
        P(c, [(22, 49 + b), (22, 50 + b), (22, 51 + b)], turq[2]); c.put(22, 48 + b, turq[4]); P(c, [(21, 49 + b), (23, 49 + b)], turq[5])


CLOAK = [
    dict(slug='ca-hearthstripe-poncho', cat='cloak', r=clay, lining=clay, len=62, flare=4, x0=20, x1=45, fx0=14, fx1=51, side_back=19, detail=_poncho),
    dict(slug='ca-dappled-rebozo', cat='cloak', r=agave, lining=agave, len=64, flare=3, x0=19, x1=46, hemstyle='tri', fx0=15, fx1=50, side_back=19, detail=_rebozo),
    dict(slug='ca-palm-rain-cape', cat='cloak', r=straw, lining=straw, len=64, flare=4, x0=20, x1=45, hemstyle='points', fx0=14, fx1=51, side_back=18, detail=_palmcape),
    dict(slug='ca-agave-fibre-mantle', cat='cloak', r=ixtle, lining=ixtle, len=65, flare=3, x0=21, x1=44, fx0=15, fx1=50, side_back=19, detail=_mantle),
    dict(slug='ca-sun-hood-cloak', cat='cloak', r=cotton, lining=cotton, len=66, flare=3, border=cochi, border_rows=2, border_sides=True, side_back=18, detail=_sunhood),
]

ITEMS = FOOT + PACK + COAT + CLOAK
