#!/usr/bin/env python3
"""pl-ana-5 "Coil Nest": inner-BBBB, peg. A square bark-and-moss nest (the hollow tree of cell 7-6) with a green anaconda coiled
round and round inside it, head resting in the middle. Four peg blanks bite into the mid-sides; the snake hugs the rim."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BARK = K.ramp('#8c5a48')
SOIL = ('#5c3c34', '#3e2a2a', '#8c5a48')
MOSS = K.ramp('#4e9a4c')
SNAKE = ('#8fc55e', '#5a9a44', '#c4ea78')
BELLY = K.ramp('#c4ea78')
SPOT = '#2e6a46'
YEL = '#f0c030'


def fn(c):
    S = 1.15 if c.small else 1.0
    core = lambda x, y: 6 <= x < 58 and 6 <= y < 58 and not (
        min(x - 6, 58 - x) < 6 and min(y - 6, 58 - y) < 6 and
        (min(x - 6, 58 - x) - 6) ** 2 + (min(y - 6, 58 - y) - 6) ** 2 > 36)
    blanks = (K.knob('B', 'peg', 32, 6, 0, -1, r=4.2 * S),
              K.knob('B', 'peg', 58, 32, 1, 0, r=4.2 * S),
              K.knob('B', 'peg', 32, 58, 0, 1, r=4.2 * S),
              K.knob('B', 'peg', 6, 32, -1, 0, r=4.2 * S))
    body = c.m(core, minus=blanks)
    c.add(body, BARK, stitch='#b07a5a')
    # dark hollow floor of the nest
    c.add(body & c.m(K.rect(9, 9, 55, 55)), SOIL)
    # moss tufts on the rim corners
    c.add(body & c.m(K.ell(10, 54, 6, 5), K.ell(54, 10, 6, 5), K.ell(54, 55, 5, 4)), MOSS)
    # the coil: outer loop hugs the rim, steps in to an inner loop, head in the middle
    w = 7.0 if not c.small else 8.0
    path = [(38, 51), (16, 51), (13, 48), (13, 16), (16, 13), (48, 13), (51, 16), (51, 42), (46, 40),
            (28, 40), (25, 37), (25, 27), (28, 25), (36, 25)]
    tail = K.thick_path([(48, 52.5), (43, 51.5), (38, 51)], 4.0 if not c.small else 5.0)
    coil = c.m(K.thick_path(path, w), tail, minus=blanks) & body
    c.add(coil, SNAKE)
    c.edge(coil, SPOT)
    # head resting in the middle of the coil
    head = c.m(K.ell(35, 31.5, 8.2 if c.small else 7.0, 6.2 if c.small else 5.2)) & body
    c.add(head, SNAKE)
    c.edge(head, SPOT)
    c.add(c.m(K.ell(36, 34.5, 4.5, 1.8)) & head, BELLY)
    # spots along the coil (anaconda rosettes)
    for sx, sy in ((22, 51), (32, 51), (13, 24), (13, 40), (24, 13), (42, 13), (51, 24), (51, 34), (40, 40), (25, 32)):
        x, y = c.P(sx, sy)
        c.px(x, y, SPOT)
        if not c.small:
            c.px(x + 1, y, SPOT)
            c.px(x, y + 1, SPOT)
            c.px(x + 1, y + 1, SPOT)
    # sleepy-cosy face: yellow anaconda eyes with felt pupils
    for ex in (32, 39):
        x, y = c.P(ex, 30)
        if c.small:
            c.px(x, y, YEL); c.px(x + 1, y, YEL); c.px(x, y + 1, K.UMBER); c.px(x + 1, y + 1, K.UMBER)
        else:
            for dx in (-1, 0, 1):
                c.px(x + dx, y - 1, YEL)
                c.px(x + dx, y, YEL)
            c.px(x, y, K.UMBER); c.px(x, y + 1, K.UMBER); c.px(x - 1, y - 1, '#fff4c0')
    c.smile(35.5, 33)
    tx, ty = c.P(35.5, 36)
    c.px(tx, ty, '#d8322b')


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-ana-5', 'Coil Nest', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ana-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ana-5.png'))
