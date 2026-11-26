"""pl-silk-3 Greenjar Giggle. Inner-TBTB, keyhole: a round teal-glazed caravanserai jar that IS the piece.
N keyhole tab = the lid's knob (flared neck + gold-capped ball, like the dome finials), S keyhole tab = the jar's foot,
E + W keyhole blanks bite into the belly sides (the jar's waist). Teal dome glaze, sandstone band with the gate bunting, sand foot (cell 4-7)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

GLAZE = K.ramp('#3f8883')
GLAZE2 = K.ramp('#5ea597')
LID = K.ramp('#225258')
SAND = K.ramp('#ecc794')
SANDDK = K.ramp('#b07a3a')
GOLD = K.GOLD
BUNT = ('#d6322b', '#f0c030', '#3f7fc8', '#f4f0e4')


def fn(c):
    k = 1.15 if c.small else 1.0
    # rounded square belly with straight sides between the knobs
    core = lambda x, y: (11 <= x < 53 and 18 <= y < 55) and not (
        (x < 22 and y < 29 and (x - 22) ** 2 + (y - 29) ** 2 > 121) or
        (x >= 42 and y < 29 and (x - 42) ** 2 + (y - 29) ** 2 > 121) or
        (x < 19 and y >= 47 and (x - 19) ** 2 + (y - 47) ** 2 > 64) or
        (x >= 45 and y >= 47 and (x - 45) ** 2 + (y - 47) ** 2 > 64))
    tabN = K.knob('T', 'keyhole', 32, 18, 0, -1, r=5.8 * k)
    tabS = K.knob('T', 'keyhole', 32, 55, 0, 1, r=3.4 * k)
    bE = K.knob('B', 'keyhole', 53, 36, 1, 0, r=3.2 * k)
    bW = K.knob('B', 'keyhole', 11, 36, -1, 0, r=3.2 * k)
    cut = (bE, bW)
    body = c.m(core, minus=cut)
    c.add(body, GLAZE, stitch=None)
    # glossy left highlight on the belly
    c.add(c.m(K.ell(19, 30, 3, 5.5), minus=cut) & body, GLAZE2)
    # lid: dark dome-teal band on the shoulders with ribs, knob = N tab
    lid = c.m(lambda x, y: y < 25.5) & body
    c.add(lid, LID)
    knobm = c.m(tabN, minus=(K.rect(0, 18, 64, 64),))
    c.add(knobm, LID)
    c.add(c.m(K.ell(32, 8.6 if not c.small else 8.0, 3.2 * k, 3.2 * k)) & knobm, GOLD)
    if not c.small:
        for rx in (24, 28, 32, 36, 40):
            x, _ = c.P(rx, 0)
            for y in range(c.P(0, 19.5)[1], c.P(0, 24)[1]):
                if (x, y) in lid:
                    c.px(x, y, LID[1])
    c.edge(lid, LID[1])
    c.add(c.m(K.rect(0, 25.5, 64, 27.2 if not c.small else 27.5)) & body, GOLD)
    # sandstone band with the bunting (gate garland) around the belly
    band = c.m(K.rect(0, 43, 64, 49)) & body
    c.add(band, SAND)
    c.edge(band, SANDDK[1])
    step = 4 if not c.small else 5
    i = 0
    for rx in range(13, 52, step):
        x, y = c.P(rx, 44.5)
        col = BUNT[i % 4]
        i += 1
        if (x, y) not in body:
            continue
        if not c.small:
            for dx in range(-1, 2):
                c.px(x + dx, y, col)
                c.px(x + dx, y + 1, col)
            c.px(x, y + 2, col)
        else:
            c.px(x, y, col)
            c.px(x + 1, y, col)
            c.px(x, y + 1, col)
    # foot = S tab, sand
    foot = c.m(tabS, minus=(K.rect(0, 0, 64, 54),))
    c.add(foot, SANDDK)
    # face: happy squint eyes + giggling open mouth
    for ex in (25, 39):
        cx, cy = c.P(ex, 30)
        if not c.small:
            for dx, dy in ((-2, 1), (-1, 0), (0, -1), (1, 0), (2, 1)):
                c.px(cx + dx, cy + dy, K.UMBER)
            for dx, dy in ((-1, 1), (0, 0), (1, 1)):
                c.px(cx + dx, cy + dy, K.UMBER)
        else:
            for dx, dy in ((-1, 1), (0, 0), (1, 0), (2, 1)):
                c.px(cx + dx, cy + dy, K.UMBER)
    mx, my = c.P(32, 34)
    if not c.small:
        for dx in range(-3, 4):
            c.px(mx + dx, my, K.UMBER)
        for dx in range(-2, 3):
            c.px(mx + dx, my + 1, '#8d1d38')
            c.px(mx + dx, my + 2, K.UMBER if abs(dx) == 2 else '#8d1d38')
        for dx in range(-1, 2):
            c.px(mx + dx, my + 3, K.UMBER)
    else:
        for dx in range(-1, 3):
            c.px(mx + dx, my, K.UMBER)
        c.px(mx, my + 1, '#8d1d38')
        c.px(mx + 1, my + 1, '#8d1d38')
        c.px(mx - 1, my + 1, K.UMBER)
        c.px(mx + 2, my + 1, K.UMBER)
    c.blush(20, 33.5)
    c.blush(43, 33.5)


K.render_pal(fn, 'pl-silk-3', 'Greenjar Giggle', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-silk-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-silk-3.png')
