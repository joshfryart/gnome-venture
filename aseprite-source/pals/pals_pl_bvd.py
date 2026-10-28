"""Puzzle Pals: BEAVERDAM TUNNELS (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-bvd-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_bvd.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Delve mood: cosy-curious cave beasts, never scary. kit_lair parts are building blocks only. Silhouette = the row's shape + knob, body = its own
15 x 15 art px cell of game/assets/img/jigsaw/places/delve-beaverdam-tunnels.png, calmed onto 2 tones of a pal-own colour family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Willow Chew      pale chewed-wood apricot      | a leafy willow stick held in the teeth          | cheeky side-glance, buck teeth, one brow
  2 Paddletail Slap  pond teal                     | a flat crosshatched beaver tail + splash drops  | startled: wide eyes up, brows shot up, o
  3 Tunnel Trickle   tunnel water blue             | a leaf boat with a twig mast on its head, drips | smug: heavy lids, smirk
  4 Damwall Logs     sunlit log mustard (+ moss)   | its 4 tabs are log ends with tree rings, moss   | grumpy: angled brows, frown, creak marks
  5 Lodge Door       lodge maroon-rose (+ gold)    | a stick-arch doorway round its face, a poppy    | shy: peeks down from the dark door, blush
  6 Dam Captain      chestnut beaver (rare)        | whimsy beaver: captain cap, flat tail tapping   | proud happy arcs, buck-tooth grin
Ring blanks are mirror-symmetric (n and s centred, e and w at the same height); the Plus tabs are centred (no pinwheel).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-beaverdam-tunnels'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-beaverdam-tunnels-a12bc9')

WOOD = ('#d9a660', '#e9b98a')
POND = ('#3a7a66', '#4a8a7a')
TUNNEL = ('#4a98bc', '#7fb8dc')
LOGY = ('#b8923e', '#cea550')
LODGE = ('#8a3c38', '#a6524a')
CHEST = ('#a8582f', '#bc6c3c')
BARK = ('#7a4a1f', '#5e3418', '#9a6b3f', '#3d2a1c')
TAILC = ('#6b4a3a', '#4e3428', '#8a6650', '#3a241c')
LEAF = ('#7aa84a', '#58863a', '#a8cc6a', '#3a5a2a')
WATER = ('#8fc4e2', '#5aa8c8', '#cfe8f0', '#3f8fb0')
MOSS = ('#5a9a4a', '#3a7a3a', '#8cc46a', '#2a5a2a')
NAVYC = ('#2f6290', '#264a70', '#4a7ab0', '#1a3050')
RING = '#8a5a28'
BLUSH = '#f0a0a0'
POPPY = '#f08a24'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def buck_teeth(st, x, y, h=3):
    """Two cream beaver teeth under a mouth line: 2 px each, umber gap and outline."""
    st.paint(rect(x - 1, y - 1, x + 5, y - 1), UMBER)
    st.paint(rect(x - 1, y, x - 1, y + h - 1) | rect(x + 2, y, x + 2, y + h - 1) | rect(x + 5, y, x + 5, y + h - 1) |
             rect(x, y + h, x + 4, y + h), UMBER)
    st.paint(rect(x, y, x + 1, y + h - 1) | rect(x + 3, y, x + 4, y + h - 1), CREAM)


def willow_stick(st, x0, x1, y):
    """A peeled willow stick (2 px), pale chewed ends, three lance leaves sprouting off it."""
    m = rect(x0, y, x1, y + 1)
    st.part(m, BARK[2], d=1, contour=True)
    st.paint(rect(x0, y, x0 + 1, y + 1) | rect(x1 - 1, y, x1, y + 1), '#f2e4c0')
    st.paint(m & (YY == y + 1) & (XX > x0 + 1) & (XX < x1 - 1), BARK[0])
    lv = blank()
    for lx, ly, ang in ((x0 + 3, y, -1), (x1 - 4, y, -1), (x1 - 8, y + 1, 1)):
        lv |= poly([(lx, ly), (lx - 2, ly + ang * 3), (lx - 1, ly + ang * 6), (lx + 1, ly + ang * 4)])
    st.part(lv & ~m, LEAF[0], d=1, contour=True)
    st.paint(lv & ~m & ~shift(lv, 1, 0), LEAF[2])
    return m | lv


def flat_tail(st, cx, cy, rx, ry, rot):
    """A flat beaver paddle tail: a tilted oval with a crosshatch of scale lines, lighter top edge."""
    c, s = np.cos(rot), np.sin(rot)
    u = (CX - cx) * c + (CY - cy) * s
    v = -(CX - cx) * s + (CY - cy) * c
    m = (u / rx) ** 2 + (v / ry) ** 2 <= 1
    st.part(m, TAILC[0], d=1, contour=True)
    hatch = m & shrink(m, 1) & ((((XX + YY) % 3) == 0) | (((XX - YY) % 3) == 0))
    st.paint(hatch, TAILC[1])
    return m


def drop(st, cx, cy, r=1.6, col=WATER):
    m = disc(cx, cy, r) | poly([(cx - r * 0.8, cy - 0.3), (cx, cy - r * 2.4), (cx + r * 0.8, cy - 0.3)])
    st.paint(m, col[0], solid=True)
    st.paint(m & ~shift(m, -1, -1), col[3])
    st.dots([(int(cx - 0.5), int(cy - 0.5))], col[2])
    return m


def leaf_boat(st, cx, by, w=8):
    """A curled leaf hull floating, a twig mast with a cream sail."""
    hull = ellipse(cx, by - 1, w, 3.2) & (CY > by - 1.5)
    hull |= rect(int(cx - w), int(by) - 3, int(cx - w) + 1, int(by) - 1) | rect(int(cx + w) - 2, int(by) - 4, int(cx + w) - 1, int(by) - 1)
    mast = rect(int(cx), int(by) - 12, int(cx), int(by) - 2)
    sail = poly([(cx + 1, by - 12.5), (cx + 6, by - 10.5), (cx + 1, by - 8)])
    st.part(sail, '#d6322b', d=0, contour=True)
    st.paint(mast, BARK[0], solid=True)
    st.part(hull, LEAF[0], d=1, contour=True)
    st.paint(line([(cx - w + 2, by - 1), (cx + w - 3, by - 1)]) & hull, LEAF[2])
    return hull | mast | sail


def log_end(st, cx, cy, r, clip):
    """The cut end of a log on a tab: pale wood disc, two growth rings, a heart dot."""
    m = disc(cx, cy, r) & shrink(clip, 1)
    st.paint(m, '#e9c98a')
    st.paint(m & ~disc(cx, cy, r - 1), '#5e3418')
    st.paint(disc(cx, cy, r - 2.2) & ~disc(cx, cy, r - 3.1), RING)
    st.paint(disc(cx, cy, 0.9), RING)
    return m


def moss(st, x, y, w=7):
    m = blank()
    for i in range(w):
        h = 1 + (i * 5 % 3)
        m |= rect(x + i, y - h, x + i, y)
    st.part(m, MOSS[0], d=0, contour=False)
    st.paint(m & ~shift(m, 0, 1), MOSS[2])
    return m


def creak(st, x, y, side=1):
    st.sprite(['C.', '.C', 'C.'] if side > 0 else ['.C', 'C.', '.C'], x, y, {'C': CREAM}, solid=False)
    st.extra[y:y + 3, x:x + 2] |= st.px[y:y + 3, x:x + 2].sum(-1) == hx(CREAM).astype(int).sum()


def poppy(st, cx, cy):
    petals = disc(cx - 1.2, cy, 1.8) | disc(cx + 1.2, cy, 1.8) | disc(cx, cy - 1.2, 1.8) | disc(cx, cy + 1.2, 1.8)
    st.part(petals, POPPY, d=1, contour=True)
    st.paint(disc(cx, cy, 0.9), '#5e2f1e')
    st.paint(line([(cx, cy + 3), (cx - 1, cy + 6)]), LEAF[1], solid=True)
    return petals


def captain_cap(st, cx, y, w=9):
    """A navy captain's cap: soft crown, cream band, black-umber brim jutting left, gold badge."""
    crown = ellipse(cx + 1, y - 1, w + 1, 4.5) & (CY < y + 0.5)
    band = rect(int(cx - w), int(y), int(cx + w), int(y) + 2)
    brim = ellipse(cx - 3, y + 3.2, w - 1, 1.8) & (CY > y + 2.5)
    st.part(crown, NAVYC[0], d=1, contour=True)
    st.part(band, CREAM, d=1, contour=True)
    st.part(brim, NAVYC[3], d=0, contour=True)
    st.sprite(['.G.', 'GLG', '.G.'], int(cx) - 1, int(y) - 1, {'G': GOLD, 'L': GOLD_L})
    return crown | band | brim


