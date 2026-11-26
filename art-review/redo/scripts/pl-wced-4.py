# pl-wced-4 "Far Snowcaps": a sleepy lavender mountain that is an inner-TTTT piece with double knobs.
# Top tab = the two snowy summits (the double knob's two lobes are the peaks), left/right tabs = lavender foothills,
# bottom tab = a dark cedar clump in front. Colours from cell 8-2: cream snow slope, peach sky glow, lavender ridge comb.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

SNOW = K.ramp('#fff4e4')
PEACH = K.ramp('#fde2ae')
LAV = K.ramp('#a8a0c8')
LAVD = K.ramp('#8a80b4')
CEDAR = K.ramp('#357e53')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(13, 18, 51, 50)
    # top: two peaks rising from the top side (double-knob tab made pointy)
    pk1 = K.poly([(19, 19), (27, 4), (34, 19)])
    pk2 = K.poly([(30, 19), (38, 7), (46, 19)])
    tL = K.knob('T', 'double', 13, 34, -1, 0, r=4.8 * s)
    tR = K.knob('T', 'double', 51, 34, 1, 0, r=4.8 * s)
    tB = K.knob('T', 'double', 32, 50, 0, 1, r=4.8 * s)
    body = c.m(core, pk1, pk2, tL, tR)
    c.add(body, LAV, stitch=None)
    # far ridge comb (darker lavender) across lower body
    comb = c.m(K.rect(6, 40, 58, 50), *[K.rect(x, 37 - (i % 3), x + 2.4, 41) for i, x in enumerate(range(14, 50, 4))])
    c.add(comb & body, LAVD)
    # snow: peaks and a jagged snowline down the upper body
    snow = c.m(K.poly([(13, 26), (17, 22), (19, 19), (27, 4), (32, 13), (38, 7), (46, 19), (51, 23), (51, 27),
                       (46, 25), (42, 28), (38, 24), (33, 28), (28, 24), (23, 28), (18, 25), (13, 29)]))
    c.add(snow & body, SNOW)
    # cedar clump in front = bottom tab
    ced = c.m(tB, K.ell(32, 51, 9, 4))
    c.add(ced, CEDAR)
    # peach alpenglow on the left peak face
    glow = c.m(K.poly([(27, 4), (32, 13), (30, 16), (26, 12), (22, 16)]), K.poly([(38, 7), (42, 13), (39, 16), (37, 12)]))
    c.add(glow & body, PEACH)
    # sleepy face on the lavender between snowline and comb
    if c.small:
        for ex in (24, 38):
            x, y = c.P(ex, 33)
            for dx in range(-1, 2):
                c.px(x + dx, y, K.UMBER)
        x, y = c.P(31, 37)
        c.px(x, y, K.UMBER); c.px(x + 1, y, K.UMBER)
    else:
        for ex in (24, 40):
            x, y = c.P(ex, 32)
            for dx in range(-2, 3):
                c.px(x + dx, y + (1 if abs(dx) < 2 else 0), K.UMBER)
        c.smile(32, 35)
        c.blush(20, 35); c.blush(43, 35)


K.render_pal(fn, 'pl-wced-4', 'Far Snowcaps', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wced-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wced-4.png')
