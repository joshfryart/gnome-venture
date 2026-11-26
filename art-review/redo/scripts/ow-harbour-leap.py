import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

GREY = ramp('#8b9096')
BELLY = ('#d8dce0', '#a9afb5', '#eef0f2')
SEA = ramp('#2f79aa')
FOAM = ramp('#efe0b7')


def fn(c):
    """whimsy-dolphin, hook: a grey dolphin leaping out of a blue sea block. Hook tabs E and S (sea), hook blank W under the beak."""
    k = 1.3 if c.small else 1.0
    # piece core with a rounded top: the dolphin's arched back
    core = lambda x, y: (12 <= x < 52 and 20 <= y < 57) and not (y < 30 and ((x - 32) / 21) ** 2 + ((y - 30) / 12) ** 2 > 1)
    beak = poly([(14, 30), (4, 33), (4, 37), (14, 38)])
    fin = poly([(26, 21), (32, 8), (35, 9), (38, 20)])
    fluke = poly([(44, 24), (52, 10), (56, 8), (55, 13), (60, 14), (58, 18), (50, 28)])
    tabE = knob('T', 'hook', 52, 40, 1, 0, r=5.6 * k, nw=3.2)
    tabS = knob('T', 'hook', 32, 57, 0, 1, r=5.0 * k, nw=3.0, flip=True)
    blankW = knob('B', 'hook', 12, 49.5, -1, 0, r=3.8 * k)
    sil = c.m(core, beak, fin, fluke, tabE, tabS, minus=(blankW,))
    sea_line = lambda x, y: y > 43 + 1.6 * __import__('math').sin(x / 3.0)
    body = sil - c.m(sea_line)
    c.add(body, GREY)
    c.add(sil & c.m(sea_line), SEA)
    # cream foam crest along the waterline (the breakwater cream)
    foam = c.m(lambda x, y: 41.5 + 1.6 * __import__('math').sin(x / 3.0) < y <= 43.6 + 1.6 * __import__('math').sin(x / 3.0)) & sil
    c.add(foam, FOAM)
    # pale belly
    c.add(c.m(ell(26, 41, 13, 5)) & body, BELLY)
    c.add(c.m(poly([(5, 35.5), (14, 35.5), (14, 38), (5, 37)])) & body, BELLY)
    c.edge(c.m(fin) - c.m(core), GREY[1])
    # face
    c.eye(19, 30)
    c.blush(22, 35)
    c.line([(6, 35.2), (13, 35.6)], '#4a2c1a')
    # splash drops
    for (x, y) in ((8, 50), (56, 52)):
        pass
    if not c.small:
        for (x, y) in body:
            if 47 <= x <= 52 and 15 <= y <= 30 and (x + y) % 5 == 0:
                pass


K.render_pal(fn, 'ow-harbour-leap', 'Harbour Leap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/ow-harbour-leap-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/ow-harbour-leap.png')
print('ok')
