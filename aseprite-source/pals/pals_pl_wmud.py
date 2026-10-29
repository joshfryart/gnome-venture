"""Puzzle Pals: MUD MOSQUE LIBRARY (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wmud-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wmud.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: library sprites, keyhole knobs, clear day. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-mud-mosque-library.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Onion Dome Daydream    turquoise tile              | blue onion dome cap with gold finial + thought rain cloud      | dreamy half-lids, o mouth
  2 Wobbly Bookpile        leather oxblood             | three tilted books stacked on top tied with string             | worried eyes glancing aside, wobbly flat mouth
  3 Candy Minaret          mud-brick tan               | pink candy bands around, little balcony + crescent tip on top   | ^ ^ happy eyes, grin
  4 Rainbow Spine Shelves  shelf walnut (+ rainbow)    | rainbow book spines on a shelf, scroll on each tab             | eyes looking up, cat mouth
  5 Cobalt Peekhole        pale plaster (+ cobalt)     | round cobalt-trimmed window in the middle, wall studs           | wink + one eye, smirk
  6 Slowpage Tortoise      olive tortoise + tile shell | whimsy tortoise in round spectacles, scroll in hand, glow      | eyes behind specs, smile, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-mud-mosque-library'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-mud-mosque-library-e5856f')

TURQ = ('#3a9aa8', '#62bec6')          # turquoise tile
OXB = ('#7a2e2e', '#9c4a40')           # leather oxblood
MUD = ('#b08a56', '#caaa6e')           # mud brick tan
WAL = ('#5a3a28', '#74432e')           # shelf walnut
PLAS = ('#d8c6a0', '#ecdcb8')          # pale plaster
OLIVE = ('#6a8a3a', '#8aa852')         # tortoise olive
COBALT = ('#22488e', '#4a70b8')
GOLD = ('#e0b040', '#fff0a0')
CANDY = '#e87a9a'
CREAM = '#fbf0dc'
BLUSH = '#f0a0a0'
RAIN = '#8ac8f0'
SPINES = ['#d84a4a', '#f0a040', '#f0d850', '#5ab85a', '#4a8ad8', '#9a5ac8']


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['.....', 'UUUUU', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def wobble_mouth(st, x, y):
    st.sprite(['.U...U.', 'U.U.U.U'], x, y, {'U': UMBER}, solid=False)


def scroll(st, x, y, vertical=False):
    lo = lambda v: int(v - 3.5) if v % 1 else v - 3  # noqa: E731
    hi = lambda v: int(v + 3.5) if v % 1 else v + 3  # noqa: E731
    x, y = (x, y) if not vertical else (x, y)
    if vertical:
        x = int(x)
        r = rect(x - 1, lo(y), x + 1, hi(y))
        ends = rect(x - 2, lo(y), x + 2, lo(y)) | rect(x - 2, hi(y), x + 2, hi(y))
    else:
        y = int(y)
        r = rect(lo(x), y - 1, hi(x), y + 1)
        ends = rect(lo(x), y - 2, lo(x), y + 2) | rect(hi(x), y - 2, hi(x), y + 2)
    st.part(r, CREAM, d=0, contour=True, shade=False)
    st.paint(ends, '#a07a4a', solid=True)


# ------------------------------------------------------------------ 1. Onion Dome Daydream: corner-BB keyhole, common.
def onion_dome_daydream():
    key = 'pl-wmud-1'
    st = Sticker()
    core = (12, 24, 48, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', 4, 3.0), e=('B', 'keyhole', 3, 3.0))
    dome = ellipse(30, 22, 15, 9) & (YY <= 24)
    dome |= line([(30, 13), (30, 9)], w=2)
    st.part(dome & ~holes, COBALT[0], d=1, contour=True)
    st.paint(ellipse(25, 18, 3, 2) & dome, COBALT[1])
    st.part(rect(29, 6, 31, 9), GOLD[0], d=0, contour=True, shade=False)
    st.part(body, tex=fill(key, body, 12, 15, 40, list(TURQ)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x in range(15, 47, 6):
        st.paint(rect(x, 49, x + 2, 50) & body, CREAM)
    # thought cloud + rain
    cl = disc(51, 12, 3.4) | disc(55, 11, 3) | disc(48, 13, 2.4)
    st.part(cl, '#e8f0f8', d=1, contour=True)
    st.dots([(49, 18), (53, 19), (56, 17)], RAIN)
    st.dots([(44, 19)], '#e8f0f8')
    st.eye(20, 32, lid=2)
    st.eye(35, 32, lid=2)
    st.mouth('o', 29, 41)
    return key, st


# ------------------------------------------------------------------ 2. Wobbly Bookpile: edge-TTB keyhole, common.
def wobbly_bookpile():
    key = 'pl-wmud-2'
    st = Sticker()
    core = (12, 25, 46, 54)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 3, 3.6), w=('B', 'keyhole', 3, 3.0))
    books = [((20, 18, 40, 21), '#4a8ad8'), ((22, 14, 38, 17), '#5ab85a'), ((25, 10, 36, 13), '#f0a040')]
    for (a, b, c, d), col in books:
        bk = rect(a, b, c, d)
        st.part(bk, col, d=1, contour=True)
        st.paint(rect(a + 1, b + 1, c - 1, b + 1), CREAM)
    st.part(body, tex=fill(key, body, 12, 16, 40, list(OXB)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(30, 10, 30, 24), '#d8c090', solid=True)     # string
    st.stitch(body, col='#d8b070', skip=grow(holes, 3))
    st.eye(19, 32, look=(-1, 0))
    st.eye(34, 32, look=(-1, 0))
    wobble_mouth(st, 26, 41)
    return key, st


# ------------------------------------------------------------------ 3. Candy Minaret: inner-TBTB keyhole, common.
def candy_minaret():
    key = 'pl-wmud-3'
    st = Sticker()
    core = (15, 19, 49, 47)
    body, holes = piece_blanks(core, n=('T', 'keyhole', -5, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 5, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 9, 40, list(MUD)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (22, 37, 43):
        st.paint(rect(15, y, 49, y + 1) & body & ~grow(holes, 1), CANDY)
    # little balcony + crescent tip atop the north tab
    st.part(rect(23, 11, 29, 12), '#8a6a3a', d=0, contour=True, shade=False)
    st.paint(disc(26, 8, 1.8) & ~disc(27, 7.4, 1.4), GOLD[0], solid=True)
    happy_eye(st, 21, 27)
    happy_eye(st, 37, 27)
    st.mouth('grin', 30, 32)
    return key, st


# ------------------------------------------------------------------ 4. Rainbow Spine Shelves: inner-TTTT double, uncommon.
def rainbow_spine_shelves():
    key = 'pl-wmud-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(WAL)), contour=True)
    st.paint(rect(20, 38, 43, 38), '#3a2418', solid=True)
    for i, col in enumerate(SPINES):
        x = 20 + i * 4
        st.paint(rect(x, 39, x + 2, 43), col, solid=True)   # uncommon accent: rainbow spines
    for i, col in enumerate(SPINES):
        x = 20 + i * 4
        st.paint(rect(x, 20, x + 2, 22), SPINES[5 - i], solid=True)
    scroll(st, 31.5, 10)
    scroll(st, 31.5, 53)
    scroll(st, 10, 31.5, vertical=True)
    scroll(st, 53, 31.5, vertical=True)
    st.eye(23, 26, look=(0, -1))
    st.eye(36, 26, look=(0, -1))
    st.mouth('cat', 29, 33)
    return key, st


# ------------------------------------------------------------------ 5. Cobalt Peekhole: inner-BBBB keyhole, uncommon.
def cobalt_peekhole():
    key = 'pl-wmud-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(PLAS)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=COBALT[1], skip=grow(holes, 3))   # uncommon accent: cobalt
    win = disc(31.5, 36, 8)
    st.part(win, COBALT[0], d=1, contour=True)
    st.paint(disc(31.5, 36, 5.5), '#1a2a48', solid=True)
    st.paint(rect(31, 29, 32, 43) | rect(25, 35, 38, 36), COBALT[1], solid=True)
    for x, y in ((18, 18), (45, 18), (18, 45), (45, 45)):
        st.dots([(x, y)], '#74432e')
    wink(st, 21, 18)
    st.eye(36, 18)
    st.mouth('smirk', 27, 25)
    return key, st


# ------------------------------------------------------------------ 6. Slowpage Tortoise: whimsy-tortoise keyhole, rare.
def slowpage_tortoise():
    key = 'pl-wmud-6'
    st = Sticker()
    legs = disc(20, 45, 3.2) | disc(41, 45, 3.2)
    st.part(legs, OLIVE[0], d=0, contour=True, shade=False)
    shell = ellipse(32, 36, 16, 10) & (YY <= 44)
    head = disc(15, 30, 6.5)
    tab = knob('e', 'keyhole', 49, 38, r=3.0)
    sil = shell | tab
    st.part(sil, tex=fill(key, sil, 15, 24, 40, list(TURQ)), contour=True)
    st.part(rect(16, 42, 48, 45), '#d8c090', d=1, contour=True)
    for cx, cy in ((26, 33), (36, 33), (31, 39)):
        st.paint(disc(cx, cy, 2.6) & shell, COBALT[1])
        st.dots([(cx, cy)], GOLD[0])
    st.part(head, tex=fill(key, head, 8, 23, 14, list(OLIVE)), contour=True)
    # spectacles
    st.paint(disc(12, 28, 2.6) & ~disc(12, 28, 1.6), GOLD[0], solid=True)
    st.paint(disc(18, 28, 2.6) & ~disc(18, 28, 1.6), GOLD[0], solid=True)
    st.dots([(15, 28)], GOLD[0])
    st.dots([(12, 28), (18, 28)], UMBER)
    st.mouth('smile', 13, 32)
    st.paint(rect(10, 31, 11, 31) | rect(19, 31, 20, 31), BLUSH)
    scroll(st, 15, 44, vertical=True)
    st.sparkle(26, 14)
    st.sparkle(52, 14, big=False)
    st.sparkle(55, 55, big=False)
    return key, st


PALS = [onion_dome_daydream, wobbly_bookpile, candy_minaret, rainbow_spine_shelves, cobalt_peekhole, slowpage_tortoise]

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
        print('%-10s %-22s %-9s %-15s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                   ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
