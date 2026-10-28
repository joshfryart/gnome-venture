#!/usr/bin/env python3
"""List the rest-stop activities that have no picture of their own yet (game/assets/img/acts/act-<slug>.png), with the brief for drawing it.
Usage: tools/missing_act_art.py [--csv]    Reads stop_acts.txt, stop_acts_regional.txt, stop_acts_waves.txt (tier upgrade acts tt_* are skipped)."""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, '..', 'game', 'includes', 'data')
ART = os.path.join(HERE, '..', 'game', 'assets', 'img', 'acts')
rows = []
for f in ('stop_acts.txt', 'stop_acts_regional.txt', 'stop_acts_waves.txt'):
    p = os.path.join(DATA, f)
    if not os.path.exists(p): continue
    for l in open(p, encoding='utf-8'):
        l = l.rstrip('\n')
        if not l.strip() or l.startswith('#'): continue
        c = l.split('|')
        if len(c) < 12 or c[0].startswith('tt_'): continue
        rows.append((c[0], c[1], c[3], c[6], c[11], f))
miss = [r for r in rows if not os.path.exists(os.path.join(ART, 'act-' + r[0] + '.png'))]
print(f'{len(miss)} of {len(rows)} activities have no own picture (they show their kind card)', file=sys.stderr)
for slug, name, types, kind, blurb, f in miss:
    print(('%s|%s|%s|%s|%s' if '--csv' in sys.argv else '%-22s %-30s [%s, %s] %s') % (slug, name, types, kind, blurb))
