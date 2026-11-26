import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Inner-BBBB, peg: a little box jelly. Its frosty ice-blue square bell IS the piece, square peg blanks bite into all four sides,
pink tentacles hang in two bunches either side of the S blank. Ice blue + pink tentacles + frown face from the queen's bell (cell 4-2)."""

ICE = ('#cfeaf6', '#8fbcd8', '#f4fcff')
FROST = K.ramp('#a8d4ec')
PINK = ('#e886b4', '#b8507e', '#f6b8d6')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 8, 55, 46)
    bN = K.knob('B', 'peg', 32, 8, 0, -1, r=3.6 * k)
    bS = K.knob('B', 'peg', 32, 46, 0, 1, r=3.6 * k)
    bE = K.knob('B', 'peg', 55, 26, 1, 0, r=3.6 * k)
    bW = K.knob('B', 'peg', 9, 26, -1, 0, r=3.6 * k)
    cut = (bN, bS, bE, bW)
    w = 2.8 if not c.small else 3.4
    tents = []
    for x in (12.5, 18, 23.5, 40.5, 46, 51.5):
        tents.append(K.thick_path([(x, 44), (x + 1.4, 50), (x - 0.6, 55), (x + 1.0, 60)], w))
    c.add(c.m(*tents, minus=(K.rect(0, 0, 64, 45),)), PINK)
    bell = c.add(c.m(core, minus=cut), ICE, stitch='#a8d4ec')
    # frosty skirt: darker band at the bell's rim, scalloped
    skirt = c.m(lambda x, y: 39 + (1.5 if (x // 3) % 2 else 0) <= y < 46, minus=cut) & bell
    c.add(skirt, FROST)
    # frost patches like the queen's bell
    if not c.small:
        for (x, y) in bell:
            if y < 36 and (x * 7 + y * 3) % 23 == 0:
                c.px(x, y, '#e6f6fc')
    # the porthole: brass-rimmed see-through window in the bell, deep reef blue inside with a glint
    c.add(c.m(K.ell(42, 34, 6.2, 6.2)), K.ramp('#d8a640'))
    win = c.m(K.ell(42, 34, 4.2, 4.2))
    c.add(win, ('#2e7fae', '#1f5a86', '#5aa8d0'))
    gx, gy = c.P(40, 32)
    c.px(gx, gy, '#f4fcff'); c.px(gx + 1, gy, '#f4fcff')
    if not c.small:
        c.px(gx, gy + 1, '#f4fcff')
    c.eye(19, 22, disc=True)
    c.eye(33, 22, disc=True)
    c.blush(15.5, 28)
    c.blush(35, 28)
    # small wobbly frown like the queen
    cx, cy = c.P(26, 30)
    if not c.small:
        for dx in range(-1, 2):
            c.px(cx + dx, cy, K.UMBER2)
        c.px(cx - 2, cy + 1, K.UMBER2); c.px(cx + 2, cy + 1, K.UMBER2)
    else:
        c.px(cx - 1, cy + 1, K.UMBER2); c.px(cx, cy, K.UMBER2); c.px(cx + 1, cy, K.UMBER2); c.px(cx + 2, cy + 1, K.UMBER2)


if __name__ == '__main__':
    R = '/home/user/gnome-venture/'
    print(K.render_pal(fn, 'pl-bjq-5', 'Jellybell Porthole', R + 'art-review/redo/out',
                       cellfile=R + 'art-review/redo/_src/pl-bjq-5-cell.png',
                       oldfile=R + 'game/assets/img/puzzles/pals/pl-bjq-5.png'))
