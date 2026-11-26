"""pl-wsto-3 Noon Sunwink: inner-TBTB keyhole. A round yellow sun that is a plus-ish jigsaw piece: E + W keyhole tabs are fat sun rays,
N + S keyhole blanks bite the disc; four short rounded rays poke from the corners. Winking face, a sky-blue cloud wisp (cell 11-1 sky)
drifts over the lower body with a peach horizon glow, colours from the picture's setting sun."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SUN = K.ramp('#f6c43c')
SUNLT = ('#ffe78a', '#e8a82a', '#fff4c6')
RAY = K.ramp('#f0a030')
SKY = ('#8cc0e8', '#5a8ec0', '#b4d4ec')
CLOUD = ('#f4f0e4', '#b4d4ec', '#ffffff')
PEACH = '#f0dcc0'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(19, 12), (45, 12), (52, 19), (52, 45), (45, 52), (19, 52), (12, 45), (12, 19)])
    disc = K.ell(32, 32, 19, 19)
    tabE = K.knob('T', 'keyhole', 52, 32, 1, 0, r=5.2 * k)
    tabW = K.knob('T', 'keyhole', 12, 32, -1, 0, r=5.2 * k)
    blN = K.knob('B', 'keyhole', 32, 12, 0, -1, r=3.4 * k)
    blS = K.knob('B', 'keyhole', 32, 52, 0, 1, r=3.4 * k)
    rays = []
    for sx, sy in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
        b = 16.5
        t = 26.5 if c.small else 25.5
        rays.append(K.poly([(32 + sx * b, 32 + sy * (b - 7)), (32 + sx * t, 32 + sy * t), (32 + sx * (b - 7), 32 + sy * b)]))
    c.add(c.m(*rays, minus=(blN, blS)), RAY)
    c.add(c.m(tabE, tabW, minus=(core,)), RAY)
    body = c.m(core, disc, minus=(blN, blS))
    c.add(body, SUN, stitch=None if c.small else '#ffe78a')
    # inner sun glow disc (lighter centre, upper-left)
    glow = c.m(K.ell(29, 28, 11, 10), minus=(blN, blS))
    c.add(glow & body, SUNLT)
    # sky-blue cloud wisp drifting across the lower body
    cloud = c.m(K.ell(40, 42.5, 8, 3.4), K.ell(45, 40.5, 4.5, 3.6), minus=(blN, blS))
    c.add(cloud & body, CLOUD)
    c.edge(cloud & body, SKY[0])
    # face: one open eye, one winking arc, smile, peach-blush
    c.eye(25, 29)
    wx, wy = c.P(38, 29)
    if c.small:
        for dx, dy in ((-1, 0), (0, 1), (1, 1), (2, 0)):
            c.px(wx + dx, wy + dy, K.UMBER)
    else:
        for dx, dy in ((-2, -1), (-1, 0), (0, 0), (1, 0), (2, -1)):
            c.px(wx + dx, wy + dy, K.UMBER)
    c.smile(31.5, 35, wide=True)
    c.blush(20.5, 34)
    c.blush(42.5, 33)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-wsto-3', 'Noon Sunwink', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-wsto-3-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-wsto-3.png'))
