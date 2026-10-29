"""Puzzle Pals: PRAYER-FLAG PASS (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wpry-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wpry.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: pass sprites, keyhole knobs, soft and hopeful. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-prayer-flag-pass.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Gilded Nubbin         polished gold                | a pole-top gold ball on a short brass stub, shine glints          | proud closed-eye smile, chin up
  2 Glacier Hat           glacier ice white-blue       | a snowy peak hat (white cap on slate rock), flurry flakes         | chilly squint, wobbly mouth
  3 Pilgrim Pebble        trail dust tan               | a small pebble held overhead in stubby hands, footprint dots      | wide hopeful eyes, o mouth
  4 Windtalking Bunting   sky blue (+ flag red stitch) | a string of blue/green/red/yellow flags strung round its top     | open singing mouth, happy ^ ^
  5 Stone Doughnuts       slate grey (+ gold stitch)   | a stacked cairn ring of three flat stones below a tiny wish flag  | sleepy content lids, cat mouth
  6 Redsaddle Yak         shaggy umber + red saddle    | whimsy yak with horns, red saddle, flag on its pack, glow (rare)  | patient half-lids, flat smile
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-prayer-flag-pass'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-prayer-flag-pass-4260ac')

GOLD = ('#c89a3a', '#e6c062')          # polished gold
ICE = ('#bcd4e4', '#e2eef4')           # glacier white-blue
DUST = ('#a89a78', '#c4b892')          # trail dust tan
SKY = ('#669bc7', '#8cb8dc')           # pass sky blue
SLATE = ('#5e5a62', '#7c7882')         # cairn slate
SHAG = ('#5a3e2c', '#7a5a40')          # yak umber (rare)
BRASS = ('#8a6a2a', '#5a441a', '#b89448')
ROCK = ('#4a4652', '#34303a', '#6a6672')
SNOWC = ('#f4f6f8', '#c8d4de')
FLAGS = ('#3a6ab4', '#4a9a4a', '#c43a3a', '#e0b83a', '#f0ece0')
SADDLE = ('#c43a3a', '#8a2424', '#e86a5a')
HORN = ('#e8dcc0', '#b0a080')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def flag_string(st, pts, size=4):
    """A sagging cord through pts with little triangle flags hanging off it, colours cycling."""
    cord = line(pts, w=1)
    st.paint(cord, '#3a3236', solid=True)
    k = 0
    for (a, b), (c, d) in zip(pts, pts[1:]):
        n = max(1, int(abs(c - a) // (size + 1)))
        for i in range(n):
            x = int(a + (c - a) * (i + 0.5) / n)
            y = int(b + (d - b) * (i + 0.5) / n)
            m = poly([(x - size / 2, y), (x + size / 2, y), (x, y + size + 1)])
            col = FLAGS[k % 4]
            st.paint(m, col, solid=True)
            st.paint(m & (CX < x - 0.2), FLAGS[4] if col == FLAGS[3] else col)
            k += 1


def wish_flag(st, x, y, col):
    st.paint(rect(x, y, x, y + 8), BRASS[1], solid=True)
    st.paint(poly([(x + 1, y), (x + 6, y + 1.5), (x + 1, y + 3.5)]), col, solid=True)


def flake(st, x, y):
    for dx, dy in ((0, 0), (-1, 0), (1, 0), (0, -1), (0, 1)):
        st.px[y + dy, x + dx] = hx(SNOWC[0])
        st.extra[y + dy, x + dx] = True


def flat_stone(st, cx, cy, rx, ry, tone):
    m = ellipse(cx, cy, rx, ry)
    st.part(m, tone, d=1, contour=True)
    st.paint(m & ~shift(m, 0, 1) & ~shift(m, 0, -1) | (m & ~shift(m, 0, 1)), ROCK[2])
    return m


# ------------------------------------------------------------------ 1. Gilded Nubbin: corner-TT keyhole, common.
def gilded_nubbin():
    key = 'pl-wpry-1'
    st = Sticker()
    core = (14, 17, 44, 47)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 14, 17, 31, list(GOLD)), contour=True)
    st.stitch(body, col='#fff0b0')
    # brass pole stub it sits on, and the big ball shine
    st.part(rect(27, 48, 31, 53), BRASS[0], d=1, contour=True)
    st.paint(rect(27, 48, 27, 53), BRASS[2])
    st.part(ellipse(29, 54, 6, 1.6), BRASS[1], d=1, contour=True)
    st.paint(disc(19.5, 22.5, 2.2), '#fff6d0')
    st.sparkle(50, 12, big=False)
    st.sparkle(8, 16, big=False)
    closed_eye(st, 19, 29)
    closed_eye(st, 33, 29)
    st.mouth('smile', 26, 37)
    st.paint(rect(16, 34, 18, 34) | rect(39, 34, 41, 34), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Glacier Hat: edge-TBB keyhole, common.
def glacier_hat():
    key = 'pl-wpry-2'
    st = Sticker()
    core = (13, 24, 50, 52)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 2, 3.0), w=('B', 'keyhole', 2, 3.0))
    st.part(body, tex=fill(key, body, 13, 24, 38, list(ICE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#7a9ab4', skip=grow(holes, 3))
    # peak hat: slate rock cone with a snow cap, sitting over the top knob
    peak = poly([(18, 27), (32, 8), (46, 27)])
    st.part(peak, ROCK[0], d=1, contour=True)
    st.paint(peak & (CX < 31), ROCK[2])
    cap = peak & (CY < 16 + ((XX % 4) == 0))
    st.paint(cap, SNOWC[0], solid=True)
    st.paint(cap & (CX > 33), SNOWC[1])
    st.paint(rect(17, 27, 47, 28) & grow(peak, 1), SNOWC[1], solid=True)
    flake(st, 8, 12)
    flake(st, 55, 16)
    flake(st, 52, 9)
    st.paint(line([(19, 34), (24, 35)]) | line([(36, 35), (41, 34)]), UMBER)     # chilly squint
    st.paint(rect(20, 37, 23, 37) | rect(37, 37, 40, 37), UMBER)
    st.sprite(['U.U.U', '.U.U.'], 28, 43, {'U': UMBER}, solid=False)               # shivery wobble
    st.paint(rect(17, 41, 19, 41) | rect(42, 41, 44, 41), '#b4d0f0')
    return key, st


# ------------------------------------------------------------------ 3. Pilgrim Pebble: inner-TBTB keyhole, common.
def pilgrim_pebble():
    key = 'pl-wpry-3'
    st = Sticker()
    core = (13, 17, 49, 47)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 13, 17, 37, list(DUST)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#6a5a3e', skip=grow(holes, 3))
    # little lucky pebble held up in two stubby hands
    st.part(ellipse(17, 14, 3, 2.4), DUST[0], d=1, contour=True)
    st.part(ellipse(45, 14, 3, 2.4), DUST[0], d=1, contour=True)
    pb = ellipse(31, 10, 6, 3.4)
    st.part(pb, '#8a8490', d=1, contour=True)
    st.paint(disc(29, 7.5, 1.4), '#c4bec8')
    st.sparkle(42, 5, big=False)
    for x, y in ((6, 50), (9, 56), (54, 50), (57, 56)):
        st.px[y, x] = hx('#6a5a3e')
        st.extra[y, x] = True
    st.eye(21, 25, look=(0, -1))
    st.eye(36, 25, look=(0, -1))
    st.mouth('o', 30, 35)
    return key, st


# ------------------------------------------------------------------ 4. Windtalking Bunting: inner-TTTT double, uncommon.
def windtalking_bunting():
    key = 'pl-wpry-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(SKY)), contour=True)
    st.stitch(body, col=SADDLE[2])                                # uncommon accent: flag red
    flag_string(st, [(18, 21), (32, 25), (46, 21)])
    happy_eye(st, 21, 31)
    happy_eye(st, 38, 31)
    st.sprite(['.UUUU.', 'URRRRU', '.URRU.'], 29, 37, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(19, 36, 21, 36) | rect(42, 36, 44, 36), BLUSH)
    for x, y in ((6, 10), (8, 9), (55, 52), (57, 51)):            # wind wisps
        st.px[y, x] = hx(FLAGS[4])
        st.extra[y, x] = True
    return key, st


# ------------------------------------------------------------------ 5. Stone Doughnuts: inner-BBBB keyhole, uncommon.
def stone_doughnuts():
    key = 'pl-wpry-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(SLATE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=GOLD[1], skip=grow(holes, 3))            # uncommon accent: pole gold
    for cy, rx in ((48, 13), (43, 10.5), (38.5, 8)):              # the cairn of stone rings
        m = ellipse(31.5, cy, rx, 2.6)
        st.part(m, DUST[0], d=1, contour=True)
        st.paint(m & ~shift(m, 0, -1), DUST[1])
        st.paint(ellipse(31.5, cy - 0.5, rx * 0.35, 0.9), ROCK[1])
    st.paint(rect(31, 26, 32, 36), BRASS[0], solid=True)
    st.paint(poly([(33, 26), (39, 27.5), (33, 29.5)]), FLAGS[3], solid=True)
    st.paint(poly([(30, 26), (24, 27.5), (30, 29.5)]), FLAGS[3], solid=True)
    st.eye(19, 22, lid=2)
    st.eye(39, 22, lid=2)
    st.mouth('cat', 30, 31)
    st.paint(rect(15, 30, 17, 30) | rect(46, 30, 48, 30), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Redsaddle Yak: whimsy-yak keyhole, rare.
def redsaddle_yak():
    key = 'pl-wpry-6'
    st = Sticker()
    torso = ellipse(36, 36, 17, 11)
    head = ellipse(18, 30, 9, 8)
    tab = knob('n', 'keyhole', 36, 25.5, r=3.0)
    legs = rect(24, 44, 28, 54) | rect(44, 44, 48, 54)
    st.part(legs, SHAG[0], d=1, contour=True)
    st.paint(rect(24, 53, 28, 54) | rect(44, 53, 48, 54), ROCK[1])
    # horns
    hl = line([(13, 25), (10, 20), (11, 15)], w=2)
    hr = line([(23, 24), (27, 19), (26, 15)], w=2)
    st.part(hl | hr, HORN[0], d=1, contour=True)
    body = torso | head | tab
    st.part(body, tex=fill(key, body, 6, 20, 48, list(SHAG)), contour=True)
    # shaggy fringe under belly
    for x in range(22, 52, 3):
        st.paint(rect(x, 45, x, 47) & grow(torso, 2), SHAG[0], solid=True)
    # red saddle with trim + flag on its pack
    sd = rect(29, 27, 44, 38) & torso
    st.part(sd, SADDLE[0], d=1, contour=True)
    st.paint(rect(31, 30, 42, 35) & sd, SADDLE[2])
    st.paint(rect(29, 38, 44, 38) & grow(sd, 1), FLAGS[3])
    st.paint(rect(37, 8, 37, 26), BRASS[1], solid=True)
    st.paint(poly([(38, 8), (45, 10), (38, 13)]), FLAGS[0], solid=True)
    st.paint(poly([(38, 13), (44, 15), (38, 18)]), FLAGS[2], solid=True)
    # face: fluffy fringe, patient eyes, muzzle
    st.paint(rect(12, 23, 24, 24) & head, SHAG[1])
    st.eye(12, 26, lid=1)
    st.eye(19, 26, lid=1)
    st.part(ellipse(17, 34.5, 5, 2.6), HORN[0], d=1, contour=True)
    st.mouth('smile', 15, 35)
    st.sparkle(52, 8)
    st.sparkle(9, 46, big=False)
    st.sparkle(56, 30, big=False)
    return key, st


PALS = [gilded_nubbin, glacier_hat, pilgrim_pebble, windtalking_bunting, stone_doughnuts, redsaddle_yak]

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
