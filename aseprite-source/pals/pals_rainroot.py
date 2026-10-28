"""Puzzle Pals: THE RAINROOT REACHES roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_rainroot.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py / pals_sunsprinkle.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own
cell of game/assets/img/jigsaw/rainroot.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (kapok orchid, the sloth's branch, the mate gourd, the bromeliad crown, an Andean chullo, a leaf umbrella).
Picture palette (jigsaw_rainroot.py): jungle greens #2f7a45 / #5fa850, macaw blue #2a6fc0, heliconia orange #f08a24, red #d6322b, clay #b8502a,
orchid pink #e46a9b, sloth #9a8a6a, glossy frog #5fd06a.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('rainroot')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'rainroot':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

PINK, PINK_D, PINK_L = '#e46a9b', '#b84a7a', '#f6b8cf'
YEL = '#f0b92b'
LEAF, LEAF_D, LEAF_L = '#5fa850', '#2f7a45', '#a4c860'
WOOD, WOOD_D = '#9a6b3f', '#5c3420'
BARK = '#7a4a1f'
SLOTH_D = '#5c4a3a'
GOURD, GOURD_D, GOURD_L = '#b07a3a', '#7a4a1f', '#d9a35a'
SILVER = '#c9c5bc'
RED, RED_D = '#d6322b', '#a8241f'
ORG = '#f08a24'
BLUE, BLUE_D, BLUE_L = '#2a6fc0', '#1a4a8a', '#6aaae0'
WOOL = '#f1ece0'
FROG, FROG_D, FROG_L = '#5fd06a', '#2f7a45', '#a4e08a'


def body_fill(key, mask, x0, y0, size, k=4, passes=2, dx=0.0, dy=0.0, swap=None):
    col, row = ROWS[key]['piece']
    t = pic.sample(col, row, x0, y0, size, dx, dy)
    t = majority(t, mask, passes)
    t = reduce(t, mask, k)
    if swap:
        t = remap(t, mask, swap)
    return t


def relight(tex, mask, ramp):
    """Recolour the fill's kept colours by brightness onto `ramp` (dark -> light), keeping the cell's own pattern."""
    cols = np.unique(tex[mask].reshape(-1, 3), axis=0)
    lum = cols @ np.array([0.3, 0.59, 0.11])
    order = cols[np.argsort(lum)]
    t = tex.copy()
    for i, c in enumerate(order):
        j = min(len(ramp) - 1, int(i * len(ramp) / len(order)))
        t[mask & np.all(tex == c, axis=2)] = hx(ramp[j])
    return t


def feet(st, xs, y, w=6, h=4):
    for x in xs:
        shoe = rect(x, y, x + w - 1, y + h - 1)
        shoe[y, x] = shoe[y, x + w - 1] = False
        st.part(shoe, SHOE[0], d=1, contour=True)


def flower(st, cx, cy, r=2.6, petals=5, col=PINK, dark=PINK_D, heart=YEL):
    import math
    m = blank()
    for i in range(petals):
        a = math.radians(-90 + i * 360 / petals)
        m |= disc(cx + r * math.cos(a), cy + r * math.sin(a), r * 0.95)
    st.part(m, col, d=1, contour=True)
    st.paint(m & ~shift(m, -1, -1) & (CX + CY > cx + cy + 2), dark)
    st.paint(disc(cx, cy, 1.3), heart)


# ------------------------------------------------------------------ 1. Kapok Nook: corner-TB round, common. Flat foot and back, a round tab on top, a blank on the right; sleepy; a kapok orchid.
def kapok_nook():
    key = 'rr-kapok-nook'
    st = Sticker()
    core = (10, 21, 45, 48)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', -2), e=('B', 'round', 2))
    st.part(body, tex=body_fill(key, body, 10, 21, 36, k=3, passes=3, dy=0.1))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [13, 33], 49)
    flower(st, 40, 25, 3.0)
    st.eye(16, 29, lid=2)
    st.eye(29, 29, lid=2)
    st.mouth('smile', 22, 38)
    return key, st


# ------------------------------------------------------------------ 2. Hammock Hush: edge-BTB keyhole, common. Flat top hung from the bridge branch by two sloth claws, blanks either side, a tab below; sloth eye mask.
def hammock_hush():
    key = 'rr-hammock-hush'
    st = Sticker()
    branch = rect(6, 12, 56, 15)
    branch[12, 6] = branch[15, 6] = branch[12, 56] = branch[15, 56] = False
    st.part(branch, WOOD, d=1, contour=True)
    st.paint(rect(9, 15, 54, 15) & branch, WOOD_D)
    core = (13, 17, 50, 44)
    body, holes = piece_blanks(core, n='F', s=('T', 'keyhole'), w=('B', 'keyhole', -1), e=('B', 'keyhole', -1))
    fill = body_fill(key, body, 13, 17, 38, k=2, passes=4, dy=0.1)
    st.part(body, tex=relight(fill, body, ['#6e604a', '#9a8a6a', '#c2b28e']), contour=True)   # the sloth's own fur over the cell's sky
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    for x in (19, 40):                                   # two hooked claws over the branch
        st.sprite(['.CCC', 'CC.C', 'C..C', 'C...'], x, 10, {'C': CREAM})
    # sloth eye mask: dark felt patches drooping outward-down
    st.paint(ellipse(21.5, 29.5, 5.6, 4.4) | ellipse(18, 33.5, 3.2, 2.6), UMBER2)
    st.paint(ellipse(41.5, 29.5, 5.6, 4.4) | ellipse(45, 33.5, 3.2, 2.6), UMBER2)
    st.eye(19, 27, socket=None)
    st.eye(39, 27, socket=None)
    st.mouth('smile', 29, 36)
    return key, st


# ------------------------------------------------------------------ 3. Mate Mumble: inner-TBTB peg, common. Pegs top and bottom, blanks either side; a mate gourd with a silver straw.
def mate_mumble():
    key = 'rr-mate-mumble'
    st = Sticker()
    core = (13, 19, 48, 44)
    body, holes = piece_blanks(core, n=('T', 'peg'), s=('T', 'peg'), w=('B', 'peg'), e=('B', 'peg'))
    st.part(body, tex=body_fill(key, body, 13, 19, 36, k=3, passes=3))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [16, 41], 45, w=6, h=4)
    # gourd held in front, lower right, with the bombilla
    st.part(line([(44, 27), (40, 38)], 2), SILVER, d=0, contour=True)
    g = ellipse(40, 43, 6.5, 6) | ellipse(40, 37.5, 4, 2)
    st.part(g, GOURD, d=2, contour=True)
    st.paint(rect(35, 36, 45, 37) & g, GOURD_D)
    st.dots([(37, 40), (38, 40), (37, 41)], GOURD_L)
    st.eye(19, 26, look=(1, 0), lid=1)
    st.eye(30, 26, look=(1, 0), lid=1)
    st.mouth('flat', 26, 35)
    return key, st


# ------------------------------------------------------------------ 4. Bromeliad Bolt: inner-TTTT tri, uncommon. Plus of arrow knobs, a spiky red-and-green bromeliad crown with its cup of rain; heliconia stitch.
def bromeliad_bolt():
    key = 'rr-bromeliad-bolt'
    st = Sticker()
    core = (19, 22, 44, 46)
    body = piece(core, n=('T', 'tri'), e=('T', 'tri'), s=('T', 'tri'), w=('T', 'tri'))
    # crown: strap leaves fanning up from the top corners of the core, red heart, a blue cup of rain
    lv = poly([(22, 23), (12, 9), (19, 12), (26, 20)]) | poly([(42, 23), (52, 9), (45, 12), (38, 20)]) | \
        poly([(25, 22), (21, 6), (28, 14), (30, 21)]) | poly([(39, 22), (43, 6), (36, 14), (34, 21)])
    st.part(lv, LEAF, d=2, contour=True)
    st.paint(line([(22, 22), (14, 11)]) | line([(42, 22), (50, 11)]), LEAF_D)
    red = poly([(27, 22), (24, 13), (30, 18)]) | poly([(37, 22), (40, 13), (34, 18)])
    st.part(red, RED, d=1, contour=True)
    st.part(body, tex=body_fill(key, body, 19, 22, 26, k=3, passes=3))   # body over the crown so the top knob tip reads
    st.stitch(body, col=ORG)
    st.eye(23, 29, look=(0, 0))
    st.eye(35, 29, look=(0, 0))
    st.mouth('smirk', 30, 38)
    return key, st


# ------------------------------------------------------------------ 5. Highland Ring: inner-BBBB round, uncommon. The Ring: four round blanks, a striped Andean chullo cocked on its corner; macaw-blue stitch.
def highland_ring():
    key = 'rr-highland-ring'
    st = Sticker()
    core = (10, 17, 50, 52)
    body, holes = piece_blanks(core, n=('B', 'round', 9, 3.8), e=('B', 'round', 2, 3.8), s=('B', 'round', 0, 3.8),
                               w=('B', 'round', 6, 3.8))
    st.part(body, tex=relight(body_fill(key, body, 10, 17, 41, k=3, passes=3), body, ['#1d4a3a', '#256650', '#2f7a5c']))   # no pale sky patch
    st.blank_shade(body, holes)
    st.stitch(body, col=BLUE_L, skip=grow(holes, 3))
    # chullo: knitted red cone over the top-left corner, one yellow zigzag band, an ear flap with a tassel, a wool pom
    hat = poly([(8, 24), (12, 14), (18, 10), (24, 14), (29, 24)])
    st.part(hat, RED, d=2, contour=True)
    zz = np.abs(CY - (19.5 + np.abs((CX % 4) - 2) - 1)) < 1.0
    st.paint(hat & shrink(hat, 1) & zz, YEL)
    flap = poly([(8, 23), (13, 23), (12, 29), (9, 29)])
    st.part(flap, RED, d=1, contour=True)
    st.part(rect(10, 30, 11, 32), YEL, d=0, contour=True)
    st.part(disc(18, 9.5, 2.4), WOOL, d=1, contour=True)
    st.eye(19, 30, look=(1, 0))
    st.eye(32, 30, look=(1, 0))
    st.mouth('o', 27, 39)
    return key, st


# ------------------------------------------------------------------ 6. Glimmer Frog: whimsy-frog hook, rare. A frog: wide body, eye bumps, splayed toes, a hooked back foot; a leaf umbrella; glow + sparkles.
def glimmer_frog():
    key = 'rr-glimmer-frog'
    st = Sticker()
    # leaf umbrella behind (accessory): a pointed jungle leaf with a midrib, its stem in the frog's right hand
    st.part(line([(44, 34), (41, 17)], 2), LEAF_D, d=0, contour=True)
    leafm = disc(45.1, 27.0, 17.9) & disc(38.9, 2.5, 17.9)
    st.part(leafm, LEAF, d=2, contour=True)
    st.paint(line([(30, 18), (53, 12)]) & shrink(leafm, 1), LEAF_D)
    st.paint(line([(38, 16), (40, 12)]) | line([(45, 14), (47, 11)]), LEAF_D)
    bodym = ellipse(31, 39, 17, 10.5)
    bumps = disc(22, 29, 5.6) | disc(39, 29, 5.6)
    legs = ellipse(15, 45, 5, 4.5) | ellipse(47, 45, 5, 4.5)
    toes = disc(11, 49.5, 1.8) | disc(16, 50, 1.8) | disc(25, 49.5, 1.8) | disc(37, 49.5, 1.8) | disc(46, 50, 1.8) | disc(51, 49.5, 1.8)
    hook = knob("w", "hook", 34, 17, r=4.6, nw=2.9)
    body = bodym | bumps | legs | toes | hook
    st.part(body, tex=relight(body_fill(key, body, 11, 22, 40, k=3, passes=3), body, [FROG_D, '#3f8a4a', FROG]), contour=True)
    st.paint(hook & ~bodym, FROG)
    st.paint(hook & ~bodym & ~shift(hook, 1, 1), FROG_L)
    belly = ellipse(31, 44, 10, 5) & bodym
    st.paint(belly, FROG_L)
    st.stitch(bodym & ~belly, depth=2)
    st.eye(19, 26, look=(1, 0))
    st.eye(36, 26, look=(1, 0))
    st.sprite(['U.........U', '.UUUUUUUUU.'], 25, 36, {'U': UMBER}, solid=False)
    st.dots([(18, 37), (19, 37), (42, 37), (43, 37)], PINK_L)
    st.sparkle(4, 24, big=False)
    st.sparkle(14, 6)
    st.sparkle(56, 30, big=False)
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


PALS = [kapok_nook, hammock_hush, mate_mumble, bromeliad_bolt, highland_ring, glimmer_frog]

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
