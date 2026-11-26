"""pl-scg-2 Sack Snooze: edge-TBT, peg. A lumpy burlap sack slumped in the smugglers' rowboat, asleep.
Flat S = the rowboat gunwale it sits on (wood + red stripe from the boat, sea-blue water lapping at the hull, cell 2-6),
peg blank N = the cinched dip between the sack's two lumpy shoulders, peg tabs W + E = the knotted ends of the rope band
tied round its middle (the picture's sacks wear a dark band). Closed felt eyes + a little blue Z."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SACK = K.ramp('#c48e58')
ROPE = K.ramp('#8a5a34')
WOOD = K.ramp('#b8814e')
STRIPE = K.ramp('#a33748')
SEA = K.ramp('#1c4468')
SEAL = '#2c6888'
WEAVE = '#a87444'


def fn(c):
    k = 1.15 if c.small else 1.0
    sh_l = K.ell(19, 26, 11, 7.5)
    sh_r = K.ell(45, 26, 11, 7.5)
    core = K.rect(9.5, 25, 54.5, 57)
    tabW = K.knob('T', 'peg', 9.5, 34.5, -1, 0, r=3.4 * k)
    tabE = K.knob('T', 'peg', 54.5, 34.5, 1, 0, r=3.4 * k)
    blankN = K.knob('B', 'peg', 32, 17.5, 0, -1, r=5.0 * k)
    body = c.m(sh_l, sh_r, core, minus=(blankN,))
    c.add(body, SACK, stitch=None if c.small else WEAVE)
    # burlap weave flecks (64 only)
    if not c.small:
        for (x, y) in body:
            if (x * 3 + y * 5) % 11 == 0 and 20 < y < 44:
                c.px(x, y, WEAVE)
    # cinch wrinkles fanning down from the tied mouth (the blank)
    wr = SACK[1]
    for pts in ([(29, 30.5), (26, 32)], [(35, 30.5), (38, 32)], [(32, 30.5), (32, 32)]):
        if not c.small or pts[1][0] == 32:
            c.line(pts, wr)
    # lumps: soft shade crescents low on the belly
    if not c.small:
        c.line([(14, 47), (17, 48), (21, 47.5)], wr)
        c.line([(43, 47.5), (47, 48), (50, 47)], wr)
    # rope band round the middle, knotted ends = the side tabs
    band = c.m(K.rect(9.5, 32.5, 54.5, 36.5))
    c.add(band & body, ROPE)
    c.add(c.m(tabW, tabE, minus=(core,)), ROPE)
    # twist the rope: diagonal light dashes along band + knots
    for (x, y) in band | c.m(tabW, tabE, minus=(core,)):
        if (x + y) % 3 == 0:
            c.px(x, y, ROPE[2])
    # tied neck: a rope collar at the floor of the cinched mouth
    c.add(body & c.m(K.rect(26, 27.5, 38, 30.5)), ROPE)
    # rowboat gunwale (flat bottom side): wood, red stripe, sea at the waterline
    c.add(body & c.m(K.rect(0, 49, 64, 57)), WOOD)
    c.add(body & c.m(K.rect(0, 51.5, 64, 53.5)), STRIPE)
    c.add(body & c.m(K.rect(0, 55, 64, 57)), SEA)
    if not c.small:
        for x in range(c.P(10, 0)[0], c.P(54, 0)[0]):
            if x % 4 in (0, 1):
                c.px(x, c.P(0, 55)[1], SEAL)
        for gx in (21, 32, 43):
            x = c.P(gx, 0)[0]
            for y in range(c.P(0, 49)[1], c.P(0, 51.5)[1]):
                c.px(x, y, WOOD[1])
    else:
        for x in range(c.P(10, 0)[0], c.P(54, 0)[0]):
            if x % 3 == 0:
                c.px(x, c.P(0, 55)[1], SEAL)
    # sleeping face: closed eyes (lid arcs), small o mouth
    for ex in (24, 40):
        cx, cy = c.P(ex, 42.5)
        if not c.small:
            for dx in (-2, -1, 0, 1, 2):
                c.px(cx + dx, cy + (0 if abs(dx) == 2 else 1), K.UMBER)
        else:
            for dx in (-1, 0, 1):
                c.px(cx + dx, cy + (0 if abs(dx) == 1 else 1), K.UMBER)
    mx, my = c.P(32, 46)
    c.px(mx, my, K.UMBER2)
    if not c.small:
        c.px(mx + 1, my, K.UMBER2)
        c.blush(19, 45)
        c.blush(44, 45)
    # little Z on the right shoulder
    zx, zy = c.P(43, 21)
    if not c.small:
        for dx in range(5):
            c.px(zx + dx, zy, SEAL)
            c.px(zx + dx, zy + 4, SEAL)
        c.px(zx + 3, zy + 1, SEAL)
        c.px(zx + 2, zy + 2, SEAL)
        c.px(zx + 1, zy + 3, SEAL)
    else:
        for dx in range(3):
            c.px(zx + dx, zy, SEAL)
            c.px(zx + dx, zy + 2, SEAL)
        c.px(zx + 1, zy + 1, SEAL)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-scg-2', 'Sack Snooze', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-scg-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-scg-2.png'))
