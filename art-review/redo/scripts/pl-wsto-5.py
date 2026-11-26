# pl-wsto-5 "Round-Eyed Peeker": a mossy carved stone head (moai-like watcher) that IS an inner-TTBB keyhole piece.
# Tabs: N (a moss-tufted stone topknot) and E (a carved stone ear); blanks: W (cheek) and S (under the chin).
# Colours from cell 1-5: mauve-grey stone, tan brow band, deep violet brow shadow, moss greens, big dark round eye.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, knob, thick_path, ramp

STONE = ramp('#b0a2ac')
BAND = ramp('#bea197')
PALE = ramp('#c8bbba')
MOSS = ramp('#5aa050')
MOSSL = '#9ed070'
VIOLET = '#544c74'
VIOLET2 = '#7a6e92'
EYE = '#2b1c26'
CREAM = '#e0d4c8'


def fn(c):
    k = 1.15 if c.small else 1.0
    # core: square-ish with a gently domed crown (rounded top corners only)
    core = c.m(lambda x, y: (13 <= x < 51 and 18 <= y < 59) or ((x - 32) / 19) ** 2 + ((y - 20) / 10) ** 2 < 1)
    tabN = knob('T', 'keyhole', 32, 11, 0, -1, r=4.6 * k)
    tabE = knob('T', 'keyhole', 51, 33, 1, 0, r=4.4 * k)
    blankW = knob('B', 'keyhole', 13, 46, -1, 0, r=4.0 * k)
    blankS = knob('B', 'keyhole', 32, 59, 0, 1, r=3.5 * k)
    body = (core | c.m(tabN, tabE)) - c.m(blankW, blankS)
    c.add(body, STONE)
    # carved ear on the E tab
    ear = c.m(tabE) & body
    c.add(ear, PALE)
    c.line([(54, 30.5), (57.5, 30.5), (58.5, 33), (57, 35.5), (55, 35.5)], STONE[1])
    # brow band (the tan carved band across the forehead)
    band = body & c.m(rect(0, 19, 64, 25.5))
    c.add(band, BAND)
    c.edge(band, VIOLET2)
    # heavy brow ridge shadow
    brow = body & c.m(rect(15, 25.5, 49, 28.5))
    c.add(brow, (VIOLET, VIOLET, VIOLET2))
    # moss: topknot tuft on the N tab and patches on the crown / cheeks
    tuft = c.m(tabN, ell(32, 13, 7, 3.5)) & body
    c.add(tuft, MOSS)
    patches = c.m(ell(22, 15.5, 4.5, 2.2), ell(45, 50, 3.4, 4.5), ell(20, 54, 3, 2.4)) & body
    c.add(patches, MOSS)
    if not c.small:
        for (x, y) in patches | tuft:
            if (x * 3 + y * 5) % 7 == 0:
                c.px(x, y, MOSSL)
    else:
        for (x, y) in tuft:
            if (x + y) % 3 == 0:
                c.px(x, y, MOSSL)
    # long carved nose
    nose = c.m(poly([(29.5, 28), (34.5, 28), (36.5, 40), (27.5, 40)]))
    c.add(nose, PALE)
    c.edge(nose, STONE[1])
    for x in range(*[c.P(28, 0)[0], c.P(36.5, 0)[0]]):
        c.px(x, c.P(0, 40)[1], VIOLET2)
    # flat carved lips
    lips = c.m(rect(24, 42.5, 40, 46))
    c.add(lips, PALE)
    y = c.P(0, 44.2)[1]
    for x in range(c.P(24, 0)[0], c.P(40, 0)[0]):
        c.px(x, y, VIOLET)
    # big round eyes (felt: dark disc + cream glint)
    for ex in (22.5, 41.5):
        r = 4.2
        eye = c.m(ell(ex, 33, r, r))
        for (x, y) in eye:
            c.px(x, y, EYE)
        gx, gy = c.P(ex - 1.6, 31.4)
        c.px(gx, gy, CREAM)
        if not c.small:
            c.px(gx + 1, gy, CREAM)
            c.px(gx, gy + 1, CREAM)


K.render_pal(fn, 'pl-wsto-5', 'Round-Eyed Peeker', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wsto-5-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wsto-5.png')
print(K.check(__import__('PIL.Image').Image.open('/home/user/gnome-venture/art-review/redo/out/pl-wsto-5.png')) ['colours'])
