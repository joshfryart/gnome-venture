"""Puzzle Pals: TEA GARDEN SLOPES (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-tegr-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_tegr.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: misty-slope sprites, keyhole knobs, fresh and cheerful. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-tea-garden-slopes.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Heapsy Basket        tea-leaf green               | a woven wicker basket heaped with leaves on its head            | strained squint, wobbly mouth, sweat drop
  2 Magenta Muffler      picker magenta               | a striped muffler wrapped round its middle, tail flying         | wide eyes looking aside, open grin
  3 Steeping Cuppa       mist teal                    | a white teacup on its foot, three steam curls above             | sleepy lids, soft smile, cheeks
  4 Conehat Cluster      straw tan (+ leaf green)     | three tiny conical straw hats, on the north, east and west tabs | happy ^ ^ eyes, o mouth
  5 Buttermilk Daybreak  buttermilk pale (+ ridge blue)| a pale round sun rising over misty blue ridge lines on its belly | wink + eye, cat mouth
  6 Beaming Headpicker   soil brown                   | whimsy chibi picker: big straw cone hat, red bandana, two leaves and a bud held up, glow (rare) | big grin, closed happy eyes
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-tea-garden-slopes'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-tea-garden-slopes-eb52f5')

LEAF = ('#4f8f4f', '#6aae62')         # tea leaf green
MAGE = ('#b0306e', '#cc4a8a')         # picker magenta
MIST = ('#7fa8ac', '#9cc0c4')         # mist teal
STRAW = ('#c8a464', '#dcbc80')        # straw tan
BUTTER = ('#e8dcae', '#f4ecc8')       # buttermilk pale
SOIL = ('#5a3424', '#74462e')         # soil brown (rare)
WICKER = ('#9a6a34', '#6e4620', '#c08a4a')
HAT = ('#d8b06a', '#a87e40', '#f0d090')
RIDGE = ('#5a7a9a', '#7a98b4')
CUPW = ('#f4f0e6', '#c8c0b0')
BAND = '#c83a3a'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def squint(st, x, y, flip=False):
    rows_ = ['U....', '.UU..', '...UU'] if not flip else ['....U', '..UU.', 'UU...']
    st.sprite(rows_, x, y, {'U': UMBER}, solid=False)


def cone_hat(st, cx, by, w=7, h=6):
    m = poly([(cx - w, by), (cx, by - h), (cx + w, by)])
    st.part(m, HAT[0], d=1, contour=True)
    st.paint(m & (YY == by - 1), HAT[1])
    st.paint(m & (CX < cx) & (YY < by - 2), HAT[2])
    return m


def leaf(st, cx, cy, col=LEAF[1]):
    st.sprite(['.L.', 'LLL', 'LDL', '.L.'], cx - 1, cy - 2, {'L': col, 'D': '#2e5e2e'}, solid=True)


def steam(st, x, y):
    st.sprite(['.W', 'W.', '.W', 'W.'], x, y, {'W': '#f4f8f8'}, solid=True)


# ------------------------------------------------------------------ 1. Heapsy Basket: corner-BB keyhole, common.
def heapsy_basket():
    key = 'pl-tegr-1'
    st = Sticker()
    core = (12, 24, 47, 53)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', -6, 3.0), e=('B', 'keyhole', 2, 3.0))
    st.part(body, tex=fill(key, body, 12, 24, 36, list(LEAF)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#2e5e2e', skip=grow(holes, 3))
    heap = ellipse(32, 15, 13, 7) & (CY <= 16)
    st.part(heap, '#5aa04a', d=1, contour=True)
    st.paint(heap & ((XX + YY) % 4 == 0), '#86c46a')
    bk = rect(20, 15, 44, 24) & ~(rect(20, 22, 21, 24) | rect(43, 22, 44, 24))
    st.part(bk, WICKER[0], d=1, contour=True)
    st.paint(bk & ((XX + YY) % 3 == 0), WICKER[1])
    st.paint(bk & (YY == 16), WICKER[2])
    squint(st, 17, 34)
    squint(st, 30, 34, flip=True)
    st.mouth('cat', 24, 43)
    st.dots([(42, 31), (42, 32)], '#bfe6f0')
    return key, st


# ------------------------------------------------------------------ 2. Magenta Muffler: edge-TTB keyhole, common.
def magenta_muffler():
    key = 'pl-tegr-2'
    st = Sticker()
    core = (16, 14, 47, 46)
    body, holes = piece_blanks(core, s='F', n=('B', 'keyhole', 0, 3.0), e=('T', 'keyhole', -4, 3.4), w=('T', 'keyhole', -4, 3.4))
    st.part(body, tex=fill(key, body, 14, 14, 36, list(MAGE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f0b0d0', skip=grow(holes, 3))
    muf = rect(16, 34, 47, 38)
    st.part(muf, '#e070a8', d=1, contour=True)
    st.paint(muf & (XX % 4 < 2), '#f4f0e6')
    tail = rect(38, 38, 42, 50)
    st.part(tail, '#e070a8', d=1, contour=True)
    st.paint(tail & (YY % 4 < 2), '#f4f0e6')
    st.paint(rect(37, 51, 43, 51) & (XX % 2 == 0), '#e070a8')
    st.eye(21, 21, look=(-1, 0))
    st.eye(35, 21, look=(-1, 0))
    st.mouth('grin', 28, 29)
    return key, st


# ------------------------------------------------------------------ 3. Steeping Cuppa: inner-TBTB keyhole, common.
def steeping_cuppa():
    key = 'pl-tegr-3'
    st = Sticker()
    core = (13, 17, 50, 48)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 13, 17, 38, list(MIST)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e0f0f0', skip=grow(holes, 3))
    cup = (ellipse(32, 38, 9, 6) & (CY >= 36)) | rect(23, 35, 41, 37)
    st.part(cup, CUPW[0], d=1, contour=True)
    st.paint(rect(24, 35, 40, 35), '#7a9a3a')
    st.paint(cup & (YY == 41), CUPW[1])
    st.part(disc(43, 38, 2.0) & ~disc(43, 38, 0.8), CUPW[0], d=0, contour=True, shade=False)
    for x in (27, 31, 35):
        steam(st, x, 29)
    st.eye(22, 23, lid=2)
    st.eye(37, 23, lid=2)
    st.mouth('smile', 30, 26)
    st.paint(rect(17, 28, 19, 28) | rect(44, 28, 46, 28), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Conehat Cluster: inner-TTTT keyhole, uncommon.
def conehat_cluster():
    key = 'pl-tegr-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(STRAW)), contour=True)
    st.stitch(body, col=LEAF[0])                               # uncommon accent: tea leaf green
    cone_hat(st, 32, 13, 6, 6)
    cone_hat(st, 11, 32, 5, 5)
    cone_hat(st, 52, 32, 5, 5)
    leaf(st, 32, 52)
    happy_eye(st, 22, 26)
    happy_eye(st, 37, 26)
    st.mouth('o', 30, 35)
    return key, st


# ------------------------------------------------------------------ 5. Buttermilk Daybreak: inner-BBBB double, uncommon.
def buttermilk_daybreak():
    key = 'pl-tegr-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(BUTTER)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=RIDGE[0], skip=grow(holes, 3))         # uncommon accent: ridge blue
    sun = disc(32, 42, 6)
    st.part(sun, '#fff8e0', d=1, contour=True)
    ridge = poly([(14, 49), (24, 41), (32, 46), (42, 39), (50, 49)]) & ~sun | (poly([(14, 49), (24, 43), (32, 47), (42, 42), (50, 49)]))
    st.part(ridge & ~disc(32, 42, 5), RIDGE[1], d=1, contour=True)
    st.paint(rect(16, 47, 47, 47) & (XX % 3 == 0), '#e8f0f4')
    wink(st, 20, 21)
    st.eye(37, 20)
    st.mouth('cat', 29, 29)
    st.paint(rect(17, 29, 19, 29) | rect(44, 29, 46, 29), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Beaming Headpicker: whimsy-picker keyhole, rare.
def beaming_headpicker():
    key = 'pl-tegr-6'
    st = Sticker()
    dress = ellipse(30, 47, 14, 8)
    head = disc(30, 31, 10)
    tab = knob('e', 'keyhole', 44, 46, r=3.0)
    body = head | dress | tab
    st.part(body, tex=fill(key, body, 14, 18, 38, list(SOIL)), contour=True)
    st.paint(shrink(head, 2) & (CY > 26), '#f0c8a0')     # face skin
    st.paint(rect(21, 39, 39, 41) & dress, BAND)                                        # red bandana
    st.paint(dress & (YY == 52) & (XX % 2 == 0), LEAF[1])
    hat = cone_hat(st, 30, 25, 18, 14)
    st.paint(hat & (YY == 18) & (XX % 2 == 0), HAT[1])
    st.part(disc(48, 34, 2.6), '#f0c8a0', d=1, contour=True)                            # raised hand
    st.paint(line([(48, 31), (48, 24)]), '#2e5e2e', solid=True)
    leaf(st, 46, 24)
    leaf(st, 51, 24)
    st.part(disc(48, 20, 1.6), '#9ad070', d=0, contour=True, shade=False)               # the bud
    happy_eye(st, 22, 29)
    happy_eye(st, 32, 29)
    st.mouth('grin', 27, 34)
    st.paint(rect(21, 34, 22, 34) | rect(37, 34, 38, 34), BLUSH)
    st.sparkle(5, 6)
    st.sparkle(55, 10, big=False)
    st.sparkle(6, 40, big=False)
    return key, st


PALS = [heapsy_basket, magenta_muffler, steeping_cuppa, conehat_cluster, buttermilk_daybreak, beaming_headpicker]

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
