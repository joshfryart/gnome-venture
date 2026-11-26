import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER, UMBER2, CREAM

R = '/home/user/gnome-venture/'
FOX = ramp('#e8822a')
FOXD = ramp('#b85a1e')
SNOW = ('#eef3fa', '#b8c8e0', '#ffffff')
CAP = ramp('#a062c8')
AUR = ramp('#3fcf8e')
EARIN = ('#5a3020', '#3a2014', '#7a4a30')


def fn(c):
    """Whimsy-fox, peg: a fox face-on whose head+body is the square core; ears break out at the top corners, N peg tab = aurora-purple
    nightcap (green brim), E peg tab = white tail tip, peg blanks W and S. Fox orange from the camp fox, snow white/blue from cell 10-6."""
    k = 1.15 if c.small else 1.0
    core = rect(12, 21, 50, 56)
    earL = poly([(12, 30), (12.5, 7), (27, 21)])
    earR = poly([(50, 30), (49.5, 7), (35, 21)])
    tabN = knob('T', 'peg', 31, 21, 0, -1, r=5.0 * k)
    tabE = knob('T', 'peg', 50, 45, 1, 0, r=4.6 * k)
    bW = knob('B', 'peg', 12, 39, -1, 0, r=4.2 * k)
    bS = knob('B', 'peg', 30, 56, 0, 1, r=4.2 * k)
    body = c.m(core, earL, earR, minus=(bW, bS))
    c.add(body, FOX, stitch=FOX[1] if not c.small else None)
    # inner ears
    c.add(c.m(poly([(14.5, 26), (14.8, 12), (23, 21)])), EARIN)
    c.add(c.m(poly([(47.5, 26), (47.2, 12), (39, 21)])), EARIN)
    # lower body darker, tail up the right side with white tip (= E tab)
    low = c.m(rect(12, 44, 50, 56), minus=(bW, bS))
    c.add(low, FOXD)
    tail = c.m(ell(44, 47, 7.5, 9), minus=(bS,)) & body
    c.add(tail, FOX)
    c.add(c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(rect(47, 0, 51, 64))), SNOW)
    c.edge(tail, FOX[1])
    # white muzzle / cheeks (snow)
    c.add(c.m(poly([(15, 31), (31, 46), (47, 31), (40, 36), (31, 38), (22, 36)])), SNOW)
    c.add(c.m(ell(31, 41, 6, 4.5)), SNOW)
    # belly patch, snow blue
    c.add(c.m(ell(20, 52, 5, 3.5)) & body, SNOW)
    # nightcap: purple peg with cream pompom, green aurora brim
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 18, 64, 22))), CAP)
    c.add(c.m(rect(19, 21, 43, 25.5)), AUR)
    if not c.small:
        for (x, y) in c.m(ell(31, 13, 2.2, 2.2)):
            c.px(x, y, CREAM)
        for (x, y) in c.m(rect(26, 17, 36, 18.5)):
            c.px(x, y, CAP[2])
    else:
        x, y = c.P(31, 13)
        c.px(x, y, CREAM)
    # nose + face
    nx, ny = c.P(31, 38.5)
    for dx in range(-1, 2 if not c.small else 1):
        c.px(nx + dx, ny, UMBER)
    c.px(nx, ny + 1, UMBER)
    c.eye(24.5, 31)
    c.eye(37.5, 31)
    c.blush(19.5, 36)
    c.blush(42, 36)


K.render_pal(fn, 'pl-aurc-6', 'Nightcap Fox', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-aurc-6-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-aurc-6.png')
