# Concept: a snow-capped lavender peak that is an inner piece. N tab = the rounded snowy summit (the "scoop"), E tab = a rock spur,
# W and S blanks cut into the rock. Snowcap drips like ice cream; mauve/lavender/pink from cell 8-2 and the far peaks.
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROCK = K.ramp('#ae86c4')
SHADE = K.ramp('#8466ae')
SNOW = ('#f6f0f6', '#d4c4e4', '#ffffff')
PINK = K.ramp('#e89aa8')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(8, 36), (29, 11), (35, 11), (56, 36), (56, 56), (8, 56)])
    tabN = K.knob('T', 'round', 32, 14, 0, -1, r=4.6 * k, nw=4.4)
    tabE = K.knob('T', 'round', 56, 45, 1, 0, r=4.6 * k)
    blW = K.knob('B', 'round', 8, 46, -1, 0, r=4.2 * k)
    blS = K.knob('B', 'round', 32, 56, 0, 1, r=4.2 * k)
    body = c.m(core, tabN, tabE, minus=(blW, blS))
    c.add(body, ROCK, stitch=None)
    # shaded right face of the mountain (ridge from summit down)
    c.add(body & c.m(K.poly([(33, 10), (64, 40), (64, 64), (44, 64)])), SHADE)
    # pink sunset glow on lower left slope

    # snowcap: everything above a wavy drip line
    def drip(x, y):
        base = 29 + 1.8 * math.sin((x - 8) / 48 * math.pi * 3)
        d = base
        for dx, dl in ((19, 6), (44, 8)):
            if abs(x - dx) < 3:
                d = max(d, base + dl * math.sqrt(max(0.0, 1 - ((x - dx) / 3) ** 2)))
        return y < d
    snow = body & c.m(drip)
    c.add(snow, SNOW, stitch='#cfc0e0')
    c.edge(snow, '#b8a8d4')
    # face on the snow scoop
    c.eye(27, 22)
    c.eye(37, 22)
    c.smile(32, 25.5)
    c.blush(23, 25)
    c.blush(40, 25)
    # rock crags
    for pts in (((14, 40), (18, 37), (22, 41)), ((40, 42), (44, 38), (49, 43)), ((24, 48), (28, 45))):
        c.line(pts, SHADE[1])


K.render_pal(fn, 'pl-sll-5', 'Snowcap Scoop', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sll-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sll-5.png')
