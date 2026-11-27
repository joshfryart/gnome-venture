#!/usr/bin/env python3
"""Audit (and fix) the stop-perk proposal set.

Proposal tooling only: reads the four perk files, claude/route-list.md and the game's data files; writes nothing under game/.

    python3 claude/tools_audit_stop_perks.py          # audit only, prints the report, exit 1 on any error
    python3 claude/tools_audit_stop_perks.py --fix    # apply the FIXES and RAISES tables to the .md files, write the Hook list, then audit
    python3 claude/tools_audit_stop_perks.py --unraise  # take the impact raises (RAISES) out again: the set as it was before them

Files: claude/proposal-stop-perks.md (Maplewold 18 stops, section 5; 36 templates, section 6),
       claude/proposal-stop-perks-regions-A.md (CA NWE CB SA), -B.md (SE EE MENA WCA), -C.md (ESA CSA EA SEA OC).

Checks
  1. Stops: every town, village and haven of every region in route-list.md has exactly 3 perks, one per bar;
     nothing missing, nothing invented (Cattailmere, Granitegate are the two new Maplewold villages; the border
     villages Larkbrook, Windbottom, Honeythorpe are owned by the Maplewold set). Counts per region and total.
  2. Uniqueness across all files (and the 36 templates): names; effects normalised (case, punctuation, stop and
     region names taken out); near-duplicate effects (same family, content-word overlap); same family + scope + target.
  3. Caps: world (W) use per family against its cap; A4 coins against the 10-a-game-day ceiling; crop rule
     (at most one crop-scoped perk per crop per effect family, all files); region rule (one region= perk per
     family per region); place-stack ceiling (see PLACE_STACK).
  4. Sizes: nothing above 2% / +1 unit / one daily charge, except the narrow place perks raised to 3% by the impact pass
     (VETO3 in the fixes file: every one is listed for Josh's veto in proposal-perk-impact.md); the size cell and the
     number in the effect text agree; power words in D perks; A3 gifts are a crop, a gatherable or a snack, never a meal.
  5. Hooks: every perk mapped to a family hook + scope keys + daily trigger / UI page; NEW hooks deduplicated
     (written as section "Hook list" into proposal-stop-perks.md with --fix).
  6. Items: every gift names a real item slug (`slug` in back-quotes) found in game data; named crops are real
     crops of that stop's region (region_crops.txt).
"""
import os
import re
import sys
from collections import Counter, defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CL = os.path.join(ROOT, 'claude')
DATA = os.path.join(ROOT, 'game', 'includes', 'data')
INC = os.path.join(ROOT, 'game', 'includes')

F_MAIN = os.path.join(CL, 'proposal-stop-perks.md')
F_A = os.path.join(CL, 'proposal-stop-perks-regions-A.md')
F_B = os.path.join(CL, 'proposal-stop-perks-regions-B.md')
F_C = os.path.join(CL, 'proposal-stop-perks-regions-C.md')
F_ROUTES = os.path.join(CL, 'route-list.md')
ORDER = {F_MAIN: 0, F_A: 1, F_B: 2, F_C: 3}   # "later" file = higher number; clashes are fixed in the later one
SHORT = {F_MAIN: 'main', F_A: 'A', F_B: 'B', F_C: 'C'}

REGION_CODE = {
    'The Maplewold': 'NA', 'Maizehollow': 'CA', 'Mistmoor': 'NWE', 'The Sunsprinkle Isles': 'CB',
    'The Rainroot Reaches': 'SA', 'Olivewhistle Shore': 'SE', 'Birchbramble Steppe': 'EE',
    'The Dunewhisper': 'MENA', 'The Greatcanopy': 'WCA', 'Thornacre Savanna': 'ESA', 'Spicepeak': 'CSA',
    'Blossomreach': 'EA', 'The Monsoon Tangle': 'SEA', 'The Coralscatter': 'OC',
}
NEW_NA_VILLAGES = {'Cattailmere', 'Granitegate'}
BORDER_OWNED_BY_NA = {'Larkbrook': 'CA', 'Windbottom': 'NWE', 'Honeythorpe': 'EA'}
# Maplewold set: numeric perks that are place perks (section 4.1), daily charges that are place perks
NA_PLACE = {'The Straightened Signpost', 'Beacon Basket, Refilled', "This Year's Stone", 'Goat-Track Pickings'}
NA_PLACE_DAILY = {'Oatcake for the Road', 'Spring-Boiled Egg'}

# family -> (label, unit, world cap, per-perk max, existing hook)
FAM = {
    'F01': ('sell', '%', 5, 2, '`world.php:519` `sell_price_with_bonus` (from `sell_to_shop` `:536`)'),
    'F02': ('buy', '%', 5, 2, '`world.php:415` in `shop_price` (`:392`)'),
    'F03': ('xp', '%', 5, 2, '`gnome.php:308` in `add_xp` (`:303`)'),
    'F04': ('garden xp', '%', 5, 2, '`gnome.php:355` `add_garden_xp`'),
    'F05': ('walk time', '%', 6, 2, '`adventure.php:192` in `route_walk_minutes` (`:187`)'),
    'F06': ('pot time', '%', 6, 2, '`crafting.php:465` in `cook_seconds` (`:459`)'),
    'F07': ('dish energy', '%', 5, 2, '`gnome.php:625` in `eat_item` (`:509`)'),
    'F08': ('boost length', '%', 8, 2, '`gnome.php:439` in `buff_minutes` (`:434`)'),
    'F09': ('healing', '%', 8, 2, '`health.php:130` `hp_heal_points`; `adventure.php:1280` `rest_heal`; `stops.php:969` rest acts'),
    'F10': ('harvest extra', '%', 4, 2, '`garden_logic.php:1598` in `do_harvest` (`:1474`)'),
    'F11': ('gather extra', '%', 4, 2, '`gathering.php:78` `gather_on_walk`, `:181` `gather_here`'),
    'F12': ('watering lasts', '%', 8, 2, '`garden_logic.php:865` `water_seconds`'),
    'F13': ('seed back', '%', 4, 2, '`garden_logic.php:1634` in `do_harvest`'),
    'F14': ('friendship chance', '%', 8, 2, '`friends.php:56` `friend_add` (extra roll NEW inside it)'),
    'F15': ('stop coins', '%', 8, 2, '`stops.php:670` `stop_rewards`'),
    'F16': ('stop check', '%', 4, 2, '`stops.php:742` `stop_check` (roll `:748`)'),
    'F17': ('pest', '%', 8, 2, '`garden_fx.php:281` `pest_chances`'),
    'F18': ('fast travel cost', '%', 5, 2, '`world.php:282` in `travel_to` (`:267`)'),
    'F19': ('spot hidden', '%', 4, 2, '`explore.php:222` in `explore_deeper` (`:187`)'),
    'F20': ('max health', 'pt', 3, 1, '`adventure.php:81` in `gnome_combat` (`:71`)'),
    'F21': ('torch steps', 'step', 3, 1, '`delve_v2.php:37` `dv2_fuel`'),
    'F22': ('rest energy', 'energy', 2, 1, '`stops.php:969` `stop_do` case rest'),
    'F23': ('seed on fast travel', '%', 4, 2, '`world.php:292` in `travel_to`'),
}
DAILY = {'A1': 'dayfree', 'A2': 'dayback', 'A3': 'daygift', 'A4': 'daycoin'}
FLAGS = {'A5': 'info', 'A6': 'looks'}
A4_CEILING = 10
# Place-stack ceiling (rule P2, written into proposal-stop-perks.md 4.1): for one event, all place and crop perks of one
# family add up to at most this much on top of the world total (XP: one place perk at most).
PLACE_STACK = {f: (2 if f == 'F03' else (1 if FAM[f][1] in ('pt', 'step', 'energy') else 4)) for f in FAM}

