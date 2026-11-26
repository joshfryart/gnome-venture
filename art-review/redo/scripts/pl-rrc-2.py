# pl-rrc-2 "Window Peek": an edge piece that is a chunk of rose canyon wall with a lamp-lit arched window carved in it,
# a little face peeking out of the glow. Flat side = bottom (ground), peg tabs W + E (wall stones), peg blank N.
# Colours from cell 1-3: rose/mauve sandstone, umber window frame, amber-to-cream lamp glow with a centre mullion.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob

ROCK = ('#d07a78', '#9a4a66', '#f4b8a0')
MAUVE = ('#9a4a66', '#7c3b59', '#b06078')
PALE = ('#e2998c', '#d07a78', '#f4b8a0')
FRAME = ('#2b1c26', '#2b1c26', '#2b1c26')
G1 = ('#c8784c', '#c8784c', '#c8784c')
G2 = ('#f0b858', '#f0b858', '#f0b858')
G3 = ('#f8dc88', '#f8dc88', '#f8dc88')
SILL = ('#f4b8a0', '#e2998c', '#f6c8a0')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(10, 11, 54, 57)
    tabW = knob('T', 'peg', 10, 36, -1, 0, r=5.2 * k, nw=3.0)
    tabE = knob('T', 'peg', 54, 30, 1, 0, r=5.2 * k, nw=3.0)
    blankN = knob('B', 'peg', 32, 11, 0, -1, r=4.6 * k, nw=2.8)
    nicks = (ell(10, 11, 2.4, 2.4), ell(54, 11, 2.0, 2.0), ell(54, 57, 1.6, 1.6), ell(10, 57, 1.6, 1.6), ell(54.5, 46, 1.2, 2.0),
             ell(20, 10.6, 3, 1.1))                             # weathered sandstone corners
    body = c.m(core, tabW, tabE, minus=(blankN,) + nicks)
    c.add(body, ROCK, stitch=None if c.small else '#b8646c')
    # sandstone mottling (big blocks so they survive at 36)
    for (cx, cy, rx, ry, rp) in ((17, 18, 4.5, 3.0, PALE), (47, 46, 4.5, 4, MAUVE), (15, 50, 3.5, 3, MAUVE),
                                 (48, 17, 3.5, 2.6, MAUVE), (6, 36, 2.2, 2.5, PALE), (58, 30, 2.2, 2.5, MAUVE)):
        c.add(body & c.m(ell(cx, cy, rx, ry)), rp)
    # carved arched window
    fr_out = (ell(32, 33, 12.5, 10.5), rect(19.5, 33, 44.5, 52))
    c.add(body & c.m(*fr_out), FRAME)
    inner = (ell(32, 33.5, 9.5, 8), rect(22.5, 33.5, 41.5, 49.5))
    c.add(c.m(*inner), G1)
    c.add(c.m(*inner) & c.m(rect(0, 37, 64, 64)), G2)
    c.add(c.m(*inner) & c.m(rect(0, 44, 64, 64)), G3)
    # mullion + sill
    c.add(c.m(rect(31, 26, 33.2 if not c.small else 33.8, 50)), FRAME)
    c.add(body & c.m(rect(17.5, 52, 46.5, 55.5)), SILL)
    # peeking face in the glow
    c.eye(27, 36)
    c.eye(37.5, 36)
    c.blush(25, 41)
    c.blush(39.5, 41)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-rrc-2', 'Window Peek', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-rrc-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-rrc-2.png'))
