#!/usr/bin/env python3
"""Lint the quest content of Wren's Journey v2 (the data behind the setting journey_v2_open).

    python3 claude/tools_lint_quest_data.py        # prints the counts and every error; exit 1 on any error

Reads only; writes nothing. Files checked (game/includes/data/):
  journey_chapters.txt   28 main chapters (C rows) and their steps (T rows)
  journey_errands.txt    63 errands that are side quests, 14 happening acts, 2 helper errands (Q rows) and their steps (S rows)
  stop_threads_v2.txt    17 area threads + 20 cast threads (63 + 17 = the 80 side quests of the quests doc)
  journey_extras.txt     13 secret places, 16 stop themes, 13 recipes, 4 teas, 11 stall lines, pages, carried things
  stop_state.txt         dark and lit text for each of the 12 stop types
  stop_band_lines.txt    ambience, chat and plaque lines for the 5 bands

Checks: every row parses (field counts, no stray pipe); slugs are unique and fit their columns; every area, zone, place, crop, flower,
item, creature, lair, stop type, happening, chapter and errand named anywhere exists in the game's data files; every `defeat` step has a
peaceful alt; every unlock, page and carried thing named has its row and every such row is used; the counts above; chapter XP per band =
40% of the band's real XP (xp_for_level, the game's curve with its default settings) and the Petals of quests doc 1.4.
Items the game makes in code (not in a data file) are in CODE_ITEMS; tests/quest_data.php checks every item against a real install.
"""
import os
import re
import sys
from collections import Counter

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'game', 'includes')
DATA = os.path.join(ROOT, 'data')
ERRORS = []

# Items made in PHP (catalog.php, crafting.php, gathering.php) or dropped by creatures, not listed in a data file the lint reads.
CODE_ITEMS = {'plain-compost', 'rich-loam', 'worm-castings', 'straw-mulch', 'rope', 'timber-plank', 'building-stone', 'beeswax', 'seed-pearl', 'wild-honeycomb'}
CAST = {'sorrel-inkpot', 'pell-quickthistle', 'puff-morelby', 'hobb-stiles', 'garrow-stonecount', 'dab-tarrow', 'bracken-tuppence'}
BANDS = {'NA': 1, 'CA': 2, 'NWE': 2, 'CB': 3, 'SA': 3, 'SE': 3, 'EE': 3, 'MENA': 4, 'CSA': 4, 'WCA': 4, 'ESA': 4, 'EA': 5, 'SEA': 5, 'OC': 5}
BAND_LEVELS = {1: (1, 15), 2: (15, 25), 3: (25, 35), 4: (35, 45), 5: (45, 55)}
BAND_PETALS = {1: (150, 600), 2: (600, 1300), 3: (2600, 2600), 4: (5000, 5000), 5: (7500, 10000)}
STEP_KINDS = {'visit', 'grow', 'friend', 'find', 'stage', 'adopt', 'raise', 'regular', 'plant', 'deliver', 'escort', 'defeat', 'help', 'puzzle', 'seal'}
ERRAND_STEP_KINDS = {'find', 'escort', 'deliver', 'defeat', 'plant', 'visit', 'talk', 'act'}
ERRAND_KINDS = {'lost', 'creature', 'deliver', 'garden', 'helper', 'happening'}
SIDE_KINDS = {'lost', 'creature', 'deliver', 'garden'}
BENEFITS = {'-', 'native_plus:10', 'sell_bonus:10', 'free_travel', 'weekly_crate'}
ERRAND_WHERE = {'giver', 'stop', 'lit', 'stall', 'hall', 'bed', 'off', 'hearth'}
CHAPTER_WHERE = {'stop', 'hearth', 'off'}
SIDE_PER_AREA = {'NA': 11, 'CA': 7, 'NWE': 7}   # every other area: 5
BANNED = ['—', 'destiny', 'chosen one', 'prophecy', 'ancient evil', 'curse', 'doom', 'hero', 'saviour', 'realm', 'legend', 'epic',
          'quest', 'awaken', 'tapestry', 'little did', 'hurry', 'too late', '!!']


def err(where, msg):
    ERRORS.append(f'{where}: {msg}')


def rows(name):
    """[(line number, [fields])] of a pipe file, comments and blank lines left out."""
    out = []
    with open(os.path.join(DATA, name), encoding='utf-8') as f:
        for n, line in enumerate(f, 1):
            line = line.strip()
            if line and not line.startswith('#'):
                out.append((n, [p.strip() for p in line.split('|')]))
    return out


