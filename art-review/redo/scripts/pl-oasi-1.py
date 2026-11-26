# Concept: a sleepy striped orange market awning that IS a corner piece. Flat sides top (the wooden rod) and left;
# keyhole blank on the right cut into the awning cloth, keyhole blank on the bottom = the arched doorway under it.
# Colours and ring motif from cell 9-4 of "The Oasis That Moves" (orange/cream scute rings, umber seams, olive-teal and gold neighbours).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ORANGE = K.ramp('#e5945a')
CREAMO = K.ramp('#f0cc94')
DEEP = K.ramp('#d87e40')
WALL = K.ramp('#d4a06a')
ROD = K.ramp('#8a5a38')
DOOR = K.ramp('#604338')
OLIVE = K.ramp('#a9a675')
GOLD = K.ramp('#ebb254')


def fn(c):
    k = 1.15 if c.small else 1.0
    wall = K.rect(9, 30, 51, 55)
    blankE = K.knob('B', 'keyhole', 57, 21, 1, 0, r=4.2 * k)
    blankS = K.knob('B', 'keyhole', 30, 55, 0, 1, r=4.0 * k)

    def cloth(x, y):           # the awning: rod to a scalloped hem, overhanging the wall on the right
        if not (9 <= x < 57 and 9 <= y < 40):
            return False
        sx = (x - 9) % 8 - 4
        return y < 33 + (16 - sx * sx) ** 0.5 * 1.1

    body = c.m(wall, cloth, minus=(blankE, blankS))
    c.add(body, WALL, stitch='#b88450')
    # shadow strip under the hem
    shade = c.m(K.rect(9, 33, 51, 41)) & body
    c.add(shade, K.ramp('#a87048'))
    # doorway: dark arch around the bottom blank
    door = c.m(K.rect(23, 42, 37, 55), K.ell(30, 43, 7, 5)) & body
    c.add(door, DOOR)
    stripes = c.m(cloth, minus=(blankE,))
    st_o = {p for p in stripes if int((p[0] + 0.5) / c.k - 9) // 8 % 2 == 0}
    c.add(stripes - st_o, CREAMO)
    c.add(st_o, DEEP)
    c.add(c.m(K.rect(9, 9, 57, 13)), ROD)
    c.add(c.m(K.ell(10, 11, 2.2, 2.2), K.ell(55.5, 11, 2.2, 2.2)), GOLD)
    # olive-teal oasis shrub in a pot by the door
    c.add(c.m(K.ell(15.5, 46, 4.2, 4.5)) & body, OLIVE)
    c.add(c.m(K.rect(12.5, 49.5, 19, 55)) & body, ORANGE)
    # scute-ring motif on the wall right of the door
    cx, cy = c.P(44.5, 47.5)
    if not c.small:
        for dx in range(-3, 4):
            for dy in range(-3, 4):
                if 5 <= dx * dx + dy * dy <= 10:
                    c.px(cx + dx, cy + dy, DEEP[0])
        c.px(cx, cy, ORANGE[0])
    else:
        for dx, dy in ((0, -1), (1, -1), (-1, 0), (2, 0), (-1, 1), (2, 1), (0, 2), (1, 2)):
            c.px(cx + dx, cy + dy, DEEP[0])
    # sleepy face on the cloth
    for ex in (22, 36):
        x, y = c.P(ex, 22)
        if c.small:
            for dx in (-1, 0, 1):
                c.px(x + dx, y + (1 if dx == 0 else 0), K.UMBER)
        else:
            for dx in (-2, -1, 0, 1, 2):
                c.px(x + dx, y + (1 if abs(dx) < 2 else 0), K.UMBER)
    c.smile(29, 27)
    c.blush(17.5, 26)
    c.blush(40.5, 26)

R = '/home/user/gnome-venture/'
print(K.render_pal(fn, 'pl-oasi-1', 'Awning Flop', R + 'art-review/redo/out',
                   cellfile=R + 'art-review/redo/_src/pl-oasi-1-cell.png',
                   oldfile=R + 'game/assets/img/puzzles/pals/pl-oasi-1.png'))
