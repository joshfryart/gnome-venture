"""dw-canyon-crown "Canyon Crown": a rose-red sandstone mesa that is an inner-TTTT tri piece.
N tri tab = the crown's middle spire (flanked by two rounded cliff pinnacles), E + W tri tabs = jutting rock ledges,
S tri tab = a plum scree foot. Body striped in the cell's rose / plum strata with the purple dusk shadow at the base (cell 1-2)."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, ramp

ROSE = ramp('#b7525a')
PLUM = ramp('#893a50')
DUSK = ramp('#7b4581')
GLOW = ramp('#da7a6a')
SKY = '#a8537d'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = rect(13, 22, 51, 51)
    pinL = poly([(13, 22), (13, 12), (14.5, 9), (17, 8.5), (18.5, 11), (21, 11.5), (22.5, 15), (23, 22)])
    pinR = poly([(51, 22), (51, 15), (49.5, 12), (47, 11.5), (45, 13.5), (42.5, 14.5), (41, 22)])
    tabN = knob('T', 'tri', 32, 22, 0, -1, r=5.2 * k)
    tabE = knob('T', 'tri', 51, 36, 1, 0, r=4.8 * k)
    tabW = knob('T', 'tri', 13, 36, -1, 0, r=4.8 * k)
    tabS = knob('T', 'tri', 32, 51, 0, 1, r=4.8 * k)
    body = c.m(core, pinL, pinR)
    c.add(body, ROSE, stitch=None)
    # crown: pinnacles + spire in the bright glow rose
    c.add(c.m(pinL, pinR, minus=(rect(0, 21, 64, 64),)), GLOW)
    c.add(c.m(tabN, minus=(core,)), GLOW)
    # rim of the mesa top
    c.add(c.m(rect(13, 21, 51, 25)), GLOW)
    # strata bands
    c.add(c.m(rect(13, 40, 51, 44.5)), PLUM)
    c.add(c.m(rect(13, 44.5, 51, 51)), DUSK)
    c.add(c.m(tabE, tabW, minus=(core,)), PLUM)
    c.add(c.m(tabS, minus=(core,)), DUSK)
    # stepped strata ledges: dark crack with a lit lip above (cliff layers)
    for pts in ([(13, 29), (19, 29), (19, 30), (24, 30)], [(40, 30), (45, 30), (45, 29), (51, 29)],
                [(13, 40), (51, 40)]):
        c.line(pts, PLUM[1])
        c.line([(x, y - (1 / c.k)) for x, y in pts], GLOW[2])
    # crown cracks: vertical fissures in the pinnacles
    c.line([(17, 13), (17, 19)], PLUM[0])
    c.line([(46.5, 16), (46.5, 20)], PLUM[0])
    # dusk cave mouth in the purple base (the dark arched doorway of cell 1-2)
    c.add(c.m(ell(22, 47, 2.6, 2.8), rect(19.4, 47, 24.6, 49.5)) & body, (('#3b2440',) * 3))
    # crown jewel: the lantern glow from the cell set in the middle spire
    c.add(c.m(ell(32, 16.5, 2.4 * k, 2.4 * k)), ('#f0c860', '#c89030', '#fff0a0'))
    # face on the calm rose band
    c.eye(25, 34)
    c.eye(39, 34)
    c.smile(32, 38)
    c.blush(20.5, 37.5)
    c.blush(43, 37.5)


K.render_pal(fn, 'dw-canyon-crown', 'Canyon Crown', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/dw-canyon-crown-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/dw-canyon-crown.png')