def slugify(s):
    return re.sub(r'[^a-z0-9]+', '-', s.lower().strip()).strip('-')


def xp_for_level(lv, steep_from=10, steep_pct=15):
    """gnome.php xp_for_level() with the default settings xp_steep_from 10 and xp_steep_percent 15."""
    return round(50 * lv * (lv - 1) * (1 + max(0, lv - steep_from) * steep_pct / 100))


# ---------------------------------------------------------------- the game's own data

class World:
    def __init__(self):
        self.regions = {r[0] for _, r in rows('regions.txt')}
        self.zones = {(r[0], int(r[1])) for _, r in rows('zones.txt')}
        self.places = {}     # region => {name: type}
        for _, r in rows('landmarks.txt'):
            self.places.setdefault(r[0], {})[r[3]] = r[2]
        for _, r in rows('world_v2_places.txt'):
            if r[0] == 'P':
                self.places.setdefault(r[1], {})[r[4]] = r[3]
        self.crops = {r[0] for _, r in rows('crops.txt')}
        self.flowers = {r[0] for _, r in rows('flowers.txt')}
        self.region_crops = {}
        for _, r in rows('region_crops.txt'):
            self.region_crops.setdefault(r[0], {})[r[1]] = set(r[2].split(','))
        self.creatures = {r[0] for f in ('creatures.txt', 'creatures_v2.txt') for _, r in rows(f)}
        self.stop_types = {r[0] for _, r in rows('stop_tier_themes.txt')}
        self.happenings = {r[0] for _, r in rows('stop_happenings.txt')}
        self.recipes = {r[0] for _, r in rows('recipes.txt')}
        self.teas = {r[0]: frozenset(r[2].split(',')) for _, r in rows('teas.txt')}
        self.tea_parts = {r[0] for _, r in rows('tea_ingredients.txt')}
        self.old_threads = {r[0] for _, r in rows('stop_threads.txt')}
        self.items = set(CODE_ITEMS) | self.crops | {c + '-seed' for c in self.crops} | {'cut-' + f for f in self.flowers}
        self.items |= {r[0] for _, r in rows('gatherables.txt')}
        with open(os.path.join(ROOT, 'journey.php'), encoding='utf-8') as f:
            php = f.read()
        self.npcs = set(re.findall(r"'([a-z]+-[a-z]+)',\s*\n?\s*\"", php)) | {'clover-puddlejump', 'ottilie-kettlewick'}
        self.old_chapters = set(re.findall(r"\['([a-z]+-[a-z-]+)', '[A-Z]{2,4}', \d+,", php))
        self.lairs = {reg: {slugify(n) for n, t in pl.items() if t == 'lair'} for reg, pl in self.places.items()}

    def place_slugs(self, region):
        return {slugify(n) for n in self.places.get(region, {})}


# ---------------------------------------------------------------- shared grammar checks

def check_text(where, text):
    low = text.lower()
    for word in BANNED:
        if re.search(r'(?<![a-z])' + re.escape(word) + (r'(?![a-z])' if word.isalpha() else ''), low):
            err(where, f'banned word or mark "{word}" (flavor doc 1)')


def check_items(w, where, part, carried=()):
    """item:slug:N (slug may be a/b alternatives)."""
    p = part.split(':')
    if len(p) < 3 or not p[2].isdigit():
        return err(where, f'bad item part "{part}"')
    for slug in p[1].split('/'):
        if slug not in w.items and slug not in carried:
            err(where, f'unknown item "{slug}"')


def check_needs(w, where, spec, carried=(), where_ok=None, region=None):
    """A stage, deliver or reward-like spec: item:slug:N, coins:N, meal:N, fine:N, from:WHERE, to:WHERE."""
    for part in filter(None, spec.split(',')):
        key = part.split(':')[0]
        if key == 'item':
            check_items(w, where, part, carried)
        elif key in ('coins', 'meal', 'fine'):
            if not re.fullmatch(key + r':\d+', part):
                err(where, f'bad part "{part}"')
        elif key in ('from', 'to') and where_ok is not None:
            check_where(w, where, part.split(':', 1)[1], where_ok, region)
        else:
            err(where, f'unknown part "{part}"')


def check_where(w, where, place, tokens, region):
    name = re.sub(r'\*\d+$', '', place)
    if name not in tokens and name not in w.places.get(region, {}):
        err(where, f'unknown place "{name}" in {region}')


