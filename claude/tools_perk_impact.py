#!/usr/bin/env python3
"""Estimate the real-world boost of every stop perk (540) and mark the ones below a meaningful amount.

Proposal tooling only: reads the four perk files through tools_audit_stop_perks.parse_all(); writes nothing under game/.

    python3 claude/tools_perk_impact.py              # writes claude/proposal-perk-impact.csv, prints the summary
    python3 claude/tools_perk_impact.py --snapshot   # also saves the table as proposal-perk-impact-before.csv (run once, before raising)
    python3 claude/tools_perk_impact.py --md         # also rewrites the generated part of proposal-perk-impact.md

The model (baselines, shares, exchange rates, threshold) is explained in claude/proposal-perk-impact.md; every number
of it is in the tables at the top of this file, so a changed assumption is one edit and a re-run.
"""
import csv
import os
import re
import sys
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tools_audit_stop_perks as A   # noqa: E402

CL = A.CL
F_CSV = os.path.join(CL, 'proposal-perk-impact.csv')
F_BEFORE = os.path.join(CL, 'proposal-perk-impact-before.csv')
F_MD = os.path.join(CL, 'proposal-perk-impact.md')

# ------------------------------------------------------------------ 1. baseline per game day, by band
BANDS = ['1-15', '15-35', '35-55']
BAND_LEVEL = [8, 25, 45]
REGION_BAND = {'NA': 0, 'CA': 1, 'NWE': 1, 'CB': 1, 'SA': 1, 'SE': 1, 'EE': 1,
               'MENA': 2, 'CSA': 2, 'WCA': 2, 'ESA': 2, 'EA': 2, 'SEA': 2, 'OC': 2}
# key: (label, [band 1, band 2, band 3], source or assumption)
BASE = {
    'awake_min':   ('Awake minutes', [960, 960, 960], 'master 1.1: 06:00 to 22:00'),
    'stops':       ('Stops visited', [3.5, 3.5, 3.5], 'master 3 A1: 3 to 4 stops on a touring day'),
    'acts':        ('Stop acts done', [17.5, 17.5, 17.5], 'master 3 A1: 5 acts a stop x 3.5 stops'),
    'walks':       ('Walks (routes)', [5, 5, 5], 'assumption: one walk per stop, the first leg and one side path'),
    'walk_min':    ('Walk minutes', [150, 180, 220], 'master 3 A1: about 30 min between neighbours x 5 walks; roads get longer (assumption)'),
    'harvests':    ('Harvests', [3, 5, 6], 'master 3 A3: 6 beds (10, 12 later: assumption), a crop every 2 sleeps on average'),
    'waterings':   ('Watering actions', [6, 10, 12], 'master 3 A3: every bed watered every game day'),
    'plantings':   ('Seeds planted', [3, 5, 6], 'one per harvest (annuals)'),
    'gxp':         ('Garden XP', [54, 90, 108], 'harvests x 18 (`catalog.php:247` xp_per_harvest = tier x tier x 2, tier 3)'),
    'pests':       ('Pest visits', [1, 1, 1], 'assumption'),
    'pot_min':     ('Pot cook minutes', [30, 45, 60], '`recipes.txt`: meal 15 min, snack 3, feast 45; 2 to 3 dishes a day (assumption)'),
    'dishes':      ('Dishes eaten', [2, 3, 3], 'assumption'),
    'dish_energy': ('Energy from dishes', [18, 27, 30], '`recipes.txt`: a meal gives 9 energy on average'),
    'boost_min':   ('Boost minutes running', [450, 670, 700], '`recipes.txt`: a meal boost lasts 224 min on average'),
    'earned':      ('Petals earned', [300, 800, 1450], 'act coins + shop sales below'),
    'act_coins':   ('Petals from stop acts', [225, 560, 950], '`stop_acts.txt`: 7 paying acts x (14 + 4 x stop level) x 0.7 won, stop level = 8, 25, 45'),
    'sold':        ('Petals from shop sales', [80, 250, 500], 'assumption (no sim; master 3 A4)'),
    'spent':       ('Petals spent in shops', [100, 300, 600], 'assumption; master 4: 3,600 Petals of stop fees in 20 to 35 game days'),
    'xp':          ('XP gained', [2100, 27000, 142000], 'master 2.1 band totals / master 3 game days: 75.7k in 36, 2.4M in 90, 13.5M in 95'),
    'act_xp':      ('XP from stop acts', [630, 8100, 42600], 'assumption: 30% of the XP of the day'),
    'friend_ev':   ('Friendship events (chats, gifts)', [6, 8, 8], 'assumption: 3 to 4 folk, one chat and one gift each'),
    'friend_pts':  ('Friendship points', [20, 25, 25], 'master 3 A5: a Friend (100 points) in 6 to 12 game days, 2 to 3 folk at a time'),
    'gifts':       ('Gifts given', [3, 4, 4], 'half of the friendship events'),
    'travels':     ('Fast travels', [0.1, 0.3, 0.5], 'assumption; 150 Petals and 2 energy each (`functions.php:407`)'),
    'floors':      ('Delve floors', [0.33, 0.67, 0.67], 'assumption: a delve every 3 game days, 1 to 2 floors'),
    'delve_steps': ('Delve torch steps', [15, 30, 30], 'floors x 45 (`delve_floors.php:16` DV_TORCH standard)'),
    'fights':      ('Fights', [2, 3, 3], 'assumption (`trail_enc_pct` 3% a tile)'),
    'max_hp':      ('Max health', [44, 95, 155], '20 + 3 x level (proposal-stop-perks.md section 4)'),
    'healed':      ('Health healed', [44, 95, 155], 'assumption: one full bar a game day'),
    'rests':       ('Rest acts', [2, 2, 2], 'assumption: 2 of the 17.5 acts; 3 or 5 energy each (`stop_acts.txt`)'),
    'checks':      ('Stop checks and contests', [6, 6, 6], 'assumption: a third of the acts roll'),
    'crafts':      ('Craft acts', [1, 1, 1], 'assumption'),
    'finds':       ('Gathered finds', [6, 8, 10], 'assumption: 1.2 to 2 finds a walk'),
    'spots':       ('Hidden-thing rolls', [2, 2, 2], 'assumption'),
    'energy':      ('Energy spent', [60, 160, 260], 'max energy 10 + 5 a level (`gnome.php:272`) + food and rest'),
}
# ------------------------------------------------------------------ 2. exchange rates: 1 value point (VP) = 1 Petal
VP_ENERGY = 3.0        # inn bed: 14 Petals for 5 energy (2.8); late supper: 9 Petals for 2 energy (4.5) (`stop_acts.txt`)
VP_ITEM = 8.0          # a common crop or snack; common gatherables average 9 Petals (`gatherables.txt`)
VP_FIND = 12.0         # a gathered find: common 9, uncommon 21 (`gatherables.txt`)
VP_SEED = 6.0          # assumption: a seed is a little under its crop
VP_FRIEND = 4.0        # assumption: an 8-Petal gift gives about 2 points
VP_HP = 0.5            # assumption: half a Petal a health point (potion = half a bar)
VP_BOOST_MIN = 0.1     # assumption: a 224-minute meal boost is worth about 20 Petals
VP_GXP = 1.0           # assumption
VP_PEST = 5.0          # assumption: 1 energy to pick it off + lost growth
VP_SPOT = 30.0         # assumption: a hidden place or cache
VP_STEP = 1.0          # assumption: one torch step = one lit tile
TRAVEL_COST = 150      # `functions.php:407`


