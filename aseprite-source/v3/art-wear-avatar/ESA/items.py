"""Thornacre Savanna (ESA): 20 wearables as small designs on the cats.py templates. Ramps = art-wear-concepts/ESA/common.lua
(C.R.*) and gnome-wear/_gw.lua (W.R.*), 6 tones dark -> light."""
from av import C, M, ellipse, poly, rect, line, form, INK

# ---- shared ramps (W.R, dark -> light)
sole = ["#24171f", "#3a2629", "#51342f", "#6a4537", "#80563f", "#9a6b4c"]
ember = ["#5e1c33", "#8a2a3d", "#b52e3f", "#d23c3c", "#e8573f", "#ff8a5c"]
jay = ["#1e2f63", "#28488e", "#3364b4", "#4688d2", "#6cb0e6", "#bfe6f6"]
leather = ["#55301f", "#80492c", "#a5673a", "#c4864c", "#dca566", "#f0c98a"]
wood = ["#3e2420", "#5e3627", "#7e4a2f", "#9e6239", "#be8048", "#dca266"]
canvas = ["#4a3c34", "#6c5c4a", "#8e7e62", "#ad9e7a", "#c9bb92", "#e4d8b0"]
blanket = ["#5a1e30", "#86283a", "#ad3a3c", "#cc5544", "#e2744e", "#f39a62"]
strap = ["#3a2220", "#55302a", "#704234", "#8c5640", "#a86c4c", "#c48a60"]
brass = ["#6e3a1a", "#a0601e", "#d98322", "#f5b82e", "#ffd25a", "#fff0b0"]
steel = ["#3a3c52", "#55576e", "#74758c", "#9a9aae", "#c4c4d2", "#eceaf2"]
yarnA = ["#5c1f2e", "#842a36", "#a8383a", "#c64e40", "#dc6a4a", "#f08e62"]
yarnB = ["#1d4048", "#285e62", "#357c78", "#46998c", "#68b8a2", "#a2dcc0"]
autumn = ["#6e2a1c", "#a8401e", "#d8602a", "#ee8434", "#f8a848", "#ffd27a"]
# ---- ESA ramps (common.lua)
coffee = ["#2e1a1c", "#46282a", "#5e3a31", "#7a4f3c", "#98694c", "#b88a64"]
sisal = ["#6a5030", "#8e7044", "#b09258", "#ccb06e", "#e2cb8c", "#f4e4b2"]
madder = ["#4e1a24", "#74242c", "#9a3232", "#bb4638", "#d4624a", "#e88a66"]
indigo = ["#1a1c40", "#242c5e", "#2e3e7e", "#3e549c", "#5874b8", "#8aa2d6"]
umber = ["#261a20", "#35242a", "#463034", "#5a3e3e", "#70504a", "#8a6658"]
bark = ["#4a2420", "#6c3426", "#8e462e", "#ac5c36", "#c87a46", "#e09c62"]
barkg = ["#2e2426", "#463836", "#5e4c46", "#786256", "#927a6a", "#b09884"]
gourd = ["#5a3418", "#86501e", "#ae7228", "#cc9238", "#e2b452", "#f4d684"]
wool = ["#54443c", "#7a6656", "#a08a70", "#c2ae90", "#dccaa8", "#f0e4c6"]
khaki = ["#3e3a26", "#5a5434", "#787044", "#958c58", "#b0a872", "#cec694"]
suede = ["#5a3a26", "#7e5434", "#a07044", "#bc8c58", "#d4a874", "#e8c896"]
ochre = ["#5e3014", "#8a4a18", "#b06a20", "#cc8a2e", "#e2aa48", "#f2cc78"]
banana = ["#183a24", "#205430", "#2c723a", "#3e9442", "#62b44c", "#9cd468"]
sand = ["#5a3e2c", "#7c5a3e", "#9e7a52", "#bc9a68", "#d4b682", "#ead2a4"]
leafg = ["#1d3a2a", "#245236", "#2f6c3c", "#428a44", "#64aa50", "#98ca6a"]
skin = ["#51302b", "#a4684c", "#c98462", "#f0b98d", "#ffd2a8", "#ffe0bd"]   # rig default skin, for bare sandal feet
BEADS = (ember[4], jay[4], brass[4], yarnB[4])


def P(c, pts, col):
    for x, y in pts: c.put(x, y, col)


def tone(c, q, r):
    """index of c[q] in ramp r (None if not from it)."""
    col = c.get(q)
    return r.index(col) if col in r else None


def retone(c, m, src, dst, shift=0):
    """repaint the pixels of mask m that carry ramp src with the same tone of ramp dst."""
    for q in m:
        i = tone(c, q, src)
        if i is not None: c.put(q[0], q[1], dst[max(0, min(5, i + shift))])