def check_plant(w, where, spec):
    p = spec.split(':')
    if p[0] == 'crop' and len(p) == 3 and p[2].isdigit():
        for c in p[1].split('/'):
            if c not in w.crops:
                err(where, f'unknown crop "{c}"')
    elif p[0] == 'flower' and len(p) in (2, 3):
        if p[1] not in w.flowers:
            err(where, f'unknown flower "{p[1]}"')
    elif p[0] == 'bed' and len(p) == 2 and p[1] in ('1', '2', '3'):
        pass
    else:
        err(where, f'bad plant spec "{spec}"')


def check_defeat(w, where, spec, region):
    sp = dict(x.split(':', 1) for x in spec.split(',') if ':' in x)
    if 'creature' in sp:
        if sp['creature'] not in w.creatures:
            err(where, f'unknown creature "{sp["creature"]}"')
    elif 'lair' in sp:
        if not any(sp['lair'] in s for s in w.lairs.get(region, ())):
            err(where, f'no lair like "{sp["lair"]}" in {region}')
    else:
        err(where, f'bad defeat spec "{spec}"')


def check_reward(w, where, spec, extras=None, region=None):
    """c= xp= item= fp= (reward), and seed= page= title= mark= unlock= (extra)."""
    used = []
    if spec in ('', '-'):
        return used
    for part in spec.split(','):
        if '=' not in part:
            err(where, f'bad reward part "{part}"')
            continue
        k, v = part.split('=', 1)
        if k in ('c', 'xp'):
            if not re.fullmatch(r'\d+(:\d+)?', v):
                err(where, f'bad {k}= "{v}"')
        elif k == 'fp':
            if not v.isdigit():
                err(where, f'bad fp= "{v}"')
        elif k == 'item':
            if not re.fullmatch(r'[a-z0-9-]+:\d+(@\d+)?', v) or v.split(':')[0] not in w.items:
                err(where, f'unknown reward item "{v}"')
        elif extras is None:
            err(where, f'"{k}=" belongs in the extra field')
        elif k == 'seed':
            crop = v.split(':')[0]
            if crop not in w.region_crops.get(region, {}).get('treasure', set()):
                err(where, f'seed "{crop}" is no treasure crop of {region}')
            used.append(('seed', crop))
        elif k == 'page':
            if v not in extras['PAGE']:
                err(where, f'page "{v}" has no PAGE row')
            used.append(('PAGE', v))
        elif k == 'title':
            used.append(('title', v))
        elif k == 'mark':
            pass
        elif k == 'unlock':
            typ, _, slug = v.partition(':')
            table = {'place': 'PLACE', 'theme': 'THEME', 'recipe': 'RECIPE', 'tea': 'TEA', 'shop': 'SHOP'}.get(typ)
            if not table:
                err(where, f'unknown unlock "{v}" (Puzzle Pals are never a quest reward)')
            elif slug not in extras[table] and not (typ == 'recipe' and slug in w.recipes):
                err(where, f'unlock {v} has no {table} row')
            used.append((table, slug))
        else:
            err(where, f'unknown extra "{part}"')
    return used


def check_trigger(w, where, trig, region, chapters, extras):
    if trig in ('', '-'):
        return
    for part in trig.split(','):
        m = re.fullmatch(r'(tier>=[1-4]|regular)@(area|zone:(\d+)|type:([a-z/]+))(\*\d+)?', part)
        if m:
            if m.group(3) and (region, int(m.group(3))) not in w.zones:
                err(where, f'trigger zone {m.group(3)} is not in {region}')
            for t in (m.group(4) or '').split('/'):
                if t and t not in w.stop_types:
                    err(where, f'trigger stop type "{t}"')
        elif re.fullmatch(r'(lit>=\d+|bed>=[1-3])', part):
            pass
        elif part.startswith('chapter='):
            if part[8:] not in chapters:
                err(where, f'trigger chapter "{part[8:]}"')
        elif part.startswith('stage>='):
            if not re.fullmatch(r'stage>=[1-3]@[a-z0-9-]+', part) or part.split('@')[1] not in chapters:
                err(where, f'bad trigger "{part}"')
        elif part.startswith('found='):
            if part[6:] not in w.place_slugs(region) and part[6:] not in extras['PLACE']:
                err(where, f'trigger place "{part[6:]}" is not in {region}')
        elif part.startswith('seal='):
            if part[5:] not in w.regions:
                err(where, f'trigger seal "{part[5:]}"')
        elif part.startswith('hp='):
            for h in part[3:].split('/'):
                if h not in w.happenings:
                    err(where, f'unknown happening "{h}"')
        else:
            err(where, f'bad trigger "{part}"')


