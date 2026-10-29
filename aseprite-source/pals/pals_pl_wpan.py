"""Puzzle Pals: PANDA BAMBOO GROVE (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-wpan-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_wpan.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: grove sprites, keyhole knobs, soft and curious. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy, zzz); everything else drawn here. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/wonder-panda-bamboo-grove.png, calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Knock-Knock Bamboo  bamboo-stalk green          | a tall jointed bamboo stalk it knocks on, leaf + knock marks      | cheeky wink, open grin
  2 Basket Munchkin     warm wheat                  | a woven bamboo bowl round its middle, a shoot in its mouth, crumbs | happy ^ ^ eyes, puffed cheeks, munch
  3 Sproutling Patch    grass sage-mint             | three pointy bamboo shoots + grass tufts poking up at its foot     | startled, looks up, o mouth
  4 Fuzzy Black Boots   olive meadow (+ sky stitch) | four plump black paws with grey toe beans, one per tab             | sleepy heavy lids, soft smile
  5 Dark Eye Patches    sky blue (+ bamboo stitch)  | two big tilted black eye patches round slow-blinking eyes          | half-lid slow blink, cat mouth
  6 Splinter Paw Panda  panda white + black parts   | whimsy seated panda, raised paw with a splinter, shoot, glow (rare)| serious flat brows, flat mouth
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-panda-bamboo-grove'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-panda-bamboo-grove-564306')

BAMBOO = ('#5f9a3a', '#82b850')        # bamboo stalk green
WHEAT = ('#c4a66a', '#dcc28a')         # warm wheat
SAGE = ('#86b89a', '#a8cfb6')          # grass sage-mint
OLIVE = ('#6b7645', '#848f55')         # olive meadow
SKY = ('#7fb4d4', '#a4cde6')           # sky blue
SNOW = ('#dfe2dc', '#f2f3ee')          # panda white (rare)
STALK = ('#6aa83e', '#3f7a2a', '#a6d46a', '#2a5a1e')
LEAF = ('#4f9a3a', '#2f6a2a', '#8cc85a')
WEAVE = ('#9a6a34', '#6a4422', '#c4945a')
SHOOT = ('#d8b878', '#a8844a', '#f0dca8')
INK = ('#2c2a30', '#1c1a20', '#4a4852')
BEAN = '#7a7884'
PINK = '#e8a0a8'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers
def stalk(st, x, y0, y1, w=4):
    """Upright bamboo stalk: green tube, light left side, dark joint rings every 9 px."""
    m = rect(x, y0, x + w - 1, y1)
    st.part(m, STALK[0], d=1, contour=True)
    st.paint(m & (XX == x + 1), STALK[2])
    for y in range(y0 + 7, y1 - 2, 9):
        st.paint(rect(x, y, x + w - 1, y), STALK[3])
        st.paint(rect(x, y + 1, x + w - 1, y + 1), STALK[2])
    return m


def leaf(st, x, y, L=7, up=True):
    pts = [(x + i, y - (i // 2 if up else -(i // 3))) for i in range(L)]
    m = blank()
    for i, (a, b) in enumerate(pts):
        m |= rect(a, b, a, b + (1 if 1 < i < L - 2 else 0))
    st.paint(m, LEAF[0], solid=True)
    st.paint(m & ~shift(m, 0, -1), LEAF[2])
    return m


def knock(st, x, y):
    """Two little knock arcs (cream, border only)."""
    for k, (dx, dy) in enumerate(((0, 0), (3, -3))):
        rows_ = ['C..', '.C.', '.C.', 'C..']
        for j, r in enumerate(rows_):
            for i, ch in enumerate(r):
                if ch == 'C':
                    st.px[y + dy + j, x + dx + i + k] = hx(CREAM)
                    st.extra[y + dy + j, x + dx + i + k] = True


def happy_eye(st, x, y):
    st.sprite(['.UUU.', 'UU.UU', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def bowl(st, cx, top, rx, h):
    m = ellipse(cx, top, rx, h) & (CY >= top)
    m |= rect(int(cx - rx), int(top) - 1, int(cx + rx) - 1, int(top))
    st.part(m, WEAVE[0], d=1, contour=True)
    inner = shrink(m, 1)
    st.paint(inner & ((XX + YY) % 4 == 0), WEAVE[1])
    st.paint(inner & ((XX - YY) % 4 == 0), WEAVE[2])
    st.paint(rect(int(cx - rx), int(top) - 1, int(cx + rx) - 1, int(top)) & m, WEAVE[2])
    return m


def shoot_cone(st, cx, by, h, w):
    m = poly([(cx - w, by), (cx, by - h), (cx + w, by)])
    st.part(m, SHOOT[0], d=1, contour=True)
    st.paint(m & (CX < cx - 0.3), SHOOT[2])
    st.paint(m & (CY < by - h * 0.62), LEAF[0])
    st.paint(m & (CY > by - h * 0.62) & (CY < by - h * 0.62 + 1), SHOOT[1])
    return m


def tuft(st, x, y):
    st.sprite(['G.G.G', 'GGgGG', '.GGG.'], x, y, {'G': LEAF[0], 'g': LEAF[2]}, solid=True)


def paw(st, cx, cy, r=4.2):
    m = disc(cx, cy, r)
    st.part(m, INK[0], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 1), INK[2])
    for dx, dy in ((-2, -1), (0, -2), (2, -1)):
        st.dots([(int(cx + dx), int(cy + dy))], BEAN)
    st.paint(rect(int(cx) - 1, int(cy) + 1, int(cx) + 1, int(cy) + 1), BEAN)
    return m


def patch(st, cx, cy, lean):
    m = poly([(cx - 4 + lean, cy - 5), (cx + 4 + lean, cy - 4), (cx + 4 - lean, cy + 6), (cx - 4 - lean, cy + 5)])
    m = grow(shrink(m, 1), 1) | ellipse(cx, cy + 0.5, 4.5, 5.6)
    st.paint(m, INK[0])
    st.paint(m & ~shift(m, 1, 1), INK[2])
    return m


# ------------------------------------------------------------------ 1. Knock-Knock Bamboo: corner-TT keyhole, common.
def knock_knock_bamboo():
    key = 'pl-wpan-1'
    st = Sticker()
    core = (20, 24, 46, 50)
    stalk(st, 9, 7, 53)
    leaf(st, 13, 17, L=7)
    body = piece(core, n=('T', 'keyhole', 3, 3.6), e=('T', 'keyhole', 2, 3.6))
    st.part(body, tex=fill(key, body, 20, 24, 27, list(BAMBOO)), contour=True)
    st.stitch(body, col='#c8e48a')
    st.part(ellipse(18.5, 38, 3, 2.4), BAMBOO[0], d=1, contour=True)     # the stubby knocking paw on the stalk
    knock(st, 14, 26)
    st.part(ellipse(26, 52, 3, 1.8), '#4a6a2a', d=1, contour=True)
    st.part(ellipse(40, 52, 3, 1.8), '#4a6a2a', d=1, contour=True)
    wink(st, 24, 33)
    st.eye(36, 32, look=(-1, 0))
    st.mouth('grin', 30, 41)
    st.paint(rect(23, 40, 25, 40) | rect(41, 40, 43, 40), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Basket Munchkin: edge-TBB keyhole, common.
def basket_munchkin():
    key = 'pl-wpan-2'
    st = Sticker()
    core = (14, 18, 49, 46)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', -4, 3.6), e=('B', 'keyhole', -3, 3.0), w=('B', 'keyhole', -3, 3.0))
    st.part(body, tex=fill(key, body, 14, 18, 36, list(WHEAT)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8a6a3a', skip=grow(holes, 3))
    bowl(st, 32, 40, 21, 13)
    happy_eye(st, 21, 27)
    happy_eye(st, 38, 27)
    st.paint(disc(19, 33, 2) | disc(45, 33, 2), BLUSH)
    st.sprite(['UUUU', 'URRU', '.UU.'], 30, 32, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    sh = line([(33, 34), (48, 24)], w=2)                                # the shoot it munches, poking out right
    st.part(sh, SHOOT[0], d=0, contour=True, shade=False)
    st.paint(sh & ~shift(sh, 0, -1), SHOOT[2])
    st.paint(disc(48.5, 23.5, 1.6), LEAF[0], solid=True)
    for x, y in ((51, 30), (53, 35)):                                   # a few crumbs dropping
        st.px[y, x] = hx(LEAF[2])
        st.extra[y, x] = True
    return key, st


# ------------------------------------------------------------------ 3. Sproutling Patch: inner-TBBB keyhole, common.
def sproutling_patch():
    key = 'pl-wpan-3'
    st = Sticker()
    core = (13, 15, 50, 48)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 4, 3.6), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 13, 15, 38, list(SAGE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e6f2d0', skip=grow(holes, 3))
    shoot_cone(st, 18, 53, 13, 3.5)
    shoot_cone(st, 45, 53, 10, 3)
    shoot_cone(st, 26, 54, 7, 2.5)
    tuft(st, 36, 50)
    st.eye(20, 25, look=(0, -1))
    st.eye(37, 25, look=(0, -1))
    st.paint(line([(20, 21), (24, 20)]) | line([(37, 20), (41, 21)]), UMBER)    # brows up: something poked me
    st.mouth('o', 29, 35)
    return key, st


# ------------------------------------------------------------------ 4. Fuzzy Black Boots: inner-TTTT double, uncommon.
def fuzzy_black_boots():
    key = 'pl-wpan-4'
    st = Sticker()
    core = (17, 17, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.6), e=('T', 'double', 0, 3.6), s=('T', 'double', 0, 3.6), w=('T', 'double', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(OLIVE)), contour=True)
    st.stitch(body, col=SKY[1])                                   # uncommon accent: the grove's sky blue
    for cx, cy in ((32, 11.5), (32, 52.5), (11.5, 32), (52.5, 32)):
        paw(st, cx, cy)
    st.eye(22, 27, lid=2)
    st.eye(37, 27, lid=2)
    st.paint(rect(20, 34, 22, 34) | rect(41, 34, 43, 34), BLUSH)
    st.mouth('smile', 30, 37)
    return key, st


# ------------------------------------------------------------------ 5. Dark Eye Patches: inner-BBBB keyhole, uncommon.
def dark_eye_patches():
    key = 'pl-wpan-5'
    st = Sticker()
    core = (11, 11, 52, 52)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.0), e=('B', 'keyhole', 0, 3.0), s=('B', 'keyhole', 0, 3.0),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 11, 11, 42, list(SKY)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=BAMBOO[1], skip=grow(holes, 3))          # uncommon accent: bamboo green
    patch(st, 23, 28, 1)
    patch(st, 41, 28, -1)
    st.eye(21, 27, lid=1, socket=None)
    st.eye(39, 27, lid=3, socket=None)                           # mid slow-blink
    st.paint(ellipse(32, 38, 2, 1.3), INK[0])
    st.mouth('cat', 30, 40)
    st.paint(rect(15, 37, 17, 37) | rect(46, 37, 48, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Splinter Paw Panda: whimsy-panda keyhole, rare.
def splinter_paw_panda():
    key = 'pl-wpan-6'
    st = Sticker()
    torso = ellipse(30, 44, 13, 10)
    head = ellipse(29, 26, 13, 9.5)
    tab = knob('w', 'keyhole', 45, 17.5, r=3.0)
    ears = disc(19, 17, 4) | disc(39, 17, 4)
    st.part(ears, INK[0], d=1, contour=True)
    body = torso | head | tab
    st.part(body, tex=fill(key, body, 11, 15, 36, list(SNOW)), contour=True)
    st.stitch(torso & ~head, col='#c8ccd4', skip=grow(head, 1))
    # black arm band and seated feet
    st.part(ellipse(30, 38, 13.5, 3) & torso, INK[0], d=0, contour=True, shade=False)
    st.part(ellipse(21, 52, 5, 3.5), INK[0], d=1, contour=True)
    st.part(ellipse(39, 52, 5, 3.5), INK[0], d=1, contour=True)
    st.paint(disc(21, 52, 1.6) | disc(39, 52, 1.6), PINK)
    # left paw holding a shoot
    sh = line([(17, 47), (13, 33)], w=2)
    st.part(sh, SHOOT[0], d=0, contour=True, shade=False)
    st.paint(disc(13, 32, 1.5), LEAF[0], solid=True)
    st.part(disc(17, 45, 3), INK[0], d=1, contour=True)
    # raised right arm + paw, pink pad, the splinter
    arm = line([(40, 40), (47, 24)], w=5)
    st.part(arm, INK[0], d=1, contour=True)
    pw = disc(48, 20, 4.2)
    st.part(pw, INK[0], d=1, contour=True)
    st.paint(disc(48, 20.5, 2.2), PINK)
    st.paint(line([(48, 20), (51, 16)]), '#8a5a2a', solid=True)
    st.dots([(52, 15)], '#c4945a')
    st.sil[15, 52] = True
    # serious face
    patch(st, 23, 26, 1)
    patch(st, 35, 26, -1)
    st.eye(21, 25, look=(1, 0), lid=1, socket=None)
    st.eye(33, 25, look=(1, 0), lid=1, socket=None)
    st.paint(rect(20, 21, 25, 21) | rect(33, 21, 38, 21), UMBER)      # level judge brows
    st.paint(ellipse(29, 31.5, 2, 1.2), INK[0])
    st.mouth('flat', 28, 33)
    st.sparkle(4, 8)
    st.sparkle(53, 6, big=False)
    st.sparkle(54, 34, big=False)
    return key, st


PALS = [knock_knock_bamboo, basket_munchkin, sproutling_patch, fuzzy_black_boots, dark_eye_patches, splinter_paw_panda]

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
