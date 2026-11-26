"""pl-chil-6 Pepper Prince (rare, whimsy-chili, peg).
Concept: a plump red chili pod that is the piece. Square-ish shoulders with straight sides, peg tab E (pod bulge), peg blank W biting
into the pod, N peg tab = a little gold crown sitting on the green calyx; the pod tapers to a curled tip at the bottom.
Red / coral / green / pale yellow from the hanging chili strings in cell 2-4, wood-tan twine from the ristra post."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

RED = K.ramp('#e83828')
CORAL = K.ramp('#ff9068')
GREEN = ('#4a9a48', '#2e7048', '#8cc870')
CROWN = ('#f0c030', '#b07a10', '#fff088')
TWINE = K.ramp('#c08850')


def fn(c):
    k = 1.15 if c.small else 1.0
    pod = poly([(12, 25), (16, 21), (48, 21), (52, 25), (52, 40), (50, 46), (45, 51), (38, 55), (31, 58), (25, 60.5), (21, 61), (21, 56),
                (16, 52), (12, 45)])
    tip = thick_path([(26, 58.5), (18, 60.5), (12.5, 58.5), (11, 54.5)], 3.8 if not c.small else 4.6)
    tabE = knob('T', 'peg', 52, 35, 1, 0, r=5.4 * k, nw=3.2)
    blankW = knob('B', 'peg', 12, 36, -1, 0, r=4.3 * k, nw=2.8)
    tabN = knob('T', 'peg', 32, 21, 0, -1, r=5.2 * k)
    body = c.m(pod, tip, tabE, minus=(blankW,))
    c.add(body, RED, stitch=None)
    # tip turns coral like the riper pods in the string
    c.add(c.m(tip) | (body & c.m(lambda x, y: y > 54 and x < 30)), CORAL)
    # green calyx with scalloped edge spilling over the shoulders
    cal = body & c.m(lambda x, y: 19 <= y < 24.5 + (2.4 if ((x - 13) // 6) % 2 == 0 else 0) and ell(32, 23, 18, 6.5)(x, y))
    c.add(cal, GREEN)
    # crown = N peg tab, three points
    crown = c.m(tabN, minus=(lambda x, y: y >= 20,
                             lambda x, y: y < 13.5 and (abs(x - 29.0) < 1.3 or abs(x - 35.0) < 1.3)))
    c.add(crown, CROWN)
    gx, gy = c.P(32, 16.5)
    c.px(gx, gy, RED[0])
    if not c.small:
        c.px(gx - 1, gy, RED[0])
        c.px(gx, gy + 1, RED[1])
        c.px(gx - 1, gy + 1, RED[1])
    # twine wrap from the ristra (two bands round the pod waist on the E tab side)
    c.add(body & c.m(rect(52, 0, 64, 64)), RED)
    c.add(body & c.m(rect(52, 34, 64, 36.4 if not c.small else 37.2)), TWINE)
    # gloss streak upper left
    c.add(c.m(thick_path([(16, 29), (16, 31)], 2.6)) & body, ('#ffc8b8', '#ffc8b8', '#ffc8b8'))
    # green stem curling out from under the crown
    c.add(c.m(thick_path([(38, 21), (41, 16), (44.5, 14.5), (46.5, 16.5)], 2.6 if not c.small else 3.2)), GREEN)
    c.eye(26, 34)
    c.eye(38, 34)
    c.smile(32, 39.5, wide=True)
    c.blush(22, 39)
    c.blush(42, 39)


K.render_pal(fn, 'pl-chil-6', 'Pepper Prince', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-chil-6-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-chil-6.png')
