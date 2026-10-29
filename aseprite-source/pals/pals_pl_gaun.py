"""Puzzle Pals: GAUCHO GNOME RANCH (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-gaun-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_gaun.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of the pampas ranch by day. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy, puff); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-gaucho-gnome-ranch.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Redroof Rest    terracotta roof red     | a roof gable + chimney with a smoke puff on top    | open eyes look up, soft smile
  2 Rail Lean       weathered fence grey-tan| two fence posts + a rail, a brown cow ear peeking  | laughing ^ ^ eyes, big grin
  3 Gourd Pass      mate-gourd olive        | a silver bombilla straw + yerba leaves on top      | sleepy lids, 'o' sip
  4 Windmill Whirl  pampas sky blue (+steel)| a 4-blade steel rotor on the face, water drops     | wide side glance, cat mouth
  5 Noon Shade      tree-crown green (+sun) | leafy scallop rim, a small sun above               | content closed lids, smile, blush
  6 Pampas Rider    chestnut horse          | whimsy chibi horse + red-capped gnome in a flat hat, glow | big grin, round eyes
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-gaucho-gnome-ranch'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-gaucho-gnome-ranch-3c3ac8')

ROOF = ('#b44a2c', '#d0663a')
FENCE = ('#9a8a72', '#b8a88c')
GOURD = ('#8a8a3e', '#a9a263')
SKY = ('#6aa8cc', '#a6d1e8')
CROWN = ('#3e7a34', '#5a9a44')
CHEST = ('#7e3d28', '#9a5534')
WOOD = ('#6a4a2e', '#8a6440', '#4a3020')
STEEL = ('#c8d0d8', '#8a96a2', '#5a6672')
LEAFY = ('#6a9a3a', '#9ac45a')
SUN = ('#f8d24a', '#fff0a0')
HATRED = ('#c8402e', '#e05a3a')
BEARD = ('#f2ece0', '#cfc6b4')
SKIN = '#f0c8a0'
DROP = ('#a6d1e8', '#ffffff')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_down(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


# ------------------------------------------------------------------ 1. Redroof Rest: corner-TB round, common.
def redroof_rest():
    key = 'pl-gaun-1'
    st = Sticker()
    core = (12, 24, 44, 51)
    # chimney + smoke first so the body covers its foot
    chim = rect(34, 13, 38, 24)
    st.part(chim, ROOF[0], d=1, contour=True)
    st.paint(rect(33, 12, 39, 13), '#7a2e1a', solid=True)
    m = disc(38, 9, 2.4) | disc(42, 6, 2.0) | disc(46, 5, 1.5)
    st.paint(m, '#e8e4dc')
    st.paint(m & (CY > 7), '#c4c0b8')
    st.extra |= m
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', -6, 3.6), e=('B', 'round', 2, 2.8))
    st.part(body, tex=fill(key, body, 12, 24, 33, list(ROOF)), contour=True)
    for y in (29, 33):                                       # roof tile rows
        st.paint(rect(14, y, 42, y) & body & (XX % 4 != 0), '#8e3420')
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f2b48a', skip=grow(holes, 3))
    st.eye(18, 36, look=(0, -1))
    st.eye(31, 36, look=(0, -1))
    st.mouth('smile', 24, 44)
    st.paint(rect(14, 43, 16, 43) | rect(38, 43, 40, 43), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Rail Lean: edge-TTB peg, common.
def rail_lean():
    key = 'pl-gaun-2'
    st = Sticker()
    core = (14, 24, 44, 51)
    for px_ in (18, 40):                                     # fence posts behind
        post = rect(px_, 12, px_ + 3, 26)
        st.part(post, WOOD[1], d=1, contour=True)
        st.paint(rect(px_, 12, px_ + 3, 12), WOOD[2], solid=True)
    rail = rect(15, 16, 46, 18)
    st.part(rail, WOOD[0], d=1, contour=True)
    st.paint(rect(16, 16, 45, 16), WOOD[1])
    ear = poly([(48, 10), (55, 8), (52, 14)])                # cow ear peeking over the rail
    st.part(ear, '#7a4a2a', d=1, contour=True)
    st.paint(shrink(ear, 1), '#e8a8a0')
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 2, 3.4), e=('T', 'peg', 3, 3.4), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 14, 24, 31, list(FENCE)), contour=True)
    st.paint(rect(16, 38, 42, 38) & body & (XX % 5 != 0), '#7a6a52')   # plank grain
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e8dcc4', skip=grow(holes, 3))
    closed_up(st, 20, 31)
    closed_up(st, 34, 31)
    st.mouth('grin', 26, 40)
    st.paint(rect(17, 36, 19, 36) | rect(39, 36, 41, 36), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Gourd Pass: inner-TBTB round, common.
def gourd_pass():
    key = 'pl-gaun-3'
    st = Sticker()
    core = (14, 20, 46, 46)
    straw = line([(36, 22), (42, 8)], w=2)                   # silver bombilla
    st.part(straw, STEEL[0], d=1, contour=True)
    st.paint(rect(40, 7, 43, 8), STEEL[1], solid=True)
    body, holes = piece_blanks(core, n=('T', 'round', -4, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', -6, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 20, 33, list(GOURD)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#d8d090', skip=grow(holes, 3))
    for x in (22, 26, 30):                                   # yerba leaf flecks on the top
        st.paint(rect(x, 23, x + 1, 23) | rect(x + 1, 24, x + 1, 24), LEAFY[1])
    st.paint(rect(16, 27, 44, 27) & body, '#6a6a2a')         # gourd rim band
    st.eye(21, 31, lid=3)
    st.eye(34, 31, lid=3)
    st.mouth('o', 28, 38)
    st.paint(rect(18, 37, 20, 37) | rect(38, 37, 40, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Windmill Whirl: inner-TTTT peg, uncommon.
def windmill_whirl():
    key = 'pl-gaun-4'
    st = Sticker()
    core = (17, 18, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 18, 30, list(SKY)), contour=True)
    st.stitch(body, col=STEEL[2])                            # uncommon accent: windmill steel
    rot = blank()
    for dx, dy in ((0, -1), (0, 1), (-1, 0), (1, 0)):        # symmetric 4-blade rotor (a plus, not a pinwheel)
        rot |= line([(31.5, 41.5), (31.5 + 5 * dx, 41.5 + 5 * dy)], w=2)
    st.paint(grow(rot, 1), STEEL[2], solid=True)
    st.paint(rot, STEEL[0], solid=True)
    st.paint(rot & (CX > 31) & (CY > 41), STEEL[1])
    st.paint(rect(31, 41, 32, 42), STEEL[2], solid=True)
    st.eye(23, 26, look=(1, 0))
    st.eye(36, 26, look=(-1, 0))
    st.mouth('cat', 29, 33)
    for dx in (11, 52):
        st.paint(disc(dx, 32.5, 1.5), DROP[0], solid=True)
        st.dots([(dx, 32)], DROP[1])
    return key, st


# ------------------------------------------------------------------ 5. Noon Shade: inner-BBBB round, uncommon.
def noon_shade():
    key = 'pl-gaun-5'
    st = Sticker()
    core = (11, 13, 52, 50)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(CROWN)), contour=True)
    rim = body & ~shrink(body, 3)
    st.paint(rim & ((XX + YY) % 3 == 0), '#2a5a24')
    st.paint(rim & ((XX - YY) % 4 == 0), LEAFY[1])
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=SUN[0], skip=grow(holes, 3))          # uncommon accent: noon sun gold
    sun = disc(32, 38, 2.4)
    st.paint(sun, SUN[0], solid=True)
    st.dots([(31, 37)], SUN[1])
    closed_down(st, 22, 25)
    closed_down(st, 37, 25)
    st.mouth('grin', 30, 30)
    st.paint(rect(18, 30, 20, 30) | rect(43, 30, 45, 30), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Pampas Rider: whimsy-horse round, rare.
def pampas_rider():
    key = 'pl-gaun-6'
    st = Sticker()
    horse = ellipse(28, 40, 15, 7.5)
    neck = poly([(36, 38), (40, 24), (46, 24), (44, 40)])
    head = ellipse(47, 27, 6.5, 5) | ellipse(51, 30, 4, 3.4)
    ears = poly([(42, 23), (43, 17), (45, 22)]) | poly([(46, 22), (48, 17), (49, 23)])
    legs = blank()
    for lx in (17, 25, 32, 39):
        legs |= rect(lx - 2, 44, lx + 1, 52)
    tail = line([(13, 37), (9, 42), (10, 47)], w=3)
    body = horse | neck | head | ears | legs | tail | knob('n', 'round', 28, 33.5, r=3.0)
    st.part(body, tex=fill(key, body, 9, 17, 46, list(CHEST)), contour=True)
    st.paint(legs & (CY > 50), '#3a2216')                    # hooves
    st.paint(tail, '#4a2a1a')
    st.paint(line([(41, 22), (37, 34)], w=2) & neck, '#4a2a1a')   # mane
    st.paint(ellipse(52, 31, 2.6, 2) & (CY > 30), '#c8906a')   # muzzle
    st.dots([(53, 30)], UMBER)
    st.eye(44, 25, look=(1, 0))
    st.sprite(['U..U', '.UU.'], 50, 33, {'U': UMBER}, solid=False)
    # the chibi gaucho gnome on top
    gn = ellipse(27, 25, 7, 6)
    st.part(gn, SKIN, d=1, contour=True)
    beard = ellipse(27, 30, 7, 5) & (CY > 26)
    st.part(beard, BEARD[0], d=1, contour=True)
    st.paint(beard & ((XX + YY) % 4 == 0), BEARD[1])
    brim = rect(17, 18, 37, 19)
    crown = rect(21, 13, 33, 18)
    st.part(crown, '#3a2a20', d=1, contour=True)
    st.part(brim, '#2a1c14', d=1, contour=True)
    st.paint(rect(21, 17, 33, 17), HATRED[0])               # red band
    st.paint(rect(25, 22, 25, 23) | rect(29, 22, 29, 23), UMBER)
    st.sprite(['U...U', 'URRRU', '.UUU.'], 25, 26, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(21, 25, 22, 25) | rect(32, 25, 33, 25), BLUSH)
    st.sparkle(6, 6)
    st.sparkle(50, 8, big=False)
    st.sparkle(56, 44, big=False)
    return key, st


PALS = [redroof_rest, rail_lean, gourd_pass, windmill_whirl, noon_shade, pampas_rider]

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
