"""The Rainroot Reaches (SA): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/SA/common.lua
(C.R.*) and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light): SA common.lua C.R
latex = ["#5a2e14", "#8a4a1a", "#b8701e", "#d8962e", "#eebd52", "#fbe08a"]
alpaca = ["#6a5444", "#927660", "#b59a7c", "#d2bc98", "#e8d8b6", "#f8eed4"]
indigo = ["#1a1c40", "#262c60", "#323f80", "#4458a0", "#6278be", "#8ea2da"]
straw = ["#5e4018", "#86601e", "#ad8228", "#cca23a", "#e2c25a", "#f4e08e"]
balsa = ["#6a4a30", "#946c46", "#b8905c", "#d4b078", "#e8cc98", "#f6e4bc"]
leafG = ["#173a2a", "#1f5434", "#2a6e3a", "#3c8c40", "#5cac48", "#94cc5e"]
leafY = ["#2a4a1e", "#3e6a24", "#58882c", "#76a636", "#9cc44c", "#cce276"]
gourd = ["#5c3416", "#86501e", "#ae6e26", "#cc8e34", "#e2b04e", "#f2d07a"]
palm = ["#3a4018", "#56601e", "#748228", "#94a034", "#b4bc4c", "#d4d878"]
string = ["#5a4a3c", "#7e6a54", "#a08a6c", "#bca888", "#d6c4a2", "#ece0c2"]
passion = ["#2e1a3a", "#4a2650", "#6a3466", "#8a4a7c", "#a86894", "#c890b0"]
bark = ["#5a3a24", "#7e5634", "#a07448", "#bc925e", "#d4b07c", "#e8cea0"]
cacao = ["#2e1a1a", "#45261e", "#5e3426", "#7a4630", "#985c3c", "#b8784c"]
mist = ["#4a4058", "#6a5e7c", "#8a80a0", "#a8a0bc", "#c6c0d6", "#e2def0"]
pink = ["#6a1a3a", "#9a2a52", "#c8406a", "#e06486", "#f08ea6", "#fcc0cc"]
turq = ["#14484a", "#1e6a66", "#2a8c80", "#3cae98", "#66ccb0", "#a4e8cc"]
frog = ["#1b4a2a", "#24702e", "#38962e", "#5cba34", "#8ed448", "#c4ec7a"]
# gnome-wear/_gw.lua W.R
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
felt = ["#3a2026", "#552f2c", "#704033", "#8a5239", "#a66a45", "#c48a5a"]
ember = ["#5e1c33", "#8a2a3d", "#b52e3f", "#d23c3c", "#e8573f", "#ff8a5c"]
jay = ["#1e2f63", "#28488e", "#3364b4", "#4688d2", "#6cb0e6", "#bfe6f6"]
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
canvas = ["#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
yarnA = ["#5c1f2e", "#842a36", "#a8383a", "#c64e40", "#dc6a4a", "#f08e62"]
lav = ["#35295f", "#5a459e", "#8a6fd0", "#b69ae8", "#d6c4f6", "#efe4ff"]
autumn = ["#6e2a1c", "#a8401e", "#d8602a", "#ee8434", "#f8a848", "#ffd27a"]

WEAVE = [yarnA, straw, indigo, alpaca]   # highland warp-stripe order


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def recol(c, m, r, by):
    """repaint already-formed pixels of m with ramp by(q) keeping their tone index in r."""
    for q in m:
        col = c.get(q)
        if col in r: c.put(q[0], q[1], by(q)[r.index(col)])


# ======================================================================== FOOTWEAR
def _latex(c, g, ft, k):
    v, top, x0, x1, cy, cx = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy']), int(ft['cx'])
    # dipped rim: pale drip tongues running down from the cuff
    for x in range(x0, x1 + 1):
        c.put(x, top, latex[5] if x % 2 else latex[4])
        if x % 3 == 0: c.put(x, top + 1, latex[4]); c.put(x, top + 2, latex[3])
    # glossy drip lumps on the toe
    if v != 'back':
        tx = cx + 2 if v == 'side' else cx - 1
        P(c, [(tx, cy + 1), (tx + 2, cy + 1)], latex[1]); P(c, [(tx, cy), (tx + 2, cy)], latex[5])
    else:
        c.put(cx, cy - 1, latex[5])
    # tree frog on the near/right toe
    near = (v == 'side' and ft['side'] == 'near') or (v == 'front' and ft['side'] == 'R')
    if near:
        fx = cx + 2 if v == 'side' else cx - 1
        fy = cy - 1
        P(c, [(fx, fy), (fx + 1, fy), (fx - 1, fy + 1), (fx + 2, fy + 1)], frog[3])
        P(c, [(fx, fy + 1), (fx + 1, fy + 1)], frog[4]); c.put(fx + 1, fy - 1, frog[5]); c.put(fx, fy - 1, INK)


def _booties(c, g, ft, k):
    v, top, x0, x1 = g['view'], g['top'], g['sx0'], g['sx1']
    # knitted cuff: red / indigo / red stripes, ribbed
    for x in range(x0, x1 + 1):
        c.put(x, top, yarnA[4] if x % 2 else yarnA[3])
        c.put(x, top + 1, indigo[4] if x % 2 else indigo[3])
        c.put(x, top + 2, yarnA[3] if x % 2 else yarnA[2])
    # felted speckle
    for q in g['foot']:
        if (q[0] * 5 + q[1] * 3) % 7 == 0 and c.get(q) in alpaca[2:5]: c.put(q[0], q[1], alpaca[5])
    # two pom-pom ties on the outer side
    if v == 'side':
        if ft['side'] == 'near':
            px = x1 + 1
            P(c, [(px, top + 1), (px + 1, top + 2)], strap[2])
            P(c, [(px + 1, top + 3), (px + 2, top + 3), (px + 1, top + 4), (px + 2, top + 4)], yarnA[3]); c.put(px + 1, top + 3, yarnA[5])
    else:
        out = x0 - 1 if ft['side'] == 'L' else x1 + 1
        d = -1 if ft['side'] == 'L' else 1
        c.put(out, top + 1, strap[2])
        for i, oy in enumerate((2, 4)):
            ox = out + d * i
            P(c, [(ox, top + oy), (ox + d, top + oy), (ox, top + oy + 1), (ox + d, top + oy + 1)], yarnA[3]); c.put(min(ox, ox + d), top + oy, yarnA[5])


def _sandals(c, g, ft, k):
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # thick plaited sole: the last 2 rows + one row of overhang, herringbone
    sol = M(q for q in foot if q[1] >= y1 - 1) | M((x, y1 + 1) for x in range(x0 + 1, x1))
    for q in foot - sol:   # the foot-bed above the sole sits in shade, so the thongs and sole edge read
        if c.get(q) != INK: c.put(q[0], q[1], sole[3] if q[0] > (x0 + x1) / 2 + 1 else sole[4])
    for q in sol: c.put(q[0], q[1], straw[4] if (q[0] + q[1]) % 3 == 0 else (straw[3] if (q[0] + q[1]) % 3 == 1 else straw[2]))
    for x in range(x0 + 1, x1): c.put(x, y1 + 1, straw[1])
    # crossing leather thongs over the top of the foot
    if v == 'side':
        for i in range(5):
            c.put(x1 - 1 - i, y1 - 2 - i // 2, leather[4]); c.put(x0 + 2 + i, y1 - 2 - i // 2, leather[3])
        P(c, [(x0 + 1, y0 + 1), (x0 + 1, y0 + 2), (x0, y0 + 1)], leather[3])          # heel strap
        if ft['side'] == 'near': c.put(x1 - 2, y1 - 3, turq[4]); c.put(x1 - 2, y1 - 2, turq[2])
    else:
        mx = int(round(cx))
        for i in range(-3, 4):   # X of thongs over the instep
            c.put(mx + i, y1 - 2 - (3 - abs(i)) // 2, leather[4] if i < 1 else leather[3])
            c.put(mx + i, y0 + 1 + (3 - abs(i)) // 2 if v == 'front' else y0 + 1, leather[3] if i < 1 else leather[2])
        if v == 'front' and ft['side'] == 'R': c.put(mx, y1 - 3, turq[4]); c.put(mx + 1, y1 - 3, turq[2])


def _balsa(c, g, ft, k):
    v, cx, cy = g['view'], ft['cx'], int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # wood grain
    for q in foot:
        if q[1] == cy and q[0] % 3 == 0 and c.get(q) not in (INK,): c.put(q[0], q[1], balsa[2])
    if v == 'back':   # open heel: dark foot-bed showing above the heel
        for x in range(x0 + 2, x1 - 1): c.put(x, y0, bark[1]); c.put(x, y0 + 1, bark[2])
        return
    if v == 'side':
        vamp = poly([(cx - 1, y0 - 1), (x1 + 0.5, cy - 0.5), (x1 + 1, cy + 1), (cx - 1, cy + 1)])
    else:
        vamp = poly([(x0 + 2, y0), (x1 - 1, y0), (x1 - 2, cy + 1), (x0 + 3, cy + 1)])
    form(c, vamp, leafG, frac=0.35)
    vx0, vy0, vx1, vy1 = vamp.bbox()
    if v == 'side':
        for i in range(vx1 - vx0): c.put(vx0 + i, vy0 + 1 + i // 2, leafG[5])
    else:
        mx = (vx0 + vx1) // 2
        for y in range(vy0, vy1 + 1): c.put(mx, y, leafG[5])
    near = (v == 'side' and ft['side'] == 'near') or (v == 'front' and ft['side'] == 'R')
    if near:   # bromeliad tucked under the vamp
        bx, by = (vx0, vy0 - 1) if v == 'side' else (vx1 - 1, vy0 - 1)
        P(c, [(bx, by), (bx + 1, by - 1), (bx - 1, by - 1)], pink[3]); c.put(bx, by - 1, pink[5]); c.put(bx, by - 2, pink[4])


def _wraps(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    cols = [yarnA, straw, indigo, yarnA, alpaca, indigo]
    for y in range(top, cy - 2):
        for x in range(x0, x1 + 1):
            band = (y - top + (x - x0) // 3) // 2   # diagonal winding
            r = cols[band % len(cols)]
            t = 4 if x == x0 else (2 if x >= x1 - 1 else 3)
            c.put(x, y, r[t])
    # cord tie at the top + at the ankle
    for x in range(x0, x1 + 1):
        c.put(x, top, canvas[4] if x % 2 else canvas[2])
        c.put(x, cy - 3, canvas[3] if x % 2 else canvas[1])
    # tassel from the top tie
    if v == 'side':
        if ft['side'] == 'near': P(c, [(x1 + 1, top + 1), (x1 + 1, top + 2)], canvas[3]); P(c, [(x1 + 1, top + 3), (x1 + 2, top + 3)], yarnA[4]); c.put(x1 + 1, top + 4, yarnA[2])
    else:
        tx = x0 - 1 if ft['side'] == 'L' else x1 + 1
        P(c, [(tx, top + 1), (tx, top + 2)], canvas[3]); P(c, [(tx, top + 3), (tx, top + 4)], yarnA[4]); c.put(tx, top + 5, yarnA[2])


FOOT = [
    dict(slug='sa-latex-puddle-boots', cat='footwear', shell=latex, upper=latex, sole=sole[1], rim=62, half=4, toe=1, detail=_latex),
    dict(slug='sa-puna-wool-booties', cat='footwear', shell=alpaca, upper=alpaca, sole=alpaca[0], rim=62, half=4, puff=1, detail=_booties),
    dict(slug='sa-plaited-fibre-sandals', cat='footwear', shell=straw, upper=straw, sole=straw[1], rim=None, toe=1, detail=_sandals),
    dict(slug='sa-balsa-bark-clogs', cat='footwear', shell=balsa, upper=balsa, sole=bark[1], rim=None, puff=0.5, toe=1, detail=_balsa),
    dict(slug='sa-striped-leg-wraps', cat='footwear', shell=leather, upper=yarnA, sole=sole[1], rim=59, half=3, toe=1, detail=_wraps),
]


# ======================================================================== BACKPACK
def _stripes(c, m, rows):
    """horizontal stripes, each ramp kept in its formed tone"""
    tmp = C(); form(tmp, m, alpaca, frac=0.3, hi=None)
    for q, col in tmp.items():
        r = rows(q)
        c.put(q[0], q[1], r[alpaca.index(col)])


def bundle_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 9, 9, 7)
    _stripes(c, m, lambda q: WEAVE[((q[1] - y) // 2) % 4])
    # knot + two knotted ears
    for s in (-1, 1):
        ear = line([(x + s * 1, y + 2), (x + s * 7, y - 2)], 2)
        form(c, ear, yarnA, frac=0.3)
        P(c, [(x + s * 8, y - 2), (x + s * 8, y - 1)], yarnA[1])
    form(c, ellipse(x - 0.5, y + 2, 2, 1.5), yarnA, frac=0.3, hi=[(x - 1, y + 1)])
    # quinoa seed-head out of the knot
    P(c, [(x, y), (x, y - 1), (x, y - 2)], leafY[2])
    P(c, [(x, y - 3), (x - 1, y - 4), (x, y - 5), (x + 1, y - 4), (x, y - 6)], autumn[3]); P(c, [(x, y - 4), (x - 1, y - 5)], autumn[5])


def bundle_side(c, x, y, g):
    m = ellipse(x - 4, y + 9, 4.5, 7)
    _stripes(c, m, lambda q: WEAVE[((q[1] - y) // 2) % 4])
    ear = line([(x - 3, y + 2), (x - 7, y - 3)], 2); form(c, ear, yarnA, frac=0.3)
    form(c, ellipse(x - 3, y + 2, 1.5, 1.5), yarnA, frac=0.3)
    P(c, [(x - 2, y), (x - 2, y - 1), (x - 2, y - 2)], leafY[2])
    P(c, [(x - 2, y - 3), (x - 3, y - 4), (x - 2, y - 5), (x - 1, y - 4), (x - 2, y - 6)], autumn[3]); c.put(x - 2, y - 4, autumn[5])


def _plait(c, m, r):
    for q in m:
        a = ((q[0] + q[1]) // 2) % 2 if (q[1] // 2) % 2 else ((q[0] - q[1]) // 2) % 2
        if c.get(q) in (r[3], r[4]): c.put(q[0], q[1], r[4] if a else r[3])


def cone_back(c, x, y, g):
    m = poly([(x - 9, y), (x + 9, y), (x + 3, y + 17), (x - 3, y + 17)])
    form(c, m, straw, frac=0.3); _plait(c, m, straw)
    for xx in range(x - 9, x + 9): c.put(xx, y, straw[5] if xx % 2 else straw[4]); c.put(xx, y + 1, straw[2])
    # cacao pod + leaf peeking over the rim
    pod = ellipse(x + 2, y - 2, 2, 2.5)
    form(c, pod, autumn, frac=0.4, under=False)
    for yy in range(y - 4, y): c.put(x + 2, yy, autumn[1])
    P(c, [(x - 2, y - 1), (x - 3, y - 2), (x - 4, y - 3)], leafG[3]); P(c, [(x - 3, y - 1), (x - 4, y - 2)], leafG[5])
    # tumpline rising from both rim ends towards the forehead
    for s, x0 in ((-1, x - 9), (1, x + 8)):
        P(c, [(x0, y - 1), (x0 - s, y - 2), (x0 - 2 * s, y - 3)], strap[2])


def cone_side(c, x, y, g):
    m = poly([(x - 9, y), (x, y), (x - 2, y + 17), (x - 6, y + 17)])
    form(c, m, straw, frac=0.25); _plait(c, m, straw)
    for xx in range(x - 9, x): c.put(xx, y, straw[5] if xx % 2 else straw[4]); c.put(xx, y + 1, straw[2])
    form(c, ellipse(x - 5, y - 2, 2, 2.5), autumn, frac=0.4, under=False)
    P(c, [(x - 8, y - 1), (x - 9, y - 2)], leafG[4])
    P(c, [(x, y - 1), (x + 1, y - 2), (x + 2, y - 3), (x + 3, y - 4)], strap[2])   # tumpline forward over the head


def frame_back(c, x, y, g):
    for px in (x - 7, x + 6):
        form(c, rect(px, y - 5, px + 1, y + 17), wood, frac=0.5)
    for ry in (y - 2, y + 5, y + 13):
        form(c, rect(x - 6, ry, x + 5, ry), wood, frac=0.2, rim=False)
        for px in (x - 7, x + 6): P(c, [(px, ry - 1), (px + 1, ry + 1)], canvas[4]); P(c, [(px + 1, ry - 1), (px, ry + 1)], canvas[2])
    # gourd tied on
    gd = ellipse(x - 0.5, y + 3, 2, 2) | ellipse(x - 0.5, y + 9, 4, 3.5)
    form(c, gd, gourd, frac=0.35, hi=[(x - 3, y + 7), (x - 2, y + 2)])
    P(c, [(x - 1, y), (x, y)], wood[2])
    for xx in range(x - 4, x + 4): c.put(xx, y + 6, canvas[3] if xx % 2 else canvas[1])
    # yellow flower in the top-left lashing
    fx, fy = x - 8, y - 3
    P(c, [(fx, fy), (fx - 1, fy + 1), (fx + 1, fy + 1), (fx, fy + 2)], brass[4]); c.put(fx, fy + 1, autumn[2])


def frame_side(c, x, y, g):
    form(c, rect(x - 1, y - 5, x, y + 17), wood, frac=0.5)
    for ry in (y - 2, y + 5, y + 13): form(c, rect(x - 3, ry, x - 2, ry), wood, frac=0.2, rim=False)
    gd = ellipse(x - 5, y + 3, 1.5, 2) | ellipse(x - 5.5, y + 9, 3, 3.5)
    form(c, gd, gourd, frac=0.35, hi=[(x - 7, y + 7)])
    for xx in range(x - 9, x - 1): c.put(xx, y + 6, canvas[3] if xx % 2 else canvas[1])
    fx, fy = x - 2, y - 4
    P(c, [(fx, fy), (fx - 1, fy + 1), (fx + 1, fy + 1)], brass[4]); c.put(fx, fy + 1, autumn[2])


def satchel_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 9, 8.5, 6.5) | rect(x - 8, y + 4, x + 7, y + 11)
    form(c, m, palm, frac=0.3)
    for q in m:   # chevron palm weave
        if c.get(q) == palm[3] and (q[0] + abs((q[1] % 4) - 2)) % 3 == 0: c.put(q[0], q[1], palm[4])
    # strap loop over the top
    for q in line([(x - 6, y + 3), (x - 6, y), (x - 4, y - 2), (x + 3, y - 2), (x + 5, y), (x + 5, y + 3)], 1): c.put(q[0], q[1], strap[2])
    # big leaf flap with midrib
    leaf = poly([(x - 6, y + 2), (x + 5, y + 2), (x + 4, y + 7), (x - 0.5, y + 12), (x - 5, y + 7)])
    form(c, leaf, leafG, frac=0.35)
    for yy in range(y + 3, y + 12): c.put(x, yy, leafG[5] if yy < y + 8 else leafG[4])
    for i in (1, 3): P(c, [(x - i, y + 4 + i), (x + i, y + 4 + i)], leafG[2])
    # leaf-cutter ant with a pink petal scrap, lower right on the weave
    ax, ay = x + 4, y + 12
    P(c, [(ax, ay), (ax + 1, ay), (ax + 2, ay)], INK); c.put(ax + 1, ay - 1, pink[4]); c.put(ax + 2, ay - 2, pink[3]); c.put(ax + 1, ay - 2, pink[5])


def satchel_side(c, x, y, g):
    m = ellipse(x - 4, y + 9, 4, 6.5)
    form(c, m, palm, frac=0.3)
    for q in m:
        if c.get(q) == palm[3] and (q[0] + abs((q[1] % 4) - 2)) % 3 == 0: c.put(q[0], q[1], palm[4])
    leaf = poly([(x - 8, y + 2), (x - 3, y + 2), (x - 3, y + 9), (x - 8, y + 6)])
    form(c, leaf, leafG, frac=0.3)
    for i in range(5): c.put(x - 8 + i, y + 3 + i // 2, leafG[5])
    P(c, [(x - 2, y + 2), (x - 1, y), (x, y - 1)], strap[2])
    ax, ay = x - 6, y + 13
    P(c, [(ax, ay), (ax + 1, ay), (ax + 2, ay)], INK); c.put(ax + 1, ay - 1, pink[4]); c.put(ax, ay - 2, pink[3])


def _fruit(c, cx, cy, r, rad):
    form(c, ellipse(cx, cy, rad, rad), r, frac=0.4, hi=[(int(cx) - 1, int(cy) - 1)])


def _net(c, m, keep=()):
    for q in m:
        if q in keep: continue
        a, b = (q[0] + q[1]) % 4 == 0, (q[0] - q[1]) % 4 == 0
        if a and b: c.put(q[0], q[1], string[5])          # knots
        elif a or b: c.put(q[0], q[1], string[3] if q[0] < 34 else string[2])


def net_back(c, x, y, g):
    cy = y + 9
    # single shoulder cord, over the right shoulder
    for q in line([(x - 1, y + 2), (x + 3, y - 1), (x + 8, y - 2)], 1): c.put(q[0], q[1], string[3])
    _fruit(c, x - 4, cy + 2, autumn, 3.5)
    _fruit(c, x + 3, cy + 3, passion, 3.5)
    _fruit(c, x - 1, cy - 3, gourd, 3)
    _fruit(c, x + 4, cy - 3, passion, 2.5)
    m = c.mask() - M(q for q in c if q[1] < y + 2)
    # the split passionfruit (seeds) stays clear of the net
    seed = ellipse(x + 3, cy + 3, 1.5, 1.5)
    _net(c, m, keep=seed)
    for q in seed: c.put(q[0], q[1], brass[4] if (q[0] + q[1]) % 2 else brass[3])
    c.put(x + 3, cy + 3, INK); c.put(x + 2, cy + 4, INK)
    form(c, rect(x - 2, y + 2, x, y + 3), string, frac=0.3)   # gathered neck


def net_side(c, x, y, g):
    cy = y + 9
    for q in line([(x - 4, y + 2), (x - 2, y - 1), (x + 1, y - 3)], 1): c.put(q[0], q[1], string[3])
    _fruit(c, x - 5, cy + 3, autumn, 3)
    _fruit(c, x - 3, cy - 2, passion, 3)
    m = c.mask() - M(q for q in c if q[1] < y + 2)
    seed = ellipse(x - 3, cy - 2, 1.5, 1.5)
    _net(c, m, keep=seed)
    for q in seed: c.put(q[0], q[1], brass[4] if (q[0] + q[1]) % 2 else brass[3])
    c.put(x - 3, cy - 2, INK)
    form(c, rect(x - 5, y + 2, x - 3, y + 3), string, frac=0.3)


PACK = [
    dict(slug='sa-striped-bundle-cloth', cat='backpack', y0=50, back=bundle_back, side=bundle_side),
    dict(slug='sa-cone-vine-basket', cat='backpack', back=cone_back, side=cone_side),
    dict(slug='sa-highland-carry-frame', cat='backpack', back=frame_back, side=frame_side),
    dict(slug='sa-leaf-flap-satchel', cat='backpack', back=satchel_back, side=satchel_side),
    dict(slug='sa-market-net-bag', cat='backpack', back=net_back, side=net_side),
]


# ======================================================================== COAT
def _in_sleeve(q, g):
    if g['view'] == 'side': return q in g['sleeves'][0]
    return any(q in s for s in g['sleeves']) and (q[0] <= 22 or q[0] >= 43)


def _fleece(q, t, g):
    # curls: a lit pixel with its shade under-right, on a scattered grid
    x, y = q[0], q[1] - g['b']
    cx, cy = x - (y // 2 % 2) * 1, y
    if cx % 3 == 0 and cy % 2 == 0: return alpaca[min(5, 5 - t)]
    if cx % 3 == 1 and cy % 2 == 1 and t < 3: return alpaca[max(1, 2 - t // 2)]
    return None


def _fleece_d(c, g):
    v, b = g['view'], g['b']
    # stitched felt edge along the hem
    for q in list(c.keys()):
        if (q[0], q[1] + 1) not in c and q[1] > 60 + b: c.put(q[0], q[1], felt[3] if q[0] % 2 else felt[1])
    if v == 'front':
        form(c, rect(31, 60 + b, 34, 60 + b), wood, frac=0.3, rim=False)       # wooden toggle
        P(c, [(32, 59 + b), (32, 61 + b)], felt[2])
    tuft = {'front': [(46, 48), (46, 47), (47, 46), (45, 47)], 'back': [(19, 48), (19, 47), (18, 46), (20, 47)], 'side': [(22, 48), (22, 47), (21, 46), (23, 48)]}[v]
    for i, (x, y) in enumerate(tuft): c.put(x, y + b, alpaca[5] if i else alpaca[4])


def _shingle(q, t, g):
    y = q[1] - g['b']
    row = (y - 46) // 3
    ph = (y - 46) % 3
    r = leafY if row % 2 else leafG
    off = 0 if row % 2 else 2
    i = max(1, min(5, 4 - t))
    if ph == 2: return r[1] if (q[0] + off) % 4 != 0 else r[i]
    if ph == 0: return r[min(5, i + 1)] if (q[0] + off) % 4 == 1 else r[i]
    return r[i]


def _smock(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    # rain drop running off the bottom shingle
    x = {'front': 38, 'back': 27, 'side': 37}[v] + hs
    c.put(x, 64 + b, jay[5]); c.put(x, 65 + b, jay[4])
    if g['f'] % 2 == 0: c.put(x, 67 + b, jay[4])
    # leaf-tip points along the hem
    for q in list(c.keys()):
        if (q[0], q[1] + 1) not in c and q[1] >= 65 + b and q[0] % 4 == 1: c.put(q[0], q[1] + 1, leafG[1])


def _warp(q, t, g):
    i = max(1, min(5, 4 - t))
    if _in_sleeve(q, g):
        sl = next(s for s in g['sleeves'] if q in s)
        y1 = sl.bbox()[3]
        if q[1] >= y1 - 1: return indigo[max(1, i - 1)]     # turned indigo cuff
        return WEAVE[(q[1] // 2) % 4][i]
    return WEAVE[(q[0] // 2) % 4][i]


def _patch(c, x, y):
    form(c, rect(x, y, x + 2, y + 2), alpaca, frac=0.3, rim=False)
    c.put(x + 1, y + 1, yarnA[4]); P(c, [(x + 1, y), (x, y + 1), (x + 2, y + 1), (x + 1, y + 2)], pink[4])


def _jacket(c, g):
    v, b = g['view'], g['b']
    if v == 'front': _patch(c, 25, 59 + b)
    elif v == 'side': _patch(c, 30, 51 + b + g['p']['arm'] // 2)
    else:
        for x in range(21, 45): c.put(x, 63 + b, indigo[2])   # woven hem band


def _dots(q, t, g):
    y = q[1] - g['b']
    if (q[0] % 4, y % 4) in ((1, 1), (3, 3)): return felt[3] if t < 2 else felt[2]
    if (q[0] % 4, y % 4) in ((2, 1), (1, 2)) and (q[0] // 4 + y // 4) % 2: return felt[4] if t < 2 else felt[3]
    return None


def _barkcoat(c, g):
    v, b = g['view'], g['b']
    # belt
    for x in range(19, 47):
        if (x, 59 + b) in c: c.put(x, 59 + b, strap[2] if x < 40 else strap[1])
    if v == 'front': form(c, rect(31, 58 + b, 33, 60 + b), strap, frac=0.3)
    # wide sleeve mouths
    for s in g['sleeves']:
        x0, y0, x1, y1 = s.bbox()
        if v == 'side':
            P(c, [(x0 - 1, y1), (x1 + 1, y1)], bark[2])
        else:
            P(c, [(x0 - 1, y1 - 1), (x0 - 1, y1), (x1 + 1, y1 - 1), (x1 + 1, y1)], bark[3])
    # morpho butterfly on the shoulder
    bx, by = {'front': (47, 48), 'back': (18, 48), 'side': (20, 48)}[v]
    by += b
    wings = [(bx - 1, by), (bx - 1, by + 1), (bx + 1, by), (bx + 1, by + 1), (bx - 2, by - 1), (bx + 2, by - 1)]
    P(c, wings, jay[4]); P(c, [(bx - 2, by - 1), (bx + 2, by - 1)], jay[5]); P(c, [(bx - 1, by + 1), (bx + 1, by + 1)], jay[2])
    P(c, [(bx, by), (bx, by + 1)], INK)


def _baffle(q, t, g):
    y = q[1] - g['b']
    if _in_sleeve(q, g):
        if q[1] % 3 == 0: return cacao[1]
    elif (y - 47) % 4 == 0: return cacao[1] if t < 2 else cacao[0]
    elif (y - 47) % 4 == 1 and t < 2: return cacao[5]
    return None


def _puffer(c, g):
    v, b = g['view'], g['b']
    # alpaca collar where it clears the beard/scarf: shoulder tops
    col = {'front': [(45, 47), (46, 47), (45, 46)], 'back': [(18, 48), (19, 48), (20, 47), (44, 47), (45, 48), (46, 48)], 'side': [(21, 47), (22, 47), (22, 46), (23, 46), (21, 48)]}[v]
    for x, y in col: c.put(x, y + b, alpaca[4] if (x + y) % 2 else alpaca[3])
    # kapok fluff escaping a seam on the sleeve
    s = g['sleeves'][-1 if v == 'back' else 0]
    x0, y0, x1, y1 = s.bbox()
    fx, fy = {'front': (x0 - 1, y0 + 4), 'back': (x1 + 2, y0 + 4), 'side': (x0 - 1, y0 + 5)}[v]
    P(c, [(fx, fy), (fx - 1, fy), (fx, fy - 1), (fx - 1, fy + 1)], mist[5]); c.put(fx - 1, fy, alpaca[5])
    if v == 'front':
        for y in (59, 62): P(c, [(32, y + b), (33, y + b)], cacao[0])   # snap buttons below the beard


COAT = [
    dict(slug='sa-fleece-vest', cat='coat', r=alpaca, sleeves=False, puff=1, pattern=_fleece, detail=_fleece_d),
    dict(slug='sa-shingle-leaf-smock', cat='coat', r=leafG, hem=1, pattern=_shingle, detail=_smock),
    dict(slug='sa-warp-stripe-jacket', cat='coat', r=yarnA, pattern=_warp, detail=_jacket),
    dict(slug='sa-bark-cloth-tunic-coat', cat='coat', r=bark, hem=3, pattern=_dots, detail=_barkcoat),
    dict(slug='sa-kapok-puffer', cat='coat', r=cacao, puff=1, hem=1, pattern=_baffle, detail=_puffer),
]


# ======================================================================== CLOAK
def _depth(m, q, n=12):
    k = 0
    while k < n and (q[0], q[1] + k + 1) in m: k += 1
    return k


def _poncho(c, g, m, v):
    if v == 'front': return
    tmp = C(); form(tmp, m, alpaca, frac=0.35 if v == 'back' else 0.2)
    for q in m:   # chevron stripes following the hem edges
        col = tmp.get(q)
        if col not in alpaca: continue
        d = _depth(m, q)
        r = WEAVE[(d // 2) % 4] if d < 10 else yarnA
        c.put(q[0], q[1], r[alpaca.index(col)])
    # knotted fringe
    for q in m.bottom():
        if q[0] % 2 == 0: c.put(q[0], q[1] + 1, straw[3])
    bot = max(m, key=lambda q: (q[1], -abs(q[0] - 32)))
    bx, by = bot
    for yy in range(by + 1, by + 4): c.put(bx, yy, yarnA[2])   # the long tassel on the point
    P(c, [(bx, by + 4), (bx - 1, by + 4), (bx + 1, by + 4), (bx, by + 5)], yarnA[3]); c.put(bx, by + 4, yarnA[5])


def _thatch(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    if v == 'front':
        for q in m:
            if q[1] % 2 == 0 and c.get(q) not in (None,): c.put(q[0], q[1], straw[1])
        return
    h = y1 - y0 + 1
    tiers = [y0 + h // 3, y0 + 2 * h // 3, y1]
    tmp = C(); form(tmp, m, straw, frac=0.35 if v == 'back' else 0.2)
    for q in m:
        col = tmp.get(q)
        tier = 0 if q[1] <= tiers[0] else (1 if q[1] <= tiers[1] else 2)
        r = palm if tier == 1 else straw
        i = straw.index(col) if col in straw else 3
        # fringe streaks
        if (q[0] + tier) % 2 == 0: i = max(1, i - 1)
        if q[1] in (tiers[0], tiers[1]) and q[0] % 2: i = 1
        if q[1] in (tiers[0] - 1, tiers[1] - 1) and q[0] % 2 == 0: i = 1
        c.put(q[0], q[1], r[i])
    for q in m.bottom():   # shaggy hem
        if q[0] % 2: c.pop(q, None)
    # neck tie
    b = g['b']
    if v == 'back':
        for x in range(28, 37): c.put(x, 46 + b, strap[2])
        bird = [(44, 44, frog[3]), (45, 44, frog[4]), (45, 43, frog[4]), (46, 44, INK), (46, 45, pink[3]), (43, 44, frog[1]), (42, 45, frog[1]), (44, 45, frog[2]), (47, 45, canvas[1])]
    else:
        bird = [(24, 43, frog[3]), (23, 43, frog[4]), (23, 42, frog[4]), (22, 43, INK), (22, 44, pink[3]), (25, 43, frog[1]), (26, 44, frog[1]), (24, 44, frog[2]), (21, 44, canvas[1])]
    flap = g['f'] % 2   # hovering: wings flick
    for x, y, col in bird:
        c.put(x, y + b - flap, col)


def _feathers(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    if v == 'front':
        for q in m:
            d = _depth(m, q)
            c.put(q[0], q[1], (ember if d < 2 else brass if d < 4 else jay)[2 if (q[0] + q[1]) % 2 else 3])
        return
    tmp = C(); form(tmp, m, alpaca, frac=0.35 if v == 'back' else 0.2)
    for q in m:
        col = tmp.get(q)
        d = _depth(m, q)
        r = ember if d < 3 else (brass if d < 5 else (jay if d < 7 else felt))
        i = alpaca.index(col) if col in alpaca else 3
        if (q[0] + (d // 3)) % 3 == 0 and d < 7: i = max(1, i - 1)   # feather shafts
        c.put(q[0], q[1], r[i])
    for q in m.top(): c.put(q[0], q[1], felt[3])   # felt collar edge
    # one loose blue feather drifting off the hem, sways with the cloth
    tl = g['tail']
    if v == 'back': fx, fy = x1 - 1 + tl, y1 + 3
    else: fx, fy = x0 - 2 + tl, y1 + 2
    P(c, [(fx, fy), (fx + 1, fy + 1)], jay[4]); c.put(fx + 2, fy + 2, jay[2]); c.put(fx - 1, fy - 1, jay[5])


def _shawl(c, g, m, v):
    b, tl = g['b'], g['tail']
    if v == 'front':
        return
    c.clear()
    if v == 'back':
        band = ellipse(32.5, 47 + b, 11.5, 3).rows(45 + b, 51 + b) - ellipse(32.5, 45 + b, 7, 2)
        ends = [rect(23, 49 + b, 27, 63 + b), rect(37, 49 + b, 41, 63 + b)]
    else:
        band = ellipse(28, 48 + b, 4, 3)
        ends = [rect(22, 49 + b, 26, 63 + b)]
    form(c, band, mist, frac=0.3)
    for i, e in enumerate(ends):
        e = M((x + (tl if y > 55 + b else 0), y) for x, y in e)
        form(c, e, mist, frac=0.4)
        x0, y0, x1, y1 = e.bbox()
        for y in range(y0 + 2, y1, 3): c.put(x0 + 1, y, mist[5])        # soft weave flecks
        for x in range(x0, x1 + 1):                                      # knotted fringe
            c.put(x, y1 + 1, lav[2] if x % 2 else lav[1])
            if x % 2 == 0: c.put(x, y1 + 2, lav[3])
        if i == 0:   # pink orchid pinned on the left end
            ox, oy = x0 + 2, y0 + 5
            P(c, [(ox - 1, oy), (ox + 1, oy), (ox, oy - 1), (ox, oy + 1)], pink[4]); c.put(ox, oy, pink[1]); c.put(ox + 1, oy + 1, pink[3])


def _indigo(c, g, m, v):
    b, tl = g['b'], g['tail']
    if v == 'front': return
    # pointed hood flopping sideways, red-lined, bell on the tip
    if v == 'back':
        hood = ellipse(32.5, 50 + b, 6, 4) | poly([(36, 47 + b), (39, 48 + b), (43 + tl, 55 + b), (42 + tl, 57 + b)])
        form(c, hood, indigo, frac=0.35)
        for q in ellipse(32.5, 48 + b, 4, 1.5): c.put(q[0], q[1], yarnA[2])
        tip = (42 + tl, 58 + b)
    else:
        hood = ellipse(25, 49 + b, 3, 4) | poly([(24, 47 + b), (21, 48 + b), (19 + tl, 55 + b), (20 + tl, 57 + b)])
        form(c, hood, indigo, frac=0.3)
        for q in ellipse(27, 49 + b, 1, 3): c.put(q[0], q[1], yarnA[2])
        tip = (20 + tl, 58 + b)
    tx, ty = tip
    c.put(tx, ty, brass[1])
    P(c, [(tx - 1, ty + 1), (tx, ty + 1), (tx + 1, ty + 1), (tx - 1, ty + 2), (tx + 1, ty + 2)], brass[3]); c.put(tx - 1, ty + 1, brass[5]); c.put(tx, ty + 2, brass[1])
    # felt seam fleck along the hem
    for q in m.bottom():
        if q[0] % 3 == 0: c.put(q[0], q[1], indigo[0])


CLOAK = [
    dict(slug='sa-striped-poncho', cat='cloak', r=alpaca, lining=yarnA, len=64, flare=4, x0=19, x1=46, hemstyle='diamond', fx0=13, fx1=52, side_back=19, detail=_poncho),
    dict(slug='sa-thatch-rain-cape', cat='cloak', r=straw, lining=straw, len=63, flare=4, x0=20, x1=45, fx0=14, fx1=51, side_back=19, detail=_thatch),
    dict(slug='sa-feather-shoulder-mantle', cat='cloak', r=ember, lining=ember, len=56, flare=4, hemstyle='points', fx0=14, fx1=51, side_back=19, detail=_feathers),
    dict(slug='sa-cloud-forest-shawl', cat='cloak', r=mist, lining=mist, len=52, flare=2, fx0=16, fx1=49, detail=_shawl),
    dict(slug='sa-indigo-hooded-cloak', cat='cloak', r=indigo, lining=yarnA, len=67, flare=3, front_flare=4, side_back=18, detail=_indigo),
]

ITEMS = FOOT + PACK + COAT + CLOAK
