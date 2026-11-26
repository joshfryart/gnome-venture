"""pl-drft-3 "Dusk Lap": inner-TBTB round. A sunset wave that is a puzzle piece: the N round tab is the curling crest (cream foam lip,
dark hollow of the curl), the S round tab is the foam froth lapping onto the sand, round blanks E and W bite into the water body.
Body in the stepped diagonal sunset bands of cell 6-4 (salmon, rose, plum, violet, indigo), gold sun-glint streak, felt eyes."""
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SALMON = K.ramp('#f09878')
ROSE = K.ramp('#d06c84')
PLUM = K.ramp('#9a4c8c')
VIOLET = K.ramp('#6a3e86')
INDIGO = K.ramp('#4a3a80')
FOAM = ('#f8ecd0', '#e0c8a8', '#ffffff')
GOLD = '#ffe090'
BLUE = '#3e5c9c'


def fn(c):
    k = 1.15 if c.small else 1.0
    core = K.rect(11, 18, 53, 55)
    tabN = K.knob('T', 'round', 30, 18, 0, -1, r=5.8 * k)
    tabS = K.knob('T', 'round', 32, 55, 0, 1, r=4.8 * k)
    bE = K.knob('B', 'round', 53, 38, 1, 0, r=4.6 * k)
    bW = K.knob('B', 'round', 11, 36, -1, 0, r=4.6 * k)
    # breaking lip: the crest curls over to the right and down, past the tab
    import math
    cx, cy, R = 30, 10.8, 7.4 * k
    spiral = [(cx + R * (1 - t * 0.55) * math.cos(a), cy - R * (1 - t * 0.55) * math.sin(a))
              for t, a in ((i / 10, math.radians(-35 + i * 32)) for i in range(11))]
    lip = K.thick_path(spiral, 3.8 if c.small else 3.4)
    body = c.m(core, minus=(bW, bE))
    # stepped diagonal sunset bands, as in the cell (high on the right)
    def band(lo, hi):
        def f(x, y):
            s = y + ((x - 11) // 6) * 2.2
            return lo <= s < hi
        return f
    allb = c.m(core, tabN, lip, minus=(bW, bE))
    c.add(allb & c.m(lambda x, y: True), SALMON)
    c.add(body & c.m(band(27, 36)), ROSE, stitch=None)
    c.add(body & c.m(band(36, 45)), PLUM)
    c.add(body & c.m(band(45, 54)), VIOLET)
    c.add(body & c.m(band(54, 99)), INDIGO)
    # curl hollow (dark violet inside the crest)
    c.add(c.m(K.ell(31, 11.5, 3.2, 3.0)), VIOLET)
    # foam cap along the whole top of the wave, dripping in scallops
    cap = c.m(lambda x, y: 11 <= x < 53 and 18 <= y and (y < 20.5 or ((x - 11) % 7 - 3.5) ** 2 + (y - 20.5) ** 2 < 7.5), minus=(bW, bE))
    c.add(cap, FOAM)
    # foam lip over the crest
    c.add(c.m(lip), FOAM)
    # foam froth tab at the bottom
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(K.rect(0, 52.5, 64, 56))), FOAM)
    # foam scallops along the bottom edge where the wave laps
    sc = c.m(lambda x, y: 51 <= y < 55 and ((x - 11) % 8 - 4) ** 2 + (y - 55) ** 2 < 14, minus=(bW, bE))
    c.add(sc & body, FOAM)
    # sun-glint streaks (gold) and a blue ripple, as in the cell
    w = 2.6 if c.small else 1.6
    c.add(c.m(K.thick_path([(36, 26), (47, 23.5)], w)), (GOLD, GOLD, GOLD))
    c.add(c.m(K.thick_path([(15, 47), (24, 45)], w)), (BLUE, BLUE, BLUE))
    c.eye(25, 32, disc=True)
    c.eye(36, 31, disc=True)
    c.smile(30.5, 37.5, K.UMBER)
    c.blush(20.5, 37)
    c.blush(40, 36)


K.render_pal(fn, 'pl-drft-3', 'Dusk Lap', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-drft-3-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-drft-3.png')
