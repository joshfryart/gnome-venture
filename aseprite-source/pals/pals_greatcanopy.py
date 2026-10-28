"""Puzzle Pals: THE GREATCANOPY roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_greatcanopy.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its own cell of
game/assets/img/jigsaw/greatcanopy.jpg (12 x 8 grid) snapped to the picture's palette and calmed to ~4 colours, palib house finish.
One accessory each from the picture's motifs (calabash gourd catching roof rain, talking drum, yam sprout, Grandmother Tortoise's shell,
the rope canopy bridge + rainbow, the grey parrot with the kente bunting).
Picture palette (jigsaw_greatcanopy.py): emerald #1f8a5a / leaf #2a9a52, laterite #b8532e, thatch #d9a84a, kente gold #e8b02a,
red #c8302a, indigo #3a4a8a, gourd #d9a35a, rain sky #94abb4.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('greatcanopy')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'greatcanopy':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

GOURD, GOURD_D, GOURD_L = '#d9a35a', '#a8743a', '#f2cf8a'
KGOLD, KGREEN, KRED = '#e8b02a', '#1f8a5a', '#c8302a'
RED_D = '#8a2020'
INDIGO, INDIGO_L = '#3a4a8a', '#6a7ac0'
LEAF, LEAF_D, LEAF_L = '#2a9a52', '#1a6a3a', '#6cc878'
WOOD, WOOD_D = '#9a6b3f', '#6a4424'
RAIN = '#cfe0e6'
TORT, TORT_D, TORT_L = '#8a8a4a', '#5e5e30', '#b4b070'
GREY, GREY_D = '#5a5456', '#3a3638'
RAINBOW = ('#c8302a', '#e8843a', '#e8b02a', '#5ab05a', '#3a6ab0', '#6a4a9a')


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


def drop(st, x, y):
    """A 2 x 3 raindrop (the picture's rain), cream-blue with a white glint."""
    st.sprite(['.r', 'rr', 'rR'], x, y, {'r': RAIN, 'R': '#8fb0bc'})


def fill_colours(tex, mask):
    cols, cnt = np.unique(tex[mask].reshape(-1, 3), axis=0, return_counts=True)
    return [(hexs(c), int(n)) for c, n in zip(cols[np.argsort(-cnt)], np.sort(cnt)[::-1])]


# ------------------------------------------------------------------ 1. Calabash Cup: corner-BB round, common. Flat foot and back, blanks top and right, a calabash half on its head catching a raindrop.
def calabash_cup():
    key = 'gc-calabash-cup'
    st = Sticker()
    core = (11, 22, 44, 49)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'round', 6), e=('B', 'round', 4))
    st.part(body, tex=body_fill(key, body, 11, 22, 34, k=3, passes=3))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [14, 32], 50)
    # calabash half (bowl, rim up) worn as a cap on the flat top-left corner, a raindrop falling in
    bowl = ellipse(21, 16, 11, 9) & (CY > 15)
    st.part(bowl, GOURD_L, d=2, contour=True)
    st.paint(ellipse(21, 16, 9, 1.6) & bowl, WOOD_D)                   # the rim opening, dark inside
    zig = bowl & shrink(bowl, 1) & (np.abs(CY - (20.5 + ((CX.astype(int) // 2) % 2))) < 0.6)
    st.paint(zig, GOURD_D)                                               # carved zigzag band
    drop(st, 20, 8)
    st.eye(15, 29, look=(1, 0))
    st.eye(27, 29, look=(1, 0))
    st.mouth('smile', 21, 38)
    return key, st


# ------------------------------------------------------------------ 2. Drum Tap: edge-TBB double, common. Flat foot, top double knob, blanks either side, a red-and-gold talking drum.
def drum_tap():
    key = 'gc-drum-tap'
    st = Sticker()
    core = (13, 24, 46, 50)
    body, holes = piece_blanks(core, s='F', n=('T', 'double', -3), w=('B', 'double', 4), e=('B', 'double', 4))
    st.part(body, tex=body_fill(key, body, 13, 24, 34, k=3, passes=3))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [16, 35], 51, w=7)
    # drum at the lower right: an hourglass talking drum, cream head, red body with gold kente bands
    head = ellipse(49, 37, 6, 2.2)
    drum = poly([(43, 37), (55, 37), (52, 44), (55, 51), (43, 51), (46, 44)])
    st.part(drum, KRED, d=2, contour=True)
    st.paint(drum & (np.abs(CY - 44) < 1.1), KGOLD)
    st.paint(drum & (np.abs(CY - 49) < 0.6), KGOLD)
    st.part(head, '#f2e4c0', d=1, rim=False)
    st.paint(line([(38, 29), (45, 35)], 2), WOOD_D, solid=True)            # the stick, mid-tap
    st.dots([(44, 31), (47, 32)], GOLD)                                     # beat marks
    st.eye(19, 30, look=(1, 0))
    st.eye(31, 30, look=(1, 0))
    st.mouth('grin', 24, 39)
    return key, st


# ------------------------------------------------------------------ 3. Yam Nub: inner-TBTB peg, common. Pegs top and bottom, blanks at the sides, a two-leaf yam sprout on its top peg.
def yam_nub():
    key = 'gc-yam-nub'
    st = Sticker()
    core = (17, 22, 44, 45)
    body, holes = piece_blanks(core, n=('T', 'peg', 0, 3.4), s=('T', 'peg', 0, 3.4), e=('B', 'peg', 2), w=('B', 'peg', 2))
    tex = body_fill(key, body, 17, 22, 28, k=2, passes=3, dy=-0.12, swap={'#2a1a10': '#b8532e'})
    tex = remap(tex, body & (CY < 38), {'#3a9a50': '#b8532e'})          # a laterite yam root over a grass hem: the face reads on one colour
    st.part(body, tex=tex)
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [21, 36], 54, w=5, h=3)
    # yam sprout: a stalk and two leaves (the yam mounds in the picture)
    st.part(rect(30, 10, 31, 15), LEAF_D, d=0, contour=True)
    lf = poly([(30, 12), (25, 7), (20, 8), (21, 13), (26, 14)]) | poly([(32, 11), (37, 6), (43, 7), (42, 12), (37, 13)])
    st.part(lf, LEAF, d=2, contour=True)
    st.paint(line([(29, 12), (23, 9)]) | line([(33, 11), (40, 8)]), LEAF_D)
    st.eye(21, 28, look=(0, 1))
    st.eye(34, 28, look=(0, 1))
    st.mouth('tooth', 27, 37)                                              # giggles when dug up
    return key, st


# ------------------------------------------------------------------ 4. Shellstep: inner-TTTT double, uncommon. The Plus: four double knobs = four tortoise feet, Grandmother Tortoise's shell cap, kente-green stitch.
def shellstep():
    key = 'gc-shellstep'
    st = Sticker()
    core = (18, 22, 44, 47)
    body = piece(core, n=('T', 'double'), e=('T', 'double'), s=('T', 'double'), w=('T', 'double'))
    st.part(body, tex=body_fill(key, body, 18, 22, 27, k=2, passes=3, swap={'#2a1a10': '#7a6a3a'}))
    toes = body & ~rect(13, 13, 49, 52) & ~(CY < 22)
    st.paint(toes & shrink(toes, 1) & (((XX + YY) % 3) == 0), TORT_D)
    st.stitch(body, col=KGREEN)
    # tortoise-shell dome over the top knob: olive plates with darker seams
    dome = ellipse(31, 22, 14, 9) & (CY < 23)
    st.part(dome, TORT, d=2, contour=True)
    plates = (np.abs(CX - 31) < 3.5) & (CY > 15) & (CY < 21) | (np.abs(CX - 23) < 2.5) & (CY > 17) & (CY < 21) | \
        (np.abs(CX - 39) < 2.5) & (CY > 17) & (CY < 21)
    st.paint(dome & shrink(dome, 1) & plates, TORT_L)
    st.paint(dome & (np.abs(CY - 22) < 0.6), TORT_D)
    st.eye(22, 28, look=(1, 0), lid=1)
    st.eye(34, 28, look=(1, 0), lid=1)
    st.mouth('smile', 27, 37)
    return key, st


# ------------------------------------------------------------------ 5. Canopy Loop: inner-BBBB keyhole, uncommon. The Ring: four blanks, a rope canopy-bridge sash, rainbow stitch.
def canopy_loop():
    key = 'gc-canopy-loop'
    st = Sticker()
    core = (10, 11, 50, 50)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.6), s=('B', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.6))
    st.part(body, tex=body_fill(key, body, 10, 11, 41, k=3, passes=3, swap={'#4a2c1a': '#adc2c4', '#3a6ab0': '#7f97a6'}))   # calm the rope tangle to rain sky
    st.blank_shade(body, holes)
    # rainbow stitch: the dashes cycle through the picture's rainbow (the uncommon accent)
    ring = shrink(body, 2) & ~shrink(body, 3) & ~grow(holes, 3)
    horiz = ring & (shift(ring, 1, 0) | shift(ring, -1, 0))
    on = np.where(horiz, XX % 3 != 2, YY % 3 != 2)
    band = ((XX + YY) // 6) % len(RAINBOW)
    for i, c in enumerate(RAINBOW):
        st.paint(ring & on & (band == i), c)
    # rope bridge slung across the lower body: two ropes with plank dashes
    rope1 = line([(12, 38), (21, 43), (30, 45), (39, 43), (49, 38)], 2)
    rope2 = shift(rope1, 0, 5)
    planks = blank()
    for px in range(14, 49, 4):
        planks |= rect(px, 38, px + 1, 52)
    span = blank()
    for xx in range(13, 49):
        ys = np.nonzero(rope1[:, xx])[0]
        if len(ys):
            span[ys.min():ys.min() + 6, xx] = True
    st.paint(span & planks & body, WOOD)
    st.paint(rope1 & body, WOOD_D)
    st.paint(rope2 & body, WOOD_D)
    st.eye(20, 25, look=(1, 0))
    st.eye(35, 25, look=(1, 0))
    st.mouth('grin', 28, 33)
    return key, st


# ------------------------------------------------------------------ 6. Parrot Pennant: whimsy-parrot hook, rare. A grey-parrot piece (head, hooked beak, wing, red tail), hook knob = the perching foot, kente pennant; glow + sparkles.
def parrot_pennant():
    key = 'gc-parrot-pennant'
    st = Sticker()
    head = disc(24, 19, 9.5)
    torso = ellipse(30, 34, 11, 13)
    foot = knob('s', 'hook', 32, 45.5, r=3.3)
    body = head | torso | foot
    # red tail fan behind the body, down and to the right
    tail = poly([(34, 42), (41, 40), (49, 51), (43, 53), (38, 49)])
    st.part(tail, KRED, d=2, contour=True)
    st.paint(line([(40, 44), (45, 51)]) & shrink(tail, 1), RED_D)
    # kente pennant on a pole held behind the shoulder
    st.part(rect(45, 9, 46, 38), WOOD, d=1, contour=True)
    flag = poly([(47, 10), (56, 15), (47, 20)])
    st.part(flag, KGOLD, d=1, contour=True)
    st.paint(flag & (np.abs(CX - 50.5) < 1.1), KGREEN)
    st.paint(flag & (np.abs(CX - 53.5) < 0.8), KRED)
    st.part(body, tex=body_fill(key, body, 12, 17, 28, k=3, passes=3), contour=True)
    st.stitch(torso & ~head)
    # wing: a darker teardrop on the torso
    wing = ellipse(34, 34, 6, 9) & torso
    st.part(wing, LEAF_D, d=2, contour=True)
    st.paint(wing & shrink(wing, 1) & (((CY.astype(int)) % 3) == 0) & (CX > 32), LEAF)
    # hooked beak on the left of the head: simple wedge, dark upper, pale lower
    beak = poly([(15, 17), (8, 20), (9, 25), (15, 24)])
    st.part(beak, GREY_D, d=1, rim=False, contour=True)
    st.paint(rect(9, 23, 13, 24) & beak, '#c9c5bc')
    st.eye(17, 14, look=(-1, 0))
    st.eye(26, 14, look=(-1, 0))
    st.sparkle(4, 34)
    st.sparkle(53, 26, big=False)
    st.sparkle(35, 4, big=False)
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
        dropped = set(order[:len(vals) - cap])
        keep = [i for i in range(len(vals)) if i not in dropped]
        for i in dropped:
            j = keep[int(((rgb[keep] - rgb[i]) ** 2).sum(-1).argmin())]
            m = a & (keyv == vals[i])
            rgba[m, :3] = rgb[j]
    ys, xs = np.nonzero(border)
    margin = min(int(xs.min()), int(ys.min()), int(N - 1 - xs.max()), int(N - 1 - ys.max()))
    cols = len({tuple(p) for p in rgba[a][:, :3]})
    os.makedirs(os.path.dirname(path), exist_ok=True)
    Image.fromarray(rgba, 'RGBA').save(path, optimize=True)
    return {'colours': cols, 'margin': margin}


PALS = [calabash_cup, drum_tap, yam_nub, shellstep, canopy_loop, parrot_pennant]

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
