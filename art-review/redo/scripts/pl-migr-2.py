#!/usr/bin/env python3
"""pl-migr-2 "Faraway Dashes": a wildebeest that is an edge piece (edge-TBT, keyhole).
Flat S = the gold savanna strip it stands on (with a row of tiny far-off herd dashes), keyhole tab W = its head and muzzle
(the keyhole flare is the neck), keyhole tab E = its tufted tail, keyhole blank N = the dip of the back behind the high shoulder hump.
Colours from cell 8-4: slate-plum herd bodies, mauve-brown brindle, sunset orange, pale gold horizon."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

BODY = ramp('#4a3a52')
DARK = ramp('#2c2234')
BRIN = ramp('#7e5b55')
GOLD = ramp('#ffd78e')
GRASS = ramp('#c88a52')
HORN = ramp('#e8d8b0')
SUN = '#ff9a6c'
HERD = '#3c2e40'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(15, 16, 55, 58)
    head = knob('T', 'keyhole', 15, 30, -1, 0, r=7.0 * k, nw=3.4)
    tail = knob('T', 'keyhole', 55, 28, 1, 0, r=3.6 * k)
    dip = knob('B', 'keyhole', 38, 16, 0, -1, r=4.6 * k)
    body = c.m(core, tail, head, minus=(dip,))
    c.add(body, BODY, stitch=None)
    # shoulder hump + dark mane along the neck/back
    mane = c.m(poly([(14, 16), (30, 16), (32, 22), (22, 24), (14, 26)]))
    c.add(mane & body, DARK)
    # brindle stripes on the flank
    for sx in (28, 34, 40, 46):
        c.add(c.m(thick_path([(sx, 25), (sx - 2, 44)], 2.8 if c.small else 2.2)) & body, BRIN)
    # head (tab) dark, pale muzzle tip, beard under the chin
    hd = c.m(head, minus=(core,))
    c.add(hd, ramp('#6e5662'))
    c.add(c.m(ell(2.5, 32.5, 3.0, 3.6)) & hd, DARK)
    c.add(c.m(poly([(10, 34), (17, 33), (15, 44), (12, 40)])), DARK)
    # tail tuft dark end
    c.add(c.m(ell(61, 28, 3.4, 4.0)) & c.m(tail, minus=(core,)), DARK)
    # horns: curved hooks rising off the head
    hw = 3.0 if c.small else 2.4
    c.add(c.m(thick_path([(10.5, 24), (8, 20.5), (5, 18.5), (3.5, 15)], hw)), HORN)
    c.add(c.m(thick_path([(13, 24), (14.5, 19), (18, 16.5)], hw)), HORN)
    # savanna strip: sunset line, gold grass, legs, far-off herd dashes
    c.add(body & c.m(rect(0, 46, 64, 64)), GOLD)
    c.add(body & c.m(rect(0, 46, 64, 48.5)), ramp(SUN))
    c.add(body & c.m(rect(0, 54.5, 64, 64)), GRASS)
    for lx in (19, 25, 43, 49):
        c.add(c.m(rect(lx, 44, lx + (4 if c.small else 3.2), 54.5)), DARK)
    # tiny herd dashes on the horizon strip
    y = c.P(0, 50.5)[1]
    for hx in (30.5, 35, 39.5):
        x, _ = c.P(hx, 0)
        c.px(x, y, HERD); c.px(x + 1, y, HERD)
        if not c.small:
            c.px(x + 2, y, HERD); c.px(x, y + 1, HERD); c.px(x + 2, y + 1, HERD); c.px(x + 2, y - 1, HERD)
    c.eye(8, 29.5, disc=True, look=(-1, 0))


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-migr-2', 'Faraway Dashes', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-migr-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-migr-2.png'))
