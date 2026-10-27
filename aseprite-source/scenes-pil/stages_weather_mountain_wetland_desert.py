"""Weather variants of the mountain, wetland and desert stage backdrops (2026-10-27):
game/assets/img/scenes/stage-<land>-<weather>.png plus stage-weather-<land>.json (weather -> file key).

Usage: python3 -B aseprite-source/scenes-pil/stages_weather_mountain_wetland_desert.py [out_dir] [key ...]
       (default out_dir: game/assets/img/scenes; keys like mountain-fog, desert-heat; default all drawn variants)

Each variant redraws the land's v1 (sun) composition from stages_mountain_wetland_desert.py: same horizon, same
landmark at x 100..140, same flat lane from grid y 86, so the weathers read as one place. Only the sky, the light
(a colour grade on the land), wet / frosted / snowy ground, particles and a few small props change.
Weathers that make no sense for a land are not drawn: they alias to a near one in the json (see ALIAS).
Existing variants that already are a weather are reused (wetland rain -> wetland-v2), the -v2 / -v3 files stay as
time-of-day flavour and are not touched.
Palette: as the v1 art; borrowed tints are noted where they are defined (storm slate, fog / overcast greys).
"""
import json
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pixlib import (Canvas, ramp, rect, rrect, ell, poly, line, blank, shift, dil4, hx, W, H)  # noqa: E402
from shops import (WOOD, DWOOD, STONE, MOSS, LEAF)  # noqa: E402
from stops import (bands, wave, cloud, pine, rock, tufts, ripples)  # noqa: E402
from stages_mountain_wetland_desert import (peak, mesa, flowers, meadow, snowy_pine, cairn, cattails, lily,  # noqa: E402
                                            saguaro, barrel_cactus, heron, check, GROUND, NEAR)

WEATHERS = ['sun', 'cloud', 'rain', 'storm', 'frost', 'heat', 'wind', 'fog', 'snow']

# borrowed tints (all between existing families, noted per the palette rule)
SLATE0 = '#3f3d5e'   # storm sky top: dusk 700 toward stone 700
SLATE1 = '#5b6470'   # stone 700
SLATE2 = '#737b86'   # between stone 700 and 500
OVC0 = '#a3aab0'     # overcast grey (as wetland-v2)
OVC1 = '#c9c5bc'     # stone 300
OVC2 = '#d9dcd4'     # pale overcast (as wetland-v2)
FROSTC = '#d9d4ee'   # frost / snow shadow lilac (as mountain-v3)
SNOWC = '#f1ece0'    # soil 100, the snow
ICE = '#cde6e8'      # pale ice blue (as the v1 skies)
BOLT = '#fff3c8'
BOLT_E = '#f5cf6a'
RAINC = '#c9d8de'    # rain streaks (as wetland-v2)


# ------------------------------------------------------------------ helpers
def regrade(cv, pairs, mask=None):
    """Simultaneous colour remap (a->b and b->c do not chain), optionally inside a mask only."""
    src = cv.px.copy()
    for a, b in pairs.items():
        m = np.all(src == hx(a), axis=2)
        if mask is not None:
            m &= mask
        cv.px[m] = hx(b)


def colour_mask(cv, cols):
    m = blank()
    for c in cols:
        m |= np.all(cv.px == hx(c), axis=2)
    return m


def tops(m, k=1):
    """The top k pixels of every column run of a mask (where snow or frost settles)."""
    return m & ~shift(m, 0, k)


def h32(i, j=0):
    """Small integer hash (xorshift-multiply), so scattered particles do not line up."""
    v = (i * 0x9E3779B1 + j * 0x85EBCA77 + 0x27D4EB2F) & 0xffffffff
    v ^= v >> 15
    v = (v * 0x2C1B3C6D) & 0xffffffff
    v ^= v >> 12
    v = (v * 0x297A2D39) & 0xffffffff
    v ^= v >> 15
    return v


def sprinkle(cv, mask, col, n, seed=0, size=1):
    ys, xs = mask.nonzero()
    if not len(ys):
        return
    for i in range(n):
        k = h32(i, seed) % len(ys)
        x, y = xs[k], ys[k]
        if size == 1:
            cv.dots([(x, y)], col)
        else:
            cv.fill(rect(x, y, x + 1, y) & mask, col)


def streaks(cv, col, n=140, seed=3, dx=-1, ln=3, y0=0, y1=H - 1, mask=None):
    """Rain: short slanted lines."""
    for i in range(n):
        x = (h32(i, seed) % (W + 30)) - 15
        y = y0 + h32(i, seed + 7) % max(1, (y1 - y0 + 1))
        m = line([(x, y), (x + dx, y + ln)])
        if mask is not None:
            m &= mask
        cv.fill(m, col)


def snowfall(cv, n=90, seed=1, y1=H - 1, big=0.25, col=SNOWC, sh=FROSTC):
    for i in range(n):
        x = h32(i, seed) % W
        y = h32(i, seed + 3) % (y1 + 1)
        if (h32(i, seed + 9) % 100) < big * 100:
            cv.fill(rect(x, y, x + 1, y + 1), col)
            cv.dots([(x + 1, y + 1)], sh)
        else:
            cv.dots([(x, y)], col)


def bolt(cv, pts, branch=None):
    m = line(pts, w=2)
    thin = blank()
    if branch:
        thin = line(branch, w=1)
    cv.fill(dil4(m | thin), BOLT_E)
    cv.fill(m | thin, BOLT)


def overcast(cv, row, col, sh, y=0, step=34, w=56, seed=0):
    """A deck of overlapping clouds right across the sky."""
    for i, x in enumerate(range(-20 + seed, W + 10, step)):
        cloud(cv, x, y + (h32(i, seed) % 7) - 3 + row, w + (h32(i, seed + 1) % 16), col, sh)


def low_deck(cv, wx, y=22, seed=3):
    """A low cloud base for rain and storm, drawn over the far layer of a land."""
    c0, c1, c2 = {'rain': (OVC2, OVC0, '#8b8f96'), 'storm': (SLATE2, SLATE1, SLATE0)}[wx]
    cv.fill(rect(0, 0, W - 1, y + 6), c1)
    overcast(cv, y - 10, c1, c2, step=30, w=58, seed=seed)
    overcast(cv, y, c0, c1, step=38, w=54, seed=seed + 11)


