# Supper Sun: a glowing sunset-lantern sun that is an inner piece (TBTB, round). Tabs top (lantern cap on its string)
# and bottom (purple savanna hill the sun sinks into), blanks left and right cut into the glowing rim. Colours from cell 1-3.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RIM = K.ramp('#e87a38')
GLOW = K.ramp('#ffb848')
HOT = K.ramp('#ffe890')
CORE = ('#fffbe0', '#ffe890', '#ffffff')
HILL = K.ramp('#b86470')
HILL2 = K.ramp('#8a4c96')
CAP = K.ramp('#6b442e')


def sq(cx, cy, a, b, p=4):
    return lambda x, y: abs((x - cx) / a) ** p + abs((y - cy) / b) ** p < 1


def fn(c):
    s = 1.15 if c.small else 1.0
    r = 4.6 * s
    core = sq(32, 33, 21, 18)
    top = K.knob('T', 'round', 32, 15, 0, -1, r=r)
    bot = K.knob('T', 'round', 32, 51, 0, 1, r=r, nw=3.2)
    lb = K.knob('B', 'round', 11, 33, -1, 0, r=r)
    rbk = K.knob('B', 'round', 53, 33, 1, 0, r=r)
    string = K.rect(30.7, 0, 33.3, 6) if not c.small else K.rect(30.2, 0, 33.8, 6)
    blanks = (lb, rbk)
    import math
    rays = []
    for ang, ln in ((-150, 34), (-30, 34), (-118, 33), (-62, 33)):
        a = math.radians(ang)
        ux, uy = math.cos(a), math.sin(a)
        px, py = -uy, ux
        bx, by = 32 + ux * 17, 33 + uy * 14
        w = 4.4 if not c.small else 5.0
        tip = (32 + ux * ln, 33 + uy * ln * 0.8)
        rays.append(K.poly([(bx + px * w, by + py * w), tip, (bx - px * w, by - py * w)]))
    raym = c.m(*rays, minus=blanks)
    body = c.m(core, top, bot, minus=blanks) | raym
    c.add(body, RIM)
    c.add(raym - c.m(core), GLOW)
    c.add(c.m(string), CAP)
    c.add(c.m(K.rect(26, 5, 38, 9.5), minus=blanks) & body, CAP)       # lantern cap on the top tab
    c.add(c.m(K.ell(32, 33, 17.5, 15.5), minus=blanks) & body, GLOW, stitch='#e87a38')
    c.add(c.m(K.ell(30, 30, 11, 9.5)), HOT)
    c.add(c.m(K.ell(23, 24, 3.5, 2.6)), CORE)
    # the savanna hills the sun is sinking behind (fill the bottom, incl. the bottom tab)
    hill = c.m(K.poly([(0, 43), (10, 40), (22, 42.5), (34, 39.5), (46, 41), (64, 38), (64, 64), (0, 64)])) & body
    c.add(hill, HILL)
    far = c.m(K.poly([(0, 49), (14, 46.5), (30, 48.5), (44, 46), (64, 48), (64, 64), (0, 64)])) & body
    c.add(far, HILL2)
    # tiny baobab silhouette on the hill
    tree = c.m(K.rect(44, 35, 46.6, 41), K.ell(45.3, 34.5, 4.6, 2)) if not c.small else c.m(K.rect(43.5, 34, 46.5, 41), K.ell(45, 33.5, 5, 2.4))
    # face on the glowing disc
    c.eye(26, 31)
    c.eye(38, 31)
    c.smile(32, 36, wide=True)
    c.blush(21, 34)
    c.blush(41, 34)


K.render_pal(fn, 'pl-baob-3', 'Supper Sun', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-baob-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-baob-3.png')
