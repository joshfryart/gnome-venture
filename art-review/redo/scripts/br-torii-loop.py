import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

R = '/home/user/gnome-venture/'
RED = K.ramp('#d8402a')
CAP = ('#4a3428', '#3a2a20', '#6a5040')
STONE = K.ramp('#c4bcaa')
STEP = '#6a5e50'
GOLD = K.ramp('#e8b030')
GRASS = K.ramp('#5aa040')


def fn(c):
    S = 1.15 if c.small else 1.0
    core = K.rect(12, 12, 52, 56)
    kasagi = K.poly([(1, 4), (10, 8), (54, 8), (63, 4), (61, 11), (53, 15), (11, 15), (3, 11)])
    nuki = K.rect(7, 21, 57, 26)
    blanks = [K.knob('B', 'hook', 32, 8, 0, -1, r=3.6 * S),
              K.knob('B', 'hook', 12, 40, -1, 0, r=4.0 * S),
              K.knob('B', 'hook', 52, 40, 1, 0, r=4.0 * S, flip=True),
              K.knob('B', 'hook', 32, 56, 0, 1, r=4.0 * S)]
    body = c.m(core, kasagi, nuki, minus=blanks)
    c.add(body, STONE)                                          # gate opening: stone stairs
    lp = c.m(K.rect(12, 12, 21, 56)) & body
    rp = c.m(K.rect(43, 12, 52, 56)) & body
    c.add(lp, RED); c.add(rp, RED)
    c.add(c.m(K.rect(12, 51, 21, 56), K.rect(43, 51, 52, 56)) & body, CAP)   # black pillar feet
    nk = c.m(nuki) & body
    c.add(nk, RED)
    kb = c.m(kasagi) & body
    c.add(kb, RED)
    c.add(c.m(K.poly([(1, 4), (10, 8), (54, 8), (63, 4), (62, 8), (54, 10), (10, 10), (2, 8)])) & body, CAP)
    c.edge(lp, RED[1]); c.edge(rp, RED[1]); c.edge(nk, RED[1]); c.edge(kb, RED[1])
    # stair treads in the opening
    for y in ((40, 46, 52) if not c.small else (41, 48)):
        c.line([(21, y), (43, y)], STEP)
        c.line([(21, y + 1.2), (43, y + 1.2)], STONE[2])
    # face on the gate opening, under the nuki
    c.eye(27, 30.5 if not c.small else 29.5)
    c.eye(37, 30.5 if not c.small else 29.5)
    c.smile(32, 35 if not c.small else 33.5)
    c.blush(24, 34); c.blush(39, 34)


K.render_pal(fn, 'br-torii-loop', 'Torii Loop', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/br-torii-loop-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/br-torii-loop.png')
