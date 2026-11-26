"""pl-aurc-1 "Tent Flap": corner-TB, round. An orange A-frame camp tent that is a corner piece: flat W wall and flat S (snow) side,
round tab N = the tent's top knot with the red pennant flying off its pole, round blank E bitten into the right wall.
Pale yellow door flap down the middle (the face lives on it), periwinkle snow drift along the bottom (cell 3-4 snow blues)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, poly, knob, thick_path, ell, ramp

TENT = ramp('#f39a3e')
DOOR = ('#ffc85e', '#e0a040', '#fff4c0')
SNOW = ('#a2b0de', '#7c8cc8', '#d8e0f8')
FLAG = ramp('#e44a5c')
POLE = ramp('#7a4a1f')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = poly([(9, 57), (9, 36), (32, 15), (55, 36), (55, 57)])
    tabN = knob('T', 'round', 32, 17, 0, -1, r=4.6 * s)
    blankE = knob('B', 'round', 55, 45, 1, 0, r=4.2 * s)
    body = c.m(core, tabN, minus=(blankE,))
    c.add(body, TENT, stitch='#ffd08a')
    # pole and pennant above the knot
    pw = 2.0 if not c.small else 2.8
    c.add(c.m(thick_path([(32, 8), (32, 1.5)], pw)), POLE)
    c.add(c.m(poly([(32.5, 1), (45, 4.2), (32.5, 8.5)])), FLAG)
    # top knot (the tab) in a darker canvas tone
    c.add(c.m(tabN, minus=(core,)), ('#e07a30', '#b05a20', '#f8b060'))
    # door flap: pale triangle, light upper
    door = c.m(poly([(32, 22), (19, 57), (45, 57)]), minus=(blankE,))
    c.add(door, DOOR)
    c.edge(door, '#c06a20')
    c.add(door & c.m(poly([(32, 22), (27.5, 34), (36.5, 34)])), ('#fff4c0', '#ffe090', '#ffffff'))
    # snow drift along the bottom, wavy top
    snow = body & c.m(lambda x, y: y > 50 + (1.6 if (x // 5) % 2 else 0))
    c.add(snow, SNOW)
    if not c.small:
        for sx, sy in ((14, 54), (24, 55.5), (40, 54.5), (50, 55)):
            c.px(*c.P(sx, sy), '#ffffff')
    # tent seams down each roof slope
    if not c.small:
        c.line([(32, 20), (12, 38)], '#c06a20')
        c.line([(32, 20), (52, 38)], '#c06a20')
    c.eye(28.5, 41)
    c.eye(35.5, 41)
    c.smile(32, 45)
    c.blush(25.5, 45)
    c.blush(38.5, 45)


K.render_pal(fn, 'pl-aurc-1', 'Tent Flap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurc-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurc-1.png')
print(K.check(K.draw(fn, 64))['colours'])
