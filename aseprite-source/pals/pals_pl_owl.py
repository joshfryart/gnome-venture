"""Puzzle Pals: DEN OF THE GREAT WHITE OWL (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-owl-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_owl.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair + palib parts (building blocks only). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-den-of-the-great-white-owl.png, calmed by brightness onto 2 tones of ONE colour family per pal:
  1 Pinfeather Hush      owl-chest brown, tilted   | a cream pinfeather tucked behind, a paw raised "shh"   | shy hush: closed arcs, pursed o, blush
  2 Nightglow Fleck      aurora teal-green         | a crescent moon worn as a tipped hat, glow flecks       | cheeky: wink, tongue-out grin
  3 Aurora Thread        aurora lilac              | a green + pink thread scarf streaming off in a wave     | startled: dot eyes, brows up, open oval
  4 Owlet Peep           den-night indigo          | ear tufts, cream chevron bib, gold talons, a pinecone   | bored-sleepy: gold owl eyes half shut, beak
  5 Snowcrag Halo        crag grey + snow cap      | an aurora halo ring floating over a snowy cap          | grumpy: low brows, side eyes, wobbly pout
  6 Great White Plumelet warm owl white (rare)     | whimsy feather: curved vane, split barbs, gold quill, aurora-dipped tip | proud: big bright eyes, grin
Hook blanks small (r <= 3); browns lifted; no puffs; the rare's split barbs + rachis make it read as a feather, not a leaf.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-den-of-the-great-white-owl'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-den-of-the-great-white-owl-34dfad')

OWLBR = ('#9a6450', '#b77c5e')         # owl chest brown, lifted off mud
TEAL = ('#2f9282', '#43b496')          # aurora green
LILAC = ('#a274c0', '#bf90d0')         # aurora purple
NIGHT = ('#4c48a2', '#5e5abc')         # den indigo, lifted
CRAG = ('#7e848e', '#989ea8')          # crag rock grey
WHITE = ('#e4ddd0', '#f4f0e8')         # owl white
AUR_G, AUR_P, AUR_K = '#3aa88a', '#b784c8', '#e8a0d8'
MOON = ('#fff1c8', '#e8cf8a', '#ffffff', '#b8964a')
SNOW = ('#eef3f8', '#c4d0e0', '#ffffff', '#8a9ab4')
CONE = ('#9a6a40', '#6a4428', '#c89a64', '#4a2c1a')
OWLGOLD = ('#f5b840', '#e08a24', '#fde08a', '#a8601a')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, list(tones))


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def shear(m, k, cy):
    """Lean a mask: row y moves k * (y - cy) px sideways (a tilt without rotation blur)."""
    o = blank()
    for y in range(N):
        o[y] = shift(m, int(round(k * (y - cy))), 0)[y]
    return o


def arc_eye(st, x, y, up=True):
    """Closed eye as a 5 px arc: up = happy ^ , else a soft downward lash."""
    st.sprite(['.UUU.', 'U...U'] if up else ['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def wink(st, x, y):
    st.sprite(['UU...', '..UUU', 'UU...'], x, y, {'U': UMBER}, solid=False)


def dot_eye(st, x, y):
    """Startled eye: cream 5 x 6 oval, one 2 x 2 pupil, no glint."""
    st.sprite(['.UUU.', 'UCCCU', 'UCPCU', 'UCPCU', 'UCCCU', '.UUU.'], x - 1, y - 1, {'U': UMBER2, 'C': CREAM, 'P': UMBER}, solid=False)
    st.dots([(x + 2, y + 2)], UMBER)


def owl_eye(st, x, y, lid=0):
    """Owl eye: 7 x 7 gold disc in an umber ring, round umber pupil, cream glint; lid rows of night indigo from the top."""
    ring = disc(x + 3.5, y + 3.5, 4.4)
    iris = disc(x + 3.5, y + 3.5, 3.3)
    st.paint(ring, UMBER2)
    st.paint(iris, OWLGOLD[0])
    st.paint(iris & ~disc(x + 3.0, y + 3.0, 3.0), OWLGOLD[1])
    st.paint(disc(x + 3.5, y + 3.5, 1.6), UMBER)
    st.dots([(x + 2, y + 2)], CREAM)
    if lid:
        lm = ring & (YY < y + lid)
        st.paint(lm, '#3a3680')
        st.paint(ring & (YY == y + lid - 1), UMBER)


def beak(st, x, y):
    st.sprite(['GGG', 'DGD', '.D.'], x, y, {'G': OWLGOLD[2], 'D': OWLGOLD[1]}, solid=False)


def hush_paw(st, x, y, col):
    """A stubby paw raised beside the mouth, one finger up: shh."""
    paw = ellipse(x + 2, y + 3, 2.6, 2.4) | rect(x + 1, y - 2, x + 2, y + 1)
    st.part(paw, col, d=1, contour=True)
    return paw


def crescent(st, cx, cy, r=5.0, dx=2.2, dy=-1.4, pal=MOON):
    m = disc(cx, cy, r) & ~disc(cx + dx, cy + dy, r * 0.82)
    st.part(m, pal[0], d=1, contour=True)
    st.paint(m & ~shift(m, 1, 1) & shrink(m, 0), pal[2])
    return m


def flecks(st, pts, col=MOON[0]):
    for x, y in pts:
        st.paint(rect(x, y, x, y) | rect(x + 1, y, x + 1, y), col, solid=True)


def thread(st, pts, cols=(AUR_G, AUR_K)):
    """A 2 px aurora thread: two strands, green over pink, frayed ends."""
    a = line(pts, w=2)
    st.part(a, cols[0], d=0, contour=True)
    st.paint(a & ~shift(a, 0, -1), cols[1])
    return a


def pinfeather(st, x, y, L=18, ang=-118):
    """kit feather, retinted to soft owl tan, with dark brown bars across the vane (owl barring) and a pale quill."""
    m = feather(st, x, y, L=L, ang=ang, pal=('#e2c49c', '#b08660', '#f6e4c4', '#7a5238'))
    st.paint(line([(x, y), (x + math.cos(math.radians(ang)) * L * 0.9, y + math.sin(math.radians(ang)) * L * 0.9)]) & shrink(m, 1), '#7a5238')
    a = math.radians(ang)
    for t in (0.42, 0.62, 0.82):
        bx, by = x + math.cos(a) * L * t, y + math.sin(a) * L * t
        px_, py_ = -math.sin(a), math.cos(a)
        st.paint(line([(bx + px_ * 4, by + py_ * 4 + 1), (bx - px_ * 4, by - py_ * 4)]) & shrink(m, 1), '#8a5a3a')
    return m


def thread_scarf(st, x0, x1, y):
    """An aurora thread scarf: a 3 px knitted band round the neck (green, pink stripes) + a long wavy tail streaming right."""
    band = rect(x0, y, x1, y + 2)
    tail = line([(x1 - 3, y + 1), (x1 + 2, y - 1), (x1 + 5, y - 4), (x1 + 8, y - 4), (x1 + 10, y - 7)], w=3)
    m = band | tail
    st.part(m, AUR_G, d=1, contour=True)
    st.paint(m & ((XX + YY) % 4 == 0), AUR_K)
    st.paint(band & (YY == y), '#7ad8b4')
    st.paint(rect(x1 + 9, y - 10, x1 + 9, y - 9) | rect(x1 + 11, y - 9, x1 + 11, y - 8), AUR_K, solid=True)
    return m


def chevron_bib(st, cx, y, w=7, h=7):
    m = ellipse(cx, y + h / 2, w, h / 2)
    st.paint(m, '#f1ece0')
    for k in range(3):
        for i, xo in enumerate((-4, 0, 4)):
            yy = y + 2 + k * 2 + (i % 2)
            if m[yy, int(cx + xo)]:
                st.sprite(['U.U', '.U.'], int(cx + xo) - 1, yy, {'U': '#a8a8b8'}, solid=False)
    return m


def talons(st, xs, y):
    for x in xs:
        st.sprite(['.GGG.', 'G.G.G'], x, y, {'G': OWLGOLD[0]}, solid=True)
        st.dots([(x + 2, y)], OWLGOLD[1])


def ear_tuft(st, x, y, side):
    m = poly([(x, y + 4), (x + side * 2.5, y - 4), (x + side * 6, y + 4)])
    st.part(m, NIGHT[1], d=1, contour=True)
    st.paint(m & shrink(m, 1) & (YY < y + 1), '#8e8ad8')
    return m


def pinecone(st, cx, cy):
    m = ellipse(cx, cy, 3.6, 4.8)
    st.part(m, CONE[0], d=1, contour=True)
    scales(st, m & shrink(m, 1), CONE, step=3)
    st.paint(rect(int(cx), int(cy - 6), int(cx), int(cy - 5)), '#3a6a4a', solid=True)
    return m


def snow_cap(st, x0, x1, y, drips):
    m = ellipse((x0 + x1) / 2, y, (x1 - x0) / 2, 4.0) & (CY > y - 4)
    m = m & (CY < y + 3)
    for dx, h in drips:
        m |= rect(x0 + dx, y + 2, x0 + dx + 2, y + 2 + h) | disc(x0 + dx + 1.5, y + 3 + h, 1.6)
    st.part(m, SNOW[0], d=1, contour=True)
    st.paint(m & ~shift(m, 0, -1) & (CY > y), SNOW[1])
    return m


def halo(st, cx, cy, rx=9.0, ry=2.6):
    o = ellipse(cx, cy, rx, ry) & ~ellipse(cx, cy, rx - 1.9, ry - 1.3)
    st.paint(o, AUR_G, solid=True)
    st.paint(o & (CY < cy), '#7ad8b4')
    st.paint(o & (CX > cx + rx * 0.45), AUR_K)
    return o


def brows(st, l, r, col=UMBER):
    st.paint(line(l) | line(r), col)


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


# ------------------------------------------------------------------ 1. Pinfeather Hush: corner-TT peg, common.
def pinfeather_hush():
    key = 'pl-owl-1'
    st = Sticker()
    core = (13, 24, 43, 49)
    pinfeather(st, 21, 27, L=22, ang=-108)                           # a barred pinfeather tucked behind, poking up
    body = piece(core, s='F', w='F', n=('T', 'peg', 6, 3.4), e=('T', 'peg', 2, 3.6))
    body = shear(body, -0.2, 37)
    st.part(body, tex=fill(key, body, 12, 23, 33, OWLBR), contour=True)
    st.stitch(body, col='#f1ece0')
    nub_feet(st, [15, 33], 49, '#6a4a3a')
    arc_eye(st, 17, 32, up=False)
    arc_eye(st, 29, 32, up=False)
    st.paint(rect(16, 36, 18, 36) | rect(32, 36, 34, 36), BLUSH)
    st.sprite(['.U.', 'URU', '.U.'], 23, 38, {'U': UMBER, 'R': MOUTH_RED}, solid=False)   # pursed little o
    hush_paw(st, 27, 37, '#d0987a')
    return key, st


# ------------------------------------------------------------------ 2. Nightglow Fleck: edge-BTB hook, common.
def nightglow_fleck():
    key = 'pl-owl-2'
    st = Sticker()
    core = (14, 24, 46, 50)
    body, holes = piece_blanks(core, s='F', w=('B', 'hook', 2, 2.6), n=('T', 'hook', -5, 3.2), e=('B', 'hook', 3, 2.6))
    st.part(body, tex=fill(key, body, 14, 24, 32, TEAL), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#bdf0d8', skip=grow(holes, 3))
    crescent(st, 36, 19, r=5.5)                                      # a moon fleck worn like a tipped hat
    flecks(st, [(10, 14), (48, 9), (53, 22), (8, 25)])
    st.part(rect(17, 51, 22, 54) & ~rect(17, 51, 17, 51) & ~rect(22, 51, 22, 51), SHOE[0], d=1, contour=True)
    st.part(rect(37, 51, 42, 54) & ~rect(37, 51, 37, 51) & ~rect(42, 51, 42, 51), SHOE[0], d=1, contour=True)
    wink(st, 19, 32)
    st.eye(32, 31, look=(-1, 0))
    st.sprite(['U.....U', '.UUUUU.', '..UPPU.', '...PP..'], 22, 40, {'U': UMBER, 'P': '#f07a8a'}, solid=False)
    return key, st


# ------------------------------------------------------------------ 3. Aurora Thread: inner-TBTB tri, common.
def aurora_thread():
    key = 'pl-owl-3'
    st = Sticker()
    core = (16, 22, 42, 46)
    body, holes = piece_blanks(core, n=('T', 'tri', 3, 3.6), e=('B', 'tri', 0, 3.0), s=('T', 'tri', -3, 3.4), w=('B', 'tri', 2, 3.0))
    st.part(body, tex=fill(key, body, 16, 22, 27, LILAC), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f2e0f6', skip=grow(holes, 3))
    thread_scarf(st, 15, 43, 39)
    dot_eye(st, 20, 28)
    dot_eye(st, 33, 28)
    brows(st, [(19, 24), (24, 23)], [(33, 23), (38, 24)])
    st.sprite(['.UU.', 'URRU', 'URRU', '.UU.'], 27, 34, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.sprite(['C', 'C'], 41, 26, {'C': '#a9d6ea'}, solid=False)                  # a sweat drop
    return key, st


# ------------------------------------------------------------------ 4. Owlet Peep: inner-TTTT double, uncommon.
def owlet_peep():
    key = 'pl-owl-4'
    st = Sticker()
    core = (16, 22, 44, 46)
    ear_tuft(st, 16, 21, 1)
    ear_tuft(st, 44, 21, -1)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 2), s=('T', 'double', 0, 3.4), w=('T', 'double', 2))
    st.part(body, tex=fill(key, body, 16, 22, 29, NIGHT), contour=True)
    st.stitch(body, col=AUR_G)                                       # uncommon accent: the aurora green
    chevron_bib(st, 30, 36, w=7, h=8)
    owl_eye(st, 19, 26, lid=3)
    owl_eye(st, 33, 26, lid=3)
    beak(st, 29, 32)
    pinecone(st, 49, 40)
    talons(st, [22, 33], 55)
    st.sprite(['GG', 'G.', 'GG'], 8, 14, {'G': GOLD_L}, solid=False)            # a bored little "peep" mark
    st.extra[14:17, 8:10] |= np.array([[1, 1], [1, 0], [1, 1]], bool)
    st.dots([(11, 16)], GOLD_L)
    st.extra[16, 11] = True
    return key, st


# ------------------------------------------------------------------ 5. Snowcrag Halo: inner-BBBB peg, uncommon.
def snowcrag_halo():
    key = 'pl-owl-5'
    st = Sticker()
    core = (12, 20, 48, 51)
    body, holes = piece_blanks(core, n=('B', 'peg', 5, 3.0), e=('B', 'peg', 3, 3.2), s=('B', 'peg', -3, 3.2), w=('B', 'peg', 3, 3.2))
    st.part(body, tex=fill(key, body, 12, 20, 37, CRAG), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=AUR_K, skip=grow(holes, 3))                 # uncommon accent: aurora pink
    snow_cap(st, 11, 49, 21, [(3, 2), (24, 3), (33, 1)])
    st.paint(rect(32, 22, 37, 25) & body, CRAG[0])                  # the peg blank stays a cut under the snow
    halo(st, 27, 11, rx=10, ry=2.8)
    st.eye(18, 33, look=(1, 0), lid=1)
    st.eye(32, 33, look=(1, 0), lid=1)
    brows(st, [(17, 29), (22, 31)], [(32, 31), (37, 29)])
    st.sprite(['.UUU.', 'U...U'], 25, 42, {'U': UMBER}, solid=False)               # pout
    st.paint(rect(26, 43, 28, 43), '#5e2a2a')
    return key, st


# ------------------------------------------------------------------ 6. Great White Plumelet: whimsy-feather hook, rare.
def feather_mask(x0, y0, x1, y1, W=12.0, bend=5.0):
    """A flight feather from quill end (x0, y0) to tip (x1, y1): curved vane, rounded tip, wider on the right, barb splits on both edges."""
    L = ((x1 - x0) ** 2 + (y1 - y0) ** 2) ** 0.5
    ux, uy = (x1 - x0) / L, (y1 - y0) / L
    px, py = -uy, ux
    left, right, spine = [], [], []
    for t in np.linspace(0, 1, 24):
        b = bend * math.sin(math.pi * t)
        sx, sy = x0 + ux * L * t + px * b, y0 + uy * L * t + py * b
        spine.append((sx, sy))
        if t < 0.16:
            wl = wr = 1.0
        else:
            s_ = (t - 0.16) / 0.84
            f = math.sin(math.pi * min(1.0, 0.12 + 0.88 * s_ ** 0.8)) ** 0.6
            wl, wr = W * 0.8 * f, W * f
        left.append((sx + px * wl, sy + py * wl))
        right.append((sx - px * wr, sy - py * wr))
    m = poly(left + right[::-1])
    for side, pts, idx in ((1, left, (10, 16)), (-1, right, (13,))):
        for i in idx:
            sx, sy = spine[i]
            ex, ey = pts[i]
            # a V split: from the edge, slanting back toward the quill, 60 % of the way to the rachis
            cut = poly([(ex + side * px * 2 + ux * 1.6, ey + side * py * 2 + uy * 1.6), (ex - ux * 2.6 + side * px * 2, ey - uy * 2.6 + side * py * 2),
                        (sx + (ex - sx) * 0.4 - ux * 2.0, sy + (ey - sy) * 0.4 - uy * 2.0)])
            m &= ~cut
    return m, spine, (ux, uy, px, py, L)


def great_white_plumelet():
    key = 'pl-owl-6'
    st = Sticker()
    col, row = ROWS[key]['piece']
    x0, y0, x1, y1 = 17, 53, 46, 9
    vane, spine, (ux, uy, px, py, L) = feather_mask(x0, y0, x1, y1, W=13.5, bend=4.0)
    tab = knob('e', 'hook', 34, 47, r=2.8)
    body = vane | tab
    t = cell_fill(pic, (col, row), body, 12, 8, 44, 3, 3)
    st.part(body, tex=calm_tones(t, body, list(WHITE)), contour=True)
    d = ((CX - x0) * (x1 - x0) + (CY - y0) * (y1 - y0)) / L / L
    face = rect(21, 23, 44, 40)
    inner = shrink(body, 1)
    # soft barbs: faint slanted lines from the rachis out, off the face
    for k in (5, 8, 19):
        sx, sy = spine[k]
        for sd in (1, -1):
            br = line([(sx + sd * px * 3, sy + sd * py * 3), (sx + sd * px * 9 - ux * 4, sy + sd * py * 9 - uy * 4)]) & shrink(body, 2) & ~face
            st.paint(br, '#d6cdbc')
    # dipped in aurora light: the tip bands green -> lilac -> pink, a cream lit edge
    tip = inner & (d > 0.74)
    st.paint(tip, '#7ad8b4')
    st.paint(tip & (d > 0.79), AUR_G)
    st.paint(tip & (d > 0.87), AUR_P)
    st.paint(tip & (d > 0.94), AUR_K)
    rach = line([spine[k] for k in range(2, 23)], w=1)
    st.paint(rach & ~face & inner & (d < 0.74), '#c8b896')
    st.paint(rach & ~face & inner & (d >= 0.74), '#fff3c8')
    quill = line([spine[0], spine[5]], w=2)
    st.part(quill, OWLGOLD[0], d=1, contour=True)
    st.stitch(vane & (d < 0.72), col=GOLD)
    st.eye(24, 28, look=(1, -1))
    st.eye(35, 26, look=(1, -1))
    st.paint(rect(23, 35, 25, 35) | rect(39, 33, 41, 33), BLUSH)
    st.mouth('grin', 30, 34)
    st.sparkle(51, 22)
    st.sparkle(8, 10, big=False)
    st.sparkle(50, 48, big=False)
    st.sparkle(9, 36, big=False)
    return key, st


PALS = [pinfeather_hush, nightglow_fleck, aurora_thread, owlet_peep, snowcrag_halo, great_white_plumelet]

if __name__ == '__main__':
    import math  # noqa: F401
    print('dominant', pic.dominant(4))
    paths = []
    for fn in PALS:
        key, st = fn()
        tidy(st)
        assert key in ROWS, key
        p = os.path.join(OUTDIR, key + '.png')
        info = st.save(p, glow=(ROWS[key]['rarity'] == 'rare'))
        paths.append(p)
        print('%-10s %-21s %-9s %-13s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
