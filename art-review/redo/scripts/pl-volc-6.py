import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
R = '/home/user/gnome-venture/'
# Concept: a chibi spice gnome that IS a whimsy piece: the straw cone hat is the top edge, the square tunic core carries
# a keyhole tab on the left side, keyhole blanks on the right side and the bottom (between the boots).
# Colours from cell 5-6: purple spice gems (tunic), terrace wood brown (beard, belt, boots), tan soil, straw gold hat.
STRAW = K.ramp('#e2b552')
BAND = K.ramp('#8a5ad0')
PURP = K.ramp('#9a6ad8')
WOOD = K.ramp('#7a4a2a')
BEARD = K.ramp('#8a5a32')
SKIN = K.ramp('#f0c8a0')
SOIL = K.ramp('#d8a060')
LILAC = '#c8a8f0'

def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(10, 30, 54, 58)
    tabs = [K.knob('T', 'keyhole', 10, 43, -1, 0, r=4.2 * s)]
    blanks = [K.knob('B', 'keyhole', 54, 43, 1, 0, r=4.0 * s),
              K.knob('B', 'keyhole', 32, 58, 0, 1, r=3.6 * s)]
    hat = K.poly([(32, 1.5), (35, 6), (50, 25), (14, 25), (29, 6)])
    brim = K.ell(32, 25, 23, 4.2)
    body = c.m(core, *tabs, minus=blanks)
    c.add(body, PURP, stitch=LILAC)
    # boots / soil at the feet
    c.add(c.m(K.rect(0, 52, 64, 64), minus=blanks) & body, WOOD)
    # belt
    c.add(c.m(K.rect(0, 45, 64, 48.5), minus=blanks) & body, WOOD)
    c.add(c.m(K.rect(29.5, 44.5, 34.5, 49)), SOIL)
    # face
    c.add(c.m(K.ell(32, 32.5, 10.5, 6.5)), SKIN)
    # beard: a rounded wedge down to the belt
    beard = c.m(K.poly([(21, 35), (25, 34.5), (32, 36.5), (39, 34.5), (43, 35), (40, 42), (32, 47.5), (24, 42)]))
    c.add(beard, BEARD)
    c.edge(beard, WOOD[1])
    # hat + brim + spice band
    c.add(c.m(hat, brim), STRAW)
    c.add(c.m(K.poly([(18.5, 20), (45.5, 20), (48, 23.5), (16, 23.5)])), BAND)
    c.edge(c.m(brim), STRAW[1])
    # spice dots on the tunic (gems from the cell)
    for (x, y) in ((16, 38), (48, 38), (15, 49.5), (46, 50)):
        p = c.P(x, y)
        c.px(*p, LILAC)
        if not c.small:
            c.px(p[0] + 1, p[1], LILAC)
    # face below the brim
    c.eye(27.5, 31) ; c.eye(36.5, 31)
    c.blush(24, 33.5); c.blush(39, 33.5)
    # nose
    nx, ny = c.P(32, 33.5)
    c.px(nx, ny, SKIN[1])
    if not c.small:
        c.px(nx - 1, ny, SKIN[1])

K.render_pal(fn, 'pl-volc-6', 'Sunhat Spicer', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-volc-6-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-volc-6.png')
