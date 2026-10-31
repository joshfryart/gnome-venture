#!/usr/bin/env python3
"""Lint the Puzzle Pal Boons (game/includes/data/puzzle_pal_boons.txt) against puzzle_pals.txt and the effect list in includes/puzzle_pals.php.
Usage: tools/lint_pal_boons.py [BOONS.txt] [--require-boons]
Checks: 5 columns, one row per key, key is a pal, effect and active valid (read from PPAL_EFFECTS / PPAL_ACTIVES in puzzle_pals.php), active only on a rare,
name unique and <= 24 chars, line <= 120 chars, curly apostrophes, no '|'; per roster: 6 different effects, and no two rosters share 4 or more of their effects (as a set);
each rare's (effect, active) pair is unique. --require-boons: every pal needs a row. Prints a fingerprint per roster. Exit 1 on any problem."""
import re, sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, '..', 'game', 'includes', 'data')
SRC = open(os.path.join(HERE, '..', 'game', 'includes', 'puzzle_pals.php'), encoding='utf-8').read()
EFFECTS = set(re.findall(r"^\s*'([a-z]+)' => \['[^']+', \[", SRC.split('const PPAL_EFFECTS = [', 1)[1].split('];', 1)[0], re.M))
ACTIVES = set(re.findall(r"^\s*'([a-z]+)' => \[\d", SRC.split('const PPAL_ACTIVES = [', 1)[1].split('];', 1)[0], re.M))

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    path = args[0] if args else os.path.join(DATA, 'puzzle_pal_boons.txt')
    pals = {}
    for l in open(os.path.join(DATA, 'puzzle_pals.txt'), encoding='utf-8').read().splitlines():
        c = l.split('|')
        if l.strip() and l[0] != '#' and len(c) == 14: pals[c[1]] = (c[0], c[3])
    bad, rows, names = [], {}, {}
    for n, l in enumerate(open(path, encoding='utf-8').read().splitlines(), 1):
        if not l.strip() or l[0] == '#': continue
        c = l.split('|')
        if len(c) != 5: bad.append('line %d: %d columns, want 5' % (n, len(c))); continue
        key, name, eff, act, line = c
        if key in rows: bad.append('line %d: duplicate key %s' % (n, key))
        if key not in pals: bad.append('line %d: %s is not a pal' % (n, key)); continue
        if eff not in EFFECTS: bad.append('line %d: %s: unknown effect %s' % (n, key, eff))
        if act != '-' and act not in ACTIVES: bad.append('line %d: %s: unknown active %s' % (n, key, act))
        if act != '-' and pals[key][1] != 'rare': bad.append('line %d: %s: only a rare may have an active' % (n, key))
        if len(name) > 24 or not name: bad.append('line %d: %s: name length' % (n, key))
        if name.lower() in names: bad.append('line %d: name %s also on %s' % (n, name, names[name.lower()]))
        names[name.lower()] = key
        if len(line) > 120: bad.append('line %d: %s: line over 120 chars' % (n, key))
        if "'" in name + line: bad.append('line %d: %s: straight apostrophe, use ’' % (n, key))
        rows[key] = (eff, act)
    ros = {}
    for key, (pic, rar) in pals.items():
        ros.setdefault(pic, []).append(key)
    sets = {}
    rares = {}
    for pic, keys in sorted(ros.items()):
        got = [k for k in keys if k in rows]
        if '--require-boons' in sys.argv and len(got) != len(keys): bad.append('%s: %d of %d pals have no Boon' % (pic, len(keys) - len(got), len(keys)))
        if not got: continue
        effs = [rows[k][0] for k in got]
        if len(set(effs)) != len(effs): bad.append('%s: effects repeat: %s' % (pic, ', '.join(effs)))
        sets[pic] = set(effs)
        for k in got:
            if pals[k][1] == 'rare':
                pair = rows[k]
                if pair in rares: bad.append('%s: rare %s has the same (effect, active) as %s' % (pic, k, rares[pair]))
                rares[pair] = k
        print('%s: %s' % (pic, ' '.join(rows[k][0] + ('+' + rows[k][1] if rows[k][1] != '-' else '') for k in got)))
    pics = sorted(sets)
    for i, a in enumerate(pics):
        for b in pics[i + 1:]:
            if len(sets[a] & sets[b]) >= 4 and len(sets[a]) == 6: bad.append('TOO ALIKE %s ~ %s: share %s' % (a, b, ','.join(sorted(sets[a] & sets[b]))))
    for b in bad: print('PROBLEM', b)
    print('%d Boons, %d rosters, %d problems' % (len(rows), len(sets), len(bad)))
    sys.exit(1 if bad else 0)
main()
