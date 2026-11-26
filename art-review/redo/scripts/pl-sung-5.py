# Porthole Peekaboo: inner-BBBB (double). A square of galleon hull planks whose whole middle is a big brass porthole;
# two felt eyes peek up through the cyan glass. Colours from the hull (#a9714a), brass rims (#ffdb5c) and glass (#2a98b8 / #9cf3f7).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

HULL = K.ramp('#a9714a')
PLANK = '#7a4f33'
BRASS = ('#f0c850', '#b08a2a', '#ffea5e')
GLASS = ('#2a98b8', '#1a6f8c', '#5fc0d8')
SHINE = '#9cf3f7'
ROPE = '#593f25'


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 4.4 * k
    lo, hi = 5, 59
    core = (K.rect(lo + 3, lo, hi - 3, hi), K.rect(lo, lo + 3, hi, hi - 3),
            K.ell(lo + 3, lo + 3, 3, 3), K.ell(hi - 3, lo + 3, 3, 3), K.ell(lo + 3, hi - 3, 3, 3), K.ell(hi - 3, hi - 3, 3, 3))
    blanks = (K.knob('B', 'double', 32, lo, 0, -1, r=r), K.knob('B', 'double', 32, hi, 0, 1, r=r),
              K.knob('B', 'double', lo, 32, -1, 0, r=r), K.knob('B', 'double', hi, 32, 1, 0, r=r))
    body = c.m(*core, minus=blanks)
    c.add(body, HULL, stitch=None)
    # plank seams (horizontal, like the hull)
    for py in (13, 22, 42, 51):
        x0, y = c.P(lo, py)
        x1, _ = c.P(hi, py)
        for x in range(x0, x1 + 1):
            if (x, y) in body:
                c.px(x, y, PLANK)
    # brass ring
    ring = c.m(K.ell(32, 32, 15.5, 15.5), minus=blanks)
    c.add(ring, BRASS)
    glass = c.m(K.ell(32, 32, 11.2, 11.2))
    c.add(glass, GLASS)
    c.edge(glass, '#6a4a18')
    # rivets on the ring
    for (rx, ry) in ((32 - 14, 32 - 0.01), (32 + 13.6, 32), (32, 18.3), (32, 45.7)) if False else ((22.8, 22.8), (41.5, 22.5), (22.5, 41.5), (41.5, 41.5)):
        x, y = c.P(rx, ry)
        c.px(x, y, '#b08a2a')
        if not c.small:
            c.px(x + 1, y + 1, '#fff4b0')
    # glass shine streak upper left
    if c.small:
        for (x, y) in ((13, 14), (14, 13), (13, 15)):
            c.px(x, y, SHINE)
    else:
        c.line([(24, 30), (30, 24)], SHINE)
        c.line([(25, 32), (32, 25)], SHINE)
    # peeking eyes, low in the glass, looking up
    c.eye(27.5, 36, disc=True, look=(0, -1))
    c.eye(36.5, 36, disc=True, look=(0, -1))
    # corner bolts on the hull
    for (bx, by) in ((10, 10), (54, 10), (10, 54), (54, 54)):
        x, y = c.P(bx, by)
        c.px(x, y, ROPE)
        if not c.small:
            c.px(x - 1, y - 1, HULL[2])


K.render_pal(fn, 'pl-sung-5', 'Porthole Peekaboo', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sung-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sung-5.png')
