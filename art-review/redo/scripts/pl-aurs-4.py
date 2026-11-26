# Green Ripple (pl-aurs-4): an aurora curtain spirit that IS an inner-TTTT round-knob piece.
# Wavy crest along the top with a violet fringe, vertical green light-streaks down the body, a ragged ray fringe
# along the bottom edge, a diagonal ripple band (the cell's stepped green bands); round tabs on all four sides.
import math
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

MINT = K.ramp('#6af8bc')
SEA = K.ramp('#3cc8a0')
DEEP = ('#2aa888', '#238070', '#4aeaa8')
VIO = ('#9a68d0', '#6a58c8', '#d890e8')
SKY = ('#4a98d8', '#3a70a8', '#8ac0ec')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, x1, y0, y1 = 13, 51, 15, 49

    def crest(x):   # wavy top of the curtain
        return y0 + 3.6 * math.sin((x - x0) / (x1 - x0) * 2 * math.pi * 1.0 + 0.4)

    def body_p(x, y):
        if not (x0 <= x < x1):
            return False
        if y < crest(x) or y >= y1:
            return False
        return True

    # ray fringe along the bottom: alternating streaks hang below the core
    rays = []
    xs = [15, 20.5, 25.5, 38.5, 43.5, 49]
    for i, rx in enumerate(xs):
        ln = 6 if i % 2 == 0 else 3.5
        rays.append(K.rect(rx - 1.8, y1 - 1, rx + 1.8, y1 + ln))
    tabs = [
        K.knob('T', 'round', 32, crest(32) + 0.3, 0, -1, r=4.6 * k),
        K.knob('T', 'round', 32, y1, 0, 1, r=4.6 * k),
        K.knob('T', 'round', x0, 33, -1, 0, r=4.6 * k),
        K.knob('T', 'round', x1, 27, 1, 0, r=4.6 * k),
    ]
    sil = c.m(body_p, *rays, *tabs)
    # base: deep green everything
    c.add(sil, DEEP)
    # vertical light streaks (curtain) across the upper/middle body
    streak_cols = [MINT, SEA, MINT, K.ramp('#38d898'), MINT, SEA, MINT, SEA]
    w = (x1 - x0) / len(streak_cols)
    for i, rmp in enumerate(streak_cols):
        sx = x0 + i * w
        # diagonal ripple: lower boundary steps down to the left, like the cell's bands
        def low(x, y, sx=sx):
            return sx <= x < sx + w and y < 44 - (x - x0) * 0.32
        c.add(c.m(low) & sil, rmp)
    # violet fringe along the crest + top tab cap
    def fdep(x):   # ragged violet drips, like the picture's purple curtain top
        return (4.5 if c.small else 4) + (2.0 if int((x - x0) / 3.2) % 3 == 1 else 0)
    def fringe(x, y):
        return y < crest(x) + fdep(x) and x0 - 1 <= x < x1 + 1
    top_tab = c.m(tabs[0])
    c.add((c.m(fringe) | top_tab) & sil, VIO)
    # sky-blue line between the violet and green (cell top-left)
    def band(x, y):
        return crest(x) + fdep(x) <= y < crest(x) + fdep(x) + 1.6 and x0 <= x < x1
    c.add(c.m(band) & sil, SKY)
    # bright highlight streaks (1-2 px vertical light rays) at 64 px
    if not c.small:
        for sx in (17, 27, 41):
            c.line([(sx, crest(sx) + 8), (sx, 40 - (sx - x0) * 0.32)], '#c8ffe4')
    # face on the calm middle
    c.eye(25, 30, disc=True)
    c.eye(38, 29, disc=True)
    c.smile(31.5, 36, wide=True)
    c.blush(21.5, 34)
    c.blush(42, 33)


K.render_pal(fn, 'pl-aurs-4', 'Green Ripple', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurs-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurs-4.png')