def vp_min(b):
    """1 game minute = the Petals of the day / 960."""
    return BASE['earned'][1][b] / 960.0


def vp_xp(b):
    """A day of XP is worth a day of Petals."""
    return BASE['earned'][1][b] / BASE['xp'][1][b]


# ------------------------------------------------------------------ 3. shares (how much of the day's domain a scope reaches)
STOPS_PER_REGION = 12.5
V = 3.5 / STOPS_PER_REGION        # 0.28: a given stop is visited on 28% of the game days spent in its region
S = {
    'acts_here': V * 5 / 17.5,    # 0.08: 5 of the day's 17.5 acts, on a visit day
    'walk_from': V / 5,           # 0.056: one of the day's 5 walks
    'walk_pair': V / 3 / 5 * 2,   # 0.037: one named neighbour of about three, both ways
    'walk_dest': V / 3 / 5,       # 0.019: one named neighbour, one way
    'walk_hub': V / 5 * 2,        # 0.11: every walk that starts or ends at the stop
    'stall': V / 3.5,             # 0.08: a visit day's trade is spread over 3.5 stalls
    'eat_here': V / 3.5,          # 0.08
    'rest_here': V / 2,           # 0.14: one of the day's two rest acts
    'cook_here': 0.05,            # a pot on a stop's fire instead of at home
    'travel_from': 1 / STOPS_PER_REGION,   # 0.08: a fast travel starts wherever the gnome stands
    'travel_to_town': 0.3,
    'lair_road': 0.1,             # of the day's fights
}
# Landscapes: share of a region = its villages in zones of that landscape / all its villages (`zones.txt`)
LAND_WORDS = {'grassland': 'grassland', 'forest': 'forest', 'coast': 'coast', 'tundra': 'tundra', 'mountain': 'mountain',
              'mountains': 'mountain', 'desert': 'desert', 'wetland': 'wetland', 'rainforest': 'rainforest', 'island': 'island',
              'islands': 'island'}
LAND = defaultdict(lambda: defaultdict(float))
for _r in A.data_lines('zones.txt'):
    if len(_r) >= 6:
        LAND[_r[0]][_r[2]] += float(_r[5])
LAND['NA']['wetland'] += 1    # Cattailmere (Beaverdam Fens) and Granitegate (Cairnback Ridge): the two new Maplewold zones
LAND['NA']['mountain'] += 1


def land_share(region, text):
    """Share of the region's stops and roads in the landscapes the text names (1.0 if it names none)."""
    named = {LAND_WORDS[w] for w in re.findall(r'[a-z]+', text.lower()) if w in LAND_WORDS}
    if not named:
        return 1.0
    tot = sum(LAND[region].values()) or 1.0
    x = sum(LAND[region].get(l, 0.0) for l in named) / tot
    return min(1.0, x if x > 0 else 0.25)
DAYPART = {'dawn': 0.125, 'day': 0.625, 'dusk': 0.125, 'night': 0.125}       # of the 16 awake hours
WEATHER = {'rain': 0.15, 'storm': 0.05, 'wind': 0.10, 'fog': 0.07, 'snow': 0.07, 'frost': 0.06, 'heat': 0.10, 'sun': 0.22,
           'cloud': 0.18}                                                    # assumption; adds up to 1
