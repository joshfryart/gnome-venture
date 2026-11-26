"""pl-ffy-2 Canoe Glimmer: edge-BTB, tri. A glowing canoe lamp sitting in its outrigger canoe. Flat S = canoe keel,
tri tab N = the lamp's flame, tri blanks W + E bite into the lamp glass. Lamp yellow + canoe wood + cave water blue (cell 2-6)."""
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

GLOW = K.ramp('#f4d860')
FLAME = ('#fff2b0', '#f0b830', '#ffffff')
WOODR = K.ramp('#9a6232')
HULL = K.ramp('#b67a3c')
WATER = K.ramp('#2e5a86')
FFLY = '#c8f060'


def fn(c):
    k = 1.15 if c.small else 1.0
    glass = K.rect(13, 20, 51, 46)
    hull = K.poly([(2, 38), (8, 43), (56, 43), (62, 38), (60, 48), (52, 56), (12, 56), (4, 48)])
    tabN = K.knob('T', 'tri', 32, 20, 0, -1, r=5.2 * k)
    blankW = K.knob('B', 'tri', 13, 32, -1, 0, r=4.0 * k)
    blankE = K.knob('B', 'tri', 51, 32, 1, 0, r=4.0 * k)
    cut = (blankW, blankE)
    body = c.m(glass, minus=cut)
    c.add(body, GLOW)
    # flame tab
    c.add(c.m(tabN, minus=(glass,)), FLAME)
    # wooden lamp frame: top cap + corner posts
    cap = c.m(K.rect(13, 20, 51, 24.5))
    c.add(cap, WOODR)
    c.add(c.m(K.rect(13, 24, 17, 46), K.rect(47, 24, 51, 46), minus=cut), WOODR)
    c.add(c.m(K.rect(13, 41, 51, 44.5)), WOODR)
    # canoe hull with upturned prow ends
    c.add(c.m(hull), HULL, stitch=None if c.small else HULL[2])
    c.add(c.m(K.rect(0, 52, 64, 57)) & c.m(hull), WATER)
    c.edge(c.m(hull), HULL[1])
    # inner warm core of the glass
    if not c.small:
        for (x, y) in c.m(K.ell(32, 33, 9, 7)):
            if (x, y) in body:
                c.px(x, y, GLOW[2])
    else:
        for (x, y) in c.m(K.ell(32, 33, 7, 5)):
            c.px(x, y, GLOW[2])
    # lantern pane bars (thin wood mullions) beside the face
    for gx in (20.5, 43.5):
        c.line([(gx, 25), (gx, 40.5)], WOODR[0])
    # hull plank line
    c.line([(8, 47.5), (56, 47.5)], HULL[1])
    # tiny fireflies resting on the prows
    c.px(*c.P(4, 41), FFLY)
    c.px(*c.P(59.5, 41), FFLY)
    # face
    c.eye(26, 33)
    c.eye(38, 33)
    c.smile(32, 38.5)
    c.blush(22, 37.5)
    c.blush(41, 37.5)


K.render_pal(fn, 'pl-ffy-2', 'Canoe Glimmer', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ffy-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ffy-2.png')
