"""pl-sing-3 Misty Foamcap. Inner-TBTB keyhole: a white puff of foam bobbing on the pool. N keyhole tab = a round foam bubble on top,
S keyhole tab = a blue water drip, keyhole blanks bite E and W into the foam mass. Lower band is pool water with white ripple dashes (cell 5-6)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

FOAM = K.ramp('#eef6f8')
FOAM2 = ('#d4e8f0', '#a8c8d8', '#eef6f8')
POOL = K.ramp('#78bce0')
DEEP = K.ramp('#3c8cc8')
SKY = K.ramp('#a8d8ec')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 20, 55, 52)
    # foam puffs round the top corners
    puffs = (K.ell(15.5, 18, 6.5, 6.5), K.ell(48.5, 18, 6.5, 6.5), K.ell(23.5, 14.5, 5.5, 5), K.ell(40.5, 14.5, 5.5, 5))
    tabN = K.knob('T', 'keyhole', 32, 16, 0, -1, r=5.6 * k)
    tabS = K.knob('T', 'keyhole', 32, 52, 0, 1, r=4.8 * k)
    bE = K.knob('B', 'keyhole', 55, 33, 1, 0, r=3.6 * k)
    bW = K.knob('B', 'keyhole', 9, 33, -1, 0, r=3.6 * k)
    corner = (lambda x, y: (x < 9 or x >= 55),)
    body = c.m(core, tabN, K.rect(18, 16, 46, 21), *puffs, minus=(bE, bW) + corner)
    c.add(body, FOAM, stitch=None if c.small else '#c4dcea')
    # puff seams (inner contour bubbles)
    for pr in puffs:
        c.edge(c.m(pr) & body, FOAM2[1] if not c.small else FOAM2[0])
    bub = c.m(tabN, minus=(core,) + puffs)
    c.edge(bub, FOAM2[1])
    # water band (pool) at the bottom + the drip tab
    water = c.m(core, minus=(bE, bW)) & c.m(K.rect(0, 41, 64, 64))
    c.add(water, POOL)
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(K.rect(0, 50, 64, 53))), DEEP)
    # wavy waterline: foam scallops dip into the water
    wave = c.m(lambda x, y: 39 <= y < 42.5 - 2.2 * abs(((x - 9) % 8) - 4) / 4 and 9 <= x < 55)
    c.add(wave & body, FOAM)
    # ripple dashes on the water (the cell's white streaks)
    for (y0, xs) in ((45, (13, 27, 41)), (49, (19, 34, 46))):
        for x0 in xs:
            for xx in range(*[c.P(x0, 0)[0], c.P(x0 + (5 if not c.small else 6), 0)[0]]):
                c.px(xx, c.P(0, y0)[1], '#f4fafc')
    # sparkle bubbles on the foam (64 only)
    if not c.small:
        c.px(*c.P(19, 22), SKY[0]); c.px(*c.P(47, 26), SKY[0]); c.px(*c.P(44, 21), SKY[0])
        c.px(*c.P(29, 8), '#ffffff'); c.px(*c.P(30, 8), '#ffffff')
    # face on the foam
    c.eye(26, 26)
    c.eye(38, 26)
    c.smile(32, 31, wide=not c.small)
    c.blush(21, 30)
    c.blush(42, 30)


K.render_pal(fn, 'pl-sing-3', 'Misty Foamcap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sing-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sing-3.png')