# ---------------------------------------------------------------- journey_chapters.txt

def parse_alt(alt):
    """journey_v2_alt(): kind:spec:qty, the qty the last part when it is a number."""
    p = alt.split(':')
    kind = p.pop(0)
    if len(p) > 1 and p[-1].isdigit():
        p.pop()
    return kind, ':'.join(p)


def check_step(w, where, kind, spec, region, zone, errands, is_alt=False):
    sp = dict((x.split(':', 1) + [''])[:2] for x in spec.split(',')) if spec not in ('', '-') else {}
    if 'zone' in sp and (region, int(sp['zone'])) not in w.zones:
        err(where, f'zone {sp["zone"]} is not in {region}')
    if kind == 'find' and spec != '-':
        for name in spec.split('/'):
            check_where(w, where, name, set(), region)
    elif kind == 'stage':
        check_needs(w, where, spec)
    elif kind == 'deliver':
        check_needs(w, where, spec, where_ok=CHAPTER_WHERE, region=region)
        if 'to' not in sp:
            err(where, 'deliver without to:')
    elif kind == 'escort':
        if not {'who', 'from', 'to'} <= set(sp):
            err(where, 'escort needs who, from and to')
        for k in ('from', 'to'):
            if k in sp:
                check_where(w, where, sp[k], CHAPTER_WHERE, region)
    elif kind == 'defeat':
        check_defeat(w, where, spec, region)
    elif kind == 'plant':
        check_plant(w, where, spec)
    elif kind == 'help' and 'errand' in sp:
        if errands.get(sp['errand'], {}).get('kind') != 'helper':
            err(where, f'errand "{sp["errand"]}" is no helper errand of journey_errands.txt')
    elif kind == 'seal':
        if not re.fullmatch(r'leaf|standing:\d+|seals:(\d+|[A-Z/]+)', spec):
            err(where, f'bad seal spec "{spec}"')
        elif spec.startswith('seals:') and not spec[6:].isdigit() and not set(spec[6:].split('/')) <= w.regions:
            err(where, f'unknown area in "{spec}"')
    elif kind == 'raise':
        if not ({'tier', 'lit'} & set(sp)):
            err(where, f'raise needs tier: or lit: ("{spec}")')
    elif kind == 'act' and is_alt:
        pass
    elif kind not in STEP_KINDS:
        err(where, f'unknown step kind "{kind}"')


