# pl-wced-1 "Misty Moonpeek": a pale cream moon peeking over layered cedar pads.
# corner-BB, keyhole: flat left + flat bottom (the ground), keyhole blanks cut into the top (moon) and right side.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MOON = ('#fbeedb', '#e8c9a8', '#ffffff')
PEACH = ('#efd2b4', '#e0b896', '#f8e4cc')
GLOW = ('#f6c49a', '#e8a878', '#f8d6b4')
CEDAR = ('#3f8f3c', '#2a6a2e', '#6cb54e')
CEDAR2 = ('#2f7434', '#21552a', '#4f9a44')
RIB = K.ramp('#d8402a')
X0, Y0, X1, Y1 = 6, 7, 55, 58


def fn(c):
    k = 1.15 if c.small else 1.0
    R, r0 = 24, 5
    core = [K.rect(X0, Y0 + R, X1, Y1), K.rect(X0 + r0, Y0, X1 - R, Y1), K.rect(X0, Y0 + r0, X1 - R, Y1),
            K.ell(X0 + r0, Y0 + r0, r0, r0), K.ell(X1 - R, Y0 + R, R, R)]
    blanks = (K.knob('B', 'keyhole', 19, Y0, 0, -1, r=4.4 * k),
              K.knob('B', 'keyhole', X1, 37, 1, 0, r=4.6 * k))
    body = c.m(*core, minus=blanks)
    c.add(body, MOON)
    # moon shade crescent along the right of the dome (peach, the cell's sky colour)
    c.add(c.m(K.ell(X1 - R, Y0 + R, R, R), minus=(K.ell(X1 - R - 4, Y0 + R - 2, R, R),)) & body, GLOW)
    # faint peach craters (moon motif / sky colour)
    for cx, cy, r in ((15, 24, 3.0), (40, 15, 2.4), (27, 13, 1.8)):
        c.add(c.m(K.ell(cx, cy, r, r * 0.85)) & body, PEACH)
    # cedar canopy: back row darker, front row brighter, flat bottom = ground
    back = c.m(K.ell(14, 41, 11, 5.5), K.ell(34, 39, 12, 5.5), K.ell(52, 41, 9, 5.5)) & body
    c.add(back, CEDAR2)
    front = c.m(K.ell(20, 49, 16, 6.5), K.ell(45, 48, 14, 6.5), K.rect(0, 51, 64, 64)) & body
    c.add(front, CEDAR, stitch='#8fcf6a')
    c.edge(front, '#21552a')
    # red ribbons hanging on the pads (from the picture)
    for x, y in ((12, 40), (40, 38), (30, 48)):
        c.add(c.m(K.rect(x, y, x + 1.9 / k * k + (0.9 if c.small else 0), y + 4.5)), RIB)
    # face peeking just above the trees
    c.eye(23, 28)
    c.eye(36, 28)
    c.blush(18, 32)
    c.blush(41, 32)
    c.smile(29.5, 32)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wced-1', 'Misty Moonpeek', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wced-1-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wced-1.png'))