errors, warns = [], []


def err(msg):
    errors.append(msg)


def warn(msg):
    warns.append(msg)


def read(p):
    with open(p, encoding='utf-8') as f:
        return f.read()


def write(p, s):
    with open(p, 'w', encoding='utf-8') as f:
        f.write(s)


# ------------------------------------------------------------------ game data
def data_lines(name):
    out = []
    for ln in read(os.path.join(DATA, name)).splitlines():
        if ln.strip() and not ln.startswith('#'):
            out.append(ln.split('|'))
    return out


CROPS = {r[0]: r[2] for r in data_lines('crops.txt') if len(r) > 2}          # slug -> kind
CROP_NAME = {r[0]: r[1].lower() for r in data_lines('crops.txt') if len(r) > 2}
REGION_CROPS = defaultdict(set)                                              # region -> crop slugs
for r in data_lines('region_crops.txt'):
    if len(r) >= 3:
        REGION_CROPS[r[0]].update(x.strip() for x in r[2].split(',') if x.strip())
RECIPE_TIER = {r[0]: (r[7] if len(r) > 7 else '') for r in data_lines('recipes.txt')}


def item_slugs():
    s = set(CROPS) | set(RECIPE_TIER)
    for name, col in (('gatherables.txt', 0), ('trail_sight_items.txt', 0), ('flowers.txt', 0), ('hybrids.txt', 0),
                      ('tea_ingredients.txt', 0)):
        s |= {r[col].strip() for r in data_lines(name)}
    for r in data_lines('crafts.txt'):
        if len(r) > 3:
            s |= {x.split(':')[0].strip() for x in r[3].split(',')}
    for name in ('stop_acts.txt', 'stop_acts_regional.txt', 'stop_acts_waves.txt', 'stop_acts_living.txt'):
        for m in re.finditer(r'([a-z][a-z0-9-]+):\d+', read(os.path.join(DATA, name))):
            s.add(m.group(1))
    for fn in os.listdir(INC):
        if fn.endswith('.php'):
            for m in re.finditer(r"slug\s*=\s*'([a-z][a-z0-9-]+)'", read(os.path.join(INC, fn))):
                s.add(m.group(1))
    return s


ITEMS = item_slugs()
SNACK_OK = {k for k, v in RECIPE_TIER.items() if v in ('snack', 'preserve')}


# ------------------------------------------------------------------ fixes
VETO3 = set()   # perk keys (file:stop:bar) allowed at 3%: narrow place perks raised by the impact pass, listed for Josh's veto


def apply_fixes(raise_too=True):
    """Corrections (FIXES), then the impact raises (RAISES). Re-runnable: the raises are taken out first (new -> old, last row
    first), so every correction finds its text again; then the corrections and the raises are put back in order."""
    import tools_audit_stop_perks_fixes as fx   # noqa: E402  (kept beside this script)
    files = {'main': F_MAIN, 'A': F_A, 'B': F_B, 'C': F_C, 'master': os.path.join(CL, 'PROPOSAL-HOLLOW-MASTER.md')}
    texts = {k: read(p) for k, p in files.items()}
    raises = list(getattr(fx, 'RAISES', []))
    undone = 0
    for fkey, old, new, why in reversed(raises):
        if texts[fkey].count(new) == 1 and (old in new or old not in texts[fkey]):   # old in new: a row that only adds text
            texts[fkey] = texts[fkey].replace(new, old)
            undone += 1
    applied = skipped = 0
    for label, table in (('fixes', fx.FIXES), ('raises', raises if raise_too else [])):
        applied = skipped = 0
        for fkey, old, new, why in table:
            t = texts[fkey]
            n = t.count(old)
            if new in t and (n == 0 or old in new):
                skipped += 1
            elif n == 1:
                texts[fkey] = t.replace(old, new)
                applied += 1
            else:
                err(f'{label[:-1].upper()} not applicable ({fkey}, found {n}x): {old[:90]!r} [{why}]')
        print(f'{label}: {applied} applied, {skipped} already in place, of {len(table)}')
    for k, p in files.items():
        write(p, texts[k])


# ------------------------------------------------------------------ parsing
def norm_stop(s):
    s = re.sub(r'\s*\((haven|town|village|new|NEW)\)', '', s).replace('**', '').strip()
    s = re.sub(r'^The ', '', s)
    return s


def split_icon(s):
    s = s.strip()
    m = re.match(r'^([^\w\'"(]+)\s+(.*)$', s)
    return (m.group(1).strip(), m.group(2).strip()) if m else ('', s)


def cells(line):
    return [c.strip() for c in line.strip().strip('|').split('|')]


class Perk:
    def __init__(self, **k):
        self.__dict__.update(k)

    def key(self):
        return f'{SHORT[self.file]}:{self.stop}:{self.bar}'


def parse_tables(path):
    """Yield (heading_region_code, header, row-cells) for perk tables (header has Stop and Bar)."""
    lines = read(path).splitlines()
    region = None
    i = 0
    while i < len(lines):
        ln = lines[i]
        m = re.match(r'^##\s+\d+\.\s+(.+?)\s+\((\w+)\)', ln)
        if m:
            region = m.group(2)
        if ln.startswith('| Stop |') and '| Bar |' in ln:
            header = cells(ln)
            i += 2
            while i < len(lines) and lines[i].startswith('|'):
                yield region, header, cells(lines[i]), i + 1
                i += 1
            continue
        i += 1


def size_of(s):
    s = s.strip()
    if s == 'flag':
        return ('flag', 0)
    if 'a day' in s and not re.search(r'coin', s):
        return ('daily', 1)
    m = re.match(r'([+-]?\d+)\s*(%)?', s)
    if m:
        unit = '%' if m.group(2) else ('coin' if 'coin' in s else 'unit')
        return (unit, abs(int(m.group(1))))
    return ('?', 0)


