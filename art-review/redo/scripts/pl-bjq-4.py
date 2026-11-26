# Gold Spike Tiara: a gold crown that is an inner-TTTT piece. Top tab = double knob (two crown pearls) between
# two corner spikes; left/right/bottom double tabs on a pale bubble-jelly lower body. Colours from cell 6-0
# (gold crown spike #fada70/#f4c040/#c8883a on teal #42b8cc, white jelly below, pink tip #ff7aa8).
import sys; sys.path.insert(0, '/home/user/gnome-venture/art-review/kit'); import pal_kit as K

GOLD = K.ramp('#f4c040'); GOLD = (GOLD[0], '#c8883a', '#fff4a0')
JELLY = ('#e4f6fb', '#9ccfdc', '#ffffff')
TEAL = K.ramp('#42b8cc')
PINK = K.ramp('#ff7aa8')


def fn(c):
    s = 1.15 if c.small else 1.0
    top, mid, bot = 22, 35, 50
    core = K.rect(13, top, 51, bot)
    spikeL = K.poly([(13, top + 1), (14, 9), (16, 5.5), (18.5, 8), (26.5, top + 1)])
    spikeR = K.poly([(51, top + 1), (50, 9), (48, 5.5), (45.5, 8), (37.5, top + 1)])
    tT = K.knob('T', 'double', 32, top, 0, -1, r=4.6 * s)
    tL = K.knob('T', 'double', 13, 42, -1, 0, r=5.0 * s)
    tR = K.knob('T', 'double', 51, 42, 1, 0, r=5.0 * s)
    tB = K.knob('T', 'double', 32, bot, 0, 1, r=5.0 * s)
    # jelly lower body + side/bottom tabs
    jel = c.m(K.rect(13, mid, 51, bot), tL, tR, tB)
    c.add(jel, JELLY, stitch=None)
    crown = c.m(K.rect(13, top, 51, mid), spikeL, spikeR, tT)
    c.add(crown, GOLD, stitch='#c8883a')
    # band trim at crown bottom
    trim = c.m(K.rect(13, mid - 3, 51, mid))
    c.add(trim, ('#e0a838', '#c8883a', '#f4c040'))
    c.edge(jel, '#9ccfdc')
    # pink gems on spike tips, teal gem in pearl knob centre
    for gx in (15.5, 48.5):
        c.add(c.m(K.ell(gx + (1 if gx < 32 else -1), 10.5, 2.2, 2.2)), PINK)
    for gx in (23, 32, 41):
        c.add(c.m(K.ell(gx, mid - 1.5, 1.9, 1.6)), TEAL if gx == 32 else PINK)
    # bubbles in the jelly
    for bx, by, br in ((18, 46, 2.4), (47, 46, 2.4), (32, 46.5, 1.8)):
        b = c.m(K.ell(bx, by, br, br))
        c.edge(b, '#7fc8d8')
        x, y = c.P(bx - br * 0.4, by - br * 0.4)
        c.px(x, y, '#ffffff')
    # crown jewels on the band, face on the jelly
    for gx, col in ((22, PINK), (32, TEAL), (42, PINK)):
        c.add(c.m(K.poly([(gx, 23.5), (gx + 3, 27), (gx, 30.5), (gx - 3, 27)])), col)
    c.eye(25, 40.5)
    c.eye(39, 40.5)
    c.blush(21, 43.5); c.blush(42, 43.5)
    c.smile(32, 42.5)


K.render_pal(fn, 'pl-bjq-4', 'Gold Spike Tiara', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-bjq-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-bjq-4.png')
