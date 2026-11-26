#!/usr/bin/env python3
"""pl-stnd-3 "Lilac Sprinkle": inner-TBTB keyhole. A little mossy standing stone (the lilac-grey sarsens of the Standing Stones picture).
N keyhole tab = the stone's rounded cap, S keyhole tab = a grass tuft at its foot, keyhole blanks bite in from E and W.
Moss patches, a glowing cyan rune and lilac star flecks sprinkled over it (cell 7-7: mossy stone foot on the grass ring)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = ('#8a82ac', '#5a5480', '#b4acd4')
STONE_D = ('#6e6694', '#4a4468', '#8a82ac')
MOSS = K.ramp('#4a8a4e')
GRASS = K.ramp('#3f8a5a')
RUNE = '#7fe8dc'
LILAC = '#d8b8f8'
LILAC2 = '#b088e0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(14, 15), (18, 11), (46, 11), (50, 15), (51, 50), (48, 53), (16, 53), (13, 50)])
    tabN = K.knob('T', 'keyhole', 32, 11, 0, -1, r=6.0 * k, nw=3.4)
    tabS = K.knob('T', 'keyhole', 32, 53, 0, 1, r=5.6 * k, nw=3.4)
    blE = K.knob('B', 'keyhole', 51, 38, 1, 0, r=4.0 * k)
    blW = K.knob('B', 'keyhole', 13, 38, -1, 0, r=4.0 * k)
    stone = c.m(core, tabN, minus=(blE, blW, K.rect(0, 52, 64, 64)))
    c.add(stone, STONE, stitch=None if c.small else '#a49cc8')
    # darker lower-right flank of the stone (lit from the upper left)
    flank = stone & c.m(lambda x, y: x > 43 and y > 14)
    c.add(flank, STONE_D)
    c.edge(flank, STONE[1])
    # grass skirt + S tuft
    grass = c.m(K.rect(11, 49, 53, 54), tabS, minus=(blE, blW)) | (c.m(lambda x, y: 11 < x < 53 and y > 47 - (2.5 if (int(x) // 3) % 2 else 0) and y < 54))
    c.add(grass, GRASS)
    # moss patches (cell: green clumps on the stone)
    for (mx, my, rx, ry) in ((20, 16, 4, 2.6), (45, 19, 3, 2.6), (40, 43, 3.6, 2.4), (19, 43, 3, 2.2)):
        c.add(stone & c.m(K.ell(mx, my, rx, ry)), MOSS)
    # crack
    if not c.small:
        c.line([(33, 33), (31, 37), (33, 40)], STONE[1])
    # cyan rune on the cap
    rx, ry = c.P(32, 5.5)
    for dy in range(-2 if not c.small else -1, 3 if not c.small else 2):
        c.px(rx, ry + dy, RUNE)
    c.px(rx - 1, ry - 1, RUNE)
    c.px(rx + 1, ry + (1 if not c.small else 0), RUNE)
    # lilac sprinkle flecks (stars spilled on stone and grass)
    flecks = [(18, 22), (46, 13), (35, 50), (22, 51), (44, 51), (26, 37), (38, 38), (30, 14)]
    for (fx, fy) in (flecks if not c.small else flecks[:6]):
        x, y = c.P(fx, fy)
        c.px(x, y, LILAC)
        if not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(x + d[0], y + d[1], LILAC2)
    # face
    c.eye(25.5, 24, disc=True)
    c.eye(37.5, 24, disc=True)
    c.blush(21.5, 29)
    c.blush(40.5, 29)
    c.smile(31.5, 29)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-stnd-3', 'Lilac Sprinkle', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stnd-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stnd-3.png'))