def parse_all():
    perks = []
    for path in (F_MAIN, F_A, F_B, F_C):
        last_stop, last_type = None, ''
        for region, hdr, c, lineno in parse_tables(path):
            if len(c) != len(hdr):
                err(f'{SHORT[path]} line {lineno}: {len(c)} cells, header has {len(hdr)}')
                continue
            row = dict(zip(hdr, c))
            stop = row['Stop'] or last_stop
            if row['Stop']:
                last_type = row.get('Type', '')
            last_stop = stop
            stop = norm_stop(stop)
            if 'Icon' in row:
                icon, name = row['Icon'], row['Perk']
            else:
                icon, name = split_icon(row['Perk'])
            fam = row['Family'].split()[0]
            scope_txt = row.get('Scope', '')
            if path == F_MAIN:
                reg = BORDER_OWNED_BY_NA.get(stop, 'NA')
                if fam in FLAGS:
                    cls = 'F'
                elif fam in DAILY:
                    cls = 'D'
                else:
                    cls = 'P' if name in NA_PLACE else 'W'
                if fam == 'A4':
                    cls = 'D'
                owner = 'NA'
            else:
                reg = region
                cls = scope_txt.strip()[:1] if scope_txt.strip() else '?'
                owner = region
            perks.append(Perk(file=path, region=reg, owner=owner, stop=stop, type=last_type, bar=row['Bar'],
                              icon=icon, name=name, effect=row['Effect'], size=row['Size'], scope=scope_txt,
                              cls=cls, fam=fam, line=lineno))
    return perks


def parse_templates():
    t = read(F_MAIN)
    sec = t.split('## 6. Type templates', 1)[1].split('## 7.', 1)[0]
    out = []
    for ln in sec.splitlines():
        if ln.startswith('| ') and not ln.startswith('| Type') and not ln.startswith('|---'):
            c = cells(ln)
            for bar, cell in zip(('Repairs', 'Larder', 'Cheer'), c[1:4]):
                m = re.match(r'^(\S+)\s+(.+?):\s+(.*)\s+\((\w+)\)$', cell)
                if m:
                    out.append(Perk(file=F_MAIN, region='TEMPLATE', owner='TEMPLATE', stop='{' + c[0] + '}', type=c[0],
                                    bar=bar, icon=m.group(1), name=m.group(2), effect=m.group(3), size='', scope='P',
                                    cls='P', fam=m.group(4), line=0))
    return out


def parse_routes():
    reg_stops = defaultdict(set)
    cur = None
    for ln in read(F_ROUTES).splitlines():
        m = re.match(r'^## (.+?) \(\d+ routes', ln)
        if m:
            cur = REGION_CODE.get(m.group(1)) if '->' not in m.group(1) else None
            continue
        if cur and ln.startswith('| ') and re.match(r'^\| \d+', ln):
            c = cells(ln)
            for end in (c[1], c[2]):
                mm = re.match(r'^(.+?) \((town|village|haven)\)$', end)
                if mm:
                    reg_stops[cur].add(norm_stop(mm.group(1)))
    return reg_stops


# ------------------------------------------------------------------ text helpers
STOPWORDS = set('a an the of at on in to from and or is are by your you for each day with any that it its one 1 2 more '
                'less than time chance than s this be has have than when while first once'.split())


def norm_effect(e, names):
    s = e.lower().replace('’', "'")
    for n in sorted(names, key=len, reverse=True):
        s = s.replace(n.lower(), ' X ')
    s = re.sub(r'`[^`]*`', ' ', s)
    s = re.sub(r"[^a-z0-9% ]+", ' ', s)
    s = re.sub(r'\bx\b(\s+s\b)?', 'X', s)
    return re.sub(r'\s+', ' ', s).strip()


def words(s):
    return {w for w in re.findall(r'[a-z]+', s.lower()) if w not in STOPWORDS and len(w) > 2}


# crop mentions -----------------------------------------------------------
def crop_names():
    out = {}
    for slug in CROPS:
        nm = CROP_NAME[slug]
        forms = {nm, slug.replace('-', ' ')}
        for f in list(forms):
            forms.add(f + 's')
            forms.add(f + 'es')
            if f.endswith('y'):
                forms.add(f[:-1] + 'ies')
        for f in forms:
            out[f] = slug
    out['oat'] = 'oats'
    out['beans'] = None
    return out


CROP_FORMS = crop_names()
GROUPS = {   # group words -> crop kinds (resolved inside the stop's region)
    'fruit trees': {'tree'}, 'tree crops': {'tree'}, 'tree harvests': {'tree'}, 'fruit crops': {'fruit', 'tree'},
    'grain': {'grain'}, 'grains': {'grain'}, 'nut and tree': {'nut', 'tree'}, 'nut harvests': {'nut'},
    'leafy': {'vegetable', 'herb'}, 'herbs and spices': {'herb', 'spice'}, 'pod crops': {'legume'},
}
CROP_FAMS = {'F04', 'F06', 'F07', 'F08', 'F10', 'F12', 'F13', 'F17', 'F14', 'F01', 'F02', 'F03'}
PLACE_WORDS = re.compile(r"\b(eaten at|drunk at|bought at|cooked at|stall|stalls|market pays|shared at|at [A-Z]|in [A-Z][a-z]+ Market)")


def crops_in(text, region):
    t = ' ' + re.sub(r'[^a-z ]', ' ', text.lower()) + ' '
    found = set()
    for f in sorted(CROP_FORMS, key=len, reverse=True):
        if f and f' {f} ' in t and CROP_FORMS[f]:
            found.add(CROP_FORMS[f])
            t = t.replace(f' {f} ', ' _ ')
    if region in REGION_CROPS:
        for g, kinds in GROUPS.items():
            if re.search(r'\b' + g + r'\b', text.lower()):
                found |= {c for c in REGION_CROPS[region] if CROPS.get(c) in kinds}
        if 'local crops' in text.lower() and not any(g in text.lower() for g in GROUPS):
            found |= REGION_CROPS[region]
    return found


def crop_scoped(p):
    """True if the perk acts on crops wherever they grow (garden/kitchen), not at one stop's stall or table."""
    if p.fam not in CROP_FAMS and not (p.fam == 'A3' and 'harvest' in p.effect.lower()):
        return False
    e = p.effect
    if p.fam in ('F01', 'F02', 'F03', 'F14') and ('stall' in e or 'Market' in e or ' at ' in e or 'shop' in e.lower()):
        return False
    if re.search(r'\b(eaten|drunk|bought|cooked|shared) (at|in|on)\b', e) or "'s fire" in e or 'campfire' in e:
        return False
    if 'items' in p.scope or 'local' in e or 'harvest' in e.lower() or 'Dishes with' in e or 'Dishes made with' in e \
            or 'Watering' in e or 'Pests' in e or 'garden XP' in e or 'Gifts of' in e:
        return bool(crops_in(e, p.region if p.region in REGION_CROPS else 'NA'))
    return False


