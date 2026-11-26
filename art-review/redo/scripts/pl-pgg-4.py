"""pl-pgg-4 Loot Heap: inner-TTTT, double. A pirate treasure chest brimming with a domed heap of gold coins (cell 1-5 / the chest in the
picture). N double tab = two coins topping the heap, W and E double tabs = coins spilling over the sides, S double tab = the chest's two
stubby feet. Gold #f4c84a / #fff0a0 and chest wood #ae7749 / #5e3536 bands sampled from the picture. Face lives on the gold heap."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GOLD = ('#f4c84a', '#c08a28', '#fff0a0')
WOOD = K.ramp('#ae7749')
BAND = ('#5e3536', '#482a31', '#8c5438')
LOCK = ('#fadb73', '#b07a10', '#fff0a0')
COINDK = '#c08a28'
COINLT = '#fff6c8'


def fn(c):
    k = 1.15 if c.small else 1.0
    # gold heap: a dome on top of the chest (core stays square-ish)
    heap = K.poly([(13, 34), (13, 22), (18, 17), (26, 14.5), (38, 14.5), (46, 17), (51, 22), (51, 34)])
    chest = K.rect(13, 31, 51, 52)
    tabs = [(32, 15, 0, -1, 6.0), (13, 25, -1, 0, 5.4), (51, 25, 1, 0, 5.4), (32, 52, 0, 1, 5.6)]
    preds = [K.knob('T', 'double', mx, my, nx, ny, r=r * k) for (mx, my, nx, ny, r) in tabs]
    goldm = c.m(heap, *preds[:3], minus=(K.rect(0, 33, 64, 64),))
    c.add(goldm, GOLD)
    ch = c.m(chest)
    c.add(ch, WOOD, stitch=None if c.small else '#d9a46c')
    feet = c.m(preds[3], minus=(chest,))
    c.add(feet, GOLD)   # coins spilled out in front of the chest
    lobes = []
    for (mx, my, nx, ny, r) in tabs:
        r *= k
        kk, cc = r * 0.56, r + 1.6 - 0.3
        for sgn in (-1, 1):
            lobes.append((mx + nx * cc - ny * kk * sgn, my + ny * cc + nx * kk * sgn))
    # lid band and corner straps
    lid = c.m(K.rect(13, 31, 51, 35.5))
    c.add(lid, BAND)
    c.add(c.m(K.rect(13, 35.5, 17, 52), K.rect(47, 35.5, 51, 52)), BAND)
    # gold lock plate with keyhole
    c.add(c.m(K.rect(28.5, 33, 35.5, 41.5)), LOCK)
    kx, ky = c.P(32, 36)
    c.px(kx, ky, K.UMBER)
    c.px(kx, ky + 1, K.UMBER)
    if not c.small:
        c.px(kx - 1, ky, K.UMBER)
        c.px(kx, ky + 2, K.UMBER)
    # coin markings: a dark ring arc + light glint on each lobe and scattered in the heap
    for (x, y) in lobes:   # each tab lobe is a coin: dark rim ring + square hole
        if not c.small:
            ring = c.m(K.ell(x, y, 3.0, 3.0), minus=(K.ell(x, y, 2.0, 2.0),))
            for (px, py) in ring:
                c.px(px, py, COINDK)
        cx, cy = c.P(x, y)
        c.px(cx, cy, COINDK)
        if c.small:
            c.px(cx - 1, cy - 1, COINLT)
        else:
            c.px(cx - 1, cy - 2, COINLT)
    coins = []
    heapcoins = [(20, 22), (44, 22), (25, 29), (39, 29), (32, 19), (17, 30), (47, 30)]
    if c.small:
        heapcoins = [(20, 22), (44, 22), (32, 19)]
    for (x, y) in coins + heapcoins:
        cx, cy = c.P(x, y)
        if c.small:
            c.px(cx, cy, COINDK)
            c.px(cx - 1, cy - 1, COINLT)
        else:
            for dx, dy in ((1, 1), (0, 1), (1, 0), (-1, 1), (1, -1)):
                c.px(cx + dx, cy + dy, COINDK)
            c.px(cx - 1, cy - 1, COINLT)
            c.px(cx, cy - 1, COINLT)
    # face on the heap
    c.eye(26, 24.5)
    c.eye(38, 24.5)
    c.smile(32, 28.5, wide=True)
    c.blush(22, 27.5)
    c.blush(41.5 if not c.small else 41, 27.5)


K.render_pal(fn, 'pl-pgg-4', 'Loot Heap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-pgg-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-pgg-4.png')
