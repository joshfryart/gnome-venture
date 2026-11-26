import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""pl-smg-5 Salthall Roundel: inner-BBBB peg. A pink salt-wall block framed in mine timber (posts and lintel), with a big round lit window
(the glowing tunnel mouth of the salt-mine picture) in the middle. Peg blanks cut into all four sides; the face lives in the warm glow."""

SALT = K.ramp('#e4c4cc')      # cell 1-4 salt wall
LAVB = K.ramp('#a898c8')      # lavender blotches
TIMB = K.ramp('#8a5a30')      # mine frame timber
RIM = K.ramp('#5e3a2a')       # carved window rim
GLOW = K.ramp('#f0dca0')      # lit window
GLOWC = '#fbf0c8'             # hot centre


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 8, 8, 56, 56
    core = K.rect(x0, y0, x1, y1)
    cut = lambda x, y: (min(x - x0, x1 - x) < 3 and min(y - y0, y1 - y) < 3) and \
        ((x - (x0 + 3 if x < 32 else x1 - 3)) ** 2 + (y - (y0 + 3 if y < 32 else y1 - 3)) ** 2 > 9)
    r = 3.6 * k
    bN = K.knob('B', 'peg', 32, y0, 0, -1, r=r)
    bS = K.knob('B', 'peg', 32, y1, 0, 1, r=r)
    bW = K.knob('B', 'peg', x0, 32, -1, 0, r=r)
    bE = K.knob('B', 'peg', x1, 32, 1, 0, r=r)
    blanks = (bN, bS, bW, bE, cut)
    body = c.m(core, minus=blanks)
    c.add(body, SALT, stitch=None)
    # lavender salt blotches (from the picture's wall)
    blot = c.m(K.ell(17, 46, 5, 3.5), K.ell(47, 20, 4.5, 3), K.ell(46, 48, 3.5, 2.5), minus=blanks)
    c.add(blot & body, LAVB)
    # timber frame: lintel on top, posts left and right
    fr = 5.5
    lintel = c.m(K.rect(x0, y0, x1, y0 + fr), minus=blanks)
    posts = c.m(K.rect(x0, y0, x0 + fr, y1), K.rect(x1 - fr, y0, x1, y1), minus=blanks)
    c.add(posts, TIMB)
    c.add(lintel, TIMB)
    c.edge(lintel, TIMB[1])
    # round window
    cx, cy = 32, 33
    rim = c.m(K.ell(cx, cy, 13, 13), minus=blanks)
    win = c.m(K.ell(cx, cy, 10.5, 10.5))
    c.add(rim, RIM)
    c.add(win, GLOW)
    # warm glow: soft rings toward a hot centre (top-left), like the tunnel mouth of the picture
    c.edge(win, '#e0b868')
    hot = c.m(K.ell(cx - 1.5, cy - 1.5, 7.5, 7.0))
    for p in hot:
        c.px(p[0], p[1], GLOWC)
    for p in c.m(K.ell(cx - 5, cy - 5.5, 2.2, 1.6)):
        c.px(p[0], p[1], '#ffffff' if False else '#fffaf0')
    # salt crystals hanging under the lintel (the stalactites of the picture)
    for sx in (17, 47):
        tri = c.m(K.poly([(sx - 3, y0 + fr - 0.5), (sx + 3, y0 + fr - 0.5), (sx, y0 + fr + 6.5)]))
        for p in tri:
            c.px(p[0], p[1], '#f4eef6')
        x, y = c.P(sx + 1.5, y0 + fr + 0.5)
        c.px(x, y, '#c9bcdc')
    # rim rivets of light salt at 4 diagonals
    import math
    for a in (45, 135, 225, 315):
        x, y = c.P(cx + 11.8 * math.cos(math.radians(a)), cy + 11.8 * math.sin(math.radians(a)))
        c.px(x, y, '#f4eef4')
    # face in the glow
    c.eye(28, 32)
    c.eye(36.5, 32)
    c.smile(32, 36.5, wide=True)
    c.blush(25, 36)
    c.blush(39, 36)


K.render_pal(fn, 'pl-smg-5', 'Salthall Roundel', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-smg-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-smg-5.png')
