"""Puzzle Pals: THE STEPPED SEED TEMPLE (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-step-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_step.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: hillside temple sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Body = its own cell of game/assets/img/jigsaw/places/wonder-the-stepped-seed-temple.png,
calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Grumpy Mossmask       moss green                  | two leafy ears on the sides of a carved stone face                | heavy-browed sleepy eyes, flat grumble
  2 Glyph Doodle          pale terrace stone grey     | a row of carved triangle + square glyphs across the belly         | eyes glancing sideways, cat mouth
  3 Marigold Dot Duo      marigold orange             | an orange + a pink flower bobbing on stalks above its head        | wide open eyes, toothy grin
  4 Ziggurat Zigzag       temple earth brown (+ cream)| a stepped cream ziggurat with a tiny door on the chest            | two happy arcs, smile
  5 Goldseal Gleam        sky blue (+ gold)           | a big round gold medallion with a seed mark on the belly          | eyes looking up, little o mouth
  6 Scarlet Riddlecaller  scarlet macaw red           | whimsy macaw: hooked beak, blue/yellow wing, '?' speech mark, glow| one eye winking, beak open
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-stepped-seed-temple'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-stepped-seed-temple-fd002d')

MOSS = ('#4c7a34', '#6a9a46')
TSTONE = ('#b8b4a8', '#d4d0c4')
MARI = ('#e0862a', '#f4a63e')
EARTH = ('#6a4630', '#86603e')
SKYB = ('#86bcdc', '#b0d6ea')
SCAR = ('#c42a26', '#e04438')
CREAMS = '#efe4c4'
LEAF = '#3a6a2a'
PINK = '#e8709a'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_arc(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


# 1. Grumpy Mossmask: corner-BB keyhole, common.
def grumpy_mossmask():
    key = 'pl-step-1'
    st = Sticker()
    core = (14, 12, 49, 50)
    body, holes = piece_blanks(core, n='F', w='F', e=('B', 'keyhole', 0, 3.4), s=('B', 'keyhole', 0, 3.4))
    for sx in (1, -1):
        cx = 13 if sx == 1 else 50
        leaf = poly([(cx, 22), (cx - 9 * sx, 16), (cx - 7 * sx, 28)])
        st.part(leaf, '#5e9a3a', d=1, contour=True)
        st.paint(line([(cx, 22), (cx - 7 * sx, 19)]), LEAF)
    st.part(body, tex=fill(key, body, 14, 12, 38, list(MOSS)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.eye(20, 25, lid=2)
    st.eye(34, 25, lid=2)
    st.paint(line([(19, 22), (25, 24)]) | line([(39, 24), (45, 22)]), UMBER)
    st.mouth('flat', 29, 38)
    st.paint(rect(28, 37, 28, 37) | rect(32, 37, 32, 37), UMBER)
    return key, st


# 2. Glyph Doodle: edge-TBB keyhole, common.
def glyph_doodle():
    key = 'pl-step-2'
    st = Sticker()
    core = (15, 18, 48, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 8, 40, list(TSTONE)), contour=True)
    st.blank_shade(body, holes, width=1)
    gl = '#6a6458'
    for i, x in enumerate((19, 27, 35, 42)):
        if i % 2 == 0:
            st.paint(poly([(x, 46), (x + 2.5, 41), (x + 5, 46)]), gl)
        else:
            st.paint(rect(x, 41, x + 4, 45) & ~rect(x + 1, 42, x + 3, 44), gl)
    st.eye(22, 26, look=(1, 0))
    st.eye(36, 26, look=(1, 0))
    st.mouth('cat', 30, 35)
    st.paint(rect(18, 34, 20, 34) | rect(44, 34, 46, 34), BLUSH)
    return key, st


# 3. Marigold Dot Duo: inner-TBTB keyhole, common.
def marigold_dot_duo():
    key = 'pl-step-3'
    st = Sticker()
    core = (15, 22, 48, 48)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    for x, col in ((15, '#f08a20'), (45, PINK)):
        st.paint(line([(x + 2, 13), (x + 2, 22)]), LEAF)
        st.part(disc(x + 2, 11, 4), col, d=1, contour=True)
        st.paint(disc(x + 2, 11, 1.2), '#ffe070')
    st.part(body, tex=fill(key, body, 15, 14, 34, list(MARI)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.eye(21, 28)
    st.eye(37, 28)
    st.mouth('tooth', 29, 38)
    st.paint(rect(19, 36, 21, 36) | rect(42, 36, 44, 36), BLUSH)
    return key, st


# 4. Ziggurat Zigzag: inner-TTTT keyhole, uncommon (Plus, symmetric).
def ziggurat_zigzag():
    key = 'pl-step-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(EARTH)), contour=True)
    st.stitch(body, col=CREAMS)
    for i, (x0, x1) in enumerate(((22, 41), (25, 38), (28, 35))):
        y = 42 - i * 3
        st.paint(rect(x0, y, x1, y + 2), CREAMS)
        st.paint(rect(x0, y + 2, x1, y + 2), '#c8b890')
    st.paint(rect(31, 34, 32, 37), UMBER2)
    happy_arc(st, 22, 26)
    happy_arc(st, 37, 26)
    st.mouth('smile', 30, 29)
    return key, st


# 5. Goldseal Gleam: inner-BBBB double, uncommon (Ring, symmetric).
def goldseal_gleam():
    key = 'pl-step-5'
    st = Sticker()
    core = (10, 10, 53, 53)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.4), e=('B', 'double', 0, 3.4), s=('B', 'double', 0, 3.4),
                               w=('B', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 10, 10, 44, list(SKYB)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.eye(21, 18, look=(0, -1))
    st.eye(38, 18, look=(0, -1))
    st.mouth('o', 31, 25)
    st.part(disc(32, 39, 9), '#e8b830', d=1, contour=True)
    st.paint(disc(32, 39, 9) & ~disc(32, 39, 7.8), '#b8862a')
    st.paint(ellipse(32, 39, 2.2, 3.5), '#8a5a1f')
    st.paint(rect(31, 37, 31, 38), '#f8e090')
    st.paint(rect(28, 33, 29, 34), '#fff3c8')
    return key, st


# 6. Scarlet Riddlecaller: whimsy-macaw keyhole, rare.
def scarlet_riddlecaller():
    key = 'pl-step-6'
    st = Sticker()
    head = disc(30, 22, 10)
    bod = ellipse(31, 38, 11, 12)
    tail = poly([(26, 46), (36, 46), (33, 57), (29, 57)])
    tab = knob('w', 'keyhole', 38, 21, r=2.4)
    st.part(tail, '#2a6ac8', d=1, contour=True)
    sil = head | bod | tab
    st.part(sil, tex=fill(key, sil, 14, 12, 36, list(SCAR)), contour=True)
    wing = poly([(30, 34), (42, 32), (40, 46), (32, 44)])
    st.part(wing, '#f0c030', d=1, contour=True)
    st.paint(poly([(33, 40), (41, 38), (40, 46), (32, 44)]) & wing, '#2a7ad8')
    st.paint(ellipse(25, 23, 4, 3), '#f4f0e8')
    beak = poly([(38, 18), (46, 21), (43, 28), (38, 26)])
    st.part(beak, '#ece4d0', d=1, contour=True)
    st.paint(poly([(39, 25), (43, 27), (38, 28)]), '#2a2420')
    st.eye(23, 19)
    st.paint(rect(31, 21, 35, 21), UMBER)
    st.paint(rect(30, 20, 30, 20) | rect(36, 20, 36, 20), UMBER)
    st.part(rect(25, 50, 27, 52) | rect(35, 50, 37, 52), '#4a4a50', d=0, contour=True, shade=False)
    q = ['.GGG.', 'G...G', '...G.', '..G..', '.....', '..G..']
    st.sprite(q, 49, 9, {'G': GOLD}, solid=False)
    st.sparkle(8, 10)
    st.sparkle(8, 44, big=False)
    st.sparkle(52, 48, big=False)
    return key, st


PALS = [grumpy_mossmask, glyph_doodle, marigold_dot_duo, ziggurat_zigzag, goldseal_gleam, scarlet_riddlecaller]

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
