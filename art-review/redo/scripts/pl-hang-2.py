import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Leaning Palm Fringe: edge-TTB keyhole. Flat bottom = sandstone ruin ledge; top tab = frond tuft, right tab = drooping frond,
# left blank cut into the stone/trunk mass. Greens from cell 3-1 (garden canopy), ruin beige + sky blue from the picture.
LEAF = K.ramp('#5cbf48')
LEAF2 = K.ramp('#3f9a3a')
DEEP = '#2f7a34'
STONE = K.ramp('#d2bc96')
TRUNK = K.ramp('#a8743e')
COCO = K.ramp('#7a5230')
SKY = K.ramp('#8fb0e0')

def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(9, 10, 55, 58)
    top = K.knob('T', 'keyhole', 33, 10, 0, -1, r=4.5 * k)
    right = K.knob('T', 'keyhole', 55, 24, 1, 0, r=4.5 * k)
    left = K.knob('B', 'keyhole', 9, 40, -1, 0, r=4.5 * k)
    notches = [K.poly([(x - 2.2, 9.5), (x + 2.2, 9.5), (x, 13.5)]) for x in (16, 23, 43, 50)]
    notches += [K.poly([(55.5, y - 2.2), (55.5, y + 2.2), (51.5, y)]) for y in (15, 36)]
    body = c.m(core, top, right, minus=[left] + notches)
    # lower fronds: darker drooping leaves fill everything above the ledge (no sky: the piece IS the palm)
    c.add(body, LEAF2)
    # ruin ledge at the bottom (flat side)
    stone = c.m(K.rect(0, 46, 64, 64)) & body
    c.add(stone, STONE, stitch='#a8906a')
    # leaning trunk from bottom-left up to crown at upper right
    trunk = c.m(K.thick_path([(22, 58), (27, 44), (33, 32), (38, 24)], 8.5)) & body
    c.add(trunk, TRUNK)
    # bright crown with a fringed (zigzag) lower hem, covers top + right tab
    def crown(x, y):
        ph = ((x - 9) / 7.0) % 1.0
        hem = 24 + 13 * (1 - abs(ph - 0.5) * 2) ** 0.6   # long drooping frond fingers
        return y < hem
    can = c.m(crown, minus=(K.rect(0, 46, 64, 64),)) & body
    c.add(can, LEAF, stitch=LEAF[2] if not c.small else None)
    # short ribs on each finger
    for x in range(12, 56, 7):
        c.line([(x + 0.5, 24), (x + 0.5, 33)], LEAF2[0])
    # coconuts under crown
    nuts = c.m(K.ell(35, 27, 3.0, 3.0), K.ell(40.5, 26, 3.0, 3.0))
    c.add(nuts, COCO)
    # trunk rings
    for t in (0.2, 0.42, 0.64, 0.86):
        x = 22 + (35 - 22) * t
        y = 58 + (30 - 58) * t
        c.line([(x - 3.2, y - 1.2), (x + 3.2, y + 1.2)], TRUNK[1])
    # ruin arch in the stone
    arch = c.m(K.rect(42, 50, 49, 58), K.ell(45.5, 50, 3.5, 3.5)) & body
    c.add(arch, K.ramp('#6a5068'))
        # face on the canopy
    c.eye(28, 16, disc=True)
    c.eye(42, 16, disc=True)
    c.smile(35, 20)
    c.blush(23, 20)
    c.blush(47, 20)

K.render_pal(fn, 'pl-hang-2', 'Leaning Palm Fringe', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-hang-2-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-hang-2.png')