SEASON = 0.25
FESTIVAL = 0.1
CROP_TIER_SHARE = {'staple': 0.70, 'uncommon': 0.25, 'treasure': 0.05}       # of the garden's harvests while in the region
DISH_ING = 2.5                                                               # ingredients a dish (`recipes.txt`)
KIND = [   # act kinds named in an effect -> share of the acts at a stop
    (r'cost 2 or more energy', 0.3), (r'craft and (mend|cook|paint)', 0.35), (r'mend and haul', 0.3), (r'pick and contest', 0.35),
    (r'fishing and gathering', 0.25), (r'sense and lore', 0.5), (r'trade and haggle', 0.2), (r'\bcontests?\b', 0.2), (r'\blore acts?\b', 0.2),
    (r'\bcraft acts?\b', 0.2), (r'\bpower acts?\b', 0.15), (r'\bmend acts?\b', 0.2), (r'haggle checks', 0.15), (r'charm checks', 0.33),
    (r'\btend acts?\b', 0.15),
]
GOODS = [  # goods named at a stall -> share of the trade there
    (r'for what you sell|pays 2% more at dawn|charge 2% less|shops in', 1.0), (r'native crops|crops you sell', 0.5), (r'\bseeds?\b', 0.4),
    (r'\bfood\b', 0.4), (r'dishes', 0.3), (r'\bfruit\b', 0.25), (r'spices and (herbs|dried fruit|chilies)|spices', 0.2),
    (r'roots and tubers', 0.2), (r'\bfish\b', 0.2), (r'pickles and preserves|smoked and dried|bread and oil', 0.15),
    (r'`[a-z-]+`|leeks|corn\b|peanuts and quinoa|flowers|sea salt', 0.1),
]
# World perks of the Maplewold set: share of the day's domain, set by hand from the effect text (the audit has no scope cell there)
WORLD_SHARE = {
    'Level Scales': (0.63, 'crops are 70% of shop sales, 90% of them native while in the Maplewold'),
    'Second Breakfast': (None, 'day part'),
    'A Bed With Your Name On': (0.15, 'inns hold about 15% of the rest acts'),
    'Tidy Skeps': (0.3, 'flowering plants: 30% of the beds'),
    'Honey in the Tea': (0.3, 'teas: 30% of the boost minutes'),
    'Greased Wheel': (0.3, 'breads and bakes: 30% of the pot minutes'),
    "Miller's Pinch": (0.35, 'two of four staples'),
    'Dry Woodpile': (0.3 * 0.5, 'forest trails x half of the healing is trail rests'),
    "Squirrel's Arithmetic": (0.3, 'forest'),
    'Fireside Regular': (0.12, 'camps: about 1 stop in 8'),
    'Sawdust Mulch': (None, 'weather'),
    'Swept Steps': (0.3, 'forest'),
    'What You Leave Comes Back': (0.9, 'native crops while in the Maplewold'),
    'Sound Nets': (0.17, 'jetties and ferries: 2 stop types of 12'),
    'Catch of the Day': (0.2, 'fish: 20% of shop sales'),
    'Beaver-Tight Hull': (0.25, 'coast stops'),
    "Porter's Crate": (0.25, 'coast shops'),
    "Watcher's Flask": (None, 'weather'),
    'Scrubbed Pools': (0.08, 'hot springs: about 1 stop in 12'),
    'Warm to the Bones': (None, 'weather'),
    'Rice in the Turn-Ups': (1.0, 'every fast travel'),
    'Border Lamp': (None, 'day part'),
    'Packed by the Cook': (0.7, 'own dishes: 70% of the boost minutes'),
    'Up With the Lark': (None, 'day part'),
    'Tailwind': (None, 'weather'),
    'Propped Boughs': (0.3, 'fruit and tree crops'),
    'Hop-Yard Hum': (0.5, 'gifts are half of the friendship events'),
    'Stacked Birch': (0.15, 'syrups and sweets'),
    'Brim-Full Bucket': (0.2, 'tree and sap harvests'),
}
THRESH_R = 0.0095      # "about 1%" of the day's activity in the perk's own domain
THRESH_FELT = 0.25     # a clearly felt event at least once in 4 game days = about every visit to the stop (V = 0.28)

REGION_NAMES = {v: k for k, v in A.REGION_CODE.items()}
CROP_TIER = {}
for _r in A.data_lines('region_crops.txt'):
    if len(_r) >= 3:
        for _c in _r[2].split(','):
            CROP_TIER[(_r[0], _c.strip())] = _r[1]
TIER_N = Counter((reg, t) for (reg, c), t in CROP_TIER.items())


def crop_share(region, crops):
    """Share of the garden's harvests that are the named crops, on a game day in the region."""
    q = 0.0
    for c in crops:
        t = CROP_TIER.get((region, c))
        if t:
            q += CROP_TIER_SHARE[t] / TIER_N[(region, t)]
    return min(1.0, q)


def dish_share(q):
    return 1 - (1 - q) ** DISH_ING


