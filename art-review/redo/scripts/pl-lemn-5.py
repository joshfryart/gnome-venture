import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
# Sunset Halo: a setting sun whose peach halo is an inner-BBBB piece (peg blanks on all four sides),
# rounded rays at the corners, amber sun face centre, terracotta monastery eave across the lower-left corner (cell 10-3).
HALO = K.ramp('#ffcf94')      # cell peach sky
PALE = K.ramp('#f2dcaa')      # cell pale cream band
SUN = ('#f4a42a', '#c8701c', '#ffd870')
RAY = ('#f2a03a', '#c86a1c', '#f8c868')
ROOF = ('#c2562c', '#8a3020', '#e08048')
PLUM = K.ramp('#6a2e3e')

def fn(c):
    s = 1.12 if c.small else 1.0
    r = 3.2 * s
    core = K.poly([(12, 7), (52, 7), (57, 12), (57, 52), (52, 57), (12, 57), (7, 52), (7, 12)])
    blanks = [K.knob('B', 'peg', 32, 7, 0, -1, r=r), K.knob('B', 'peg', 32, 57, 0, 1, r=r),
              K.knob('B', 'peg', 7, 32, -1, 0, r=r), K.knob('B', 'peg', 57, 32, 1, 0, r=r)]
    body = c.m(core, minus=blanks)
    c.add(body, HALO)
    c.add(c.m(K.rect(0, 0, 64, 16)) & body, PALE)
    # painted sun rays radiating through the halo (8 wedges)
    import math
    wedges = []
    for i in range(8):
        a = i * math.pi / 4 + math.pi / 8
        ca, sa = math.cos(a), math.sin(a)
        px_, py_ = -sa, ca
        tip = (32 + ca * 31, 32 + sa * 31)
        b1 = (32 + ca * 15 + px_ * 5, 32 + sa * 15 + py_ * 5)
        b2 = (32 + ca * 15 - px_ * 5, 32 + sa * 15 - py_ * 5)
        wedges.append(K.poly([b1, tip, b2]))
    c.add(c.m(*wedges) & body, RAY)
    sun = c.m(K.ell(32, 32, 15, 15))
    c.add(sun, SUN, stitch=None if c.small else '#ffe08a')
    c.edge(sun, '#c8701c')
    # monastery roof eave in the lower-left corner (from the cell)
    eave = c.m(K.poly([(2, 36), (26, 62), (2, 62)])) & body
    c.add(eave, ROOF)
    c.add(c.m(K.poly([(2, 46), (16, 62), (2, 62)])) & body, PLUM)
    c.edge(eave, '#8a3020')
    c.eye(27, 30)
    c.eye(37, 30)
    c.smile(32, 36)
    c.blush(23, 35); c.blush(40, 35)

K.render_pal(fn, 'pl-lemn-5', 'Sunset Halo', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-lemn-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-lemn-5.png')
