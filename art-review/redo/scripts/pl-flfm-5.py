import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp, UMBER, UMBER2

# Temple Arch, inner-BBBB round: a lakeside hut that IS the piece. Pink hip roof (cell 5-3) on top with the N blank notched into its peak,
# warm wooden walls with E/W blanks, the S blank is the arched doorway (gold glow round it), the two lit windows are the eyes.
ROOF = ramp('#ec7172')
ROOFD = ramp('#982c5c')
WALL = ramp('#f4c488')
GLOW = ramp('#ffd870')
WIN = ramp('#fff4b8')

def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(9, 9, 55, 56)
    bN = knob('B', 'round', 32, 9, 0, -1, r=4.2 * k)
    bE = knob('B', 'round', 55, 19, 1, 0, r=3.8 * k)
    bW = knob('B', 'round', 9, 19, -1, 0, r=3.8 * k)
    bS = knob('B', 'round', 32, 56, 0, 1, r=4.6 * k)
    blanks = (bN, bE, bW, bS)
    body = c.m(core, minus=blanks)
    c.add(body, WALL, stitch=None if c.small else '#c8945a')
    # roof: hip shape filling the top of the square, eave band darker
    roof = c.m(rect(9, 9, 55, 30), minus=blanks)
    c.add(roof, ROOF)
    eave = c.m(rect(9, 27, 55, 31), minus=blanks)
    c.add(eave, ramp('#582850'))
    c.edge(eave, UMBER2)
    # roof tiles: staggered darker dashes
    if not c.small:
        for row, y in enumerate((14, 19, 24)):
            for x in range(12 + (row % 2) * 3, 54, 6):
                c.line([(x, y), (x + 2.5, y)], ROOF[1])
    else:
        for row, y in enumerate((15, 22)):
            for x in range(12 + (row % 2) * 4, 54, 8):
                c.line([(x, y), (x + 2, y)], ROOF[1])
    # hip ridge lines from the peak notch down to the eave corners
    # arched doorway (cell's lit door): plum frame, warm light inside; the S blank bites into its threshold
    frame = c.m(ell(32, 45, 9.6, 9.6), rect(22.4, 45, 41.6, 56), minus=blanks)
    c.add(frame, ramp('#82444a'))
    door = c.m(ell(32, 45, 7.4, 7.4), rect(24.6, 45, 39.4, 56), minus=blanks)
    c.add(door, GLOW)
    c.edge(door, ramp('#d8485c')[0])
    # roof underside shading (the plum band of the cell)
    c.add(c.m(rect(9, 23, 55, 27), minus=blanks), ROOFD)
    # windows = eyes
    for wx in (16.5, 47.5):
        w = c.m(rect(wx - 4.5, 34, wx + 4.5, 42))
        c.add(w, WIN)
        c.edge(w, UMBER2)
        c.eye(wx, 38.5)
    c.blush(13.5, 46)
    c.blush(50, 46)

K.render_pal(fn, 'pl-flfm-5', 'Temple Arch', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-flfm-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-flfm-5.png')