# ------------------------------------------------------------------ 4. qualifiers in the effect text
def cond_factor(e):
    """Day part x weather x season x festival share named in the text, and a short note."""
    low = e.lower()
    f, notes = 1.0, []
    low = re.sub(r'first (visit|walk|act|rest act|sale|dish|fish|seed|tea|gift|lore act|craft act|power act|tend act|cook or craft act|festival act)[^:,]*? each (day|night)',
                 lambda m: m.group(0).replace('each night', 'each day at night'), low)
    # day part
    dp = set()
    if re.search(r'outside the night|except at night', low):
        dp = {'dawn', 'day', 'dusk'}
    elif re.search(r'before dusk', low):
        dp = {'dawn', 'day'}
    elif re.search(r'after dawn', low):
        dp = {'day', 'dusk', 'night'}
    else:
        if re.search(r'\bdawn\b', low):
            dp.add('dawn')
        if re.search(r'\bdusk\b', low):
            dp.add('dusk')
        if re.search(r'from dusk on|after dusk', low):
            dp |= {'dusk', 'night'}
        if re.search(r'\bnights?\b', low):
            dp.add('night')
        if re.search(r'\bby day\b|day part "day"|\bmidday\b', low):
            dp.add('day')
    if dp:
        x = sum(DAYPART[d] for d in dp)
        f *= x
        notes.append('day part %.2f' % x)
    # weather
    we = set()
    if re.search(r'in dry weather|dry weather', low):
        we = {'sun', 'cloud', 'wind', 'heat'}
    elif re.search(r'when it is not raining|outside the rain', low):
        we = set(WEATHER) - {'rain', 'storm'}
    else:
        for k, rx in (('rain', r'\brain(y|s)?\b'), ('storm', r'\bstorms?\b'), ('wind', r'\bwind(y)?\b'), ('fog', r'\bfog\b'),
                      ('snow', r'\bsnow(s)?\b'), ('frost', r'\bfrost\b'), ('heat', r'\b(heat|hot)\b'), ('sun', r'\b(sunny|clear)\b'),
                      ('cloud', r'\bcloud(y)?\b')):
            if re.search(rx, low) and not (k == 'heat' and 'hot spring' in low):
                we.add(k)
        if re.search(r'\bcold\b', low):
            we |= {'snow', 'frost'}
    if we:
        x = min(1.0, sum(WEATHER[w] for w in we))
        f *= x
        notes.append('weather %.2f' % x)
    # season
    m = re.search(r'outside (spring|summer|autumn|winter)', low)
    if m:
        f *= 0.75
        notes.append('season 0.75')
    else:
        se = set(re.findall(r'\b(spring|summer|autumn|winter)\b', low.replace('hot spring', '')))
        if se:
            f *= SEASON * len(se)
            notes.append('season %.2f' % (SEASON * len(se)))
    if 'festival' in low:
        f *= FESTIVAL
        notes.append('festival %.2f' % FESTIVAL)
    return f, notes


def kind_factor(e):
    for rx, x in KIND:
        if re.search(rx, e, re.I):
            return x
    return 1.0


def goods_factor(e):
    for rx, x in GOODS:
        if re.search(rx, e, re.I):
            return x
    return 1.0


def is_region(p):
    return 'region=' in p.scope or 'region' in A.scope_keys(p) or bool(re.search(r'\banywhere in\b|\bany \w+ stall\b', p.effect))


def land_factor(p):
    return land_share(p.region, p.effect)


# ------------------------------------------------------------------ 5. the estimate
def base(key, b):
    return BASE[key][1][b]


def pct_of(p):
    u, n = A.size_of(p.size)
    return n


