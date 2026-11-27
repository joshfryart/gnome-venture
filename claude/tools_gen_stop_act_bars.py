#!/usr/bin/env python3
"""Generate the act -> bar assignment for the 'Lasting marks' proposal (claude/proposal-stop-perks.md, section 2).

Proposal tooling only: reads the game's act data, writes nothing under game/.

    python3 claude/tools_gen_stop_act_bars.py            # writes claude/proposal-stop-act-bars.txt, prints the share table
    python3 claude/tools_gen_stop_act_bars.py --check    # same, but only prints (no file written)

Rules (section 2, first match wins):
  0. override: a row in stop_act_state.txt "moves" names the bar(s) (numbers ignored)
  1. tags: STOP_TAG_WORDS from game/includes/stops.php, with the two fixes
       (a) a tag word matches a whole word or that word plus a plain ending (pie, pies; never pier)
       (b) tags found in the NAME rank before tags found in the blurb; inside each: fix>craft>cook>gather>tend>trade>play>lore>rest
     plus the extra cook words the doc asks for (fry, broth, cordial, porridge, pickle)
  2. first bar by act kind; 3. stop type signature / lean / moves; 4. second bar (half points)
Base points B by energy: 0 = 6, 1 = 9, 2 = 12, 3+ = 15 (before D/W/F/V).
Deterministic: no randomness, files read in a fixed order, output sorted by file order then type order.
"""
import os
import re
import sys
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, 'game', 'includes', 'data')
STOPS_PHP = os.path.join(ROOT, 'game', 'includes', 'stops.php')
OUT = os.path.join(ROOT, 'claude', 'proposal-stop-act-bars.txt')

ACT_FILES = ['stop_acts.txt', 'stop_acts_regional.txt', 'stop_acts_waves.txt', 'stop_acts_living.txt']
TYPES = ['market', 'mill', 'inn', 'shrine', 'jetty', 'herb', 'workshop', 'orchard', 'ferry', 'tower', 'spring', 'camp']
TAG_ORDER = ['fix', 'craft', 'cook', 'gather', 'tend', 'trade', 'play', 'lore', 'rest']
TAG_BAR = {'fix': 'Repairs', 'craft': 'Repairs', 'cook': 'Larder', 'gather': 'Larder', 'tend': 'Larder',
           'trade': 'Cheer', 'play': 'Cheer', 'lore': 'Cheer', 'rest': 'Cheer'}
EXTRA_COOK = ['fry', 'broth', 'cordial', 'porridge', 'pickle']
GAME_KINDS = {'contest', 'pick', 'power', 'collect'}
SHOP_KINDS = {'buy', 'snack', 'swap', 'seedswap'}

# Step 3: type -> (signature, lean, {game kind: bar})
TYPE_RULES = {
    'market':   ('Larder',  'Larder',  {'pick': 'Larder', 'power': 'Repairs'}),
    'mill':     ('Larder',  'Repairs', {'power': 'Repairs'}),
    'inn':      ('Cheer',   'Larder',  {'power': 'Repairs', 'collect': 'Larder'}),
    'shrine':   ('Cheer',   'Repairs', {'pick': 'Larder'}),
    'jetty':    ('Larder',  'Repairs', {'power': 'Larder', 'pick': 'Larder'}),
    'herb':     ('Larder',  'Larder',  {'collect': 'Larder'}),
    'workshop': ('Repairs', 'Repairs', {'power': 'Repairs', 'pick': 'Repairs'}),
    'orchard':  ('Larder',  'Larder',  {'power': 'Larder'}),
    'ferry':    ('Repairs', 'Repairs', {'power': 'Repairs', 'pick': 'Larder'}),
    'tower':    ('Repairs', 'Larder',  {'power': 'Repairs', 'pick': 'Larder'}),
    'spring':   ('Cheer',   'Repairs', {'pick': 'Larder'}),
    'camp':     ('Cheer',   'Larder',  {'power': 'Repairs', 'pick': 'Larder'}),
}
BARS = ['Repairs', 'Larder', 'Cheer']


def read_tag_words():
    src = open(STOPS_PHP, encoding='utf-8').read()
    m = re.search(r'const STOP_TAG_WORDS = \[(.*?)\n\];', src, re.S)
    if not m:
        sys.exit('STOP_TAG_WORDS not found in stops.php')
    words = {}
    for tag, body in re.findall(r"'(\w+)'\s*=>\s*\[([^\]]*)\]", m.group(1)):
        words[tag] = re.findall(r"'([^']+)'", body)
    words['cook'] = words['cook'] + [w for w in EXTRA_COOK if w not in words['cook']]
    return words


