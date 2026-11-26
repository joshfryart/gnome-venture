"""pl-wgwo-1 Dangling Dripstone: corner-TT keyhole. A lilac stalactite hanging from a flat cave ceiling (top flat) with a flat left side;
the bottom keyhole tab is the stalactite's dripping point with a cyan glow sparkle, the right keyhole tab a rocky side bud.
Colours: lilac rock #9a8ac8 / #5d5193 and glowworm cyan from the Glowworm Grotto (cell 4-1)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

ROCK = K.ramp('#9a8ac8')
CEIL = ('#5d5193', '#433a6e', '#7c6eae')
RIDGE = '#7c6eae'
GLOW = K.ramp('#4fd8c8')
SPARK = '#c8fff4'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(6, 5), (51, 5), (51, 30), (44, 42), (20, 42), (6, 30)])
    tabS = knob('T', 'keyhole', 32, 41.5, 0, 1, r=5.6 * k, nw=2.8)
    tabE = knob('T', 'keyhole', 50.5, 19, 1, 0, r=4.6 * k, nw=2.4)
    body = c.m(core, tabE)
    c.add(body, ROCK)
    c.add(c.m(tabS, minus=(core,)), ROCK)
    # drip bulb glows cyan at the tip
    c.add(c.m(ell(32, 52.5, 4.6 * k, 4.6 * k), minus=(core,)), GLOW)
    # ceiling slab with a rough lower lip
    slab = c.m(rect(6, 5, 51, 10.5), *[ell(x, 10.5, 2.6, 2.2) for x in (10, 19, 28, 37, 46)])
    c.add(slab & body, CEIL)
    # vertical ridges (stalactite streaks), converging toward the tip
    for top, bot in (((12, 15), (22, 38)), ((45, 15), (41, 38)), ((31, 36), (31, 45))):
        c.line([top, bot], ROCK[1])
        if not c.small:
            c.line([(top[0] + 1, top[1]), (bot[0] + 1, bot[1])], RIDGE)
    # glowworm threads hanging from the slab
    for gx, n in ((9.5, 3), (48, 2)):
        for i in range(n):
            x, y = c.P(gx, 15 + i * 4)
            c.px(x, y, GLOW[2])
    # sparkle on the drip
    sx, sy = c.P(32, 52.5)
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        c.px(sx + dx, sy + dy, SPARK)
    if not c.small:
        for dx, dy in ((2, 0), (-2, 0), (0, 2), (0, -2)):
            c.px(sx + dx, sy + dy, GLOW[2])
    # face: calm, holding still
    c.eye(24, 22)
    c.eye(36.5, 22)
    c.smile(30, 28)
    c.blush(19, 26)
    c.blush(41, 26)


K.render_pal(fn, 'pl-wgwo-1', 'Dangling Dripstone', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgwo-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgwo-1.png')
