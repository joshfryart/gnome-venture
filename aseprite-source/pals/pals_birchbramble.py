"""Puzzle Pals: BIRCHBRAMBLE STEPPE roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_birchbramble.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own cell of
game/assets/img/jigsaw/birchbramble.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~3-4 colours, palib house finish.
One accessory each from the picture's motifs (the snowman's red scarf, the geese's blue neck bow, the brass samovar, birch catkins,
the chimney stork nest with a painted egg, the homing stork's polka-dot bundle).
Picture palette (jigsaw_birchbramble.py): sky #9ccbe6 / #cfe8f2, grass #8cc84a / #5fa83a, birch #f1ece0, red #d6322b, blue #2f62b8,
samovar gold #e8a317, log #a06a38, black earth #4a3424.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('birchbramble')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'birchbramble':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

RED, RED_D, RED_L = '#d6322b', '#a8241f', '#f0705a'
BLUE, BLUE_D, BLUE_L = '#2f62b8', '#1f4282', '#6a9ae0'
BRASS, BRASS_D, BRASS_L = '#e8a317', '#b07a10', '#f5cf6a'
LEAF, LEAF_D, LEAF_L = '#8cc84a', '#5fa83a', '#b8e070'
CATKIN, CATKIN_D = '#c9a94a', '#8a6a2a'
LOG, LOG_D, LOG_L = '#a06a38', '#74462a', '#c88a4a'
SNOW, SNOW_S = '#f4f8f8', '#c9dbe6'
SKY_L, SKY = '#cfe8f2', '#9ccbe6'
BEAK = '#e8841f'
INK = '#2a2a30'          # stork flight feathers (the picture's own black)
STEAM = '#eef2f2'


def body_fill(key, mask, x0, y0, size, k=4, passes=2, dx=0.0, dy=0.0, swap=None):
    col, row = ROWS[key]['piece']
    t = pic.sample(col, row, x0, y0, size, dx, dy)
    t = majority(t, mask, passes)
    t = reduce(t, mask, k)
    if swap:
        t = remap(t, mask, swap)
    return t


def lift(tex, mask, col, thr=260):
    """Calm a dark busy cell: fill colours darker than thr (r+g+b) become col, so the face reads on top."""
    t = tex.copy()
    dark = mask & (t.astype(int).sum(-1) < thr)
    t[dark] = hx(col)
    return t


def tidy(st, cap=35):
    """Colour budget (< 40 with outline and border): fold the rarest painted tones into their nearest kept colour."""
    m = st.sil | st.extra
    while True:
        cols, cnt = np.unique(st.px[m].reshape(-1, 3), axis=0, return_counts=True)
        if len(cols) <= cap:
            return
        i = cnt.argmin()
        rest = np.delete(cols, i, 0).astype(int)
        near = rest[((rest - cols[i].astype(int)) ** 2).sum(-1).argmin()]
        st.px[m & np.all(st.px == cols[i], axis=2)] = near


def feet(st, xs, y, w=6, h=4):
    for x in xs:
        shoe = rect(x, y, x + w - 1, y + h - 1)
        shoe[y, x] = shoe[y, x + w - 1] = False
        st.part(shoe, SHOE[0], d=1, contour=True)


def webfeet(st, xs, y):
    """Goose feet: orange 6 x 3 webbed wedges."""
    for x in xs:
        st.part(poly([(x + 2, y), (x + 3, y), (x + 6, y + 3), (x - 1, y + 3)]), BEAK, d=1, contour=True)


# ------------------------------------------------------------------ 1. Slushbelly: corner-BB round, common. Snowball corner piece, carrot nose, the snowman's red scarf.
def slushbelly():
    key = 'bb-slushbelly'
    st = Sticker()
    core = (11, 19, 44, 48)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'round', -7, 4.0), e=('B', 'round', 3, 4.2))
    tex = body_fill(key, body, 11, 19, 34, k=3, passes=3, dx=0.05, dy=0.62)
    tex = np.where(body[..., None] & (tex.astype(int).sum(-1) < 420)[..., None], hx(SNOW_S), tex)
    st.part(body, tex=tex)
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [14, 32], 49)
    # red scarf round the neck, tail hanging down the left front
    scarf = rect(11, 37, 44, 39) & body
    st.part(scarf, RED, d=1, contour=True)
    tail = poly([(15, 39), (20, 39), (21, 47), (15, 46)])
    st.part(tail, RED, d=1, contour=True)
    st.paint(rect(15, 44, 21, 44) & tail, RED_L)
    st.paint(rect(11, 39, 44, 39) & scarf, RED_D)
    st.eye(15, 27, look=(1, 1))
    st.eye(28, 27, look=(1, 1))
    st.sprite(['OOO.', 'OOOOO', '.OO..'], 22, 32, {'O': BEAK}, solid=False)   # carrot nose: a fat wedge, reads at 32 px
    st.dots([(35, 33), (35, 34)], SNOW_S)                                    # a melt drip
    return key, st


# ------------------------------------------------------------------ 2. Gander Gait: edge-TTB keyhole, common. Goose-yard edge piece, wedge beak, blue neck bow, webbed feet.
def gander_gait():
    key = 'bb-gander-gait'
    st = Sticker()
    core = (16, 21, 45, 48)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', -4), w=('T', 'keyhole', 2), e=('B', 'keyhole', 3))
    st.part(body, tex=body_fill(key, body, 16, 21, 30, k=2, passes=4))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    webfeet(st, [20, 35], 49)
    st.eye(19, 27, look=(1, 0))
    st.eye(31, 27, look=(1, 0))
    st.sprite(['OOOOOO', '.OOOO.', '..OO..'], 25, 34, {'O': BEAK}, solid=False)   # wedge beak
    st.paint(rect(25, 34, 30, 34), '#b85a14')
    # blue ribbon bow at the throat (the picture's geese wear them)
    bow = poly([(20, 39), (26, 42), (20, 45)]) | poly([(37, 39), (31, 42), (37, 45)]) | rect(26, 40, 31, 44)
    st.part(bow, BLUE, d=1, contour=True)
    st.paint(rect(27, 41, 30, 43), BLUE_L)
    return key, st


# ------------------------------------------------------------------ 3. Samovar Puff: inner-TBBB peg, common. Porch piece wearing a brass samovar as a hat, steaming.
def samovar_puff():
    key = 'bb-samovar-puff'
    st = Sticker()
    core = (11, 24, 42, 50)
    body, holes = piece_blanks(core, n=('T', 'peg', -6), e=('B', 'peg', 2), s=('B', 'peg', 0), w=('B', 'peg', 2))
    lum = body_fill(key, body, 11, 24, 32, k=3, passes=4, dx=-0.15).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(LOG_L)
    tex[lum < 300] = hx(LOG)
    tex = majority(tex, body, 4)   # the porch cell by brightness: two wood tones
    st.part(body, tex=tex)
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [12, 35], 51, w=6, h=3)
    # samovar perched on the right shoulder: foot, urn, neck, chimney cap, a side handle, a tap; steam puffs
    st.part(rect(36, 21, 42, 23), BRASS_D, d=0, contour=True)
    urn = ellipse(39, 15.5, 7, 6.5)
    st.part(urn, BRASS, d=2, contour=True)
    st.part(rect(37, 7, 41, 9), BRASS, d=1, contour=True)
    st.paint(rect(32, 16, 33, 17), UMBER2, solid=True)        # tap
    st.paint(rect(45, 13, 47, 14) | rect(46, 13, 47, 18), BRASS_D, solid=True)   # handle
    st.paint(rect(33, 14, 45, 14) & urn, RED)                   # painted red band
    st.dots([(36, 12), (35, 13)], '#fff4c0')
    for cx, cy, r in ((48, 9, 2.4), (52, 13, 1.8)):
        st.part(disc(cx, cy, r), STEAM, d=1, rim=False)
    st.eye(16, 30, look=(1, 0))
    st.eye(27, 30, look=(1, 0))
    st.mouth('grin', 22, 38)
    return key, st


# ------------------------------------------------------------------ 4. Catkin Crown: inner-TTTT double, uncommon. Birch-wood plus piece crowned with catkins; leaf-green accent stitch.
def catkin_crown():
    key = 'bb-catkin-crown'
    st = Sticker()
    core = (18, 24, 44, 47)
    body = piece(core, n=('T', 'double'), e=('T', 'double'), s=('T', 'double'), w=('T', 'double'))
    st.part(body, tex=body_fill(key, body, 18, 24, 27, k=3, passes=3, swap={'#2a1a10': '#c9c5bc'}))
    st.stitch(body, col=LEAF_D)
    # crown: a leafy band over the brow with five upright catkins
    band = rect(17, 23, 45, 26)
    st.part(band, LEAF, d=1, contour=True)
    st.paint(rect(17, 26, 45, 26), LEAF_D)
    for i, x in enumerate((18, 24, 30, 36, 42)):
        h = 7 if i == 2 else 5
        cat = rect(x, 22 - h, x + 2, 22) & ~rect(x, 22 - h, x, 22 - h) & ~rect(x + 2, 22 - h, x + 2, 22 - h)
        st.part(cat, CATKIN, d=1, contour=True)
        st.dots([(x + 1, 22 - h + 2), (x + 1, 22 - h + 4)], CATKIN_D)
    st.eye(21, 30, look=(1, 0))
    st.eye(33, 30, look=(1, 0))
    st.mouth('cat', 28, 39)
    return key, st


# ------------------------------------------------------------------ 5. Chimney Nest: inner-BBBB keyhole, uncommon. Sky-and-chimney ring piece with the stork's twig nest and a painted egg; red accent stitch.
def chimney_nest():
    key = 'bb-chimney-nest'
    st = Sticker()
    core = (10, 14, 50, 50)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.6), s=('B', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.6))
    st.part(body, tex=lift(body_fill(key, body, 10, 14, 41, k=3, passes=3), body, SKY, thr=330))
    st.blank_shade(body, holes)
    st.stitch(body, col=RED, skip=grow(holes, 3))
    # twig nest on the top-left corner, a blue painted egg in it
    egg = ellipse(17.5, 12.5, 3.4, 4.6)
    st.part(egg, BLUE_L, d=1, contour=True)
    st.paint(rect(14, 12, 21, 13) & egg, '#f6efe0')
    st.dots([(16, 12), (19, 13)], RED)
    nest = ellipse(17, 18.5, 9.5, 3.8)
    st.part(nest, LOG, d=2, contour=True)
    for a, b in (((9, 18), (15, 21)), ((14, 17), (22, 20)), ((19, 18), (26, 17)), ((11, 20), (21, 18))):
        st.paint(line([a, b]) & shrink(nest, 1), LOG_D)
    st.dots([(12, 17), (21, 17)], LOG_L)
    st.eye(23, 28, look=(1, 0))
    st.eye(34, 28, look=(1, 0))
    st.mouth('grin', 28, 37)
    return key, st


# ------------------------------------------------------------------ 6. Homing Stork: whimsy-stork tri, rare. A stork made of sky (its cell), black wing tips, tri-knob tail,
# long red beak with a polka-dot travel bundle, one leg tucked; glow + sparkles.
def homing_stork():
    key = 'bb-homing-stork'
    st = Sticker()
    col, row = ROWS[key]['piece']
    head = disc(25, 17, 8)
    neck = poly([(23, 22), (30, 22), (33, 31), (26, 31)])
    trunk = ellipse(34, 36, 13, 8.5)
    tail = knob('e', 'tri', 34, 46.5, r=2.8)
    body = head | neck | trunk | tail
    # legs (behind the body): one straight, one tucked up, red
    st.part(rect(31, 42, 32, 53), RED, d=0, contour=True)
    st.part(line([(37, 43), (41, 47), (37, 50)], 2), RED, d=0, contour=True)
    st.part(rect(28, 53, 34, 53), RED, d=0, contour=True)
    # the sky cell by brightness: cloud = snow white, sky = pale sky, so the stork reads white and still shows its own clouds
    src = pic.sample(col, row, 12, 8, 42).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(SKY_L)
    tex[src > 660] = hx(SNOW)
    tex = majority(tex, body, 3)
    st.part(body, tex=tex, contour=True)
    wing = trunk & (CX > 37) & (CY < 41) | tail
    st.paint(wing & shrink(body, 1), INK)
    st.paint(line([(38, 33), (47, 34)]) & trunk, '#4a4a54')
    st.stitch(trunk & ~wing, skip=grow(wing, 1))
    # beak: long red wedge from the head, a bundle hung on its tip
    beak = poly([(18, 18), (8, 24), (8, 25), (18, 23)])
    st.part(beak, RED, d=1, contour=True)
    st.paint(line([(10, 26), (11, 28)]), UMBER2, solid=True)
    bundle = disc(12, 31.5, 3.6) | poly([(9, 28), (15, 28), (12, 30)])
    st.part(bundle, BLUE, d=1, contour=True)
    st.paint(rect(10, 28, 14, 29) & bundle, BLUE_D)
    st.dots([(10, 31), (13, 32), (11, 34), (14, 34)], '#f6efe0')
    st.eye(19, 12, look=(-1, 0))
    st.eye(26, 12, look=(-1, 0))
    st.sparkle(46, 9)
    st.sparkle(51, 22, big=False)
    st.sparkle(9, 44)
    return key, st


PALS = [slushbelly, gander_gait, samovar_puff, catkin_crown, chimney_nest, homing_stork]

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
        print('%-20s %-9s %-11s %-6s colours %d margin %d' % (key, ROWS[key]['rarity'], ROWS[key]['shape'], ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