def lint_chapters(w, errands):
    C, T = {}, []
    for n, r in rows('journey_chapters.txt'):
        where = f'journey_chapters.txt:{n}'
        if r[0] == 'C':
            if len(r) != 21:
                err(where, f'C row has {len(r) - 1} fields, wants 20')
                continue
            c = dict(zip(['slug', 'area', 'zone', 'sort', 'title', 'giver', 'lv', 'needs', 'coins', 'xp', 'item', 'qty', 'rtitle', 'benefit', 'btext',
                          'project', 'icon', 'intro', 'letter', 'replaces'], r[1:]))
            if c['slug'] in C:
                err(where, f'chapter slug "{c["slug"]}" twice')
            C[c['slug']] = c
            if not re.fullmatch(r'[a-z0-9-]{1,80}', c['slug']):
                err(where, 'bad slug')
            if c['area'] not in w.regions:
                err(where, f'unknown area "{c["area"]}"')
            elif c['zone'] != '0' and (c['area'], int(c['zone'])) not in w.zones:
                err(where, f'zone {c["zone"]} is not in {c["area"]}')
            if c['giver'] != '-' and c['giver'] not in w.npcs:
                err(where, f'unknown giver "{c["giver"]}"')
            if not re.fullmatch(r'\d+(-\d+)?', c['lv']):
                err(where, f'bad levels "{c["lv"]}"')
            if c['item'] != '-' and c['item'] not in w.items:
                err(where, f'unknown reward item "{c["item"]}"')
            if c['benefit'] not in BENEFITS:
                err(where, f'unknown benefit "{c["benefit"]}"')
            if c['replaces'] != '-' and c['replaces'] not in w.old_chapters:
                err(where, f'replaces "{c["replaces"]}", which is no old chapter')
            for k, size in (('title', 120), ('project', 80), ('btext', 255), ('rtitle', 60), ('needs', 255), ('benefit', 40)):
                if len(c[k]) > size:
                    err(where, f'{k} is longer than {size}')
            if not c['intro'] or not c['letter'] or c['letter'] == '-':
                err(where, 'a chapter needs an intro and a letter')
            check_text(where, c['title'] + ' ' + c['intro'] + ' ' + c['letter'])
        elif r[0] == 'T':
            if len(r) != 9:
                err(where, f'T row has {len(r) - 1} fields, wants 8')
                continue
            T.append((where, dict(zip(['chapter', 'kind', 'spec', 'qty', 'lv', 'opt', 'alt', 'label'], r[1:]))))
        elif r[0] != 'P':
            err(where, f'unknown row "{r[0]}"')
    for slug, c in C.items():
        for need in c['needs'].split('/') if c['needs'] != '-' else []:
            if need not in C:
                err(f'chapter {slug}', f'needs "{need}", which is no chapter')
    replaced = Counter(c['replaces'] for c in C.values() if c['replaces'] != '-')
    for old, n in replaced.items():
        if n > 1:
            err('journey_chapters.txt', f'old chapter "{old}" is replaced {n} times')
    if set(replaced) != w.old_chapters:
        err('journey_chapters.txt', f'old chapters not replaced: {sorted(w.old_chapters - set(replaced))}')
    steps = {}
    for where, t in T:
        c = C.get(t['chapter'])
        if not c:
            err(where, f'step of unknown chapter "{t["chapter"]}"')
            continue
        steps.setdefault(t['chapter'], []).append(t)
        if t['kind'] not in STEP_KINDS:
            err(where, f'unknown step kind "{t["kind"]}"')
        if not t['qty'].isdigit() or t['opt'] not in ('0', '1'):
            err(where, 'bad qty or opt')
        if not re.fullmatch(r'\d+(-\d+)?|any', t['lv']):
            err(where, f'bad levels "{t["lv"]}"')
        for k in ('spec', 'alt', 'label'):
            if len(t[k]) > 255:
                err(where, f'{k} is longer than 255')
        check_step(w, where, t['kind'], t['spec'], c['area'], c['zone'], errands)
        if t['alt'] != '-':
            kind, spec = parse_alt(t['alt'])
            check_step(w, where + ' alt', kind, spec, c['area'], c['zone'], errands, True)
        elif t['kind'] == 'defeat':
            err(where, 'a defeat step needs a peaceful alt (quests doc 1.2)')
        elif t['kind'] == 'help' and 'errand:' in t['spec']:
            err(where, 'a help errand step needs an alt until errands are built')
        check_text(where, t['label'])
    for slug, c in C.items():
        need = [t for t in steps.get(slug, []) if t['opt'] == '0']
        if not need or need[-1]['kind'] != 'seal':
            err(f'chapter {slug}', 'the last step that counts must be a seal step')
        if not 5 <= len(steps.get(slug, [])) <= 20:
            err(f'chapter {slug}', f'{len(steps.get(slug, []))} steps')
    # XP and Petals by band
    xp, lines = Counter(), []
    for slug, c in C.items():
        band = 5 if slug == 'the-last-page' else 2 if slug == 'the-crossing' else BANDS.get(c['area'], 0)
        xp[band] += int(c['xp'])
        lo, hi = BAND_PETALS[band]
        if not lo <= int(c['coins']) <= hi:
            err(f'chapter {slug}', f'{c["coins"]} Petals, band {band} pays {lo} to {hi}')
    for band, (lo, hi) in BAND_LEVELS.items():
        want = round(0.4 * (xp_for_level(hi) - xp_for_level(lo)))
        lines.append(f'band {band} {xp[band]:,}')
        if xp[band] != want:
            err('journey_chapters.txt', f'band {band} chapters pay {xp[band]:,} XP, 40% of the band is {want:,}')
    per_area = Counter('joint' if s in ('the-crossing', 'the-last-page') else c['area'] for s, c in C.items())
    want = {'NA': 7, 'CA': 4, 'NWE': 4, 'joint': 2}
    for area in list(w.regions) + ['joint']:
        if per_area[area] != want.get(area, 1):
            err('journey_chapters.txt', f'{area} has {per_area[area]} chapters, wants {want.get(area, 1)}')
    if len(C) != 28:
        err('journey_chapters.txt', f'{len(C)} main chapters, wants 28')
    print(f'main chapters {len(C)}, steps {len(T)}; XP {sum(xp.values()):,} ({", ".join(lines)})')
    return C


# ---------------------------------------------------------------- journey_extras.txt

