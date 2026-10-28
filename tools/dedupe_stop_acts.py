#!/usr/bin/env python3
"""Find repeats among rest-stop activities: the shipped files plus any drafts.
Usage: tools/dedupe_stop_acts.py [DRAFT.txt ...]   (compares every row with every other; prints flagged pairs; exit 1 if any)
Flags: same or very similar name; blurbs that share most of their wording; identical craft spec / contest moves / pick label+n; collect sets with the
same label or overlapping entries; the same tale; the same win line. Region rows are compared with everything (a regional idea must not repeat a plain one)."""
import os, re, sys, difflib, itertools
HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, '..', 'game', 'includes', 'data')
def load(path, tag):
    out = []
    for l in open(path, encoding='utf-8'):
        l = l.rstrip('\n')
        if l.strip() and not l.startswith('#'):
            c = l.split('|')
            if len(c) >= 12 and not c[0].startswith('tt_'): out.append((tag, c))
    return out
rows = []
for f in ('stop_acts.txt', 'stop_acts_regional.txt', 'stop_acts_waves.txt'):
    p = os.path.join(DATA, f)
    if os.path.exists(p): rows += load(p, f)
for d in sys.argv[1:]: rows += load(d, os.path.basename(d))
seen = {}
uniq = []
for t, c in rows:   # a draft already shipped under the same slug is the same row, not a repeat
    if c[0] in seen: continue
    seen[c[0]] = 1; uniq.append((t, c))
rows = uniq
def words(s): return set(re.findall(r'[a-z]{4,}', s.lower()))
def norm(s): return re.sub(r'[^a-z ]', '', s.lower()).strip()
def spec(c):
    p = {}
    for x in c[8].split(';'):
        if '=' in x: k, v = x.split('=', 1); p[k] = v
    return p
flags = []
for (ta, a), (tb, b) in itertools.combinations(rows, 2):
    why = []
    na, nb = norm(a[1]), norm(b[1])
    if na == nb or difflib.SequenceMatcher(None, na, nb).ratio() >= 0.85: why.append('name')
    wa, wb = words(a[11]), words(b[11])
    if wa and wb and len(wa & wb) / min(len(wa), len(wb)) >= 0.6 and len(wa & wb) >= 6: why.append('blurb wording')
    if a[6] == b[6]:
        k = a[6]
        if k == 'craft' and a[8] == b[8]: why.append('same craft')
        if k == 'contest' and set(spec(a).get('moves', '').lower().split('/')) == set(spec(b).get('moves', '').lower().split('/')): why.append('same moves')
        if k == 'pick' and norm(spec(a).get('label', '')) == norm(spec(b).get('label', '')) and spec(a).get('label') and a[3] == b[3]: why.append('same pick label')
        if k == 'collect':
            ea = {x.lower() for x in spec(a).get('items', '').split('/') if x}; eb = {x.lower() for x in spec(b).get('items', '').split('/') if x}
            if ea and eb and len(ea & eb) / min(len(ea), len(eb)) >= 0.5: why.append('collect entries overlap')
            if norm(spec(a).get('label', '')) == norm(spec(b).get('label', '')): why.append('same collect label')
        if k == 'lore':
            if {t.strip().lower() for t in a[8].split(';;')} & {t.strip().lower() for t in b[8].split(';;')}: why.append('same tale')
    if a[12].strip() and a[12].strip().lower() == b[12].strip().lower() and a[6] != 'craft': why.append('same win line')
    if why: flags.append(f'{a[0]} ({ta}) ~ {b[0]} ({tb}): {", ".join(why)}   [{a[1]} / {b[1]}]')
print(f'{len(rows)} rows compared, {len(flags)} flagged')
for f in flags: print('  ' + f)
sys.exit(1 if flags else 0)
