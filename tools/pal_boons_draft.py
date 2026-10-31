#!/usr/bin/env python3
"""Propose Boon effects (and the rare's active) for Puzzle Pal rosters.
Usage: tools/pal_boons_draft.py [--gallery | SLUG ...]   (no names = the 14 gallery pictures without a Boon row yet)
Prints key|effect|active|? rows (name and line are written afterwards by the Opus review). Seeded by crc32(slug), so reruns give the same draft.
Rules (claude/brainstorm-pal-rosters.md 3.2): 6 different effects per roster, no two rosters share 4 or more effects, each rare's (effect, active) pair unique,
slot pools per rarity; among the legal drafts it prefers the one where most pals keep the effect their calling has today."""
import os, random, re, sys, zlib
HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, '..', 'game', 'includes', 'data')
COMMON_POOL = ['mend', 'sip', 'feast', 'petal', 'guard', 'bulwark', 'slip', 'first']
UNCOMMON_POOL = ['ward', 'foot', 'bulwark', 'slip', 'guard', 'first', 'rally', 'feast', 'edge', 'mend']
RARE_POOL = ['edge', 'first', 'rally', 'petal', 'foot', 'ward', 'bulwark', 'guard', 'mend', 'sip', 'slip', 'feast']
ACTIVES = ['strike', 'shield', 'patch']
CALLING_EFFECT = {'rootwarden': 'ward', 'thornblade': 'edge', 'wayfinder': 'foot', 'seedkeeper': 'mend', 'brewroot': 'sip', 'bloomcaller': 'petal'}

def load():
    pals, order = {}, []
    for l in open(os.path.join(DATA, 'puzzle_pals.txt'), encoding='utf-8').read().splitlines():
        c = l.split('|')
        if l.strip() and l[0] != '#' and len(c) == 14:
            pals.setdefault(c[0], []).append({'key': c[1], 'rarity': c[3], 'calling': c[4]})
    boons = {}
    p = os.path.join(DATA, 'puzzle_pal_boons.txt')
    for l in open(p, encoding='utf-8').read().splitlines():
        c = l.split('|')
        if l.strip() and l[0] != '#' and len(c) == 5: boons[c[0]] = (c[2], c[3])
    return pals, boons

def main():
    pals, boons = load()
    names = [a for a in sys.argv[1:] if not a.startswith('--')]
    if not names: names = [s for s in pals if not s.startswith('pl-') and not all(p['key'] in boons for p in pals[s])]
    for attempt in range(60):   # a roster that finds no legal draft after the others: try another order (still deterministic)
        order = names[:] if attempt == 0 else random.Random(attempt).sample(names, len(names))
        out = draft(pals, boons, order)
        if out is not None: print(out, end=''); return
    print('# no legal draft for this set in 60 orders')

def draft(pals, boons, names):
    lines = []
    sets, rares = [], set()
    for s, ps in pals.items():
        if all(p['key'] in boons for p in ps):
            sets.append(set(boons[p['key']][0] for p in ps))
            for p in ps:
                if p['rarity'] == 'rare': rares.add(boons[p['key']])
    for slug in names:
        rng = random.Random(zlib.crc32(slug.encode()))
        best = None
        for _ in range(20000):
            pick, used = [], set()
            for p in pals[slug]:
                pool = {'common': COMMON_POOL, 'uncommon': UNCOMMON_POOL, 'rare': RARE_POOL}[p['rarity']]
                opts = [e for e in pool if e not in used]
                if not opts: break
                e = rng.choice(opts); used.add(e); pick.append(e)
            if len(pick) != len(pals[slug]): continue
            act = rng.choice(ACTIVES)
            rare_e = [e for p, e in zip(pals[slug], pick) if p['rarity'] == 'rare'][0]
            if (rare_e, act) in rares: continue
            if any(len(used & o) >= 4 for o in sets): continue
            score = sum(1 for p, e in zip(pals[slug], pick) if CALLING_EFFECT.get(p['calling']) == e)
            if best is None or score > best[0]: best = (score, pick, act)
        if not best:
            return None
        _, pick, act = best
        sets.append(set(pick))
        for p, e in zip(pals[slug], pick):
            a = act if p['rarity'] == 'rare' else '-'
            if p['rarity'] == 'rare': rares.add((e, act))
            lines.append('%s|%s|%s|?' % (p['key'], e, a))
    order_key = {s: i for i, s in enumerate(pals)}
    lines.sort(key=lambda l: [i for i, s in enumerate(pals) if any(p['key'] == l.split('|')[0] for p in pals[s])][0])
    return '\n'.join(lines) + '\n'
main()
