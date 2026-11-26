#!/usr/bin/env python3
"""gc-shellstep "Shellstep": inner-TTTT, double. A tortoise seen from above whose domed shell IS the square piece body.
N double tab = the head (its two lobes are the bulging eyes), E and W double tabs = the paired legs (front + back foot each side),
S double tab = the stubby tail and hind toes. Olive shell with gold scute rims and umber seams, grey-brown skin (Great Canopy cell 9-6)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SHELL = K.ramp('#7a6a39')
RIM = K.ramp('#c3a859')
SKIN = K.ramp('#8a8070')
SEAM = '#4e4224'
SCUTE_LT = '#a79759'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 13, 14, 51, 51
    cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
    # square-ish shell core with softly rounded corners
    rr = 9
    core = lambda x, y: (x0 <= x < x1 and y0 <= y < y1 and not (
        (x < x0 + rr or x >= x1 - rr) and (y < y0 + rr or y >= y1 - rr) and
        min((x - (x0 + rr)) ** 2, (x - (x1 - rr)) ** 2) + min((y - (y0 + rr)) ** 2, (y - (y1 - rr)) ** 2) > rr * rr))
    tN = K.knob('T', 'double', cx, y0, 0, -1, r=6.2 * k, nw=4.2)
    tE = K.knob('T', 'double', x1, cy, 1, 0, r=5.6 * k, nw=3.6)
    tW = K.knob('T', 'double', x0, cy, -1, 0, r=5.6 * k, nw=3.6)
    tS = K.knob('T', 'double', cx, y1, 0, 1, r=4.4 * k)
    shell = c.m(core)
    head = K.ell(cx, y0 - 6.2 * k, 7.6 * k, 5.4 * k) if not c.small else K.ell(cx, y0 - 6.8, 9.2, 6.6)
    for t in (tE, tW, tS):
        c.add(c.m(t, minus=(core,)), SKIN)
    c.add(c.m(tN, head, minus=(core,)), SKIN)
    c.add(shell, RIM)
    inner = c.m(K.ell(cx, cy, (x1 - x0) / 2 - 3.5, (y1 - y0) / 2 - 3.5), lambda x, y: x0 + 6 <= x < x1 - 6 and y0 + 6 <= y < y1 - 6)
    c.add(inner, SHELL, stitch=None)
    # scute seams: central hexagon + spokes to the rim
    hx = [(cx - 5, cy - 7), (cx + 5, cy - 7), (cx + 8, cy), (cx + 5, cy + 7), (cx - 5, cy + 7), (cx - 8, cy)]
    hexm = c.m(K.poly(hx))
    c.add(hexm, K.ramp(SCUTE_LT))
    c.edge(hexm, SEAM)
    spokes = [((cx - 5, cy - 7), (x0 + 7, y0 + 7)), ((cx + 5, cy - 7), (x1 - 7, y0 + 7)),
              ((cx + 5, cy + 7), (x1 - 7, y1 - 7)), ((cx - 5, cy + 7), (x0 + 7, y1 - 7)),
              ((cx - 8, cy), (x0 + 4, cy)), ((cx + 8, cy), (x1 - 4, cy))]
    for a, b in spokes:
        c.line([a, b], SEAM)
    c.edge(inner, SEAM)
    # marginal scute ticks on the gold rim
    if not c.small:
        for t in (0.25, 0.5, 0.75):
            xm = x0 + (x1 - x0) * t
            ym = y0 + (y1 - y0) * t
            c.line([(xm, y0 + 0.5), (xm, y0 + 3.5)], SEAM)
            c.line([(xm, y1 - 3.5), (xm, y1 - 0.5)], SEAM)
            c.line([(x0 + 0.5, ym), (x0 + 3.5, ym)], SEAM)
            c.line([(x1 - 3.5, ym), (x1 - 0.5, ym)], SEAM)
        # olive speckles from the cell's dotted shell
        for (px, py) in [(cx - 2, cy - 2), (cx + 2, cy + 2), (cx + 3, cy - 3), (cx - 3, cy + 3)]:
            c.px(*c.P(px, py), SHELL[1])
    # toes: little umber claws at the leg-lobe tips
    for (lx, ly, dx, dy) in [(x1 + 6.5, cy - 3.2, 1, 0), (x1 + 6.5, cy + 3.2, 1, 0),
                             (x0 - 6.5, cy - 3.2, -1, 0), (x0 - 6.5, cy + 3.2, -1, 0)]:
        for oy in ((-1.6, 0, 1.6) if not c.small else (-1.2, 1.2)):
            px, py = c.P(lx + dx * 3.2, ly + oy)
            c.px(px, py, K.CREAM)
            c.px(px - dx, py, SKIN[1])
    # face: two felt eyes on the head lobes, a smile under them
    ey = y0 - 7.0 * k + 0.5
    ex = 3.4 * k
    c.eye(cx - ex, ey, disc=True)
    c.eye(cx + ex + (0.6 if c.small else 0), ey, disc=True)
    if not c.small:
        c.smile(cx, y0 - 2.2)
    c.blush(cx - ex - 3, ey + 3)
    c.blush(cx + ex + 2, ey + 3)


K.render_pal(fn, 'gc-shellstep', 'Shellstep', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/gc-shellstep-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/gc-shellstep.png')
