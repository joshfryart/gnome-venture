import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

CORN = ramp('#f0c040')
KER = '#f8dc78'
HUSK = ramp('#8cc8a4')     # cell sky mint, deepened
MAUVE = ramp('#b892a9')    # cell mountain
PLUM = '#6a495a'
LAVA = ramp('#f08a2a')
SILK = ramp('#e8783a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 15, 51, 58)
    tabN = knob('T', 'peg', 32, 15, 0, -1, r=5.0 * k)
    bW = knob('B', 'peg', 13, 44, -1, 0, r=3.7 * k)
    bE = knob('B', 'peg', 51, 44, 1, 0, r=3.7 * k)
    body = c.m(core, tabN, minus=(bW, bE))
    c.add(body, CORN)
    # silk tuft cap on the peg tip
    tip = c.m(tabN, minus=(core,)) & body
    ys = sorted({y for _, y in tip})
    c.add({p for p in tip if p[1] <= ys[len(ys) // 2]}, SILK)
    # kernel grid
    step = 2 if c.small else 3
    # husk leaves sweeping up both sides from the base
    DK = ramp('#5fa882')
    hl = poly([(12, 59), (12, 22), (18, 30), (24, 44), (29, 59)])
    hr = poly([(52, 59), (52, 22), (46, 30), (40, 44), (35, 59)])
    hm = poly([(24, 59), (32, 45), (40, 59)])
    L = c.add(body & c.m(hl), DK)
    R = c.add(body & c.m(hr), DK)
    M = c.add(body & c.m(hm), HUSK)
    c.edge(M, HUSK[1])
    for (x, y) in body - L - R - M - tip:
        if x % step == 1 and y % step == 1:
            c.px(x, y, KER)
    for P in (L, R):
        c.edge(P, DK[1])
    if not c.small:
        c.line([(15, 54), (15, 30)], DK[2]); c.line([(49, 54), (49, 30)], DK[2])
    # mauve scout neckerchief with lava-orange trim
    nk = poly([(21, 34), (43, 34), (32, 43)])
    N = c.add(body & c.m(nk), MAUVE)
    c.add(body & c.m(rect(20, 32, 44, 35)), LAVA)
    c.edge(N, PLUM)
    # face
    c.eye(26.5, 24)
    c.eye(37.5, 24)
    c.smile(32, 27.5)
    c.blush(22.5, 27.5)
    c.blush(40.5, 27.5)


K.render_pal(fn, 'mh-cob-scout', 'Cob Scout', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/mh-cob-scout-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/mh-cob-scout.png')
