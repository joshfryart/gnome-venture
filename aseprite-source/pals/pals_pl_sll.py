"""Puzzle Pals: SNOWLEOPARD LEDGES (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-sll-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_sll.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Delve mood: cosy-curious cave and cliff beasts, never scary. Built on palib + kit_lair (building blocks only: PlacePic, rows, cell_fill,
calm_tones, tidy). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/delve-snowleopard-ledges.png, calmed onto 2 tones of a pal-own colour family so the face reads.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Cairn Stack      cairn slate grey          | 3 pebbles balanced on its head (tilted), stone seams, wobble marks | shy: eyes aside, blush, tiny smile
  2 Ledge Hop        dawn peach                | wool-wrapped walking stick, pawprint trail, mid-hop paws + motion   | cheeky wink, toothy grin
  3 Ichu Whisker     ichu gold                 | tuft of golden grass on its head, one blade tickling down           | mid-sneeze: squeezed >< eyes, round o
  4 Woolly Pennants  pennant-sky lavender (+ wool red) | a 4-colour wool bunting across its brow, wind lines, tassels | grumpy brows, frown
  5 Snowcap Scoop    peak cobalt (+ snow cream)| a snow-scoop top with sprinkles and a wafer stick                   | smug half lids, tongue-out smirk
  6 Fluffytail Snow Leopard  snow white + grey rosettes (rare) | whimsy-fluffytail: curled leopard wrapped in its fluffy tail | asleep, :3 muzzle
Blanks mirror-placed (e and w at the same height); the Plus is centred on all 4 sides.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-snowleopard-ledges'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-snowleopard-ledges-9a49a1')

SLATE = ('#767a8c', '#9498aa')
PEACH = ('#e2927e', '#f0ae98')
ICHU = ('#c4862a', '#d8a244')
LAV = ('#8e76b4', '#a892c8')
COBALT = ('#3a4ab8', '#5262cc')
SNOW = ('#c8c8d4', '#e8e8f0')
PEBBLES = ('#a48ac0', '#d8b888', '#8b8f96')
WOOD = ('#a86a3a', '#7a4a24', '#c88a58', '#4a2c1a')
WOOL = ('#d8343a', '#f08a24', '#3c9aa8', '#e86a9c')
WAFER = ('#e0b070', '#b8844a')
ROSETTE = ('#4e5266', '#a4a8b8')
BLUSH = '#f0a0a0'
PINK = '#e86a9c'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0, k=3, passes=3):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, k, passes, dx, dy)
    return calm_tones(t, body, tones)


def extra_sprite(st, rows_, x, y, cmap):
    st.sprite(rows_, x, y, cmap, solid=False)
    for j, r in enumerate(rows_):
        for i, ch in enumerate(r):
            if ch not in '. ':
                st.extra[y + j, x + i] = True


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def pebble(st, cx, cy, rx, ry, col):
    m = ellipse(cx, cy, rx, ry)
    st.part(m, col, d=1, contour=True)
    st.paint(m & disc(cx - rx * 0.45, cy - ry * 0.45, 1.0), hexs(tone(hx(col), 'rim')))
    return m


def stone_seams(st, body, ys, avoid, col):
    """Wavy cairn seams across a body: it is a stack of flat stones."""
    for y0 in ys:
        m = body & (np.abs(CY - (y0 + 0.9 * np.sin(XX * 0.55))) < 0.5) & shrink(body, 2) & ~avoid
        st.paint(m, col)


def walking_stick(st, x0, y0, x1, y1):
    m = line([(x0, y0), (x1, y1)], w=2)
    st.part(m, WOOD[0], d=1, contour=True)
    wrap = m & (CY > y1 + 3) & (CY < y1 + 7)
    st.paint(wrap, WOOL[0])
    st.paint(wrap & ((YY % 2) == 0), '#f2e4c0')
    st.paint(rect(int(x1) - 1, int(y1) + 7, int(x1) - 1, int(y1) + 10), WOOL[0], solid=True)   # a tassel off the wrap
    return m


def pawprint(st, x, y):
    extra_sprite(st, ['C.C', '.C.'], x, y, {'C': '#fff3c8'})


def wink(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y + 2, {'U': UMBER}, solid=False)


def squeeze_eye(st, x, y, right=False):
    rows_ = ['UU...', '.UUU.', '...UU', '.UUU.', 'UU...']
    if right:
        rows_ = [r[::-1] for r in rows_]
    st.sprite(rows_, x, y, {'U': UMBER}, solid=False)


def grass_tuft(st, bx, by):
    """Ichu tuft: 5 springy golden blades from one root, the long one arcing over and down."""
    blades = [[(bx, by), (bx - 4, by - 7)], [(bx, by), (bx - 1, by - 10)], [(bx + 1, by), (bx + 4, by - 9)],
              [(bx + 1, by), (bx + 7, by - 8), (bx + 11, by - 8), (bx + 13, by - 5)]]
    m = blank()
    for b in blades:
        m |= line(b, w=2)
    st.part(m, '#f4e08c', d=0, contour=True)
    tips = blank()
    for b in blades:
        tips |= disc(b[-1][0] + 0.5, b[-1][1] + 0.5, 1.2)
    st.paint(tips & m, '#fff3c8')
    st.paint(line([(bx - 3, by), (bx + 4, by)], w=2), '#b07a20', solid=True)   # the root clump
    return m


def bunting(st, x0, x1, y, sag=3):
    """A wool bunting garland: a sagging cream string with four woven pennants (red, orange, teal, pink) and tassel ends."""
    pts = [(x, y + sag * (1 - ((x - (x0 + x1) / 2) / ((x1 - x0) / 2)) ** 2)) for x in np.linspace(x0, x1, 12)]
    st.paint(line(pts), CREAM, solid=True)
    n = 4
    for i in range(n):
        cx = x0 + (x1 - x0) * (i + 0.5) / n
        ty = y + sag * (1 - ((cx - (x0 + x1) / 2) / ((x1 - x0) / 2)) ** 2)
        tri = poly([(cx - 3.2, ty), (cx + 3.2, ty), (cx, ty + 6.5)])
        st.part(tri, WOOL[i], d=1, contour=True)
        st.paint(tri & ((XX + YY) % 3 == 0) & shrink(tri, 1), hexs(tone(hx(WOOL[i]), 'rim')))     # woven texture
    for ex in (x0, x1):
        st.paint(rect(int(ex), int(y), int(ex), int(y) + 3), WOOL[0], solid=True)
    return pts


def wind_lines(st, pts):
    for (x, y, L) in pts:
        extra_sprite(st, ['C' * L], x, y, {'C': '#e8e8f0'})


def snow_scoop(st, body, y):
    """Snow-scoop top: everything in the body above a scalloped scoop lip is snow cream, with a ridged lip and wool sprinkles."""
    lip = y + 1.3 * np.cos(XX * 1.05)
    m = body & (CY < lip)
    st.paint(m, '#f4f2fa')
    st.paint(m & ~shift(m, 0, -1), '#cfd2e6')
    st.paint(m & ~shift(m, 0, -2) & shift(m, 0, -1), '#e2e2f0')
    st.paint(m & ~shift(m, 1, 1) & shrink(m, 0), '#ffffff')
    sprinkles = [(20, 25, 0), (27, 22, 2), (33, 26, 3), (38, 23, 1), (24, 29, 1), (36, 29, 0), (30, 17, 3)]
    for x, yy, c in sprinkles:
        if m[yy, x] and m[yy, x + 1]:
            st.paint(rect(x, yy, x + 1, yy), WOOL[c])
    return m


def wafer(st, x0, y0, x1, y1):
    m = line([(x0, y0), (x1, y1)], w=3)
    st.part(m, WAFER[0], d=1, contour=True)
    st.paint(m & ((XX + YY) % 3 == 0), WAFER[1])
    return m


def closed_arc(st, x, y):
    st.sprite(['U...U', '.UUU.'], x, y, {'U': UMBER}, solid=False)


def nub_feet(st, xs, y, col):
    for x in xs:
        st.part(ellipse(x + 2.5, y + 1.5, 3, 2), col, d=1, contour=True)


def rosette(st, cx, cy, mask):
    """Snow-leopard rosette: a broken ring of 4 dark dots round a lighter centre."""
    for j, r in enumerate(['DD.', 'DLD', '.DD']):
        for i, ch in enumerate(r):
            x, y = cx - 1 + i, cy - 1 + j
            if ch != '.' and mask[y, x]:
                st.px[y, x] = hx(ROSETTE[0] if ch == 'D' else ROSETTE[1])


# ------------------------------------------------------------------ 1. Cairn Stack: corner-TT round, common. Slate grey stone stack, three pebbles balanced on its head, shy.
def cairn_stack():
    key = 'pl-sll-1'
    st = Sticker()
    core = (12, 25, 44, 49)
    body = piece(core, n=('T', 'round', -6, 3.8), e=('T', 'round', 3, 3.8))
    st.part(body, tex=fill(key, body, 12, 25, 33, list(SLATE)), contour=True)
    stone_seams(st, body, [43.5], rect(0, 0, 63, 41), '#62667a')
    st.stitch(body, col='#c8c0dc')
    pebble(st, 35.5, 22, 6, 2.8, PEBBLES[0])
    pebble(st, 37.5, 17.4, 4.6, 2.3, PEBBLES[1])
    pebble(st, 35.8, 13.3, 3.0, 1.9, PEBBLES[2])
    extra_sprite(st, ['C.', '.C', '.C', 'C.'], 44, 12, {'C': CREAM})        # wobble marks
    extra_sprite(st, ['.C', 'C.', 'C.', '.C'], 28, 12, {'C': CREAM})
    nub_feet(st, [16, 34], 49, '#585c6e')
    st.eye(17, 31, look=(-1, 1))
    st.eye(30, 31, look=(-1, 1))
    st.paint(rect(15, 38, 17, 38) | rect(34, 38, 36, 38), BLUSH)
    st.sprite(['U.U', '.U.'], 25, 39, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 2. Ledge Hop: edge-BTB peg, common. Dawn peach, mid-hop on tiny paws, a wool-wrapped walking stick, cheeky wink.
def ledge_hop():
    key = 'pl-sll-2'
    st = Sticker()
    core = (12, 22, 42, 45)
    body, holes = piece_blanks(core, s='F', n=('B', 'peg', 0, 3.0), e=('T', 'peg', 1, 3.4), w=('B', 'peg', 1, 3.0))
    walking_stick(st, 52, 53, 50, 17)
    st.part(body, tex=fill(key, body, 12, 22, 31, list(PEACH)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#fbe0c8', skip=grow(holes, 3))
    for x in (17, 31):                                                      # dangling hind paws, toes curled
        p = ellipse(x + 2.5, 47.5, 3, 2)
        st.part(p, '#c87a6a', d=1, contour=True)
        st.dots([(x + 1, 48), (x + 3, 48)], PINK)
    st.part(ellipse(49.5, 34, 2.4, 2.4), '#c87a6a', d=1, contour=True)      # a paw gripping the stick
    extra_sprite(st, ['CCC.CC'], 14, 53, {'C': '#fff3c8'})                  # hop motion lines
    extra_sprite(st, ['CC.CCC'], 30, 54, {'C': '#fff3c8'})
    pawprint(st, 5, 18)
    pawprint(st, 9, 13)
    pawprint(st, 14, 9)
    st.eye(17, 28, look=(1, -1))
    wink(st, 30, 28)
    st.mouth('tooth', 23, 37)
    return key, st


# ------------------------------------------------------------------ 3. Ichu Whisker: inner-TBTB tri, common. Ichu gold, a grass tuft on its head, one blade tickles: mid-sneeze.
def ichu_whisker():
    key = 'pl-sll-3'
    st = Sticker()
    core = (15, 25, 46, 48)
    body, holes = piece_blanks(core, n=('T', 'tri', -7, 3.2), e=('B', 'tri', 3, 2.8), s=('T', 'tri', 2, 3.4), w=('B', 'tri', 3, 2.8))
    st.part(body, tex=fill(key, body, 15, 25, 32, list(ICHU), k=2, passes=5), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#fbe8b0', skip=grow(holes, 3))
    grass_tuft(st, 31, 25)
    for x in (17, 37):
        sh = rect(x, 50, x + 6, 53)
        sh[50, x] = sh[50, x + 6] = False
        st.part(sh, '#6a4a8a', d=1, contour=True)                            # violet felt boots (the dusk mountain)
    squeeze_eye(st, 19, 31)
    squeeze_eye(st, 34, 31, right=True)
    st.sprite(['.UUU.', 'URRRU', 'URRRU', '.UUU.'], 28, 39, {'U': UMBER, 'R': MOUTH_RED}, solid=False)
    st.paint(rect(17, 38, 19, 38) | rect(39, 38, 41, 38), '#e86a5a')
    extra_sprite(st, ['C', 'C', '.', 'C'], 12, 13, {'C': CREAM})             # startle marks
    extra_sprite(st, ['C..', '.C.', '..C'], 15, 17, {'C': CREAM})
    return key, st


# ------------------------------------------------------------------ 4. Woolly Pennants: inner-TTTT double, uncommon. Lavender, a 4-colour wool bunting across its brow, grumpy in the wind.
def woolly_pennants():
    key = 'pl-sll-4'
    st = Sticker()
    core = (17, 24, 45, 48)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 17, 24, 29, list(LAV)), contour=True)
    st.stitch(body, col=WOOL[0])                                             # uncommon accent: the wool red
    bunting(st, 15, 47, 23, sag=3)
    wind_lines(st, [(7, 17, 4), (6, 22, 3), (52, 15, 4)])
    st.eye(20, 32, lid=1)
    st.eye(33, 32, lid=1)
    st.paint(line([(19, 30), (24, 31)]) | line([(33, 31), (38, 30)]), UMBER)
    st.sprite(['.UUUU.', 'U....U'], 26, 41, {'U': UMBER}, solid=False)
    return key, st


# ------------------------------------------------------------------ 5. Snowcap Scoop: inner-TTBB round, uncommon. Peak cobalt with a snow-scoop top, sprinkles, a wafer, smug and licking.
def snowcap_scoop():
    key = 'pl-sll-5'
    st = Sticker()
    core = (13, 25, 45, 50)
    body, holes = piece_blanks(core, n=('T', 'round', 0, 3.8), e=('T', 'round', 2, 3.6), s=('B', 'round', -2, 3.0), w=('B', 'round', 6, 3.0))
    wafer(st, 39, 24, 45, 12)
    st.part(body, tex=fill(key, body, 13, 25, 33, list(COBALT)), contour=True)
    st.blank_shade(body, holes, width=1)
    snow_scoop(st, body, 30)
    st.stitch(body & (YY > 32), col='#cfd8f4', skip=grow(holes, 3))          # uncommon accent: snow cream
    st.eye(20, 34, look=(1, 0), lid=2)
    st.eye(32, 34, look=(1, 0), lid=2)
    st.sprite(['.....U', 'UUUUU.', '...PP.', '...P..'], 23, 43, {'U': UMBER, 'P': PINK}, solid=False)
    st.paint(rect(17, 40, 19, 40) | rect(37, 40, 39, 40), BLUSH)
    return key, st


# ------------------------------------------------------------------ 6. Fluffytail Snow Leopard: whimsy-fluffytail peg, rare. A snow leopard curled asleep in its own huge fluffy tail.
def fluffytail():
    key = 'pl-sll-6'
    st = Sticker()
    curl = ellipse(35, 37, 14, 11)                                           # the curled body
    head = disc(22, 31, 9.5)
    ears = disc(15.5, 23.5, 2.6) | disc(28.5, 23, 2.6)
    tab = knob('n', 'peg', 40, 26.6, r=2.8)
    body = curl | head | ears | tab
    t = cell_fill(pic, ROWS[key]['piece'], body, 12, 18, 40, 2, 4)
    st.part(body, tex=calm_tones(t, body, list(SNOW)), contour=True)
    for x, y in ((38, 31), (45, 33), (35, 36), (41, 39), (47, 39), (33, 29)):
        rosette(st, x, y, shrink(curl, 1) & ~head)
    st.paint(ears & shrink(ears, 1) & ~head, '#f0b4c0')
    st.stitch(curl & ~head & (CY < 42), col='#fff3c8')
    tail = blank()                                                           # the big fluffy tail wraps round the front, tip up by the chin
    path = [(47, 41), (48, 46), (44, 50), (37, 52), (30, 52), (23, 50), (17, 46), (14, 41)]
    for i, (x, y) in enumerate(path):
        tail |= disc(x, y, 4.2 + 0.5 * (i % 2) + (0.3 if i == len(path) - 1 else 0))
    st.part(tail, '#b8bccc', d=2, contour=True)
    st.paint(tail & ~shrink(tail, 1) & (((XX + YY) % 3) == 0) & (CY > 44), '#f4f4fa')   # tufted fur edge
    for x, y in ((45, 45), (38, 49), (30, 49), (23, 47)):
        rosette(st, x, y, shrink(tail, 1))
    st.paint(tail & disc(13.5, 39.5, 3.4), '#ffffff')                        # the white tail tip
    st.paint(ellipse(22, 35.5, 4.6, 2.8) & head, '#fbf4ea')                  # muzzle
    closed_arc(st, 15, 30)
    closed_arc(st, 24, 30)
    st.sprite(['PPP', '.P.'], 21, 33, {'P': PINK}, solid=False)
    st.sprite(['U.U.U', '.U.U.'], 20, 35, {'U': UMBER}, solid=False)
    st.paint(rect(13, 34, 14, 34) | rect(29, 34, 30, 34), BLUSH)
    st.paint(rect(14, 37, 16, 37) | rect(28, 37, 30, 37), '#9a9eae')        # whiskers
    zzz(st, 31, 12)
    st.sparkle(51, 10)
    st.sparkle(9, 10, big=False)
    st.sparkle(56, 28, big=False)
    st.px = np.roll(st.px, -2, axis=0)                                       # nudge up 2 px for the bottom margin (top rows are empty)
    st.sil = shift(st.sil, 0, -2)
    st.extra = shift(st.extra, 0, -2)
    return key, st


PALS = [cairn_stack, ledge_hop, ichu_whisker, woolly_pennants, snowcap_scoop, fluffytail]

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
        print('%-10s %-24s %-9s %-18s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