# ------------------------------------------------------------------ hooks
def scope_keys(p):
    e, s = p.effect, p.scope
    k = set()
    low = e.lower()
    if p.cls in ('P', 'D'):
        if re.search(r'\b(start|starts|from)\b', low) and ('walk' in low or 'travel' in low or 'road' in low):
            k.add('from')
        if re.search(r'\b(end|ends|to)\b', low) and ('walk' in low or 'travel' in low) and 'from' not in k:
            k.add('to')
        if 'from=' in s and not k:
            k.add('at')
        if 'to=' in s and 'to' not in k and 'travel' in low:
            k.add('to')
        if 'region=' in s or re.search(r'\b(anywhere in|in the [A-Z]|in [A-Z][a-z]+ delves|on the Maplewold|inside the)\b', e):
            k.add('region')
    if crop_scoped(p):
        k.add('items')
    if re.search(r'\b(dawn|dusk|night|midday|by day|day part)\b', low):
        k.add('dp')
    if re.search(r'\b(rain|rainy|wind|windy|snow|snows|frost|fog|heat|hot|sunny|storm|clear nights|dry weather|no wind|cold)\b', low):
        k.add('we')
    if re.search(r'\b(spring|summer|autumn|winter)\b', low) and 'hot spring' not in low:
        k.add('se')
    if re.search(r'\b(contest|lore acts|craft acts|craft and|trade and|haggle|pick and|power act|mend and|fishing and|festival act|tend act|charm checks|sense and lore|lore check|cook acts)\b', low):
        k.add('kind')
    if 'festival' in low:
        k.add('fest')
    if re.search(r'(forest|coast|mountain|desert|wetland|tundra|island|rainforest)\b.*\b(walk|trail|road|gather)|(walk|trail|road|gather)\w*\b.*\b(forest|coast|mountain|desert|wetland|tundra|island|rainforest)', low):
        k.add('land')
    if re.search(r'delve|torch|Galleries|Grottoes|Hollows|Run\b|Canyon|Bridges|Long Wall|Maze|Ledges|Fire Trails', e):
        k.add('delve')
    if re.search(r'road from .* to the|road to Condor', e):
        k.add('route')
    if re.search(r'\bfish\b|teas?\b|soups|stews|egg dishes|breads|bakes|syrups|sweets|spices|dried|pickles|preserves|roots and tubers|seeds\b|flowers|juices|drinks|tools and gear|leeks', low) \
            and p.fam in ('F01', 'F02', 'F06', 'F07', 'F08'):
        k.add('group')
    return k


SCOPE_NOTE = {
    'from': 'stop the walk / act / fast travel starts at (`$route` from, `users.location_id`)',
    'to': 'stop the walk ends at (`$route` to); fast travel ends only at a region town',
    'at': 'the stop the gnome stands at (`users.location_id`)',
    'region': 'region of the place (and `land=` where named)',
    'items': 'named crops (crop slug list), resolved per event: dish ingredients, harvested or watered crop',
    'dp': '`gclock_my_hour()` day part', 'we': '`gclock_my_weather()`', 'se': 'season of the gnome\'s date',
    'kind': 'act kind of the stop act (`stop_do` `$kind`)', 'fest': 'stop festival day (`stop_calendar`)',
    'land': 'landscape of the route / place', 'delve': 'delve landmark id', 'route': 'route id (lair road)',
    'group': 'item group (category or recipe tag: fish, tea, soup, bread...)',
}

# Daily triggers: regex -> (trigger key, hook point). Order matters: first match wins.
TRIGGERS = [
    (r'turns up a coin', 'coin on a road walk', '`give_find` (`adventure.php:447`)'),
    (r'first visit', 'first visit to the stop', '`stop_stamp` (`stop_pass.php:119`), exists'),
    (r'first food you buy', 'first food bought in a shop', '`buy_from_shop` (`world.php:356`), exists'),
    (r'first (seed|tool|food).*buy|first seed you buy', 'first buy at the stop\'s stall', '`buy_from_shop` (`world.php:356`) + stall stop id, NEW test'),
    (r'first (sale|fish you sell|dish you sell)|sells? .*pays 2 coins|first sale', 'first sale at the stop\'s stall', '`sell_to_shop` (`world.php:536`) + stall stop id, NEW test'),
    (r'first rest act', 'first rest act at the stop', '`stop_do` case rest (`stops.php:969`)'),
    (r'first (lore|craft|power|tend|festival|cook or craft) act|first act|first stop act|act you do', 'first act (of a kind) at the stop', '`stop_do` (`stops.php:810`) energy / reward step, NEW charge test'),
    (r'lore check at', 'failed check at a wonder', 'NEW in `wonder_try` (`landmarks.php:228`)'),
    (r'lost (contest|game)|contest .*(tried|played) again', 'lost contest replay', 'NEW in `stop_do` case contest (`stops.php:953`)'),
    (r'failed stop check|failed .*check', 'failed stop check re-roll', '`stop_check` roll (`stops.php:748`), exists'),
    (r'wear on your walking staff|staff wear', 'staff wear', '`start_expedition` (`adventure.php:237`), exists'),
    (r'rod wear|wear on your fishing rod', 'rod wear', 'NEW in the tool-wear step of `gather_on_walk` / `gather_here` (`gathering.php`; limits `tools.php:285`)'),
    (r'rock pick', 'rock-pick wear', 'NEW in the tool-wear step of `gather_on_walk` (`gathering.php`)'),
    (r'bug net', 'bug-net wear', 'NEW in the tool-wear step of `gather_on_walk` (`gathering.php`)'),
    (r'tool wear|wear.*tool|tool use', 'tool wear', 'NEW in the tool-wear step of `gather_on_walk` / `gather_here` (`gathering.php`; limits `tools.php:285`)'),
    (r'seed you plant', 'planting', 'NEW in `garden_action` plant (`garden_logic.php:1197`)'),
    (r'weeding', 'weeding', '`garden_action` weed (`garden_logic.php:1317`), exists'),
    (r'watering', 'watering', '`garden_claim_free_water` (`garden_logic.php:554`), exists'),
    (r'fast travel', 'fast travel', '`travel_to` (`world.php:283`), exists'),
    (r'torch step', 'torch step in a named delve', 'NEW in the delve step cost (`delve_v2.php`, beside `dv2_fuel`)'),
    (r'cook with|bake you cook', 'first dish cooked with a named crop', '`crafting.php:529` extra-dish roll, NEW charge test'),
    (r'harvest', 'first harvest of a named crop', '`do_harvest` (`garden_logic.php:1474`), NEW charge test'),
    (r'tea you brew', 'first tea brewed', 'NEW in the Hovel kettle (`tea.php`)'),
    (r'dish (you eat|cooked)|first dish', 'first dish eaten / cooked at the stop', '`eat_item` (`gnome.php:509`) / `cook_seconds` stop ctx, NEW charge test'),
    (r'gift', 'first gift to the stop\'s folk', 'NEW in `stop_gift` (`stop_folk.php:181`)'),
    (r'walk .*finds nothing|look once more', 'an empty walk find', 'NEW in `give_find` (`adventure.php:447`)'),
    (r'fish you find|gather at|time you gather', 'first find of a kind on a walk / gather here', '`gather_on_walk` / `gather_here` (`gathering.php:78, 181`), NEW charge test'),
    (r'craft act .*(fails|ingredient)|ingredient back|ingredients back', 'craft ingredients back', 'NEW in `stop_do` case craft'),
    (r'walk|road', 'first walk from / to the stop', '`route_energy` (`adventure.php:202`) / `start_expedition`; arrival: NEW in the walk-end step'),
    (r'coin', 'coin on a find', '`give_find` (`adventure.php:447`)'),
]


