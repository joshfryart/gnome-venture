# Concept: a little square-rigged sailboat that IS an inner piece. Mast-top tab N and keel tab S (keyhole), sail cut by keyhole
# blanks W and E; sail striped in the sunset peach/salmon bands of cell 0-5, hull in the dusk magenta, waterline in the night purple.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PEACH = K.ramp('#ffb877')
SALMON = K.ramp('#ee8a78')
HULL = K.ramp('#b8587e')
SEA = K.ramp('#5a3a78')
MAST = K.ramp('#8a4a3a')
RED = K.ramp('#d6403a')


def fn(c):
    k = 1.15 if c.small else 1.0
    sail = K.poly([(12, 10), (52, 10), (52, 33), (46, 36.5), (32, 38), (18, 36.5), (12, 33)])
    hull = K.poly([(8, 39), (56, 39), (50, 55), (14, 55)])
    mast = K.rect(30, 8, 34, 40)
    tabN = K.knob('T', 'keyhole', 32, 10, 0, -1, r=4.3 * k)
    tabS = K.knob('T', 'keyhole', 32, 55, 0, 1, r=3.8 * k)
    blW = K.knob('B', 'keyhole', 12, 24, -1, 0, r=4.3 * k)
    blE = K.knob('B', 'keyhole', 52, 24, 1, 0, r=4.3 * k)
    # mast + top tab (mast head with red pennant colour)
    c.add(c.m(mast), MAST)
    c.add(c.m(tabN, minus=(K.rect(0, 10, 64, 64),)), RED)
    # sail: horizontal sunset bands
    sm = c.m(sail, minus=(blW, blE))
    c.add(sm, PEACH, stitch=None)
    band = c.m(lambda x, y: int((y - 10) // 6.5) % 2 == 1)
    c.add(sm & band, SALMON)
    c.edge(sm, PEACH[1])
    # hull + keel tab
    hm = c.m(hull, tabS)
    c.add(hm, HULL)
    c.add(hm & c.m(K.rect(0, 51, 64, 64), tabS), SEA)
    c.edge(c.m(hull), HULL[1])
    # mast drawn over the sail
    c.add(c.m(K.rect(30.5, 10, 33.5, 38)), MAST)
    # face on the hull
    c.eye(24, 44.5)
    c.eye(40, 44.5)
    c.smile(32, 46)
    c.blush(19, 47)
    c.blush(44, 47)


K.render_pal(fn, 'pl-wlig-3', 'Thimble Sailboat', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlig-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlig-3.png')
print(K.check(K.draw(fn, 64))['colours'])
