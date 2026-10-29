"""Puzzle Pals: NORTHERN LIGHTS SAUNA (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-aurs-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_aurs.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a lakeside log sauna at blue hour under a faint aurora. kit_lair parts used only as
building blocks (PlacePic, rows, cell_fill, calm_tones, tidy, puff, frost_chip); everything else drawn here.
Silhouette = row shape + knob, body = its own cell of game/assets/img/jigsaw/places/haven-northern-lights-sauna.png,
calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Steam Hello   sauna-paint red        | a stone chimney on top puffing 3 steam clouds       | happy ^ ^ eyes, big grin
  2 Pine Shiver   pine green             | a snowy pine tip crown + shiver marks either side   | wide eyes looking up, 'o' brr
  3 Dock Creak    weathered silver plank | plank seams, nail heads, a little dock post         | side glance, smirk
  4 Green Ripple  aurora green           | wavy light bands across the body, star dots         | eyes look up, soft smile
  5 Cool Dip      lake-ice blue          | dark water hole in the middle, ice shards around    | round eyes, cat mouth
  6 Towel Bear    honey bear brown       | whimsy bear: round ears, pink towel wrap, steam     | sleepy closed lids, smile, blush
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-northern-lights-sauna'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-northern-lights-sauna-d871cc')

RED = ('#9a3a30', '#b65040')
PINE = ('#2e5e44', '#447a56')
PLANK = ('#7e8088', '#9a9ca2')
AURORA = ('#3aa070', '#5cc488')
ICE = ('#6e9cc4', '#92bede')
BEAR = ('#8a5a34', '#a8724a')
STEAM = ('#d8dde6', '#b0b8c6', '#f6f8fc', '#8890a0')
STONE = ('#5a5258', '#3e383e')
SNOW = '#eef6fc'
TOWEL = ('#e08aa0', '#f4b4c4', '#b8607a')
WATER = ('#1e3248', '#2e4a68')
STAR = '#fff4c8'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_down(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def star(st, x, y):
    m = rect(x, y - 1, x, y + 1) | rect(x - 1, y, x + 1, y)
    st.paint(m, STAR, solid=True)
    st.extra |= m


# ------------------------------------------------------------------ 1. Steam Hello: corner-BB round, common.
def steam_hello():
    key = 'pl-aurs-1'
    st = Sticker()
    core = (10, 24, 44, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'round', 4, 3.0), e=('B', 'round', 2, 3.0))
    st.part(body, tex=fill(key, body, 10, 24, 35, list(RED)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (38, 46):                                        # log seams
        st.paint(rect(12, y, 42, y) & shrink(body, 2), '#6e2820')
    st.stitch(body, col='#e6a090', skip=grow(holes, 3))
    chim = rect(34, 14, 40, 24)
    st.part(chim, STONE[0], d=1, contour=True)
    st.paint(rect(34, 18, 40, 18) & chim, STONE[1])
    puff(st, 39, 11, r=2.4, pal=STEAM)
    puff(st, 47, 8, r=2.0, pal=STEAM, lobes=2)
    puff(st, 53, 14, r=1.6, pal=STEAM, lobes=2)
    closed_up(st, 15, 31)
    closed_up(st, 28, 31)
    st.mouth('grin', 21, 38)
    st.paint(rect(13, 36, 15, 36) | rect(32, 36, 34, 36), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Pine Shiver: edge-TBT peg, common.
def pine_shiver():
    key = 'pl-aurs-2'
    st = Sticker()
    core = (16, 26, 46, 54)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 0, 3.4), e=('B', 'peg', 3, 2.8), w=('T', 'peg', 3, 3.4))
    st.part(body, tex=fill(key, body, 16, 26, 31, list(PINE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8ac49a', skip=grow(holes, 3))
    tree = poly([(31, 6), (24, 16), (27, 16), (22, 23), (40, 23), (35, 16), (38, 16)])
    tree = tree | poly([(31, 6), (38, 16), (35, 16), (40, 23), (31, 23)])
    st.part(tree, PINE[1], d=1, contour=True)
    st.paint(tree & ~shift(tree, 0, -1), SNOW)
    st.paint(rect(30, 8, 31, 9), SNOW)
    for sx in (8, 55):                                        # shiver marks
        st.paint(rect(sx, 36, sx, 38) | rect(sx + (1 if sx < 30 else -1), 41, sx + (1 if sx < 30 else -1), 43), STEAM[1], solid=True)
    st.eye(21, 33, look=(0, -1))
    st.eye(35, 33, look=(0, -1))
    st.mouth('o', 30, 42)
    return key, st


# ------------------------------------------------------------------ 3. Dock Creak: inner-TBTB peg, common.
def dock_creak():
    key = 'pl-aurs-3'
    st = Sticker()
    core = (14, 18, 48, 44)
    body, holes = piece_blanks(core, n=('T', 'peg', 0, 3.4), e=('B', 'peg', 0, 2.8), s=('T', 'peg', -6, 3.4), w=('B', 'peg', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 18, 35, list(PLANK)), contour=True)
    st.blank_shade(body, holes, width=1)
    for x in (24, 38):                                        # plank seams
        st.paint(rect(x, 20, x, 42) & shrink(body, 2), '#55565e')
    for nx, ny in ((19, 21), (29, 21), (43, 21), (19, 41), (43, 41)):
        st.paint(rect(nx, ny, nx, ny), '#3e3a3a')
    st.stitch(body, col='#c8b48a', skip=grow(holes, 3))
    post = rect(48, 44, 52, 56)
    st.part(post, '#6a5040', d=1, contour=True)
    st.paint(rect(48, 44, 52, 44), SNOW)
    st.eye(21, 27, look=(1, 0))
    st.eye(33, 27, look=(1, 0))
    st.mouth('smirk', 27, 35)
    st.paint(rect(18, 33, 20, 33) | rect(40, 33, 42, 33), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Green Ripple: inner-TTTT round, uncommon.
def green_ripple():
    key = 'pl-aurs-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'round', 0, 3.6), e=('T', 'round', 0, 3.6), s=('T', 'round', 0, 3.6), w=('T', 'round', 0, 3.6))
    st.part(body, tex=fill(key, body, 18, 18, 28, list(AURORA)), contour=True)
    for base in (23, 40):                                     # symmetric light waves
        m = blank()
        for x in range(19, 45):
            y = base + round(1.5 * math.cos((x - 31.5) / 3.0))
            m |= rect(x, y, x, y)
        st.paint(m & shrink(body, 2), '#a6ecc0')
    st.stitch(body, col='#9a7ad0')                             # uncommon accent: aurora violet
    st.eye(25, 28, look=(0, -1))
    st.eye(34, 28, look=(0, -1))
    st.mouth('smile', 29, 34)
    star(st, 9, 9)
    star(st, 54, 9)
    return key, st


# ------------------------------------------------------------------ 5. Cool Dip: inner-BBBB peg, uncommon.
def cool_dip():
    key = 'pl-aurs-5'
    st = Sticker()
    core = (11, 12, 52, 51)
    body, holes = piece_blanks(core, n=('B', 'peg', 0, 2.8), e=('B', 'peg', 0, 2.8), s=('B', 'peg', 0, 2.8), w=('B', 'peg', 0, 2.8))
    st.part(body, tex=fill(key, body, 11, 12, 42, list(ICE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=RED[1], skip=grow(holes, 3))            # uncommon accent: sauna red
    hole = ellipse(31.5, 40, 9, 4)
    st.paint(hole, WATER[0])
    st.paint(hole & (CY < 38.5), WATER[1])
    st.paint(rect(26, 40, 29, 40), '#6a8ab0')
    st.paint(rect(33, 41, 37, 41), '#6a8ab0')
    st.eye(22, 24, look=(0, 0))
    st.eye(37, 24, look=(0, 0))
    st.mouth('cat', 29, 31)
    st.paint(rect(17, 30, 19, 30) | rect(44, 30, 46, 30), BLUSH)
    for sx, sy in ((17, 44), (46, 44)):
        st.paint(rect(sx, sy, sx + 1, sy) | rect(sx, sy - 1, sx, sy - 1), SNOW)
    return key, st


# ------------------------------------------------------------------ 6. Towel Bear: whimsy-bear round, rare.
def towel_bear():
    key = 'pl-aurs-6'
    st = Sticker()
    head = disc(32, 28, 14)
    ears = disc(21, 16, 4.5) | disc(43, 16, 4.5)
    belly = ellipse(32, 41, 15, 8)
    tab = knob('s', 'round', 32, 48, r=3.2)
    body = head | ears | belly | tab
    st.part(body, tex=fill(key, body, 14, 12, 38, list(BEAR)), contour=True)
    st.paint(disc(21, 16, 2.2) | disc(43, 16, 2.2), '#d49a78')
    towel = belly & (CY > 38)
    st.part(towel, TOWEL[0], d=1, contour=True, rim=False)
    st.paint(towel & ((YY % 4) == 0), TOWEL[1])
    st.paint(rect(32, 39, 36, 44) & towel, TOWEL[2])
    snout = ellipse(32, 32, 5, 3.5)
    st.paint(snout, '#e0b48a')
    st.paint(rect(31, 30, 33, 30), UMBER)
    closed_down(st, 23, 24)
    closed_down(st, 36, 24)
    st.mouth('smile', 30, 34)
    st.paint(rect(20, 30, 22, 30) | rect(42, 30, 44, 30), BLUSH)
    puff(st, 11, 30, r=2.0, pal=STEAM, lobes=2)
    puff(st, 51, 28, r=2.0, pal=STEAM, lobes=2)
    st.sparkle(11, 10)
    st.sparkle(51, 10, big=False)
    st.sparkle(32, 7, big=False)
    return key, st


PALS = [steam_hello, pine_shiver, dock_creak, green_ripple, cool_dip, towel_bear]

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
