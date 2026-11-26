"""pl-dlz-5 Karst Yawn: inner-TTBB peg. A yawning green dragonlizard head in profile, facing left.
N peg tab = bone horn, W peg tab = snout tip (nostril), E and S peg blanks. Cobbled green scales from cell 5-4, den-purple mouth."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path

GREEN = K.ramp('#5c9a38')
DKG = '#2f5a28'
SCALE = '#3d7228'
BELLY = K.ramp('#a8c46a')
HORN = K.ramp('#e2c48a')
MOUTH = ('#3a2240', '#2e1a34', '#4e2e54')
TONGUE = K.ramp('#d8607a')
TOOTH = '#f4f0e4'
EYE = K.ramp('#f0b020')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(12, 14, 52, 54)
    tabN = knob('T', 'peg', 38, 14, 0, -1, r=5.0 * k)
    tabW = knob('T', 'peg', 12, 24, -1, 0, r=4.6 * k)
    blankE = knob('B', 'peg', 52, 25, 1, 0, r=4.6 * k)
    blankS = knob('B', 'peg', 27, 54, 0, 1, r=4.6 * k)
    blanks = (blankE, blankS)
    body = c.m(core, tabW, minus=blanks)
    c.add(body, GREEN)
    # horn tab (bone, like the picture's horns), slightly curved tip
    c.add(c.m(tabN, minus=(core,)) | (c.m(tabN) & c.m(rect(0, 12, 64, 15))), HORN)
    # scales: irregular cobbles (jittered cells), only on the upper head, like cell 5-4
    cw, ch = (6, 5) if not c.small else (5, 4)
    for (x, y) in body:
        if y / c.k > 31:
            continue
        row = y // ch
        off = (row * 3) % cw
        col = (x + off) // cw
        jit = (row * 7 + col * 5) % 3 - 1
        if (y + (col % 2)) % ch == 0 or (x + off + jit) % cw == 0:
            if not c.small or (x + y) % 2 == 0:
                c.px(x, y, SCALE)
    # lower jaw: lighter belly green
    jaw = c.m(poly([(6, 42), (40, 38), (52, 40), (52, 54), (6, 54)]), minus=blanks) & body
    c.add(jaw, BELLY)
    if not c.small:
        for (x, y) in jaw:
            if y % 4 == 0 and (x + y) % 3 != 0 or (x + (y // 4) * 2) % 5 == 0 and y % 4 == 2:
                c.px(x, y, BELLY[1]) if (x, y) in K.erode(jaw) else None
    # open mouth: wide wedge from the left edge (the yawn)
    mouth = c.m(poly([(8, 30), (40, 34), (44, 37), (40, 40), (8, 46)])) & body
    c.add(mouth, MOUTH)
    c.add(c.m(ell(18, 43, 9, 3.2)) & mouth, TONGUE)
    # teeth: top row pointing down, bottom row pointing up
    if not c.small:
        for tx in (12, 17, 22, 27, 32):
            ty = 30 + (tx - 8) * 4 / 32
            c.add(c.m(poly([(tx - 1.6, ty - 0.5), (tx + 1.6, ty - 0.5), (tx, ty + 3.2)])) & body, (TOOTH, TOOTH, TOOTH))
        for tx in (14, 24, 34):
            ty = 46 - (tx - 8) * 6 / 32
            c.add(c.m(poly([(tx - 1.6, ty + 0.5), (tx + 1.6, ty + 0.5), (tx, ty - 3.2)])) & body, (TOOTH, TOOTH, TOOTH))
    else:
        for tx in (12, 20, 28):
            ty = 30 + (tx - 8) * 4 / 32
            c.add(c.m(poly([(tx - 2.2, ty - 0.5), (tx + 2.2, ty - 0.5), (tx, ty + 4)])) & body, (TOOTH, TOOTH, TOOTH))
    # nostril on the snout tab
    c.add(c.m(ell(6.5, 22.5, 1.4, 1.2) if not c.small else ell(6.5, 22.5, 1.8, 1.8)), MOUTH)
    # brow ridge + yellow slit eye
    c.add(c.m(thick_path([(22, 21), (36, 19)], 3.4 if not c.small else 4.2)), GREEN)
    c.add(c.m(ell(31, 26.5, 4.2, 3.6)), EYE)
    ex, ey = c.P(31.5, 26.5)
    hh = 2 if not c.small else 1
    for dy in range(-hh, hh + 1):
        c.px(ex, ey + dy, K.UMBER)
    c.px(ex - 1, ey - hh, K.CREAM)
    c.add(c.m(thick_path([(22, 20), (37, 17.5)], 2.2 if not c.small else 2.8)), (DKG, DKG, DKG))


K.render_pal(fn, 'pl-dlz-5', 'Karst Yawn', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-dlz-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-dlz-5.png')
