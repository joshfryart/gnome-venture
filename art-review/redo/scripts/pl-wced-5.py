"""pl-wced-5 Mossring Cushion. Inner-BBBB, keyhole: a plump square floor cushion (puffed corners, gently pinched sides) whose
outer band is the mossy cedar-hedge ring and whose middle is the red ribbon cushion, button-tufted; a keyhole blank bites each side.
Orange flame tassels at the corners. Hedge greens + light speckle, ribbon red, campfire orange (cell 5-6)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MOSS = K.ramp('#3c8c48')
MOSSD = ('#2a6a3a', '#1c4a2c', '#3c8c48')
SPECK = '#8cd070'
RED = K.ramp('#d03a2a')
FLAME = K.ramp('#f08a2a')


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.poly([(7, 7), (32, 8.5), (57, 7), (55.5, 32), (57, 57), (32, 55.5), (7, 57), (8.5, 32)])
    corners = [K.ell(x, y, 5.0, 5.0) for x, y in ((10, 10), (54, 10), (10, 54), (54, 54))]
    r = 2.9 * s
    blanks = (K.knob('B', 'keyhole', 32, 8.5, 0, -1, r=r), K.knob('B', 'keyhole', 32, 55.5, 0, 1, r=r),
              K.knob('B', 'keyhole', 8.5, 32, -1, 0, r=r), K.knob('B', 'keyhole', 55.5, 32, 1, 0, r=r))
    body = c.m(core, *corners, minus=blanks)
    # tassels outside the corners
    for (x, y, dx, dy) in ((6, 6, -1, -1), (58, 6, 1, -1), (6, 58, -1, 1), (58, 58, 1, 1)):
        c.add(c.m(K.ell(x + dx * 1.2, y + dy * 1.2, 2.8 * s, 2.8 * s)), FLAME)
    c.add(body, MOSS, stitch=None)
    # inner red cushion = body eroded by the moss band width
    pad = K.poly([(16, 17), (32, 19), (48, 17), (46, 32), (48, 47), (32, 45.5), (16, 47), (18, 32)])
    puffs = [K.ell(x, y, 4, 4) for x, y in ((18.5, 19.5), (45.5, 19.5), (18.5, 44.5), (45.5, 44.5))]
    inner = c.m(pad, *puffs) & body
    ring = body - inner
    # moss speckle and darker tufts on the ring
    for (x, y) in ring:
        h = (x * 7 + y * 13) % 11
        if h == 0:
            c.px(x, y, SPECK)
        elif h == 5 and not c.small:
            c.px(x, y, MOSSD[0])
    c.add(inner, RED, stitch=None if c.small else '#e8705a')
    c.edge(inner, RED[1])
    # tufting buttons
    for bx, by in ((23.5, 25), (40.5, 25), (23.5, 39.5), (40.5, 39.5)):
        x, y = c.P(bx, by)
        c.px(x, y, RED[1])
        if not c.small:
            c.px(x + 1, y, RED[1]); c.px(x, y - 1, RED[2])
    c.eye(27, 31, disc=False)
    c.eye(37, 31, disc=False)
    c.smile(32, 36)
    c.blush(23.5, 35)
    c.blush(40, 35)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wced-5', 'Mossring Cushion', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wced-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wced-5.png'))
