#!/usr/bin/env python3
"""pl-tgm-3 "Temple Chip": inner-TBBB, peg. A stepped sandstone temple block (cell 7-5): N peg tab = the little shrine capstone on the top step,
W / E / S peg blanks cut into the lower block. Its face lives in the slate window niche with the orange L glyph brackets; grey mortar course below."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#b8a47a')
STONE2 = ('#d8c494', '#b8a47a', '#ecd8a8')
SLATE = K.ramp('#4a4458')
GREY = '#7c7068'
GLYPH = '#ffb84a'
CREAMS = '#ecd8a8'


def fn(c):
    k = 1.15 if c.small else 1.0
    top = K.rect(21, 16, 43, 25)
    mid = K.rect(15, 24, 49, 37)
    base = K.rect(9, 36, 55, 58)
    tabN = K.knob('T', 'peg', 32, 16, 0, -1, r=4.4 * k)
    blW = K.knob('B', 'peg', 9, 48, -1, 0, r=4.0 * k)
    blE = K.knob('B', 'peg', 55, 48, 1, 0, r=4.0 * k)
    blS = K.knob('B', 'peg', 32, 58, 0, 1, r=3.8 * k)
    body = c.m(base, mid, top, tabN, minus=(blW, blE, blS))
    c.add(body, STONE, stitch=None)
    for part in (c.m(mid) & body, c.m(top, tabN) & body):
        c.add(part, STONE2 if part is not None else STONE)
    c.edge(c.m(mid, top, tabN) & body, GREY)
    c.edge(c.m(top, tabN) & body, GREY)
    # mortar course in the base
    y0 = c.P(0, 39.5)[1]
    for x in range(c.n):
        if (x, y0) in body:
            c.px(x, y0, SLATE[0])
    # sandstone speckles (grey and cream, like the cell)
    sp = [(12, 40, GREY), (50, 41, CREAMS), (13, 54, CREAMS), (51, 54, GREY), (24, 19, GREY), (39, 21, CREAMS),
          (18, 27, GREY), (46, 33, GREY), (17, 33, CREAMS), (45, 27, CREAMS), (23, 54, GREY), (41, 49, CREAMS),
          (22, 48, CREAMS), (36, 18, GREY), (26, 22, CREAMS)]
    for (sx, sy, col) in sp:
        x, y = c.P(sx, sy)
        c.px(x, y, col)
        if not c.small:
            c.px(x + 1, y, col)
    # slate window niche = the face, with the orange L glyph
    niche = c.m(K.rect(22, 27, 42, 45))
    c.add(niche, SLATE)
    c.edge(niche, '#2b1c26')
    w = 2.6 if c.small else 2.0
    c.add(c.m(K.thick_path([(25.5, 37.5), (25.5, 41.5), (38.5, 41.5)], w)), (GLYPH, GLYPH, GLYPH))
    c.eye(28, 33, disc=True)
    c.eye(36.5, 33, disc=True)
    c.blush(19, 34)
    c.blush(45, 34)

if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-tgm-3', 'Temple Chip', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tgm-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tgm-3.png'))
