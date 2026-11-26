"""pl-wced-2 Fireside Flickerling. Edge-TBB, keyhole: a flame sprite rising out of the stone fire ring.
Flat S = the stone ring (grey stones, dark pit); keyhole tab N = the flame's tip; keyhole blanks W + E bite the flame's flanks.
Flame orange/gold/cream from the campfire, cedar green needle held over the fire (cell 5-5 cedar tier greens)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

ORANGE = ramp('#f08a3c')
EMBER = ramp('#d8481e')
GOLD = ramp('#ffcc68')
FLAME_CORE = ('#fff2e2', '#ffd070', '#ffffff')
STONE = ramp('#b8b0c0')
PIT = ('#3a2c3c', '#2e2230', '#5a4a5c')
CEDAR = ('#3c8a58', '#2a6a4c', '#7ccb74')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 15, 54, 58)
    # round the two top corners like flame shoulders
    shoulder_cut = (lambda x, y: x < 15 and y < 20 and (x - 15) ** 2 + (y - 20) ** 2 > 25,
                    lambda x, y: x > 49 and y < 20 and (x - 49) ** 2 + (y - 20) ** 2 > 25)
    tabN = knob('T', 'keyhole', 32, 15, 0, -1, r=5.4 * k)
    blankW = knob('B', 'keyhole', 10, 31, -1, 0, r=5.0 * k)
    blankE = knob('B', 'keyhole', 54, 31, 1, 0, r=5.0 * k)
    body = c.m(core, tabN, minus=(blankW, blankE) + shoulder_cut)
    c.add(body, EMBER)
    # orange flame body inside the red rim (no stitch: busy small body)
    inner = c.m(poly([(12, 46), (12, 30), (15, 18), (20, 26), (24, 14), (28, 22), (32, 2), (36, 22), (40, 14), (44, 26), (49, 18), (52, 30), (52, 46)]))
    c.add(inner & body, ORANGE)
    # gold tongue
    gold = c.m(poly([(18, 46), (17, 34), (20, 24), (24, 30), (27, 20), (32, 10), (37, 20), (40, 30), (44, 24), (47, 34), (46, 46)]))
    c.add(gold & body, GOLD)
    # cream heart low in the flame
    c.add(c.m(poly([(24, 46), (25, 40), (28, 36), (32, 30), (36, 36), (39, 40), (40, 46)])) & body, FLAME_CORE)
    # stone ring: dark pit lip, then grey stones to the flat bottom
    c.add(body & c.m(rect(0, 46, 64, 49)), PIT)
    stones = body & c.m(rect(0, 49, 64, 58))
    c.add(stones, STONE)
    for sx in (21, 32, 43):
        x, _ = c.P(sx, 0)
        for y in range(c.P(0, 50)[1], c.n):
            if (x, y) in stones:
                c.px(x, y, STONE[1])
    if not c.small:
        for (x, y) in stones:
            if (x * 3 + y * 5) % 11 == 0:
                c.px(x, y, STONE[2])
    # cedar needle held over the fire, little ember hands at each end
    nw = 3.0 if not c.small else 3.6
    c.add(c.m(thick_path([(19, 41.5), (45, 39.5)], nw)) & body, CEDAR)
    if not c.small:
        c.line([(21, 40.5), (43, 38.8)], CEDAR[2])
        for t in range(23, 43, 4):
            yy = 41.5 - (t - 19) * 2 / 26
            c.line([(t, yy - 1.5), (t + 2, yy - 4)], CEDAR[1])
    c.add(c.m(ell(19, 41.5, 2.6, 2.6), ell(45, 39.5, 2.6, 2.6)) & body, EMBER)
    # face on the gold tongue
    c.eye(27.5, 29, disc=False)
    c.eye(36.5, 29, disc=False)
    c.smile(32, 34)
    c.blush(23.5, 32.5)
    c.blush(40, 32.5)


K.render_pal(fn, 'pl-wced-2', 'Fireside Flickerling', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wced-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wced-2.png')
