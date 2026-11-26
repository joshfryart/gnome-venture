"""pl-mirr-4 Fluffy Pinkbelly: inner-TTTT keyhole. A round flamingo, the piece core is its fluffy body.
N tab = head on a short neck with a bent cream/umber beak, E tab = magenta tail tuft, W tab = folded wing tip,
S tab = the knees/legs dipping into the lavender mirror water. Colours from cell 3-5 (peach belly, flamingo pink, umber)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp

PINK = ramp('#f08cbc')
HOT = ramp('#d8488c')
PEACH = ramp('#f0c094')
LEG = ramp('#b83a78')
WATER = ramp('#9a8cd0')
BEAK = ramp('#f4e8dc')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: rect(12, 17, 52, 50)(x, y) and not (
        (x < 16 and y < 21 and (x - 16) ** 2 + (y - 21) ** 2 > 16) or
        (x > 48 and y < 21 and (x - 48) ** 2 + (y - 21) ** 2 > 16) or
        (x < 16 and y > 46 and (x - 16) ** 2 + (y - 46) ** 2 > 16) or
        (x > 48 and y > 46 and (x - 48) ** 2 + (y - 46) ** 2 > 16))
    tN = knob('T', 'keyhole', 32, 17, 0, -1, r=6.0 * k)
    tE = knob('T', 'keyhole', 52, 32, 1, 0, r=5.0 * k)
    tW = knob('T', 'keyhole', 12, 33, -1, 0, r=5.0 * k)
    tS = knob('T', 'keyhole', 32, 50, 0, 1, r=5.5 * k, nw=4.0)
    body = c.m(core, tN, tE, tW, tS)
    c.add(body, PINK, stitch=None)
    # head tab: brighter pink head
    head = c.m(tN, minus=(core,))
    c.add(head, PINK)
    # beak: cream, bent down, umber tip, sticking out to the left of the head
    bk = poly([(29, 5), (21, 5.5), (18, 8), (17, 14), (20, 14.5), (22, 10.5), (29, 11)])
    c.add(c.m(bk), BEAK)
    c.add(c.m(poly([(19.5, 7), (18, 8), (17, 14), (20, 14.5), (21.3, 11)])), (K.UMBER2, K.UMBER2, '#6a4430'))
    # tail tuft E and wing W: hot pink
    c.add(c.m(tE, minus=(rect(0, 0, 50, 64),)), HOT)
    wing = c.m(ell(20, 34, 9, 10), tW, minus=(rect(0, 0, 9.5, 64),)) & body
    wing = c.m(ell(19, 33, 9.5, 10.5)) | c.m(tW, minus=(core,))
    c.add(wing & body, HOT)
    c.edge(c.m(ell(19, 33, 9.5, 10.5)) & body, HOT[1])
    if not c.small:
        c.line([(14, 30), (20, 35), (22, 40)], HOT[1])
        c.line([(55, 30), (61, 28)], HOT[1])
        c.line([(55, 34), (61, 36)], HOT[1])
    # fluffy peach belly (the cell's motif) with scalloped edge
    belly = c.m(lambda x, y: ((x - 36) / 13) ** 2 + ((y - 39) / 10) ** 2 < 1 + 0.12 * ((int(x) // 3 + int(y) // 3) % 2))
    c.add(belly & body, PEACH)
    # legs tab S: water below, two leg stems
    c.add(c.m(tS, minus=(rect(0, 0, 64, 51),)), WATER)
    lw = 1.8 if not c.small else 1.8
    c.add(c.m(thick_path([(30, 47), (30, 61)], lw), thick_path([(34.5, 47), (34.5, 61)], lw)) & body, LEG)
    # face on the head
    c.eye(33, 9.5)
    c.blush(43, 31) if False else None
    c.blush(25, 22)
    c.smile(40, 24, K.UMBER2) if False else None


K.render_pal(fn, 'pl-mirr-4', 'Fluffy Pinkbelly', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mirr-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mirr-4.png')
