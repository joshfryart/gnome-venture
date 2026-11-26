#!/usr/bin/env python3
# pl-wfri-3 "Mycelium Twinkles": a fat pink toadstool that is an inner-TBTB keyhole piece.
# Top tab = the knob on the cap dome, left/right blanks cut into the cream stem, bottom tab = a mossy root
# with golden mycelium threads. Colours from cell 8-7: pink cap, cream spots and stem, green grass, gold sparkles.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CAP = K.ramp('#d4507a')
CAPDK = ('#a63e64', '#7a2c4a', '#c45a80')
STEM = ('#f4e8d0', '#c9b896', '#fff8e8')
MOSS = K.ramp('#4a9a5c')
GOLD = K.GOLD
SPOT = '#fff4d6'
D = '/home/user/gnome-venture/'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(12, 28, 52, 54)
    cap = K.ell(32, 31, 21.5, 19)
    capcut = K.rect(0, 0, 64, 34)
    tabT = K.knob('T', 'keyhole', 32, 12.5, 0, -1, r=4.2 * s)
    tabB = K.knob('T', 'keyhole', 32, 54, 0, 1, r=4.2 * s)
    blL = K.knob('B', 'keyhole', 12, 44, -1, 0, r=3.4 * s)
    blR = K.knob('B', 'keyhole', 52, 44, 1, 0, r=3.4 * s)
    capm = lambda x, y: cap(x, y) and capcut(x, y)
    body = c.m(core, capm, tabT, tabB, minus=(blL, blR))
    # stem (cream) is the lower body
    stem = c.m(core, tabB, minus=(blL, blR))
    c.add(stem, STEM, stitch='#c9b896')
    # moss skirt along the bottom and the root tab
    moss = c.m(K.rect(0, 49, 64, 64), tabB) & body
    c.add(moss, MOSS)
    # cap on top (with its keyhole knob)
    capmask = c.m(capm, tabT) & body
    c.add(capmask, CAP, stitch=CAPDK[0])
    # darker underside band of the cap rim
    under = c.m(K.rect(0, 30.5, 64, 34)) & capmask
    c.add(under, CAPDK)
    c.edge(capmask, CAPDK[1])
    # cream spots on the cap
    for (x, y, r) in ((20, 24, 2.6), (32, 17, 2.0), (43, 23, 2.8), (27, 28, 1.6), (38, 28.5, 1.5)):
        if c.small and r < 1.8:
            continue
        for p in c.m(K.ell(x, y, r * s, r * s)) & capmask:
            c.px(p[0], p[1], SPOT)
    # gold mycelium threads in the moss and root, with twinkles
    thr = [(24, 51), (28, 55), (32, 58), (36, 55), (41, 51)]
    w = 2.6 if c.small else 1.6
    for p in c.m(K.thick_path(thr, w)) & moss:
        c.px(p[0], p[1], GOLD[0])
    for p in c.m(K.thick_path([(32, 58), (32, 62)], w)) & moss:
        c.px(p[0], p[1], GOLD[2])
    for (x, y) in ((18, 51), (46, 52)):
        cx, cy = c.P(x, y)
        c.px(cx, cy, GOLD[2])
        if not c.small:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(cx + dx, cy + dy, GOLD[0])
    # face on the stem
    c.eye(27, 39)
    c.eye(37, 39)
    c.smile(32, 44)
    c.blush(23, 43)
    c.blush(40, 43)


K.render_pal(fn, 'pl-wfri-3', 'Mycelium Twinkles', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=D + 'art-review/redo/_src/pl-wfri-3-cell.png',
             oldfile=D + 'game/assets/img/puzzles/pals/pl-wfri-3.png')
