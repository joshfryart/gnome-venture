# pl-snw-4 "Snowcrown Peaks": a snowy mountain that is an inner-TTTT piece. The top double tab is the twin snowy summits,
# the core is the mountain (snowcap with a jagged snowline over mauve rock with dark crevasse stripes), the side and bottom
# double tabs are rock spurs. Colours from cell 6-1 (snow cream, periwinkle snow shadow) and the picture's mauve rock.
import sys
sys.path.insert(0, '/home/user/gnome-venture/art-review/kit')
import pal_kit as K

SNOW = K.ramp('#f8f3e4')
SHAD = K.ramp('#a3aacb')
ROCK = K.ramp('#a8979a')
DEEP = K.ramp('#6d6072')
NIGHT = '#3f3550'


def fn(c):
    s = 1.15 if c.small else 1.0
    x0, y0, x1, y1 = 13, 16, 51, 52
    # square core whose top side rises gently into the mountain's shoulder (straight sides kept elsewhere)
    core = K.poly([(x0, 24), (32, 13), (x1, 24), (x1, y1), (x0, y1)])
    top = K.knob('T', 'double', 32, 17.5, 0, -1, r=7.2 * s, nw=2.6)
    lef = K.knob('T', 'double', x0, 36, -1, 0, r=4.6 * s)
    rig = K.knob('T', 'double', x1, 36, 1, 0, r=4.6 * s)
    bot = K.knob('T', 'double', 32, y1, 0, 1, r=4.6 * s)
    body = c.m(core, top, lef, rig, bot)
    c.add(body, ROCK)
    # dark crevasse stripes in the rock (the picture's vertical gullies)
    for gx, gt in ((19, 30), (31.5, 33), (44, 30)):
        g = c.m(K.poly([(gx, gt), (gx + 4.2, 53), (gx - 4.2, 53)]))
        c.add(g & body, DEEP)
    # snowcap: summits + upper band with a jagged snowline
    snow_line = [(x0 - 1, 27), (16, 33), (20, 27), (25.5, 37), (31.5, 29), (37.5, 37), (43, 27), (47, 33), (x1 + 1, 27),
                 (x1 + 1, 0), (x0 - 1, 0)]
    cap = c.m(K.poly(snow_line)) & body
    c.add(cap, SNOW)
    # periwinkle shade on the right half of the snow (light from upper left), as in the cell
    sh = c.m(K.poly([(33, 4), (x1 + 2, 4), (x1 + 2, 27), (47, 33), (43, 27), (37.5, 37), (33, 31)])) & cap
    c.add(sh, SHAD)
    c.edge(cap, SHAD[1])
    # snow dusting on the top of the side spurs: four snowy points in all
    dust = c.m(K.ell(x0 - 6.5, 31.5, 5.0, 3.0), K.ell(x1 + 6.5, 31.5, 5.0, 3.0)) & c.m(lef, rig)
    c.add(dust - c.m(core), SNOW)
    # face on the rock, between the gullies
    c.eye(25, 42.5, disc=True)
    c.eye(38, 42.5, disc=True)
    c.smile(31.5, 47.5, col=NIGHT)
    c.blush(21, 46.5)
    c.blush(41.5, 46.5)


K.render_pal(fn, 'pl-snw-4', 'Snowcrown Peaks', '/home/user/gnome-venture/art-review/redo/out',
             cellfile='/home/user/gnome-venture/art-review/redo/_src/pl-snw-4-cell.png',
             oldfile='/home/user/gnome-venture/game/assets/img/puzzles/pals/pl-snw-4.png')
