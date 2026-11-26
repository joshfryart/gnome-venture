"""pl-tcb-3 Yurt Kettle: inner-TBTB, peg. Tabs N (green lid knob) and S (squat foot), blanks W and E cut into the belly,
spout breaking out at the upper right. Banded maroon/orange planks + leaf-green lid from cell 10-6 (Canopy Bridges)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

MAROON = K.ramp('#8e3c3c')
ORANGE = K.ramp('#c8683c')
LEAF = K.ramp('#3e8a60')
LEAF2 = K.ramp('#57a168')
FOOT = K.ramp('#6e303a')
PEACH = '#f4a868'


def fn(c):
    k = 1.15 if c.small else 1.0
    # kettle belly: square-ish core with rounded shoulders, small lid dome on top
    core = lambda x, y: rect(11, 28, 52, 56)(x, y) or ell(31.5, 31, 20.5, 9)(x, y) and y >= 22
    dome = ell(31.5, 23, 11, 5.5)
    tabN = knob('T', 'peg', 31.5, 18.5, 0, -1, r=3.4 * k)
    tabS = knob('T', 'peg', 31.5, 56, 0, 1, r=4.2 * k)
    blW = knob('B', 'peg', 11, 44, -1, 0, r=3.4 * k)
    blE = knob('B', 'peg', 52, 44, 1, 0, r=3.4 * k)
    sw = 7.0 if not c.small else 7.6
    spout = thick_path([(46, 35), (54, 31), (58, 25), (59, 20)], sw)
    handle = thick_path([(16, 26), (10, 22), (5, 26), (6, 33), (11, 36)], 3.6 if not c.small else 4.4)
    body = c.m(core, dome, minus=(blW, blE))
    c.add(c.m(handle, minus=(core,)), FOOT)
    c.add(c.m(spout, minus=(blE,)), ORANGE)
    c.add(body, MAROON)
    # plank bands (orange stripes across the belly, like the bridge boards)
    bands = c.m(lambda x, y: (30 <= y < 34.5 or 40 <= y < 44.5 or 50 <= y < 54.5)) & body
    c.add(bands, ORANGE)
    # green lid with leaf knob
    lid = c.m(dome, minus=(rect(0, 26, 64, 64),)) | c.m(lambda x, y: 24.5 <= y < 27 and 20 <= x < 43)
    c.add(lid, LEAF)
    c.add(c.m(tabN, minus=(dome,)) | (c.m(tabN) & c.m(rect(0, 16.5, 64, 19))), LEAF2)
    c.add(c.m(tabS, minus=(core,)), FOOT)
    # spout tip highlight + steam vent dot
    if not c.small:
        tx, ty = c.P(59, 19)
        c.px(tx, ty, PEACH)
        c.px(tx - 1, ty, PEACH)
        # board seams on bands
        for x in range(c.P(11, 0)[0], c.P(52, 0)[0]):
            if x % 9 == 4:
                for yy in (30, 40, 50):
                    for d in range(5):
                        p = (x, c.P(0, yy)[1] + d)
                        if p in body:
                            c.px(p[0], p[1], ORANGE[1])
    # face on the calm maroon band
    c.eye(25, 37, disc=True)
    c.eye(38, 37, disc=True)
    c.blush(21, 40)
    c.blush(41, 40)
    c.smile(31.5, 38.5, K.CREAM)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-tcb-3', 'Yurt Kettle', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-tcb-3-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-tcb-3.png'))
