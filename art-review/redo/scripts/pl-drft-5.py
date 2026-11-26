"""pl-drft-5 Pink Porthole. Inner-BBBB, round: a pink porthole window. The four round blanks bite the middle of each side of a
rounded-square frame, leaving four bolted lugs in the corners. The round glass shows the tavern's sunset over the sea. The frame is
awning pink with a cream ring, and the bolts are thatch gold (cell 9-3: thatch and the pink/cream awning)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

PINK = K.ramp('#e8485c')
PINKL = K.ramp('#f47172')
CREAMR = ('#fff1d4', '#e0b0a0', '#fffae8')
GOLD = ('#e0a050', '#a8684a', '#f0bc64')
SKY = K.ramp('#7a4a9c')
SUN = ('#f89a88', '#d8707c', '#ffd898')
SEA = K.ramp('#37437f')


def fn(c):
    k = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 9, 9, 55, 55
    def rsq(x, y, r=7):
        cx = min(max(x, x0 + r), x1 - r)
        cy = min(max(y, y0 + r), y1 - r)
        return (x - cx) ** 2 + (y - cy) ** 2 < r * r and x0 <= x < x1 and y0 <= y < y1
    r = 4.0 * k
    blanks = (K.knob('B', 'round', 32, y0, 0, -1, r=r), K.knob('B', 'round', 32, y1, 0, 1, r=r),
              K.knob('B', 'round', x0, 32, -1, 0, r=r), K.knob('B', 'round', x1, 32, 1, 0, r=r))
    body = c.m(rsq, minus=blanks)
    c.add(body, PINK, stitch=None if c.small else '#f6b8cf')
    # cream ring + glass
    ring = c.m(K.ell(32, 32, 14, 14), minus=blanks)
    c.add(ring, GOLD)                                          # brass rim (thatch gold)
    c.add(c.m(K.ell(32, 32, 12.2, 12.2)), CREAMR)
    glass = c.m(K.ell(32, 32, 10.6, 10.6))
    c.add(glass, SKY)
    c.add(glass & c.m(K.rect(0, 28.5, 64, 64)), ('#f89a88', '#d8707c', '#f8b0a0'))   # sunset band
    c.add(glass & c.m(K.ell(32, 35, 3.6, 3.6)), ('#ffd898', '#f0bc64', '#fffae8'))  # sun on the horizon
    c.add(glass & c.m(K.rect(0, 34.5, 64, 64)), SEA)            # sea
    c.edge(glass, '#5a3a7a')
    # a pink cloud streak in the sky
    c.add(glass & c.m(K.ell(29, 25, 5, 1.4)), ('#f89fbc', '#d8707c', '#ffd0e0'))
    # sun glitter on the sea, sky streak
    for (gx, gy) in ((31, 37.5), (33.5, 39.5), (30, 41.5), (34, 43.5)):
        x, y = c.P(gx, gy)
        c.px(x, y, '#ffd898')
        if not c.small:
            c.px(x + 1, y, '#ffd898')
    # glass glint (upper left)
    gx, gy = c.P(25, 26.5)
    for d in range(3 if not c.small else 2):
        c.px(gx + d, gy - d + 1, '#fffae8')
    # thatch fringe brow along the top of the frame
    # four bolts on the corner lugs
    for (bx, by) in ((15.5, 48.5), (48.5, 48.5)):
        x, y = c.P(bx, by)
        if c.small:
            c.px(x, y, GOLD[2]); c.px(x + 1, y, GOLD[0]); c.px(x, y + 1, GOLD[0]); c.px(x + 1, y + 1, GOLD[1])
        else:
            for dx in range(-1, 2):
                for dy in range(-1, 2):
                    c.px(x + dx, y + dy, GOLD[0])
            c.px(x - 1, y - 1, GOLD[2]); c.px(x + 1, y + 1, GOLD[1]); c.px(x + 1, y, GOLD[1]); c.px(x, y + 1, GOLD[1])
    # face in the glass sky
    c.eye(16, 17.5, disc=True, look=(1, 1))
    c.eye(48, 17.5, disc=True, look=(-1, 1))
    c.blush(13.5, 22.5)
    c.blush(49, 22.5)


K.render_pal(fn, 'pl-drft-5', 'Pink Porthole', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-drft-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-drft-5.png')
