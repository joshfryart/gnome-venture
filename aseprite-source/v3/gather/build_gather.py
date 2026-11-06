#!/usr/bin/env python3
"""Assemble the layered gather art into game/assets/img/gather (run from aseprite-source/v3/gather).
scene3-<land>[-dusk|-night].png  from out/scene-<land>.png (+ graded)
satchel-back|front-<key>[-dusk|-night].png from out/satchel-*-<key>.png (+ graded)
weather-*.png from out/weather-*.png
Only lands whose out/scene-<land>.png exists are published; the game falls back to the old art for the rest."""
import os, shutil, sys, subprocess
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'out')
DST = os.path.abspath(os.path.join(HERE, '../../../game/assets/img/gather'))
LANDS = ['coast', 'mountain', 'forest', 'desert', 'rainforest', 'grassland', 'wetland', 'tundra', 'island']
KEYS = ['leather', 'canvas', 'patchwork']
done = []
def graded(src, dst_base):
    shutil.copyfile(src, dst_base + '.png')
    subprocess.check_call([sys.executable, os.path.join(HERE, 'grade.py'), src, dst_base + '-dusk.png', dst_base + '-night.png'])
for l in LANDS:
    s = os.path.join(OUT, f'scene-{l}.png')
    if os.path.isfile(s): graded(s, os.path.join(DST, f'scene3-{l}')); done.append(l)
for k in KEYS:
    for part in ('back', 'front'):
        s = os.path.join(OUT, f'satchel-{part}-{k}.png')
        if os.path.isfile(s): graded(s, os.path.join(DST, f'satchel-{part}-{k}'))
for w in ('rain', 'storm', 'frost', 'wind', 'fog', 'cloud'):
    s = os.path.join(OUT, f'weather-{w}.png')
    if os.path.isfile(s): shutil.copyfile(s, os.path.join(DST, f'weather-{w}.png'))
print('published lands:', ', '.join(done))
