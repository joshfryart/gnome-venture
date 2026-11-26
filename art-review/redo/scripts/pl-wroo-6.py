import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER, UMBER2, CREAM

# whimsy-temple, keyhole: stepped mossy temple whose top block is a grinning stone face.
# N tab = moss/frog crown, E+W tabs = stone ears, S blank = glowing doorway. Roots wrap the tiers (cell 5-2).
STONE = ramp('#a9b49c')
STONE2 = ramp('#8e9a84')
MOSS = ramp('#5fae3c')
ROOT = ramp('#8a5a34')
GLOW = '#f2d77a'


def fn(c):
    k = 1.15 if c.small else 1.0
    face = rect(15, 15, 49, 35)
    tier = rect(9, 35, 55, 45)
    base = rect(4, 45, 60, 61)
    tabN = knob('T', 'keyhole', 32, 15, 0, -1, r=5.2 * k)
    tabE = knob('T', 'keyhole', 49, 24, 1, 0, r=4.2 * k)
    tabW = knob('T', 'keyhole', 15, 24, -1, 0, r=4.2 * k)
    blankS = knob('B', 'keyhole', 32, 61, 0, 1, r=3.8 * k)
    body = c.m(face, tier, base, tabN, tabE, tabW, minus=(blankS,))
    c.add(body, STONE2)
    fm = c.add(body & c.m(face, tabE, tabW), STONE, stitch=None if c.small else '#c8d0b8')
    c.add(body & c.m(tabN), STONE)
    c.add(body & c.m(ell(32, 6.5, 6.5, 3.2), rect(15, 14, 49, 18), rect(29.5, 6, 34.5, 15)), MOSS)
    # frog-ish moss crown: two little eye bumps
    if not c.small:
        for fx in (29.5, 34.5):
            x, y = c.P(fx, 5)
            c.px(x, y, CREAM); c.px(x, y + 1, UMBER)
    # moss drips on face top
    c.add(body & c.m(ell(19, 18, 3.5, 2.6), ell(45, 18.5, 3, 2.4), ell(26, 17.5, 2.5, 2.2)), MOSS)
    # tier block lines
    if not c.small:
        for yy in (40.5, 53):
            c.line([(10, yy), (54, yy)], STONE2[1])
        for xx, y0, y1 in ((20, 35, 40), (38, 40, 46), (14, 46, 53), (48, 53, 60), (26, 53, 60)):
            c.line([(xx, y0), (xx, y1)], STONE2[1])
    tm = c.m(tier, base) & body
    c.edge(c.m(face) & body, STONE2[1])
    # moss patches on tiers
    c.add(body & c.m(ell(13, 47, 4, 2.2), ell(50, 36, 4, 2), ell(57, 47, 3, 2)), MOSS)
    # roots wrapping
    w = 3.4 if not c.small else 3.8
    c.add(body & c.m(thick_path([(4, 52), (14, 49), (24, 51), (31, 47), (40, 49), (50, 46), (60, 49)], w)), ROOT)
    c.add(body & c.m(thick_path([(9, 40), (18, 37), (26, 41)], w), thick_path([(40, 42), (48, 38), (55, 40)], w)), ROOT)
    # roots hugging the face like arms
    c.add(body & c.m(thick_path([(6, 46), (11, 34), (12, 24), (17, 15)], w), thick_path([(58, 46), (53, 34), (52, 24), (47, 15)], w), minus=(rect(16, 19, 48, 35),)), ROOT)
    # glowing doorway rim around the blank
    door = c.m(knob('B', 'keyhole', 32, 61, 0, 1, r=3.8 * k + 1.6))
    for p in door & body:
        c.px(p[0], p[1], GLOW)
    # face: carved brows, eyes, big grin with teeth
    for ex in (24.5, 39.5):
        c.line([(ex - 4, 20), (ex + 3, 19.5)], STONE2[1])
        c.eye(ex, 23.5, disc=True)
    mx0, mx1 = c.P(23, 28.5), c.P(41, 32)
    for x in range(mx0[0], mx1[0] + 1):
        for y in range(mx0[1], mx1[1] + 1):
            t = (x - mx0[0]) / max(1, mx1[0] - mx0[0])
            # curved grin: corners lifted
            lift = 0 if 0.15 < t < 0.85 else 1
            if y >= mx0[1] + lift:
                c.px(x, y, UMBER)
    # teeth row
    ty = mx0[1] + 1
    for x in range(mx0[0] + 2, mx1[0] - 1):
        if (x - mx0[0]) % (3 if not c.small else 2) != 0:
            c.px(x, ty, CREAM)
    c.blush(19.5, 28)
    c.blush(43.5, 28)


K.render_pal(fn, 'pl-wroo-6', 'Grinning Stone Face', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wroo-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wroo-6.png')
