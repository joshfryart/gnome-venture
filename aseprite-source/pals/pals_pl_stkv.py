"""Puzzle Pals: STORK CHIMNEY VILLAGE (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-stkv-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_stkv.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: stork sprites, keyhole knobs, pink evening. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-stork-chimney-village.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Pink Dusk Lullaby     dusk rose pink              | crescent moon nightcap + tiny stork silhouette, two stars      | sleepy closed arcs, o yawn
  2 Airmail Parcel Sway   kraft parcel brown          | string loop up the top tab to a stork beak, twine cross        | wide eyes, small smile
  3 Sunflower Nodder      leaf sage green             | sunflower head nodding over the top, petal ring, leaves        | ^ ^ happy eyes, grin
  4 Bowtie Bundle         wrap cream (+ bow red)      | big red bow on top, ribbon cross, tails on side tabs           | eyes glancing up, cat mouth
  5 Lamplit Shutters      plaster lilac (+ shutter blue)| warm lit window in the middle, blue shutters both sides      | wink + lid, smirk
  6 Rooftop Courier       white stork + red-tile roof | whimsy stork perched on a tile ridge, parcel in beak, glow     | joyful lashes, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-stork-chimney-village'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-stork-chimney-village-fd6bb4')

DUSK = ('#c87a96', '#e4a2b6')          # dusk rose pink
KRAFT = ('#9a7048', '#b88c60')         # kraft parcel brown
SAGE = ('#7a9a5a', '#9ab878')          # leaf sage green
WRAP = ('#d8c49a', '#ece0bc')          # wrap cream (picture #ceba92)
LILAC = ('#807ea5', '#a09ec2')         # plaster lilac (picture #807ea5)
WHITE = ('#e4e4ea', '#fafafc')         # stork white (rare)
CREAM = '#fbf0dc'
RED = ('#c8343c', '#e2565a')
BLUE = ('#3a6ab0', '#5a8ad0')
TILE = ('#a8402c', '#c85a3c')
SUN = ('#f0c030', '#ffe070')
BEAK = '#e8783a'
BLACK = '#2a2430'
GOLD = ('#f0c84a', '#fff0a0')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def lash_eye(st, x, y):
    st.sprite(['U.U.U', '.UUU.', 'UUUUU', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def sleep_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def stork_head(st, x, y, d):
    """tiny stork in flight: white body, black wing, orange beak pointing d."""
    st.part(ellipse(x, y, 3, 1.6), WHITE[1], d=0, contour=True, shade=False)
    st.paint(rect(x - 1, y - 2, x + 1, y - 1), BLACK, solid=True)
    st.paint(rect(x + 3 * d, y, x + 4 * d, y) if d > 0 else rect(x - 4, y, x - 3, y), BEAK, solid=True)


# ------------------------------------------------------------------ 1. Pink Dusk Lullaby: corner-TB keyhole, common.
def pink_dusk_lullaby():
    key = 'pl-stkv-1'
    st = Sticker()
    core = (12, 18, 48, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', -4, 3.6), e=('B', 'keyhole', 4, 3.0))
    st.part(body, tex=fill(key, body, 12, 9, 46, list(DUSK)), contour=True)
    st.blank_shade(body, holes, width=1)
    moon = disc(40, 13, 5) & ~disc(43, 11, 4.2)
    st.part(moon, GOLD[0], d=1, contour=True)
    st.part(ellipse(21, 24, 5, 2.4), WHITE[1], d=0, contour=True)
    st.paint(rect(18, 21, 23, 22), BLACK, solid=True)
    st.paint(rect(26, 24, 29, 24), BEAK, solid=True)
    st.paint(rect(15, 25, 17, 25), BEAK, solid=True)
    for x, y in ((40, 24), (22, 47)):
        st.dots([(x, y), (x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)], GOLD[1])
    sleep_eye(st, 20, 33)
    sleep_eye(st, 35, 33)
    st.paint(rect(18, 38, 20, 38) | rect(41, 38, 43, 38), BLUSH)
    st.mouth('o', 30, 40)
    return key, st


# ------------------------------------------------------------------ 2. Airmail Parcel Sway: edge-BTB keyhole, common.
def airmail_parcel_sway():
    key = 'pl-stkv-2'
    st = Sticker()
    core = (14, 24, 46, 53)
    body, holes = piece_blanks(core, s='F', n=('B', 'keyhole', 0, 3.0), e=('T', 'keyhole', 3, 3.6), w=('B', 'keyhole', 3, 3.0))
    st.part(body, tex=fill(key, body, 12, 16, 40, list(KRAFT)), contour=True)
    st.blank_shade(body, holes, width=1)
    tw = (rect(29, 24, 30, 53) | rect(12, 44, 47, 45)) & body & ~grow(holes, 1)
    st.paint(tw, CREAM)
    st.part(line([(26, 25), (30, 14), (34, 25)], w=1), CREAM, d=0, contour=True, shade=False)
    # stork beak gripping the string
    st.part(ellipse(36, 8, 5, 3), WHITE[1], d=0, contour=True)
    st.paint(rect(36, 5, 40, 6), BLACK, solid=True)
    st.part(line([(31, 10), (28, 13)], w=1) | rect(28, 13, 32, 14), BEAK, d=0, contour=True, shade=False)
    st.dots([(34, 7)], BLACK)
    st.eye(17, 32)
    st.eye(36, 32)
    st.mouth('smile', 27, 39)
    return key, st


# ------------------------------------------------------------------ 3. Sunflower Nodder: inner-TBTB keyhole, common.
def sunflower_nodder():
    key = 'pl-stkv-3'
    st = Sticker()
    core = (15, 20, 48, 49)
    body, holes = piece_blanks(core, n=('T', 'keyhole', -5, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 5, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 12, 36, list(SAGE)), contour=True)
    st.blank_shade(body, holes, width=1)
    petals = None
    for dx, dy in ((0, -5), (4, -3), (5, 1), (3, 5), (-3, 5), (-5, 1), (-4, -3), (0, 6)):
        p = disc(40 + dx, 15 + dy, 2.4)
        petals = p if petals is None else petals | p
    st.part(petals, SUN[0], d=1, contour=True)
    st.part(disc(40, 16, 3), '#6a4020', d=1, contour=True)
    st.dots([(39, 15), (41, 17)], '#3a2010')
    st.paint(ellipse(18, 44, 3, 1.5) | ellipse(45, 44, 3, 1.5), SAGE[1])
    happy_eye(st, 19, 28)
    happy_eye(st, 34, 28)
    st.mouth('grin', 26, 36)
    return key, st


# ------------------------------------------------------------------ 4. Bowtie Bundle: inner-TTTT keyhole, uncommon.
def bowtie_bundle():
    key = 'pl-stkv-4'
    st = Sticker()
    core = (18, 20, 45, 47)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 19, 30, list(WRAP)), contour=True)
    st.paint((rect(31, 8, 32, 56) | rect(8, 38, 55, 39)) & body, RED[0])   # uncommon accent: bow red ribbon
    bow = ellipse(26, 16, 4.5, 3) | ellipse(37, 16, 4.5, 3)
    st.part(bow, RED[0], d=1, contour=True)
    st.paint(ellipse(26, 16, 2, 1) | ellipse(37, 16, 2, 1), RED[1])
    st.part(disc(31.5, 16.5, 1.8), RED[1], d=1, contour=True)
    st.eye(23, 27, look=(0, -1))
    st.eye(36, 27, look=(0, -1))
    st.paint(rect(21, 34, 23, 34) | rect(40, 34, 42, 34), BLUSH)
    st.mouth('cat', 30, 33)
    return key, st


# ------------------------------------------------------------------ 5. Lamplit Shutters: inner-BBBB double, uncommon.
def lamplit_shutters():
    key = 'pl-stkv-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(LILAC)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.part(rect(25, 30, 38, 45), SUN[1], d=1, contour=True)
    st.paint(rect(25, 37, 38, 37) | rect(31, 30, 32, 45), SUN[0])
    for x in (18, 40):
        st.part(rect(x, 30, x + 5, 45), BLUE[0], d=1, contour=True)
        for y in (32, 35, 38, 41):
            st.paint(rect(x + 1, y, x + 4, y), BLUE[1])
    wink(st, 21, 20)
    st.eye(37, 19, lid=1)
    st.mouth('smirk', 29, 25)
    return key, st


# ------------------------------------------------------------------ 6. Rooftop Courier: whimsy-whitestork keyhole, rare.
def rooftop_courier():
    key = 'pl-stkv-6'
    st = Sticker()
    roof = poly([(13, 54), (32, 45), (51, 54)])
    st.part(roof, TILE[0], d=0, contour=True)
    for y in (48, 51):
        st.paint(rect(13, y, 51, y) & roof, TILE[1])
    legs = line([(30, 38), (30, 46)], w=1) | line([(36, 38), (36, 46)], w=1)
    st.part(legs, BEAK, d=0, contour=True, shade=False)
    bodyb = ellipse(34, 33, 11, 7)
    head = disc(24, 17, 6.5)
    nk = line([(27, 28), (25, 20)], w=4)
    tab = knob('e', 'keyhole', 45, 33, r=3.0)
    sil = bodyb | nk | head | tab
    st.part(sil, tex=fill(key, sil, 13, 9, 40, list(WHITE)), contour=True)
    st.paint(ellipse(39, 32, 8, 4) & bodyb & (YY > 31), BLACK)
    beak = poly([(17, 17), (9, 21), (17, 20)])
    st.part(beak, BEAK, d=0, contour=True, shade=False)
    # parcel dangling from beak
    st.part(line([(11, 21), (11, 24)]), CREAM, d=0, contour=False, shade=False)
    st.part(rect(7, 25, 15, 31), KRAFT[0], d=1, contour=True)
    st.paint(rect(11, 25, 11, 31) | rect(7, 28, 15, 28), RED[0])
    lash_eye(st, 22, 13)
    st.paint(rect(26, 20, 28, 20), BLUSH)
    st.sparkle(49, 10)
    st.sparkle(8, 8, big=False)
    st.sparkle(52, 42, big=False)
    return key, st

PALS = [pink_dusk_lullaby, airmail_parcel_sway, sunflower_nodder, bowtie_bundle, lamplit_shutters, rooftop_courier]

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
