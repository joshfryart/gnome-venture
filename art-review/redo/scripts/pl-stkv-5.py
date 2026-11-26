import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, UMBER

R = '/home/user/gnome-venture/'
SHUT = ramp('#5e62b4')      # blue shutters, picked toward the cell's dusk-hill purple
SLAT = '#3e3f84'
GLASS = ramp('#ffd860')     # lamplight / sunset gold
GLOW = '#fff0b8'
ROOF = ramp('#d0583a')      # roof terracotta (cell corner)
SILL = ramp('#f8e2bb')      # cream wall
FRAME = ramp('#8a5a34')


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.7 * k
    core = rect(6, 7, 58, 58)
    bN = knob('B', 'double', 32, 7, 0, -1, r=r)
    bS = knob('B', 'double', 32, 58, 0, 1, r=r)
    bW = knob('B', 'double', 6, 34, -1, 0, r=r)
    bE = knob('B', 'double', 58, 34, 1, 0, r=r)
    bl = (bN, bS, bW, bE)
    body = c.m(core, minus=bl)
    # glass behind everything
    c.add(body, GLASS)
    # window frame (brown) around the glass
    frame = c.m(rect(19, 15, 45, 50), minus=bl + (rect(21, 18.5, 43, 46),))
    # shutters
    shL = c.add(c.m(rect(6, 17, 19.5, 47), minus=bl), SHUT)
    shR = c.add(c.m(rect(44.5, 17, 58, 47), minus=bl), SHUT)
    c.add(frame, FRAME)
    # roof lintel and sill
    c.add(c.m(rect(6, 7, 58, 17), minus=bl), ROOF)
    c.add(c.m(rect(6, 47, 58, 58), minus=bl), SILL)
    c.edge(shL, SLAT); c.edge(shR, SLAT)
    # shutter slats
    step = 4 if not c.small else 5
    for (x0, x1) in ((7, 18.5), (45.5, 57)):
        for yy in range(19, 47, step):
            for x in range(c.P(x0, 0)[0], c.P(x1, 0)[0]):
                p = (x, c.P(0, yy)[1])
                if p in body:
                    c.px(p[0], p[1], SLAT)
    # roof tile lines
    if not c.small:
        for xx in range(9, 58, 6):
            x, y = c.P(xx, 11)
            if (x, y) in body:
                c.px(x, y, ROOF[1]); c.px(x, y + 1, ROOF[1])
    # muntins: cross
    mx = c.P(32, 0)[0]
    my = c.P(0, 32)[1]
    for y in range(c.P(0, 18)[1], c.P(0, 46)[1]):
        c.px(mx, y, FRAME[0])
        if not c.small:
            c.px(mx - 1, y, FRAME[0])
    for x in range(c.P(21, 0)[0], c.P(43, 0)[0]):
        c.px(x, my, FRAME[0])
        if not c.small:
            c.px(x, my - 1, FRAME[0])
    # lamp glow in panes (upper left of each pane brighter)
    for (gx, gy) in ((22, 25), (34, 25), (22, 35), (34, 35)):
        x0, y0 = c.P(gx, gy)
        c.px(x0, y0, GLOW)
        if not c.small:
            c.px(x0 + 1, y0, GLOW); c.px(x0, y0 + 1, GLOW)
    # face: eyes in the upper panes, smile in the lower panes
    c.eye(26.5, 25.5)
    c.eye(38, 25.5)
    c.smile(32, 38.5, UMBER, wide=True)
    c.blush(23.5, 30); c.blush(40, 30)


K.render_pal(fn, 'pl-stkv-5', 'Lamplit Shutters', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-stkv-5-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-stkv-5.png')
