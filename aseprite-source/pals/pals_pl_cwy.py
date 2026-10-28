"""Puzzle Pals: FORGE OF THE CINDER WYRM (lair, Places) roster (6 pals) -> game/assets/img/puzzles/pals/pl-cwy-N.png (64 x 64, transparent).
Usage: python3 -B aseprite-source/pals/pals_pl_cwy.py [outdir]   (PAL_SHEET=<png> also writes a contact sheet)
First lair place, built from kit_lair (the shared lair parts). Silhouette = the row's shape + knob, body = its own 15 x 15 art px cell of
game/assets/img/jigsaw/places/lair-forge-of-the-cinder-wyrm.png, calmed onto 2 or 3 of the picture's own tones so the face reads.
Picture dominants: wall #672830 / #48242e, wyrm red #d6322b / #a8352e, shadow #3a1e2a; lava #f08a24 / #e0501f; purple sky #8c4a78.
Accessories from the motifs (forge, cinder, wyrm): a cinder cap, a slag drip, wyrm horns, back-spine crown with sparks, ash puffs, dragon wings.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from palib import *  # noqa: F401,F403,E402
from kit_lair import *  # noqa: F401,F403,E402

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else OUT
SLUG = 'lair-forge-of-the-cinder-wyrm'
pic = PlacePic(SLUG)
ROWS = rows('pl-lair-forge-of-the-cinder-wyrm-db3da4')

WALL, WALL_D, WALL_L = '#683638', '#582c34', '#784240'
RED, RED_D, RED_L = '#d6322b', '#b12d22', '#f2793a'
LAVA_O, LAVA_R, LAVA_L = '#f08a24', '#e0501f', '#f5b840'
SLAG = ('#f5b840', '#e8a317', '#fbe0a8', '#b07a10')
WYRM_HORN = ('#f08a24', '#e0501f', '#f5cf6a', '#b12d22')     # the wyrm's orange back spines
LILAC_ASH = ('#8a7a7a', '#6a5a5e', '#b098b0', '#48474f')


def fill(key, body, x0, y0, size, tones, k=3, passes=3, dx=0.0, dy=0.0, cuts=None):
    t = cell_fill(pic, ROWS[key]['piece'], body, x0, y0, size, k, passes, dx, dy)
    return calm_tones(t, body, tones, cuts)


# ------------------------------------------------------------------ 1. Ember Flake: corner-BB hook, common. Lava corner piece, flat foot + back, a cinder cap with glowing cracks.
def ember_flake():
    key = 'pl-cwy-1'
    st = Sticker()
    core = (11, 21, 44, 48)
    body, holes = piece_blanks(core, s='F', w='F', n=('B', 'hook', 6, 4.0), e=('B', 'hook', 5, 4.0))
    st.part(body, tex=fill(key, body, 11, 21, 34, [LAVA_R, LAVA_O]))
    st.blank_shade(body, holes)
    st.stitch(body, col=LAVA_L, skip=grow(holes, 3))
    claw_feet(st, [14, 33], 49)
    # the cinder that drifted off the wyrm's back, worn as a cap on the flat corner
    ember(st, 19, 19, r=7.0, lick=True)
    st.eye(15, 28, look=(1, 0))
    st.eye(27, 28, look=(1, 0))
    st.mouth('smile', 20, 37)
    return key, st


# ------------------------------------------------------------------ 2. Slag Drip: edge-TBB tri, common. Lava edge piece, glowing slag poured over its tri knob, drips running down.
def slag_drip():
    key = 'pl-cwy-2'
    st = Sticker()
    core = (13, 24, 44, 49)
    body, holes = piece_blanks(core, s='F', n=('T', 'tri', 0, 4.4), e=('B', 'tri', 3), w=('B', 'tri', 3))
    st.part(body, tex=fill(key, body, 13, 24, 32, [RED_D, LAVA_R], dy=0.1))
    st.blank_shade(body, holes)
    st.stitch(body, col=LAVA_O, skip=grow(holes, 3))
    claw_feet(st, [16, 34], 50)
    # slag: a gold cap over the knob with three slow drips
    cap = body & (CY < 23.5)
    for x, h in ((22, 3), (29, 5), (35, 2)):
        cap |= body & rect(x, 22, x + 2, 23 + h) & ~rect(x, 23 + h, x, 23 + h) & ~rect(x + 2, 23 + h, x + 2, 23 + h)
    st.paint(cap, SLAG[0])
    st.paint(cap & ~shift(cap, -1, -1), SLAG[1])
    st.paint(cap & ~shift(cap, 1, 1) & shift(cap, -1, -1), SLAG[2])
    st.sprite(['gG', 'GG', '.G'], 30, 53, {'G': SLAG[0], 'g': SLAG[2]})      # the drip that is taking its time
    st.eye(18, 31, look=(0, 1), lid=1)
    st.eye(32, 31, look=(0, 1), lid=1)
    st.mouth('o', 26, 40)
    return key, st


# ------------------------------------------------------------------ 3. Scorch Sliver: inner-TBBB peg, common. Wyrm-jaw piece, two little horns, a curl of smoke.
def scorch_sliver():
    key = 'pl-cwy-3'
    st = Sticker()
    core = (13, 23, 44, 50)
    body, holes = piece_blanks(core, n=('T', 'peg', -4), e=('B', 'peg', 2, 3.6), s=('B', 'peg', 0, 3.4), w=('B', 'peg', 2, 3.6))
    st.part(body, tex=fill(key, body, 13, 23, 32, [RED_D, RED]))
    st.blank_shade(body, holes)
    st.stitch(body, col=LAVA_O, skip=grow(holes, 3))
    claw_feet(st, [14, 37], 51, w=6, h=3)
    horn(st, 17, 22, h=7, lean=-0.9, w=5)
    horn(st, 40, 22, h=7, lean=0.5, w=5)
    puff(st, 51, 10, r=2.3, pal=LILAC_ASH, lobes=3)  # a curl of smoke drifting off, still smelling faintly
    # cheeky slanted brows over the eyes, spooky-cute
    st.eye(17, 31, look=(1, 0))
    st.eye(31, 31, look=(1, 0))
    st.paint(line([(16, 28), (21, 29)]) | line([(31, 29), (36, 28)]), UMBER)
    st.mouth('tooth', 23, 40)
    return key, st


# ------------------------------------------------------------------ 4. Spine Spark: inner-TTTT double, uncommon. Forge-wall plus, the wyrm's orange back spines as a crown, sparkler pops.
def spine_spark():
    key = 'pl-cwy-4'
    st = Sticker()
    core = (17, 23, 45, 48)
    body = piece(core, n=('T', 'double', 0, 4.0), e=('T', 'double'), s=('T', 'double'), w=('T', 'double'))
    st.part(body, tex=fill(key, body, 17, 23, 29, [WALL, WALL_L]))
    st.stitch(body, col=LAVA_L)                                  # uncommon accent: the spines' gold
    spike_crown(st, 18, 44, 22, n=4, h=5, pal=WYRM_HORN, tip=LAVA_L)
    st.eye(21, 30, look=(1, 0))
    st.eye(34, 30, look=(1, 0))
    st.mouth('grin', 27, 39)
    sparks(st, [(15, 11), (46, 12)], big=False)
    st.dots([(19, 13), (42, 14)], GOLD_L)
    return key, st


# ------------------------------------------------------------------ 5. Ash Wreath: inner-BBBB hook, uncommon. Cool lilac-ash ring, a crown of ash puffs, one tiny ember still hoping.
def ash_wreath():
    key = 'pl-cwy-5'
    st = Sticker()
    core = (11, 19, 50, 50)
    body, holes = piece_blanks(core, n=('B', 'hook', 0, 4.0), e=('B', 'hook', 0, 4.0), s=('B', 'hook', 0, 4.0), w=('B', 'hook', 0, 4.0))
    st.part(body, tex=fill(key, body, 11, 19, 40, [LILAC_ASH[0], LILAC_ASH[2]]))
    st.blank_shade(body, holes)
    st.stitch(body, col=LAVA_O, skip=grow(holes, 3))              # uncommon accent: ember orange
    claw_feet(st, [15, 40], 51)
    puff(st, 16, 18, r=3.2, pal=('#b3a8a6', '#938280', '#d0d5d5', '#6a5a5e'))
    puff(st, 45, 18, r=3.2, pal=('#b3a8a6', '#938280', '#d0d5d5', '#6a5a5e'))
    ember(st, 47, 12, r=2.2)
    st.eye(18, 27, look=(1, -1))
    st.eye(37, 27, look=(1, -1))
    st.mouth('smile', 27, 36)
    return key, st


# ------------------------------------------------------------------ 6. Last Forge Flame: whimsy-flame tri, rare. A living flame curled asleep, little wyrm wings, dreaming; glow + sparkles.
def last_forge_flame():
    key = 'pl-cwy-6'
    st = Sticker()
    col, row = ROWS[key]['piece']
    fl = flame_mask(31, 52, 28, 39, lean=0.45, licks=2)
    tab = knob('w', 'tri', 41, 17.8, r=3.4)
    body = fl | tab
    bat_wing(st, 44, 37, L=8, side=1, pal=('#a8352e', '#6b1b2c', '#d6322b', '#3a1e2a'))
    bat_wing(st, 20, 38, L=7, side=-1, pal=('#a8352e', '#6b1b2c', '#d6322b', '#3a1e2a'))
    # the cell's own pixels by brightness onto the flame ramp: red skin, orange heart
    src = pic.sample(col, row, 17, 12, 30).astype(int).sum(-1)
    tex = np.zeros((N, N, 3), np.uint8)
    tex[:] = hx(RED)
    tex[src > 330] = hx(LAVA_R)
    tex = majority(tex, body, 3)
    st.part(body, tex=tex, contour=True)
    heart = flame_mask(32, 51, 19, 22, lean=0.3, licks=0) & shrink(body, 3)
    st.paint(heart, LAVA_O)
    st.paint(heart & ~shift(heart, 0, 2), LAVA_L)
    st.stitch(fl, col=LAVA_L)
    st.eye(24, 36, look=(0, 1), lid=2)
    st.eye(35, 36, look=(0, 1), lid=2)
    st.mouth('smile', 28, 44)
    zzz(st, 49, 22)
    st.sparkle(10, 10)
    st.sparkle(52, 8, big=False)
    st.sparkle(9, 46, big=False)
    return key, st


PALS = [ember_flake, slag_drip, scorch_sliver, spine_spark, ash_wreath, last_forge_flame]

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
        print('%-10s %-17s %-9s %-13s %-7s colours %d margin %d' % (key, ROWS[key]['name'], ROWS[key]['rarity'], ROWS[key]['shape'],
                                                                     ROWS[key]['knob'], info['colours'], info['margin']))
        if info['colours'] > 40 or info['margin'] < 3:
            print('  WARN', info)
    sheet = os.environ.get('PAL_SHEET')
    if sheet:
        contact_sheet(paths, sheet)
        print('sheet', sheet)
