"""Puzzle Pals: CONDOR'S CRAG (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-cnd-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_cnd.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair + palib parts (building blocks only). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-condors-crag.png, calmed by brightness onto 2 tones of ONE colour family per pal (no two share a body tone):
  1 Crag Quill        condor-head bronze      | a cream quill-spear with a gold nib, held up    | brave: brows set, toothy grin, side look
  2 Ledge Feather     high-sky blue, tilted   | aviator goggles on its brow, wind streaks       | gleeful: wide eyes back over its shoulder, open grin
  3 Updraft Fluff     cloud white, fluffy top | a brass spyglass at one eye                     | squinting: one eye shut, tongue-tip smile
  4 Talon Clutch      crag grey + gold cracks | four curled talons gripping its bottom edge     | straining grumpy: heavy brows, clenched teeth
  5 Nest Wobble       mountain-mist periwinkle, tilted the other way | twig nest + speckled egg | worried shy: brows up, wobbly mouth, blush
  6 Grand Condor Plume  condor slate (rare)  | whimsy condor: spread fingered wings, cream bars, red head, gold plume crest | smug: half lids, beak
Hook blanks small (r <= 3); no ash puffs; browns lifted; the rare's wings carry cream bars + finger tips so they read as wings, not leaves.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-condors-crag'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-condors-crag-c1d06d')

BRONZE = ('#bb5427', '#d9885a')
SKY = ('#5aa0d4', '#82c0e4')
CLOUD = ('#d6e2ec', '#f4f8fa')
CRAG = ('#8b8f96', '#a9adb4')
MIST = ('#6c80ac', '#8ea2c8')
SLATE = ('#5a5470', '#6e6886')
CRACK = '#fbe8a8'
TWIG = ('#a8703e', '#7a4a2a', '#d9a066', '#5a341e')
BRASS = ('#e8a317', '#b07a10', '#fbe8a8', '#7a5210')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, list(tones))


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def shear(m, k, cy):
    """Lean a mask: row y moves k * (y - cy) px sideways (a tilt pose without rotation blur)."""
    o = blank()
    for y in range(N):
        dx = int(round(k * (y - cy)))
        o[y] = shift(m, dx, 0)[y]
    return o


def brows(st, l, r, col=UMBER):
    st.paint(line(l) | line(r), col)


def quill_spear(st, x0, y0, x1, y1):
    """A cream flight feather on a long quill, its tip capped by a rounded gold nib (it thinks it is a spear)."""
    shaft = line([(x0, y0), (x1, y1)], w=2)
    st.part(shaft, '#d8c496', d=1, contour=True)
    feather(st, x0 + (x1 - x0) * 0.38, y0 + (y1 - y0) * 0.38, L=13, ang=-96, pal=BONE)
    nib = poly([(x1 - 2.5, y1 + 1), (x1 + 0.5, y1 - 5), (x1 + 3.5, y1 + 1)]) | disc(x1 + 0.5, y1 - 4, 1.2)
    st.part(nib, GOLDP[0], d=1, contour=True)
    st.paint(nib & (CX < x1), GOLDP[2])
    return shaft | nib


def goggles(st, y, x0, x1, lx, rx):
    """Aviator goggles pushed up on the brow: a strap band across, two round brass-rimmed lenses with a sky glint."""
    strap = rect(x0, y, x1, y + 1)
    st.paint(strap, '#5a341e')
    st.paint(strap & (YY == y), '#7a4a2a')
    for cx in (lx, rx):
        rim = disc(cx, y + 1, 3.6)
        st.part(rim, BRASS[0], d=1, contour=True, rim=False)
        lens = disc(cx, y + 1, 2.3)
        st.paint(lens, '#2f5a7e')
        st.paint(lens & disc(cx - 0.8, y + 0.2, 1.0), '#eef8fc')


def streaks(st, pts):
    for (x, y, L) in pts:
        st.paint(rect(x, y, x + L - 1, y), '#eef8fc', solid=True)


def fluff_top(x0, x1, y, r=2.4, step=4):
    m = blank()
    x = x0 + r
    while x <= x1 - r + 0.5:
        m |= disc(x, y, r)
        x += step
    return m


def spyglass(st, ex, ey):
    """A brass spyglass held to the eye at (ex, ey), pointing right: dark eyepiece, brass tube with a dark band, wider objective + glass."""
    eyep = rect(ex, ey - 2, ex + 3, ey + 2)
    tube = rect(ex + 4, ey - 2, ex + 10, ey + 2)
    obj = rect(ex + 11, ey - 3, ex + 15, ey + 3)
    st.part(eyep, '#7a4a2a', d=1, contour=True)
    st.part(tube | obj, BRASS[0], d=1, contour=True)
    st.paint(rect(ex + 8, ey - 2, ex + 8, ey + 2) | rect(ex + 11, ey - 3, ex + 11, ey + 3), BRASS[3])
    st.paint((tube | obj) & ((YY == ey - 2) | (YY == ey - 3)), BRASS[2])
    st.paint(rect(ex + 15, ey - 2, ex + 15, ey + 2), '#b8dff0')
    return eyep | tube | obj


def talon(st, x, y, side=1):
    """A curled bone talon gripping down and under from (x, y): 2 px thick hook, cream tip."""
    s = side
    m = line([(x, y), (x + s * 1, y + 3), (x + s * 0.5, y + 5), (x - s * 1.5, y + 6)], w=2)
    st.part(m, BONE[0], d=1, contour=True)
    st.paint(m & (YY >= y + 5), BONE[3])
    return m


def zig(st, pts, col=CRACK, dark='#c98a14'):
    m = line(pts)
    st.paint(shift(m, 1, 1) & ~m, dark)
    st.paint(m, col)
    return m


def nest(st, cx, cy, w=10):
    """A twiggy bowl nest with a speckled cream egg peeking out and two stray twigs."""
    egg = ellipse(cx + 1, cy - 3, 3.6, 4.4)
    st.part(egg, '#f4f8fa', d=1, contour=True)
    st.dots([(int(cx), int(cy - 4)), (int(cx + 2), int(cy - 2))], '#8ea2c8')
    bowl = ellipse(cx, cy + 1, w / 2, 3.2) & (CY > cy - 1)
    st.part(bowl, TWIG[0], d=1, contour=True)
    st.paint(bowl & (((XX * 2 + YY) % 5) == 0), TWIG[3])
    st.paint(bowl & (((XX - YY * 2) % 6) == 0), TWIG[2])
    tw = line([(cx - w / 2 - 2, cy - 2), (cx - w / 2 + 2, cy + 1)]) | line([(cx + w / 2 - 1, cy + 1), (cx + w / 2 + 3, cy - 3)])
    st.paint(tw, TWIG[2], solid=True)
    return bowl | egg | tw


def wobble_marks(st, pts):
    for x, y, s in pts:
        st.paint(line([(x, y), (x + s, y + 2), (x, y + 4)]), '#eef8fc', solid=True)


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


def arc_eye(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y + 1, {'U': UMBER}, solid=False)


# ------------------------------------------------------------------ 1. Crag Quill: corner-TB hook, common. Bronze, holds a quill-spear, brave toothy grin.
def crag_quill():
    key = 'pl-cnd-1'
    st = Sticker()
    core = (17, 22, 47, 49)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'hook', -5, 3.0), e=('B', 'hook', 3, 2.6))
    quill_spear(st, 12, 54, 12, 13)
    st.part(body, tex=fill(key, body, 17, 22, 31, BRONZE), contour=True)
    st.blank_shade(body, holes, width=1)
    st.part(ellipse(16, 38, 3, 2.6), BRONZE[1], d=1, contour=True)      # the stubby arm gripping its quill
    nub_feet(st, [21, 38], 50, '#8a3a1e')
    st.eye(21, 30, look=(1, 0))
    st.eye(33, 30, look=(1, 0))
    brows(st, [(20, 27), (25, 28)], [(33, 28), (38, 27)])
    st.mouth('tooth', 27, 39)
    return key, st


# ------------------------------------------------------------------ 2. Ledge Feather: edge-BTB tri, common. Sky blue, leans into the wind, goggles up, gleeful.
def ledge_feather():
    key = 'pl-cnd-2'
    st = Sticker()
    core = (16, 22, 45, 48)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', 2, 3.6), e=('B', 'tri', 2, 3.2), w=('B', 'tri', 2, 3.2))
    body, holes = shear(body, -0.18, 36), shear(holes, -0.18, 36)
    st.part(body, tex=fill(key, body, 16, 22, 30, SKY), contour=True)
    st.blank_shade(body, holes, width=1)
    goggles(st, 24, 17, 47, 25, 37)
    streaks(st, [(8, 30, 4), (6, 36, 5), (9, 42, 3)])
    nub_feet(st, [18, 36], 49, '#3f6f9f')
    st.eye(22, 31, look=(-1, 0))
    st.eye(34, 31, look=(-1, 0))
    st.mouth('grin', 27, 39)
    return key, st


# ------------------------------------------------------------------ 3. Updraft Fluff: inner-TBTB peg, common. Cloud white with a fluffy crown, a brass spyglass at one eye.
def updraft_fluff():
    key = 'pl-cnd-3'
    st = Sticker()
    core = (14, 25, 43, 48)
    body, holes = piece_blanks(core, n=('T', 'peg', 6, 3.0), e=('B', 'peg', 6, 2.6), s=('T', 'peg', -3, 3.2), w=('B', 'peg', 6, 2.6))
    body |= fluff_top(12, 36, 24.5, 3.4, 6) | disc(13.5, 30, 3.0) | disc(44.5, 29, 2.8)
    body &= ~holes
    st.part(body, tex=fill(key, body, 14, 25, 30, CLOUD), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#8ea2c8', skip=grow(holes, 3))
    st.sprite(['U....', '.UU..', '...UU', '.UU..', 'U....'][::1], 19, 30, {'U': UMBER}, solid=False)   # squeezed-shut eye: >
    spyglass(st, 29, 32)
    st.sprite(['U.....U', '.UUUUU.', '..URR..'], 20, 39, {'U': UMBER, 'R': '#e0707a'}, solid=False)
    st.paint(rect(15, 37, 17, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Talon Clutch: inner-TTTT double, uncommon. Crag grey with gold crag cracks, four talons gripping on.
def talon_clutch():
    key = 'pl-cnd-4'
    st = Sticker()
    core = (18, 22, 45, 46)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 18, 22, 28, CRAG), contour=True)
    face = rect(20, 26, 44, 42)
    for p in ([(19, 45), (23, 42), (26, 45)], [(39, 24), (42, 27), (45, 25)]):
        zig(st, p)
    st.stitch(body, col=CRACK, skip=face)                                # uncommon accent: the crag's gold seams
    for x, s in ((20, -1), (25, 1), (38, -1), (43, 1)):
        talon(st, x, 46, s)
    st.eye(22, 30, look=(0, 1), lid=1)
    st.eye(35, 30, look=(0, 1), lid=1)
    brows(st, [(21, 27), (26, 29)], [(35, 29), (40, 27)])
    st.paint(line([(21, 28), (26, 30)]) | line([(35, 30), (40, 28)]), UMBER)
    st.sprite(['UUUUUUU', 'UCUCUCU', 'UUUUUUU'], 28, 38, {'U': UMBER, 'C': CREAM}, solid=False)
    st.paint(rect(20, 37, 21, 37) | rect(41, 37, 42, 37), '#c87878')
    return key, st


# ------------------------------------------------------------------ 5. Nest Wobble: inner-TTBB hook, uncommon. Mountain-mist periwinkle, a twig nest + egg on its head, wobbling.
def nest_wobble():
    key = 'pl-cnd-5'
    st = Sticker()
    core = (15, 25, 43, 48)
    body, holes = piece_blanks(core, n=('T', 'hook', 3, 3.0), e=('T', 'hook', 3, 3.0), s=('B', 'hook', -5, 2.4), w=('B', 'hook', 6, 2.4))
    body, holes = shear(body, 0.1, 36), shear(holes, 0.1, 36)
    st.part(body, tex=fill(key, body, 15, 25, 29, MIST), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=TWIG[2], skip=grow(holes, 3))                  # uncommon accent: the twig tan
    nest(st, 31, 18, w=15)
    st.eye(20, 31, look=(1, -1))
    st.eye(32, 31, look=(1, -1))
    brows(st, [(20, 28), (24, 27)], [(33, 27), (37, 28)])
    st.sprite(['.U...U.', 'U.U.U.U'], 24, 39, {'U': UMBER}, solid=False)
    st.paint(rect(17, 37, 19, 37) | rect(36, 37, 38, 37), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Grand Condor Plume: whimsy-condor peg, rare. A condor cut as a piece: spread wings, red head, gold plume.
def grand_condor_plume():
    key = 'pl-cnd-6'
    st = Sticker()
    col, row = ROWS[key]['piece']
    # wings: a straight leading edge rising from the shoulder, ragged trailing edge, fingered primaries at the tip (the picture's condor)
    lw = [(26, 30), (17, 24), (11, 22), (10, 25), (12, 26), (10, 28), (12, 29), (10, 31), (13, 32), (12, 34), (15, 34),
          (16, 36), (19, 35), (20, 38), (23, 37), (26, 40)]
    wl = poly(lw)
    wr = poly([(64 - x, y) for x, y in lw])
    torso = ellipse(32, 38, 8, 10)
    tail = knob('s', 'peg', 32, 47.5, r=2.8)
    feet = rect(27, 47, 28, 48) | rect(35, 47, 36, 48)
    body = wl | wr | torso | tail
    src = pic.sample(col, row, 10, 22, 44).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(SLATE[0])
    tex[src > 360] = hx(SLATE[1])
    tex = majority(tex, body, 3)
    st.part(body, tex=tex, contour=True)
    for w in (wl, wr):                                                   # the cream wing bars, the condor's mark
        bar = w & (CY > 27 + (np.abs(CX - 32) - 9) * -0.35) & (CY < 31 + (np.abs(CX - 32) - 9) * -0.35) & (np.abs(CX - 32) > 9) & (np.abs(CX - 32) < 19)
        st.paint(bar, '#f2e4c0')
        st.paint(bar & ~shift(bar, 0, -1), '#d8c496')
    st.paint(feet, GOLDP[0], solid=True)
    st.stitch(torso, col='#fff3c8')
    ruff = ellipse(32, 29.5, 7.5, 3.2)
    st.part(ruff, '#f4f8fa', d=1, contour=True)
    st.paint(ruff & (CY > 31), '#d6e2ec')
    feather(st, 35, 16, L=8, ang=-50, pal=GOLDP)                        # the floating plume, worn as a crest
    head = ellipse(32, 21, 6.8, 6.2)
    st.part(head, '#c8603a', d=1, contour=True)
    st.paint(head & ellipse(32, 24, 4.5, 3), '#d9885a')
    st.eye(26, 18, look=(1, 0), lid=1, socket=None)
    st.eye(33, 18, look=(1, 0), lid=1, socket=None)
    st.paint(line([(33, 16), (36, 15), (38, 16)]), UMBER)               # one smug raised brow
    st.part(ellipse(29, 15.5, 2.4, 2.2), '#821e23', d=1, contour=True)          # the condor's red comb
    beak = poly([(29.5, 23), (34.5, 23), (34.5, 26), (33, 28.5), (31.5, 27), (29.5, 25)])
    st.part(beak, '#f2e4c0', d=1, contour=True)                                    # hooked cream beak
    st.paint(rect(33, 27, 33, 28), '#6a4a2a')
    st.paint(rect(24, 24, 25, 24) | rect(38, 24, 39, 24), BLUSH)
    st.sparkle(9, 12)
    st.sparkle(50, 10, big=False)
    st.sparkle(51, 50, big=False)
    return key, st


PALS = [crag_quill, ledge_feather, updraft_fluff, talon_clutch, nest_wobble, grand_condor_plume]

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
        print('%-10s %-19s %-9s %-13s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
