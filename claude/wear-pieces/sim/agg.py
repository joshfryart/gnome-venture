#!/usr/bin/env python3
"""Aggregate wear_sim.php json lines into a summary per piece.
usage: python3 agg.py OUT.json FILE.jsonl...   (writes OUT.json; prints the baseline and the per-region table)
All deltas are points: win % and health lost % (of max health); negative health = less health lost = the piece helps. Per bot (look = careful, greedy = careless), then their mean.
  eff   = fx - plain, paired (same deck size, same seed): the effect alone. Precise.
  piece = plain - base, unpaired: what one more piece of that type and value is worth. Noisy per piece, so it is smoothed:
          piece_s = region mean (every piece of the region) + type offset (every region) (+ for a Rare at Fine, its rank step measured the same way).
  est   = piece_s + eff: the per-piece estimate used for the goals. raw = fx - base (unsmoothed, for reference).
  play  = share of fights where you placed it at least once; fire = wear effect actions per fight.
"""
import json, sys, collections, statistics as st

ORDER = ['NA','CA','NWE','CB','SE','SA','EE','MENA','EA','CSA','SEA','WCA','ESA','OC']
BOTS = ('look', 'greedy')

def mean(x): x = list(x); return sum(x) / len(x) if x else 0.0

def load(files):
    base = collections.defaultdict(list)      # (bot, reg) -> rows
    pairs = collections.defaultdict(dict)     # (slug, rank, bot, k) -> md -> row
    meta = {}
    for f in files:
        for l in open(f):
            r = json.loads(l)
            if r['md'] == 'base': base[(r['bot'], r['reg'])].append(r)
            else:
                pairs[(r['slug'], r['rank'], r['bot'], r['k'])][r['md']] = r
                meta[r['slug']] = (r['reg'], r['rar'], r['type'], r['code'])
    return base, pairs, meta

def summarise(base, pairs, meta):
    B = {k: {'win': 100 * mean(r['win'] for r in v), 'hp': 100 * mean(r['hp'] for r in v), 'turns': mean(r['turns'] for r in v), 'n': len(v),
             'sd': st.pstdev([100 * r['hp'] for r in v])} for k, v in base.items()}
    acc = collections.defaultdict(lambda: collections.defaultdict(lambda: collections.defaultdict(list)))
    for (slug, rank, bot, k), m in pairs.items():
        if 'fx' not in m or 'plain' not in m: continue
        fx, pl = m['fx'], m['plain']; d = acc[(slug, rank)][bot]
        for key, val in (('fw', fx['win']), ('fh', fx['hp']), ('ft', fx['turns']), ('pw', pl['win']), ('ph', pl['hp']), ('pt', pl['turns']),
                         ('play', 1 if fx['pl'] else 0), ('fire', fx['fx']), ('err', 1 if 'err' in fx or 'err' in pl else 0),
                         ('diff', 1 if (fx['hp'], fx['turns'], fx['win']) != (pl['hp'], pl['turns'], pl['win']) else 0)):
            d[key].append(val)
    out = {}
    for (slug, rank), bb in acc.items():
        reg, rar, ty, code = meta[slug]; o = {'slug': slug, 'rank': rank, 'reg': reg, 'rar': rar, 'type': ty, 'code': code}
        for bot, d in bb.items():
            b = B.get((bot, reg))
            if not b: continue
            n = len(d['fw'])
            eh = [100 * (x - y) for x, y in zip(d['fh'], d['ph'])]
            o[bot] = {'n': n, 'ewin': 100 * (mean(d['fw']) - mean(d['pw'])), 'ehp': mean(eh), 'se_ehp': st.pstdev(eh) / n ** 0.5,
                      'pwin': 100 * mean(d['pw']) - b['win'], 'php': 100 * mean(d['ph']) - b['hp'], 'pturns': mean(d['pt']) - b['turns'],
                      'rwin': 100 * mean(d['fw']) - b['win'], 'rhp': 100 * mean(d['fh']) - b['hp'], 'eturns': mean(d['ft']) - mean(d['pt']),
                      'play': mean(d['play']), 'fire': mean(d['fire']), 'diff': mean(d['diff']), 'err': sum(d['err'])}
        bots = [b for b in BOTS if b in o]
        if not bots: continue
        for k in o[bots[0]]:
            if k != 'n': o[k] = mean(o[b][k] for b in bots)
        out[f'{slug}@{rank}'] = o
    # smoothing of the unpaired part: region mean + type offset, per rank
    for rank in {o['rank'] for o in out.values()}:
        g = [o for o in out.values() if o['rank'] == rank]
        for m in ('php', 'pwin', 'pturns'):
            rm = {r: mean(o[m] for o in g if o['reg'] == r) for r in ORDER}
            tm = collections.defaultdict(list)
            for o in g: tm[o['type']].append(o[m] - rm[o['reg']])
            for o in g: o[m + '_s'] = rm[o['reg']] + mean(tm[o['type']])
    for m in ('php', 'pwin', 'pturns'):   # a higher rank: the same piece's smoothed Common value + the mean rank step over every piece run at both ranks (4 Rares a region are too few to smooth alone)
        for rank in {o['rank'] for o in out.values()} - {1}:
            both = [(o, out.get(f"{o['slug']}@1")) for o in out.values() if o['rank'] == rank and f"{o['slug']}@1" in out]
            if not both: continue
            step = mean(o[m] - c[m] for o, c in both)
            for o, c in both: o[m + '_s'] = c[m + '_s'] + step
    for o in out.values():
        o['est_hp'] = o['php_s'] + o['ehp']; o['est_win'] = o['pwin_s'] + o['ewin']; o['est_turns'] = o['pturns_s'] + o['eturns']
    return out, B

def table(out, B):
    L = ['baseline (no wear piece): win % / health lost % / turns, careful (look) | careless (greedy)']
    for reg in ORDER:
        if ('look', reg) in B:
            a, b = B[('look', reg)], B[('greedy', reg)]
            L.append(f"{reg:5} n={a['n']} {a['win']:5.1f} {a['hp']:5.1f} {a['turns']:4.1f} | {b['win']:5.1f} {b['hp']:5.1f} {b['turns']:4.1f}")
    for rank in sorted({o['rank'] for o in out.values()}):
        L.append(f'\nrank {rank}: mean per region and rarity. est = smoothed piece + effect; eff = effect alone; play = fights it was placed; fire = effect actions a fight')
        for reg in ORDER:
            for rar in ('Common', 'Uncommon', 'Rare'):
                g = [o for o in out.values() if o['rank'] == rank and o['reg'] == reg and o['rar'] == rar]
                if g: L.append(f"{reg:5} {rar:9} n={len(g):2} est win {mean(o['est_win'] for o in g):+5.1f} hp {mean(o['est_hp'] for o in g):+6.1f} | eff win {mean(o['ewin'] for o in g):+5.1f} hp {mean(o['ehp'] for o in g):+6.1f} | piece hp {mean(o['php_s'] for o in g):+6.1f} | raw hp {mean(o['rhp'] for o in g):+6.1f} | play {mean(o['play'] for o in g):.2f} fire {mean(o['fire'] for o in g):.2f}")
    return '\n'.join(L)

if __name__ == '__main__':
    base, pairs, meta = load(sys.argv[2:]); out, B = summarise(base, pairs, meta)
    json.dump({'pieces': out, 'base': {f'{k[0]}|{k[1]}': v for k, v in B.items()}}, open(sys.argv[1], 'w'), indent=0)
    print('pieces', len(out), 'errors', sum(o['err'] for o in out.values()))
    print(table(out, B))
