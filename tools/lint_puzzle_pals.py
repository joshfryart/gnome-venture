#!/usr/bin/env python3
"""Lint the Puzzle Pals data (game/includes/data/puzzle_pals.txt and puzzle_pal_names.txt).
Usage: tools/lint_puzzle_pals.py [PALS.txt] [--names NAMES.txt] [--pics slug1,slug2] [--npcs NPC_NAMES.txt]
  --pics  extra picture slugs that exist (uploads); built-in slugs are read from game/includes/jigsaw.php (JIGSAWS), and slugs starting pl- are Places.
  --npcs  one NPC name per line; a pal may not share a name with one.
Checks: 14 columns, unique key (<= 48 chars, a-z 0-9 - _), picture exists, rarity, calling, stats 0-3 and the rarity's total band (common 3-4, uncommon 5, rare 6),
piece 0-11 x 0-7, shape + knob valid, perk valid, whole roster: at most 6 pals, 3/2/1 mix when it has 6, no shared shape+knob, unique names across ALL pictures,
no '|' in text, curly apostrophes, name banks (40 first names + 30 epithets per place kind, no dupes). Prints problems; exit 1 if any."""
import re, sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, '..', 'game', 'includes', 'data')
RARITY = {'common': (3, 4), 'uncommon': (5, 5), 'rare': (6, 6)}
MIX = {'common': 3, 'uncommon': 2, 'rare': 1}
CALLINGS = {'rootwarden', 'bloomcaller', 'thornblade', 'seedkeeper', 'wayfinder', 'brewroot'}
PERKS = {'-', 'gather', 'road', 'finder', 'tinker', 'bloom', 'shine'}
KNOBS = {'round', 'keyhole', 'peg', 'tri', 'double', 'hook'}
SHAPES = {'corner-TT', 'corner-TB', 'corner-BB', 'edge-TTB', 'edge-TBB', 'edge-TBT', 'edge-BTB', 'inner-TTTT', 'inner-BBBB', 'inner-TBTB', 'inner-TTBB', 'inner-TTTB', 'inner-TBBB'}
WHIM = re.compile(r'^whimsy-[a-z]{2,16}$')
KINDS = ['haven', 'wonder', 'delve', 'lair']

def opt(n):
    return sys.argv[sys.argv.index(n) + 1] if n in sys.argv else ''

def builtin_slugs():
    src = open(os.path.join(HERE, '..', 'game', 'includes', 'jigsaw.php'), encoding='utf-8').read()
    blk = src.split('const JIGSAWS = [', 1)[1].split('];', 1)[0]
    return set(re.findall(r"^\s*'([a-z0-9]+)'\s*=>\s*\[", blk, re.M))

