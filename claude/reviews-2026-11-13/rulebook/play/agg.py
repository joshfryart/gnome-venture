import json, sys, collections
rows = [json.loads(l) for l in open(sys.argv[1])]
def agg(key):
    g = collections.defaultdict(list)
    for r in rows: g[key(r)].append(r)
    for k in sorted(g):
        v = g[k]; n = len(v); win = [r for r in v if r['over'] in ('seen_off', 'charmed')]
        m = lambda f: sum(f(r) for r in v) / n
        print(k, 'n', n, 'win%', round(100 * len(win) / n), 'charmed%', round(100 * sum(r['over'] == 'charmed' for r in v) / n), 'defeat', sum(r['over'] == 'defeat' for r in v), 'stall', sum(r['over'] == 'stall' for r in v),
              'turns', round(m(lambda r: r['turns']), 1), 'lost%', round(m(lambda r: r['lostpct'])), 'own%', round(100 * m(lambda r: r['own'] / r['max'])), 'ownFoe%', round(100 * m(lambda r: r['ownFoe'] / r['max'])), 'ownThorn%', round(100 * m(lambda r: r['ownThorn'] / r['max'])),
              'pass', round(m(lambda r: r['pass']), 2), 'blocked', round(m(lambda r: r['blocked']), 1), 'useups', round(m(lambda r: r['useups']), 1), 'emptyStart%', round(100 * sum(r['emptyStart'] for r in v) / max(1, sum(r['turns'] for r in v))),
              'aimOver%', round(100 * sum(r['aimOver'] for r in v) / max(1, sum(r['aimTurns'] for r in v))), 'aimOverNoPoison%', round(100 * sum(r.get('aimOverNP', 0) for r in v) / max(1, sum(r['aimTurns'] for r in v))), 'poison%', round(100 * m(lambda r: r.get('poisonLost', 0) / r['max'])), 'big%', round(100 * sum(r['big'] for r in v) / max(1, sum(r['aimTurns'] for r in v))), 'shown/real', round(sum(r['aimShown'] for r in v) / max(1, sum(r['aimTurns'] for r in v)), 1), round(sum(r['aimReal'] for r in v) / max(1, sum(r['aimTurns'] for r in v)), 1))
print('== by policy'); agg(lambda r: r['pol'])
print('== by policy, size'); agg(lambda r: (r['pol'], r['size']))
print('== reader and greedy by class rule'); rows2 = rows; rows = [r for r in rows if r['pol'] in ('reader', 'greedy')]; agg(lambda r: (r['kind'], r['pol']))
