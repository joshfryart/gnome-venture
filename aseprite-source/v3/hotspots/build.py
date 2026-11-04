#!/usr/bin/env python3
"""Build hotspot buttons: python3 build.py [key ...]. Writes hs-<key>.lua/.png/.aseprite here and runs Aseprite."""
import math, os, subprocess, sys
from bodies import B
HERE = os.path.dirname(os.path.abspath(__file__))
AS = '/tmp/aseq/squashfs-root/AppRun'
pre = open(os.path.join(HERE, 'prelude.lua')).read()
DIRS = {'N': 0, 'NE': 45, 'E': 90, 'SE': 135, 'S': 180, 'SW': 225, 'W': 270, 'NW': 315}
def arrow(a):
    t = math.radians(DIRS[a])
    pts = [(-5, 13), (-5, -2), (-14, -2), (0, -19), (14, -2), (5, -2), (5, 13)]
    q = [[round(24 + x * math.cos(t) - y * math.sin(t), 2), round(24 + x * math.sin(t) + y * math.cos(t), 2)] for x, y in pts]
    return 'fill(poly{%s}, %s)\n' % (','.join('{%s,%s}' % tuple(p) for p in q), 'R.GOAL' )
jobs = {}
for k, b in B.items(): jobs['hs-' + k] = (b, False)
for a in DIRS:
    jobs['hs-exit-' + a] = (arrow(a).replace('R.GOAL', 'R.cream'), False)
    jobs['hs-exit-' + a + '-goal'] = (arrow(a).replace('R.GOAL', 'R.gold'), True)
want = sys.argv[1:]
for name, (body, goal) in jobs.items():
    if want and name[3:] not in want: continue
    src = pre + '\n' + body + '\nfinish(%r, {goal=%s})\n' % (name, 'true' if goal else 'false')
    open(os.path.join(HERE, name + '.lua'), 'w').write(src)
    r = subprocess.run([AS, '-b', '--script-param', 'out=' + HERE + '/', '--script', os.path.join(HERE, name + '.lua')], capture_output=True, text=True)
    print((r.stdout + r.stderr).strip()[:300])
