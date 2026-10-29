"""Puzzle Pals: SPICE SOUK (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-spsk-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_spsk.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of a covered MENA spice market, mint tea and rest. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-spice-souk.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Awning Flutter    coral awning red       | scalloped red/cream striped valance on top, wind curl | looks up, open smile
  2 Palm Sway         olive palm green       | palm crown of fronds + date cluster                    | laughing ^ ^ eyes, big grin
  3 Lamp Dangle       lantern amber-orange   | hanging chain + hook, glowing pane, tea steam          | sleepy lids, 'o'
  4 Spice Dunes       turmeric saffron (+mint)| 4 spice cones (red/green N-S, gold E-W) on the tabs   | smug closed eyes, smirk
  5 Brass Glimmer     souk sky blue (+brass) | brass bowl on the belly with cinnamon sticks, gold dust| wide eyes, cat mouth
  6 Minty Fez Vendor  fez plum-burgundy      | whimsy fez with black tassel, mint tea glass, glow     | wink, cheeky tooth grin
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-spice-souk'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-spice-souk-8d3043')

AWN = ('#c4483a', '#de6a52')
PALM = ('#5f7a34', '#7a9440')
AMBER = ('#c8742a', '#e0943e')
SAFF = ('#d6a22a', '#ecc04a')
SKY = ('#6fa8c8', '#94c3db')
PLUM = ('#7a2438', '#963246')
STRIPE = ('#f2e4c0', '#c4483a')
FROND = ('#3f7a34', '#5e9a40', '#2a5226')
DATE = ('#8a3a1a', '#b85a2a')
BRASS = ('#c98a14', '#f5cf6a', '#8a5a10')
CINN = ('#8a4a22', '#b06a32')
MINT = ('#6ac48a', '#a8e4b4')
GLASS = '#d8f0f0'
CHAIN = '#4a2c1a'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_down(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def mark(st, m):
    st.extra |= m


def sprite_mark(st, rows_, x, y, col):
    for j, r in enumerate(rows_):
        for i, ch in enumerate(r):
            if ch != '.':
                st.px[y + j, x + i] = hx(col)
                st.extra[y + j, x + i] = True


# ---------------------------------------------------------------- own helpers
def valance(st, x0, x1, y):
    """Striped awning valance: 4 px stripes red/cream, scalloped lower edge."""
    m = rect(x0, y, x1, y + 5)
    for x in range(x0, x1 + 1, 4):
        m |= disc(x + 2, y + 6, 2.1)
    m &= (CX >= x0) & (CX <= x1 + 1)
    st.part(m, STRIPE[0], d=1, contour=True, shade=False)
    st.paint(m & (((XX - x0) // 4) % 2 == 1), STRIPE[1])
    st.paint(rect(x0, y, x1, y), '#8a2a22')
    return m


def wind(st, x, y):
    rows_ = ['CCC.', '...C', 'CC..']
    sprite_mark(st, rows_, x, y, CREAM)
    sprite_mark(st, rows_, x + 3, y + 5, CREAM)


def frond(st, x, y, ang, L):
    pts = []
    for i in range(L):
        a = math.radians(ang) + 0.04 * i * (1 if math.cos(math.radians(ang)) > 0 else -1)
        pts.append((x + i * math.cos(a), y + i * math.sin(a) + 0.02 * i * i))
    m = blank()
    for (a, b), (c, d) in zip(pts, pts[1:]):
        m |= line([(a, b), (c, d)], w=2)
    for (a, b) in pts[2::2]:
        m |= line([(a, b), (a, b + 2)])
    st.part(m, FROND[1], d=1, contour=True, shade=False)
    st.paint(m & ~shift(m, 0, -1), FROND[0])
    return m


def chain(st, x, y0, y1):
    m = blank()
    for y in range(y0, y1, 3):
        m |= rect(x, y, x, y + 1) | rect(x - 1, y + 1, x + 1, y + 1)
    hook = disc(x, y0 - 1, 2) & ~disc(x, y0 - 1, 1)
    st.paint(m | hook, CHAIN, solid=True)
    mark(st, m | hook)


def steam(st, x, y):
    rows_ = ['.C', 'C.', '.C', 'C.']
    sprite_mark(st, rows_, x, y, CREAM)
    sprite_mark(st, rows_, x + 4, y - 2, CREAM)


def cone(st, cx, by, w, h, col, down=False):
    s = -1 if down else 1
    m = poly([(cx - w, by), (cx + w + 1, by), (cx + 0.5, by - s * h)])
    st.part(m, col[0], d=1, contour=True, shade=False)
    st.paint(m & (CX < cx + 0.5), col[1])
    return m


def bowl(st, cx, cy, rx):
    m = ellipse(cx, cy, rx, rx * 0.6) & (CY > cy - 1)
    rim = ellipse(cx, cy - 1, rx, 2)
    st.part(m | rim, BRASS[0], d=1, contour=True, shade=False)
    st.paint(rim, BRASS[2])
    st.paint(m & (CX < cx - 1) & (CY > cy + 1) & ~shrink(m, 1), BRASS[1])
    for dx in (-3, 0, 3):
        stick = rect(int(cx + dx), int(cy) - 8, int(cx + dx) + 1, int(cy) - 1)
        st.part(stick, CINN[0], d=0, contour=True, shade=False)
        st.paint(stick & (XX == int(cx + dx)), CINN[1])
    return m


def tea_glass(st, x, y):
    g = rect(x, y, x + 4, y + 6)
    st.part(g, GLASS, d=0, contour=True, shade=False)
    st.paint(rect(x + 1, y + 2, x + 3, y + 6), MINT[0])
    st.paint(rect(x + 1, y + 2, x + 3, y + 2), MINT[1])
    st.paint(rect(x, y + 6, x + 4, y + 6), BRASS[0])
    mark(st, g)


# ------------------------------------------------------------------ 1. Awning Flutter: corner-TT round, common.
def awning_flutter():
    key = 'pl-spsk-1'
    st = Sticker()
    core = (12, 22, 44, 50)
    body = piece(core, n=('T', 'round', 6, 3.6), e=('T', 'round', 4, 3.6))
    st.part(body, tex=fill(key, body, 12, 22, 33, list(AWN)), contour=True)
    st.stitch(body, col='#f2c4a4')
    valance(st, 13, 43, 23)
    wind(st, 50, 8)
    st.eye(19, 33, look=(0, -1))
    st.eye(32, 33, look=(0, -1))
    st.mouth('smile', 26, 42)
    st.paint(rect(16, 41, 18, 41) | rect(38, 41, 40, 41), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Palm Sway: edge-TBT peg, common.
def palm_sway():
    key = 'pl-spsk-2'
    st = Sticker()
    core = (14, 26, 46, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 0, 3.4), w=('T', 'peg', 2, 3.4), e=('B', 'peg', 2, 2.8))
    st.part(body, tex=fill(key, body, 14, 26, 33, list(PALM)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c4d478', skip=grow(holes, 3))
    for ang, L in ((195, 13), (235, 10), (-55, 10), (-15, 13)):
        frond(st, 30, 14, ang, L)
    st.part(rect(29, 15, 31, 25), '#8a6a3a', d=0, contour=True, shade=False)
    st.part(disc(28, 21, 1.8) | disc(32, 21, 1.8) | disc(30, 23, 1.8), DATE[0], d=0, contour=True, shade=False)
    st.dots([(27, 20), (31, 20)], DATE[1])
    closed_up(st, 20, 34)
    closed_up(st, 35, 34)
    st.mouth('grin', 28, 40)
    st.paint(rect(17, 38, 19, 38) | rect(41, 38, 43, 38), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Lamp Dangle: inner-TBTB round, common.
def lamp_dangle():
    key = 'pl-spsk-3'
    st = Sticker()
    core = (14, 21, 44, 45)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', 0, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 22, 31, list(AMBER)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f5cf6a', skip=grow(holes, 3))
    chain(st, 29, 10, 16)
    pane = rect(25, 38, 33, 44)
    st.part(pane, '#fff3c8', d=0, contour=True, shade=False)
    st.paint(rect(26, 41, 32, 44), '#f5cf6a')
    st.paint(rect(29, 38, 29, 44), '#c98a14')
    steam(st, 48, 18)
    st.eye(19, 29, lid=3)
    st.eye(34, 29, lid=3)
    st.mouth('o', 28, 33)
    return key, st


# ------------------------------------------------------------------ 4. Spice Dunes: inner-TTTT peg, uncommon.
def spice_dunes():
    key = 'pl-spsk-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(SAFF)), contour=True)
    st.stitch(body, col=MINT[0])                                  # uncommon accent: mint
    cone(st, 31.5, 15, 4, 6, ('#b8382a', '#d65a40'))              # N paprika
    cone(st, 31.5, 49, 4, 6, ('#4a8a3a', '#6aaa4a'), down=True)  # S cumin-mint green
    cone(st, 12, 36, 3, 6, ('#c98a14', '#f5cf6a'))                # W gold
    cone(st, 51, 36, 3, 6, ('#c98a14', '#f5cf6a'))                # E gold
    closed_up(st, 22, 28)
    closed_up(st, 37, 28)
    st.mouth('smirk', 29, 36)
    st.paint(rect(20, 33, 22, 33) | rect(41, 33, 43, 33), BLUSH)
    return key, st


# ------------------------------------------------------------------ 5. Brass Glimmer: inner-BBBB round, uncommon.
def brass_glimmer():
    key = 'pl-spsk-5'
    st = Sticker()
    core = (11, 13, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(SKY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=BRASS[1], skip=grow(holes, 3))           # uncommon accent: brass
    bowl(st, 31.5, 41, 9)
    st.dots([(18, 40), (45, 40), (20, 46), (43, 46)], BRASS[1])
    st.eye(21, 23)
    st.eye(38, 23)
    st.mouth('cat', 30, 31)
    return key, st


# ------------------------------------------------------------------ 6. Minty Fez Vendor: whimsy-fez peg, rare.
def minty_fez_vendor():
    key = 'pl-spsk-6'
    st = Sticker()
    fez = poly([(16, 50), (47, 50), (43, 17), (20, 17)])
    top = ellipse(31.5, 17, 11.5, 3)
    tab = knob('e', 'peg', 34, 45.5, r=3.2)
    body = fez | top | tab
    st.part(body, tex=fill(key, body, 12, 12, 40, list(PLUM)), contour=True)
    st.paint(fez & (CY > 44) & (CY < 47), BRASS[0])               # gold band
    st.paint(fez & (CY > 44) & (CY < 45), BRASS[1])
    st.paint(top & (CY < 17), '#a84a5a')
    # tassel: cord from the top button over to the left side
    st.paint(disc(31.5, 15.5, 1.5), CHAIN, solid=True)
    cord = line([(31, 15), (24, 13), (18, 16)])
    st.paint(cord, UMBER, solid=True)
    tas = poly([(16, 16), (20, 16), (21, 25), (15, 25)])
    st.part(tas, '#3a2216', d=0, contour=True, shade=False)
    st.paint(rect(17, 17, 17, 24) & tas, '#5c3420')
    st.paint(cord, '#3a2216', solid=True)
    mark(st, cord)
    wink(st, 23, 29)
    st.eye(36, 28)
    st.mouth('tooth', 29, 37)
    st.paint(rect(21, 36, 23, 36) | rect(41, 36, 43, 36), BLUSH)
    tea_glass(st, 49, 38)
    steam(st, 49, 30)
    st.sparkle(6, 6)
    st.sparkle(52, 8, big=False)
    st.sparkle(8, 40, big=False)
    return key, st


PALS = [awning_flutter, palm_sway, lamp_dangle, spice_dunes, brass_glimmer, minty_fez_vendor]

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
