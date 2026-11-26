import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

# Mazeroot Mangrove (whimsy-mangrove, tri): a little mangrove whose square brown root-trunk is the piece core.
# N tri tab = canopy leaf tip, E tri tab = a root stub, W tri blank cut into the trunk, S tri tab = water ripple.
# Root arches (the maze) stand in a teal water strip; colours from cell 11-5 (brown/plum roots, teal water) + green canopy.
BARK = ramp('#aa6b4c')
ROOT = ramp('#8c4c3c')
LEAF = ('#4a9c50', '#2f6a3a', '#7ac87a')
WATER = ramp('#3a9494')
PLUM = '#5c2c3c'


def fn(c):
    k = 1.15 if c.small else 1.0
    canopy = [ell(32, 14.5, 18, 9), ell(19, 19.5, 8, 6), ell(45, 19.5, 8, 6)]
    trunk = rect(13, 20, 51, 46)
    roots = poly([(13, 44), (51, 44), (55, 54), (9, 54)])
    water = rect(8, 53, 56, 59.5)
    arches = [ell(cx, 54, 3.4, 6.2) for cx in (19.5, 32, 44.5)]
    tabN = knob('T', 'tri', 32, 6, 0, -1, r=3.8 * k)
    tabE = knob('T', 'tri', 50, 33, 1, 0, r=4.0 * k)
    tabS = knob('T', 'tri', 32, 59.5, 0, 1, r=4.0 * k)
    blkW = knob('B', 'tri', 14, 33, -1, 0, r=4.0 * k)

    tr = c.add(c.m(trunk, tabE, minus=[blkW] + canopy), BARK, stitch=None if c.small else '#c88a5c')
    rt = c.add(c.m(roots, minus=arches + [blkW]), ROOT)
    c.add(c.m(water, tabS), WATER)
    rt2 = c.add(c.m(roots, minus=arches + [water, blkW]), ROOT)
    # root ridges curving down into the water
    if not c.small:
        for pts in ([(24, 45), (26, 49), (26, 53)], [(38, 45), (38, 49), (38.5, 53)], [(14, 46), (12, 53)], [(50, 46), (52, 53)]):
            c.line(pts, PLUM)
    cp = c.add(c.m(*canopy, tabN), LEAF)
    c.edge(cp, LEAF[1])
    c.edge(rt2, PLUM)
    # bark streaks (plum, like the cell)
    for pts in ([(18, 26), (19, 30)], [(46, 25), (45, 29)], [(20, 40), (22, 43)], [(44, 39), (42, 43)]):
        if c.small:
            continue
        c.line(pts, PLUM)
    # leaf highlights
    for (lx, ly) in ((22, 12), (30, 9), (40, 12), (16, 18), (48, 18)):
        x, y = c.P(lx, ly)
        c.px(x, y, '#9bd960')
        if not c.small:
            c.px(x + 1, y, '#9bd960')
    # water ripple lines
    if not c.small:
        for wx in (11, 24, 36, 49):
            x, y = c.P(wx, 56.5)
            for d in range(3):
                c.px(x + d, y, '#9ae0c8')
    else:
        x, y = c.P(36, 56.5)
        c.px(x, y, '#9ae0c8'); c.px(x + 1, y, '#9ae0c8')
    c.eye(26, 32)
    c.eye(38, 32)
    c.smile(32, 37.5)
    c.blush(22, 36.5)
    c.blush(41, 36.5)


K.render_pal(fn, 'pl-mgr-6', 'Mazeroot Mangrove', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mgr-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mgr-6.png')
print(K.check(K.draw(fn, 64))['colours'], K.check(K.draw(fn, 36))['colours'])
