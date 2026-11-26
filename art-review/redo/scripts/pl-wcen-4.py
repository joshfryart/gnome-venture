# Concept: a sunbeam sprite -- the piece body IS four slanting shafts of pale green light falling from the cenote's dark rock rim,
# inner-TTTT double knobs: N tab = two sky-white cloud puffs at the opening, S tab = two tiptoe feet where the beams touch down,
# E/W tabs = beam ends spilling sideways. Colours from cell 5-2: mint sky, cream-green beams, slate-grey gaps, umber/grey rim.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SKY = K.ramp('#e2f2e0')
CLOUD = ('#f6faf0', '#c8d8c8', '#ffffff')
BEAM = K.ramp('#d6eab0')
GLOW = K.ramp('#f2f5d4')
GAP = K.ramp('#7f8a86')
DUSK = K.ramp('#58606f')
RIM = K.ramp('#6a6458')


def fn(c):
    k = 1.15 if c.small else 1.0
    sk = 0.22   # the whole piece leans like the beams
    core = K.poly([(11, 13), (49, 13), (49 + 38 * sk, 51), (11 + 38 * sk, 51)])
    nx, ny = 0.977, -0.213
    tN = K.knob('T', 'double', 30, 13, 0, -1, r=4.8 * k)
    tS = K.knob('T', 'double', 41, 51, 0, 1, r=4.6 * k)
    tE = K.knob('T', 'double', 49 + 20 * sk, 33, nx, ny, r=4.2 * k)
    tW = K.knob('T', 'double', 11 + 20 * sk, 33, -nx, -ny, r=4.2 * k)
    period, width = 10.0, 6.4

    def ph(x, y):
        return (x - sk * (y - 13) - 11 + 1.6) % period

    def beam(x, y):
        return ph(x, y) < width
    # tiptoes: the four beams end in separate points along the bottom
    toes = lambda x, y: y > 46.5 and abs(ph(x, y) - (width + period) / 2) < (y - 46.5) * 0.75 + 0.6
    body = c.m(core, tN, tE, tW, tS, minus=(toes,))
    c.add(body, GAP)
    c.add(c.m(lambda x, y: y > 36 and not beam(x, y)) & body, DUSK)
    c.add(c.m(beam) & body, BEAM)
    c.add(c.m(lambda x, y: beam(x, y) and ph(x, y) < 2.4) & body, GLOW)
    # rock rim of the opening across the top, with drips
    rim = c.m(K.rect(0, 13, 64, 18), K.ell(17, 18, 1.8, 3.4), K.ell(43, 18.5, 1.8, 3.8)) & body
    c.add(rim, RIM)
    c.add(c.m(tN, minus=(K.rect(0, 13, 64, 64),)), CLOUD)
    c.add(c.m(tS, minus=(core,)), GLOW)
    c.add(c.m(tE, minus=(core,)), BEAM)
    c.add(c.m(tW, minus=(core,)), BEAM)
    c.add(c.m(K.ell(32.5, 31, 10.5, 6.8)) & body, GLOW)
    c.eye(27, 29, disc=True)
    c.eye(38, 29, disc=True)
    c.smile(32.5, 35)
    c.blush(25, 33.5)
    c.blush(40, 33.5)


K.render_pal(fn, 'pl-wcen-4', 'Slanting Sunbeams', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-wcen-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-wcen-4.png')
