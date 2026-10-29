"""Puzzle Pals: HANGING GARDEN RUINS (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-hang-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_hang.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: garden sprites, keyhole knobs, golden-hour calm. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px
cell of game/assets/img/jigsaw/places/wonder-the-hanging-garden-ruins.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Fruit Tray Tumble     plum purple                  | a wicker tray rim with red/green/purple fruit tumbling on top  | dizzy swirl eyes, wavy grin
  2 Leaning Palm Fringe   palm trunk tan-brown         | a leaning palm crown of green fronds over its top knob         | one-eye wink, side smile
  3 Brimful Pool          pool blue                    | a ripple ring and droplets splashing at the brim               | wide sparkly eyes, o mouth
  4 Berrybush Bobbles     bush green (+ berry red)     | red berry bobbles dotted all over, leaf sprig top              | happy ^ ^, open laugh
  5 Vine Curtain Gateway  sandstone (+ vine green)     | a stone arch lintel with two mirrored vines dangling           | sleepy lids, cat mouth
  6 Swallow Swoop         swallow navy + cream belly   | whimsy swallow, forked tail, seed in beak, glow (rare)         | bright bead eye, beak
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-hanging-garden-ruins'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-hanging-garden-ruins-f5f93d')

PLUM = ('#7a4a7e', '#9c6aa0')          # fruit plum
TRUNK = ('#9a6a42', '#bc8a5a')         # palm trunk
POOL = ('#4a8ac4', '#74b0e0')          # little pool
BUSH = ('#5a8a3a', '#7aaa52')          # berry bush
SAND = ('#c49a68', '#e0bc88')          # sandstone arch
NAVY = ('#2e3a6a', '#46568a')          # swallow (rare)
CREAM = ('#f4e8cc', '#d8c8a4')
LEAF = ('#3a7a32', '#5aa04a', '#2a5a24')
BERRY = ('#c43a3a', '#e86a5a')
FRUIT = ('#c43a3a', '#5aa04a', '#8a4a9a', '#e0b83a')
WICK = ('#a0743a', '#6a4a22')
WATER = ('#a8d8f4', '#ffffff')
STONE = ('#a07a50', '#7a5a38', '#c8a478')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def dot(st, x, y, col):
    st.px[y, x] = hx(col)
    st.extra[y, x] = True


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def swirl_eye(st, x, y):
    st.sprite(['.UUU.', 'U...U', 'U.U.U', 'U..U.', '.UU..'], x, y, {'U': UMBER}, solid=False)


def fruit(st, cx, cy, r, col):
    m = disc(cx, cy, r)
    st.part(m, col, d=1, contour=True)
    st.paint(disc(cx - r * 0.4, cy - r * 0.4, max(0.8, r * 0.3)), '#fff4f0')
    return m


def vine(st, x, y0, y1, flip):
    for y in range(y0, y1):
        xx = x + (1 if (y // 3) % 2 else 0) * flip
        st.paint(rect(xx, y, xx, y), LEAF[2], solid=True)
        if y % 4 == 1:
            st.paint(rect(xx - 2 if flip > 0 else xx + 1, y, xx - 1 if flip > 0 else xx + 2, y), LEAF[1], solid=True)


# ------------------------------------------------------------------ 1. Fruit Tray Tumble: corner-TB keyhole, common.
def fruit_tray():
    key = 'pl-hang-1'
    st = Sticker()
    core = (12, 22, 44, 52)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 12, 22, 33, list(PLUM)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#d8b0dc', skip=grow(holes, 3))
    # wicker tray rim under the fruit, fruit tumbling on top
    st.part(rect(14, 20, 42, 23), WICK[0], d=1, contour=True)
    for x in range(15, 42, 3):
        st.paint(rect(x, 21, x, 22), WICK[1])
    fruit(st, 20, 15, 3.5, FRUIT[0])
    fruit(st, 28, 12, 3.2, FRUIT[2])
    fruit(st, 36, 15, 3.5, FRUIT[1])
    fruit(st, 45, 9, 2.6, FRUIT[0])
    st.paint(rect(28, 7, 28, 8), LEAF[2], solid=True)
    swirl_eye(st, 17, 30)
    swirl_eye(st, 31, 30)
    st.sprite(['U.U.U', '.U.U.'], 25, 41, {'U': UMBER}, solid=False)
    st.paint(rect(14, 38, 16, 38) | rect(38, 38, 40, 38), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Leaning Palm Fringe: edge-TTB keyhole, common.
def palm_fringe():
    key = 'pl-hang-2'
    st = Sticker()
    core = (13, 26, 50, 53)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 13, 26, 38, list(TRUNK)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#5a3a1e', skip=grow(holes, 3))
    # leaning palm crown: fronds fanning from the top knob, leaning right
    hub = (34, 17)
    for tip in ((18, 12), (24, 5), (36, 4), (48, 9), (54, 18), (44, 22)):
        f = line([hub, ((hub[0] + tip[0]) / 2, min(hub[1], tip[1]) - 2), tip], w=2)
        st.part(f, LEAF[0], d=1, contour=True)
        st.paint(line([hub, tip], w=1) & f, LEAF[1])
    st.part(disc(34, 18, 2.5), TRUNK[0], d=1, contour=True)
    for x, y in ((6, 20), (9, 18), (58, 30)):
        dot(st, x, y, LEAF[1])
    st.paint(rect(20, 38, 24, 38) | rect(20, 37, 20, 37) | rect(24, 37, 24, 37), UMBER)    # wink
    st.eye(37, 35)
    st.sprite(['U...', '.UUU'], 29, 45, {'U': UMBER}, solid=False)
    st.paint(rect(17, 42, 19, 42) | rect(44, 42, 46, 42), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Brimful Pool: inner-TBTB keyhole, common.
def brimful_pool():
    key = 'pl-hang-3'
    st = Sticker()
    core = (13, 19, 49, 49)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 13, 19, 37, list(POOL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=WATER[0], skip=grow(holes, 3))
    # ripple rings across the brim + splash droplets
    st.paint(ellipse(31, 24, 9, 1.6) & ~ellipse(31, 24, 7, 0.8), WATER[0], solid=True)
    for x, y in ((22, 9), (40, 9), (31, 5), (8, 14), (55, 14)):
        st.paint(disc(x, y, 1.3), WATER[0], solid=True)
        dot(st, x, y, WATER[1])
    st.eye(20, 29)
    st.eye(36, 29)
    dot(st, 21, 30, WATER[1])
    dot(st, 37, 30, WATER[1])
    st.mouth('o', 30, 40)
    st.paint(rect(17, 37, 19, 37) | rect(42, 37, 44, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Berrybush Bobbles: inner-TTTT keyhole, uncommon.
def berrybush():
    key = 'pl-hang-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(BUSH)), contour=True)
    st.stitch(body, col=BERRY[1])                                   # uncommon accent: berry red
    for x, y in ((21, 21), (42, 21), (19, 42), (44, 42), (31, 45), (31, 20), (12, 31), (51, 31)):
        st.paint(disc(x, y, 1.4), BERRY[0], solid=True)
        dot(st, x, y, BERRY[1])
    st.paint(line([(31, 9), (31, 13)]), LEAF[2], solid=True)
    st.paint(poly([(27, 9), (31, 11), (27, 12)]) | poly([(35, 9), (31, 11), (35, 12)]), LEAF[1], solid=True)
    happy_eye(st, 22, 28)
    happy_eye(st, 37, 28)
    st.sprite(['.UUUU.', 'URRRRU', '.URRU.'], 29, 35, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    return key, st


# ------------------------------------------------------------------ 5. Vine Curtain Gateway: inner-BBBB double, uncommon.
def vine_gateway():
    key = 'pl-hang-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(SAND)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=LEAF[1], skip=grow(holes, 3))               # uncommon accent: vine green
    # arch lintel across the brow, two mirrored vines dangling
    lint = rect(17, 17, 46, 20)
    st.part(lint, STONE[0], d=1, contour=True)
    st.paint(rect(17, 17, 46, 17), STONE[2])
    st.paint(rect(31, 18, 32, 19), STONE[1])
    vine(st, 20, 21, 44, 1)
    vine(st, 43, 21, 44, -1)
    st.eye(24, 27, lid=2)
    st.eye(34, 27, lid=2)
    st.mouth('cat', 30, 36)
    st.paint(rect(24, 34, 25, 34) | rect(38, 34, 39, 34), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Swallow Swoop: whimsy-swallow keyhole, rare.
def swallow():
    key = 'pl-hang-6'
    st = Sticker()
    torso = ellipse(30, 34, 14, 10)
    head = disc(42, 26, 8)
    tab = knob('n', 'keyhole', 28, 24.5, r=3.0)
    tail = poly([(18, 34), (4, 46), (12, 38), (6, 52), (20, 40)])
    st.part(tail, NAVY[0], d=1, contour=True)
    body = torso | head | tab
    st.part(body, tex=fill(key, body, 16, 18, 36, list(NAVY)), contour=True)
    belly = ellipse(33, 39, 10, 5) & torso
    st.paint(belly, CREAM[0], solid=True)
    st.paint(belly & (CY > 41), CREAM[1])
    st.paint(ellipse(42, 31, 4, 2) & head, '#c4503a')               # rusty throat
    wing = poly([(20, 30), (36, 28), (30, 38)])
    st.part(wing, NAVY[1], d=1, contour=True)
    st.paint(poly([(50, 25), (56, 27), (50, 28)]), '#3a2a1a', solid=True)
    st.paint(ellipse(57.5, 27, 1.5, 1.2), '#e0b83a', solid=True)    # seed in beak
    st.eye(42, 23, socket=None)
    st.sparkle(56, 12)
    st.sparkle(8, 18, big=False)
    st.sparkle(46, 52, big=False)
    return key, st


PALS = [fruit_tray, palm_fringe, brimful_pool, berrybush, vine_gateway, swallow]

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