def forms(w):
    """Whole-word forms a tag word may take (fix (a)): the word, or the word plus a plain ending."""
    f = {w, w + 's', w + 'es', w + 'ed', w + 'ing', w + 'er', w + 'ers', w + 'y', w + 'ies'}
    if w.endswith('e'):
        f |= {w + 'd', w[:-1] + 'ing'}
        if len(w) >= 4:
            f |= {w + 'r', w + 'rs'}
    if w.endswith('y'):
        f |= {w[:-1] + 'ies', w[:-1] + 'ied'}
    if re.search(r'[^aeiou][aeiou][bdgklmnprt]$', w):
        f |= {w + w[-1] + 'ing', w + w[-1] + 'ed', w + w[-1] + 'er'}
    return f


def build_matchers(words):
    return {tag: (set().union(*(forms(w) for w in ws)), ws) for tag, ws in words.items()}


def tok_hit(toks, forms_set, words):
    """A token is a form of the word, or a compound that starts with the word and goes on with 4+ letters (bakehouse)."""
    if toks & forms_set:
        return True
    return any(tk.startswith(w) and len(tk) - len(w) >= 4 for tk in toks for w in words)


def tags_in(text, matchers):
    toks = set(re.findall(r"[a-z]+", text.lower().replace('’', "'").replace("'", '')))
    return [t for t in TAG_ORDER if matchers.get(t) and tok_hit(toks, matchers[t][0], matchers[t][1])]


def ranked_tags(name, blurb, matchers):
    n = tags_in(name, matchers)
    b = [t for t in tags_in(blurb, matchers) if t not in n]
    return n, n + b


def load_food():
    food = {'garden-honey'}
    for line in open(os.path.join(DATA, 'recipes.txt'), encoding='utf-8'):
        if line.strip() and not line.startswith('#'):
            food.add(line.split('|')[0].strip())
    return food


def load_acts():
    acts = []
    for fn in ACT_FILES:
        for line in open(os.path.join(DATA, fn), encoding='utf-8'):
            if not line.strip() or line.startswith('#') or '|' not in line:
                continue
            c = line.rstrip('\n').split('|')
            types = [t.strip() for t in c[3].split(',') if t.strip()]
            acts.append({'slug': c[0], 'name': c[1], 'types': types, 'kind': c[6],
                         'energy': int(c[7] or 0), 'spec': c[8], 'blurb': c[11] if len(c) > 11 else '',
                         'win': c[9], 'file': fn})
    return acts


def load_overrides():
    ov = {}
    for line in open(os.path.join(DATA, 'stop_act_state.txt'), encoding='utf-8'):
        if not line.strip() or line.startswith('#'):
            continue
        c = line.rstrip('\n').split('|')
        if len(c) < 3 or c[2].strip() in ('', '-'):
            continue
        bars = []
        for part in c[2].split(','):
            m = re.match(r'\s*meter:(\w+)', part)
            if m:
                b = m.group(1).capitalize()
                if b in BARS and b not in bars:
                    bars.append(b)
        if bars:
            ov[c[0]] = bars
    return ov


def base_points(energy):
    return 6 if energy <= 0 else 9 if energy == 1 else 12 if energy == 2 else 15


