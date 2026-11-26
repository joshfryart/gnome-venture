"""pl-jdf-1 "Wing Jot": a jade dragonfly wing flake that is a corner-TT piece (tri knobs).
Flat top (the dark-teal leading edge, the costa) and flat left (the wing root), tri tabs on the right (wing tip) and bottom,
bottom-right corner rounded like a wing tip. Pale mint membrane with dashed teal veins from cell 2-2, red pterostigma from the picture."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, knob, thick_path

MEM = K.ramp('#9edcc8')
COSTA = K.ramp('#1f8a78')
VEIN = '#2a8a7a'
STIG = K.ramp('#c8402e')
ROOT = K.ramp('#3fae6a')


def fn(c):
    k = 1.15 if c.small else 1.0
    top, bot = 14, 44
    core_r = rect(4, top, 24, bot)
    tip = ell(24, 29, 33, 15.2)
    flat = lambda x, y: y >= top
    tabE = knob('T', 'tri', 56.5, 29, 1, 0, r=4.6 * k, nw=3.0)
    tabS = knob('T', 'tri', 19, bot, 0, 1, r=5.0 * k, nw=3.0)
    body = c.m(core_r, lambda x, y: tip(x, y) and flat(x, y), tabE, tabS)
    c.add(body, MEM)
    # faint membrane mesh: small cells of lighter vein (the wing's lacework)
    mesh = '#7cc8b4'
    if not c.small:
        for (x, y) in body:
            if (y % 5 == 0 and x > 8) or ((x + (y // 5) * 2) % 6 == 0 and y % 5 != 0):
                c.px(x, y, mesh)
    # leading edge (costa): dark-teal band along the flat top
    c.add(body & c.m(rect(0, 0, 46, top + 3.2)), COSTA)
    # wing root: small jade knuckle at the top-left
    c.add(body & c.m(ell(4, top + 4, 6, 8)), ROOT)
    # pterostigma near the tip on the leading edge
    c.add(body & c.m(lambda x, y: 42 <= x < 50 and tip(x, y) and y < top + 6 and y >= top), STIG)
    # longitudinal veins fanning from the root toward the tip
    c.line([(8, 22), (20, 22.5)], VEIN)
    c.line([(38, 23), (54, 26)], VEIN)
    c.line([(8, 39), (46, 38), (54, 32)], VEIN)
    # dashed cross veins (cell motif), kept off the face
    for vx, y1 in ((12, 43), (44, 41), (19, 54)):
        for y in range(c.P(0, top + 3)[1] if vx != 19 else c.P(0, 39)[1], c.P(0, y1)[1]):
            if (y // 2) % 2 == 0:
                c.px(c.P(vx, 0)[0], y, VEIN)
    # face on the calm membrane
    face = c.m(ell(29, 30.5, 10, 6))
    for p in face:
        c.over.pop(p, None)
    c.eye(24, 29, disc=True)
    c.eye(34, 29, disc=True)
    c.smile(29, 34.5)


K.render_pal(fn, 'pl-jdf-1', 'Wing Jot', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jdf-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jdf-1.png')
