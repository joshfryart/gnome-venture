"""The Greatcanopy (WCA): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/WCA/common.lua (C.R.*)
and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- ramps (dark -> light)
indigo = ["#1a1d4a", "#22306e", "#2c4890", "#3a64ae", "#5a8acb", "#94bce4"]
ochre = ["#6a3418", "#94501f", "#b86e28", "#d48d36", "#e8ae4e", "#f6d27c"]
raffia = ["#5e4424", "#866434", "#ab8846", "#c9a75a", "#e0c477", "#f3e0a0"]
redleather = ["#4e1a22", "#74242a", "#9a3430", "#bc4a36", "#d66a44", "#ec9460"]
plantain = ["#163e2a", "#1f5e30", "#2f8236", "#4ea43c", "#7cc44a", "#b6e270"]
mahogany = ["#341a1a", "#4e2420", "#6c3226", "#8a442c", "#a85a36", "#c67a48"]
calabash = ["#6a4a1e", "#946a28", "#bc8e34", "#d8ad46", "#ecc962", "#f8e496"]
cotton = ["#6a5a4e", "#8e7e6c", "#b0a28c", "#cdc1a8", "#e4dac2", "#f6efdc"]
kente = ["#6e4210", "#9a6014", "#c88418", "#e8a820", "#f8c840", "#ffe48a"]
forest = ["#11302a", "#18463a", "#215c42", "#2e744a", "#418e52", "#64aa60"]
palm = ["#6a2410", "#9a3a12", "#c85618", "#e87420", "#f89a36", "#ffc66a"]
mud = ["#24161a", "#36221f", "#4a3026", "#5e3e2e", "#745038", "#8c6646"]
grey = ["#3a3a4a", "#55566a", "#727488", "#9294a6", "#b4b6c4", "#d8dae2"]
water = ["#2a4a7a", "#3a86b0", "#4fa8c4", "#5fc4c8", "#8fdcd8", "#c8f4ea"]
ember = ["#5e1c33", "#8a2a3d", "#b52e3f", "#d23c3c", "#e8573f", "#ff8a5c"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
skin = ["#6e3a2e", "#a5634a", "#c98462", "#f0b98d", "#ffd2a8", "#ffe0bd"]   # gnome default skin, for bare toes


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def _toe_dir(g, ft):
    """+1 = toe points right on screen (side view), 0 = front/back."""
    return 1 if g['view'] == 'side' else 0


# ======================================================================== FOOTWEAR
def _sandal(c, g, ft, k):
    v, cy, cx = g['view'], int(ft['cy']), int(ft['cx'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # bare toes on top (back view: heel), thick plaited palm-fibre sole on the 3 bottom rows
    for q in foot:
        if q[1] < y1 - 2: c.put(q[0], q[1], skin[4] if q[1] == y0 or q[0] == x0 + 1 else (skin[2] if q[0] > x1 - 2 else skin[3]))
    for q in foot:
        if q[1] >= y1 - 2:
            if q[1] == y1: c.put(q[0], q[1], raffia[1])
            else: c.put(q[0], q[1], raffia[4] if (q[0] + q[1] * 2) % 3 else raffia[2])   # plait ticks
    # red tooled-leather strap loop over the foot
    sy = y1 - 3
    if v == 'side':
        P(c, [(x, sy) for x in range(cx - 1, cx + 3)], redleather[3]); P(c, [(cx, sy - 1), (cx + 1, sy - 1)], redleather[4])
        P(c, [(x1 - 1, sy), (x1 - 2, sy)], redleather[2])            # toe loop
        if not g['far']: c.put(x1 - 1, sy - 1, brass[4]); c.put(x1, sy, brass[2])   # bell on the toe strap
    else:
        for x in range(x0 + 1, x1): c.put(x, sy, redleather[3] if x < x1 - 2 else redleather[2])
        if v == 'front':
            P(c, [(cx - 2, sy - 1), (cx - 1, sy - 2), (cx + 1, sy - 2), (cx + 2, sy - 1)], redleather[4])   # two loop arcs
            P(c, [(cx - 2, sy - 2), (cx + 2, sy - 2)], redleather[2])
            c.put(cx, sy, brass[4]); c.put(cx, sy + 1, brass[2])      # bell
        else:
            P(c, [(cx, sy - 1), (cx, sy - 2)], redleather[2])          # heel strap up the back


def _mudwader(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # cotton top binding
    for x in range(x0, x1 + 1): c.put(x, top, cotton[4] if x < x1 - 1 else cotton[2]); c.put(x, top + 1, cotton[3] if x < x1 - 1 else cotton[1])
    # criss-cross cord down the indigo wrap
    w = x1 - x0
    for y in range(top + 2, cy - 2):
        t = (y - top - 2) % 4
        for x in (x0 + 1 + t * (w - 2) // 3, x1 - 1 - t * (w - 2) // 3):
            if x0 <= x <= x1: c.put(x, y, cotton[5] if x < x1 - 1 else cotton[3])
    # weed sprout growing out of the binding (one foot)
    if k == (1 if v != 'side' else 1) and not g['far']:
        sx = x1 - 1 if v != 'back' else x0 + 1
        P(c, [(sx, top - 1), (sx, top - 2)], plantain[3]); c.put(sx + (1 if v != 'back' else -1), top - 3, plantain[5]); c.put(sx - (1 if v != 'back' else -1), top - 2, plantain[4])


def _clogs(c, g, ft, k):
    v, cy, cx = g['view'], int(ft['cy']), int(ft['cx'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # gold inlay sole line, then two raised heel blocks under it
    for q in foot.bottom(): c.put(q[0], q[1], kente[3] if q[0] < x1 - 1 else kente[2])
    if v == 'side':
        blocks = [(x0 + 1, x0 + 2), (x1 - 3, x1 - 2)]
    else:
        blocks = [(x0 + 1, x0 + 2), (x1 - 2, x1 - 1)]
    for a, z in blocks:
        for x in range(a, z + 1):
            c.put(x, y1 + 1, mahogany[1]); c.put(x, y1 + 2, mahogany[0])
        c.put(a, y1 + 1, mahogany[3])
    # woven gold/green band over the instep
    by = y0 + 1
    for x in range(x0 + 1, x1):
        c.put(x, by, kente[4] if (x // 2) % 2 else forest[3])
    # tree frog on the toe (near / right foot)
    if v != 'back' and not g['far'] and k == 1:
        fx = x1 - 2 if v == 'side' else cx
        P(c, [(fx - 1, y0), (fx, y0), (fx + 1, y0)], plantain[4]); c.put(fx - 1, y0 - 1, plantain[5]); c.put(fx + 1, y0 - 1, plantain[3])
        c.put(fx - 1, y0 - 1, INK if v == 'side' else plantain[5]); c.put(fx, y0 + 1, ember[4])


def _ochre(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # turned-down redleather cuff, 2 rows wide, overhangs the shaft by a px, cotton stitch dashes
    for x in range(x0 - 1, x1 + 2):
        c.put(x, top, redleather[4] if x < x1 else redleather[2])
        c.put(x, top + 1, redleather[3] if x < x1 else redleather[2])
        c.put(x, top + 2, redleather[1])
    for x in range(x0, x1 + 1, 2): c.put(x, top + 1, cotton[5])
    # tassel swinging at the outer side (lags the step)
    sw = g['tail']
    if v == 'side':
        if not g['far']:
            tx = x0 - 1 + sw
            P(c, [(x0 - 1, top + 3), (tx - 1, top + 4)], redleather[2]); P(c, [(tx - 1, top + 5), (tx - 2, top + 5), (tx - 1, top + 6)], redleather[4]); c.put(tx - 2, top + 6, redleather[1])
    else:
        out = x0 - 2 if ft['side'] == 'L' else x1 + 2
        d = -1 if ft['side'] == 'L' else 1
        P(c, [(out, top + 3), (out + sw, top + 4)], redleather[2]); P(c, [(out + sw, top + 5), (out + sw + d, top + 5)], redleather[4]); c.put(out + sw, top + 6, redleather[1])


def _plantain(c, g, ft, k):
    v, cy, cx = g['view'], int(ft['cy']), int(ft['cx'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # leaf wrap seams: diagonal folds
    for q in foot:
        if (q[0] - q[1]) % 4 == 0 and q[1] < y1 - 1: c.put(q[0], q[1], plantain[2] if q[0] > x1 - 3 else plantain[5])
    # vine tie round the ankle + spiky leaf ends sticking up
    ty = y0
    for x in range(x0 + 1, x1): c.put(x, ty, forest[2])
    tips = range(x0 + 1, x1, 2)
    for i, x in enumerate(tips):
        h = 2 if i % 2 == 0 else 1
        for yy in range(ty - h, ty): c.put(x, yy, plantain[4] if yy == ty - h else plantain[3])
    # curly vine tendril at the tie
    if v != 'back' and not g['far'] and k == 1:
        tx = x1 if v == 'side' else x1
        P(c, [(tx, ty), (tx + 1, ty - 1), (tx + 1, ty - 2), (tx, ty - 3)], forest[4])
    elif v == 'back' and k == 0:
        P(c, [(x0, ty), (x0 - 1, ty - 1), (x0 - 1, ty - 2), (x0, ty - 3)], forest[4])


FOOT = [
    dict(slug='wca-palm-sole-sandals', cat='footwear', shell=raffia, upper=raffia, sole=raffia[0], rim=None, puff=0, toe=1, detail=_sandal),
    dict(slug='wca-mudwader-wraps', cat='footwear', shell=strap, upper=indigo, sole=strap[0], rim=59, half=4, toe=1, detail=_mudwader),
    dict(slug='wca-rainroot-clogs', cat='footwear', shell=mahogany, upper=mahogany, sole=mahogany[0], rim=None, toe=2, detail=_clogs),
    dict(slug='wca-ochre-trail-boots', cat='footwear', shell=ochre, upper=ochre, sole=mahogany[1], rim=62, half=4, toe=1, detail=_ochre),
    dict(slug='wca-plantain-slippers', cat='footwear', shell=plantain, upper=plantain, sole=forest[1], rim=None, puff=1, detail=_plantain),
]


# ======================================================================== BACKPACK
def _weave(c, m, r, a=4, b=3):
    for q in m: c.put(q[0], q[1], r[a] if (q[0] // 2 + q[1]) % 2 else r[b])


def _shade_right(c, m, r, n=2):
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if q[0] > x1 - n: c.put(q[0], q[1], r[2])
        if q[1] == y1: c.put(q[0], q[1], r[1])


def _feather(c, x, y, d=1):
    """grey hornbill-style feather quill rising up-right from (x,y)."""
    P(c, [(x, y), (x + d, y - 1), (x + 2 * d, y - 2), (x + 3 * d, y - 3), (x + 4 * d, y - 4)], grey[4])
    P(c, [(x + d, y - 2), (x + 2 * d, y - 3), (x + 3 * d, y - 4)], grey[2])
    c.put(x + 4 * d, y - 5, grey[5]); c.put(x + 5 * d, y - 5, INK); c.put(x + 5 * d, y - 6, grey[1])


def calabash_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 8.5, 8.5, 8)
    form(c, m, calabash, frac=0.3, hi=[(x - 5, y + 3), (x - 4, y + 3)])
    # cut lid line + stem
    for xx in range(x - 6, x + 6): c.put(xx, y + 4, calabash[1] if xx > x + 2 else calabash[2])
    P(c, [(x - 1, y - 1), (x, y - 1)], plantain[3]); c.put(x, y - 2, plantain[2])
    # knotted cord net on the lower half
    for q in m:
        if q[1] > y + 8 and ((q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0): c.put(q[0], q[1], strap[2])
    for xx in range(x - 8, x + 8):
        if (xx, y + 8) in m: c.put(xx, y + 8, cotton[4] if xx % 2 else strap[3])
    # hornbill feather tucked into the net, right side
    _feather(c, x + 5, y + 9)


def calabash_side(c, x, y, g):
    m = ellipse(x - 4, y + 8.5, 5, 8)
    form(c, m, calabash, frac=0.25, hi=[(x - 7, y + 3)])
    for xx in range(x - 8, x): c.put(xx, y + 4, calabash[2])
    P(c, [(x - 5, y - 1), (x - 4, y - 1)], plantain[3])
    for q in m:
        if q[1] > y + 8 and ((q[0] + q[1]) % 4 == 0 or (q[0] - q[1]) % 4 == 0): c.put(q[0], q[1], strap[2])
    for xx in range(x - 9, x + 1):
        if (xx, y + 8) in m: c.put(xx, y + 8, cotton[4] if xx % 2 else strap[3])
    _feather(c, x - 7, y + 9, -1)


def cone_back(c, x, y, g):
    m = poly([(x - 9, y + 1), (x + 9, y + 1), (x + 3, y + 18), (x - 3, y + 18)])
    _weave(c, m, raffia); _shade_right(c, m, raffia)
    for q in m:   # dyed palm-orange band
        if y + 8 <= q[1] <= y + 9: c.put(q[0], q[1], palm[3] if q[1] == y + 8 else (palm[2] if q[0] % 2 else palm[4]))
    # coiled rim
    rim = rect(x - 10, y - 1, x + 9, y + 1)
    for q in rim: c.put(q[0], q[1], raffia[4] if (q[0] + q[1]) % 3 else raffia[2])
    for q in rim.bottom(): c.put(q[0], q[1], raffia[1])
    # two wide shoulder bands
    for sx in (x - 4, x + 3):
        for yy in range(y + 2, y + 14):
            if (sx, yy) in m: c.put(sx, yy, strap[2]); c.put(sx + 1, yy, strap[3])
    # cocoa pod poking out of the top
    # cocoa pod poking out of the top, leaning out past the right shoulder so it shows behind the head
    pod = ellipse(x + 9, y - 3, 1.5, 2.5)
    form(c, pod, palm, frac=0.4, hi=[(x + 8, y - 5)])
    for yy in (y - 4, y - 2): c.put(x + 9, yy, palm[2])
    P(c, [(x + 10, y - 6), (x + 11, y - 7)], forest[3])
    P(c, [(x - 9, y - 2), (x - 10, y - 3), (x - 10, y - 4)], plantain[3])   # leaf tucked in


def cone_side(c, x, y, g):
    m = poly([(x - 8, y + 1), (x, y + 1), (x, y + 18), (x - 3, y + 18)])
    _weave(c, m, raffia); _shade_right(c, m, raffia, 1)
    for q in m:
        if y + 8 <= q[1] <= y + 9: c.put(q[0], q[1], palm[3] if q[1] == y + 8 else palm[2])
    rim = rect(x - 9, y - 1, x, y + 1)
    for q in rim: c.put(q[0], q[1], raffia[4] if (q[0] + q[1]) % 3 else raffia[2])
    for q in rim.bottom(): c.put(q[0], q[1], raffia[1])
    pod = ellipse(x - 4, y - 4, 2, 3)
    form(c, pod, palm, frac=0.4, hi=[(x - 5, y - 6)])
    P(c, [(x - 4, y - 8), (x - 3, y - 9)], forest[3])


def _dots(c, m, col, step=3):
    for q in m:
        if q[0] % step == 0 and (q[1] + (q[0] // step)) % step == 0 and (q[0], q[1] + 1) in m and (q[0] + 1, q[1]) in m: c.put(q[0], q[1], col)


def _chameleon(c, x, y, d=1):
    """tiny green chameleon on a branch/knot, facing d, at body row y."""
    P(c, [(x, y), (x + d, y), (x + 2 * d, y), (x + 3 * d, y)], plantain[4])
    P(c, [(x + d, y - 1), (x + 2 * d, y - 1)], plantain[5]); c.put(x + 4 * d, y, plantain[3]); c.put(x + 3 * d, y - 1, INK)
    P(c, [(x - d, y), (x - 2 * d, y + 1), (x - 1 * d, y + 2)], plantain[2])   # curled tail
    P(c, [(x + d, y + 1), (x + 3 * d, y + 1)], plantain[2])


def bundle_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 9.5, 9, 7)
    form(c, m, indigo, frac=0.3, hi=[(x - 5, y + 5)])
    _dots(c, m - m.inner_edge(), cotton[5])
    # gathered folds toward the knot
    for q in m:
        if q[1] < y + 7 and (q[0] - x) % 3 == 0: c.put(q[0], q[1], indigo[2])
    # two knotted ears on top
    for ex, d in ((x - 4, -1), (x + 3, 1)):
        ear = poly([(ex - 1, y + 4), (ex + 2, y + 4), (ex + 1 + 2 * d, y - 2), (ex + 2 * d, y - 2)])
        form(c, ear, indigo, frac=0.4)
    form(c, rect(x - 1, y + 2, x, y + 4), indigo, frac=0.5)   # knot
    # carrying pole across the shoulders under the knot
    for xx in range(x - 12, x + 12): c.put(xx, y + 3, mahogany[4] if xx < x + 6 else mahogany[2]); c.put(xx, y + 4, mahogany[1])
    _chameleon(c, x - 9, y + 2)


def bundle_side(c, x, y, g):
    m = ellipse(x - 4.5, y + 9.5, 5, 7)
    form(c, m, indigo, frac=0.25, hi=[(x - 7, y + 5)])
    _dots(c, m - m.inner_edge(), cotton[5])
    ear = poly([(x - 6, y + 4), (x - 3, y + 4), (x - 5, y - 2), (x - 6, y - 2)])
    form(c, ear, indigo, frac=0.4)
    for xx in range(x - 10, x + 2): c.put(xx, y + 3, mahogany[4]); c.put(xx, y + 4, mahogany[1])
    _chameleon(c, x - 10, y + 2, 1)


def satchel_back(c, x, y, g):
    body = rect(x - 7, y + 2, x + 6, y + 14)
    form(c, body, redleather, frac=0.3)
    for q in body.inner_edge():   # tooled zig-zag border
        if q[1] > y + 2 and (q[0] + q[1]) % 2 == 0: c.put(q[0], q[1], redleather[1])
    flap = poly([(x - 7, y + 1), (x + 7, y + 1), (x + 7, y + 5), (x, y + 10), (x - 7, y + 5)])
    form(c, flap, ochre, frac=0.3)
    for q in flap.inner_edge():
        if q[1] > y + 2: c.put(q[0], q[1], ochre[1] if (q[0] + q[1]) % 2 else ochre[2])
    P(c, [(x - 1, y + 4), (x, y + 3), (x + 1, y + 4), (x, y + 5)], redleather[2])   # tooled diamond
    # fringe below
    for xx in range(x - 6, x + 6):
        for yy in range(y + 15, y + 17 + (xx % 2)): c.put(xx, yy, redleather[2] if xx % 2 else redleather[3])
    # brass bead string from the flap tip
    P(c, [(x, y + 11)], strap[1]); P(c, [(x, y + 12), (x, y + 14)], brass[4]); P(c, [(x, y + 13)], brass[2])
    # top handle loop
    P(c, [(x - 4, y), (x - 4, y - 1), (x - 3, y - 2), (x + 2, y - 2), (x + 3, y - 1), (x + 3, y)], redleather[2])
    P(c, [(x - 2, y - 2), (x - 1, y - 2), (x, y - 2), (x + 1, y - 2)], redleather[3])


def satchel_side(c, x, y, g):
    body = rect(x - 5, y + 2, x, y + 14)
    form(c, body, redleather, frac=0.3)
    flap = rect(x - 6, y + 1, x - 5, y + 9)
    form(c, flap, ochre, frac=0.3)
    for yy in range(y + 15, y + 17): c.put(x - 4, yy, redleather[2]); c.put(x - 2, yy, redleather[3]); c.put(x - 1, yy + 1, redleather[2])
    P(c, [(x - 7, y + 10), (x - 7, y + 12)], brass[4]); c.put(x - 7, y + 11, brass[2])
    P(c, [(x - 3, y), (x - 3, y - 1), (x - 2, y - 2), (x - 1, y - 2)], redleather[2])


def _bamboo(c, x0, y0, y1):
    for yy in range(y0, y1 + 1):
        node = (yy - y0) % 5 == 4
        c.put(x0, yy, kente[2] if node else kente[4]); c.put(x0 + 1, yy, kente[1] if node else kente[2])


def _gourd(c, x, y):
    form(c, ellipse(x, y + 3, 1.5, 1.5), calabash, frac=0.4, hi=[(x - 1, y + 2)])
    c.put(x, y + 1, calabash[3]); c.put(x, y, strap[1]); c.put(x, y - 1, strap[2])


def frame_back(c, x, y, g):
    for rx in (x - 7, x + 5): _bamboo(c, rx, y - 3, y + 16)
    for ry in (y - 1, y + 13):
        for xx in range(x - 6, x + 6): c.put(xx, ry, kente[4] if xx < x + 3 else kente[3])
    # rolled sleeping mat lashed across
    mat = rect(x - 10, y + 3, x + 9, y + 9)
    for q in mat:
        col = raffia[4] if (q[0] % 2) else raffia[3]
        if q[0] in (x - 5, x - 4, x + 2, x + 3): col = forest[3] if q[0] % 2 else forest[4]
        if q[1] == y + 3: col = raffia[5] if col not in forest else forest[5]
        if q[1] == y + 9: col = raffia[1]
        c.put(q[0], q[1], col)
    for yy in range(y + 4, y + 9): c.put(x - 10, yy, raffia[2] if yy % 2 else raffia[4])   # rolled end
    for rx in (x - 8, x + 7):
        for yy in range(y + 3, y + 10): c.put(rx, yy, strap[2])
    # water gourd swinging below the frame
    sw = g['tail']
    P(c, [(x + 4, y + 14), (x + 4 + sw, y + 15)], strap[2])
    _gourd(c, x + 4 + sw, y + 16)


def frame_side(c, x, y, g):
    _bamboo(c, x - 2, y - 3, y + 16)
    e = ellipse(x - 6, y + 6, 3.5, 3.5)
    for q in e: c.put(q[0], q[1], raffia[4] if ((q[0] - x + 6) ** 2 + (q[1] - y - 6) ** 2) % 5 > 1 else raffia[2])   # mat roll end
    for q in e.inner_edge(): c.put(q[0], q[1], forest[3])
    c.put(x - 6, y + 6, raffia[1])
    sw = g['tail']
    P(c, [(x - 3, y + 14), (x - 4 + sw, y + 15)], strap[2])
    _gourd(c, x - 4 + sw, y + 16)


PACK = [
    dict(slug='wca-calabash-pack', cat='backpack', y0=49, back=calabash_back, side=calabash_side),
    dict(slug='wca-raffia-cone-basket', cat='backpack', back=cone_back, side=cone_side),
    dict(slug='wca-indigo-bundle', cat='backpack', back=bundle_back, side=bundle_side),
    dict(slug='wca-tooled-satchel', cat='backpack', back=satchel_back, side=satchel_side),
    dict(slug='wca-bamboo-frame-pack', cat='backpack', back=frame_back, side=frame_side),
]


# ======================================================================== COAT
def _strips(q, t, g):
    s = (q[0] // 3) % 4
    r = (kente, forest, kente, ember)[s]
    return r[max(1, min(5, 4 - t))]


def _smock(c, g):
    v, b = g['view'], g['b']
    for q in list(c.keys()):   # stitched seams between strips
        if q[0] % 3 == 0 and q[1] % 2 == 0 and c[q] != INK: c.put(q[0], q[1], kente[1])
    if v == 'front':
        pk = rect(37, 60 + b, 41, 63 + b)
        form(c, pk, forest, frac=0.3)
        for q in pk.inner_edge():
            if q[1] > 60 + b and (q[0] + q[1]) % 2: c.put(q[0], q[1], cotton[5])
    elif v == 'side':
        pk = rect(25, 59 + b, 28, 62 + b)
        form(c, pk, forest, frac=0.3)
        for q in pk.inner_edge():
            if (q[0] + q[1]) % 2: c.put(q[0], q[1], cotton[5])


def _mudcloth(q, t, g):
    y = q[1] - g['b']
    if y % 3 == 0 and (q[0] + y // 3) % 3 == 0: return cotton[4] if t < 2 else cotton[2]   # dots
    if y % 3 == 1 and (q[0] // 2 + y) % 4 == 0 and q[0] % 2 == 0: return cotton[3] if t < 2 else cotton[2]   # dashes
    return None


def _vest(c, g):
    v, b = g['view'], g['b']
    for q in list(c.keys()):   # ember edging on the hem and armholes
        if c[q] != INK and ((q[0], q[1] + 1) not in c or c.get((q[0], q[1] + 1)) == INK) and q[1] >= 60 + b: c.put(q[0], q[1], ember[2])
    if v == 'front':
        form(c, ellipse(32.5, 61.5 + b, 1, 1), ember, frac=0.4, hi=[(32, 61 + b)])   # kola-nut button
        c.put(31, 61 + b, ember[2])
    elif v == 'side':
        form(c, ellipse(41, 60.5 + b, 1, 1), ember, frac=0.4)


def _tiers(q, t, g):
    y = q[1] - g['b']
    if y in (53, 58, 63): return palm[3] if t < 2 else palm[2]
    if y in (54, 59): return raffia[1]
    if q[0] % 2 == 0: return raffia[max(1, 3 - t)]
    return None


def _raffiacoat(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    m = M(q for q in c.keys())
    # shaggy bottom fringe: ragged hem
    for q in m.bottom():
        if q[0] % 2 == 0 and q[1] >= 64 + b: c.pop(q, None)
    # sleeve fringe ends
    # raindrop sliding off the fringe (cycles down over the walk)
    k = g['f'] % 4
    dx = 41 + hs if v != 'side' else 39 + hs
    if v == 'back': dx = 23 + hs
    yy = 67 + b + k
    c.put(dx, yy, water[4]); c.put(dx, yy + 1, water[2])
    if k == 0: c.put(dx, yy - 1, water[5])


def _rings(q, t, g):
    y = q[1] - g['b']
    a, bb = q[0] % 5, (y + (q[0] // 5) * 2) % 5
    if (a, bb) in ((1, 0), (0, 1), (2, 1), (1, 2)): return indigo[5] if t < 2 else indigo[4]
    return None


def _adire(c, g):
    v, b = g['view'], g['b']
    # cream piping on the cuffs
    for s in g['sleeves']:
        for q in s.bottom():
            if q in c and c[q] != INK: c.put(q[0], q[1], cotton[4]); c.put(q[0], q[1] - 1, cotton[3])
    if v == 'front':
        # wrap-over front edge, diagonal cream piping below the beard
        for i, y in enumerate(range(59, 65)):
            x = 29 + i
            if (x, y + b) in c: c.put(x, y + b, cotton[5]); c.put(x + 1, y + b, indigo[1])
        # hibiscus in the buttonhole, beside the beard
        P(c, [(44, 51 + b), (46, 51 + b), (45, 50 + b), (45, 52 + b)], ember[4]); c.put(45, 51 + b, kente[5]); c.put(46, 52 + b, ember[2])
        c.put(44, 53 + b, plantain[3])
    elif v == 'side':
        P(c, [(40, 51 + b), (42, 51 + b), (41, 50 + b), (41, 52 + b)], ember[4]); c.put(41, 51 + b, kente[5])
    else:
        for x in range(25, 41):   # collar band
            if (x, 50 + b) in c and c[(x, 50 + b)] != INK: c.put(x, 50 + b, cotton[3])


def _quilt(q, t, g):
    y = q[1] - g['b']
    if (q[0] + y) % 4 == 0 or (q[0] - y) % 4 == 0: return cotton[2] if t < 2 else cotton[1]
    return None


def _jerkin(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    for q in list(c.keys()):   # ochre edging on the hem
        if c[q] != INK and (q[0], q[1] + 1) not in c and q[1] >= 62 + b: c.put(q[0], q[1], ochre[3]); c.put(q[0], q[1] - 1, ochre[4])
    if v == 'front':
        for y in (60, 62): P(c, [(31, y + b), (32, y + b), (33, y + b)], strap[2])   # toggles
    # kapok fluff escaping a seam (side seam / shoulder)
    fx, fy = {'front': (46, 59), 'back': (18, 59), 'side': (22, 56)}[v]
    d = 1 if v == 'front' else -1
    P(c, [(fx, fy + b), (fx + d, fy + b), (fx + d, fy - 1 + b), (fx + 2 * d, fy + b)], cotton[5])
    c.put(fx + d, fy + 1 + b, cotton[3])


COAT = [
    dict(slug='wca-strip-weave-smock', cat='coat', r=kente, hem=2, pattern=_strips, detail=_smock),
    dict(slug='wca-mudcloth-vest', cat='coat', r=mud, sleeves=False, pattern=_mudcloth, detail=_vest),
    dict(slug='wca-raffia-rain-coat', cat='coat', r=raffia, hem=2, puff=1, pattern=_tiers, detail=_raffiacoat),
    dict(slug='wca-adire-jacket', cat='coat', r=indigo, pattern=_rings, detail=_adire),
    dict(slug='wca-kapok-jerkin', cat='coat', r=cotton, puff=1, pattern=_quilt, detail=_jerkin),
]


# ======================================================================== CLOAK
def _leafcape(c, g, m, v):
    b = g['b']
    x0, y0, x1, y1 = m.bbox()
    if v != 'front':
        # leaf separations (dark) and midribs (light)
        # leaves 4 px apart, aligned with the template's leaf-point hem; each leaf: dark edge, lit left half, pale midrib
        for q in m:
            if q[1] > y0 + 2:
                ph = (q[0] - x0 + g['tail']) % 4
                lo = (q[0], q[1] + 1) not in m
                if ph == 0: c.put(q[0], q[1], plantain[1])
                elif ph == 1 and not lo: c.put(q[0], q[1], plantain[4])
                elif ph == 2 and q[1] > y0 + 4 and not lo: c.put(q[0], q[1], plantain[5] if q[1] % 4 else plantain[4])
                elif ph == 3 and not lo: c.put(q[0], q[1], plantain[2])
    # vine collar
    for q in m.top(): c.put(q[0], q[1], forest[3]); c.put(q[0], q[1] + 1, forest[2] if q[0] % 2 else forest[4])
    # snail on one leaf
    if v == 'back':
        sx, sy = 37, 59 + b
    elif v == 'side':
        sx, sy = 23, 57 + b
    else:
        return
    form(c, ellipse(sx, sy, 1, 1), calabash, frac=0.4, hi=[(sx - 1, sy - 1)]); c.put(sx, sy, raffia[1])
    P(c, [(sx + 1, sy + 2), (sx, sy + 2), (sx - 1, sy + 2)], cotton[3]); c.put(sx + 2, sy + 1, cotton[4]); c.put(sx + 2, sy, INK)


def _shawlstripes(c, g, m, v):
    b = g['b']
    x0, y0, x1, y1 = m.bbox()
    rs = (kente, forest, ember, kente, indigo)
    for q in m:
        if c.get(q) == INK: continue
        r = rs[((q[0] - x0) // 4 if v != 'side' else (q[1] - y0) // 3) % 5]
        t = 3
        if q[0] > x1 - (x1 - x0) * 0.3: t = 2
        if (q[0], q[1] + 1) not in m: t = 1
        c.put(q[0], q[1], r[t])
    # folded-over band near the top
    for q in m:
        if y0 + 3 <= q[1] <= y0 + 4: c.put(q[0], q[1], kente[4] if q[1] == y0 + 3 else kente[1])
    # fringed ends
    for q in m.bottom():
        if q[0] % 2 == 0: c.put(q[0], q[1] + 1, kente[4]); c.put(q[0], q[1] + 2, kente[2])
    # cowrie shell sewn on the corner
    if v != 'front':
        if v == 'back':   # bottom-left corner sits under the hand: sew it a little in from the corner
            cx = x0 + 5; cy = max(q[1] for q in m if q[0] == cx) - 1
        else:
            cq = min(m, key=lambda q: (q[0], -q[1])); cx, cy = cq[0] + 1, cq[1] - 1
        P(c, [(cx, cy - 1), (cx + 1, cy - 1), (cx, cy), (cx + 1, cy)], cotton[5]); c.put(cx, cy, cotton[3]); c.put(cx + 1, cy, cotton[2])
        c.put(cx, cy + 1, cotton[4])


def _parrot_feather(c, pts):
    for i, (x, y) in enumerate(pts): c.put(x, y, ember[4] if i % 2 == 0 else ember[3])


def _indigohood(c, g, m, v):
    b = g['b']
    x0, y0, x1, y1 = m.bbox()
    # scatter of resist dots in the lower third
    for q in m:
        if q[1] > y1 - 7 and q[1] < y1 and (q[0] * 3 + q[1] * 5) % 9 == 0 and c.get(q) != INK: c.put(q[0], q[1], cotton[5])
    if v == 'back':
        hood = poly([(26, 49 + b), (39, 49 + b), (35, 57 + b), (30, 57 + b)])
        form(c, hood, indigo, frac=0.35)
        for q in hood.inner_edge():
            if q[1] > 49 + b: c.put(q[0], q[1], indigo[1])
        c.put(32, 58 + b, indigo[1])
        # red tail feather + brass pin at the left shoulder clasp
        P(c, [(23, 47 + b), (24, 47 + b)], brass[4])
        _parrot_feather(c, [(22, 48 + b), (21, 49 + b), (21, 50 + b), (20, 51 + b)])
    elif v == 'side':
        hood = ellipse(24.5, 50 + b, 3, 4)
        form(c, hood, indigo, frac=0.3)
        for q in hood.inner_edge():
            if q[0] >= 26: c.put(q[0], q[1], indigo[1])
        c.put(28, 47 + b, brass[4])
        _parrot_feather(c, [(27, 48 + b), (27, 49 + b), (26, 50 + b), (26, 51 + b)])
    else:
        c.put(19, 46 + b, brass[4])
        _parrot_feather(c, [(18, 47 + b), (17, 48 + b), (17, 49 + b), (16, 50 + b)])


def _raffiaponcho(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    # straw weave texture
    for q in m:
        if (q[0] + q[1]) % 3 == 0 and c.get(q) not in (INK,): c.put(q[0], q[1], raffia[2] if q[0] > x1 - 5 else raffia[4])
    # two dyed red bands following the hem
    for q in m:
        below = sum(1 for k in range(1, 6) if (q[0], q[1] + k) in m)
        if below in (2, 4): c.put(q[0], q[1], ember[3] if below == 4 else ember[2])
    # long fringe
    for q in m.bottom():
        if q[0] % 2 == 0:
            c.put(q[0], q[1] + 1, raffia[4]); c.put(q[0], q[1] + 2, raffia[2])
    # seed-pod rattle hanging from a corner
    tl = g['tail']
    if v != 'side':
        cq = min(m, key=lambda q: (q[0], -q[1])) if v == 'back' else max(m, key=lambda q: (q[0], q[1]))
        px, py = cq[0], cq[1] + 1
    else:
        cq = min(m, key=lambda q: (q[0], -q[1])); px, py = cq[0], cq[1] + 1
    P(c, [(px, py), (px + tl, py + 1)], mahogany[1])
    form(c, ellipse(px + tl, py + 3, 1, 1.5), mahogany, frac=0.4, hi=[(px + tl - 1, py + 2)])


def _scales(c, g, m, v):
    b = g['b']
    x0, y0, x1, y1 = m.bbox()
    for q in m:
        if c.get(q) == INK: continue
        row = (q[1] - y0 - 1) // 3
        off = 2 if row % 2 else 0
        px = (q[0] - x0 + off + g['tail']) % 4
        py = (q[1] - y0 - 1) % 3
        r = strap if row < 2 else ochre
        shade = q[0] > x1 - (x1 - x0) * 0.3
        if py == 2: col = strap[0] if px in (0, 3) else r[1]       # rounded tab bottom
        elif px == 3 and py == 0: col = strap[1]                  # gap between tabs
        elif py == 0 and px in (0, 1): col = r[2] if shade else r[5]   # lit top of each tab
        else: col = r[2] if shade else r[3]
        if q[1] <= y0: col = strap[2]
        c.put(q[0], q[1], col)
    # scalloped hem: drop the tab corners on the last row
    for q in list(m.bottom()):
        row = (q[1] - y0 - 1) // 3
        if (q[0] - x0 + (2 if row % 2 else 0) + g['tail']) % 4 in (0, 3): c.pop(q, None)
    # carved hornbill-beak clasp
    if v == 'back':
        P(c, [(30, 47 + b), (31, 47 + b), (32, 47 + b), (33, 47 + b)], kente[4]); P(c, [(33, 48 + b), (34, 48 + b)], kente[3]); c.put(34, 49 + b, kente[1])
        P(c, [(30, 46 + b), (31, 46 + b)], kente[5]); c.put(29, 47 + b, mahogany[1])
    elif v == 'side':
        P(c, [(27, 46 + b), (28, 46 + b), (29, 46 + b)], kente[4]); P(c, [(29, 47 + b), (30, 47 + b)], kente[3]); c.put(30, 48 + b, kente[1]); c.put(27, 45 + b, kente[5])
    else:
        P(c, [(18, 46 + b), (17, 46 + b), (16, 47 + b)], kente[4]); c.put(16, 48 + b, kente[2])


CLOAK = [
    dict(slug='wca-plantain-leaf-cape', cat='cloak', r=plantain, lining=forest, len=62, flare=3, hemstyle='points', fx0=15, fx1=50, side_back=19, detail=_leafcape),
    dict(slug='wca-strip-weave-shawl', cat='cloak', r=kente, lining=kente, len=60, flare=2, fx0=15, fx1=50, side_back=20, detail=_shawlstripes),
    dict(slug='wca-indigo-hood-mantle', cat='cloak', r=indigo, lining=indigo, len=67, flare=3, front_wide=2, side_back=18, detail=_indigohood),
    dict(slug='wca-raffia-poncho', cat='cloak', r=raffia, lining=raffia, len=62, flare=4, x0=20, x1=45, hemstyle='diamond', fx0=13, fx1=52, side_back=19, detail=_raffiaponcho),
    dict(slug='wca-scaleleaf-mantle', cat='cloak', r=ochre, lining=strap, len=59, flare=3, fx0=15, fx1=50, side_back=20, detail=_scales),
]

ITEMS = FOOT + PACK + COAT + CLOAK
