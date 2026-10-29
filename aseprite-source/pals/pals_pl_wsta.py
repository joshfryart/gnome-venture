"""Puzzle Pals: STARPATH CANOE (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wsta-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wsta.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: night-beach sprites, keyhole knobs, soft and curious. kit_lair parts used only as building blocks (PlacePic, rows,
cell_fill, calm_tones, tidy, flame, zzz); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art
px cell of game/assets/img/jigsaw/places/wonder-starpath-canoe.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Dot-to-Dot Sky       night indigo blue          | gold star dots joined by thin lines across it, a star on its knob  | looking up, o wonder
  2 Hazy Island Nap      hazy island mauve          | a little island hump + palm on its head, zzz, sea line at its feet  | sleepy lids, smirk
  3 Torchlet Wiggle      bamboo torch tan           | a wiggling flame crown, lashing bands, sand pile                    | happy ^ ^ eyes, tooth grin
  4 Cream Sail Billow    sail cream (+ red)         | mast pole through it, red sail mark, breeze lines both sides       | wide eyes, smile
  5 Crescent Hull Smile  dark hull maroon (+ gold)  | crescent canoe hull cradling it, gold prow knob, paddle            | glance aside, grin
  6 Starwise Cheerer     navigator brown            | whimsy navigator, red headband, arms raised, gold star, glow (rare)| brows up, cat mouth
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-starpath-canoe'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-starpath-canoe-a8df46')

SKY = ('#2a2e6a', '#3e4490')           # night indigo
ISLE = ('#6a5078', '#8a6e96')          # hazy island mauve
TORCH = ('#c8985a', '#dcb478')         # bamboo torch tan
SAIL = ('#dccaa0', '#efe2c0')          # sail cream
HULL = ('#6e3a3c', '#8c5250')          # dark hull maroon
NAV = ('#7a4a2e', '#9a6644')           # navigator brown (rare)
GOLDC = ('#e8c040', '#b88a20', '#fff0a0')
REDM = ('#c8323a', '#e8585a')
SEA = ('#3a6a9a', '#7aa8d0')
PALM = ('#3f7a3a', '#6aa850')
SANDC = ('#d8b878', '#b89458')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def mark(st, pts, col):
    for x, y in pts:
        st.px[y, x] = hx(col)
        st.extra[y, x] = True


def star(st, cx, cy, col=GOLDC[0]):
    mark(st, [(cx, cy - 1), (cx - 1, cy), (cx + 1, cy), (cx, cy + 1)], col)
    mark(st, [(cx, cy)], GOLDC[2])


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


# ------------------------------------------------------------------ 1. Dot-to-Dot Sky: corner-TB keyhole, common.
def dot_to_dot_sky():
    key = 'pl-wsta-1'
    st = Sticker()
    core = (12, 18, 46, 50)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', -5, 3.6), e=('B', 'keyhole', 2, 3.0))
    st.part(body, tex=fill(key, body, 12, 12, 38, list(SKY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8a90d0', skip=grow(holes, 3))
    pts = [(16, 22), (24, 25), (40, 21), (42, 45), (17, 46)]
    inner = shrink(body, 3)
    for a, b in zip(pts, pts[1:]):
        st.paint(line([a, b]) & inner & ~rect(18, 28, 40, 41), GOLDC[0])
    for x, y in pts:
        st.paint(disc(x, y, 1.6), GOLDC[2])
    star(st, 24, 9)
    st.eye(20, 31, look=(0, -1))
    st.eye(33, 31, look=(0, -1))
    st.mouth('o', 26, 38)
    st.paint(rect(16, 37, 18, 37) | rect(39, 37, 41, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Hazy Island Nap: edge-TBB keyhole, common.
def hazy_island_nap():
    key = 'pl-wsta-2'
    st = Sticker()
    core = (12, 24, 48, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 6, 3.4), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 12, 18, 36, list(ISLE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c0a8cc', skip=grow(holes, 3))
    hump = ellipse(22, 23, 8, 4) & (CY < 24)                            # tiny island on its head
    st.part(hump, '#4e3a5e', d=1, contour=True)
    st.paint(line([(22, 20), (21, 13)]), '#7a5a3a')                     # palm trunk
    st.part(ellipse(18, 13, 4, 1.6) | ellipse(25, 13, 4, 1.6), PALM[0], d=1, contour=True)
    st.paint(rect(14, 46, 46, 46) & shrink(body, 2), SEA[1])            # sea line lapping its feet
    zzz(st, 50, 10)
    st.eye(20, 33, lid=2)
    st.eye(34, 33, lid=2)
    st.mouth('smirk', 26, 41)
    st.paint(rect(16, 40, 18, 40) | rect(40, 40, 42, 40), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Torchlet Wiggle: inner-TBTB keyhole, common.
def torchlet_wiggle():
    key = 'pl-wsta-3'
    st = Sticker()
    core = (15, 22, 47, 48)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.4), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.4),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 16, 16, 32, list(TORCH)), contour=True)
    st.blank_shade(body, holes, width=1)
    for y in (26, 44):                                                   # lashing bands
        st.paint(rect(16, y, 46, y) & shrink(body, 1) & ~grow(holes, 2), '#6a4422')
    st.stitch(body, col='#e8cc90', skip=grow(holes, 3) | rect(0, 25, 63, 27) | rect(0, 43, 63, 45))
    flame(st, 31, 18, w=8, h=10, lean=0.8, licks=2)
    st.part(ellipse(50, 55, 4, 2), SANDC[0], d=1, contour=True)           # warm sand pile
    happy_eye(st, 21, 30)
    happy_eye(st, 36, 30)
    st.mouth('tooth', 29, 37)
    st.paint(rect(21, 36, 23, 36) | rect(39, 36, 41, 36), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Cream Sail Billow: inner-TTTT double, uncommon.
def cream_sail_billow():
    key = 'pl-wsta-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(SAIL)), contour=True)
    st.stitch(body, col=REDM[0])                                        # uncommon accent: sail red
    st.paint(rect(31, 18, 32, 45) & ~rect(18, 24, 45, 41), '#7a5030')   # mast through it, top and bottom
    st.part(rect(29, 37, 34, 41), REDM[0], d=1, contour=True)            # the little red mark
    mark(st, [(5, 21), (6, 21), (7, 21), (56, 21), (57, 21), (58, 21)], SEA[1])   # breeze lines, mirrored
    st.eye(23, 26)
    st.eye(36, 26)
    st.mouth('smile', 30, 33)
    st.paint(rect(20, 32, 22, 32) | rect(41, 32, 43, 32), BLUSH)
    return key, st


# ------------------------------------------------------------------ 5. Crescent Hull Smile: inner-TTBB keyhole, uncommon.
def crescent_hull_smile():
    key = 'pl-wsta-5'
    st = Sticker()
    core = (16, 19, 46, 42)
    body, holes = piece_blanks(core, n=('T', 'keyhole', -4, 3.4), e=('T', 'keyhole', -2, 3.4), s=('B', 'keyhole', 4, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    hull = (ellipse(32, 42, 24, 12) & ~ellipse(32, 35, 22, 10) & (CY > 40)) & ~holes
    body = body | hull
    st.part(body, tex=fill(key, body, 6, 12, 52, list(HULL)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=GOLDC[0], skip=grow(holes, 3))                  # uncommon accent: gold trim
    st.part(disc(10, 43, 2.5), GOLDC[0], d=1, contour=True)              # prow knob
    st.part(disc(54, 43, 2.5), GOLDC[0], d=1, contour=True)
    st.paint(rect(16, 49, 48, 49) & shrink(body, 1), GOLDC[1])
    st.eye(22, 25, look=(1, 0))
    st.eye(35, 25, look=(1, 0))
    st.mouth('grin', 28, 33)
    st.paint(rect(19, 32, 21, 32) | rect(41, 32, 43, 32), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Starwise Cheerer: whimsy-navigator keyhole, rare.
def starwise_cheerer():
    key = 'pl-wsta-6'
    st = Sticker()
    for sx in (-1, 1):                                                   # arms cheering up
        x0 = 32 + sx * 15
        arm = line([(32 + sx * 11, 36), (x0, 26), (x0 + sx * 2, 21)], w=3)
        st.part(arm, NAV[1], d=1, contour=True)
        st.part(disc(x0 + sx * 2, 19, 2.6), NAV[1], d=1, contour=True)
    tab = knob('s', 'keyhole', 32, 48, r=3.0)
    head = disc(32, 26, 11)
    torso = ellipse(32, 41, 11, 7)
    body = head | torso | tab
    st.part(body, tex=fill(key, body, 18, 14, 30, list(NAV)), contour=True)
    st.part(torso & (CY > 40) & ~tab, '#e0a838', d=1, contour=True)      # sash wrap
    st.paint(rect(22, 45, 42, 45) & torso, REDM[0])
    st.part(head & (CY < 20), '#2a1a18', d=1, contour=True)              # hair
    st.part(rect(21, 19, 43, 21) & grow(head, 1), REDM[0], d=1, contour=True)   # bright headband
    st.paint(rect(22, 20, 42, 20) & head, REDM[1])
    st.part(disc(32, 11, 2.4) | poly([(32, 8), (35, 11), (32, 14), (29, 11)]), GOLDC[0], d=1, contour=True)   # the star
    st.dots([(31, 10)], GOLDC[2])
    st.eye(25, 24, look=(0, -1))
    st.eye(34, 24, look=(0, -1))
    st.paint(line([(25, 22), (29, 22)]) | line([(34, 22), (38, 22)]), UMBER)
    st.mouth('cat', 30, 31)
    st.paint(rect(23, 30, 25, 30) | rect(39, 30, 41, 30), BLUSH)
    st.sparkle(5, 5)
    st.sparkle(54, 32, big=False)
    st.sparkle(6, 40, big=False)
    return key, st


PALS = [dot_to_dot_sky, hazy_island_nap, torchlet_wiggle, cream_sail_billow, crescent_hull_smile, starwise_cheerer]

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