def mentions_stop(p):
    e = p.effect.lower()
    first = p.stop.lower().split()[0]
    return p.stop.lower() in e or (len(first) > 4 and first in e) or "here" in e


def trigger_of(p):
    low = p.effect.lower()
    for rx, key, hook in TRIGGERS:
        if re.search(rx, low):
            return key, hook
    return None, None


UI_PAGES = [
    (r'today page', 'Today page', '`today_view.php`'), (r'route menu|fast-travel list', 'route menu', '`here_view.php` routes block'),
    (r'route map', 'walk view (route maps)', '`adventure.php` walk view, trail maps'),
    (r'tea journal', 'kitchen / recipes / tea', '`kitchen.php`, `tea_view.php`'),
    (r'fireflies|songlines|delve', 'delve', '`delve_v2.php` view'),
    (r'world map|maplewold map', 'world map', '`maps.php`'),
    (r'rest acts show', 'stop page', '`here_view.php` stop card / `stop_living.php`'),
    (r'tallest plant', 'garden', '`garden.php` / `garden_logic.php` view'), (r'stop page|stop checks|notice board|plaque|stop gossip', 'stop page', '`here_view.php` stop card / `stop_living.php`'),
    (r'satchel', 'satchel', '`inventory.php`'), (r'passport', 'passport', '`passport.php`, `stop_pass.php`'),
    (r'garden|gate|fence|water butt|plot|bed', 'garden', '`garden.php` / `garden_logic.php` view'),
    (r'recipe|cooking pot|tea menu', 'kitchen / recipes / tea', '`kitchen.php`, `tea_view.php`'),
    (r'shop|stall|shelves', 'shops', '`shop.php`, `world.php`'), (r'friends page|chat lines', 'friends', '`friends.php`, `villagers.php`'),
    (r'profile|portrait|perks page|hovel|windowsill|chimney|home|door|walking staff', 'gnome / home', '`profile.php`, `hovel.php`, `gnome.php`'),
    (r'delve|torch', 'delve', '`delve_v2.php` view'), (r'seed packets|seed ages', 'seed packets', '`inventory.php`'),
]


def ui_of(p):
    low = p.effect.lower()
    for rx, key, f in UI_PAGES:
        if re.search(rx, low):
            return key, f
    return 'other', '?'


