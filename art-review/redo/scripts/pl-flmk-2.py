import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp, UMBER, CREAM

# Edge-TTB, peg: a stilt-house window greeting the market. Flat N = the terracotta roof eave, peg tabs W + E = the wooden shutters
# flung open, peg blank S = the gap between two stilts over the water. Glowing amber panes with wooden mullions, brown wall,
# dusky purple lower wall (cell 3-3 of the floating market).
AMBER = ramp('#f0b048')
GLOW = ramp('#f8d070')
WALLR = ramp('#a87050')
DUSK = ramp('#5e3e56')
ROOF = ramp('#c8583a')
SHUT = ramp('#8a5230')
SILL = ramp('#d0a060')
MULL = '#b07040'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(15, 8, 49, 58)
    tabW = knob('T', 'peg', 15, 30, -1, 0, r=6.6, nw=2.6)
    tabE = knob('T', 'peg', 49, 30, 1, 0, r=6.6, nw=2.6)
    blankS = knob('B', 'peg', 32, 58, 0, 1, r=4.4 * k)
    body = c.m(core, tabW, tabE, minus=(blankS,))
    c.add(body, WALLR)
    # dusky lower wall + stilts
    c.add(body & c.m(rect(0, 44, 64, 64)), DUSK)
    # shutters (the tabs)
    shW = c.m(tabW, minus=(core,))
    shE = c.m(tabE, minus=(core,))
    c.add(shW, SHUT)
    c.add(shE, SHUT)
    for sh in (shW, shE):
        xs = [x for x, _ in sh]; ys = [y for _, y in sh]
        x0, x1 = min(xs) + 1, max(xs) - 1
        y0, y1 = min(ys) + 1, max(ys) - 1
        step = 2 if c.small else 3
        for y in range(y0 + 1, y1):
            if (y - y0) % step == 0:
                for x in range(x0 + 1, x1):
                    if (x, y) in sh:
                        c.px(x, y, SHUT[1])
    # roof eave band (flat top)
    c.add(body & c.m(rect(0, 8, 64, 15)), ROOF)
    if not c.small:
        for (x, y) in body & c.m(rect(0, 8, 64, 15)):
            if y == c.P(0, 11.5)[1] and x % 4 == 0:
                c.px(x, y, ROOF[1])
    # window: dark frame, amber panes, glowing upper transom
    frame = c.m(rect(19, 17, 45, 42))
    c.add(frame, (UMBER, UMBER, UMBER))
    c.add(c.m(rect(21, 19, 43, 40)), AMBER)
    c.add(c.m(rect(21, 19, 43, 25)), GLOW)
    mw = 1.6 if not c.small else 1.8
    c.add(c.m(rect(32 - mw, 19, 32 + mw, 40), rect(21, 25, 43, 25 + mw * 1.4)), (MULL, MULL, MULL))
    # sill
    c.add(c.m(rect(17, 41, 47, 44.5)), SILL)
    # face in the lower panes
    c.eye(26.5, 32.5)
    c.eye(37.5, 32.5)
    c.blush(23.5, 36.5)
    c.blush(40, 36.5)
    c.smile(32, 36.5)


K.render_pal(fn, 'pl-flmk-2', 'Shutter Hello', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flmk-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flmk-2.png')
