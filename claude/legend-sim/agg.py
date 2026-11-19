#!/usr/bin/env python3
"""Sum up legend_sim.php json lines.   usage: python3 agg.py FILE.jsonl...   (prints markdown tables)
Per level and bot the baseline is the tuner's gnome with no legend piece. A piece's numbers are its fights minus that baseline, in points:
  dwin  = win % with the piece - baseline win %           (+ = easier)
  dhp   = health lost % with the piece - baseline         (- = the piece saves health)
  mean over the bots and levels (each cell weighted the same); se = standard error of that mean from the cell variances.
  place = share of fights where the piece was placed at least once; fire = times it fired in a chain per fight.
Outlier rule: a piece is flagged when its (dwin, dhp) is more than 3 points from the median of all 42 pieces on that measure AND more than 2.5 standard errors from it.
"""
import json, sys, collections, statistics as st

def mean(x):
    x = list(x); return sum(x) / len(x) if x else 0.0

rows = collections.defaultdict(list)   # (lv, bot, crop) -> list of rows
meta = {}
for f in sys.argv[1:]:
    for l in open(f):
        l = l.strip()
        if not l.startswith('{'): continue
        r = json.loads(l); rows[(r['lv'], r['bot'], r['crop'])].append(r)
        if r['crop'] != 'base': meta[r['crop']] = (r['type'], r['v'], r['tag'])
levels = sorted({k[0] for k in rows}); bots = sorted({k[1] for k in rows}); crops = sorted(meta)
base = {}
for lv in levels:
    for b in bots:
        v = rows[(lv, b, 'base')]
        base[(lv, b)] = dict(win=100 * mean(r['win'] for r in v), hp=100 * mean(r['hp'] for r in v), turns=mean(r['turns'] for r in v), n=len(v),
                             vwin=(mean(r['win'] for r in v) * (1 - mean(r['win'] for r in v))) * 1e4, vhp=st.pvariance([100 * r['hp'] for r in v]))
print('## Baseline (no legend piece)\n')
print('| level | bot | fights | win % | health lost % | turns |\n|---|---|---|---|---|---|')
for (lv, b), v in sorted(base.items()): print(f"| {lv} | {b} | {v['n']} | {v['win']:.1f} | {v['hp']:.1f} | {v['turns']:.2f} |")
res = {}
for c in crops:
    cells = []; w_se = 0; h_se = 0; pl = []; fi = []; err = 0; turns = []
    for lv in levels:
        for b in bots:
            v = rows.get((lv, b, c), []);
            if not v: continue
            B = base[(lv, b)]; n = len(v); wr = mean(r['win'] for r in v)
            dw = 100 * wr - B['win']; dh = 100 * mean(r['hp'] for r in v) - B['hp']
            cells.append((dw, dh)); w_se += (wr * (1 - wr) * 1e4) / n + B['vwin'] / B['n']; h_se += st.pvariance([100 * r['hp'] for r in v]) / n + B['vhp'] / B['n']
            pl.append(mean(1 if r['pl'] else 0 for r in v)); fi.append(mean(r['fx'] for r in v)); err += sum(1 for r in v if 'err' in r); turns.append(mean(r['turns'] for r in v) - B['turns'])
    m = len(cells)
    res[c] = dict(dwin=mean(x[0] for x in cells), dhp=mean(x[1] for x in cells), sew=(w_se ** 0.5) / m, seh=(h_se ** 0.5) / m, place=mean(pl), fire=mean(fi), err=err, dturns=mean(turns),
                  bylv={lv: (mean(100 * mean(r['win'] for r in rows[(lv, b, c)]) - base[(lv, b)]['win'] for b in bots if rows.get((lv, b, c))), mean(100 * mean(r['hp'] for r in rows[(lv, b, c)]) - base[(lv, b)]['hp'] for b in bots if rows.get((lv, b, c)))) for lv in levels})
mw = st.median(r['dwin'] for r in res.values()); mh = st.median(r['dhp'] for r in res.values())
print(f"\nMedian over the {len(crops)} pieces: dwin {mw:+.2f}, dhp {mh:+.2f}\n")
print('## Per piece (mean over bots and levels; sorted by health)\n')
print('| piece | type v tag | dwin | dhp | se win / hp | placed | fires / fight | by level (dwin / dhp) | flag |\n|---|---|---|---|---|---|---|---|---|')
for c in sorted(crops, key=lambda c: res[c]['dhp']):
    r = res[c]; t, v, tag = meta[c]
    fl = []
    if abs(r['dwin'] - mw) > 3 and abs(r['dwin'] - mw) > 2.5 * r['sew']: fl.append('win ' + ('high' if r['dwin'] > mw else 'low'))
    if abs(r['dhp'] - mh) > 3 and abs(r['dhp'] - mh) > 2.5 * r['seh']: fl.append('health ' + ('saves' if r['dhp'] < mh else 'costs'))
    lvs = ' / '.join(f"{lv}: {r['bylv'][lv][0]:+.1f} {r['bylv'][lv][1]:+.1f}" for lv in levels)
    print(f"| {c} | {t} {v} {tag or '-'} | {r['dwin']:+.1f} | {r['dhp']:+.1f} | {r['sew']:.1f} / {r['seh']:.1f} | {100 * r['place']:.0f}% | {r['fire']:.2f} | {lvs} | {', '.join(fl) or ''} |")
print('\n## By type (mean of the pieces)\n')
print('| type | pieces | dwin | dhp | placed | fires / fight |\n|---|---|---|---|---|---|')
by = collections.defaultdict(list)
for c in crops: by[meta[c][0]].append(res[c])
for t, v in sorted(by.items()): print(f"| {t} | {len(v)} | {mean(x['dwin'] for x in v):+.1f} | {mean(x['dhp'] for x in v):+.1f} | {100 * mean(x['place'] for x in v):.0f}% | {mean(x['fire'] for x in v):.2f} |")
print('\nerrors:', sum(r['err'] for r in res.values()))
json.dump(res, open('legend_res.json', 'w'), indent=1)
