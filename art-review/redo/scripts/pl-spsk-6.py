import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

# Minty Fez Vendor: whimsy-fez, peg. A red fez (truncated cone) IS the piece: peg tab N = fez button, gold tassel cord down the
# right side ending in a gold peg tab E, peg blanks W and S. Cell 6-4: fez red, tassel gold, cream fur brim, purple dusk.
FEZ = ramp('#c8283a')
TASSEL = ('#f0b020', '#b07a10', '#f8d870')
CREAMR = ramp('#efe2c8')
PURP = ramp('#5a3c8c')
MINT = ramp('#4fb88a')
ROOT = '/home/user/gnome-venture'

def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(18, 14), (46, 14), (51, 54), (13, 54)])
    tabN = knob('T', 'peg', 32, 14, 0, -1, r=4.6 * k)
    tabE = knob('T', 'peg', 49.8, 40, 0.99, -0.12, r=4.0 * k)
    blankW = knob('B', 'peg', 15.6, 30, -0.99, -0.12, r=3.4 * k, nw=2.2)
    body = c.m(core, minus=(blankW,))
    c.add(body, FEZ, stitch='#e86a70')
    # button on top (peg tab), dark fez red
    c.add(c.m(tabN, minus=(core,)), ramp('#8e1a28'))
    # tassel cord: from button over the top and down the right side, ending in the gold peg tab
    cw = 2.8 if not c.small else 3.2
    c.add(c.m(thick_path([(32, 13.5), (42, 15.5), (47.5, 22), (49.5, 40)], cw)) & (body | c.m(tabN)), TASSEL)
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(rect(46, 33, 52, 48))), TASSEL)
    # brim band: cream (bunny fur) with a mint stripe (mint tea)
    c.add(body & c.m(rect(0, 47, 64, 64)), CREAMR)
    c.add(body & c.m(rect(0, 45, 64, 47.6)), MINT)
    # face on the red
    c.eye(26, 31)
    c.eye(38, 31)
    if c.small:
        c.smile(31, 37)
    else:
        c.smile(32, 37, wide=True)
    c.blush(21.5, 35)
    c.blush(41.5, 35)
    # tassel threads on the gold tab
    if not c.small:
        x0, y0 = c.P(53, 34)
        for dx in (0, 2, 4):
            for dy in range(0, 7):
                if (x0 + dx, y0 + dy) in c.m(tabE):
                    c.px(x0 + dx, y0 + dy, TASSEL[1])

K.render_pal(fn, 'pl-spsk-6', 'Minty Fez Vendor', ROOT + '/art-review/redo/out',
             cellfile=ROOT + '/art-review/redo/_src/pl-spsk-6-cell.png',
             oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-spsk-6.png')
