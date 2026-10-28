"""Puzzle Pals: SPICEPEAK roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_spicepeak.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own cell of
game/assets/img/jigsaw/spicepeak.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (saffron crocus, yak horns, chilli garland, the white stupa, marigold boat garland, the kites).
Picture palette (jigsaw_spicepeak.py): saffron #f0a020, magenta #c8327a, teal #2a9a9a, snow #f7f5ee, tea #3f9a4a, wood #b07a3a, prayer flags.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('spicepeak')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'spicepeak':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

SAFF, SAFF_D, SAFF_L = '#f0a020', '#c06a10', '#f8d060'
MAG, MAG_D, MAG_L = '#c8327a', '#8e1f58', '#ec74ac'
TEAL, TEAL_D, TEAL_L = '#2a9a9a', '#1d7378', '#7fd0c8'
CROC, CROC_D, CROC_L = '#8a5aa8', '#634080', '#b48ad0'
WOOD, WOOD_D = '#b07a3a', '#7a4a1f'
SNOW, SNOW_D = '#f4f0e4', '#c9c5bc'
RED, RED_D = '#d6322b', '#a8241f'
LEAF = '#3f9a4a'
YAK, YAK_L = '#4a3a30', '#6a5848'
HORN = '#f1ece0'
FLAGS = ('#3f7fc8', '#d6322b', '#3f9a4a', '#f0c030')


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


def fill_cols(t, mask):
    cols = np.unique(t[mask].reshape(-1, 3), axis=0)
    return [hexs(c) for c in cols]


# ------------------------------------------------------------------ 1. Saffron Snip: corner-BB round, common. Flat foot and back, blanks top and right, a saffron crocus in its cap.
def saffron_snip():
    key = 'sp-saffron-snip'
    st = Sticker()
    core = (11, 21, 45, 50)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'round', 7, 4.2), e=('B', 'round', 4, 4.2))
    st.part(body, tex=body_fill(key, body, 11, 21, 35, k=4, passes=3))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [14, 34], 51)
    # crocus on the flat top-left corner: two leaves, three purple petals, red-orange saffron threads
    lv = poly([(13, 22), (9, 14), (15, 19)]) | poly([(26, 22), (30, 14), (24, 19)])
    st.part(lv, LEAF, d=1, contour=True)
    pet = ellipse(14.5, 15.5, 3.2, 5) | ellipse(24.5, 15.5, 3.2, 5) | ellipse(19.5, 13, 3.6, 6.2)
    st.part(pet, CROC, d=2, contour=True)
    st.paint(pet & (np.abs(CX - 19.5) < 0.6) & (CY > 8.5) & (CY < 17), CROC_D)
    st.paint(line([(19, 20), (17, 11)]) | line([(20, 20), (22, 11)]), RED)
    st.dots([(17, 11), (22, 11)], SAFF)
    st.eye(14, 29, look=(1, 0))
    st.eye(26, 29, look=(1, 0))
    st.mouth('grin', 20, 38)
    return key, st


# ------------------------------------------------------------------ 2. Yak Yonder: edge-TTB double, common. Flat foot, tabs top and left, blank right; a woolly yak cap with horns.
def yak_yonder():
    key = 'sp-yak-yonder'
    st = Sticker()
    core = (17, 25, 48, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'double', 0), w=('T', 'double', 2), e=('B', 'double', 3, 4.4))
    st.part(body, tex=body_fill(key, body, 17, 25, 32, k=4, passes=3, swap={'#2a1a10': '#4f9a45', '#4a2c1a': '#6eae5a'}))   # calm the moth and bush outlines
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [20, 38], 51)
    # horns first (behind the cap), then the shaggy yak-wool cap over the top knob
    horns = poly([(25, 20), (18, 16), (15, 9), (19, 11), (22, 15), (27, 17)]) | \
        poly([(40, 20), (47, 16), (50, 9), (46, 11), (43, 15), (38, 17)])
    st.part(horns, HORN, d=1, contour=True)
    cap = ellipse(32.5, 21, 10, 6) & (CY < 24)
    st.part(cap, YAK, d=2, contour=True)
    st.paint(cap & shrink(cap, 1) & (CY < 20) & (((XX * 2 + YY) % 5) == 0), YAK_L)   # wool tufts
    st.eye(22, 30, look=(-1, 0))
    st.eye(34, 30, look=(-1, 0))
    st.mouth('smile', 27, 40)
    return key, st


# ------------------------------------------------------------------ 3. Chilli Chime: inner-TBTB peg, common. Pegs top and bottom, blanks either side (low), a chilli garland on the brow.
def chilli_chime():
    key = 'sp-chilli-chime'
    st = Sticker()
    core = (12, 16, 49, 43)
    body, holes = piece_blanks(core, n=('T', 'peg'), s=('T', 'peg'), e=('B', 'peg', 6), w=('B', 'peg', 6))
    t = body_fill(key, body, 12, 16, 38, k=4, passes=3)
    sw = {c: WOOD for c in fill_cols(t, body) if hx(c).astype(int).sum() < 260}   # the souk's dark timbers -> lit wood, so eyes read
    sw.update({c: '#d9a35a' for c in fill_cols(t, body) if c in ('#2a9a9a', '#1d7378', '#7fd0c8', '#d6322b', '#a8241f')})   # no stray shelf teal or red
    t = remap(t, body, sw)
    st.part(body, tex=t)
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [24, 33], 53, w=5, h=3)
    # garland: a sagging string across the brow with three fat red chillies (green caps), tips curling
    st.paint(line([(13, 18), (22, 20), (31, 21), (40, 20), (48, 18)]), UMBER2)
    for x, y in ((16, 19), (28, 21), (40, 19)):
        ch = rect(x, y + 1, x + 4, y + 4) | rect(x + 1, y + 5, x + 3, y + 6) | rect(x + 2, y + 7, x + 2, y + 8)
        st.part(ch, RED, d=1, contour=True)
        st.dots([(x + 1, y), (x + 2, y)], LEAF)
    st.eye(21, 29, look=(0, 1))
    st.eye(35, 29, look=(0, 1))
    st.mouth('o', 29, 37)
    return key, st


# ------------------------------------------------------------------ 4. Stupa Snug: inner-TTTT double, uncommon. Plus shape under a little white stupa dome with a gold spire; saffron stitch.
def stupa_snug():
    key = 'sp-stupa-snug'
    st = Sticker()
    core = (18, 23, 45, 48)
    body = piece(core, n=('T', 'double'), e=('T', 'double'), s=('T', 'double'), w=('T', 'double'))
    st.part(body, tex=body_fill(key, body, 18, 23, 28, k=4, passes=3))
    st.stitch(body, col=SAFF_D)
    dome = ellipse(32, 17, 9, 6.5) & (CY < 18)
    band = rect(22, 17, 42, 18)
    spire = poly([(32, 6), (29.5, 12), (34.5, 12)])
    st.part(spire, SAFF, d=1, contour=True)
    st.part(dome, SNOW, d=2, contour=True)
    st.part(band, SAFF, d=1, contour=True)
    st.dots([(24, 17), (28, 17), (32, 17), (36, 17), (40, 17)], MAG)       # prayer-flag beads on the band
    st.eye(22, 27, look=(1, 0))
    st.eye(34, 27, look=(1, 0))
    st.mouth('smile', 28, 37)
    return key, st


# ------------------------------------------------------------------ 5. Teal Ferry: inner-TTBB hook, uncommon. Hooks top and right, blanks under and left; a marigold boat garland crown; magenta stitch.
def teal_ferry():
    key = 'sp-teal-ferry'
    st = Sticker()
    core = (14, 20, 45, 46)
    body, holes = piece_blanks(core, n=('T', 'hook', -2), e=('T', 'hook', -3), s=('B', 'hook', 5, 4.2), w=('B', 'hook', 6, 4.2))
    t = body_fill(key, body, 14, 20, 32, k=3, passes=4)
    lum = {c: hx(c).astype(int).sum() for c in fill_cols(t, body)}
    t = remap(t, body, {c: (TEAL_D if v < 330 else TEAL if v < 520 else TEAL_L) for c, v in lum.items()})   # ghats/boats -> one calm river family
    st.part(body, tex=t)
    st.blank_shade(body, holes)
    st.stitch(body, col=MAG, skip=grow(holes, 3))
    feet(st, [16, 41], 47, w=6, h=4)
    # marigold garland crown along the brow: round flower beads, orange and yellow
    for i, x in enumerate(range(15, 45, 5)):
        fl = disc(x + 1.5, 21.5, 2.3)
        st.part(fl, SAFF if i % 2 == 0 else '#e0702a', d=1, contour=True)
        st.dots([(x + 1, 21)], SAFF_L)
    st.eye(20, 27, look=(1, 0))
    st.eye(32, 27, look=(1, 0))
    st.mouth('grin', 25, 36)
    return key, st


# ------------------------------------------------------------------ 6. Lofty Kite: whimsy-kite tri, rare. A diamond kite (sky quadrants + magenta), cross spars, tri knob tail tie, prayer-flag bows.
def lofty_kite():
    key = 'sp-lofty-kite'
    st = Sticker()
    cx, cy = 27.5, 24
    kite = poly([(cx, 8), (cx + 17, cy - 2), (cx, 43), (cx - 17, cy - 2)])
    tie = knob('s', 'tri', cx, 42, r=2.8, nw=1.8)
    body = kite | tie
    # tail: a thin cream string (black border only, like a sparkle) curling out to the right, three prayer-flag bows
    tail = line([(28, 47), (33, 50), (39, 48), (45, 51), (51, 48), (55, 44)])
    st.paint(tail, SNOW)
    st.extra |= tail
    for (bx, by), c in zip(((36, 49), (45, 51), (53, 46)), (FLAGS[0], FLAGS[1], FLAGS[3])):
        bow = poly([(bx - 3, by - 3), (bx, by), (bx - 3, by + 3)]) | poly([(bx + 3, by - 3), (bx, by), (bx + 3, by + 3)])
        st.paint(bow, c)
        st.paint(rect(bx, by, bx, by), UMBER2)
        st.extra |= bow
    tex = body_fill(key, body, 10, 8, 35, k=3, passes=3)
    quad = body & (((CX > cx) & (CY < cy - 2)) | ((CX < cx) & (CY > cy - 2)))
    tex[quad] = hx(MAG)
    st.part(body, tex=tex, contour=True)
    spars = (rect(int(cx), 10, int(cx), 45) | rect(11, cy - 2, 44, cy - 2)) & shrink(kite, 1)
    st.paint(spars, WOOD_D)
    st.stitch(kite, col=SAFF_L)
    st.eye(19, 15, look=(0, 1))
    st.eye(31, 15, look=(0, 1))
    st.mouth('grin', int(cx) - 2, cy + 2)
    st.sparkle(49, 6)
    st.sparkle(7, 40, big=False)
    st.sparkle(51, 30, big=False)
    return key, st


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
            m = a & (keyv == vals[i])
            rgba[m, :3] = rgb[j]
    ys, xs = np.nonzero(border)
    margin = min(int(xs.min()), int(ys.min()), int(N - 1 - xs.max()), int(N - 1 - ys.max()))
    cols = len({tuple(p) for p in rgba[a][:, :3]})
    Image.fromarray(rgba, 'RGBA').save(path, optimize=True)
    return {'colours': cols, 'margin': margin}


PALS = [saffron_snip, yak_yonder, chilli_chime, stupa_snug, teal_ferry, lofty_kite]

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
