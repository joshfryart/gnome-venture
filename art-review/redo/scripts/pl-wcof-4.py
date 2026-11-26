"""pl-wcof-4 Cuppa Constellation. Inner-TTTT, double: a little ceremony coffee cup (sini) that IS the piece. Square cup body with the
woven rug stripes (red / gold / teal diagonals, cell 9-7) wrapped round it; N double tab = two puffs of steam off the dark coffee,
E double tab = the cup's loop handle, S double tab = the clay foot, W double tab = two gold stars (the constellation)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import UMBER2, rect, ell, poly, knob, ramp

RED, GOLD, TEAL = ramp('#d0503c'), ramp('#f2c14e'), ramp('#3c8a8c')
CLAY = ramp('#a8704e')
CUP = ('#f2ebe0', '#c9bfb0', '#ffffff')
COFFEE = ('#6e4438', '#4a2c22', '#8a5a48')
STEAM = ('#e8e4ec', '#b8b4c8', '#ffffff')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(13, 17), (51, 17), (51, 44), (48, 50), (43, 52), (21, 52), (16, 50), (13, 44)])
    tN = knob('T', 'double', 32, 17, 0, -1, r=5.4 * k)
    tE = knob('T', 'double', 51, 33, 1, 0, r=4.8 * k)
    tS = knob('T', 'double', 32, 52, 0, 1, r=4.6 * k)
    tW = knob('T', 'double', 13, 33, -1, 0, r=4.8 * k)
    c.add(c.m(core), CUP, stitch=None)
    # rug band round the cup's belly: diagonal stripes red / gold / teal / gold
    band = c.m(core) & c.m(rect(0, 31, 64, 44))
    seq = [RED, GOLD, TEAL, GOLD]
    w = 3.2
    for i, rp in enumerate(seq):
        c.add(band & c.m(lambda x, y, i=i: int(((x + y) / w)) % 4 == i), rp)
    # coffee surface (top rim)
    c.add(c.m(ell(32, 18.8, 17.2, 3.4 if not c.small else 3.2)), COFFEE)
    c.add(c.m(tN, minus=(rect(0, 15, 64, 64),)), STEAM)
    c.add(c.m(tE, minus=(core,)), CUP)
    c.add(c.m(tS, minus=(core,)), CLAY)
    c.add(c.m(tW, minus=(core,)), GOLD)
    # handle hole and star glints
    if not c.small:
        hx, hy = c.P(57.5, 33)
        for dx in (0, 1):
            for dy in (-1, 0):
                c.px(hx + dx - 1, hy + dy, CUP[1])
    for sy in (30.2, 35.8):
        x, y = c.P(5.6, sy)
        c.px(x, y, '#fff6d0')
        if not c.small:
            c.px(x + 1, y, '#fff6d0'); c.px(x, y + 1, '#fff6d0')
    # rim line under the coffee
    c.edge(c.m(ell(32, 18.8, 17.2, 3.4 if not c.small else 3.2)), UMBER2)
    c.edge(c.m(core) & c.m(rect(0, 31, 64, 44)), RED[1]) if False else None
    # face on the calm cream area
    c.eye(25, 28)
    c.eye(39, 28)
    c.smile(32, 30)
    c.blush(21, 29)
    c.blush(42, 29)


K.render_pal(fn, 'pl-wcof-4', 'Cuppa Constellation', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcof-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcof-4.png')
