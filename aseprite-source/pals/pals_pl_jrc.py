"""Puzzle Pals: JAGUAR ROOT CAVES (delve, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-jrc-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_jrc.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Built on palib + kit_lair (building blocks only). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/delve-jaguar-root-caves.png, calmed onto 2 tones of a pal-own colour family so the face reads.
Delve mood: cute cave beasts and the dark's small treasures, cosy-curious, never scary.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Rosette Nub     cinnamon rosette rust       | 3 jaguar rosettes, a firefly over it, curly tail nub, purr marks | happy closed ^^ eyes, cat :3, blush
  2 Rootlet Swing   cave violet                 | swings from a hanging root (ceiling clump), kicking boots       | cheeky wink, open grin
  3 Glowcap Nibble  glow-mushroom aqua          | tilted glowcap hat with a bite out of it, glow motes, zzz       | sleepy heavy lids, big yawn
  4 Softpad Prints  root-path sand (+ umber)    | a paw print on each of the 4 tabs, all pointing right, ! mark   | startled ring eyes, tiny o, raised brows
  5 Sunspill Arch   jungle green (+ sun yellow) | sunglasses, sun rising behind it, cream whiskers, leaf sprout     | smug smirk behind shades
  6 Boulder Jaguar  jaguar gold (rare)          | whole sitting chibi jaguar: round ears, rosettes, curled tail, mossy boulder | serious: slit cat eyes, brows, muzzle
Plus and Ring pals: knobs centred (n/s at 0, e/w at the same height). The jaguar has no mane and a full sitting body (not the lion head).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'delve-jaguar-root-caves'
pic = PlacePic(SLUG)
ROWS = rows('pl-delve-jaguar-root-caves-0a418b')

CINNAMON = ('#a8582f', '#c0703e')
VIOLETC = ('#76568a', '#8e6ea2')
AQUA = ('#4aa8ac', '#6cc6c0')
SANDP = ('#c9a96e', '#dcc08a')
JUNGLE = ('#6aa652', '#82bc68')
JAG = ('#e8a317', '#f5b840')
ROSE_D = '#5a2a14'
ROOT = ('#c08038', '#8a5424', '#e0a85a', '#5a3a2a')
CEIL = ('#5a3a2a', '#3e2618', '#7a5238', '#2a1a10')
CAP = ('#d8f4dc', '#3a9ab0', '#fbffe8', '#246a80')
SUN = ('#f8d860', '#e8a317', '#fff3c8')
LEAF = ('#4a8a3e', '#356a2e', '#7ab55c', '#24402c')
SLATE = ('#6a6878', '#48474f', '#8e8c9c', '#2e2e38')
MOSS = ('#7ab55c', '#4a8a3e')
PRINT = '#5a3018'
BLUSH = '#f0a0a0'
GLOW = '#c8ecdc'


def fill(key, body, x0, y0, size, tones, dx=0.0, dy=0.0):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3, dx, dy)
    return calm_tones(t, body, tones)


def extra_sprite(st, rows_, x, y, cmap):
    st.sprite(rows_, x, y, cmap, solid=False)
    for j, r in enumerate(rows_):
        for i, ch in enumerate(r):
            if ch not in '. ':
                st.extra[y + j, x + i] = True


# ---------------------------------------------------------------- own helpers (drawn for this roster)
def rosette(st, cx, cy, r=2.6, ring=ROSE_D, core=None):
    """A jaguar rosette: a broken dark ring (3 arcs) round a slightly deeper centre."""
    ang = np.arctan2(CY - cy, CX - cx)
    rg = disc(cx, cy, r) & ~disc(cx, cy, r - 1.5) & ((np.floor((ang + np.pi) / (np.pi / 3)).astype(int) % 2 == 0) | (np.abs(ang) < 0.5))
    if core:
        st.paint(disc(cx, cy, r - 1.15), core)
    st.paint(rg, ring)
    return rg


def happy_eye(st, x, y):
    st.sprite(['.UUUU.', 'UU..UU', 'U....U'], x, y, {'U': UMBER}, solid=False)


def firefly(st, x, y):
    extra_sprite(st, ['c.c', '.U.', 'yYy', '.y.'], x, y, {'c': CREAM, 'U': UMBER, 'y': '#d8f070', 'Y': '#fbffc8'})


def hanging_root(st, pts):
    m = line(pts, w=2)
    st.part(m, ROOT[0], d=1, contour=True)
    st.paint(line(pts, w=1) & m, ROOT[2])
    return m


def ceiling_clump(st, x0, x1, y0, y1):
    m = ellipse((x0 + x1) / 2, (y0 + y1) / 2, (x1 - x0) / 2, (y1 - y0) / 2)
    st.part(m, CEIL[0], d=1, contour=True)
    st.paint(m & (YY == int(y0) + 1) & shrink(m, 1), CEIL[2])
    return m


def boot(st, x, y, w=6, h=4, col=SHOE[0]):
    sh = rect(x, y, x + w - 1, y + h - 1)
    sh[y, x] = sh[y, x + w - 1] = False
    st.part(sh, col, d=1, contour=True)
    return sh


def glowcap(st, cx, cy, rx=11, ry=7, lean=0.0):
    """A glow mushroom cap worn as a hat: dome, cream gill band, pale spots, and a round bite nibbled out of its right edge."""
    dome = ellipse(cx, cy, rx, ry) & (CY < cy + 0.5 + lean * (CX - cx))
    dome &= ~disc(cx + rx - 0.5, cy - ry * 0.45, 2.6)
    gill = dome & (CY >= cy - 1 + lean * (CX - cx))
    st.part(dome, CAP[0], d=1, contour=True)
    st.paint(gill, '#7ac0c0')
    st.paint(gill & (XX % 2 == 0), '#5aa0a8')
    for sx, sy in ((cx - 6, cy - 3), (cx, cy - 6), (cx + 4, cy - 3), (cx - 2, cy - 2)):
        st.paint(disc(sx, sy, 1.4) & shrink(dome, 1) & ~gill, '#6cc6d0')
    return dome


def yawn(st, x, y):
    st.sprite(['.UUU.', 'URRRU', 'URRRU', '.UUU.'], x, y, {'U': UMBER, 'R': MOUTH_RED}, solid=False)


def paw_print(st, x, y, col=PRINT):
    """A soft paw print pointing right: a 3 x 3 pad and 3 toe beans ahead of it."""
    st.sprite(['...TT', '.P...', 'PPP.T', 'PPPPT', 'PPP.T', '.P...', '...TT'], x, y, {'P': col, 'T': col}, solid=False)


def ring_eye(st, x, y):
    """Startled eye: a 6 x 6 round cream eye in an umber ring with a tiny 2 x 2 pupil (wide awake)."""
    e = ellipse(x + 3, y + 3, 3.2, 3.2)
    st.paint(grow(e, 1), UMBER)
    st.paint(e, CREAM)
    st.paint(rect(x + 2, y + 2, x + 3, y + 3), UMBER)


def sunglasses(st, x, y):
    lens = ['LLLLLLL', 'LggLLLL', 'LgLLLLL', 'LLLLLLL', '.LLLLL.']
    for lx in (x, x + 10):
        st.sprite(lens, lx, y, {'L': '#24202c', 'g': '#8a9ac8'}, solid=False)
    st.paint(rect(x + 7, y + 1, x + 9, y + 1), '#24202c')
    st.paint(rect(x - 2, y, x - 1, y) | rect(x + 17, y, x + 18, y), '#24202c')


def sun(st, cx, cy, r=5.5):
    for k in range(8):
        a = math.radians(k * 45 + 22.5)
        st.paint(line([(cx + (r + 1.5) * math.cos(a), cy + (r + 1.5) * math.sin(a)), (cx + (r + 3.2) * math.cos(a), cy + (r + 3.2) * math.sin(a))]),
                 SUN[0], solid=True)
    m = disc(cx, cy, r)
    st.part(m, SUN[0], d=1, contour=True)
    st.paint(disc(cx - 1.5, cy - 1.5, 1.5), SUN[2])
    return m


def leaf_sprout(st, x, y):
    st.paint(line([(x, y), (x, y - 4)]), LEAF[1], solid=True)
    m = ellipse(x + 3.5, y - 5.5, 3.5, 2) | ellipse(x - 3, y - 4, 2.8, 1.6)
    st.part(m, LEAF[0], d=1, contour=True)
    st.paint(line([(x + 1, y - 5), (x + 6, y - 6)]) & m, LEAF[2])
    return m


def cat_eye(st, x, y):
    """Jaguar eye: 5 x 5 round amber-green iris in an umber socket, vertical slit pupil, glint."""
    e = ellipse(x + 2.5, y + 2.5, 2.8, 2.8)
    st.paint(grow(e, 1), UMBER2)
    st.paint(e, '#b8d050')
    st.paint(e & (YY >= y + 3), '#8aa83a')
    st.paint(rect(x + 2, y, x + 2, y + 4), UMBER)
    st.dots([(x + 1, y + 1)], CREAM)


# ------------------------------------------------------------------ 1. Rosette Nub: corner-BB round, common. A cinnamon rosette lost in the roots, purring.
def rosette_nub():
    key = 'pl-jrc-1'
    st = Sticker()
    core = (14, 22, 47, 48)
    body, holes = piece_blanks(core, e=('B', 'round', 2, 3.2), s=('B', 'round', -3, 3.2))
    # curly tail nub off the west side
    tail = line([(14, 40), (10, 39), (8, 36), (9, 33), (12, 33)], w=3)
    st.part(tail, CINNAMON[1], d=1, contour=True)
    st.paint(line([(9, 34), (12, 33)], w=1), ROSE_D)
    st.part(body, tex=fill(key, body, 14, 22, 34, list(CINNAMON)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#f0c890', skip=grow(holes, 3))
    for cx, cy, r in ((19.5, 27.5, 3.2), (42.5, 27.5, 2.8), (39.5, 43.5, 3.4)):
        rosette(st, cx, cy, r, core='#d8925a')
    happy_eye(st, 20, 31)
    happy_eye(st, 33, 31)
    st.paint(rect(18, 36, 20, 36) | rect(37, 36, 39, 36), BLUSH)
    st.mouth('cat', 27, 37)
    firefly(st, 41, 10)
    extra_sprite(st, ['.c.c', 'c.c.'], 52, 20, {'c': CREAM})          # purr marks
    extra_sprite(st, ['.c.c', 'c.c.'], 54, 25, {'c': CREAM})
    return key, st


# ------------------------------------------------------------------ 2. Rootlet Swing: edge-TBB peg, common. Cave violet, swinging from a hanging root, cheeky.
def rootlet_swing():
    key = 'pl-jrc-2'
    st = Sticker()
    branch = line([(8, 9), (14, 7), (21, 8), (28, 7), (35, 8), (42, 7)], w=3)   # a gnarly root running along the cave roof
    st.part(branch, ROOT[1], d=1, contour=True)
    st.paint(line([(8, 8), (14, 6), (21, 7), (28, 6), (35, 7), (42, 6)]) & branch, ROOT[0])
    hanging_root(st, [(20, 9), (24, 13), (29, 16), (33, 18)])            # the swing root, slanted mid-swing
    hanging_root(st, [(12, 9), (12, 13), (11, 15)])                       # two short rootlets dangling off it
    hanging_root(st, [(40, 9), (41, 12)])
    core = (18, 26, 47, 48)
    body, holes = piece_blanks(core, n=('T', 'peg', 2, 3.4), e=('B', 'peg', 3, 2.8), w=('B', 'peg', 3, 2.8))
    st.part(body, tex=fill(key, body, 18, 26, 30, list(VIOLETC)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#c8b0dc', skip=grow(holes, 3))
    for hx_, hy in ((28, 19), (38, 19)):                                  # paws gripping the root on top of the tab
        st.part(ellipse(hx_, hy, 2.4, 1.8), VIOLETC[1], d=1, contour=True)
    boot(st, 20, 49, 6, 4)
    boot(st, 39, 47, 6, 4)                                               # one boot kicked up
    st.eye(22, 31, look=(1, 0))
    st.sprite(['UU...', '..UU.', '....U', '..UU.', 'UU...'], 35, 31, {'U': UMBER}, solid=False)   # the wink
    st.mouth('grin', 29, 39)
    st.paint(rect(20, 38, 22, 38), BLUSH)
    return key, st


# ------------------------------------------------------------------ 3. Glowcap Nibble: inner-TBTB tri, common. Glow aqua, a nibbled glowcap hat, sleepy.
def glowcap_nibble():
    key = 'pl-jrc-3'
    st = Sticker()
    core = (15, 26, 46, 48)
    body, holes = piece_blanks(core, n=('T', 'tri', -8, 3.0), e=('B', 'tri', 4, 2.8), s=('T', 'tri', 1, 3.0), w=('B', 'tri', 4, 2.8))
    st.part(body, tex=fill(key, body, 15, 26, 32, list(AQUA)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body & (YY > 29), col=GLOW, skip=grow(holes, 3))
    stalk = rect(36, 19, 39, 27)
    st.part(stalk, '#eef8e8', d=1, contour=True)                         # a glowcap growing out of its head
    glowcap(st, 37.5, 19, 8.5, 6.5, lean=0.0)
    st.paint(line([(33, 29), (35, 27), (38, 28)]), AQUA[0])
    st.eye(20, 33, lid=3)
    st.eye(33, 33, lid=3)
    st.paint(line([(20, 32), (24, 33)]) | line([(33, 33), (37, 32)]), UMBER)   # droopy lid creases
    yawn(st, 28, 40)
    for x, y in ((8, 22), (52, 36), (11, 44)):
        extra_sprite(st, ['.g.', 'gWg', '.g.'], x, y, {'g': '#8ad8cc', 'W': '#eefaf6'})
    zzz(st, 49, 10)
    return key, st


# ------------------------------------------------------------------ 4. Softpad Prints: inner-TTTT double, uncommon. Path sand, a paw print on each tab, startled.
def softpad_prints():
    key = 'pl-jrc-4'
    st = Sticker()
    core = (18, 22, 45, 49)
    body = piece(core, n=('T', 'double', 0, 3.4), e=('T', 'double', 0, 3.4), s=('T', 'double', 0, 3.4), w=('T', 'double', 0, 3.4))
    st.part(body, tex=fill(key, body, 18, 22, 28, list(SANDP)), contour=True)
    st.stitch(body, col=ROOT[0])                                         # uncommon accent: the root gold
    for x, y in ((29, 12), (49, 32), (29, 51), (10, 32)):                # one print on each tab, all pointing at the cave mouth (right)
        paw_print(st, x, y)
    ring_eye(st, 22, 30)
    ring_eye(st, 34, 30)
    st.paint(line([(21, 26), (23, 25), (26, 26)]) | line([(34, 26), (37, 25), (39, 26)]), UMBER)
    st.mouth('o', 30, 40)
    extra_sprite(st, ['W', 'W', 'W', '.', 'W'], 54, 13, {'W': CREAM})
    return key, st


# ------------------------------------------------------------------ 5. Sunspill Arch: inner-BBBB round, uncommon. Jungle green, sunbathing in shades, smug.
def sunspill_arch():
    key = 'pl-jrc-5'
    st = Sticker()
    sun(st, 14, 15, 4.4)
    core = (13, 20, 50, 53)
    body, holes = piece_blanks(core, n=('B', 'round', 0, 2.4), e=('B', 'round', 0, 2.4), s=('B', 'round', 0, 2.4), w=('B', 'round', 0, 2.4))
    st.part(body, tex=fill(key, body, 15, 22, 35, list(JUNGLE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col=SUN[0], skip=grow(holes, 3))                       # uncommon accent: the sun yellow
    leaf_sprout(st, 44, 20)
    sunglasses(st, 22, 30)
    for y, dy in ((40, -1), (42, 0), (44, 1)):                            # warm cream whiskers
        st.paint(line([(19, y), (24, y + dy * 0 + 1)]) | line([(40, y + 1), (45, y + dy * 0)]), CREAM)
    st.mouth('smirk', 29, 41)
    return key, st


# ------------------------------------------------------------------ 6. Boulder Jaguar: whimsy-jaguar peg, rare. A sitting chibi jaguar on its mossy boulder, very serious.
def boulder_jaguar():
    key = 'pl-jrc-6'
    st = Sticker()
    # mossy boulder (with the peg tab on its west end)
    rock = ellipse(31, 50.5, 17, 4.2)
    rock |= knob('w', 'peg', 50.5, 15, r=2.3)
    st.part(rock, SLATE[0], d=1, contour=True)
    st.paint(rock & (YY <= 47), MOSS[0])
    st.paint(rock & (YY == 48) & ((XX % 3) != 0), MOSS[1])
    # tail curling up on the right
    tail = line([(39, 47), (46, 46), (50, 41), (50, 35), (47, 32)], w=3)
    st.part(tail, JAG[0], d=1, contour=True)
    st.paint(grow(rect(46, 32, 47, 33), 1) & tail, ROSE_D)
    st.paint(tail & ((XX + YY) % 6 == 0), ROSE_D)
    # body
    torso = ellipse(30, 38.5, 9.5, 8.5)
    ears = disc(19.5, 13.5, 3.8) | disc(40.5, 13.5, 3.8)
    head = ellipse(30, 23.5, 13, 10)
    sil = torso | head | ears
    t = cell_fill(pic, ROWS[key]['piece'], sil, 14, 10, 34, 3, 3)
    tex = calm_tones(t, sil, list(JAG))
    st.part(ears, tex=tex, d=1, contour=True)
    st.paint(disc(20, 14, 1.8) | disc(40, 14, 1.8), '#8a4a20')
    st.part(torso, tex=tex, d=2, contour=True)
    st.paint(ellipse(30, 41, 5, 5.5) & torso, CREAM)                    # belly
    st.part(head, tex=tex, d=2, contour=True)
    for cx, cy, r in ((22.5, 37.5, 3.0), (37.5, 37, 3.0), (20, 18, 2.6), (40, 18, 2.6), (30, 15.5, 2.4)):
        rosette(st, cx, cy, r, core='#c8781c')
    st.paint(ellipse(30, 29.5, 6, 4), CREAM)                            # muzzle
    st.sprite(['PPP', '.P.'], 29, 27, {'P': '#d8707a'}, solid=False)     # nose
    st.sprite(['U.U.U', '.U.U.'], 28, 30, {'U': UMBER}, solid=False)
    for px in (22, 33):                                                  # front paws on the boulder
        st.part(ellipse(px + 2.5, 46.5, 3.2, 2.2), JAG[1], d=1, contour=True)
        st.paint(rect(px + 2, 46, px + 2, 47) | rect(px + 4, 46, px + 4, 47), '#be6913')
    cat_eye(st, 20, 21)
    cat_eye(st, 35, 21)
    st.paint(line([(19, 19), (25, 20)]) | line([(35, 20), (41, 19)]), UMBER)    # very serious brows
    for y in (29, 31):
        st.paint(line([(19, y), (23, y)]) | line([(37, y), (41, y)]), CREAM)
    st.sparkle(6, 8)
    st.sparkle(53, 10, big=False)
    st.sparkle(55, 22, big=False)
    return key, st


PALS = [rosette_nub, rootlet_swing, glowcap_nibble, softpad_prints, sunspill_arch, boulder_jaguar]

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
