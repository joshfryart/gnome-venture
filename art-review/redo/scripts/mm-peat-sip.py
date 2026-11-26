#!/usr/bin/env python3
"""mm-peat-sip "Peat Sip": the cottage's stone chimney stack as an inner-TBBB piece (peg).
N peg tab = the chimney pot (with a peat-smoke puff), W/E/S peg blanks cut into the stone. Grey coursed stone and mortar,
amber hearth-glow mouth, moss and heather tufts at the foot (Mistmoor cell 8-5: cottage wall, lit window, heather)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob

STONE = K.ramp('#9c9d97')
MORTAR = '#757670'
POT = K.ramp('#b07a4a')
SMOKE = K.ramp('#c9cbd6')
AMBER = '#f2b84a'
AMBER2 = '#d98a2b'
HEATH = K.ramp('#8a5a8e')
MOSS = K.ramp('#5f7a3c')
CAP = K.ramp('#bfc0b8')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(12, 22, 52, 57)
    tabN = knob('T', 'peg', 32, 22, 0, -1, r=6.0 * k, nw=3.4)
    bW = knob('B', 'peg', 12, 38, -1, 0, r=3.8 * k)
    bE = knob('B', 'peg', 52, 38, 1, 0, r=3.8 * k)
    bS = knob('B', 'peg', 32, 57, 0, 1, r=3.6 * k)
    blanks = (bW, bE, bS)
    body = c.m(core, minus=blanks)
    c.add(body, STONE)
    # mortar courses (brick bond) on the stack
    if True:
        rows = [27, 33, 39, 45, 51] if not c.small else [28, 35, 42, 49]
        x0, x1 = c.P(13, 0)[0], c.P(51, 0)[0]
        for ri, ry in enumerate(rows):
            y = c.P(0, ry)[1]
            for x in range(x0 + 1, x1 - 1):
                if (x, y) in body:
                    c.px(x, y, MORTAR)
            # vertical joints
            step = 8 if not c.small else 6
            off = (ri % 2) * (step // 2)
            prev = c.P(0, rows[ri - 1] if ri else 22)[1]
            for x in range(x0 + 2 + off, x1 - 1, step):
                for yy in range(prev + 1, y):
                    if (x, yy) in body:
                        c.px(x, yy, MORTAR)
    # capstone band at top of stack
    c.add(body & c.m(rect(11, 22, 53, 26.5)), CAP)
    # chimney pot (peg tab)
    pot = c.m(tabN, minus=(core,))
    c.add(pot, POT)
    # ember glow in the pot mouth
    tx, ty = c.P(32, 22 - 1.0 - 1.8 * 6.0 * k)
    for dx in range(-2 if not c.small else -1, 3 if not c.small else 2):
        c.px(tx + dx, ty + 1, AMBER2)
    # peat smoke puff drifting up-right from the pot
    c.add(c.m(ell(46, 9, 7.5, 3.6), ell(43, 6.5, 3.8, 3.8), ell(49.5, 5.5, 4.4, 4.2), minus=(tabN,)), SMOKE)
    # moss and heather tufts at the foot
    c.add(body & c.m(ell(17, 58, 8, 5.5), ell(47, 58, 8, 5.5)), MOSS)
    for hx, hy in ((15.5, 51.5), (20.5, 52.5), (43.5, 52.5), (48.5, 51.5)):
        c.add(c.m(ell(hx, hy, 3.2, 3.0)) & body, HEATH)
    # face: felt eyes on the stone, amber hearth-glow mouth
    c.eye(24, 32, disc=True)
    c.eye(40, 32, disc=True)
    c.blush(18.5, 37)
    c.blush(44.5, 37)
    mx0, my0 = c.P(28, 37.5)
    mx1, my1 = c.P(36.5, 45)
    for x in range(mx0, mx1 + 1):
        for y in range(my0, my1 + 1):
            edge = x in (mx0, mx1) or y in (my0, my1) or (y == my0 + 1 and x in (mx0 + 1, mx1 - 1))
            corner = (x in (mx0, mx1) and y in (my0, my0 + 1, my1)) or (y == my0 and x in (mx0 + 1, mx1 - 1))
            if corner:
                continue
            c.px(x, y, K.UMBER if edge else (K.UMBER2 if y < my1 - (2 if not c.small else 1) else AMBER))


K.render_pal(fn, 'mm-peat-sip', 'Peat Sip', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mm-peat-sip-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mm-peat-sip.png')
