# Sakura Flurry: edge-TTB peg. A cherry-blossom tree that IS an edge piece: pink blossom canopy fills the top of the
# square body (peg tabs N and E are blossom tufts, peg blank bites the W canopy), the brown trunk stands on the flat S side
# against the cell's pale pink sky, with fallen petals. Colours from cell 1-3 (pink/mauve canopy, umber-brown trunk, blush sky).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, thick_path

PINK = ramp('#f8a8c4')
ROSE = ramp('#c8689a')
MAUVE = ramp('#a15189')
BARK = ramp('#8a5238')
SKY = ramp('#f0c8e0')
PETAL = '#ffe4ee'
GRASS = ramp('#7ab55c')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 15, 52, 58)
    tabN = knob('T', 'peg', 31, 15, 0, -1, r=5.0 * k)
    tabE = knob('T', 'peg', 52, 28, 1, 0, r=4.8 * k)
    blankW = knob('B', 'peg', 10, 28, -1, 0, r=4.6 * k)
    # puffy blossom scallops along the top edge (small, so the side still reads straight)
    bumps = [ell(x, 15.5, 3.6, 2.6) for x in (14.5, 21, 41, 47.5)]
    body = c.m(core, tabN, tabE, *bumps, minus=(blankW,))
    c.add(body, SKY)
    # grass strip on the flat south side
    c.add(body & c.m(rect(0, 54, 64, 64)), GRASS)
    # canopy: clumps with a scalloped lower edge, deep mauve underneath
    clumps = [ell(16, 38, 7, 5.5), ell(27, 40, 7, 4.5), ell(38, 39.5, 7, 5), ell(48, 37, 6, 6)]
    canopy = c.m(rect(0, 0, 64, 35), *clumps) & body
    c.add(canopy, MAUVE)
    mid = c.m(rect(0, 0, 64, 32), ell(17, 35, 6, 4.5), ell(28, 36.5, 6, 4), ell(39, 36, 6, 4.5), ell(48, 33, 5, 5)) & canopy
    c.add(mid, ROSE)
    puffs = c.m(ell(19, 21, 9, 6.5), ell(39, 21, 9, 6.5), ell(31, 11, 5, 4.5), ell(56, 26, 4.5, 5), ell(30.5, 28, 9, 4.5)) & canopy
    c.add(puffs, PINK)
    # trunk standing on the grass, flared roots, two branches into the canopy
    trunk = c.m(poly([(22, 58), (26, 52), (27.5, 38), (34.5, 38), (36, 52), (41, 58)]),
                thick_path([(29, 42), (22, 36)], 3.2 * k), thick_path([(33, 43), (40, 37)], 3.2 * k)) & body
    c.add(trunk - mid, BARK)
    if not c.small:
        c.line([(30.5, 45), (30.5, 53)], BARK[1])
    # fallen petals drifting on the sky (one heading for a teacup)
    for (x, y) in ((15, 47), (46, 49), (19, 51) if not c.small else (46, 44)):
        px, py = c.P(x, y)
        c.px(px, py, PETAL)
        c.px(px + 1, py, PINK[0])
        if not c.small:
            c.px(px, py + 1, ROSE[0])
    # five-dot blossoms in the canopy (64 px)
    if not c.small:
        for (x, y) in ((14, 30), (47, 30), (44, 16), (25, 17)):
            cx, cy = c.P(x, y)
            for dx, dy in ((0, -1), (-1, 0), (1, 0), (0, 1)):
                c.px(cx + dx, cy + dy, PETAL)
            c.px(cx, cy, '#e8a317')
    # face on the canopy
    c.eye(24, 25)
    c.eye(37, 25)
    c.blush(20, 29)
    c.blush(40, 29)
    c.smile(30.5, 29)


K.render_pal(fn, 'pl-cblo-2', 'Sakura Flurry', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cblo-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cblo-2.png')
