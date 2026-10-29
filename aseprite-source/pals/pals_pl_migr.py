"""Puzzle Pals: THE GREAT MIGRATION (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-migr-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_migr.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: savanna sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy, puff); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-the-great-migration.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Powderpuff Dust     dust peach-cream            | 3 soft dust puffs billowing off the top tab, hoof prints      | sleepy half-lids, small o (sneeze)
  2 Faraway Dashes      horizon gold-orange         | a row of tiny dark herd silhouettes trotting across a horizon | eyes glancing right, smile
  3 Acacia Umbrella     acacia green                | flat-topped acacia canopy on top, trunk down the middle       | ^ ^ happy eyes, cat mouth
  4 Jade Sparklet       jade green (+ white facets) | faceted gem lines across the body, glints on every tab        | eyes looking up, open grin
  5 Honeysun Disc       honey (+ sunset rose)       | sun rays round the disc, rose horizon band low                | round eyes with brows, smirk
  6 Pinstripe Plodder   zebra white, black stripes  | whimsy chibi zebra: mane, ears, hooves, tufted tail, glow     | big shiny eyes, toothy grin, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-great-migration'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-great-migration-764397')

DUST = ('#dcb894', '#f0d6b4')
HORIZON = ('#d8902e', '#eeb050')
ACACIA = ('#4e8a34', '#6aa444')
JADE = ('#2a9a6a', '#4ec08a')
HONEY = ('#e0a832', '#f4cc5a')
ZEBRA = ('#e4e4e0', '#fafaf6')
STRIPE = '#24222a'
ROSE = ('#d8707a', '#f0a0a0')
BARK = ('#6a4a2e', '#8a6a44')
CREAM_ = '#fbf0dc'
HERD = '#3a2a24'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def dust_puff(st, cx, cy, r):
    m = disc(cx, cy, r) | disc(cx - r * 0.8, cy + r * 0.4, r * 0.7) | disc(cx + r * 0.8, cy + r * 0.4, r * 0.7)
    st.part(m, DUST[1], d=1, contour=True)
    st.paint(m & (CY < cy - r * 0.3) & shrink(m, 1), '#fff4e4')
    return m


def herd_beast(st, x, y):
    """A tiny far-off wildebeest silhouette: body, head down-forward, 4 legs."""
    st.sprite(['.....H.', 'HHHHHHH', 'HHHHH..', 'H.H.H..'], x, y, {'H': HERD}, solid=True)


# 1. Powderpuff Dust: corner-TT keyhole, common.
def powderpuff_dust():
    key = 'pl-migr-1'
    st = Sticker()
    core = (12, 22, 46, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 2, 3.6))
    st.part(body, tex=fill(key, body, 12, 12, 46, list(DUST)), contour=True)
    st.blank_shade(body, holes, width=1)
    dust_puff(st, 16, 14, 3.4)
    dust_puff(st, 47, 12, 2.6)
    dust_puff(st, 54, 26, 2.0)
    for x, y in ((17, 47), (22, 49), (38, 47)):
        st.paint(ellipse(x, y, 1.6, 1.2) & ~rect(x, y - 2, x, y + 2), '#b08a64')
    st.eye(20, 32, lid=2)
    st.eye(34, 32, lid=2)
    st.mouth('o', 27, 39)
    st.paint(rect(16, 38, 18, 38) | rect(40, 38, 42, 38), BLUSH)
    return key, st


# 2. Faraway Dashes: edge-TBT keyhole, common.
def faraway_dashes():
    key = 'pl-migr-2'
    st = Sticker()
    core = (13, 24, 47, 55)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 3, 3.6), e=('B', 'keyhole', 3, 3.0))
    st.part(body, tex=fill(key, body, 13, 12, 40, list(HORIZON)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(14, 46, 46, 46) & body, '#b06a22')
    for x in (15, 23, 31):
        herd_beast(st, x, 42)
    st.eye(21, 31, look=(1, 0))
    st.eye(33, 31, look=(1, 0))
    st.mouth("smile", 26, 37)
    return key, st


# 3. Acacia Umbrella: inner-TBTB keyhole, common.
def acacia_umbrella():
    key = 'pl-migr-3'
    st = Sticker()
    core = (14, 20, 49, 50)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 10, 40, list(ACACIA)), contour=True)
    st.blank_shade(body, holes, width=1)
    canopy = ellipse(31.5, 17, 15, 3.6)
    st.part(canopy, '#3a6e28', d=1, contour=True)
    st.paint(canopy & (CY < 15) & shrink(canopy, 1) & ((XX // 2) % 2 == 0), '#88bc56')
    st.paint(rect(31, 36, 32, 46) & body & ~grow(holes, 1), BARK[0])
    st.paint(line([(31, 40), (27, 37)]) | line([(32, 40), (36, 37)]), BARK[0])
    happy_eye(st, 21, 27)
    happy_eye(st, 38, 27)
    st.mouth('cat', 29, 31)
    return key, st


# 4. Jade Sparklet: inner-TTTT keyhole, uncommon.
def jade_sparklet():
    key = 'pl-migr-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(JADE)), contour=True)
    facet = (line([(18, 24), (24, 18)]) | line([(39, 18), (45, 24)]) | line([(18, 39), (24, 45)]) | line([(45, 39), (39, 45)]))
    st.paint(facet & body, '#d8fff0')
    st.stitch(body, col='#d8fff0')
    for x, y in ((31, 9), (31, 54), (9, 31), (54, 31)):
        st.dots([(x, y), (x + 1, y)], '#ffffff')
    st.eye(25, 27, look=(0, -1))
    st.eye(35, 27, look=(0, -1))
    st.mouth('grin', 29, 35)
    return key, st


# 5. Honeysun Disc: inner-BBBB double, uncommon.
def honeysun_disc():
    key = 'pl-migr-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(HONEY)), contour=True)
    st.blank_shade(body, holes, width=1)
    sun = disc(31.5, 31.5, 13)
    st.paint(sun & ~disc(31.5, 31.5, 12) & ~grow(holes, 1), '#fff0a0')
    for x, y in ((15, 15), (48, 15), (15, 48), (48, 48)):
        st.paint(disc(x, y, 1.4), '#fff0a0')
    st.paint(rect(11, 42, 52, 45) & body & ~grow(holes, 1), ROSE[0])
    st.stitch(body, col=ROSE[1], skip=grow(holes, 3))
    st.eye(25, 26)
    st.eye(36, 26)
    st.paint(line([(24, 23), (27, 22)]) | line([(37, 22), (40, 23)]), UMBER)
    st.mouth('smirk', 29, 34)
    return key, st


# 6. Pinstripe Plodder: whimsy-zebra keyhole, rare.
def pinstripe_plodder():
    key = 'pl-migr-6'
    st = Sticker()
    torso = ellipse(36, 40, 14, 8)
    head = ellipse(19, 26, 10, 9)
    muzzle = ellipse(15, 33, 6, 4)
    ears = poly([(12, 19), (11, 11), (16, 17)]) | poly([(22, 18), (25, 10), (27, 18)])
    legs = rect(25, 44, 29, 53) | rect(43, 44, 47, 53)
    tab = knob('n', 'keyhole', 38, 32.5, r=3.0)
    tail = line([(49, 37), (53, 43)], w=1)
    sil = torso | head | muzzle | ears | legs | tab
    st.part(tail, STRIPE, d=0, contour=True, shade=False)
    st.part(disc(53, 44, 1.8), STRIPE, d=0, contour=True, shade=False)
    st.part(sil, tex=fill(key, sil, 9, 9, 46, list(ZEBRA)), contour=True)
    body = (torso | legs | tab) & shrink(sil, 1)
    st.paint(body & (((XX + YY // 2) % 5) < 2) & (CX > 25), STRIPE)
    st.paint(head & shrink(sil, 1) & (((YY) % 5) < 1) & (CY < 22), STRIPE)
    st.paint(rect(24, 52, 30, 53) | rect(42, 52, 48, 53), STRIPE, solid=True)
    st.paint(muzzle & shrink(sil, 1), '#5a5258')
    st.dots([(12, 33), (16, 33)], STRIPE)
    st.paint(rect(20, 15, 27, 16) | rect(25, 17, 29, 18), STRIPE)    # mane tuft
    st.eye(15, 23, look=(-1, 0))
    st.eye(23, 23, look=(-1, 0))
    st.mouth('tooth', 12, 35)
    st.paint(rect(9, 30, 10, 30) | rect(26, 29, 27, 29), BLUSH)
    st.sparkle(52, 10)
    st.sparkle(40, 20, big=False)
    st.sparkle(6, 46, big=False)
    return key, st


PALS = [powderpuff_dust, faraway_dashes, acacia_umbrella, jade_sparklet, honeysun_disc, pinstripe_plodder]

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