def main():
    args = [a for i, a in enumerate(sys.argv[1:], 1) if not a.startswith('--') and not sys.argv[i - 1].startswith('--')]
    path = args[0] if args else os.path.join(DATA, 'puzzle_pals.txt')
    names_path = opt('--names') or os.path.join(DATA, 'puzzle_pal_names.txt')
    pics = builtin_slugs() | set(x for x in opt('--pics').split(',') if x)
    npcs = set(l.strip().lower() for l in open(opt('--npcs'), encoding='utf-8')) if opt('--npcs') else set()
    bad = []
    def err(ln, m): bad.append('%s: %s' % (ln, m))
    keys, seen_names, roster = {}, {}, {}
    for n, l in enumerate(open(path, encoding='utf-8'), 1):
        l = l.rstrip('\n')
        if not l.strip() or l.startswith('#'): continue
        c = l.split('|'); ln = 'line %d' % n
        if len(c) != 14: err(ln, '%d columns, want 14' % len(c)); continue
        pic, key, name, rar, call, g, ni, h, lu, piece, shape, knob, perk, blurb = c
        if key in keys: err(ln, 'duplicate key %s (line %d)' % (key, keys[key]))
        keys[key] = n
        if not re.fullmatch(r'[a-z0-9_-]{2,48}', key): err(ln, 'bad key %r' % key)
        if pic not in pics and not pic.startswith('pl-'): err(ln, 'unknown picture %r' % pic)
        if rar not in RARITY: err(ln, 'bad rarity %r' % rar)
        if call not in CALLINGS: err(ln, 'bad calling %r' % call)
        try:
            st = [int(x) for x in (g, ni, h, lu)]
            if any(x < 0 or x > 3 for x in st): err(ln, 'stats must be 0-3')
            if rar in RARITY and not RARITY[rar][0] <= sum(st) <= RARITY[rar][1]: err(ln, '%s stats total %d, want %d-%d' % (rar, sum(st), *RARITY[rar]))
        except ValueError: err(ln, 'stats are not numbers')
        m = re.fullmatch(r'(\d+)-(\d+)', piece)
        if not m or int(m.group(1)) > 11 or int(m.group(2)) > 7: err(ln, 'piece %r not col-row in 0-11 x 0-7' % piece)
        if shape not in SHAPES and not WHIM.match(shape): err(ln, 'bad shape %r' % shape)
        if rar == 'rare' and not WHIM.match(shape): err(ln, 'a rare pal should be a whimsy-* piece')
        if rar != 'rare' and WHIM.match(shape): err(ln, 'only a rare pal is a whimsy-* piece')
        if knob not in KNOBS: err(ln, 'bad knob %r' % knob)
        if perk not in PERKS: err(ln, 'bad perk %r' % perk)
        if not name.strip() or len(name) > 30: err(ln, 'name empty or over 30 chars')
        if not blurb.strip() or len(blurb) > 120: err(ln, 'blurb empty or over 120 chars')
        if "'" in name + blurb: err(ln, 'straight apostrophe: use ’')
        if name.lower() in seen_names: err(ln, 'name %r already used (line %d)' % (name, seen_names[name.lower()]))
        seen_names[name.lower()] = n
        if name.lower() in npcs: err(ln, 'name %r is an existing NPC' % name)
        roster.setdefault(pic, []).append((n, rar, shape, knob))
    for pic, rows in roster.items():
        if len(rows) > 6: err(pic, 'roster has %d pals, max 6' % len(rows))
        if len(rows) == 6:
            for r, want in MIX.items():
                got = sum(1 for x in rows if x[1] == r)
                if got != want: err(pic, 'roster has %d %s, want %d' % (got, r, want))
        seen = {}
        for n, rar, shape, knob in rows:
            if (shape, knob) in seen: err('line %d' % n, '%s: shape+knob %s/%s also on line %d' % (pic, shape, knob, seen[(shape, knob)]))
            seen[(shape, knob)] = n
    # name banks
    bank = {'first': {}, 'epithet': {}}
    for n, l in enumerate(open(names_path, encoding='utf-8'), 1):
        if not l.strip() or l.startswith('#'): continue
        c = l.rstrip('\n').split('|')
        if len(c) != 3 or c[0] not in bank or c[1] not in KINDS: err('names line %d' % n, 'want first|kind|a,b,c or epithet|kind|a,b,c'); continue
        w = [x for x in c[2].split(',') if x]
        if len(set(w)) != len(w): err('names line %d' % n, 'duplicate word in %s %s' % (c[0], c[1]))
        if "'" in c[2]: err('names line %d' % n, 'straight apostrophe')
        bank[c[0]][c[1]] = w
    for k in KINDS:
        if len(bank['first'].get(k, [])) < 40: err('names', '%s: %d first names, want 40' % (k, len(bank['first'].get(k, []))))
        if len(bank['epithet'].get(k, [])) < 30: err('names', '%s: %d epithets, want 30' % (k, len(bank['epithet'].get(k, []))))
    for b in bad: print(b)
    print('%d pals in %d pictures, %d problems' % (len(keys), len(roster), len(bad)))
    sys.exit(1 if bad else 0)

main()
