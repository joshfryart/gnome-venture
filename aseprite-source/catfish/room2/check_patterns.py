#!/usr/bin/env python3
"""check_patterns.py: pattern-count checks for run80 coats (grey space, recomputed from run80_coats).
python3 -I check_patterns.py"""
import os, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import numpy as np
import run80_coats as C

layers = C.load_layers(); pose, legs = C.parse_lua()
greys = [C.rd(os.path.join(C.OUT80, 'cf-cat-grey-run%02d.png' % (f + 1))) for f in range(C.NF)]
geo = [C.geometry(f, pose[f], legs[f]) for f in range(C.NF)]
infos = [C.classify(f, geo[f], layers, greys[f]) for f in range(C.NF)]
bad = 0
Ls = [pose[f]['L'] for f in range(C.NF)]
for p in C.R.PATTERNS:
    cnt = []; cov = []; body = []; comps = []
    for f in range(C.NF):
        img = C.make_pattern(p, infos[f]); m = img[..., 3] > 0
        cnt.append(int(m.sum())); cov.append(m.sum() / len(infos[f]))
        # body-zone features: pattern pixels on part 'body' and the number of separate 8-connected pieces
        bm = np.zeros(m.shape, bool)
        for k, d in infos[f].items():
            if d['part'] in ('body', 'haunch', 'chest') and m[k[1], k[0]]: bm[k[1], k[0]] = True
        body.append(int(bm.sum())); comps.append(len(C.components(bm)))
    # fill patterns (white / calico / points) follow the silhouette; judge the jump on coverage = pattern px / felt px, others on raw count
    ser = cov if p in ('tuxedo', 'calico', 'pointed') else cnt
    print('         jump on', 'coverage' if ser is cov else 'raw count', '; trunk(body+haunch+chest) px below')
    jumps = [abs(ser[(f + 1) % C.NF] - ser[f]) / ser[f] for f in range(C.NF)]
    print('%-8s counts %s' % (p, cnt))
    print('         L      %s' % Ls)
    print('         body px %s  body pieces %s  max jump %.1f%%' % (body, comps, 100 * max(jumps)))
    if max(jumps) > 0.08: print('         FAIL jump > 8%'); bad += 1
    if p in ('tabby', 'spotted'):
        need = 3
        if min(comps[3:6]) < need: print('         FAIL body feature vanished in frames 4-6'); bad += 1
print('check_patterns:', 'FAILED' if bad else 'ok')
sys.exit(1 if bad else 0)
