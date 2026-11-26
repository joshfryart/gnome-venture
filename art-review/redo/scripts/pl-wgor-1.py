"""pl-wgor-1 Marmalade Treetop: corner-TT keyhole. A round glade fruit tree: canopy = piece body (flat N + W sides),
S keyhole tab = trunk with flared roots, E keyhole tab = a big hanging marmalade orange. Glade greens, sunbeam glow upper left."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

LEAF = K.ramp('#3f9a4a')
LEAF2 = ('#2c7038', '#4a3e5c', '#3f8a48')
SUN = K.ramp('#9ad07a')
BARK = K.ramp('#8a5a36')
ORNG = K.ramp('#e8782a')
GLOW = '#f8c050'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(7, 9, 51, 45)
    trunk_tab = K.knob('T', 'keyhole', 29, 45, 0, 1, r=6.2 * k, nw=3.6)
    fruit_tab = K.knob('T', 'keyhole', 51, 27, 1, 0, r=6.4 * k, nw=2.6)
    # canopy: rounded lower-right edge only (flat N and W stay straight)
    rc = lambda cx, cy, sx, sy, R: (lambda x, y: (x - cx) * sx > 0 and (y - cy) * sy > 0 and (x - cx) ** 2 + (y - cy) ** 2 > R * R)
    canopy = c.m(core, minus=(rc(44, 38, 1, 1, 7), rc(45, 15, 1, -1, 6), rc(13, 39, -1, 1, 6)))
    c.add(canopy, LEAF)
    # lower tier of leaves (darker lens like the picture trees)
    import math
    tier = c.m(lambda x, y: y > 31 - 1.6 * abs(math.sin((x - 7) * math.pi / 8))) & canopy
    top = c.m(lambda x, y: y > 20 - 1.6 * abs(math.sin((x - 11) * math.pi / 8))) & canopy
    c.add(top, LEAF)
    c.edge(top, LEAF[1])
    c.add(tier, LEAF2)
    c.edge(tier, LEAF[1])
    # sunbeam patch upper-left
    sun = c.m(lambda x, y: x + y < 30 and x < 51 and y < 45) & canopy
    c.add(sun, SUN)
    # trunk (S tab)
    c.add(c.m(trunk_tab, minus=(core,)) | (c.m(trunk_tab) & c.m(K.rect(0, 42, 64, 46))), BARK)
    # big hanging orange (E tab) with a leafy stem in the neck
    ft = c.m(fruit_tab, minus=(core,))
    c.add(ft, ORNG)
    neck = c.m(K.rect(49, 21, 55, 29)) & c.m(fruit_tab)
    c.add(neck, LEAF2)
    # fruits on the canopy
    fruits = [(13, 37), (44, 38), (43, 14), (31, 14)] if c.small else [(13, 37), (22, 40), (38, 40), (45, 33), (43, 14), (31, 14)]
    r = 3.4 if c.small else 3.0
    for fx, fy in fruits:
        c.add(c.m(K.ell(fx, fy, r, r)), ORNG)
        c.edge(c.m(K.ell(fx, fy, r, r)), ORNG[1])
        c.px(*c.P(fx - 1, fy - 1), ORNG[2])
    # glowing marmalade fruits where the sunbeam lands
    for fx, fy in [(14, 15)] if c.small else [(14, 15), (21, 22)]:
        c.add(c.m(K.ell(fx, fy, r + 0.3, r + 0.3)), (GLOW, '#e8902a', '#fff0b0'))
        c.edge(c.m(K.ell(fx, fy, r + 0.3, r + 0.3)), '#e8902a')
        c.px(*c.P(fx - 1, fy - 1), '#fff0b0')
    c.px(*c.P(56.5, 25.5), ORNG[2])
    c.px(*c.P(55.5, 26.5), ORNG[2])
    # face on the calm middle of the canopy
    c.eye(25.5, 26, disc=False)
    c.eye(35.5, 26, disc=False)
    c.smile(30.5, 30)
    c.blush(21, 30)
    c.blush(39, 30)


K.render_pal(fn, 'pl-wgor-1', 'Marmalade Treetop', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgor-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgor-1.png')
