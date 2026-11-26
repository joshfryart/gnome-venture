import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math
# Quiet Sipper: a gnome that is an inner-TBTB piece. Top tab = red hat pom, right tab = brown coconut kava cup,
# left blank into the green shell tunic, bottom blank between the felt boots. Colours from cell 1-6: turtle-shell green, tan wall, wood.
HAT = K.ramp('#c8302a'); SKIN = K.ramp('#f0b888'); BEARD = K.ramp('#f4f0e4')
SHELL = K.ramp('#7ab84a'); WOOD = K.ramp('#a8682e'); BOOT = K.ramp('#8a5a2e'); KAVA = K.ramp('#b89a6a')
VEIN = '#2f5a2a'

def fn(c):
    s = 1.15 if c.small else 1.0
    L = lambda y: 27 - 15 * (y - 10) / 42.0      # left side x at y
    R = lambda y: 37 + 15 * (y - 10) / 42.0
    core = K.poly([(27, 10), (37, 10), (52, 52), (12, 52)])
    nl = (-42 / math.hypot(42, 15), -15 / math.hypot(42, 15))
    nr = (42 / math.hypot(42, 15), -15 / math.hypot(42, 15))
    top = K.knob('T', 'round', 32, 10, 0, -1, r=3.6 * s, nw=2.2)
    cup = K.knob('T', 'round', R(41), 41, nr[0], nr[1], r=5.0 * s, nw=3.0)
    lb = K.knob('B', 'round', L(38), 38, nl[0], nl[1], r=4.6 * s, nw=2.8)
    bb = K.knob('B', 'round', 32, 52, 0, 1, r=3.6 * s, nw=2.4)
    body = c.m(core, top, cup, minus=(lb, bb))
    # tunic (shell green) everywhere, then layers on top
    c.add(body, SHELL, stitch=None)
    hat = c.m(K.poly([(10, 27), (54, 27), (38, 6), (26, 6)]), top) & body
    c.add(hat, HAT)
    face = c.m(K.rect(10, 27, 54, 35)) & body
    c.add(face, SKIN)
    beard = c.m(K.ell(32, 38, 9.5, 7.5), K.rect(23, 33, 41, 37)) & body
    c.add(beard, BEARD)
    boots = c.m(K.rect(6, 49, 58, 56)) & body
    c.add(boots, BOOT)
    cupm = c.m(cup, minus=(core,)) | c.m(K.ell(R(41) + 1, 41, 3.5, 4)) & body
    cupm = cupm & body
    c.add(cupm, WOOD)
    # kava surface in cup
    cx, cy = R(41) + 4.5, 37.0
    c.add(c.m(K.ell(cx + 1, cy, 3.6 * s, 1.6)) & cupm, KAVA)
    c.edge(hat, HAT[1]); c.edge(beard, BEARD[1]); c.edge(boots, BOOT[1])
    # hat brim band
    c.line([(L(26.5), 26.5), (R(26.5), 26.5)], HAT[1])
    # shell veins on the tunic
    if not c.small:
        c.line([(20, 48), (25, 44), (24, 40)], VEIN)
        c.line([(44, 48), (39, 44), (40, 40)], VEIN)
        c.line([(25, 44), (39, 44)], VEIN)
        c.line([(32, 44), (32, 48)], VEIN)
    else:
        c.line([(21, 48), (26, 44), (38, 44), (43, 48)], VEIN)
    # hand on cup
    hx, hy = c.P(R(41) - 1, 43)
    for d in ((0, 0), (1, 0), (0, 1), (1, 1)):
        c.px(hx + d[0], hy + d[1], SKIN[0])
    # sleepy, content face: closed eyes (quiet sipper) + nose + blush
    for ex in (28, 36):
        x, y = c.P(ex, 30)
        if c.small:
            c.px(x, y, K.UMBER); c.px(x + 1, y, K.UMBER)
        else:
            c.px(x - 1, y - 1, K.UMBER); c.px(x, y, K.UMBER); c.px(x + 1, y, K.UMBER); c.px(x + 2, y - 1, K.UMBER)
    nx, ny = c.P(32, 32)
    c.px(nx, ny, SKIN[1]); c.px(nx - 1, ny, SKIN[1])
    c.blush(24.5, 32.5); c.blush(38.5, 32.5)

K.render_pal(fn, 'pl-kava-3', 'Quiet Sipper', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-kava-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-kava-3.png')
