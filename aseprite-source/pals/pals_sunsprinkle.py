"""Puzzle Pals: THE SUNSPRINKLE ISLES roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_sunsprinkle.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own cell of
game/assets/img/jigsaw/sunsprinkle.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (scallop shell, palm crown, starfish, coral, the red-and-cream life ring, the sloop's sail + paddle).
Picture palette (jigsaw_sunsprinkle.py): sea #2bb3bf / #1f8fa8, sand #f2d9a0, palm #4fae4a, coral #f2827a, pink coral #f6a0b8, coconut #8a5a2a.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('sunsprinkle')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'sunsprinkle':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

CORAL, CORAL_D, CORAL_L = '#f2827a', '#c8504f', '#ffb3a6'
PINK, PINK_D = '#f6a0b8', '#d0607f'
PALM, PALM_D, PALM_L = '#4fae4a', '#2f7a3a', '#8fd06a'
COCO, COCO_D, COCO_L = '#8a5a2a', '#5c3420', '#b07a3a'
TURQ, TURQ_D = '#2bb3bf', '#1a7f8f'
SAIL = '#fff4e8'
YEL = '#f0b92b'
WOOD = '#b07a3a'
RED = '#d6322b'


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


def star_mask(cx, cy, ro, ri, rot=-90.0):
    import math
    pts = []
    for i in range(10):
        a = math.radians(rot + i * 36)
        r = ro if i % 2 == 0 else ri
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return poly(pts)


# ------------------------------------------------------------------ 1. Shell Skip: corner-BB keyhole, common. Flat foot and back, blanks top and right, a scallop-shell cap.
def shell_skip():
    key = 'ss-shell-skip'
    st = Sticker()
    core = (11, 19, 44, 48)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'keyhole', 3), e=('B', 'keyhole', 3))
    st.part(body, tex=body_fill(key, body, 11, 19, 34))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [14, 32], 49)
    # scallop shell cap on the flat top-left corner: a fan with ribs and a hinge
    ang = np.arctan2(CY - 23.0, CX - 18.0)
    fan = ellipse(18, 23, 10.5, 11.5) & (CY < 22.5)
    for i in range(7):                                  # scalloped rim: one bump per rib
        a = np.pi + (i + 0.5) * np.pi / 7
        fan |= disc(18 + 10.7 * np.cos(a), 23 + 11.7 * np.sin(a), 2.0) & (CY < 22.5)
    ears = poly([(12, 19), (15, 19), (16, 24), (11, 24)]) | poly([(21, 19), (24, 19), (25, 24), (20, 24)])
    st.part(ears, CORAL, d=1, contour=True)
    st.part(fan, PINK, d=2, contour=True)
    rib = fan & shrink(fan, 1) & ((np.floor((ang + np.pi) / (np.pi / 14)).astype(int) % 2) == 0) & (CY < 21)
    st.paint(rib, PINK_D)
    st.eye(15, 28, look=(1, 0))
    st.eye(27, 28, look=(1, 0))
    st.mouth('grin', 20, 37)
    return key, st


# ------------------------------------------------------------------ 2. Palm Fidget: edge-BTB keyhole, common. Flat foot, blanks either side, a palm crown sprouting from its top knob.
def palm_fidget():
    key = 'ss-palm-fidget'
    st = Sticker()
    core = (13, 26, 50, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole'), w=('B', 'keyhole', 5), e=('B', 'keyhole', 5))
    st.part(body, tex=body_fill(key, body, 13, 26, 38, passes=3, k=3, dy=0.05))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [17, 40], 51, w=7)
    # palm crown: four broad fronds from the knob top, two coconuts at the root
    fr = poly([(32, 15), (24, 8), (16, 9), (11, 14), (20, 12), (27, 14)]) | poly([(32, 15), (40, 8), (48, 9), (53, 14), (44, 12), (37, 14)]) | \
        poly([(31, 16), (22, 15), (14, 19), (12, 24), (19, 19), (26, 18)]) | poly([(33, 16), (42, 15), (50, 19), (52, 24), (45, 19), (38, 18)])
    st.part(fr, PALM, d=2, contour=True)
    st.paint(line([(31, 15), (18, 10)]) | line([(33, 15), (46, 10)]) | line([(30, 16), (17, 19)]) | line([(34, 16), (47, 19)]), PALM_D)
    nut = disc(29, 16.5, 2.6) | disc(35, 16.5, 2.6)
    st.part(nut, COCO, d=1, contour=True)
    st.dots([(28, 15), (34, 15)], COCO_L)
    st.eye(22, 28, look=(-1, 0))
    st.eye(36, 28, look=(1, 0))
    st.mouth('o', 30, 37)
    return key, st


# ------------------------------------------------------------------ 3. Tide Tuck: inner-TTTB round, common. Blank underfoot, sleepy, an orange starfish on its top knob.
def tide_tuck():
    key = 'ss-tide-tuck'
    st = Sticker()
    core = (17, 20, 44, 45)
    body, holes = piece_blanks(core, n=('T', 'round'), e=('T', 'round', 1), w=('T', 'round', 1), s=('B', 'round', 0, 4.4))
    st.part(body, tex=body_fill(key, body, 17, 20, 28, k=3, passes=3,
                                swap={'#8a5a2a': '#d9b77a', '#5c3420': '#c9a46a', '#b88f68': '#c9a46a', '#d0a87e': '#f2d9a0'}))   # calm the coconuts: sand reads under a face
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [17, 39], 46, w=6, h=4)
    star = star_mask(43, 15.5, 8, 3.6, rot=-80)
    st.part(star, '#f08a24', d=2, contour=True)
    st.dots([(43, 15), (42, 11), (46, 13), (40, 17), (45, 18)], '#f8dc6a')
    st.eye(21, 27, look=(0, 1), lid=1)
    st.eye(34, 27, look=(0, 1), lid=1)
    st.mouth('smile', 26, 36)
    return key, st


# ------------------------------------------------------------------ 4. Coral Cuff: inner-TTTT double, uncommon. Plus shape, each double knob tipped with pink coral; coral stitch.
def coral_cuff():
    key = 'ss-coral-cuff'
    st = Sticker()
    core = (18, 20, 44, 46)
    body = piece(core, n=('T', 'double'), e=('T', 'double'), s=('T', 'double'), w=('T', 'double'))
    st.part(body, tex=body_fill(key, body, 18, 20, 27))
    tips = body & ~rect(14, 16, 48, 50)
    st.part(tips, PINK, d=2)
    st.stitch(body, col=CORAL_D)
    st.paint(tips & shrink(tips, 1) & (((XX + YY) % 4) == 0), CORAL_L)    # polyp dots
    st.eye(22, 27, look=(1, 0))
    st.eye(34, 27, look=(1, 0))
    st.mouth('cat', 29, 37)
    return key, st


# ------------------------------------------------------------------ 5. Lagoon Loop: inner-BBBB keyhole, uncommon. The Ring: four blanks, a wink, a red-and-cream life ring; teal stitch.
def lagoon_loop():
    key = 'ss-lagoon-loop'
    st = Sticker()
    core = (10, 12, 50, 50)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.6), s=('B', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.6))
    st.part(body, tex=body_fill(key, body, 10, 12, 41, k=3, passes=3, dx=-0.2,
                                swap={'#efe0c0': '#5fd3cc', '#c9b48a': '#a6ece0', '#74462a': '#1f8fa8', '#4a2c1a': '#1f8fa8'}))
    st.blank_shade(body, holes)
    st.stitch(body, col=TURQ_D, skip=grow(holes, 3))
    # life ring on the lower right corner
    ring = disc(46, 46, 8) & ~disc(46, 46, 3.6)
    st.part(ring, RED, d=2, contour=True)
    seg = ring & shrink(ring, 1) & ((np.abs(CX - 46) < 1.6) | (np.abs(CY - 46) < 1.6))
    st.paint(seg, SAIL)
    st.eye(22, 24, look=(1, 0))
    st.sprite(['.UUU.', 'U...U', 'U...U'], 33, 25, {'U': UMBER}, solid=False)   # the wink: a closed eye, 5 px wide
    st.mouth('smile', 26, 33)
    return key, st


# ------------------------------------------------------------------ 6. Cocopaddle: whimsy-boat peg, rare. A coconut-half hull with a peg keel, mast and striped sail, a paddle; glow + sparkles.
def cocopaddle():
    key = 'ss-cocopaddle'
    st = Sticker()
    hull = ellipse(31.5, 32, 23, 17) & (CY > 32)
    keel = knob('s', 'peg', 32, 47.5, r=3.3)
    body = hull | keel
    # paddle behind the hull (accessory), mast, sail (picture's sloop: cream with coral stripes), pennant
    paddle = line([(13, 22), (22, 40)], 2)
    blade = ellipse(13, 20, 3.2, 5.2)
    st.part(paddle, WOOD, d=0, contour=True)
    st.part(blade, WOOD, d=2, contour=True)
    st.part(rect(31, 9, 32, 33), COCO, d=1, contour=True)
    sail = poly([(34, 10), (34, 30), (53, 30)])
    st.part(sail, SAIL, d=2, contour=True)
    for k in range(2):
        st.paint(sail & rect(0, 17 + k * 7, N, 19 + k * 7), CORAL)
    st.part(poly([(33, 8), (40, 10), (33, 12)]), YEL, d=1, contour=True)
    st.part(body, tex=body_fill(key, body, 9, 25, 46, k=3, passes=3, dy=0.1), contour=True)
    # coconut rim: husk band with a cream flesh line along the deck
    st.paint(body & (CY < 34), COCO)
    st.paint(body & (CY > 34) & (CY < 35), CREAM)
    st.paint(body & (CY > 35) & (CY < 37), COCO)
    st.paint(body & (CY > 36) & (CY < 37), COCO_D)
    st.stitch(hull & (CY > 37))
    st.eye(19, 39, look=(1, 0))
    st.eye(32, 39, look=(1, 0))
    st.mouth('grin', 25, 43)
    st.sparkle(45, 4)
    st.sparkle(5, 35, big=False)
    st.sparkle(53, 44)
    return key, st


def save_capped(st, path, glow, cap=38):
    """Sticker.save, then fold the rarest fill colours into their nearest kept colour until the sticker has <= cap colours."""
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
            m = a & (keyv == vals[i])
            rgba[m, :3] = rgb[j]
    ys, xs = np.nonzero(border)
    margin = min(int(xs.min()), int(ys.min()), int(N - 1 - xs.max()), int(N - 1 - ys.max()))
    cols = len({tuple(p) for p in rgba[a][:, :3]})
    Image.fromarray(rgba, 'RGBA').save(path, optimize=True)
    return {'colours': cols, 'margin': margin}


PALS = [shell_skip, palm_fidget, tide_tuck, coral_cuff, lagoon_loop, cocopaddle]

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
