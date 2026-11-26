import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Popcorn Moon: a fat crescent moon made of popped corn (whimsy-moon), rounded-square core so it reads as a piece.
# Double-knob tabs top and bottom, a double blank in the left (back of the moon), the crescent bite on the right.
# Colours from cell 11-2 (tree canopy): leaf green with magenta berries and a brown branch; butter/cream popcorn from the cornfield.
SRC = '/home/user/gnome-venture/art-review/redo/_src/'
BUTTER = K.ramp('#f2c94c')
CORN = K.ramp('#f6ecc8')
LEAF = K.ramp('#3f9a5c')
BARK = K.ramp('#7a4a2a')
BERRY = '#c8327a'

def sq(cx, cy, r, p=3.2):
    return lambda x, y: (abs(x - cx) / r) ** p + (abs(y - cy) / r) ** p < 1

def fn(c):
    k = 1.15 if c.small else 1.0
    core = sq(28, 32, 22)
    bite = K.ell(48, 32, 15, 19)
    # popped kernels on the horn tips (bumpy popcorn edge)
    horns = [K.ell(42, 12.5, 4.2, 3.6), K.ell(45.5, 16, 3.4, 3.4), K.ell(42, 51.5, 4.2, 3.6), K.ell(45.5, 48, 3.4, 3.4)]
    tt = K.knob('T', 'double', 22, 10.5, 0, -1, r=4.6 * k)
    tb = K.knob('T', 'double', 22, 53.5, 0, 1, r=4.6 * k)
    bl = K.knob('B', 'double', 6.5, 32, -1, 0, r=4.3 * k)
    body = c.m(core, tt, tb, *horns, K.ell(11, 53, 6.5, 3.2), K.ell(31, 53.5, 6.5, 3.2), minus=(bite, bl))
    c.add(body, BUTTER)
    # puffy popcorn kernels (cream) incl. the horn tips
    puffs = [(42, 12.5, 4.2), (45.5, 16, 3.2), (42, 51.5, 4.2), (45.5, 48, 3.2), (14, 18, 4.5), (24, 14, 4), (13, 44, 4.5), (32, 47, 4), (34, 16, 3.5)]
    if c.small:
        puffs = [(42.5, 13, 4.5), (42.5, 51, 4.5), (15, 18, 5), (14, 45, 5)]
    for (x, y, r) in puffs:
        q = r * 0.62
        pm = c.m(K.ell(x - q * 0.7, y + q * 0.3, q, q), K.ell(x + q * 0.7, y + q * 0.3, q, q), K.ell(x, y - q * 0.55, q, q)) & body
        c.add(pm, CORN)
        c.edge(pm, '#d9b860')
    # leafy sprig from the canopy cell, tucked on the bottom tab, with magenta berries
    leaves = c.m(K.ell(13, 53, 7.5, 3.6), K.ell(31, 53, 7.5, 3.6), K.ell(22, 57.5, 5.5, 4.5)) & body
    c.add(leaves, LEAF)
    c.edge(leaves, LEAF[1])
    for (x, y) in ([(10, 53), (33, 53), (22, 58)] if not c.small else [(10, 53), (33, 53)]):
        bx, by = c.P(x, y)
        c.px(bx, by, BERRY); c.px(bx + 1, by, BERRY)
        if not c.small:
            c.px(bx, by + 1, BERRY); c.px(bx + 1, by + 1, '#8e1f58')
    # face on the wide back of the moon
    c.eye(18, 30)
    c.eye(27, 30)
    c.smile(22.5, 35)
    c.blush(14, 35); c.blush(30, 35)

K.render_pal(fn, 'mh-popcorn-moon', 'Popcorn Moon', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=SRC + 'mh-popcorn-moon-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mh-popcorn-moon.png')
