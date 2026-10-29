"""Puzzle Pals: FLOATING MARKET (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-flmk-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_flmk.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a bright-morning Southeast-Asian canal market. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-floating-market.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Noodle Awning    awning red               | red+white scalloped awning on top + a flapping pennant  | wide round eyes, toothy grin
  2 Shutter Hello    stilt-house wood brown   | two open green shutters as waving arms, a window lamp   | happy ^ ^ eyes, big grin
  3 Stir Wave        pot iron slate           | a ladle stuck in, steam curls, a waving mitten hand     | sleepy lids, 'o'
  4 Coconut Lookout  palm green               | palm fronds crown (symmetric) + 2 coconuts below        | side glance, smirk
  5 Basket Rock      wicker tan-orange        | woven rim, melons + mango heaped in, ripple             | closed v v eyes, cat mouth, blush
  6 Noodle Skipper   bowl cream + blue band   | whimsy noodle bowl, pointed straw gnome hat, chopsticks, steam, glow | round eyes, smile, white beard
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-floating-market'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-floating-market-f899c8')

AWNRED = ('#c23a32', '#dc5a48')
WOOD = ('#8e5a36', '#a87048')
SLATE = ('#56606a', '#6e7a84')
PALM = ('#3e8a3e', '#56a04a')
WICKER = ('#c8843a', '#dca055')
BOWL = ('#eee2c4', '#fbf2dc')
SHUT = ('#3f8a72', '#5aa88c', '#2a6452')
LAMP = '#ffd96a'
STEAM = ('#e6eef0', '#ffffff')
FROND = ('#2f6a2a', '#4f9a3a', '#7cc458')
COCO = ('#6a4228', '#8a5a34', '#4a2c1a')
MELON = ('#7cba4a', '#4f8a2e', '#a8d870')
MANGO = ('#f2b22e', '#d8861e')
CANAL = ('#499291', '#7cc0bc')
BLUEB = ('#3a6ab4', '#5a8ad4')
STRAWH = ('#e8c66a', '#c09a3e', '#f8e49a')
NOODLE = ('#f4d98a', '#e0b860')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_v(st, x, y):
    st.sprite(['U...U', '.U.U.', '..U..'], x, y, {'U': UMBER}, solid=False)


def curl(st, x, y, n=2):
    for k in range(n):
        m = (rect(x + k * 4, y - 5 * k, x + k * 4 + 1, y - 5 * k) | rect(x + k * 4 + 2, y - 5 * k - 1, x + k * 4 + 2, y - 5 * k - 2)
             | rect(x + k * 4 + 1, y - 5 * k - 3, x + k * 4 + 1, y - 5 * k - 3))
        st.paint(m, STEAM[0], solid=True)
        st.extra |= m


def ripple(st, cx, cy, rx):
    m = ellipse(cx, cy, rx, 2.0) & ~ellipse(cx, cy - 0.5, rx - 1.5, 1.2)
    st.paint(m, CANAL[0], solid=True)
    st.paint(m & (CY < cy), CANAL[1])
    st.extra |= m


def frond(st, x, y, ang, L):
    a = math.radians(ang)
    m = blank()
    for i in range(L):
        m |= disc(x + i * math.cos(a), y + i * math.sin(a) + 0.05 * i * i, 2.0 * (1 - i / L) + 0.8)
    st.part(m, FROND[1], d=1, contour=True)
    st.paint(m & ~shift(m, 0, -1), FROND[2])
    return m


# ------------------------------------------------------------------ 1. Noodle Awning: corner-TB round, common.
def noodle_awning():
    key = 'pl-flmk-1'
    st = Sticker()
    core = (12, 24, 44, 51)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', 4, 3.6), e=('B', 'round', 3, 2.8))
    st.part(body, tex=fill(key, body, 12, 24, 33, list(AWNRED)), contour=True)
    st.blank_shade(body, holes, width=1)
    # awning: stripes across the top band with a scalloped hem
    band = body & (CY < 32)
    st.paint(band & ((XX // 4) % 2 == 0), '#f6f0e4')
    for sx in range(12, 45, 4):
        sc = disc(sx + 2, 32, 2.0) & (CY >= 32) & body
        st.paint(sc, '#f6f0e4' if (sx // 4) % 2 == 0 else AWNRED[1])
    st.stitch(body & (CY > 34), col='#f6c0a0', skip=grow(holes, 3))
    # pennant flapping on a pole off the top tab
    pole = rect(39, 8, 39, 21)
    st.part(pole, '#8a5a34', d=1, contour=True)
    flag = poly([(40, 8), (48, 10.5), (40, 13)])
    st.part(flag, '#f2b22e', d=1, contour=True)
    st.eye(19, 38, look=(1, 0))
    st.eye(32, 38, look=(1, 0))
    st.mouth('tooth', 24, 44)
    st.paint(rect(15, 44, 17, 44) | rect(37, 44, 39, 44), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Shutter Hello: edge-TTB peg, common.
def shutter_hello():
    key = 'pl-flmk-2'
    st = Sticker()
    core = (17, 24, 45, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', -4, 3.4), e=('T', 'peg', -2, 3.4), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 17, 24, 29, list(WOOD)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(body & (YY % 4 == 0) & shrink(body, 2), '#74462a')           # plank lines
    st.stitch(body, col='#d8a878', skip=grow(holes, 3))
    # little window above with warm lamp; shutters swung wide like waving arms
    win = rect(24, 36, 37, 46)
    st.part(win, '#3a2a20', d=1, contour=True)
    st.paint(rect(26, 38, 35, 44), LAMP)
    st.paint(rect(30, 38, 31, 44) | rect(26, 41, 35, 41), '#8e5a36')
    for x0 in (16, 38):
        sh = rect(x0, 35, x0 + 6, 47)
        st.part(sh, SHUT[0], d=1, contour=True)
        st.paint(sh & (YY % 3 == 0) & shrink(sh, 1), SHUT[2])
        st.paint(rect(x0 + 1, 36, x0 + 1, 46), SHUT[1])
    closed_up(st, 23, 28)
    closed_up(st, 34, 28)
    st.mouth('grin', 29, 31)
    st.paint(rect(20, 31, 22, 31) | rect(40, 31, 42, 31), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Stir Wave: inner-TBTB round, common.
def stir_wave():
    key = 'pl-flmk-3'
    st = Sticker()
    core = (14, 22, 46, 46)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', -6, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 22, 33, list(SLATE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(body & (CY < 26) & (CY > 22) & shrink(body, 1), '#3e464e')
    st.paint(body & (CY > 22) & (CY < 24) & shrink(body, 1), '#8e9aa4')
    st.stitch(body & (CY > 26), col='#a8b4bc', skip=grow(holes, 3))
    # ladle sticking out up-right
    lad = line([(38, 24), (47, 10)], w=2)
    st.part(lad, '#a8743e', d=1, contour=True)
    # waving mitten hand on the left
    hand = disc(12, 17, 3.2) | rect(11, 19, 13, 22)
    st.part(hand, '#f0c8a0', d=1, contour=True)
    st.paint(rect(7, 12, 7, 14) | rect(6, 16, 6, 18), STEAM[0], solid=True)
    st.extra |= rect(6, 12, 7, 18)
    curl(st, 24, 15, 2)
    st.eye(22, 31, lid=3)
    st.eye(35, 31, lid=3)
    st.mouth('o', 29, 38)
    st.paint(rect(18, 37, 20, 37) | rect(39, 37, 41, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Coconut Lookout: inner-TTTT peg, uncommon.
def coconut_lookout():
    key = 'pl-flmk-4'
    st = Sticker()
    core = (17, 18, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 18, 30, list(PALM)), contour=True)
    st.stitch(body, col=CANAL[1])                                   # uncommon accent: canal teal
    for ang in (-150, -30):
        frond(st, 31.5, 11, ang, 14)
    st.part(disc(31.5, 11, 2.4), COCO[1], d=1, contour=True)
    for cx in (25, 38):
        c = disc(cx, 45, 2.8)
        st.part(c, COCO[0], d=1, contour=True)
        st.paint(disc(cx - 1, 44, 0.8), COCO[1], solid=True)
    st.eye(25, 29, look=(1, 0))
    st.eye(37, 29, look=(1, 0))
    st.mouth('smirk', 29, 37)
    return key, st


# ------------------------------------------------------------------ 5. Basket Rock: inner-BBBB round, uncommon.
def basket_rock():
    key = 'pl-flmk-5'
    st = Sticker()
    core = (11, 13, 52, 50)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(WICKER)), contour=True)
    inner = shrink(body, 2)
    st.paint(inner & ((XX + YY) % 4 == 0), '#9a5e26')
    st.paint(inner & ((XX - YY) % 4 == 0), '#f0c27a')
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=CANAL[0], skip=grow(holes, 3))              # uncommon accent: canal teal
    for cx, cy, r, P in ((22, 18, 5, MELON), (42, 18, 5, MELON), (32, 17, 4, MANGO)):
        f = disc(cx, cy, r) & body
        st.part(f, P[0], d=1, contour=True)
        st.paint(disc(cx - 1.5, cy - 1.5, 1.2) & f, P[-1] if P is MELON else '#fde08a')
    face = ellipse(32, 34, 13, 8)
    st.paint(face & ~holes, '#e6b878')
    closed_v(st, 23, 31)
    closed_v(st, 37, 31)
    st.mouth('cat', 30, 36)
    st.paint(rect(20, 36, 22, 36) | rect(42, 36, 44, 36), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Noodle Skipper: whimsy-noodlebowl round, rare.
def noodle_skipper():
    key = 'pl-flmk-6'
    st = Sticker()
    bowl = ellipse(32, 37, 21, 12) & (CY > 35)
    rimm = ellipse(32, 35, 21, 4)
    foot = rect(25, 47, 39, 50)
    hat = poly([(16, 23), (32, 9), (48, 23)])
    head = ellipse(32, 28, 10, 7)
    tab = knob('s', 'round', 32, 50, r=2.8)
    body = bowl | rimm | foot | head | tab
    st.part(body, tex=fill(key, body, 12, 20, 40, list(BOWL)), contour=True)
    st.paint(bowl & (CY > 41) & (CY < 44), BLUEB[0])
    st.paint(bowl & (CY > 41) & (CY < 44) & (XX % 4 == 0), BLUEB[1])
    nood = ellipse(32, 35, 18, 2.6)
    st.paint(nood, NOODLE[0])
    st.paint(nood & ((XX + YY) % 3 == 0), NOODLE[1])
    # face with white beard over the rim
    beard = ellipse(32, 34, 7, 4.5)
    st.part(beard, '#f4f0ea', d=1, contour=True)
    st.paint(beard & ((XX + YY) % 4 == 0), '#d8d2c8')
    st.part(hat, STRAWH[0], d=1, contour=True)
    st.paint(hat & ((XX + 2 * YY) % 5 == 0), STRAWH[1])
    st.paint(hat & (CX < 32) & (CY < 18), STRAWH[2])
    st.eye(27, 28, look=(0, 0))
    st.eye(37, 28, look=(0, 0))
    st.mouth('smile', 30, 33)
    st.paint(rect(22, 31, 23, 31) | rect(41, 31, 42, 31), BLUSH)
    sticks = line([(45, 33), (52, 17)]) | line([(47, 34), (54, 19)])
    st.part(sticks, '#a8743e', d=0, contour=True, shade=False)
    curl(st, 11, 31, 2)
    st.sparkle(9, 10)
    st.sparkle(52, 9, big=False)
    st.sparkle(51, 46, big=False)
    return key, st


PALS = [noodle_awning, shutter_hello, stir_wave, coconut_lookout, basket_rock, noodle_skipper]

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
