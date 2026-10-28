"""Puzzle Pals: THE DUNEWHISPER roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_dunewhisper.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own cell of
game/assets/img/jigsaw/dunewhisper.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (the brass mint-tea pot, the scarab's sand ball, the lantern string, a rose cliff crown,
a date-palm sprig, the flying carpet).
Picture palette (jigsaw_dunewhisper.py): dusk violet #563a78 / #3d2a63, rose #d06a78, canyon #b8525a, sand #e2a273, lantern #ffd85a,
palm #5a8a4a, teal #3f8fa0, carpet red #d6322b.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('dunewhisper')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'dunewhisper':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

LANT, LANT_D, LANT_L = '#ffd85a', '#e8a317', '#fff4c0'
SAND, SAND_D, SAND_L = '#e2a273', '#c47c5e', '#f2c08a'
CANYON, CANYON_D, CANYON_L = '#b8525a', '#8a3a50', '#d97a6a'
ROSE = '#d06a78'
TEAL, TEAL_D, TEAL_L = '#3f8fa0', '#25637d', '#7ac0c8'
PALM, PALM_D, PALM_L = '#5a8a4a', '#35603f', '#8ab060'
TRUNK, TRUNK_D = '#8a5a3a', '#5c3a2a'
RED, RED_D = '#d6322b', '#a8241f'
SQUASH = '#f08a24'


def body_fill(key, mask, x0, y0, size, k=4, passes=2, dx=0.0, dy=0.0, swap=None):
    col, row = ROWS[key]['piece']
    t = pic.sample(col, row, x0, y0, size, dx, dy)
    t = majority(t, mask, passes)
    t = reduce(t, mask, k)
    if swap:
        t = remap(t, mask, swap)
    return t


def calm(tex, mask, keep_n=2):
    """Fold every fill colour but the keep_n commonest into the nearest kept one (a flat felt body the face reads on)."""
    return reduce(tex, mask, keep_n)


def tidy(st, cap=35):
    """Colour budget (< 40 with outline and border): fold the rarest painted tones into their nearest kept colour."""
    m = st.sil | st.extra
    while True:
        cols, cnt = np.unique(st.px[m].reshape(-1, 3), axis=0, return_counts=True)
        if len(cols) <= cap:
            return
        i = cnt.argmin()
        rest = np.delete(cols, i, 0).astype(int)
        near = rest[((rest - cols[i].astype(int)) ** 2).sum(-1).argmin()]
        st.px[m & np.all(st.px == cols[i], axis=2)] = near


def feet(st, xs, y, w=6, h=4):
    for x in xs:
        shoe = rect(x, y, x + w - 1, y + h - 1)
        shoe[y, x] = shoe[y, x + w - 1] = False
        st.part(shoe, SHOE[0], d=1, contour=True)


# ------------------------------------------------------------------ 1. Sherbet Sip: corner-TT round, common. Dusk-and-caravan corner piece holding a brass mint-tea pot up high.
def sherbet_sip():
    key = 'dw-sherbet-sip'
    st = Sticker()
    core = (16, 24, 44, 50)
    body = piece(core, s='F', w='F', n=('T', 'round', 3), e=('T', 'round', 2))
    # teapot held up over the flat top-left corner: pear body, long spout, lid knob, handle
    handle = disc(22, 17, 4.2) & ~disc(22, 17, 2.2) & (CX > 21)
    st.part(handle, LANT_D, d=0, contour=True)
    spout = poly([(11, 17), (8, 10), (10, 9), (14, 14)])
    st.part(spout, LANT, d=1, contour=True)
    pot = ellipse(16, 17.5, 5.5, 4.5) | poly([(13, 13), (19, 13), (18, 10), (14, 10)])
    st.part(pot, LANT, d=2, contour=True)
    st.part(rect(15, 7, 17, 9), LANT_D, d=0, contour=True)
    st.paint(rect(11, 18, 21, 18) & pot, TEAL)                          # enamel band
    st.part(body, tex=calm(body_fill(key, body, 16, 24, 29, k=3, passes=3), body, 2), contour=True)
    st.stitch(body)
    feet(st, [19, 35], 51)
    st.eye(21, 31, look=(-1, -1))
    st.eye(33, 31, look=(-1, -1))
    st.mouth('grin', 27, 39)
    return key, st


# ------------------------------------------------------------------ 2. Scarab Roll: edge-BTB keyhole, common. Carpet-and-lamp edge piece pushing its ball of sand.
def scarab_roll():
    key = 'dw-scarab-roll'
    st = Sticker()
    core = (9, 22, 39, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', -2), w=('B', 'keyhole', -3), e=('B', 'keyhole', -5))
    st.part(body, tex=calm(body_fill(key, body, 9, 22, 31, k=3, passes=4, dy=-0.15), body, 2))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [12, 28], 50)
    # the sand ball, rolled ahead on the right with a ripple band
    ball = disc(50, 46, 7.5)
    st.part(ball, SAND, d=3, contour=True)
    st.paint(ball & shrink(ball, 1) & (np.abs((CX - 50) * 0.6 + (CY - 46) - 1) < 0.9), SAND_D)
    st.dots([(47, 42), (52, 49)], SAND_L)
    st.eye(19, 28, look=(1, 0))
    st.eye(30, 28, look=(1, 0))
    st.mouth('grin', 24, 37)
    return key, st


# ------------------------------------------------------------------ 3. Lantern Lark: inner-TBBB peg, common. Minaret-and-dusk piece, wedge beak, a lantern string draped over its head.
def lantern_lark():
    key = 'dw-lantern-lark'
    st = Sticker()
    core = (12, 21, 45, 48)
    body, holes = piece_blanks(core, n=('T', 'peg', 0), e=('B', 'peg', 5, 3.4), s=('B', 'peg', 0, 3.4), w=('B', 'peg', 5, 3.4))
    st.part(body, tex=calm(body_fill(key, body, 12, 21, 34, k=3, passes=3, dx=0.1, swap={'#4a3366': '#7a4580'}), body, 2))   # calm the minaret column
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [14, 37], 49)
    # lantern string: a sagging cord across the top corners with three fat lanterns
    cord = line([(8, 18), (16, 21), (28, 22), (41, 21), (50, 18)])
    st.paint(cord, UMBER2, solid=True)
    for lx, ly, c, cd in ((12, 19, LANT, LANT_D), (46, 19, ROSE, CANYON_D)):
        lm = ellipse(lx + 0.5, ly + 4.0, 3.0, 3.5)
        st.part(lm, c, d=1, contour=True)
        st.paint(rect(lx - 1, ly + 1, lx + 1, ly + 1), UMBER2, solid=True)
    st.eye(19, 27, look=(0, 1))
    st.eye(33, 27, look=(0, 1))
    # wedge beak
    st.sprite(['OOOOOO', '.OOOO.', '..OO..'], 26, 33, {'O': SQUASH}, solid=False)
    st.paint(rect(26, 33, 31, 33), '#b85a14')
    return key, st


# ------------------------------------------------------------------ 4. Canyon Crown: inner-TTTT tri, uncommon. Plus of rose cliff, a crown of cliff spires; teal stitch accent.
def canyon_crown():
    key = 'dw-canyon-crown'
    st = Sticker()
    core = (18, 22, 45, 47)
    body = piece(core, n=('T', 'tri'), e=('T', 'tri'), s=('T', 'tri'), w=('T', 'tri'))
    st.part(body, tex=body_fill(key, body, 18, 22, 28, k=2, passes=3, swap={'#7a4580': '#b8525a', '#563a78': '#9a4a52'}), contour=True)   # one cliff rose
    st.stitch(body, col=TEAL)
    # crown: a gold band with three flat-topped rose cliff spires (the middle one rides the top tab)
    sp = poly([(16, 25), (16, 15), (20, 13), (23, 19), (28, 19), (29, 9), (35, 9), (36, 19), (41, 19), (44, 13), (48, 15), (48, 25)])
    st.part(sp, CANYON, d=2, contour=True)
    st.paint(sp & ~shift(sp, 0, 1) & ~shift(sp, 1, 1), CANYON_L)          # sunlit mesa tops
    st.paint(line([(19, 17), (19, 21)]) | line([(32, 12), (32, 18)]) | line([(45, 17), (45, 21)]), CANYON_D)   # cliff cracks
    band = rect(16, 22, 48, 25)
    st.part(band, LANT, d=1, contour=True)
    st.paint(rect(30, 23, 33, 24), TEAL)                               # teal gem
    st.paint(rect(30, 23, 30, 23), TEAL_L)
    st.eye(22, 30, look=(1, 0))
    st.eye(35, 30, look=(1, 0))
    st.mouth('smile', 29, 39)
    return key, st


# ------------------------------------------------------------------ 5. Oasis Hoop: inner-BBBB double, uncommon. The Ring: oasis-pool piece with a date-palm sprig; teal stitch accent.
def oasis_hoop():
    key = 'dw-oasis-hoop'
    st = Sticker()
    core = (11, 15, 50, 49)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.8), e=('B', 'double', 0, 3.8), s=('B', 'double', 0, 3.8),
                               w=('B', 'double', 0, 3.8))
    st.part(body, tex=body_fill(key, body, 11, 15, 40, k=3, passes=3, swap={'#c98a5a': '#563a78', '#2a1a10': '#563a78'}))   # calm the camel head: pool only
    st.blank_shade(body, holes)
    st.stitch(body, col=TEAL_L, skip=grow(holes, 3))
    feet(st, [15, 41], 50)
    # date-palm sprig tucked over the left top corner: two fronds and a hanging bunch of dates
    fr = poly([(17, 14), (10, 9), (8, 12), (13, 15)]) | poly([(18, 14), (23, 7), (27, 9), (21, 15)])
    st.part(fr, PALM, d=1, contour=True)
    st.paint(line([(16, 14), (10, 11)]) | line([(19, 14), (24, 9)]), PALM_D)
    dates = disc(16.5, 18, 2.0) | disc(20, 18.5, 2.0) | disc(18, 21.5, 2.0)
    st.part(dates, TRUNK, d=1, contour=True)
    st.dots([(16, 17), (19, 18)], '#b07a4a')
    st.eye(20, 25, look=(0, 1))
    st.eye(36, 25, look=(0, 1))
    st.mouth('grin', 28, 32)
    return key, st


# ------------------------------------------------------------------ 6. Mirage Moon: whimsy-moon keyhole, rare. Lantern-gold crescent (its moon cell by brightness) riding the flying carpet; glow + sparkles.
def mirage_moon():
    key = 'dw-mirage-moon'
    st = Sticker()
    col, row = ROWS[key]['piece']
    moon = disc(35, 29, 18.5) & ~disc(46.5, 23, 13.5)
    tab = knob('w', 'keyhole', 29, 16.5, r=3.0)
    body = moon | tab
    src = pic.sample(col, row, 16, 11, 38).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(LANT)
    tex[src > 520] = hx(LANT_L)
    tex = majority(tex, body, 3)
    st.part(body, tex=tex, contour=True)
    st.stitch(moon)
    # flying carpet under the crescent: red, gold stripe, tassels at the corners
    carpet = poly([(13, 46), (48, 42), (50, 47), (15, 51)])
    st.part(carpet, RED, d=1, contour=True)
    st.paint(line([(15, 48), (48, 44)]) & carpet, LANT)
    st.paint(line([(16, 49), (48, 45)]) & carpet & (((XX // 3) % 2) == 0), TEAL)
    st.part(rect(10, 46, 12, 47) | rect(13, 51, 15, 52) | rect(49, 41, 51, 42) | rect(51, 47, 53, 48), LANT, d=0, contour=True)
    st.eye(18, 25, look=(1, 0), lid=1)
    st.eye(26, 28, look=(1, 0))
    st.mouth('smile', 21, 36)
    st.sparkle(50, 4)
    st.sparkle(54, 28, big=False)
    st.sparkle(5, 36, big=False)
    return key, st


PALS = [sherbet_sip, scarab_roll, lantern_lark, canyon_crown, oasis_hoop, mirage_moon]

if __name__ == '__main__':
    print('dominant', pic.dominant(4))
    paths = []
    for fn in PALS:
        key, st = fn()
        tidy(st)
        assert key in ROWS, key
        p = os.path.join(OUTDIR, key + '.png')
        info = st.save(p, glow=(ROWS[key]['rarity'] == 'rare'))
        paths.append(p)
        print('%-20s %-9s %-11s %-8s colours %d margin %d' % (key, ROWS[key]['rarity'], ROWS[key]['shape'], ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
