"""Puzzle Pals: THE CANOPY BRIDGES (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-tcb-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_tcb.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built from kit_lair parts as building blocks only. Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/delve-the-canopy-bridges.png, calmed onto 2 tones of a pal-own colour family so the face reads.
Delve mood: cosy-curious beasts of the high rope bridges at dawn (walnut leaves, the valley yurt, rope knots, the walnut marmot), never scary.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Dawnleaf Drift     dawn sky pink                | an orange walnut leaf landed on its head, a dew drop        | sleepy: closed arcs, tiny smile, blush
  2 Plank Skipper      meadow green                 | skips on a 3-plank rope bridge strip, one stub arm waving   | cheeky wink, open grin
  3 Yurt Kettle        yurt felt terracotta         | an enamel blue kettle on its head whistling steam, boots    | startled: wide eyes up, brows up, o mouth
  4 Bridge Knots       dawn violet (+ rope tan)     | fat rope knots wrapped on all four tabs, a rope tail         | grumpy brows, frown
  5 Treetop Porch      spruce teal (+ dawn pink)    | sits on a plank porch ledge, a resting wind swirl beside it  | smug half lids, side look, smirk
  6 Bridgewalk Marmot  marmot tan (rare)            | whimsy chibi marmot, cream belly, walnut held up like a prize| proud beady eyes, buck teeth grin
Plus (4) and Ring (5) and the TBTB (3): knobs centred (n, s on the centre line, e and w at the same height): no rotating offsets.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-the-canopy-bridges'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-the-canopy-bridges-073a0a')

PINKD = ('#c47e9e', '#d599b2')          # dawn sky pink
MEADOW = ('#7ea85a', '#98bc70')         # valley grass
FELT = ('#c4643a', '#d67c4c')           # yurt felt, lifted off the brick
VIOL = ('#6a6aa8', '#7c7ab4')           # dawn violet
SPRUCE = ('#3f7a66', '#4f8c76')         # spruce teal, lifted
MARMOT = ('#b8925a', '#c9a96e')         # marmot tan
LEAF = ('#f08a24', '#c8601c', '#f8b860', '#8a3a14')
WOOD = ('#b07a45', '#8a5a30', '#d8a868', '#5c3a20')
ROPE = ('#d8b878', '#a88850', '#f2dca8', '#6a5030')
ENAMEL = ('#8ec4dc', '#5a94b8', '#d8f0fa', '#3a6a90')
WALNUT = ('#d8b070', '#a87a3e', '#f2d8a0', '#6a4422')
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


def closed_eye(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def walnut_leaf(st, cx, cy, L=9, ang=-30.0, w=3.4):
    """A walnut leaflet: long oval, pointed tip, midrib and two vein pairs, a short stem at its root."""
    a = math.radians(ang)
    ux, uy = math.cos(a), math.sin(a)
    px, py = -uy, ux
    pts = []
    for t in np.linspace(0, 1, 9):
        ww = w * math.sin(math.pi * t) ** 0.8
        pts.append((cx + ux * L * t + px * ww, cy + uy * L * t + py * ww))
    for t in np.linspace(1, 0, 9):
        ww = w * math.sin(math.pi * t) ** 0.8
        pts.append((cx + ux * L * t - px * ww, cy + uy * L * t - py * ww))
    m = poly(pts)
    stem = line([(cx - ux * 3, cy - uy * 3), (cx + ux, cy + uy)], w=1)
    st.paint(stem, LEAF[3], solid=True)
    st.part(m, LEAF[0], d=1, contour=True)
    st.paint(line([(cx + ux, cy + uy), (cx + ux * L * 0.85, cy + uy * L * 0.85)]) & shrink(m, 1), LEAF[2])
    for t in (0.35, 0.6):
        bx, by = cx + ux * L * t, cy + uy * L * t
        st.paint(line([(bx, by), (bx + (ux + px) * 2, by + (uy + py) * 2)]) & shrink(m, 1), LEAF[1])
    return m | stem


def dew(st, x, y):
    st.sprite(['.D.', 'DLD', '.D.'], x, y, {'D': ENAMEL[0], 'L': '#ffffff'}, solid=False)
    st.extra[y:y + 3, x:x + 3] |= np.array([[0, 1, 0], [1, 1, 1], [0, 1, 0]], bool)


def plank_strip(st, x0, x1, y, n=3):
    """A strip of rope bridge: n planks with gaps, a rope line running under them, rope ends curling down."""
    m = blank()
    span = (x1 - x0 + 1) / n
    for i in range(n):
        a = int(round(x0 + i * span)) + 1
        b = int(round(x0 + (i + 1) * span)) - 1
        m |= rect(a, y, b, y + 2)
    rope = rect(x0, y + 3, x1, y + 3) | rect(x0, y + 4, x0, y + 5) | rect(x1, y + 4, x1, y + 5)
    st.paint(rope, ROPE[1], solid=True)
    st.part(m, WOOD[0], d=1, contour=True)
    st.paint(m & (YY == y), WOOD[2])
    return m | rope


def wave_arm(st, x, y, col):
    """A stub arm raised up and out from (x, y), waving: a 3 px wide rounded nub with 2 motion ticks."""
    arm = line([(x, y), (x + 4, y - 4)], w=4)
    mitt = disc(x + 5.5, y - 6.5, 3.0) | disc(x + 3.5, y - 8.5, 1.5)
    st.part(arm, col, d=1, contour=True)
    st.part(mitt, '#e8a04a', d=1, contour=True)                       # a felt mitten (the thumb up)
    st.sprite(['M..', '.M.', '...', 'M..'], x + 7, y - 11, {'M': CREAM}, solid=False)
    for dx_, dy_ in ((0, 0), (1, 1), (0, 3)):
        st.extra[y - 11 + dy_, x + 7 + dx_] = True
    return arm


def kettle(st, cx, by):
    """An enamel kettle standing on row by: round belly, lid with knob, spout to the right, arched handle, a whistle of steam."""
    belly = ellipse(cx, by - 4, 7, 5) & (CY < by + 0.5)
    lid = rect(int(cx) - 3, int(by) - 10, int(cx) + 2, int(by) - 9)
    knobm = rect(int(cx) - 1, int(by) - 12, int(cx), int(by) - 11)
    spout = line([(cx + 5, by - 4), (cx + 10, by - 9)], w=2)
    handle = (np.abs(np.hypot(CX - cx - 0.0, CY - (by - 9)) - 5.2) < 0.75) & (CY < by - 9)
    st.part(handle, ENAMEL[3], d=0, contour=False)
    st.part(spout, ENAMEL[0], d=1, contour=True)
    m = belly | lid
    st.part(m, ENAMEL[0], d=1, contour=True)
    st.part(knobm, UMBER2, d=0, contour=False)
    st.paint(belly & (YY == int(by) - 4) & ((XX % 2) == 0), CREAM)        # a dotted folk band round the belly
    st.paint(rect(int(cx) - 5, int(by) - 7, int(cx) - 4, int(by) - 6), ENAMEL[2])
    st.sprite(['.S.S', 'S.S.', '.S.S'], int(cx) + 11, int(by) - 15, {'S': CREAM}, solid=False)   # steam whistle
    for j, r in enumerate(['.S.S', 'S.S.', '.S.S']):
        for i, ch in enumerate(r):
            if ch == 'S':
                st.extra[int(by) - 15 + j, int(cx) + 11 + i] = True
    return m | spout | handle


def rope_knot(st, cx, cy, horiz=True, r=4.2):
    """A fat rope knot wrapped round a tab: a rounded rope barrel with twisted strand ticks, light top-left."""
    m = ellipse(cx, cy, r if horiz else r * 0.75, r * 0.75 if horiz else r)
    st.part(m, ROPE[0], d=1, contour=True)
    st.paint(m & shrink(m, 1) & (((XX + YY) % 3) == 0), ROPE[1])
    st.paint(m & shrink(m, 1) & ~shift(m, 1, 1), ROPE[2])
    return m


def porch(st, x0, x1, y):
    """A round treetop porch ledge: an elliptic plank deck with board seams, a bracket under it, a bit of trunk below."""
    deck = ellipse((x0 + x1) / 2, y + 2, (x1 - x0) / 2, 3.2)
    trunk = rect(int((x0 + x1) / 2) - 3, y + 4, int((x0 + x1) / 2) + 3, y + 8)
    brk = line([((x0 + x1) / 2 - 3, y + 7), ((x0 + x1) / 2 - 9, y + 3)], w=2) | line([((x0 + x1) / 2 + 3, y + 7), ((x0 + x1) / 2 + 9, y + 3)], w=2)
    st.part(trunk, '#6a4426', d=1, contour=True)
    st.part(brk, WOOD[1], d=0, contour=True)
    st.part(deck, WOOD[0], d=1, contour=True)
    st.paint(deck & (((XX - x0) % 6) == 0) & shrink(deck, 1), WOOD[1])
    st.paint(deck & ~shift(deck, 0, 1), WOOD[2])
    return deck | trunk | brk


def wind_swirl(st, cx, cy):
    """The wind sitting down: a cream spiral curl with a trailing tail line."""
    s = blank()
    for k in range(26):
        a = k * 0.42
        rr = 0.6 + k * 0.17
        x, y = cx + rr * math.cos(a), cy + rr * math.sin(a)
        s |= rect(int(round(x)), int(round(y)), int(round(x)), int(round(y)))
    s |= line([(cx + 4, cy + 4), (cx - 5, cy + 5)])
    st.paint(s, CREAM, solid=True)
    return s


def bead_eye(st, x, y):
    """Marmot eye: a 4 x 4 round glossy dark bead in a thin umber rim, two glints."""
    b = ellipse(x + 2, y + 2, 2.3, 2.4)
    st.paint(grow(b, 1), UMBER2)
    st.paint(b, UMBER)
    st.dots([(x + 1, y + 1), (x + 2, y + 1), (x + 3, y + 3)], CREAM)


def walnut(st, cx, cy, r=3.6):
    m = ellipse(cx, cy, r, r * 1.1)
    st.part(m, WALNUT[0], d=1, contour=True)
    st.paint(line([(cx, cy - r), (cx, cy + r)]) & m, WALNUT[3])
    st.paint(m & shrink(m, 1) & ~(XX == int(cx)) & (((YY + (XX % 2)) % 3) == 0), WALNUT[1])
    st.paint(rect(int(cx) - 2, int(cy) - 2, int(cx) - 2, int(cy) - 1) & m, WALNUT[2])
    return m


# ------------------------------------------------------------------ 1. Dawnleaf Drift: corner-TT round, common. Dawn pink, a walnut leaf drifted onto its head, dozing.
def dawnleaf_drift():
    key = 'pl-tcb-1'
    st = Sticker()
    core = (11, 22, 43, 49)
    body = piece(core, n=('T', 'round', -6, 3.6), e=('T', 'round', 3, 3.6))
    st.part(body, tex=fill(key, body, 11, 22, 33, list(PINKD)), contour=True)
    st.stitch(body, col='#f8dce6')
    walnut_leaf(st, 27, 23, L=16, ang=-22, w=4.4)
    dew(st, 9, 16)
    nub_feet(st, [15, 35], 49, '#9a5a78')
    closed_eye(st, 17, 33)
    closed_eye(st, 30, 33)
    st.paint(rect(15, 37, 17, 37) | rect(34, 37, 36, 37), BLUSH)
    st.sprite(['U.U', '.U.'], 25, 39, {'U': UMBER}, solid=False)
    zzz(st, 50, 14)
    return key, st


# ------------------------------------------------------------------ 2. Plank Skipper: edge-TTB tri, common. Meadow green, skipping a rope plank strip, waving at the sheep.
def plank_skipper():
    key = 'pl-tcb-2'
    st = Sticker()
    core = (15, 20, 45, 46)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', -4, 3.6), w=('T', 'tri', 2, 3.4), e=('B', 'tri', 2, 2.8))
    st.part(body, tex=fill(key, body, 15, 20, 31, list(MEADOW)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#e2f0c0', skip=grow(holes, 3))
    wave_arm(st, 45, 25, MEADOW[0])
    plank_strip(st, 8, 54, 49, n=4)
    st.eye(19, 29, look=(1, 0))
    st.sprite(['.UUU.', 'U...U'], 32, 31, {'U': UMBER}, solid=False)     # the wink: a closed ^ eye
    st.mouth('grin', 26, 37)
    st.paint(rect(18, 36, 20, 36) | rect(38, 36, 40, 36), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Yurt Kettle: inner-TBTB peg, common. Yurt felt terracotta, an enamel kettle whistling on its head, startled.
def yurt_kettle():
    key = 'pl-tcb-3'
    st = Sticker()
    core = (14, 26, 46, 49)
    body, holes = piece_blanks(core, n=('T', 'peg', 0, 3.2), e=('B', 'peg', 0, 2.8), s=('T', 'peg', 0, 3.0), w=('B', 'peg', 0, 2.8))
    st.part(body, tex=fill(key, body, 14, 26, 33, list(FELT)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f8d8a8', skip=grow(holes, 3))
    kettle(st, 30, 24)
    for x in (13, 41):
        sh = rect(x, 52, x + 6, 54)
        sh[52, x] = sh[52, x + 6] = False
        st.part(sh, SHOE[0], d=1, contour=True)
    st.eye(18, 32, look=(0, -1))
    st.eye(37, 32, look=(0, -1))
    st.paint(line([(18, 29), (20, 28), (22, 29)]) | line([(37, 29), (39, 28), (41, 29)]), UMBER)
    st.mouth('o', 29, 41)
    return key, st


# ------------------------------------------------------------------ 4. Bridge Knots: inner-TTTT double, uncommon. Dawn violet, a fat rope knot on each tab, grumpy about the marmots' knotwork.
def bridge_knots():
    key = 'pl-tcb-4'
    st = Sticker()
    core = (17, 22, 46, 46)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 22, 30, list(VIOL)), contour=True)
    st.stitch(body, col=ROPE[0])                                         # uncommon accent: the bridge rope tan
    rope_knot(st, 32, 20, horiz=True)
    rope_knot(st, 32, 49, horiz=True)
    rope_knot(st, 15, 34.5, horiz=False)
    rope_knot(st, 49, 34.5, horiz=False)
    st.eye(22, 30, lid=1)
    st.eye(36, 30, lid=1)
    st.paint(line([(21, 27), (26, 29)]) | line([(36, 29), (41, 27)]) | line([(21, 26), (26, 28)]) | line([(36, 28), (41, 26)]), UMBER)
    st.sprite(['.UUUU.', 'U....U'], 29, 40, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 5. Treetop Porch: inner-BBBB round, uncommon. Spruce teal on a plank porch, the wind curled up resting beside it, smug.
def treetop_porch():
    key = 'pl-tcb-5'
    st = Sticker()
    core = (14, 16, 47, 46)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 0, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 0, 3.0))
    st.part(body, tex=fill(key, body, 14, 16, 34, list(SPRUCE)))
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=PINKD[1], skip=grow(holes, 3))                  # uncommon accent: the dawn pink
    porch(st, 9, 54, 46)
    wind_swirl(st, 50, 13)
    st.eye(20, 25, look=(1, 0), lid=2)
    st.eye(35, 25, look=(1, 0), lid=2)
    st.paint(line([(35, 22), (38, 21), (40, 22)]), UMBER)
    st.mouth('smirk', 28, 35)
    return key, st


# ------------------------------------------------------------------ 6. Bridgewalk Marmot: whimsy-marmot tri, rare. A chibi marmot holding a walnut up like a prize.
def bridgewalk_marmot():
    key = 'pl-tcb-6'
    st = Sticker()
    head = ellipse(28, 27, 13, 9.5)
    belly = ellipse(28, 42, 13.5, 11) & (CY < 53)
    ears = disc(17.5, 20.5, 2.4) | disc(38.5, 20.5, 2.4)
    tab = knob('w', 'tri', 43, 15.4, r=3.0)
    body = head | belly | ears | tab
    tail = ellipse(44, 49, 5, 3.0)
    st.part(tail, '#7a5232', d=1, contour=True)
    st.part(body, tex=fill(key, body, 13, 15, 32, list(MARMOT)), contour=True)
    st.paint(ears & shrink(ears, 1) & ~head, '#8a5a34')
    st.paint(ellipse(28, 44, 8, 7.5) & belly & ~head, CREAM)            # cream belly
    st.paint(ellipse(28, 21, 9, 4.5) & shrink(head, 1), '#8a6038')     # the dark marmot cap over the brow
    st.paint(ellipse(28, 21, 9, 4.5) & shrink(head, 1) & ((XX + YY) % 4 == 0), '#a07a46')
    st.stitch(belly & (YY > 37), col='#f8e8c0')
    st.part(ellipse(21, 53, 4.5, 2.2) | ellipse(35, 53, 4.5, 2.2), '#5c3a24', d=1, contour=True)
    muzzle = ellipse(28, 31, 5.5, 3.8)
    st.part(muzzle, '#f2e4c0', d=1, contour=True)
    bead_eye(st, 19, 23)
    bead_eye(st, 33, 23)
    st.sprite(['UUU', '.U.'], 27, 29, {'U': UMBER}, solid=False)        # nose
    st.sprite(['UU.UU', '.UUU.', '.CUC.', '.C.C.'], 26, 31, {'U': UMBER, 'C': '#ffffff'}, solid=False)   # buck-tooth grin
    st.paint(rect(16, 30, 18, 30) | rect(38, 30, 40, 30), BLUSH)
    walnut(st, 28, 42, r=5.2)                                          # the prize, hugged up to its chest
    st.part(ellipse(21.5, 43, 3, 2.6) | ellipse(34.5, 43, 3, 2.6), '#a07a46', d=1, contour=True)   # both paws on it
    st.dots([(40, 37), (41, 36), (42, 37), (41, 38)], GOLD_L)
    st.extra[36:39, 40:43] |= np.array([[0, 1, 0], [1, 0, 1], [0, 1, 0]], bool)
    st.sparkle(52, 9)
    st.sparkle(7, 8, big=False)
    st.sparkle(55, 36, big=False)
    return key, st


PALS = [dawnleaf_drift, plank_skipper, yurt_kettle, bridge_knots, treetop_porch, bridgewalk_marmot]

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
        print('%-10s %-17s %-9s %-14s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
