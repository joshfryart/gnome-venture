"""pl-drmc-6 Hut Dweller (rare, whimsy-hut, peg).
Concept: a round mud hut whose thatched cone roof + square mud wall IS the piece: N peg tab = the roof's smoke-hole cap,
E peg tab off the wall, W peg blank cut into the wall, S flat ground. Lit arched doorway is the mouth, eyes under the eaves,
a string of festival lanterns around the eaves (cell 2-3: purple night sky with lantern lights; picture: golden thatch huts, glowing windows)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, UMBER, UMBER2

THATCH = K.ramp('#d8a850')
MUD = K.ramp('#a8683a')
NIGHT = K.ramp('#5a3a8c')
GLOW = ('#f8c850', '#e07a28', '#fff0a0')
LANTERNS = ('#f0a020', '#ec74ac', '#f8d060', '#e0483a', '#7fd0c8')


def fn(c):
    k = 1.15 if c.small else 1.0
    roof = poly([(27, 11), (37, 11), (56, 31), (8, 31)])
    wall = rect(12, 30, 52, 55)
    tabN = knob('T', 'peg', 32, 11, 0, -1, r=4.2 * k)
    tabE = knob('T', 'peg', 52, 43, 1, 0, r=4.5 * k)
    blkW = knob('B', 'peg', 12, 43, -1, 0, r=4.5 * k)
    c.add(c.m(wall, tabE, minus=(blkW,)), MUD, stitch=None if c.small else '#c88a58')
    c.add(c.m(roof, tabN), THATCH)
    # purple smoke-hole cap on the peg (night sky colour)
    c.add(c.m(tabN, minus=(roof,)), NIGHT)
    # purple dusk shade on the wall foot (the cell's night hills)
    c.add(c.m(rect(12, 51, 52, 56), minus=(blkW,)), NIGHT)
    # thatch straw lines
    if not c.small:
        for x0, x1 in ((30, 22), (34, 42)):
            c.line([(x0, 14), (x1, 28)], THATCH[1])
        c.line([(32, 14), (32, 28)], THATCH[1])
    else:
        c.line([(30, 15), (24, 27)], THATCH[1])
        c.line([(34, 15), (40, 27)], THATCH[1])
    # eave shadow line under the roof
    c.line([(12, 31.5), (51.5, 31.5)], MUD[1])
    # lantern string across the eaves
    for i, lx in enumerate((14, 22, 32, 42, 50)):
        x, y = c.P(lx, 29 if lx in (14, 50) else 30)
        col = LANTERNS[i]
        c.px(x, y, col)
        c.px(x + 1, y, col)
        if not c.small:
            c.px(x, y + 1, col)
            c.px(x + 1, y + 1, col)
    # lit arched doorway = mouth
    door = c.m(rect(27.5 - k, 45, 38.5 + k, 56), ell(33, 45, 5.5 + k, 5.5 + k))
    c.add(door, GLOW)
    inner = c.m(rect(30, 47.5, 36, 56), ell(33, 47.5, 3, 3))
    for p in inner:
        c.px(*p, GLOW[2] if p[1] < c.P(0, 51)[1] else GLOW[0])
    c.edge(door, UMBER2)
    # face under the eaves
    c.eye(25, 38)
    c.eye(41, 38)
    c.blush(20, 42)
    c.blush(45, 42)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-drmc-6', 'Hut Dweller', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-drmc-6-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-drmc-6.png'))
