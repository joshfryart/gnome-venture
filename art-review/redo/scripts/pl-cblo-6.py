# Concept: a little teahouse that IS a whimsy piece: navy curly-eaved roof with a gold ridge whose peg tab is the finial (N),
# a hanging gold lantern as the E peg tab, a deep peg blank cut into the W wall, a flat lavender stone plinth (S) with a step;
# warm gold shoji window with wood mullions on a rose wall between maroon pillars (cell 8-5), window = face.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

ROOF = ramp('#5a68aa'); EAVE = ramp('#424e8e'); RIDGE = ramp('#e8b040')
WALLR = ramp('#c09094'); PILLAR = ramp('#8a4a4a'); WIN = ramp('#f0a040')
STONE = ramp('#c0bcd6'); LANT = ramp('#f8c048'); PINK = '#ffc8d8'
MULL, WINHI = '#b86e44', '#ffe090'


def fn(c):
    k = 1.15 if c.small else 1.0
    tabN = knob('T', 'peg', 32, 12, 0, -1, r=3.6 * k, nw=2.0)
    tabE = knob('T', 'peg', 52, 40, 1, 0, r=4.2 * k)
    blankW = knob('B', 'peg', 12, 40, -1, 0, r=3.8 * k)
    roof = poly([(17, 12), (47, 12), (56, 21), (60, 19), (63, 16), (62.5, 22), (58, 27), (6, 27), (1.5, 22), (1, 16), (4, 19), (8, 21)])
    wall = rect(12, 26, 52, 52)
    plinth = rect(9, 51, 55, 59)
    body = c.m(roof, wall, plinth, tabN, tabE, minus=(blankW,))
    # wall + pillars
    c.add(c.m(wall, minus=(blankW,)), WALLR)
    c.add(c.m(rect(12, 26, 16, 52), minus=(blankW,)), PILLAR)
    c.add(c.m(rect(48, 26, 52, 52)), PILLAR)
    # shoji window (the face)
    win = c.m(rect(23, 30, 47, 46), minus=())
    c.add(win, WIN)
    c.add(c.m(rect(23, 30, 47, 35)), (WINHI, WINHI, '#fff4c8'))
    c.edge(win, K.UMBER2)
    for xu in (29, 35, 41):
        if not c.small:
            c.line([(xu, 31), (xu, 45)], MULL)
    if c.small:
        c.line([(35, 31), (35, 45)], MULL)
    # plinth
    c.add(c.m(plinth, minus=()), STONE)
    # lantern tab
    c.add(c.m(tabE, minus=(wall,)), LANT)
    # roof
    c.add(c.m(roof), ROOF)
    c.add(c.m(roof) & c.m(rect(0, 23.5, 64, 28)), EAVE)
    c.add(c.m(tabN, minus=(roof,)) | (c.m(rect(17, 12, 47, 15.5)) & c.m(roof)), RIDGE)
    # tile lines on the roof
    if not c.small:
        for xu in range(14, 52, 5):
            c.line([(32 + (xu - 32) * 0.75, 16.5), (xu, 23)], EAVE[1])
    else:
        for xu in (18, 26, 38, 46):
            c.line([(32 + (xu - 32) * 0.75, 17), (xu, 23)], EAVE[1])
    # blossom petals on the wall
    for (x, y) in ((17.5, 48), (46, 28.5)):
        c.px(*c.P(x, y), PINK)
    # lantern glow + face on the window
    c.px(*c.P(57.5, 40), '#fff4c8')
    c.eye(29.5, 40)
    c.eye(40.5, 40)
    c.smile(35, 43.5)
    c.blush(25.5, 43.5)
    c.blush(43.5, 43.5)
    # plinth step line
    if not c.small:
        c.line([(10, 54.5), (54, 54.5)], STONE[1])
        for xu in (20, 32, 44):
            c.line([(xu, 55), (xu, 58)], STONE[1])
    c.add(c.m(rect(30, 51, 39, 55)), ramp('#a07088'))


if __name__ == '__main__':
    print(K.render_pal(fn, 'pl-cblo-6', 'Hilltop Teahouse', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-cblo-6-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-cblo-6.png'))