def est_number(p, b):
    """-> (share, rel size, domain key, unit text fn, vp per unit, notes)"""
    e, low, fam = p.effect, p.effect.lower(), p.fam
    n = pct_of(p)
    cf, notes = cond_factor(e)
    reg = is_region(p)
    crop = A.crop_scoped(p)
    crops = A.crops_in(e, p.region if p.region in A.REGION_CROPS else 'NA') if crop else set()
    q = crop_share(p.region, crops) if crops else 0.0
    rel = n / 100.0
    s = None
    if p.cls == 'W':
        ws, why = WORLD_SHARE.get(p.name, (1.0, 'everywhere'))
        s = cf if ws is None else ws * cf
        notes.insert(0, 'world: ' + why)
    dom = {'F01': 'sold', 'F02': 'spent', 'F03': 'act_xp', 'F04': 'gxp', 'F05': 'walk_min', 'F06': 'pot_min', 'F07': 'dish_energy',
           'F08': 'boost_min', 'F09': 'healed', 'F10': 'harvests', 'F11': 'finds', 'F12': 'waterings', 'F13': 'harvests',
           'F14': 'friend_ev', 'F15': 'act_coins', 'F16': 'checks', 'F17': 'pests', 'F18': 'travels', 'F19': 'spots',
           'F20': 'fights', 'F21': 'floors', 'F22': 'rests', 'F23': 'travels'}[fam]
    if fam == 'F03' and p.cls == 'W':
        dom = 'xp'

    def loc(stop_share, what):
        """Region-wide = 1, else the stop's share."""
        if reg:
            x = land_factor(p)
            notes.append('region-wide' + (' x landscapes named %.2f' % x if x < 1 else ''))
            return x
        notes.append('%s %.3f' % (what, stop_share))
        return stop_share

    if s is None:
        if fam in ('F01', 'F02'):
            g = goods_factor(e)
            if crops and not re.search(r'stall|market|shop', low):
                s = q
                notes.append('named crops %.2f of sales' % q)
            else:
                s = loc(S['stall'], 'this stall') * g
                if g < 1:
                    notes.append('goods %.2f' % g)
        elif fam == 'F03':
            k = kind_factor(e)
            s = loc(S['acts_here'], 'acts here') * k
            if k < 1:
                notes.append('act kind %.2f' % k)
        elif fam in ('F04', 'F10', 'F12', 'F13', 'F17'):
            s = q
            notes.append('named crops %.2f of the beds' % q)
        elif fam in ('F06', 'F07', 'F08'):
            if crops:
                s = dish_share(q)
                notes.append('dishes with a named crop %.2f (crops %.2f)' % (s, q))
            else:
                g = 1.0
                if re.search(r'\bteas?\b|juices|drinks|cordials|soups|egg dishes|fish dishes|meals bought|with fish', low):
                    g = 0.3
                    notes.append('dish kind 0.30')
                s = loc(S['cook_here'] if fam == 'F06' else S['eat_here'], 'cooked here' if fam == 'F06' else 'eaten or bought here') * g
        elif fam == 'F05':
            if reg:
                s = loc(0, '')
            elif re.search(r'neighbours', low):
                s = S['walk_hub']
                notes.append('all walks from or to the stop %.3f' % s)
            elif re.search(r'start or end|both ways', low) and not re.search(r'between \w+ and|from \w+ to', e):
                s = S['walk_hub']
                notes.append('all walks from or to the stop %.3f' % s)
            elif re.search(r'between|both ways', low):
                s = S['walk_pair']
                notes.append('one named road, both ways %.3f' % s)
            elif re.search(r'walks from [\w\' -]+ to ', low):
                s = S['walk_dest'] * (2 if ' or ' in low else 1)
                notes.append('named destination %.3f' % s)
            else:
                s = S['walk_from']
                notes.append('walks from (or to) the stop %.3f' % s)
        elif fam == 'F09':
            if reg:
                s = loc(0, '')
            elif 'walks' in low:
                s = S['walk_from']
                notes.append('rests on walks from the stop %.3f' % s)
            else:
                s = S['rest_here']
                notes.append('rest acts here %.2f' % s)
        elif fam == 'F11':
            s = loc(S['walk_from'], 'gathering here or on walks from here')
            if re.search(r'with a (rod|tide bucket)', low):
                s *= 0.3
                notes.append('one tool 0.30')
        elif fam == 'F14':
            if crops:
                s = q * 0.5
                notes.append('gifts of the named crop %.2f' % s)
            else:
                s = loc(S['acts_here'], "this stop's folk")
                if not (re.search(r'chats', low) and re.search(r'gifts', low)):
                    s *= 0.5
                    notes.append('chats or gifts only 0.50')
                if re.search(r'gifts of fruit', low):
                    s *= 0.5
                    notes.append('fruit 0.50')
        elif fam in ('F15', 'F16'):
            k = kind_factor(e)
            s = loc(S['acts_here'], 'acts here') * k
            if k < 1:
                notes.append('act kind %.2f' % k)
        elif fam in ('F18', 'F23'):
            if re.search(r'ends at', low):
                s = S['travel_to_town']
                notes.append('travels to this town %.2f' % s)
            elif reg:
                s = loc(0, '')
            else:
                s = S['travel_from']
                notes.append('travels that start here %.2f' % s)
                if re.search(r' to (maizehollow|the greatcanopy|the rainroot reaches)', low):
                    s *= 0.3
                    notes.append('one target 0.30')
        elif fam == 'F19':
            if reg:
                s = loc(0, '')
            elif re.search(r'walks from [\w\' -]+ to ', low):
                s = S['walk_dest'] * 2
                notes.append('named destinations %.3f' % s)
            else:
                s = S['walk_from']
                notes.append('walks from (or to) the stop %.3f' % s)
        elif fam == 'F20':
            if re.search(r'road (from|to)', low):
                s = S['lair_road']
                notes.append('one lair road %.2f of the fights' % s)
            else:
                s = loc(1.0, '')
        elif fam == 'F21':
            s = 1.0
            notes.append('the region\'s delve')
        elif fam == 'F22':
            s = loc(S['rest_here'], 'rest acts here')
        s *= cf
    if fam == 'F20':
        rel = 1.0 / base('max_hp', b)
    elif fam == 'F21':
        rel = 1.0 / 45
    elif fam == 'F22':
        rel = 1.0 / 4
    return s, rel, dom, notes


def fmt(x):
    if x >= 100:
        return '%.0f' % x
    if x >= 10:
        return '%.0f' % x
    if x >= 1:
        return '%.1f' % x
    if x >= 0.1:
        return '%.2f' % x
    return '%.3f' % x


def every(x):
    """Events a day -> 'once in N game days'."""
    if x <= 0:
        return 'never'
    if x >= 1:
        return '%s a game day' % fmt(x)
    return 'once in %.0f game days' % round(1 / x)


