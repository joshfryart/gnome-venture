"""Puzzle Pals: THE MONSOON TANGLE roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_monsoontangle.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own cell of
game/assets/img/jigsaw/monsoontangle.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (bamboo stilts, the planter's conical straw hat, a lotus, a paper lantern, strangler-fig roots,
the fruit-boat gnome's giant leaf umbrella). Picture palette (jigsaw_monsoontangle.py): jade #4fae6a, canal teal #3a9aa0, hot pink #e8408a,
mango #f08a24, thatch #c9a052, bamboo #b8b85a, wood #9a5a2a, rain sky #8fb5b2.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('monsoontangle')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'monsoontangle':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

JADE, JADE_D, JADE_L = '#4fae6a', '#2f8a4f', '#8fd07a'
DJADE = '#1f6a45'
TEAL, TEAL_D = '#3a9aa0', '#2a7a84'
PINK, PINK_D, PINK_L = '#e8408a', '#b82a6a', '#f890b8'
ORG, ORG_D, ORG_L = '#f08a24', '#c0601a', '#f8b850'
YEL, YEL_D = '#f0c43a', '#c99a1a'
RED = '#d6322b'
THATCH, THATCH_D, THATCH_L = '#c9a052', '#9a7434', '#e8c878'
BAMBOO, BAMBOO_D, BAMBOO_L = '#b8b85a', '#86862e', '#dede8a'
WOOD, WOOD_D, WOOD_L = '#9a5a2a', '#6a3a1a', '#c07a40'
INK, INK_L = '#3a3440', '#5e5e6a'
WHITE = '#f4f0e8'


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


# ------------------------------------------------------------------ 1. Stilt Stoop: corner-TB round, common. Bamboo-wall corner piece up on two bamboo stilts.
def stilt_stoop():
    key = 'mt-stilt-stoop'
    st = Sticker()
    core = (13, 18, 42, 41)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'round', -3), e=('B', 'round', 1, 4.0))
    # two bamboo stilts under the flat foot, with node bands, and felt boots at the bottom
    for x in (17, 34):
        pole = rect(x, 40, x + 2, 52)
        st.part(pole, BAMBOO, d=1, contour=True)
        st.paint(pole & ((YY == 44) | (YY == 48)), BAMBOO_D)
    st.part(body, tex=lift(body_fill(key, body, 13, 18, 30, k=3, passes=4), body, BAMBOO, 330), contour=True)   # calm the window frame and wall shadow
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [15, 32], 52, w=7, h=3)
    st.eye(17, 26, look=(1, 0))
    st.eye(29, 26, look=(1, 0))
    st.mouth('grin', 22, 34)
    return key, st


# ------------------------------------------------------------------ 2. Seedling Plod: edge-TBB peg, common. Terrace edge piece in the planter's conical straw hat.
def seedling_plod():
    key = 'mt-seedling-plod'
    st = Sticker()
    core = (14, 24, 43, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', 7), e=('B', 'peg', 5), w=('B', 'peg', 5))   # blanks low, so the eyes sit clear of them
    st.part(body, tex=body_fill(key, body, 14, 24, 30, k=2, passes=4), contour=True)
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [17, 33], 50)
    # conical non la hat cocked over the left of the head, beside the peg
    hat = poly([(7, 27), (21, 11), (36, 25), (35, 27)])
    st.part(hat, THATCH, d=2, contour=True)
    st.paint(line([(12, 23), (31, 23)]) & hat, THATCH_D)
    st.paint(line([(16, 18), (26, 18)]) & hat, THATCH_D)
    st.eye(19, 30, look=(0, 1))
    st.eye(31, 30, look=(0, 1))
    st.mouth('o', 26, 39)
    return key, st


# ------------------------------------------------------------------ 3. Lotus Lump: inner-TBTB keyhole, common. Canal piece asleep, a pink lotus on its head.
def lotus_lump():
    key = 'mt-lotus-lump'
    st = Sticker()
    core = (14, 21, 45, 45)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 7), s=('T', 'keyhole', 0), e=('B', 'keyhole', 0, 3.6), w=('B', 'keyhole', 0, 3.6))
    t = body_fill(key, body, 14, 21, 32, k=3, passes=3)
    t = lift(t, body, TEAL, 330)
    st.part(body, tex=t, contour=True)
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    # lotus: three pointed pink petals and a gold heart, on the top-left shoulder
    petals = poly([(20, 21), (14, 13), (19, 16), (22, 9), (25, 16), (30, 13), (24, 21)])
    st.part(petals, PINK, d=2, contour=True)
    st.paint(line([(22, 12), (22, 19)]) & petals, PINK_L)
    st.dots([(21, 19), (22, 19), (23, 19)], YEL)
    st.eye(19, 28, lid=2)
    st.eye(33, 28, lid=2)
    st.mouth('smile', 26, 37)
    return key, st


# ------------------------------------------------------------------ 4. Sky Lantern: inner-TTTT tri, uncommon. Rain-sky Plus piece with mango arrow tips, holding a paper lantern.
def sky_lantern():
    key = 'mt-sky-lantern'
    st = Sticker()
    core = (16, 18, 43, 45)
    body = piece(core, n=('T', 'tri'), e=('T', 'tri'), s=('T', 'tri'), w=('T', 'tri'))
    st.part(body, tex=body_fill(key, body, 16, 18, 28, k=3, passes=3))
    tips = body & ~rect(12, 14, 47, 49)
    st.part(tips, ORG, d=2)
    st.stitch(body, col=ORG_D)
    # paper lantern on a string from the east tip
    st.paint(line([(52, 33), (52, 39)]), UMBER2, solid=True)
    lan = ellipse(52.5, 44, 4.2, 5.2)
    st.part(lan, PINK, d=2, contour=True)
    st.paint(lan & (np.abs(CX - 52.5) < 0.8), PINK_D)
    st.part(rect(50, 38, 54, 39) | rect(50, 49, 54, 50), YEL, d=0, contour=True)
    st.eye(21, 26, look=(0, -1))
    st.eye(33, 26, look=(0, -1))
    st.mouth('smile', 27, 35)
    return key, st


# ------------------------------------------------------------------ 5. Fig Knot: inner-TTBB hook, uncommon. Canopy piece wrapped in strangler-fig roots, pink accent.
def fig_knot():
    key = 'mt-fig-knot'
    st = Sticker()
    core = (14, 19, 44, 45)
    body, holes = piece_blanks(core, n=('T', 'hook', -2), e=('T', 'hook', 2), s=('B', 'hook', 0, 4.0), w=('B', 'hook', 1, 4.0))
    t = lift(body_fill(key, body, 14, 19, 31, k=2, passes=4, dy=-0.3), body, JADE, 300)
    st.part(body, tex=t, contour=True)
    st.blank_shade(body, holes)
    st.stitch(body, col=PINK, skip=grow(holes, 3))
    feet(st, [15, 38], 46, w=6, h=3)
    # strangler roots: draped over the right shoulder and down the side, kept off the face
    roots = line([(41, 15), (44, 25), (42, 34), (45, 44)], 3) | line([(44, 40), (31, 43), (17, 42)], 2)
    st.part(roots, WOOD, d=1, contour=True)
    st.paint(roots & shrink(roots, 1) & ((XX + YY) % 4 == 0), WOOD_L)
    st.eye(18, 26, look=(-1, 0))
    st.eye(29, 26, look=(-1, 0))
    st.mouth('smirk', 22, 35)
    return key, st


# ------------------------------------------------------------------ 6. Bill Brolly: whimsy-hornbill double, rare. Hornbill (casque + big yellow bill, white tail band), double-knob tail, leaf umbrella.
def bill_brolly():
    key = 'mt-bill-brolly'
    st = Sticker()
    col, row = ROWS[key]['piece']
    head = disc(23, 33, 8)
    torso = ellipse(34, 40, 11, 8.5)
    tail = poly([(40, 35), (46, 38), (46, 45), (40, 46)])
    tab = knob('e', 'double', 41.5, 46.5, r=2.8)
    body = head | torso | tail | tab
    # leaf umbrella behind: a stalk held up from the back, a broad jade leaf with a midrib and ribs
    st.part(rect(35, 18, 36, 34), JADE_D, d=0, contour=True)
    leaf = ellipse(36, 19.5, 16, 8.5) & (CY < 20)
    leaf |= poly([(20, 19), (52, 19), (50, 21), (22, 21)])
    st.part(leaf, JADE, d=2, contour=True)
    for x in (25, 31, 41, 47):
        st.paint(line([(36, 12), (x, 19)]) & shrink(leaf, 1), JADE_D)
    st.paint(rect(35, 12, 36, 19) & leaf, JADE_L)
    # body: the cell's own pixels mapped by brightness onto the hornbill's slate-black
    src = pic.sample(col, row, 12, 22, 42).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(INK)
    tex[src > 560] = hx(INK_L)
    tex = majority(tex, body, 3)
    st.part(body, tex=tex, contour=True)
    # white belly and white tail band (pied hornbill)
    st.paint(torso & ellipse(32, 46, 8, 3.5) & shrink(body, 2), WHITE)
    st.paint(body & ((tail | tab) & (CX > 46.5)) & shrink(body, 1), WHITE)
    st.stitch(torso & ~head, col=GOLD)
    # big bill: yellow wedge with an orange casque on top
    bill = poly([(20, 31), (12, 33), (8, 37), (9, 39), (20, 38)])
    st.part(bill, YEL, d=1, rim=False, contour=True)
    casque = poly([(20, 26), (14, 28), (10, 32), (20, 31)])
    st.part(casque, ORG, d=1, rim=False, contour=True)
    st.paint(line([(10, 38), (19, 37)]) & bill, YEL_D)
    feet(st, [28, 36], 48, w=5, h=3)
    st.eye(21, 27, look=(-1, 0), socket=None)
    st.eye(27, 28, look=(-1, 0), socket=None)
    st.sparkle(4, 14)
    st.sparkle(55, 27, big=False)
    st.sparkle(7, 48, big=False)
    return key, st


PALS = [stilt_stoop, seedling_plod, lotus_lump, sky_lantern, fig_knot, bill_brolly]

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
