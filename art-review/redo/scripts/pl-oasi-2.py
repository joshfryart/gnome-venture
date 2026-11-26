import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
import math
from pal_kit import rect, ell, poly, thick_path, knob, ramp

# Frond Fanfare: edge-TBB keyhole. A palm tree that is an edge piece: flat bottom = peach dune (cell 9-2),
# keyhole tab N = the young frond spear, keyhole blanks W and E cut into the pink sky (cell 9-2).
# The top half is a green fan of fronds (picture's palms) with drooping tips past the corners; trunk in the middle.
GREEN = ramp('#479949')
GREENL = ramp('#7ac85a')
TRUNK = ramp('#8a5a36')
SKY = ramp('#e8b0b0')
SAND = ramp('#ffc890')
NUT = ramp('#6a4428')
DKG = '#2f6a3a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 15, 54, 58)
    tabN = knob('T', 'keyhole', 32, 15, 0, -1, r=5.0 * k)
    blankW = knob('B', 'keyhole', 10, 45, -1, 0, r=4.4 * k)
    blankE = knob('B', 'keyhole', 54, 45, 1, 0, r=4.4 * k)
    # drooping frond tips past the upper corners (rounded)
    droopW = thick_path([(16, 20), (9, 24), (5.5, 30)], 6.0 if not c.small else 6.5)
    droopE = thick_path([(48, 20), (55, 24), (58.5, 30)], 6.0 if not c.small else 6.5)
    body = c.m(core, minus=(blankW, blankE))
    # sky (lower half background)
    c.add(body, SKY)
    # sand dune: flat bottom, curved crest like the cell
    dune = c.m(lambda x, y: y > 51 + 3.5 * math.cos((x - 26) / 14.0) - 1.5 and 10 <= x < 54, minus=(blankW, blankE))
    c.add(dune & body, SAND, stitch=None)
    # trunk
    trunk = c.m(poly([(28, 34), (36, 34), (37.5, 57), (26.5, 57)]))
    c.add(trunk & body, TRUNK)
    if True:
        for yy in (39, 44, 49, 54):
            c.line([(27.5, yy), (36.5, yy + 1)], TRUNK[1])
    # canopy: fan of fronds over the top of the core + droops + spear tab
    saw = lambda x, y: 10 <= x < 54 and 15 <= y < 31.5 + 3.2 * (1 - abs(((x - 10) % 5.5) / 2.75 - 1))
    canopy = c.m(saw, ell(32, 31, 12, 5), droopW, droopE)
    c.add(canopy, GREEN)
    # alternating lighter fronds of the fan (wedges from the crown)
    def wedge(x, y):
        a = math.degrees(math.atan2(y - 34, x - 32))
        return int((a + 180) // 18) % 2 == 0
    c.add(canopy & c.m(wedge, minus=(ell(32, 26, 11, 6),)), GREENL)
    spear = c.m(tabN, minus=(rect(10, 15.8, 54, 34),))
    c.add(spear, GREENL)
    # frond ribs radiating from the crown (avoid the face zone)
    for ang in (-160, -130, -50, -20):
        a = math.radians(ang)
        c.line([(32 + 9 * math.cos(a), 33 + 9 * math.sin(a)), (32 + 24 * math.cos(a), 33 + 22 * math.sin(a))], DKG)
    c.line([(16, 20), (9, 24), (6, 29)], DKG)
    c.line([(48, 20), (55, 24), (58, 29)], DKG)
    # jagged frond leaflet notches along the canopy hem
    if not c.small:
        for xx in range(14, 52, 4):
            c.px(*c.P(xx, 33.5), DKG)
    # coconuts under the crown
    c.add(c.m(ell(28.5, 37.5, 2.8, 2.8), ell(35.5, 37.5, 2.8, 2.8)), NUT)
    # face on the calm canopy centre
    c.eye(26, 25)
    c.eye(38, 25)
    c.smile(32, 29.5)
    c.blush(22.5, 28)
    c.blush(41, 28)


K.render_pal(fn, 'pl-oasi-2', 'Frond Fanfare', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-oasi-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-oasi-2.png')
