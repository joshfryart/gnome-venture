"""Puzzle Pals: LEMON GROVE MONASTERY (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-lemn-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_lemn.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a southern terraced lemon-grove monastery at dawn. kit_lair parts used only as building
blocks (PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-lemon-grove-monastery.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Belfry Ding    terracotta tower orange | a gold bell hung on top + two 'ding' ticks        | looks up, small smile
  2 Cowl Hum       monk robe brown         | a pointed hood cowl framing the face + music notes | closed humming lids, 'o'
  3 Jar Jostle     cordial glass teal      | a cork stopper + a lemon label, clink sparks       | wide round eyes, big grin
  4 Arch Parade    cream monastery wall    | three navy arched windows across the belly (2nd accent violet) | side glance, cat mouth
  5 Sunset Halo    dusk rose pink          | a sinking sun disc + sea stripes (2nd accent sea blue) | sleepy lids, smirk
  6 Abbot Lemon    lemon yellow            | whimsy lemon, leafy sprig crown, tiny tonsure, glow   | wink, toothy grin, blush
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-lemon-grove-monastery'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-lemon-grove-monastery-c58bd8')

TERRA = ('#b8532e', '#d06c3a')
ROBE = ('#6a4a30', '#86603e')
GLASS = ('#3e8a86', '#5aaaa2')
WALL = ('#d8ccb0', '#ece2c8')
ROSE = ('#c47896', '#dc98ad')
LEMON = ('#e8c628', '#f8e050')
BELL = ('#d8a630', '#f4d060', '#8a6420')
NAVY = ('#2c2c5a', '#44447a')
LEAF = ('#3e8a3a', '#62ae4a', '#24582a')
SUN = ('#f8b850', '#ffe8a0')
SEA = ('#4a8ac0', '#7ab4dc')
CORK = ('#a87a4a', '#7a5432')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_down(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def tick(st, pts):
    m = blank()
    for x, y in pts:
        m |= rect(x, y, x, y)
    st.paint(m, BELL[1], solid=True)
    st.extra |= m


def note(st, x, y):
    m = disc(x, y, 1.6) | rect(int(x + 1), y - 5, int(x + 1), y)
    m |= rect(int(x + 2), y - 5, int(x + 3), y - 5)
    st.paint(m, UMBER, solid=True)
    st.extra |= grow(m, 1)


# ------------------------------------------------------------------ 1. Belfry Ding: corner-TT round, common.
def belfry_ding():
    key = 'pl-lemn-1'
    st = Sticker()
    core = (12, 24, 44, 52)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', 0, 3.6), e=('T', 'round', 0, 3.6))
    st.part(body, tex=fill(key, body, 12, 24, 33, list(TERRA)), contour=True)
    st.stitch(body, col=BELL[1])
    bell = (ellipse(28, 14, 5, 6) & (CY > 10)) | rect(22, 16, 34, 18)
    st.part(bell, BELL[0], d=1, contour=True)
    st.paint(rect(26, 12, 27, 15), BELL[1])
    st.part(disc(28, 20, 1.6), BELL[2], d=1, contour=True)
    tick(st, [(16, 10), (17, 12), (40, 10), (39, 12)])
    st.eye(18, 33, look=(0, -1))
    st.eye(31, 33, look=(0, -1))
    st.mouth('smile', 24, 42)
    st.paint(rect(15, 40, 17, 40) | rect(37, 40, 39, 40), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Cowl Hum: edge-TTB peg, common.
def cowl_hum():
    key = 'pl-lemn-2'
    st = Sticker()
    core = (14, 22, 44, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 0, 3.4), e=('T', 'peg', 3, 3.4), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 14, 22, 31, list(ROBE)), contour=True)
    st.blank_shade(body, holes, width=1)
    hood = poly([(29, 8), (40, 26), (18, 26)]) | ellipse(29, 26, 11, 4)
    st.part(hood, ROBE[0], d=1, contour=True)
    face = ellipse(29, 34, 8, 7) & body
    st.part(face, '#f0c8a0', d=1, contour=True, rim=False)
    st.paint(rect(15, 44, 43, 45) & body, '#c49a48')         # rope belt
    closed_down(st, 22, 31)
    closed_down(st, 31, 31)
    st.mouth('o', 28, 36)
    return key, st


# ------------------------------------------------------------------ 3. Jar Jostle: inner-TBTB round, common.
def jar_jostle():
    key = 'pl-lemn-3'
    st = Sticker()
    core = (15, 18, 47, 46)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', 0, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 15, 18, 33, list(GLASS)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(rect(18, 21, 19, 40) & body, '#a8dcd4')          # glass glint
    cork = rect(26, 8, 36, 13)
    st.part(cork, CORK[0], d=1, contour=True)
    label = ellipse(31, 40, 6, 3.4)
    st.part(label, LEMON[1], d=1, contour=True)
    st.paint(rect(29, 40, 33, 40), LEAF[0])
    st.eye(22, 27)
    st.eye(35, 27)
    st.mouth('grin', 29, 33)
    tick(st, [(8, 20), (9, 22), (54, 20), (53, 22)])
    return key, st


# ------------------------------------------------------------------ 4. Arch Parade: inner-TTTT round, uncommon.
def arch_parade():
    key = 'pl-lemn-4'
    st = Sticker()
    core = (16, 17, 47, 46)
    body = piece(core, n=('T', 'round', 0, 3.6), e=('T', 'round', 0, 3.6), s=('T', 'round', 0, 3.6), w=('T', 'round', 0, 3.6))
    st.part(body, tex=fill(key, body, 16, 17, 32, list(WALL)), contour=True)
    for ax in (21, 31.5, 42):
        arch = (disc(ax, 37, 3) | rect(int(ax - 3), 37, int(ax + 3), 43))
        st.part(arch & body, NAVY[0], d=1, contour=True, rim=False)
        st.paint(rect(int(ax), 36, int(ax), 43) & body, NAVY[1])
    st.stitch(body, col='#8a6ab8')                              # uncommon accent: dawn violet
    st.paint(rect(16, 46, 47, 46) & body, TERRA[0])
    st.eye(24, 24, look=(1, 0))
    st.eye(35, 24, look=(1, 0))
    st.mouth('smile', 29, 30)
    st.paint(rect(20, 29, 22, 29) | rect(39, 29, 41, 29), BLUSH)
    return key, st


# ------------------------------------------------------------------ 5. Sunset Halo: inner-BBBB peg, uncommon.
def sunset_halo():
    key = 'pl-lemn-5'
    st = Sticker()
    core = (11, 12, 52, 51)
    body, holes = piece_blanks(core, n=('B', 'peg', 0, 2.8), e=('B', 'peg', 0, 2.8), s=('B', 'peg', 0, 2.8), w=('B', 'peg', 0, 2.8))
    st.part(body, tex=fill(key, body, 11, 12, 42, list(ROSE)), contour=True)
    st.blank_shade(body, holes, width=1)
    sun = disc(31.5, 31, 11) & (CY < 38)
    st.part(sun & body, SUN[0], d=1, contour=False, rim=False)
    st.paint(disc(31.5, 31, 8) & (CY < 38) & body, SUN[1])
    for y in (38, 41, 44):
        st.paint(rect(15, y, 48, y + 1) & body & ~grow(holes, 2), SEA[0])
    st.paint(rect(20, 41, 43, 41) & body, SEA[1])
    st.stitch(body, col=SEA[1], skip=grow(holes, 3))          # uncommon accent: sea blue
    st.eye(24, 26, lid=3)
    st.eye(35, 26, lid=3)
    st.mouth('smirk', 29, 33)
    return key, st


# ------------------------------------------------------------------ 6. Abbot Lemon: whimsy-lemon round, rare.
def abbot_lemon():
    key = 'pl-lemn-6'
    st = Sticker()
    lemon = ellipse(32, 33, 19, 15) | ellipse(13.5, 33, 3.5, 3) | ellipse(50.5, 33, 3.5, 3)
    tab = knob('s', 'round', 32, 47, r=3.4)
    body = lemon | tab
    st.part(body, tex=fill(key, body, 10, 17, 44, list(LEMON)), contour=True)
    st.paint(body & ((XX * 3 + YY * 5) % 11 == 0) & ~shrink(body, 5), '#c8a418')   # peel pores
    st.part(ellipse(32, 20, 5, 2), '#f8ecb0', d=1, contour=False, rim=False)       # tonsure
    for lx, ang in ((25, -1), (39, 1)):
        lf = poly([(32, 18), (32 + ang * 13, 9), (32 + ang * 5, 15)])
        st.part(lf | ellipse(32 + ang * 8, 13, 5, 2.5), LEAF[1], d=1, contour=True)
    st.part(rect(31, 12, 32, 18), LEAF[2], d=1, contour=False)
    closed_up(st, 22, 29)
    st.eye(37, 27)
    st.mouth('tooth', 29, 37)
    st.paint(rect(19, 35, 21, 35) | rect(43, 35, 45, 35), BLUSH)
    st.sparkle(9, 11)
    st.sparkle(54, 18, big=False)
    st.sparkle(12, 52, big=False)
    return key, st


PALS = [belfry_ding, cowl_hum, jar_jostle, arch_parade, sunset_halo, abbot_lemon]

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
