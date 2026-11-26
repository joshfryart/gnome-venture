# Cherry Topper: a stone-head watcher (moai) wearing a cherry-red cap. Corner-TT, keyhole: flat W + S (the block head's
# side and chin base), keyhole tab N = the cap's cherry pom, keyhole tab E = the stone ear. Stone lilac-grey, moss-green hair
# peeking under the cap, peach sunset brim band (cell 0-3 sky).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = K.ramp('#aaa2b4')
STONE_D = K.ramp('#7d7590')
MOSS = K.ramp('#5aa04a')
CHERRY = K.ramp('#c8283a')
PEACH = K.ramp('#f6c890')
STEM = K.ramp('#4f8a3a')


def fn(c):
    k = 1.15 if c.small else 1.0
    dome = lambda x, y: 9 <= x < 49 and K.ell(29, 31, 22, 12)(x, y) and y < 31
    core = lambda x, y: K.rect(9, 30, 49, 59)(x, y) or dome(x, y)
    tabN = K.knob('T', 'keyhole', 29, 20, 0, -1, r=5.6 * k)
    tabE = K.knob('T', 'keyhole', 49, 43, 1, 0, r=4.6 * k)
    body = c.m(core, tabN, tabE)
    # stone head (whole body first)
    c.add(body, STONE)
    # stone ear in the E tab, darker stone
    ear = c.m(tabE, minus=(core,)) | (c.m(tabE) & c.m(K.rect(47, 0, 50, 64)))
    c.add(ear, STONE_D)
    c.add(c.m(K.ell(54.5, 43, 1.6, 2.2)), K.ramp('#5e5676'))
    # cherry cap: dome across the top of the core
    cap = c.m(K.rect(9, 0, 49, 31)) & body
    c.add(cap, CHERRY)
    # cherry pom = the N keyhole tab, with a little stem + leaf on top
    pom = c.m(tabN, minus=(core,))
    c.add(pom, CHERRY)
    c.edge(pom, CHERRY[1])
    # peach brim band
    brim = c.m(K.rect(9, 29, 49, 32.5)) & body
    c.add(brim, PEACH)
    # moss hair tufts peeking under the brim
    hair = c.m(lambda x, y: 32.5 <= y < 35 + (3.2 if ((x - 9) // 3) % 2 == 0 else 0) and (x < 15 or x > 43)) & body
    c.add(hair, MOSS)
    # heavy stone brow
    sock = c.m(K.rect(14, 40, 44, 47))
    c.add(sock & body, STONE_D)
    brow = c.m(K.rect(13, 37, 45, 40.5))
    c.add(brow & body, STONE)
    c.edge(brow, STONE[2])
    # long nose
    nose = c.m(K.poly([(26.5, 39), (31.5, 39), (33.5, 50), (24.5, 50)]))
    c.add(nose, STONE)
    c.edge(nose, STONE_D[1])
    # flat thin lips
    lips = c.m(K.rect(21, 53, 37, 55.6))
    c.add(lips, STONE_D)
    # moss patches on the stone (picture motif)
    if not c.small:
        for (x, y) in [(13, 46), (14, 47), (13, 47), (42, 51), (43, 51), (43, 52), (17, 56), (18, 56)]:
            c.px(*c.P(x, y), MOSS[0])
        lx, ly = c.P(29, 9.5)
    # stem + leaf on the cherry pom
    c.add(c.m(K.ell(35, 9.5, 3.6, 2.0)), MOSS)
    c.line([(29, 13), (31, 9.5), (33, 9.5)], STEM[1])
    c.eye(20.5, 44, disc=True)
    c.eye(37.5, 44, disc=True)


K.render_pal(fn, 'pl-wsto-1', 'Cherry Topper', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wsto-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsto-1.png')
