#!/usr/bin/env python3
"""Build game/includes/data/build_plans.txt from claude/build-plans-base.txt, scaling costs by region level.

Rule (Josh approved 2026-11-10; region levels from includes/progression.php REGION_LEVELS):
  factor = 1 + (L - 1) / 40            (L = region level 1..35; Maplewold L=1 stays as written in the base file)
  item:slug:N, meal:N, fine:N   -> max(1, round_half_up(N * factor)); tools handed in and used up are NOT scaled
  coins:N                       -> N + 5 * (L - 1)
  days:N:E (clear stages)       -> never changed
Edit the base file, then run:  python3 tools/scale_build_plans.py   (idempotent: always rebuilt from the base)
"""
import re, sys, os
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
BASE = os.path.join(ROOT, 'claude', 'build-plans-base.txt')
OUT = os.path.join(ROOT, 'game', 'includes', 'data', 'build_plans.txt')
LEVELS = {'NA': 1, 'CA': 4, 'NWE': 6, 'CB': 8, 'SE': 10, 'SA': 12, 'EE': 14, 'MENA': 17, 'EA': 20, 'CSA': 23, 'SEA': 26, 'WCA': 29, 'ESA': 32, 'OC': 35}
TOOLS = {'tin-lantern', 'glowcap-lantern', 'miner-s-lantern', 'hatchet', 'harvest-trug', 'woven-basket', 'diver-s-creel', 'fine-mesh-net', 'camping-gear', 'masterwork-barrow'}
HEADER = """# Costs scale with the region's level (rule in tools/scale_build_plans.py; this file is GENERATED from claude/build-plans-base.txt, edit the base and re-run):
#   factor = 1 + (L - 1) / 40, L = region level (Maplewold 1 ... Oceania 35); item / meal / fine counts x factor (rounded, min 1; tools handed in are not scaled);
#   coins: + 5 per level above 1; clear stages (days:N:E) are never changed. Example: 4 Rope + 250 Petals at level 1 is 7 Rope + 420 Petals at level 35.
"""

def scale_need(n, f, L):
    kind = n.split(':')[0]
    if kind == 'coins':
        return 'coins:%d' % (int(n.split(':')[1]) + 5 * (L - 1))
    if kind == 'item':
        _, slug, q = n.split(':')
        if slug in TOOLS: return n
        return 'item:%s:%d' % (slug, max(1, int(int(q) * f + 0.5)))
    if kind in ('meal', 'fine'):
        return '%s:%d' % (kind, max(1, int(int(n.split(':')[1]) * f + 0.5)))
    return n

region = None
out = []
for line in open(BASE, encoding='utf-8').read().split('\n'):
    m = re.match(r'# -+ .*\((\w+)\)\s*$', line)
    if m: region = m.group(1)
    if line.startswith('P|'):
        p = line.split('|')
        L = LEVELS[region]
        f = 1 + (L - 1) / 40
        p[5] = ','.join(scale_need(n, f, L) for n in p[5].split(','))
        line = '|'.join(p)
    out.append(line)
text = '\n'.join(out)
# header block goes after the opening comment lines (before the first region marker)
i = text.index('# ------')
text = text[:i] + HEADER + text[i:]
open(OUT, 'w', encoding='utf-8').write(text)
print('wrote', OUT)
