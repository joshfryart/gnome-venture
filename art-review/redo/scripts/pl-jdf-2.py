# Reedleg Cling: a jade dragonfly nymph that IS an edge piece. Top = blank cut between its two big blue compound eyes,
# left/right = hook tabs that are its front legs gripping, bottom = the flat side, a lily-green reed it clings to.
# Colours/motif from cell 11-5: jade-teal water, mint wing-vein dots (as wing pads), blue dragonfly eyes from the picture.
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

JADE = K.ramp('#2f9a82')
BELLY = K.ramp('#5cc0a0')
EYE = K.ramp('#39a8d0')
MINT = K.ramp('#96d8c4')
REED = K.ramp('#5aa83a')
LEG = K.ramp('#1d6a62')

def fn(c):
    s = 1.15 if c.small else 1.0
    core = K.rect(12, 9, 52, 57)
    tl = K.knob('T', 'hook', 12, 28, -1, 0, r=4.6 * s, flip=True)
    tr = K.knob('T', 'hook', 52, 28, 1, 0, r=4.6 * s)
    bt = K.knob('B', 'round', 32, 9, 0, -1, r=5.2 * s)
    w = 3.2 if c.small else 2.8
    lg = [K.thick_path([(13, 40), (6, 45), (7, 51)], w), K.thick_path([(51, 40), (58, 45), (57, 51)], w)]
    body = c.m(core, tl, tr, minus=(bt,))
    c.add(c.m(*lg), LEG)
    c.add(body, JADE, stitch=None if c.small else '#7ccfb4')
    # hooked front legs (the tabs) darker
    legs = c.m(tl, tr, K.rect(8, 24, 14, 34), K.rect(50, 24, 56, 34), minus=(bt,))
    c.add(legs, LEG)
    # segmented abdomen
    ab = c.m(K.ell(32, 38, 11, 12))
    c.add(ab, BELLY)
    for yy in (32, 37, 42):
        c.line([(23, yy), (41, yy)], JADE[1])
    # wing pads in mint (the cell's wing-vein dots)
    wl = c.m(K.ell(19, 38, 4.5, 8))
    wr = c.m(K.ell(45, 38, 4.5, 8))
    c.add(wl, MINT); c.add(wr, MINT)
    c.edge(wl, MINT[1]); c.edge(wr, MINT[1])
    if not c.small:
        for yy in (34, 38, 42):
            c.px(*c.P(19, yy), '#d5f9fa'); c.px(*c.P(45, yy), '#d5f9fa')
    # big blue compound eyes either side of the top blank
    el = c.m(K.ell(20, 16, 7.5, 6.5), minus=(bt,))
    er = c.m(K.ell(44, 16, 7.5, 6.5), minus=(bt,))
    c.add(el, EYE); c.add(er, EYE)
    c.edge(el, EYE[1]); c.edge(er, EYE[1])
    # reed: the flat bottom side, gripped by the back legs
    reed = c.m(K.rect(3, 50, 61, 57), K.ell(3, 53.5, 2.5, 3.5), K.ell(61, 53.5, 2.5, 3.5))
    c.add(reed, REED)
    c.edge(reed, REED[1])
    for x0 in (16, 26, 38, 48):
        c.line([(x0, 47), (x0 - 1 if x0 < 32 else x0 + 1, 51)], LEG[1])
    # face: felt eyes in the compound eyes, smile below
    c.eye(20, 16.5, look=(1, 0))
    c.eye(44, 16.5, look=(-1, 0) if not c.small else (0, 0))
    c.smile(32, 25)
    c.blush(25, 25); c.blush(38, 25)

K.render_pal(fn, 'pl-jdf-2', 'Reedleg Cling', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-jdf-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-jdf-2.png')
