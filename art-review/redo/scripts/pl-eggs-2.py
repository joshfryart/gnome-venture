"""pl-eggs-2 "Dabbing Painter": edge-TTB, peg.
A gnome painter that IS an edge piece: flat S side is the grass he stands in, N peg tab is the tip of his red
egg-striped hat, W peg tab is his paintbrush dipped in red, E peg blank bites into his smock.
Colours from cell 4-6 (mauve house wall, peach sky, grass greens, wood post) + the red/yellow striped egg on the roof."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

HAT = ramp('#d6382c')
YEL = ramp('#f2c02e')
WALLC = ramp('#b897a6')
SKIN = ramp('#eab48c')
BEARD = ramp('#f4ece0')
GRASS = ramp('#86c24a')
GRASSD = ramp('#4f9a4c')
WOODC = ramp('#b0703a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(12, 59), (12, 31), (14, 29), (24, 15), (40, 15), (50, 29), (52, 31), (52, 59)])
    tabN = knob('T', 'peg', 32, 15, 0, -1, r=4.6 * k)
    tabW = knob('T', 'peg', 12, 43, -1, 0, r=4.6 * k)
    blankE = knob('B', 'peg', 52, 43, 1, 0, r=4.4 * k)
    body = c.m(core, tabN, tabW, minus=(blankE,))
    # smock (house wall mauve)
    c.add(body, WALLC)
    # hat: brim band across the whole top + the peg tip; yellow egg stripe
    hat = body & c.m(rect(0, 0, 64, 31.5))
    c.add(hat, HAT)
    stripe = body & c.m(rect(0, 8, 64, 10.5), rect(0, 19, 64, 22), rect(0, 26, 64, 29))
    c.add(stripe, YEL)
    c.add(body & c.m(rect(0, 29, 64, 31.5)), HAT)
    # face + beard
    face = c.m(ell(32, 35, 11, 6)) & body - hat
    c.add(face, SKIN)
    beard = c.m(poly([(20, 37), (44, 37), (40, 47), (32, 53), (24, 47)])) & body
    c.add(beard, BEARD)
    c.edge(beard, BEARD[1])
    # nose
    c.add(c.m(ell(32, 37, 3.2, 2.6)), ramp('#e8907a'))
    # brush: W peg = red bristles, wooden handle across the smock to a hand
    brushtip = c.m(tabW, minus=(rect(12, 0, 64, 64),))
    c.add(brushtip, HAT)
    c.add(c.m(rect(9, 41.2, 13.5, 44.8)) & body, ramp('#c9c5bc'))
    c.add(c.m(thick_path([(13, 43), (22, 45)], 3.2 if c.small else 2.6)) & body, WOODC)
    c.add(c.m(ell(23, 45.5, 3, 2.8)) & body, SKIN)
    # paint dabs on smock
    for (x, y, col) in ((44, 51, HAT), (17, 52, YEL), (29, 56, HAT)):
        c.add(c.m(ell(x, y, 2.4 * k, 2.0 * k)) & body, col)
    # grass at the flat bottom
    g = body & c.m(lambda x, y: y >= 55 + (1.5 if int(x // 3) % 2 else 0))
    c.add(g, GRASS)
    c.add(body & c.m(rect(0, 57.5, 64, 64)), GRASSD)
    # eyes + cheeks under the brim
    c.eye(27, 33.5)
    c.eye(37, 33.5)
    if not c.small:
        c.blush(24, 36)
        c.blush(39, 36)


K.render_pal(fn, 'pl-eggs-2', 'Dabbing Painter', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-eggs-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-eggs-2.png')
