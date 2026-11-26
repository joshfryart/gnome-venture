"""pl-wpry-1 Gilded Nubbin: corner-TT keyhole. The shiny gold ball finial of the prayer pole as a corner piece:
flat W and S sides (S = the dark wooden pole socket collar), keyhole tabs N (the ball's top nub) and E. Gold #fbd781/#d59d5a
from cell 5-2, with the sky blue #78b4ec of the cell reflected as a shine window on the upper left."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob

GOLDB = K.ramp('#f0b84a')
GOLDL = ('#fbd781', '#e8b050', '#fff0c0')
SKY = K.ramp('#78b4ec')
POLE = K.ramp('#8a5a2e')
BAND = K.ramp('#c8202a')


def rr(x0, y0, x1, y1, r):
    return lambda x, y: (x0 <= x < x1 and y0 <= y < y1) and not (
        (x < x0 + r and y < y0 + r and (x - x0 - r) ** 2 + (y - y0 - r) ** 2 > r * r) or
        (x > x1 - r and y < y0 + r and (x - x1 + r) ** 2 + (y - y0 - r) ** 2 > r * r))


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rr(10, 14, 50, 56, 20)
    tabN = knob('T', 'keyhole', 30, 15, 0, -1, r=5.0 * k)
    tabE = knob('T', 'keyhole', 50, 36, 1, 0, r=5.0 * k)
    body = c.m(core, tabN, tabE)
    c.add(body, GOLDB, stitch=None if c.small else '#c88a30')
    c.add(c.m(tabN, minus=(core,)), GOLDL)
    c.add(c.m(tabE, minus=(core,)), GOLDL)
    # sky reflection window (upper left shine)
    shine = c.m(ell(21, 27, 5.2, 6.5), minus=(ell(23.5, 29.5, 4.5, 5.5),))
    c.add(shine & body, SKY)
    c.add(c.m(ell(18.5, 24, 1.8, 2.2)) & body, ('#ffffff', '#ffffff', '#ffffff'))
    # sphere shading: darker lower-right crescent of the ball
    c.add(c.m(ell(30, 34, 20, 20), minus=(ell(27, 31, 19, 19),)) & body & c.m(rect(0, 0, 64, 46)), (GOLDB[1], GOLDB[1], GOLDB[1]))
    # tiered spire rings along the flat S side (darker gold, like the stupa spire)
    c.add(c.m(rect(10, 45, 50, 56)) & body, K.ramp('#d59d5a'))
    c.edge(c.m(rect(10, 45, 50, 50.5)) & body, '#a87030')
    # a string of prayer flags across the rings
    cols = K.FLAGS
    for i, fx in enumerate((13.5, 20.5, 27.5, 34.5, 41.5)):
        x, y = c.P(fx, 50.5)
        w, h = (2, 2) if c.small else (4, 4)
        for dx in range(w):
            for dy in range(h - (dx if not c.small else 0) // 2):
                c.px(x + dx, y + dy, cols[i] if cols[i] != '#f4f0e4' else '#f4f0e4')
    c.line([(10, 50), (50, 50)], K.UMBER2)
    # face
    c.eye(26, 35, look=(0, 0))
    c.eye(38, 35)
    c.smile(32, 40)
    c.blush(21.5, 39.5)
    c.blush(42, 39.5)


K.render_pal(fn, 'pl-wpry-1', 'Gilded Nubbin', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpry-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpry-1.png')
