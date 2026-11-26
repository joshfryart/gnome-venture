"""pl-mgr-2 "Frog Peeper": edge-TTB, peg. A green tree frog that IS an edge piece.
Flat S = the mossy mangrove log it sits on; peg tabs W and E = its splayed front feet with toe pads;
peg blank N = the dip of its head between two bulging yellow eyes (the cell 5-6 is the frog's yellow eye on teal water)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

FROG = ('#8cd058', '#4c9a3c', '#c8f07a')     # cell greens #9ad85f / #6cc044 / #c8f07a
FROGD = ('#5aa83e', '#30733f', '#8cd058')    # back spots, darker frog green
BELLY = ('#d4f08c', '#9ad85f', '#eefac0')
EYE = ('#ffe27a', '#d8a838', '#fff2b8')      # the cell's yellow eye
LOG = ('#8a5a3a', '#5e3a2a', '#b07a52')      # mangrove root brown
MOSS = ('#3c8c44', '#2a6440', '#6cc044')
TEAL = ('#3a9494', '#2e7a84', '#7fd0c8')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 28, 54, 51)
    hump = ell(32, 32, 23, 11)
    eyeL, eyeR = ell(19, 23, 9.5, 8.5), ell(45, 23, 9.5, 8.5)
    tabW = knob('T', 'peg', 10, 41, -1, 0, r=4.6 * k, nw=3.0)
    tabE = knob('T', 'peg', 54, 41, 1, 0, r=4.6 * k, nw=3.0)
    blankN = knob('B', 'peg', 32, 21.5, 0, -1, r=3.8 * k)
    logb = rect(7, 50, 57, 60)
    body = c.m(core, hump, eyeL, eyeR, tabW, tabE, minus=(blankN,))
    c.add(body, FROG, stitch=None if c.small else FROG[1])
    # log the frog sits on (flat bottom edge), moss lip, teal water glint at the ends
    lg = c.m(logb)
    c.add(lg, LOG)
    c.add(c.m(lambda x, y: 49.5 <= y < 52.5 + (1.6 if (int(x) // 4) % 2 else 0) and 7 <= x < 57), MOSS)
    if not c.small:
        for x in range(c.P(12, 0)[0], c.P(52, 0)[0]):
            if x % 6 == 0:
                c.px(x, c.P(0, 56)[1], LOG[1]); c.px(x + 1, c.P(0, 56)[1], LOG[1])
    # belly
    c.add(c.m(ell(32, 46, 13, 6.5), minus=(logb,)) & body, BELLY)
    # back spots
    for sx, sy, r in ((26, 33, 2.4), (38, 33, 2.4)) if not c.small else ():
        c.add(c.m(ell(sx, sy, r, r * 0.8)) & body, FROGD)
    # front feet: toe pads on the peg tabs
    for tx in (3.5, 60.5):
        for dy in ((-3.2, 0, 3.2) if not c.small else (-3, 3)):
            m = c.m(ell(tx, 41 + dy, 1.8 * k, 1.5 * k)) & body
            c.add(m, BELLY)
    # big yellow eyes with horizontal umber pupils
    for ex in (19, 45):
        c.add(c.m(ell(ex, 22.5, 6.2, 5.8)), EYE)
        cx, cy = c.P(ex, 23)
        if not c.small:
            for dx in range(-2, 3):
                c.px(cx + dx, cy, K.UMBER); c.px(cx + dx, cy - 1, K.UMBER)
            c.px(cx - 1, cy - 3, '#ffffff'); c.px(cx - 2, cy - 3, '#ffffff')
        else:
            for dx in range(-1, 2):
                c.px(cx + dx, cy, K.UMBER)
            c.px(cx - 1, cy - 2, '#ffffff')
    # wide frog grin and cheeks
    y = c.P(0, 38)[1]
    x0, x1 = c.P(21, 0)[0], c.P(43, 0)[0]
    for x in range(x0 + 1, x1):
        c.px(x, y, K.UMBER)
    c.px(x0, y - 1, K.UMBER); c.px(x1, y - 1, K.UMBER)
    c.blush(18, 36); c.blush(45, 36)
    # nostrils
    if not c.small:
        c.px(*c.P(29.5, 29.5), FROG[1]); c.px(*c.P(34, 29.5), FROG[1])


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-mgr-2', 'Frog Peeper', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mgr-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mgr-2.png')
    print(rep)