# ------------------------------------------------------------------ main audit
def audit(write_hooks):
    perks = parse_all()
    tmpl = parse_templates()
    routes = parse_routes()
    by_owner = defaultdict(list)
    for p in perks:
        by_owner[p.owner].append(p)

    print('== 1. Stops and counts')
    expected = {}
    for code, stops in routes.items():
        expected[code] = set(stops)
    expected['NA'] = expected['NA'] | NEW_NA_VILLAGES | set(BORDER_OWNED_BY_NA)
    for b, code in BORDER_OWNED_BY_NA.items():
        expected[code].discard(b)
    total = 0
    per_stop = defaultdict(list)
    for p in perks:
        per_stop[(p.owner, p.stop)].append(p)
    rows = []
    for code in ['NA', 'CA', 'NWE', 'CB', 'SA', 'SE', 'EE', 'MENA', 'WCA', 'ESA', 'CSA', 'EA', 'SEA', 'OC']:
        got = {s for (o, s) in per_stop if o == code}
        miss, extra = expected.get(code, set()) - got, got - expected.get(code, set())
        for s in sorted(miss):
            err(f'stop missing: {code} {s}')
        for s in sorted(extra):
            err(f'stop invented / not in route list: {code} {s}')
        n = sum(len(per_stop[(code, s)]) for s in got)
        total += n
        cls = Counter(p.cls for p in by_owner[code])
        rows.append((code, len(got), n, cls['W'], cls['P'], cls['D'], cls['F']))
    for (o, s), ps in per_stop.items():
        bars = sorted(p.bar for p in ps)
        if bars != ['Cheer', 'Larder', 'Repairs']:
            err(f'{o} {s}: bars {bars}')
        fams = [p.fam for p in ps]
        if len(set(fams)) != len(fams):
            err(f'{o} {s}: one family twice {fams}')
        if sum(1 for f in fams if f == 'A5') > 1 or sum(1 for f in fams if f == 'A6') > 1:
            err(f'{o} {s}: two flags of one kind')
    print('| Set | Stops | Perks | W | P | D | F |')
    for r in rows:
        print('| %s | %d | %d | %d | %d | %d | %d |' % r)
    file_counts = Counter(SHORT[p.file] for p in perks)
    print(f'total perks: {total}  (by file: {dict(file_counts)})')

    allp = perks + tmpl
    stop_names = {p.stop for p in perks} | {'Maplewold', 'Maplewold Market'} | set(REGION_CODE) | \
                 {k.replace('The ', '') for k in REGION_CODE} | {'Thornacre market', 'Spicepeak market', 'Coralscatter market',
                  'Monsoon Tangle market', 'Isles Market', 'Thousand Chilies', 'Savanna', 'Isles', 'Reaches', 'Shore'}
    stop_names |= {'{stop}'}

    print('\n== 2. Uniqueness')
    seen = {}
    for p in sorted(allp, key=lambda x: (ORDER[x.file], x.line)):
        k = re.sub(r'[^a-z0-9]', '', p.name.lower())
        if k in seen:
            err(f'duplicate name "{p.name}": {seen[k].key()} and {p.key()}')
        else:
            seen[k] = p
    seen = {}
    for p in sorted(allp, key=lambda x: (ORDER[x.file], x.line)):
        k = norm_effect(p.effect, stop_names)
        if k in seen:
            err(f'duplicate effect "{k}": {seen[k].key()} and {p.key()}')
        else:
            seen[k] = p
    # near duplicates (same family; flags compared across A5/A6 too)
    ordered = sorted(allp, key=lambda x: (ORDER[x.file], x.line))
    nd = 0
    for i, a in enumerate(ordered):
        wa = words(norm_effect(a.effect, stop_names))
        for b in ordered[i + 1:]:
            same = (a.fam in FLAGS and b.fam in FLAGS) or (a.fam in DAILY and a.fam == b.fam)
            if not same:
                continue
            wb = words(norm_effect(b.effect, stop_names))
            if not wa or not wb:
                continue
            j = len(wa & wb) / len(wa | wb)
            if j >= (NEAR_FLAG if a.fam in FLAGS else NEAR_DAILY):
                if (a.key(), b.key()) in NEAR_OK:
                    continue
                nd += 1
                err(f'near-duplicate effect ({j:.2f}) {a.key()} "{a.effect}"  ~  {b.key()} "{b.effect}"')
    print(f'near-duplicate pairs over {NEAR}: {nd}')
    # family + scope + target + condition: the effect's content words without the place and without sale/size filler
    sig = defaultdict(list)
    for p in perks:
        if p.fam in FAM:
            w = frozenset(x for x in re.findall(r'[a-z]+', norm_effect(p.effect, stop_names).replace('by day', 'byday')) if x not in SIG_FILL and x not in STOPWORDS)
            sig[(p.fam, p.cls, w)].append(p)
    for k, ps in sig.items():
        if len(ps) > 1:
            err(f'same family + scope + target + condition ({k[0]} {sorted(k[2])}): {[q.key() for q in ps]}')
    tgt = defaultdict(list)
    for p in perks:
        if p.cls in ('W',):
            tgt[('W', p.fam, tuple(sorted(scope_keys(p))), norm_effect(p.effect, stop_names))].append(p)
    for k, ps in tgt.items():
        if len(ps) > 1:
            err(f'same family+scope+target: {[q.key() for q in ps]}')

    print('\n== 3. Caps')
    world = defaultdict(int)
    for p in perks:
        if p.cls == 'W' and p.fam in FAM:
            world[p.fam] += size_of(p.size)[1]
    crop_use = defaultdict(list)
    region_use = defaultdict(list)
    place_max = defaultdict(lambda: defaultdict(int))
    for p in perks:
        u, n = size_of(p.size)
        if p.fam in FAM and p.cls == 'P':
            ks = scope_keys(p)
            if 'items' in ks or crop_scoped(p):
                for c in crops_in(p.effect, p.region if p.region in REGION_CROPS else 'NA'):
                    crop_use[(p.fam, c)].append(p)
            elif 'region' in ks:
                region_use[(p.fam, p.region)].append(p)
        if p.fam == 'A3' and 'harvest' in p.effect.lower():
            for c in crops_in(p.effect, p.region):
                crop_use[('F10', c)].append(p)
        if p.cls == 'W' and crop_scoped(p):
            for c in crops_in(p.effect, 'NA'):
                crop_use[(p.fam, c)].append(p)
    for (f, c), ps in sorted(crop_use.items()):
        if len(ps) > 1:
            err(f'crop rule: {c} gets {f} from {len(ps)} perks: {[q.key() for q in ps]}')
        for q in ps:
            if q.region in REGION_CROPS and c not in REGION_CROPS[q.region] and q.owner != 'NA':
                err(f'crop not native: {q.key()} names {c}, not in region_crops {q.region}')
    for (f, r), ps in sorted(region_use.items()):
        if len(ps) > 1:
            err(f'region rule: {r} has {len(ps)} region-wide {f} perks: {[q.key() for q in ps]}')
    print('| Family | Effect | World cap | World use (Maplewold) | Left | Place perks | Place-stack ceiling | Most at one event |')
    print('|---|---|---|---|---|---|---|---|')
    fam_tab = []
    place_n = Counter(p.fam for p in perks if p.cls == 'P')
    for f, (lab, unit, cap, pmax, hook) in FAM.items():
        if world[f] > cap:
            err(f'cap: {f} world {world[f]} > {cap}')
        u = '%' if unit == '%' else ' ' + unit
        most = cap + PLACE_STACK[f]
        fam_tab.append((f, lab, cap, world[f], cap - world[f], place_n[f], PLACE_STACK[f], most, u))
        print(f'| {f} | {lab} | {cap}{u} | {world[f]} | {cap - world[f]} | {place_n[f]} | {PLACE_STACK[f]} | {most}{u} |')
    a4 = [p for p in perks if p.fam == 'A4']
    a4sum = sum(int(re.search(r'(\d+)', p.size).group(1)) for p in a4)
    print(f'A4 coin perks: {len(a4)}, coins if every one fires in one game day: {a4sum} (ceiling {A4_CEILING}, enforced in code)')
    if a4sum > A4_CEILING:
        warn(f'A4 sum {a4sum} > {A4_CEILING}: the code ceiling cuts it')

    print('\n== 4. Sizes and power')
    for p in perks:
        u, n = size_of(p.size)
        if p.fam in FAM:
            if u == '%' and n > 2 and not (n == 3 and p.cls == 'P' and p.key() in VETO3):
                err(f'over 2% (3% only for a narrow place perk on the veto list): {p.key()} {p.size}')
            if p.key() in VETO3 and not (u == '%' and n == 3 and p.cls == 'P'):
                err(f'veto list names a perk that is not a 3% place perk: {p.key()} {p.size}')
            m = re.search(r'(\d+)\s*%', p.effect)
            if u == '%' and m and int(m.group(1)) != n:
                err(f'size cell {p.size} and effect text {m.group(1)}% differ: {p.key()}')
            if u in ('unit',) and n > 1:
                err(f'over +1: {p.key()} {p.size}')
            if u == 'daily':
                err(f'family {p.fam} but daily size: {p.key()}')
            if n > FAM[p.fam][3] and u in ('%', 'unit') and p.key() not in VETO3:
                err(f'{p.fam} perk above its per-perk size {FAM[p.fam][3]}: {p.key()} {p.size}')
        if p.fam in DAILY and u not in ('daily', 'coin', 'unit'):
            if not (p.fam == 'A4'):
                err(f'daily perk with odd size {p.size}: {p.key()}')
        if p.fam == 'A4':
            m = re.search(r'(\d+)', p.size)
            if m and int(m.group(1)) > 2:
                err(f'A4 above 2 coins: {p.key()}')
        if p.fam in FLAGS and p.size != 'flag':
            err(f'flag family with size {p.size}: {p.key()}')
        for rx in POWER_WORDS:
            if re.search(rx, p.effect, re.I) and p.key() not in POWER_OK:
                err(f'power word /{rx}/: {p.key()} "{p.effect}"')
        if re.search(r'\b([3-9]|\d\d)\s*%', p.effect) and p.key() not in VETO3:
            err(f'effect text names >2%: {p.key()}')

    for rx in THEMES:
        ps = [p for p in perks if p.fam in FLAGS and re.search(rx, p.effect, re.I)]
        if len(ps) > 1:
            err(f'flag theme /{rx}/ used {len(ps)} times: {[q.key() for q in ps]}')

    print('\n== 5. Daily triggers')
    trig = defaultdict(list)
    for p in perks:
        if p.fam in DAILY:
            k, hook = trigger_of(p)
            if not k:
                err(f'no trigger found for daily perk {p.key()} "{p.effect}"')
                continue
            sc = p.stop if (mentions_stop(p) or k in PLACE_TRIGGERS) else 'W'
            if k == 'first harvest of a named crop':
                k = k + ': ' + ','.join(sorted(crops_in(p.effect, p.region)))
            trig[(k, sc)].append(p)
    world_trig = defaultdict(list)
    for (k, sc), ps in trig.items():
        if len(ps) > 1:
            err(f'daily trigger shared: {k} @ {sc}: {[q.key() for q in ps]}')
        if sc == 'W':
            world_trig[k] += ps
    for (k, sc), ps in trig.items():
        if sc != 'W' and k in world_trig and k not in TRIGGER_SHARED_OK:
            err(f'place daily trigger "{k}" at {sc} also used by a world daily perk {[q.key() for q in world_trig[k]]}: {[q.key() for q in ps]}')

    print('\n== 6. Items and crops')
    for p in perks:
        if p.fam == 'A3' or re.search(r'\bone (warm|cup|bowl|piece|slice|wedge|cone|handful|pinch|parcel|heel|twist|small)', p.effect):
            slugs = re.findall(r'`([a-z][a-z0-9-]+)`', p.effect)
            gives_item = re.search(r'\bone\b|\bwith one\b|\bone extra\b|\bgives?\b', p.effect) and not re.search(r'energy|health|coin', p.effect)
            if gives_item and not slugs and not re.search(r'one extra( \w+)?$|gives one extra|comes with one extra|one ingredient back', p.effect):
                err(f'gift names no item slug: {p.key()} "{p.effect}"')
            for s in slugs:
                if s not in ITEMS:
                    err(f'unknown item slug `{s}`: {p.key()}')
                elif s in RECIPE_TIER and RECIPE_TIER[s] not in ('snack', 'preserve'):
                    err(f'gift is a {RECIPE_TIER[s]} (too big for a daily gift): `{s}` {p.key()}')
        for s in re.findall(r'`([a-z][a-z0-9-]+)`', p.scope):
            if s not in CROPS:
                err(f'scope names unknown crop `{s}`: {p.key()}')
            elif p.region in REGION_CROPS and s not in REGION_CROPS[p.region]:
                err(f'scope crop `{s}` not native to {p.region}: {p.key()}')

    print('\n== 7. Hooks')
    hook_rows = build_hooks(perks)
    if write_hooks:
        write_hook_list(hook_rows, fam_tab, rows, total)
    for r in hook_rows['bad']:
        err(r)
    return perks, rows, total, fam_tab


