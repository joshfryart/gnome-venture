"""pl-lemn-2 "Cowl Hum": edge-TTB, peg. A brown-robed monk, face peeking from his cowl. Flat S (robe hem on the
grove's grass), peg tab N (the cowl's peak), peg tab W (a sleeve holding a sprig of herbs), peg blank E (cut into the robe).
Grass hem and herb greens from cell 10-6 (hedge green + yellow-green lawn); lemon-gold rope belt from the grove."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

ROBE = ramp('#5e3c26')
HOOD = ramp('#8e6040')
SKIN = ramp('#f0c8a0')
GRASS = ramp('#b1cc64')
HEDGE = ramp('#3e784a')
LEAF = ramp('#8ab850')
ROPE = ramp('#e8c040')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = rect(13, 17, 51, 59)
    tabN = knob('T', 'peg', 32, 17, 0, -1, r=4.6 * s, nw=3.2)
    tabW = knob('T', 'peg', 13, 44, -1, 0, r=4.8 * s, nw=3.0)
    blankE = knob('B', 'peg', 51, 36, 1, 0, r=4.6 * s, nw=2.8)
    corners = (lambda x, y: y < 23 and (x < 13 + 6 - ((6 - (23 - y)) if 23 - y < 6 else 0) and ((x - 19) ** 2 + (y - 23) ** 2 > 36) and x < 19),
               lambda x, y: y < 23 and x >= 45 and (x - 45) ** 2 + (y - 23) ** 2 > 36)
    body = c.m(core, tabN, tabW, minus=(blankE,) + corners)
    c.add(body, ROBE)
    # cowl: rounded hood covering the top, peak = top tab
    hood = c.m(ell(31, 30, 13.5, 14), tabN, poly([(22, 22), (32, 9), (42, 22)])) & body
    c.add(hood, HOOD)
    c.edge(hood, HOOD[1])
    # face opening
    face = c.m(ell(32, 31, 9.5, 8.5))
    c.add(face, SKIN)
    c.edge(face, HOOD[1])
    # shadow brow inside hood
    c.add(c.m(ell(32, 24.5, 9.5, 3.0)) & face, HOOD)
    # eyes closed-ish humming: felt eyes + round 'o' mouth
    c.eye(28, 30)
    c.eye(36, 30)
    c.blush(25, 34)
    c.blush(38, 34)
    mx, my = c.P(32, 35.5)
    if c.small:
        c.px(mx, my, '#8a3a2a'); c.px(mx - 1, my, '#8a3a2a')
    else:
        for dx, dy in ((0, 0), (-1, 0), (0, 1), (-1, 1)):
            c.px(mx + dx, my + dy, '#8a3a2a')
    # rope belt, lemon gold
    belt = c.m(rect(13, 45, 51, 48.5)) & body
    c.add(belt, ROPE)
    if not c.small:
        c.add(c.m(thick_path([(40, 48), (41, 54)], 2.6)) & body, ROPE)
    # sleeve on the west tab with hands + herb sprig
    sleeve = c.m(tabW, poly([(10, 39), (20, 37), (27, 44), (27, 50), (10, 50)])) & body
    c.add(sleeve, HOOD)
    c.edge(sleeve, HOOD[1])
    c.add(c.m(ell(5.5, 44, 2.6, 2.8)) & body, SKIN)
    # herb sprig: green leaves in the tab, held by the hand
    sprig = c.m(ell(4.5, 39.5, 3.4, 3.6), ell(9, 38.5, 2.6, 3.2)) & body
    c.add(sprig, LEAF)
    if not c.small:
        c.px(*c.P(5, 39), HEDGE[1]); c.px(*c.P(9, 38), HEDGE[1])
    # grass hem: the grove lawn at the robe's foot
    hem = c.m(lambda x, y: y >= 54 + (1.5 if (int(x) // 3) % 2 else 0)) & body
    c.add(hem, GRASS)
    c.add(c.m(lambda x, y: y >= 57.5 and 13 <= x < 51 and (int(x) // 5) % 3 == 0) & body, HEDGE)
    if not c.small:
        # a tiny hummed note stitched on the robe
        nx, ny = c.P(22, 50)
        for d in range(4):
            c.px(nx + 1, ny - d, ROPE[2])
        c.px(nx, ny, ROPE[2]); c.px(nx + 2, ny - 3, ROPE[2])


K.render_pal(fn, 'pl-lemn-2', 'Cowl Hum', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lemn-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lemn-2.png')
