"""Puzzle Pals: STONE HEAD WATCHERS (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wsto-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wsto.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: sunny headland sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-stone-head-watchers.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Cherry Topper       cherry red                  | tall red cap band on top with a green moss-hair fringe          | wide bright eyes, toothy grin
  2 Roll-Away Seed      seed gold                   | grass tuft underfoot + whoosh speed lines, a little stalk       | dizzy side-glance, o mouth
  3 Noon Sunwink        pale sun yellow             | ring of short sun rays round the top, a cloud wisp              | wink + happy arc, wide smile
  4 Eyebrow Row         sea teal (+ stone grey)     | a row of three tiny carved heads across the belly               | both brows raised high, flat mouth
  5 Round-Eyed Peeker   headland grass (+ sky)      | carved long nose + big round carved eye rims, grass blades      | huge round eyes glancing left, small smile
  6 Blinkseed Stonehead stone grey, red cap         | whimsy moai head, red cap, mossy top, gold seed on its lip, glow| one eye blinking closed, carved pout
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-stone-head-watchers'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-stone-head-watchers-88f47d')

CHERRY = ('#c23a34', '#dc5a4a')
SEEDG = ('#d49a2a', '#ecc050')
SUNY = ('#f0d870', '#faeca0')
SEA = ('#3a8a9a', '#5aa8b4')
GRASS = ('#6aa84e', '#8ac464')
STONE = ('#6a6a70', '#8a8a90')
STONE_D = '#4a4a52'
MOSSG = ('#7ab55c', '#9ad070')
SKY = '#a8d8ee'
SEEDP = ('#e8a317', '#b07a10', '#fff3c8')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_arc(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def seed(st, cx, cy, r=2.6):
    m = disc(cx, cy, r)
    st.part(m, SEEDP[0], d=1, contour=True)
    st.dots([(int(cx - 1), int(cy - 1))], SEEDP[2])
    return m


def mini_head(st, x, y):
    """A tiny carved stone head, 5 wide 7 tall: grey block, moss top, dark brow + nose."""
    st.paint(rect(x, y, x + 4, y + 6), STONE[1], solid=True)
    st.paint(rect(x, y, x + 4, y), MOSSG[0], solid=True)
    st.paint(rect(x, y + 2, x + 4, y + 2), STONE_D, solid=True)
    st.paint(rect(x + 2, y + 3, x + 2, y + 5), STONE_D, solid=True)
    st.paint(rect(x + 4, y + 1, x + 4, y + 6), STONE[0], solid=True)


# 1. Cherry Topper: corner-TT keyhole, common.
def cherry_topper():
    key = 'pl-wsto-1'
    st = Sticker()
    core = (12, 22, 46, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', -3, 3.6), e=('T', 'keyhole', 2, 3.6))
    st.part(body, tex=fill(key, body, 12, 12, 42, list(CHERRY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(body & (YY >= 22) & (YY <= 25), '#8a2420')
    fringe = body & (YY >= 26) & (YY <= 27) & ((XX % 3) != 0)
    st.paint(fringe, MOSSG[0])
    st.paint(body & (YY == 26) & ((XX % 3) == 1), MOSSG[1])
    st.paint(rect(14, 21, 44, 21) & body, '#f08a70')
    st.eye(19, 32)
    st.eye(34, 32)
    st.mouth('tooth', 26, 42)
    st.paint(rect(15, 40, 17, 40) | rect(41, 40, 43, 40), BLUSH)
    return key, st


# 2. Roll-Away Seed: edge-TBB keyhole, common.
def roll_away_seed():
    key = 'pl-wsto-2'
    st = Sticker()
    core = (15, 22, 47, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 12, 38, list(SEEDG)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a8721a', skip=grow(holes, 3))
    for y in (28, 34, 40):                               # whoosh lines trailing left
        st.paint(rect(5, y, 9, y), CREAM)
        st.extra |= rect(5, y, 9, y)
    for x in (14, 20, 26, 34, 40, 46):                   # grass tuft underfoot
        st.part(poly([(x, 55), (x + 1.5, 50), (x + 3, 55)]), GRASS[0], d=0, contour=True, shade=False)
    st.eye(22, 30, look=(1, 0))
    st.eye(34, 30, look=(1, 0))
    st.mouth('o', 29, 39)
    return key, st


# 3. Noon Sunwink: inner-TBTB keyhole, common.
def noon_sunwink():
    key = 'pl-wsto-3'
    st = Sticker()
    core = (14, 18, 49, 48)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 10, 36, list(SUNY)), contour=True)
    st.blank_shade(body, holes, width=1)
    for (x, y) in ((8, 10), (52, 10), (8, 52), (53, 52)):   # sun rays at the corners
        r = rect(x, y, x + 2, y + 2)
        st.part(r, '#f5b440', d=0, contour=True, shade=False)
    cloud = ellipse(44, 44, 5, 2.2) | disc(41, 42, 2.2)
    st.part(cloud, '#f4f8f8', d=0, contour=True, shade=False)
    wink(st, 21, 27)
    happy_arc(st, 36, 28)
    st.mouth('grin', 29, 35)
    st.paint(rect(18, 34, 20, 34) | rect(43, 34, 45, 34), BLUSH)
    return key, st


# 4. Eyebrow Row: inner-TTTT double, uncommon.
def eyebrow_row():
    key = 'pl-wsto-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(SEA)), contour=True)
    st.stitch(body, col=STONE[1])
    for x in (21, 29, 37):
        mini_head(st, x, 36)
    st.eye(22, 24)
    st.eye(37, 24)
    st.paint(line([(21, 20), (24, 19), (27, 20)]) | line([(36, 20), (39, 19), (42, 20)]), UMBER)
    st.mouth('flat', 31, 31)
    return key, st


# 5. Round-Eyed Peeker: inner-TTBB keyhole, uncommon.
def round_eyed_peeker():
    key = 'pl-wsto-5'
    st = Sticker()
    core = (13, 16, 47, 49)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 13, 10, 40, list(GRASS)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=SKY, skip=grow(holes, 3))
    for cx in (23, 38):
        st.paint(disc(cx, 28, 5.5) & ~disc(cx, 28, 4.2), STONE_D)
        st.paint(disc(cx, 28, 4.2), CREAM, solid=True)
        st.paint(disc(cx - 1.5, 28, 2), UMBER, solid=True)
        st.dots([(cx - 2, 27)], '#ffffff')
    st.paint(rect(30, 26, 31, 37), STONE_D)
    st.paint(rect(29, 37, 32, 37), STONE_D)
    st.mouth('smile', 28, 41)
    return key, st


# 6. Blinkseed Stonehead: whimsy-stonehead keyhole, rare.
def blinkseed_stonehead():
    key = 'pl-wsto-6'
    st = Sticker()
    head = rect(19, 18, 44, 50) & ~(disc(19, 18, 3) & (XX < 19)) & ellipse(31.5, 34, 13.5, 20)
    tab = knob('s', 'keyhole', 31, 50, r=3.0)
    sil = head | tab
    st.part(sil, tex=fill(key, sil, 15, 14, 36, list(STONE)), contour=True)
    st.paint(head & (YY <= 18), MOSSG[0])
    cap = rect(21, 7, 42, 14)
    st.part(cap, '#c8402e', d=1, contour=True)
    st.paint(rect(22, 8, 41, 8), '#f07a60')
    st.paint(rect(22, 9, 23, 13), '#e0604a')
    st.paint(rect(18, 23, 45, 24) & head, STONE_D)
    st.eye(22, 26)
    st.paint(rect(36, 29, 41, 29), UMBER)              # the blink
    st.paint(rect(36, 28, 36, 28) | rect(41, 28, 41, 28), UMBER)
    st.paint(rect(31, 25, 32, 37), STONE_D)
    st.paint(rect(27, 41, 36, 42), STONE_D)
    st.paint(rect(28, 41, 35, 41), MOUTH_RED)
    seed(st, 40, 46, 2.6)
    st.paint(rect(17, 37, 19, 37) | rect(44, 37, 46, 37), BLUSH)
    st.sparkle(6, 6)
    st.sparkle(52, 20, big=False)
    st.sparkle(9, 44, big=False)
    return key, st


PALS = [cherry_topper, roll_away_seed, noon_sunwink, eyebrow_row, round_eyed_peeker, blinkseed_stonehead]

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
        print('%-10s %-19s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                   ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
