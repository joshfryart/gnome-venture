"""Puzzle Pals: THE THOUSAND GATES (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-gate-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_gate.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: dawn hillside sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Body = its own cell of game/assets/img/jigsaw/places/wonder-the-thousand-gates.png,
calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Lollipop Maple        maple red                   | a lollipop trunk stick underfoot, leaf sprig on top               | sleepy lidded eyes, small smile
  2 Hilltop Bowl Shimmer  hill green                  | a shining gold offering bowl balanced on its head                 | eyes glancing sideways, open grin
  3 Torii Tophat          dawn lilac                  | a black curved torii roof-beam tipped like a top hat              | wide open eyes, toothy grin
  4 Redgate Staircase     mist blue-grey (+ red)      | three red gates stepping up across the belly, smaller each time   | two happy arcs, wide smile
  5 Dawnglow Pearl        sun peach (+ cream)         | a ring of short sun rays round the body                           | eyes looking up, little o mouth
  6 Whisker Sentinel      cat cream, grey stripes     | whimsy shrine cat: pointed ears, whiskers, red collar + gold bell | calm half-lid eyes, cat mouth
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-thousand-gates'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-thousand-gates-147003')

MAPLE = ('#b8322a', '#d8503a')
HILL = ('#3f8a3a', '#5aa64c')
LILAC = ('#a890c0', '#c4b0d8')
MIST = ('#5f6c8d', '#7f8cad')
PEACH = ('#f2b88c', '#fad6b0')
CATC = ('#e8e0d0', '#f6f0e4')
VERM = '#d03a2a'
ROOF = '#2a2430'
TRUNK = '#7a4a1f'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_arc(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def mini_gate(st, x, y, w, h):
    st.paint(rect(x - 1, y, x + w + 1, y), ROOF)
    st.paint(rect(x, y + 1, x + w, y + 1), VERM)
    st.paint(rect(x + 1, y + 2, x + 1, y + h) | rect(x + w - 1, y + 2, x + w - 1, y + h), VERM)


# 1. Lollipop Maple: corner-TB keyhole, common.
def lollipop_maple():
    key = 'pl-gate-1'
    st = Sticker()
    st.part(rect(30, 47, 33, 53), TRUNK, d=1, contour=True)
    core = (12, 19, 46, 47)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', 2, 3.6), e=('B', 'keyhole', 0, 3.0))
    body = body & ~(disc(12, 19, 5) & ~disc(17, 24, 5)) & ~(disc(12, 47, 5) & ~disc(17, 42, 5))
    st.part(body, tex=fill(key, body, 12, 10, 38, list(MAPLE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.part(poly([(36, 8), (41, 10), (37, 12)]), '#e88a3a', d=0, contour=True, shade=False)
    st.eye(19, 27, lid=2)
    st.eye(32, 27, lid=2)
    st.mouth('smile', 26, 36)
    st.paint(rect(16, 35, 18, 35) | rect(38, 35, 40, 35), BLUSH)
    return key, st


# 2. Hilltop Bowl Shimmer: edge-TTB keyhole, common.
def hilltop_bowl():
    key = 'pl-gate-2'
    st = Sticker()
    core = (13, 24, 44, 54)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 14, 36, list(HILL)), contour=True)
    st.blank_shade(body, holes, width=1)
    bowl = ellipse(31.5, 14, 9, 5) & (YY >= 13)
    st.part(bowl, '#e0a830', d=1, contour=True)
    st.paint(rect(23, 13, 40, 13), '#fff0a0')
    st.paint(rect(26, 15, 29, 15), '#ffe070')
    st.sparkle(42, 6, big=False)
    st.eye(21, 31, look=(1, 0))
    st.eye(35, 31, look=(1, 0))
    st.mouth('grin', 29, 41)
    return key, st


# 3. Torii Tophat: inner-TBTB keyhole, common.
def torii_tophat():
    key = 'pl-gate-3'
    st = Sticker()
    core = (15, 20, 48, 44)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 14, 34, list(LILAC)), contour=True)
    st.blank_shade(body, holes, width=1)
    crown = rect(22, 9, 41, 17)
    st.part(crown, ROOF, d=1, contour=True)
    brim = poly([(10, 16), (53, 16), (50, 20), (13, 20)]) | rect(9, 14, 11, 16) | rect(52, 14, 54, 16)
    st.part(brim, '#3a3240', d=1, contour=True)
    st.paint(rect(22, 15, 41, 15), VERM)
    st.eye(21, 25)
    st.eye(37, 25)
    st.mouth('tooth', 29, 34)
    st.paint(rect(19, 33, 21, 33) | rect(42, 33, 44, 33), BLUSH)
    return key, st


# 4. Redgate Staircase: inner-TTTT keyhole, uncommon (Plus, symmetric).
def redgate_staircase():
    key = 'pl-gate-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 16, 16, 32, list(MIST)), contour=True)
    st.stitch(body, col='#c8d0e4')
    mini_gate(st, 21, 38, 6, 5)
    mini_gate(st, 29, 36, 5, 5)
    mini_gate(st, 36, 34, 4, 5)
    happy_arc(st, 22, 25)
    happy_arc(st, 37, 25)
    st.mouth('smile', 30, 29)
    return key, st


# 5. Dawnglow Pearl: inner-BBBB double, uncommon (Ring, symmetric).
def dawnglow_pearl():
    key = 'pl-gate-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.4), e=('B', 'double', 0, 3.4), s=('B', 'double', 0, 3.4),
                               w=('B', 'double', 0, 3.4))
    body = body & ~(disc(11, 11, 4) & ~disc(15, 15, 4)) & ~(disc(53, 11, 4) & ~disc(49, 15, 4)) & \
        ~(disc(11, 53, 4) & ~disc(15, 49, 4)) & ~(disc(53, 53, 4) & ~disc(49, 49, 4))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(PEACH)), contour=True)
    st.blank_shade(body, holes, width=1)
    for (x, y) in ((16, 16), (46, 16), (16, 46), (46, 46)):
        st.paint(rect(x, y, x + 1, y + 1), '#fff4dc')
    st.paint(disc(31.5, 43, 4.5) & (YY <= 42), '#f08a40')
    st.paint(rect(24, 43, 39, 43), '#c86a30')
    st.paint(rect(31, 35, 32, 36) | rect(25, 38, 25, 38) | rect(38, 38, 38, 38), '#f08a40')
    st.eye(22, 22, look=(0, -1))
    st.eye(37, 22, look=(0, -1))
    st.mouth('o', 31, 30)
    return key, st


# 6. Whisker Sentinel: whimsy-gatecat keyhole, rare.
def whisker_sentinel():
    key = 'pl-gate-6'
    st = Sticker()
    head = ellipse(31.5, 28, 14, 11)
    ears = poly([(18, 24), (20, 10), (28, 19)]) | poly([(45, 24), (43, 10), (35, 19)])
    bodym = ellipse(31.5, 42, 11, 7)
    tab = knob('s', 'keyhole', 32, 48, r=2.4)
    sil = head | ears | bodym | tab
    st.part(sil, tex=fill(key, sil, 14, 10, 38, list(CATC)), contour=True)
    st.paint(poly([(21, 15), (22, 21), (25, 19)]) | poly([(42, 15), (41, 21), (38, 19)]), '#f0b0b0')
    for x in (28, 31, 34):
        st.paint(rect(x, 18, x, 21), '#8a8690')
    st.part(rect(21, 37, 42, 39), VERM, d=0, contour=True, shade=False)
    st.part(disc(31.5, 41.5, 2.2), GOLD, d=1, contour=True)
    st.eye(23, 25, lid=1)
    st.eye(36, 25, lid=1)
    st.mouth('cat', 29, 32)
    st.paint(line([(13, 30), (20, 31)]) | line([(43, 31), (50, 30)]), UMBER2)
    st.paint(rect(20, 33, 22, 33) | rect(41, 33, 43, 33), BLUSH)
    st.sparkle(6, 6)
    st.sparkle(52, 8, big=False)
    st.sparkle(8, 46, big=False)
    return key, st


PALS = [lollipop_maple, hilltop_bowl, torii_tophat, redgate_staircase, dawnglow_pearl, whisker_sentinel]

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
        print('%-10s %-21s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                   ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
