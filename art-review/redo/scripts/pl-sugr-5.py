# pl-sugr-5 "Syrup Shine": inner-BBBB round. The sugar shack's firebox window as a creature: a square log-framed window
# (the piece core) with four round blanks bitten into the frame, snow on the top logs, inside a roaring orange fire
# with a yellow heart (cell 7-6), a syrup pan bubbling on top; the fire has felt eyes and a smile.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

LOG = ramp('#94553c')
LOGD = ramp('#6b3b43')
BOX = ramp('#3a2a38')
FIRE = ramp('#ff7a30')
GLOW = ramp('#ffd060')
SNOW = ramp('#f6e6df')
SYRUP = ramp('#c87848')


def fn(c):
    k = 1.15 if c.small else 1.0
    r = 3.3 * k
    core = rect(6, 6, 58, 58)
    bl = (knob('B', 'round', 32, 7, 0, -1, r=r), knob('B', 'round', 32, 57, 0, 1, r=r),
          knob('B', 'round', 7, 32, -1, 0, r=r), knob('B', 'round', 57, 32, 1, 0, r=r))
    body = c.m(core, minus=bl)
    c.add(body, LOG, stitch=None)
    # log seams on the frame (horizontal logs top/bottom, vertical posts)
    win = rect(18, 19, 46, 47)
    c.add(c.m(win) & body, BOX)
    # snow cap on top logs
    c.add(c.m(lambda x, y: y < 9.5 + (1.5 if (x // 5) % 2 else 0) and 6 <= x < 58, minus=bl) & body, SNOW)
    # fire: orange tongues
    fire = poly([(17, 47), (17, 36), (21, 30), (24, 36), (28, 24), (32, 33), (36, 22), (40, 34), (43, 29), (47, 36), (47, 47)])
    c.add(c.m(fire) & c.m(win), FIRE)
    heart = poly([(22, 47), (25, 39), (29, 33), (32, 38), (36, 31), (39, 38), (42, 47)])
    c.add(c.m(heart) & c.m(win), GLOW)
    # syrup pan across top of window
    pan = rect(18, 19, 46, 23)
    c.add(c.m(pan), SYRUP)
    for bx in (21, 27, 33, 39, 44):
        c.px(*c.P(bx, 20.5), SNOW[0])
    c.edge(c.m(win), LOGD[1])
    # log seams
    if not c.small:
        for yy in (13, 51):
            for x in range(c.P(8, 0)[0], c.P(56, 0)[0]):
                p = (x, c.P(0, yy)[1])
                if p in body and not (c.P(17, 0)[0] <= x < c.P(47, 0)[0] and False):
                    c.px(*p, LOG[1])
        for xx in (12, 52):
            for y in range(c.P(0, 17)[1], c.P(0, 47)[1]):
                p = (c.P(xx, 0)[0], y)
                if p in body:
                    c.px(*p, LOG[1])
    # face in the fire glow
    c.eye(27, 41, disc=False)
    c.eye(37, 41, disc=False)
    c.smile(32, 44.5)
    c.blush(23.5, 44)
    c.blush(40, 44)


K.render_pal(fn, 'pl-sugr-5', 'Syrup Shine', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-sugr-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-sugr-5.png')
