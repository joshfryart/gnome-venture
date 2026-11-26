# Web Snag: a cobweb patch that is an edge piece. Flat top = the anchor thread, hook blanks W and E,
# hook tab S = a curled silk snag-hook with a gnome hat caught on it. Silver web spokes radiate from a pair of
# eyes at the hub (the lair's web-eyes motif); body in the lair's dusky violet stone (cell 8-2).
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

DUSK = K.ramp('#4a3c5a')
SILK = K.ramp('#c8cce8')
HAT = K.ramp('#c8402a')
THREAD = '#d4d8f0'
THREAD2 = '#9a98c0'


def fn(c):
    k = 1.3 if c.small else 1.0
    O = [(9, 9), (55, 9), (55, 37), (44, 49), (20, 49), (9, 37)]
    core = K.poly(O)
    tabS = K.knob('T', 'hook', 32, 49, 0, 1, r=5.4 * k, nw=2.8)
    bW = K.knob('B', 'hook', 9, 24, -1, 0, r=4.0 * k)
    bE = K.knob('B', 'hook', 55, 24, 1, 0, r=4.0 * k, flip=True)
    body = c.m(core, minus=(bW, bE))
    c.add(body, DUSK)
    # anchor thread along the flat top
    c.add(c.m(K.rect(9, 9, 55, 11.5)), SILK)
    # silk hook tab
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(K.rect(0, 46, 64, 50))), SILK)
    hx, hy = 32, 28
    ends = [(9, 11), (32, 11), (55, 11), (55, 37), (44, 48), (20, 48), (9, 37)]
    for e in ends:
        c.line([(hx, hy), e], THREAD)
    # sagging spiral rings: each segment between spokes bows toward the hub
    rings = (0.45, 0.78) if not c.small else (0.6,)
    for i, f in enumerate(rings):
        pts = []
        for a in range(len(ends) + 1):
            e1 = ends[a % len(ends)]
            p1 = (hx + (e1[0] - hx) * f, hy + (e1[1] - hy) * f)
            if a:
                e0 = ends[a - 1]
                p0 = (hx + (e0[0] - hx) * f, hy + (e0[1] - hy) * f)
                mx, my = (p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2
                pts.append((hx + (mx - hx) * 0.86, hy + (my - hy) * 0.86))
            pts.append(p1)
        c.line(pts, THREAD)
    # hub: face
    c.add(c.m(K.ell(hx, hy, 9, 6.5) if not c.small else K.ell(hx, hy, 8, 4.5)), DUSK)
    c.eye(hx - 4.2, hy, disc=True)
    c.eye(hx + 4.2, hy, disc=True, look=(1, 0) if not c.small else (0, 0))
    if not c.small:
        c.smile(hx, hy + 3.5, K.CREAM)
    # snagged hat on the top-right corner of the web
    hat = K.poly([(43, 16), (55, 16), (52, 3)])
    c.add(c.m(hat), HAT)
    c.add(c.m(K.rect(41.5, 14.5, 56.5, 18)), K.ramp('#e8d8b0'))


K.render_pal(fn, 'pl-sbs-2', 'Web Snag', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sbs-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sbs-2.png')
