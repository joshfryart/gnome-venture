import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Berrybush Bobbles, inner-TTTT keyhole: a round berry bush planted in a sandstone planter block from the Hanging Garden ruins.
N, E, W keyhole tabs = leafy bobbles of the bush; S keyhole tab = the planter's foot. Planter wears the cell's green vine band,
hanging vines and the dusky purple arch doorway. Greens / sandstone / purple from cell 4-4."""
LEAF = K.ramp('#4aa850')
LEAF2 = ('#70c860', '#3a9a48', '#a8e090')
STONE = ('#dec4a0', '#b4946c', '#f4e0b8')
VINE = ('#5ac05a', '#3a9a48', '#90dc80')
ARCH = ('#4e3a50', '#3a2a3c', '#6a5a70')
BERRY = ('#d83a3a', '#a02430', '#f07a6a')
R = ROOT = None

def fn(c):
    Kk = 1.15 if c.small else 1.0
    core = K.rect(12, 13, 52, 52)
    tN = K.knob('T', 'keyhole', 32, 13, 0, -1, r=6.4 * Kk)
    tE = K.knob('T', 'keyhole', 52, 25, 1, 0, r=5.8 * Kk)
    tW = K.knob('T', 'keyhole', 12, 25, -1, 0, r=5.8 * Kk)
    tS = K.knob('T', 'keyhole', 32, 52, 0, 1, r=5.2 * Kk)
    body = c.m(core, tN, tE, tW, tS)
    # bush: everything above y=38 plus the three leafy tabs; rounded top corners via ellipses
    bush = c.m(K.ell(32, 28, 21, 16), K.rect(12, 20, 52, 38), tN, tE, tW) & c.m(K.rect(0, 0, 64, 37))
    bush = (bush & body) | c.m(tN, tE, tW, minus=(core,))
    c.add(bush, LEAF)
    # leaf clumps: small dark crescents under light tufts, scattered over the bush
    tufts = [(18, 17), (27, 16), (37, 16), (46, 17), (16, 29), (48, 29), (24, 35), (40, 35), (32, 4), (4, 25), (60, 25), (32, 21)]
    if c.small:
        tufts = [(18, 17), (46, 17), (16, 31), (48, 31), (32, 4)]
    for (tx, ty) in tufts:
        x, y = c.P(tx, ty)
        for dx in (-1, 0, 1):
            c.px(x + dx, y + 1, LEAF[1])
        c.px(x - 2, y, LEAF[1]); c.px(x + 2, y, LEAF[1])
        if not c.small:
            c.px(x, y - 1, LEAF2[2]); c.px(x - 1, y - 1, LEAF2[2])
    # planter
    pot = body - bush
    pot = c.m(K.rect(12, 36, 52, 52), tS) - bush
    pot = pot & body
    c.add(pot, STONE)
    band = pot & c.m(K.rect(0, 36, 64, 40))
    c.add(band, VINE)
    # arch doorway on the planter
    c.add(c.m(K.rect(28.5, 45, 35.5, 52), K.ell(32, 45.5, 3.5, 3)) & pot, ARCH)
    # hanging vines
    for vx, ln in ((17, 49), (24, 46), (43, 48), (47, 45)):
        if c.small and vx in (24, 47):
            continue
        x, _ = c.P(vx, 0)
        for y in range(c.P(0, 40)[1], c.P(0, ln)[1]):
            if (x, y) in pot:
                c.px(x, y, VINE[1])
    # stone blocks hint
    if not c.small:
        for (sx, sy) in ((20, 47), (40, 45)):
            x, y = c.P(sx, sy)
            c.px(x, y, STONE[1]); c.px(x + 1, y, STONE[1])
    # berries
    bl = [(21, 19), (43, 19), (32, 15), (15, 22), (49, 22), (19, 32), (45, 32), (30, 6), (5, 22), (58, 28), (14, 34), (50, 35)]
    if c.small:
        bl = [(22, 18), (41, 18), (31, 6), (5, 23), (57, 27), (17, 31), (45, 31)]
    for (bx, by) in bl:
        x, y = c.P(bx, by)
        sz = 2 if c.small else 3
        for dx in range(sz):
            for dy in range(sz):
                c.px(x + dx, y + dy, BERRY[0])
        c.px(x, y, BERRY[2])
        if not c.small:
            c.px(x + 1, y + 1, BERRY[1])
    # face
    c.eye(26, 25)
    c.eye(38, 25)
    c.blush(22, 29); c.blush(41, 29)
    c.smile(32, 29)

K.render_pal(fn, 'pl-hang-4', 'Berrybush Bobbles', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hang-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hang-4.png')
