# pl-cnd-6 "Grand Condor Plume": a giant purple condor flight feather that is the piece.
# Vane = square-ish core with a rounded feather tip on top; right side peg TAB, left side peg BLANK (a split in the vane),
# bottom peg TAB = the orange-red quill sticking out of a cream downy ruff. Colours from cell 6-2: wing purple, condor-neck red, cream ruff.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROOT = '/home/user/gnome-venture/'
PURP = K.ramp('#786295')
PURPD = K.ramp('#56426e')
LAV = '#9a82bc'
RED = K.ramp('#b04a40')
CREAMR = ('#f8e6bc', '#d8b890', '#fff4d0')
PINK = '#b2609e'


def fn(c):
    s = 1.15 if c.small else 1.0
    # vane: straight piece sides x 14 / 49, tip curling up to the upper right like a plume, tapering at the bottom into the down
    vane_p = K.poly([(14, 40), (14, 20), (16, 12), (21, 6), (28, 2.5), (37, 0.8), (44, 1.5), (47.5, 6), (49, 14), (49, 41),
                     (42, 47), (21, 47)])
    tab_l = K.knob('T', 'peg', 14, 27, -1, 0, r=4.5 * s)
    blank_r = K.knob('B', 'peg', 49, 38, 1, 0, r=4.0 * s)
    quill = K.knob('T', 'peg', 31.5, 55, 0, 1, r=3.0 * s, nw=1.8 * s)
    splits = (K.poly([(12, 15.5), (22, 15), (13, 19)]), K.poly([(51, 21), (42, 22.5), (51, 25)]))
    vane = c.m(vane_p, tab_l, minus=(blank_r,) + splits)
    c.add(vane, PURP, stitch=None if c.small else LAV)
    # darker right half of the vane (real two-tone feather)
    half = c.m(K.poly([(33, 0), (64, 0), (64, 50), (32, 50), (33, 24)])) & vane
    c.add(half, PURPD)
    # barbs: light diagonal bands sweeping from the shaft out and up
    w = 1.3 if not c.small else 1.8
    for y in ((12, 22, 32, 41) if not c.small else (16, 32)):
        c.add(c.m(K.thick_path([(31, y), (16, y - 8)], w)) & vane, ('#b9a6d6',) * 3)
        c.add(c.m(K.thick_path([(34, y - 2), (47, y - 10)], w)) & vane, (LAV,) * 3)
    # downy cream ruff and the quill peg
    down = [K.ell(21, 48, 4.5, 4), K.ell(26, 51, 4, 3.6), K.ell(37, 51, 4, 3.6), K.ell(42.5, 48, 4.5, 4), K.ell(31.5, 49, 3.5, 3)]
    c.add(c.m(*down), CREAMR)
    c.add(c.m(quill, K.rect(30, 50, 33, 57)), RED)
    # rachis (shaft) in condor-neck red, curving up to the tip
    c.add(c.m(K.thick_path([(31.5, 48), (32, 30), (34, 16), (38, 7), (42, 2.5)], 2.7 if c.small else 2.3)), RED)
    # pink tip accent
    c.add(c.m(K.ell(42, 3.5, 5, 4)) & vane, (PINK, '#8e3e7a', '#d68ec4'))
    # face on the calm middle of the vane, either side of the shaft
    c.eye(24.5, 28, disc=True)
    c.eye(39.5, 26, disc=True)
    c.smile(32.5, 34, col=K.UMBER)
    c.blush(20, 34)
    c.blush(43.5, 32)


K.render_pal(fn, 'pl-cnd-6', 'Grand Condor Plume', ROOT + 'art-review/redo/out',
             cellfile=ROOT + 'art-review/redo/_src/pl-cnd-6-cell.png',
             oldfile=ROOT + 'game/assets/img/puzzles/pals/pl-cnd-6.png')
