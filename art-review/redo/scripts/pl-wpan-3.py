import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER

R = '/home/user/gnome-venture/'
SHOOT = ramp('#6fb040')     # bamboo sheath green
SHOOT2 = ramp('#8ed060')    # lighter sheath
TIP = ramp('#b8e070')       # fresh tip
GRASS = ramp('#9ad84a')     # lime grass from the cell
SOIL = ramp('#4a3048')      # panda plum, used for the earth crumbs
LINE = '#3e6e2a'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = poly([(21, 12), (43, 12), (54, 61), (10, 61)])
    tabN = knob('T', 'keyhole', 32, 12, 0, -1, r=4.6 * k)
    spike = poly([(28.5, 4), (32, -2), (35.5, 4)])
    bW = knob('B', 'keyhole', 15.9, 37, -0.976, -0.22, r=2.7 * k, nw=1.6)
    bE = knob('B', 'keyhole', 48.1, 37, 0.976, -0.22, r=2.7 * k, nw=1.6)
    bS = knob('B', 'keyhole', 32, 61, 0, 1, r=2.2 * k, nw=1.4)
    body = c.m(core, tabN, spike, minus=(bW, bE, bS))
    c.add(body, SHOOT)
    # overlapping sheaths: big up-pointing scales, alternating shades, pale tips
    rows = ((40, SHOOT, (20, 44), 15), (26, SHOOT2, (32,), 14), (14, SHOOT, (32,), 9))
    for (y, rmp, xs, w) in rows:
        for cx in xs:
            sh = poly([(cx - w, y + 18), (cx, y - 3), (cx + w, y + 18)])
            m = c.m(sh) & body
            c.add(m, rmp)
            c.edge(m, LINE)
            tipm = c.m(poly([(cx - 2.6, y + 2.5), (cx, y - 3), (cx + 2.6, y + 2.5)])) & body
            c.add(tipm, TIP)
    tip = c.m(tabN, spike, minus=(rect(0, 13, 64, 64),))
    c.add(tip, TIP)
    # grass tuft at the base with blades poking up
    def grass(x, y):
        if y >= 54:
            return True
        ph = (x % 6) / 6.0
        return y >= 54 - 6 * (1 - abs(ph * 2 - 1))
    g = c.m(grass) & body
    c.add(g, GRASS)
    # face on the middle sheath
    c.eye(27, 39, disc=True)
    c.eye(37, 39, disc=True)
    c.blush(23.5, 44)
    c.blush(40, 44)
    c.smile(32, 44)


K.render_pal(fn, 'pl-wpan-3', 'Sproutling Patch', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-wpan-3-cell.png', oldfile=R + 'game/assets/img/puzzles/pals/pl-wpan-3.png')
