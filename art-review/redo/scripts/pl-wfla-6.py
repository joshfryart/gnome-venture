# Stallkeeper Plumeling (pl-wfla-6): a flamingo minding a feather stall, merged into one whimsy-stallbird keyhole piece.
# Square pink body = the bird; keyhole tab N = neck + head with black-tipped bent beak; keyhole tab W = tail plume;
# keyhole blank E bites the wing; flat S = the stall counter with a lilac/cream striped skirt. Shallows pinks + lilac water (cell 6-6).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#ef8ca6')
ROSE = K.ramp('#d86a88')
WING = K.ramp('#a9496f')
BEAK = ('#3a2830', '#2b1c26', '#5a3a4a')
BILL = K.ramp('#ffc8d2')
LILAC = K.ramp('#c880b0')
CREAMR = K.ramp('#ffe4dc')
WOOD = K.ramp('#b07a5a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: K.rect(12, 30, 52, 50)(x, y) or K.rect(18, 24, 46, 50)(x, y) or K.ell(18, 30, 6, 6)(x, y) or K.ell(46, 30, 6, 6)(x, y)
    # neck (keyhole flare at the base) + head bulb
    neckbase = K.knob('T', 'keyhole', 28, 24, 0, -1, r=4.0 * k, nw=3.0 * k)
    neck = K.thick_path([(28, 24), (26, 17), (29, 10)], 4.6 * k)
    head = K.ell(31, 8.5, 6.5, 5.5)
    beak = K.poly([(35, 5), (43, 7), (44, 12), (41, 15), (39, 12), (35, 12)])
    tabW = K.knob('T', 'keyhole', 12, 36, -1, 0, r=5.0 * k)
    blankE = K.knob('B', 'keyhole', 52, 34, 1, 0, r=4.6 * k)
    counter = K.rect(8, 48, 56, 61)
    body = c.m(core, neckbase, neck, head, beak, tabW, counter, minus=(blankE,))
    c.add(body, PINK, stitch=None)
    # tail plume (tab W), deeper pink
    c.add(body & c.m(tabW, K.rect(12, 30, 15, 42), minus=(K.rect(15, 0, 64, 64),)), ROSE)
    # folded wing hugging the blank
    wing = body & c.m(K.ell(38, 37, 12, 9), minus=(K.rect(0, 46, 64, 64),))
    c.add(wing, ROSE)
    c.edge(wing, WING[0])
    if not c.small:
        for fy, fx0 in ((35, 30), (39, 31), (43, 33)):
            c.line([(fx0, fy), (fx0 + 8, fy + 2)], WING[0])
    # head and beak
    c.add(body & c.m(beak), BILL)
    c.add(body & c.m(K.poly([(39, 9), (44, 9), (44, 12), (41, 15), (38, 12)])), BEAK)
    # counter: wooden top plank + striped skirt
    plank = body & c.m(K.rect(8, 48, 56, 52))
    c.add(plank, WOOD)
    skirt = body & c.m(K.rect(8, 52, 56, 61))
    sw = 6 if not c.small else 6.5
    for i in range(9):
        x0 = 8 + i * sw
        c.add(skirt & c.m(K.rect(x0, 52, x0 + sw, 61)), LILAC if i % 2 == 0 else CREAMR)
    # three plumes for sale standing on the counter
    for px_, col in ((18, WING), (23, ROSE), (47, WING)):
        c.add(c.m(K.ell(px_, 43, 2.2 * k, 5.5), minus=(K.rect(0, 48, 64, 64),)) & body, col)
        c.add(c.m(K.thick_path([(px_, 43), (px_, 48)], 1.4 * k)) & body, CREAMR)
    # eye on the head, blush on the cheek
    c.eye(31, 8.5)
    c.blush(31, 12)


K.render_pal(fn, 'pl-wfla-6', 'Stallkeeper Plumeling', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wfla-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wfla-6.png')
