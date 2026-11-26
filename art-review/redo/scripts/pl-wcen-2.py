"""pl-wcen-2 Plinking Pebbles: edge-BTB keyhole. A smooth grey pool pebble that IS an edge piece: flat bottom = the pool floor
(teal water band with the cell's pale ripple dashes), keyhole tab on top = a falling drip, keyhole blanks W and E cut into the stone.
Colours from cell 8-7: stone greys #9da2a2/#586070, pool teal #28a0aa, ripple #d8fff0."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

STONE = ('#9da2a2', '#586070', '#c8ccc6')
STONE2 = ('#868c90', '#48505f', '#b4b8b4')
POOL = K.ramp('#28a0aa')
POOL2 = ('#44c8c0', '#1f7a94', '#8ee8dc')
DRIP = ('#8ee8dc', '#44c8c0', '#e8fff0')
RIP = '#d8fff0'


def se(cx, cy, rx, ry, p=3.2):
    return lambda x, y: abs((x - cx) / rx) ** p + abs((y - cy) / ry) ** p < 1


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: se(32, 33, 23, 21)(x, y) or (9 <= x < 55 and 33 <= y < 55)
    peb = se(32, 34, 23, 19, 2.4)
    tabN = K.knob('T', 'keyhole', 32, 12.5, 0, -1, r=5.0 * k)
    bW = K.knob('B', 'keyhole', 9, 31, -1, 0, r=3.8 * k, nw=2.2)
    bE = K.knob('B', 'keyhole', 55, 31, 1, 0, r=3.8 * k, nw=2.2)
    body = c.m(core, minus=(bW, bE))
    c.add(body, STONE, stitch=None if c.small else STONE[2])
    # drip tab (falling water drop) in pale teal
    drip = c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(K.rect(0, 11, 64, 14)))
    c.add(drip, DRIP)
    # dark underside of the pebble (shadow like the cell)
    c.add(body & c.m(lambda x, y: y >= 40 and peb(x, y)), STONE2)
    # pool water = the flat edge; the pebble's rounded bottom shows through it, tinted
    pool = body & c.m(lambda x, y: y >= 33 and not peb(x, y))
    c.add(pool, POOL)
    c.edge(c.m(peb) & body, '#48505f')
    water = body & c.m(K.rect(0, 46, 64, 64))
    c.add(water, POOL)
    sub = water & c.m(peb)
    c.add(sub, ('#3a8290', '#2a6474', '#4a98a0'))
    c.add(body & c.m(K.rect(0, 46, 64, 47.6)), POOL2)
    # second little pebble plinking in the water (right)
    if not c.small:
        c.add(c.m(K.ell(49, 51.5, 3.6, 2.0)), STONE2)
    # ripple dashes (from the cell)
    if not c.small:
        for (y, x0, x1, ph) in ((40, 10, 13, 0), (40, 51, 54, 0), (50, 11, 45, 0), (53, 12, 53, 3)):
            for x in range(c.P(x0, 0)[0], c.P(x1, 0)[0]):
                if (x + ph) % 6 < 3:
                    c.px(x, c.P(0, y)[1], RIP)
    else:
        y = c.P(0, 51.5)[1]
        for x in range(c.P(11, 0)[0], c.P(53, 0)[0]):
            if x % 4 < 2:
                c.px(x, y, RIP)
    # ripple ring around the drip point on the stone: a pale highlight streak (wet sheen)
    c.add(c.m(K.ell(22, 22, 6, 2.6)) & body, ('#e0e4dc', '#c8ccc6', '#f4f6ee'))
    # face
    c.eye(25, 31, disc=False)
    c.eye(39, 31, disc=False)
    c.smile(32, 36)
    c.blush(21, 35)
    c.blush(42, 35)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-wcen-2', 'Plinking Pebbles', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-wcen-2-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-wcen-2.png'))
