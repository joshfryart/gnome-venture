"""Puzzle Pals: THE LABYRINTH ISLE (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-labi-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_labi.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: bright island sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Body = its own cell of game/assets/img/jigsaw/places/wonder-the-labyrinth-isle.png,
calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Cypress Candle       dark cypress green          | a tall pointed cypress-tip hat with a gold candle glint           | sleepy lidded eyes, small smile
  2 Creamsail Dawdle     sail cream                  | a little red boat hull underfoot + mast pennant                  | eyes glancing sideways, cat mouth
  3 Gatepost Lampshine   lamp orange                 | two tiny white gateposts with lit lamps on its shoulders         | wide open eyes, toothy grin
  4 Hedgerow Swirls      bright hedge lime (+ sand)  | concentric maze-lane rings across the belly                      | two happy arcs, wide smile
  5 Questionmark Bubble  sky blue (+ white)          | a big umber question mark on its chest                           | eyes looking up, little o mouth
  6 Plinth Riddler       stone grey, dark plinth     | whimsy stone gnome: grey pointy hat, beard, plinth base, glow    | one eyebrow raised, patient smirk
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-labyrinth-isle'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-labyrinth-isle-1eea49')

CYPRESS = ('#2c4a26', '#3e6234')
SAILC = ('#e8e7cb', '#f6f4dc')
LAMPO = ('#e08a2a', '#f2aa48')
HEDGE = ('#6ab040', '#8ccc58')
SKYB = ('#8cc8e4', '#c5e2ee')
STONE = ('#7a7a82', '#9a9aa2')
STONE_D = '#4e4e58'
PLINTH = '#3a3640'
SAND = '#e8d8a0'
HULL = '#c23a34'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_arc(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


# 1. Cypress Candle: corner-TT keyhole, common.
def cypress_candle():
    key = 'pl-labi-1'
    st = Sticker()
    core = (12, 24, 44, 54)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', -6, 3.6), e=('T', 'keyhole', 2, 3.6))
    st.part(body, tex=fill(key, body, 12, 14, 40, list(CYPRESS)), contour=True)
    st.stitch(body, col='#7aa86a')
    hat = poly([(17, 25), (22, 8), (27, 25)])
    st.part(hat, '#3e6234', d=1, contour=True)
    st.paint(line([(22, 12), (20, 22)]), '#5a8a48')
    st.paint(rect(21, 8, 22, 10), GOLD)
    st.eye(18, 34, lid=2)
    st.eye(31, 34, lid=2)
    st.mouth('smile', 24, 44)
    st.paint(rect(15, 42, 17, 42) | rect(37, 42, 39, 42), BLUSH)
    return key, st


# 2. Creamsail Dawdle: edge-TBT keyhole, common.
def creamsail_dawdle():
    key = 'pl-labi-2'
    st = Sticker()
    core = (15, 22, 47, 46)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 15, 10, 36, list(SAILC)), contour=True)
    st.blank_shade(body, holes, width=1)
    hull = poly([(10, 47), (54, 47), (48, 55), (16, 55)])
    st.part(hull, HULL, d=1, contour=True)
    st.paint(rect(14, 48, 50, 48) & hull, '#e8705a')
    st.part(rect(31, 7, 32, 12), '#7a4a1f', d=0, contour=True, shade=False)
    st.part(poly([(33, 7), (39, 9), (33, 11)]), HULL, d=0, contour=True, shade=False)
    st.eye(22, 27, look=(-1, 0))
    st.eye(35, 27, look=(-1, 0))
    st.mouth('cat', 29, 37)
    return key, st


# 3. Gatepost Lampshine: inner-TBTB keyhole, common.
def gatepost_lampshine():
    key = 'pl-labi-3'
    st = Sticker()
    core = (15, 20, 48, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 12, 34, list(LAMPO)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x in (12, 47):
        st.part(rect(x, 13, x + 4, 22), '#f4f2ea', d=1, contour=True)
        st.part(rect(x, 9, x + 4, 12), '#ffd060', d=0, contour=True, shade=False)
        st.paint(rect(x + 1, 10, x + 3, 11), '#fff3c8')
        st.paint(rect(x, 8, x + 4, 8), UMBER2, solid=True)
    st.eye(21, 27)
    st.eye(37, 27)
    st.mouth('tooth', 29, 37)
    st.paint(rect(19, 35, 21, 35) | rect(42, 35, 44, 35), BLUSH)
    return key, st


# 4. Hedgerow Swirls: inner-TTTT keyhole, uncommon (Plus, symmetric).
def hedgerow_swirls():
    key = 'pl-labi-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(HEDGE)), contour=True)
    st.stitch(body, col=SAND)
    for r in (7.5, 4.5):
        st.paint(disc(32, 38, r) & ~disc(32, 38, r - 1.2) & (YY >= 35), '#3e7a2c')
    st.paint(rect(31, 36, 32, 38), SAND)
    happy_arc(st, 22, 26)
    happy_arc(st, 37, 26)
    st.mouth('smile', 30, 30)
    return key, st


# 5. Questionmark Bubble: inner-BBBB double, uncommon (Ring, symmetric).
def questionmark_bubble():
    key = 'pl-labi-5'
    st = Sticker()
    core = (10, 10, 53, 53)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.4), e=('B', 'double', 0, 3.4), s=('B', 'double', 0, 3.4),
                               w=('B', 'double', 0, 3.4))
    body = body & ~(disc(10, 10, 4) & ~disc(14, 14, 4)) & ~(disc(54, 10, 4) & ~disc(50, 14, 4)) & \
        ~(disc(10, 54, 4) & ~disc(14, 50, 4)) & ~(disc(54, 54, 4) & ~disc(50, 50, 4))
    st.part(body, tex=fill(key, body, 10, 10, 44, list(SKYB)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#ffffff', skip=grow(holes, 3))
    st.eye(21, 21, look=(0, -1))
    st.eye(38, 21, look=(0, -1))
    st.mouth('o', 31, 28)
    q = ['.UUUU.', 'UU..UU', '....UU', '...UU.', '..UU..', '..UU..', '......', '..UU..']
    st.sprite(q, 29, 34, {'U': UMBER}, solid=False)
    return key, st


# 6. Plinth Riddler: whimsy-stonegnome keyhole, rare.
def plinth_riddler():
    key = 'pl-labi-6'
    st = Sticker()
    head = ellipse(31.5, 32, 12, 9)
    hat = poly([(18, 27), (31.5, 10), (45, 27)])
    plinth = rect(18, 42, 45, 47)
    tab = knob('s', 'keyhole', 32, 48, r=2.4)
    sil = head | rect(22, 32, 41, 42) | plinth | tab
    st.part(sil, tex=fill(key, sil, 14, 14, 36, list(STONE)), contour=True)
    st.part(plinth | tab, PLINTH, d=2, contour=True)
    st.paint(rect(19, 42, 44, 43), '#5a5662')
    st.part(hat, '#8a8a94', d=2, contour=True)
    st.paint(line([(31, 13), (25, 25)]), '#b4b4bc')
    beard = poly([(23, 35), (40, 35), (31.5, 42)])
    st.part(beard, '#d8d8de', d=1, contour=True)
    st.eye(23, 28)
    st.eye(35, 29, lid=1)
    st.paint(line([(22, 25), (26, 24)]), UMBER)
    st.mouth('smirk', 29, 36)
    st.paint(rect(19, 34, 21, 34) | rect(42, 34, 44, 34), BLUSH)
    st.sparkle(8, 8)
    st.sparkle(50, 12, big=False)
    st.sparkle(8, 40, big=False)
    return key, st


PALS = [cypress_candle, creamsail_dawdle, gatepost_lampshine, hedgerow_swirls, questionmark_bubble, plinth_riddler]

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