def assign(act, typ, matchers, food, ov):
    """-> (first, second or None, why)"""
    if act['slug'] in ov:
        b = ov[act['slug']]
        return b[0], (b[1] if len(b) > 1 else None), 'override'
    name_tags, tags = ranked_tags(act['name'], act['blurb'], matchers)
    sig, lean, moves = TYPE_RULES[typ]
    k = act['kind']
    moved_from = None
    if k == 'craft':
        out = act['spec'].split('>')[-1] if '>' in act['spec'] else ''
        outs = {re.sub(r':\d+$', '', o.strip()) for o in out.split(',')}
        first, why = ('Larder', 'craft: cook tag/food') if ('cook' in tags or outs & food) else ('Repairs', 'craft')
    elif k == 'tend':
        if tags and tags[0] in ('fix', 'craft', 'cook', 'gather', 'tend'):
            first, why = TAG_BAR[tags[0]], 'tend: tag ' + tags[0]
        else:
            first, why = lean, 'tend: lean'
    elif k == 'rest':
        first, why = ('Larder', 'rest: cook in name') if 'cook' in name_tags else ('Cheer', 'rest')
    elif k in ('lore', 'gossip'):
        first, why = 'Cheer', k
    elif k in SHOP_KINDS:
        first, why = 'Larder', k
    elif k in GAME_KINDS:
        if k in moves:
            first, moved_from, why = moves[k], 'Cheer', 'type move'
        else:
            first, why = 'Cheer', k
    elif k == 'check':
        first, why = (TAG_BAR[tags[0]], 'check: tag ' + tags[0]) if tags else (lean, 'check: lean')
    elif k == 'thread':
        first, why = sig, 'thread: signature'
    else:
        first, why = lean, 'default: lean'
    # step 4
    second = None
    if k in ('lore', 'gossip', 'thread'):
        second = None
    elif k in SHOP_KINDS:
        second = 'Cheer'
    elif moved_from and moved_from != first:
        second = moved_from
    else:
        for t in tags:
            if t != 'rest' and TAG_BAR[t] != first:
                second = TAG_BAR[t]
                break
        if second is None and k in GAME_KINDS and lean != first:
            second = lean
    return first, second, why


# ------------------------------------------------------------------ noise check
# An independent "obvious nature" reading, used only to flag rows for a human look. Strong words in the NAME only.
NATURE = {
    'Larder': ['fish', 'angl', 'catch', 'egg', 'honey', 'hive', 'bee', 'sap', 'syrup', 'harvest', 'crop', 'seed', 'sow', 'plant',
               'graft', 'prune', 'orchard', 'apple', 'berr', 'mushroom', 'forage', 'milk', 'goat', 'hen', 'chicken', 'sheep',
               'lamb', 'cow', 'cheese', 'bread', 'bake', 'oven', 'stew', 'soup', 'jam', 'pickle', 'fritter', 'fry', 'brew',
               'kitchen', 'pantry', 'cellar', 'grain', 'flour', 'thresh', 'rice', 'maize', 'corn', 'herb', 'tea', 'compost',
               'garden', 'vine', 'hop', 'pick', 'gather', 'dig', 'clam', 'mussel', 'oyster', 'crab', 'shrimp', 'net', 'trap',
               'smoke', 'dry', 'salt', 'meal', 'feast', 'supper', 'breakfast', 'lunch', 'picnic', 'cook', 'roast', 'boil',
               'churn', 'press', 'cider', 'juice', 'cordial', 'broth', 'porridge', 'dumpling', 'noodle', 'tortilla', 'feed'],
    'Repairs': ['mend', 'fix', 'repair', 'patch', 'build', 'rebuild', 'shore', 'prop', 'carve', 'whittle', 'forge', 'anvil',
                'hammer', 'nail', 'plank', 'board', 'beam', 'roof', 'thatch', 'fence', 'wall', 'bridge', 'dam', 'dyke', 'dike',
                'wheel', 'cart', 'rope', 'knot', 'splice', 'tar', 'caulk', 'hull', 'boat', 'raft', 'lock', 'gate', 'sluice',
                'stone', 'mortar', 'brick', 'kiln', 'pot', 'loom', 'weave', 'spin', 'sew', 'stitch', 'sharpen', 'oil', 'grease',
                'chop', 'split', 'saw', 'timber', 'log', 'haul', 'carry', 'stack', 'dig', 'ditch', 'drain', 'clear', 'sweep',
                'scrub', 'clean', 'tidy', 'paint', 'whitewash', 'sail', 'rig', 'beacon', 'lamp', 'lantern', 'chimney', 'tool'],
    'Cheer': ['tale', 'story', 'stories', 'song', 'sing', 'dance', 'music', 'fiddle', 'drum', 'game', 'race', 'contest',
              'duel', 'toss', 'cards', 'riddle', 'puzzle', 'guess', 'kite', 'star', 'watch', 'sky', 'aurora', 'legend',
              'gossip', 'chat', 'festival', 'parade', 'bow', 'prayer', 'offering', 'bell', 'chant', 'poem', 'joke', 'laugh',
              'trivia', 'quiz', 'view', 'sunset', 'sunrise', 'dawn', 'dusk', 'bird', 'sit', 'rest', 'nap', 'soak', 'bath',
              'skim', 'swim', 'sled', 'toboggan', 'skate', 'spot', 'count'],
}


