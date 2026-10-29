"""Puzzle Pals: THE STANDING STONES (wonder, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-stnd-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_stnd.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
Wonder mood: dusk hill sprites, keyhole knobs. kit_lair parts used only as building blocks (PlacePic, rows, cell_fill,
calm_tones, tidy); everything else drawn here. Body = its own cell of game/assets/img/jigsaw/places/wonder-the-standing-stones.png,
calmed onto 2 tones of a pal-own family.
UNIQUENESS PASS (Joshua: every pal an individual):
  1 Spiral Scribble       slate stone violet          | a carved umber spiral on its cheek-side flank                  | sleepy lidded eyes, small smile
  2 Goldtip Twinkle       moss olive                  | a gold knob on its head with a twinkle glint                    | eyes glancing sideways, cat mouth
  3 Lilac Sprinkle        lilac                       | white star flecks sprinkled over it + grass tuft feet           | wide open eyes, toothy grin
  4 Mosscap Toppers       bright moss green (+ grey)  | a woolly moss hat with grey stone ears poking out               | two happy arcs, wide smile
  5 Buttercream Moonlight buttercream (+ indigo)      | a round moon face rim with stones ringing its chest             | eyes looking up, little o mouth
  6 Hollowtop Menhir      dusk indigo stone, moss cap | whimsy chibi menhir: moss cap, dark hollow, note, glow          | eyes shut humming, grin
Ring and Plus are mirror-symmetric (all knobs centred).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'wonder-the-standing-stones'
pic = PlacePic(SLUG)
ROWS = rows('pl-wonder-the-standing-stones-f29dd4')

SLATE = ('#6a6488', '#857ea0')
OLIVE = ('#6a7a3a', '#86964a')
LILAC = ('#a68ad0', '#c4aee4')
MOSS = ('#4e9a3c', '#6cba50')
CREAM = ('#f0e2a8', '#fbf0c6')
DUSK = ('#4a3c80', '#62529a')
MOSSCAP = '#5ca844'
HOLLOW = '#1e1830'
GREY = '#9a98a8'
BLUSH = '#f0a0a0'


def fill(key, body, x0, y0, size, tones):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, 3, 3)
    return calm_tones(t, body, tones)


def happy_arc(st, x, y):
    st.sprite(['.UUU.', 'U...U'], x, y, {'U': UMBER}, solid=False)


# 1. Spiral Scribble: corner-TT keyhole, common.
def spiral_scribble():
    key = 'pl-stnd-1'
    st = Sticker()
    core = (12, 18, 46, 54)
    body, holes = piece_blanks(core, s='F', w='F', n=('T', 'keyhole', -4, 3.6), e=('T', 'keyhole', 2, 3.6))
    st.part(body, tex=fill(key, body, 12, 10, 42, list(SLATE)), contour=True)
    st.stitch(body, col='#b0a8c8')
    sp = ['UUUUUU', 'U....U', 'U.UU.U', 'U..U.U', 'UUUU.U', '.....U', 'UUUUUU']
    st.sprite(sp, 33, 40, {'U': '#3a2e52'}, solid=False)
    st.eye(18, 28, lid=2)
    st.eye(30, 28, lid=2)
    st.mouth('smile', 23, 37)
    st.paint(rect(15, 36, 17, 36) | rect(35, 36, 37, 36), BLUSH)
    return key, st


# 2. Goldtip Twinkle: edge-TBB keyhole, common.
def goldtip_twinkle():
    key = 'pl-stnd-2'
    st = Sticker()
    core = (15, 22, 48, 52)
    body, holes = piece_blanks(core, s='F', n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 10, 38, list(OLIVE)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.part(disc(31.5, 12, 3.4), GOLD, d=1, contour=True)
    st.paint(rect(30, 10, 31, 11), "#fff3c8")
    st.sparkle(40, 8, big=False)
    st.eye(22, 30, look=(1, 0))
    st.eye(35, 30, look=(1, 0))
    st.mouth('cat', 29, 40)
    return key, st


# 3. Lilac Sprinkle: inner-TBTB keyhole, common.
def lilac_sprinkle():
    key = 'pl-stnd-3'
    st = Sticker()
    core = (15, 18, 48, 46)
    body, holes = piece_blanks(core, n=('T', 'keyhole', 0, 3.6), e=('B', 'keyhole', 0, 3.0), s=('T', 'keyhole', 0, 3.6),
                               w=('B', 'keyhole', 0, 3.0))
    st.part(body, tex=fill(key, body, 15, 10, 34, list(LILAC)), contour=True)
    st.blank_shade(body, holes, width=1)
    for (x, y) in ((19, 21), (43, 22), (24, 42), (40, 41), (32, 20), (18, 33), (45, 34)):
        st.paint(rect(x, y - 1, x, y + 1) | rect(x - 1, y, x + 1, y), '#ffffff')
    for x in (13, 46):
        st.paint(line([(x, 52), (x + 1, 47)]) | line([(x + 2, 52), (x + 3, 48)]) | line([(x + 4, 52), (x + 4, 47)]), '#4e8a3a')
    st.eye(21, 25)
    st.eye(37, 25)
    st.mouth('tooth', 29, 35)
    st.paint(rect(19, 33, 21, 33) | rect(42, 33, 44, 33), BLUSH)
    return key, st


# 4. Mosscap Toppers: inner-TTTT keyhole, uncommon (Plus, symmetric).
def mosscap_toppers():
    key = 'pl-stnd-4'
    st = Sticker()
    core = (18, 18, 45, 45)
    body = piece(core, n=('T', 'keyhole', 0, 3.6), e=('T', 'keyhole', 0, 3.6), s=('T', 'keyhole', 0, 3.6), w=('T', 'keyhole', 0, 3.6))
    st.part(body, tex=fill(key, body, 17, 17, 30, list(MOSS)), contour=True)
    cap = ellipse(31.5, 21, 12, 5) & (YY <= 23)
    st.part(cap, '#2f6a28', d=1, contour=True)
    for x in (22, 27, 32, 37, 41):
        st.paint(rect(x, 20, x, 20), '#8ad070')
    st.paint(rect(19, 24, 20, 26) | rect(43, 24, 44, 26), GREY)
    happy_arc(st, 22, 29)
    happy_arc(st, 37, 29)
    st.mouth('smile', 30, 34)
    st.paint(rect(21, 33, 23, 33) | rect(40, 33, 42, 33), BLUSH)
    return key, st


# 5. Buttercream Moonlight: inner-BBBB double, uncommon (Ring, symmetric).
def buttercream_moonlight():
    key = 'pl-stnd-5'
    st = Sticker()
    core = (10, 10, 53, 53)
    body, holes = piece_blanks(core, n=('B', 'double', 0, 3.4), e=('B', 'double', 0, 3.4), s=('B', 'double', 0, 3.4),
                               w=('B', 'double', 0, 3.4))
    body = body & ~(disc(10, 10, 4) & ~disc(14, 14, 4)) & ~(disc(54, 10, 4) & ~disc(50, 14, 4)) & \
        ~(disc(10, 54, 4) & ~disc(14, 50, 4)) & ~(disc(54, 54, 4) & ~disc(50, 50, 4))
    st.part(body, tex=fill(key, body, 10, 10, 44, list(CREAM)), contour=True)
    st.blank_shade(body, holes, width=1)
    st.stitch(body, col='#d8c070', skip=grow(holes, 3))
    st.paint(ellipse(31.5, 50, 16, 6) & body & (YY <= 47), '#5e9a58')
    for x in (20, 27, 35, 42):
        st.part(ellipse(x + 0.5, 40, 1.6, 3), DUSK[1], d=0, contour=True, shade=False)
    st.paint(rect(16, 27, 18, 27) | rect(45, 27, 47, 27), BLUSH)
    st.eye(21, 20, look=(0, -1))
    st.eye(38, 20, look=(0, -1))
    st.mouth('o', 31, 28)
    return key, st


# 6. Hollowtop Menhir: whimsy-menhir keyhole, rare.
def hollowtop_menhir():
    key = 'pl-stnd-6'
    st = Sticker()
    stone = ellipse(31.5, 22, 12, 10) | rect(20, 22, 43, 48)
    tab = knob('s', 'keyhole', 32, 49, r=2.4)
    sil = stone | tab
    st.part(sil, tex=fill(key, sil, 14, 12, 38, list(DUSK)), contour=True)
    cap = ellipse(31.5, 15, 13, 5) & (YY <= 18)
    st.part(cap, MOSSCAP, d=1, contour=True)
    st.part(ellipse(31.5, 12, 4, 2), HOLLOW, d=0, contour=False, shade=False)
    st.paint(rect(22, 16, 22, 19) | rect(40, 16, 40, 20), MOSSCAP)
    st.paint(rect(23, 40, 26, 41) | rect(37, 36, 40, 37), '#3a2e66')
    st.eye(23, 26, lid=3)
    st.eye(36, 26, lid=3)
    st.mouth('grin', 29, 33)
    st.paint(rect(21, 32, 23, 32) | rect(41, 32, 43, 32), BLUSH)
    st.sprite(['..UU', '..U.', '..U.', 'UUU.', 'UU..'], 50, 24, {'U': '#ffe9a0'}, solid=False)
    st.sparkle(8, 8)
    st.sparkle(51, 8, big=False)
    st.sparkle(8, 42, big=False)
    return key, st


PALS = [spiral_scribble, goldtip_twinkle, lilac_sprinkle, mosscap_toppers, buttercream_moonlight, hollowtop_menhir]

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
        print('%-10s %-19s %-9s %-16s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                   ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
