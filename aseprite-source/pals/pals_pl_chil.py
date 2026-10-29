"""Puzzle Pals: MARKET OF A THOUSAND CHILIES (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-chil-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_chil.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a bright Central American market plaza. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-market-of-a-thousand-chilies.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Stripe Shade    awning sand cream      | red-and-cream striped scalloped awning brim on top | side glance, smirk
  2 Pennant Wave    plaza sky blue         | a pole with a red swallowtail pennant              | wide open eyes, big grin
  3 Cocoa Curl      chimney-smoke grey     | a curling smoke wisp rising off the head           | happy closed ^ ^ eyes, smile
  4 Chili Cluster   stall-wood amber       | a pile of red chilies on top + chilies on each tab | wide eyes, toothy spicy grin
  5 Cocoa Cauldron  cocoa brown            | a black cocoa pot with bubbles                     | sleepy heavy lids, cat mouth
  6 Pepper Prince   chili red (whimsy)     | green calyx + tiny gold crown, glow                | closed smiling lids, 'o', blush
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-market-of-a-thousand-chilies'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-market-of-a-thousand-chilies-ba9373')

SAND = ('#c8a870', '#dcc28e')
SKY = ('#4f86c0', '#6ea2d6')
SMOKE = ('#9a98a6', '#bcbac6')
AMBER = ('#b8782e', '#d09440')
COCOA = ('#652d25', '#7e3e30')
CHILI = ('#c42a22', '#de4430')
STRIPE = ('#c8302a', '#f2e6c8')
FLAG = ('#d0342a', '#f06a48', '#8a1e18')
POLE = ('#6a4428', '#8a6038')
WISP = ('#e8e6ee', '#c8c6d2')
STEM = ('#3e7a2c', '#5ea040', '#2a5420')
POT = ('#2a2220', '#4a3c38', '#1a1412')
CROWN = ('#f0c040', '#fff0a0', '#b8862a')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_shut(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def smile_shut(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def awning(st, x0, x1, y0, y1):
    m = rect(x0, y0, x1, y1)
    for sx in range(x0 + 2, x1, 4):
        m |= disc(sx + 0.5, y1, 2.0)
    st.part(m, STRIPE[1], d=1, contour=True, rim=False)
    st.paint(m & (((XX - x0) // 4) % 2 == 0), STRIPE[0])
    st.paint(rect(x0, y0, x1, y0), '#8a1e18')
    return m


def pennant(st, px, top, bot, tip):
    pole = rect(px, top, px + 1, bot)
    st.part(pole, POLE[0], d=1, contour=True, rim=False)
    st.paint(rect(px, top - 1, px + 1, top - 1), CROWN[0], solid=True)
    f = poly([(px - 1, top + 1), (tip, top + 3), (tip + 4, top + 5.5), (tip, top + 8), (px - 1, top + 10)])
    st.part(f, FLAG[0], d=1, contour=True)
    st.paint(f & (CY < top + 4), FLAG[1])
    st.paint(rect(tip + 6, top + 5, px - 4, top + 5) & f, '#f2e6c8')


def wisp(st, pts):
    m = blank()
    for i, (x, y, r) in enumerate(pts):
        m |= disc(x, y, r)
    st.part(m, WISP[0], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 1), '#ffffff')
    return m


def chili(st, x, y, ang, L=7):
    a = math.radians(ang)
    m = blank()
    for i in range(L):
        m |= disc(x + i * math.cos(a), y + i * math.sin(a), 1.9 * (1 - i / (L + 2)) + 0.4)
    st.part(m, CHILI[0], d=1, contour=True)
    st.paint(m & ~shift(m, 0, -1), CHILI[1])
    sx, sy = int(round(x - 1.5 * math.cos(a))), int(round(y - 1.5 * math.sin(a)))
    st.paint(rect(sx - 1, sy, sx, sy) | rect(sx, sy - 1, sx, sy), STEM[1], solid=True)
    return m


def cocoa_pot(st, cx, cy, r):
    m = disc(cx, cy, r) & (CY >= cy - r * 0.35)
    st.part(m, POT[0], d=1, contour=True)
    st.paint(m & (CX < cx - r * 0.5) & (CY < cy + r * 0.5), POT[1])
    lip = rect(int(cx - r - 1), int(cy - r * 0.35) - 1, int(cx + r + 1), int(cy - r * 0.35))
    st.part(lip, POT[1], d=1, contour=True, rim=False)
    st.paint(rect(int(cx - r + 1), int(cy - r * 0.35) - 1, int(cx + r - 1), int(cy - r * 0.35) - 1), '#8a4a30')
    for bx, by in ((cx - 3, cy - r * 0.35 - 4), (cx + 2, cy - r * 0.35 - 6), (cx + 0, cy - r * 0.35 - 9)):
        b = disc(bx, by, 1.3)
        st.paint(b, '#c89a7a', solid=True)
        st.extra |= grow(b, 1)


# ------------------------------------------------------------------ 1. Stripe Shade: corner-TB round, common.
def stripe_shade():
    key = 'pl-chil-1'
    st = Sticker()
    core = (12, 24, 44, 52)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', 4, 3.6), e=('B', 'round', 2, 2.8))
    st.part(body, tex=fill(key, body, 12, 24, 33, list(SAND)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a07e48', skip=grow(holes, 3))
    awning(st, 9, 47, 18, 22)
    st.eye(18, 31, look=(1, 0))
    st.eye(30, 31, look=(1, 0))
    st.mouth('smirk', 23, 41)
    st.paint(rect(14, 39, 16, 39) | rect(36, 39, 38, 39), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Pennant Wave: edge-BTB peg, common.
def pennant_wave():
    key = 'pl-chil-2'
    st = Sticker()
    core = (14, 24, 44, 51)
    body, holes = piece_blanks(core, s='F', n=('B', 'peg', 0, 2.8), e=('T', 'peg', 3, 3.4), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 14, 24, 31, list(SKY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c8e0f4', skip=grow(holes, 3))
    pennant(st, 46, 9, 27, 22)
    st.eye(19, 32, look=(0, -1))
    st.eye(32, 32, look=(0, -1))
    st.mouth('grin', 25, 41)
    st.paint(rect(16, 39, 18, 39) | rect(38, 39, 40, 39), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Cocoa Curl: inner-TBTB round, common.
def cocoa_curl():
    key = 'pl-chil-3'
    st = Sticker()
    core = (14, 22, 46, 46)
    body, holes = piece_blanks(core, n=('T', 'round', 4, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', -6, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 22, 33, list(SMOKE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e8e6ee', skip=grow(holes, 3))
    wisp(st, [(28, 16, 2.4), (24, 13, 2.1), (25, 10, 1.8), (29, 8, 1.6), (32, 10, 1.3)])
    happy_shut(st, 21, 31)
    happy_shut(st, 34, 31)
    st.mouth('smile', 27, 37)
    st.paint(rect(18, 35, 20, 35) | rect(39, 35, 41, 35), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Chili Cluster: inner-TTTT peg, uncommon.
def chili_cluster():
    key = 'pl-chil-4'
    st = Sticker()
    core = (17, 20, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 20, 30, list(AMBER)), contour=True)
    for y in (39, 43):                                         # stall plank lines
        st.paint(rect(19, y, 44, y) & body, '#8a5420')
    st.stitch(body, col=CHILI[1])                              # uncommon accent: chili red
    for x, a in ((23, 160), (40, 20)):
        chili(st, x, 20, a, 8)
    chili(st, 31.5, 11, 90, 8)
    st.eye(24, 27, look=(0, 0))
    st.eye(35, 27, look=(0, 0))
    st.mouth('tooth', 29, 34)
    return key, st


# ------------------------------------------------------------------ 5. Cocoa Cauldron: inner-BBBB round, uncommon.
def cocoa_cauldron():
    key = 'pl-chil-5'
    st = Sticker()
    core = (11, 13, 52, 50)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(COCOA)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=SAND[1], skip=grow(holes, 3))         # uncommon accent: plaza sand
    st.eye(23, 21, lid=2)
    st.eye(36, 21, lid=2)
    st.mouth('cat', 29, 28)
    cocoa_pot(st, 31.5, 41, 7)
    st.paint(rect(18, 27, 20, 27) | rect(43, 27, 45, 27), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Pepper Prince: whimsy-chili peg, rare.
def pepper_prince():
    key = 'pl-chil-6'
    st = Sticker()
    pod = ellipse(31, 31, 13, 10)
    for i in range(16):
        t = i / 15.0
        pod |= disc(31 + 9 * t * t, 36 + 16 * t, 11 * (1 - t) + 1.2)
    tab = knob('w', 'peg', 30, 20, r=3.0)
    body = pod | tab
    st.part(body, tex=fill(key, body, 14, 20, 34, list(CHILI)), contour=True)
    st.paint(body & ~shift(body, 1, 1) & ~shift(body, 2, 2) & (CY < 46), '#f06a48')
    calyx = ellipse(31, 21, 9, 3.2) | rect(30, 16, 32, 20)
    st.part(calyx, STEM[0], d=1, contour=True)
    st.paint(calyx & (CY < 21), STEM[1])
    cr = rect(25, 14, 37, 17) | poly([(25, 14), (25, 9), (28, 13)]) | poly([(37, 14), (37, 9), (34, 13)])
    cr |= rect(30, 9, 32, 14)
    st.part(cr, CROWN[0], d=1, contour=True, rim=False)
    st.paint(rect(26, 15, 36, 15), CROWN[2])
    st.paint(rect(31, 15, 31, 15), '#d0342a', solid=True)
    smile_shut(st, 23, 27)
    smile_shut(st, 35, 27)
    st.mouth('o', 30, 32)
    st.paint(rect(20, 31, 22, 31) | rect(40, 31, 42, 31), BLUSH)
    st.sparkle(8, 10)
    st.sparkle(51, 18, big=False)
    st.sparkle(48, 6, big=False)
    return key, st


PALS = [stripe_shade, pennant_wave, cocoa_curl, chili_cluster, cocoa_cauldron, pepper_prince]

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
