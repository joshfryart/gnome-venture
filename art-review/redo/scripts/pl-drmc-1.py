import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

POT = ramp('#4a3a5c')      # night-purple iron pot
RIM = ramp('#6a5880')
STEW = ramp('#c87a30')     # groundnut stew (sand of the cell)
NUT = ramp('#e0a860')
FIRE = ramp('#d8402a')
FLAME = ramp('#f08a20')
GLOW = '#f8d060'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(7, 17, 55, 57)                      # flat W and S sides
    tabN = knob('T', 'round', 30, 17, 0, -1, r=5.6 * k)   # stew bubble rising
    blkE = knob('B', 'round', 55, 35, 1, 0, r=4.6 * k)    # cut into belly
    body = c.m(core, tabN, minus=(blkE,))
    # fire fills the whole piece first (bottom band + corners)
    c.add(body, FIRE)
    # pot belly
    belly = ell(31, 33, 24.5, 20)
    potm = c.add(body & c.m(belly, rect(7, 17, 55, 30)), POT, stitch='#6a5880')
    # rim band
    # stew surface (lumpy top) + bubble tab, then the iron rim band below it
    lumps = [ell(bx, 17.5, 3.2, 2.2) for bx in (13, 20, 40, 47)]
    stew = c.add(c.m(rect(7, 17, 55, 22.5), tabN, *lumps, minus=(blkE,)), STEW)
    rim = c.add(body & c.m(rect(7, 22.5, 55, 26.5)), RIM)
    c.edge(rim, POT[1])
    bub = c.add(body & c.m(ell(30, 10.5, 4.6 * k, 4.6 * k)), NUT)
    c.edge(bub, STEW[1])
    # flames: tongues licking up the lower part
    tongues = []
    for fx, top, w in ((10, 40, 4.5), (19, 46, 4), (28, 50, 4), (38, 49, 4), (48, 44, 4.5), (54, 47, 3)):
        tongues.append(poly([(fx - w, 58), (fx, top), (fx + w, 58)]))
    c.add(body & c.m(*tongues, minus=(belly,)), FLAME)
    inner = []
    for fx, top, w in ((10, 47, 2.5), (19, 51, 2.2), (38, 53, 2.2), (48, 50, 2.5)):
        inner.append(poly([(fx - w, 58), (fx, top), (fx + w, 58)]))
    if not c.small:
        c.add(body & c.m(*inner, minus=(belly,)), (GLOW, FLAME[0], '#fbe8a0'))
    c.edge(potm & c.m(belly), K.UMBER2)
    # bubbles on the surface
    for bx in ((13, 17), (20, 17), (40, 17), (47, 17)):
        x, y = c.P(*bx)
        c.px(x, y, NUT[2])
        if not c.small: c.px(x - 1, y, NUT[2]); c.px(x, y + 1, NUT[0])
    x, y = c.P(28.6, 9)
    c.px(x, y, '#fff4d8')
    if not c.small:
        c.px(x + 1, y, NUT[2]); c.px(x, y + 1, NUT[2])
    # face on belly
    c.eye(23, 34, disc=True)
    c.eye(38, 34, disc=True)
    c.smile(30.5, 40, col=K.CREAM, wide=True)
    c.blush(18, 39)
    c.blush(43, 39)


K.render_pal(fn, 'pl-drmc-1', 'Groundnut Bubble', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-drmc-1-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-drmc-1.png')
