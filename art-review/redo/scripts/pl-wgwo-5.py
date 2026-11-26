"""pl-wgwo-5 Pool of Quiet: inner-BBBB keyhole. A still round grotto pool seen from above, set in a square ring of lavender cave stone;
all four sides are keyhole blanks bitten into the stone rim. Turquoise glow-water (cell 1-6) with ripple rings, a hushed sleepy face,
glowworm sparkles and a lilac mushroom stepping stone from the grotto picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#7c6cae')
STONE2 = K.ramp('#5a4a8a')
WATER = K.ramp('#30b4bc')
DEEP = K.ramp('#1f8aa4')
SHROOM = K.ramp('#a49cc8')
GLOW = '#c8fff0'


def fn(c):
    k = 1.15 if c.small else 1.0
    def rr(x0, y0, x1, y1, r):
        return lambda x, y: (K.rect(x0 + r, y0, x1 - r, y1)(x, y) or K.rect(x0, y0 + r, x1, y1 - r)(x, y)
                             or any(K.ell(cx, cy, r, r)(x, y) for cx in (x0 + r, x1 - r) for cy in (y0 + r, y1 - r)))
    core = rr(5, 6, 59, 58, 6)
    r = 3.4 * k
    bl = [K.knob('B', 'keyhole', 32, 6, 0, -1, r=r), K.knob('B', 'keyhole', 32, 58, 0, 1, r=r),
          K.knob('B', 'keyhole', 5, 32, -1, 0, r=r), K.knob('B', 'keyhole', 59, 32, 1, 0, r=r)]
    body = c.add(c.m(core, minus=bl), STONE, stitch=None if c.small else STONE[2])
    # pebbles in the rim (small, flattened, so they read as cave stones not buttons)
    for (x, y) in ((13, 13), (51, 13), (12, 51), (51, 50), (20, 9.5), (44, 54.5)):
        c.add(c.m(K.ell(x, y, 4.2, 2.6)) & body, STONE2)
    # the pool: a wide flat oval, back wall shadow at top so it reads as a basin of water, not a ball
    pool = c.add(c.m(K.ell(32, 33, 17.5, 13.5)), WATER)
    c.edge(pool, K.UMBER2)
    c.add(c.m(K.ell(32, 33, 17.5, 13.5), minus=(K.ell(32, 35.5, 17.5, 13.5),)), DEEP)
    # flat ripple rings around the stepping stone
    if not c.small:
        for (rx, ry) in ((7.5, 2.6), (11.5, 4.0)):
            rip = c.m(lambda x, y, rx=rx, ry=ry: 0.80 < ((x - 40) / rx) ** 2 + ((y - 42.5) / ry) ** 2 < 1.05)
            for p in rip & pool:
                c.px(*p, WATER[2])
    else:
        rip = c.m(lambda x, y: 0.70 < ((x - 40) / 9) ** 2 + ((y - 42.5) / 3.6) ** 2 < 1.1)
        for p in rip & pool:
            c.px(*p, WATER[2])
    # water shimmer: short horizontal light streaks and darker teal bands, like the cell's patchy pool surface
    for (x0, x1, y, col) in ((19, 27, 38.5, WATER[2]), (16, 22, 34, DEEP[0]), (41, 48, 31, WATER[2]), (24, 33, 44.5, DEEP[0]),
                             (44, 48, 36, DEEP[0])):
        if c.small and col == DEEP[0] and x1 - x0 < 6:
            continue
        c.line([(x0, y), (x1, y)], col)
    # mushroom stepping stone in the water (lilac, like the grotto pool stones)
    c.add(c.m(K.ell(40, 41.5, 4.6, 2.4)), SHROOM)
    # face: calm, sleepy eyes and tiny o mouth (hush)
    c.eye(25, 30)
    c.eye(34, 30)
    mx, my = c.P(29.5, 35)
    c.px(mx, my, K.UMBER)
    if not c.small:
        c.px(mx + 1, my, K.UMBER)
    c.blush(21, 33)
    c.blush(37, 33) if not c.small else None
    # glowworm sparkles
    for (x, y) in ((44, 27), (22, 42), (49, 36)):
        px, py = c.P(x, y)
        c.px(px, py, GLOW)
        if not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(px + d[0], py + d[1], WATER[2])


K.render_pal(fn, 'pl-wgwo-5', 'Pool of Quiet', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgwo-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgwo-5.png')
