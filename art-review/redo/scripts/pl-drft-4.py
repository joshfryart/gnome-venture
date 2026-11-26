#!/usr/bin/env python3
"""pl-drft-4 "Thatch Ridge": a thatched beach-bar hut that is an inner-TTTT peg piece.
N peg = straw roof-tuft finial, W/E pegs = the thatch eaves poking out, S peg = the bar's wooden post.
Straw golds with plum strand flecks from cell 8-2; red/cream awning and coconut cups from the tavern picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/'
STRAW = K.ramp('#ecba5c')
STRAW2 = ('#d4964a', '#a86e34', '#ecba5c')
WOOD = K.ramp('#8a5634')
RED = K.ramp('#d4444a')
CREAMR = ('#f4e8d0', '#d8c8a8', '#fffaf0')
COCO = K.ramp('#c79a62')
STRAND = '#6e3c38'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.poly([(13, 21), (32, 12), (51, 21), (51, 51), (13, 51)])
    tN = K.knob('T', 'peg', 32, 13, 0, -1, r=4.4 * k)
    tW = K.knob('T', 'peg', 13, 28, -1, 0, r=4.4 * k)
    tE = K.knob('T', 'peg', 51, 28, 1, 0, r=4.4 * k)
    tS = K.knob('T', 'peg', 32, 51, 0, 1, r=4.0 * k)
    body = c.m(core, tN, tW, tE, tS)
    c.add(body, WOOD)

    def fringe(x, y):
        return y < 33 + (2.5 if int(x // 3) % 2 else 0)
    roof = body & c.m(fringe)
    c.add(roof, STRAW)
    # layered thatch rows: darker hem with scallops
    for yb in (19, 26):
        band = body & c.m(lambda x, y, yb=yb: yb <= y < yb + 2.5 + (1.5 if int(x // 3) % 2 else 0))
        c.add(band, STRAW2)
    # vertical straw strokes + a few plum stalks from the cell
    step = 3 if not c.small else 2
    for (x, y) in roof:
        if x % step == 0 and (x, y - 1) in roof and (x, y + 1) in roof and (y + x) % 5 < 2:
            c.px(x, y, STRAW[1] if not c.small else STRAW2[0])
    if not c.small:
        for sx, sy in ((20, 23), (29, 16), (40, 22), (45, 30), (24, 30), (35, 29)):
            x, y = c.P(sx, sy)
            c.px(x, y, STRAND); c.px(x, y + 1, STRAND)
    # red/cream awning
    aw = body & c.m(K.rect(0, 34, 64, 39.5), minus=(fringe,))
    c.add(aw, CREAMR)
    c.add(aw & c.m(lambda x, y: int((x - 13) // 4) % 2 == 0), RED)
    # coconut cups on the counter corners
    for cx in (18.5, 45.5):
        c.add(c.m(K.ell(cx, 47.5, 3.2, 2.8)) & body, COCO)
        if not c.small:
            x, y = c.P(cx - 1, 46)
            c.px(x, y, COCO[2])
    # face on the bar front
    c.eye(26, 44, disc=True)
    c.eye(38, 44, disc=True)
    c.smile(32, 48)


K.render_pal(fn, 'pl-drft-4', 'Thatch Ridge', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-drft-4-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-drft-4.png')
