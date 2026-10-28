"""Puzzle Pals: THORNACRE SAVANNA roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_thornacre.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own cell of
game/assets/img/jigsaw/thornacre.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (the coffee gnome's big purple hat, a flamingo plume, a red termite spire, acacia twigs with
weaver nests, the lookout gnome's brass spyglass, an acacia sprig for the giraffe).
Picture palette (jigsaw_thornacre.py): gold grass #e2a93e, umber #7a4a1f, red clay #b8502a, granite #b9a088, giraffe #f0b048,
flamingo #f08aa0, acacia #7a8a3a, gnome purple #7a5cc0.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('thornacre')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'thornacre':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

PURP, PURP_D, PURP_L = '#7a5cc0', '#4e3a8a', '#c3b2ea'
PINK, PINK_D, PINK_L = '#f08aa0', '#c8607a', '#f8c0c8'
CLAY, CLAY_D, CLAY_L = '#b8502a', '#8a3a1f', '#d9764a'
MUD = '#c9875a'
BARK, BARK_D = '#8a6a52', '#6a4e3c'
LEAF, LEAF_D, LEAF_L = '#7a8a3a', '#55652a', '#a4b05a'
THATCH, THATCH_D = '#d9a35a', '#a8743a'
GRAN, GRAN_D, GRAN_L = '#b9a088', '#8a7464', '#dccab0'
BRASS, BRASS_D, BRASS_L = '#e8a317', '#b07a10', '#f5cf6a'
GIR, GIR_D, GIR_L = '#f0b048', '#c98a2a', '#f8d88a'
SPOT = '#a8701c'
LICHEN = '#f08a24'


def body_fill(key, mask, x0, y0, size, k=4, passes=2, dx=0.0, dy=0.0, swap=None):
    col, row = ROWS[key]['piece']
    t = pic.sample(col, row, x0, y0, size, dx, dy)
    t = majority(t, mask, passes)
    t = reduce(t, mask, k)
    if swap:
        t = remap(t, mask, swap)
    return t


def ramp_fill(key, mask, x0, y0, size, cols, cuts, passes=3, dx=0.0, dy=0.0):
    """The cell's own pixels mapped by brightness (r+g+b) onto a ramp: cols[i] where brightness >= cuts[i-1], so the cell's shapes
    survive but the colours become one material (granite, giraffe hide)."""
    col, row = ROWS[key]['piece']
    src = pic.sample(col, row, x0, y0, size, dx, dy).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(cols[0])
    for c, cut in zip(cols[1:], cuts):
        tex[src >= cut] = hx(c)
    return majority(tex, mask, passes)


def lift(tex, mask, col, thr=260):
    """Calm a dark busy cell: fill colours darker than thr (r+g+b) become col, so the face reads on top."""
    t = tex.copy()
    t[mask & (t.astype(int).sum(-1) < thr)] = hx(col)
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


def nudge(st, dx, dy):
    """Move everything drawn so far by (dx, dy) to keep the 3 px clear border."""
    st.px = np.stack([shift(st.px[..., i], dx, dy) for i in range(3)], -1)
    st.sil, st.extra = shift(st.sil, dx, dy), shift(st.extra, dx, dy)


def feet(st, xs, y, w=6, h=4):
    for x in xs:
        shoe = rect(x, y, x + w - 1, y + h - 1)
        shoe[y, x] = shoe[y, x + w - 1] = False
        st.part(shoe, SHOE[0], d=1, contour=True)


# ------------------------------------------------------------------ 1. Coffee Crumb: corner-TT round, common. Bottom-right corner piece (flat foot + back),
# grass-and-coffee-mat cell, the roasting gnome's very large purple hat perched on its top knob.
def coffee_crumb():
    key = 'th-coffee-crumb'
    st = Sticker()
    core = (15, 27, 46, 50)
    body = piece(core, s='F', e='F', n=('T', 'round', 3), w=('T', 'round', 1))
    st.part(body, tex=lift(body_fill(key, body, 15, 27, 32, k=3, passes=3), body, '#4f9a45', 300))
    st.stitch(body)
    feet(st, [18, 37], 51)
    # big gnome hat: wide brim, tall cone leaning left with a drooping tip, a pale band
    brim = poly([(16, 24), (48, 21), (49, 25), (17, 28)])
    cone = poly([(21, 24), (27, 12), (31, 6), (36, 9), (39, 15), (43, 23)])
    st.part(cone, PURP, d=2, contour=True)
    st.part(brim, PURP, d=1, contour=True)
    st.paint(poly([(22, 20), (42, 18), (43, 22), (22, 24)]) & cone, PURP_L)
    st.eye(19, 32, look=(1, 0))
    st.eye(33, 32, look=(1, 0))
    st.mouth('grin', 26, 41)
    nudge(st, 3, 2)
    return key, st


# ------------------------------------------------------------------ 2. Flamingo Flick: edge-BTB keyhole, common. Waterhole edge piece on ONE pink leg,
# a pink plume on its top knob.
def flamingo_flick():
    key = 'th-flamingo-flick'
    st = Sticker()
    core = (14, 24, 48, 46)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', -2), w=('B', 'keyhole', 2), e=('B', 'keyhole', 2))
    st.part(body, tex=ramp_fill(key, body, 14, 24, 35, ('#25637d', '#3f8fb0', '#a9d6ea'), (300, 640), passes=3))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    # one long pink leg with a knee, a felt boot; the other leg folded up under the body
    st.part(rect(29, 47, 31, 50), PINK, d=1, contour=True)
    feet(st, [27], 51, w=7, h=3)
    # plume: three fat pink feathers fanning up from the keyhole knob
    plume = ellipse(26.5, 11, 2.6, 4) | ellipse(31, 10, 2.8, 4.5) | ellipse(35.5, 11, 2.6, 4)
    st.part(plume & (CY < 14), PINK, d=2, contour=True)
    st.paint(line([(31, 7), (31, 12)]), PINK_D)
    st.eye(21, 30, look=(1, 0))
    st.eye(35, 30, look=(1, 0))
    st.mouth('smirk', 28, 39)
    nudge(st, 0, 2)
    return key, st


# ------------------------------------------------------------------ 3. Termite Tower: inner-TBBB round, common. Red termite-mound piece carrying a
# taller red clay spire (with its little air holes) on its head.
def termite_tower():
    key = 'th-termite-tower'
    st = Sticker()
    core = (12, 22, 49, 48)
    body, holes = piece_blanks(core, n=('T', 'round', 9), e=('B', 'round', 5, 3.4), s=('B', 'round', 0, 3.4), w=('B', 'round', 5, 3.4))
    st.part(body, tex=lift(body_fill(key, body, 12, 22, 38, k=3, passes=3, dx=0.15), body, CLAY_L, 330))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [13, 42], 49)
    spire = poly([(13, 23), (16, 16), (18, 10), (21, 6), (24, 9), (26, 15), (29, 19), (31, 23)])
    st.part(spire, CLAY, d=2, contour=True)
    st.paint(line([(18, 12), (17, 21)]) & spire, CLAY_L)
    st.dots([(21, 11), (22, 11), (21, 12), (22, 12), (24, 18), (25, 18), (24, 19), (25, 19)], UMBER2)
    st.eye(20, 26, look=(-1, 0))
    st.eye(36, 26, look=(-1, 0))
    st.mouth('tooth', 28, 34)
    nudge(st, 0, 1)
    return key, st


# ------------------------------------------------------------------ 4. Acacia Antler: inner-TTTT tri, uncommon. Plus piece from the thatch, acacia-green
# arrow tips (the accent), two antler twigs with flat-top leaf pads and hanging weaver nests.
def acacia_antler():
    key = 'th-acacia-antler'
    st = Sticker()
    core = (19, 24, 44, 46)
    body = piece(core, n=('T', 'tri'), e=('T', 'tri'), s=('T', 'tri'), w=('T', 'tri'))
    # antlers behind the body
    tw = line([(23, 25), (17, 15), (11, 12)], 2) | line([(19, 18), (21, 11)], 2) | \
        line([(40, 25), (46, 15), (52, 12)], 2) | line([(44, 18), (42, 11)], 2)
    st.part(tw, BARK, d=0, contour=True)
    pads = ellipse(12, 10, 4.5, 2.2) | ellipse(21, 9, 3.5, 2) | ellipse(51, 10, 4.5, 2.2) | ellipse(42, 9, 3.5, 2)
    st.part(pads, LEAF, d=1, contour=True)
    nests = ellipse(11, 16, 2.2, 2.6) | ellipse(52, 16, 2.2, 2.6)
    st.part(nests, THATCH, d=1, contour=True)
    st.part(body, tex=body_fill(key, body, 19, 24, 26, k=3, passes=3), contour=True)
    tips = body & ~rect(core[0] - 2, core[1] - 2, core[2] + 2, core[3] + 2)
    st.part(tips, LEAF, d=2)
    st.stitch(body, col=LEAF_D)
    st.eye(23, 29, look=(0, 1))
    st.eye(35, 29, look=(0, 1))
    st.mouth('smile', 29, 38)
    return key, st


# ------------------------------------------------------------------ 5. Kopje Keeper: inner-TTBB hook, uncommon. Granite piece (its cell carved into
# granite tones), wide never-blinking eyes, orange lichen stitch (accent), the lookout gnome's brass spyglass.
def kopje_keeper():
    key = 'th-kopje-keeper'
    st = Sticker()
    core = (17, 22, 46, 45)
    body, holes = piece_blanks(core, n=('B', 'hook', 7, 4.0), e=('B', 'hook', 6), s=('T', 'hook', 0), w=('T', 'hook', 2))
    st.part(body, tex=ramp_fill(key, body, 17, 22, 30, (GRAN, GRAN, GRAN_L), (240, 560), dx=-0.25))
    st.blank_shade(body, holes)
    st.stitch(body, col=LICHEN, skip=grow(holes, 3))
    st.dots([(40, 40), (41, 40), (40, 41), (22, 41), (23, 41)], LICHEN)
    # spyglass tucked over the left shoulder, pointing up-left at the plain
    st.eye(21, 28, look=(0, 0))
    st.eye(32, 28, look=(1, 0))
    # brass spyglass held up to the right eye, pointing out over the plain
    tube = rect(39, 28, 46, 32) | rect(47, 27, 54, 33)
    st.part(tube, BRASS, d=1, contour=True)
    st.paint(rect(46, 27, 46, 33) | rect(42, 28, 42, 32), BRASS_D)
    st.paint(rect(54, 28, 54, 32), UMBER2)
    st.mouth('flat', 30, 38)
    return key, st


# ------------------------------------------------------------------ 6. Tall Tiptoe: whimsy-giraffe double, rare. A giraffe-shaped piece whose double knob
# is its pair of ossicones; hide = its cell mapped onto giraffe gold with patches; an acacia sprig in its mouth; glow + sparkles.
def tall_tiptoe():
    key = 'th-tall-tiptoe'
    st = Sticker()
    torso = ellipse(21, 36, 11, 5.5) | ellipse(27, 34, 6, 5)          # sloping back, high withers
    neck = poly([(26, 31), (35, 20), (41, 22), (33, 37)])
    head = ellipse(42, 18, 8.5, 6.5) | ellipse(48, 21, 4, 3.5)
    horns = knob('n', 'double', 41, 12.5, r=2.6, nw=1.6)
    legs = rect(12, 38, 13, 53) | rect(16, 39, 17, 53) | rect(26, 38, 27, 53) | rect(30, 37, 31, 53)
    tail = line([(11, 33), (9, 40)], 1)
    body = torso | neck | head | horns | legs
    st.part(tail, GIR_D, d=0, contour=True)
    tex = ramp_fill(key, body, 8, 6, 46, (SPOT, GIR, GIR_L), (480, 640), passes=3)
    tex[head & np.all(tex == hx(SPOT), axis=2)] = hx(GIR)
    st.part(body, tex=tex)
    hide = shrink(torso | neck, 2) & ~grow(head, 1)
    for gy in range(18, 44, 5):                                # reticulated patches, offset each row
        for gx in range(4 + (gy // 5 % 2) * 3, 46, 6):
            sp = rect(gx, gy, gx + 3, gy + 2)
            sp[gy, gx] = sp[gy + 2, gx + 3] = False
            st.paint(sp & hide, SPOT)
    st.paint(horns & (CY < 9), UMBER2)
    for x in (12, 16, 26, 30):                                 # little hooves
        st.paint(rect(x, 52, x + 1, 53), UMBER2)
    st.stitch(torso | neck, skip=grow(legs, 1) | grow(head, 1))
    # acacia sprig in the mouth
    sprig = ellipse(52.5, 26.5, 3.0, 2.2) | ellipse(49.5, 29, 2.4, 1.8)
    st.part(sprig, LEAF, d=1, contour=True)
    st.eye(37, 15, look=(1, 0))
    st.eye(44, 15, look=(1, 0))
    st.mouth('smile', 44, 22)
    st.sparkle(52, 6)
    st.sparkle(7, 21, big=False)
    st.sparkle(50, 41)
    nudge(st, 0, 1)
    return key, st


PALS = [coffee_crumb, flamingo_flick, termite_tower, acacia_antler, kopje_keeper, tall_tiptoe]

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
        print('%-20s %-9s %-11s %-6s colours %d margin %d %s' % (key, ROWS[key]['rarity'], ROWS[key]['shape'], ROWS[key]['knob'], info['colours'],
                                                              info['margin'], info['sides']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
