# Ceiling Constellation (pl-wgwo-4): inner-TTTT, double. A chunk of glowworm-grotto cave ceiling: purple rock crown on top,
# teal stone body hung with glowing glowworm threads; four bright stars joined by a constellation line; double tabs on all four
# sides, the N tab a purple rock lump, the E/W/S tabs glowing cyan twin beads (the threads' drops). Colours from cell 6-0.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#3e6f84')
ROCK = K.ramp('#5e5294')
GLOW = ('#6ff0e4', '#3fb8b8', '#d8fff8')
THREAD = '#6da5c5'
STAR = '#e8fffa'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 12, 52, 46)
    tN = K.knob('T', 'double', 32, 12, 0, -1, r=5.0 * k)
    tS = K.knob('T', 'double', 32, 46, 0, 1, r=4.8 * k)
    tE = K.knob('T', 'double', 52, 27, 1, 0, r=4.8 * k)
    tW = K.knob('T', 'double', 12, 27, -1, 0, r=4.8 * k)
    # big stalactites hanging off the bottom corners: the cave roof's teeth
    drips = (K.poly([(12, 45), (23, 45), (17, 60)]), K.poly([(41, 45), (52, 45), (47, 60)]))
    body = c.m(core, tN, tE, tW, tS, *drips)
    c.add(body, STONE)
    # purple rock crown and stalactites; teal glow-lit stone below (cell 6-0: purple roof over the teal thread curtain)
    rock = c.m(K.rect(0, 0, 64, 19), tN, tE, tW,
               K.poly([(12, 18), (22, 18), (17, 26)]), K.poly([(28, 18), (36, 18), (32, 23)]), K.poly([(42, 18), (52, 18), (47, 27)]))
    c.add(body & rock, ROCK)
    c.add(c.m(*drips) & c.m(K.rect(0, 44, 64, 64)), ROCK)
    c.edge(body & rock, ROCK[1])
    # glowworm threads hanging straight down with glowing beads
    w = 1.0 if not c.small else 1.8
    xs = (19.5, 25, 39, 44.5) if not c.small else (19.5, 44.5)
    for tx in xs:
        y1 = 44 if tx in (19.5, 44.5) else 30
        for p in c.m(K.thick_path([(tx, 20), (tx, y1)], w)) & body:
            c.px(p[0], p[1], THREAD)
        for by in range(24, int(y1) + 1, 6 if not c.small else 9):
            c.px(*c.P(tx, by), GLOW[0])
    for tx in (17, 47):
        for p in c.m(K.thick_path([(tx, 46), (tx, 63)], w)):
            c.px(p[0], p[1], THREAD)
        if c.P(tx, 58) in body:
            c.px(*c.P(tx, 58), GLOW[0])
        c.px(*c.P(tx, 62), GLOW[0])
    # the four glowing dots: one bright star on each tab
    for sx, sy in ((32, 6.5), (57.5, 27), (32, 51.5), (6.5, 27)):
        x, y = c.P(sx, sy)
        for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
            c.px(x + dx, y + dy, GLOW[0])
        c.px(x, y, STAR)
    c.add(c.m(tS) & c.m(K.rect(0, 45, 64, 64)), STONE)
    x, y = c.P(32, 51.5)
    for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
        c.px(x + dx, y + dy, GLOW[0])
    c.px(x, y, STAR)
    # face on the glowing stone
    c.eye(26.5, 32, disc=True)
    c.eye(37.5, 32, disc=True)
    c.smile(32, 37)
    c.blush(22, 37)
    c.blush(41, 37)


K.render_pal(fn, 'pl-wgwo-4', 'Ceiling Constellation', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgwo-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgwo-4.png')
