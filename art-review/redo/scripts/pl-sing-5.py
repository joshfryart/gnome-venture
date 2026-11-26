"""pl-sing-5 Tuckaway Ledge: inner-BBBB, double. A purple stone organ-pipe block (cell 7-4) with a dark ledge-cave tucked in its middle:
a blue waterfall curtain parted at both sides, shy disc eyes peering out of the dark, and the rare flowers sitting on the stone lip.
Double blanks cut into all four sides of the stone (N where the water pours in)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob

STONE = K.ramp('#948aa8')
STONED = K.ramp('#726888')
LIP = K.ramp('#b8aec8')
CAVE = ('#3e3650', '#2b1c26', '#564c6a')
WATER = ('#4a90d0', '#2f6aa8', '#a8d8f0')
GROOVE = '#564c6a'
PINK, YEL, WHT, LEAF = '#e8607e', '#f0c840', '#f4f0e4', '#5aa04a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(8, 8, 56, 56)
    bN = knob('B', 'double', 32, 8, 0, -1, r=4.6 * k)
    bS = knob('B', 'double', 32, 56, 0, 1, r=4.6 * k)
    bW = knob('B', 'double', 8, 30, -1, 0, r=4.4 * k)
    bE = knob('B', 'double', 56, 30, 1, 0, r=4.4 * k)
    blanks = (bN, bS, bW, bE)
    body = c.m(core, minus=blanks)
    c.add(body, STONE, stitch=None)
    # organ-pipe grooves and courses (cell motif)
    pipes = c.m(rect(8, 8, 56, 56), minus=blanks)
    for gx in (19, 45):
        g = c.m(rect(gx, 8, gx + (2.2 if c.small else 1.5), 56), minus=blanks)
        for p in g:
            c.edges[p] = GROOVE
    # cave: arched dark recess
    cave = c.m(ell(32, 31, 12, 11), rect(20, 31, 44, 42), minus=blanks)
    c.add(cave, CAVE)
    c.edge(cave, '#2b1c26')
    # stone lip (the ledge)
    lip = c.m(rect(12, 41.5, 52, 46.5), minus=blanks)
    c.add(lip, LIP)
    # course lines on stone
    for cy in (16, 50):
        for x in range(c.P(8, 0)[0], c.P(56, 0)[0]):
            p = (x, c.P(0, cy)[1])
            if p in body and p not in cave and p not in lip:
                c.px(p[0], p[1], GROOVE)
    # waterfall curtain parted on both sides of the cave: two falling sheets with white streaks and foam
    wl = c.m(rect(15, 18, 23.5, 42), minus=blanks)
    wr = c.m(rect(40.5, 18, 49, 42), minus=blanks)
    c.add(wl | wr, WATER)
    for sx, y0 in ((17.5, 21), (20.5, 26), (43.5, 24), (46.5, 20)):
        c.line([(sx, y0), (sx, y0 + 12)], WHT if not c.small else WATER[2])
    for fx in (15.5, 19, 22.5, 41.5, 45, 48.5):
        x, y = c.P(fx, 41.5)
        c.px(x, y, WHT)
        if not c.small:
            c.px(x + 1, y, WHT)
    # felt eyes peering from the dark
    c.eye(28, 30, disc=True)
    c.eye(36, 30, disc=True)
    # tucked flowers on the lip
    fl = [(25, 39.5, PINK), (32, 39, YEL), (39, 39.5, '#d8483a')]
    for fx, fy, col in fl:
        x, y = c.P(fx, fy)
        if c.small:
            for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 0)):
                c.px(x + dx, y + dy, col)
            c.px(x, y, YEL if col != YEL else WHT)
        else:
            for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1), (-1, -1), (1, -1), (-1, 1), (1, 1)):
                if abs(dx) + abs(dy) < 2:
                    c.px(x + dx, y + dy, col)
            c.px(x - 1, y - 1, col if (x + y) % 2 else K.ramp(col)[2])
            c.px(x, y, YEL if col != YEL else WHT)
            c.px(x, y + 2, LEAF)


rep = K.render_pal(fn, 'pl-sing-5', 'Tuckaway Ledge', '/home/user/gnome-venture/art-review/redo/out',
                   cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sing-5-cell.png',
                   oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sing-5.png')
print(rep)
