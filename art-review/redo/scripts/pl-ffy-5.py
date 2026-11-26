"""pl-ffy-5 Night Archway: inner-BBBB, tri. A purple cave-stone archway that is the piece itself: tri blanks cut into all four sides
(N into the keystone, S into the doorway floor, E/W into the pillars). The arch window shows cell 6-4: pale moonlit sky, the moon,
a snowy peak and misty blue lowland, ringed by the glowing blue arch rim. Felt eyes on the keystone, firefly dots on the stone."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#7a68a8')
RIM = K.ramp('#3a68d0')
SKY = ('#8aa8dc', '#7090c8', '#a8c0e8')
MIST = ('#b4c4e4', '#94a8d4', '#d0dcf0')
LOW = ('#7088c0', '#506aa8', '#90a8d8')
SNOW = ('#eef2fc', '#c4cce8', '#ffffff')
MOON = ('#f0dc98', '#d8b860', '#fcf0c8')
FLY = '#d8f060'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 9, 55, 55)
    bN = K.knob('B', 'tri', 32, 9, 0, -1, r=3.6 * k)
    bS = K.knob('B', 'tri', 32, 55, 0, 1, r=3.6 * k)
    bE = K.knob('B', 'tri', 55, 40, 1, 0, r=3.6 * k)
    bW = K.knob('B', 'tri', 9, 40, -1, 0, r=3.6 * k)
    blanks = (bN, bS, bE, bW)
    body = c.m(core, minus=blanks)
    c.add(body, STONE, stitch='#9a8ac4')
    vous = c.m(K.ell(32, 37, 17, 17), K.rect(15, 37, 49, 55), minus=blanks)
    c.add(vous, K.ramp('#8a78b8'))
    c.edge(vous, STONE[1])
    if not c.small:
        import math
        for a in (200, 240, 270, 300, 340):
            t = math.radians(a)
            c.line([(32 + 13 * math.cos(t), 37 + 13 * math.sin(t)), (32 + 16.5 * math.cos(t), 37 + 16.5 * math.sin(t))], STONE[1])
        for yy in (45, 51):
            c.line([(15.5, yy), (19, yy)], STONE[1])
            c.line([(45, yy), (48.5, yy)], STONE[1])
    win_rim = c.m(K.ell(32, 37, 12.5, 12.5), K.rect(19.5, 37, 44.5, 55), minus=blanks)
    c.add(win_rim, RIM)
    win = c.m(K.ell(32, 37, 9.5, 9.5), K.rect(22.5, 37, 41.5, 55), minus=blanks)
    c.add(win, SKY)
    # misty lowland and snowy peak inside the window
    c.add(win & c.m(K.rect(0, 45, 64, 64)), MIST)
    c.add(win & c.m(K.poly([(22, 47), (30, 38.5), (33, 38), (40, 47)])), SNOW)
    c.add(win & c.m(K.rect(0, 49, 64, 64)), LOW)
    c.add(win & c.m(K.ell(39, 53, 5, 4)), K.ramp('#3a4a8a'))
    c.add(win & c.m(K.ell(26.5, 32, 3, 3)), MOON)
    # keystone face
    c.eye(25.5, 20.5)
    c.eye(38.5, 20.5)
    c.blush(21.5, 24)
    c.blush(41.5, 24)
    # fireflies on the stone
    for fx, fy in ((14, 15), (50, 14), (13.5, 30), (50.5, 28), (15, 50), (49, 50)):
        x, y = c.P(fx, fy)
        c.px(x, y, FLY)
        if not c.small:
            c.px(x + 1, y, FLY)
            c.px(x, y + 1, FLY)
            c.px(x + 1, y + 1, '#a8c040')


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-ffy-5', 'Night Archway', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ffy-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ffy-5.png')
    print(rep)
