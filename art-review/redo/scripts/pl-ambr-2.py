#!/usr/bin/env python3
"""pl-ambr-2 Barkband Ladder. Edge-TBB, keyhole: a stout birch-trunk segment that IS the piece. Flat S = the trunk sawn flat on the
leaf litter; keyhole tab N = the amber leaf crown sprouting from the top; keyhole blanks E + W bite into the trunk.
Pale birch bark warmed by the amber light, umber-brown bark bands as ladder rungs, amber/gold foliage (cell 4-1: trunk + gold leaves)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

BARK = K.ramp('#fbecc4')
BAND = K.ramp('#7a4034')
LEAF = K.ramp('#f8aa38')
LEAF2 = K.ramp('#fcc55c')
LITTER = K.ramp('#d8843a')


def fn(c):
    S = 1.15 if c.small else 1.0
    core = K.rect(14, 21, 50, 58)
    tabN = K.knob('T', 'keyhole', 32, 21, 0, -1, r=7.0 * S, nw=3.6)
    blE = K.knob('B', 'keyhole', 50, 44, 1, 0, r=2.9 * S, nw=1.8)
    blW = K.knob('B', 'keyhole', 14, 44, -1, 0, r=2.9 * S, nw=1.8)
    cut = (blE, blW)
    body = c.m(core, minus=cut)
    c.add(body, BARK, stitch=None if c.small else '#e8c47a')
    # leaf crown: scalloped amber cap over the top of the trunk + the keyhole tab
    def capf(x, y):
        return y < 26 + (2.4 if int((x + 1) // 5) % 2 else 0)
    lumps = (K.ell(27, 9.5, 3.4, 3.4), K.ell(37, 9.5, 3.4, 3.4), K.ell(32, 5.5, 3.6, 3.0))
    crown = c.m(tabN, *lumps, minus=(K.rect(0, 21, 64, 64),)) | (c.m(capf) & body)
    c.add(crown, LEAF)
    c.add(c.m(K.ell(29, 6.5, 3.4, 2.6), K.ell(25.5, 9.5, 1.6, 1.8), K.ell(20, 22.5, 3.2, 1.6), K.ell(33, 22.5, 3.2, 1.6), K.ell(44, 22.5, 2.6, 1.5)) & (crown), LEAF2)
    # bark bands = ladder rungs (full width, slight birch wobble)
    def band(y0, h, gaps):
        return lambda x, y: y0 <= y < y0 + h and not any(a <= x < b for a, b in gaps)
    bands = c.m(band(39.5, 3.0, ((27, 30),)), band(48, 3.0, ((36, 39),))) & body
    c.add(bands, BAND)
    # little birch lenticel dashes
    for (bx, by) in ((19, 30), (45, 29.5), (24, 46), (40, 47.5), (20, 56.5), (44, 56.5)):
        x, y = c.P(bx, by)
        c.px(x, y, BAND[0])
        c.px(x + 1, y, BAND[0])
    # leaf litter at the sawn foot
    
    # dark flared roots on the flat foot (the picture's trunk bases)
    roots = c.m(K.poly([(14, 58), (14, 54), (18, 55.5), (22, 53), (26, 55.5), (32, 53.5), (38, 55.5), (42, 53), (46, 55.5), (50, 54), (50, 58)])) & body
    c.add(roots, BAND)
    # leaf texture: darker amber flecks in the crown
    for (lx, ly) in ((28, 13), (35, 6.5), (32, 16), (38, 11.5), (18, 24.5), (27, 23), (40, 24), (47, 24.5)):
        x, y = c.P(lx, ly)
        c.px(x, y, LEAF[1])
    # a tiny beetle climbing the rungs (64 px only)
    if not c.small:
        x, y = c.P(38, 44)
        for dx, dy in ((0, 0), (1, 0), (0, 1), (1, 1), (0, -1), (1, -1)):
            c.px(x + dx, y + dy, '#2b1c26')
        c.px(x, y - 2, '#7a4034')
        c.px(x + 1, y - 2, '#7a4034')
    c.eye(26, 32.5)
    c.eye(38, 32.5)
    c.smile(32, 35.4)
    c.blush(21.5, 35.3)
    c.blush(41.5, 35.3)


if __name__ == '__main__':
    rep = K.render_pal(fn, 'pl-ambr-2', 'Barkband Ladder', '/home/user/gnome-venture/art-review/redo/out',
                       cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-ambr-2-cell.png',
                       oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-ambr-2.png')
    print(rep)
