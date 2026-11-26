"""pl-wlfe-2 Butter Moonlet: edge-TTB keyhole. The full butter moon of the lantern-festival sky IS the piece: a round-cornered cream
moon disc with craters and the picture's lower-right butter shading band; keyhole tabs N and E are moon bulges, keyhole blank W bites
the moon; the flat S side is a navy-indigo night cloud bank the moon rests on (sky colours from cell 0-0)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MOON = ('#fff0c0', '#e8d8a8', '#fffbe8')
CRATER = ('#e8d8a8', '#d0c090', '#f4e6b8')
NIGHT = ('#2a2262', '#1e1c52', '#3a2a72')
CLOUD = ('#3a2a72', '#2a2262', '#5a4a92')


def rrect(x0, y0, x1, y1, r):
    def f(x, y):
        if not (x0 <= x < x1 and y0 <= y < y1):
            return False
        cx = min(max(x, x0 + r), x1 - r)
        cy = min(max(y, y0 + r), y1 - r)
        return (x - cx) ** 2 + (y - cy) ** 2 < r * r
    return f


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rrect(9, 12, 53, 57, 16)
    flat = K.rect(9, 40, 53, 57)        # bottom corners square: the flat edge
    tabN = K.knob('T', 'keyhole', 31, 13, 0, -1, r=5.0 * k)
    tabE = K.knob('T', 'keyhole', 53, 34, 1, 0, r=4.8 * k)
    blankW = K.knob('B', 'keyhole', 9, 32, -1, 0, r=4.6 * k)
    body = c.m(core, flat, tabN, tabE, minus=(blankW,))
    c.add(body, MOON, stitch=None if c.small else '#f4e2a8')
    # picture moon: butter shading band on the lower right
    band = body - c.m(K.ell(26, 31, 22, 25))
    c.add(band, ('#ecd89c', '#d0c090', '#f4e6b8'))
    # craters
    for (cx, cy, r) in ((40, 20, 3.6), (18, 22, 2.4), (45, 40, 3.0), (15, 42, 2.6)):
        rr = r * (1.25 if c.small else 1)
        cr = c.m(K.ell(cx, cy, rr, rr)) & body
        c.add(cr, ('#d8c690', '#b8a878', '#e8d8a8'))
        c.edge(cr, '#c0ae78')
    # night cloud bank along the flat bottom side
    cloud = c.m(K.rect(9, 54, 53, 57), K.ell(13, 53, 5, 4), K.ell(23, 51, 6.5, 5), K.ell(35, 52.5, 6, 4.5), K.ell(46, 51.5, 5.5, 4.5)) & body
    c.add(cloud, CLOUD)
    c.edge(cloud, NIGHT[1])
    # tiny gold stars on the cloud
    for (sx, sy) in ((24, 55), ):
        x, y = c.P(sx, sy)
        c.px(x, y, '#f8d060')
        if not c.small:
            for d in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                c.px(x + d[0], y + d[1], '#f0a020')
    # sleepy happy face
    if c.small:
        for ex in (22, 36):
            x, y = c.P(ex, 32)
            c.px(x - 1, y, K.UMBER); c.px(x, y + 1, K.UMBER); c.px(x + 1, y + 1, K.UMBER); c.px(x + 2, y, K.UMBER)
    else:
        for ex in (23, 37):
            x, y = c.P(ex, 31)
            c.px(x - 2, y, K.UMBER); c.px(x - 1, y + 1, K.UMBER); c.px(x, y + 1, K.UMBER); c.px(x + 1, y + 1, K.UMBER); c.px(x + 2, y, K.UMBER)
    c.blush(19, 37)
    c.blush(40, 37)
    c.smile(30, 39)


K.render_pal(fn, 'pl-wlfe-2', 'Butter Moonlet', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wlfe-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wlfe-2.png')