def number_row(p, b):
    s, rel, dom, notes = est_number(p, b)
    r = s * rel
    B = base(dom, b)
    fam = p.fam
    n = pct_of(p)
    felt = 0.0
    if fam == 'F01':
        amt, unit, vp = B * r, 'Petals', B * r
        txt = 'sales +%s%% on %.0f%% of them = +%s Petals/day' % (n, s * 100, fmt(amt))
    elif fam == 'F02':
        amt, vp = B * r, B * r
        txt = 'shop prices -%s%% on %.0f%% of the spend = %s Petals/day saved' % (n, s * 100, fmt(amt))
    elif fam == 'F03':
        amt = B * r
        vp = amt * vp_xp(b)
        txt = 'XP +%s%% on %.0f%% of %s = +%s XP/day' % (n, s * 100, 'all XP' if dom == 'xp' else 'the act XP', fmt(amt))
    elif fam == 'F04':
        amt = B * r
        vp = amt * VP_GXP
        txt = 'garden XP +%s%% on %.0f%% of the harvests = +%s garden XP/day' % (n, s * 100, fmt(amt))
    elif fam == 'F05':
        amt = B * r
        vp = amt * vp_min(b)
        txt = 'walk -%s%% on %.0f%% of the walking = %s min/day saved' % (n, s * 100, fmt(amt))
    elif fam == 'F06':
        amt = B * r
        vp = amt * vp_min(b)
        txt = 'pot time -%s%% on %.0f%% of the pots = %s min/day saved' % (n, s * 100, fmt(amt))
    elif fam == 'F07':
        amt = B * r
        vp = amt * VP_ENERGY
        txt = 'dish energy +%s%% on %.0f%% of the dishes = +%s energy/day' % (n, s * 100, fmt(amt))
    elif fam == 'F08':
        amt = B * r
        vp = amt * VP_BOOST_MIN
        txt = 'boosts +%s%% on %.0f%% of them = +%s boost min/day' % (n, s * 100, fmt(amt))
    elif fam == 'F09':
        amt = B * r
        vp = amt * VP_HP
        txt = 'healing +%s%% on %.0f%% of it = +%s health/day' % (n, s * 100, fmt(amt))
    elif fam == 'F10':
        amt = B * r
        felt = amt
        vp = amt * VP_ITEM
        txt = '+%s%% chance on %.0f%% of the harvests = +%s crops/day (%s)' % (n, s * 100, fmt(amt), every(amt))
    elif fam == 'F11':
        amt = B * r
        felt = amt
        vp = amt * VP_FIND
        txt = '+%s%% chance on %.0f%% of the finds = +%s finds/day (%s)' % (n, s * 100, fmt(amt), every(amt))
    elif fam == 'F12':
        amt = B * r
        vp = amt * VP_ENERGY
        txt = 'watering +%s%% longer on %.0f%% of the beds = %s waterings/day saved' % (n, s * 100, fmt(amt))
    elif fam == 'F13':
        amt = B * r
        felt = amt
        vp = amt * VP_SEED
        txt = '+%s%% seed chance on %.0f%% of the harvests = +%s seeds/day (%s)' % (n, s * 100, fmt(amt), every(amt))
    elif fam == 'F14':
        amt = B * r
        felt = amt
        vp = amt * VP_FRIEND
        txt = '%s%% chance on %.0f%% of the chats and gifts = +%s friendship/day (%s)' % (n, s * 100, fmt(amt), every(amt))
    elif fam == 'F15':
        amt = B * r
        vp = amt
        txt = 'act coins +%s%% on %.0f%% of the acts = +%s Petals/day' % (n, s * 100, fmt(amt))
    elif fam == 'F16':
        amt = B * r
        vp = amt * (14 + 4 * BAND_LEVEL[b])
        txt = 'checks +%s%% on %.0f%% of them = +%s wins/day (%s)' % (n, s * 100, fmt(amt), every(amt))
    elif fam == 'F17':
        amt = B * r
        vp = amt * VP_PEST
        txt = 'pests -%s%% on %.0f%% of the beds = %s pests/day fewer (%s)' % (n, s * 100, fmt(amt), every(amt))
    elif fam == 'F18':
        amt = B * TRAVEL_COST * r
        vp = amt
        txt = 'fast travel -%s%% on %.0f%% of the trips = %s Petals/day saved' % (n, s * 100, fmt(amt))
    elif fam == 'F19':
        amt = B * r
        felt = amt
        vp = amt * VP_SPOT
        txt = 'spot +%s%% on %.0f%% of the rolls = +%s finds/day (%s)' % (n, s * 100, fmt(amt), every(amt))
    elif fam == 'F20':
        felt = B * s
        amt = felt
        vp = amt * VP_HP
        txt = '+1 max health (%.1f%% of the bar) in %.0f%% of the fights = %s fights/day with it' % (rel * 100, s * 100, fmt(felt))
    elif fam == 'F21':
        felt = B * s
        amt = felt
        vp = amt * VP_STEP
        txt = '+1 torch step of 45 (2.2%%) on every floor there = +%s steps/day' % fmt(amt)
    elif fam == 'F22':
        felt = B * s
        amt = felt
        vp = amt * VP_ENERGY
        txt = '+1 energy (+25%%) on %.0f%% of the rest acts = +%s energy/day (%s)' % (s * 100, fmt(amt), every(felt))
    elif fam == 'F23':
        amt = B * r
        felt = amt
        vp = amt * VP_SEED
        txt = '+%s%% seed chance on %.0f%% of the fast travels = +%s seeds/day (%s)' % (n, s * 100, fmt(amt), every(amt))
    ok = r >= THRESH_R or (fam in ('F20', 'F21', 'F22') and felt >= THRESH_FELT)
    return dict(share=s, r=r, felt=felt, boost=txt, vp=vp, ok=ok, notes='; '.join(notes))