def lint_extras(w):
    cols = {'PLACE': 7, 'THEME': 8, 'RECIPE': (10, 11), 'TEA': 5, 'SHOP': 5, 'PAGE': 4, 'ITEM': 4}
    X = {k: {} for k in cols}
    for n, r in rows('journey_extras.txt'):
        where = f'journey_extras.txt:{n}'
        want = cols.get(r[0])
        if want is None or len(r) not in (want if isinstance(want, tuple) else (want,)):
            err(where, f'bad {r[0]} row ({len(r) - 1} fields)')
            continue
        if r[1] in X[r[0]] or not re.fullmatch(r'[a-z0-9-]+', r[1]):
            err(where, f'bad or repeated slug "{r[1]}"')
        X[r[0]][r[1]] = r
        check_text(where, ' '.join(r[2:]))
        if r[0] == 'PLACE':
            if (r[2], int(r[3])) not in w.zones or r[4] not in ('haven', 'wonder'):
                err(where, 'bad region, zone or type')
            if r[5] in w.places.get(r[2], {}) or slugify(r[5]) not in (r[1], 'the-' + r[1]):
                err(where, 'the name is taken, or the slug is not the name')
        elif r[0] == 'THEME':
            if not set(r[2].split(',')) <= w.stop_types or r[3] not in ('1', '2', '3', '4'):
                err(where, 'bad stop type or tier')
        elif r[0] == 'RECIPE':
            if r[1] in w.recipes:
                err(where, 'recipes.txt has this slug already')
            for part in r[3].split(','):
                if part.split(':')[0] not in w.crops:
                    err(where, f'ingredient "{part}" is no crop')
            if r[8] not in ('snack', 'meal', 'feast', 'preserve') or (r[8] == 'preserve') != (len(r) == 11):
                err(where, 'bad tier (a preserve has an items-per-batch column)')
        elif r[0] == 'TEA':
            parts = set(r[3].split(','))
            if r[1] in w.teas or not parts <= w.tea_parts or frozenset(parts) in w.teas.values():
                err(where, 'tea slug or blend is taken, or a component is no tea ingredient')
        elif r[0] == 'SHOP' and r[2] not in w.regions:
            err(where, f'unknown area "{r[2]}"')
    for typ, want in (('PLACE', 13), ('THEME', 16), ('RECIPE', 13), ('TEA', 4), ('SHOP', 11)):
        if len(X[typ]) != want:
            err('journey_extras.txt', f'{len(X[typ])} {typ} rows, wants {want}')
    print('extras: ' + ', '.join(f'{len(v)} {k.lower()}' for k, v in X.items()))
    return X


# ---------------------------------------------------------------- journey_errands.txt and stop_threads_v2.txt

def lint_errands(w):
    Q, S = {}, []
    for n, r in rows('journey_errands.txt'):
        where = f'journey_errands.txt:{n}'
        if r[0] == 'Q':
            if len(r) != 14:
                err(where, f'Q row has {len(r) - 1} fields, wants 13')
                continue
            q = dict(zip(['id', 'area', 'zone', 'kind', 'giver', 'trigger', 'repeat', 'lv', 'reward', 'extra', 'title', 'intro', 'outro'], r[1:]))
            if q['id'] in Q or not re.fullmatch(r'[a-z0-9-]+', q['id']):
                err(where, f'bad or repeated id "{q["id"]}"')
            Q[q['id']] = dict(q, where=where, steps=[])
        elif r[0] == 'S':
            if len(r) != 7:
                err(where, f'S row has {len(r) - 1} fields, wants 6')
                continue
            S.append((where, dict(zip(['errand', 'kind', 'spec', 'qty', 'alt', 'label'], r[1:]))))
        else:
            err(where, f'unknown row "{r[0]}"')
    for where, s in S:
        if s['errand'] not in Q:
            err(where, f'step of unknown errand "{s["errand"]}"')
        else:
            Q[s['errand']]['steps'].append((where, s))
    return Q