def build_hooks(perks):
    fam_scope = defaultdict(lambda: defaultdict(int))
    trig = defaultdict(int)
    trig_hook = {}
    ui = defaultdict(int)
    ui_file = {}
    bad = []
    for p in perks:
        if p.fam in FAM:
            ks = scope_keys(p)
            for k in ks or {'none'}:
                fam_scope[p.fam][k] += 1
            low = p.effect.lower()
            m = re.search(r'fast travel (?:that (?:starts or )?ends at|to|between) (?:the )?([A-Z][\w-]+(?: [A-Z][\w-]+)*)', p.effect, re.I)
            if p.fam in ('F18', 'F23') and m and 'Market' not in m.group(1):
                if True:
                    bad.append(f'unrealistic hook: {p.key()} fast travel only ends at a region town ("{p.effect}")')
        elif p.fam in DAILY:
            k, h = trigger_of(p)
            if k:
                trig[k] += 1
                trig_hook[k] = h
        elif p.fam in FLAGS:
            k, f = ui_of(p)
            ui[k] += 1
            ui_file[k] = f
        for rx in UNREAL:
            if re.search(rx, p.effect):
                bad.append(f'unrealistic hook /{rx}/: {p.key()} "{p.effect}"')
    return {'fam': fam_scope, 'trig': trig, 'trig_hook': trig_hook, 'ui': ui, 'ui_file': ui_file, 'bad': bad}


def write_hook_list(h, fam_tab, rows, total):
    out = ['## Hook list (all 540 perks, deduplicated; audit 2026-11-27)', '',
           f'Generated by `python3 claude/tools_audit_stop_perks.py --fix` from the perk rows of this file and the three region files ({total} perks). '
           'One resolver does the work: `stop_mark_fx($uid, $family, $ctx)` (NEW, `includes/stop_marks.php`, section 8) adds the world marks of the family '
           '(capped) and the place marks whose scope fits `$ctx`, then applies the place-stack ceiling (4.1 rule P2). So the per-family work is: call it at the '
           'existing hook and pass the context keys below. Everything marked NEW is new code; the rest exists today.', '',
           '**Families (number perks).** Count = perks that use the scope key.', '',
           '| Family | Hook point (exists) | Context keys the perks need (count) |', '|---|---|---|']
    for f, (lab, unit, cap, pmax, hook) in FAM.items():
        ks = h['fam'].get(f, {})
        kk = ', '.join(f'`{k}` {n}' for k, n in sorted(ks.items(), key=lambda x: -x[1]))
        out.append(f'| {f} {lab} | {hook} | {kk or "-"} |')
    out += ['', 'Context keys, where each comes from (all NEW as `$ctx` entries; the data exists):', '']
    for k, v in SCOPE_NOTE.items():
        out.append(f'- `{k}`: {v}')
    out += ['', '**Daily charges (A1 to A4): trigger -> hook point.** One `stop_mark_charge($uid, $perkKey)` (NEW) call at each.', '',
            '| Trigger | Perks | Hook point |', '|---|---|---|']
    for k, n in sorted(h['trig'].items(), key=lambda x: -x[1]):
        out.append(f'| {k} | {n} | {h["trig_hook"][k]} |')
    out += ['', '**Flags (A5 info, A6 looks): page -> file.** One `stop_mark_flag($uid, $perkKey)` (NEW) test in each view; no game rule changes.', '',
            '| Page | Flags | File |', '|---|---|---|']
    for k, n in sorted(h['ui'].items(), key=lambda x: -x[1]):
        out.append(f'| {k} | {n} | {h["ui_file"][k]} |')
    out += ['', '**NEW, deduplicated** (everything the 540 perks need that is not in the code today):', '']
    out += [f'{i}. {x}' for i, x in enumerate(NEW_HOOKS, 1)]
    out += ['', '**Cut as unrealistic in the audit** (rewritten in place, see the audit log in `PROPOSAL-HOLLOW-MASTER.md`): fast travel "to" a village '
            '(`travel_to` only lands at a region\'s town, `world.php:283`); fast travel inside one region (refused as "already here"); wonder states the game '
            'does not keep (where the Oasis That Moves is, whether the Great Migration passes, panda shoots today); a walk "ridden" for no energy (a free walk, '
            'not a 1-energy convenience).', '']
    block = '\n'.join(out) + '\n'
    t = read(F_MAIN)
    start = t.find('## Hook list')
    if start >= 0:
        end = t.find('\n## ', start + 5)
        t = t[:start] + block + (t[end + 1:] if end >= 0 else '')
    else:
        anchor = t.find('## 9. Open questions')
        t = t[:anchor] + block + '\n' + t[anchor:]
    write(F_MAIN, t)
    print('wrote section "Hook list" into proposal-stop-perks.md')


