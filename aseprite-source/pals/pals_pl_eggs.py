"""Puzzle Pals: PAINTED EGG HOUSE (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-eggs-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_eggs.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of an Eastern European folk-art cottage on a bright spring day. kit_lair parts used only as building
blocks (PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-painted-egg-house.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Painted Bough    spring leaf green       | a twig bough on top hung with 3 small painted eggs     | laughing ^ ^ eyes, big grin
  2 Dabbing Painter  gnome-hat red           | a pointed red hat, white beard, a brush with a wet dab | focused squint + one open eye, tongue out
  3 Spring Chick     chick yellow            | an orange beak, a fluff tuft, little wing flaps         | wide round eyes, 'o' cheep
  4 Fence Eggs       picket-sky blue (+ cream)| 4 striped eggs, one on each tab, picket rails          | sleepy calm lids, smile
  5 Wreath Hollow    wreath orange (+ green) | a woven wreath rim with leaves + a red ribbon bow below | shy, looks down, cat mouth, blush
  6 Pink Stripe Egg  egg pink                | whimsy egg body, zigzag folk stripes, red bow, glow    | huge grin, round happy eyes
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-painted-egg-house'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-painted-egg-house-abccd0')

LEAF = ('#5e9a3e', '#7ab44e')          # spring leaf green
HAT = ('#b83a2a', '#d0563a')           # gnome-hat red
CHICK = ('#e8c23a', '#f4dc6a')         # chick yellow
SKY = ('#6aa8c8', '#8fc4e1')           # picket-sky blue
WREATH = ('#d0742e', '#e8944a')        # wreath orange
PINK = ('#e88aa8', '#f4aec4')          # egg pink (rare)
TWIG = ('#7e4a2b', '#5a3420')
BEARD = ('#f2ece0', '#cfc6b4')
BEAK = ('#e8781f', '#b85a1a')
EGGCOLS = [('#d63a34', '#f2e4c0'), ('#3a6ab8', '#f4dc6a'), ('#f4dc6a', '#d63a34'), ('#5e9a3e', '#f2e4c0')]
GREEN = '#4a8a3a'
RIBBON = ('#c8302a', '#e85a4a')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def squint(st, x, y):
    st.sprite(['UUUUU', '.....'], x, y + 2, {'U': UMBER}, solid=False)


def small_egg(st, cx, cy, rx, ry, cols, stripe=True):
    m = ellipse(cx, cy, rx, ry)
    st.part(m, cols[0], d=1, contour=True)
    if stripe:
        st.paint(m & (abs(CY - cy) < 0.8) & shrink(m, 0), cols[1])
        st.paint(m & (abs(CY - (cy - ry * 0.55)) < 0.5) & ((XX % 2) == 0), cols[1])
    st.dots([(int(cx - rx * 0.4), int(cy - ry * 0.5))], '#ffffff')
    return m


def limbs(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


# ------------------------------------------------------------------ 1. Painted Bough: corner-TB round, common.
def painted_bough():
    key = 'pl-eggs-1'
    st = Sticker()
    core = (12, 26, 44, 51)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 12, 26, 33, list(LEAF)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c4e08a', skip=grow(holes, 3))
    # bough: a twig across the top with 3 dangling painted eggs
    tw = line([(8, 15), (28, 12), (52, 9)], w=2)
    st.part(tw, TWIG[0], d=1, contour=True)
    for i, (x, y) in enumerate(((14, 14), (36, 11), (50, 10))):
        st.paint(rect(x, y + 1, x, y + 3), TWIG[1], solid=True)
        small_egg(st, x, y + 7, 2.8, 3.8, EGGCOLS[i])
    closed_up(st, 18, 34)
    closed_up(st, 31, 34)
    st.mouth('grin', 24, 39)
    st.paint(rect(15, 38, 17, 38) | rect(36, 38, 38, 38), BLUSH)
    limbs(st, [15, 33], 51, '#3e6a2a')
    return key, st


# ------------------------------------------------------------------ 2. Dabbing Painter: edge-TTB peg, common.
def dabbing_painter():
    key = 'pl-eggs-2'
    st = Sticker()
    core = (14, 24, 44, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 0, 3.4), e=('T', 'peg', 2, 3.4), w=('B', 'peg', 2, 2.8))
    hat = poly([(15, 25), (29, 7), (43, 25)])
    st.part(hat, HAT[1], d=1, contour=True)
    st.paint(hat & (CX > 30) & shrink(hat, 0), HAT[0])
    st.part(body, tex=fill(key, body, 14, 24, 31, list(HAT)), contour=True)
    st.blank_shade(body, holes, width=1)
    beard = ellipse(29, 47, 9, 4.5) & (CY > 43)
    st.part(beard, BEARD[0], d=1, contour=True)
    st.paint(beard & (CY > 48), BEARD[1])
    st.stitch(body, col='#f2c4a0', skip=grow(holes, 3) | grow(beard, 1))
    squint(st, 19, 31)
    st.eye(31, 31, look=(1, 0))
    st.sprite(['UUUUU', '.URU.', '..R..'], 26, 38, {'U': UMBER, 'R': '#e86a6a'}, solid=False)   # tongue out, concentrating
    # brush: handle to the right, a wet blue dab at the tip
    br = line([(44, 46), (52, 32)], w=2)
    st.part(br, TWIG[0], d=1, contour=True)
    tip = disc(52.5, 29.5, 2.2)
    st.part(tip, '#3a6ab8', d=1, contour=True)
    st.paint(rect(55, 24, 56, 25), '#3a6ab8', solid=True)
    limbs(st, [17, 35], 51, '#5a2a1a')
    return key, st


# ------------------------------------------------------------------ 3. Spring Chick: inner-TBTB round, common.
def spring_chick():
    key = 'pl-eggs-3'
    st = Sticker()
    core = (14, 18, 46, 45)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', -4, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 18, 33, list(CHICK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#fff2b0', skip=grow(holes, 3))
    tuft = line([(29, 13), (28, 8)]) | line([(31, 13), (32, 7)]) | line([(33, 13), (35, 9)])
    st.paint(tuft, CHICK[0], solid=True)
    st.eye(20, 27)
    st.eye(36, 27)
    beak = poly([(27, 35), (35, 35), (31, 40)])
    st.part(beak, BEAK[0], d=1, contour=True)
    st.paint(beak & (CY > 37), BEAK[1])
    st.paint(rect(17, 35, 19, 35) | rect(42, 35, 44, 35), BLUSH)
    for wx in (16, 44):
        st.paint(ellipse(wx, 41, 2.5, 3.5) & body, '#d8a82a')
    limbs(st, [20, 37], 46, BEAK[0])
    return key, st


# ------------------------------------------------------------------ 4. Fence Eggs: inner-TTTT peg, uncommon.
def fence_eggs():
    key = 'pl-eggs-4'
    st = Sticker()
    core = (19, 20, 44, 44)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 18, 30, list(SKY)), contour=True)
    for py in (24, 41):                                          # picket rails, cream accent
        st.paint(rect(19, py, 44, py + 1) & shrink(body, 1), '#f2e4c0')
    st.stitch(body, col='#f2e4c0')
    for (cx, cy), cols in zip(((31.5, 12), (31.5, 52), (12, 32), (51, 32)), EGGCOLS):
        small_egg(st, cx, cy, 3.0, 3.8, cols)
    st.eye(23, 28, lid=2)
    st.eye(36, 28, lid=2)
    st.mouth('smile', 29, 36)
    st.paint(rect(20, 35, 22, 35) | rect(41, 35, 43, 35), BLUSH)
    return key, st


# ------------------------------------------------------------------ 5. Wreath Hollow: inner-BBBB round, uncommon.
def wreath_hollow():
    key = 'pl-eggs-5'
    st = Sticker()
    core = (11, 13, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(WREATH)), contour=True)
    rim = body & ~shrink(body, 3) & shrink(body, 0)
    st.paint(rim & ((XX + YY) % 4 == 0), '#a8521e')
    st.paint(rim & ((XX - YY) % 6 == 0), GREEN)                  # uncommon accent: wreath leaves
    st.blank_shade(body, holes, width=1)
    for lx, ly in ((15, 17), (48, 17), (15, 48), (48, 48)):
        st.paint(ellipse(lx, ly, 2.2, 1.4), GREEN, solid=True)
    st.eye(21, 25, look=(0, 1))
    st.eye(38, 25, look=(0, 1))
    st.paint(rect(18, 33, 20, 33) | rect(43, 33, 45, 33), BLUSH)
    st.mouth('cat', 29, 34)
    # red ribbon bow just above the south blank
    bow = poly([(25, 39), (31, 42), (25, 45)]) | poly([(38, 39), (32, 42), (38, 45)])
    st.part(bow, RIBBON[0], d=1, contour=True)
    st.paint(rect(30, 41, 33, 43), RIBBON[1], solid=True)
    return key, st


# ------------------------------------------------------------------ 6. Pink Stripe Egg: whimsy-egg round, rare.
def pink_stripe_egg():
    key = 'pl-eggs-6'
    st = Sticker()
    egg = ellipse(32, 31, 15, 16) & (CY > 18)
    egg |= ellipse(32, 28, 12.5, 13)
    tab = knob('s', 'round', 32, 46.5, r=3.0)
    body = egg | tab
    st.part(body, tex=fill(key, body, 14, 10, 40, list(PINK)), contour=True)
    # zigzag folk stripes
    for by, col in ((22, '#f2e4c0'), (38, '#c8302a')):
        zz = blank()
        for x in range(16, 48):
            y = by + (x % 4 if x % 8 < 4 else 4 - x % 4) - 2
            zz |= rect(x, y, x, y + 1)
        st.paint(zz & shrink(egg, 1), col)
    st.paint(shrink(egg, 1) & (abs(CY - 43) < 0.6) & (XX % 3 == 0), '#f2e4c0')
    st.eye(22, 25)
    st.eye(37, 25)
    st.mouth('grin', 29, 33)
    st.paint(rect(19, 32, 21, 32) | rect(42, 32, 44, 32), '#d0506a')
    # red bow on top
    bow = poly([(24, 10), (32, 14), (24, 18)]) | poly([(40, 10), (32, 14), (40, 18)])
    st.part(bow, RIBBON[0], d=1, contour=True)
    st.paint(bow & (CY < 13) & shrink(bow, 0), RIBBON[1])
    st.paint(rect(30, 12, 33, 16), RIBBON[1], solid=True)
    limbs(st, [14, 45], 36, PINK[0])
    st.sparkle(7, 7)
    st.sparkle(54, 20, big=False)
    st.sparkle(8, 46, big=False)
    return key, st


PALS = [painted_bough, dabbing_painter, spring_chick, fence_eggs, wreath_hollow, pink_stripe_egg]

if __name__ == '__main__':
    paths = []
    for fn in PALS:
        key, st = fn()
        tidy(st)
        assert key in ROWS, key
        p = os.path.join(OUTDIR, key + '.png')
        info = st.save(p, glow=(ROWS[key]['rarity'] == 'rare'))
        paths.append(p)
        print('%-10s %-17s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