def lint_errand_rows(w, Q, extras, chapters):
    used = []
    carried = set(extras['ITEM'])
    for q in Q.values():
        where, region = q['where'], q['area']
        if region not in w.regions:
            err(where, f'unknown area "{region}"')
            continue
        if q['zone'] != '0' and (region, int(q['zone'])) not in w.zones:
            err(where, f'zone {q["zone"]} is not in {region}')
        if q['kind'] not in ERRAND_KINDS:
            err(where, f'unknown kind "{q["kind"]}"')
        if q['giver'] not in w.stop_types | CAST | w.npcs | w.place_slugs(region) | {'any'}:
            err(where, f'unknown giver "{q["giver"]}"')
        if q['repeat'] not in ('once', 'regular', 'act') or (q['repeat'] == 'act') != (q['kind'] == 'happening'):
            err(where, f'bad repeat "{q["repeat"]}" for a {q["kind"]} row')
        if q['kind'] == 'happening' and 'hp=' not in q['trigger']:
            err(where, 'a happening act needs an hp= trigger')
        if not q['lv'].isdigit() or not BAND_LEVELS[BANDS[region]][0] <= int(q['lv']) <= BAND_LEVELS[BANDS[region]][1]:
            err(where, f'level {q["lv"]} is outside the band of {region}')
        check_trigger(w, where, q['trigger'], region, chapters, extras)
        check_reward(w, where, q['reward'])
        used += check_reward(w, where, q['extra'], extras, region)
        if q['kind'] != 'helper' and q['extra'] in ('', '-'):
            err(where, 'no first-time extra')
        if not q['title'] or not q['intro'] or not q['outro']:
            err(where, 'title, intro and outro are needed')
        if q['kind'] == 'creature' and q['outro'].count(';;') != 2:
            err(where, 'a creature errand has three endings (beaten ;; charmed ;; peaceful)')
        check_text(where, q['title'] + ' ' + q['intro'] + ' ' + q['outro'])
        if not q['steps']:
            err(where, 'no steps')
        if q['kind'] == 'creature' and not any(s['kind'] == 'defeat' for _, s in q['steps']):
            err(where, 'a creature errand needs a defeat step')
        for swhere, s in q['steps']:
            kinds = [(s['kind'], s['spec'])] + ([parse_alt(s['alt'])] if s['alt'] != '-' else [])
            if s['kind'] not in ERRAND_STEP_KINDS or not s['qty'].isdigit():
                err(swhere, f'bad step kind or qty "{s["kind"]}"')
            if s['kind'] == 'defeat' and s['alt'] == '-':
                err(swhere, 'a defeat step needs a peaceful alt')
            for kind, spec in kinds:
                if kind == 'defeat':
                    check_defeat(w, swhere, spec, region)
                elif kind == 'plant':
                    check_plant(w, swhere, spec)
                elif kind == 'deliver':
                    check_needs(w, swhere, spec, carried, ERRAND_WHERE, region)
                    used += [('ITEM', i) for part in spec.split(',') if part.startswith('item:') for i in part.split(':')[1].split('/') if i in carried]
                elif kind == 'escort':
                    for part in spec.split(','):
                        if part.split(':')[0] in ('from', 'to'):
                            check_where(w, swhere, part.split(':', 1)[1], ERRAND_WHERE, region)
            check_text(swhere, s['label'])
    return used


def lint_threads(w, extras, chapters):
    T, used = {}, []
    for n, r in rows('stop_threads_v2.txt'):
        where = f'stop_threads_v2.txt:{n}'
        if len(r) != 9:
            err(where, f'{len(r)} fields, wants 9 (a stray pipe in a beat?)')
            continue
        tid, icon, name, types, regions, reward, beats, trigger, extra = r
        if tid in T or tid in w.old_threads or not re.fullmatch(r'[a-z0-9-]{1,40}', tid):
            err(where, f'bad or repeated id "{tid}"')
        T[tid] = r
        if types != 'any' and not set(types.split(',')) <= w.stop_types:
            err(where, f'unknown stop type in "{types}"')
        regs = regions.split(',')
        if not regions or not set(regs) <= w.regions:
            err(where, f'unknown region in "{regions}"')
            continue
        if len({BANDS[x] for x in regs}) != 1:
            err(where, 'the regions of a thread are of one band')
        band = BANDS[regs[0]]
        pay = {1: 'c=45:8,xp=16:3', 2: 'c=90:12,xp=120:10', 3: 'c=180:20,xp=300:20', 4: 'c=300:30,xp=600:40', 5: 'c=450:40,xp=1000:60'}[band]
        if not reward.startswith(pay):
            err(where, f'band {band} thread pay is {pay}, not "{reward}"')
        check_reward(w, where, reward)
        bl = beats.split(';;')
        if not 4 <= len(bl) <= 6 or any(b.count('~') != 1 or not all(x.strip() for x in b.split('~')) for b in bl):
            err(where, f'{len(bl)} beats, wants 4 to 6, each "title ~ text"')
        for reg in regs:
            check_trigger(w, where, trigger, reg, chapters, extras)
        used += check_reward(w, where, extra, extras, regs[0])
        if not tid.startswith('cast-') and extra in ('', '-'):
            err(where, 'an area thread has a first-time extra')
        check_text(where, name + ' ' + beats)
    return T, used


