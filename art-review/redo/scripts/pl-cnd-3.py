#!/usr/bin/env python3
"""pl-cnd-3 "Updraft Fluff": inner-TBTB, peg. A puff of the condor's cream neck ruff that IS the piece: a square fluff body with
scalloped fluffy edges, peg tabs W and E are two little purple condor wing-feather 'wings' (it rides the wind), square peg blanks N and S
bite into the fluff. Cream ruff + dusk-purple wing from cell 6-3 / the condor's crag picture, a peach sky wisp."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, poly

CREAMR = K.ramp('#f2dfb4')
FLUFF2 = K.ramp('#e6cc98')
PURP = K.ramp('#7b6599')
PURPD = K.ramp('#5b4774')
PEACH = '#f77b70'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 14, 13, 50, 52
    core = rect(x0 + 2, y0 + 2, x1 - 2, y1 - 2)
    # big round fluff puffs all round the rim (a cloud of neck down), leaving straight-ish sides
    puffs = []
    for t in (18.5, 25, 32, 39, 45.5):
        puffs.append(ell(t, y0 + 3, 3.9, 3.9))
        puffs.append(ell(t, y1 - 3, 3.9, 3.9))
    for t in (18, 24.5, 41.5, 48):
        puffs.append(ell(x0 + 3, t, 3.9, 3.9))
        puffs.append(ell(x1 - 3, t, 3.9, 3.9))
    tabW = knob('T', 'peg', x0 + 0.5, 33, -1, 0, r=4.8 * k)
    tabE = knob('T', 'peg', x1 - 0.5, 33, 1, 0, r=4.8 * k)
    # feather fingers at the tab tips (condor primaries)
    def fan(sx, sg):
        out = []
        for dy, ln in ((-4.2, 10), (0, 12), (4.2, 10)):
            out.append(poly([(sx, 33 + dy * 0.4 - 2.2), (sx + sg * ln, 33 + dy * 1.7 - 1.0), (sx + sg * (ln + 1.5), 33 + dy * 1.7 + 1.0), (sx, 33 + dy * 0.4 + 2.2)]))
        return out
    fW = fan(x0 - 2, -1)
    fE = fan(x1 + 2, 1)
    blankN = knob('B', 'peg', 32, y0 + 0.5, 0, -1, r=3.2 * k)
    blankS = knob('B', 'peg', 32, y1 - 0.5, 0, 1, r=3.2 * k)
    body = c.m(core, *puffs, minus=(blankN, blankS))
    c.add(body, CREAMR)
    allp = (core, *puffs)
    c.add(c.m(tabW, *fW, minus=allp), PURP)
    c.add(c.m(tabE, *fE, minus=allp), PURP)
    # inner fluff curls (darker cream) where puffs meet, gives the down texture
    for pf in puffs:
        pass
    curl = FLUFF2[1]
    for (cx, cy) in ((22.5, 19), (41.5, 19), (22.5, 47), (41.5, 47), (19, 24), (45, 24), (19, 42), (45, 42)):
        px, py = c.P(cx, cy)
        c.px(px, py, curl)
        if not c.small:
            c.px(px + 1, py + 1, curl)
            c.px(px - 1, py + 1, curl)
    # wing vanes
    for sg, sx in ((-1, x0 - 2), (1, x1 + 2)):
        for dy in (-5.2, 5.2):
            c.line([(sx + sg * 2, 33 + dy * 0.35), (sx + sg * 8, 33 + dy * 1.2)], PURPD[1])
    # face
    c.eye(26.5, 30)
    c.eye(37.5, 30)
    c.smile(32, 35)
    c.blush(23, 35)
    c.blush(40, 35)
    # peach dusk wisp (wind) across the lower fluff
    c.line([(21, 41), (26, 42), (33, 42), (38, 41), (41, 39)], PEACH)


K.render_pal(fn, 'pl-cnd-3', 'Updraft Fluff', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cnd-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cnd-3.png')
