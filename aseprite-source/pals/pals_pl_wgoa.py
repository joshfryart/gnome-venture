"""Puzzle Pals: GOAT PATH VINEYARDS (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wgoa-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wgoa.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: little harvest sprites made of the hillside's own roofs, trees, crates and barrels, keyhole knobs, warm golden hour, never scary.
kit_lair parts used only as building blocks (PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = the row's
shape + knob, body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/wonder-goat-path-vineyards.png, calmed onto 2 tones.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Terracotta Topknot     roof-tile terracotta       | a scalloped red tile roof ridge as a topknot, little chimney          | content closed ^ ^ eyes, smile
  2 Green Pencil Cypress   cypress deep green         | a tall pointed cypress spire swaying off its head, doodle line in sky | dreamy, looks up, little o
  3 Squishy Grape Crate    grape purple               | a heap of grapes on its head, crate slats across its belly            | cheeky wink, tooth grin
  4 Harvest Hat Parade     straw gold (+ red)         | a pointy red harvest hat on every tab, grape basket on its belly      | wide round eyes, big grin
  5 Hoopsy Barrels         oak barrel brown (+ iron)  | iron hoop bands across its middle, two round barrel tops as feet       | sleepy heavy lids, flat mouth
  6 Supervising Billy      wool cream                 | whimsy goat head: curled horns, ears, beard, one stolen grape (rare)  | side-eye half lids, smirk
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-goat-path-vineyards'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-goat-path-vineyards-19fd4a')

TERRA = ('#c0583a', '#d8744a')         # roof-tile terracotta
CYPR = ('#2f6a3a', '#3f8a4a')          # cypress green
GRAPE = ('#6a3e7a', '#87559a')         # grape purple
STRAW = ('#d4a85a', '#e8c47a')         # straw gold
OAK = ('#7a4a32', '#94603e')           # barrel oak
WOOL = ('#eadcbc', '#f6ecd4')          # goat wool (rare)
TILE = ('#a83e2a', '#e0805a', '#7a2a1e')
GRP = ('#5a2e6a', '#9a6ab4', '#3a1a48')
IRON = ('#4a4a52', '#7a7a86', '#2a2a32')
HATR = ('#b8382e', '#e06050', '#7a2020')
HORNC = ('#c9a96e', '#f1dca8', '#8a6a3a')
LEAF = '#5a9a3a'
BLUSH = '#f0a0b8'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def grape(st, cx, cy, r=2.0, solid=True):
    m = disc(cx, cy, r)
    if solid:
        st.part(m, GRP[0], d=1, contour=True)
    else:
        st.paint(m, GRP[0])
    st.dots([(int(cx - 1), int(cy - 1))], GRP[1])
    return m


def hat(st, cx, by, w=5, h=9, lean=0.0):
    m = poly([(cx - w, by), (cx + w, by), (cx + lean + 0.5, by - h), (cx + lean - 0.5, by - h)])
    st.part(m, HATR[0], d=1, contour=True)
    st.paint(m & (CY > by - 2), HATR[2])
    return m


# ------------------------------------------------------------------ 1. Terracotta Topknot: corner-BB keyhole, common.
def terracotta_topknot():
    key = 'pl-wgoa-1'
    st = Sticker()
    core = (12, 22, 46, 50)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', 7, 3.0), e=('B', 'keyhole', 4, 3.0))
    st.part(body, tex=fill(key, body, 12, 22, 35, list(TERRA)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f2b48a', skip=grow(holes, 3))
    roof = poly([(10, 23), (22, 11), (32, 23)])              # the roof ridge topknot, tiles in scalloped rows
    chim = rect(13, 11, 16, 17)
    st.part(chim, TILE[2], d=1, contour=True)
    st.part(roof, TILE[0], d=1, contour=True)
    for y in (16, 20):
        st.paint(roof & shrink(roof, 1) & (CY > y - 0.5) & (CY < y + 0.5) & ((XX % 3) != 0), TILE[1])
    st.paint(roof & shrink(roof, 1) & ((XX % 3) == 0) & (CY > 13), TILE[2])
    closed_up(st, 17, 32)
    closed_up(st, 30, 32)
    st.mouth('smile', 24, 38)
    st.paint(rect(15, 36, 17, 36) | rect(35, 36, 37, 36), BLUSH)
    for x in (16, 35):
        st.part(ellipse(x + 2.5, 51.5, 3.2, 2), '#7a3020', d=1, contour=True)
    return key, st


# ------------------------------------------------------------------ 2. Green Pencil Cypress: edge-TBB keyhole, common.
def green_pencil_cypress():
    key = 'pl-wgoa-2'
    st = Sticker()
    core = (14, 30, 44, 51)
    spire = poly([(17, 31), (41, 31), (31, 6), (29, 6)])     # the slim cypress spire rising off its head, leaning a touch
    st.part(spire, CYPR[0], d=1, contour=True)
    st.paint(spire & shrink(spire, 1) & ((YY + XX // 3) % 4 == 0), CYPR[1])
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', -4, 3.4), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 30, 31, list(CYPR)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#9ad08a', skip=grow(holes, 3))
    doodle = line([(36, 9), (40, 7), (43, 9), (47, 7), (51, 9)])   # the pencil doodle in the sky
    st.paint(doodle, '#3a5a8a')
    st.extra |= doodle
    st.eye(20, 35, look=(0, -1))
    st.eye(33, 35, look=(0, -1))
    st.mouth('o', 28, 43)
    st.paint(rect(17, 42, 19, 42) | rect(39, 42, 41, 42), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Squishy Grape Crate: inner-TBTB keyhole, common.
def squishy_grape_crate():
    key = 'pl-wgoa-3'
    st = Sticker()
    core = (15, 22, 46, 44)
    for (x, y) in ((22, 19), (27, 17), (32, 16), (37, 17), (42, 19), (25, 13), (30, 12), (35, 13), (40, 14)):
        grape(st, x, y, 2.6)                                    # the grape heap on its head
    st.part(poly([(30, 9), (34, 7), (33, 10)]), LEAF, d=1, contour=True)
    body, holes = piece_blanks(core, n=('T', 'keyhole', -10, 3.2), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.4), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 18, 32, list(GRAPE)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (39, 42):                                          # crate slats
        st.paint(body & shrink(body, 1) & (YY == y), '#b08a5a')
    st.stitch(body & (YY < 37), col='#d4b0e4', skip=grow(holes, 3))
    st.eye(21, 26, lid=4)
    st.eye(35, 26, look=(1, 0))
    st.mouth('tooth', 28, 33)
    st.paint(rect(18, 33, 20, 33) | rect(41, 33, 43, 33), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Harvest Hat Parade: inner-TTTT double, uncommon.
def harvest_hat_parade():
    key = 'pl-wgoa-4'
    st = Sticker()
    core = (19, 21, 44, 44)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 19, 21, 26, list(STRAW)), contour=True)
    st.stitch(body, col=HATR[1])                               # uncommon accent: harvest red
    hat(st, 32, 15, w=5, h=8)                                  # hats bobbing on the tabs, symmetric
    hat(st, 11, 32, w=4, h=7)
    hat(st, 53, 32, w=4, h=7)
    bask = ellipse(32, 40, 6, 3.5) & (CY > 38)                 # grape basket on its belly
    st.part(bask, '#8a5a2a', d=1, contour=True)
    st.paint(bask & ((XX + YY) % 3 == 0), '#b07a3a')
    for x in (29, 32, 35):
        grape(st, x, 37, 1.8, solid=False)
    st.eye(23, 25)
    st.eye(36, 25)
    st.mouth('grin', 30, 31)
    st.paint(rect(21, 31, 22, 31) | rect(41, 31, 42, 31), BLUSH)
    return key, st


# ------------------------------------------------------------------ 5. Hoopsy Barrels: inner-BBBB keyhole, uncommon.
def hoopsy_barrels():
    key = 'pl-wgoa-5'
    st = Sticker()
    for x in (21, 43):                                         # two round barrel tops as feet
        m = ellipse(x, 52, 6, 3.4)
        st.part(m, OAK[0], d=1, contour=True)
        st.paint(m & ~ellipse(x, 52, 4.8, 2.3), IRON[0])
    core = (11, 10, 52, 48)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 2.4), e=('B', 'keyhole', 0, 2.4), s=('B', 'keyhole', 0, 2.4), w=('B', 'keyhole', 0, 2.4))
    st.part(body, tex=fill(key, body, 11, 10, 42, list(OAK)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (17, 40):                                         # iron hoops (uncommon accent)
        st.paint(body & (YY >= y) & (YY <= y + 1), IRON[0])
        st.paint(body & (YY == y), IRON[1])
    st.paint(body & shrink(body, 2) & ((XX - 11) % 7 == 0) & (YY > 19) & (YY < 39), '#5a3424')   # staves
    st.eye(20, 24, lid=3)
    st.eye(39, 24, lid=3)
    st.mouth('flat', 31, 33)
    st.paint(rect(17, 32, 19, 32) | rect(44, 32, 46, 32), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Supervising Billy: whimsy-goat keyhole, rare.
def supervising_billy():
    key = 'pl-wgoa-6'
    st = Sticker()
    for s in (-1, 1):                                          # curled horns
        h = poly([(32 + s * 5, 18), (32 + s * 9, 17), (32 + s * 14, 9), (32 + s * 12, 7), (32 + s * 8, 12)])
        st.part(h, HORNC[0], d=1, contour=True)
        st.paint(h & ((YY % 3) == 0), HORNC[2])
        ear = ellipse(32 + s * 16, 25, 5, 2.5)
        st.part(ear, WOOL[0], d=1, contour=True)
    head = ellipse(32, 29, 12, 11) | ellipse(32, 40, 8, 6)
    tab = knob('s', 'keyhole', 32, 45, r=3.0)
    beard = poly([(28, 45), (36, 45), (32, 52)])
    body = head | tab
    st.part(body, tex=fill(key, body, 18, 16, 30, list(WOOL)), contour=True)
    st.part(beard, '#d8c8a4', d=1, contour=True)
    st.paint(ellipse(32, 41, 6, 3.6), '#e8b8a0')               # muzzle
    st.dots([(30, 40), (34, 40)], UMBER)
    st.eye(22, 26, look=(1, 0), lid=2)
    st.eye(37, 26, look=(1, 0), lid=2)
    st.mouth('smirk', 30, 43)
    grape(st, 39, 44, 2.4)                                      # the one grape he took
    st.paint(line([(39, 41), (40, 40)]), LEAF)
    st.paint(rect(19, 33, 21, 33) | rect(42, 33, 44, 33), BLUSH)
    st.sparkle(7, 8)
    st.sparkle(52, 40, big=False)
    st.sparkle(10, 44, big=False)
    return key, st


PALS = [terracotta_topknot, green_pencil_cypress, squishy_grape_crate, harvest_hat_parade, hoopsy_barrels, supervising_billy]

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
        print('%-10s %-22s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
