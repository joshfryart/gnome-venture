"""Puzzle Pals: GORILLA GLADE (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wgor-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wgor.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: glade sprites, keyhole knobs, misty green morning. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell
of game/assets/img/jigsaw/places/wonder-gorilla-glade.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Marmalade Treetop     marmalade orange            | leafy green crown on top dotted with orange fruit, trunk below | wide bright eyes, open grin
  2 Peekaboo Pipsqueak    sooty charcoal              | baby gorilla face, big round ears, mum's shoulder hump behind   | huge shy look-aside eyes, o mouth
  3 Rainbow Fruit Tumble  meadow grass green          | heap of pink/blue/gold/orange fruit on its belly, grass tufts   | ^ ^ happy eyes, cat mouth
  4 Sunbeam Staircase     misty pale gold (+ leaf)    | diagonal beam steps across body, dust-mote dots on each tab     | sleepy half-lids, small smile
  5 Orange Offering       palm leather tan (+ orange) | big cupped hand below holding an orange with a leaf             | one wink, smirk
  6 Frowny Silverback     slate gorilla + silver back | whimsy silverback, stern brow, fruit held out, glow + sparkles   | stern-brow eyes, flat mouth, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-gorilla-glade'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-gorilla-glade-90c244')

MARM = ('#d8782a', '#f0984a')          # marmalade orange
SOOT = ('#3a3a40', '#56565e')          # sooty charcoal
GRASS = ('#4a8a3a', '#68a84e')         # meadow grass
MIST = ('#e4dc9a', '#f4eec0')          # misty sunbeam gold
PALM = ('#8a6248', '#a87e5e')          # palm leather
SLATE = ('#3c4250', '#565e70')         # silverback slate (rare)
LEAF = ('#386732', '#5a9241', '#26281f')
ORANGE = ('#f08a1e', '#ffb64a')
SILVER = ('#b8bcc4', '#dfe2e8')
FACE = ('#7a6a68', '#9a8a84')
BLUSH = '#e89a9a'
FRUITS = ('#e85a8a', '#5a8ae8', '#f0c84a', '#f08a1e', '#a85ad8')


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['.....', 'UUUUU', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def stern_eye(st, x, y, side):
    brow = ['UUU..', '..UUU'] if side < 0 else ['..UUU', 'UUU..']
    st.sprite(brow, x, y, {'U': UMBER}, solid=False)
    st.sprite(['.WW.', 'WUUW', '.WW.'], x, y + 3, {'U': UMBER, 'W': CREAM}, solid=False)


def big_eye(st, x, y, look):
    st.sprite(['.UUUU.', 'UWWWWU', 'UWWWWU', 'UWWWWU', '.UUUU.'], x, y, {'U': UMBER, 'W': CREAM}, solid=False)
    px = x + 2 + look
    st.paint(rect(px, y + 1, px + 1, y + 3), UMBER, solid=True)
    st.dots([(px, y + 1)], '#ffffff')


def fruit(st, x, y, col, r=2.0):
    st.part(disc(x, y, r), col, d=1, contour=True)
    st.dots([(int(x) - 1, int(y) - 1)], '#fff4d0')


# ------------------------------------------------------------------ 1. Marmalade Treetop: corner-TT keyhole, common.
def marmalade_treetop():
    key = 'pl-wgor-1'
    st = Sticker()
    core = (12, 22, 46, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 2, 3.6))
    crown = disc(22, 17, 6) | disc(31, 14, 7) | disc(40, 17, 6) | rect(16, 17, 44, 23)
    st.part(crown, LEAF[0], d=1, contour=True)
    st.paint(disc(31, 12, 3.5) | disc(22, 15, 2.5), LEAF[1])
    st.part(body, tex=fill(key, body, 12, 12, 42, list(MARM)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x, y in ((19, 16), (27, 11), (35, 13), (41, 18), (25, 19)):
        fruit(st, x, y, ORANGE[0], 1.6)
    st.part(rect(27, 48, 33, 53), '#6a4428', d=0, contour=False, shade=False)
    st.eye(18, 29)
    st.eye(33, 29)
    st.paint(rect(16, 37, 18, 37) | rect(40, 37, 42, 37), BLUSH)
    st.mouth('grin', 25, 37)
    return key, st


# ------------------------------------------------------------------ 2. Peekaboo Pipsqueak: edge-TTB keyhole, common.
def peekaboo_pipsqueak():
    key = 'pl-wgor-2'
    st = Sticker()
    core = (14, 22, 46, 53)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 4, 3.6), w=('B', 'keyhole', 4, 3.0))
    hump = ellipse(46, 22, 9, 6) & ~rect(0, 0, 63, 14)
    st.part(hump & ~grow(body, 0), '#26281f', d=0, contour=True, shade=False)
    st.part(body, tex=fill(key, body, 14, 14, 40, list(SOOT)), contour=True)
    st.blank_shade(body, holes, width=1)
    for ex in (14, 46):
        st.part(disc(ex, 30, 3.2), SOOT[1], d=1, contour=True)
        st.paint(disc(ex, 30, 1.4), FACE[0])
    st.part(ellipse(30, 36, 11, 9), FACE[1], d=1, contour=True)
    big_eye(st, 20, 29, 1)
    big_eye(st, 33, 29, 1)
    st.dots([(28, 39), (31, 39)], UMBER)
    st.mouth('o', 28, 42)
    return key, st


# ------------------------------------------------------------------ 3. Rainbow Fruit Tumble: inner-TBTB keyhole, common.
def rainbow_fruit_tumble():
    key = 'pl-wgor-3'
    st = Sticker()
    core = (14, 16, 49, 47)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 8, 36, list(GRASS)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x in range(18, 46, 5):
        st.paint(line([(x, 47), (x + 1, 44)]) & body & ~grow(holes, 1), LEAF[1])
    pts = ((22, 41), (27, 42), (32, 41), (37, 42), (42, 41), (25, 37), (30, 37), (35, 37), (40, 37), (32, 33))
    for i, (x, y) in enumerate(pts):
        fruit(st, x, y, FRUITS[i % 5], 2.0)
    happy_eye(st, 20, 22)
    happy_eye(st, 38, 22)
    st.mouth('cat', 30, 27)
    return key, st


# ------------------------------------------------------------------ 4. Sunbeam Staircase: inner-TTTT double, uncommon.
def sunbeam_staircase():
    key = 'pl-wgor-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(MIST)), contour=True)
    for k in range(3):
        y = 34 + k * 3
        st.paint(rect(20 + k * 0, y, 43, y) & body & (((XX + YY) // 2) % 2 == 0), '#fffbe0')
    st.stitch(body, col=LEAF[1])                                    # uncommon accent: leaf green
    for x, y in ((31, 10), (32, 53), (10, 31), (53, 32), (29, 12), (34, 51)):
        st.dots([(x, y)], '#fff3a0')
    st.eye(22, 24, lid=2)
    st.eye(36, 24, lid=2)
    st.mouth('smile', 29, 30)
    return key, st


# ------------------------------------------------------------------ 5. Orange Offering: inner-BBBB keyhole, uncommon.
def orange_offering():
    key = 'pl-wgor-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(PALM)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=ORANGE[1], skip=grow(holes, 3))              # uncommon accent: orange
    hand = ellipse(31.5, 42, 12, 5) | disc(21, 38, 3) | disc(42, 38, 3)
    st.part(hand, '#3a3438', d=1, contour=True)
    st.paint(ellipse(31.5, 41, 8, 2.5), '#6a5a5a')
    st.part(disc(31.5, 35, 4.5), ORANGE[0], d=1, contour=True)
    st.dots([(30, 33)], '#fff4d0')
    st.part(ellipse(34, 29.5, 2.5, 1.2), LEAF[1], d=0, contour=True, shade=False)
    wink(st, 18, 18)
    st.eye(38, 17)
    st.mouth('smirk', 28, 25)
    return key, st


# ------------------------------------------------------------------ 6. Frowny Silverback: whimsy-gorilla keyhole, rare.
def frowny_silverback():
    key = 'pl-wgor-6'
    st = Sticker()
    torso = ellipse(32, 39, 16, 12)
    head = ellipse(32, 19, 9, 8) | ellipse(32, 13, 5, 3)
    arms = disc(15, 45, 4.5) | disc(49, 45, 4.5)
    tab = knob('s', 'keyhole', 32, 47, r=3.0)
    sil = torso | head | arms | tab
    st.part(sil, tex=fill(key, sil, 9, 4, 50, list(SLATE)), contour=True)
    st.paint(ellipse(32, 30, 13, 3) & torso, SILVER[0])
    st.paint(ellipse(32, 29, 10, 1.5) & torso, SILVER[1])
    st.paint(ellipse(32, 42, 9, 7), SLATE[1])
    st.part(ellipse(32, 22, 7, 5), FACE[0], d=1, contour=True)
    st.paint(rect(24, 15, 40, 16), '#26262c')
    stern_eye(st, 25, 15, -1)
    stern_eye(st, 35, 15, 1)
    st.dots([(30, 22), (33, 22)], UMBER)
    st.mouth('flat', 30, 25)
    st.paint(rect(24, 23, 25, 23) | rect(38, 23, 39, 23), BLUSH)
    fruit(st, 49, 41, ORANGE[0], 3.0)
    st.part(ellipse(51, 37.5, 2, 1), LEAF[1], d=0, contour=True, shade=False)
    st.sparkle(8, 10)
    st.sparkle(54, 10, big=False)
    st.sparkle(9, 54, big=False)
    return key, st


PALS = [marmalade_treetop, peekaboo_pipsqueak, rainbow_fruit_tumble, sunbeam_staircase, orange_offering, frowny_silverback]

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
        print('%-10s %-19s %-9s %-14s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                   ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
