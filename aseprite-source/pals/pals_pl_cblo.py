"""Puzzle Pals: CHERRY BLOSSOM TEAHOUSE (haven, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-cblo-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_cblo.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Haven mood: cosy hearth folk of an East Asian hilltop teahouse at dawn. kit_lair parts used only as building blocks
(PlacePic, rows, cell_fill, calm_tones, tidy); everything else drawn here. Silhouette = row shape + knob,
body = its own cell of game/assets/img/jigsaw/places/haven-cherry-blossom-teahouse.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Teapot Tilt       cornflower teapot blue  | a teapot lid + spout pouring a drip, handle loop     | side glance down, smile
  2 Sakura Flurry     sakura pink             | a blossom crown (3 flowers) + falling petals        | laughing ^ ^ eyes, big grin
  3 Fuji Bow          dusk mauve mountain     | a white snowcap on its head, mist band              | bowing closed v eyes, 'o'
  4 Lantern Bob       lantern red (+ gold)    | gold cap + foot bands, ribs, a glowing tassel       | wide round eyes, cat mouth
  5 Roof Medallion    medallion gold (+indigo)| an indigo roof-tile rim, dawn sun rays              | looks up, smirk
  6 Hilltop Teahouse  timber brown, indigo roof | whimsy teahouse, curly eaves, warm window, glow   | sleepy lids, soft smile, blush, waving
Ring and Plus are mirror-symmetric (all knobs centred, east/west at the same height).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'haven-cherry-blossom-teahouse'
pic = PlacePic(SLUG)
ROWS = rows('pl-haven-cherry-blossom-teahouse-ad6328')

POT = ('#3e70b4', '#5a90d0')
SAKURA = ('#e08aa6', '#f2b0c4')
FUJI = ('#86729e', '#a28eba')
LANT = ('#c0362e', '#da5440')
MEDAL = ('#d6a23a', '#ecc25a')
TIMBER = ('#8a5a34', '#a8744a')
INDIGO = ('#2e3466', '#454c8a', '#6a72b0')
PETAL = ('#f6c4d4', '#d87494', '#fff0f4')
SNOW = ('#f6f8fc', '#c8d0e4')
GOLDB = ('#e8b23a', '#fff0a0', '#9a6a18')
WARM = ('#f8c860', '#fff0b0')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def closed_up(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


def closed_down(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def petal(st, x, y):
    st.sprite(['.P.', 'PpP', '.P.'], x, y, {'P': PETAL[0], 'p': PETAL[1]}, solid=True)


def blossom(st, cx, cy):
    m = blank()
    for k in range(5):
        a = -math.pi / 2 + k * 2 * math.pi / 5
        m |= disc(cx + 2.2 * math.cos(a), cy + 2.2 * math.sin(a), 1.7)
    st.part(m, PETAL[0], d=1, contour=True)
    st.paint(disc(cx, cy, 1.0), PETAL[1], solid=True)
    st.dots([(int(cx), int(cy))], GOLDB[0])
    return m


# ------------------------------------------------------------------ 1. Teapot Tilt: corner-TB round, common.
def teapot_tilt():
    key = 'pl-cblo-1'
    st = Sticker()
    core = (14, 22, 44, 51)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', 0, 3.6), e=('B', 'round', 2, 2.8))
    handle = ellipse(12, 36, 5, 7) & ~ellipse(12, 36, 2.6, 4.4) & (CX < 15)
    st.part(handle, POT[0], d=1, contour=True)
    spout = line([(44, 44), (52, 36), (55, 33)], w=3)
    st.part(spout, POT[0], d=1, contour=True)
    st.part(body, tex=fill(key, body, 14, 22, 31, list(POT)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#bcd4f0', skip=grow(holes, 3))
    lid = ellipse(29, 13, 6, 2.4)
    st.part(lid, POT[1], d=1, contour=True)
    st.part(disc(29, 9.5, 1.8), SNOW[0], d=1, contour=True)
    st.paint(rect(55, 36, 55, 37) | rect(55, 40, 55, 41), SNOW[1], solid=True)
    st.extra |= rect(55, 36, 55, 41)
    st.eye(21, 31, look=(1, 1))
    st.eye(33, 31, look=(1, 1))
    st.mouth('smile', 26, 40)
    st.paint(rect(18, 38, 20, 38) | rect(37, 38, 39, 38), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Sakura Flurry: edge-TTB peg, common.
def sakura_flurry():
    key = 'pl-cblo-2'
    st = Sticker()
    core = (14, 24, 44, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', -6, 3.4), e=('T', 'peg', 3, 3.4), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 14, 24, 31, list(SAKURA)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=PETAL[2], skip=grow(holes, 3))
    blossom(st, 22, 13)
    blossom(st, 32, 10)
    blossom(st, 41, 15)
    petal(st, 50, 22)
    petal(st, 8, 14)
    petal(st, 52, 52)
    closed_up(st, 19, 32)
    closed_up(st, 33, 32)
    st.mouth('grin', 26, 39)
    st.paint(rect(17, 37, 19, 37) | rect(38, 37, 40, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Fuji Bow: inner-TBTB round, common.
def fuji_bow():
    key = 'pl-cblo-3'
    st = Sticker()
    core = (14, 18, 46, 44)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.6), e=('B', 'round', 0, 2.8), s=('T', 'round', -6, 3.6), w=('B', 'round', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 18, 33, list(FUJI)), contour=True)
    st.blank_shade(body, holes, width=1)
    cap = body & ((CY < 21) | (CY < 24 + 2 * ((XX % 6) < 3)))
    st.paint(cap & shrink(body, 0), SNOW[0])
    st.paint(cap & (CX > 38), SNOW[1])
    st.stitch(body, col='#d8cce8', skip=grow(holes, 3) | cap)
    st.paint(rect(16, 40, 44, 40) & body & ((XX % 4) < 3), '#dcd6ec')      # valley mist band
    st.eye(21, 28, lid=4)
    st.eye(35, 28, lid=4)
    st.mouth('smile', 28, 35)
    st.paint(rect(18, 33, 20, 33) | rect(40, 33, 42, 33), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Lantern Bob: inner-TTTT peg, uncommon.
def lantern_bob():
    key = 'pl-cblo-4'
    st = Sticker()
    core = (17, 18, 46, 46)
    body = piece(core, n=('T', 'peg', 0, 3.4), e=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), w=('T', 'peg', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 18, 30, list(LANT)), contour=True)
    for x in (23, 40):                                         # paper ribs, mirrored
        st.paint(rect(x, 22, x, 42) & body, '#8e2420')
    st.paint(rect(19, 20, 44, 22) & body, GOLDB[0])            # uncommon accent: gold cap + foot bands
    st.paint(rect(19, 42, 44, 44) & body, GOLDB[0])
    st.paint(rect(19, 20, 44, 20) & body, GOLDB[1])
    st.stitch(body, col=GOLDB[1])
    st.eye(25, 28, look=(0, 0))
    st.eye(34, 28, look=(0, 0))
    st.mouth('cat', 29, 35)
    st.paint(rect(21, 34, 23, 34) | rect(40, 34, 42, 34), '#f4a08a')
    return key, st


# ------------------------------------------------------------------ 5. Roof Medallion: inner-BBBB round, uncommon.
def roof_medallion():
    key = 'pl-cblo-5'
    st = Sticker()
    core = (11, 13, 52, 50)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 13, 42, list(MEDAL)), contour=True)
    rim = body & ~shrink(body, 3)
    st.paint(rim, INDIGO[0])                                   # uncommon accent: indigo roof tiles
    st.paint(rim & ((XX + YY) % 3 == 0), INDIGO[2])
    st.blank_shade(body, holes, width=1)
    face = disc(31.5, 31, 11) & ~disc(31.5, 31, 10)
    st.paint(face, GOLDB[2])
    for a in range(8):                                         # dawn rays
        t = a * math.pi / 4 + math.pi / 8
        st.dots([(int(round(31.5 + 13.5 * math.cos(t))), int(round(31 + 13.5 * math.sin(t))))], GOLDB[1])
    st.eye(24, 25, look=(0, -1))
    st.eye(35, 25, look=(0, -1))
    st.mouth('smirk', 29, 34)
    st.paint(rect(22, 32, 24, 32) | rect(39, 32, 41, 32), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Hilltop Teahouse: whimsy-teahouse peg, rare.
def hilltop_teahouse():
    key = 'pl-cblo-6'
    st = Sticker()
    walls = rect(17, 28, 46, 46)
    tab = knob('s', 'peg', 32, 46, r=3.2)
    body = walls | tab
    st.part(body, tex=fill(key, body, 14, 26, 36, list(TIMBER)), contour=True)
    roof = poly([(11, 30), (14, 26), (19, 18), (45, 18), (50, 26), (53, 30), (48, 28), (16, 28)])
    roof |= disc(11, 28.5, 1.6) | disc(53, 28.5, 1.6)               # curly eave tips
    st.part(roof, INDIGO[1], d=1, contour=True)
    st.paint(roof & (CY < 21), INDIGO[2])
    st.paint(rect(14, 27, 50, 27) & roof, INDIGO[0])
    st.part(disc(32, 14, 3.2), GOLDB[0], d=1, contour=True)    # the roof medallion
    win = rect(35, 32, 43, 41)
    st.paint(win, WARM[0], solid=True)
    st.paint(rect(36, 33, 42, 36), WARM[1], solid=True)
    st.paint(rect(39, 32, 39, 41) | rect(35, 37, 43, 37), TIMBER[0])
    st.eye(19, 33, lid=2)
    st.eye(28, 33, lid=2)
    st.mouth('smile', 22, 41)
    st.paint(rect(17, 40, 19, 40) | rect(31, 40, 33, 40), BLUSH)
    arm = line([(47, 40), (50, 37), (51, 34)], w=2)            # waving hand
    st.part(arm, TIMBER[1], d=1, contour=True)
    st.part(disc(51.5, 33, 1.8), TIMBER[1], d=1, contour=True)
    st.sparkle(9, 9)
    st.sparkle(48, 8, big=False)
    st.sparkle(10, 40, big=False)
    return key, st


PALS = [teapot_tilt, sakura_flurry, fuji_bow, lantern_bob, roof_medallion, hilltop_teahouse]

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
