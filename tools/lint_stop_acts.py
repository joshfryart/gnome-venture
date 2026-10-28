#!/usr/bin/env python3
"""Lint a draft of rest-stop activities (same columns as stop_acts.txt / stop_acts_regional.txt).
Usage: tools/lint_stop_acts.py DRAFT.txt ITEM_SLUGS.txt [--region]
  ITEM_SLUGS.txt = "slug|category|name" lines (dump of the items table).  --region = the 15th column (region codes) is required.
Checks: column count, unique slug (also against the shipped files), kind, stop types, cond syntax, spec per kind, reward tokens, real item slugs, no '|' in text,
sensible lengths, curly apostrophes. Prints problems; exit 1 if any."""
import re, sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, '..', 'game', 'includes', 'data')
TYPES = {'market','mill','inn','shrine','jetty','herb','workshop','orchard','ferry','tower','spring','camp'}
KINDS = {'check','pick','power','lore','rest','buy','swap','craft','collect','tend','contest'}
STATS = {'grit','nimble','hardiness','lore','sense','charm','luck'}
REGIONS = {'NA','CA','CB','SA','NWE','SE','EE','MENA','WCA','ESA','CSA','EA','SEA','OC'}
RW = {'c','xp','en','item','crop','find','fish','seed','buff','fp','reveal'}
COND = re.compile(r'^(-|(dp|se|we)=[a-z,]+(/(dp|se|we)=[a-z,]+)*)$')

def load(path):
    out = []
    for l in open(path, encoding='utf-8'):
        l = l.rstrip('\n')
        if l.strip() and not l.startswith('#'): out.append(l.split('|'))
    return out

def main():
    draft, slugs = sys.argv[1], sys.argv[2]
    region = '--region' in sys.argv
    items = {l.split('|')[0] for l in open(slugs, encoding='utf-8') if l.strip()}
    shipped = set()
    for f in ('stop_acts.txt', 'stop_acts_regional.txt'):
        p = os.path.join(DATA, f)
        if os.path.exists(p): shipped |= {r[0] for r in load(p)}
    bad = []
    seen = set()
    rows = load(draft)
    for r in rows:
        s = r[0] if r else '?'
        def err(m): bad.append(f'{s}: {m}')
        if len(r) < (15 if region else 14): err(f'{len(r)} columns'); continue
        slug, name, icon, types, when, tier, kind, energy, spec, win, lose, blurb, lw, ll = r[:14]
        if not re.fullmatch(r'[a-z0-9_]{3,40}', slug): err('slug format')
        if slug in seen: err('duplicate in draft')
        seen.add(slug)
        if slug in shipped: err('slug already shipped')
        if not name or len(name) > 40: err('name empty or over 40')
        if not icon: err('no icon')
        ts = [t.strip() for t in types.split(',')]
        if not ts or any(t not in TYPES and t != 'any' for t in ts): err(f'bad types {types}')
        if not COND.match(when): err(f'bad when {when}')
        if tier != '0': err('tier must be 0')
        if kind not in KINDS: err(f'kind {kind}')
        if not energy.isdigit() or int(energy) > 2: err('energy 0-2')
        if region:
            rg = [x.strip() for x in r[14].split(',')]
            if not rg or any(x not in REGIONS for x in rg): err(f'bad region {r[14]}')
        for what, rw in (('win', win), ('lose', lose)):
            for tok in [t for t in rw.split(',') if t]:
                k, _, v = tok.split('@')[0].partition('=')
                if k not in RW: err(f'{what} reward {k}'); continue
                if k == 'item':
                    sl = v.split(':')[0]
                    if sl not in items: err(f'{what} item {sl} does not exist')
        if kind == 'check':
            opts = spec.split(';')
            if not 1 <= len(opts) <= 3: err('check needs 1-3 options')
            for o in opts:
                p = o.split(':', 2)
                if len(p) != 3 or p[0] not in STATS or not p[1].isdigit() or not 0 <= int(p[1]) <= 15: err(f'check option {o}')
        elif kind == 'pick':
            m = re.search(r'n=(\d)', spec)
            if not m or not 2 <= int(m.group(1)) <= 6: err('pick n=2..6')
        elif kind == 'power':
            m = re.search(r'n=(\d)', spec)
            if not m or not 3 <= int(m.group(1)) <= 7: err('power n=3..7')
        elif kind == 'lore':
            if len([t for t in spec.split(';;') if t.strip()]) < 3: err('lore needs 3+ tales separated by ;;')
        elif kind == 'craft':
            if '>' not in spec: err('craft spec a:2>b:1')
            else:
                a, b = spec.split('>', 1)
                for part in a.split(',') + [b]:
                    sl = part.split(':')[0]
                    if sl not in items: err(f'craft item {sl} does not exist')
        elif kind == 'collect':
            p = dict(x.split('=', 1) for x in spec.split(';') if '=' in x)
            e = [x for x in p.get('items', '').split('/') if x]
            if len(e) < 6 or len(e) > 12: err('collect needs 6-12 items')
            if not p.get('set') or not p.get('done'): err('collect needs set= and done=')
        elif kind == 'tend':
            p = dict(x.split('=', 1) for x in spec.split(';') if '=' in x)
            if not p.get('steps', '').isdigit() or not 2 <= int(p['steps']) <= 6 or not p.get('label'): err('tend steps=2..6;label=')
        elif kind == 'contest':
            p = dict(x.split('=', 1) for x in spec.split(';') if '=' in x)
            if len([x for x in p.get('moves', '').split('/') if x]) != 3: err('contest moves=A/B/C')
        elif kind == 'rest' and 'cost=' not in spec: err('rest needs cost=')
        if len(blurb) < 25 or len(blurb) > 260: err('blurb 25-260 chars')
        for t in (name, blurb, lw, ll, spec):
            if "'" in t: err("straight apostrophe, use ’")
        if kind in ('check', 'pick', 'power', 'contest', 'collect') and (not lw or not ll): err('needs win and lose lines')
    print(f'{len(rows)} rows, {len(bad)} problems')
    for b in bad: print('  ' + b)
    sys.exit(1 if bad else 0)
main()
