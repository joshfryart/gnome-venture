"""Puzzle Pals: PINK RIVER DOLPHIN POOLS (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wdol-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wdol.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: flooded forest sprites, keyhole knobs, bright day. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-pink-river-dolphin-pools.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Lilypad Parasol       lily-pad green              | notched lily pad held up as a parasol, a tiny frog under it  | wide bright eyes, grin
  2 Scarlet Chatterbox    macaw scarlet               | hooked beak, blue/gold wing flash, perch twig at its feet    | ^ ^ happy eyes, wide-open o
  3 Notch-Ladder Trunk    bark brown                  | gold notch rungs up the trunk, two hanging vines             | sleepy half-lids, flat mouth
  4 Rosy Fin Salute       river teal (+ dolphin pink) | pink dorsal fin raised on the top tab, ripple rings          | eyes glancing up, cat mouth
  5 Parcel on a Pad       seed-sack mustard (+ green) | tied seed bundle with a bow, lily pad under it               | one wink, smirk
  6 Nudging Boto          dolphin pink + cream belly  | whimsy boto, long snout nudging a seed, flipper, glow        | joyful lashes, snout smile, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-pink-river-dolphin-pools'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-pink-river-dolphin-pools-29137e')

LILY = ('#4e8e3a', '#72b04e')          # lily-pad green
SCAR = ('#c42e2a', '#e2523e')          # macaw scarlet
BARK = ('#7a4a2a', '#9a6438')          # bark brown
TEAL = ('#3e8a86', '#62aaa2')          # river teal
SACK = ('#c89a3a', '#e0b858')          # seed-sack mustard
PINK = ('#e47aa4', '#f6a2c2')          # dolphin pink (rare)
CRM = '#fbf0dc'
FROG = '#8ac84a'
MACB = ('#3a6ac8', '#f0c84a')
VINE = '#4a8a3a'
NOTCH = '#f0c84a'
BLUSH = '#f0a0a0'
SEED = ('#8a5a2a', '#b07a3a')


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


def seed(st, x, y):
    st.part(ellipse(x, y, 2.2, 1.6), SEED[1], d=1, contour=True)
    st.dots([(int(x) - 1, int(y) - 1)], '#e0b878')


# ------------------------------------------------------------------ 1. Lilypad Parasol: corner-BB keyhole, common.
def lilypad_parasol():
    key = 'pl-wdol-1'
    st = Sticker()
    core = (12, 20, 48, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', -4, 3.0), e=('B', 'keyhole', 3, 3.0))
    st.part(body, tex=fill(key, body, 12, 12, 40, list(LILY)), contour=True)
    st.blank_shade(body, holes, width=1)
    # parasol pad above the brow, with its notch
    pad = ellipse(28, 13, 15, 5) & ~poly([(28, 13), (32, 7), (36, 7)])
    st.part(pad, LILY[1], d=1, contour=True)
    st.paint(line([(28, 13), (18, 11)]) | line([(28, 13), (38, 15)]), LILY[0])
    st.part(rect(27, 16, 28, 21), '#6a4a2a', d=0, contour=True, shade=False)
    st.eye(18, 28)
    st.eye(33, 28)
    st.mouth('grin', 23, 37)
    # tiny frog in the shade, lower left
    st.part(ellipse(19, 47, 5, 3), FROG, d=1, contour=True)
    st.part(disc(16, 44, 1.6) | disc(21, 44, 1.6), FROG, d=0, contour=True, shade=False)
    st.dots([(16, 44), (21, 44)], UMBER)
    st.paint(rect(17, 48, 21, 48), '#4a7a2a')
    return key, st


# ------------------------------------------------------------------ 2. Scarlet Chatterbox: edge-TBB keyhole, common.
def scarlet_chatterbox():
    key = 'pl-wdol-2'
    st = Sticker()
    core = (13, 17, 48, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 13, 9, 40, list(SCAR)), contour=True)
    st.blank_shade(body, holes, width=1)
    # wing flash, blue over gold, right side
    st.paint(poly([(36, 38), (46, 34), (46, 46), (38, 46)]) & body, MACB[0])
    st.paint(rect(38, 44, 46, 46) & body, MACB[1])
    # hooked beak
    st.sprite(['.CCCC.', 'CCCCCU', 'CCCCCU', '.UCCU.', '..UU..'], 28, 30, {'C': CRM, 'U': UMBER})
    happy_eye(st, 20, 25)
    happy_eye(st, 36, 25)
    st.mouth('o', 29, 36)
    # perch twig under its feet
    st.part(rect(8, 52, 55, 54), '#7a4a2a', d=0, contour=True, shade=False)
    st.paint(rect(8, 52, 55, 52), '#9a6438')
    for x in (22, 38):
        st.part(rect(x, 50, x + 3, 51), '#e0a040', d=0, contour=True, shade=False)
    return key, st


# ------------------------------------------------------------------ 3. Notch-Ladder Trunk: inner-TBTB keyhole, common.
def notch_ladder_trunk():
    key = 'pl-wdol-3'
    st = Sticker()
    core = (16, 15, 47, 47)
    body, holes = piece_blanks(core, n=('T', 'keyhole', -5, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 5, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 16, 8, 32, list(BARK)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in range(18, 46, 5):
        st.paint(rect(30, y, 33, y + 1) & body, NOTCH)
    for x in (19, 44):
        v = line([(x, 15), (x, 30)], w=1) | disc(x, 31, 1.3)
        st.paint(v & body, VINE)
    st.eye(20, 33, lid=2)
    st.eye(37, 33, lid=2)
    st.mouth('flat', 30, 41)
    return key, st


# ------------------------------------------------------------------ 4. Rosy Fin Salute: inner-TTTT double, uncommon.
def rosy_fin_salute():
    key = 'pl-wdol-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(TEAL)), contour=True)
    st.stitch(body, col=PINK[0])                                     # uncommon accent: dolphin pink
    fin = poly([(25, 24), (32, 9), (34, 10), (38, 24)])
    st.part(fin, PINK[0], d=1, contour=True)
    st.paint(line([(32, 11), (30, 22)]), PINK[1])
    for y in (40, 43):
        st.paint(rect(22, y, 41, y) & ((XX // 2) % 2 == 0), '#c8e8e0')
    st.eye(22, 27, look=(0, -1))
    st.eye(37, 27, look=(0, -1))
    st.paint(rect(20, 34, 22, 34) | rect(41, 34, 43, 34), BLUSH)
    st.mouth('cat', 30, 35)
    return key, st


# ------------------------------------------------------------------ 5. Parcel on a Pad: inner-BBBB keyhole, uncommon.
def parcel_on_a_pad():
    key = 'pl-wdol-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(SACK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=LILY[1], skip=grow(holes, 3))              # uncommon accent: lily green
    # tie + bow across the bundle top
    st.paint(rect(18, 21, 45, 22) & body, '#8a5a2a')
    bow = ellipse(28, 21.5, 3.2, 2) | ellipse(36, 21.5, 3.2, 2)
    st.part(bow, '#a8241f', d=1, contour=True)
    st.paint(disc(32, 22, 1.3), '#6a1a1a', solid=True)
    # lily pad below
    st.part(ellipse(32, 47, 12, 2.6) & ~poly([(32, 47), (30, 50), (34, 50)]), LILY[0], d=1, contour=True)
    seed(st, 20, 43)
    seed(st, 44, 43)
    wink(st, 21, 28)
    st.eye(36, 27, lid=1)
    st.mouth('smirk', 29, 36)
    return key, st


# ------------------------------------------------------------------ 6. Nudging Boto: whimsy-boto keyhole, rare.
def nudging_boto():
    key = 'pl-wdol-6'
    st = Sticker()
    bodyb = ellipse(28, 37, 14, 9)
    head = disc(36, 31, 8.5)
    snout = ellipse(45.5, 35, 5, 2.4)
    tail = poly([(16, 35), (11, 28), (12, 37), (11, 46), (17, 41)])
    tab = knob('n', 'keyhole', 25, 28, r=3.2)
    sil = bodyb | head | snout | tail | tab
    st.part(sil, tex=fill(key, sil, 11, 14, 42, list(PINK)), contour=True)
    st.paint(ellipse(31, 42, 9, 3.2) & bodyb, CRM)
    # flipper
    st.part(poly([(28, 42), (23, 49), (32, 46)]), PINK[0], d=1, contour=True)
    # melon bump highlight
    st.paint(ellipse(36, 25, 3, 1.4), PINK[1])
    lash_eye(st, 35, 28)
    st.paint(rect(39, 35, 41, 35), '#d84a7a')
    st.paint(line([(43, 37), (48, 37)]), UMBER)
    st.paint(rect(31, 35, 33, 35), BLUSH)
    # the nudged seed
    st.part(ellipse(53, 34, 2.2, 2.6), SEED[1], d=1, contour=True)
    st.dots([(52, 33)], '#e0b878')
    st.sparkle(44, 13)
    st.sparkle(10, 15, big=False)
    st.sparkle(51, 49, big=False)
    return key, st


PALS = [lilypad_parasol, scarlet_chatterbox, notch_ladder_trunk, rosy_fin_salute, parcel_on_a_pad, nudging_boto]

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