def arc_eye(st, x, y):
    """Happy closed eye: an upward arc (^), 5 px wide, 2 px thick at the peak."""
    st.sprite(['.UUU.', 'U...U', 'U...U'], x, y, {'U': UMBER}, solid=False)


def bead_eye(st, x, y, glint=True):
    """Small shy bead eye: 3 x 3 umber, a cream glint."""
    st.paint(rect(x, y, x + 2, y + 2), UMBER)
    if glint:
        st.dots([(x, y)], CREAM)


# ------------------------------------------------------------------ 1. Willow Chew: corner-BB round, common. Pale chewed wood, a leafy stick in its teeth, cheeky.
def willow_chew():
    key = 'pl-bvd-1'
    st = Sticker()
    core = (11, 21, 46, 49)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'round', 8, 3.4), e=('B', 'round', 7, 3.4))
    st.part(body, tex=fill(key, body, 11, 21, 35, list(WOOD)), contour=True)
    st.blank_shade(body, holes)
    st.stitch(body, col='#a8582f', skip=grow(holes, 3))
    for x in (16, 36):
        st.part(ellipse(x + 2.5, 50.5, 3.2, 2), '#7a4a1f', d=1, contour=True)
    st.eye(15, 28, look=(1, 0))
    st.eye(27, 28, look=(1, 0))
    st.paint(line([(27, 25), (30, 24), (32, 25)]), UMBER)                # one brow cocked
    willow_stick(st, 8, 40, 40)
    buck_teeth(st, 20, 38, h=2)
    st.paint(rect(13, 36, 15, 36) | rect(33, 36, 35, 36), BLUSH)
    return key, st


