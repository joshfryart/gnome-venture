"""pl-mgr-3 Jarlight Twig. Inner-TBTB, tri: a glass jar lantern that IS the piece. N tri tab = the root-wood cork knob,
S tri tab = the twig it is held up on (with a sprout leaf), tri blanks bite into the glass E + W. Inside: concentric lime glow
rings round a firefly (the cell's halo), a teal puddle of mangrove water at the bottom, gold firefly light (cell 7-5)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob, ramp, UMBER2, CREAM

GLASS = ramp('#a8dc70')
GLOW = ramp('#d0ec7c')
CORE = ('#fffbc0', '#fcea88', '#ffffff')
TEAL = ramp('#3a9494')
ROOT = ramp('#a0583c')
TWIG = ramp('#86483c')
LEAF = ramp('#7cc464')
BUG = ramp('#58293d')
GOLD = ramp('#f8d850')


def fn(c):
    k = 1.15 if c.small else 1.0
    jar = poly([(13, 29), (18, 24), (46, 24), (51, 29), (51, 52), (47, 57), (17, 57), (13, 52)])
    neck = rect(19, 20, 45, 25)
    lid = rect(17, 13, 47, 20)
    tabN = knob('T', 'tri', 32, 13, 0, -1, r=4.0 * k)
    tabS = knob('T', 'tri', 32, 57, 0, 1, r=3.6 * k)
    blankE = knob('B', 'tri', 51, 40, 1, 0, r=3.4 * k)
    blankW = knob('B', 'tri', 13, 40, -1, 0, r=3.4 * k)
    cut = (blankE, blankW)
    glass = c.m(jar, neck, minus=cut)
    c.add(glass, GLASS)
    c.add(c.m(ell(32, 40, 14, 13), minus=cut) & glass, GLOW)
    c.add(c.m(ell(32, 41, 8.5, 9)) & glass, CORE)
    water = c.m(lambda x, y: y > 51.5 + (0.8 if (int(x) // 4) % 2 else 0)) & glass
    c.add(water, TEAL)
    # cork lid of root wood with its tri knob, the twig below
    c.add(c.m(lid, tabN, minus=(neck,)), ROOT)
    c.add(c.m(rect(17, 18, 47, 20.5)), ramp('#6e3a2c'))
    c.add(c.m(tabS, minus=(jar,)), TWIG)
    if not c.small:
        c.line([(21, 15.5), (27, 15.5)], ROOT[1])
        c.line([(36, 15.5), (43, 15.5)], ROOT[1])
        c.line([(19, 23), (45, 23)], GLASS[1])   # neck rim
    # glass highlight streaks (upper left) and right-side glint
    c.line([(16.5, 30), (16.5, 37)], '#f4fbe0')
    c.line([(17.5, 27), (19, 25.5)], '#f4fbe0')
    c.line([(47.5, 45), (47.5, 49)], '#f4fbe0')
    # the firefly (the creature): wings, gold glowing tail, dark head with felt eyes, antennae
    wing = '#f4fbe0'
    wl = c.m(ell(23.5, 37, 6, 3.6)) & glass
    wr = c.m(ell(40.5, 37, 6, 3.6)) & glass
    c.add(wl | wr, (wing, '#c8e0b0', '#ffffff'))
    c.edge(wl, '#9cc88c'); c.edge(wr, '#9cc88c')
    tail = c.m(ell(32, 45, 5, 5.5)) & glass
    c.add(tail, GOLD)
    c.edge(tail, '#e0a830')
    if not c.small:
        c.line([(28, 44), (36, 44)], '#e0a830')
    head = c.m(ell(32, 34, 7.2, 5.6)) & glass
    c.add(head, BUG)
    c.edge(head, UMBER2)
    if not c.small:
        c.line([(29, 28.5), (26.5, 25.5), (25, 25.5)], UMBER2)
        c.line([(35, 28.5), (37.5, 25.5), (39, 25.5)], UMBER2)
    else:
        c.line([(28.5, 28.5), (26.5, 26)], UMBER2)
        c.line([(35.5, 28.5), (37.5, 26)], UMBER2)
    c.eye(29, 34, disc=True)
    c.eye(35.5 if not c.small else 34.5, 34, disc=True)
    if not c.small:
        c.blush(25.5, 37.5)
        c.blush(37.5, 37.5)


K.render_pal(fn, 'pl-mgr-3', 'Jarlight Twig', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-mgr-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-mgr-3.png')