# ======================================================================== FOOTWEAR
def _sandals(c, g, ft, k):
    v, cx, cy = g['view'], int(ft['cx']), int(ft['cy'])
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # thick stacked sole: the bottom row becomes a pale leather layer, a dark sole row under it
    for q in foot.bottom():
        c.put(q[0], q[1], leather[4] if q[0] < x1 - 1 else leather[2])
        c.put(q[0], q[1] + 1, sole[1])
    if v == 'front':
        # crossed toe straps (an X over the toes) + ankle loop
        for i in range(4):
            c.put(cx - 2 + i, cy - 1 + i // 2 * 0 + (i % 2), leather[2])
        P(c, [(cx - 3, cy - 1), (cx - 2, cy), (cx - 1, cy + 1), (cx + 2, cy - 1), (cx + 1, cy), (cx, cy + 1)], leather[2])
        P(c, [(cx - 2, cy - 1), (cx + 1, cy - 1)], leather[4]); P(c, [(cx - 1, cy), (cx, cy)], leather[1])
        for x in range(x0 + 1, x1): c.put(x, y0, leather[4] if x < x1 - 1 else leather[2])
        c.put(cx, y0, brass[4])
    elif v == 'back':
        for x in range(x0 + 1, x1): c.put(x, y0, leather[4] if x < x1 - 1 else leather[2])
        for y in range(y0 + 1, y1): c.put(cx, y, leather[2])
    else:
        P(c, [(x1 - 2, cy - 1), (x1 - 3, cy), (x1 - 4, cy - 1), (x1 - 3, cy - 1)], leather[2])
        for y in range(y0, y1): c.put(x0 + 2, y, leather[3])
        c.put(x0 + 2, y0 + 1, brass[4])
    # long white acacia thorn stuck in the sole edge (outer edge of the near/right foot)
    if k == 1 and v != 'back':
        sy = y1 + 1
        P(c, [(x1 + 1, sy - 1), (x1 + 2, sy - 1), (x1 + 3, sy - 2)], canvas[5]); c.put(x1, sy, canvas[3])
    elif k == 1:
        P(c, [(x1 + 1, y1), (x1 + 2, y1 - 1)], canvas[5])


def _trek(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # woven striped cuff: teal / rust / teal rows with a weave tick
    for x in range(x0, x1 + 1):
        c.put(x, top, yarnB[4] if x % 2 else yarnB[3])
        c.put(x, top + 1, yarnA[4] if x % 2 == 0 else yarnA[3])
        c.put(x, top + 2, yarnB[2] if x < x1 - 1 else yarnB[1])
    if v == 'front':   # high laced front
        mx = (x0 + x1) // 2
        for i, y in enumerate(range(top + 3, cy - 1)):
            P(c, [(mx - 1 + (i % 2) * 2, y)], canvas[5]); c.put(mx, y, coffee[1])
        if k == 1:   # coffee-cherry pair on the lace end
            P(c, [(mx + 2, top + 3), (mx + 3, top + 4)], leafg[3])
            P(c, [(mx + 3, top + 5), (mx + 4, top + 5)], madder[4]); P(c, [(mx + 3, top + 6), (mx + 4, top + 6)], madder[2])
    elif v == 'side':
        if not g['far']:
            for i, y in enumerate(range(top + 3, cy - 1)): c.put(x1 - 1, y, canvas[5] if i % 2 else coffee[1])
            P(c, [(x1 + 1, top + 3)], leafg[3]); P(c, [(x1 + 1, top + 4), (x1 + 2, top + 4)], madder[4]); P(c, [(x1 + 2, top + 5)], madder[2])
    else:   # heel seam
        for y in range(top + 3, cy): c.put((x0 + x1) // 2, y, coffee[2])


def _sisal(c, g, ft, k):
    v, cx, cy, top = g['view'], int(ft['cx']), int(ft['cy']), g['top']
    shoe = g['foot'] | g['shaft']
    x0, y0, x1, y1 = shoe.bbox()
    for q in shoe:   # plait: diagonal herringbone of two straw tones
        i = tone(c, q, sisal)
        if i is not None and i >= 2 and ((q[0] + q[1]) % 3 == 0): c.put(q[0], q[1], sisal[i - 1])
    # coiled-rope sole
    for q in g['foot'].bottom(): c.put(q[0], q[1], sisal[1] if q[0] % 2 else sisal[2])
    # madder band stitching across the vamp
    if v != 'back':
        for x in range(x0 + 1, x1): c.put(x, cy - 1, madder[3] if x % 2 else madder[2])
    else:
        for x in range(x0 + 1, x1): c.put(x, top + 1, madder[3] if x % 2 else madder[2])
    # small aloe sprig tucked in the heel
    if v == 'side' and not g['far']:
        hx = x0
        P(c, [(hx, top - 1), (hx - 1, top - 2), (hx + 1, top - 2), (hx, top - 3)], leafg[4]); P(c, [(hx, top - 2)], leafg[2]); c.put(hx - 1, top - 3, leafg[5])
    elif v == 'back' and k == 0:
        hx = cx
        P(c, [(hx, top - 1), (hx - 1, top - 2), (hx + 1, top - 2), (hx, top - 3)], leafg[4]); c.put(hx, top - 2, leafg[2])
    elif v == 'front' and k == 0:
        hx = x0 + 1
        P(c, [(hx, top - 1), (hx - 1, top - 2), (hx - 1, top - 3)], leafg[4]); c.put(hx, top - 2, leafg[2])


def _gaiters(c, g, ft, k):
    v, top, x0, x1, cy = g['view'], g['top'], g['sx0'], g['sx1'], int(ft['cy'])
    # wrapped stripe felt: diagonal dark / cream bands down the shaft (stops 2 rows above the foot shoe)
    for y in range(top + 1, cy - 2):
        for x in range(x0, x1 + 1):
            dark = ((x + y * (1 if v != 'side' else -1)) // 2) % 2 == 0
            shade = x >= x1 - 1
            col = (umber[2] if shade else umber[3]) if dark else (canvas[3] if shade else canvas[5] if x == x0 else canvas[4])
            c.put(x, y, col)
    # tie cord at the top
    for x in range(x0, x1 + 1): c.put(x, top, umber[1] if x % 2 else canvas[2])
    # tail-hair tassel on the tie cord, on the outer side
    if (v == 'front' and k == 0) or (v == 'back' and k == 1):
        tx = x0 - 1
        P(c, [(tx, top), (tx, top + 1)], canvas[2]); P(c, [(tx, top + 2), (tx - 1, top + 3), (tx, top + 3)], umber[4]); P(c, [(tx - 1, top + 4)], umber[2])
    elif v == 'front' or v == 'back':
        pass
    elif v == 'side' and not g['far']:
        tx = x1 + 1
        P(c, [(tx, top), (tx, top + 1)], canvas[2]); P(c, [(tx, top + 2), (tx + 1, top + 3), (tx, top + 3)], umber[4]); P(c, [(tx + 1, top + 4)], umber[2])


def _baobab(c, g, ft, k):
    v, cx, cy, top = g['view'], int(ft['cx']), int(ft['cy']), g['top']
    foot = g['foot']
    x0, y0, x1, y1 = foot.bbox()
    # bark-textured sides: grey-brown lower half with vertical bark cracks
    for q in foot:
        if q[1] >= cy and q[1] < y1:
            c.put(q[0], q[1], barkg[3] if (q[0] * 2 + q[1]) % 5 else barkg[1])
            if q[0] >= x1 - 1: c.put(q[0], q[1], barkg[2])
    for q in foot.bottom(): c.put(q[0], q[1], wood[0])
    if v == 'side':   # upturned toe
        P(c, [(x1, y0 + 1), (x1, y0), (x1 + 1, y0), (x1 + 1, y0 - 1)], wood[4]); c.put(x1 - 1, y0, wood[3])
    elif v == 'front':
        c.put(cx, y0 - 1, wood[4])
    # strap heel band (the 'upper' rim rows) gets a dark stitch
    if g['shaft']:
        for x in range(g['sx0'], g['sx1'] + 1): c.put(x, top, strap[4] if x % 3 else strap[2])
    # velvety baobab seed pod hanging from the strap on the outer side
    if (v == 'front' and k == 0) or (v == 'back' and k == 1) or (v == 'side' and not g['far']):
        px = (x0 - 2) if v != 'side' else (g['sx0'] - 2)
        py = top + 1
        c.put(px + 1, py, strap[1])
        P(c, [(px, py + 1), (px - 1, py + 1), (px, py + 2), (px - 1, py + 2), (px, py + 3), (px - 1, py + 3)], khaki[3])
        c.put(px - 1, py + 1, khaki[5]); c.put(px, py + 3, khaki[1]); c.put(px - 1, py + 3, khaki[2])


FOOT = [
    dict(slug='esa-acacia-sandals', cat='footwear', shell=skin, upper=skin, sole=sole[1], rim=None, detail=_sandals),
    dict(slug='esa-highland-trek-boots', cat='footwear', shell=coffee, upper=coffee, sole=sole[0], rim=60, half=4, toe=1, detail=_trek),
    dict(slug='esa-sisal-slippers', cat='footwear', shell=sisal, upper=sisal, sole=sisal[1], rim=64, half=4, puff=0.5, detail=_sisal),
    dict(slug='esa-stripe-gaiters', cat='footwear', shell=leather, upper=canvas, sole=sole[0], rim=58, half=4, detail=_gaiters),
    dict(slug='esa-baobab-clogs', cat='footwear', shell=wood, upper=strap, sole=wood[0], rim=65, half=4, puff=1, toe=1, detail=_baobab),
]


# ======================================================================== BACKPACK
# Back view: the scarf + beard hide everything above row ~49 between x 20..45, so these packs hang lower (y0 51-52) and the
# quirks sit on the visible part of the pack or poke out past the beard at the shoulders.
def basket_back(c, x, y, g):
    m = rect(x - 8, y + 1, x + 7, y + 13) - M({(x - 8, y + 13), (x + 7, y + 13)})
    form(c, m, sisal, frac=0.3)
    for q in m:   # coil rows: a darker groove every second row, stitch ticks
        if (q[1] - y) % 2 == 0: c.put(q[0], q[1], sisal[2] if q[0] < x + 5 else sisal[1])
        elif (q[0] + q[1]) % 4 == 0 and q[0] < x + 5: c.put(q[0], q[1], sisal[4])
    for xx in range(x - 8, x + 8):   # madder zigzag band + indigo band
        c.put(xx, y + 4 - (xx % 2), madder[4] if xx < x + 5 else madder[2]); c.put(xx, y + 5, madder[2] if xx < x + 5 else madder[1])
        c.put(xx, y + 9, indigo[4] if xx % 2 else indigo[5]); c.put(xx, y + 10, indigo[2])
    for q in m.bottom(): c.put(q[0], q[1], sisal[0])
    lid = ellipse(x - 0.5, y, 8.5, 1.5)
    form(c, lid, sisal, frac=0.3)
    for q in lid:
        if (q[0] + q[1]) % 2 == 0 and q[1] >= y: c.put(q[0], q[1], sisal[3])
    for q in lid.bottom(): c.put(q[0], q[1], sisal[1])
    # sorghum head poking out under the lid, leaning out past the left shoulder
    P(c, [(x - 8, y), (x - 9, y - 1), (x - 10, y - 1), (x - 11, y - 2)], leafg[3]); c.put(x - 10, y - 2, leafg[5])
    for q in ellipse(x - 13, y - 3, 1.5, 1.8): c.put(q[0], q[1], madder[4] if (q[0] + q[1]) % 2 else ochre[4])
    c.put(x - 14, y - 4, ochre[5])


def basket_side(c, x, y, g):
    m = rect(x - 8, y + 1, x, y + 13) - M({(x - 8, y + 13)})
    form(c, m, sisal, frac=0.25)
    for q in m:
        if (q[1] - y) % 2 == 0: c.put(q[0], q[1], sisal[2])
    for xx in range(x - 8, x + 1):
        c.put(xx, y + 4 - (xx % 2), madder[4]); c.put(xx, y + 5, madder[2])
        c.put(xx, y + 9, indigo[4] if xx % 2 else indigo[5]); c.put(xx, y + 10, indigo[2])
    form(c, ellipse(x - 4, y, 5, 1.5), sisal, frac=0.3)
    P(c, [(x - 8, y), (x - 9, y - 1), (x - 10, y - 2)], leafg[3])
    for q in ellipse(x - 11, y - 4, 1.2, 1.8): c.put(q[0], q[1], madder[4] if (q[0] + q[1]) % 2 else ochre[4])
    for yy in range(y + 2, y + 10): c.put(x, yy, strap[2])


def _net(c, m, x, y):
    for q in m:
        if ((q[0] - x) + (q[1] - y)) % 4 == 0 or ((q[0] - x) - (q[1] - y)) % 4 == 0:
            i = tone(c, q, gourd)
            c.put(q[0], q[1], strap[1] if i is not None and i <= 2 else strap[2])


def _feather(c, pts, flip=False):
    """guinea-fowl feather: dark grey vane with white spots, pts from quill to tip."""
    for i, (fx, fy) in enumerate(pts):
        c.put(fx, fy, steel[0] if i < 1 else (steel[5] if i % 2 == 0 else steel[1]))
        c.put(fx, fy + 1, steel[1] if i % 2 else steel[5])


def calabash_back(c, x, y, g):
    bulb = ellipse(x - 0.5, y + 8, 7.5, 5)
    neck = ellipse(x - 0.5, y + 2, 2.5, 2.5)
    form(c, neck, gourd, frac=0.35, hi=[(x - 2, y + 1)])
    form(c, bulb, gourd, frac=0.3, hi=[(x - 5, y + 5), (x - 4, y + 4)])
    _net(c, M(q for q in bulb if q[1] >= y + 6), x, y)
    for xx in range(x - 3, x + 2): c.put(xx, y + 4, strap[2])   # cord ring under the neck
    form(c, rect(x - 2, y - 2, x, y - 1), wood, frac=0.4)        # stopper
    # spotted guinea-fowl feather stuck in the stopper, lying out to the left
    _feather(c, [(x - 3, y - 1), (x - 4, y - 1), (x - 5, y - 2), (x - 6, y - 2), (x - 7, y - 2), (x - 8, y - 3)])


def calabash_side(c, x, y, g):
    bulb = ellipse(x - 5, y + 8, 5, 5)
    neck = ellipse(x - 4, y + 2, 2, 2.5)
    form(c, neck, gourd, frac=0.35)
    form(c, bulb, gourd, frac=0.25, hi=[(x - 8, y + 5)])
    _net(c, M(q for q in bulb if q[1] >= y + 6), x, y)
    form(c, rect(x - 5, y - 2, x - 3, y - 1), wood, frac=0.4)
    _feather(c, [(x - 6, y - 2), (x - 7, y - 3), (x - 8, y - 3), (x - 9, y - 4), (x - 10, y - 5)])


def sack_back(c, x, y, g):
    m = ellipse(x - 0.5, y + 8, 8.5, 5.5) | ellipse(x - 0.5, y + 4, 5, 2.5)
    form(c, m, canvas, frac=0.3, hi=[(x - 6, y + 4)])
    for q in m:   # burlap weave flecks
        if (q[0] * 3 + q[1] * 5) % 7 == 0 and tone(c, q, canvas) in (3, 4): c.put(q[0], q[1], canvas[2])
    for xx in range(x - 9, x + 9):   # red woven stripe
        if (xx, y + 9) in m: c.put(xx, y + 9, madder[3] if xx < x + 5 else madder[2])
    neck = rect(x - 2, y, x + 1, y + 1)
    form(c, neck, canvas, frac=0.3)
    for xx in range(x - 2, x + 2): c.put(xx, y + 1, strap[3] if xx % 2 else strap[1])   # drawstring knot
    tuft = poly([(x - 4, y - 3), (x + 3, y - 3), (x + 1, y), (x - 2, y)])
    form(c, tuft, canvas, frac=0.3)
    # rope shoulder loops down both sides
    for side in (-1, 1):
        for i, yy in enumerate(range(y + 2, y + 13)):
            xx = x + side * (7 + (1 if 2 < i < 8 else 0)) - (1 if side > 0 else 0)
            c.put(xx, yy, strap[3] if i % 2 else strap[1])
    # tiny yellow weaver bird perched on the knot
    bx, by = x + 2, y + 1
    P(c, [(bx, by), (bx + 1, by), (bx + 2, by), (bx + 1, by - 1), (bx + 2, by - 1)], brass[4]); c.put(bx + 2, by - 2, brass[4])
    c.put(bx + 3, by - 2, sole[2]); c.put(bx + 3, by - 1, brass[2]); c.put(bx + 1, by + 1, brass[2]); c.put(bx - 1, by - 1, brass[2])


def sack_side(c, x, y, g):
    m = ellipse(x - 5, y + 8, 5, 5.5) | ellipse(x - 4, y + 4, 3.5, 2.5)
    form(c, m, canvas, frac=0.25)
    for q in m:
        if (q[0] * 3 + q[1] * 5) % 7 == 0 and tone(c, q, canvas) in (3, 4): c.put(q[0], q[1], canvas[2])
    for xx in range(x - 11, x + 1):
        if (xx, y + 9) in m: c.put(xx, y + 9, madder[3])
    form(c, rect(x - 5, y, x - 3, y + 1), canvas, frac=0.3)
    for xx in range(x - 5, x - 2): c.put(xx, y + 1, strap[2])
    form(c, poly([(x - 7, y - 3), (x - 1, y - 3), (x - 3, y), (x - 5, y)]), canvas, frac=0.3)
    bx, by = x - 7, y + 1
    P(c, [(bx, by), (bx - 1, by), (bx - 2, by), (bx - 1, by - 1), (bx - 2, by - 1)], brass[4]); c.put(bx - 2, by - 2, brass[4])
    c.put(bx - 3, by - 2, sole[2]); c.put(bx - 3, by - 1, brass[2]); c.put(bx + 1, by - 1, brass[2])
    for yy in range(y + 2, y + 11): c.put(x, yy, strap[2])


def _blog(c, x0, x1, y):
    for xx in range(x0, x1 + 1):
        c.put(xx, y, barkg[4] if xx % 4 else barkg[5]); c.put(xx, y + 1, barkg[3] if xx % 5 != 2 else barkg[1]); c.put(xx, y + 2, barkg[2])
    P(c, [(x0, y), (x0, y + 2)], wood[4]); c.put(x0, y + 1, wood[2])


def frame_back(c, x, y, g):
    for rx in (x - 8, x + 7):   # acacia poles
        form(c, rect(rx, y - 3, rx + 1, y + 14), wood, frac=0.5)
    form(c, rect(x - 8, y + 13, x + 8, y + 13), wood, frac=0.2, rim=False)
    for i, ly in enumerate((y + 3, y + 6, y + 9)): _blog(c, x - 10 + (i % 2), x + 9 - (i % 2), ly)
    # rolled striped cloth on top
    roll = rect(x - 9, y - 1, x + 8, y + 2)
    for q in roll:
        s = (q[0] - x) % 6
        r = blanket if s < 2 else (yarnB if s < 4 else canvas)
        c.put(q[0], q[1], r[4] if q[1] == y - 1 else r[3] if q[1] < y + 2 else r[1])
    P(c, [(x - 9, y), (x - 9, y + 1)], canvas[5])
    for rx in (x - 4, x + 3):
        for yy in range(y - 1, y + 12): c.put(rx, yy, strap[3] if yy % 2 else strap[1])
    # puffball acacia flowers on a thorny twig, out past the right shoulder
    P(c, [(x + 9, y - 1), (x + 10, y - 2), (x + 11, y - 3)], wood[2]); c.put(x + 10, y - 3, canvas[5])
    for (fx, fy) in ((x + 12, y - 5), (x + 10, y - 5)):
        P(c, [(fx, fy), (fx + 1, fy), (fx, fy - 1), (fx + 1, fy - 1)], brass[4]); c.put(fx, fy - 1, brass[5])


def frame_side(c, x, y, g):
    form(c, rect(x - 1, y - 3, x, y + 14), wood, frac=0.5)
    for i, ly in enumerate((y + 3, y + 6, y + 9)):
        e = ellipse(x - 4, ly + 1, 2.5, 1.5)
        for q in e: c.put(q[0], q[1], barkg[4] if (q[0] - x) % 2 else barkg[3])
        P(c, [(x - 4, ly + 1)], wood[4])
    e = ellipse(x - 4, y + 0.5, 3, 2)
    for q in e: c.put(q[0], q[1], blanket[4] if q[1] < y else yarnB[3] if q[1] == y else canvas[3])
    P(c, [(x - 4, y), (x - 4, y + 1)], canvas[5])
    form(c, rect(x - 7, y + 13, x - 1, y + 13), wood, frac=0.2, rim=False)
    form(c, rect(x - 7, y + 3, x - 7, y + 14), wood, frac=0.2, rim=False)
    P(c, [(x - 1, y - 4), (x - 2, y - 5), (x - 3, y - 6)], wood[2])
    P(c, [(x - 4, y - 7), (x - 3, y - 7), (x - 4, y - 8), (x - 3, y - 8)], brass[4]); c.put(x - 4, y - 8, brass[5])


def satchel_back(c, x, y, g):
    # strap handle arching over the top
    for q in ellipse(x - 0.5, y + 1, 6, 3) - ellipse(x - 0.5, y + 1, 5, 2):
        if q[1] <= y + 1: c.put(q[0], q[1], strap[2] if q[0] < x + 3 else strap[1])
    body = rect(x - 10, y + 2, x + 9, y + 11) - M({(x - 10, y + 2), (x + 9, y + 2)})
    form(c, body, leather, frac=0.25, hi=[(x - 8, y + 3)])
    flap = ellipse(x - 0.5, y + 3, 10, 4.5).rows(y + 2, y + 7)
    form(c, flap, leather, frac=0.25)
    for q in flap.bottom(): c.put(q[0], q[1], leather[1])
    # row of plain coloured beads along the flap edge
    for i, q in enumerate(sorted(flap.bottom(), key=lambda p: p[0])):
        c.put(q[0], q[1] - 1, BEADS[i % 4])
    c.put(x - 1, y + 8, wool[5]); c.put(x, y + 8, wool[4]); c.put(x - 1, y + 9, wool[3]); c.put(x, y + 9, wool[2])   # cowrie button
    # long fringe
    for xx in range(x - 9, x + 9):
        if xx % 2 == 0:
            for yy in range(y + 12, y + 15 + (xx % 4 == 0)): c.put(xx, yy, leather[2] if yy < y + 14 else leather[1])


def satchel_side(c, x, y, g):
    for q in ellipse(x - 2, y + 1, 3, 3) - ellipse(x - 2, y + 1, 2, 2):
        if q[1] <= y + 1: c.put(q[0], q[1], strap[2])
    body = rect(x - 5, y + 2, x, y + 11) - M({(x - 5, y + 2)})
    form(c, body, leather, frac=0.3)
    flap = rect(x - 6, y + 2, x, y + 7) - M({(x - 6, y + 2)})
    form(c, flap, leather, frac=0.3)
    for i, yy in enumerate(range(y + 3, y + 8)): c.put(x - 6, yy, BEADS[i % 4])
    for xx in range(x - 5, x + 1):
        if xx % 2 == 0:
            for yy in range(y + 12, y + 15 + (xx % 4 == 0)): c.put(xx, yy, leather[2] if yy < y + 14 else leather[1])


PACK = [
    dict(slug='esa-coiled-basket-pack', cat='backpack', y0=51, front_lift=5, back=basket_back, side=basket_side),
    dict(slug='esa-calabash-carrier', cat='backpack', y0=52, front_lift=5, back=calabash_back, side=calabash_side),
    dict(slug='esa-grain-sack-pack', cat='backpack', y0=51, front_lift=5, back=sack_back, side=sack_side),
    dict(slug='esa-acacia-frame-pack', cat='backpack', y0=51, front_lift=5, back=frame_back, side=frame_side),
    dict(slug='esa-herders-satchel', cat='backpack', y0=51, front_lift=5, back=satchel_back, side=satchel_side),
]


# ======================================================================== COAT
def _ribs(q, t, g):
    if (q[1] - g['b']) % 2 == 0: return bark[max(0, 4 - t - 1)]
    return None


def _figleaf(c, x, y):
    P(c, [(x, y), (x + 1, y), (x + 2, y), (x - 1, y + 1), (x, y + 1), (x + 1, y + 1), (x + 2, y + 1), (x + 3, y + 1), (x, y + 2), (x + 1, y + 2), (x + 2, y + 2)], leafg[4])
    P(c, [(x + 1, y - 1), (x - 1, y), (x + 3, y)], leafg[3]); P(c, [(x + 1, y + 1), (x + 1, y + 2)], leafg[2]); c.put(x + 1, y + 3, leafg[1])


def _smock(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        for y in (60, 62): P(c, [(32, y + b), (33, y + b)], wood[4]); c.put(34, 60 + b, wood[2]); c.put(34, 62 + b, wood[2])
        _figleaf(c, 23 + hs, 62 + b)
    elif v == 'back':
        _figleaf(c, 38 + hs, 62 + b)
    else:
        _figleaf(c, 33 + hs, 62 + b)
    # short wide sleeves: the cuff end row gets a deep fold
    for s in g['sleeves'] if v != 'side' else []:
        for q in s.bottom():
            if q in c: c.put(q[0], q[1], bark[1])


def _vest_pat(q, t, g):
    s = (q[0] - g['hem'] if q[1] - g['b'] > 61 else q[0]) % 7
    r = autumn if s < 3 else (yarnB if s < 5 else canvas)
    return r[max(1, min(5, 4 - t))]


def _vest(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    # fringed hem: every other pixel of the bottom row dropped, cream threads below
    bot = c.mask().bottom()
    for q in bot:
        if q[1] >= 63 + b:
            if q[0] % 2: c.put(q[0], q[1] + 1, canvas[4]); c.put(q[0], q[1] + 2, canvas[2])
    if v == 'front':   # turquoise sunbird feather in the buttonhole
        P(c, [(43, 50 + b), (44, 49 + b), (44, 48 + b), (45, 47 + b)], yarnB[5]); P(c, [(43, 49 + b), (45, 48 + b)], yarnB[3]); c.put(42, 51 + b, jay[2])
    elif v == 'side':
        P(c, [(38, 52 + b), (39, 51 + b), (39, 50 + b), (40, 49 + b)], yarnB[5]); c.put(38, 51 + b, yarnB[3])


def _wool_pat(q, t, g):
    if (q[0] * 5 + q[1] * 3) % 11 == 0 and t < 2: return wool[3]
    return None


def _woolcoat(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':
        for i, y in enumerate((60, 62, 64, 66)):
            for bx in (29, 36):
                xx = bx + (hs if y > 63 else 0)
                odd = bx == 36 and i == 2
                c.put(xx, y + b, madder[4] if odd else wood[2]); c.put(xx - 1, y + b, madder[2] if odd else wood[1])
        # tall collar points beside the beard
        for x0 in (19, 44):
            P(c, [(x0, 46 + b), (x0 + 1, 46 + b), (x0, 47 + b), (x0 + 1, 47 + b)], wool[5] if x0 < 30 else wool[3])
        for y in range(59, 68): c.put(32 + (hs if y > 63 else 0), y + b, wool[2])
    elif v == 'back':   # tall collar band
        for x in range(25, 41): c.put(x, 46 + b, wool[4] if x < 37 else wool[2]); c.put(x, 47 + b, wool[1])
        for y in range(62, 68): c.put(32 + hs, y + b, wool[1])   # back vent
        for x in range(26, 40): c.put(x, 58 + b, wool[1]); c.put(x, 59 + b, wool[4] if x < 37 else wool[2])   # half-belt
        P(c, [(27, 59 + b), (38, 59 + b)], wood[2])
    else:
        for x in range(30, 37): c.put(x, 47 + b, wool[4])
        for y in (59, 61, 63): c.put(40, y + b, wood[3])
        c.put(40, 65 + b, madder[4])


def _jacket_pat(q, t, g):
    return None


def _field(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    # rolled sleeves: a light roll band 2 rows above the cuff
    sls = g['sleeves']
    for s in sls:
        x0, y0, x1, y1 = s.bbox()
        for q in s.rows(y1 - 2, y1 - 1):
            if q in c: c.put(q[0], q[1], khaki[5] if q[1] == y1 - 2 else khaki[1])
    if v == 'front':
        for px in (23, 37):   # two lower patch pockets below the beard
            pk = rect(px + hs, 60 + b, px + 4 + hs, 63 + b)
            form(c, pk, khaki, frac=0.3)
            for x in range(px + hs, px + 5 + hs): c.put(x, 59 + b, strap[2])
        # giraffe-spot patch on the left pocket
        for (x, y), col in {(24, 61): brass[3], (25, 61): ochre[2], (26, 61): brass[3], (24, 62): ochre[2], (25, 62): brass[4], (26, 62): ochre[2]}.items():
            c.put(x + hs, y + b, col)
        for y in (59, 61, 63): c.put(32 + (hs if y > 63 else 0), y + b, brass[4])
        # upper pockets peek beside the beard
        for px in (19, 45):
            P(c, [(px, 51 + b), (px + 1, 51 + b)], strap[2])
    elif v == 'back':
        for x in range(21, 45): c.put(x, 50 + b, khaki[2])   # yoke seam
        for x in range(25, 41): c.put(x, 58 + b, strap[2]); c.put(x, 59 + b, khaki[4] if x < 37 else khaki[2])
        P(c, [(26, 59 + b), (39, 59 + b)], brass[4])
        for y in range(60, 64): c.put(32 + hs, y + b, khaki[1])
    else:
        pk = rect(35 + hs, 59 + b, 39 + hs, 62 + b); form(c, pk, khaki, frac=0.3)
        for x in range(35 + hs, 40 + hs): c.put(x, 58 + b, strap[2])
        P(c, [(36 + hs, 60 + b), (38 + hs, 61 + b)], brass[3]); c.put(37 + hs, 60 + b, ochre[2])


def _beaded(c, g):
    v, b, hs = g['view'], g['b'], g['hem']
    if v == 'front':   # bead collar visible at the shoulders beside the beard
        for x in list(range(18, 23)) + list(range(42, 47)):
            c.put(x, 47 + b, BEADS[x % 4]); c.put(x, 48 + b, suede[1])
        # side slits
        for y in range(63, 67): c.put(21 + hs, y + b, INK); c.put(44 + hs, y + b, INK)
        # tiny brass bell on the hem
        bx = 38 + hs
        c.put(bx, 67 + b, strap[1]); P(c, [(bx - 1, 68 + b), (bx, 68 + b)], brass[4]); P(c, [(bx - 1, 69 + b), (bx, 69 + b)], brass[2])
    elif v == 'back':
        for x in range(20, 46):
            if (x, 50 + b) in c: c.put(x, 50 + b, BEADS[x % 4])
            if (x, 51 + b) in c: c.put(x, 51 + b, suede[1])
        for y in range(63, 67): c.put(21 + hs, y + b, INK); c.put(44 + hs, y + b, INK)
    else:
        for x in range(28, 37): c.put(x, 47 + b, BEADS[x % 4]); c.put(x, 48 + b, suede[1])
        for y in range(63, 67): c.put(33 + hs, y + b, INK)
        bx = 40 + hs
        c.put(bx, 67 + b, strap[1]); P(c, [(bx, 68 + b), (bx + 1, 68 + b)], brass[4]); P(c, [(bx, 69 + b), (bx + 1, 69 + b)], brass[2])


COAT = [
    dict(slug='esa-barkcloth-smock', cat='coat', r=bark, hem=2, puff=1, pattern=_ribs, detail=_smock),
    dict(slug='esa-stripe-weave-vest', cat='coat', r=autumn, sleeves=False, open=4, pattern=_vest_pat, detail=_vest),
    dict(slug='esa-highland-wool-coat', cat='coat', r=wool, hem=4, pattern=_wool_pat, detail=_woolcoat),
    dict(slug='esa-savanna-field-jacket', cat='coat', r=khaki, detail=_field),
    dict(slug='esa-beaded-tunic-coat', cat='coat', r=suede, hem=3, detail=_beaded),
]


# ======================================================================== CLOAK
def _wrap(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # asymmetric drape: hem rises toward the knotted (left) shoulder
    if v != 'side':
        lo_left = (v == 'back')
        for q in list(c.keys()):
            k = (q[0] - x0) if lo_left else (x1 - q[0])
            if q[1] > y1 - 7 + k * 0.45 and q in m: del c[q]
    # ochre / indigo check
    for q in list(c.keys()):
        i = tone(c, q, ochre)
        if i is None: continue
        a, bb = (q[0] - tl) % 5 == 0, (q[1] - b) % 5 == 0
        if a and bb: c.put(q[0], q[1], indigo[1])
        elif a or bb: c.put(q[0], q[1], indigo[max(1, min(4, i))])
    # fringe threads along the hem
    for q in M(c.keys()).bottom():
        if q[0] % 2 and q[1] > y0 + 6: c.put(q[0], q[1] + 1, indigo[2])
    # knot over the shoulder + carved wooden bead
    if v == 'back':
        kx, ky = 20, 49 + b
    elif v == 'side':
        kx, ky = 27, 47 + b
    else:
        kx, ky = 44, 46 + b
    form(c, ellipse(kx, ky, 1.6, 1.3), ochre, frac=0.3)
    P(c, [(kx - 1, ky + 2), (kx - 1, ky + 3)], ochre[2])
    for q in ellipse(kx - 1, ky + 4.5, 1, 1): c.put(q[0], q[1], wood[3])
    c.put(kx - 2, ky + 4, wood[5])


def _hshawl(c, g, m, v):
    x0, y0, x1, y1 = m.bbox()
    # coloured woven border bands across the lower part
    for q in list(c.keys()):
        if q not in m: continue
        d = y1 - q[1]
        i = tone(c, q, wool)
        if i is None: continue
        if d in (2,): c.put(q[0], q[1], yarnA[max(1, i)])
        elif d == 3: c.put(q[0], q[1], brass[max(1, i - 1)])
        elif d == 4: c.put(q[0], q[1], yarnB[max(1, i)])
        elif d == 6: c.put(q[0], q[1], yarnA[max(1, i)])
    # fold line near the top
    for q in m:
        if q[1] == y0 + 3 and tone(c, q, wool) is not None: c.put(q[0], q[1], wool[2])
    # tasselled ends at the bottom corners; brass bead on one
    if v != 'side':
        L = min((q for q in m if q[1] == y1), key=lambda q: q[0]); R = max((q for q in m if q[1] == y1), key=lambda q: q[0])
        for t in (L, R):
            P(c, [(t[0], t[1] + 1), (t[0], t[1] + 2)], yarnA[3]); c.put(t[0], t[1] + 3, yarnA[1])
        bead = R if v == 'back' else L
        P(c, [(bead[0], bead[1] + 2), (bead[0] + 1, bead[1] + 2)], brass[4]); c.put(bead[0], bead[1] + 3, brass[2]); c.put(bead[0], bead[1] + 4, yarnA[3])
    else:
        L = min((q for q in m if q[1] == y1), key=lambda q: q[0])
        P(c, [(L[0], L[1] + 1), (L[0], L[1] + 2)], yarnA[3]); P(c, [(L[0], L[1] + 3), (L[0] + 1, L[1] + 3)], brass[4]); c.put(L[0], L[1] + 4, yarnA[2])


def _banana(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # shingled leaves: rows of 4-wide leaves, staggered, each with a pale midrib and a dark lower edge
    for q in list(c.keys()):
        if q not in m: continue
        i = tone(c, q, banana)
        if i is None: continue
        ry = (q[1] - y0 - 2)
        if ry < 0: continue
        row = ry // 4
        lx = (q[0] - tl + (2 if row % 2 else 0)) % 4
        ly = ry % 4
        if ly == 3: c.put(q[0], q[1], banana[max(0, i - 2)])
        elif lx == 0: c.put(q[0], q[1], banana[max(1, i - 1)])
        elif lx == 2 and ly < 2: c.put(q[0], q[1], banana[min(5, i + 1)])
    # collar band
    for q in m:
        if q[1] <= y0 + 1: c.put(q[0], q[1], strap[3] if q[1] == y0 else strap[1])
    # a little snail riding on a leaf
    if v == 'back':
        sx, sy = 37 + tl, y1 - 4
    elif v == 'side':
        sx, sy = x0 + 3, y1 - 5
    else:
        return
    P(c, [(sx, sy), (sx + 1, sy), (sx, sy - 1), (sx + 1, sy - 1)], gourd[4]); c.put(sx, sy - 1, gourd[2]); c.put(sx + 1, sy - 1, gourd[5])
    P(c, [(sx - 1, sy + 1), (sx, sy + 1), (sx + 1, sy + 1), (sx + 2, sy + 1)], sand[5]); c.put(sx + 2, sy, sand[4])


def _dust(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # dust speckle
    for q in m:
        if (q[0] * 7 + q[1] * 3) % 13 == 0 and tone(c, q, sand) in (3, 4): c.put(q[0], q[1], sand[2])
    # fringe with madder tips
    for q in m.bottom():
        if q[0] % 2 == 0: c.put(q[0], q[1] + 1, sand[2]); c.put(q[0], q[1] + 2, madder[3])
    if v == 'back':   # pointed hood lying down the back
        hood = poly([(24, 49 + b), (41, 49 + b), (33.5, 61 + b), (31.5, 61 + b)])
        form(c, hood, sand, frac=0.4)
        for q in hood.inner_edge(): c.put(q[0], q[1], sand[1] if q[1] > 50 + b else sand[2])
        for q in hood.bottom(): c.put(q[0], q[1], sand[0])
        for q in ellipse(32.5, 50.5 + b, 4, 1.2): c.put(q[0], q[1], sand[0])
        # agama lizard clinging to the hem (blue body, orange head, head up)
        lx, ly = 38 + tl, y1 - 1
        for yy in range(ly - 4, ly + 1): c.put(lx, yy, jay[3] if yy % 2 else jay[4])
        P(c, [(lx, ly - 6), (lx, ly - 5)], autumn[4]); c.put(lx, ly - 6, autumn[5])
        P(c, [(lx - 1, ly - 4), (lx + 1, ly - 3), (lx - 1, ly - 1), (lx + 1, ly)], jay[2])
        P(c, [(lx, ly + 1), (lx + 1, ly + 2), (lx + 1, ly + 3)], jay[2])
    elif v == 'side':
        hood = poly([(24, 47 + b), (29, 47 + b), (27, 56 + b), (25, 56 + b)])
        form(c, hood, sand, frac=0.3)
        lx, ly = x0 + 3 + tl, y1 - 1
        for yy in range(ly - 4, ly + 1): c.put(lx, yy, jay[3] if yy % 2 else jay[4])
        P(c, [(lx, ly - 6), (lx, ly - 5)], autumn[4])
        P(c, [(lx - 1, ly - 3), (lx + 1, ly - 1)], jay[2]); c.put(lx, ly + 1, jay[2])


def _dotshawl(c, g, m, v):
    b, tl = g['b'], g['tail']
    x0, y0, x1, y1 = m.bbox()
    # resist-dot circles: small rings (plus of pale with a dark centre) on a staggered grid
    for q in list(c.keys()):
        if q not in m or tone(c, q, indigo) is None: continue
        gx, gy = (q[0] - tl) % 6, (q[1] - y0) % 6
        if (q[1] - y0) // 6 % 2: gx = (q[0] - tl + 3) % 6
        if (gx, gy) in ((2, 3), (4, 3), (3, 2), (3, 4)): c.put(q[0], q[1], indigo[5])
        elif (gx, gy) == (3, 3): c.put(q[0], q[1], indigo[1])
    # corner tassels at the side corners (cream) and the point
    if v != 'side':
        for side in (0, 1):
            cand = [q for q in m if q[1] <= y0 + 4]
            t = min(cand, key=lambda q: q[0]) if side == 0 else max(cand, key=lambda q: q[0])
            P(c, [(t[0], t[1] + 1), (t[0], t[1] + 2), (t[0], t[1] + 3)], canvas[4]); c.put(t[0], t[1] + 4, canvas[2])
        bot = max(m, key=lambda q: q[1])
        P(c, [(bot[0], bot[1] + 1), (bot[0], bot[1] + 2)], canvas[4]); c.put(bot[0], bot[1] + 3, canvas[2])
    # small orange butterfly resting on it
    if v == 'back':
        bx, by = 37 + tl, 52 + b
    elif v == 'side':
        bx, by = x0 + 4, y0 + 6
    else:
        return
    P(c, [(bx - 1, by), (bx - 1, by + 1), (bx + 1, by), (bx + 1, by + 1)], autumn[4]); P(c, [(bx - 1, by + 1), (bx + 1, by + 1)], autumn[2])
    c.put(bx, by, umber[0]); c.put(bx, by + 1, umber[0]); c.put(bx - 1, by, autumn[5])


CLOAK = [
    dict(slug='esa-check-blanket-wrap', cat='cloak', r=ochre, lining=ochre, len=65, flare=3, x0=21, x1=45, fx0=15, fx1=50, side_back=18, detail=_wrap),
    dict(slug='esa-highland-shawl', cat='cloak', r=wool, lining=wool, len=59, flare=2, x0=20, x1=45, fx0=15, fx1=50, side_back=20, detail=_hshawl),
    dict(slug='esa-banana-leaf-rain-cape', cat='cloak', r=banana, lining=banana, len=62, flare=4, hemstyle='points', fx0=14, fx1=51, side_back=18, detail=_banana),
    dict(slug='esa-dust-mantle', cat='cloak', r=sand, lining=sand, len=65, flare=3, fx0=15, fx1=50, side_back=18, detail=_dust),
    dict(slug='esa-indigo-dot-shawl', cat='cloak', r=indigo, lining=indigo, len=66, flare=3, x0=19, x1=46, hemstyle='tri', border=canvas, border_rows=1, border_sides=True, fx0=14, fx1=51, side_back=19, detail=_dotshawl),
]

ITEMS = FOOT + PACK + COAT + CLOAK
