"""pl-rrs-4 Dotcircle Painting: inner-TTTT, double. A red-rock boulder pal; the square boulder body is the piece, four double tabs are
lumpy rock knobs. Its belly carries a dot painting: concentric rings of cream and teal dots (the songline dots of cell 10-7), on rust
#b05a50 rock with an ochre #e8905a sunlit cap."""
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ROCK = K.ramp('#b05a50')
OCHRE = K.ramp('#e8905a')
CREAMD = '#fff0c0'
TEALD = '#58c0b8'
PLUM = '#8f4750'


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
    core = rrect(12, 13, 52, 53, 6)
    tabs = [K.knob('T', 'double', 32, 13, 0, -1, r=5.4 * k),
            K.knob('T', 'double', 32, 53, 0, 1, r=5.4 * k),
            K.knob('T', 'double', 12, 33, -1, 0, r=5.4 * k),
            K.knob('T', 'double', 52, 33, 1, 0, r=5.4 * k)]
    body = c.m(core, *tabs)
    c.add(body, ROCK)
    # sunlit ochre cap on the upper left of the rock, wavy lower edge
    cap = c.m(lambda x, y: y < 25 - 0.25 * x + 1.8 * math.sin(x / 3.0)) & body
    c.add(cap, OCHRE)
    # rock cracks (plum) at the lower corners
    c.line([(15, 44), (18, 46), (18, 50)], PLUM)
    c.line([(49, 18), (46, 21), (47, 24)], PLUM)
    # the dot painting: a darker painted disc with rings of dots
    cx, cy = 32, 38.5
    disc = c.m(K.ell(cx, cy, 13.5, 13.5))
    c.add(disc & body, ('#8f4750', '#6e3440', '#a85a60'))
    small = c.small

    def dot(x, y, col):
        px, py = c.P(x, y)
        for dx in range(2):
            for dy in range(2):
                if small and (dx or dy):
                    continue
                c.px(px + dx, py + dy, col)

    if small:
        px, py = c.P(cx, cy)
        for dx in (-1, 0):
            for dy in (-1, 0):
                c.px(px + dx, py + dy, CREAMD)
        rings = [(4.6, TEALD, 8), (8.6, CREAMD, 12), (12.0, TEALD, 16)]
    else:
        dot(cx - 1, cy - 1, TEALD)
        rings = [(4.0, CREAMD, 8), (7.5, TEALD, 12), (11.0, CREAMD, 18)]
    off = 0 if small else 0.8
    for rad, col, nd in rings:
        for i in range(nd):
            a = 2 * math.pi * i / nd + 0.2
            dot(cx + rad * math.cos(a) - off, cy + rad * math.sin(a) - off, col)
    # the songline: a dotted trail out along the E tab
    for j, x in enumerate((48, 52, 56) if not small else (49, 54, 58)):
        dot(x - off, 33 - off, TEALD if j % 2 else CREAMD)
    # face high on the ochre cap
    c.eye(25, 19.5)
    c.eye(38, 19.5)
    c.smile(31.5, 22.5, PLUM)
    c.blush(20, 23)
    c.blush(43, 23)


K.render_pal(fn, 'pl-rrs-4', 'Dotcircle Painting', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrs-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrs-4.png')
