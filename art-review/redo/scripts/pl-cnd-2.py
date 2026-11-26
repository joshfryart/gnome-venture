"""pl-cnd-2 Ledge Feather. Edge-BTB, tri: an upright condor flight feather that IS the piece. Flat S = the bone-white
down ruff it stands on (the condor's ruff / ledge), tri tab N = the pointed feather tip, tri blanks W + E = the notches
split into the vane. Cream quill up the middle, slanting barb lines, dusky condor purple from cell 3-2, bone-white tip."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

VANE = ('#56426e', '#3a2c56', '#78629f')
VANE2 = ('#78629f', '#56426e', '#9a82bc')
BONE = ('#f8e6bc', '#cdb48a', '#fffbe8')
QUILL = ('#f4dcb0', '#c9a878', '#fff4dc')
HEAD = '#e07a48'


def fn(c):
    k = 1.15 if c.small else 1.0
    # feather core: straight sides, top corners rounded into the tip
    core = lambda x, y: rect(13, 28, 51, 58)(x, y) or (ell(32, 29, 19, 19)(x, y) and y < 29)
    tabN = knob('T', 'tri', 32, 11, 0, -1, r=4.6 * k, nw=4.0)
    blankW = knob('B', 'tri', 13, 36, -1, 0, r=4.4 * k)
    blankE = knob('B', 'tri', 51, 36, 1, 0, r=4.4 * k)
    body = c.m(core, tabN, minus=(blankW, blankE))
    c.add(body, VANE)
    # lighter outer vane half (light from upper left)
    c.add(body & c.m(lambda x, y: x < 32), VANE2)
    # bone-white tip of the feather (like the wing tips in the picture)
    c.add(body & c.m(lambda x, y: y < 9.5), BONE)
    # quill down the middle
    qw = 3.2 if c.small else 2.6
    c.add(body & c.m(thick_path([(32, 8), (32, 58)], qw)), QUILL)
    # barbs: slanting lines up-and-out from the quill
    if not c.small:
        for y0 in (18, 25, 32, 41, 47):
            c.line([(29.5, y0 + 3), (17, y0 - 3)], VANE[1])
            c.line([(34.5, y0 + 3), (47, y0 - 3)], VANE[1])
        c.line([(31, 44), (15, 40)], VANE[1]); c.line([(31, 45), (15, 41)], '#e8d8f8')
    else:
        for y0 in (24, 36, 47):
            c.line([(29, y0 + 3), (18, y0 - 2)], VANE[1])
            c.line([(35, y0 + 3), (46, y0 - 2)], VANE[1])
    # down ruff along the flat bottom (scalloped top edge)
    ruff = body & c.m(lambda x, y: y > 49.5 - 2.6 * abs(((x - 13) % 8) - 4) / 4 + 1.6)
    c.add(ruff, BONE)
    # face on the vane, small orange beak-blush below the eyes
    c.eye(24.5, 29, disc=True)
    c.eye(39.5, 29, disc=True)
    c.smile(32, 36, '#f8e6bc')
    c.blush(20.5, 34)
    c.blush(43.5, 34)


K.render_pal(fn, 'pl-cnd-2', 'Ledge Feather', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cnd-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cnd-2.png')
