"""pl-wpan-4 Fuzzy Black Boots: a squat panda that IS an inner-TTTT piece (double knobs).
N double tab = two black ears, S double tab = two plump black boots (mauve pads), W/E double tabs = black paws.
Cream head/belly and plum-black limbs from cell 4-7 (the panda's dark leg against its cream belly, grass at the foot)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path, ramp

CREAMF = ramp('#f7ebd8')
PLUM = ('#3d3042', '#29202e', '#5a4a60')
PAD = ramp('#6a4a58')
GRASS = ramp('#3f8a3c')
BAMBOO = ramp('#5cae4a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(14, 15, 50, 49)
    tN = knob('T', 'double', 32, 15, 0, -1, r=6.4 * k)
    tS = knob('T', 'double', 32, 49, 0, 1, r=7.0 * k)
    tW = knob('T', 'double', 14, 34, -1, 0, r=4.8 * k)
    tE = knob('T', 'double', 50, 34, 1, 0, r=4.8 * k)
    body = c.m(core)
    c.add(body, CREAMF)
    # ears (N tab)
    c.add(c.m(tN, minus=(core,)) | (c.m(tN) & c.m(rect(0, 14, 64, 16.5))), PLUM)
    # arms: dark band across the shoulders into the side paws
    arms = c.m(tW, tE, lambda x, y: (x < 21 or x > 43) and 29 < y < 49)
    c.add(arms & c.m(core, tW, tE), PLUM)
    # legs + boots (S tab): dark lower band
    legs = c.m(tS, lambda x, y: 42 <= y < 49 and 14 <= x < 50)
    c.add(legs, PLUM)
    # cream belly bulge over the legs
    belly = c.m(ell(32, 39, 10.5, 8.5)) & body
    c.add(belly, CREAMF)
    # boot pads (mauve)
    for sx in (28.0, 36.0):
        c.add(c.m(ell(sx, 56.5, 2.8 * k, 2.2 * k)), PAD)
    # face: plum eye patches, felt eyes
    for ex, tilt in ((24.5, 1), (39.5, -1)):
        c.add(c.m(ell(ex, 25.5, 5.6, 6.0)), PLUM)
    c.eye(24.5, 25, disc=True, look=(1, 0))
    c.eye(39.5, 25, disc=True, look=(-1, 0) if not c.small else (0, 0))
    # nose and smile
    nx, ny = c.P(32, 30)
    c.px(nx, ny, K.UMBER)
    c.px(nx - 1, ny, K.UMBER)
    if not c.small:
        c.px(nx + 1, ny, K.UMBER)
        c.px(nx, ny + 1, K.UMBER)
    c.smile(32, 32.5, K.UMBER2)
    c.blush(19.5, 30)
    c.blush(43.5, 30)
    # bamboo stalk held across the belly (picture motif)
    w = 3.0 if c.small else 3.4
    bam = c.m(thick_path([(29, 35.5), (35, 47)], w))
    c.add(bam, BAMBOO)
    jx, jy = c.P(32, 41)
    c.px(jx, jy, BAMBOO[1]); c.px(jx + 1, jy, BAMBOO[1])
    # grass tufts between the boots


K.render_pal(fn, 'pl-wpan-4', 'Fuzzy Black Boots', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wpan-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wpan-4.png')
