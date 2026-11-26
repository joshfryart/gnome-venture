"""pl-wdol-2 Scarlet Chatterbox: edge-TBB keyhole. A scarlet macaw in profile facing left IS the piece.
Flat S = the mossy trunk-brown branch it grips; keyhole tab W = its big round hooked beak; keyhole blank N = the dip between head and back;
keyhole blank E = bite in the wing. Wing coverts in the cell's sage green, flight feathers blue, yellow band; branch in the picture's trunk brown."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

RED = K.ramp('#d6302a')
YEL = K.ramp('#f0c030')
SAGE = K.ramp('#8cc89a')
BLUE = K.ramp('#3a6ec0')
BARK = K.ramp('#8a5a34')
MOSS = K.ramp('#6aa878')
BEAK = ('#ece4d0', '#b8ae98', '#fbf6ea')
BEAKLO = ('#4a3a30', '#2f241e', '#6a5648')
FACE = ('#f4f0e4', '#d8d0c0', '#ffffff')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(14, 11, 52, 57)
    tabW = knob('T', 'keyhole', 14, 27, -1, 0, r=5.6 * k)
    hook = poly([(2.5, 25), (9, 30), (10, 37.5), (6, 36.5), (2.5, 31)])
    blankN = knob('B', 'keyhole', 40, 11, 0, -1, r=3.6 * k)
    blankE = knob('B', 'keyhole', 52, 33, 1, 0, r=3.8 * k)
    # round off the top-left corner like a head
    corner = lambda x, y: x < 22 and y < 19 and (x - 22) ** 2 + (y - 19) ** 2 > 64
    body = c.m(core, tabW, hook, minus=(blankN, blankE, corner))
    c.add(body, RED, stitch=None)
    # wing: sage coverts, yellow band, blue flight feathers sweeping down-right
    wing = c.m(poly([(30, 24), (44, 21), (52, 26), (52, 46), (46, 52), (36, 50), (29, 38)]), minus=(blankE,))
    c.add(wing & body, SAGE)
    # raised waving wing tip = the post right of the top blank (blue tips, sage coverts)
    c.add(c.m(rect(43.5, 11, 52, 24)) & body, SAGE)
    c.add(c.m(rect(43.5, 11, 52, 16)) & body, BLUE)
    c.edge(c.m(rect(43.5, 11, 52, 30)) & body, SAGE[1])
    c.add(c.m(poly([(30, 33), (52, 30), (52, 37), (31, 39)]), minus=(blankE,)) & body, YEL)
    c.add(c.m(poly([(32, 41), (52, 39), (52, 48), (46, 52), (37, 50)])) & body, BLUE)
    if not c.small:
        for x0 in (38, 43, 48):
            c.line([(x0, 42), (x0 - 2, 50)], BLUE[1])
    # tail: long blue/red feathers down the right edge to the branch
    c.add(c.m(rect(47, 46, 52, 57)) & body, BLUE)
    # branch (flat bottom side)
    br = c.m(rect(0, 50, 64, 57)) & body
    c.add(br, BARK)
    c.add(c.m(rect(14, 50, 52, 52)) & body, MOSS)
    if not c.small:
        for x in range(c.P(16, 0)[0], c.P(50, 0)[0], 5):
            c.px(x, c.P(0, 54)[1], BARK[1])
            c.px(x + 1, c.P(0, 54)[1], BARK[1])
    # feet gripping the branch
    for fx in (24, 31):
        c.add(c.m(ell(fx, 50.5, 2.6, 2.2)), ('#5a5a62', '#3e3e46', '#7a7a84'))
    # beak: the keyhole tab, cream upper mandible, dark lower
    # white bare face runs into the keyhole neck; the round keyhole bulb + hook is the beak
    c.add(c.m(ell(20, 25, 6, 6.5), rect(10, 21, 15, 33)) & body, FACE)
    beak = c.m(tabW, hook, minus=(rect(9.5, 0, 64, 64),))
    c.add(beak, BEAK)
    c.add(c.m(poly([(4, 30), (10, 28.5), (12, 33), (8, 34)])) & body, BEAKLO)
    if not c.small:
        c.line([(16, 28), (19, 29.5), (23, 28)], '#c9c5bc')
    c.eye(20.5, 22.5)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-wdol-2', 'Scarlet Chatterbox', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wdol-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wdol-2.png')
    print(rep)
