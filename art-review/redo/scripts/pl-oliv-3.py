# Loaf Share (pl-oliv-3): inner-TBTB, round. A wicker bread basket that IS the piece: N round tab = a big golden roll
# heaped on top, S round tab = the basket's round wicker foot, E + W round blanks bite into the basket sides (hand-holds).
# Wicker in the piazza wall terracotta, rolls in the lamp-glow ochre + stone cream, cloth in the lavender/mortar of cell 0-6.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path

WICK = K.ramp('#9a5848')
WICKD = '#7c4848'
CRUST = K.ramp('#e09a50')
CRUMB = K.ramp('#e8d8c0')
CLOTH = K.ramp('#d8d4e8')
MORT = '#7a6678'
SCORE = '#a8602e'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(11, 26, 53, 54)
    tabN = knob('T', 'round', 32, 22, 0, -1, r=6.4 * k, nw=4.5)
    tabS = knob('T', 'round', 32, 54, 0, 1, r=5.2 * k, nw=5.0)
    bW = knob('B', 'round', 11, 42, -1, 0, r=4.2 * k)
    bE = knob('B', 'round', 53, 42, 1, 0, r=4.2 * k)
    rollL = ell(19.5, 24, 9, 7.5)
    rollR = ell(44.5, 24, 9, 7.5)
    rollC = ell(32, 18, 8, 7)
    body = c.m(core, tabS, minus=(bW, bE))
    # three buns heaped in the basket: two side rolls behind, the big top roll (N tab) in front of them
    mL = c.add(c.m(rollL, minus=(bW,)), CRUST)
    mR = c.add(c.m(rollR, minus=(bE,)), CRUST)
    c.edge(mL, SCORE)
    c.edge(mR, SCORE)
    mC = c.add(c.m(tabN, rollC), CRUST)
    c.edge(mC, SCORE)
    # glossy top light on each bun
    for (x, y, w) in ((15, 20, 5), (40, 20, 5), (27, 13, 6)):
        c.line([(x, y), (x + w, y - 1.5)], CRUST[2])
    # crumb split on the top bun, score marks on the side buns
    c.line([(29, 18), (35, 18)], CRUMB[0])
    if not c.small:
        c.line([(30, 19), (34, 19)], CRUMB[2])
    c.line([(17, 25), (22, 23)], SCORE)
    c.line([(42, 23), (47, 25)], SCORE)
    # wicker basket
    c.add(body, WICK)
    # lavender gingham cloth lining folded over the rim (the cell's lavender + mortar)
    rim = c.m(rect(11, 29, 53, 34), minus=(bW, bE))
    c.add(rim, CLOTH)
    ry0, ry1 = c.P(0, 29)[1], c.P(0, 34)[1]
    cs = 4 if not c.small else 3
    for (x, y) in rim:
        if (x // cs + (y - ry0) // max(1, (ry1 - ry0) // 2)) % 2 == 0:
            c.px(x, y, MORT if c.small else '#a89cb8')
    # basket weave: brick-like rows (echoes the piazza stone wall of the cell)
    rows = (38, 44, 50) if not c.small else (38, 46)
    for i, yy in enumerate(rows):
        y = c.P(0, yy)[1]
        for x in range(c.n):
            if (x, y) in body:
                c.px(x, y, WICKD)
    ys = [c.P(0, 33)[1]] + [c.P(0, r)[1] for r in rows] + [c.P(0, 56)[1]]
    step = 6 if not c.small else 4
    for i in range(len(ys) - 1):
        for x in range(c.n):
            if (x + (i % 2) * (step // 2)) % step == 0:
                for y in range(ys[i] + 1, ys[i + 1]):
                    if (x, y) in body and c.P(0, 35)[1] <= y and not (c.P(20, 0)[0] <= x <= c.P(44, 0)[0] and y < c.P(0, 47)[1]):
                        c.px(x, y, WICKD)
    # face on the basket front
    c.eye(25, 40, disc=True)
    c.eye(39, 40, disc=True)
    c.smile(32, 44, wide=True)
    c.blush(20, 44)
    c.blush(43, 44)


K.render_pal(fn, 'pl-oliv-3', 'Loaf Share', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oliv-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oliv-3.png')
