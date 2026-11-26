"""pl-wroo-2 Elbow Root Hug. Edge-TTB, keyhole: a thick tan root bent like an elbow (vertical on the W, bending along the flat S),
hugging a mossy temple stone block in its crook. N keyhole tab = the root's sprouting top, E keyhole tab = the root's curled end,
keyhole blank cut into the stone = the temple's arched doorway. Root tans, moss greens and jungle teal from cell 8-2."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

ROOT = K.ramp('#c08a56')
ROOT2 = K.ramp('#8a5a36')
STONE = K.ramp('#8c9a84')
MOSS = K.ramp('#5a9a3a')
LEAF = K.ramp('#6aa84a')
DOOR = ('#f0d080', '#c8a050', '#f8e8b0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(9, 14, 55, 56)
    tabN = knob('T', 'keyhole', 17, 14, 0, -1, r=4.6 * k)
    tabW = knob('T', 'keyhole', 9, 29, -1, 0, r=4.2 * k)
    blankE = knob('B', 'keyhole', 55, 29, 1, 0, r=4.8 * k)    # the temple's arched doorway
    body = c.m(core, tabN, tabW, minus=(blankE,))
    c.add(body, STONE)
    # mossy stone courses
    stone_r = rect(25, 14, 55, 42)
    if True:
        for yy in (23, 32):
            y = c.P(0, yy)[1]
            for x in range(c.P(25, 0)[0], c.n):
                if (x, y) in body:
                    c.px(x, y, STONE[1])
        for (xx, y0, y1) in ((40, 14, 23), (33, 23, 32), (47, 23, 32), (40, 32, 42)):
            x = c.P(xx, 0)[0]
            for y in range(c.P(0, y0)[1], c.P(0, y1)[1]):
                c.px(x, y, STONE[1])
    moss = c.m(lambda x, y: y < 19 + 2.5 * ((int(x) // 3) % 2) or (x > 49 and (int(x + y) // 2) % 3 == 0)) & c.m(stone_r) & body
    c.add(moss, MOSS)
    # root: elbow L
    rootp = c.m(rect(9, 14, 25, 56), rect(9, 42, 55, 56), tabN, tabW, ell(25, 42, 6, 6)) & body
    c.add(rootp, ROOT)
    c.edge(rootp, ROOT[1])
    # root hand curling over the stone top (the hug)
    hand = c.m(thick_path([(24, 24), (30, 19.5), (44, 18.5), (50, 21), (51, 25)], 4.4 if not c.small else 5.0))
    c.add(hand, ROOT)
    c.edge(hand, ROOT[1])
    # bark: mottled blotches like the picture's roots (dark brown and light tan patches)
    if not c.small:
        blots_d = [(12, 20), (20, 30), (13, 37), (32, 52), (44, 47), (50, 53)]
        blots_l = [(16, 24), (11, 31), (21, 39), (37, 47), (46, 52)]
        for (bx, by) in blots_d:
            c.add(c.m(ell(bx, by, 2.2, 1.4)) & rootp, ROOT2)
        for (bx, by) in blots_l:
            c.add(c.m(ell(bx, by, 2.0, 1.2)) & rootp, (ROOT[2], ROOT[0], ROOT[2]))
    else:
        for (bx, by) in [(12, 20), (20, 31), (40, 52)]:
            c.add(c.m(ell(bx, by, 2.4, 1.6)) & rootp, ROOT2)
    # sprout leaf on the N tab
    c.add(c.m(ell(21.5, 5.5, 3.6 * k, 2.2 * k)), LEAF)
    # face on the elbow
    c.eye(14, 46)
    c.eye(22, 46)
    c.blush(11, 50)
    c.blush(24.5, 50)
    c.smile(18, 51)


K.render_pal(fn, 'pl-wroo-2', 'Elbow Root Hug', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wroo-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wroo-2.png')
