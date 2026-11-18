"""Blossomreach (EA): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/EA/common.lua (R.*)
and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light. Quirks sit where the view shows them (see concepts.md)."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light): EA/common.lua
hemp = ["#5e4a30", "#86704a", "#a8925e", "#c6b076", "#dccb92", "#efe2b4"]
straw = ["#5a3a1c", "#80561e", "#a87a28", "#cc9c36", "#e4bc52", "#f6dc86"]
lacq = ["#3a1420", "#5e1c26", "#86262a", "#a83a30", "#c85a3e", "#e88a5a"]
indigo = ["#141c3a", "#1e2a56", "#283c74", "#344f92", "#4a68ae", "#7090c8"]
indigoL = ["#283c74", "#344f92", "#4a68ae", "#6a88c4", "#90acd8", "#b8ccea"]
fleece = ["#6a5a52", "#8e7c6c", "#b2a088", "#cebca0", "#e4d6ba", "#f6ecd4"]
jade = ["#163a36", "#1e5a4c", "#2a7a5e", "#3c9a6e", "#62b882", "#a2d8a2"]
petal = ["#6e2a52", "#9a3a68", "#c4587e", "#e07c98", "#f2a2b6", "#fccad6"]
plum = ["#3c1a3c", "#5a2450", "#7a3060", "#98406c", "#b45a7a", "#d0848e"]
bamboo = ["#3a3a1c", "#5a5a22", "#7e7a2c", "#a29a3a", "#c4b852", "#e2d880"]
rattan = ["#4a2c1a", "#6e4222", "#94602e", "#b8803c", "#d4a052", "#ecc278"]
ramie = ["#2e4a5e", "#46687a", "#64889a", "#88aab8", "#b0ccd4", "#dceaea"]
frost = ["#3a4462", "#526088", "#7082a8", "#94a6c4", "#bccad8", "#e2eaf0"]
oat = ["#4a3e3a", "#6a5c52", "#8c7c6c", "#ac9c86", "#c8baa0", "#e2d6bc"]
frog = ["#1e4a2a", "#2e6a2e", "#4a8a34", "#6eab3c", "#98c84a", "#c8e47a"]
turq = ["#1a4a5a", "#226a74", "#2e8c8a", "#46ae9e", "#72cab2", "#b0eace"]
moss = ["#1e3a2e", "#24544a", "#3f9150", "#5aa854", "#7cc35a", "#c4e07a"]
snow = ["#5a6a8c", "#7a8cac", "#a0b0ca", "#c4d2e2", "#e0eaf2", "#f4f8fa"]
# ---- gnome-wear/_gw.lua
lining = ["#5a3a2a", "#8a5a36", "#b07a46", "#cf9b5c", "#e6bd7e", "#f6dca6"]
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
felt = ["#3a2026", "#552f2c", "#704033", "#8a5239", "#a66a45", "#c48a5a"]
ember = ["#5e1c33", "#8a2a3d", "#b52e3f", "#d23c3c", "#e8573f", "#ff8a5c"]
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
canvas = ["#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
steel = ["#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2"]
yarnA = ["#5c1f2e", "#842a36", "#a8383a", "#c64e40", "#dc6a4a", "#f08e62"]
autumn = ["#6e2a1c", "#a8401e", "#d8602a", "#ee8434", "#f8a848", "#ffd27a"]
gold = ["#6a3e1a", "#9a5e1e", "#c88428", "#e6aa3a", "#f6cc5a", "#ffe8a0"]


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def D(c, d, dx=0, dy=0):
    for (x, y), col in d.items(): c.put(x + dx, y + dy, col)


def tone(r, col, default=3):
    return r.index(col) if col in r else default


def shift(c, q, r, k):
    """move pixel q k steps along ramp r (only if it is on that ramp)."""
    col = c.get(q)
    if col in r: c.put(q[0], q[1], r[max(0, min(5, r.index(col) + k))])


# ======================================================================== FOOTWEAR
def _sandals(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    for q in foot:   # plaited hemp: diagonal weave ticks
        if (q[0] + 2 * q[1]) % 3 == 0: shift(c, q, hemp, -1)
    for q in foot.bottom(): c.put(q[0], q[1], hemp[1])
    for q in foot.bottom().sh(0, -1):
        if q in foot: c.put(q[0], q[1], hemp[2] if q[0] % 2 else hemp[4])   # thick plaited sole edge
    if v == 'side':
        tx = int(ft['cx'] + 3)
        P(c, [(tx, cy), (tx - 1, cy - 1), (tx - 2, cy - 1), (tx - 3, cy - 2)], ember[3])   # cord from the toe to the ankle
        P(c, [(tx - 4, cy - 2), (tx - 5, cy - 2)], ember[2]); c.put(tx - 1, cy - 1, ember[5])
        for x in range(cx - 3, cx + 1): c.put(x, cy - 3, ember[2] if x % 2 else ember[4])   # ankle tie
        if k == 1: P(c, [(tx, cy - 2)], petal[5]); c.put(tx + 1, cy - 2, petal[3])
    else:
        P(c, [(cx - 3, cy - 2), (cx - 2, cy - 1), (cx - 1, cy), (cx, cy), (cx + 1, cy - 1), (cx + 2, cy - 2)], ember[3])
        P(c, [(cx - 1, cy), (cx - 2, cy - 1)], ember[4])
        for x in range(cx - 3, cx + 3): c.put(x, cy - 3, ember[2] if x % 2 else ember[4])
        if v == 'front':
            c.put(cx + 3, cy - 2, ember[2])   # loose tie end
            if k == 1: P(c, [(cx, cy + 1)], petal[5]); P(c, [(cx + 1, cy + 1), (cx, cy + 2)], petal[3])   # plum petal on the toe


def _clogs(c, g, ft, k):
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    x0, x1 = int(round(cx - 4)), int(round(cx + 4))
    if v == 'side': x0, x1 = int(cx - 4), int(cx + 5)
    # sock top stays the 'shell' (cream cotton); lacquered platform + wooden teeth below it
    for x in range(x0, x1 + 1):
        c.put(x, cy + 1, lacq[4] if x < x1 - 2 else lacq[3])
        c.put(x, cy + 2, lacq[2] if x < x1 - 2 else lacq[1])
    c.put(x0 + 1, cy + 1, lacq[5])
    if v == 'side':
        teeth = [(x0 + 1, x0 + 2), (x1 - 3, x1 - 2)]
    else:
        teeth = [(x0 + 1, x1 - 1)]
    for a, z in teeth:
        for x in range(a, z + 1):
            c.put(x, cy + 3, wood[3] if x < z - 1 else wood[2]); c.put(x, cy + 4, wood[1])
    # green cloth thong
    if v == 'front':
        ix = int(cx)
        P(c, [(ix, cy), (ix - 1, cy - 1), (ix - 2, cy - 2), (ix + 1, cy - 1), (ix + 2, cy - 2)], jade[3]); c.put(ix, cy, jade[4])
        if k == 1:   # snail on the front tooth
            D(c, {(x1 - 2, cy + 3): autumn[4], (x1 - 1, cy + 3): rattan[2], (x1 - 2, cy + 4): rattan[3], (x1 - 1, cy + 4): autumn[3],
                  (x1, cy + 4): fleece[4], (x1, cy + 3): fleece[3]})
    elif v == 'side':
        tx = int(cx + 3)
        P(c, [(tx, cy), (tx - 1, cy - 1), (tx - 2, cy - 2), (tx - 3, cy - 2)], jade[3]); c.put(tx, cy, jade[4])
        if k == 1:
            D(c, {(x1 - 1, cy + 3): autumn[4], (x1, cy + 3): rattan[2], (x1 - 1, cy + 4): rattan[3], (x1, cy + 4): autumn[3], (x1 + 1, cy + 4): fleece[4]})
    else:
        P(c, [(int(cx) - 2, cy - 2), (int(cx) + 2, cy - 2)], jade[2])


def _indigo(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    foot = g['foot']
    for q in foot.bottom(): c.put(q[0], q[1], fleece[1])          # thick pale sole, 2 rows
    for q in foot.bottom().sh(0, -1):
        if q in foot: c.put(q[0], q[1], fleece[3] if q[0] % 3 else fleece[2])
    for y in (top + 2, top + 4, cy - 1):   # running stitch rows
        for x in range(x0 - 3, x1 + 5):
            if (x + y) % 3 != 0 and (x, y) in c and c[(x, y)] in indigo: c.put(x, y, fleece[4] if c[(x, y)] in indigo[3:] else fleece[2])
    if k == 0:   # ginkgo leaf tucked in the cuff
        lx = x0 + 2
        D(c, {(lx, top - 1): straw[1], (lx - 1, top - 2): gold[3], (lx, top - 2): gold[4], (lx + 1, top - 2): gold[3],
              (lx - 2, top - 3): gold[4], (lx - 1, top - 3): gold[5], (lx, top - 3): gold[4], (lx + 1, top - 3): gold[4], (lx + 2, top - 3): gold[2]})


def _felt(c, g, ft, k):
    v, top, x0, x1, cy, cx = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy']), ft['cx']
    xs = range(x0 - 1, x1 + 2)
    for x in xs:   # rust applique band with a cream stitch dot
        for y, col in ((top + 3, yarnA[4]), (top + 4, yarnA[3]), (top + 5, yarnA[1])):
            if (x, y) in c and c[(x, y)] in fleece: c.put(x, y, col)
        if (x, top + 4) in c and c[(x, top + 4)] == yarnA[3] and x % 3 == 0: c.put(x, top + 4, fleece[5])
    for x in xs:   # stitched rim
        if (x, top) in c and c[(x, top)] in fleece: c.put(x, top, fleece[2] if x % 2 else fleece[4])
    if v == 'side':   # gently upturned toe with a wool pompom
        tx = int(cx + 6)
        D(c, {(tx, cy - 1): fleece[4], (tx + 1, cy - 2): fleece[3], (tx + 1, cy - 3): yarnA[4], (tx + 2, cy - 3): yarnA[3],
              (tx + 1, cy - 4): yarnA[5], (tx + 2, cy - 4): yarnA[4]})
    elif v == 'front':
        ix = int(cx) - (1 if ft['side'] == 'L' else 0)
        D(c, {(ix, cy): yarnA[5], (ix + 1, cy): yarnA[4], (ix, cy + 1): yarnA[3], (ix + 1, cy + 1): yarnA[2]})


def _straw(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    for q in list(g['foot'] | g['shaft']):
        if q not in c or c[q] not in straw: continue
        r = (q[1] - top) % 4
        if r == 0: c.put(q[0], q[1], straw[4] if q[0] % 2 else straw[3])        # thatch tier top
        elif r == 3: c.put(q[0], q[1], straw[1] if q[0] % 2 else straw[2])      # shaggy tier edge
        elif q[0] % 2 == 0: shift(c, q, straw, -1)                              # hanging strands
    # shaggy tier ends stick out sideways
    for x in range(x0, x1 + 1): c.put(x, top + 6, strap[2] if x % 2 else strap[3])   # tie at the shin
    c.put(x1 + 1, top + 7, strap[2])
    if k == 1:   # tuft of snow on the top layer
        for x in range(x0, x1 + 1): c.put(x, top, snow[3] if x > x1 - 2 else snow[4])
        for x in range(x0 + 1, x1): c.put(x, top - 1, snow[5] if x < x1 - 1 else snow[4])
        c.put(x0 + 2, top - 2, snow[5])


FOOT = [
    dict(slug='ea-hemp-sandals', cat='footwear', shell=hemp, sole=hemp[1], rim=None, detail=_sandals),
    dict(slug='ea-rain-clogs', cat='footwear', shell=fleece, sole=fleece[2], rim=None, detail=_clogs),
    dict(slug='ea-indigo-boots', cat='footwear', shell=indigo, upper=indigo, cuff=indigoL, cuff_rows=1, sole=fleece[1], rim=62, half=4, toe=1, detail=_indigo),
    dict(slug='ea-felt-boots', cat='footwear', shell=fleece, upper=fleece, sole=sole[1], rim=59, half=4, toe=2, detail=_felt),
    dict(slug='ea-snow-straw-boots', cat='footwear', shell=straw, upper=straw, sole=straw[0], rim=59, half=4, puff=0.5, detail=_straw),
]


# ======================================================================== BACKPACK
def _shade_right(c, m, r, n=2):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if q[0] > x1 - n: c.put(q[0], q[1], r[2])
        if q[1] == y1: c.put(q[0], q[1], r[1])


def _pole(c, pts, w=2):
    m = line(pts, w)
    form(c, m, bamboo, frac=0.5)
    ys = sorted({q[1] for q in m})
    for y in ys[2::5]:   # bamboo nodes
        for q in m:
            if q[1] == y: c.put(q[0], q[1], bamboo[1])
            if q[1] == y - 1: c.put(q[0], q[1], bamboo[5])
    return m


def _logs(c, x0, x1, y):
    for xx in range(x0, x1 + 1):
        c.put(xx, y, wood[4] if xx % 5 else wood[5]); c.put(xx, y + 1, wood[3] if xx % 4 != 1 else wood[2]); c.put(xx, y + 2, wood[2])
    P(c, [(x0, y), (x0, y + 2)], wood[4]); c.put(x0, y + 1, wood[1])   # end grain


def _persimmon(c, x, y):
    D(c, {(x + 1, y): moss[3], (x, y + 1): autumn[5], (x + 1, y + 1): autumn[4], (x + 2, y + 1): autumn[3],
          (x, y + 2): autumn[3], (x + 1, y + 2): autumn[3], (x + 2, y + 2): autumn[2], (x + 1, y + 3): autumn[1]})


def aframe_back(c, x, y, g):
    _pole(c, [(x - 9, y + 17), (x - 11, y - 4)])
    _pole(c, [(x + 8, y + 17), (x + 10, y - 4)])
    for yy in (y + 12, y + 16):
        for xx in range(x - 8, x + 9): c.put(xx, yy, bamboo[4] if xx < x + 5 else bamboo[2])
    for i, ly in enumerate((y + 1, y + 4, y + 7)):
        _logs(c, x - 12 + (i % 2), x + 11 - (i % 2), ly)
    for rx in (x - 5, x + 4):   # rope lashing
        for yy in range(y + 1, y + 10): c.put(rx, yy, strap[3] if yy % 2 else strap[1])
    P(c, [(x + 11, y + 0)], strap[1]); _persimmon(c, x + 11, y + 0)   # persimmon hanging from the right prong


def aframe_side(c, x, y, g):
    _pole(c, [(x - 1, y + 17), (x - 3, y - 9)])
    for yy in (y + 12, y + 16):
        P(c, [(x - 3, yy), (x - 2, yy)], bamboo[3])
    for i, ly in enumerate((y + 1, y + 4, y + 7)):
        e = ellipse(x - 5, ly + 1.5, 2.5, 1.5)
        for q in e: c.put(q[0], q[1], wood[4] if (q[0] + q[1]) % 2 else wood[5])
        P(c, [(x - 5, ly + 1), (x - 5, ly + 2)], wood[2])
    for yy in range(y + 1, y + 10): c.put(x - 2, yy, strap[3] if yy % 2 else strap[1])
    P(c, [(x - 4, y - 8)], strap[1]); _persimmon(c, x - 6, y - 8)


def _basket_weave(c, m):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        col = rattan[4] if (q[0] + q[1]) % 2 else rattan[3]
        if (q[1] - y0) % 4 == 3: col = rattan[2]
        if q[0] > x1 - 2: col = rattan[2] if col != rattan[4] else rattan[3]
        if q[1] == y1: col = rattan[1]
        c.put(q[0], q[1], col)


def _fiddlehead(c, x, y, sgn=1):
    """a curled fern shoot: stem from (x, y) going up/out, curl at the tip."""
    s = sgn
    P(c, [(x, y), (x + s, y - 1), (x + 2 * s, y - 2), (x + 3 * s, y - 3), (x + 3 * s, y - 4)], moss[3])
    D(c, {(x + 4 * s, y - 5): moss[4], (x + 5 * s, y - 5): moss[5], (x + 6 * s, y - 4): moss[4], (x + 5 * s, y - 3): moss[3], (x + 4 * s, y - 4): moss[2]})


def basket_back(c, x, y, g):
    m = poly([(x - 9, y - 2), (x + 9, y - 2), (x + 6, y + 17), (x - 6, y + 17)])
    _basket_weave(c, m)
    form(c, rect(x - 10, y - 3, x + 9, y - 2), rattan, frac=0.3)   # rim
    # fern fronds out of the left, fiddlehead + mushroom on the right
    P(c, [(x - 8, y - 4), (x - 10, y - 5), (x - 12, y - 6), (x - 14, y - 6)], moss[3]); P(c, [(x - 11, y - 7), (x - 13, y - 7), (x - 9, y - 6)], moss[4])
    D(c, {(x + 5, y - 5): felt[4], (x + 6, y - 5): felt[3], (x + 7, y - 5): felt[2], (x + 4, y - 4): felt[3], (x + 5, y - 4): felt[3], (x + 6, y - 4): felt[2],
          (x + 7, y - 4): felt[1], (x + 8, y - 4): felt[1], (x + 6, y - 3): fleece[4]})
    _fiddlehead(c, x + 9, y - 3, 1)


def basket_side(c, x, y, g):
    m = poly([(x - 8, y - 2), (x + 1, y - 2), (x + 1, y + 17), (x - 5, y + 17)])
    _basket_weave(c, m)
    form(c, rect(x - 9, y - 3, x + 1, y - 2), rattan, frac=0.3)
    P(c, [(x - 6, y - 4), (x - 8, y - 6), (x - 9, y - 7), (x - 11, y - 8)], moss[3]); P(c, [(x - 7, y - 6), (x - 10, y - 8), (x - 8, y - 7)], moss[4])
    D(c, {(x - 3, y - 5): felt[4], (x - 2, y - 5): felt[3], (x - 4, y - 4): felt[3], (x - 3, y - 4): felt[3], (x - 2, y - 4): felt[2], (x - 1, y - 4): felt[1],
          (x - 3, y - 3): fleece[4]})
    _fiddlehead(c, x - 5, y - 3, -1)


def _dots(c, m, r, step=4):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        a, b = (q[0] - x0) % step, (q[1] - y0) % step
        row = ((q[1] - y0) // step) % 2
        if b == 1 and a == (1 + 2 * row) % step:
            c.put(q[0], q[1], r[5] if c.get(q) not in (r[2], r[1]) else r[4])
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                p = (q[0] + dx, q[1] + dy)
                if p in m and c.get(p) == r[3]: c.put(p[0], p[1], r[4])


def bundle_back(c, x, y, g):
    y += 3
    m = rect(x - 9, y + 3, x + 8, y + 15) - M({(x - 9, y + 3), (x + 8, y + 3), (x - 9, y + 15), (x + 8, y + 15)})
    form(c, m, plum, frac=0.3)
    _dots(c, m, plum)
    for q in line([(x - 8, y + 15), (x - 1, y + 6)]) | line([(x + 7, y + 15), (x, y + 6)]):   # wrap folds
        if q in m: c.put(q[0], q[1], plum[2])
    ears = line([(x - 2, y + 4), (x - 5, y + 1), (x - 6, y - 1)], 2) | line([(x + 1, y + 4), (x + 4, y + 1), (x + 5, y - 1)], 2)
    form(c, ears, plum, frac=0.4)
    knot = ellipse(x - 0.5, y + 4.5, 2, 1.5)
    form(c, knot, plum, frac=0.4, hi=[(x - 2, y + 4)])
    # plum blossom sprig pushed through the knot
    P(c, [(x + 1, y + 5), (x + 3, y + 4), (x + 5, y + 3), (x + 7, y + 2), (x + 8, y + 1)], wood[1]); P(c, [(x + 2, y + 5), (x + 4, y + 4), (x + 6, y + 3)], wood[2])
    D(c, {(x + 9, y): petal[5], (x + 10, y): petal[4], (x + 9, y + 1): petal[4], (x + 10, y + 1): petal[2], (x + 8, y): petal[3],
          (x + 5, y + 2): petal[5], (x + 6, y + 2): petal[3]})


def bundle_side(c, x, y, g):
    m = rect(x - 8, y + 3, x, y + 16) - M({(x - 8, y + 3), (x - 8, y + 16)})
    form(c, m, plum, frac=0.25)
    _dots(c, m, plum)
    ear = line([(x - 3, y + 4), (x - 5, y + 1), (x - 6, y - 1)], 2)
    form(c, ear, plum, frac=0.4)
    form(c, ellipse(x - 2.5, y + 4.5, 1.5, 1.5), plum, frac=0.4)
    P(c, [(x - 4, y + 5), (x - 6, y + 4), (x - 8, y + 3), (x - 9, y + 2)], wood[1])
    D(c, {(x - 10, y + 1): petal[5], (x - 11, y + 1): petal[4], (x - 10, y + 2): petal[3], (x - 11, y + 2): petal[2], (x - 7, y + 3): petal[5]})


def _gourd(c, x, y):
    D(c, {(x, y): strap[1], (x, y + 1): strap[1], (x, y + 2): gold[4], (x + 1, y + 2): gold[2], (x - 1, y + 3): gold[4], (x, y + 3): gold[5],
          (x + 1, y + 3): gold[3], (x + 2, y + 3): gold[2], (x - 1, y + 4): gold[3], (x, y + 4): gold[3], (x + 1, y + 4): gold[2], (x + 2, y + 4): gold[1],
          (x, y + 5): gold[1], (x + 1, y + 5): gold[1], (x, y + 2 - 0): gold[4]})
    c.put(x, y + 2, gold[3])


def chest_back(c, x, y, g):
    m = rect(x - 7, y - 1, x + 6, y + 16)
    form(c, m, lacq, frac=0.25)
    form(c, rect(x - 8, y - 2, x + 7, y - 1), lacq, frac=0.25)   # lid lip
    for dy in (5, 10):
        for xx in range(x - 6, x + 6): c.put(xx, y + dy, lacq[0])
    for dy in (2, 7, 12):   # drawer pulls
        P(c, [(x - 1, y + dy + 1), (x, y + dy + 1)], brass[4]); c.put(x, y + dy + 2, brass[2]); c.put(x - 1, y + dy + 2, brass[3])
    for cx_, cy_, sx, sy in ((x - 7, y - 2, 1, 1), (x + 6, y - 2, -1, 1), (x - 7, y + 16, 1, -1), (x + 6, y + 16, -1, -1)):   # brass corners
        P(c, [(cx_, cy_), (cx_ + sx, cy_), (cx_, cy_ + sy)], brass[4] if sx > 0 else brass[2])
    tl = g['tail']
    P(c, [(x + 7, y + 1), (x + 8, y + 2)], strap[1])
    _gourd(c, x + 8 + tl, y + 2)   # water gourd swinging from the side


def chest_side(c, x, y, g):
    m = rect(x - 6, y - 1, x, y + 16)
    form(c, m, lacq, frac=0.3)
    form(c, rect(x - 7, y - 2, x + 1, y - 1), lacq, frac=0.25)
    for yy in (y + 4, y + 9, y + 14): c.put(x - 6, yy, lacq[1])
    P(c, [(x - 6, y - 2), (x - 5, y - 2), (x - 6, y + 16), (x - 5, y + 16), (x - 6, y + 15)], brass[4])
    tl = g['tail']
    P(c, [(x - 7, y + 1), (x - 8, y + 2)], strap[1])
    _gourd(c, x - 10 + tl, y + 2)


def _lantern(c, x, y):
    D(c, {(x + 1, y): strap[1], (x + 1, y + 1): strap[1], (x, y + 2): wood[1], (x + 1, y + 2): wood[1], (x + 2, y + 2): wood[1],
          (x, y + 3): ember[4], (x + 1, y + 3): brass[5], (x + 2, y + 3): ember[3], (x, y + 4): autumn[3], (x + 1, y + 4): brass[4], (x + 2, y + 4): ember[2],
          (x, y + 5): ember[3], (x + 1, y + 5): ember[3], (x + 2, y + 5): ember[1], (x + 1, y + 6): wood[1], (x + 1, y + 7): brass[3]})


def satchel_back(c, x, y, g):
    m = rect(x - 8, y + 2, x + 7, y + 15) - M({(x - 8, y + 2), (x + 7, y + 2), (x - 8, y + 15), (x + 7, y + 15)})
    form(c, m, jade, frac=0.25)
    for q in m:   # diamond quilting
        if (q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0:
            c.put(q[0], q[1], jade[2] if c[q] in (jade[3], jade[4]) else jade[1])
    flap = ellipse(x - 0.5, y + 2, 7.5, 6.5).rows(y + 2, y + 9)
    form(c, flap, jade, frac=0.3)
    for q in flap:
        if (q[0] + q[1]) % 4 == 0: c.put(q[0], q[1], jade[3] if c[q] == jade[4] else jade[2])
    for q in flap.bottom(): c.put(q[0], q[1], lining[4] if q[0] < x + 4 else lining[2])
    P(c, [(x - 1, y + 9), (x, y + 9)], wood[4]); P(c, [(x - 1, y + 10), (x, y + 10)], wood[2])   # toggle
    for xx in (x - 6, x + 5): P(c, [(xx, y), (xx, y + 1)], lining[3])
    P(c, [(x + 8, y + 1), (x + 9, y + 1), (x + 10, y + 1), (x + 11, y + 1)], strap[1])
    _lantern(c, x + 11 + g['tail'], y)


def satchel_side(c, x, y, g):
    m = rect(x - 4, y + 2, x, y + 15) - M({(x - 4, y + 2), (x - 4, y + 15)})
    form(c, m, jade, frac=0.3)
    for q in m:
        if (q[0] + q[1]) % 4 == 0: c.put(q[0], q[1], jade[2])
    for yy in range(y + 2, y + 10): c.put(x - 5, yy, jade[4] if yy < y + 9 else lining[4])
    c.put(x - 5, y + 9, wood[4])
    P(c, [(x - 1, y), (x - 1, y + 1)], lining[3])
    _lantern(c, x - 9 + g['tail'], y)


PACK = [
    dict(slug='ea-bamboo-aframe', cat='backpack', back=aframe_back, side=aframe_side),
    dict(slug='ea-forager-basket', cat='backpack', back=basket_back, side=basket_side),
    dict(slug='ea-cloth-bundle', cat='backpack', back=bundle_back, side=bundle_side),
    dict(slug='ea-tea-chest', cat='backpack', back=chest_back, side=chest_side),
    dict(slug='ea-quilted-satchel', cat='backpack', back=satchel_back, side=satchel_side),
]


# ======================================================================== COAT
def _square_sleeves(c, g, r, rows=3, cuff=None):
    """widen the lower sleeve 1 px each side (wide square sleeves); optional cuff ramp on the last row(s)."""
    for s in g['sleeves']:
        x0, y0, x1, y1 = s.bbox()
        for y in range(y1 - rows + 1, y1 + 1):
            xs = [q[0] for q in s if q[1] == y]
            if not xs: continue
            a, z = min(xs), max(xs)
            c.put(a - 1, y, r[4]); c.put(z + 1, y, r[2])
            for x in range(a, z + 1):
                if (x, y) not in c: c.put(x, y, r[3])
        if cuff:
            for x in range(x0 - 1, x1 + 2):
                if (x, y1) in c: c.put(x, y1, cuff[3] if x < x1 else cuff[2])


def _stitch(q, t, g):
    y = q[1] - g['b']
    if y in (51, 55, 59, 63) and (q[0] + y) % 3 != 0 and t < 3: return fleece[3] if t < 2 else fleece[1]
    return None


def _jacket(c, g):
    v, b = g['view'], g['b']
    _square_sleeves(c, g, indigo, 3)
    if v == 'front':
        for y in range(55, 65):   # contrasting collar band down the front
            P(c, [(30, y + b), (35, y + b)], canvas[4] if y % 3 else canvas[3])
            P(c, [(31, y + b)], canvas[2]); P(c, [(32, y + b), (33, y + b), (34, y + b)], indigo[1])
        patch = rect(37, 60 + b, 40, 63 + b)    # mended patch with a stitched cross
    elif v == 'back':
        patch = rect(24, 57 + b, 27, 60 + b)
    else:
        patch = rect(35, 59 + b, 38, 62 + b)
    for q in patch: c.put(q[0], q[1], indigoL[4] if q[1] == patch.bbox()[1] else indigoL[3])
    px, py = patch.bbox()[:2]
    P(c, [(px, py), (px + 1, py + 1), (px + 2, py + 2), (px + 3, py + 3), (px + 3, py), (px + 2, py + 1), (px + 1, py + 2), (px, py + 3)], fleece[5])
    if v == 'back':   # collar band shows at the nape under the scarf edge
        for x in range(26, 40): c.put(x, 50 + b, canvas[3] if x % 4 else canvas[2])


def _channels(q, t, g):
    if (q[1] - g['b']) % 3 == 0: return autumn[2] if t < 2 else autumn[1]
    if (q[1] - g['b']) % 3 == 1 and t < 2: return autumn[4]
    return None


def _vest(c, g):
    v, b = g['view'], g['b']
    if v == 'front':
        for y in range(55, 65): c.put(33, y + b, autumn[1])   # front opening
        for y in (59, 61, 63):   # knotted jade cord buttons
            P(c, [(32, y + b)], jade[4]); P(c, [(33, y + b)], jade[3]); P(c, [(34, y + b)], jade[2])
        P(c, [(34, 64 + b), (34, 65 + b), (35, 66 + b)], jade[3])   # one loose end
    elif v == 'side':
        for y in (57, 59, 61): P(c, [(40, y + b), (41, y + b)], jade[3])
        P(c, [(41, 62 + b), (42, 63 + b)], jade[2])


def _wrap(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    _square_sleeves(c, g, petal, 4, cuff=fleece)
    if v == 'front':   # crossed front edge with the cream collar, below the beard
        for q in line([(28, 55 + b), (35, 62 + b), (35, 66 + b)], 2):
            if q in c: c.put(q[0], q[1], fleece[4] if q[0] < 35 or q[1] < 63 + b else fleece[3])
    if v == 'side':
        for q in line([(36, 55 + b), (39, 60 + b), (39, 66 + b)], 1):
            if q in c: c.put(q[0], q[1], fleece[4])
    # soft jade sash
    for x in range(10, 56):
        for y, col in ((59 + b, jade[4]), (60 + b, jade[2])):
            if (x, y) in c and c[(x, y)] in petal: c.put(x, y, col)
    if v == 'front':
        P(c, [(37, 61 + b), (37, 62 + b), (38, 63 + b)], jade[3])
        D(c, {(23, 63 + b): autumn[4], (24, 63 + b): autumn[5], (25, 63 + b): autumn[3], (26, 62 + b): autumn[2], (26, 64 + b): autumn[2], (24, 64 + b): autumn[2]})   # goldfish
    elif v == 'back':
        D(c, {(39, 63 + b): autumn[4], (40, 63 + b): autumn[5], (41, 63 + b): autumn[3], (42, 62 + b): autumn[2], (42, 64 + b): autumn[2], (40, 64 + b): autumn[2]})
        P(c, [(31, 61 + b), (31, 62 + b), (32, 63 + b)], jade[3])
    else:
        D(c, {(28, 63 + b): autumn[3], (29, 63 + b): autumn[5], (30, 63 + b): autumn[4], (27, 62 + b): autumn[2], (27, 64 + b): autumn[2], (29, 64 + b): autumn[2]})
        P(c, [(25, 61 + b), (24, 62 + b)], jade[3])


def _curl(c, m):
    for q in m:
        c.put(q[0], q[1], fleece[5] if (q[0] + q[1]) % 2 else fleece[4])
        if (q[0] * 2 + q[1]) % 5 == 0: c.put(q[0], q[1], fleece[2])
    for q in m.bottom(): c.put(q[0], q[1], fleece[2] if q[0] % 2 else fleece[3])


def _fleece(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    # cuffs + hem band of curly fleece
    for s in g['sleeves']:
        x0, y0, x1, y1 = s.bbox()
        _curl(c, M(q for q in s if q[1] >= y1 - 2))
    full = c.mask()
    _curl(c, M(q for q in full if (q[0], q[1] + 1) not in full or (q[0], q[1] + 2) not in full).rows(60 + b, 70 + b))
    if v != 'side':
        col = ellipse(32.5, 49 + b, 14.5, 4).rows(46 + b, 53 + b)
        _curl(c, col)
    else:
        _curl(c, ellipse(30, 49 + b, 6, 3).rows(46 + b, 51 + b))
    if v == 'front':   # side fastening + turquoise bead toggle on a leather loop
        for y in range(55, 62): c.put(38, y + b, leather[1])
        D(c, {(39, 57 + b): leather[1], (40, 58 + b): leather[1], (38, 58 + b): turq[4], (39, 58 + b): turq[3], (38, 59 + b): turq[2], (39, 59 + b): turq[1]})
    elif v == 'side':
        D(c, {(40, 56 + b): leather[1], (41, 57 + b): turq[4], (41, 58 + b): turq[2]})


def _weave(q, t, g):
    if q[0] % 2 == 0 and (q[1] - g['b']) % 2 == 0: return ramie[4] if t < 2 else ramie[3]
    return None


def _ramie(c, g):
    v, b = g['view'], g['b']
    # short wide sleeves: drop the lower half of the sleeve (the tunic sleeve shows), widen the new edge
    torso = g['torso']
    for s in g['sleeves']:
        x0, y0, x1, y1 = s.bbox()
        cut = y0 + (y1 - y0) // 2 + (1 if v != 'side' else 0)
        for q in s:
            if q[1] > cut and q not in torso: c.pop(q, None)
        xs = [q[0] for q in s if q[1] == cut]
        if xs:
            for x in range(min(xs) - 1, max(xs) + 2):
                if v != 'side' or x < 34: c.put(x, cut, ramie[4] if x < max(xs) else ramie[2])
    if v == 'front':
        P(c, [(32, 60 + b), (33, 60 + b), (34, 60 + b)], canvas[4]); P(c, [(33, 61 + b), (34, 62 + b)], canvas[3])   # canvas tie
        cic = (18, 48)
    elif v == 'back':
        cic = (45, 48)
    else:
        cic = (27, 50)
    x, y = cic[0], cic[1] + b   # cicada clinging to the shoulder
    D(c, {(x + 1, y): frog[1], (x, y): INK, (x + 2, y): INK, (x + 1, y + 1): frog[2], (x + 1, y + 2): frog[1],
          (x, y + 1): ramie[5], (x + 2, y + 1): ramie[5], (x, y + 2): ramie[4], (x + 2, y + 2): ramie[4], (x + 1, y + 3): frog[0]})


COAT = [
    dict(slug='ea-indigo-jacket', cat='coat', r=indigo, hem=1, pattern=_stitch, detail=_jacket),
    dict(slug='ea-padded-vest', cat='coat', r=autumn, sleeves=False, puff=1, pattern=_channels, detail=_vest),
    dict(slug='ea-spring-wrap', cat='coat', r=petal, hem=2, detail=_wrap),
    dict(slug='ea-fleece-jacket', cat='coat', r=leather, hem=1, detail=_fleece),
    dict(slug='ea-ramie-jacket', cat='coat', r=ramie, pattern=_weave, detail=_ramie),
]


# ======================================================================== CLOAK
def _straw_cape(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        r = (q[1] - y0) % 5
        if r == 4: c.put(q[0], q[1], straw[1] if q[0] % 2 else straw[2])       # tier edge
        elif r == 0: c.put(q[0], q[1], straw[4] if q[0] % 3 else straw[5])     # next tier lit
        elif q[0] % 2 == 0: shift(c, q, straw, -1)
        elif (q[0] + q[1]) % 7 == 0: c.put(q[0], q[1], hemp[4])                 # palm fibre strands
    b = g['b']
    frogd = {(0, 0): frog[5], (2, 0): frog[4], (0, 1): frog[4], (1, 1): frog[4], (2, 1): frog[2], (-1, 2): frog[2], (3, 2): frog[1], (1, 0): frog[3]}
    if v == 'back':
        D(c, {(36 + dx, 56 + b + dy): col for (dx, dy), col in frogd.items()})
        for x in range(27, 38): c.put(x, 50 + b, strap[2] if x % 2 else strap[3])   # neck cord
    elif v == 'side':
        D(c, {(20 + dx, 57 + b + dy): col for (dx, dy), col in frogd.items()})


def _quilt(c, m, r):
    for q in m:
        if ((q[0] + q[1]) % 5 == 0 or (q[0] - q[1]) % 5 == 0) and c.get(q) in r: shift(c, q, r, -1)


def _snowhood(c, g, m, v):
    b = g['b']
    x0, y0, x1, y1 = m.bbox()
    if v != 'front': _quilt(c, m, frost)
    if v == 'back':
        hood = ellipse(32.5, 52 + b, 7, 4.5)
        form(c, hood, frost, frac=0.3)
        for q in hood.inner_edge():
            if q[1] > 49 + b: c.put(q[0], q[1], fleece[5] if (q[0] + q[1]) % 2 else fleece[4])
        for q in ellipse(32.5, 51 + b, 4, 2):
            if q[1] >= 50 + b: c.put(q[0], q[1], frost[1])
        D(c, {(32, 57 + b): brass[5], (31, 57 + b): ember[4], (33, 57 + b): ember[3], (32, 56 + b): ember[4], (32, 58 + b): ember[2]})   # plum blossom pin
    elif v == 'side':
        hood = ellipse(24.5, 50 + b, 3, 4)
        form(c, hood, frost, frac=0.3)
        for q in hood.inner_edge():
            if q[0] >= 25: c.put(q[0], q[1], fleece[5] if q[1] % 2 else fleece[4])
        D(c, {(28, 47 + b): brass[5], (27, 47 + b): ember[4], (29, 47 + b): ember[3], (28, 46 + b): ember[4], (28, 48 + b): ember[2]})   # plum blossom at the throat
    else:
        D(c, {(16, 46 + b): brass[5], (15, 46 + b): ember[4], (17, 46 + b): ember[3], (16, 45 + b): ember[4], (16, 47 + b): ember[2]})


def _maple(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    for q in m:   # autumn -> maple-red gradient down the shawl
        f = (q[1] - y0) / max(1, y1 - y0)
        if f > 0.45 and c.get(q) in autumn:
            c.put(q[0], q[1], ember[max(1, autumn.index(c[q]))])
    if v != 'front':
        for q in m:   # tie-dye rings
            if (q[0] - x0) % 6 == 3 and (q[1] - y0) % 6 == 4 and all((q[0] + dx, q[1] + dy) in m for dx in (-1, 1) for dy in (-1, 1)):
                c.put(q[0], q[1], ember[1])
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)): c.put(q[0] + dx, q[1] + dy, lining[5] if dy <= 0 else lining[4])
        tl = g['tail']
        for q in m.bottom():   # fringe
            if (q[0] + tl) % 2 == 0:
                c.put(q[0], q[1] + 1, lining[4]); c.put(q[0], q[1] + 2, lining[2])
    b = g['b']
    if v == 'back':   # red dragonfly
        D(c, {(28, 54 + b): ember[4], (29, 54 + b): ember[3], (30, 54 + b): ember[2], (31, 54 + b): ember[2], (32, 54 + b): ember[1],
              (29, 53 + b): steel[5], (30, 53 + b): steel[4], (29, 55 + b): steel[5], (30, 55 + b): steel[4]})
    elif v == 'side':
        D(c, {(20, 55 + b): ember[1], (21, 55 + b): ember[2], (22, 55 + b): ember[3], (23, 55 + b): ember[4],
              (21, 54 + b): steel[5], (22, 54 + b): steel[4], (21, 56 + b): steel[5], (22, 56 + b): steel[4]})


def _poncho(c, g, m, v):
    for q in m:   # felt speckle
        h = (q[0] * 7 + q[1] * 13) % 11
        if h == 0: shift(c, q, oat, 1)
        elif h == 5: shift(c, q, oat, -1)
    for q in m:   # running stitch inside the border
        if v != 'front' and (q[0], q[1] + 3) not in m and (q[0], q[1] + 2) in m and q[0] % 3 != 0: c.put(q[0], q[1], fleece[5])
    b = g['b']
    if v == 'back':   # turquoise bead string from the collar tie
        for x in range(28, 37): c.put(x, 50 + b, yarnA[2] if x % 2 else yarnA[3])
        D(c, {(32, 51 + b): strap[1], (32, 52 + b): turq[4], (32, 53 + b): turq[2], (32, 54 + b): yarnA[4], (32, 55 + b): turq[4], (32, 56 + b): turq[2]})
    elif v == 'side':
        D(c, {(27, 50 + b): yarnA[3], (28, 51 + b): turq[4], (28, 52 + b): turq[2], (28, 53 + b): yarnA[4], (28, 54 + b): turq[4]})


def _capelet(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    tl = g['tail']
    for x in range(x0, x1 + 1):   # petal-scalloped hem: rounded 3-px lobes
        ph = (x - x0 + tl) % 4
        col = [q for q in m if q[0] == x]
        if not col: continue
        yb = max(q[1] for q in col)
        if ph == 0:
            c.pop((x, yb), None); c.pop((x, yb - 1), None)
            if (x, yb - 2) in c: c.put(x, yb - 2, petal[2])
        else:
            c.put(x, yb, petal[2] if ph == 2 else petal[1])
            c.put(x, yb - 1, petal[5] if ph == 2 else petal[4])
    b = g['b']
    bird = {(0, 0): moss[4], (1, 0): snow[5], (-1, 1): moss[3], (0, 1): brass[5], (1, 1): moss[3], (2, 1): moss[2], (3, 1): moss[1], (2, 0): moss[3], (-1, 0): wood[1]}
    if v == 'back':   # white-eye on the right shoulder (faces left)
        D(c, {(46 + dx, 46 + b + dy): col for (dx, dy), col in bird.items()})
        P(c, [(31, 50 + b), (31, 51 + b)], jade[3]); c.put(31, 52 + b, brass[4]); P(c, [(34, 50 + b), (34, 51 + b)], jade[2]); c.put(34, 52 + b, brass[3])
    elif v == 'side':   # faces right, on the back of the shoulder
        D(c, {(23 - dx, 45 + b + dy): col for (dx, dy), col in bird.items()})
        P(c, [(28, 48 + b), (28, 49 + b)], jade[3]); c.put(28, 50 + b, brass[4])
    else:
        D(c, {(17 - dx, 45 + b + dy): col for (dx, dy), col in bird.items()})


CLOAK = [
    dict(slug='ea-straw-rain-cape', cat='cloak', r=straw, lining=straw, len=64, flare=4, x0=20, x1=45, hemstyle='points', fx0=14, fx1=51, side_back=18, detail=_straw_cape),
    dict(slug='ea-plum-snow-hood', cat='cloak', r=frost, lining=frost, len=67, flare=3, border=fleece, border_rows=1, fx0=15, fx1=50, side_back=18, detail=_snowhood),
    dict(slug='ea-maple-shawl', cat='cloak', r=autumn, lining=autumn, len=64, flare=3, x0=19, x1=46, hemstyle='tri', fx0=15, fx1=50, detail=_maple),
    dict(slug='ea-felt-poncho', cat='cloak', r=oat, lining=oat, len=63, flare=2, x0=19, x1=46, border=yarnA, border_rows=2, border_sides=True, fx0=14, fx1=51, side_back=19, detail=_poncho),
    dict(slug='ea-blossom-capelet', cat='cloak', r=petal, lining=petal, len=55, flare=3, x0=20, x1=45, fx0=15, fx1=50, side_back=20, detail=_capelet),
]

ITEMS = FOOT + PACK + COAT + CLOAK
