# Smokecap Button: a grey-mauve caldera mushroom that is an edge piece. Flat bottom = caldera ground (lava-lit rim),
# left + right tri tabs on the stem, top tri blank notched into the cap (a vent the smoke puffs out of).
# Colours from cell 5-7 (mauve crater rock, dusty rose, lava orange) and the picture's cream stem + white cap spots.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

CAP = K.ramp('#a97d7d')
CAPDK = K.ramp('#8a6070')
GILL = K.ramp('#5e4260')
STEM = ('#f0d8c0', '#c8aa94', '#fff4e4')
LAVA = ('#e8602c', '#b0401c', '#f8a040')
SPOT = '#fff8ed'
SMOKE = '#dbd1e2'


def fn(c):
    k = 1.15 if c.small else 1.0
    cap0 = K.ell(32, 30, 25, 19)
    capr = K.rect(16, 11, 48, 30)
    cap = lambda x, y: cap0(x, y) or capr(x, y)
    capcut = K.rect(0, 30, 64, 64)
    stem = K.rect(15, 33, 49, 58)
    tl = K.knob('T', 'tri', 15, 45, -1, 0, r=4.5 * k)
    tr = K.knob('T', 'tri', 49, 45, 1, 0, r=4.5 * k)
    bt = K.knob('B', 'tri', 32, 11, 0, -1, r=5.0 * k)
    capm = c.m(cap, minus=(capcut, bt))
    gill = c.m(K.rect(8, 30, 56, 35), K.ell(32, 30, 24, 5), minus=(bt,))
    stemm = c.m(stem, tl, tr, minus=(K.rect(0, 0, 64, 33),))
    lava = c.m(K.rect(15, 53, 49, 58))
    c.add(stemm, STEM, stitch='#d8bca4')
    c.add(lava, LAVA)
    c.add(gill, GILL)
    c.add(capm, CAP, stitch=CAPDK[1])
    # cap spots (picture motif)
    for (x, y, r) in ((17, 22, 3.2), (45, 21, 3.4), (30, 25, 2.6), (22, 15, 2.2) if not c.small else (22, 16, 2.4)):
        for p in c.m(K.ell(x, y, r, r * 0.8)):
            if p in capm:
                c.px(p[0], p[1], SPOT)
    # gill lines
    if not c.small:
        for x in range(12, 54, 3):
            a = c.P(x, 32)
            c.px(a[0], a[1] + 1, GILL[1])
    # smoke puff rising out of the top vent, drawn inside the notch area of the cap rim
    for p in c.m(K.ell(41, 14, 3.0, 2.4)):
        if p in capm:
            c.px(p[0], p[1], SMOKE)
    # face on the stem
    c.eye(26, 41)
    c.eye(38, 41)
    c.smile(32, 46)
    c.blush(21, 46)
    c.blush(42, 46)


K.render_pal(fn, 'pl-smk-2', 'Smokecap Button', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smk-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smk-2.png')
