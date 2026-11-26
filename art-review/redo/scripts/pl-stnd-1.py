# Spiral Scribble: a little purple standing stone that IS a corner piece. Flat W + S sides (S sits in grass),
# keyhole tabs N (mossy stone cap) and E; a glowing teal spiral rune carved on its face. Colours from cell 2-6 / Standing Stones.
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = ('#847ca0', '#625a80', '#aaa4c4')
STONE_DK = '#463e62'
MOSS = K.ramp('#518a6a')
GRASS = ('#68a47c', '#3a7058', '#9ccc9a')
RUNE = '#7fe8d8'
RUNE_DK = '#4a8a9c'


def spiral(cx, cy, r0, turns, n=60):
    pts = []
    for i in range(n + 1):
        t = i / n
        a = -math.pi / 2 + t * turns * 2 * math.pi
        r = 1.2 + (r0 - 1.2) * t
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(12, 57), (12.5, 25), (14.5, 19), (20, 16), (43, 16), (48.5, 19), (50.5, 25), (51, 57)])
    tabN = K.knob('T', 'keyhole', 31.5, 16.8, 0, -1, r=6.6 * k, nw=2.5)
    tabE = K.knob('T', 'keyhole', 50.8, 37, 1, 0, r=6.6 * k, nw=2.5)
    body = c.m(core, tabE, tabN)
    c.add(body, STONE, stitch=None)
    # mossy cap: the N tab + a drip of moss along the top
    moss = c.m(K.ell(20, 17.5, 6.5, 3.2), K.ell(43.5, 18, 5, 2.6), K.ell(30, 5.5, 4, 2.2))
    c.add(moss, MOSS)
    # grass skirt along the flat S side, blades poking up
    blades = [K.poly([(x - 2, 51), (x, 46 - (i % 2) * 2.5), (x + 2, 51)]) for i, x in enumerate(range(14, 51, 5))]
    grass = c.m(K.rect(12, 51, 51, 57), *blades, minus=(K.rect(51, 0, 64, 64),))
    c.add(grass, GRASS)
    # stone cracks / speckles (texture of the picture's stones)
    if not c.small:
        c.line([(44, 22), (46, 26), (45, 29)], STONE_DK)
        c.line([(16, 30), (18, 33)], STONE_DK)
        for (x, y) in ((17, 25), (45, 44), (18, 46), (40, 23)):
            c.px(*c.P(x, y), STONE[2])
    # carved spiral rune, glowing teal, on the belly
    w = 3.2 if c.small else 2.6
    pts = spiral(31.5, 41, 9.5 if c.small else 9.0, 1.6 if c.small else 1.9)
    for p in c.m(K.thick_path(pts, w + 1.6)):
        c.px(p[0], p[1], RUNE_DK)
    for p in c.m(K.thick_path(pts, w)):
        c.px(p[0], p[1], RUNE)
    # face above the rune
    c.eye(24, 27.5, disc=True)
    c.eye(39, 27.5, disc=True)
    c.blush(19.5, 32)
    c.blush(43, 32)


K.render_pal(fn, 'pl-stnd-1', 'Spiral Scribble', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-stnd-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-stnd-1.png')
