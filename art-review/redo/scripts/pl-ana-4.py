# Scale Diamonds (pl-ana-4): a coiled anaconda seen from above IS an inner-TTTT piece. The square core is the coil,
# four double tabs (two-lobed, like coil loops) stick out N E S W, the head rests in the middle of the coil with
# the picture's yellow eyes, four dark diamond markings ride the coil. Colours from cell 4-7: lime scales, mid green, dark spot green.
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

LIME = K.ramp('#c4ea78')
MID = ('#3f8a3c', '#2e6a34', '#5aa044')
DARK = '#1c4434'
EYE = '#e8c020'
TONGUE = '#d8302a'


def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(13, 13, 51, 51)
    tabs = [K.knob('T', 'double', 32, 13, 0, -1, r=5.0 * s), K.knob('T', 'double', 51, 32, 1, 0, r=5.0 * s),
            K.knob('T', 'double', 32, 51, 0, 1, r=5.0 * s), K.knob('T', 'double', 13, 32, -1, 0, r=5.0 * s)]
    body = c.m(core, *tabs)
    c.add(body, LIME)
    # the coil: the groove between turns is a mid-green spiral line, so the lime body reads as a coiled snake
    pts = []
    for i in range(0, 240):
        t = i / 240 * 1.75 * 2 * math.pi + 0.8
        rr = 17.5 - (t - 0.8) * 1.15
        cx, cy = math.cos(t), math.sin(t)
        d = (abs(cx) ** 4 + abs(cy) ** 4) ** 0.25
        pts.append((32 + rr * cx / d, 32 + rr * cy / d))
    groove = c.m(K.thick_path(pts, 3.0 if not c.small else 3.4)) & body
    c.add(groove, MID)
    band = body - groove
    # head in the coil centre
    head = c.m(K.ell(32, 31, 8.5, 7.0))
    c.add(head, K.ramp('#a6d86a'))
    c.edge(head, K.ramp('#5aa044')[1])
    # yellow eyes (the picture's snake eye)
    for ex in (27.5, 36.5):
        cx, cy = c.P(ex, 29)
        if not c.small:
            for dx in range(-1, 2):
                for dy in range(-1, 2):
                    c.px(cx + dx, cy + dy, EYE)
            c.px(cx, cy - 1, K.UMBER); c.px(cx, cy, K.UMBER); c.px(cx, cy + 1, K.UMBER)
            c.px(cx - 1, cy - 1, '#fff2b0')
        else:
            c.px(cx, cy, EYE); c.px(cx + 1, cy, K.UMBER); c.px(cx, cy - 1, EYE); c.px(cx + 1, cy - 1, K.UMBER)
    # nostrils + forked tongue
    nx, ny = c.P(32, 35)
    if not c.small:
        c.px(nx - 2, ny - 1, DARK); c.px(nx + 1, ny - 1, DARK)
        for y in range(ny + 1, ny + 5):
            c.px(nx, y, TONGUE)
        c.px(nx - 1, ny + 5, TONGUE); c.px(nx + 1, ny + 5, TONGUE)
    else:
        c.px(nx, ny + 1, TONGUE); c.px(nx, ny + 2, TONGUE); c.px(nx - 1, ny + 3, TONGUE); c.px(nx + 1, ny + 3, TONGUE)
    # four diamond markings on the outer coil (the blurb's 'scale diamonds')
    for (dx, dy) in ((19, 19), (45, 19), (45, 45), (19, 45)):
        r = 3.2 if not c.small else 3.6
        dm = c.m(K.poly([(dx, dy - r), (dx + r, dy), (dx, dy + r), (dx - r, dy)]))
        c.add(dm & body, (DARK, DARK, '#2e6a4a'))
        hx, hy = c.P(dx - 0.8, dy - 0.8)
        c.px(hx, hy, '#6ab08a')
    # small dark scale flecks along the band (64 px only)
    if not c.small:
        for (x, y) in band:
            if (x * 7 + y * 3) % 23 == 0 and (x, y) not in head:
                c.px(x, y, '#3a7a40')


K.render_pal(fn, 'pl-ana-4', 'Scale Diamonds', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ana-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ana-4.png')
