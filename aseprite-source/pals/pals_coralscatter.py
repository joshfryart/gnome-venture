"""Puzzle Pals: THE CORALSCATTER roster (6 pals) -> game/assets/img/puzzles/pals/<key>.png (64 x 64, transparent, hard pixels).
Usage: python3 -B aseprite-source/pals/pals_coralscatter.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Same approach as pals_maplewold.py / pals_sunsprinkle.py: silhouette = the row's shape + knob (game/includes/data/puzzle_pals.txt), body = its
own cell of game/assets/img/jigsaw/coralscatter.jpg (12 x 8 grid, 150 px cells) snapped to the picture's palette and calmed to ~4 colours,
palib house finish. One accessory each from the picture's motifs (snorkel mask, octopus tentacles, anemone + clownfish, crab-claw sail,
glowworm jar, flower lei on the sea turtle). Picture palette (jigsaw_coralscatter.py): coral #ef6f78, aqua #4cc7c4, lava #f27a2a, navy #22305a.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
pic = Pic('coralscatter')
ROWS = {}
for l in open(os.path.join(ROOT, 'game', 'includes', 'data', 'puzzle_pals.txt'), encoding='utf-8'):
    c = l.rstrip('\n').split('|')
    if not l.startswith('#') and len(c) == 14 and c[0] == 'coralscatter':
        ROWS[c[1]] = {'rarity': c[3], 'piece': tuple(int(v) for v in c[9].split('-')), 'shape': c[10], 'knob': c[11]}

CORAL, CORAL_D, CORAL_L = '#ef6f78', '#bf4560', '#ffa6a0'
LAVA, LAVA_D, LAVA_L = '#f27a2a', '#c2481e', '#ffc94a'
AQUA, AQUA_D, AQUA_L = '#4cc7c4', '#2a9aa8', '#9ee8de'
VOLC, VOLC_L = '#5a3a56', '#7e5674'
SKIN, SKIN_D, SKIN_L = '#5cb07a', '#3f9a5e', '#9acc6a'
YEL, YEL_D = '#f2c43a', '#c9921a'
ANEM, ANEM_D, ANEM_L = '#f08ac0', '#c87a9a', '#f0b0c8'
WHITE = '#f2ecd8'
WOOD = '#a0663a'
RED = '#d6322b'


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


def feet(st, xs, y, w=6, h=4):
    for x in xs:
        shoe = rect(x, y, x + w - 1, y + h - 1)
        shoe[y, x] = shoe[y, x + w - 1] = False
        st.part(shoe, SHOE[0], d=1, contour=True)


# ------------------------------------------------------------------ 1. Snorkel Snip: corner-BB round, common. Flat foot and back, blanks top and right, a coral snorkel mask + yellow tube.
def snorkel_snip():
    key = 'cs-snorkel-snip'
    st = Sticker()
    core = (13, 20, 47, 49)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'round', 6), e=('B', 'round', 6))
    st.part(body, tex=body_fill(key, body, 13, 20, 35, k=3, passes=3))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [16, 34], 50)
    # snorkel tube up the left side (behind), bending into the mask
    tube = rect(8, 11, 10, 31) | rect(8, 29, 15, 31)
    st.part(tube, YEL, d=1, contour=True)
    st.paint(rect(8, 11, 10, 13), RED, solid=True)
    # mask: coral frame, aqua glass, strap to the back
    st.paint(rect(36, 30, 47, 31) & body & ~grow(holes, 1), CORAL_D)
    frame = rect(14, 25, 35, 36)
    frame[25, 14] = frame[25, 35] = frame[36, 14] = frame[36, 35] = False
    st.part(frame, CORAL, d=1, contour=True)
    st.paint(rect(16, 27, 33, 34), AQUA_L)
    st.paint(rect(16, 27, 33, 27), '#c8f4ee')
    st.paint(rect(24, 27, 25, 34), CORAL)
    st.eye(17, 28, look=(1, 0), socket=None)
    st.eye(27, 28, look=(1, 0), socket=None)
    st.mouth('grin', 22, 40)
    return key, st


# ------------------------------------------------------------------ 2. Octo Ogle: edge-TTB peg, common. Flat underside, tabs left and top, blank right; four curly pink tentacles.
def octo_ogle():
    key = 'cs-octo-ogle'
    st = Sticker()
    core = (14, 20, 46, 44)
    body, holes = piece_blanks(core, s='F', w=('T', 'peg', 2), n=('T', 'peg', -4), e=('B', 'peg', 5))
    st.part(body, tex=body_fill(key, body, 14, 20, 33, k=3, passes=5, dx=0.1))
    st.blank_shade(body, holes)
    st.stitch(body, skip=grow(holes, 3))
    # tentacles: four stalks, each curling outward at the toe, sucker dots
    for x, d in ((15, -1), (23, -1), (32, 1), (40, 1)):
        t = rect(x, 44, x + 4, 50) | rect(x + (2 if d > 0 else -2), 50, x + 4 + (2 if d > 0 else -2), 53)
        tip = (x + 6, 52) if d > 0 else (x - 2, 52)
        t[53, x + 4 + 2 if d > 0 else x - 2] = False
        st.part(t, CORAL, d=1, contour=True)
        st.dots([(x + 2, 46), (x + 2, 48), tip if False else (x + 2 + d, 51)], CORAL_L)
    st.eye(18, 26, look=(1, -1))
    st.eye(30, 26, look=(1, -1))
    st.mouth('o', 25, 35)
    return key, st


# ------------------------------------------------------------------ 3. Anemone Nudge: inner-TBTB double, common. Tabs top and bottom, blanks either side; anemone tuft hat, a clownfish.
def anemone_nudge():
    key = 'cs-anemone-nudge'
    st = Sticker()
    core = (16, 22, 46, 46)
    body, holes = piece_blanks(core, n=('T', 'double'), s=('T', 'double'), e=('B', 'double', 3, 3.3), w=('B', 'double', 3, 3.3))
    t = body_fill(key, body, 16, 22, 31, k=3, passes=5, dy=0.3, swap={'#f27a2a': '#e8c48a', '#ffc94a': '#fbe4b0'})   # calm the orange coral: sand reads under a face
    st.part(body, tex=t)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, skip=grow(holes, 3))
    feet(st, [18, 39], 47)
    # anemone tuft on the top knob: fat tendrils with pale tips
    tuft = blank()
    for i, x in enumerate((22, 26, 30, 34, 38)):
        h = 9 if i in (1, 3) else (11 if i == 2 else 7)
        tuft |= rect(x, 19 - h, x + 2, 20)
    tuft |= ellipse(31.5, 19.5, 11, 3)
    st.part(tuft, ANEM, d=1, contour=True)
    for i, x in enumerate((22, 26, 30, 34, 38)):
        h = 9 if i in (1, 3) else (11 if i == 2 else 7)
        st.paint(rect(x, 19 - h, x + 2, 20 - h), ANEM_L)
    # clownfish nosing in from the upper right
    fish = ellipse(48, 12, 5, 3.2) | poly([(52, 12), (56, 8), (56, 16)])
    st.part(fish, LAVA, d=1, contour=True)
    st.paint(fish & rect(47, 0, 48, 20), WHITE)
    st.paint(fish & rect(52, 0, 52, 20), WHITE)
    st.dots([(45, 11)], UMBER)
    st.eye(20, 28, look=(1, -1))
    st.eye(33, 28, look=(1, -1))
    st.mouth('smile', 26, 37)
    return key, st


# ------------------------------------------------------------------ 4. Claw Sail: inner-TTTT tri, uncommon. Plus of arrows, a striped crab-claw sail on a mast; lava stitch accent.
def claw_sail():
    key = 'cs-claw-sail'
    st = Sticker()
    core = (15, 21, 42, 46)
    body = piece(core, n=('T', 'tri', -2), e=('T', 'tri'), s=('T', 'tri'), w=('T', 'tri'))
    t = body_fill(key, body, 15, 21, 28, k=3, passes=5, dy=-0.25, swap={'#f27a2a': '#ef6f78'})   # the sail's stripes, calmed to coral + weave
    st.part(body, tex=t)
    st.stitch(body, col=LAVA)
    # mast + crab-claw sail (two horns, concave top) off the top right
    st.part(rect(40, 9, 41, 23), WOOD, d=0, contour=True)
    sail = poly([(41, 23), (36, 6), (44, 11), (55, 8)]) & ~ellipse(46, 5.5, 5.5, 4)
    st.part(sail, LAVA, d=2, contour=True)
    stripes = sail & shrink(sail, 1) & (((XX - YY // 2) % 6) < 2)
    st.paint(stripes, LAVA_L)
    st.eye(18, 28, look=(1, 0))
    st.eye(30, 28, look=(1, 0))
    st.mouth('grin', 24, 37)
    return key, st


# ------------------------------------------------------------------ 5. Grotto Glim: inner-BBBB keyhole, uncommon. The Ring: four blanks, cave-dark fill lifted to volcano purple, a glowworm jar; aqua stitch.
def grotto_glim():
    key = 'cs-grotto-glim'
    st = Sticker()
    core = (10, 12, 50, 50)
    body, holes = piece_blanks(core, n=('B', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.6), s=('B', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.6))
    t = body_fill(key, body, 10, 12, 41, k=3, passes=3, dx=0.1)
    t = lift(t, body, VOLC_L, thr=230)
    st.part(body, tex=t)
    st.blank_shade(body, holes)
    st.stitch(body, col=AQUA, skip=grow(holes, 3))
    # glowworm specks in the fill (the grotto), kept off the face
    st.dots([(16, 17), (42, 16), (15, 41), (37, 44), (45, 23)], AQUA_L)
    # jar of glowworms on the lower right corner
    jar = rect(40, 41, 51, 53)
    jar[41, 40] = jar[41, 51] = jar[53, 40] = jar[53, 51] = False
    st.part(jar, AQUA, d=2, contour=True)
    st.part(rect(41, 38, 50, 40), WOOD, d=1, contour=True)
    st.dots([(43, 45), (47, 44), (45, 48), (49, 49), (43, 51)], '#e8f2f6')
    st.paint(rect(42, 43, 42, 47), '#c8f4ee')
    st.eye(20, 24, look=(1, -1))
    st.eye(33, 24, look=(1, -1))
    muz = rect(27, 32, 31, 36)
    muz[32, 27] = muz[32, 31] = muz[36, 27] = muz[36, 31] = False
    st.paint(muz, '#a898bc')   # a pale muzzle so the ooh reads on the cave dark
    st.mouth('o', 28, 33)
    return key, st


# ------------------------------------------------------------------ 6. Keel Drift: whimsy-turtle hook, rare. Sea turtle seen from above: shell = its cell, flippers, hook tail, a lei; wink, glow + sparkles.
def keel_drift():
    key = 'cs-keel-drift'
    st = Sticker()
    shell = ellipse(32, 35, 16.5, 12.5)
    tail = knob('s', 'hook', 33, 46.5, r=2.9, nw=2.0)
    # flippers behind the shell: big front pair swept forward, small rear pair
    fl = poly([(19, 28), (12, 20), (10, 24), (14, 31), (18, 35)]) | poly([(45, 28), (52, 20), (54, 24), (50, 31), (46, 35)])
    rl = ellipse(19, 45, 5, 3.2) | ellipse(45, 45, 5, 3.2)
    st.part(fl | rl, SKIN, d=2, contour=True)
    st.part(tail, SKIN, d=1, contour=True)
    head = ellipse(32, 16, 9.5, 7.5)
    ts = body_fill(key, shell, 15, 22, 34, k=3, passes=3, dx=-0.57, dy=0.16)
    ts = remap(ts, shell, {c: '#9a6a3f' for c in ('#4cc7c4', '#2a9aa8', '#9ee8de', '#3fb4bc', '#2a92a8', '#bff0ea', '#c8f4ee', '#76dcd2')})   # water at the rim -> shell
    st.part(shell, tex=ts, contour=True)
    # scutes: a ring and spokes in the shell's own deep tone
    sc = shrink(shell, 4) & ~shrink(shell, 5)
    st.paint(sc, '#6a4428')
    for a, b in (((32, 26), (32, 30)), ((32, 42), (32, 46)), ((19, 36), (23, 36)), ((41, 36), (45, 36))):
        st.paint(line([a, b]) & shrink(shell, 2), '#6a4428')
    st.stitch(shell)
    st.part(head, SKIN, d=2, contour=True)
    # lei: a band of coral and yellow blossoms where the neck meets the shell
    lei = ellipse(32, 23.5, 10, 2.6)
    st.part(lei, CORAL, d=1, contour=True)
    st.paint(lei & ((XX % 4) == 0), YEL)
    st.eye(25, 13, look=(0, 1), socket=None)
    st.sprite(['.....', 'U...U', '.UUU.'], 34, 14, {'U': UMBER}, solid=False)   # the slow wink: a closed eye
    st.mouth('smile', 30, 19)
    st.sparkle(51, 6)
    st.sparkle(9, 9, big=False)
    st.sparkle(54, 38, big=False)
    return key, st


PALS = [snorkel_snip, octo_ogle, anemone_nudge, claw_sail, grotto_glim, keel_drift]

if __name__ == '__main__':
    print('dominant', pic.dominant(4))
    paths = []
    for fn in PALS:
        key, st = fn()
        assert key in ROWS, key
        tidy(st, 34)
        p = os.path.join(OUTDIR, key + '.png')
        info = st.save(p, glow=(ROWS[key]['rarity'] == 'rare'))
        paths.append(p)
        print('%-20s %-9s %-11s %-8s colours %d margin %d' % (key, ROWS[key]['rarity'], ROWS[key]['shape'], ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] >= 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