def lint_counts(w, Q, T, used, extras):
    side = Counter(q['area'] for q in Q.values() if q['kind'] in SIDE_KINDS)
    area_threads = {t: r for t, r in T.items() if not t.startswith('cast-')}
    for tid, r in area_threads.items():
        side[r[4]] += 1
        if tid in Q:
            err('stop_threads_v2.txt', f'"{tid}" is an errand and a thread')
    for area in sorted(w.regions):
        if side[area] != SIDE_PER_AREA.get(area, 5):
            err('side quests', f'{area} has {side[area]}, wants {SIDE_PER_AREA.get(area, 5)}')
    n_err = sum(1 for q in Q.values() if q['kind'] in SIDE_KINDS)
    counts = [('errands that are side quests', n_err, 63), ('area threads', len(area_threads), 17), ('side quests', n_err + len(area_threads), 80),
              ('cast threads', len(T) - len(area_threads), 20), ('happening acts', sum(1 for q in Q.values() if q['kind'] == 'happening'), 14),
              ('helper errands', sum(1 for q in Q.values() if q['kind'] == 'helper'), 2),
              ('repeatable errands', sum(1 for q in Q.values() if q['repeat'] == 'regular'), 15),
              ('titles', len({v for k, v in used if k == 'title'}), 14), ('treasure seeds', sum(1 for k, _ in used if k == 'seed'), 7),
              ('recipe unlocks', sum(1 for k, _ in used if k == 'RECIPE'), 13)]
    for what, n, want in counts:
        if n != want:
            err('counts', f'{n} {what}, wants {want}')
    print(', '.join(f'{what} {n}' for what, n, _ in counts))
    seen = Counter(used)
    for typ in ('PLACE', 'THEME', 'RECIPE', 'TEA', 'SHOP', 'PAGE', 'ITEM'):
        for slug in extras[typ]:
            if slug == 'two-lamp-loaf':   # the recipe of The Crossing (a chapter, not an errand)
                continue
            if seen[(typ, slug)] == 0:
                err('journey_extras.txt', f'{typ} {slug} is given by nothing')
            elif seen[(typ, slug)] > 1 and typ not in ('ITEM',):
                err('journey_extras.txt', f'{typ} {slug} is given {seen[(typ, slug)]} times')


# ---------------------------------------------------------------- stop_state.txt and stop_band_lines.txt

def lint_flavour(w):
    state = Counter()
    for n, r in rows('stop_state.txt'):
        where = f'stop_state.txt:{n}'
        if len(r) != 3 or r[0] not in w.stop_types or r[1] not in ('dark', 'lit') or not r[2]:
            err(where, 'wants: stop type | dark or lit | text')
            continue
        state[(r[0], r[1])] += 1
        check_text(where, r[2])
    for t in w.stop_types:
        for s in ('dark', 'lit'):
            if state[(t, s)] != 1:
                err('stop_state.txt', f'{t} has {state[(t, s)]} {s} lines, wants 1')
    band = Counter()
    for n, r in rows('stop_band_lines.txt'):
        where = f'stop_band_lines.txt:{n}'
        ok = (r[0] == 'A' and len(r) == 4 and re.fullmatch(r'dp=(dawn|day|dusk|night)/lit=[01]', r[2])) \
            or (r[0] == 'C' and len(r) == 5 and r[2] in ('dark', 'first', 'half', 'seal')) \
            or (r[0] == 'P' and len(r) == 4 and r[2] in ('1', '2', '3', '4'))
        if not ok or r[1] not in ('1', '2', '3', '4', '5'):
            err(where, f'bad {r[0]} row')
            continue
        band[(r[1], r[0])] += 1
        check_text(where, r[-1])
    for b in '12345':
        for typ, want in (('A', 6), ('C', 4), ('P', 3)):
            if band[(b, typ)] != want:
                err('stop_band_lines.txt', f'band {b} has {band[(b, typ)]} {typ} rows, wants {want}')
    print(f'stop state lines {sum(state.values())}, band lines {sum(band.values())}')


def main():
    w = World()
    extras = lint_extras(w)
    Q = lint_errands(w)
    chapters = lint_chapters(w, Q)
    used = lint_errand_rows(w, Q, extras, chapters)
    T, tused = lint_threads(w, extras, chapters)
    lint_counts(w, Q, T, used + tused, extras)
    lint_flavour(w)
    if ERRORS:
        print(f'\n{len(ERRORS)} errors')
        for e in ERRORS:
            print('  ' + e)
        return 1
    print('\nquest data: clean')
    return 0


if __name__ == '__main__':
    sys.exit(main())
