"""Puzzle Pals: THE SKY CITY RUINS (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-skyc-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_skyc.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: sunset sky-ruin sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy, puff); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-the-sky-city-ruins.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Cloudstep Climb     dusk lilac stone            | white stair steps climbing off the top-right into a cloud puff | eyes rolled up, small o mouth
  2 Pinkpad Float       candy pink                  | frilly cloud-pad skirt underneath + drift lines                | sleepy half lids, soft smile
  3 Apricot Sunbun      apricot sun                 | a purple snow-capped peak rising over its belly, short rays    | closed happy arcs, cat mouth
  4 Stonestep Benches   hillside green (+ grey)     | three grey stone step bands across the belly                   | wide straight eyes, toothy grin
  5 Amberlit Window     ruin beige (+ amber)        | glowing amber arched window in the chest, stone lintel         | eyes glancing down, smirk
  6 Trailpack Cubbie    cub brown, red pack         | whimsy bear cub, round ears, red backpack strap, glow          | big eyes gazing up-right, grin, blush
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-sky-city-ruins'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-sky-city-ruins-5b061c')

LILAC = ('#8a74a0', '#a890bc')
PINK = ('#e07aa8', '#f4a0c4')
APRI = ('#f0a050', '#f8c478')
HILL = ('#5e8c40', '#7aa858')
BEIGE = ('#b8a694', '#d4c4b2')
CUB = ('#8a5a34', '#a8744a')
STONE = ('#8c8c94', '#b4b4bc')
STONE_D = '#5c5c66'
CLOUD = ('#e8e4f0', '#ffffff')
AMBER = ('#e88a20', '#f8c048', '#fff0b0')
PEAK = ('#6a5a9a', '#8a7ab8')
PACK = ('#c03a30', '#e05a48')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_arc(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def cloud(st, cx, cy, w=5):
    m = ellipse(cx, cy, w, 2.2) | disc(cx - w / 3, cy - 1.5, 2.2) | disc(cx + w / 4, cy - 1.8, 2.4)
    st.part(m, CLOUD[0], d=0, contour=True, shade=False)
    st.paint(m & (YY <= cy - 2), CLOUD[1])
    return m


# 1. Cloudstep Climb: corner-BB keyhole, common.
def cloudstep_climb():
    key = 'pl-skyc-1'
    st = Sticker()
    core = (10, 22, 42, 51)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 10, 16, 36, list(LILAC)), contour=True)
    st.blank_shade(body, holes, width=1)
    for i in range(4):                                   # stair steps climbing off the top-right corner
        x, y = 38 + i * 4, 19 - i * 3
        stp = rect(x, y, x + 4, y + 2)
        st.part(stp, STONE[1], d=0, contour=True, shade=False)
        st.paint(rect(x, y + 2, x + 4, y + 2), STONE[0])
    cloud(st, 53, 10, w=4)
    st.eye(16, 33, look=(0, -1))
    st.eye(29, 33, look=(0, -1))
    st.mouth('o', 23, 42)
    return key, st


# 2. Pinkpad Float: edge-TBB keyhole, common.
def pinkpad_float():
    key = 'pl-skyc-2'
    st = Sticker()
    core = (15, 18, 47, 44)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 10, 36, list(PINK)), contour=True)
    st.blank_shade(body, holes, width=1)
    skirt = blank()
    for x in range(13, 51, 5):                           # frilly cloud pad underneath
        skirt |= disc(x + 2, 47, 3.0)
    skirt &= (YY >= 44)
    st.part(skirt, CLOUD[0], d=0, contour=True, shade=False)
    st.paint(skirt & (YY == 45), CLOUD[1])
    for y in (24, 32):                                   # drift lines
        st.paint(rect(5, y, 8, y), CREAM)
        st.extra |= rect(5, y, 8, y)
    st.eye(23, 27, lid=2)
    st.eye(36, 27, lid=2)
    st.mouth('smile', 28, 36)
    st.paint(rect(19, 34, 21, 34) | rect(41, 34, 43, 34), BLUSH)
    return key, st


# 3. Apricot Sunbun: inner-TBTB keyhole, common.
def apricot_sunbun():
    key = 'pl-skyc-3'
    st = Sticker()
    core = (14, 17, 49, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 10, 36, list(APRI)), contour=True)
    st.blank_shade(body, holes, width=1)
    peak = poly([(16, 46), (33, 32), (48, 46)]) & body
    st.paint(peak, PEAK[0])
    st.paint(poly([(33, 32), (48, 46), (40, 46)]) & peak, PEAK[1])
    st.paint(poly([(29, 35.5), (33, 32), (37, 35.5)]) & peak, CLOUD[1])
    for (x, y) in ((9, 9), (52, 9)):                     # short sun rays
        st.part(rect(x, y, x + 2, y + 2), '#f8d070', d=0, contour=True, shade=False)
    happy_arc(st, 21, 25)
    happy_arc(st, 37, 25)
    st.mouth('cat', 29, 28)
    st.paint(rect(18, 29, 20, 29) | rect(43, 29, 45, 29), BLUSH)
    return key, st


# 4. Stonestep Benches: inner-TTTT keyhole, uncommon (Plus, symmetric).
def stonestep_benches():
    key = 'pl-skyc-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 16, 16, 32, list(HILL)), contour=True)
    for y in (34, 38, 42):                               # stone step bands
        band = rect(18, y, 45, y + 1) & body
        st.paint(band & (YY == y), STONE[1])
        st.paint(band & (YY == y + 1), STONE_D)
    st.eye(23, 23)
    st.eye(36, 23)
    st.mouth('tooth', 28, 30)
    return key, st


# 5. Amberlit Window: inner-BBBB double, uncommon (Ring, symmetric).
def amberlit_window():
    key = 'pl-skyc-5'
    st = Sticker()
    core = (12, 12, 51, 51)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.0), e=('B', 'double', 0, 3.0), s=('B', 'double', 0, 3.0),
                               w=('B', 'double', 0, 3.0))
    st.part(body, tex=fill(key, body, 12, 12, 40, list(BEIGE)), contour=True)
    st.blank_shade(body, holes, width=1)
    win = (rect(26, 32, 37, 45) | disc(31.5, 32, 5.5)) & (YY <= 45)
    st.paint(grow(win, 1), STONE_D, solid=True)
    st.paint(win, AMBER[0], solid=True)
    st.paint(shrink(win, 2), AMBER[1], solid=True)
    st.paint(rect(30, 33, 33, 41), AMBER[2], solid=True)
    st.paint(rect(24, 46, 39, 47), STONE[1], solid=True)
    st.eye(21, 19, look=(0, 1))
    st.eye(38, 19, look=(0, 1))
    st.mouth('smirk', 29, 25)
    return key, st


# 6. Trailpack Cubbie: whimsy-bearcub keyhole, rare.
def trailpack_cubbie():
    key = 'pl-skyc-6'
    st = Sticker()
    head = disc(30, 27, 13)
    ears = disc(19, 16, 4.2) | disc(41, 16, 4.2)
    belly = ellipse(30, 41, 12, 7)
    tab = knob('s', 'keyhole', 30, 47, r=2.6)
    body = head | ears | belly | tab
    st.part(body, tex=fill(key, body, 14, 12, 36, list(CUB)), contour=True)
    st.paint(disc(19, 16, 2) | disc(41, 16, 2), '#d49a78')
    pack = rect(42, 33, 50, 45) & ~disc(42, 33, 1) & ~disc(50, 33, 1)
    st.part(pack, PACK[0], d=1, contour=True)
    st.paint(rect(43, 38, 49, 38), PACK[1])
    st.paint(line([(22, 36), (42, 34)], w=2) & belly, PACK[0])
    snout = ellipse(30, 32, 5, 3.2)
    st.paint(snout, '#e0b48a')
    st.paint(rect(29, 30, 31, 30), UMBER)
    st.eye(22, 22, look=(1, -1))
    st.eye(35, 22, look=(1, -1))
    st.mouth('grin', 27, 33)
    st.paint(rect(17, 29, 19, 29) | rect(40, 29, 42, 29), BLUSH)
    cloud(st, 54, 18, w=4)
    st.sparkle(9, 9)
    st.sparkle(53, 8, big=False)
    st.sparkle(12, 44, big=False)
    return key, st


PALS = [cloudstep_climb, pinkpad_float, apricot_sunbun, stonestep_benches, amberlit_window, trailpack_cubbie]

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