DAILY_RULES = [   # (regex on the effect, probability the trigger fires on a game day in the region, note); V = a visit day
    (r'first weeding', lambda b: 0.6, 'weeding on 60% of days'),
    (r'first watering', lambda b: 1.0, 'every day'),
    (r'first fast travel', lambda b: min(1.0, base('travels', b)), 'fast-travel days'),
    (r'first seed you plant', lambda b: 0.9, 'planting days'),
    (r'failed stop check', lambda b: 0.9, '6 checks a day, 35% fail'),
    (r'walking staff', lambda b: 1.0, 'every walking day'),
    (r'fishing rod', lambda b: 0.6, 'rod days'),
    (r'first food you buy in a shop', lambda b: 0.5, 'food bought on half the days'),
    (r'road walk turns up a coin', lambda b: 0.25, '5 walks x 1 in 20'),
    (r'(rock pick|bug net)', lambda b: V * 0.5, 'visit day x tool used on that walk 0.5'),
    (r'lore check at', lambda b: 0.1, 'wonder days'),
    (r'torch step', lambda b: base('floors', b) / 2 if base('floors', b) < 1 else 0.5, 'delve days'),
    (r'lost (contest|game)|contest .*(tried|played) again', lambda b: V * 0.6 * 0.35, 'visit day x contest played 0.6 x lost 0.35'),
    (r'craft act .*fails', lambda b: V * 0.6 * 0.35, 'visit day x craft act 0.6 x failed 0.35'),
    (r'first tea you brew in', lambda b: 0.5, 'tea days'),
    (r'first festival act', lambda b: 1.0, 'region-wide (festival share in the conditions)'),
    (r'first act you do each day in [A-Z]|first act each day in [A-Z]', lambda b: 1.0, 'region-wide'),
    (r'first (seed|tool).*buy at', lambda b: V * 0.4, 'visit day x seed bought there 0.4'),
    (r'first (fish|dish) you sell', lambda b: V * 0.25, 'visit day x that good sold there 0.25'),
    (r'first (thing you sell|sale)', lambda b: V * 0.9, 'visit day x something sold there 0.9'),
    (r'first time you gather at|gather at', lambda b: V * 0.6, 'visit day x gather here 0.6'),
    (r'first fish you find on a walk', lambda b: V * 0.3, 'visit day x a fish found 0.3'),
    (r'first find on a walk|first thing you find on a walk', lambda b: V * 0.9, 'visit day x a find 0.9'),
    (r'finds nothing', lambda b: V * 0.5, 'visit day x an empty find 0.5'),
    (r'gift', lambda b: V * 0.5, 'visit day x a gift given there 0.5'),
    (r'dish cooked at|first dish you (eat|cook) at', lambda b: V * 0.5, 'visit day x a dish there 0.5'),
    (r'first rest act', lambda b: V * 0.9, 'visit day x a rest act there 0.9'),
    (r'first (lore|craft|power|tend|cook or craft|check|contest) (act|you try)', lambda b: V * 0.9, 'visit day x that act done 0.9'),
    (r'first act', lambda b: V * 0.9, 'visit day x an act there 0.9'),
    (r'after a rest act', lambda b: V * 0.9, 'visit day x a rest act there 0.9'),
    (r'walk of 4 sections or more', lambda b: V * 0.4, 'visit day x a long walk 0.4'),
    (r'first walk (each day )?(from|between) [\w\' -]+ (to|and) ', lambda b: V / 3, 'visit day x that one road of three'),
    (r'first walk', lambda b: V, 'visit day'),
    (r'first visit', lambda b: V, 'visit day'),
]


def daily_row(p, b):
    e, low = p.effect, p.effect.lower()
    cf, notes = cond_factor(e)
    prob, why = None, ''
    crops = A.crops_in(e, p.region) if re.search(r'harvest|cook with', low) else set()
    if crops and 'harvest' in low:
        q = crop_share(p.region, crops)
        prob = 1 - (1 - q) ** base('harvests', b)
        why = 'a harvest of the named crop that day (crops %.2f of the beds)' % q
    elif crops:
        q = dish_share(crop_share(p.region, crops))
        prob = 1 - (1 - q) ** base('dishes', b)
        why = 'a dish with the named crop that day'
    else:
        for rx, fn, w in DAILY_RULES:
            if re.search(rx, low):
                prob, why = fn(b), w
                break
    if prob is None:
        prob, why = V, 'visit day (default)'
    felt = prob * cf
    notes.insert(0, why)
    units = 2 if re.search(r'\btwo\b|\b2 (coins|energy)\b', low) or re.match(r'\+?2\b', p.size.strip()) else 1
    fam = p.fam
    if fam == 'A1':
        vp1 = VP_ENERGY
        what = '1 energy'
    elif fam == 'A2':
        if re.search(r'seed', low):
            vp1, what = VP_SEED, '1 seed'
        elif re.search(r'check|contest|game', low):
            vp1, what = 0.65 * (14 + 4 * BAND_LEVEL[b]), 'one more try at an act reward'
        elif re.search(r'ingredient|gift', low):
            vp1, what = VP_ITEM, '1 item kept'
        elif re.search(r'torch', low):
            vp1, what = VP_STEP, '1 torch step'
        elif re.search(r'finds nothing|look once more', low):
            vp1, what = 0.5 * VP_FIND, 'a second look (half a find)'
        else:
            vp1, what = 2.0, '1 tool wear'
    elif fam == 'A3':
        if re.search(r'energy', low) and not re.search(r'`', e):
            vp1, what = VP_ENERGY * units, '%d energy' % units
        elif re.search(r'heals? 1 health', low):
            vp1, what = VP_HP, '1 health'
        else:
            vp1, what = VP_ITEM * units, '%d item%s' % (units, 's' if units > 1 else '')
    else:
        m = re.search(r'(\d+)', p.size)
        c = int(m.group(1)) if m else 1
        vp1, what = float(c), '%d coin%s' % (c, 's' if c > 1 else '')
    vp = felt * vp1
    txt = 'daily: %s on %.0f%% of days (%s) = %s VP/day' % (what, felt * 100, every(felt), fmt(vp))
    return dict(share=felt, r=0.0, felt=felt, boost=txt, vp=vp, ok=felt >= THRESH_FELT, notes='; '.join(notes))


