import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp, UMBER, UMBER2, CREAM

TIN = ramp('#9aa8c0')
RIM = ramp('#6e7c98')
LOG = ramp('#c8843e')
RING = ramp('#e8b878')
SAP = ramp('#e89a28')
SNOW = ('#f4f6fa', '#c8d0e0', '#ffffff')


def fn(c):
    """Corner-TT, round: a tin sap bucket. Flat W + S (bucket wall/base), N round tab = falling amber sap drop,
    E round tab = the round end of a maple log (cell 1-6 firewood ends) the bucket hangs on."""
    k = 1.15 if c.small else 1.0
    core = poly([(12, 25), (51, 25), (47.5, 58), (15.5, 58)])
    lip = c.m(rect(9.5, 21, 53.5, 26), ell(9.5, 23.5, 2.5, 2.5), ell(53.5, 23.5, 2.5, 2.5))
    tabN = knob('T', 'round', 30, 21, 0, -1, r=5.4 * k, nw=2.0)
    tipN = poly([(30, 5.5 - (1 if c.small else 0)), (27.6, 10), (32.4, 10)])
    tabE = knob('T', 'round', 49.5, 41, 1, 0, r=5.4 * k, nw=4.2)
    body = c.m(core)
    c.add(body, TIN, stitch=None)
    # corrugation bands
    c.add(body & c.m(rect(0, 38, 64, 41)), RIM)
    c.add(body & c.m(rect(0, 53, 64, 58)), RIM)
    c.add(lip, RIM)
    snow = c.m(lambda x, y: 20 <= y < 22.5 + (1.5 if 13 < x < 21 else 0) and 8 <= x < 27)
    c.add(snow & lip, SNOW)
    c.add(c.m(rect(28, 21, 47, 22.6)) & lip, SAP)
    # E tab: stub of maple log with ring end
    logm = c.m(tabE, minus=(core,))
    c.add(logm, LOG)
    cx, cy = 49.5 + 1.6 + 5.4 * k + 1, 41
    c.add(c.m(ell(cx, cy, 2.8 * k, 2.8 * k)) & logm, RING)
    if not c.small:
        c.px(*c.P(cx, cy), LOG[1])
    # N tab: falling sap teardrop
    drop = c.m(tabN, tipN, minus=(rect(0, 21, 64, 64),))
    c.add(drop, SAP)
    if not c.small:
        x, y = c.P(28, 11)
        c.px(x, y, SAP[2]); c.px(x, y + 1, SAP[2])
    # vertical tin seams
    if not c.small:
        for gx in (19, 44):
            x, _ = c.P(gx, 0)
            for y in range(c.P(0, 42)[1], c.P(0, 52)[1]):
                if (x, y) in body:
                    c.px(x, y, TIN[2] if gx == 18 else TIN[1])
    # rivets on the rim
    for rx in (19, 44):
        c.px(*c.P(rx, 55.5), RIM[2])
    # face
    c.eye(24, 32)
    c.eye(38, 32)
    c.smile(31, 35.5)
    c.blush(19, 35)
    c.blush(42, 35)


K.render_pal(fn, 'pl-sugr-1', 'Bucket Plink', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sugr-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sugr-1.png')
print(K.check(K.draw(fn, 64))['colours'])
