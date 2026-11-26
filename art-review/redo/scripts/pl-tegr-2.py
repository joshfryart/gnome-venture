#!/usr/bin/env python3
"""pl-tegr-2 "Magenta Muffler": a knitted magenta scarf wound into an edge piece (edge-TTB, keyhole).
Keyhole blank N = the scarf loop's neck opening, keyhole tabs W and E = the wound coils bulging out, flat S hem.
Two fringed tails hang off the lower right. Knit ribs in magenta, tea-green stripes and pink blossoms from cell 5-6 (tea bushes),
stone-cream fringe from the terrace wall."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MAGR = K.ramp('#c8327a')
TEAG = K.ramp('#4e9a48')
STONE = K.ramp('#e8d4a8')
PINK = '#f29ac0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(10, 15, 52, 50)
    tabW = K.knob('T', 'keyhole', 10, 31, -1, 0, r=4.4 * k)
    tabN = K.knob('T', 'keyhole', 24, 15, 0, -1, r=4.4 * k)
    blankE = K.knob('B', 'keyhole', 52, 31, 1, 0, r=3.9 * k)
    body = c.m(core, tabW, tabN, minus=(blankE,))
    c.add(body, MAGR)
    # classic striped scarf: green + cream stripes across the wound body
    for y0, rmp, h in ((20, TEAG, 3.4), (23.4, STONE, 1.8), (41, STONE, 1.8), (42.8, TEAG, 3.4)):
        c.add(c.m(K.rect(0, y0, 64, y0 + h)) & body, rmp)
    # knit texture: rows of small v stitches in a mid magenta
    mid = '#a82868'
    vy = 3
    for (x, y) in body:
        if (y // 3) % 1 == 0 and (((x % 4 == 0 or x % 4 == 2) and y % vy == 0) or (x % 4 == 1 and y % vy == 1)):
            if not c.small or (x + y) % 2 == 0:
                c.px(x, y, mid)
    # knot on top: tab N is the tied knot, a shade darker with a twist line
    knot = c.m(tabN, minus=(core,))
    c.add(knot, K.ramp('#b02a6c'))
    c.line([(21.5, 7), (26.5, 12)], MAGR[1])
    # fringe along the flat hem: cream tassels hanging 3 units
    fr = c.m(lambda x, y: 50 <= y < 54 and 11 <= x < 51 and int(x / (2 if not c.small else 2.6)) % 2 == 0)
    c.add(fr, STONE)
    c.add(c.m(K.rect(10, 48, 52, 50)) & body, K.ramp('#8e1f58'))
    # pink tea blossoms on the green stripes
    for (bx, by) in ((16, 21.5), (44, 44.5), (36, 21.5)):
        x, y = c.P(bx, by)
        c.px(x, y, PINK)
        if not c.small:
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(x + dx, y + dy, PINK)
            c.px(x, y, '#f8e070')
    # face in the wide magenta band
    c.eye(24, 31.5, disc=True)
    c.eye(36, 31.5, disc=True)
    c.blush(20, 35)
    c.blush(40, 35)
    c.smile(30, 35)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-tegr-2', 'Magenta Muffler', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tegr-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tegr-2.png'))