def flag_row(p, b):
    page, _ = A.ui_of(p)
    if p.fam == 'A5':
        return dict(share=1.0, r=0.0, felt=1.0, boost='info: saves a look-up or a wrong guess on the %s page' % page, vp=0.0, ok=True,
                    notes='flag: no number; meaningful because it saves a decision or a tap')
    return dict(share=1.0, r=0.0, felt=1.0, boost='looks: seen on the %s page' % page, vp=0.0, ok=True,
                notes='flag: looks only, outside the boost model by design')


def estimate_all():
    rows = []
    for p in A.parse_all():
        b = REGION_BAND[p.region]
        if p.fam in A.FAM:
            d = number_row(p, b)
        elif p.fam in A.DAILY:
            d = daily_row(p, b)
        else:
            d = flag_row(p, b)
        scope = {'W': 'world', 'P': 'place', 'D': 'daily', 'F': 'flag'}[p.cls]
        if p.cls == 'P':
            scope = 'crops' if A.crop_scoped(p) else ('region' if is_region(p) else 'stop')
        d.update(id='%s:%s:%s' % (p.region, p.stop, p.bar), name=p.name, fam=p.fam, scope=scope, size=p.size, effect=p.effect,
                 band=BANDS[b], status='ok' if d['ok'] else 'LOW', perk=p)
        rows.append(d)
    return rows


COLS = ['id', 'name', 'family', 'scope', 'size', 'band', 'share_of_domain', 'pct_of_domain', 'felt_per_day', 'boost_per_game_day',
        'value_points', 'status', 'effect', 'model_notes']


def write_csv(rows, path):
    with open(path, 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(COLS)
        for d in rows:
            w.writerow([d['id'], d['name'], d['fam'], d['scope'], d['size'], d['band'], '%.3f' % d['share'], '%.2f' % (d['r'] * 100),
                        '%.3f' % d['felt'], d['boost'], '%.2f' % d['vp'], d['status'], d['effect'], d['notes']])


def read_csv(path):
    with open(path, encoding='utf-8') as f:
        return {r['id']: r for r in csv.DictReader(f)}


def summary(rows):
    out = []
    fams = list(A.FAM) + list(A.DAILY) + list(A.FLAGS)
    lab = {f: A.FAM[f][0] for f in A.FAM}
    lab.update({'A1': 'first action cheaper', 'A2': 'something comes back', 'A3': 'daily gift', 'A4': 'day coins', 'A5': 'info flag', 'A6': 'looks flag'})
    out.append('| Family | Perks | ok | LOW | Median boost (% of the day\'s domain, or felt events a day) | Median VP/day |')
    out.append('|---|---|---|---|---|---|')
    for f in fams:
        rs = [d for d in rows if d['fam'] == f]
        if not rs:
            continue
        low = sum(1 for d in rs if d['status'] == 'LOW')
        vals = sorted((d['r'] * 100 if f in A.FAM and f not in ('F20', 'F21', 'F22') else d['felt']) for d in rs)
        med = vals[len(vals) // 2]
        vps = sorted(d['vp'] for d in rs)
        unit = '%' if f in A.FAM and f not in ('F20', 'F21', 'F22') else ' a day'
        out.append('| %s %s | %d | %d | %d | %s%s | %s |' % (f, lab[f], len(rs), len(rs) - low, low, fmt(med) if f not in A.FLAGS else '-',
                                                          unit if f not in A.FLAGS else '', fmt(vps[len(vps) // 2]) if f not in A.FLAGS else '-'))
    tot_low = sum(1 for d in rows if d['status'] == 'LOW')
    out.append('| **All** | **%d** | **%d** | **%d** | | |' % (len(rows), len(rows) - tot_low, tot_low))
    return out


def histogram(rows):
    bins = [(0, 0.1), (0.1, 0.25), (0.25, 0.5), (0.5, 0.95), (0.95, 1.5), (1.5, 3), (3, 1000)]
    num = [d for d in rows if d['fam'] in A.FAM]
    out = ['Number perks (%d), boost as %% of the day\'s activity in the perk\'s own domain:' % len(num), '', '```']
    for lo, hi in bins:
        n = sum(1 for d in num if lo <= d['r'] * 100 < hi)
        out.append('%5s to %-5s %% | %-60s %d' % (lo, hi if hi < 1000 else 'more', '#' * int(round(n / 4.0)), n))
    out.append('```')
    day = [d for d in rows if d['fam'] in A.DAILY]
    out += ['', 'Daily charges (%d), how often the charge is used:' % len(day), '', '```']
    for lo, hi, t in ((0, 0.1, 'less than once in 10 days'), (0.1, 0.25, 'once in 4 to 10 days'), (0.25, 0.5, 'once in 2 to 4 days'),
                      (0.5, 0.95, 'every other day or more'), (0.95, 9, 'every day')):
        n = sum(1 for d in day if lo <= d['felt'] < hi)
        out.append('%-28s | %-40s %d' % (t, '#' * int(round(n / 2.0)), n))
    out.append('```')
    return out


def main():
    rows = estimate_all()
    write_csv(rows, F_CSV)
    if '--snapshot' in sys.argv:
        write_csv(rows, F_BEFORE)
    print('\n'.join(summary(rows)))
    print()
    print('\n'.join(histogram(rows)))
    if '--list-low' in sys.argv:
        for d in rows:
            if d['status'] == 'LOW':
                print('%-34s %-4s %-6s %-7s r=%.2f%% felt=%.2f | %s | %s' % (d['id'], d['fam'], d['scope'], d['size'], d['r'] * 100, d['felt'], d['effect'], d['notes']))
    if '--md' in sys.argv:
        import tools_perk_impact_md
        tools_perk_impact_md.write(rows)


if __name__ == '__main__':
    main()