# ------------------------------------------------------------------ 2. Paddletail Slap: edge-TTB peg, common. Pond teal, a flat crosshatched tail mid-slap, splash drops.
def paddletail_slap():
    key = 'pl-bvd-2'
    st = Sticker()
    core = (13, 23, 41, 46)
    flat_tail(st, 45, 48, 7.5, 4.0, -0.55)
    body, holes = piece_blanks(core, s='F', n=('T', 'peg', -4, 3.6), e=('T', 'peg', -5, 3.4), w=('B', 'peg', 2, 3.2))
    st.part(body, tex=fill(key, body, 13, 23, 29, list(POND)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#a4d0e8', skip=grow(holes, 3))
    drop(st, 52, 32, r=1.5)
    drop(st, 56, 38, r=1.2)
    drop(st, 48, 29, r=1.1)
    st.eye(17, 31, look=(0, -1))
    st.eye(29, 31, look=(0, -1))
    st.paint(line([(16, 27), (18, 26), (20, 27)]) | line([(29, 27), (31, 26), (33, 27)]), UMBER)
    st.sprite(['.UU.', 'URRU', 'URRU', '.UU.'], 23, 39, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    return key, st


# ------------------------------------------------------------------ 3. Tunnel Trickle: inner-TBTB tri, common. Tunnel water blue, a leaf boat riding its head, smug.
def tunnel_trickle():
    key = 'pl-bvd-3'
    st = Sticker()
    core = (14, 24, 46, 46)
    body, holes = piece_blanks(core, n=('T', 'tri', 6, 3.4), e=('B', 'tri', 4, 2.9), s=('T', 'tri', -4, 3.4), w=('B', 'tri', 4, 2.9))
    st.part(body, tex=fill(key, body, 14, 24, 32, list(TUNNEL)), contour=True)
    st.blank_shade(body, holes, width=1)
    wave = body & shrink(body, 2) & (np.abs(CY - (43 + 1.2 * np.sin(XX * 0.8))) < 0.6)
    st.paint(wave, '#cfe8f0')
    st.stitch(body & (YY < 41), col='#cfe8f0', skip=grow(holes, 3))
    leaf_boat(st, 22, 25, w=8)
    drop(st, 50, 53, r=1.3)
    st.eye(18, 30, look=(1, 0), lid=2)
    st.eye(31, 30, look=(1, 0), lid=2)
    st.mouth('smirk', 26, 38)
    return key, st


# ------------------------------------------------------------------ 4. Damwall Logs: inner-TTTT double, uncommon. Sunlit log mustard, four log-end tabs with rings, moss, grumpy.
def damwall_logs():
    key = 'pl-bvd-4'
    st = Sticker()
    core = (18, 22, 45, 46)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 18, 22, 28, list(LOGY)), contour=True)
    grain = body & shrink(body, 3) & ((YY == 26) | (YY == 43)) & (XX > 20) & (XX < 43) & ((XX % 5) != 0)
    st.paint(grain, '#9a7432')
    st.stitch(body & shrink(body, 0), col=MOSS[2])                       # uncommon accent: moss green
    for cx, cy in ((32, 17.2), (51.2, 34.5), (32, 51.8), (12.8, 34.5)):
        log_end(st, cx, cy, 3.9, body)
    moss(st, 19, 23, w=6)
    st.eye(22, 30, lid=1)
    st.eye(35, 30, lid=1)
    st.paint(line([(21, 26), (26, 28)]) | line([(21, 27), (26, 29)]) | line([(35, 28), (40, 26)]) | line([(35, 29), (40, 27)]), UMBER)
    st.sprite(['.UUUU.', 'U....U'], 28, 39, {'U': UMBER}, solid=False)
    creak(st, 47, 22, 1)
    return key, st


# ------------------------------------------------------------------ 5. Lodge Door: inner-BBBB round, uncommon. Lodge maroon, a stick arch doorway round its peeking face, a poppy.
def lodge_door():
    key = 'pl-bvd-5'
    st = Sticker()
    core = (12, 18, 51, 51)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 3.0), e=('B', 'round', 2, 3.0), s=('B', 'round', 0, 3.0), w=('B', 'round', 2, 3.0))
    st.part(body, tex=fill(key, body, 12, 18, 40, list(LODGE)))
    st.blank_shade(body, holes)
    st.stitch(body, col=GOLD, skip=grow(holes, 3))                       # uncommon accent: the lodge lantern gold
    door = ellipse(31.5, 39, 11.5, 14) & (CY < 47.5) & shrink(body, 3)
    arch = door & ~ellipse(31.5, 39.5, 8.5, 11)
    st.paint(door, '#e0a868')
    st.paint(door & ~shift(door, 0, 2), '#b07a45')
    st.paint(door & (YY == 47), '#3f8fb0')                               # the waterline at its sill
    st.paint(arch, BARK[0])
    st.paint(arch & (((XX + YY) % 4) == 0), BARK[2])
    st.paint(door & ~arch & dil4(arch), '#5e3418')
    st.paint(arch & (CX < 31.5) & (CY < 32), '#b07a45')
    poppy(st, 46, 24)
    poppy(st, 17, 26)
    st.eye(24, 35, look=(-1, 1))
    st.eye(34, 35, look=(-1, 1))
    st.paint(rect(22, 42, 24, 42) | rect(38, 42, 40, 42), BLUSH)
    st.sprite(['U.U', '.U.'], 30, 43, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 6. Dam Captain: whimsy-beaver double, rare. A sitting chibi beaver in a captain's cap, flat tail tapping time.
def dam_captain():
    key = 'pl-bvd-6'
    st = Sticker()
    col, row = ROWS[key]['piece']
    flat_tail(st, 46, 45, 8.5, 4.4, -0.9)
    st.dots([(55, 34), (57, 36)], CREAM)                                 # beat marks: it keeps time
    st.extra[34, 55] = st.extra[36, 57] = True
    head = disc(29.5, 27, 12)
    ears = disc(19.5, 17.5, 3.2) | disc(39.5, 17.5, 3.2)
    bod = ellipse(29.5, 42.5, 13.5, 10)
    tab = knob('w', 'double', 44, 16.0, r=3.2)
    body = head | ears | bod | tab
    src = pic.sample(col, row, 15, 14, 30).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(CHEST[0])
    tex[src > 330] = hx(CHEST[1])
    tex = majority(tex, body, 3)
    st.part(body, tex=tex, contour=True)
    st.paint(disc(19.5, 17.5, 1.4) | disc(39.5, 17.5, 1.4), '#e9b98a')
    belly = ellipse(29.5, 44.5, 8.5, 7) & bod
    st.paint(belly, '#e9b98a')
    st.paint(belly & ~shift(belly, -1, -1), '#d9a660')
    muzzle = ellipse(29.5, 33, 6, 4)
    st.paint(muzzle, '#f2d6a7')
    st.stitch(bod & ~belly, col=GOLD_L)
    for x in (18, 36):
        st.part(ellipse(x + 2.5, 52, 4, 2.0), '#5e3418', d=1, contour=True)
    captain_cap(st, 29.5, 16, w=10)
    arc_eye(st, 20, 25)
    arc_eye(st, 34, 25)
    st.paint(rect(28, 30, 31, 31), UMBER)                                # nose
    st.paint(line([(26, 33), (29, 34)]) | line([(30, 34), (33, 33)]), UMBER)
    buck_teeth(st, 27, 35, h=3)
    st.paint(rect(17, 31, 19, 31) | rect(40, 31, 42, 31), BLUSH)
    st.sparkle(6, 6)
    st.sparkle(54, 8, big=False)
    st.sparkle(7, 50, big=False)
    return key, st


PALS = [willow_chew, paddletail_slap, tunnel_trickle, damwall_logs, lodge_door, dam_captain]

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
