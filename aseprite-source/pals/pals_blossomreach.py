"""Puzzle Pals: BLOSSOMREACH roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_blossomreach.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py / pals_sunsprinkle.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own
cell of game/assets/img/jigsaw/blossomreach.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (cherry blossom, golden koi, bamboo stalk, pagoda roof, a red torii gate, the dragon-fly kite).
Picture palette (jigsaw_blossomreach.py): blush pink #f2a7bf / #d9789a, vermilion #d8432e, bamboo #7ab84f, slate roof #5a6280, misty violet
#a9a6cc, koi gold #f0b92b, paper #f6eedc, pond #5fa8a0.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('blossomreach')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'blossomreach':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

PINK, PINK_D, PINK_L = '#f2a7bf', '#d9789a', '#fbd3df'
ROSE_D = '#b8506f'
VERM, VERM_D, VERM_L = '#d8432e', '#a52a1e', '#f07a50'
SLATE, SLATE_D, SLATE_L = '#5a6280', '#3e445e', '#8a92b0'
BAMBOO, BAMBOO_D, BAMBOO_L = '#7ab84f', '#4a8a3a', '#b4d878'
KOI, KOI_D = '#f08a24', '#b85a14'
YEL, YEL_L = '#f0b92b', '#f8dc6a'
PAPER, PAPER_D = '#f6eedc', '#d9ccb0'
TEAL, TEAL_D = '#3f8fb0', '#25637d'
JADE = '#4f9a45'


def body_fill(key, mask, x0, y0, size, k=4, passes=2, dx=0.0, dy=0.0, swap=None):
    col, row = ROWS[key]['piece']
    t = pic.sample(col, row, x0, y0, size, dx, dy)
    t = majority(t, mask, passes)
    t = reduce(t, mask, k)
    if swap:
        t = remap(t, mask, swap)
    return t


def feet(st, xs, y, w=6, h=4):
    for x in xs:
        shoe = rect(x, y, x + w - 1, y + h - 1)
        shoe[y, x] = shoe[y, x + w - 1] = False
        st.part(shoe, SHOE[0], d=1, contour=True)


def blossom_mask(cx, cy, r=3.2, d=3.6):
    """Five round petals round a centre: a cherry blossom that still reads at 32 px."""
    import math
    m = disc(cx, cy, 2.2)
    for i in range(5):
        a = math.radians(-90 + i * 72)
        m |= disc(cx + d * math.cos(a), cy + d * math.sin(a), r)
    return m


def save_capped(st, path, glow, cap=38):
    """Sticker.finish, then fold the rarest fill colours into their nearest kept colour until the sticker has <= cap colours."""
    rgba, border = st.finish(glow)
    a = rgba[..., 3] > 0
    keyv = (rgba[..., 0].astype(np.int64) << 16) | (rgba[..., 1].astype(np.int64) << 8) | rgba[..., 2]
    vals, cnt = np.unique(keyv[a], return_counts=True)
    if len(vals) > cap:
        rgb = np.stack([(vals >> 16) & 255, (vals >> 8) & 255, vals & 255], -1).astype(np.int32)
        protect = {int(hx(c)[0]) << 16 | int(hx(c)[1]) << 8 | int(hx(c)[2]) for c in OL + (CREAM, UMBER, UMBER2, GOLD, '#000000')}
        order = [i for i in np.argsort(cnt) if int(vals[i]) not in protect]
        drop = set(order[:len(vals) - cap])
        keep = [i for i in range(len(vals)) if i not in drop]
        for i in drop:
            j = keep[int(((rgb[keep] - rgb[i]) ** 2).sum(-1).argmin())]
            rgba[a & (keyv == vals[i]), :3] = rgb[j]
    ys, xs = np.nonzero(border)
    margin = min(int(xs.min()), int(ys.min()), int(N - 1 - xs.max()), int(N - 1 - ys.max()))
    cols = len({tuple(p) for p in rgba[a][:, :3]})
    Image.fromarray(rgba, 'RGBA').save(path, optimize=True)
    return {'colours': cols, 'margin': margin}


# ------------------------------------------------------------------ 1. Petal Pinch: corner-TT round, common. Flat foot and back, tabs top and right, a cherry blossom on its top knob.
def petal_pinch():
    key = 'br-petal-pinch'
    st = Sticker()
    core = (9, 21, 41, 49)
    body = piece(core, s='F', w='F', n=('T', 'round', -2), e=('T', 'round', 2))
    st.part(body, tex=body_fill(key, body, 9, 21, 33, k=3, passes=3))
    st.stitch(body)
    feet(st, [12, 31], 50)
    fl = blossom_mask(23, 12.5)
    st.part(fl, PINK, d=2, contour=True)
    st.paint(disc(23, 12.5, 1.6), YEL)
    st.dots([(23, 12)], VERM)
    st.eye(14, 29, look=(1, 0))
    st.eye(27, 29, look=(1, 0))
    st.mouth('grin', 20, 38)
    return key, st


# ------------------------------------------------------------------ 2. Koi Kin: edge-TBT keyhole, common. Flat foot, tabs either side, blank on top, a golden koi at its hip.
def koi_kin():
    key = 'br-koi-kin'
    st = Sticker()
    core = (17, 21, 46, 49)
    body, holes = piece_blanks(core, r=3.6, s='F', w=('T', 'keyhole', 1), e=('T', 'keyhole', 1), n=('B', 'keyhole', 0, 3.8))
    st.part(body, tex=body_fill(key, body, 17, 21, 30, k=3, passes=3,
                                swap={'#c8483a': '#5fa8a0', '#e8806a': '#9fd0c8'}))   # pond koi out of the face
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [20, 37], 50)
    fish = ellipse(38, 44, 6.5, 3.6) | poly([(31, 44), (26, 40), (27, 44), (26, 48)])
    st.part(fish, KOI, d=2, contour=True)
    st.paint(ellipse(39, 43, 2.4, 1.4), CREAM)
    st.dots([(42, 43)], UMBER)
    st.eye(20, 29, look=(1, 0))
    st.eye(33, 29, look=(1, 0))
    st.mouth('o', 27, 37)
    return key, st


# ------------------------------------------------------------------ 3. Panda Puff: inner-TTTB peg, common. Blank underfoot, sleepy, a bamboo stalk to chew.
def panda_puff():
    key = 'br-panda-puff'
    st = Sticker()
    core = (16, 20, 43, 45)
    body, holes = piece_blanks(core, n=('T', 'peg'), e=('T', 'peg', 1), w=('T', 'peg', 1), s=('B', 'peg', 0, 4.2))
    st.part(body, tex=body_fill(key, body, 16, 20, 28, k=3, passes=3, swap={'#3a3440': '#dcd8ce', '#8cc45a': '#f6f4ee'}))   # calm the fur: white + soft grey, bamboo stays on the stalk
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    # panda markings: dark ear patches on the top corners, slanted eye patches
    st.paint(body & (CY < 23) & ((CX < 20) | (CX > 39)), '#3a3440')
    st.paint(ellipse(22.5, 30.5, 4.5, 5) | ellipse(35.5, 30.5, 4.5, 5), '#3a3440')
    feet(st, [16, 38], 46)
    stalk = rect(47, 10, 49, 52)
    st.part(stalk, BAMBOO, d=1, contour=True)
    for ny in (19, 30, 41):
        st.paint(rect(47, ny, 49, ny), BAMBOO_D)
    leaf = poly([(49, 12), (55, 7), (57, 9), (50, 14)])
    st.part(leaf, BAMBOO_L, d=1, contour=True)
    st.eye(20, 28, look=(0, 1), lid=1, socket=None)
    st.eye(33, 28, look=(0, 1), lid=1, socket=None)
    st.sprite(['UUU', '.U.'], 28, 35, {'U': UMBER}, solid=False)
    st.mouth('smile', 27, 38)
    return key, st


# ------------------------------------------------------------------ 4. Pagoda Pin: inner-TTTT double, uncommon. Plus shape under a slate pagoda roof with a gold spire; blush tips + vermilion stitch.
def pagoda_pin():
    key = 'br-pagoda-pin'
    st = Sticker()
    core = (18, 22, 44, 47)
    body = piece(core, n=('T', 'double'), e=('T', 'double'), s=('T', 'double'), w=('T', 'double'))
    st.part(body, tex=body_fill(key, body, 18, 22, 27))
    tips = body & ~rect(14, 18, 48, 51) & (CY > 14)
    st.part(tips, PINK, d=2)
    st.stitch(body, col=VERM_D)
    roof = poly([(17, 17), (21, 14), (41, 14), (45, 17), (47, 15), (46, 19), (16, 19), (15, 15)])
    st.part(roof, SLATE, d=2, contour=True)
    st.paint(rect(22, 14, 40, 14), SLATE_L)
    st.part(rect(30, 6, 32, 13), YEL, d=1, contour=True)
    st.paint(rect(29, 9, 33, 9), YEL_L)
    st.eye(22, 27, look=(1, -1))
    st.eye(34, 27, look=(1, -1))
    st.mouth('smirk', 28, 37)
    return key, st


# ------------------------------------------------------------------ 5. Torii Loop: inner-BBBB hook, uncommon. The Ring: four blanks, a red torii gate to hop through; bamboo stitch.
def torii_loop():
    key = 'br-torii-loop'
    st = Sticker()
    core = (10, 12, 50, 50)
    body, holes = piece_blanks(core, n=('B', 'hook', 0, 3.6), e=('B', 'hook', 0, 3.6), s=('B', 'hook', 0, 3.6), w=('B', 'hook', 0, 3.6))
    st.part(body, tex=body_fill(key, body, 10, 12, 41, k=2, passes=6,
                                swap={'#2a1a10': '#e8664a', '#a52a1e': '#d8432e'}))   # calm: one vermilion lacquer with soft light patches
    st.blank_shade(body, holes)
    st.stitch(body, col=BAMBOO_D, skip=grow(holes, 3))
    st.paint(body & rect(41, 41, 53, 54), '#d8d2c2')                  # the stone steps seen through the gate, so the red gate reads
    st.paint(body & rect(41, 47, 53, 47), '#b9b2a2')
    st.paint(body & rect(41, 51, 53, 51), '#b9b2a2')
    posts = rect(42, 41, 44, 55) | rect(50, 41, 52, 55)
    st.part(posts, VERM, d=1, contour=True)
    st.part(rect(40, 44, 54, 45), VERM, d=1, contour=True)
    kasagi = rect(39, 38, 55, 40) | rect(38, 37, 39, 37) | rect(55, 37, 56, 37)
    st.part(kasagi, UMBER2, d=0, contour=True)
    st.eye(20, 22, look=(1, 0))
    st.eye(33, 22, look=(1, 0))
    st.mouth('grin', 26, 31)
    return key, st


# ------------------------------------------------------------------ 6. Dragon Dart: whimsy-dragonfly tri, rare. Head + thorax + long tail ending in a tri knob, four paper wings; glow + sparkles.
def dragon_dart():
    key = 'br-dragon-dart'
    st = Sticker()
    head = ellipse(31.5, 17.5, 11, 9)
    thorax = ellipse(31.5, 28, 5.5, 5)
    tail = rect(29, 28, 34, 45)
    tip = knob('s', 'tri', 32, 45.5, r=3.0)
    body = head | thorax | tail | tip
    # paper wings (the dragon-fly kite), behind the body: two long front wings, two shorter back wings
    wings = ellipse(18, 25, 10, 3.6) | ellipse(45, 25, 10, 3.6) | ellipse(20, 32, 8.5, 3.2) | ellipse(43, 32, 8.5, 3.2)
    wings &= ~body
    st.part(wings, PAPER, d=1, contour=True)
    st.paint(wings & ((np.abs(CY - 25) < 0.6) | (np.abs(CY - 32) < 0.6)) & shrink(wings, 1), TEAL)
    st.paint(wings & (CX < 13) & (CY < 29), PINK)
    st.paint(wings & (CX > 50) & (CY < 29), PINK)
    st.part(body, tex=body_fill(key, body, 16, 9, 32, k=3, passes=3), contour=True)
    st.stitch(head)
    for sy in (35, 39, 43):
        st.paint(rect(29, sy, 34, sy) & body, TEAL_D)
    st.eye(23, 14, look=(1, 0))
    st.eye(35, 14, look=(1, 0))
    st.mouth('smile', 29, 22)
    st.sparkle(6, 7)
    st.sparkle(53, 44, big=False)
    st.sparkle(8, 43)
    return key, st


PALS = [petal_pinch, koi_kin, panda_puff, pagoda_pin, torii_loop, dragon_dart]

if __name__ == '__main__':
    print('dominant', pic.dominant(4))
    paths = []
    for fn in PALS:
        key, st = fn()
        assert key in ROWS, key
        p = os.path.join(OUTDIR, key + '.png')
        info = save_capped(st, p, glow=(ROWS[key]['rarity'] == 'rare'))
        paths.append(p)
        print('%-20s %-9s %-11s %-6s colours %d margin %d' % (key, ROWS[key]['rarity'], ROWS[key]['shape'], ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
