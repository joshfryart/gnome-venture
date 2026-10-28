"""Puzzle Pals: MISTMOOR roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_mistmoor.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own cell of
game/assets/img/jigsaw/mistmoor.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (fly-agaric toadstool, the red-and-cream lighthouse, the Crooked Kettle, heather, the kite's
bow tail, Professor Hoot's gatepost). Picture palette (jigsaw_mistmoor.py): slate sky #7b8797, heather #8a5a8e, moss #6f7f4a, rust #a85a2c,
peat #5a3e2c, stone #9c9d97, lantern amber #f2b84a, kite mustard #c9a23a, wine #9a3a3a, wool #e6e2d6.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('mistmoor')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'mistmoor':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

FLY, FLY_D = '#b8483a', '#8a2c2a'
WOOL, WOOL_D = '#e6e2d6', '#bdb8ac'
WINE = '#9a3a3a'
WARM, WARM_D = '#f2b84a', '#d98a2a'
HEATH, HEATH_D, HEATH_L = '#8a5a8e', '#64406c', '#b07fb2'
MOSS, MOSS_D = '#6f7f4a', '#55633a'
RUST, RUST_D, RUST_L = '#a85a2c', '#7c3e22', '#c97a3e'
MUST = '#c9a23a'
STONE, STONE_D = '#9c9d97', '#74766f'
MIST = '#c3c9d0'
OWL = '#8a6a4a'


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


def tint(tex, mask, col, amt=0.5):
    """Pull the whole fill toward one colour (keeps its own light and dark, so it is still its cell)."""
    t = tex.copy()
    t[mask] = (t[mask].astype(float) * (1 - amt) + hx(col).astype(float) * amt).round().astype(np.uint8)
    return t


def calm(tex, mask, col, bright=540, warm=50):
    """Quiet a loud prop inside a cell (the lighthouse, a lit window): very pale or strongly warm fill colours become col."""
    t = tex.copy()
    v = t.astype(int)
    loud = mask & ((v.sum(-1) > bright) | (v[..., 0] - v[..., 2] > warm))
    t[loud] = hx(col)
    return t


def feet(st, xs, y, w=6, h=4):
    for x in xs:
        shoe = rect(x, y, x + w - 1, y + h - 1)
        shoe[y, x] = shoe[y, x + w - 1] = False
        st.part(shoe, SHOE[0], d=1, contour=True)


# ------------------------------------------------------------------ 1. Toadstool Tuck: corner-BB round, common. Flat foot and back, a fly-agaric cap pulled down over one ear.
def toadstool_tuck():
    key = 'mm-toadstool-tuck'
    st = Sticker()
    core = (10, 22, 46, 50)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'round', 7), e=('B', 'round', 4))
    st.part(body, tex=calm(body_fill(key, body, 10, 22, 37, k=3, passes=3), body, '#6f8a4e', warm=40))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [13, 33], 51)
    # fly-agaric cap on the flat top-left corner: red dome, cream gill rim, three cream spots
    cap = ellipse(19, 21, 12, 9) & (CY < 21)
    gill = rect(8, 20, 30, 22) & ellipse(19, 21, 12.5, 9)
    st.part(gill, WOOL, d=1, contour=True)
    st.part(cap, FLY, d=2, contour=True)
    st.paint(rect(9, 21, 29, 21) & gill, WOOL_D)
    st.sprite(['.CC.', 'CCCC', '.CC.'], 12, 15, {'C': WOOL}, solid=False)
    st.sprite(['CC', 'CC'], 20, 13, {'C': WOOL}, solid=False)
    st.sprite(['.CC.', 'CCCC', '.CC.'], 24, 17, {'C': WOOL}, solid=False)
    st.eye(14, 27, look=(1, 1), lid=2)
    st.eye(24, 27, look=(1, 1), lid=2)
    st.mouth('smile', 18, 36)
    return key, st


# ------------------------------------------------------------------ 2. Skerry Seal: edge-TBB keyhole, common. Flat belly, head tab, a lighthouse-striped bobble hat; nose and whiskers.
def skerry_seal():
    key = 'mm-skerry-seal'
    st = Sticker()
    core = (12, 24, 47, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole'), e=('B', 'keyhole', 6), w=('B', 'keyhole', 6))
    st.part(body, tex=calm(body_fill(key, body, 12, 24, 36, k=3, passes=3), body, '#8b96a4'))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [15, 38], 51, w=7, h=3)
    # lighthouse bobble hat on the head tab: wine and cream bands, a lantern-amber bobble
    hat = ellipse(30, 21, 10, 9) & (CY < 21)
    st.part(hat, WOOL, d=2, contour=True)
    st.paint(hat & ((CY > 13) & (CY < 16) | (CY > 18)), WINE)
    st.part(rect(19, 20, 41, 22), WINE, d=1, contour=True)
    st.part(disc(30, 10.5, 3.2), WARM, d=1, contour=True)
    st.eye(18, 28, look=(0, 0))
    st.eye(36, 28, look=(0, 0))
    st.sprite(['UUUUU', '.UUU.'], 27, 35, {'U': UMBER}, solid=False)   # wedge nose
    st.mouth('cat', 27, 38)
    st.dots([(22, 37), (21, 39), (37, 37), (38, 39)], WOOL)            # whisker spots
    return key, st


# ------------------------------------------------------------------ 3. Peat Sip: inner-TBBB peg, common. Cottage-wall piece with the Crooked Kettle on its head, humming.
def peat_sip():
    key = 'mm-peat-sip'
    st = Sticker()
    core = (12, 22, 47, 51)
    body, holes = piece_blanks(core, n=('T', 'peg', -5), e=('B', 'peg', 7, 3.3), s=('B', 'peg', 0, 3.1), w=('B', 'peg', 7, 3.3))
    st.part(body, tex=calm(body_fill(key, body, 12, 22, 36, k=3, passes=3), body, STONE, warm=60))   # the lit window would fight the face
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [14, 39], 52)
    # copper kettle on the peg: round belly, spout up to the right, arched handle, a puff of steam
    spout = poly([(30, 15), (35, 11), (38, 11), (38, 13), (33, 18)])
    st.part(spout, RUST, d=1, contour=True)
    handle = ellipse(25, 12, 5.5, 4) & ~ellipse(25, 12, 3.4, 2.2) & (CY < 13)
    st.part(handle, UMBER2, d=0, contour=True)
    pot = ellipse(25, 16, 8, 5)
    st.part(pot, RUST, d=2, contour=True)
    st.part(rect(24, 10, 26, 11), RUST_D, d=0, contour=True)
    st.part(disc(41.5, 9.5, 2.2), MIST, d=1, contour=True)
    st.eye(17, 29, look=(0, -1), lid=1)
    st.eye(31, 29, look=(0, -1), lid=1)
    st.sprite(['.U.', 'U.U', '.U.'], 24, 36, {'U': UMBER}, solid=False)   # hummed o
    return key, st


# ------------------------------------------------------------------ 4. Stone Sentry: inner-TTTT tri, uncommon. A standing-stone Plus, dead serious, heather sprig behind its ear; heather stitch.
def stone_sentry():
    key = 'mm-stone-sentry'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'tri'), e=('T', 'tri'), s=('T', 'tri'), w=('T', 'tri'))
    st.part(body, tex=body_fill(key, body, 18, 18, 28, k=3, passes=3))
    st.stitch(body, col=HEATH_L)
    # heather sprig tucked at the top-left corner: a stem and a spray of purple bells
    st.part(line([(14, 22), (21, 15)], 2), MOSS_D, d=0, contour=True)
    spray = disc(13, 14, 3.2) | disc(17, 11, 3.0) | disc(10, 18, 2.6) | disc(19, 16, 2.4)
    st.part(spray, HEATH, d=2, contour=True)
    st.dots([(12, 13), (16, 10), (10, 17)], HEATH_L)
    st.eye(22, 25, look=(0, 0), lid=2)
    st.eye(36, 25, look=(0, 0), lid=2)
    st.mouth('flat', 30, 36)
    return key, st


# ------------------------------------------------------------------ 5. Kite Knot: inner-TTBB hook, uncommon. Sky piece in a huff, its kite tail tied in mustard and wine bows; mustard stitch.
def kite_knot():
    key = 'mm-kite-knot'
    st = Sticker()
    core = (17, 17, 44, 43)
    body, holes = piece_blanks(core, n=('T', 'hook', 0), w=('T', 'hook', 0), e=('B', 'hook', 5), s=('B', 'hook', -4))
    # tail behind the body: a wavy string from the lower right corner with three bows
    tail = line([(42, 41), (47, 45), (45, 49), (51, 51), (53, 54)], 2)
    st.part(tail, UMBER2, d=0, contour=True)
    st.part(body, tex=calm(body_fill(key, body, 17, 17, 28, k=3, passes=3), body, '#7b8797', warm=40), contour=True)
    st.blank_shade(body, holes)
    st.stitch(body, col=MUST, skip=grow(holes, 3))
    for (bx, by, c) in ((44, 41, MUST), (42, 47, WINE), (49, 48, MUST)):
        st.sprite(['B...B', 'BB.BB', 'BBkBB', 'BB.BB', 'B...B'], bx, by, {'B': c, 'k': UMBER}, solid=True)
    st.eye(20, 24, look=(-1, 0), lid=2)
    st.eye(31, 24, look=(-1, 0), lid=2)
    st.mouth('smirk', 24, 34)
    return key, st


# ------------------------------------------------------------------ 6. Gatepost Hoot: whimsy-owl keyhole, rare. Owl-cut piece (ear tufts, keyhole wings) on its drystone gatepost; glow + sparkles.
def gatepost_hoot():
    key = 'mm-gatepost-hoot'
    st = Sticker()
    # gatepost first (behind the owl): stone block with a mossy cap
    post = rect(22, 45, 41, 53)
    st.part(post, STONE, d=2, contour=True)
    st.paint(rect(22, 45, 41, 46), MOSS)
    st.paint(rect(26, 49, 31, 49) | rect(35, 51, 39, 51), STONE_D)
    owl = ellipse(31.5, 31, 14, 16)
    tufts = poly([(18, 22), (19, 9), (27, 17)]) | poly([(45, 22), (44, 9), (36, 17)])
    wings = knob('w', 'keyhole', 33, 18.5, r=3.6) | knob('e', 'keyhole', 33, 44.5, r=3.6)
    body = (owl | tufts | wings) & (CY < 46)
    st.part(body, tex=tint(body_fill(key, body, 14, 12, 36, k=3, passes=3), body, OWL, 0.35), contour=True)
    st.stitch(body, skip=grow(tufts, 1) | (YY < 36))
    # facial discs, eyes, wedge beak, chest chevrons, talons on the post
    st.part(disc(25.5, 26.5, 6.2) | disc(37.5, 26.5, 6.2), WOOL, d=1)
    st.eye(23, 24, look=(1, 0))
    st.eye(35, 24, look=(-1, 0))
    st.sprite(['BBB', 'BBB', '.B.'], 30, 30, {'B': WARM_D}, solid=False)
    st.sprite(['C...C...C', '.C.C.C.C.'], 27, 37, {'C': WOOL}, solid=False)
    st.sprite(['AA.A..A.AA'], 22 + 4, 45, {'A': WARM_D}, solid=False)
    st.sparkle(5, 5)
    st.sparkle(53, 8, big=False)
    st.sparkle(51, 50)
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


PALS = [toadstool_tuck, skerry_seal, peat_sip, stone_sentry, kite_knot, gatepost_hoot]

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
