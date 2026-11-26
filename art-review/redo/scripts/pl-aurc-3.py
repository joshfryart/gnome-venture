import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Pine Watch: inner-TBTB round. N tab = snowy pine tip, S tab = trunk, round blanks E+W bite the middle tier.
# Three stepped teal tiers with snow ledges (cell 0-5: snowy teal pine, brown trunk, navy dusk).
G1 = K.ramp('#4aa88c')    # top tier (lit)
G2 = K.ramp('#38907b')    # middle tier
G3 = K.ramp('#26786a')    # bottom tier
TRUNK = K.ramp('#7a4a3a')
SNOW = ('#f4f8fe', '#c8d4e8', '#ffffff')
DEEP = '#1a4858'

def fn(c):
    k = 1.15 if c.small else 1.0
    t1 = K.poly([(23, 14), (41, 14), (52, 29), (12, 29)])
    t2 = K.poly([(15, 27), (49, 27), (55, 41), (9, 41)])
    t3 = K.poly([(13, 39), (51, 39), (57, 50), (55, 52), (9, 52), (7, 50)])
    tabN = K.knob('T', 'round', 32, 15, 0, -1, r=5.0 * k)
    tabS = K.knob('T', 'round', 32, 52, 0, 1, r=4.6 * k)
    bW = K.knob('B', 'round', 12, 34.5, -1, 0, r=3.5 * k)
    bE = K.knob('B', 'round', 52, 34.5, 1, 0, r=3.5 * k)
    cut = (bW, bE)
    c.add(c.m(t3, minus=cut), G3)
    c.add(c.m(t2, minus=cut + (t3,)), G2, stitch=None)
    c.add(c.m(t1, minus=(t2,)), G1)
    c.add(c.m(tabN, minus=(t1,)), G1)
    c.add(c.m(tabS, minus=(t3,)), TRUNK)
    # tier hems: dark teal shadow lines under each tier overhang
    for y in (28.6, 40.6):
        c.line([(10 if y > 40 else 13, y), (54 if y > 40 else 51, y)], DEEP)
    # snow: cap on the tip, ledges on each tier's top
    c.add(c.m(lambda x, y: y < 5.5 + (1.3 if (x // 3) % 2 else 0)) & c.m(tabN), SNOW)
    c.add(c.m(lambda x, y: 14 <= y < 16.5 + (1.4 if (x // 4) % 2 else 0) and 22 <= x < 42), SNOW)
    c.add(c.m(lambda x, y: 41.4 <= y < 43.6 + (1.2 if (x // 4) % 2 else 0) and (11 <= x < 22 or 42 <= x < 53)), SNOW)
    if not c.small:
        c.add(c.m(lambda x, y: 29.4 <= y < 31.2 and (15 <= x < 22 or 42 <= x < 49)), SNOW)
        for (x, y) in ((22, 22), (41, 25), (14, 47), (49, 46), (36, 49), (25, 21)):
            c.px(*c.P(x, y), SNOW[2])
    else:
        for (x, y) in ((22, 22), (49, 46), (15, 47)):
            c.px(*c.P(x, y), SNOW[2])
    # bark line on trunk
    if not c.small:
        x0 = c.P(32, 0)[0]
        for y in range(c.P(0, 54)[1], c.P(0, 60)[1]):
            c.px(x0, y, TRUNK[1])
    # watchful face on the middle tier: wide-open eyes, small smile
    c.eye(26, 34, disc=True)
    c.eye(38, 34, disc=True)
    c.smile(32, 38.2)

K.render_pal(fn, 'pl-aurc-3', 'Pine Watch', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurc-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurc-3.png')
