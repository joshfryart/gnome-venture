#!/usr/bin/env python3
# Pan Ting: a steel pan drum on its stand, as a corner piece.
# Flat top (the pan's rim) + flat left; right side = round TAB (the mallet's rubber ball); bottom = round BLANK (the arch between the stand's legs).
# Colours from cell 4-6: lavender-steel pan (#a8a4c4 / #d8d4e8 / #625c88), sand (#f2c890), driftwood barrel (#a05c40), plum shade (#6e3a48).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STEEL = ('#a8a4c4', '#7a74a0', '#d8d4e8')
BOWL = ('#c0bcd6', '#8a86ae', '#e6e2f2')
DIM = '#7a74a0'
LEG = ('#625c88', '#4a4470', '#8a86ae')
SAND = K.ramp('#f2c890')
BALL = K.ramp('#c0583c')
STICK = '#b1764a'
BAND = ('#ffd060', '#c89a30', '#ffe9a0')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 8, 50, 10, 56
    core = K.rect(x0, y0, x1, y1)
    tab = K.knob('T', 'round', x1, 30, 1, 0, r=5.0 * k)
    blank = K.knob('B', 'round', 32, y1, 0, 1, r=6.0 * k, nw=3.4 * k)
    body = c.m(core, tab, minus=(blank, K.rect(0, 0, 64, y0), K.rect(0, 0, x0, 64)))
    # sand ground behind the stand fills everything first
    c.add(body, SAND)
    # stand: two splayed legs + crossbar (steel-dark), feet on the sand
    legs = c.m(K.thick_path([(22, 38), (11, 55)], 4.2), K.thick_path([(36, 38), (47, 55)], 4.2),
               K.rect(15, 44, 43, 47.2), K.rect(26, 38, 32, 46), minus=(blank,))
    c.add(legs & body, LEG)
    # pan skirt: the drum body, chrome with vertical gleams
    skirt = c.m(K.rect(x0, y0, x1, 37))
    c.add(skirt, STEEL)
    for gx in (12, 46):
        c.line([(gx, 26), (gx, 34)], '#e6e2f2')
    # gold band around the bottom of the skirt
    c.add(c.m(K.rect(x0, 34, x1, 38)), BAND)
    # pan top surface: a wide ellipse, clipped flat at the top rim
    top = c.m(K.ell(29, 18.5, 20.5, 8.5), minus=(K.rect(0, 0, 64, y0),))
    top &= body
    c.add(top, BOWL)
    c.edge(top, DIM)
    # note dimples on the playing surface
    for (dx, dy, rx, ry) in ((18, 15, 4.2, 2.8), (29, 13, 4.0, 2.4), (40, 15, 4.2, 2.8), (29, 20.5, 5.0, 2.8)):
        if c.small and dy == 20.5:
            continue
        d = c.m(K.ell(dx, dy, rx, ry))
        c.edge(d, DIM)
    # mallet: wooden handle neck + rubber ball (the tab)
    out = c.m(tab, minus=(core,))
    c.add(out, BALL)
    c.add(c.m(K.rect(x1, 28.4, x1 + 3.0 * k, 31.6)) & out, (STICK, '#8a5438', '#d8985c'))
    # face on the skirt
    c.eye(21, 27, disc=False)
    c.eye(36, 27, disc=False)
    c.smile(28.5, 30.5)
    c.blush(15, 30)
    c.blush(41, 30)


K.render_pal(fn, 'pl-drft-1', 'Pan Ting', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-drft-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-drft-1.png')
