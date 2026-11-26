import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
"""Edge-TTB, keyhole: a grey goose marching left. Flat S = grass strip with orange feet; N keyhole tab = the neck and round head
(orange beak); E keyhole tab = the tail tuft; W keyhole blank bites into the breast. Slate goose, orange bill/feet, grass green (cell 1-7)."""
GOOSE = K.ramp('#8c8f9a')
WING = K.ramp('#6c707c')
BELLY = K.ramp('#c4c6cc')
ORANGE = K.ramp('#e8741c')
GRASS = K.ramp('#4aa83a')
ROOT = '/home/user/gnome-venture/'


def fn(c):
    S = 1.15 if c.small else 1.0
    core = K.rect(9, 27, 55, 58)
    # N keyhole tab stretched into a goose neck: keyhole flare at the base, long stem, round head on top
    flare = K.knob('T', 'keyhole', 21, 27, 0, -1, r=5.0 * S, nw=3.4)
    neck = K.thick_path([(21, 28), (21, 13)], 7.4 if not c.small else 8.4)
    head = K.ell(21.5, 10.5, 6.2, 5.6)
    tabN = lambda x, y: flare(x, y) or neck(x, y) or head(x, y)
    tabE = K.knob('T', 'keyhole', 55, 36, 1, 0, r=4.8 * S)
    blankW = K.knob('B', 'keyhole', 9, 42, -1, 0, r=5.0 * S)
    beak = K.poly([(17, 7.5), (7.5, 10.5), (17, 13.5)])
    body = c.m(core, tabE, tabN, minus=(blankW,))
    c.add(body, GOOSE)
    # beak (breaks out of the head: goose cue on the outline)
    c.add(c.m(beak), ORANGE)
    # pale breast / belly
    c.add(body & c.m(K.ell(25, 47, 13, 8)), BELLY)
    # wing: darker folded wing with feather bars
    wing = body & c.m(K.poly([(26, 31), (50, 30), (60, 37), (52, 46), (30, 46)]))
    c.add(wing, WING)
    c.edge(wing, WING[1])
    for i, x in enumerate((34, 41, 48)):
        c.line([(x, 34), (x + 3, 43)], WING[2] if not c.small else WING[1])
    # grass strip at the bottom (the flat side)
    grass = body & c.m(lambda x, y: y >= 51.5 + (1.5 if int(x // 3) % 2 else 0))
    c.add(grass, GRASS)
    # orange feet planted in the grass, mid-stride
    c.add(c.m(K.rect(20, 46, 23.5, 53), K.rect(16, 52, 25, 55.5)), ORANGE)
    c.add(c.m(K.rect(36, 46, 39.5, 52), K.rect(34, 51, 42, 54.5)), ORANGE)
    # head: dark cap line on the neck back
    c.eye(21.5, 9.5)
    if not c.small:
        c.blush(23.5, 13)


r = K.render_pal(fn, 'bb-gander-gait', 'Gander Gait', '/home/user/gnome-venture/art-review/redo/out',
                 cellfile=ROOT + 'art-review/redo/_src/bb-gander-gait-cell.png',
                 oldfile=ROOT + 'game/assets/img/puzzles/pals/bb-gander-gait.png')
print(r)
