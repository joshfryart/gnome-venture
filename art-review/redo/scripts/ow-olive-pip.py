# Olive Pip: a plump green olive that IS an edge piece. Flat S = the olive sits on the grove's ochre earth (terracotta furrow band),
# N double tab = brown twig with two silver-green olive leaves, W double tab = a little sister olive budding off the side, E double blank
# bitten into the flesh. Colours from cell 8-4: olive-tree green, ochre earth, terracotta furrow, bark brown, goat cream.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

OLIVE = K.ramp('#86973a')
OLIVE2 = K.ramp('#5f6e33')
LEAF = K.ramp('#9aa86a')
BARK = K.ramp('#8b5a3a')
EARTH = K.ramp('#c9a859')
TERRA = K.ramp('#c7643a')


def fn(c):
    k = 1.15 if c.small else 1.0
    # olive core: square-ish with rounded top corners (fruit shoulders), flat bottom
    # an olive: a tall oval whose lower half widens into the straight-sided piece body
    core = lambda x, y: (K.ell(32, 36, 20.5, 17)(x, y) or K.rect(12, 38, 52, 58)(x, y)) and 12 <= x < 52 and y >= 19
    tabN = K.knob('T', 'double', 32, 20, 0, -1, r=5.8 * k)
    tabW = K.knob('T', 'double', 12, 38, -1, 0, r=4.8 * k)
    blankE = K.knob('B', 'double', 52, 38, 1, 0, r=4.6 * k)
    body = c.m(core, tabW, minus=(blankE,))
    c.add(body, OLIVE, stitch=None if c.small else OLIVE[2])
    # sister olive on the W tab, darker
    c.add(c.m(tabW, minus=(K.rect(12, 0, 64, 64),)), OLIVE2)
    c.add(c.m(K.ell(5.2, 35.6, 1.3, 1.6)) & c.m(tabW), K.ramp('#9aa86a'))
    # twig stem + two leaves on the N tab
    # the double tab drawn as two pointed olive leaves fanning off a twig
    def leaf(cx, cy, ang, L, W):
        import math
        ca, sa = math.cos(ang), math.sin(ang)
        def f(x, y):
            u, v = (x - cx) * ca + (y - cy) * sa, -(x - cx) * sa + (y - cy) * ca
            return abs(u) < L and abs(v) < W * (1 - (u / L) ** 2)
        return f
    lw = 3.6 if not c.small else 4.2
    lL = leaf(25.5, 11, 0.55, 8.5, lw)
    lR = leaf(38.5, 11, -0.55, 8.5, lw)
    sw = 2.6 if not c.small else 3.2
    c.add(c.m(K.thick_path([(32, 22), (32, 14)], sw)), BARK)
    c.add(c.m(lL), LEAF)
    c.add(c.m(lR), K.ramp('#7f9150'))
    # earth at the flat bottom: ochre soil with a terracotta furrow
    c.add(body & c.m(K.rect(0, 51, 64, 64)), EARTH)
    c.add(body & c.m(K.rect(0, 55, 64, 64)), TERRA)
    # olive highlight shine (upper left)
    c.add(c.m(K.ell(21, 29, 2.8, 5.0)) & body, K.ramp('#c9d38a'))
    # face
    c.eye(26, 38)
    c.eye(38, 38)
    c.smile(32, 44)
    c.blush(21, 43)
    c.blush(42, 43)


K.render_pal(fn, 'ow-olive-pip', 'Olive Pip', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/ow-olive-pip-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ow-olive-pip.png')
