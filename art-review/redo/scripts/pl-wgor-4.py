"""pl-wgor-4 Sunbeam Staircase: inner-TTTT, double knobs. A staircase of slanting glade sunbeams: the piece's upper-right corner
is cut into four stair steps (sunlit cream treads, green risers), the body is striped with the cell's diagonal pale-green light shafts
over the dark trunk green, double tabs on all four sides, felt face on the lowest, calmest flight (cell 2-2 of Wonder Gorilla Glade)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

DARK = K.ramp('#3c7a5c')     # trunk / shade green
MID = K.ramp('#70b888')      # glade green
BEAM = K.ramp('#b0d49e')     # pale light shaft
TREAD = K.ramp('#f0e4a0')    # sunlit step top
SUN = '#fff4c8'

STEPS = [(12, 25, 12), (25, 34, 19), (34, 43, 26), (43, 52, 33)]   # (x0, x1, top y)


def fn(c):
    k = 1.15 if c.small else 1.0
    core = [K.rect(x0, y0, x1, 52) for x0, x1, y0 in STEPS]
    tabN = K.knob('T', 'double', 20, 12, 0, -1, r=4.8 * k)
    tabE = K.knob('T', 'double', 52, 43, 1, 0, r=4.8 * k)
    tabW = K.knob('T', 'double', 12, 32, -1, 0, r=4.8 * k)
    tabS = K.knob('T', 'double', 32, 52, 0, 1, r=4.8 * k)
    body = c.m(*core, tabN, tabE, tabW, tabS)
    c.add(body, MID)
    # diagonal light shafts slanting down-right (parallel to the stair flight), as in the cell
    shafts = [lambda x, y, o=o: 0 <= (x - 0.75 * y) - o < 5 for o in (-22, -6)]
    c.add(body & c.m(*shafts), BEAM)
    # dark trunk band down the left edge (the cell's dark stripe)
    c.add(body & c.m(K.rect(0, 0, 16, 64), tabW), DARK)
    # stair treads (sun on top) and risers
    for x0, x1, y0 in STEPS:
        c.add(body & c.m(K.rect(x0, y0, x1, y0 + 3.2)), TREAD)
    for (x0, x1, y0), (_, _, ny) in zip(STEPS, STEPS[1:]):
        c.add(body & c.m(K.rect(x1, y0 + 3.2, x1 + 2.6, ny)), DARK)       # riser shadow under each step lip
    c.add(body & c.m(tabN, minus=(K.rect(0, 12, 64, 64),)), BEAM)
    # dust motes in the beams
    for mx, my in ((40, 34), (46, 44), (27, 30)):
        x, y = c.P(mx, my)
        c.px(x, y, SUN)
        if not c.small:
            c.px(x + 1, y, SUN); c.px(x, y - 1, SUN); c.px(x - 1, y, SUN); c.px(x, y + 1, SUN)
    # face on the lower flight
    c.eye(24, 39, disc=False)
    c.eye(33, 39, disc=False)
    c.smile(28.5, 44)
    c.blush(20.5, 43)
    c.blush(36.5, 43)


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-wgor-4', 'Sunbeam Staircase', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wgor-4-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wgor-4.png'))
