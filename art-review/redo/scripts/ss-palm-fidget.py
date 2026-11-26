# Palm Fidget: an edge piece that is a little coconut palm. Flat side = sandy base; top = keyhole TAB (coconut cluster
# poking up from the crown); left and right = keyhole BLANKS cut into the tan trunk. Fronds droop over the top corners.
# Colours: cell's wing tan #c2ad8e / #8f7a5d (trunk + rings), picture's palm greens, coconut brown, sand, sky-blue breeze.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

TRUNK = K.ramp('#c2ad8e')
RING = '#8f7a5d'
FROND = K.ramp('#4fae4a')
FROND2 = K.ramp('#3a8b3f')
NUT = K.ramp('#905f2c')
SAND = K.ramp('#e6cf98')
SKY = '#7fcfe6'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(11, 20, 53, 57)
    top = K.knob('T', 'keyhole', 32, 20, 0, -1, r=4.6 * s)
    lb = K.knob('B', 'keyhole', 11, 45, -1, 0, r=3.6 * s, nw=2.2)
    rb = K.knob('B', 'keyhole', 53, 45, 1, 0, r=3.6 * s, nw=2.2)
    blanks = (lb, rb)
    c.add(c.m(core, minus=blanks), TRUNK)
    c.add(c.m(K.rect(11, 51, 53, 57), minus=blanks), SAND)
    # fronds: a crown band plus long leaves drooping out over both top corners, with leaflet notches underneath
    leafL = K.poly([(32, 21), (18, 19), (8, 23), (4, 31), (9, 29), (11, 33), (15, 29), (18, 33), (21, 29), (25, 32), (28, 28), (32, 29)])
    leafR = K.poly([(32, 21), (46, 19), (56, 23), (60, 31), (55, 29), (53, 33), (49, 29), (46, 33), (43, 29), (39, 32), (36, 28), (32, 29)])
    band = K.rect(11, 20, 53, 27)
    upL = K.poly([(31, 22), (24, 15), (16, 11), (9, 12), (14, 14), (13, 17), (18, 16), (19, 20), (23, 19), (25, 23)])
    upR = K.poly([(33, 22), (40, 15), (48, 11), (55, 12), (50, 14), (51, 17), (46, 16), (45, 20), (41, 19), (39, 23)])
    c.add(c.m(upL, upR), FROND2)
    c.add(c.m(band, leafL, leafR, minus=blanks), FROND, stitch=None)
    inner = c.m(K.poly([(32, 23), (22, 23), (16, 27), (22, 26), (32, 27)]), K.poly([(32, 23), (42, 23), (48, 27), (42, 26), (32, 27)]))
    c.add(inner, FROND2)
    # coconuts under the crown, and the keyhole tab = a sprouting coconut on top
    c.add(c.m(top, minus=(band,)) | c.m(K.ell(32, 19.5, 5.5, 3.4)), NUT)
    # trunk rings (cell tan/brown) and a sky-blue breeze on the sand
    for y in (33, 48):
        c.line([(14, y), (32, y + 1.5), (50, y)], RING)
    if not c.small:
        c.line([(12, 21), (20, 25), (24, 29)], FROND2[1])
        c.line([(52, 21), (44, 25), (40, 29)], FROND2[1])
    c.line([(18, 54), (24, 54)], SKY)
    c.line([(38, 54), (45, 54)], SKY)
    c.eye(27, 39)
    c.eye(37, 39)
    c.smile(32, 44)
    c.blush(23, 43)
    c.blush(41, 43)


r = K.render_pal(fn, 'ss-palm-fidget', 'Palm Fidget', '/home/user/gnome-venture/art-review/redo/out',
                 cellfile='/home/user/gnome-venture/art-review/redo/_src/ss-palm-fidget-cell.png',
                 oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ss-palm-fidget.png')
print(r)
