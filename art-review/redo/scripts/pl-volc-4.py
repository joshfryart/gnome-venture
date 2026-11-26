#!/usr/bin/env python3
"""Pinkpetal Rows (pl-volc-4), inner-TTTT keyhole: a terrace flower-bed planter whose box IS the piece.
N keyhole tab = a big pink bloom on its stem (the keyhole ball is the flower head), E + W keyhole tabs = the planter's stone handles,
S keyhole tab = the planter's foot. Body: stripes of orange and red blooms on dark soil split by grey stone terrace walls
(cell 4-5 of the volcano spice gardens), a brown soil-box front wearing the face."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SOIL = K.ramp('#7a4a2a')
DIRT = ('#4a2c1a', '#3a2214', '#6a4028')
STONE = K.ramp('#9a96a0')
ORG = '#f08a30'
ORGD = '#c0601a'
RED = '#e8443a'
REDD = '#a8281e'
PINK = K.ramp('#ec74ac')
PINKL = '#f6b8cf'
LEAF = K.ramp('#3f9a4a')
GOLDC = '#f5cf6a'


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 12, 20, 52, 54
    core = K.rect(x0, y0, x1, y1)
    tabN = K.knob('T', 'keyhole', 32, y0, 0, -1, r=6.2 * k, nw=2.2)
    tabE = K.knob('T', 'keyhole', x1, 46, 1, 0, r=4.2 * k, nw=2.4)
    tabW = K.knob('T', 'keyhole', x0, 46, -1, 0, r=4.2 * k, nw=2.4)
    tabS = K.knob('T', 'keyhole', 32, y1, 0, 1, r=4.0 * k, nw=2.4)
    body = c.m(core)
    c.add(body, DIRT)
    # pink bloom on its stem (N tab): green stem/neck, pink flower head
    flower = c.m(tabN, minus=(core,))
    c.add(flower, LEAF)
    head = c.m(K.ell(32, 9.2 if not c.small else 8.0, 6.4 * k, 6.0 * k)) & flower
    c.add(head, PINK)
    # handles + foot in terrace stone / soil
    c.add(c.m(tabE, tabW, minus=(core,)), SOIL)
    c.add(c.m(tabS, minus=(core,)), SOIL)
    # stone terrace walls
    w1 = c.m(K.rect(x0, 29.5, x1, 32))
    c.add(w1, STONE)
    # front of the planter: brown wooden box with a stone rim
    c.add(c.m(K.rect(x0, 40, x1, y1)), SOIL)
    c.add(c.m(K.rect(x0, 40, x1, 42.5)), STONE)
    # rows of blooms: orange row on top, red row in the middle
    def blooms(yc, col, dk, n):
        step = (x1 - x0) / n
        for i in range(n):
            bx = x0 + step * (i + 0.5)
            px, py = c.P(bx, yc)
            if c.small:
                lv = [(-1, 2), (1, 2)]
                pts = [(0, -1), (1, -1), (-1, 0), (0, 0), (1, 0), (2, 0), (0, 1), (1, 1)]
                ctr = (0, 0)
            else:
                lv = [(-2, 3), (-1, 3), (2, 3), (3, 3), (-1, 2), (2, 2)]
                pts = [(0, -3), (1, -3), (-1, -2), (0, -2), (1, -2), (2, -2), (-2, -1), (-1, -1), (0, -1), (1, -1), (2, -1), (3, -1),
                       (-2, 0), (-1, 0), (0, 0), (1, 0), (2, 0), (3, 0), (-1, 1), (0, 1), (1, 1), (2, 1)]
                ctr = (0, -1)
            for dx, dy in lv:
                c.px(px + dx, py + dy, LEAF[0])
            for dx, dy in pts:
                c.px(px + dx, py + dy, col)
            for dx, dy in pts:
                if (dx + 1, dy + 1) not in pts:
                    c.px(px + dx, py + dy, dk)
            c.px(px + ctr[0], py + ctr[1], PINKL)
    blooms(24.0, ORG, ORGD, 4)
    blooms(35.0, RED, REDD, 4)
    # pink centre dots (the "pink petals")
    # flower head detail
    hx, hy = c.P(32, 9.2 if not c.small else 8.0)
    c.px(hx, hy, GOLDC)
    if not c.small:
        c.px(hx - 1, hy, GOLDC)
        c.px(hx, hy - 1, GOLDC)
        c.px(hx - 1, hy - 1, GOLDC)
        for (a, b) in ((-4, -1), (3, -1), (-1, -4), (-1, 3)):
            c.px(hx + a, hy + b, PINK[1])
        c.px(hx - 3, hy - 3, PINKL)
        c.px(hx - 2, hy - 4, PINKL)
    # leaf on the stem
    lx, ly = c.P(34.5, 17)
    for dx, dy in ([(0, 0), (1, 0), (1, -1), (2, -1)] if not c.small else [(0, 0), (1, -1)]):
        c.px(lx + dx, ly + dy, LEAF[2])
    # face on the planter front
    c.eye(26, 47, disc=False)
    c.eye(38, 47, disc=False)
    c.smile(32, 50)
    c.blush(21.5, 50.5)
    c.blush(42, 50.5)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-volc-4', 'Pinkpetal Rows', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-volc-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-volc-4.png'))
