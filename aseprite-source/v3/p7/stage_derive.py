#!/usr/bin/env python3
"""Derive a landscape's weather and dawn/dusk stage art from its hand-drawn clear-day base.
usage: stage_derive.py <land> <base.png> <outdir>
Writes stage-<key>.png for every key the game uses for that land (scene.php DAYPART_STAGE_ART + stage-weather-<land>.json) except the base itself.
Hard pixels only: per-pixel colour maps plus the transparent weather overlays from gather/out/weather-*.png."""
import sys, os, json, colorsys, importlib.util, random, math
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
GATHER = os.path.join(HERE, '..', 'gather')
spec = importlib.util.spec_from_file_location('grade', os.path.join(GATHER, 'grade.py')); G = importlib.util.module_from_spec(spec); spec.loader.exec_module(G)
GAME = os.path.join(HERE, '../../../game/assets/img/scenes')

def clamp(t): return tuple(max(0, min(255, int(round(c * 255)))) for c in t)
def overcast(k, dark=.88, sat=.62, cool=.10):
    r, g, b = [c / 255 for c in k]; h, s, v = colorsys.rgb_to_hsv(r, g, b)
    t = colorsys.hsv_to_rgb(h, s * sat, v * dark); t = G.mixc(t, (.55, .62, .74), cool); return clamp(t)
def stormy(k): return overcast(k, .72, .5, .16)
def frosty(k):
    r, g, b = [c / 255 for c in k]; h, s, v = colorsys.rgb_to_hsv(r, g, b)
    t = colorsys.hsv_to_rgb(h, s * .75, min(1, v * 1.04)); t = G.mixc(t, (.72, .86, 1.0), .24); return clamp(t)
def snowy(k):
    r, g, b = [c / 255 for c in k]; h, s, v = colorsys.rgb_to_hsv(r, g, b)
    t = colorsys.hsv_to_rgb(h, s * .6, v * .96); t = G.mixc(t, (.8, .88, .98), .32); return clamp(t)
def hazy(k): return clamp(G.mixc([c / 255 for c in k], (.86, .89, .93), .5))
def hot(k):
    r, g, b = [c / 255 for c in k]; h, s, v = colorsys.rgb_to_hsv(r, g, b)
    t = colorsys.hsv_to_rgb(h, min(1, s * 1.02), min(1, v * 1.03)); return clamp((t[0] * 1.03, t[1] * 1.0, t[2] * .93))
def windy(k): return k
def cloudy(k): return overcast(k, .94, .8, .06)
def dawn(k):
    r, g, b = [c / 255 for c in k]; h, s, v = colorsys.rgb_to_hsv(r, g, b)
    t = colorsys.hsv_to_rgb(h, s * .95, v * .93); t = (t[0] * 1.08, t[1] * .94, t[2] * 1.0)
    t = G.mixc(t, (.96, .62, .72), .16)
    if v > .75: t = G.mixc(t, (1.0, .82, .6), .15)
    return clamp(t)
def dusk(k): return G.dusk(k)

def apply(base, fn, overlay=None):
    im = base.copy(); px = im.load(); cache = {}
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a == 0: continue
            kk = (r, g, b)
            if kk not in cache: cache[kk] = fn(kk)
            px[x, y] = cache[kk] + (a,)
    if overlay:
        ov = Image.open(os.path.join(GATHER, 'out', f'weather-{overlay}.png')).convert('RGBA'); im.alpha_composite(ov)
    return im

RECIPE = {'cloud': (cloudy, 'cloud'), 'rain': (overcast, 'rain'), 'storm': (stormy, 'storm'), 'frost': (frosty, 'frost'), 'snow': (snowy, 'snow'),
          'heat': (hot, None), 'wind': (windy, 'wind'), 'fog': (hazy, None)}
DAYPART = {'grassland': {'dawn': 'grassland-v2'}, 'forest': {'dusk': 'forest-v2'}, 'coast': {'dawn': 'coast-v2', 'dusk': 'coast-v2'}, 'mountain': {'dawn': 'mountain-v2'},
           'wetland': {'dusk': 'wetland-v3'}, 'desert': {'dawn': 'desert-v2', 'dusk': 'desert-v3'}, 'rainforest': {'dawn': 'rainforest-v2'},
           'tundra': {'dawn': 'tundra-v2'}, 'island': {'dawn': 'island-v2', 'dusk': 'island-v3'}}
if __name__ == '__main__':
    land, basep, outd = sys.argv[1:4]
    base = Image.open(basep).convert('RGBA'); os.makedirs(outd, exist_ok=True)
    wmap = json.load(open(os.path.join(GAME, f'stage-weather-{land}.json')))
    done = {}
    for wx, key in wmap.items():
        if key == land or key in done or wx == 'sun': continue
        if wx not in RECIPE: continue
        fn, ov = RECIPE[wx]; done[key] = wx
        apply(base, fn, ov).save(os.path.join(outd, f'stage-{key}.png'))
    for part, key in DAYPART.get(land, {}).items():
        if key in done: continue
        done[key] = part
        apply(base, dawn if part == 'dawn' else dusk).save(os.path.join(outd, f'stage-{key}.png'))
    print(land, sorted(done.items()))
