"""pl-scr-3 Dune Ticktock: an hourglass that is an inner-TBTB double-knob piece.
Tabs N and S are the cap finials (twin knobs), double blanks W and E pinch the glass into the hourglass waist.
Caps in the mauve dusk sky of cell 0-5 (#a8587a), sand in the picture's dune gold, face on the top sand."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

R = '/home/user/gnome-venture/'
MAUVE = K.ramp('#a8587a')
GLASS = ('#ead6e4', '#c4a6c0', '#fbf2f6')
SAND = K.ramp('#f2b84a')
DUNE = K.ramp('#e1a66a')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(13, 13, 51, 51)
    tabN = K.knob('T', 'double', 32, 13, 0, -1, r=4.4 * k)
    tabS = K.knob('T', 'double', 32, 51, 0, 1, r=4.4 * k)
    blW = K.knob('B', 'double', 13, 32, -1, 0, r=5.0 * k)
    blE = K.knob('B', 'double', 51, 32, 1, 0, r=5.0 * k)
    body = c.m(core, tabN, tabS, minus=(blW, blE))
    c.add(body, GLASS)
    # two glass bulbs (inner contour), pinched at the waist
    bulbN = c.m(K.ell(32, 19, 15.5, 13.5)) & body
    bulbS = c.m(K.ell(32, 45, 15.5, 13.5)) & body
    c.edge(bulbN | bulbS, '#b892b4')
    # sand: top funnel draining, stream, bottom dune pile
    c.add(c.m(K.poly([(15, 20), (49, 20), (35, 32), (29, 32)])) & bulbN, SAND)
    c.add(c.m(K.rect(30.6, 30, 33.4, 42)) & body, SAND)
    c.add(c.m(K.poly([(14, 46), (32, 37.5), (50, 46)])) & bulbS | (c.m(K.rect(13, 45, 51, 47)) & bulbS), DUNE)
    # caps (mauve wood) with the twin finials
    capN = c.m(K.rect(13, 13, 51, 18.5)) | c.m(tabN, minus=(core,))
    capS = c.m(K.rect(13, 45.5, 51, 51)) | c.m(tabS, minus=(core,))
    c.add(capN & body, MAUVE)
    c.add(capS & body, MAUVE)
    c.edge(capN & body, MAUVE[1])
    c.edge(capS & body, MAUVE[1])
    # glass glint
    if not c.small:
        c.line([(17, 37), (17, 42)], '#ffffff')
        c.line([(46, 21), (46, 26)], '#ffffff')
        # tick marks on the caps
        for x in (18, 24, 40, 46):
            c.px(*c.P(x, 15.5), '#ec9ac0')
    else:
        c.line([(17, 38), (17, 41)], '#ffffff')
    # face on the top sand
    c.eye(27, 23.5)
    c.eye(37, 23.5)
    c.smile(31.5, 26)
    c.blush(23, 25.5)
    c.blush(40, 25.5)


K.render_pal(fn, 'pl-scr-3', 'Dune Ticktock', R + 'art-review/redo/out',
             cellfile=R + 'art-review/redo/_src/pl-scr-3-cell.png',
             oldfile=R + 'game/assets/img/puzzles/pals/pl-scr-3.png')
