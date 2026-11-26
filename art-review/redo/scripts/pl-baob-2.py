"""pl-baob-2 Branch Bird. Edge-TTB, peg: a plump rosy songbird perched on a baobab branch. Flat S = the branch it grips,
peg tab N = its green canopy-leaf crest, peg tab W = its peach beak (open in song), peg blank E = the notch between its purple
wing and tail. Sunset pink body, dusk-purple wing, canopy greens, peach beak (cell 3-1: canopy over pink sky and purple hill)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#c0607c')
PURP = K.ramp('#8a4c96')
LEAF = ('#48a048', '#2a6a48', '#78bc54')
BEAK = K.ramp('#f0b080')
BARK = ('#a87850', '#6e4a2e', '#c99a6a')
BELLY = K.ramp('#e89aa8')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(12, 18, 50, 57)
    round_tl = K.rect(12, 18, 17, 23)   # rounded head corner
    head_c = K.ell(17, 23, 5, 5)
    tabN = K.knob('T', 'peg', 30, 18, 0, -1, r=4.6 * k)
    tabW = K.knob('T', 'peg', 12, 31, -1, 0, r=3.9 * k)
    tip = K.poly([(5.5, 27.2), (5.5, 34.8), (1.2, 31)])
    blankE = K.knob('B', 'peg', 50, 40, 1, 0, r=4.4 * k)
    body = c.m(core, tabN, tabW, tip, minus=(blankE,)) - (c.m(round_tl) - c.m(head_c))
    c.add(body, PINK, stitch=None)
    # crest (N tab): a feather tuft, purple with canopy-green tips
    crest = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 16, 64, 19.5)))
    c.add(crest, PURP)
    c.add(crest & c.m(K.rect(0, 0, 64, 12.5)), LEAF)
    for fx in (28.2, 31.8):
        x, _ = c.P(fx, 0)
        for y in range(c.P(0, 9)[1], c.P(0, 18)[1]):
            if (x, y) in crest:
                c.px(x, y, PURP[1] if y >= c.P(0, 12.5)[1] else LEAF[1])
    # beak (W tab), peach, open in song
    c.add(c.m(tabW, tip, minus=(core,)) | (c.m(tabW) & c.m(K.rect(10, 0, 13.5, 64))), BEAK)
    bx0, by = c.P(2, 31)
    bx1, _ = c.P(10.5, 31)
    for x in range(bx0, bx1 + 1):
        c.px(x, by, K.UMBER2)
    # belly
    c.add(c.m(K.ell(25, 42, 11, 8.5)) & body, BELLY)
    # wing: purple teardrop on the back, feather lines
    wing = c.m(K.poly([(27, 27), (36, 22.5), (50, 22.5), (50, 31), (40, 35), (30, 36)])) & body
    c.add(wing, PURP)
    c.edge(wing, PURP[1])
    if not c.small:
        c.line([(34, 27), (47, 25)], PURP[1])
        c.line([(34, 31), (47, 28)], PURP[1])
    # tail fan below the blank (purple feathers with dark splits)
    tail = c.m(K.poly([(36, 50.5), (50, 46), (50, 50.5)]), K.rect(41, 45, 50, 50.5)) & body
    c.add(tail, PURP)
    c.edge(tail, PURP[1])
    if not c.small:
        c.line([(42, 49), (49, 46.5)], PURP[1])
    # branch = the flat S side, bark with a leaf tuft, toes gripping
    br = c.m(K.rect(0, 50.5, 64, 57)) & body
    c.add(br, BARK)
    c.edge(br, BARK[1])
    c.add(c.m(K.ell(17, 51, 4, 2.6)) & body, LEAF)
    for tx in (25, 33):
        x, y = c.P(tx, 50.5)
        w = 2 if c.small else 3
        for dx in range(-w + 1, w):
            c.px(x + dx, y, '#e07a30')
        c.px(x, y - 1, '#e07a30')
        c.px(x - w + 1, y + 1, '#e07a30')
        c.px(x + w - 1, y + 1, '#e07a30')
    c.eye(21, 27)
    c.blush(23, 33)


if __name__ == '__main__':
    r = K.render_pal(fn, 'pl-baob-2', 'Branch Bird', '/home/user/gnome-venture/art-review/redo/out',
                     cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-baob-2-cell.png',
                     oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-baob-2.png')
    print(r)
