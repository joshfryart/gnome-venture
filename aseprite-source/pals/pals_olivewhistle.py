"""Puzzle Pals: OLIVEWHISTLE SHORE roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_olivewhistle.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own cell of
game/assets/img/jigsaw/olivewhistle.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (the fisher's teal net, an olive sprig, an oil amphora, a fisher's kerchief, the press beam,
a red gnome cap on the leaping dolphin). Picture palette (jigsaw_olivewhistle.py): sea #3f93bf / #2f78aa, ochre #d9a855, olive #8a9a52,
terracotta #c8643a, stone #d8c6a0, lemon #f2d23a, net #3f8a7a.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('olivewhistle')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'olivewhistle':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

NET, NET_D, NET_L = '#3f8a7a', '#2a5a50', '#6ab0a0'
CORK = '#d6322b'
OLIVE, OLIVE_D, OLIVE_L = '#8a9a52', '#5f6f34', '#b8c48a'
OLIVE_FRUIT, OLIVE_FRUIT_L = '#4e3a6a', '#a87ab8'
TERRA, TERRA_D, TERRA_L = '#c8643a', '#9a4426', '#e88a5a'
LEMON, LEMON_D = '#f2d23a', '#c9a414'
SEA, SEA_D = '#3f93bf', '#25637d'
WOOD, WOOD_D = '#b07a3a', '#7a4a1f'
DOLPH, DOLPH_D, DOLPH_L = '#7a8fa8', '#4f6a84', '#b0c4d6'
RED = '#d6322b'


def body_fill(key, mask, x0, y0, size, k=4, passes=2, dx=0.0, dy=0.0, swap=None, pre=None):
    col, row = ROWS[key]['piece']
    t = pic.sample(col, row, x0, y0, size, dx, dy)
    if pre:                                  # whole-colour swaps before the calm-down (the picture's own ink lines, busy props)
        t = remap(t, mask, pre)
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


def leaf(cx, cy, L, ang, w=2.4):
    """A slim olive leaf: a pointed lens from (cx, cy) along angle ang (degrees)."""
    t = math.radians(ang)
    ux, uy = math.cos(t), math.sin(t)
    px, py = -uy, ux
    return poly([(cx, cy), (cx + ux * L * 0.5 + px * w, cy + uy * L * 0.5 + py * w), (cx + ux * L, cy + uy * L),
                 (cx + ux * L * 0.5 - px * w, cy + uy * L * 0.5 - py * w)])


# ------------------------------------------------------------------ 1. Net Nudge: corner-TB round, common. Flat foot and back, tab up, blank right; a teal net cap with a cork float.
def net_nudge():
    key = 'ow-net-nudge'
    st = Sticker()
    core = (11, 21, 44, 49)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', 7), e=('B', 'round', 3, 4.6))
    st.part(body, tex=body_fill(key, body, 11, 21, 34, k=4, passes=3,
                                pre={'#2a1a10': '#7a4a1f', '#4a2c1a': '#7a4a1f', '#f2d23a': '#d9a855', '#c9a414': '#d9a855', '#fff08a': '#f0cc80',
                                     '#25637d': '#d9a855', '#3f8fb0': '#d9a855', '#2f78aa': '#d9a855',
                                     '#d6322b': '#b07a3a', '#a8241f': '#7a4a1f', '#f08a5a': '#d9a855'}))   # the fisher's red hat would read as a nose
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [14, 31], 50)
    # knotted net cap over the flat top-left corner: a dome with an open diamond mesh, a red cork float on top
    cap = ellipse(21, 23, 11.5, 8.5) & (CY < 23.5)
    st.part(cap, NET, d=2, contour=True)
    mesh = cap & shrink(cap, 1) & ((((XX + YY) % 4) == 0) | (((XX - YY) % 4) == 0))
    st.paint(mesh, NET_D)
    st.paint(rect(10, 22, 32, 23) & cap, NET_D)
    cork = ellipse(21, 13.5, 3, 2.6)
    st.part(cork, CORK, d=1, contour=True)
    st.dots([(20, 12)], '#f08a5a')
    st.eye(15, 28, look=(1, 0))
    st.eye(27, 28, look=(1, 0))
    st.mouth('smile', 20, 37)
    return key, st


# ------------------------------------------------------------------ 2. Olive Pip: edge-TBT double, common. Flat foot, tabs up and left, blank right; an olive sprig on the top knob.
def olive_pip():
    key = 'ow-olive-pip'
    st = Sticker()
    core = (14, 27, 47, 51)
    body, holes = piece_blanks(core, s='F', n=('T', 'double', -2), w=('T', 'double', 1), e=('B', 'double', 2, 4.6))
    st.part(body, tex=body_fill(key, body, 14, 27, 34, k=3, passes=3,
                                pre={'#2a1a10': '#c8643a', '#4a2c1a': '#c8643a', '#f1ece0': '#c9a85a', '#ffffff': '#c9a85a', '#c9bfa8': '#c9a85a',
                                     '#a8946e': '#c9a85a', '#f0e4c4': '#e2c47a', '#9a8a7a': '#c9a85a'}))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [17, 36], 52)
    # sprig: a stalk from the knob, two silver-olive leaves, one plump dark olive hanging right
    st.part(line([(29, 18), (32, 12)], 2), WOOD_D, d=0, contour=True)
    lv = leaf(30, 15, 11, -165) | leaf(32, 13, 10, -32)
    st.part(lv, OLIVE, d=1, contour=True)
    st.paint(line([(30, 15), (21, 13)]) & lv, OLIVE_D)
    st.paint(line([(32, 13), (39, 9)]) & lv, OLIVE_D)
    fruit = ellipse(39.5, 17, 3.4, 4.2)
    st.part(fruit, OLIVE_FRUIT, d=2, contour=True)
    st.dots([(38, 15)], OLIVE_FRUIT_L)
    st.eye(18, 33, look=(-1, 0))
    st.eye(30, 33, look=(-1, 0))
    st.mouth('cat', 22, 42)
    return key, st


# ------------------------------------------------------------------ 3. Jar Hum: inner-TBTB peg, common. Tall waisted piece, humming, an oil amphora standing at its side.
def jar_hum():
    key = 'ow-jar-hum'
    st = Sticker()
    core = (11, 17, 37, 44)
    body = piece(core, n=('T', 'peg'), s=('T', 'peg'), e=('B', 'peg', -3), w=('B', 'peg', -3))
    st.part(body, tex=body_fill(key, body, 11, 17, 28, k=3, passes=3,
                                pre={'#2a1a10': '#c08a4a', '#4a2c1a': '#c08a4a', '#c8643a': '#d9a855', '#9a4426': '#c08a4a', '#e88a5a': '#e2c48e',
                                     '#d6322b': '#d9a855', '#a8241f': '#c08a4a'}))
    st.stitch(body)
    feet(st, [17, 27], 54, w=5, h=3)
    # amphora: narrow neck with a lip, two loop handles, a fat belly tapering to a point foot
    belly = ellipse(49, 44, 6.5, 7.5) | poly([(44, 48), (54, 48), (50, 56), (48, 56)])
    neck = rect(47, 32, 51, 38)
    lip = rect(45, 31, 53, 32)
    handles = (disc(44.5, 37, 2.6) & ~disc(44.5, 37, 1.2)) | (disc(53.5, 37, 2.6) & ~disc(53.5, 37, 1.2))
    st.part(handles & (CX < 47) | handles & (CX > 51), TERRA_D, d=0, contour=True)
    st.part(neck | belly, TERRA, d=2, contour=True)
    st.part(lip, TERRA_L, d=1, contour=True)
    st.paint(rect(43, 42, 55, 43) & shrink(belly, 1), '#e8b878')        # painted band
    st.dots([(46, 40), (45, 41)], TERRA_L)
    st.eye(14, 23, look=(1, 0), lid=1)
    st.eye(26, 23, look=(1, 0), lid=1)
    st.paint(body & (CY > 40) & (CY < 43), '#b07a3a')                 # glazed rim band + olive dots so the fill isn't plain
    st.dots([(15, 37), (21, 37), (27, 37), (33, 37)], '#8a9a52')
    st.mouth('smile', 22, 32)
    return key, st


# ------------------------------------------------------------------ 4. Sun Glint: inner-TTTT tri, uncommon. A sun-ray plus (lemon-tipped arrows = the accent), a wink, a blue fisher's kerchief.
def sun_glint():
    key = 'ow-sun-glint'
    st = Sticker()
    core = (18, 20, 44, 46)
    body = piece(core, n=('T', 'tri'), e=('T', 'tri'), s=('T', 'tri'), w=('T', 'tri'))
    st.part(body, tex=body_fill(key, body, 18, 20, 27, k=4, passes=3))
    tips = body & ~rect(13, 15, 49, 51)
    st.part(tips, LEMON, d=2)
    st.stitch(body, col=SEA_D)
    # kerchief: a knotted band with a point, cream stripe
    kf = (rect(18, 39, 44, 41) | poly([(25, 41), (37, 41), (31, 47)])) & body
    st.part(kf, '#c8402e', d=1, contour=True)                            # red fisher's kerchief: contrasts the blue sea fill
    st.paint(kf & (CY > 40) & (CY < 41.5) & shrink(kf, 1), '#f0e4c4')
    st.eye(22, 26, look=(1, 0))
    st.sprite(['.UUU.', 'U...U', 'U...U'], 35, 27, {'U': UMBER}, solid=False)   # the wink
    st.mouth('smirk', 28, 34)
    return key, st


# ------------------------------------------------------------------ 5. Press Ring: inner-BBBB double, uncommon. The Ring: four blanks, millstone fill, the press beam behind it; olive-green stitch.
def press_ring():
    key = 'ow-press-ring'
    st = Sticker()
    core = (10, 14, 49, 52)
    # press beam behind, out of the upper-right corner (wood, iron band)
    beam = line([(36, 30), (54, 11)], 3)
    st.part(beam, WOOD, d=1, contour=True)
    st.paint(line([(50, 13), (52, 15)], 2) & beam, '#5b6470')
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.8), e=('B', 'double', 0, 3.8), s=('B', 'double', 0, 3.8),
                               w=('B', 'double', 0, 3.8))
    st.part(body, tex=body_fill(key, body, 10, 14, 40, k=3, passes=3, pre={'#4a2c1a': '#8d7e71', '#2a1a10': '#7e6c65', '#38140d': '#8d7e71', '#290807': '#8d7e71'}), contour=True)
    st.blank_shade(body, holes)
    st.stitch(body, col=OLIVE_L, skip=grow(holes, 3))
    st.eye(21, 27, look=(0, 1))
    st.eye(33, 27, look=(0, 1))
    st.mouth('grin', 26, 36)
    return key, st


# ------------------------------------------------------------------ 6. Harbour Leap: whimsy-dolphin hook, rare. An arched leaping dolphin (hook = flipper), red gnome cap; glow + sparkles.
def harbour_leap():
    key = 'ow-harbour-leap'
    st = Sticker()
    k, ox, oy = 0.8, 31.0, 33.0                      # drawn on a 0.8 scale round (31, 33) so the glow keeps a 3 px clear margin

    def T(x, y):
        return (ox + (x - 31) * k, oy + (y - 31) * k)
    # spine from the tail (lower left) over the arch to the snout (right): union of discs
    m = blank()
    path = [(9, 46, 2.6), (12, 41, 3.6), (16, 35, 5.2), (21, 30, 7.0), (27, 27, 8.4), (33, 26, 9.0), (39, 27, 8.6), (44, 30, 7.6),
            (48, 33, 5.2), (51, 35, 2.6), (54, 37, 2.1), (58, 38.5, 1.9)]
    path = [T(x, y) + (r * k + 0.5,) for x, y, r in path]
    for (ax, ay, ar), (bx, by, br) in zip(path, path[1:]):
        for t in np.linspace(0, 1, 6):
            m |= disc(ax + (bx - ax) * t, ay + (by - ay) * t, ar + (br - ar) * t)
    flukes = poly([T(9, 44), T(3, 44), T(5, 51), T(10, 49)]) | poly([T(11, 44), T(9, 53), T(14, 57), T(14, 47)])
    dorsal = poly([T(24, 21), T(26, 11), T(34, 19)])
    hx_, hy_ = T(36, 33)
    flip = knob('s', 'hook', hx_, hy_, r=3.4, flip=True)
    body = m | flukes | dorsal | flip
    # signature accessory first (behind the head top): red knit gnome cap with a cream pompom
    cap = poly([T(37, 21), T(50, 21), T(48, 11), T(43, 8)])
    st.part(cap, RED, d=2, contour=True)
    px_, py_ = T(42.5, 8)
    st.part(disc(px_, py_, 2.2), '#f0e4c4', d=1, contour=True)
    tex = body_fill(key, body, 6, 15, 42, k=3, passes=3,
                    pre={'#2f78aa': DOLPH, '#3f93bf': DOLPH, '#25637d': DOLPH_D, '#2a1a10': DOLPH_D, '#4a2c1a': DOLPH_D, '#6fb6d0': DOLPH_L,
                         '#f0e0b8': DOLPH_L, '#ffffff': DOLPH_L, '#d8eef0': DOLPH_L, '#fff2b0': DOLPH_L, '#f1ece0': DOLPH_L, '#4f6a84': DOLPH_D,
                         '#b0c4d6': DOLPH_L, '#7a8fa8': DOLPH})
    st.part(body, tex=tex, contour=True)
    band = poly([T(37, 20), T(51, 20), T(51, 22), T(37, 22)]) & body       # cap turn-up over the brow
    st.paint(band, '#f0e4c4')
    belly = m & ~shift(m, 0, -3) & (CX > 18) & (CX < 50)
    st.paint(belly & ~flip, DOLPH_L)
    st.stitch(m & (CX > 14), skip=grow(flip, 2))
    st.eye(33, 25, look=(1, 0))
    st.eye(41, 25, look=(1, 0))
    st.sprite(['U...', '.UUU'], 44, 32, {'U': UMBER}, solid=False)   # dolphin smile toward the snout
    st.sparkle(51, 45)
    st.sparkle(6, 6, big=False)
    st.sparkle(54, 13, big=False)
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


PALS = [net_nudge, olive_pip, jar_hum, sun_glint, press_ring, harbour_leap]

if __name__ == '__main__':
    print('dominant', pic.dominant(4))
    paths = []
    for fn in PALS:
        key, st = fn()
        assert key in ROWS, key
        p = os.path.join(OUTDIR, key + '.png')
        info = save_capped(st, p, glow=(ROWS[key]['rarity'] == 'rare'))
        paths.append(p)
        print('%-20s %-9s %-14s %-6s colours %d margin %d' % (key, ROWS[key]['rarity'], ROWS[key]['shape'], ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