def streak_clouds(cv, specs, col, sh):
    """Wind-stretched clouds: long thin capsules with a shaded underside."""
    for (x, y, w) in specs:
        m = rrect(x, y, x + w, y + 3, 1) | rrect(x + w // 5, y - 2, x + w * 3 // 4, y + 1, 1)
        cv.fill(m, col)
        cv.fill(m & ~shift(m, 0, -1), sh)


def gusts(cv, specs, col):
    """Wind curls: a long stroke ending in a small hook."""
    for (x, y, ln) in specs:
        pts = [(x, y), (x + ln, y), (x + ln + 2, y - 1), (x + ln + 3, y - 3), (x + ln + 2, y - 5), (x + ln, y - 5),
               (x + ln - 1, y - 4)]
        cv.fill(line(pts), col)


def leaves(cv, specs, cols=('#7ab55c', '#e8a317', '#4f9a45')):
    for i, (x, y) in enumerate(specs):
        c = cols[i % len(cols)]
        if i % 2:
            cv.dots([(x, y), (x + 1, y), (x + 1, y - 1)], c)
        else:
            cv.dots([(x, y), (x + 1, y - 1), (x + 2, y - 1)], c)


def glints(cv, mask, n, seed=0, col='#f1ece0'):
    """Frost sparkles: small plus shapes on the ground."""
    ys, xs = mask.nonzero()
    if not len(ys):
        return
    for i in range(n):
        k = h32(i, seed) % len(ys)
        x, y = xs[k], ys[k]
        cv.dots([(x, y), (x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)], col)


def bent_tufts(cv, pts, col):
    """Grass tufts leaning right in the wind."""
    for (x, y) in pts:
        cv.dots([(x, y), (x + 1, y - 1), (x + 3, y - 2), (x + 2, y), (x + 3, y - 1), (x + 5, y - 2), (x + 4, y)], col)


def fog_band(cv, y0, y1, col, seed=0, x0=0, x1=W - 1):
    top = wave(y0, [(1.5, 60 + seed * 7, seed), (1, 23, seed * 2.1)], x0, x1)
    bot = wave(y1, [(1.5, 70 + seed * 5, seed + 1.3), (1, 29, seed)], x0, x1)
    m = top & ~bot
    cv.fill(m, col)
    return m


def shimmer(cv, y0, y1, col, seed=0, x0=0, x1=W - 1):
    """Heat shimmer: broken, wavering dashes over the horizon."""
    for y in range(y0, y1 + 1, 2):
        off = (h32(y, seed) % 9)
        for x in range(x0 + off, x1, 13 + (y % 3) * 2):
            ln = 3 + h32(x, y) % 5
            cv.fill(rect(x, y, x + ln, y), col)
            cv.dots([(x + ln + 1, y - 1)], col)


def puddle(cv, x, y, w, base='#8fb4c4', lip='#5b8aa0', ring='#a9d6ea'):
    p = ell(x, y, x + w, y + 4)
    cv.fill(p, base)
    cv.fill(p & ~shift(p, 0, -1), lip)
    cv.dots([(x + w // 3, y + 2), (x + w // 3 + 1, y + 1), (x + w // 3 - 1, y + 1), (x + 2 * w // 3 + 1, y + 2)], ring)


def birds(cv, pts, col):
    for (x, y) in pts:
        cv.fill(line([(x, y + 2), (x + 2, y), (x + 4, y + 2), (x + 6, y), (x + 8, y + 2)]), col)


# ------------------------------------------------------------------ skies (shared by the three lands)
def sky(cv, wx, sun=(186, 34), warm=False):
    sx, sy = sun
    if wx == 'cloud':
        bands(cv, [(0, OVC0), (14, OVC1), (34, OVC2)])
        overcast(cv, -6, OVC1, OVC0, step=36, w=58, seed=4)
        overcast(cv, 14, OVC2, OVC1, step=44, w=50, seed=17)
    elif wx == 'rain':
        bands(cv, [(0, '#8b8f96'), (12, OVC0), (28, OVC1), (42, OVC2)])
        overcast(cv, -8, OVC0, '#8b8f96', step=34, w=60, seed=2)
        overcast(cv, 10, OVC1, OVC0, step=46, w=52, seed=21)
    elif wx == 'storm':
        bands(cv, [(0, SLATE0), (16, SLATE1), (34, SLATE2)])
        overcast(cv, -8, SLATE1, SLATE0, step=32, w=62, seed=5)
        overcast(cv, 12, SLATE2, SLATE1, step=42, w=54, seed=13)
    elif wx == 'frost':
        bands(cv, [(0, '#a9d6ea'), (16, ICE), (34, '#e6efe6')])
        cv.fill(ell(sx + 2, sy + 4, sx + 12, sy + 14), '#fff3c8')
        for (x, y, w) in ((20, 22, 40), (120, 14, 30)):
            cv.fill(rrect(x, y, x + w, y + 2, 1), '#e6efe6')
    elif wx == 'heat':
        bands(cv, [(0, '#a9d6ea'), (12, ICE), (26, '#f6e7c0'), (44, '#f6d9b0')])
        ring = ell(sx - 6, sy - 6, sx + 22, sy + 22)
        cv.fill(ring, '#f6e7c0')
        cv.fill(ell(sx - 2, sy - 2, sx + 18, sy + 18), '#fff3c8')
        for k in range(8):
            import math
            a = k * math.pi / 4
            cx, cy = sx + 8, sy + 8
            cv.fill(line([(round(cx + 15 * math.cos(a)), round(cy + 15 * math.sin(a))),
                          (round(cx + 19 * math.cos(a)), round(cy + 19 * math.sin(a)))]), '#fff3c8')
    elif wx == 'wind':
        bands(cv, [(0, '#7fbcd8'), (12, '#a9d6ea'), (26, ICE), (40, '#e6efe6')])
        cv.fill(ell(sx, sy, sx + 16, sy + 16), '#f5cf6a')
        streak_clouds(cv, ((8, 10, 60), (96, 20, 74), (170, 8, 50), (40, 32, 44), (150, 34, 30)), '#f1ece0', ICE)
    elif wx == 'fog':
        bands(cv, [(0, OVC2), (30, '#e6e6dc')])
        cv.fill(ell(sx + 2, sy + 2, sx + 14, sy + 14), '#f1ece0')
    elif wx == 'snow':
        bands(cv, [(0, OVC1), (10, OVC2), (28, FROSTC)])


# ================================================================== MOUNTAIN
MOUNTAIN_GRADE = {
    'cloud': {'#c3b2ea': '#b4aecb', '#9f8ad6': '#9384c0', '#a4b86a': '#7ab55c', '#7ab55c': '#6aa452', '#f5cf6a': '#f1ece0',
              '#a9d6ea': ICE},
    'rain': {'#c3b2ea': OVC0, '#9f8ad6': '#8b8f96', '#7a5cc0': SLATE1, '#d9d4ee': OVC1, '#f1ece0': OVC2,
             '#a4b86a': '#4f9a45', '#7ab55c': '#4f9a45', '#4f9a45': '#2f6a3a', '#c9a96e': '#9a6b3f', '#9a6b3f': '#7a4a1f',
             '#4f7a5a': '#3f6a4e'},
    'storm': {'#c3b2ea': SLATE2, '#9f8ad6': SLATE1, '#7a5cc0': SLATE0, '#d9d4ee': '#8b8f96', '#f1ece0': OVC1,
              '#a4b86a': '#2f6a3a', '#7ab55c': '#4f9a45', '#4f9a45': '#2f6a3a', '#c9a96e': '#7a4a1f',
              '#9a6b3f': '#5c3420', '#4f7a5a': '#2f5a3a', '#c9c5bc': '#8b8f96', '#8b8f96': SLATE1},
    'frost': {'#c3b2ea': '#cfc8ee', '#a4b86a': FROSTC, '#7ab55c': '#a4b8a8', '#4f9a45': '#7a9a7a', '#c9a96e': OVC1,
              '#9a6b3f': '#8b8f96', '#4f7a5a': '#5f8a7a'},
    'wind': {},
    'fog': {'#9f8ad6': '#b4aecb', '#7a5cc0': '#9a96b4', '#f1ece0': '#e6e6dc', '#d9d4ee': OVC2, '#4f7a5a': '#a0aaa4',
            '#a4b86a': '#9aae86', '#7ab55c': '#86a474', '#4f9a45': '#6a8e62'},
    'snow': {'#c3b2ea': '#c9c5d8', '#9f8ad6': '#a49cc4', '#7a5cc0': '#7f74a8', '#4f7a5a': '#5f7a72'},
}


def mountain_land(cv, wx):
    snow, frost, fog, wind = wx == 'snow', wx == 'frost', wx == 'fog', wx == 'wind'
    wet = wx in ('rain', 'storm')
    # far range (lost in fog, hidden by rain)
    if wet:
        pass
    elif fog:
        for (x, t, wl, wr) in ((62, 34, 30, 34), (224, 32, 30, 40)):
            peak(cv, x, t, wl, wr, 78, '#cfccd6', '#cfccd6', None, None, seed=x)
    else:
        for (x, t, wl, wr) in ((14, 40, 36, 30), (62, 34, 30, 34), (162, 38, 34, 30), (224, 32, 30, 40)):
            peak(cv, x, t, wl, wr, 78, '#c3b2ea', '#c3b2ea', '#f1ece0', None, sh=(16 if snow else None), seed=x)
    # near range: the snow line drops in snow and frost
    extra = 9 if snow else (4 if frost else 0)
    for (x, t, wl, wr, s) in ((36, 46, 44, 40, 7), (118, 30, 52, 56, 10), (204, 44, 42, 48, 7)):
        peak(cv, x, t, wl, wr, 84, '#9f8ad6', '#7a5cc0', '#f1ece0', '#d9d4ee', sh=s + extra, seed=x)
    if wind:
        # spindrift: snow blown off the summits to the right
        for (x, t, ln) in ((36, 46, 30), (118, 30, 46), (204, 44, 26)):
            for k in range(3):
                cv.fill(rect(x + 1 + k * 3, t + k, x + ln - k * 8, t + k), '#f1ece0' if k < 2 else '#d9d4ee')
            cv.dots([(x + ln + 3, t - 1), (x + ln + 7, t), (x + ln - 4, t + 3)], '#f1ece0')
    if wx in ('rain', 'storm'):
        # the cloud base sits on the range: the big summit is hidden
        low_deck(cv, wx)
    # waterfall down the right shoulder of the big peak (frozen in frost and snow)
    fall = (FROSTC, SNOWC) if (frost or snow) else ('#a9d6ea', '#f1ece0')
    if fog:
        fall = ('#c9d8de', '#e6e6dc')
    cv.fill(rect(150, 50, 153, 76), fall[0])
    cv.fill(rect(151, 52, 151, 76), fall[1])
    if frost or snow:
        cv.dots([(150, 77), (152, 78), (153, 77)], fall[0])
    if fog:
        fog_band(cv, 56, 66, '#e6e6dc', seed=2)
    # forest band at the foot of the range
    for x in range(-4, W + 8, 9):
        h = 12 + (x * 13) % 9
        yb = 84 + (x * 5) % 4
        pine(cv, x, yb, 10, h, flat='#4f7a5a')
        if snow or frost:
            top = yb - 4 - h
            for i in range(3):
                ty = top + round(h * 0.26 * i)
                cv.fill(rect(x - 1 - i, ty + 3 + i, x + 1, ty + 3 + i), SNOWC if snow else FROSTC)
    cv.fill(ell(146, 77, 158, 82), fall[1])
    cv.fill(rect(0, 82, W - 1, 87), '#4f7a5a')
    if fog:
        fog_band(cv, 70, 80, OVC2, seed=5)
        fog_band(cv, 76, 84, '#e6e6dc', seed=9)
    # the meadow
    if snow:
        meadow(cv, FROSTC, SNOWC, '#c3b2ea')
    else:
        meadow(cv, '#7ab55c', '#a4b86a', '#4f9a45')
    # path up to the cairn (trodden track through snow)
    p = poly([(106, 135), (138, 135), (126, 88), (118, 88)])
    if snow:
        cv.fill(p, '#c9c5d8')
        cv.fill(p & ~shift(p, -2, 0), '#c3b2ea')
        for y in range(92, 134, 6):
            xx = 118 + (y - 88) * 12 // 47 + (3 if y % 12 else -3)
            cv.dots([(xx, y), (xx + 1, y)], '#a49cc4')
    else:
        cv.fill(p, '#c9a96e')
        cv.fill(p & ~shift(p, -2, 0), '#9a6b3f')
    if wet:
        for (x, y, w) in ((112, 120, 16), (118, 102, 10)):
            puddle(cv, x, y, w)
        puddle(cv, 44, 104, 20)
        puddle(cv, 170, 98, 22)
    cairn(cv, 132, 90)
    if snow or frost:
        cm = colour_mask(cv, ['#8b8f96', '#c9c5bc', '#5b6470'])
        cm &= rect(118, 64, 146, 92)
        cv.fill(tops(cm, 2 if snow else 1), SNOWC if snow else FROSTC)
    # framing pines and boulders
    if snow:
        snowy_pine(cv, 4, 108, 26, 64)
        snowy_pine(cv, 238, 110, 28, 70)
    elif frost:
        snowy_pine(cv, 4, 108, 26, 64, snow=FROSTC)
        snowy_pine(cv, 238, 110, 28, 70, snow=FROSTC)
    else:
        pine(cv, 4, 108, 26, 64)
        pine(cv, 238, 110, 28, 70)
    r1 = rock(cv, -10, 112, 34, 136, moss=None if (snow or frost) else MOSS)
    r2 = rock(cv, 196, 116, 230, 138, moss=None if (snow or frost) else MOSS)
    if snow or frost:
        for r in (r1, r2):
            cv.fill(tops(r, 3 if snow else 1), SNOWC if snow else FROSTC)
    tp = [(40, 100), (84, 108), (160, 96), (190, 104), (60, 92), (150, 124), (90, 126)]
    if snow:
        tufts(cv, tp[:4], '#7a9a7a')
    elif wind:
        bent_tufts(cv, tp + [(20, 96), (176, 112), (70, 116)], '#4f9a45')
    else:
        tufts(cv, tp, '#4f9a45')
    if wx in ('sun', 'cloud', 'wind', 'fog'):
        flowers(cv, [(52, 96, '#f5cf6a'), (96, 102, '#e46a9b'), (176, 92, '#f5cf6a'), (210, 100, '#f1ece0'),
                     (70, 120, '#e46a9b'), (150, 116, '#f5cf6a'), (30, 90, '#f1ece0')])
    if frost:
        g = colour_mask(cv, ['#7ab55c', '#a4b86a', '#4f9a45']) & rect(0, GROUND, W - 1, H - 1)
        sprinkle(cv, g, FROSTC, 40, seed=11, size=2)
        glints(cv, g, 22, seed=3)


def mountain_post(cv, wx):
    if wx == 'cloud':
        birds(cv, [(70, 22), (80, 26)], '#5b6470')
    elif wx == 'rain':
        streaks(cv, RAINC, n=170, seed=5)
    elif wx == 'storm':
        bolt(cv, [(72, 20), (64, 34), (71, 37), (60, 52), (66, 54), (56, 72)], branch=[(64, 45), (54, 49), (50, 58)])
        streaks(cv, '#a3aab0', n=230, seed=9, dx=-3, ln=5)
    elif wx == 'wind':
        gusts(cv, ((24, 58, 26), (150, 96, 20), (60, 112, 24), (176, 64, 30), (90, 46, 18)), '#f1ece0')
        leaves(cv, ((40, 70), (70, 60), (102, 74), (160, 80), (190, 58), (214, 76), (54, 98), (176, 104), (130, 64),
                    (226, 92), (16, 84), (88, 88)))
        birds(cv, [(70, 22), (84, 30)], '#4e3a8a')
    elif wx == 'fog':
        for (x, y, w) in ((-6, 94, 44), (150, 100, 56), (60, 118, 50), (186, 124, 40), (96, 106, 30)):
            cv.fill(rrect(x, y, x + w, y + 1, 1), OVC2)
    elif wx == 'snow':
        snowfall(cv, n=170, seed=4, big=0.35)


# ================================================================== WETLAND
WETLAND_GRADE = {
    'cloud': {'#a4b8a8': '#9aa89c', '#a4b86a': '#7ab55c', '#7ab55c': '#6aa452', '#f5cf6a': '#f1ece0'},
    'storm': {'#a4b8a8': SLATE2, '#7a9a7a': SLATE1, '#a4b86a': '#2f6a3a', '#7ab55c': '#4f9a45', '#4f9a45': '#2f6a3a',
              '#9a6b3f': '#5c3420', '#c9a96e': '#9a6b3f', '#f1ece0': OVC1},
    'frost': {'#a4b8a8': '#c3c8d8', '#7a9a7a': '#8f9fa0', '#a4b86a': FROSTC, '#7ab55c': '#a4b8a8', '#4f9a45': '#7a9a7a',
              '#2f6a3a': '#5f7a72', '#9a6b3f': '#8b8f96'},
    'heat': {'#a4b8a8': '#c9c8a8', '#7a9a7a': '#a4a878', '#a4b86a': '#d9b878', '#7ab55c': '#a4b86a', '#4f9a45': '#7ab55c',
             '#3f8fb0': '#4f9a8a'},
    'wind': {},
    'fog': {'#a4b8a8': OVC2, '#7a9a7a': OVC1, '#a4b86a': '#9aae86', '#7ab55c': '#86a474', '#4f9a45': '#6a8e62',
            '#2f6a3a': '#4f6e52', '#7fbcd8': '#9fbcc4', '#3f8fb0': '#7a9eac', '#a9d6ea': '#c9d8de'},
    'snow': {'#a4b8a8': '#c9c5d8', '#7a9a7a': '#a49cc4', '#4f9a45': '#7a9a7a', '#2f6a3a': '#5f7a72'},
}


def willow(cv, wx):
    crowns = (ell(-18, 14, 16, 42), ell(14, 16, 42, 44), ell(-2, 8, 34, 38), ell(-10, 26, 30, 52))
    crown = crowns[0] | crowns[1] | crowns[2] | crowns[3]
    bare = wx == 'snow'
    o = cv.obj()
    o.part(rect(6, 44, 12, 92) | poly([(6, 92), (2, 94), (16, 94), (12, 92)]), DWOOD, d=2)
    if not bare:
        for m in crowns:
            o.part(m, LEAF, d=2)
    o.draw()
    if bare:
        # winter willow: bare golden whips under a snowy crown of branches
        br = blank()
        for (x1, y1, mx, my) in ((-6, 20, 2, 32), (6, 10, 8, 28), (24, 12, 14, 28), (38, 22, 22, 32), (30, 36, 18, 40),
                                 (-4, 36, 4, 40)):
            br |= line([(9, 46), (mx, my)], w=2) | line([(mx, my), (x1, y1)], w=1)
        twigs = blank()
        for x in range(-14, 42, 2):
            ys = br[:, max(0, min(W - 1, x))].nonzero()[0]
            if x < 0 or not len(ys) or x in range(7, 12):
                continue
            yb = ys.min()
            ln = 16 + (x * 11) % 18
            twigs |= line([(x, yb + 1), (x, yb + ln // 2), (x + 1, yb + ln)])
        cv.fill(twigs, '#c9a96e')
        cv.fill(twigs & ~shift(twigs, 0, 3) & ~shift(twigs, 0, -3), '#9a6b3f')
        cv.fill(br, '#7a4a1f')
        cv.fill(tops(br, 1), SNOWC)
    for x in range(-14, 42, 2):
        col = crown[:, max(0, min(W - 1, x))]
        ys = col.nonzero()[0]
        if x < 0 or not len(ys):
            continue
        yb = ys.max()
        ln = 12 + (x * 7) % 14
        if bare:
            continue
        c = '#4f9a45' if x % 2 else '#7ab55c'
        if wx == 'wind':
            cv.fill(line([(x, yb - 2), (x + 3, yb + ln // 2), (x + 8, yb + ln - 2)]), c)
            cv.dots([(x + 9, yb + ln - 2)], '#4f9a45')
        else:
            cv.fill(rect(x, yb - 2, x, yb + ln), c)
            cv.dots([(x, yb + ln + 1)], '#4f9a45')
    if wx == 'frost':
        cm = colour_mask(cv, ['#7ab55c', '#4f9a45', '#a4b86a']) & rect(0, 0, 44, 60)
        cv.fill(tops(cm, 1), '#f1ece0')


def wetland_land(cv, wx):
    snow, frost, fog, wind, heat = wx == 'snow', wx == 'frost', wx == 'fog', wx == 'wind', wx == 'heat'
    storm = wx == 'storm'
    if storm:
        low_deck(cv, wx, y=16, seed=6)
    # far bank: hazy round trees
    for (x, w) in ((-8, 24), (10, 18), (24, 28), (50, 16), (64, 24), (86, 18), (100, 26), (122, 14), (134, 24), (156, 18),
                   (170, 26), (192, 16), (204, 24), (226, 22)):
        cv.fill(ell(x, 56 - w * 2 // 3, x + w, 60 + w // 4), '#a4b8a8')
        if snow:
            m = ell(x, 56 - w * 2 // 3, x + w, 60 + w // 4)
            cv.fill(tops(m, 2), SNOWC)
    cv.fill(rect(0, 56, W - 1, 61), '#7a9a7a')
    if heat:
        shimmer(cv, 44, 58, '#f6e7c0', seed=3)
    # the pond behind the lane
    pond = rect(0, 61, W - 1, 86)
    if snow:
        bands(cv, [(61, SNOWC), (64, ICE), (72, '#a9d6ea')])
        for (x, y, w) in ((10, 68, 30), (70, 74, 40), (150, 70, 26), (190, 78, 34), (120, 80, 20), (30, 80, 24)):
            cv.fill(rect(x, y, x + w, y), SNOWC)
        for (x, y) in ((40, 76), (96, 70), (176, 76)):
            cv.fill(line([(x, y), (x + 4, y + 2), (x + 9, y + 1)]), '#7fbcd8')
    elif frost:
        bands(cv, [(61, ICE), (64, '#a9d6ea'), (68, '#7fbcd8'), (78, '#3f8fb0')])
        ripples(cv, rect(0, 68, W - 1, 78), '#a9d6ea', step=4, ln=5, seed=2)
        # a skin of ice creeping out from the near shore
        ice = wave(80, [(2, 50, 0.4), (1, 17, 1.1)]) & rect(0, 0, W - 1, 86)
        cv.fill(ice, ICE)
        cv.fill(tops(ice, 1), SNOWC)
        for (x, y) in ((30, 83), (90, 82), (150, 84), (200, 83)):
            cv.fill(line([(x, y), (x + 3, y + 1), (x + 7, y)]) & ice, '#a9d6ea')
    elif wx in ('cloud', 'storm'):
        bands(cv, [(61, '#8fb4c4'), (68, '#5b8aa0')] if wx == 'cloud' else [(61, '#5b8aa0'), (68, SLATE1)])
        ripples(cv, rect(0, 66, W - 1, 86), '#8fb4c4' if wx == 'cloud' else '#5b8aa0', step=4, ln=5, seed=2)
    else:
        bands(cv, [(61, '#a9d6ea'), (66, '#7fbcd8'), (76, '#3f8fb0')])
        ripples(cv, rect(0, 66, W - 1, 86), '#a9d6ea', step=3 if wind else 4, ln=5, seed=2)
        if wind:
            for i in range(26):
                x = h32(i, 4) % W
                y = 66 + h32(i, 5) % 18
                cv.dots([(x, y), (x + 1, y - 1), (x + 2, y)], '#f1ece0')
    if storm:
        for i in range(30):
            x = h32(i, 8) % W
            y = 64 + h32(i, 9) % 20
            cv.fill(ell(x - 3, y - 1, x + 3, y + 1) & ~ell(x - 2, y, x + 2, y), '#8fb4c4')
    if heat:
        # the water has dropped: a rim of cracked mud along the near shore
        mud = wave(79, [(1.5, 60, 0.9), (1, 21, 0.3)]) & rect(0, 0, W - 1, 87)
        cv.fill(mud, '#c9a96e')
        cv.fill(tops(mud, 1), '#9a6b3f')
        for x in range(4, W, 11):
            y = 83 + (x % 3)
            cv.fill(line([(x, y), (x + 3, y - 1), (x + 5, y + 1)]) & mud, '#9a6b3f')
    if not snow:
        pads = ((20, 12, None), (58, 9, '#f6b8cf'), (150, 12, None), (176, 8, '#f6b8cf'), (200, 11, None), (88, 7, None))
        if heat:
            pads += ((36, 8, '#f6b8cf'), (130, 9, None), (220, 8, '#f6b8cf'))
        for (x, w, f) in pads:
            if frost:
                lily(cv, x, 72 + (x % 3) * 3, w, pad='#7a9a7a', lit='#a4b8a8')
            elif storm:
                lily(cv, x, 72 + (x % 3) * 3, w, pad='#2f6a3a', lit='#4f9a45')
            else:
                lily(cv, x, 72 + (x % 3) * 3, w, flower=f if wx != 'cloud' or x == 58 else None)
    if fog:
        fog_band(cv, 50, 60, OVC2, seed=3)
        fog_band(cv, 62, 70, '#e6e6dc', seed=7)
        fog_band(cv, 72, 77, OVC2, seed=4)
    heron(cv, 112, 82)
    cv.fill(rect(108, 82, 128, 82), ICE if (snow or frost) else ('#8fb4c4' if wx in ('cloud', 'storm') else '#a9d6ea'))
    if fog:
        fog_band(cv, 78, 82, '#e6e6dc', seed=1, x0=126)
        fog_band(cv, 78, 82, '#e6e6dc', seed=6, x1=104)
    willow(cv, wx)
    # near bank: soft wet grass, mud edge
    if snow:
        g = meadow(cv, FROSTC, SNOWC, '#c3b2ea', terms=((2, 70, 1.1), (1, 23, 0.3)))
        cv.fill(g & ~shift(g, 0, 1), SNOWC)
    else:
        g = meadow(cv, '#7ab55c', '#a4b86a', '#4f9a45', terms=((2, 70, 1.1), (1, 23, 0.3)))
        cv.fill(g & ~shift(g, 0, 1), '#9a6b3f')
    ccol = '#9a6b3f' if (snow or frost) else '#2f6a3a'
    chead = '#5c3420' if (snow or frost) else '#7a4a1f'
    if wind:
        for (x0, x1, base, hm, hv, ev) in ((196, 238, 92, 16, 14, 3), (60, 76, 88, 8, 6, 2), (160, 172, 88, 9, 6, 2)):
            for x in range(x0, x1, 4):
                hgt = hm + (x * 7) % hv
                tip = (x + hgt // 3, base - hgt + 2)
                cv.fill(line([(x, base), (x + 1, base - hgt // 2), tip]), ccol)
                if (x // 4) % ev == 0:
                    cv.fill(rect(tip[0] - 1, tip[1] + 1, tip[0] + 1, tip[1] + 5) & ~rect(tip[0] - 1, tip[1] + 5, tip[0] - 1, tip[1] + 5), chead)
    else:
        cattails(cv, 196, 238, 92, hmin=16, hvar=14, col=ccol, head=chead)
        cattails(cv, 60, 76, 88, hmin=8, hvar=6, every=2, col=ccol, head=chead)
        cattails(cv, 160, 172, 88, hmin=9, hvar=6, every=2, col=ccol, head=chead)
        if snow or frost:
            hm = colour_mask(cv, [chead]) & rect(0, 50, W - 1, 92)
            cv.fill(tops(hm, 1), SNOWC if snow else FROSTC)
    # foreground: a mossy log in the near left corner
    o = cv.obj()
    o.part(rrect(-6, 118, 44, 128, 3), WOOD, d=2)
    o.part(ell(38, 117, 48, 129), ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=1, contour=True)
    if not snow:
        o.part(rrect(-6, 116, 30, 119, 1), MOSS, d=0, contour=True)
    o.draw()
    cv.fill(ell(41, 120, 45, 126) & ~ell(42, 121, 44, 125), '#9a6b3f')
    if snow:
        cv.fill(rrect(-6, 115, 40, 118, 1), SNOWC)
        cv.fill(rect(-6, 118, 40, 118), FROSTC)
    tp = [(54, 102), (96, 108), (150, 100), (180, 108), (130, 124), (210, 124), (80, 96)]
    if snow:
        tufts(cv, tp[:4], '#7a9a7a')
    elif wind:
        bent_tufts(cv, tp + [(20, 100), (170, 118), (110, 116)], '#4f9a45')
    else:
        tufts(cv, tp, '#4f9a45')
    if wx in ('cloud', 'wind', 'fog', 'heat'):
        flowers(cv, [(70, 100, '#f5cf6a'), (120, 104, '#f1ece0'), (166, 96, '#e46a9b'), (30, 96, '#f5cf6a'), (190, 118, '#f1ece0')])
    if storm:
        for (x, y, w) in ((40, 100, 22), (170, 104, 26), (100, 120, 30)):
            puddle(cv, x, y, w, base='#5b8aa0', lip=SLATE1, ring='#8fb4c4')
    if frost:
        gm = colour_mask(cv, ['#7ab55c', '#a4b86a', '#4f9a45']) & rect(0, GROUND, W - 1, H - 1)
        sprinkle(cv, gm, FROSTC, 40, seed=11, size=2)
        glints(cv, gm, 22, seed=5)


def wetland_post(cv, wx):
    if wx == 'cloud':
        birds(cv, [(92, 36), (100, 32)], '#5b6470')
    elif wx == 'storm':
        bolt(cv, [(176, 18), (182, 28), (175, 31), (184, 44), (178, 46), (186, 58)], branch=[(180, 38), (190, 40), (194, 46)])
        streaks(cv, '#a3aab0', n=240, seed=12, dx=-3, ln=5)
    elif wx == 'heat':
        for (x, y) in ((70, 66), (168, 92), (90, 108)):
            cv.fill(rect(x, y, x + 6, y), '#3f8fb0')
            cv.dots([(x + 2, y - 1), (x + 4, y - 1), (x + 2, y + 1), (x + 4, y + 1)], '#a9d6ea')
            cv.dots([(x + 7, y)], '#25637d')
    elif wx == 'wind':
        gusts(cv, ((60, 46, 26), (150, 98, 20), (90, 114, 24), (170, 30, 30), (200, 70, 18)), '#f1ece0')
        leaves(cv, ((44, 60), (60, 50), (82, 70), (140, 56), (186, 48), (214, 66), (54, 96), (176, 104), (130, 92),
                    (226, 86), (100, 40), (30, 76), (160, 76)))
        birds(cv, [(92, 30), (104, 36)], '#5b6470')
    elif wx == 'fog':
        for (x, y, w) in ((-6, 96, 44), (150, 102, 56), (70, 120, 50), (190, 126, 40), (100, 108, 26)):
            cv.fill(rrect(x, y, x + w, y + 1, 1), OVC2)
    elif wx == 'snow':
        snowfall(cv, n=170, seed=7, big=0.35)


# ================================================================== DESERT
FROSTW = '#e6efe6'   # frost white on the desert (its v1 folds #f1ece0 into the sand cream)
DESERT_GRADE = {
    'cloud': {'#e8b48a': '#c9b4a4', '#f5cf6a': '#e8cf98', '#e8a317': '#c9a96e', '#f08a24': '#e0805a',
              '#f6e7c0': '#e8dcc0'},
    'rain': {'#e8b48a': '#b4aab0', '#f5cf6a': '#c9a96e', '#e8a317': '#9a6b3f', '#f08a24': '#c96a40', '#e0805a': '#c96a40',
             '#c96a40': '#b8553a', '#b8553a': '#8a4030', '#e8cf98': '#c9a96e', '#f6e7c0': '#d9b878', '#c9a96e': '#9a6b3f',
             '#d9b878': '#b0895a', '#f6b89a': '#e0805a'},
    'storm': {'#e8b48a': SLATE2, '#f5cf6a': '#9a6b3f', '#e8a317': '#7a4a1f', '#f08a24': '#b8553a', '#e0805a': '#b8553a',
              '#c96a40': '#8a4030', '#b8553a': '#6a3040', '#e8cf98': '#9a6b3f', '#f6e7c0': '#c9a96e', '#c9a96e': '#7a4a1f',
              '#d9b878': '#8a5a30', '#f6b89a': '#c96a40', '#9a6b3f': '#5c3420'},
    'frost': {'#e8b48a': '#d9c4cc', '#f5cf6a': '#e8dcc0', '#e8a317': '#c9b4a4', '#f08a24': FROSTW, '#e8cf98': '#d9d0c0',
              '#f6e7c0': FROSTW, '#c9a96e': '#c9b4a4', '#d9b878': '#c9c0b0'},
    'heat': {'#e8b48a': '#f6d9b0', '#e0805a': '#e8a080', '#c96a40': '#e0805a', '#b8553a': '#c96a40', '#f08a24': '#f5cf6a',
             '#e8cf98': '#f6e7c0', '#f6e7c0': '#fff3c8', '#c9a96e': '#e8cf98', '#d9b878': '#e8cf98', '#e8a317': '#f5cf6a',
             '#f5cf6a': '#f6e7c0'},
    'wind': {'#e8b48a': '#eac2a0'},
    'fog': {'#e0805a': '#d9b0a0', '#c96a40': '#d0a090', '#b8553a': '#c49488', '#f08a24': '#e6d6c8', '#f5cf6a': '#e8dcc0',
            '#e8a317': '#d9c8b0'},
}


def tumbleweed(cv, x, y, r=6):
    m = blank()
    for k in range(7):
        a = k * 0.9
        import math
        m |= line([(round(x + r * math.cos(a)), round(y + r * math.sin(a))),
                   (round(x - r * math.cos(a + 1.3)), round(y - r * math.sin(a + 1.3)))])
    ring = ell(x - r, y - r, x + r, y + r) & ~ell(x - r + 1, y - r + 1, x + r - 1, y + r - 1)
    cv.fill(m | ring, '#9a6b3f')
    cv.fill((m | ring) & ~shift(m | ring, 1, 1), '#c9a96e')


def desert_land(cv, wx):
    fog, wind, heat, frost = wx == 'fog', wx == 'wind', wx == 'heat', wx == 'frost'
    wet = wx in ('rain', 'storm')
    # far mesas in warm haze
    if not fog:
        for (x0, x1, t) in ((-10, 40, 48), (64, 108, 52), (150, 196, 46), (210, 250, 54)):
            mesa(cv, x0, x1, t, 72, '#e8b48a', '#e8b48a')
    if wet:
        low_deck(cv, wx, y=22, seed=9)
        # a rain curtain trailing from the cloud base over the far mesas
        curtain = poly([(150, 30), (232, 30), (224, 70), (158, 70)])
        streaks(cv, OVC0 if wx == 'rain' else SLATE2, n=900, seed=40, dx=-1, ln=4, y0=26, y1=70, mask=curtain)
    if heat:
        shimmer(cv, 50, 70, '#f6e7c0', seed=8)
    # mid mesas with red strata
    mesa(cv, 6, 70, 52, 82, '#e0805a', '#b8553a', stripe='#c96a40', cap='#f08a24')
    mesa(cv, 170, 236, 56, 82, '#e0805a', '#b8553a', stripe='#c96a40', cap='#f08a24')
    if fog:
        fog_band(cv, 60, 72, '#e6e6dc', seed=2)
    # dunes
    d1 = wave(74, [(4, 80, 0.3), (2, 33, 1.9)])
    cv.fill(d1, '#f5cf6a')
    cv.fill(d1 & ~shift(d1, -3, 0) & ~rect(0, 0, W, 76), '#e8a317')
    if wind:
        # sand blown off the dune crests to the right
        for x in range(4, W, 16):
            ys = d1[:, x].nonzero()[0]
            if len(ys):
                y = ys.min()
                cv.fill(rect(x, y - 1, x + 7, y - 1) | rect(x + 4, y - 2, x + 12, y - 2), '#f5cf6a')
                cv.dots([(x + 15, y - 3), (x + 18, y - 2)], '#f5cf6a')
    if frost:
        cv.fill(tops(d1, 1), FROSTW)
    # the stone arch in the middle distance
    arch = (poly([(96, 88), (98, 62), (104, 54), (136, 54), (142, 62), (144, 88)]) & ~ell(106, 62, 134, 100)) | rect(96, 84, 106, 88)
    if fog:
        fog_band(cv, 74, 82, OVC2, seed=6)
    o = cv.obj()
    o.part(arch, ramp('#e0805a', '#b8553a', '#f6b89a'), d=3)
    o.draw()
    for y in (60, 66, 76):
        cv.fill(rect(96, y, 144, y) & arch & ~shift(arch, 0, 2), '#c96a40')
    if frost:
        cv.fill(tops(arch, 1) & rect(0, 0, W, 60), FROSTW)
    if heat:
        # mirage: a false pool shimmering on the sand either side of the arch
        for (x0, x1) in ((40, 92), (148, 204)):
            cv.fill(rect(x0 + 4, 85, x1 - 4, 85), RAINC)
            cv.fill(rect(x0, 86, x1, 86) & ~rect(x0 + 10, 86, x0 + 14, 86), '#a9d6ea')
            cv.fill(rect(x0 + 8, 87, x1 - 10, 87), RAINC)
    # sand floor, ripple lines, near band
    meadow(cv, '#e8cf98', '#f6e7c0', '#c9a96e', terms=((1, 90, 0.6), (1, 41, 1.2)))
    if heat:
        for (x0, x1) in ((40, 92), (148, 204)):
            cv.fill(rect(x0 + 6, 87, x1 - 6, 87), RAINC)
            cv.fill(rect(x0 + 2, 88, x1 - 2, 88) & ~rect(x0 + 20, 88, x0 + 26, 88), '#a9d6ea')
    for (x, y, w) in ((20, 96, 18), (64, 104, 22), (150, 98, 16), (188, 106, 20), (110, 100, 14), (40, 108, 12)):
        cv.fill(rect(x, y, x + w, y) | rect(x + 2, y - 1, x + w - 4, y - 1), '#d9b878')
    if wet:
        for (x, y, w) in ((60, 98, 22), (150, 104, 26), (104, 116, 30)):
            puddle(cv, x, y, w, base='#8fb4c4' if wx == 'rain' else '#5b8aa0', lip='#5b8aa0' if wx == 'rain' else SLATE1,
                   ring='#a9d6ea' if wx == 'rain' else '#8fb4c4')
    # framing: a tall saguaro at the left edge, prickly-pear and a rock at the right
    saguaro(cv, 14, 106, 54, arms=((0.42, 1, 14), (0.62, -1, 10)))
    saguaro(cv, 226, 92, 26, arms=((0.5, -1, 8),))
    barrel_cactus(cv, 196, 122, 12)
    barrel_cactus(cv, 152, 90, 8, flower='#f5cf6a')
    if wx == 'rain':
        # the desert blooms after rain
        flowers(cv, [(13, 50, '#f6b8cf'), (23, 62, '#f6b8cf'), (5, 72, '#e46a9b'), (225, 64, '#f6b8cf'), (219, 74, '#e46a9b'),
                     (40, 100, '#e46a9b'), (90, 106, '#f5cf6a'), (176, 112, '#e46a9b'), (130, 96, '#f5cf6a'), (70, 120, '#f6b8cf')])
    r1 = rock(cv, 30, 118, 70, 136, rp=ramp('#c9a96e', '#9a6b3f', '#f2e4c0'), d=3)
    r2 = rock(cv, 208, 118, 246, 138, rp=ramp('#e0805a', '#b8553a', '#f6b89a'), d=3)
    for (x, y) in ((60, 98), (130, 110), (176, 96), (100, 124), (88, 92)):
        cv.fill(rect(x, y, x + 2, y + 1), '#9a6b3f')
    if frost:
        cact = colour_mask(cv, ['#4f9a45', '#2f6a3a', '#7ab55c'])
        cv.fill(tops(cact, 1), FROSTW)
        for r in (r1, r2):
            cv.fill(tops(r, 1), FROSTW)
        sand = colour_mask(cv, ['#e8cf98']) & rect(0, GROUND, W - 1, H - 1)
        sprinkle(cv, sand, FROSTC, 50, seed=21, size=2)
        glints(cv, sand, 20, seed=7, col=FROSTW)
    if heat:
        # a bleached skull by the path
        o = cv.obj()
        o.part(ell(170, 104, 180, 112) | rect(172, 111, 178, 114), ramp('#f6e7c0', '#c9a96e', '#fff3c8'), d=1)
        o.draw()
        cv.dots([(173, 107), (174, 107), (177, 107), (178, 107)], '#4a2c1a')
        cv.fill(line([(169, 105), (165, 102), (164, 99)]) | line([(181, 105), (185, 102), (186, 99)]), '#f6e7c0')
    if wind:
        tumbleweed(cv, 70, 106, 6)
        tumbleweed(cv, 186, 98, 4)


def desert_post(cv, wx):
    if wx == 'rain':
        streaks(cv, RAINC, n=160, seed=15)
    elif wx == 'storm':
        bolt(cv, [(40, 22), (46, 32), (38, 35), (47, 46), (40, 48), (44, 58)], branch=[(43, 40), (54, 43), (58, 50)])
        streaks(cv, '#a3aab0', n=230, seed=17, dx=-3, ln=5)
    elif wx == 'heat':
        shimmer(cv, 80, 88, '#f6e7c0', seed=2, x0=30, x1=90)
        shimmer(cv, 80, 88, '#f6e7c0', seed=5, x0=164, x1=212)
    elif wx == 'wind':
        # blowing sand: long low streaks across the lane
        for i in range(34):
            x = h32(i, 31) % (W + 20) - 10
            y = 64 + h32(i, 32) % 64
            ln = 6 + h32(i, 33) % 14
            cv.fill(rect(x, y, x + ln, y), '#f6e7c0' if i % 3 else '#d9b878')
        gusts(cv, ((30, 40, 28), (150, 52, 24), (96, 118, 22), (200, 110, 18)), '#f6e7c0')
        for (x, y) in ((56, 108), (62, 104), (52, 102)):
            cv.fill(rect(x - 8, y, x - 3, y), '#c9a96e')
    elif wx == 'fog':
        for (x, y, w) in ((-6, 96, 44), (150, 100, 56), (60, 118, 50), (186, 124, 40), (100, 106, 26)):
            cv.fill(rrect(x, y, x + w, y + 1, 1), '#e6e6dc')


LANDS = {
    'mountain': dict(sun=(186, 34), land=mountain_land, post=mountain_post, grade=MOUNTAIN_GRADE,
                     base={'#fff3c8': '#f1ece0', '#c9c5bc': '#d9d4ee', '#f2e4c0': '#f1ece0'}),
    'wetland': dict(sun=(198, 30), land=wetland_land, post=wetland_post, grade=WETLAND_GRADE,
                    base={'#fff3c8': '#f1ece0', '#f2e4c0': '#f1ece0', '#c9c5bc': '#f1ece0'}),
    'desert': dict(sun=(196, 32), land=desert_land, post=desert_post, grade=DESERT_GRADE,
                   base={'#f2e4c0': '#f6e7c0', '#f1ece0': '#f6e7c0', '#fff3c8': '#f6e7c0', '#cde6e8': '#f6e7c0'}),
}

# drawn variants and aliases (weather -> existing file key) per land
ALIAS = {
    'mountain': {'sun': 'mountain', 'heat': 'mountain'},
    'wetland': {'sun': 'wetland', 'rain': 'wetland-v2'},
    'desert': {'sun': 'desert', 'snow': 'desert-frost'},
}

SENT = '#010203'


def render(land, wx):
    L = LANDS[land]
    cv = Canvas()
    sky(cv, wx, L['sun'])
    lc = Canvas(SENT)
    L['land'](lc, wx)
    lm = ~np.all(lc.px == hx(SENT), axis=2)
    regrade(lc, L['base'])   # the v1 scene's own colour folds
    regrade(lc, L['grade'].get(wx, {}))
    cv.px[lm] = lc.px[lm]
    L['post'](cv, wx)
    return cv


def mapping(land):
    m = {}
    for wx in WEATHERS:
        m[wx] = ALIAS[land].get(wx, land + '-' + wx)
    return m


def drawn():
    out = []
    for land in LANDS:
        for wx, key in mapping(land).items():
            if key == land + '-' + wx:
                out.append((land, wx))
    return out


if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), '..', '..', 'game', 'assets', 'img', 'scenes')
    only = sys.argv[2:]
    for land, wx in drawn():
        k = land + '-' + wx
        if only and k not in only:
            continue
        cv = render(land, wx)
        n = check(cv, k)
        p = os.path.join(out, 'stage-' + k + '.png')
        cv.save(p)
        print(k, 'colours', n, '->', p)
    for land in LANDS:
        p = os.path.join(out, 'stage-weather-' + land + '.json')
        with open(p, 'w') as f:
            json.dump(mapping(land), f, indent=1)
            f.write('\n')
