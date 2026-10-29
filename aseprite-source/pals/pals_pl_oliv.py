"""Puzzle Pals: OLIVE PRESS PIAZZA (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-oliv-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_oliv.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a southern-European piazza in golden afternoon. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-olive-press-piazza.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Pennant Frolic  afternoon sky azure    | a string of red/yellow/green pennants across the top | side glance, big grin
  2 Leaf Sweep      silver sage green      | an olive crown of leaves + a falling leaf + broom twig | laughing ^ ^ eyes, smile
  3 Loaf Share      bread crust brown      | a wicker basket band with two rolls peeking up        | sleepy lids, 'o' yum
  4 Piazza Chime    terracotta tower       | arched window with a glowing golden bell (accent gold) | looks up, cat mouth
  5 Millstone Turn  granite grey disc      | millstone grooves + centre axle + oil drip (accent gold)| wide round eyes, smirk
  6 Pressed Gold    kalamata purple        | whimsy olive with a leaf stem, golden oil drop, glow   | closed happy lids, smile, blush
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-olive-press-piazza'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-olive-press-piazza-f69430')

SKY = ('#5a8cc0', '#7eaad4')
SAGE = ('#7e9474', '#a0b496')
CRUST = ('#a8682e', '#c88a48')
TERRA = ('#b85a3a', '#d27a52')
GRANITE = ('#7a7670', '#9a968e')
KALA = ('#5a3a5c', '#7a5478')
PENN = ('#d04438', '#f0c040', '#4e9a44')
OLEAF = ('#5e7a4a', '#8aa878', '#c4d4b0')
WICKER = ('#8a5a2a', '#c49a5a')
ROLL = ('#e0a858', '#f4d090')
OIL = ('#e8b828', '#fff0a0', '#b8861a')
STONE_D = '#4a4642'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_down(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def olive_leaf(st, x, y, rx=3, ry=1.4):
    m = ellipse(x, y, rx, ry)
    st.part(m, OLEAF[1], d=1, contour=True)
    st.paint(m & (CY < y), OLEAF[2])
    st.extra |= grow(m, 1)
    return m


def drop(st, cx, cy, r):
    m = disc(cx, cy, r) | poly([(cx - r + 0.5, cy - 0.5), (cx + r - 0.5, cy - 0.5), (cx, cy - r * 2.4)])
    st.part(m, OIL[0], d=1, contour=True)
    st.paint(rect(int(cx - 1), int(cy - 1), int(cx - 1), int(cy)), OIL[1])
    st.extra |= grow(m, 1)
    return m


# ------------------------------------------------------------------ 1. Pennant Frolic: corner-TT round, common.
def pennant_frolic():
    key = 'pl-oliv-1'
    st = Sticker()
    core = (12, 22, 44, 51)
    body = piece(core, s='F', w='F', n=('T', 'round', 4, 3.6), e=('T', 'round', 2, 3.6))
    st.part(body, tex=fill(key, body, 12, 22, 33, list(SKY)), contour=True)
    st.stitch(body, col='#d8e8f4')
    st.paint(line([(8, 12), (20, 17), (36, 17), (54, 11)]), WICKER[0], solid=True)
    for i, (px, py) in enumerate(((11, 14), (19, 17), (27, 18), (35, 17), (44, 15), (51, 13))):
        m = poly([(px - 2.5, py), (px + 2.5, py), (px, py + 5)])
        st.part(m, PENN[i % 3], d=1, contour=True)
        st.extra |= grow(m, 1)
    st.eye(18, 31, look=(1, 0))
    st.eye(31, 31, look=(1, 0))
    st.mouth('grin', 23, 39)
    return key, st


# ------------------------------------------------------------------ 2. Leaf Sweep: edge-TBB peg, common.
def leaf_sweep():
    key = 'pl-oliv-2'
    st = Sticker()
    core = (14, 24, 44, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 0, 3.4), e=('B', 'peg', 3, 2.8), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 14, 24, 31, list(SAGE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=OLEAF[2], skip=grow(holes, 3))
    st.part(rect(28, 14, 30, 22), WICKER[0], d=1, contour=True)
    crown = ellipse(29.5, 14, 13, 6.5)
    st.part(crown, OLEAF[0], d=1, contour=True)
    st.paint(crown & ((XX * 2 + YY) % 5 == 0), OLEAF[2])
    st.paint(crown & (CY < 11) & ((XX + YY) % 3 == 0), OLEAF[1])
    st.extra |= grow(crown, 1)
    st.part(disc(25, 15, 1.4), KALA[0], d=1, contour=True)
    st.part(disc(35, 16, 1.4), KALA[0], d=1, contour=True)
    olive_leaf(st, 53, 56, 2.6, 1.2)
    st.paint(line([(48, 50), (54, 44)]), WICKER[1], solid=True)
    closed_up(st, 19, 33)
    closed_up(st, 33, 33)
    st.mouth('smile', 26, 40)
    st.paint(rect(16, 38, 18, 38) | rect(39, 38, 41, 38), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Loaf Share: inner-TBTB round, common.
def loaf_share():
    key = 'pl-oliv-3'
    st = Sticker()
    core = (14, 18, 46, 44)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', 0, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 18, 33, list(CRUST)), contour=True)
    st.blank_shade(body, holes, width=1)
    band = rect(15, 35, 45, 43) & body
    st.paint(band, WICKER[0])
    st.paint(band & ((XX + YY) % 4 < 2), WICKER[1])
    for rx in (22, 38):
        m = ellipse(rx, 34, 4.5, 3)
        st.part(m, ROLL[0], d=1, contour=True)
        st.paint(m & (CY < 33), ROLL[1])
    st.eye(22, 24, lid=2)
    st.eye(34, 24, lid=2)
    st.mouth('o', 29, 30)
    return key, st


# ------------------------------------------------------------------ 4. Piazza Chime: inner-TTTT peg, uncommon.
def piazza_chime():
    key = 'pl-oliv-4'
    st = Sticker()
    core = (17, 18, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 18, 30, list(TERRA)), contour=True)
    win = (rect(26, 24, 37, 33) | disc(31.5, 24, 5.5)) & (CY >= 19)
    st.paint(win, '#3a2a28')
    bell = (disc(31.5, 27, 3.5) & (CY <= 28)) | rect(27, 28, 36, 29)
    st.part(bell, OIL[0], d=1, contour=True)
    st.paint(rect(30, 30, 33, 31), OIL[2])
    st.paint(rect(30, 25, 30, 26), OIL[1])
    st.stitch(body, col=OIL[0])                                # uncommon accent: bell gold
    st.eye(23, 36, look=(0, -1))
    st.eye(36, 36, look=(0, -1))
    st.mouth('cat', 29, 42)
    return key, st


# ------------------------------------------------------------------ 5. Millstone Turn: inner-BBBB round, uncommon.
def millstone_turn():
    key = 'pl-oliv-5'
    st = Sticker()
    core = (11, 13, 52, 50)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(GRANITE)), contour=True)
    st.blank_shade(body, holes, width=1)
    ring = disc(31.5, 31.5, 16) & ~disc(31.5, 31.5, 15)
    st.paint(ring & body & ~grow(holes, 2), STONE_D)
    st.part(disc(31.5, 19.5, 2.5), STONE_D, d=1, contour=True)
    st.stitch(body, col=OIL[0], skip=grow(holes, 3))          # uncommon accent: oil gold
    st.eye(22, 26, look=(0, 0))
    st.eye(37, 26, look=(0, 0))
    st.mouth('smirk', 29, 35)
    drop(st, 31.5, 44, 2.5)
    return key, st


# ------------------------------------------------------------------ 6. Pressed Gold: whimsy-olive peg, rare.
def pressed_gold():
    key = 'pl-oliv-6'
    st = Sticker()
    olive = ellipse(30, 33, 17, 20) & (CY < 52)
    tab = knob('e', 'peg', 33, 46, r=3.2)
    body = olive | tab
    st.part(body, tex=fill(key, body, 12, 13, 38, list(KALA)), contour=True)
    st.paint(ellipse(22, 24, 3, 5) & body, '#9a78a0')
    st.part(rect(30, 8, 31, 13), WICKER[0], d=1, contour=True)
    olive_leaf(st, 37, 10, 5, 2)
    closed_down(st, 21, 31)
    closed_down(st, 33, 31)
    st.mouth('smile', 27, 37)
    st.paint(rect(17, 36, 19, 36) | rect(40, 36, 42, 36), BLUSH)
    drop(st, 52, 26, 3)
    st.sparkle(8, 10)
    st.sparkle(50, 50, big=False)
    st.sparkle(14, 50, big=False)
    return key, st


PALS = [pennant_frolic, leaf_sweep, loaf_share, piazza_chime, millstone_turn, pressed_gold]

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
