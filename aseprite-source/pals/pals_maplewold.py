"""Puzzle Pals: THE MAPLEWOLD roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_maplewold.py [outdir]
Each pal is a living jigsaw piece cut from game/assets/img/jigsaw/maplewold.jpg: its silhouette is the row's shape + knob
(game/includes/data/puzzle_pals.txt), its body is filled with its own cell (col-row of the 12 x 8 grid), snapped to the picture's palette.
One accessory each from the picture's motifs (mushroom, maple leaf, sap pail, woodpile bark, the red balloon, the windmill sails).
Picture dominants (read from the render): sky #ddeff2, grass #7ab55c, maple red #d6322b, pumpkin #e8841f.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('maplewold')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'maplewold':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

RED = '#d6322b'
REDS = '#a8241f'
PUMP = '#e8841f'
BARK, BARK_D, BARK_L = '#7a4a1f', '#5c3420', '#9a6b3f'
TIN = '#b9b2a2'
POND = '#3f8fb0'


def body_fill(key, mask, x0, y0, size, k=5, passes=1, dx=0.0, dy=0.0, swap=None):
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


def leaf_mask(cx, cy, L, ang0=-90.0, w=0.3):
    """Maple leaf: 5 serrated kite lobes from one centre."""
    import math
    m = blank()
    for a, f in ((0, 1.0), (-58, 0.82), (58, 0.82), (-118, 0.5), (118, 0.5)):
        t = math.radians(ang0 + a)
        ux, uy = math.cos(t), math.sin(t)
        px, py = -uy, ux
        Lf = L * f
        ww = L * w * (0.75 + 0.25 * f)

        def P(al, ac):
            return (cx + ux * al * Lf + px * ac, cy + uy * al * Lf + py * ac)
        pts = [P(-0.15, 0), P(0.3, ww), P(0.55, ww * 0.55), P(0.66, ww * 0.85), P(1.0, 0), P(0.66, -ww * 0.85), P(0.55, -ww * 0.55), P(0.3, -ww)]
        m |= poly(pts)
    return m


# ------------------------------------------------------------------ 1. Acorn Nip: corner-TT round, common. Top-left corner piece under a toadstool cap.
def acorn_nip():
    key = 'mw-acorn-nip'
    st = Sticker()
    core = (9, 20, 38, 45)
    body = piece(core, n='F', w='F', e=('T', 'round', 1), s=('T', 'round', 5))
    tex = body_fill(key, body, 9, 20, 30, k=4, passes=2, dx=0.12, dy=0.1)
    tex = remap(tex, body, {'#9a6b3f': '#7ab55c'})                    # birch trunk -> lit grass
    tex = remap(tex, body & (CY < 39), {'#7a4a1f': '#4f9a45'})         # keep only the tilled-soil hem brown
    st.part(body, tex=tex)
    st.stitch(body)
    feet(st, [10], 46, w=7)
    shoe = rect(26, 52, 34, 55) & ~rect(26, 52, 26, 52) & ~rect(34, 52, 34, 52)
    st.part(shoe, SHOE[0], d=1, contour=True)
    # toadstool cap hat (the mushrooms of its own cell), cocked to the left
    cap = ellipse(20.5, 18.5, 14, 10) & (CY < 19.5) & (CX > 6)
    gills = rect(9, 19, 33, 20) & ~rect(9, 20, 10, 20) & ~rect(32, 20, 33, 20)
    st.part(gills, '#efe6d2', d=1, rim=False, contour=True)
    st.part(cap, RED, d=2, contour=True)
    st.sprite(['.CC.', 'CCCC', '.CC.'], 14, 12, {'C': CREAM}, solid=False)
    st.sprite(['CC', 'CC'], 25, 10, {'C': CREAM}, solid=False)
    st.sprite(['.C.', 'CCC'], 29, 15, {'C': CREAM}, solid=False)
    st.dots([(10, 16), (20, 16)], CREAM)
    st.eye(13, 26, look=(1, 0))
    st.eye(26, 26, look=(1, 0))
    st.mouth('grin', 18, 34)
    st.button(32, 39)
    return key, st


# ------------------------------------------------------------------ 2. Leaf Tuck: edge-TTB round, common. Flat foot, blank on the right, a maple leaf tucked on its knob.
def leaf_tuck():
    key = 'mw-leaf-tuck'
    st = Sticker()
    core = (17, 25, 46, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'round', -1), w=('T', 'round', 2), e=('B', 'round', 1, 4.8))
    st.part(body, tex=body_fill(key, body, 17, 25, 30, k=4, passes=2))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [20, 37], 50)
    leaf = leaf_mask(33, 16, 9.5, ang0=-75)
    stem = line([(32, 18), (30, 23)], 2)
    st.part(stem, BARK, d=0, contour=True)
    st.part(leaf, RED, d=2, contour=True)
    vein = line([(33, 17), (36, 8)]) | line([(33, 17), (26, 12)]) | line([(33, 17), (41, 15)])
    st.paint(vein & shrink(leaf, 1), REDS)
    st.eye(20, 32, look=(0, 1))
    st.eye(31, 32, look=(0, 1))
    st.mouth('smile', 23, 40)
    return key, st


# ------------------------------------------------------------------ 3. Sap Drip: inner-TBTB peg, common. Tall waisted piece, sleepy, a tin sap pail on its arm.
def sap_drip():
    key = 'mw-sap-drip'
    st = Sticker()
    core = (17, 17, 42, 44)
    body = piece(core, n=('T', 'peg'), s=('T', 'peg'), e=('B', 'peg', 2), w=('B', 'peg', 2))
    st.part(body, tex=body_fill(key, body, 17, 17, 27, k=4, passes=2, dx=0.15))
    st.stitch(body)
    feet(st, [23, 32], 54, w=5, h=3)
    arm = rect(43, 38, 47, 39) | rect(46, 40, 47, 41)
    st.part(arm, SHOE[2], d=1, contour=True)
    pail = poly([(43, 43), (55, 43), (54, 52), (44, 52)])
    st.part(pail, TIN, d=2, contour=True)
    st.paint(rect(43, 43, 55, 43), '#d8d2c2')
    st.paint(rect(44, 44, 54, 44), PUMP)                    # sap level
    st.paint(rect(44, 48, 54, 48) & pail, '#8a8474')        # hoop
    handle = line([(44, 43), (46, 40), (52, 40), (54, 43)])
    st.paint(handle & ~pail, UMBER2, solid=True)
    st.sprite(['A', 'a'], 49, 53, {'A': PUMP, 'a': '#f5b04a'})      # the drip, always a little late
    st.eye(20, 23, look=(0, 1), lid=1)
    st.eye(34, 23, look=(0, 1), lid=1)
    st.mouth('o', 28, 31)
    st.button(28, 10)
    return key, st


# ------------------------------------------------------------------ 4. Bark Badger: inner-TTBB peg, uncommon. Top blank = two dark ears, badger mask, a bark cape with a pumpkin collar.
def bark_badger():
    key = 'mw-bark-badger'
    st = Sticker()
    core = (15, 17, 46, 44)
    body = piece(core, n=('B', 'peg', 0, 4.3), e=('B', 'peg', 3), s=('T', 'peg', -3), w=('T', 'peg', 3))
    st.part(body, tex=body_fill(key, body, 15, 17, 31, k=4, passes=2))
    st.stitch(body, col=PUMP)
    feet(st, [21, 29], 54, w=6, h=3)
    # dark ear tips either side of the top blank
    ears = body & (CY < 21) & ((CX < 24) | (CX > 37))
    st.paint(ears & ~shift(~body, 0, 0), UMBER2)
    st.paint(ears & shrink(body, 1) & (CY < 20) & (CY > 18) & ((np.abs(CX - 19.5) < 2) | (np.abs(CX - 42.5) < 2)), '#c9a96e')
    # bark cape over the shoulders and down the back (woodpile bark); pumpkin collar = the uncommon accent
    cape = poly([(33, 22), (47, 22), (47, 46), (43, 43), (40, 46), (37, 42), (36, 29)]) & body
    st.part(cape, BARK, d=2, contour=True)
    for gx, gy, h in ((40, 31, 4), (43, 27, 5), (41, 37, 3), (45, 34, 4)):
        st.paint(rect(gx, gy, gx, gy + h) & shrink(cape, 1), BARK_D)
    st.dots([(39, 26), (44, 40)], BARK_L)
    collar = rect(15, 22, 47, 23) & body
    st.paint(collar, PUMP, solid=True)
    st.paint(collar & (CY > 23), '#b85a14')
    st.button(36, 24, GOLD, GOLD_D)
    # badger face under the cape: umber masks, cream blaze
    st.paint(rect(17, 28, 24, 35), UMBER2)
    st.paint(rect(28, 28, 35, 35), UMBER2)
    st.paint(rect(25, 26, 27, 36), CREAM)
    st.eye(18, 29, look=(1, 0), socket=None)
    st.eye(29, 29, look=(1, 0), socket=None)
    st.sprite(['UUU', '.U.'], 25, 37, {'U': UMBER}, solid=False)   # nose: 4 clear pixels, no fussy mouth
    return key, st


# ------------------------------------------------------------------ 5. Fourwind Finch: inner-TTTT tri, uncommon. A compass-rose plus with a beak; the picture's balloon in pond blue.
def fourwind_finch():
    key = 'mw-fourwind-finch'
    st = Sticker()
    core = (17, 22, 42, 46)
    body = piece(core, n=('T', 'tri', 0, 4.6), e=('T', 'tri'), s=('T', 'tri'), w=('T', 'tri'))
    st.part(body, tex=body_fill(key, body, 17, 22, 26, k=4, passes=2))
    st.stitch(body, col=POND)
    # balloon tied to the east arrow
    st.paint(line([(51, 32), (51, 25)]), UMBER2, solid=True)
    basket = rect(48, 21, 54, 24) & ~rect(48, 24, 48, 24) & ~rect(54, 24, 54, 24)
    st.part(basket, '#b07a3a', d=1, contour=True)
    st.dots([(49, 22), (51, 22), (53, 22), (50, 23), (52, 23)], '#7a4a1f')
    st.paint(line([(47, 17), (48, 20)]) | line([(55, 17), (54, 20)]), UMBER2, solid=True)
    env = ellipse(51, 12.5, 6, 6.5) | poly([(47, 16), (55, 16), (53, 19), (49, 19)])
    st.part(env, POND, d=2)
    st.paint(env & (np.abs(CX - 51) < 1.1), '#a9d6ea')
    st.paint(env & (np.abs(CX - 47.5) < 0.6) & (CY > 8) & (CY < 18), '#25637d')
    st.paint(env & (np.abs(CX - 54.5) < 0.6) & (CY > 8) & (CY < 18), '#25637d')
    st.eye(21, 28, look=(1, 0))
    st.eye(32, 28, look=(1, 0))
    st.sprite(['OOOOO', '.OOO.', '..U..'], 27, 34, {'U': UMBER, 'O': PUMP}, solid=False)
    st.button(28, 15)
    return key, st


# ------------------------------------------------------------------ 6. Samara Spin: whimsy-leaf (maple key) hook, rare. Seed + swept wing, propeller beanie (windmill sails), glow + sparkles.
def samara_spin():
    key = 'mw-samara-spin'
    st = Sticker()
    col, row = ROWS[key]['piece']
    seed = ellipse(20.5, 37, 11, 10)
    hook = knob('s', 'hook', 22, 46.5, r=3.3)
    body = seed | hook
    # maple key: straight thick leading edge, broad rounded tip, a trailing edge with notches, veins fanning from the seed
    wing = poly([(26, 30), (31, 24), (36, 18), (41, 13), (46, 10), (50, 8), (53, 9), (54, 13), (53, 18), (50, 23), (46, 27), (41, 29),
                 (37, 29), (33, 31), (30, 34), (28, 34)])
    for nx, ny, rr in ((51.5, 22.5, 2.6), (44.5, 29, 2.8)):   # notches bitten into the trailing edge (big enough to survive the outline)
        wing &= ~disc(nx, ny, rr)
    lum = pic.sample(col, row, 25, 8, 28).astype(int).sum(-1)
    paper = np.zeros((N, N, 3), np.uint8)
    paper[:] = hx('#f5b04a')
    paper[lum < 330] = hx('#e8a040')
    paper = majority(paper, wing, 2)
    st.part(wing, tex=paper, d=2)
    for end in ((53, 14), (49, 21), (42, 27), (35, 30)):        # veins fan from the seed to the trailing edge
        st.paint(line([(28, 32), ((28 + end[0]) // 2 + 1, (32 + end[1]) // 2 - 2), end]) & shrink(wing, 1), '#7a3a1c')
    lead = line([(28, 31), (33, 25), (38, 19), (43, 14), (48, 11), (51, 10)], 2)   # the thick rib, inset so it reads apart from the outline
    st.paint(lead & shrink(wing, 1), '#5c3420')
    st.paint(shift(lead, -1, -1) & ~lead & shrink(wing, 1), '#ffc27a')
    st.part(body, tex=body_fill(key, body, 9, 27, 23, k=4, passes=2), contour=True)
    st.stitch(seed)
    st.paint(line([(26, 31), (29, 34)]) | line([(24, 29), (28, 33)]), '#8a2c20')   # seed-bulb ridges at the wing root
    # propeller (two windmill sails) on a stalk: 3 clear blocks at 32 px
    st.part(rect(17, 22, 18, 27), BARK, d=0, contour=True)
    st.part(rect(8, 18, 15, 20) | rect(20, 18, 27, 20), '#efe6d2', d=1)
    st.part(rect(16, 17, 19, 21), RED, d=1, contour=True)
    st.eye(13, 32, look=(1, -1))
    st.eye(23, 32, look=(1, -1))
    st.mouth('tooth', 17, 40)
    st.sparkle(7, 8)
    st.sparkle(55, 27, big=False)
    st.sparkle(42, 47)
    return key, st


PALS = [acorn_nip, leaf_tuck, sap_drip, bark_badger, fourwind_finch, samara_spin]

if __name__ == '__main__':
    print('dominant', pic.dominant(4))
    paths = []
    for fn in PALS:
        key, st = fn()
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
