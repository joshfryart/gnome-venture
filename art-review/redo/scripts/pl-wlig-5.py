# pl-wlig-5 "Wide-Eyed Windows": a lighthouse tower block that is an inner-BBBB keyhole piece. Magenta lantern-roof cap (top
# blank notched into it), red and cream stripes from the lighthouse, two big round glowing windows as wide surprised eyes,
# side blanks low in the red band, bottom blank as the tower's arched door. Sunset magenta / salmon / gold from cell 9-3.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

RED = ramp('#c93f56')
CRM = ramp('#f2dcb4')
MAGE = ramp('#c25f86')
SALM = ramp('#ee8a78')
GLOW = ramp('#ffb877')
RAIL = ('#5a3a48', '#3e2832', '#7a5464')


def fn(c):
    k = 1.15 if c.small else 1.0
    L0, R0, L1, R1, T, B = 17, 47, 10, 54, 9, 56
    core = poly([(L0, T), (R0, T), (R1, B), (L1, B)])
    xl = lambda y: L0 + (L1 - L0) * (y - T) / (B - T)
    xr = lambda y: R0 + (R1 - R0) * (y - T) / (B - T)
    sy = 42
    bN = knob('B', 'keyhole', 32, T, 0, -1, r=2.7 * k, nw=1.5)
    bS = knob('B', 'keyhole', 32, B, 0, 1, r=2.7 * k, nw=1.5)
    bW = knob('B', 'keyhole', xl(sy), sy, -1, 0, r=2.7 * k, nw=1.5)
    bE = knob('B', 'keyhole', xr(sy), sy, 1, 0, r=2.7 * k, nw=1.5)
    blanks = (bN, bS, bW, bE)
    body = c.m(core, minus=blanks)
    c.add(body, CRM, stitch=None)
    band = lambda y0, y1: body & c.m(rect(0, y0, 64, y1))
    c.add(band(T, 13), MAGE)            # lantern roof
    c.add(band(13, 17), GLOW)           # lit lantern glass
    for gx in (20, 26, 38, 44):
        c.add(body & c.m(rect(gx, 13, gx + 1.6, 17)), RAIL)
    c.add(band(17, 20), RAIL)           # gallery rail
    c.add(band(37, 44), RED)
    c.add(band(49, 53), RED)
    c.add(band(53, 64), SALM)           # rock / sunset base
    # gallery railing posts
    if not c.small:
        for x in range(c.P(L0, 0)[0] + 2, c.P(R0, 0)[0] - 1, 3):
            c.px(x, c.P(0, 18)[1], '#a07a88')
    # two round windows = the eyes
    for wx in (23.5, 40.5):
        fr = c.m(ell(wx, 28.5, 7.2, 7.2))
        c.add(fr, RED)
        gl = c.m(ell(wx, 28.5, 5.2, 5.2))
        c.add(gl, GLOW)
        c.edge(fr, K.UMBER2)
        # window cross bar (64 only)
        cx, cy = c.P(wx, 28.5)
        if not c.small:
            for d in (-4, 4):
                c.px(cx + d, cy, '#c06a3a')
        c.eye(wx, 29, look=(0, 0))
    c.blush(16.5, 37)
    c.blush(46.5, 37)


K.render_pal(fn, 'pl-wlig-5', 'Wide-Eyed Windows', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlig-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlig-5.png')
print(K.check(K.draw(fn, 64))['colours'])
