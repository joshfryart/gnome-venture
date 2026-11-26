"""pl-wroo-4 Dotted Script Panel. Inner-TTTT, double knobs: a mossy carved stone tablet (temple stele) that IS the piece.
N tab = a moss tuft (double bump), S tab = two stubby root feet, E + W tabs = root ends of a tan wonder-root that wraps
around the panel's waist. Upper face, rows of carved dot-script below, gold V glyph and red dot from cell 4-5."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path

STONE = K.ramp('#a9ad92')
MOSS = K.ramp('#5f9a34')
ROOT = K.ramp('#b07a4c')
PIT = '#5d6250'
PITL = '#d6d8c2'
GOLDV = '#e8b030'
RED = '#c8302a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(14, 14, 50, 50)
    tN = knob('T', 'double', 32, 14, 0, -1, r=5.0 * k)
    tS = knob('T', 'double', 32, 50, 0, 1, r=5.0 * k)
    tE = knob('T', 'double', 50, 38, 1, 0, r=4.8 * k)
    tW = knob('T', 'double', 14, 38, -1, 0, r=4.8 * k)
    body = c.m(core)
    c.add(body, STONE, stitch=None if c.small else '#c9ccb4')
    # moss cap over the top edge + tuft tab
    moss = c.m(tN, ell(22, 14.5, 9, 3.6), ell(40, 15, 10, 3.2), rect(14, 14, 50, 16.5))
    c.add(moss, MOSS)
    # carved script inset (recessed panel) in the lower half
    inset = c.m(rect(18, 40.5, 46, 49))
    c.add(inset, K.ramp('#8f937a'))
    c.edge(inset, STONE[1])
    # wavy root wrapping the panel's middle, out through the E/W tabs (tab blobs are root knots)
    band = c.m(thick_path([(14, 35), (20, 33.5), (27, 36.5), (34, 34), (41, 36.5), (50, 35)], 4.6), tE, tW)
    c.add(band, ROOT)
    c.add(c.m(tS, minus=(core,)), STONE)
    # moss drips on the stone
    c.add(c.m(ell(46.5, 20, 2.6, 3.6), ell(16.5, 46, 2.4, 3)), MOSS)
    # face
    c.eye(26, 22.5)
    c.eye(38, 22.5)
    c.smile(32, 27)
    c.blush(21.5, 26)
    c.blush(42.5, 26)
    # dot script: rows of carved pits in the inset
    if c.small:
        rows = [(42, [20, 24, 28, 32, 36]), (46, [20, 24, 28, 32, 36, 40])]
    else:
        rows = [(42.5, [20.5, 24, 27.5, 31, 34.5, 38]), (46, [20.5, 24, 27.5, 31, 34.5, 38, 41.5])]
    for ry, xs in rows:
        for rx in xs:
            x, y = c.P(rx, ry)
            c.px(x, y, PIT)
            if not c.small:
                c.px(x + 1, y, PIT); c.px(x, y + 1, PIT); c.px(x + 1, y + 1, PITL)
    # gold V glyph + red dot (cell motif) at the end of the script
    x, y = c.P(42, 41.5) if c.small else c.P(42.5, 41)
    if c.small:
        c.px(x - 1, y, GOLDV); c.px(x + 1, y, GOLDV); c.px(x, y + 1, GOLDV); c.px(x, y - 1, RED)
    else:
        for dx, dy in ((-2, 0), (2, 0), (-1, 1), (1, 1), (0, 2)):
            c.px(x + dx, y + dy, GOLDV)
        c.px(x, y - 2, RED)
    # root grain
    if not c.small:
        c.line([(18, 35), (23, 34.5)], ROOT[1])
        c.line([(36, 35.5), (42, 37)], ROOT[1])


K.render_pal(fn, 'pl-wroo-4', 'Dotted Script Panel', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wroo-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wroo-4.png')
