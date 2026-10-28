"""Puzzle Pals: SEA-CAVE SMUGGLERS' RUN (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-scg-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_scg.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Delve mood: cosy-curious cave beasts and the dark's small treasures, never scary. kit_lair parts are building blocks only.
Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of game/assets/img/jigsaw/places/delve-sea-cave-smugglers-run.png,
calmed onto 2 tones of a pal-own colour family so the face reads (the cells are near-flat dark browns; browns lifted off mud).
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Clifftop Lamp   clifftop grass green        | a tiny hut roof hat with a lit window + blink rays, nub feet     | proud: happy ^ ^ arcs, open grin
  2 Sack Snooze     pale hessian oatmeal        | rope-tied tuft (peg tab), a patch, stencilled X, zzz              | sleepy: heavy lids, round snore
  3 Lantern Wink    lantern-glass gold          | navy hood over its crown, brass handle ring, boots                 | cheeky: one wink, tongue-out smirk
  4 Tide Notches    sea teal (+ notch gold)     | a striped tide pole held on one side, wave band across the belly  | grumpy: low brows, wobbly flat mouth
  5 Deepcave Glow   cave violet (+ glow amber)  | stalactite fringe on its brow, warm glowing heart, glow stitch     | shy: small dot eyes looking down, blush
  6 Moonlit Keg     oak russet keg (rare)       | whimsy barrel: staves, iron hoops, a crescent moon peeking out    | smug: half-lid eyes with moon glints
Ring and Plus knobs are mirror-symmetric (n/s centred, e/w at the same height). Hook tab kept small.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-sea-cave-smugglers-run'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-sea-cave-smugglers-run-588ce7')

GRASS = ('#4f8a4a', '#68a45a')
HESSIAN = ('#c8b088', '#dcc8a0')
LGOLD = ('#e0a83a', '#f2c860')
TEAL = ('#3a7c8c', '#4c94a2')
VIOLET = ('#544a92', '#6a5eaa')
OAK = ('#a0583a', '#b86c44')
ROOF = ('#b0483a', '#7e2e2a', '#d86a54', '#4e1c1c')
WINDOW = ('#ffe48a', '#f5cf6a')
ROPE = ('#d8b070', '#a87a40')
PATCH = ('#6a7aa0', '#4e5a80')
HOOD = ('#2c3466', '#1c2250', '#465090', '#141838')
BRASS = ('#d8a048', '#a87030', '#f4cc80', '#6a4420')
POLE = ('#e8dcc0', '#b0483a')
WAVE = ('#8cc4e4', '#5a94c0', '#d8f0fa')
STONE = ('#8a8498', '#6a6478', '#aaa4b8', '#4a4458')
GLOW = ('#f0a040', '#f8cc60', '#fff3c8')
IRON = ('#5b6470', '#3e4450', '#8a94a0', '#2a2e36')
MOON = ('#fff3c8', '#f5e09a')
BLUSH = '#f0a0a0'
TONGUE = '#e07070'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def arc_eye(st, x, y):
    """Happy closed eye: a 5-wide upward arc (^), 2 px thick at the peak."""
    st.sprite(['.UUU.', 'U...U', 'U...U'], x, y, {'U': UMBER}, solid=False)


def wink_eye(st, x, y):
    """A wink: a > shaped squeeze."""
    st.sprite(['U....', '.UU..', '...UU', '.UU..', 'U....'], x, y, {'U': UMBER}, solid=False)


def dot_eye(st, x, y):
    """Shy small eye: 2 x 3 umber bean with a cream glint, looking down."""
    st.sprite(['.UU.', 'UCUU', 'UUUU', '.UU.'], x, y, {'U': UMBER, 'C': CREAM}, solid=False)


def moon_eye(st, x, y, lidcol):
    """Smug eye: 6 x 5 cream oval, big umber pupil, crescent glint, a half lid of body tone with an umber lash line."""
    e = ellipse(x + 3, y + 2.5, 3.2, 2.7)
    st.paint(grow(e, 1), UMBER2)
    st.paint(e, CREAM)
    st.paint(rect(x + 2, y + 1, x + 4, y + 4) & e, UMBER)
    st.dots([(x + 2, y + 2), (x + 3, y + 1)], MOON[0])
    st.paint(e & (YY < y + 2), lidcol)
    st.paint(grow(e, 1) & (YY == y + 1) | e & (YY == y + 2) & ~rect(x + 2, y + 2, x + 3, y + 2), UMBER)


def hut_hat(st, cx, y):
    """A little clifftop hut worn as a hat: red gable roof standing on row y, a cream wall with a lit window, a chimney."""
    wall = rect(cx - 6, y - 6, cx + 5, y)
    st.part(wall, CREAM, d=1, contour=True)
    win = rect(cx - 2, y - 4, cx + 1, y - 1)
    st.paint(win, WINDOW[0])
    st.paint(rect(cx - 2, y - 4, cx + 1, y - 4) | rect(cx - 2, y - 4, cx - 2, y - 1), WINDOW[1])
    st.paint(rect(cx - 3, y - 5, cx + 2, y - 5) & ~win | rect(cx - 3, y - 5, cx - 3, y) | rect(cx + 2, y - 5, cx + 2, y), '#7a4a1f')
    chim = rect(cx + 3, y - 14, cx + 5, y - 9)
    st.part(chim, '#8a7a8a', d=1, contour=True)
    roof = poly([(cx - 9.5, y - 5.5), (cx + 0.0, y - 14.5), (cx + 9.5, y - 5.5)]) | rect(cx - 9, y - 7, cx + 8, y - 6)
    st.part(roof, ROOF[0], d=1, contour=True)
    st.paint(roof & ((XX + YY) % 3 == 0) & shrink(roof, 1), ROOF[1])
    return wall | roof | chim


def rays(st, pts):
    """Short gold blink rays (border only), each (x, y, dx, dy, len)."""
    for x, y, dx, dy, L in pts:
        for i in range(L):
            st.px[y + dy * i, x + dx * i] = hx(WINDOW[0] if i else GOLD_L)
            st.extra[y + dy * i, x + dx * i] = True


def rope_band(st, body, y0, y1):
    m = body & (YY >= y0) & (YY <= y1)
    st.paint(m, ROPE[0])
    st.paint(m & ((XX + YY) % 3 == 0), ROPE[1])
    return m


def patch(st, x, y, w=7, h=6):
    m = rect(x, y, x + w - 1, y + h - 1)
    st.part(m, PATCH[0], d=1, contour=True)
    ring = m & ~shrink(m, 1)
    st.paint(ring & (((XX + YY) % 2) == 0), CREAM)
    return m


def hood(st, body, y_hem, cx):
    """A navy cloth hood draped over the crown of a body down to row y_hem, scalloped hem, a peak."""
    wave = y_hem + 1.0 * np.cos((XX - cx) * 0.8)
    m = grow(body, 1) & (CY < wave) & (YY > 5)
    st.part(m, HOOD[0], d=1, contour=True)
    st.paint(m & ~shift(m, 0, -1) & (YY > 10), HOOD[1])
    st.paint(line([(cx - 9, y_hem - 6), (cx - 4, y_hem - 10)]) & shrink(m, 1), HOOD[2])
    return m


def handle_ring(st, cx, cy, r=4.0):
    ring = disc(cx, cy, r) & ~disc(cx, cy, r - 1.6) & (CY < cy + 1)
    st.part(ring, BRASS[0], d=1, contour=False)
    st.paint(ring & (CX < cx - 1) & (CY < cy - 1), BRASS[2])
    return ring


def tide_pole(st, x, y0, y1):
    """A striped tide pole (red and cream bands) with 4 gold notches on its side, a round cap."""
    m = rect(x, y0, x + 2, y1)
    st.part(m, POLE[0], d=1, contour=True)
    st.paint(m & (((YY - y0) // 3) % 2 == 1), POLE[1])
    for i in range(4):
        yy = y0 + 4 + i * 5
        st.paint(rect(x + 3, yy, x + 5, yy), GOLD)
        st.sil[yy, x + 3:x + 6] = True
    cap = disc(x + 1.5, y0 - 1.0, 2.0)
    st.part(cap, GOLD, d=1, contour=True)
    return m


def wave_band(st, body, y):
    w1 = body & (np.abs(CY - (y + 1.2 * np.sin(XX * 0.7))) < 1.0)
    w2 = body & (np.abs(CY - (y + 3 + 1.2 * np.sin(XX * 0.7 + 1.5))) < 0.6)
    st.paint(w1, WAVE[2])
    st.paint(w2, WAVE[0])


def stalactites(st, x0, x1, y, pts):
    """A stone brow band from x0 to x1 standing on row y, small rounded stalactites hanging under it (x, length)."""
    band = rect(x0, y - 3, x1, y)
    band[y - 3, x0] = band[y - 3, x1] = False
    tips = blank()
    for x, L in pts:
        tips |= poly([(x - 1.6, y + 0.5), (x + 1.6, y + 0.5), (x + 0.3, y + L + 0.5)]) | disc(x + 0.2, y + L - 0.4, 0.9)
    m = band | tips
    st.part(m, STONE[0], d=1, contour=True)
    st.paint(band & (YY == y - 3) | band & (YY == y - 2) & ((XX % 4) == 1), STONE[2])
    st.paint(tips & ~band & (CX > np.round(CX)), STONE[1])
    for x, L in pts:
        st.dots([(x, y + L + 1)], WAVE[2])                                   # a drip of cave water
    return m


def glow_heart(st, cx, cy, r=6.0):
    for rr, col in ((r, GLOW[0]), (r - 2.0, GLOW[1]), (r - 4.0, GLOW[2])):
        st.paint(disc(cx, cy, rr), col)


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


# ------------------------------------------------------------------ 1. Clifftop Lamp: corner-BB round, common. Clifftop green, hut roof hat with a lit window.
def clifftop_lamp():
    key = 'pl-scg-1'
    st = Sticker()
    core = (13, 26, 46, 50)
    body, holes = piece_blanks(core, nw=2.0, e=('B', 'round', 2, 2.5), s=('B', 'round', 0, 2.5))
    st.part(body, tex=fill(key, body, 13, 26, 34, list(GRASS)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#cfe8a8', skip=grow(holes, 3))
    hut_hat(st, 27, 26)
    rays(st, [(24, 7, -1, -1, 3), (16, 13, -1, 0, 3)])
    nub_feet(st, [14, 37], 50, '#3a663a')
    arc_eye(st, 18, 33)
    arc_eye(st, 32, 33)
    st.paint(rect(16, 38, 18, 38) | rect(36, 38, 38, 38), BLUSH)
    st.mouth('grin', 25, 39)
    return key, st


# ------------------------------------------------------------------ 2. Sack Snooze: edge-TBT peg, common. Hessian sack, rope-tied tuft, patched, snoring.
def sack_snooze():
    key = 'pl-scg-2'
    st = Sticker()
    core = (14, 22, 47, 47)
    body, holes = piece_blanks(core, n=('T', 'peg', 1, 3.8), e=('B', 'peg', 2, 3.2), s=('T', 'peg', -1, 3.6))
    st.part(body, tex=fill(key, body, 14, 14, 36, list(HESSIAN)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.paint(body & (YY >= 20) & (YY <= 22) & ~holes, ROPE[0])            # the rope tie round the tuft's neck
    st.paint(body & (YY == 21) & ((XX % 2) == 0), ROPE[1])
    st.stitch(body & (YY > 23), col='#8a6a48', skip=grow(holes, 3))
    st.paint(body & ((XX % 4) == 0) & (YY > 24) & (YY < 46) & shrink(body, 3) & (YY % 3 != 0), '#b89c74')   # hessian weave
    patch(st, 16, 39, 7, 6)
    st.sprite(['U...U', '.U.U.', '..U..', '.U.U.', 'U...U'], 38, 25, {'U': '#8a6a48'}, solid=False)   # stencilled X
    st.eye(20, 30, lid=3)
    st.eye(33, 30, lid=3)
    st.sprite(['.UU.', 'URRU', 'URRU', '.UU.'], 28, 37, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    zzz(st, 52, 12)
    zzz(st, 56, 6)
    return key, st


# ------------------------------------------------------------------ 3. Lantern Wink: inner-TBTB tri, common. Lantern-glass gold under a navy hood, brass ring, winking.
def lantern_wink():
    key = 'pl-scg-3'
    st = Sticker()
    core = (16, 22, 46, 47)
    body, holes = piece_blanks(core, nw=2.2, n=('T', 'tri', 0, 3.4), e=('B', 'tri', 4, 2.3), s=('T', 'tri', 0, 3.4), w=('B', 'tri', 4, 2.3))
    st.part(body, tex=fill(key, body, 16, 22, 31, list(LGOLD)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY > 27), col='#fff3c8', skip=grow(holes, 3))
    st.paint(shrink(body, 3) & (XX % 7 == 3) & (YY > 28) & (YY < 46) & ~grow(holes, 3), '#c98a30')   # lantern frame bars
    handle_ring(st, 31.5, 11.5, 3.4)
    hood(st, body, 27, 31.5)
    for x in (18, 38):
        sh = rect(x, 49, x + 6, 52)
        sh[49, x] = sh[49, x + 6] = False
        st.part(sh, SHOE[0], d=1, contour=True)
    wink_eye(st, 21, 31)
    st.eye(34, 31, look=(-1, 0))
    st.paint(line([(33, 29), (36, 28), (39, 29)]), UMBER)                 # one cocky raised brow
    st.sprite(['U.....U', '.UUUUU.', '..TT...'], 25, 39, {'U': UMBER, 'T': TONGUE}, solid=False)
    st.paint(rect(16, 38, 18, 38), BLUSH)
    return key, st


# ------------------------------------------------------------------ 4. Tide Notches: inner-TTTT double (Plus), uncommon. Sea teal, a tide pole, wave band, grumpy.
def tide_notches():
    key = 'pl-scg-4'
    st = Sticker()
    core = (18, 22, 45, 47)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 18, 22, 28, list(TEAL)), contour=True)
    st.stitch(body, col=GOLD)                                            # uncommon accent: the tide pole's notch gold
    wave_band(st, body & ~grow(rect(0, 0, 63, 0), 0), 42)
    tide_pole(st, 49, 14, 50)
    st.eye(21, 30, lid=1)
    st.eye(34, 30, lid=1)
    st.paint(line([(20, 27), (25, 29)]) | line([(34, 29), (39, 27)]) | line([(20, 28), (25, 30)]) | line([(34, 30), (39, 28)]), UMBER)
    st.sprite(['.U.U.U', 'U.U.U.'], 27, 38, {'U': UMBER}, solid=False)   # a grumbling wobbly mouth
    return key, st


# ------------------------------------------------------------------ 5. Deepcave Glow: inner-BBBB round (Ring), uncommon. Cave violet, stalactite brow, warm glow heart, shy.
def deepcave_glow():
    key = 'pl-scg-5'
    st = Sticker()
    core = (14, 20, 49, 51)
    body, holes = piece_blanks(core, nw=2.0, n=('B', 'round', 0, 2.4), e=('B', 'round', 3, 2.4), s=('B', 'round', 0, 2.4), w=('B', 'round', 3, 2.4))
    st.part(body, tex=fill(key, body, 14, 20, 36, list(VIOLET)), contour=True)
    st.blank_shade(body, holes, width=1)
    glow_heart(st, 31.5, 41.0, 5.0)
    st.stitch(body & (YY > 25), col=GLOW[1], skip=grow(holes, 3))        # uncommon accent: the deep cave's warm glow
    stalactites(st, 12, 51, 23, [(17, 4), (23, 2), (40, 3), (46, 4)])
    dot_eye(st, 21, 30)
    dot_eye(st, 38, 30)
    st.paint(rect(18, 35, 20, 35) | rect(43, 35, 45, 35), BLUSH)
    st.sprite(['U.U.U', '.U.U.'], 29, 34, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Moonlit Keg: whimsy-barrel hook, rare. An oak keg with iron hoops, a crescent moon peeking from its lid, smug.
def moonlit_keg():
    key = 'pl-scg-6'
    st = Sticker()
    cx, cy, hh = 29.5, 36.5, 15.0
    prof = lambda: 11.5 + 3.0 * (1 - ((CY - cy) / hh) ** 2)              # stave half-width, bowed out at the middle
    barrel = (np.abs(CX - cx) < prof()) & (YY >= 22) & (YY <= 51)
    barrel[22, 18] = barrel[22, 40] = barrel[51, 18] = barrel[51, 40] = False
    tab = knob('e', 'hook', 37, 44, r=2.6)
    body = barrel | tab
    moon = disc(23.5, 18.0, 6.0) & ~disc(27.0, 15.5, 5.0) & (YY < 23)  # a crescent moon peeking up from behind the lid
    st.part(moon, MOON[0], d=1, contour=True)
    st.paint(moon & ~shift(moon, 1, -1), MOON[1])
    t = cell_fill(pic, ROWS[key]['piece'], body, 12, 21, 32, 3, 3)
    st.part(body, tex=calm_tones(t, body, list(OAK)), contour=True)
    inner = barrel & (YY > 25)
    for k in (-2, -1, 1, 2):                                             # stave joints, bowed with the barrel
        st.paint(inner & (np.abs((CX - cx) - k * prof() / 2.6) < 0.5), '#6e3424')
    lid = barrel & (YY <= 24)
    st.paint(lid, '#d8966a')
    st.paint(barrel & (YY == 22), '#ecb88c')
    st.paint(barrel & (YY == 25), '#6e3424')
    st.paint(rect(27, 23, 31, 24), '#4a2018')                            # the bunghole
    for y in (28, 46):                                                   # iron hoops
        h = barrel & (YY >= y) & (YY <= y + 2)
        st.paint(h, IRON[0])
        st.paint(h & (YY == y), IRON[2])
        st.paint(h & (YY == y + 2), IRON[1])
        st.paint(h & (XX % 7 == 3) & (YY == y + 1), IRON[2])          # rivets
    st.stitch(barrel & (YY > 31) & (YY < 45), col=MOON[1])
    moon_eye(st, 18, 33, OAK[1])
    moon_eye(st, 34, 33, OAK[1])
    st.sprite(['.......U', 'UUUUUUU.'], 25, 40, {'U': UMBER}, solid=False)   # smug smirk
    st.paint(rect(16, 40, 18, 40) | rect(41, 40, 43, 40), BLUSH)
    st.sparkle(46, 8)
    st.dots([(33, 19), (35, 17), (37, 15)], MOON[0])
    st.extra[19, 33] = st.extra[17, 35] = st.extra[15, 37] = True
    st.sparkle(6, 24, big=False)
    st.sparkle(54, 54, big=False)
    return key, st


PALS = [clifftop_lamp, sack_snooze, lantern_wink, tide_notches, deepcave_glow, moonlit_keg]

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
        print('%-10s %-17s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
