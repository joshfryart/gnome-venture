# Mate Mumble: a mate gourd that is an inner-TBTB peg piece. N tab = heaped yerba (green), S tab = the gourd's foot,
# W/E blanks = the gourd's pinched waist. Colours from cell 9-4: terrace greens, tan terrace paths, llama cream (rim).
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K
from pal_kit import rect, ell, poly, thick_path, knob

GOURD = K.ramp('#a87a48')
FOOT = K.ramp('#7a5a34')
RIM = K.ramp('#f0ece0')
YERBA = K.ramp('#3f7a3a')
HILL = K.ramp('#8bb768')
HILL2 = K.ramp('#4f8a6a')
PATH = '#c8ba97'
METAL = ('#c9c5bc', '#8f8a80', '#ffffff')


def fn(c):
    k = 1.15 if c.small else 1.0
    core = lambda x, y: (13 <= x < 51 and 22 <= y < 44) or ell(32, 43, 19.5, 13.5)(x, y)
    tabN = knob('T', 'peg', 32, 22, 0, -1, r=5.5 * k)
    tabS = knob('T', 'peg', 32, 53.5, 0, 1, r=4.8 * k)
    bW = knob('B', 'peg', 13, 38, -1, 0, r=3.4 * k)
    bE = knob('B', 'peg', 51, 38, 1, 0, r=3.4 * k)
    # bombilla straw (behind the yerba)
    c.add(c.m(thick_path([(37, 22), (45, 7), (50, 6)], 3.2 if not c.small else 3.8)), METAL)
    body = c.m(core, minus=(bW, bE))
    c.add(body, GOURD, stitch=None if c.small else '#7a5430')
    c.add(c.m(tabS, minus=(core,)) | (c.m(tabS) & c.m(rect(0, 55.5, 64, 58))), FOOT)
    # terraced-hill band on the belly: green with tan terrace paths
    band = body & c.m(lambda x, y: y >= 46 + 2.5 * ((x - 13) / 38))
    c.add(band, HILL)
    lower = body & c.m(lambda x, y: y >= 52 + 2 * ((x - 13) / 38))
    c.add(lower, HILL2)
    c.line([(16, 50), (48, 52.5)], PATH)
    if not c.small:
        c.line([(22, 55.5), (43, 57)], PATH)
    # cream rim (llama-wool white)
    rim = body & c.m(rect(0, 22, 64, 26.5))
    c.add(rim, RIM)
    # yerba heap
    heap = ell(32, 21.5, 9.5, 5.5 * k)
    c.add(c.m(tabN, heap, minus=(rect(0, 22.5, 64, 64),)), YERBA)
    if not c.small:
        for (x, y) in c.m(tabN, heap, minus=(rect(0, 21, 64, 64),)):
            if (x * 3 + y * 5) % 7 == 0:
                c.px(x, y, '#8bb768')
    c.edge(rim, RIM[1])
    # face on the calm brown waist
    c.eye(27, 33)
    c.eye(37, 33)
    c.smile(32, 39)
    c.blush(23.5, 37)
    c.blush(40.5, 37)


K.render_pal(fn, 'rr-mate-mumble', 'Mate Mumble', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/rr-mate-mumble-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/rr-mate-mumble.png')
