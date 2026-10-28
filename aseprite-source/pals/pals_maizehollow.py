"""Puzzle Pals: THE MAIZEHOLLOW roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_maizehollow.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Each pal is a living jigsaw piece cut from game/assets/img/jigsaw/maizehollow.jpg: its silhouette is the row's shape + knob
(game/includes/data/puzzle_pals.txt), its body is filled with its own cell (col-row of the 12 x 8 grid), snapped to the picture's palette.
One accessory each from the picture's motifs (corn husk, a corn cob, the plaza bell, a scarecrow straw hat, the paper-flag string, popcorn).
Picture palette (aseprite-source/scenes-pil/jigsaw_maizehollow.py): maize #e8b83a, corn #5a9a3a, chili #d6322b, turquoise #3fb0a8, terra #c8643a.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('maizehollow')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'maizehollow':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

MAIZE, MAIZE_D, MAIZE_L = '#e8b83a', '#b8862a', '#f8dc7a'
CORN, CORN_D, CORN_L = '#5a9a3a', '#3a6a2a', '#8cc45a'
HUSK, HUSK_D = '#e8dcb8', '#b8a888'
CHILI, CHILI_D = '#d6322b', '#a8241f'
TURQ, TURQ_D, TURQ_L = '#3fb0a8', '#24807e', '#8adcd0'
PINK = '#e46a9b'
WOOD, WOOD_D = '#b07a3a', '#7a4a1f'
SQUASH = '#f08a24'


def body_fill(key, mask, x0, y0, size, k=4, passes=2, dx=0.0, dy=0.0, swap=None):
    col, row = ROWS[key]['piece']
    t = pic.sample(col, row, x0, y0, size, dx, dy)
    t = majority(t, mask, passes)
    t = reduce(t, mask, k)
    if swap:
        t = remap(t, mask, swap)
    return t


def lift(tex, mask, col, thr=260):
    """Calm a dark busy cell: fill colours darker than thr (r+g+b) become col, so the face reads on top."""
    t = tex.copy()
    dark = mask & (t.astype(int).sum(-1) < thr)
    t[dark] = hx(col)
    return t


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


def leaf(st, pts, col=CORN, vein=None, vcol=CORN_L):
    m = poly(pts)
    st.part(m, col, d=1, contour=True)
    if vein:
        st.paint(line(vein) & shrink(m, 1), vcol)
    return m


# ------------------------------------------------------------------ 1. Husk Hopper: corner-TB round, common. Corn-row corner piece popping out of a peeled husk.
def husk_hopper():
    key = 'mh-husk-hopper'
    st = Sticker()
    core = (14, 24, 43, 49)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'round', -1, 4.2), e=('T', 'round', 4))
    # husk leaves behind the body: peeled back from the sides like it just popped out
    leaf(st, [(16, 34), (10, 26), (8, 14), (11, 11), (16, 20), (21, 26)], HUSK, [(11, 14), (16, 27)], HUSK_D)
    leaf(st, [(41, 34), (47, 26), (50, 14), (47, 11), (42, 20), (37, 26)], HUSK, [(47, 14), (42, 27)], HUSK_D)
    st.part(body, tex=lift(body_fill(key, body, 14, 24, 30, k=3, passes=3), body, '#b8683e', 200), contour=True)
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [17, 33], 50)
    st.eye(17, 36, look=(0, -1))
    st.eye(31, 36, look=(0, -1))
    st.mouth('o', 25, 43)
    return key, st


# ------------------------------------------------------------------ 2. Cob Scout: edge-TBB peg, common. Sky-and-smoke edge piece, a corn-cob walking staff.
def cob_scout():
    key = 'mh-cob-scout'
    st = Sticker()
    core = (13, 20, 40, 47)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg'), e=('B', 'peg', 2), w=('B', 'peg', 2))
    st.part(body, tex=body_fill(key, body, 13, 20, 28, k=3, passes=2))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [16, 30], 48)
    # staff + cob on the right, held by a stubby arm
    st.part(rect(48, 30, 49, 55), WOOD_D, d=0, contour=True)
    cob = ellipse(48.5, 20, 4.5, 9.5)
    st.part(cob, MAIZE, d=1, contour=True)
    st.paint(cob & shrink(cob, 1) & ((XX + YY) % 3 == 0) & (YY % 2 == 0), MAIZE_D)
    leaf(st, [(46, 26), (41, 22), (40, 30), (47, 32)], CORN)
    leaf(st, [(51, 26), (55, 22), (55, 29), (50, 32)], CORN)
    st.part(rect(41, 35, 47, 37), WOOD_D, d=0, contour=True)
    st.eye(17, 27, look=(1, 0))
    st.eye(29, 27, look=(1, 0))
    st.mouth('smile', 23, 36)
    return key, st


# ------------------------------------------------------------------ 3. Kernel Knock: inner-TBBB round, common. Plaza piece with the bell it knocks on.
def kernel_knock():
    key = 'mh-kernel-knock'
    st = Sticker()
    core = (11, 18, 42, 46)
    body, holes = piece_blanks(core, n=('T', 'round', -3), e=('B', 'round', 2, 3.8), s=('B', 'round', 0, 3.8), w=('B', 'round', 2, 3.8))
    st.part(body, tex=lift(body_fill(key, body, 11, 18, 32, k=3, passes=3, dy=0.25), body, '#dcb482', 330))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [13, 34], 47)
    # bell hung from a little yoke over the right shoulder
    st.part(rect(42, 15, 52, 16) | rect(42, 15, 43, 22), WOOD_D, d=0, contour=True)
    bell = poly([(47, 18), (51, 18), (53, 23), (54, 28), (56, 30), (42, 30), (44, 28), (45, 23)])
    st.part(rect(48, 17, 50, 18), WOOD_D, d=0)
    st.part(bell, GOLD, d=1, contour=True)
    st.paint(rect(42, 30, 56, 30) & bell, GOLD_D)
    st.part(rect(48, 31, 50, 33), UMBER, d=0, contour=True)
    st.eye(17, 25, look=(1, -1))
    st.eye(29, 25, look=(1, -1))
    st.mouth('grin', 22, 33)
    return key, st


# ------------------------------------------------------------------ 4. Stitch Crow: inner-TTBB hook, uncommon. Temple-stone crow in a scarecrow straw hat, chili accent.
def stitch_crow():
    key = 'mh-stitch-crow'
    st = Sticker()
    core = (17, 22, 46, 45)
    body, holes = piece_blanks(core, n=('B', 'hook', 7, 4.0), e=('B', 'hook', 1), s=('T', 'hook', 0), w=('T', 'hook', 2))
    st.part(body, tex=lift(body_fill(key, body, 17, 22, 30, k=3, passes=4), body, '#dcb482', 330))
    st.blank_shade(body, holes)
    st.stitch(body, col=CHILI, skip=grow(holes, 3))
    feet(st, [19, 38], 48, w=6, h=3)
    # straw hat, cocked over the left side of the head; chili band = the uncommon accent
    brim = poly([(8, 22), (36, 18), (37, 21), (9, 25)])
    crown = poly([(14, 21), (16, 11), (22, 8), (28, 10), (31, 19)])
    st.part(brim, MAIZE, d=1, contour=True)
    st.part(crown, MAIZE, d=2, contour=True)
    st.paint(poly([(14, 17), (31, 15), (31, 19), (14, 21)]) & crown, CHILI)
    st.paint(line([(18, 12), (17, 16)]) & crown, MAIZE_D)
    st.paint(line([(24, 10), (25, 14)]) & crown, MAIZE_D)
    st.dots([(11, 25), (20, 24), (33, 22)], MAIZE_D)              # straw ends poking out
    # very serious face: flat lids, wedge beak
    st.eye(20, 28, look=(1, 0), lid=1)
    st.eye(32, 28, look=(1, 0), lid=1)
    st.sprite(['OOOOOO', '.OOOO.', '..OO..'], 26, 35, {'O': SQUASH}, solid=False)
    st.paint(rect(26, 35, 31, 35), '#b85a14')
    return key, st


# ------------------------------------------------------------------ 5. Golden Ring: inner-BBBB round, uncommon. Four-blank plaza piece wearing the paper-flag string, turquoise accent.
def golden_ring():
    key = 'mh-golden-ring'
    st = Sticker()
    core = (11, 15, 50, 49)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.8), e=('B', 'round', 0, 3.8), s=('B', 'round', 0, 3.8), w=('B', 'round', 0, 3.8))
    st.part(body, tex=lift(body_fill(key, body, 11, 15, 40, k=3, passes=3), body, '#e8dcb8', 330))
    st.blank_shade(body, holes)
    st.stitch(body, col=TURQ, skip=grow(holes, 3))
    feet(st, [15, 41], 50)
    # papel picado string across the chest: sagging cord + 5 flags
    cord = line([(11, 37), (20, 40), (30, 41), (40, 40), (50, 37)])
    st.paint(cord, UMBER2, solid=True)
    for i, (fx, fy, c) in enumerate(((13, 38, PINK), (21, 41, TURQ), (29, 42, MAIZE), (37, 41, PINK), (45, 39, TURQ))):
        fl = poly([(fx, fy), (fx + 5, fy), (fx + 5, fy + 4), (fx + 2.5, fy + 6), (fx, fy + 4)])
        st.part(fl, c, d=1, contour=True)
    st.eye(18, 24, look=(0, 1))
    st.eye(38, 24, look=(0, 1))
    st.mouth('smile', 28, 31)
    return key, st


# ------------------------------------------------------------------ 6. Popcorn Moon: whimsy-moon double, rare. Gold crescent (its cell recoloured to harvest moon), popcorn bursting, glow + sparkles.
def popcorn_moon():
    key = 'mh-popcorn-moon'
    st = Sticker()
    col, row = ROWS[key]['piece']
    moon = disc(35, 33, 19.5) & ~disc(47.5, 27, 14.5)
    tab = knob('w', 'double', 35, 16.5, r=3.0)
    body = moon | tab
    # the cell's own pixels, mapped by brightness onto the moon ramp so it still reads as a harvest moon
    src = pic.sample(col, row, 15, 13, 40).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(MAIZE)
    tex[src > 470] = hx(MAIZE_L)
    tex = majority(tex, body, 3)
    st.part(body, tex=tex, contour=True)
    st.stitch(moon)
    # popcorn bursting up out of the moon's cup: three fat puffs, cream with a squash-gold kernel hull
    for cx, cy in ((44, 24), (49, 16), (41, 11)):
        puff = disc(cx, cy, 2.8) | disc(cx + 2.6, cy + 1.4, 2.3) | disc(cx + 0.4, cy + 3, 2.3)
        st.part(puff, '#fff4dc', d=1, contour=True)
        st.dots([(cx + 1, cy + 3), (cx + 2, cy + 3)], SQUASH)
    st.eye(18, 27, look=(1, 0))
    st.eye(26, 29, look=(1, 0))
    st.mouth('smile', 21, 37)
    st.sparkle(51, 32)
    st.sparkle(51, 6, big=False)
    st.sparkle(10, 47, big=False)
    return key, st


PALS = [husk_hopper, cob_scout, kernel_knock, stitch_crow, golden_ring, popcorn_moon]

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
        print('%-20s %-9s %-11s %-6s colours %d margin %d' % (key, ROWS[key]['rarity'], ROWS[key]['shape'], ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
