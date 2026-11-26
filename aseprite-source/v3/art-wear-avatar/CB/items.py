"""The Sunsprinkle Isles (CB): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/CB/common.lua
(C.R.*) plus a few W.R-style helpers (skin from GNOME25_DEFAULT, strap, cane, sail), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light), C.R from common.lua
straw = ["#5a3f22", "#7e5a2c", "#a67c3a", "#c9a04e", "#e2c06e", "#f4dc98"]
mahog = ["#3a1a1e", "#5c2622", "#7e3828", "#9e4e30", "#bc6a3c", "#d88c52"]
hibis = ["#5e1430", "#8c1e3c", "#b82a48", "#da4058", "#f06a72", "#ffa0a0"]
turq = ["#16405a", "#1e6a7e", "#24909a", "#36b4ac", "#68d4c0", "#b0f0dc"]
indigo = ["#1a1a48", "#232c6c", "#2e4290", "#3e5cae", "#5a80c8", "#8cb0e0"]
cotton = ["#6e5a5a", "#968278", "#b8a694", "#d6c8b0", "#ecdfc6", "#faf2de"]
coral = ["#6a2030", "#9a3440", "#c8504c", "#e6745c", "#f69a78", "#ffc4a0"]
sunset = ["#7a2a1c", "#b0441e", "#de6a26", "#f4922e", "#fcb848", "#ffdc80"]
palm = ["#16382c", "#1e5434", "#2a7238", "#3e9440", "#68b84a", "#a8dc6c"]
gourd = ["#4a2c14", "#6e461c", "#966424", "#b8862e", "#d4a842", "#ecca6a"]
sisal = ["#5a4a30", "#7c6840", "#a08a56", "#c0aa6e", "#d8c68a", "#ece0b0"]
bamboo = ["#4a4a1c", "#6c6a24", "#908a2e", "#b2aa3c", "#d0c858", "#eae48c"]
shell = ["#7a4a50", "#a46a68", "#c88c80", "#e2ae98", "#f2ccb4", "#fce6d4"]
check = ["#5a2410", "#8a3a14", "#c05a1a", "#e47e24", "#f4a43a", "#fcc86a"]
seaglass = ["#1e5040", "#2a7a58", "#3aa070", "#5cc48a", "#94e0aa", "#d0f6d4"]
flam = ["#7a2a50", "#a83e68", "#d05a80", "#ec7e98", "#f8a8b8", "#ffd4dc"]
# helpers
skin = ["#51302b", "#a8684c", "#c98462", "#f0b98d", "#ffe0bd", "#fff0dc"]       # gnome25 default skin, extended
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
cane = ["#2e1838", "#45224e", "#5e3068", "#7a4484", "#9a62a0", "#c090c4"]       # purple sugar cane (icon)
sail = ["#4a4636", "#6c6650", "#8e886c", "#b0aa8a", "#ccc6a6", "#e6e0c4"]       # weathered sailcloth
silver = ["#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2"]
sulph = ["#7a5a10", "#a8801a", "#d4aa28", "#f0cc40", "#fae070", "#fff4b0"]     # sulphur butterfly
GOLD = "#f5b82e"


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def ball(c, cx, cy, r, ramp):
    m = ellipse(cx, cy, r, r)
    form(c, m, ramp, frac=0.35, hi=[(int(cx - r * .45 + .5), int(cy - r * .45 + .5))])
    return m


# ======================================================================== FOOTWEAR
def _sandal(c, g, ft, k):
    """bare (skin) foot on a 2-row plaited palm sole, red instep band + toe thong, conch charm on the toe post."""
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    for q in foot:   # plaited sole: bottom 2 rows
        if q[1] >= y1 - 1:
            c.put(q[0], q[1], straw[4] if (q[0] + q[1]) % 3 == 0 else (straw[2] if q[1] == y1 else straw[3]))
    for q in foot.bottom(): c.put(q[0], q[1], straw[1] if q[0] % 2 else straw[2])
    band = y1 - 4
    if v == 'side':
        for x in range(x0 + 2, x1 - 1): c.put(x, band, hibis[3] if x > x0 + 3 else hibis[2])
        P(c, [(x1 - 2, band + 1), (x1 - 1, band + 2)], hibis[2])            # thong to the toe
        P(c, [(x1, y1 - 3)], shell[4]); c.put(x1, y1 - 2, shell[2])        # conch charm
        if k == 1: P(c, [(x1 - 3, y1 - 2)], skin[2])
    else:
        for x in range(x0 + 1, x1): c.put(x, band, hibis[3] if x < x1 - 2 else hibis[2])
        if v == 'front':
            P(c, [(cx, band + 1)], hibis[2])
            c.put(cx, band + 2, shell[4]); c.put(cx + 1, band + 2, shell[2])   # conch on the toe post
            for x in (cx - 3, cx - 2, cx + 2, cx + 3):                          # toes
                if (x, y1 - 2) in foot: c.put(x, y1 - 2, skin[4] if x < cx else skin[3])
            for x in (cx - 2, cx + 2):
                if (x, y1 - 2) in foot: c.put(x, y1 - 2, skin[2])


def _clog(c, g, ft, k):
    """carved mahogany clog: open back, leather instep strap, heel + toe blocks (arch gap), painted hibiscus on the toe."""
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    for q in foot:   # carved grain
        if (q[0] * 2 + q[1]) % 5 == 0 and q[1] < y1 - 1: c.put(q[0], q[1], mahog[2])
    if v == 'side':
        for y in (y0, y0 + 1):
            for x in range(x0 + 3, x0 + 7): c.put(x, y, strap[4] if y == y0 else strap[2])
        for x in range(x0 + 3, x1 - 2): c.pop((x, y1), None)               # arch between heel and toe block
        P(c, [(x0 + 1, y1), (x0 + 2, y1), (x1 - 1, y1), (x1 - 2, y1)], mahog[0])
        P(c, [(x1 - 2, y1 - 3), (x1 - 3, y1 - 2), (x1 - 1, y1 - 2)], hibis[3]); c.put(x1 - 2, y1 - 2, GOLD)
    elif v == 'front':
        for x in range(x0 + 1, x1): c.put(x, y0 + 1, strap[3] if x < x1 - 2 else strap[2])
        for x in range(x0 + 1, x1): c.put(x, y0, strap[4])
        P(c, [(cx - 1, y1 - 2), (cx + 1, y1 - 2), (cx, y1 - 3)], hibis[3]); c.put(cx, y1 - 2, GOLD); c.put(cx, y1 - 1, hibis[2])
    else:   # back: open heel shows the gnome's heel
        for q in foot:
            if q[1] <= y0 + 1 and x0 + 2 <= q[0] <= x1 - 2: c.put(q[0], q[1], skin[3] if q[0] < cx + 1 else skin[2])
        for x in range(x0 + 1, x1): c.put(x, y1, mahog[0] if x in (x0 + 1, x1 - 1) or abs(x - cx) < 2 else mahog[1])


def _sisal(c, g, ft, k):
    """canvas slip-on on a thick coiled sisal sole; coral ankle ribbons curl up; starfish on the side."""
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    for q in foot:
        if q[1] >= y1 - 1: c.put(q[0], q[1], sisal[4] if (q[0] + q[1]) % 3 == 0 else sisal[2])
    for q in foot.bottom():
        c.put(q[0], q[1] + 1, sisal[1] if q[0] % 2 else sisal[2])   # extra sole row
    if v == 'side':
        rx = x0 + 2
        P(c, [(rx, y0 - 1), (rx - 1, y0 - 2), (rx - 1, y0 - 3), (rx, y0 - 4)], coral[3]); c.put(rx + 1, y0 - 4, coral[4])
        if k == 1 or True:
            sx, sy = x0 + 5, y1 - 3
            P(c, [(sx, sy - 1), (sx - 1, sy), (sx + 1, sy), (sx - 1, sy + 1), (sx + 1, sy + 1)], coral[4]); c.put(sx, sy, coral[2])
    else:
        for rx, d in ((x0 + 1, -1), (x1 - 1, 1)):
            P(c, [(rx, y0 - 1), (rx, y0 - 2), (rx + d, y0 - 3)], coral[3]); c.put(rx + d, y0 - 4, coral[4])
        if v == 'front':
            sx = x1 - 2 if ft['side'] == 'R' else x0 + 2
            P(c, [(sx, y1 - 4), (sx - 1, y1 - 3), (sx + 1, y1 - 3)], coral[4]); c.put(sx, y1 - 3, coral[2])


def _gaiter(c, g, ft, k):
    """turquoise cotton leg-wrap with criss-cross sisal lacing over a leather moccasin; red crab on the near shin."""
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    w = x1 - x0
    for i, y in enumerate(range(top + 2, cy - 2)):
        a = x0 + (i % (w + 1)) if (i // (w + 1)) % 2 == 0 else x1 - (i % (w + 1))
        b = x0 + x1 - a
        c.put(a, y, sisal[4]); c.put(b, y, sisal[3])
    for x in range(x0, x1 + 1): c.put(x, cy - 2, cotton[3] if x % 2 else cotton[2])   # wrap end over the moccasin
    if k == 1:
        cx0 = x0 + 1 if v != 'side' else x0 + 1
        y = top + 4
        P(c, [(cx0, y), (cx0 + 1, y), (cx0 + 2, y)], hibis[3]); P(c, [(cx0, y + 1), (cx0 + 2, y + 1)], hibis[1])
        P(c, [(cx0 - 1, y - 1), (cx0 + 3, y - 1)], hibis[4]); c.put(cx0 + 1, y - 1, hibis[2])


def _reef(c, g, ft, k):
    """sea-green scale-stitched bootie, rolled cotton cuff, curled gnome toe, tie with a sea-glass bead."""
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    for q in (g['foot'] | g['shaft']):
        col = c.get(q)
        if q[1] > top + 1 and col in seaglass[2:] and q[1] % 2 == 0 and (q[0] + q[1] // 2) % 2 == 0:
            c.put(q[0], q[1], seaglass[1] if col == seaglass[2] else seaglass[2])
    fx0, fy0, fx1, fy1 = g['foot'].bbox()
    if v == 'side':
        P(c, [(fx1 + 1, fy1 - 2), (fx1 + 2, fy1 - 3), (fx1 + 2, fy1 - 4)], seaglass[3]); c.put(fx1 + 1, fy1 - 5, seaglass[4])
        c.put(fx1 + 1, fy1 - 4, seaglass[1])
        if not g['far']:
            P(c, [(x1 + 1, top + 2), (x1 + 2, top + 3)], cotton[4]); c.put(x1 + 2, top + 4, seaglass[5]); c.put(x1 + 3, top + 4, seaglass[2])
    elif v == 'front':
        mx = (fx0 + fx1) // 2
        c.put(mx, fy1 - 2, seaglass[5]); c.put(mx + 1, fy1 - 2, seaglass[4]); c.put(mx, fy1 - 1, seaglass[1])   # curled toe tip, seen end-on
        tx = x1 + 1 if ft['side'] == 'R' else x0 - 1
        c.put(tx, top + 2, cotton[4]); c.put(tx, top + 3, seaglass[5]); c.put(tx, top + 4, seaglass[2])
    else:
        tx = x1 + 1 if ft['side'] == 'R' else x0 - 1
        c.put(tx, top + 2, cotton[3]); c.put(tx, top + 3, seaglass[4])


FOOT = [
    dict(slug='cb-palm-plait-sandals', cat='footwear', shell=skin, upper=skin, sole=straw[1], rim=None, detail=_sandal),
    dict(slug='cb-mahogany-clogs', cat='footwear', shell=mahog, upper=mahog, sole=mahog[0], rim=None, puff=0.5, toe=1, detail=_clog),
    dict(slug='cb-sisal-sole-slippers', cat='footwear', shell=turq, upper=turq, sole=sisal[1], rim=None, toe=1, detail=_sisal),
    dict(slug='cb-mangrove-gaiters', cat='footwear', shell=leather, upper=turq, cuff=cotton, cuff_rows=2, sole=leather[0], rim=59, half=4, detail=_gaiter),
    dict(slug='cb-curl-toe-reef-booties', cat='footwear', shell=seaglass, upper=seaglass, cuff=cotton, cuff_rows=2, sole=strap[1], rim=62, half=4, puff=0.5, toe=2, detail=_reef),
]


# ======================================================================== BACKPACK
def _basket_tex(c, m, r):
    for q in m:
        cell = (q[0] // 2 + q[1] // 2) % 2
        col = r[3]
        if cell == 0 and q[1] % 2 == 1: col = r[2]
        elif cell == 1 and q[0] % 2 == 1: col = r[2]
        elif cell == 0: col = r[4]
        c.put(q[0], q[1], col)


def _shade(c, m, r, n=2):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if q[0] > x1 - n: c.put(q[0], q[1], r[1] if c.get(q) == r[2] else r[2])
        if q[1] == y1: c.put(q[0], q[1], r[1])


def market_back(c, x, y, g):
    m = poly([(x - 10, y + 1), (x + 9, y + 1), (x + 6, y + 16), (x - 7, y + 16)])
    _basket_tex(c, m, straw); _shade(c, m, straw)
    form(c, rect(x - 10, y, x + 9, y + 1), straw, frac=0.25)                     # rim
    for xx in range(x - 9, x + 9):
        for yy in (y + 9, y + 10):
            if (xx, yy) in m: c.put(xx, yy, hibis[3] if yy == y + 9 else hibis[2])
    for sx in (x - 11, x + 10):                                                  # palm-cord loops on the sides
        d = -1 if sx < x else 1
        for yy in range(y + 4, y + 11): c.put(sx + d, yy, palm[3] if yy % 2 else palm[2])
        c.put(sx, y + 3, palm[4]); c.put(sx, y + 11, palm[2])
    ball(c, x - 12, y + 4, 2.5, sunset)                                           # mango over the rim, beside the head (left: the scarf end hides the right)
    P(c, [(x - 11, y + 1), (x - 10, y + 0)], palm[4])
    for i, (lx, ly) in enumerate([(x + 9, y - 1), (x + 10, y - 3), (x + 11, y - 5), (x + 12, y - 7), (x + 13, y - 9)]):   # palm leaf
        c.put(lx, ly, palm[3]); c.put(lx - 1, ly - 1 + (i == 0), palm[4]); c.put(lx + 1, ly + 1, palm[2])


def market_side(c, x, y, g):
    m = poly([(x - 8, y + 1), (x, y + 1), (x, y + 16), (x - 6, y + 16)])
    _basket_tex(c, m, straw); _shade(c, m, straw, 1)
    form(c, rect(x - 8, y, x, y + 1), straw, frac=0.25)
    for q in m:
        if q[1] in (y + 9, y + 10): c.put(q[0], q[1], hibis[3] if q[1] == y + 9 else hibis[2])
    for yy in range(y + 3, y + 12): c.put(x - 9, yy, palm[3] if yy % 2 else palm[2])
    ball(c, x - 2, y - 2, 2.5, sunset)
    for lx, ly in [(x - 5, y - 1), (x - 6, y - 3), (x - 7, y - 5), (x - 8, y - 7)]:
        c.put(lx, ly, palm[3]); c.put(lx + 1, ly - 1, palm[4])


def _net(c, m, every=3, col=None):
    for q in m:
        if (q[0] + q[1]) % every == 0 or (q[0] - q[1]) % every == 0:
            c.put(q[0], q[1], col or sisal[4])


def _hummingbird(c, x, y, facing=1):
    P(c, [(x, y), (x - facing, y), (x - facing * 2, y + 1)], palm[3]); c.put(x, y - 1, palm[4])
    c.put(x - facing, y - 1, palm[5]); c.put(x, y + 1, hibis[3])
    P(c, [(x + facing, y - 1), (x + facing * 2, y - 1)], INK)   # beak


def calabash_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 9, 8, 7.5)
    form(c, m, gourd, frac=0.35, hi=[(x - 5, y + 4), (x - 4, y + 3)])
    for q in m:
        if (q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0:
            c.put(q[0], q[1], sisal[4] if q[0] < x + 3 else sisal[2])
    for xx in range(x - 7, x + 7):                                               # carved wave band
        yy = y + 6 + (1 if (xx // 2) % 2 else 0)
        if (xx, yy) in m: c.put(xx, yy, gourd[1])
    form(c, rect(x - 2, y - 1, x + 1, y + 1), gourd, frac=0.4)                   # neck
    form(c, rect(x - 2, y - 3, x + 1, y - 2), mahog, frac=0.4)                   # stopper
    _hummingbird(c, x - 9, y + 4, -1)                                             # perched on the net at the shoulder (stopper is behind the head)


def calabash_side(c, x, y, g):
    m = ellipse(x - 5, y + 9, 5, 7.5)
    form(c, m, gourd, frac=0.3, hi=[(x - 8, y + 5)])
    for q in m:
        if (q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0: c.put(q[0], q[1], sisal[4] if q[0] < x - 3 else sisal[2])
    form(c, rect(x - 6, y - 1, x - 4, y + 1), gourd, frac=0.4)
    form(c, rect(x - 6, y - 3, x - 4, y - 2), mahog, frac=0.4)
    _hummingbird(c, x - 5, y - 5, -1)


def netroll_back(c, x, y, g):
    roll = rect(x - 12, y + 3, x + 11, y + 9)
    form(c, roll, turq, frac=0.25)
    _net(c, roll, 3, turq[5])
    for q in roll.bottom(): c.put(q[0], q[1], turq[1])
    for ex in (x - 12, x + 11):                                                  # rolled ends
        for yy in range(y + 3, y + 10): c.put(ex, yy, turq[1] if (yy - y) % 2 else turq[2])
    for sx in (x - 7, x + 6):                                                    # straps
        for yy in range(y + 3, y + 10): c.put(sx, yy, sisal[3] if yy % 2 else sisal[2])
    loop = line([(x - 5, y + 3), (x - 4, y), (x - 2, y - 1), (x + 1, y - 1), (x + 3, y), (x + 4, y + 3)], 1)
    for q in loop: c.put(q[0], q[1], sisal[4])
    for fx in (x - 6, x, x + 6):                                                 # cork floats
        c.put(fx, y + 10, sisal[2])
        ball(c, fx, y + 12, 1.5, sunset)
    P(c, [(x + 1, y + 6), (x + 2, y + 6), (x + 3, y + 6)], silver[4]); c.put(x + 2, y + 5, silver[5]); c.put(x + 4, y + 5, silver[3]); c.put(x + 4, y + 7, silver[3])


def netroll_side(c, x, y, g):
    x -= 2
    end = ellipse(x - 4, y + 6, 4, 4)
    form(c, end, turq, frac=0.3)
    for q in end:   # spiral rings of rolled net
        d = round(((q[0] - (x - 4)) ** 2 + (q[1] - (y + 6)) ** 2) ** .5)
        if d in (1, 3): c.put(q[0], q[1], turq[1] if d == 1 else turq[2])
    c.put(x - 4, y + 6, turq[0])
    for q in line([(x - 6, y + 2), (x - 5, y), (x - 3, y), (x - 2, y + 2)], 1): c.put(q[0], q[1], sisal[4])
    c.put(x - 4, y + 10, sisal[2]); ball(c, x - 4, y + 12, 1.5, sunset)
    P(c, [(x - 8, y + 5), (x - 8, y + 6)], silver[4])


def batik_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 10, 8.5, 7) | rect(x - 4, y + 2, x + 3, y + 4)
    form(c, m, indigo, frac=0.35)
    for (rx, ry) in ((x - 5, y + 8), (x + 3, y + 7), (x - 1, y + 13), (x + 5, y + 13), (x - 6, y + 14)):
        ring_ = ellipse(rx, ry, 1.5, 1.5)
        inner = M(q for q in ring_ if all((q[0] + a, q[1] + b) in ring_ for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))))
        for q in ring_ - inner:
            if q in m: c.put(q[0], q[1], cotton[4] if q[0] < x + 3 else cotton[2])
    ruff = M()
    for i, xx in enumerate(range(x - 4, x + 4)):                                 # gathered frill
        for yy in range(y - 2 - (i % 2), y + 2): ruff.add((xx, yy))
    form(c, ruff, indigo, frac=0.3)
    for xx in range(x - 4, x + 4): c.put(xx, y - 2 - (xx % 2), indigo[5] if xx < x + 2 else indigo[4])
    for xx in range(x - 4, x + 4): c.put(xx, y + 2, sisal[4] if xx % 2 else sisal[2])   # drawstring
    P(c, [(x + 4, y + 3), (x + 5, y + 4), (x + 5, y + 5)], sisal[3]); c.put(x + 5, y + 6, sisal[1])
    t = ellipse(x - 1.5, y + 10, 2, 1.5)                                         # turtle patch (overrides a ring)
    for q in t: c.put(q[0], q[1], palm[4] if (q[0] + q[1]) % 2 else palm[2])
    P(c, [(x + 1, y + 10)], palm[3]); P(c, [(x - 4, y + 9), (x + 1, y + 12), (x - 4, y + 12), (x + 1, y + 9)], palm[3])


def batik_side(c, x, y, g):
    m = ellipse(x - 5, y + 10, 5, 7) | rect(x - 7, y + 2, x - 3, y + 4)
    form(c, m, indigo, frac=0.3)
    for (rx, ry) in ((x - 6, y + 8), (x - 4, y + 14)):
        ring_ = ellipse(rx, ry, 1.5, 1.5)
        inner = M(q for q in ring_ if all((q[0] + a, q[1] + b) in ring_ for a, b in ((1, 0), (-1, 0), (0, 1), (0, -1))))
        for q in ring_ - inner:
            if q in m: c.put(q[0], q[1], cotton[4])
    ruff = M((xx, yy) for i, xx in enumerate(range(x - 7, x - 2)) for yy in range(y - 2 - (i % 2), y + 2))
    form(c, ruff, indigo, frac=0.3)
    for xx in range(x - 7, x - 2): c.put(xx, y + 2, sisal[4] if xx % 2 else sisal[2])
    P(c, [(x - 8, y + 3), (x - 9, y + 4), (x - 9, y + 5)], sisal[3])


def _bamboo_pole(c, x0, y0, x1, y1, vert=True):
    m = rect(x0, y0, x1, y1)
    form(c, m, bamboo, frac=0.5 if vert else 0.2)
    if vert:
        for yy in range(y0 + 3, y1, 5):
            for xx in range(x0, x1 + 1): c.put(xx, yy, bamboo[1])
    else:
        for xx in range(x0 + 3, x1, 5):
            for yy in range(y0, y1 + 1): c.put(xx, yy, bamboo[1])


def bamboo_back(c, x, y, g):
    for sx in range(x - 6, x + 6, 2):                                            # sugar cane bundle
        top = y - 4 + (sx * 3) % 3
        m = rect(sx, top, sx + 1, y + 13)
        form(c, m, cane, frac=0.5, rim=False)
        for yy in range(top + 2, y + 13, 4): c.put(sx, yy, cane[1]); c.put(sx + 1, yy, cane[0])
        c.put(sx, top, cane[4])
    for sx in (x - 9, x + 7): _bamboo_pole(c, sx, y - 4, sx + 1, y + 16)
    for ry in (y - 1, y + 6): _bamboo_pole(c, x - 9, ry, x + 8, ry, vert=False)
    mat = rect(x - 8, y + 12, x + 7, y + 15)                                     # rolled mat
    form(c, mat, straw, frac=0.25)
    for q in mat:
        if q[0] % 2 == 0 and q[1] != y + 12: c.put(q[0], q[1], straw[2])
    for xx in range(x - 6, x + 6): c.put(xx, y + 3, sisal[4] if xx % 2 else sisal[2])   # lashing
    feather = line([(x + 2, y + 4), (x + 4, y + 1), (x + 6, y - 2), (x + 8, y - 5)], 1)
    for i, q in enumerate(sorted(feather, key=lambda p: -p[1])):
        c.put(q[0], q[1], hibis[3] if i < 4 else (sunset[4] if i < 6 else turq[3]))
        c.put(q[0] + 1, q[1], hibis[2] if i < 4 else (palm[3] if i < 7 else indigo[3]))


def bamboo_side(c, x, y, g):
    for sx in (x - 8, x - 6, x - 4):
        m = rect(sx, y - 4 + (sx % 2), sx + 1, y + 13)
        form(c, m, cane, frac=0.5, rim=False)
        for yy in range(y - 2, y + 13, 4): c.put(sx, yy, cane[1])
    _bamboo_pole(c, x - 2, y - 4, x - 1, y + 16)
    _bamboo_pole(c, x - 10, y - 4, x - 10, y + 16)
    for ry in (y - 1, y + 6): _bamboo_pole(c, x - 10, ry, x - 1, ry, vert=False)
    mat = ellipse(x - 6, y + 13.5, 3.5, 2)
    form(c, mat, straw, frac=0.3)
    c.put(x - 6, y + 13, straw[1]); c.put(x - 6, y + 14, straw[2])
    for xx in range(x - 9, x - 2): c.put(xx, y + 3, sisal[4] if xx % 2 else sisal[2])
    feather = line([(x - 5, y + 4), (x - 7, y + 1), (x - 9, y - 2), (x - 11, y - 5)], 1)
    for i, q in enumerate(sorted(feather, key=lambda p: -p[1])):
        c.put(q[0], q[1], hibis[3] if i < 4 else (sunset[4] if i < 6 else turq[3]))


PACK = [
    dict(slug='cb-market-basket-pack', cat='backpack', back=market_back, side=market_side),
    dict(slug='cb-calabash-carrier', cat='backpack', back=calabash_back, side=calabash_side),
    dict(slug='cb-net-roll-bundle', cat='backpack', back=netroll_back, side=netroll_side),
    dict(slug='cb-batik-sea-sack', cat='backpack', back=batik_back, side=batik_side),
    dict(slug='cb-bamboo-frame-pack', cat='backpack', back=bamboo_back, side=bamboo_side),
]


# ======================================================================== COAT
def _in_torso(g, q):
    return q in g['torso'] and not any(q in s for s in g['sleeves'])


def _smock_pat(q, t, g):
    y = q[1] - g['b']
    if g['view'] != 'front' and y == 51: return turq[4] if q[0] % 2 else turq[2]          # stitched yoke
    if y > 52 and q[0] % 3 == 0 and t < 3 and _in_torso(g, q): return cotton[2] if t < 2 else cotton[1]   # gathers
    if y == 63: return turq[3] if q[0] % 2 else turq[2]                                      # hem stitch
    return None


def _smock(c, g):
    v, b = g['view'], g['b']
    for s in g['sleeves']:   # short puffed sleeve: turquoise stitched cuff band
        y1 = s.bbox()[3]
        for q in s:
            if q[1] == y1 - 1: c.put(q[0], q[1], turq[3] if q[0] % 2 else turq[2])
    if v == 'front':   # frangipani at the collar beside the beard
        fx, fy = 43, 50 + b
        P(c, [(fx, fy - 1), (fx - 1, fy), (fx + 1, fy), (fx, fy + 1)], flam[4]); c.put(fx, fy, GOLD); c.put(fx + 1, fy + 1, flam[2])
    elif v == 'side':
        fx, fy = 28, 48 + b
        P(c, [(fx, fy - 1), (fx - 1, fy), (fx + 1, fy), (fx, fy + 1)], flam[4]); c.put(fx, fy, GOLD)


def _wrap(c, g):
    v, b = g['view'], g['b']
    for q in list(c.keys()):   # sun-orange sash
        if q[1] - b in (58, 59) and _in_torso(g, q):
            c.put(q[0], q[1], sunset[4] if q[1] - b == 58 else sunset[2])
    for s in g['sleeves']:   # wide pale-lined cuffs
        y1 = s.bbox()[3]
        for q in s:
            if q[1] == y1 - 1: c.put(q[0], q[1], cotton[4])
    if v == 'front':
        for i in range(6): c.put(39 - i, 60 + i + b, indigo[1])                # crossover edge below the beard
        P(c, [(42, 60 + b), (42, 61 + b), (43, 62 + b), (43, 63 + b)], sunset[3]); P(c, [(43, 60 + b), (44, 61 + b)], sunset[2])
        P(c, [(43, 64 + b), (44, 64 + b), (45, 65 + b)], mahog[4]); c.put(44, 65 + b, mahog[2]); c.put(42, 65 + b, mahog[3])  # wooden fish toggle
    elif v == 'back':
        P(c, [(23, 60 + b), (23, 61 + b), (22, 62 + b), (22, 63 + b)], sunset[3]); c.put(22, 64 + b, mahog[4]); c.put(21, 64 + b, mahog[2])
    else:
        P(c, [(24, 60 + b), (23, 61 + b), (23, 62 + b), (22, 63 + b)], sunset[3])
        P(c, [(22, 64 + b), (21, 64 + b), (20, 65 + b)], mahog[4]); c.put(21, 65 + b, mahog[2])


def _check_pat(q, t, g):
    a, bb = q[0] % 4 == 0, (q[1] - g['b']) % 4 == 2
    if a and bb: return check[0] if t >= 2 else check[1]
    if a: return cotton[3] if t < 2 else cotton[2]
    if bb: return cotton[2] if t < 2 else cotton[1]
    return None


def _jacket(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        for x0 in (21, 22, 41, 42):                                               # big cream collar points
            for y in range(46, 49):
                if (x0 in (22, 41) or y < 48) and (x0, y + b) in c: c.put(x0, y + b, cotton[4] if x0 < 32 else cotton[3])
        for y in (61, 63): P(c, [(33, y + b)], mahog[1]); c.put(32, y + b, mahog[3])   # coconut-shell buttons
        P(c, [(41, 57 + b), (42, 57 + b), (43, 57 + b), (44, 57 + b)], check[0])       # pocket + sea-grape leaf
        P(c, [(42, 55 + b), (43, 55 + b), (42, 56 + b), (43, 56 + b)], palm[4]); c.put(43, 56 + b, palm[2]); c.put(44, 55 + b, palm[3])
    elif v == 'back':
        for x in range(25, 41):
            for y in (47, 48):
                if (x, y + b) in c: c.put(x, y + b, cotton[4] if y == 47 else cotton[2])
    else:
        for x in range(23, 30):
            if (x, 47 + b) in c: c.put(x, 47 + b, cotton[4])
            if (x, 48 + b) in c: c.put(x, 48 + b, cotton[2])
        P(c, [(34, 59 + b), (35, 59 + b), (36, 59 + b), (37, 59 + b)], check[0])
        P(c, [(35, 57 + b), (36, 57 + b), (35, 58 + b), (36, 58 + b)], palm[4]); c.put(36, 58 + b, palm[2])


def _sail_pat(q, t, g):
    h = (q[0] * 7 + q[1] * 13) % 23
    if h == 0 and t < 3: return sail[2] if t < 2 else sail[1]     # weathering
    if g['view'] != 'front' and q[1] - g['b'] in (46, 47) and _in_torso(g, q): return sail[4]   # stand collar
    return None


def _longcoat(c, g):
    v, b = g['view'], g['b']
    def pocket(x0, x1, y0, y1):
        for x in range(x0, x1 + 1):
            for y in range(y0, y1 + 1):
                if (x, y + b) in c: c.put(x, y + b, sail[4] if y == y0 else (sail[2] if x == x1 else sail[3]))
        for x in range(x0, x1 + 1):
            if (x, y0 + b) in c: c.put(x, y0 + b, sail[1])
    if v == 'front':
        pocket(24, 28, 61, 64); pocket(37, 41, 61, 64)
        for y in (60, 62): P(c, [(31, y + b), (32, y + b), (34, y + b), (35, y + b)], sisal[4]); c.put(33, y + b, sisal[2])  # rope frogs
        P(c, [(33, 64 + b)], shell[5]); c.put(32, 64 + b, shell[3]); c.put(34, 64 + b, shell[3])     # sand-dollar button
        c.put(33, 65 + b, shell[2])
    elif v == 'back':
        for y in range(62, 68): c.put(32 + g['hem'], y + b, sail[1])                 # back vent
    else:
        pocket(33, 38, 60, 63)
        P(c, [(39, 59 + b), (40, 59 + b)], sisal[4]); P(c, [(39, 61 + b)], shell[5])


def _vest_pat(q, t, g):
    v, y = g['view'], q[1] - g['b']
    r = sunset if y < 57 else coral
    cs = {'front': [(20, 54), (45, 54), (21, 61), (44, 61)], 'back': [(27, 52), (38, 52), (32, 59)], 'side': [(26, 53), (33, 60)]}[v]
    for cx, cy in cs:
        d = round(((q[0] - cx) ** 2 + (y - cy) ** 2) ** .5)
        if d == 2: return coral[4] if r is sunset else sunset[4]
        if d == 0: return flam[3]
    return r[max(0, min(5, 4 - t))]


def _vest(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        for y in (61, 63): c.put(33, y + b, seaglass[4]); c.put(32, y + b, seaglass[2])   # sea-glass buttons
        P(c, [(41, 58 + b), (42, 58 + b), (43, 58 + b), (44, 58 + b)], coral[1])            # pocket lip
        P(c, [(42, 57 + b), (43, 57 + b), (43, 56 + b), (44, 56 + b)], palm[4]); c.put(42, 56 + b, palm[3])   # anole peeking out
        c.put(44, 57 + b, palm[2]); c.put(43, 56 + b, INK); c.put(41, 57 + b, hibis[4])
    elif v == 'side':
        P(c, [(34, 59 + b), (35, 59 + b), (36, 59 + b), (37, 59 + b)], coral[1])
        P(c, [(35, 58 + b), (36, 58 + b), (36, 57 + b), (37, 57 + b)], palm[4]); c.put(37, 57 + b, INK); c.put(34, 58 + b, hibis[4])


COAT = [
    dict(slug='cb-breeze-smock', cat='coat', r=cotton, hem=1, puff=1, pattern=_smock_pat, detail=_smock),
    dict(slug='cb-indigo-wrap-coat', cat='coat', r=indigo, hem=3, detail=_wrap),
    dict(slug='cb-check-weave-jacket', cat='coat', r=check, pattern=_check_pat, detail=_jacket),
    dict(slug='cb-sailcloth-longcoat', cat='coat', r=sail, hem=4, pattern=_sail_pat, detail=_longcoat),
    dict(slug='cb-sunset-batik-vest', cat='coat', r=sunset, sleeves=False, pattern=_vest_pat, detail=_vest),
]


# ======================================================================== CLOAK
def _thatch(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # overlapping frond tiers every 4 rows, ragged fringe line under each
        k = (q[1] - y0) % 4
        if q[1] > y0 + 1:
            if k == 0: c.put(q[0], q[1], straw[1] if q[0] % 2 else straw[0])
            elif k == 1: c.put(q[0], q[1], straw[4] if q[0] % 3 else straw[3])
            elif (q[0] + q[1]) % 3 == 0: c.put(q[0], q[1], straw[2])
    for q in m.bottom():   # ragged fringe hem
        if q[0] % 2: c.pop(q, None)
        else: c.put(q[0], q[1], straw[1])
    b = g['b']
    if v == 'back':   # tree frog on the top tier
        fx, fy = 23, 52 + b   # left shoulder: the scarf end covers the right one
        P(c, [(fx, fy), (fx + 1, fy), (fx + 2, fy), (fx + 1, fy - 1)], palm[4]); c.put(fx, fy - 1, palm[5])
        P(c, [(fx, fy + 1), (fx + 2, fy + 1)], palm[2]); c.put(fx + 1, fy - 1, INK); c.put(fx - 1, fy, sunset[4])
    elif v == 'side':
        fx, fy = 20, 53 + b
        P(c, [(fx, fy), (fx + 1, fy), (fx - 1, fy), (fx, fy - 1)], palm[4]); c.put(fx - 1, fy - 1, INK); c.put(fx + 1, fy + 1, palm[2])


def _hibiscus(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    cx = (x0 + x1) // 2
    spots = [(cx - 6, y0 + 5), (cx + 5, y0 + 6), (cx, y0 + 10), (cx - 3, y0 + 3), (cx + 2, y0 + 2)] if v != 'side' else [(x0 + 4, y0 + 6), (x0 + 3, y0 + 12)]
    for fx, fy in spots:
        if (fx, fy) in m and (fx, fy + 2) in m:
            P(c, [(fx, fy - 1), (fx - 1, fy), (fx + 1, fy), (fx, fy + 1)], hibis[4]); c.put(fx + 1, fy + 1, hibis[2]); c.put(fx, fy, GOLD)
            c.put(fx + 2, fy + 1, palm[3]); c.put(fx - 1, fy + 2, palm[4])
    for q in m.bottom():   # fringe
        if q[0] % 2 == 0: c.put(q[0], q[1] + 1, hibis[1]); c.put(q[0], q[1] + 2, hibis[2] if (q[0] // 2) % 2 else hibis[1])
    b = g['b']
    # sulphur butterfly resting on the edge
    if v == 'back':
        ey = 50 + b; ex = max(q[0] for q in m if q[1] == ey) + 1
        P(c, [(ex, ey - 1), (ex + 1, ey - 2), (ex, ey), (ex + 1, ey)], sulph[4]); c.put(ex + 1, ey - 1, sulph[2]); c.put(ex - 1, ey, INK)
    elif v == 'side':
        ey = 52 + b; ex = min(q[0] for q in m if q[1] == ey) - 1
        P(c, [(ex, ey - 1), (ex - 1, ey - 2), (ex, ey), (ex - 1, ey)], sulph[4]); c.put(ex - 1, ey - 1, sulph[2])


def _poncho(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    cx = (x0 + x1) / 2 + g['tail']
    if v != 'front':
        for q in m:   # chevron stripes parallel to the diamond hem
            k = int(q[1] + abs(q[0] - cx) * 0.45) if v == 'back' else q[1]
            s = (k // 2) % 4
            sh = q[0] > x1 - (x1 - x0) * 0.35
            if s == 1: c.put(q[0], q[1], sisal[3] if not sh else sisal[2])
            elif s == 3: c.put(q[0], q[1], coral[3] if (k % 2) else (turq[1] if sh else turq[2]))
    for q in m.bottom():
        if q[0] % 2: c.put(q[0], q[1] + 1, sisal[2])
    if v != 'side':   # corner tassels, a scallop shell on the bottom one
        left = min(m, key=lambda q: (q[0], -q[1])); right = max(m, key=lambda q: (q[0], q[1]))
        for t in (left, right):
            P(c, [(t[0], t[1] + 1), (t[0], t[1] + 2)], coral[2]); c.put(t[0], t[1] + 3, coral[4])
        bot = max(m, key=lambda q: (q[1], -abs(q[0] - cx)))
        c.put(bot[0], bot[1] + 1, coral[2])
        if v == 'back':
            sx, sy = bot[0], bot[1] + 2
            P(c, [(sx - 1, sy), (sx, sy), (sx + 1, sy), (sx, sy + 1)], shell[4]); c.put(sx, sy, shell[2]); c.put(sx - 1, sy, shell[5])
    else:
        bot = min((q for q in m if q[1] >= y1 - 1), key=lambda q: q[0])
        P(c, [(bot[0], bot[1] + 1), (bot[0], bot[1] + 2)], coral[2])
        P(c, [(bot[0] - 1, bot[1] + 3), (bot[0], bot[1] + 3), (bot[0] + 1, bot[1] + 3)], shell[4]); c.put(bot[0], bot[1] + 4, shell[2])


def _mangrove(c, g, m, v):
    b = g['b']
    x0, y0, x1, y1 = m.bbox()
    for q in list(m):   # rooty tabs: 3 bottom rows cut into 2-px roots with 1-2 px gaps, root tips mahogany
        if q[1] >= y1 - 2:
            ph = (q[0] - x0 + g['tail']) % 4
            if ph == 3 or (ph == 2 and q[1] == y1): c.pop(q, None)
            elif q[1] == y1: c.put(q[0], q[1], mahog[3] if ph == 0 else mahog[2])
    if v == 'back':   # hood lying down the back, pointed, with the seed pod dangling from its tip
        hood = poly([(25, 47 + b), (40, 47 + b), (33, 58 + b), (32, 58 + b)])
        form(c, hood, palm, frac=0.35)
        for q in hood.inner_edge():
            if q[1] > 47 + b: c.put(q[0], q[1], palm[4] if q[0] < 33 else palm[2])
        for q in poly([(28, 48 + b), (37, 48 + b), (33, 53 + b), (32, 53 + b)]): c.put(q[0], q[1], palm[0])   # hood opening
        P(c, [(32, 59 + b), (32, 60 + b)], sisal[2]); P(c, [(32, 61 + b), (32, 62 + b), (32, 63 + b)], palm[4]); c.put(32, 64 + b, mahog[3])
    elif v == 'side':
        hood = poly([(22, 46 + b), (28, 46 + b), (26, 53 + b), (21, 52 + b)])
        form(c, hood, palm, frac=0.3)
        P(c, [(20, 53 + b), (19, 54 + b)], sisal[2]); P(c, [(19, 55 + b), (19, 56 + b)], palm[4]); c.put(19, 57 + b, mahog[3])
        P(c, [(27, 47 + b), (27, 48 + b)], sisal[4])


def _capelet(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # scalloped shell layers every 3 rows
        k = (q[1] - y0) % 3
        if q[1] > y0 + 1:
            ph = (q[0] + (q[1] - y0) // 3 * 2) % 4
            if k == 2 and ph in (0, 3): c.put(q[0], q[1], coral[1])
            elif k == 0 and ph in (1, 2): c.put(q[0], q[1], coral[5] if q[0] < x1 - 4 else coral[4])
    for q in m.bottom():   # scalloped hem
        ph = (q[0] - x0) % 4
        if ph == 0: c.pop(q, None)
        else: c.put(q[0], q[1], shell[3] if ph == 2 else coral[2])
    b = g['b']
    if v == 'back':   # high collar band behind the head
        for x in range(25, 41):
            if (x, 46 + b) in m: c.put(x, 46 + b, flam[3] if x < 37 else flam[2])
            if (x, 47 + b) in m: c.put(x, 47 + b, flam[1])
    elif v == 'side':   # collar edge + the cowrie clasp at the shoulder front
        P(c, [(27, 46 + b), (27, 47 + b)], flam[3])
        P(c, [(28, 47 + b), (29, 47 + b), (28, 48 + b), (29, 48 + b)], shell[5]); c.put(28, 48 + b, shell[2]); c.put(29, 48 + b, shell[3])


CLOAK = [
    dict(slug='cb-thatch-rain-cape', cat='cloak', r=straw, lining=straw, len=62, flare=5, x0=23, x1=42, fx0=16, fx1=49, front_flare=3, side_back=18, detail=_thatch),
    dict(slug='cb-hibiscus-shawl', cat='cloak', r=cotton, lining=cotton, len=63, flare=3, x0=19, x1=46, hemstyle='tri', border=hibis, border_rows=1, fx0=15, fx1=50, detail=_hibiscus),
    dict(slug='cb-sea-breeze-poncho', cat='cloak', r=turq, lining=turq, len=63, flare=4, x0=20, x1=45, hemstyle='diamond', fx0=15, fx1=50, front_flare=3, side_back=19, detail=_poncho),
    dict(slug='cb-mangrove-hood', cat='cloak', r=palm, lining=palm, len=67, flare=3, front_wide=2, side_back=18, detail=_mangrove),
    dict(slug='cb-shell-scallop-capelet', cat='cloak', r=coral, lining=coral, len=55, flare=4, side_back=19, fx0=13, fx1=52, front_flare=4, detail=_capelet),
]

ITEMS = FOOT + PACK + COAT + CLOAK
