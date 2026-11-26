"""pl-aurs-1 "Steam Hello": a puff of sauna steam rising out of a chimney pot, merged into a corner-BB piece.
Flat W and S sides (S = the chimney's brick base), round blanks cut into the N and E of the steam cloud.
Steam is tinted by the aurora of cell 10-1: pink-violet body, violet shade, blue aurora glow along the top."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, poly, thick_path

STEAM = ('#ecd4f4', '#c090d8', '#fbf2fd')
STEAM2 = K.ramp('#b070d8')
AUR = K.ramp('#4a98d8')
AURV = K.ramp('#b070d8')
BRICK = K.ramp('#9a5a44')
SNOW = ('#f4f0f8', '#c8bcd8', '#ffffff')


def fn(c):
    k = 1.15 if c.small else 1.0
    # steam cloud: straight W and S sides, billowing puffs along N and E around the two blanks
    core = rect(8, 16, 50, 56)
    puffs = (ell(16, 16, 8, 6), ell(42, 15, 8, 6), ell(29, 15, 9, 4), ell(50, 24, 4, 6))
    blankN = knob('B', 'round', 29, 13, 0, -1, r=4.6 * k)
    blankE = knob('B', 'round', 55, 36, 1, 0, r=4.6 * k)
    body = c.m(core, *puffs, minus=(blankN, blankE, rect(0, 0, 8, 64), rect(0, 56, 64, 64)))
    c.add(body, STEAM)
    # puff seams in lavender so the billows read
    if not c.small:
        for pts in ([(10, 43), (13, 39), (18, 38), (21, 41)], [(23, 42), (27, 38.5), (33, 38.5), (36, 42)],
                    [(38, 41), (42, 38), (47, 39), (49, 42)]):
            c.line(pts, STEAM[1])
    # aurora light washing the cloud's crown (cell 10-1 blue over violet)
    c.add(body & c.m(lambda x, y: y < 15 + (1.5 if (int(x) // 4) % 2 else 0)), AURV)
    c.add(body & c.m(lambda x, y: y < 10.5 or (y < 14 and (int(x) // 2) % 3 == 0)), AUR)
    # chimney pot: brick with a snow lip, steam pouring out of it (flat S side)
    c.add(body & c.m(rect(8, 46, 50.6, 56)), BRICK)
    c.add(body & c.m(rect(8, 44, 50.6, 47)), SNOW)
    if not c.small:
        for (y, off) in ((50.5, 0), (53.5, 4)):
            yy = c.P(0, y)[1]
            for x in range(c.P(9, 0)[0], c.P(50, 0)[0]):
                c.px(x, yy, BRICK[1])
            for bx in range(12 + off, 50, 8):
                for dy in range(1, 3):
                    c.px(c.P(bx, 0)[0], yy + dy, BRICK[1])
    else:
        yy = c.P(0, 51)[1]
        for x in range(c.P(9, 0)[0], c.P(50, 0)[0]):
            c.px(x, yy, BRICK[1])
    # steam curls
    if not c.small:
        c.line([(12, 36), (13, 33), (16, 32), (17, 35), (15, 36)], STEAM[1])
        c.line([(42, 36), (43, 39), (46, 39), (46, 37)], STEAM[1])
    # face
    c.eye(24, 30)
    c.eye(35, 30)
    c.smile(29.5, 34.5, wide=True)
    c.blush(19.5, 34)
    c.blush(39.5, 34)
    for sx, sy in ((14, 14), (44, 12)):
        x, y = c.P(sx, sy)
        c.px(x, y, '#ffffff')


K.render_pal(fn, 'pl-aurs-1', 'Steam Hello', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurs-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurs-1.png')