def nature(name, matchers_nature):
    toks = set(re.findall(r"[a-z]+", name.lower().replace('’', '').replace("'", '')))
    hits = {b: sorted(toks & m) for b, m in matchers_nature.items()}
    return {b: h for b, h in hits.items() if h}


def main():
    write = '--check' not in sys.argv
    words = read_tag_words()
    matchers = build_matchers(words)
    mnature = {b: set().union(*(forms(w) for w in ws)) for b, ws in NATURE.items()}
    food = load_food()
    ov = load_overrides()
    acts = load_acts()

    rows = []                     # (slug, type, first, second, B)
    share = {t: Counter() for t in TYPES}
    second_n = Counter()
    per_type_n = Counter()
    noise = []
    for a in acts:
        anyish = a['types'] == ['any'] or a['kind'] == 'thread' or a['types'] == ['thread']
        types = TYPES if anyish else [t for t in a['types'] if t in TYPES]
        res = {}
        for t in types:
            res[t] = assign(a, t, matchers, food, ov)
            share[t][res[t][0]] += 1
            per_type_n[t] += 1
            if res[t][1]:
                second_n[t] += 1
        B = base_points(a['energy'])
        if anyish:
            distinct = {(f, s) for f, s, _ in res.values()}
            if len(distinct) == 1:
                f, s, _ = next(iter(res.values()))
                rows.append((a['slug'], '*', f, s, B))
            else:
                for t in TYPES:
                    rows.append((a['slug'], t, res[t][0], res[t][1], B))
        else:
            for t in types:
                rows.append((a['slug'], t, res[t][0], res[t][1], B))
        # noise: the first bar came from a word tag, and the name's nature reads strongly as one other bar only
        tag_driven = [(t, r) for t, r in res.items() if 'tag' in r[2] or r[2].startswith('craft')]
        if tag_driven and a['slug'] not in ov:
            nat = nature(a['name'], mnature)
            if len(nat) == 1:
                nb = next(iter(nat))
                bad = sorted({t for t, r in tag_driven if r[0] != nb})
                if bad and len(bad) == len(tag_driven):
                    f = res[bad[0]][0]
                    noise.append((a['slug'], a['name'], a['kind'], f, nb, ','.join(nat[nb]), res[bad[0]][2]))

    # ------------------------------------------------------------ report
    lines = []
    lines.append('Per-type share of first bars (acts that can appear at the type; "any" acts count at every type)')
    lines.append('type      acts   R%  L%  C%  2nd%')
    for t in TYPES:
        n = per_type_n[t]
        r, l, c = (round(100 * share[t][b] / n) for b in BARS)
        lines.append(f'{t:<9} {n:>4}  {r:>3} {l:>3} {c:>3}  {round(100 * second_n[t] / n):>3}')
    tot = Counter()
    for t in TYPES:
        tot.update(share[t])
    N = sum(per_type_n.values())
    lines.append(f'{"all":<9} {N:>4}  ' + ' '.join(f'{round(100 * tot[b] / N):>3}' for b in BARS) + f'  {round(100 * sum(second_n.values()) / N):>3}')
    report = '\n'.join(lines)
    print(report)
    print(f'\n{len(acts)} acts, {len(rows)} rows, {len(ov)} override rows, {len(noise)} rows flagged as word-tag noise')
    for n in noise:
        print('  NOISE', ' | '.join(n))

    if write:
        with open(OUT, 'w', encoding='utf-8') as fh:
            fh.write('# Generated by claude/tools_gen_stop_act_bars.py (proposal data, not loaded by the game).\n')
            fh.write('# Rules: claude/proposal-stop-perks.md section 2, steps 0-4. Sources: game/includes/data/stop_acts*.txt + stop_act_state.txt.\n')
            fh.write('# slug | stop type | first bar | second bar or - | base points\n')
            fh.write('#   stop type "*" = an "any" act whose result is the same at all 12 types; otherwise one row per type.\n')
            fh.write('#   base points = B by energy cost (0=6, 1=9, 2=12, 3+=15), before D/W/F/V. The second bar gets floor(pts/2), least 1.\n')
            fh.write(f'# {len(acts)} acts, {len(rows)} rows.\n#\n')
            for l in lines:
                fh.write('# ' + l + '\n')
            fh.write('#\n')
            for s, t, f, sec, B in rows:
                fh.write(f'{s} | {t} | {f} | {sec or "-"} | {B}\n')
    return noise


if __name__ == '__main__':
    main()
