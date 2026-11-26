import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

# Woolly Pennants: a woven wool banner of four hanging pennant stripes on a wooden rod. inner-TTTT, double knobs on all four sides.
# Colours from cell 6-5 (sunset pink and peach clouds, cream sky, checker dither) plus the lavender of the ledges.
PINK = K.ramp('#eaa0b4')
PEACH = K.ramp('#f4ae84')
LAV = K.ramp('#9a7cc0')
CREAM = K.ramp('#f8d8a8')
WOOD = K.WOOD
ROOT = '/home/user/gnome-venture'


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 14, 15, 50, 51
    core = K.rect(x0, y0, x1, y1)
    tT = K.knob('T', 'double', 32, y0, 0, -1, r=4.5 * s)
    tB = K.knob('T', 'double', 32, y1, 0, 1, r=4.5 * s)
    tL = K.knob('T', 'double', x0, 33, -1, 0, r=4.5 * s)
    tR = K.knob('T', 'double', x1, 33, 1, 0, r=4.5 * s)
    W = (x1 - x0) / 4
    cols = [PINK, PEACH, LAV, CREAM]
    # four pennant stripes
    # pennant points reach the outline: V notches between the stripes and at the bottom corners (tab covers the middle seam)
    notch = []
    for nx in (x0, x0 + W, x1 - W, x1):
        notch.append(K.poly([(nx - 5, y1 + 1), (nx, y1 - 5.5), (nx + 5, y1 + 1)]))
    c.cut |= c.m(*notch, minus=(tB,))
    for i, rp in enumerate(cols):
        a, b = x0 + i * W, x0 + (i + 1) * W
        c.add(c.m(K.rect(a, y0, b, y1)), rp)
    # side tabs take the colour of the outer pennants, bottom tab lavender wool, top tab is the rod's wooden loop
    c.add(c.m(tL, minus=(core,)), PINK)
    c.add(c.m(tR, minus=(core,)), CREAM)
    c.add(c.m(tB, minus=(core,)), LAV)
    rod = K.rect(x0, y0, x1, y0 + (4.5 if c.small else 4))
    c.add(c.m(rod, tT, minus=(K.rect(x0, y0 + 5, x1, 64),)), WOOD)
    # pennant tips: small V notches painted (not cut) at the bottom of each stripe
    for i, rp in enumerate(cols):
        a = x0 + i * W
        m = c.m(K.poly([(a + 0.5, y1 - 7), (a + W / 2, y1 - 2.5), (a + W - 0.5, y1 - 7), (a + W - 0.5, y1), (a + 0.5, y1)]))
        c.edge(m, rp[1])
    # stripe seams
    for i in range(1, 4):
        a = x0 + i * W
        c.edge(c.m(K.rect(x0 + (i - 1) * W, y0 + 4, a, y1)), cols[i - 1][1])
    # weave checker (cell's dither) on the stripes at 64 px
    if not c.small:
        for i, rp in enumerate(cols):
            a, b = x0 + i * W, x0 + (i + 1) * W
            for (px, py) in c.m(K.rect(a + 1.5, y0 + 6, b - 1.5, y1 - 9)):
                if (px + py) % 4 == 0 and py % 2 == 0:
                    c.px(px, py, rp[2])
    # face across the middle pennants
    c.eye(25.5, 31, disc=False)
    c.eye(38.5, 31, disc=False)
    c.smile(32, 37)
    c.blush(21, 36)
    c.blush(43, 36)


K.render_pal(fn, 'pl-sll-4', 'Woolly Pennants', ROOT + '/art-review/redo/out',
             cellfile=ROOT + '/art-review/redo/_src/pl-sll-4-cell.png',
             oldfile=ROOT + '/game/assets/img/puzzles/pals/pl-sll-4.png')
