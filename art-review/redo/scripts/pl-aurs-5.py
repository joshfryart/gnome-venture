#!/usr/bin/env python3
"""pl-aurs-5 "Cool Dip": inner-BBBB, peg. A chunky block of lake ice IS the piece: four square peg blanks are holes sawn into its
sides, a round turquoise dip-hole is cut in its snowy top, and the sauna's plum-and-amber plank ladder (the tub staves of cell 1-7,
with the slate-blue hoop colour) pokes up out of the hole and breaks the top edge. Felt eyes and cold blush on the ice face."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

ICE = ('#b8dcea', '#7078a8', '#e8f6fb')      # front face; shade = the cell's slate-blue hoop
SNOW = ('#f4f0f4', '#c4c8dc', '#ffffff')
WATER = ('#3cc0c8', '#1d7a90', '#8ae4e4')
DEEP = ('#235a78', '#183c58', '#3a7aa0')
WOOD = ('#6e3c52', '#4a2638', '#94566a')     # plum staves from the cell
AMBER = K.ramp('#d8843a')                    # the amber glow on the staves


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 12, 55, 55)
    r = 4.0 * k
    blanks = (K.knob('B', 'peg', 32, 12, 0, -1, r=r), K.knob('B', 'peg', 32, 55, 0, 1, r=r),
              K.knob('B', 'peg', 9, 34, -1, 0, r=r), K.knob('B', 'peg', 55, 34, 1, 0, r=r))
    body = c.m(core, minus=blanks)
    c.add(body, ICE, stitch=None)
    # snowy top slab with a soft lumpy lower edge
    snow = c.m(lambda x, y: y < 22 + (1.3 if (int(x) // 5) % 2 else 0)) & body
    c.add(snow, SNOW)
    # the dip hole: dark rim, turquoise water, ripple ring
    rim = c.m(K.ell(30, 26.5, 14.5, 7.4))
    c.add(rim & body, WOOD)
    if not c.small:
        for (x, y) in (rim & body) - c.m(K.ell(30, 26.5, 12.5, 5.8)):
            if (x % 4 == 0):
                c.px(x, y, AMBER[1])
    hole = c.m(K.ell(30, 26.5, 12.5, 5.8))
    c.add(hole & body, DEEP)
    water = c.m(K.ell(30, 27.2, 10.6, 4.6))
    c.add(water & body, WATER)
    if not c.small:
        c.line([(23, 27.5), (27, 28.5), (32, 28.5), (36, 27.5)], WATER[2])
    else:
        c.line([(25, 28), (34, 28)], WATER[2])
    # plank ladder rising out of the hole past the top edge
    rw = 3.6 if not c.small else 4.2
    railL = c.m(K.thick_path([(35.5, 28), (38, 2.5)], rw))
    railR = c.m(K.thick_path([(45.5, 28), (48, 2.5)], rw))
    rh = 3.0 if not c.small else 3.6
    rungs = c.m(*[K.rect(37, y, 47.5, y + rh) for y in (6, 13)])
    c.add(rungs - railL - railR, AMBER)
    for p in rungs - railL - railR:
        c.px(p[0], p[1], AMBER[0])
    c.add(railL | railR, WOOD)
    # ice cracks / sheen on the front face
    if not c.small:
        c.line([(13, 46), (16, 43), (15, 40)], ICE[2])
        c.line([(50, 49), (47, 47)], ICE[2])
    # face on the ice front
    c.eye(21, 40, disc=True)
    c.eye(42, 40, disc=True)
    c.smile(31.5, 44.5)
    c.blush(17, 44)
    c.blush(46, 44)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-aurs-5', 'Cool Dip', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-aurs-5-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-aurs-5.png')
    print(rep)
