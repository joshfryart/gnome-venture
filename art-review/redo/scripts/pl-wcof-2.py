"""pl-wcof-2 Bowl of Puffs: edge-TTB keyhole. A round-bellied snack bowl heaped with white puffs IS the piece:
flat S side = bowl foot on the mat, N keyhole tab = the top puff of the heap, E keyhole tab = a puff spilling over the rim,
W keyhole blank bites the bowl belly. Bowl wears the ceremony mat stripes (red/teal/yellow diagonals) from cell 2-7."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

RED = K.ramp('#d4503a')
TEALR = K.ramp('#2e8a8c')
YEL = K.ramp('#f0c048')
PUFF = ('#f4eedc', '#cfc3a4', '#ffffff')
BROWN = K.ramp('#9a6a48')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(9, 24), (55, 24), (55, 34), (51, 58), (13, 58), (9, 34)])
    bumps = [K.ell(x, 24.5, 5.2, 4.6) for x in (14.5, 24, 40, 49.5)]
    tabN = K.knob('T', 'keyhole', 32, 22, 0, -1, r=8.0 * k)
    tabE = K.knob('T', 'keyhole', 53.5, 43, 1, 0, r=4.8 * k)
    blankW = K.knob('B', 'keyhole', 10.5, 43, -1, 0, r=4.6 * k)
    # rounded lower corners of the bowl belly (the bottom stays flat)
    belly_cut = (lambda x, y: x < 17 and y > 50 and (x - 17) ** 2 + (y - 50) ** 2 > 36,
                 lambda x, y: x > 47 and y > 50 and (x - 47) ** 2 + (y - 50) ** 2 > 36)
    body = c.m(core, tabN, tabE, *bumps, minus=(blankW,) + belly_cut)
    # bowl: diagonal mat stripes
    bowl = body & c.m(K.rect(0, 33, 64, 64))
    stripes = [TEALR, RED, YEL, RED]
    w = 6 if not c.small else 6
    for i, rp in enumerate(stripes):
        m = {(x, y) for (x, y) in bowl if int(((x + y) / c.k) // w) % 4 == i}
        c.add(m, rp)
    # calm face band across the bowl (teal) and a brown foot ring
    band = body & c.m(K.rect(0, 36, 64, 47))
    c.add(band, TEALR)
    foot = body & c.m(K.rect(0, 54.5, 64, 64))
    c.add(foot, BROWN)
    # rim
    rim = body & c.m(K.rect(0, 31, 64, 34.5))
    c.add(rim, BROWN)
    # puff heap: top of core + both tabs, lumpy inner contours
    heap = body & c.m(K.rect(0, 0, 64, 31.5))
    heap |= c.m(tabE, minus=(K.rect(0, 0, 53, 64),))
    c.add(heap, PUFF)
    for (cx, cy, r) in ((14.5, 25, 5.2), (24, 25, 5.2), (40, 25, 5.2), (49.5, 25, 5.2), (32, 11.5, 6.6), (59, 43, 4.2)):
        pm = c.m(K.ell(cx, cy, r, r * 0.9)) & heap
        if not c.small or r > 5.4:
            c.edge(pm, PUFF[1])
    # a few golden toasted spots on the puffs (64 only)
    if not c.small:
        for (x, y) in ((16, 23), (37, 27), (47, 23), (30, 10), (58, 41)):
            c.px(*c.P(x, y), YEL[0])
    else:
        c.px(*c.P(36, 23), YEL[0])
    # face on the teal band
    c.eye(25, 40.5, disc=True)
    c.eye(39, 40.5, disc=True)
    c.smile(32, 43.5, K.CREAM)
    c.blush(20, 44)
    c.blush(44, 44)


K.render_pal(fn, 'pl-wcof-2', 'Bowl of Puffs', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcof-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcof-2.png')