NEW_HOOKS = [
    '`includes/stop_marks.php`: `stop_mark_fx`, `stop_mark_flag`, `stop_mark_charge`, `stop_mark_latch`, `stop_is_place` (section 8), tables `stop_marks`, `stop_mark_use`.',
    '`$ctx` at the 23 family hooks: pass `stop` / `from` / `to` / `region` / `land` / `items` / `kind` / `group` where the call site knows them (route, location, dish ingredients, harvested crop, act kind, item category). Day part, weather, season and festival are read inside the resolver from the gnome\'s clock.',
    'Named-crop scope (`items=crop1,crop2`), replacing `items=local:<stop>`: `stop_local_crops()` returns the whole region, so a crop perk is one per crop per family (4.1 rule P3).',
    'F14 friendship: the extra +1 roll inside `friend_add` (`friends.php:56`), with the gift or chat context from `stop_gift` (`stop_folk.php:181`) and the stop chat.',
    'F18 / F23 fast travel: `from` = the stop the gnome stands at when `travel_to` runs, `to` = the target region\'s town only.',
    'F20 max health on a named lair road or a region\'s land: route id and landscape passed into `gnome_combat` (`adventure.php:71`) from the expedition.',
    'F21 torch: delve landmark id passed into `dv2_fuel` (`delve_v2.php:37`).',
    'A1 energy: a charge test in `stop_do` (first act of a kind at a stop) and in the walk-end step (first walk that ends at a stop).',
    'A2 things back: planting in `garden_action`; tool wear in `gathering.php`; craft ingredients in `stop_do` case craft; contest replay in `stop_do` case contest (`stops.php:953`); wonder check re-roll in `wonder_try` (`landmarks.php:228`); an empty walk find in `give_find`; a delve torch step beside `dv2_fuel`; a gift kept in `stop_gift`; tea ingredient back in `tea.php`.',
    'A3 gifts at a stall buy or sale (`buy_from_shop`, `sell_to_shop`) and at a first rest, lore or craft act (`stop_do`); every gift is a real item slug (crop, gatherable, snack or preserve).',
    'A4 coins: the 10-coins-a-game-day ceiling as one `stop_mark_use` row (`perk_key` = `a4`).',
    'Flags: one `stop_mark_flag` test per view (table above). Info flags read data the game keeps (weather, moon, tool wear, recipes, `stop_log`, `region_visits`, landmark runs); none adds a new game rule.',
]

# ------------------------------------------------------------------ tuning of the checks (judged by hand)
NEAR = 0.6
SIG_FILL = set('stall stalls pays pay sell sells sold cost costs charge charges less more market shop shops bought buy x you there what for in at s the of a its town itself has'.split())
NEAR_FLAG = 0.4      # flags have no place scope, so a close text is a real clash
NEAR_DAILY = 0.99    # place dailies may share a shape at different stops; same words after the stop name is a clash
NEAR_OK = {tuple(x.split(' ~ ')) for x in [   # flag pairs read by hand and kept: different object, page or information
    'main:Honeybrook:Cheer ~ A:Turtle Nesting Beach:Cheer', 'main:Shellhollow:Cheer ~ C:Sprayholt:Cheer',
    'main:Iciclecrest:Cheer ~ A:Meadowmere:Cheer', 'main:Cattailmere:Cheer ~ A:Poppynook:Cheer', 'main:Cattailmere:Cheer ~ A:Heronholt:Cheer',
    'main:Cattailmere:Cheer ~ C:Poppywell:Cheer', 'main:Aurora Camp:Cheer ~ C:Amberburrow:Cheer', 'main:Aurora Camp:Cheer ~ C:Palmgate:Cheer',
    'A:Meadowmere:Cheer ~ B:Driftmead:Cheer', 'A:Meadowmere:Cheer ~ C:Coppergate:Cheer', 'A:Windburrow:Cheer ~ A:Windwell:Cheer',
    'A:Windburrow:Cheer ~ C:Cliffmead:Repairs', 'A:Breezehollow:Cheer ~ C:Poppywell:Cheer', 'A:Heronholt:Cheer ~ C:Poppywell:Cheer',
    'A:Duneford:Cheer ~ C:Bogmead:Cheer', 'C:Meadowden:Cheer ~ C:Brambleburrow:Cheer', 'C:Meadowbottom:Cheer ~ C:Emberhollow:Cheer',
    'C:Meadowbottom:Cheer ~ C:Coralscatter Market:Cheer', 'C:Emberhollow:Cheer ~ C:Coralscatter Market:Cheer',
    'C:Amberburrow:Cheer ~ C:Palmgate:Cheer', 'C:Brambleburrow:Cheer ~ C:Turtleburrow:Repairs',
]}
POWER_WORDS = [r'costs? no energy', r'as if you had won', r'is ridden', r'free walk', r'double', r'every (act|walk)']
POWER_OK = {'main:Cattailmere:Repairs', 'main:Aurora Camp:Larder'}   # one weeding / one watering a game day (1 energy each)
TRIGGER_SHARED_OK = {'first visit to the stop', 'first rest act at the stop', 'first act (of a kind) at the stop',
                     'first sale at the stop\'s stall', 'first buy at the stop\'s stall', 'first walk from / to the stop',
                     'first dish eaten / cooked at the stop', 'first find of a kind on a walk / gather here',
                     'lost contest replay', 'craft ingredients back', 'torch step in a named delve',
                     'first gift to the stop\'s folk'}
PLACE_TRIGGERS = {'torch step in a named delve', 'failed check at a wonder', 'first visit to the stop', 'first rest act at the stop'}
# One flag per theme across all files (themes found by hand in the audit; a new flag that repeats one is an error)
THEMES = [r'\bkite\b', r'\bheron\b', r'\bseal\b', r'\bturtle\b', r'sandpiper|bird tracks', r'usual price', r'already heard',
          r'never (walked|finished)', r'region each|each ingredient grows', r'until .* need water|watering will last', r'\blair\b',
          r'which bar|points each act', r'far end of each', r'not (yet )?found', r'festival (on|day comes)', r'tin roof|drops run',
          r'cooking pot', r'walking staff', r'roads you have walked', r'\bparrot\b', r'water butt', r'passport stamps']
UNREAL = [r'Oasis That Moves is', r'Great Migration is passing', r'shoots to share today', r'is ridden', r'inside the Coralscatter costs',
          r'between coast stops']


def main():
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    fix = '--fix' in sys.argv or '--unraise' in sys.argv
    import tools_audit_stop_perks_fixes as fx
    if '--unraise' not in sys.argv:
        VETO3.update(getattr(fx, 'VETO3', ()))
    if fix:
        apply_fixes(raise_too='--unraise' not in sys.argv)
    audit(fix)
    print('\n== Result')
    for w in warns:
        print('WARN', w)
    for e in errors:
        print('ERROR', e)
    print(f'{len(errors)} errors, {len(warns)} warnings')
    sys.exit(1 if errors else 0)


if __name__ == '__main__':
    main()
