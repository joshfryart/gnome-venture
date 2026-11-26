"""pl-snw-6 Snowpeak Cub (whimsy-lion, peg): a lion cub's head, face on, whose square fluffy snow mane IS the piece.
Peg tabs N (a snowy crown tuft) and E (a mane tuft), peg blanks W and S-left bite into the mane; tan ears break the top corners.
Snow cream mane shaded with the cell's mountain mauve, a purple-rock ruff ring (cell 6-4 #3f3550 / #a6979c), tan face from the picture's lion."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp, UMBER, UMBER2

SNOW = ('#f4f0e0', '#a6979c', '#ffffff')
MAUVE = ('#887a86', '#6c5f72', '#c2b2a8')
ROCK = ramp('#54485f')
TAN = ('#d9a660', '#b07a3a', '#f0cc88')
FUR = ramp('#c77d52')
BROWN = ramp('#8f512a')
MUZ = ('#f4e6c8', '#d8c4a0', '#fff6e0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(14, 10), (50, 10), (55, 15), (55, 52), (50, 57), (14, 57), (9, 52), (9, 15)])
    tabN = knob('T', 'peg', 32, 10, 0, -1, r=4.6 * k)
    tabE = knob('T', 'peg', 55, 34, 1, 0, r=4.4 * k)
    blankW = knob('B', 'peg', 9, 34, -1, 0, r=4.2 * k)
    fluff = []
    for (cx, cy, sx, sy) in [(13, 14, 1, 1), (51, 14, -1, 1), (13, 53, 1, -1), (51, 53, -1, -1)]:
        fluff += [ell(cx - 1.5 * sx, cy + 3 * sy, 3.2, 3.2), ell(cx + 3 * sx, cy - 1.5 * sy, 3.2, 3.2), ell(cx, cy, 3.6, 3.6)]
    body = c.m(core, tabN, tabE, *fluff, minus=(blankW,))
    c.add(body, SNOW, stitch=None if c.small else '#c2b2a8')
    # mane strands: radial wedges of snow and mountain mauve (a sunburst mane), purple-rock roots round the face
    import math
    def wedge(x, y):
        d = math.hypot(x - 32, y - 36)
        a = (math.atan2(y - 36, x - 32) + math.pi) / (2 * math.pi) * 14 + 0.5
        f = abs(a - math.floor(a) - 0.5)          # 0 at the middle of a sector
        t = max(0.0, 1 - (d - 15) / 10.5)          # spike narrows outward
        return d > 15 and f < 0.36 * t
    c.add(c.m(wedge, minus=(blankW,
                            lambda x, y: (x - 32) ** 2 + (y - 36) ** 2 > 27 ** 2 and not tabN(x, y))) & body, MAUVE)
    c.add(c.m(ell(32, 36.5, 16.5, 15.5)), ROCK)
    # round ears on top of the head, inside the mane
    for ex in (22, 42):
        c.add(c.m(ell(ex, 25.5, 3.8, 3.4)), TAN)
        c.add(c.m(ell(ex, 26, 1.8, 1.6)), BROWN)
    # face
    face = c.m(ell(32, 37.5, 14, 12.5))
    c.add(face, TAN)
    c.add(c.m(ell(32, 44, 7.5, 5.2)), MUZ)
    c.add(c.m(poly([(28, 39.5), (36, 39.5), (32, 43.8)])), BROWN)
    if not c.small:
        for (x, y) in [(26, 44), (25, 46), (38, 44), (39, 46)]:
            c.px(*c.P(x, y), TAN[1])
    c.smile(32, 45.5, UMBER2, wide=not c.small)
    c.eye(26.5, 34)
    c.eye(37.5, 34)
    c.blush(23, 39)
    c.blush(40, 39)
    # snow sparkle flecks on the mane (64 only), mauve strand ticks
    if not c.small:
        for (x, y) in [(13, 20), (51, 22), (12, 46), (50, 49), (20, 53), (44, 53)]:
            c.px(x, y, '#ffffff')


K.render_pal(fn, 'pl-snw-6', 'Snowpeak Cub', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-snw-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-snw-6.png')
