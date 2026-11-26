"""pl-wmud-5 "Cobalt Peekhole": an inner-BBBB keyhole piece that is a block of sun-baked mud wall (two crenels on top, as on the
mud mosque) with a big round cobalt-trimmed window in the middle; the creature peeks out of the dark window with two felt eyes.
Four keyhole blanks cut into the wall on every side. Colours from cell 4-2: mud tan, cobalt trim, sky-blue glint, toron beam."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MUD = K.ramp('#dca064')
MUDLT = '#f8c88a'
MUDDK = '#b27846'
COBALT = K.ramp('#2e6ab0')
SKY = '#8ccdee'
HOLE = ('#2b1c26', '#2b1c26', '#3a2836')
BEAM = K.ramp('#8a5a36')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(8, 13, 56, 57)
    mer = (K.rect(8, 7, 17, 14), K.rect(47, 7, 56, 14))
    r, w = 3.0 * k, 1.8
    bl = (K.knob('B', 'keyhole', 32, 13, 0, -1, r=r, nw=w),
          K.knob('B', 'keyhole', 32, 57, 0, 1, r=r, nw=w),
          K.knob('B', 'keyhole', 8, 35, -1, 0, r=r, nw=w),
          K.knob('B', 'keyhole', 56, 35, 1, 0, r=r, nw=w))
    body = c.m(core, *mer, minus=bl)
    c.add(body, MUD, stitch=None if c.small else MUDDK)
    # mud speckle (64 px only, sparse)
    if not c.small:
        for (x, y) in [(14, 20), (48, 22), (15, 47), (47, 49), (21, 51), (42, 18), (13, 28), (51, 44)]:
            c.px(x, y, MUDLT)
            c.px(x + 1, y + 1, MUDDK)
    # cobalt trim band across the top of the wall (as on the mosque gate), dotted with sky glints
    band = c.m(K.rect(8, 16, 56, 19)) & body
    c.add(band, COBALT)
    if not c.small:
        for (x, y) in band:
            if y == c.P(0, 17)[1] and x % 4 == 1:
                c.px(x, y, SKY)
    # cobalt ring window + dark peek hole
    ring = c.m(K.ell(32, 35, 10.5, 10.5))
    c.add(ring, COBALT)
    hole = c.m(K.ell(32, 35, 7.5, 7.5))
    c.add(hole, HOLE)
    c.edge(hole, COBALT[1])
    # sky glint on the ring, upper left
    gx, gy = c.P(25, 27)
    c.px(gx, gy, SKY)
    c.px(gx + 1, gy - 1, SKY)
    if not c.small:
        c.px(gx - 1, gy + 1, SKY)
    # sill: a little wooden beam under the window
    c.add(c.m(K.rect(22, 44.5, 42, 47.5)), BEAM)
    # peeking eyes
    c.eye(29, 35, disc=True, look=(0, -1) if not c.small else (0, 0))
    c.eye(35.5, 35, disc=True, look=(0, -1) if not c.small else (0, 0))
    c.blush(17, 41)
    c.blush(46, 41)


K.render_pal(fn, 'pl-wmud-5', 'Cobalt Peekhole', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wmud-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wmud-5.png')
