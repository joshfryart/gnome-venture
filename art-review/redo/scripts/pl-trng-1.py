import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

# Redcap Speck: a red-cap mushroom that IS a corner piece (corner-TT, keyhole). Cap dome = top of the piece with a
# keyhole tab on top (spotted), stump-wood base with growth rings (the cell's browns, bark rim) = bottom with a keyhole
# tab on the right, flat left + bottom sides. Cream stem carries the face.
CAP = K.ramp('#c8322a')
STEM = K.ramp('#efe2c4')
WOOD = K.ramp('#8a5a3a')
RING = '#b9844e'
BARK = K.ramp('#5a3624')
MOSS = K.ramp('#4f8a3e')
SPOT = '#fbf6ea'
ROOT = '/home/user/gnome-venture/'

def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y1 = 4, 44, 60
    core = lambda x, y: x0 <= x < x1 and ((33 <= y < y1) or K.ell(24, 33, 21, 15)(x, y))
    top = K.knob('T', 'keyhole', 24, 18.6, 0, -1, r=6.0 * k, nw=2.4)
    right = K.knob('T', 'keyhole', x1, 49, 1, 0, r=6.0 * k, nw=2.4)
    body = c.m(core, top, right)
    base = c.m(lambda x, y: y >= 40, right) & body
    c.add(base, WOOD)
    c.add(c.m(lambda x, y: y >= 56) & body, BARK)
    c.add(c.m(K.ell(8, 57, 5, 4)) & body, MOSS)
    stem = c.m(K.poly([(15, 33), (33, 33), (35, 56), (13, 56)]))
    for (rx, ry) in (((12, 4.5), (7, 2.6)) if not c.small else ((12, 4.5),)):
        e = c.m(K.ell(46, 49, rx, ry), minus=(K.ell(46, 49, rx - 1.4, ry - 1.4),))
        for q in (e & base) - stem:
            c.px(q[0], q[1], RING)
    c.add(stem, STEM)
    c.edge(stem, '#c9b48e')
    cap = c.m(lambda x, y: y < 34, top) & body
    c.add(cap, CAP)
    c.add(c.m(K.rect(x0, 33, x1, 36)), ('#e8d2a8', '#b89a70', '#f4e6c8'))
    c.edge(cap, '#8e1f1c')
    spots = [(13, 27, 3.4, 2.8), (27, 23, 4.2, 3.4), (37, 30, 2.8, 2.4), (24, 10.6, 3.0, 2.6)]
    if c.small:
        spots = [(13, 27, 3.6, 3.2), (28, 23, 4.4, 3.8), (24, 10.6, 3.2, 3.0)]
    for (sx, sy, rx, ry) in spots:
        for p in c.m(K.ell(sx, sy, rx, ry)):
            c.px(p[0], p[1], SPOT)
    c.eye(20, 43)
    c.eye(28.5, 43)
    c.smile(24.5, 48)
    c.blush(16.5, 47)
    c.blush(32, 47)

K.render_pal(fn, 'pl-trng-1', 'Redcap Speck', '/home/user/gnome-venture/art-review/redo/out',
             cellfile=ROOT + 'art-review/redo/_src/pl-trng-1-cell.png',
             oldfile=ROOT + 'game/assets/img/puzzles/pals/pl-trng-1.png')
