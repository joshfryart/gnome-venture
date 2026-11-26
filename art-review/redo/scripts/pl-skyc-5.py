"""pl-skyc-5 Amberlit Window: inner-BBBB (double). The piece IS a sandstone ruin wall block with a tall arched window;
four double blanks bite the stone frame on every side. The pane shows the cell's sky (purple over pink) melting into
the amber sunset glow, a sleepy face in the glow, and the little blue bird from the cell perched on the sill."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#d9c1a4')
MORTAR = '#a88c70'
PURP = K.ramp('#8a5a9a')
PINK = K.ramp('#c87aa0')
AMBER = K.ramp('#f5a03c')
GLOW = K.ramp('#f8d27a')
SILL = K.ramp('#c4a882')
BIRD = K.ramp('#5a9ae0')
BEAK = '#f5a03c'


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 8, 56, 6, 58
    core = K.rect(x0, y0, x1, y1)
    r = 3.6 * s
    bl = [K.knob('B', 'double', 32, y0, 0, -1, r=r), K.knob('B', 'double', 32, y1, 0, 1, r=r),
          K.knob('B', 'double', x0, 33, -1, 0, r=r), K.knob('B', 'double', x1, 33, 1, 0, r=r)]
    body = c.m(core, minus=bl)
    c.add(body, STONE)
    # mortar courses on the stone frame
    pane = lambda x, y: (23 <= x < 41 and 27 <= y < 46) or (x - 32) ** 2 + (y - 27) ** 2 < 81
    frame = body - c.m(pane)
    if not c.small:
        for yy in (14, 22, 30, 38, 46, 53):
            py = c.P(0, yy)[1]
            for x in range(64):
                if (x, py) in frame and (x, py - 1) in frame and (x, py + 1) in frame:
                    c.px(x, py, MORTAR)
        for i, yy in enumerate((14, 22, 30, 38, 46, 53)):
            for xx in ((15, 49) if i % 2 == 0 else (12, 52)):
                px, py = c.P(xx, yy)
                for y in range(py + 1, py + 8):
                    if (px, y) in frame and all((px, y + d) in frame for d in (-1, 1)) and y < c.P(0, yy + 8)[1] - 0:
                        if y < c.P(0, [14, 22, 30, 38, 46, 53, 64][i + 1])[1]:
                            c.px(px, y, MORTAR)
    # arch voussoir ring
    ring = c.m(lambda x, y: (x - 32) ** 2 + (y - 27) ** 2 < 12.5 ** 2 and y < 28, minus=(pane,) + tuple(bl))
    c.add(ring, K.ramp('#e6d2b2'))
    c.edge(ring, MORTAR)
    # pane: sky bands into glow
    c.add(c.m(pane), PURP)
    c.add(c.m(pane, minus=(K.rect(0, 0, 64, 26),)), PINK)
    c.add(c.m(pane, minus=(K.rect(0, 0, 64, 33),)), AMBER)
    c.add(c.m(K.ell(32, 41, 7, 5), minus=(K.rect(0, 46, 64, 64),)) & c.m(pane), GLOW)
    # mullion
    c.add(c.m(K.rect(31, 17, 33.2 if not c.small else 34, 33)), STONE)
    # sill ledge
    c.add(c.m(K.rect(20, 45.5, 44, 49.5)), SILL)
    # face in the glow
    c.eye(28, 38)
    c.eye(36.5, 38)
    c.smile(32, 41.5)
    c.blush(25.5, 41)
    c.blush(39.5, 41)
    # blue bird on the sill
    bird = c.m(K.ell(41, 43, 4.4 * s, 3.0 * s), K.ell(44.2, 39.6, 2.7 * s, 2.5 * s),
               K.poly([(37.5, 42), (34.5, 40.5), (35.5, 44.5)]))
    c.add(bird, BIRD)
    c.add(c.m(K.ell(40.5, 44, 2.6 * s, 1.6 * s)), K.ramp('#c0e0fc'))
    bx, by = c.P(47.2, 39.6)
    c.px(bx, by, BEAK)
    c.px(bx + 1, by, BEAK)
    c.px(bx, by + 1, BEAK)
    ex, ey = c.P(45, 39)
    c.px(ex, ey, K.UMBER)
    if not c.small:
        c.px(ex, ey + 1, K.UMBER)
    # star in the purple sky
    sx, sy = c.P(26.5, 22)
    c.px(sx, sy, '#fff6dc')


K.render_pal(fn, 'pl-skyc-5', 'Amberlit Window', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-skyc-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-skyc-5.png')
