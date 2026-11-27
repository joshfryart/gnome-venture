#!/usr/bin/env python3
"""
Simulation of the Standing and Petal economy proposed in claude/PROPOSAL-HOLLOW-MASTER.md (sections 3, 4, 7, 8, 14).

Read-only: reads game data files and the proposal act-to-bar table, writes nothing in game/. Output:
    claude/proposal-sim-standing.md       (written by hand from this script's printout)
    claude/sim-standing-out/*.csv         (written by this script)

Run:  python3 claude/tools_sim_standing.py [--runs 400] [--seed 7] [--csv-dir claude/sim-standing-out]

Every number the model takes from the game is read from the data files or copied from the code with its source in a comment.
Every number that is NOT in the game or the proposal is in ASSUME below, with a one-line reason. Change it there and re-run.
"""
import argparse, csv, math, os, random, statistics, zlib
from collections import defaultdict, Counter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
DATA = os.path.join(ROOT, 'game', 'includes', 'data')

# ----------------------------------------------------------------------------------------------------------------------------
# Game constants (defaults from game/includes/functions.php settings_schema() and the code named)
# ----------------------------------------------------------------------------------------------------------------------------
G = dict(
    xp_steep_from=10, xp_steep_percent=15, xp_action_scale_percent=9,   # functions.php:637-640, gnome.php:289 xp_for_level
    max_energy=10, energy_per_level=5,                                   # functions.php:631/406, gnome.php:272 max_energy
    nap_energy_pct=40, nap_minutes=120,                                  # game_clock.php:141 game_nap
    awake_minutes=960,                                                   # 06:00-22:00, game_clock.php header
    grow_days=[1, 2, 3, 5, 7, 10],                                       # game_clock.php:205 grow_days_by_tier
    price_base_pct=60, sell_mult={'C': 1.00, 'U': 1.30, 'R': 1.80, 'L': 2.50},  # market100.php:295, functions.php:632-634
    seed_save_chance=60,                                                 # functions.php:628
    harvest_energy={'C': 1, 'U': 2, 'L': 3},                             # functions.php:729 harvest_energy_tiers 1,2,3
    till=1, plant=1, water=1,                                            # garden_logic.php:26 ENERGY_COST
    starting_plot=4, bed_add_cost=200, bed_add_growth_pct=20, bed_add_planks=2,   # functions.php:397-401, garden_logic.php:1712
    stop_core=3, stop_extra=2, stop_min=15,                              # functions.php:436-437, game_clock.php:611 'stop' => 15
    travel_min_per_section=10,                                           # game_clock.php:611
    repair_min=480,                                                      # game_clock.php:614 'repair' (master 1.3: a build stage costs 480 game min)
    stop_adopt_cost=300,                                                 # functions.php:444
    tier_xp=20,                                                          # stop_adopt.php:323 (+20 x tier XP)
    welcome_coins=(6, 8),                                                # stop_adopt.php:337 coins = 6 + 8 x tier
    regular_acts=3, local_acts=20,                                       # stop_living.php:23 STOP_FAMILIARITY
    cook_xp_meal=5, cook_energy_meal=1, meal_energy=11,                  # functions.php:665/677, recipes.txt (meals give 11)
    dish_factor_meal=1.6,                                                # catalog.php:634 DISH_PRICE_FACTOR
    creature_xp_mult={'small': 0.8, 'medium': 1.1, 'large': 1.6, 'boss': 2.4},   # adventure_data.php:423 (xp = level x 6 x mult)
    petals_K={'small': 0.5, 'medium': 1.0, 'large': 1.8, 'boss': 4.0},   # claude/creature-pass/SPEC.md 5.2
    regrow_xp_pct=60, life_end_yield=80,                                 # functions.php:636/739 regrow_xp_percent, life_end_yield
    life_days={'tree': 60, 'nut': 60, 'fruit': 45},                      # functions.php:736-738 (others 30)
    job_streak_every=7, job_streak_bonus=300, job_xp_monthly_pct=40, job_month_days=28,   # functions.php:451-452/778, jobs.php:36
)
# Standing (master section 4)
W_LIT, W_RAISED, W_HEARTH, W_REPAIR, W_PLACES = 14, 10, 6, 15, 10
W_FRIEND, W_THREADS, W_ERRANDS, W_GROWN, W_BED, W_FLOWER, W_DELVE, W_LAIR, W_PAGES = 5, 5, 5, 5, 6, 4, 5, 5, 5
HEARTH_PTS = {0: 0, 1: 1, 2: 2, 3: 4, 4: 6}

# ----------------------------------------------------------------------------------------------------------------------------
# Assumptions (not in the game data or the proposal). Each is a model choice; change and re-run.
# ----------------------------------------------------------------------------------------------------------------------------
ASSUME = dict(
    naps_per_day=1,             # one nap (120 min, +40% energy) a game day; the 50% real-time trickle is ignored
    stops_per_day=(3, 4),       # master A1: a touring day covers 3-4 stops
    acts_per_stop=5,            # master A1: 5 acts per stop visit
    walk_min_per_stop=30,       # master A1: about 30 min walking between neighbours
    stat_mod=1,                 # gnome stat modifier on stop checks (stats 10-13 early; mod = floor((stat-10)/2))
    craft_has_inputs=0.5,       # share of offered craft acts the gnome can do (needs the inputs in the satchel)
    power_win=0.35, power_near=0.35,   # ring toss style acts: exact / near (pays 35%), stops.php:886-888
    contest_win=1 / 3,          # rock-paper-scissors acts (draw counted as a loss for points and pay)
    yield_annual=2.0, yield_tree=3.5, regrow_yield=0.75,   # master A3 (1-3 -> 2, 2-5 -> 3.5, regrowth 75%)
    seed_cost_share=0.1,        # effective seed cost per planting = 10% of seed price (tests/balance_sim.php: seed save 60% x 1.5)
    waterings_per_cycle=lambda s: max(1, math.ceil(s / 2)),   # a dry day is owed not lost (game_clock.php:233); typical player waters every other day
    beds_by_level={1: 16, 5: 20, 8: 24, 11: 28, 13: 32},       # beds bought when affordable, at most this many by level (garden level gate not modelled)
    money_mode='basket',        # 'basket': spare beds rotate over the 7 buyable Maplewold crops (a sane mix); 'best': all on the best one
    money_basket=['soybean', 'kidney-bean', 'lentil', 'oats', 'raspberry', 'hops', 'apple'],
    meal_crops=5,               # crops per home-cooked meal (recipes.txt meals use 4-6 crops)
    eat_for_energy=True,        # an energy deficit is covered by cooking and eating own meals (11 energy each, no cap in eat code)
    gather_items_per_try=1.75,  # gathering.php:127 2-3 items per success (clock on); success rate assumed 70%
    resin_items_per_try=0.6,    # pine resin is uncommon: assumed 0.6 per try
    stone_energy=4.7, stone_min=32,   # 3 flint (1.7 tries x 1 E) + craft 3 E (crafts.txt building-stone-flint), 10 + 15 min
    plank_energy=2.0, plank_min=16,   # log -> 4 chips (1 E), 3 chips + 1 resin -> 3 planks (3 E), crafts.txt
    rope_buy=20, beeswax_buy=36,       # no shop sells them; player market at ~2x base (rebuild.php BUILDING_ITEMS 10 / 18)
    find_min=90, escort_min=90, errand_min=120, deliver_min=60, jigsaw_days=1,
    friend_town_days=(6, 12),   # master A5: 6-12 game days of chat and gifts
    chat_day_prob=0.7,          # share of game days the gnome chats or gifts in town
    thread_stop_any=True,       # every stop offers a thread to a Regular ('any' threads exist: hen, lantern, stranger, well)
    explore_find_prob=0.12,     # chance a day of spare time turns up one optional place (delve, peak) in an open zone
    fights_per_tour_day=2.0,    # fighter: creature fights met and fought on a touring day (non-fighter flees / walks round)
    fight_min=20,
    delve_level=9, delve_days=1,       # fighter clears Beaverdam Tunnels at Lv 9+ (one day of time)
    owl_fight_level=14,         # fighter beats the Owl (lair, Lv 15) at Lv 14+
    jobs_on=False,              # job board income (real data, follows game days with the clock on: jobs.php:34); reported apart
    job_done={'daily': 0.7, 'weekly': 0.6, 'monthly': 0.4},  # share of offers finished
    job_cost_share=0.3,         # share of a job's pay spent as crops / dishes handed in
    level_hint_slack=2,         # the gnome opens chapter k when level >= zone floor - 2 (level is a hint, not a lock)
    places_total=24,            # 12 villages + 12 off-road places (Sugar Shack, Stump, Lighthouse, Ferry Landing, Heron Stilt,
                                #   Dam Debt, Tunnels, Aurora Camp, Keeper's Hut, Cairnback Pass, Hollow Peak, Owl's Den); secrets add to both
    pages_rule='mean',          # pages row = 5 x mean(places share, crops share, folk share): its count is not defined in the proposal
    opt_pursuit=(0.25, 1.0),    # per-run share of optional side content the gnome does before looking at the meter
    meter_from='M7',            # 'M7': the gnome reads Wren's meter once M6 is done and M7 is under way; 'main': only when the main line is done
)

# ----------------------------------------------------------------------------------------------------------------------------
# Level curve
# ----------------------------------------------------------------------------------------------------------------------------
def xp_for_level(L):   # gnome.php:289; users.xp is a running total (add_xp compares the total to xp_for_level(level+1))
    base = 50 * L * (L - 1)
    over = max(0, L - G['xp_steep_from'])
    return int(round(base * (1 + over * G['xp_steep_percent'] / 100)))

def level_of(xp):
    L = 1
    while xp >= xp_for_level(L + 1):
        L += 1
    return L

def action_xp(n, L):   # progression.php:171 action_xp_scale (harvest, cook, craft, fight)
    if n <= 0:
        return n
    over = max(0, L - G['xp_steep_from'])
    return max(1, int(round(n * (1 + over * G['xp_action_scale_percent'] / 100))))

def max_energy(L):
    return G['max_energy'] + G['energy_per_level'] * (L - 1)

def day_energy(L):
    return max_energy(L) * (1 + ASSUME['naps_per_day'] * G['nap_energy_pct'] / 100)

def day_minutes():
    return G['awake_minutes'] - ASSUME['naps_per_day'] * G['nap_minutes']

# ----------------------------------------------------------------------------------------------------------------------------
# Data loaders
# ----------------------------------------------------------------------------------------------------------------------------
def rows(path, minf=1):
    out = []
    with open(path, encoding='utf-8') as f:
        for line in f:
            line = line.rstrip('\n')
            if not line.strip() or line.lstrip().startswith('#'):
                continue
            p = [x.strip() for x in line.split('|')]
            if len(p) >= minf:
                out.append(p)
    return out

COMMON_CROPS = ['tomato', 'potato', 'onion', 'garlic', 'carrot', 'cabbage', 'lettuce', 'radish', 'spinach', 'cucumber', 'pumpkin',
                'green-bean', 'pea', 'beet', 'turnip', 'kale', 'basil', 'mint', 'parsley', 'coriander', 'dill', 'sunflower', 'strawberry',
                'white-clover', 'winter-rye', 'crimson-clover', 'celery', 'cauliflower', 'broccoli', 'fennel', 'horseradish', 'rosemary',
                'thyme']   # catalog.php:12 (first lines; the rest are herbs not grown for sale here)

def load_crops():
    """catalog.php:179-252: rarity, seed and produce price, xp per harvest, tree-like yield; sell = floor(base x 60%) x rarity mult."""
    regions = defaultdict(dict)   # slug -> {region: tier}
    for p in rows(os.path.join(DATA, 'region_crops.txt'), 3):
        for s in p[2].split(','):
            s = s.strip()
            if s:
                regions[s][p[0]] = p[1]
    crops = {}
    for p in rows(os.path.join(DATA, 'crops.txt'), 6):
        slug, name, kind, tier, per = p[0], p[1], p[2], int(p[3]), int(p[4])
        crops[slug] = dict(slug=slug, name=name, kind=kind, tier=tier, per=per, flower=False)
    for p in rows(os.path.join(DATA, 'flowers.txt'), 6):
        crops['flower:' + p[0]] = dict(slug=p[0], name=p[1], kind='flower', tier=int(p[3]), per=int(p[4]), flower=True, region=p[2])
    for key, c in crops.items():
        t = max(1, min(6, c['tier']))
        rl = regions.get(c['slug'], {}) if not c['flower'] else {}
        n = len(rl)
        common = c['slug'] in COMMON_CROPS
        treasure = (not c['flower']) and 'treasure' in rl.values()
        if c['flower']:
            r = min(90, 15 + t * 9)
        elif common:
            r = 2 + t
        elif treasure:
            r = max(60, min(95, 85 + t * 2))
        elif n > 0:
            r = max(10, min(75, 50 + t * 5 - n * 5))
        else:
            r = 40 + t * 5
        c['rarity'] = r
        c['seed_price'] = int(round(4 + t * 4 + r * 0.6 + (t * 6 if c['per'] else 0)))
        c['base_price'] = int(round(3 + t * 3 + r * 0.4 + (6 if c['flower'] else 0)))
        c['tree'] = c['kind'] in ('tree', 'nut') or (c['per'] and t >= 6)
        c['xp'] = t * t * 2 + r // 10   # catalog.php:252
        c['sleeps'] = G['grow_days'][t - 1]
        c['regrow_sleeps'] = math.ceil(c['sleeps'] / 3) if c['per'] else 0   # regrow_minutes = grow/3 (catalog.php:247)
        c['regions'] = rl
        c['na_tier'] = rl.get('NA')
        # sell tier (items.php:48 item_rarity): staple C, uncommon/flower U, treasure L
        rt = c['na_tier'] or (list(rl.values())[0] if rl else ('flower' if c['flower'] else 'staple'))
        c['letter'] = {'staple': 'C', 'flower': 'U', 'uncommon': 'U', 'treasure': 'L'}.get(rt, 'C')
        if c['flower']:
            c['letter'] = 'U'
        c['sell'] = max(1, int(round(max(1, (c['base_price'] * G['price_base_pct']) // 100) * G['sell_mult'][c['letter']])))
        c['harvest_e'] = G['harvest_energy']['U' if (c['flower'] or c['letter'] == 'U') else ('L' if c['letter'] == 'L' else 'C')]
    return crops, regions

def crop_rates(c, L=1):
    """Per bed and game day, steady state: Petals (sold raw), energy, XP. Perennial: regrowth every regrow_sleeps at 75% yield."""
    y = ASSUME['yield_tree'] if c['tree'] else ASSUME['yield_annual']
    if c['per']:
        cyc = c['regrow_sleeps']
        y *= ASSUME['regrow_yield']
        e = c['harvest_e'] + ASSUME['waterings_per_cycle'](cyc) * G['water']
        seed = 0
    else:
        cyc = c['sleeps']
        e = G['till'] + G['plant'] + c['harvest_e'] + ASSUME['waterings_per_cycle'](cyc) * G['water']
        seed = c['seed_price'] * ASSUME['seed_cost_share']
    xp = action_xp(c['xp'], L) * (G['regrow_xp_pct'] / 100 if c['per'] else 1)
    if c['per']:
        y *= (100 + G['life_end_yield']) / 200   # harvests shrink to 80% by the end of a perennial's life (garden_logic.php:807)
    return dict(petals=(y * c['sell'] - seed) / cyc, energy=e / cyc, xp=xp / cyc, units=y / cyc, cyc=cyc)

def load_acts():
    """All stop acts (stop_acts.txt, _waves, _regional, _living): slug -> row dict."""
    acts = {}
    files = [('stop_acts.txt', False), ('stop_acts_waves.txt', True), ('stop_acts_regional.txt', True), ('stop_acts_living.txt', True)]
    for fn, has_region in files:
        for p in rows(os.path.join(DATA, fn), 12):
            p = p + [''] * (15 - len(p))
            a = dict(slug=p[0], name=p[1], types=[t.strip() for t in p[3].split(',')], cond=p[4] if p[4] != '-' else '',
                     tier=int(p[5] or 0), kind=p[6], energy=int(p[7] or 0), spec=p[8], win=p[9] if p[9] != '-' else '',
                     lose=p[10] if p[10] != '-' else '', region=[r.strip() for r in p[14].split(',') if r.strip()] if has_region else [])
            acts[a['slug']] = a
    needs = {}
    for p in rows(os.path.join(DATA, 'stop_act_state.txt'), 2):
        if p[1] and p[1] != '-':
            needs[p[0]] = p[1]
    return acts, needs

def load_bars():
    """claude/proposal-stop-act-bars.txt: slug | type | first | second | base. '*' rows hold for every type."""
    bars = {}
    with open(os.path.join(HERE, 'proposal-stop-act-bars.txt'), encoding='utf-8') as f:
        for line in f:
            if line.startswith('#') or '|' not in line:
                continue
            p = [x.strip() for x in line.split('|')]
            if len(p) != 5:
                continue
            bars[(p[0], p[1])] = (p[2], None if p[3] == '-' else p[3], int(p[4]))
    return bars

def bar_of(bars, slug, typ):
    return bars.get((slug, typ)) or bars.get((slug, '*'))

def parse_reward(spec, lvl):
    """stops.php:670 stop_rewards: c=base:perLevel, xp=base:perLevel at the stop's level (region band floor); item=slug:qty@chance."""
    out = dict(c=0.0, xp=0.0, en=0.0, items=Counter(), crop=0.0)
    for tok in [t.strip() for t in spec.split(',') if t.strip()]:
        ch = 1.0
        if '@' in tok:
            tok, c = tok.split('@', 1)
            ch = int(c) / 100
        if '=' not in tok:
            continue
        k, v = tok.split('=', 1)
        p = v.split(':')
        if k in ('c', 'xp'):
            out[k] += ch * (int(p[0]) + int(p[1] if len(p) > 1 and p[1] else 0) * lvl)
        elif k == 'en':
            out['en'] += ch * int(p[0])
        elif k == 'item':
            out['items'][p[0]] += ch * (int(p[1]) if len(p) > 1 else 1)
        elif k == 'crop':
            out['crop'] += ch * int(p[0])
    return out

def act_outcome_probs(a):
    """[(p, pays_win_share, W for bar points)]. Win share 1 = win spec, 0 = lose spec, 0.35 = near (power)."""
    k = a['kind']
    if k == 'check':
        best = 0
        for opt in a['spec'].split(';'):
            q = opt.split(':')
            if len(q) < 2:
                continue
            try:
                dc = int(q[1])
            except ValueError:
                continue
            ch = 100 if dc <= 0 else max(5, min(95, (21 - (dc - ASSUME['stat_mod'])) * 5))   # stops.php:742 stop_check
            best = max(best, ch)
        pw = best / 100 if best else 1.0
        return [(pw, 1, 1.0), (1 - pw, 0, 0.5)]
    if k == 'pick':
        n = 3
        for part in a['spec'].split(';'):
            if part.startswith('n='):
                n = int(part[2:])
        return [(1 / n, 1, 1.0), (1 - 1 / n, 0, 0.5)]
    if k == 'power':
        w, nr = ASSUME['power_win'], ASSUME['power_near']
        return [(w, 1, 1.0), (nr, 0.35, 0.5), (1 - w - nr, 0, 0.5)]
    if k == 'contest':
        w = ASSUME['contest_win']
        return [(w, 1, 1.0), (1 - w, 0, 0.5)]
    return [(1.0, 1, 1.0)]   # no dice: craft, collect, tend, lore, gossip, rest, buy, snack, swap, seedswap, thread

def act_cost_coins(a):
    if a['kind'] == 'rest':
        for part in a['spec'].split(';'):
            if part.startswith('cost='):
                return int(part[5:])
    if a['kind'] == 'buy':
        p = a['spec'].split(':')
        if len(p) >= 3 and p[2].isdigit():
            return int(p[2])
    return 0

# ----------------------------------------------------------------------------------------------------------------------------
# Stops of the Maplewold roads (master 2.3, 7.5) and of Maizehollow (proposal-stop-perks-regions-A.md 2)
# ----------------------------------------------------------------------------------------------------------------------------
NA_STOPS = [  # name, type, zone, kind (town / village / haven / border), region of the stop
    ('Maplewold Market', 'market', 1, 'town', 'NA'), ('Poppyburrow', 'inn', 1, 'village', 'NA'), ('Honeybrook', 'herb', 1, 'village', 'NA'),
    ('Cloverholt', 'mill', 1, 'village', 'NA'), ('Acornby', 'camp', 2, 'village', 'NA'), ('Birchhollow', 'workshop', 2, 'village', 'NA'),
    ('Mossgate', 'shrine', 2, 'village', 'NA'), ('Shellhollow', 'jetty', 3, 'village', 'NA'), ('Pebblestead', 'ferry', 3, 'village', 'NA'),
    ('Cattailmere', 'herb', 4, 'village', 'NA'), ('Iciclecrest', 'tower', 5, 'village', 'NA'), ('Snowcombe', 'spring', 5, 'village', 'NA'),
    ('Granitegate', 'tower', 6, 'village', 'NA'), ('The Sugar Shack', 'orchard', 1, 'haven', 'NA'), ('Aurora Camp', 'camp', 5, 'haven', 'NA'),
    ('Larkbrook', 'inn', 1, 'border', 'CA'), ('Windbottom', 'tower', 5, 'border', 'NWE'), ('Honeythorpe', 'orchard', 6, 'border', 'EA'),
]
CA_STOPS = [
    ('Maizehollow Market', 'market', 1, 'town', 'CA'), ('Poppynook', 'mill', 1, 'village', 'CA'), ('Meadowmere', 'inn', 1, 'village', 'CA'),
    ('Jadedell', 'shrine', 2, 'village', 'CA'), ('Frondthorpe', 'orchard', 2, 'village', 'CA'), ('Orchiddell', 'herb', 2, 'village', 'CA'),
    ('Saffroncrest', 'tower', 3, 'village', 'CA'), ('Scorchburrow', 'camp', 3, 'village', 'CA'), ('Stonethorpe', 'spring', 4, 'village', 'CA'),
    ('Flintcove', 'workshop', 4, 'village', 'CA'), ('Market of a Thousand Chilies', 'market', 1, 'haven', 'CA'), ('Larkbrook', 'inn', 1, 'border', 'CA'),
]
ZONE_FLOOR_NA = {1: 1, 2: 4, 3: 7, 4: 8, 5: 11, 6: 12}   # master 2.3
BAND_FLOOR = {'NA': 1, 'CA': 15, 'NWE': 15, 'EA': 45}     # master 2.1: REGION_LEVELS = band floor; stops.php:619 stop_level = region min level

ANSWER = {'mend_board': 'Repairs', 'tidy_yard': 'Repairs', 'fill_shelf': 'Larder', 'hang_lanterns': 'Cheer'}
BARS3 = ('Repairs', 'Larder', 'Cheer')

def crc(s):
    return zlib.crc32(s.encode('utf-8'))

class StopModel:
    """The act pool of one stop (stops.php:538 stop_pool), points (master 7.3) and pay (stops.php:670)."""
    def __init__(self, name, typ, region, acts, needs, bars, tier=0):
        self.name, self.typ, self.region, self.tier = name, typ, region, tier
        self.lvl = BAND_FLOOR.get(region, 1)
        plain, special, upgrades = [], [], []
        for a in acts.values():
            ts = a['types']
            explicit = typ in ts
            if not explicit and 'any' not in ts:
                continue
            if a['region']:
                if region not in a['region']:
                    continue
                explicit = True
            if a['slug'] in ANSWER or a['slug'] == 'host_table':
                continue
            if a['tier'] > 0:
                upgrades.append(a)
                continue
            if a['cond']:
                special.append(a)
                continue
            if needs.get(a['slug'], '').startswith('fam'):
                continue
            plain.append(dict(a, explicit=explicit))
        plain.sort(key=lambda a: (0 if a['explicit'] else 1, crc('core|' + name + '|' + a['slug'])))
        self.core = self._diverse(plain, G['stop_core'], [])
        used = {a['slug'] for a in self.core}
        self.rest = [a for a in plain if a['slug'] not in used]
        self.special = special
        self.upgrades = upgrades
        self.bars = bars
        self.cache = {}

    @staticmethod
    def _diverse(lst, n, kinds):
        out, left, kinds = [], list(lst), list(kinds)
        while len(out) < n and left:
            pick = next((i for i, a in enumerate(left) if a['kind'] not in kinds), None)
            if pick is None:
                kinds, pick = [], 0
            a = left.pop(pick)
            out.append(a)
            kinds.append(a['kind'])
        return out

    def cond_prob(self, cond):
        """Chance a 'when' condition holds on a random visit: dp 4 values, se 4, we 9 (uniform; the real weather is not)."""
        p = 1.0
        for part in cond.split('/'):
            if '=' not in part:
                continue
            k, v = part.split('=', 1)
            n = len([x for x in v.split(',') if x])
            p *= min(1.0, n / {'dp': 4, 'se': 4, 'we': 9}.get(k, 4))
        return p

    def offer(self, day, rng, unfilled, thread_ok, lit_tier):
        """Offer order as stop_pool: specials (<=3), answer acts (<=2, bars not full), thread, core 3, extras (2 - answers)."""
        sp = [a for a in self.special if rng.random() < self.cond_prob(a['cond'])]
        rng.shuffle(sp)
        sp = sp[:3]
        ans = [s for s, b in ANSWER.items() if b in unfilled]
        ans.sort(key=lambda s: crc('ans|%d|%s|%s' % (day, self.name, s)))
        ans = ans[:2]
        rest = sorted(self.rest, key=lambda a: crc('day|%d|%s|%s' % (day, self.name, a['slug'])))
        extra = self._diverse(rest, max(0, G['stop_extra'] - len(ans)), [a['kind'] for a in self.core])
        out = list(sp) + [ANSWER_ACTS[s] for s in ans]
        if thread_ok:
            out.append(THREAD_ACT)
        out += self.core + extra
        out += [a for a in self.upgrades if a['tier'] <= lit_tier and not a['cond']]
        return out

    def bar_row(self, a):
        if a['slug'] == 'thread_go':
            r = bar_of(self.bars, 'thread_go', self.typ)
            return r
        r = bar_of(self.bars, a['slug'], self.typ)
        if r is None:   # acts the generator did not see (should not happen): lean = Cheer, base by energy
            r = ('Cheer', None, {0: 6, 1: 9, 2: 12}.get(a['energy'], 15))
        return r

ANSWER_ACTS, THREAD_ACT = {}, None

def do_acts(stop, offered, n_acts, rng, bars_state, policy, can_craft=True):
    """Do up to n_acts acts from the offer. Returns pay dict and adds bar points to bars_state (dict bar -> points, capped 100).
    policy 'list' = top of the list (the UI order); 'bars' = best points into unfilled bars first."""
    doable = [a for a in offered if a['kind'] != 'craft' or rng.random() < ASSUME['craft_has_inputs']]
    if policy == 'bars':
        def gain(a):
            first, second, base = stop.bar_row(a)
            f = 1.5 if a['slug'] in ANSWER else 1.0
            g = base * f * (1 if bars_state[first] < 100 else 0) + (base / 2 if second and bars_state[second] < 100 else 0)
            return g
        doable.sort(key=lambda a: -gain(a))
    chosen = doable[:n_acts]
    pay = dict(c=0.0, xp=0.0, en=0.0, cost=0.0, energy=0, items=Counter(), crop=0.0, minutes=0, thread=0, n=0)
    nth = Counter()
    kinds = set()
    fed = set()
    for a in chosen:
        outs = act_outcome_probs(a)
        r, acc = rng.random(), 0
        share, W = outs[-1][1], outs[-1][2]
        for p, s, w in outs:
            acc += p
            if r < acc:
                share, W = s, w
                break
        if a['slug'] == 'thread_go':
            pay['thread'] += 1
        else:
            spec = a['win'] if share > 0 else a['lose']
            rw = parse_reward(spec, stop.lvl)
            m = share if share > 0 else 1.0
            pay['c'] += rw['c'] * m
            pay['xp'] += rw['xp'] * m
            pay['en'] += rw['en']
            pay['crop'] += rw['crop']
            for k, v in rw['items'].items():
                pay['items'][k] += v
            pay['cost'] += act_cost_coins(a)
        pay['energy'] += a['energy']
        pay['minutes'] += G['stop_min']
        pay['n'] += 1
        # bar points (master 7.3)
        first, second, base = stop.bar_row(a)
        nth[first] += 1
        D = 1.0 if nth[first] == 1 else (0.5 if nth[first] == 2 else 0.0)
        F = 1.5 if a['slug'] in ANSWER else 1.0
        pts = max(1, math.floor(base * D * W * F))
        if a['kind'] not in kinds:
            pts += 2
            kinds.add(a['kind'])
        bars_state[first] = min(100, bars_state[first] + pts)
        fed.add(first)
        if second:
            bars_state[second] = min(100, bars_state[second] + max(1, pts // 2))
            fed.add(second)
    if set(BARS3) <= fed:   # full round: +5 to the lowest unfilled bar
        low = [b for b in BARS3 if bars_state[b] < 100]
        if low:
            b = min(low, key=lambda x: bars_state[x])
            bars_state[b] = min(100, bars_state[b] + 5)
    return pay

# ----------------------------------------------------------------------------------------------------------------------------
# Q4: bar pace per stop
# ----------------------------------------------------------------------------------------------------------------------------
def bar_pace(stops, acts, needs, bars, runs, rng, policy, n_acts, tier=0, max_days=60):
    res = {}
    for (name, typ, zone, kind, region) in stops:
        sm = StopModel(name, typ, region, acts, needs, bars, tier)
        per_bar = {b: [] for b in BARS3}
        all3 = []
        for r in range(runs):
            st = {b: 0 for b in BARS3}
            done = {}
            for d in range(1, max_days + 1):
                unfilled = [b for b in BARS3 if st[b] < 100]
                off = sm.offer(d * 7919 + r, rng, unfilled, thread_ok=(d > 1), lit_tier=tier)
                do_acts(sm, off, n_acts, rng, st, policy)
                for b in BARS3:
                    if st[b] >= 100 and b not in done:
                        done[b] = d
                if len(done) == 3:
                    break
            for b in BARS3:
                per_bar[b].append(done.get(b, max_days + 1))
            all3.append(max(done.get(b, max_days + 1) for b in BARS3))
        res[name] = dict(type=typ, region=region, bars={b: pct(per_bar[b]) for b in BARS3}, all3=pct(all3), raw_all3=all3)
    return res

def pct(v, ps=(10, 50, 90)):
    s = sorted(v)
    return tuple(s[min(len(s) - 1, int(round(p / 100 * (len(s) - 1))))] for p in ps)

def latch_all(pace, stops_per_day, runs, rng, include=None):
    """Days to latch every bar of a set of stops: each game day the gnome tours `stops_per_day` stops, always the ones with
    the most visit-days still owed (perfect routing, so a floor). Visit-days needed per stop are drawn from the bar-pace runs."""
    names = [n for n in pace if include is None or n in include]
    out = []
    for r in range(runs):
        need = {n: rng.choice(pace[n]['raw_all3']) for n in names}
        day = 0
        while any(v > 0 for v in need.values()):
            day += 1
            k = rng.choice(stops_per_day) if isinstance(stops_per_day, tuple) else stops_per_day
            for n in sorted(need, key=lambda x: -need[x])[:k]:
                need[n] -= 1
        out.append(day)
    return pct(out)

# ----------------------------------------------------------------------------------------------------------------------------
# The Maplewold run: one gnome, day by day
# ----------------------------------------------------------------------------------------------------------------------------
# Chapter steps (proposal-story-2-quests.md 2.1 with master section 6). kinds:
#   work: minutes of the gnome's own time; stage: 480 min + items/Petals; find:n places; light: adopt+raise tier 1;
#   tier2: raise held stop to tier 2; crop: wait for N of a crop harvested; regular: be a Regular in zone z; meals: n meals;
#   bed: Seed Bed hand-in k (wild rice); flower; fight (alt meals for a non-fighter); friend; lit7; owl; seal
CH = [
    ('M1', 1, [('visit',), ('jigsaw',), ('crop', 'oats', 1), ('crop', 'lentil', 1), ('regular', 1), ('light', 1),
               ('work', 'escort', ASSUME['escort_min']), ('stage', {'flint': 3}, 50), ('stage', {'plank': 2}, 0), ('stage', {'rope': 1}, 100),
               ('place', 'Sugar Shack')]),
    ('M2', 2, [('find', 'Stump'), ('regular', 2), ('light', 2), ('fight', 'barn-rat', 6, 2), ('stage', {'plank': 2, 'rope': 1}, 0),
               ('stage', {}, 100), ('crop', 'hops', 3)]),
    ('M3', 3, [('find', 'Lighthouse'), ('regular', 3), ('work', 'escort', ASSUME['escort_min']), ('tier2',), ('buy', 'beeswax', 2),
               ('work', 'deliver', ASSUME['deliver_min']), ('stage', {'stone': 3}, 150), ('stage', {'rope': 2, 'plank': 2}, 0),
               ('flower', 'goldenrod'), ('find', 'Ferry Landing')]),
    ('M4', 4, [('find', 'Heron Stilt'), ('find', 'Dam Debt'), ('errand', 'na-dam-debt'), ('stage', {'plank': 4, 'rope': 2}, 200),
               ('regular', 4), ('light', 3), ('bed', 1)]),
    ('M5', 5, [('find', 'Aurora Camp'), ('regular', 5), ('buy', 'beeswax', 4), ('stage', {'beeswax': 4}, 0), ('stage', {'rope': 3}, 250),
               ('fight', 'bramble-wolf', 12, 2), ('bed', 2), ('meals', 3)]),
    ('M6', 6, [('find', "Keeper's Hut"), ('find', 'Cairnback Pass'), ('regular', 6), ('work', 'escort', ASSUME['escort_min']),
               ('stage', {'stone': 6}, 0), ('stage', {'flint': 4}, 300), ('stage', {'fine': 1}, 0), ('bed', 3), ('hearth2',)]),
    ('M7', 6, [('lit7',), ('friend',), ('owl',), ('crop', 'apple', 1), ('meals', 2)]),
]
CHAPTER_STAGES = sum(1 for _, _, st in CH for s in st if s[0] == 'stage')   # 13
BED_HANDIN = {1: 3, 2: 5, 3: 8}   # master 8 (cumulative 3, 8, 16 wild rice)

# Errands (proposal-story-2-quests.md 3.1). id: (kind, trigger, minutes, c, xp, needs)
ERRANDS = {
    'na-dam-debt': ('E', 'M4', 120, 80, 70, None),
    'na-s01': ('E', 'lit1', 120, 60, 40, None),
    'na-s02': ('E', 'tier2', 90, 90, 60, 'lit3'),
    'na-s03': ('E', 'regular1', 60, 50, 40, 'lentil2'),
    'na-s09': ('E', 'bed1', 60, 70, 60, 'goldenrod3'),
    'na-s10': ('E', 'lit_north', 150, 90, 80, None),
    'na-s06': ('E', 'M3done', 60, 30, 14, 'beeswax2'),
    'na-s04': ('E', 'mill_lit', 30, 35, 14, 'hops3'),
    'na-s05': ('T', 'stump', 4, None, None, None),     # threads: beats
    'na-s08': ('T', 'heron', 4, None, None, None),
    'na-s12': ('T', 'M6done', 5, 1, 0, None),
}

NA_FLOWERS = ['goldenrod', 'black-eyed-susan', 'blue-violet', 'california-poppy', 'coneflower', 'bee-balm', 'lupine']
NA_STAPLES = ['soybean', 'lentil', 'oats', 'kidney-bean']
NA_UNCOMMON = ['apple', 'hops', 'raspberry', 'wild-rice']


QUEST_KEEP = {'oats', 'lentil', 'hops', 'apple', 'wild-rice', 'soybean', 'kidney-bean', 'raspberry'}
ZONE_PICK = {1: 'Honeybrook', 2: 'Birchhollow', 3: 'Cattailmere'}   # villages the gnome lights in M1, M2 and M4 (M4: the paddy)
WORK_KINDS = {'jigsaw', 'stage', 'work', 'find', 'errand'}
MONEY_CROP, MONEY_SELL, BASKET_SELL = None, 0, 0


class Gnome:
    def __init__(self, rng, crops, fighter, opt):
        self.rng, self.crops, self.fighter, self.opt = rng, crops, fighter, opt
        self.xp = 0
        self.petals = 500.0   # functions.php:396 starting_coins
        self.wallet = 0.0
        self.energy_debt = 0.0
        self.mat = Counter()
        self.crop_store = Counter()
        self.harvested = Counter()
        self.flowers = set()
        self.beds = []
        self.nbeds = 16
        self.regrown = set()
        self.basket_i = 0
        self.acts_at = Counter()
        self.regular, self.visited, self.places = set(), set(), set()
        self.bars = {s[0]: {b: 0 for b in BARS3} for s in NA_STOPS}
        self.lit = {}
        self.held = None
        self.adoptions = 0
        self.secrets = 0
        self.threads = {}
        self.threads_done = 0
        self.thread_named = {}
        self.thread_named_done = set()
        self.errands_done = set()
        self.passport = set()
        self.friend_days = 0
        self.friend_need = rng.randint(*ASSUME['friend_town_days'])
        self.owl_evenings = 0
        self.owl_done = self.delve_done = False
        self.stages_done = 0
        self.bed_done = 0
        self.ch_step = {c[0]: 0 for c in CH}
        self.ch_done, self.ch_open, self.zone_open = set(), {'M1'}, {1}
        self.wanted = Counter()
        self.meals_needed = 0
        self.meals_eaten = 0
        self.carry = 0
        self.owe_energy = self.owe_min = 0.0
        self.stall_days = 0
        self.stall_by = Counter()
        self.ch_day = {}
        self.lamp7_day = None
        self.ledger, self.spend, self.xpled = Counter(), Counter(), Counter()
        self.day_ledger = Counter()

    @property
    def L(self):
        return level_of(self.xp)

    def add_xp(self, n, src):
        self.xp += n
        self.xpled[src] += n

    def earn(self, n, src):
        self.petals += n
        self.ledger[src] += n
        self.day_ledger[src] += n

    def pay(self, n, src):
        self.petals -= n
        self.spend[src] += n

    def has_crop_in_beds(self, key):
        return any(b and b[0] == key for b in self.beds)

    def want(self, key, nbeds):
        if self.wanted[key] == 0 and not self.has_crop_in_beds(key):
            self.wanted[key] += nbeds

    def standing(self):
        Lc = sum(1 for v, t in self.lit.items() if t >= 1 and v in self.regular)
        rows_ = {}
        rows_['lit'] = W_LIT * min(1, Lc / 7)   # round(0.6 x 12) = 7
        rows_['raised'] = W_RAISED * min(1, sum(t for v, t in self.lit.items() if v in self.regular) / 12)
        rows_['hearth'] = HEARTH_PTS[max([0] + list(self.lit.values()))]
        rows_['repair'] = W_REPAIR * self.stages_done / CHAPTER_STAGES
        places_sh = min(1, len(self.places) / (ASSUME['places_total'] + self.secrets))
        rows_['places'] = W_PLACES * places_sh
        friend = self.friend_days >= self.friend_need
        rows_['friend'] = W_FRIEND if friend else 0
        rows_['threads'] = W_THREADS * min(1, self.threads_done / 3)
        rows_['errands'] = W_ERRANDS * min(1, len(self.errands_done) / 5)
        grown_sh = sum(1 for c in NA_STAPLES + NA_UNCOMMON if self.harvested[c] > 0) / 8
        rows_['grown'] = W_GROWN * grown_sh
        rows_['bed'] = 2 * self.bed_done
        nf = len(self.flowers)
        rows_['flower'] = 4 if nf >= 3 else (2 if nf >= 1 else 0)
        rows_['delve'] = W_DELVE if self.delve_done else 0
        rows_['lair'] = W_LAIR if self.owl_done else 0
        folk_sh = (int(friend) + min(1, self.threads_done / 3) + min(1, len(self.errands_done) / 5)) / 3
        rows_['pages'] = W_PAGES * (places_sh + grown_sh + folk_sh) / 3
        return sum(rows_.values()), rows_

    def reserve(self):
        need = 0
        for name, z, steps in CH:
            if name in self.ch_open and name not in self.ch_done:
                for s in steps[self.ch_step[name]:]:
                    if s[0] == 'light':
                        need += 200 + (G['stop_adopt_cost'] if self.adoptions > 0 else 0)
                    elif s[0] == 'tier2':
                        need += 400
                    elif s[0] == 'lit7':
                        need += max(0, 7 - len(self.lit)) * (200 + G['stop_adopt_cost'])
                    elif s[0] == 'stage':
                        need += s[2]
        return need

    def mat_make(self, kind, n):
        use = min(self.mat[kind], n)
        self.mat[kind] -= use
        n -= use
        if n <= 0:
            return
        if kind in ('rope', 'beeswax'):
            self.pay(n * ASSUME[kind + '_buy'], 'materials bought')
        elif kind == 'stone':
            self.owe_energy += n * ASSUME['stone_energy']
            self.owe_min += n * ASSUME['stone_min']
        elif kind == 'plank':
            self.owe_energy += n * ASSUME['plank_energy']
            self.owe_min += n * ASSUME['plank_min']
        else:   # flint, fine (an uncommon find): gather tries
            tries = n / ASSUME['gather_items_per_try'] * (1 if kind == 'flint' else 3)
            self.owe_energy += tries
            self.owe_min += tries * 10

    # ---- energy: a wallet per game day; a shortfall is eaten as home-cooked meals made from crops on hand
    def edible(self):
        return sum(v for k, v in self.crop_store.items() if k.startswith('sell:'))

    def eat_crops(self, n):
        for k in list(self.crop_store):
            if n <= 0:
                break
            if k.startswith('sell:') and self.crop_store[k] > 0:
                t = min(self.crop_store[k], n)
                self.crop_store[k] -= t
                n -= t
                self.spend['crops eaten or handed in (value, not cash)'] += t * self.crops[k[5:]]['sell']
        if n > 0:   # not enough on hand: bought food (valued at the basket price)
            self.pay(n * BASKET_SELL, 'food bought for meals')

    def spend_e(self, n, debt=False, eat=True):
        if n <= 0 or self.wallet >= n:
            self.wallet -= max(0, n)
            return True
        if eat and ASSUME['eat_for_energy']:
            m = math.ceil((n - self.wallet) / (G['meal_energy'] - G['cook_energy_meal']))
            if self.edible() >= m * ASSUME['meal_crops']:
                self.eat_crops(m * ASSUME['meal_crops'])
                self.wallet += m * (G['meal_energy'] - G['cook_energy_meal'])
                self.meals_eaten += m
                self.add_xp(m * action_xp(G['cook_xp_meal'], self.L), 'cooking')
                self.wallet -= n
                return True
        if debt:
            self.wallet -= n
            return True
        return False

    def bed_cap(self):
        cap = 16
        for lv, nb in sorted(ASSUME['beds_by_level'].items()):
            if self.L >= lv:
                cap = nb
        return cap

    def garden_harvest(self):
        L = self.L
        while self.nbeds < self.bed_cap():
            k = (self.nbeds - 16) / 4
            m = min(6, (1 + G['bed_add_growth_pct'] / 100) ** k)
            cost = G['bed_add_cost'] * m
            if self.petals - cost < self.reserve():
                break
            self.pay(cost, 'garden beds')
            self.mat_make('plank', math.ceil(G['bed_add_planks'] * m - 1e-9))
            self.nbeds += 4
        while len(self.beds) < self.nbeds:
            self.beds.append(None)
        for i, b in enumerate(self.beds):
            if b is None:
                continue
            b[1] -= 1
            b[4] += 1
            if b[1] > 0:
                continue
            c = self.crops[b[0]]
            y = ASSUME['yield_tree'] if c['tree'] else ASSUME['yield_annual']
            regrown = b[2] and b[5] > 0
            if regrown:
                y *= ASSUME['regrow_yield']
            life = G['life_days'].get(c['kind'], 30)
            if b[2]:
                y *= 1 - (1 - G['life_end_yield'] / 100) * min(1, b[4] / life)
            y = max(1, int(y + self.rng.random()))
            self.spend_e(c['harvest_e'], debt=True, eat=False)
            self.add_xp(int(round(action_xp(c['xp'], L) * (G['regrow_xp_pct'] / 100 if regrown else 1))), 'harvests')
            self.harvested[b[0]] += y
            b[5] += 1
            if c['flower']:
                self.flowers.add(c['slug'])
                self.crop_store[b[0]] += y
            elif b[3] == 'quest' or b[0] in ('wild-rice',):
                self.crop_store[b[0]] += y
            else:
                self.crop_store['sell:' + b[0]] += y
            if b[2] and b[4] < life and not (c['flower'] and len(self.flowers) >= 3):
                b[1] = c['regrow_sleeps']
                self.spend_e(ASSUME['waterings_per_cycle'](c['regrow_sleeps']) * G['water'], debt=True, eat=False)
            else:
                self.beds[i] = None

    def garden_plant(self, budget, eat):
        """Plant empty beds while the energy lasts (budget = most energy this pass may use)."""
        used = 0.0
        for i, b in enumerate(self.beds):
            if b is not None:
                continue
            key = next((k for k in self.wanted if self.wanted[k] > 0), None)
            purpose = 'quest'
            if key is None:
                purpose = 'money'
                key = MONEY_CROP if ASSUME['money_mode'] == 'best' else ASSUME['money_basket'][self.basket_i % len(ASSUME['money_basket'])]
            c = self.crops[key]
            seed = c['seed_price'] * (1 if c['per'] else ASSUME['seed_cost_share'])
            if purpose == 'money' and c['per'] and self.petals - seed < self.reserve():
                key, c = 'soybean', self.crops['soybean']   # cannot spare the Petals for a perennial: a cheap annual instead
                seed = c['seed_price'] * ASSUME['seed_cost_share']
            need = (0 if c['per'] else G['till']) + G['plant'] + ASSUME['waterings_per_cycle'](c['sleeps']) * G['water']
            if used + need > budget or not self.spend_e(need, eat=eat):
                break
            used += need
            if purpose == 'quest':
                self.wanted[key] -= 1
            else:
                self.basket_i += 1
            self.beds[i] = [key, c['sleeps'], c['per'], purpose, 0, 0]   # crop, sleeps left, perennial, purpose, age, harvests
            self.pay(seed, 'seeds')


def run_gnome(seed, crops, acts, needs, bars, fighter, chapter_xp, jobs_on=False, max_days=90):
    rng = random.Random(seed)
    stops = {s[0]: StopModel(s[0], s[1], s[4], acts, needs, bars) for s in NA_STOPS}
    opt = rng.uniform(*ASSUME['opt_pursuit'])
    g = Gnome(rng, crops, fighter, opt)
    villages = [s[0] for s in NA_STOPS if s[3] == 'village']
    zone_of = {s[0]: s[2] for s in NA_STOPS}
    g.wanted.update({'oats': 1, 'lentil': 1})
    opt_crops = [c for c in ('soybean', 'kidney-bean', 'raspberry') if rng.random() < opt]
    opt_flowers = [f for f in NA_FLOWERS[1:] if rng.random() < opt / 2][:2]
    stops_per_day = rng.choice(ASSUME['stops_per_day'])
    first80 = seal_day = main_done_day = main_done_standing = None
    main_done_rows = None
    xp_at_seal = None
    daily = []
    daily_jobs = 0
    gross_cum = 0.0
    disc_cum = 0.0   # gross minus the spends the gnome cannot skip (seeds, chapter stages, buys at stops, meals, bought materials)
    for day in range(1, max_days + 1):
        L = g.L
        E = day_energy(L)
        avail = day_minutes() - g.carry
        g.carry = 0
        g.owe_energy = g.owe_min = 0.0
        g.day_ledger = Counter()
        spend0 = Counter(g.spend)
        stalled = False
        g.wallet = E + g.energy_debt
        g.garden_harvest()
        g.garden_plant(max(0, g.wallet) * 0.5, eat=False)
        work_min = 0
        fights = 0
        # ---------------- chapter steps
        for name, zone, steps in CH:
            if name not in g.ch_open or name in g.ch_done:
                continue
            while g.ch_step[name] < len(steps):
                s = steps[g.ch_step[name]]
                k = s[0]
                if k in WORK_KINDS and work_min + g.owe_min >= avail:
                    break
                ok = False
                if k in ('visit',):
                    ok = True
                elif k == 'jigsaw':
                    work_min += 240
                    ok = True
                elif k == 'crop':
                    c, n = s[1], s[2]
                    if g.harvested[c] < n:
                        g.want(c, max(1, math.ceil(n / ASSUME['yield_annual'])))
                    ok = g.harvested[c] >= n
                elif k == 'regular':
                    g.zone_open.add(s[1])
                    ok = any(zone_of[v] == s[1] and v in g.regular for v in villages)
                elif k == 'light':
                    z = ZONE_PICK[s[1]]
                    if z in g.lit:
                        ok = True
                    elif g.held is None or s[1] == 1:
                        cost = 200 + (G['stop_adopt_cost'] if g.adoptions > 0 else 0)
                        if g.petals >= cost:
                            g.pay(cost, 'stops row (fee + tiers)')
                            g.mat_make('stone', 4)
                            g.mat_make('plank', 4)
                            g.lit[z] = 1
                            g.adoptions += 1
                            g.held = None if s[1] == 1 else z   # M1: light it and hand it back; M2: keep it for M3's stall
                            g.add_xp(G['tier_xp'], 'stop tiers')
                            ok = True
                        else:
                            stalled = True
                            g.stall_by['lamp (M1/M2/M4)'] += 1
                elif k == 'tier2':
                    z = g.held or ZONE_PICK[2]
                    if g.petals >= 400:
                        g.pay(400, 'stops row (fee + tiers)')
                        g.mat_make('stone', 4)
                        g.mat_make('plank', 6)
                        g.mat_make('rope', 3)
                        g.lit[z] = 2
                        g.held = None
                        g.add_xp(2 * G['tier_xp'], 'stop tiers')
                        ok = True
                    else:
                        stalled = True
                        g.stall_by['stall tier 2 (M3)'] += 1
                elif k == 'hearth2':
                    ok = max([0] + list(g.lit.values())) >= 2
                elif k == 'buy':
                    g.mat_make(s[1], s[2])
                    g.mat[s[1]] += s[2]
                    ok = True
                elif k == 'stage':
                    if g.petals >= s[2]:
                        g.pay(s[2], 'chapter stages')
                        for m, q in s[1].items():
                            g.mat_make(m, q)
                        work_min += G['repair_min']
                        g.stages_done += 1
                        ok = True
                    else:
                        stalled = True
                        g.stall_by['chapter stage Petals'] += 1
                elif k == 'work':
                    work_min += s[2]
                    ok = True
                elif k == 'find':
                    work_min += ASSUME['find_min']
                    g.places.add(s[1])
                    ok = True
                elif k == 'place':
                    g.places.add(s[1])
                    ok = True
                elif k == 'fight':
                    if fighter:
                        fights += 1
                        work_min += ASSUME['fight_min']
                    else:
                        g.meals_needed += s[3]
                    ok = True
                elif k == 'errand':
                    work_min += ERRANDS[s[1]][2]
                    g.mat_make('flint', 0)
                    g.errands_done.add(s[1])
                    g.earn(ERRANDS[s[1]][3], 'errands')
                    g.add_xp(ERRANDS[s[1]][4], 'errands')
                    ok = True
                elif k == 'flower':
                    if s[1] not in g.flowers:
                        g.want('flower:' + s[1], 1)
                    ok = s[1] in g.flowers
                elif k == 'bed':
                    kk = s[1]
                    need = BED_HANDIN[kk]
                    if g.crop_store['wild-rice'] < need and g.harvested['wild-rice'] < 16:
                        g.want('wild-rice', 6)   # master A3: 6 beds on the signature crop
                    if 'Cattailmere' in g.lit and 'Cattailmere' in g.regular and g.crop_store['wild-rice'] >= need:
                        g.crop_store['wild-rice'] -= need
                        g.bed_done = kk
                        ok = True
                elif k == 'meals':
                    g.meals_needed += s[1]
                    ok = True
                elif k == 'lit7':
                    nl = sum(1 for v in g.lit if v in g.regular)
                    if nl >= 7:
                        ok = True
                    else:
                        cand = [v for v in villages if v not in g.lit and zone_of[v] in g.zone_open]
                        cost = 200 + G['stop_adopt_cost']
                        if len(g.lit) < 7 and cand:
                            if g.petals >= cost:
                                v = cand[0]
                                g.pay(cost, 'stops row (fee + tiers)')
                                g.mat_make('stone', 4)
                                g.mat_make('plank', 4)
                                g.lit[v] = 1
                                g.adoptions += 1
                                g.add_xp(G['tier_xp'], 'stop tiers')
                                if len(g.lit) == 7:
                                    g.lamp7_day = day
                            else:
                                stalled = True
                                g.stall_by['lamps 4-7 (M7)'] += 1
                        break
                elif k == 'friend':
                    ok = g.friend_days >= g.friend_need
                elif k == 'owl':
                    if fighter and g.L >= ASSUME['owl_fight_level']:
                        g.owl_done = True
                        fights += 1
                        work_min += 120
                    else:
                        g.owl_evenings += 1   # one evening at Aurora Camp per game day (r_na_owl_hoot)
                        work_min += 60
                        if g.owl_evenings >= 3:
                            g.owl_done = True
                    ok = g.owl_done
                    if not ok:
                        break
                if not ok:
                    break
                g.ch_step[name] += 1
            if g.ch_step[name] >= len(steps) and name not in g.ch_done:
                g.ch_done.add(name)
                g.ch_day[name] = day
                ci = [c[0] for c in CH].index(name)
                g.earn(150 + 75 * ci, 'chapters')   # story-2 1.4: band 1 chapter Petals 150 to 600 rising by zone
                g.add_xp(chapter_xp[name], 'chapters')
        for i, (name, zone, steps) in enumerate(CH):
            if name in g.ch_open:
                continue
            prest = [s[0] for s in CH[i - 1][2][g.ch_step[CH[i - 1][0]]:]]
            if all(k not in WORK_KINDS for k in prest) and g.L >= ZONE_FLOOR_NA[zone] - ASSUME['level_hint_slack']:
                g.ch_open.add(name)
                g.zone_open.add(zone)
            break
        if 'M6' in g.ch_done:
            g.zone_open.update(range(1, 7))
        if stalled:
            g.stall_days += 1
        busy = work_min + g.owe_min
        if busy > avail:
            g.carry = int(busy - avail)
            busy = avail
        left = avail - busy
        # ---------------- touring
        per_stop = ASSUME['acts_per_stop'] * G['stop_min'] + ASSUME['walk_min_per_stop']
        k_stops = min(stops_per_day, int(left // per_stop))
        open_stops = [s[0] for s in NA_STOPS if s[2] in g.zone_open and s[3] != 'border']
        want = []
        for name, zone, steps in CH:
            if name in g.ch_open and name not in g.ch_done:
                for s in steps[g.ch_step[name]:g.ch_step[name] + 3]:
                    if s[0] == 'regular' and not any(zone_of[v] == s[1] and v in g.regular for v in villages):
                        want.append('Cattailmere' if s[1] == 4 else ('Granitegate' if s[1] == 6 else next(v for v in villages if zone_of[v] == s[1])))
                    elif s[0] == 'owl' and not (fighter and g.L >= ASSUME['owl_fight_level']):
                        want.append('Aurora Camp')
                    elif s[0] == 'bed':
                        want.append('Cattailmere')
                    elif s[0] == 'lit7':
                        want += [v for v in g.lit if v not in g.regular]
        if g.friend_days < g.friend_need:
            want.append('Maplewold Market')
        want += [st for st, b in g.threads.items() if 0 < b < 4]
        tour = []
        for w in want:
            if w not in tour and w in open_stops:
                tour.append(w)
        for st in sorted(open_stops, key=lambda x: (sum(1 for b in BARS3 if g.bars[x][b] >= 100), rng.random())):
            if st not in tour:
                tour.append(st)
        tour = tour[:k_stops]
        done_tour = []
        for st in tour:
            if not g.spend_e(6):   # about 5.5 energy for five acts; no energy and nothing to eat: the walk ends here
                break
            done_tour.append(st)
            sm = stops[st]
            unfilled = [b for b in BARS3 if g.bars[st][b] < 100]
            thread_ok = st in g.regular and g.threads.get(st, 0) < 4
            off = sm.offer(day, rng, unfilled, thread_ok, g.lit.get(st, 0))
            pay = do_acts(sm, off, ASSUME['acts_per_stop'], rng, g.bars[st], 'list')
            g.earn(pay['c'], 'stop acts')
            g.pay(pay['cost'], 'stop buys and rests')
            g.add_xp(int(round(pay['xp'])), 'stop acts')
            g.wallet += 6 - pay['energy'] + pay['en']
            g.crop_store['money'] += pay['crop']
            for it, q in pay['items'].items():
                if it in ('rope', 'timber-plank', 'building-stone', 'beeswax'):
                    g.mat[{'timber-plank': 'plank', 'building-stone': 'stone'}.get(it, it)] += q
            g.acts_at[st] += pay['n']
            g.visited.add(st)
            if st in villages or st in ('The Sugar Shack', 'Aurora Camp'):
                g.places.add(st)
            if g.acts_at[st] >= G['regular_acts']:
                g.regular.add(st)
            if pay['thread']:
                g.threads[st] = g.threads.get(st, 0) + 1
                if g.threads[st] == 4:
                    g.threads_done += 1
                    rw = parse_reward('c=45:8,xp=16:3', BAND_FLOOR['NA'])   # stop_threads.txt: typical last-beat pay
                    g.earn(rw['c'], 'threads')
                    g.add_xp(int(rw['xp']), 'threads')
            if st in g.lit and st == g.held:
                g.earn(G['welcome_coins'][0] + G['welcome_coins'][1] * g.lit[st], 'adopter welcome')
            if st == 'Maplewold Market' and rng.random() < ASSUME['chat_day_prob']:
                g.friend_days += 1
        tour = done_tour
        left -= len(tour) * per_stop
        if g.friend_days < g.friend_need and 'Maplewold Market' not in tour and rng.random() < 0.3:
            g.friend_days += 1   # chat or a gift away from town
        for need_n, c, x, key in ((5, 100, 20, 'pp5'), (15, 300, 0, 'pp15')):   # stop_sets.txt passport totals
            if len(g.visited) >= need_n and key not in g.passport:
                g.passport.add(key)
                g.earn(c, 'passport')
                g.add_xp(x, 'passport')
                if key == 'pp15':
                    g.mat['plank'] += 3
        if len([s for s in NA_STOPS if s[3] != 'border' and s[0] in g.visited]) >= 15 and 'region' not in g.passport:
            g.passport.add('region')
            g.earn(250, 'passport')
            g.add_xp(40, 'passport')
            g.mat['rope'] += 2
        # ---------------- side quests: a share opt before the meter is read, all of them after
        lookmeter = ('M6' in g.ch_done and g.ch_step['M7'] >= 3) if ASSUME['meter_from'] == 'M7' else (main_done_day is not None)
        for eid, (kind, trig, mins, c, x, need) in ERRANDS.items():
            if eid in g.errands_done or eid in g.thread_named_done or eid == 'na-dam-debt' or left < 30:
                continue
            avail_e = {'lit1': len(g.lit) >= 1, 'tier2': max([0] + list(g.lit.values())) >= 2,
                       'regular1': any(zone_of[v] == 1 for v in g.regular if v in villages),
                       'bed1': g.bed_done >= 1, 'lit_north': any(zone_of[v] == 5 for v in g.lit), 'M3done': 'M3' in g.ch_done,
                       'mill_lit': 'Cloverholt' in g.lit and rng.random() < 0.15,
                       'stump': 'Stump' in g.places and any(zone_of[v] == 2 for v in g.regular if v in villages),
                       'heron': 'Heron Stilt' in g.places and 'Cattailmere' in g.regular, 'M6done': 'M6' in g.ch_done}[trig]
            if not avail_e or not (lookmeter or rng.random() < opt / 4 or eid in g.thread_named):
                continue
            if kind == 'T':
                if rng.random() < 0.6:   # its stop is on today's walk
                    g.thread_named[eid] = g.thread_named.get(eid, 0) + 1
                    left -= 15
                    if g.thread_named[eid] >= mins:
                        g.thread_named_done.add(eid)   # a thread, not an errand
                        g.threads_done += 1
                        rw = parse_reward('c=45:8,xp=16:3', 1)
                        g.earn(rw['c'], 'threads')
                        g.add_xp(int(rw['xp']), 'threads')
                        if eid == 'na-s12':
                            g.secrets += 1
                            g.places.add('Walkers Bivouac')
                continue
            if need == 'lentil2' and not fighter and g.harvested['lentil'] < 2:
                g.want('lentil', 1)
                continue
            if need == 'goldenrod3' and g.crop_store['flower:goldenrod'] < 3:
                g.want('flower:goldenrod', 2)
                continue
            if need == 'hops3' and g.crop_store['hops'] < 3:
                continue
            if need == 'lit3' and len(g.lit) < 3:
                continue
            if need == 'beeswax2':
                g.mat_make('beeswax', 2)
            left -= mins
            g.errands_done.add(eid)
            g.earn(c, 'errands')
            g.add_xp(x, 'errands')
            if eid == 'na-s09':
                g.secrets += 1
                g.places.add('Drowned Paddy Boardwalk')
            if eid == 'na-s03' and fighter:
                fights += 1
        for c in opt_crops + (['soybean', 'kidney-bean', 'raspberry'] if lookmeter else []):
            if g.harvested[c] == 0:
                g.want(c, 1)
        if len(g.flowers) < 3:
            for f in opt_flowers + (NA_FLOWERS[1:3] if lookmeter else []):
                if f not in g.flowers:
                    g.want('flower:' + f, 1)
        optional_places = [p for p in ('Beaverdam Tunnels', 'Hollow Peak') if p not in g.places]
        if left > ASSUME['find_min'] and optional_places and g.L >= 8 and (lookmeter or rng.random() < opt):
            if rng.random() < ASSUME['explore_find_prob'] * (3 if lookmeter else 1):
                g.places.add(optional_places[0])
                left -= ASSUME['find_min']
        if g.owl_done:
            g.places.add("Owl's Den")
        if lookmeter:
            for v in villages:
                if v not in g.visited and zone_of[v] in g.zone_open and left > 60:
                    g.visited.add(v)
                    g.places.add(v)
                    left -= 60
                    break
        # ---------------- fighter: fights on the walks, the delve
        if fighter:
            fights += ASSUME['fights_per_tour_day'] * len(tour) / max(1, stops_per_day)
            if not g.delve_done and g.L >= ASSUME['delve_level'] and left >= 120:
                g.delve_done = True
                g.places.add('Beaverdam Tunnels')
                left -= 240
                fights += 3
            for _ in range(int(round(fights))):
                s = rng.choice(['small', 'medium', 'medium', 'large'])
                cl = max(1, g.L + rng.randint(-1, 1))
                g.add_xp(action_xp(int(round(cl * 6 * G['creature_xp_mult'][s])), g.L), 'fights')
                g.earn(max(1, round(G['petals_K'][s] * (2 + 0.6 * cl))), 'fights')
            g.spend_e(fights, debt=True)
        # ---------------- meals handed in for steps; materials made today; then plant with what energy is left
        if g.meals_needed:
            g.eat_crops(g.meals_needed * ASSUME['meal_crops'])
            g.spend_e(g.meals_needed * G['cook_energy_meal'], debt=True)
            g.add_xp(g.meals_needed * action_xp(G['cook_xp_meal'], g.L), 'cooking')
            g.meals_needed = 0
        g.spend_e(g.owe_energy, debt=True)
        g.garden_plant(max(0, g.wallet) + 40, eat=True)
        g.energy_debt = min(0.0, g.wallet)
        # ---------------- sales
        sold = 0.0
        for ck in list(g.crop_store):
            if ck.startswith('sell:'):
                sold += g.crop_store[ck] * crops[ck[5:]]['sell']
                g.crop_store[ck] = 0
        g.earn(sold + g.crop_store['money'] * BASKET_SELL, 'crop sales')
        g.crop_store['money'] = 0
        for ck in ('soybean', 'kidney-bean', 'raspberry', 'oats', 'lentil', 'hops', 'apple', 'wild-rice'):
            keep = {'oats': 3, 'lentil': 3, 'hops': 3, 'apple': 3, 'wild-rice': 16}.get(ck, 0)
            if ck == 'wild-rice' and g.bed_done >= 3:
                keep = 0
            if g.crop_store[ck] > keep:
                g.earn((g.crop_store[ck] - keep) * crops[ck]['sell'], 'crop sales')
                g.crop_store[ck] = keep
        if jobs_on:
            for per, c, x, every in (('daily', 73.3, 24.4, 1), ('weekly', 520, 137, 7),
                                     ('monthly', 3700, 850 * G['job_xp_monthly_pct'] / 100, G['job_month_days'])):
                if day % every == 0 and rng.random() < ASSUME['job_done'][per]:
                    g.earn(c * (1 - ASSUME['job_cost_share']), 'job board')
                    g.add_xp(int(x), 'job board')
                    if per == 'daily':
                        daily_jobs += 1
                        if daily_jobs % G['job_streak_every'] == 0:
                            g.earn(G['job_streak_bonus'], 'job board')
        # ---------------- Standing
        S, rws = g.standing()
        gross_cum += sum(g.day_ledger.values())
        dspend = g.spend - spend0
        disc_cum += sum(g.day_ledger.values()) - sum(v for kk, v in dspend.items() if kk in ('seeds', 'chapter stages', 'stop buys and rests',
                                                                                                'own crops eaten as meals', 'materials bought'))
        if first80 is None and S >= 80:
            first80 = day
        main_done = 'M6' in g.ch_done and g.ch_step['M7'] >= 4
        if main_done and main_done_day is None:
            main_done_day, main_done_standing, main_done_rows = day, S, dict(rws)
            main_done_rows['_errands_n'] = len(g.errands_done)
            main_done_rows['_marks'] = sum(1 for st in g.bars for b in BARS3 if g.bars[st][b] >= 100)
        if main_done and S >= 80 and seal_day is None:
            seal_day = day
            xp_at_seal = (g.xp, Counter(g.xpled))
        daily.append(dict(day=day, level=g.L, xp=g.xp, petals=round(g.petals), gross=round(sum(g.day_ledger.values()), 1),
                          gross_cum=round(gross_cum), disc_cum=round(disc_cum), standing=round(S, 2), lit=len(g.lit),
                          src=dict(g.day_ledger), rows=dict(rws)))
        if seal_day and day >= max(seal_day, 40):
            break
    return dict(g=g, first80=first80, seal_day=seal_day, main_done_day=main_done_day, main_done_standing=main_done_standing,
                main_done_rows=main_done_rows, daily=daily, opt=opt, stops_per_day=stops_per_day, xp_at_seal=xp_at_seal)


def pick_money_crop(crops):
    """The buyable crop (Maplewold staple or uncommon, or a common crop) with the most Petals per bed-day, sold raw."""
    best = None
    for k, c in crops.items():
        if c['flower'] or not (c['slug'] in COMMON_CROPS or c['na_tier'] in ('staple', 'uncommon')):
            continue
        r = crop_rates(c)
        if best is None or r['petals'] > best[1]['petals']:
            best = (k, r)
    return best


def chapter_xp_table(total, share=0.35):
    """proposal-story-2-quests 1.4: the chapters of an area pay about 35% of the band's XP, split by level span."""
    spans = {'M1': 3, 'M2': 3, 'M3': 3, 'M4': 3, 'M5': 2, 'M6': 3, 'M7': 1}
    s = sum(spans.values())
    return {k: int(round(total * share * v / s)) for k, v in spans.items()}


def steady_state(region, stops_list, L, crops, acts, needs, bars, rng, days=150, beds=36):
    """Tier 2 spot check: Petals and XP per game day at level L in a region: touring 3-4 stops x 5 acts + a garden of `beds` on the
    region's best buyable crop (sold raw) + band 2 side content averaged (proposal-story-2 1.4). No chapter logic."""
    sms = [StopModel(s[0], s[1], s[4], acts, needs, bars) for s in stops_list if s[4] == region]
    best = None
    for k, c in crops.items():
        if c['flower'] or not (c['slug'] in COMMON_CROPS or c['regions'].get(region) in ('staple', 'uncommon')):
            continue
        r = crop_rates(c, L)
        if best is None or r['petals'] > best[1]['petals']:
            best = (k, r)
    basket = [crop_rates(c, L) for k, c in crops.items() if not c['flower'] and c['regions'].get(region) in ('staple', 'uncommon')]
    bask = {kk: statistics.mean(r[kk] for r in basket) for kk in ('petals', 'xp', 'energy')}
    pet = xp = 0.0
    en = 0.0
    for d in range(days):
        for sm in rng.sample(sms, rng.choice((3, 4))):
            st = {b: 0 for b in BARS3}
            pay = do_acts(sm, sm.offer(d, rng, list(BARS3), True, 0), 5, rng, st, 'list')
            pet += pay['c'] - pay['cost']
            xp += pay['xp']
            en += pay['energy'] - pay['en']
    stop_p, stop_x, stop_e = pet / days, xp / days, en / days
    garden_p, garden_x, garden_e = beds * best[1]['petals'], beds * best[1]['xp'], beds * best[1]['energy']
    return dict(crop=best[0], basket_p=beds * bask['petals'], basket_x=beds * bask['xp'], stop_p=stop_p, stop_x=stop_x, stop_e=stop_e, garden_p=garden_p, garden_x=garden_x, garden_e=garden_e,
                energy=day_energy(L))


def q(v):
    return '%s/%s/%s' % pct(v)


def main():
    global ANSWER_ACTS, THREAD_ACT, MONEY_CROP, MONEY_SELL, BASKET_SELL
    ap = argparse.ArgumentParser()
    ap.add_argument('--runs', type=int, default=400)
    ap.add_argument('--bar-runs', type=int, default=300)
    ap.add_argument('--seed', type=int, default=7)
    ap.add_argument('--csv-dir', default=os.path.join(HERE, 'sim-standing-out'))
    a = ap.parse_args()
    os.makedirs(a.csv_dir, exist_ok=True)
    rng = random.Random(a.seed)
    crops, regions = load_crops()
    acts, needs = load_acts()
    bars = load_bars()
    ANSWER_ACTS = {s: acts[s] for s in ANSWER}
    THREAD_ACT = acts['thread_go']
    mc = pick_money_crop(crops)
    MONEY_CROP, MONEY_SELL = mc[0], crops[mc[0]]['sell']
    BASKET_SELL = statistics.mean(crops[c]['sell'] for c in ASSUME['money_basket'])
    P = print

    def wcsv(name, rows_):
        with open(os.path.join(a.csv_dir, name), 'w', newline='') as f:
            w = csv.DictWriter(f, fieldnames=list(rows_[0].keys()))
            w.writeheader()
            w.writerows(rows_)

    P('LEVEL CURVE (gnome.php:289 xp_for_level, defaults steep from 10, +15%). users.xp is a running total.')
    for L in (5, 10, 15, 20, 25, 35, 45, 55):
        P('  Lv %2d: total %9d   | sum of thresholds Lv2..Lv%d (how the bands doc got 75,650): %9d' % (L, xp_for_level(L), L, sum(xp_for_level(k) for k in range(2, L + 1))))
    P('  energy a game day with one nap: Lv1 %.0f, Lv5 %.0f, Lv10 %.0f, Lv15 %.0f, Lv20 %.0f' % tuple(day_energy(x) for x in (1, 5, 10, 15, 20)))

    P('\nCROPS of the Maplewold, sold raw, per bed and game day (steady state):')
    out = []
    for k in NA_STAPLES + NA_UNCOMMON + ['flower:goldenrod', mc[0]]:
        c = crops[k]
        r = crop_rates(c)
        out.append(dict(crop=k, tier=c['tier'], perennial=c['per'], rarity=c['rarity'], base_price=c['base_price'], sell=c['sell'], seed_price=c['seed_price'],
                        xp=c['xp'], sleeps=c['sleeps'], regrow_sleeps=c['regrow_sleeps'], petals_bed_day=round(r['petals'], 2), energy_bed_day=round(r['energy'], 2)))
        P('  %-17s t%d %s rar %2d base %3d sell %3d seed %3d xp %3d sleeps %2d regrow %d -> %5.2f P / bed-day, %.2f E' % (
            k, c['tier'], 'per' if c['per'] else 'ann', c['rarity'], c['base_price'], c['sell'], c['seed_price'], c['xp'], c['sleeps'], c['regrow_sleeps'], r['petals'], r['energy']))
    P('  money crop (best buyable, Petals per bed-day): %s' % mc[0])
    wcsv('crops_na.csv', out)

    P('\nSTOP ACTS, top-of-list policy, 5 acts a visit (pay at the stop level = band floor; stops.php:670):')
    econ = []
    for region, lst in (('NA', NA_STOPS), ('CA', CA_STOPS)):
        for (name, typ, zone, kind, rg) in lst:
            if rg != region:
                continue
            sm = StopModel(name, typ, rg, acts, needs, bars)
            tot = Counter()
            for r in range(300):
                st = {b: 0 for b in BARS3}
                pay = do_acts(sm, sm.offer(r * 31 + 5, rng, list(BARS3), True, 0), 5, rng, st, 'list')
                for kk in ('c', 'xp', 'cost', 'energy', 'n', 'en'):
                    tot[kk] += pay[kk]
            n = tot['n']
            econ.append(dict(region=region, stop=name, type=typ, stop_level=sm.lvl, petals_per_act=round(tot['c'] / n, 2), spent_per_act=round(tot['cost'] / n, 2),
                             xp_per_act=round(tot['xp'] / n, 2), energy_per_act=round(tot['energy'] / n, 2)))
    for region in ('NA', 'CA'):
        e = [x for x in econ if x['region'] == region]
        P('  %s stops (level %d): Petals/act %.1f (min %.1f, max %.1f), spent/act %.1f, XP/act %.1f, energy/act %.2f' % (
            region, e[0]['stop_level'], statistics.mean(x['petals_per_act'] for x in e), min(x['petals_per_act'] for x in e),
            max(x['petals_per_act'] for x in e), statistics.mean(x['spent_per_act'] for x in e), statistics.mean(x['xp_per_act'] for x in e),
            statistics.mean(x['energy_per_act'] for x in e)))
    wcsv('stop_act_econ.csv', econ)

    # ------------------------------------------------------------------ Q4
    P('\nQ4 BAR PACE: visit-days to fill each bar, p10/p50/p90 (one visit a game day, tier 0)')
    bp_rows, pace = [], {}
    for region, lst, policy, n_acts in (('NA', NA_STOPS, 'list', 5), ('NA', NA_STOPS, 'bars', 5), ('NA', NA_STOPS, 'list', 3), ('CA', CA_STOPS, 'list', 5)):
        res = bar_pace(lst, acts, needs, bars, a.bar_runs, rng, policy, n_acts)
        pace[(region, policy, n_acts)] = res
        P('  %s, policy %s (%s), %d acts a visit' % (region, policy, 'top of the list' if policy == 'list' else 'best bar points', n_acts))
        for name, r in res.items():
            P('    %-28s %-8s R %s  L %s  C %s  all three %s' % (name, r['type'], '%2d/%2d/%2d' % r['bars']['Repairs'], '%2d/%2d/%2d' % r['bars']['Larder'],
                                                              '%2d/%2d/%2d' % r['bars']['Cheer'], '%2d/%2d/%2d' % r['all3']))
            bp_rows.append(dict(region=region, policy=policy, acts=n_acts, stop=name, type=r['type'],
                                **{'%s_p%d' % (b, p): r['bars'][b][i] for b in BARS3 for i, p in enumerate((10, 50, 90))},
                                all3_p10=r['all3'][0], all3_p50=r['all3'][1], all3_p90=r['all3'][2]))
        single = [r['bars'][b][1] for r in res.values() for b in BARS3]
        allm = [r['all3'][1] for r in res.values()]
        P('    single bar median over stops x bars: %.1f (range %d-%d); all three at one stop, median of medians %.1f (range %d-%d); share of bars with median in 6-10: %.0f%%' % (
            statistics.median(single), min(single), max(single), statistics.median(allm), min(allm), max(allm), 100 * sum(1 for x in single if 6 <= x <= 10) / len(single)))
        lat = latch_all(res, (3, 4), 300, rng)
        P('    days to latch every bar of these %d stops (3-4 stops a day, perfect routing): p10 %d, p50 %d, p90 %d' % ((len(res),) + lat))
    wcsv('bar_pace.csv', bp_rows)

    # ------------------------------------------------------------------ Maplewold runs
    MAIN_ONLY = dict(opt_pursuit=(0.0, 0.0), meter_from='main')
    variants = [('non-fighter', False, 'rebased', False, {}), ('fighter', True, 'rebased', False, {}),
                ('non-fighter main-line-only', False, 'rebased', False, MAIN_ONLY), ('fighter main-line-only', True, 'rebased', False, MAIN_ONLY),
                ('non-fighter', False, 'rebased', True, {}), ('non-fighter 16 beds', False, 'rebased', False, dict(beds_by_level={1: 16})),
                ('non-fighter all-best-crop', False, 'rebased', False, dict(money_mode='best')),
                ('non-fighter', False, 'doc', False, {}), ('fighter', True, 'doc', False, {})]
    summary, traj, lvl_rows, run_rows = {}, [], [], []
    for arch, fighter, cxp, jobs, over in variants:
        chxp = chapter_xp_table(xp_for_level(15) if cxp == 'rebased' else 75650)
        saved = {kk: ASSUME[kk] for kk in over}
        ASSUME.update(over)
        res = [run_gnome(a.seed * 1000 + i, crops, acts, needs, bars, fighter, chxp, jobs_on=jobs) for i in range(a.runs)]
        ASSUME.update(saved)
        key = '%s, chapter XP %s, jobs %s' % (arch, cxp, 'on' if jobs else 'off')
        summary[key] = res
        for i, r in enumerate(res):
            run_rows.append(dict(variant=key, run=i, opt=round(r['opt'], 2), stops_per_day=r['stops_per_day'], main_done_day=r['main_done_day'],
                                 standing_main_done=round(r['main_done_standing'] or 0, 2), first80=r['first80'], seal_day=r['seal_day'],
                                 lamp7_day=r['g'].lamp7_day, stall_days=r['g'].stall_days, level_end=r['g'].L, xp_end=r['g'].xp,
                                 **{'row_' + kk.strip('_'): round(v, 2) for kk, v in (r['main_done_rows'] or {}).items()}))
        P('\n[%s]  chapter XP table %s; overrides %s' % (key, chxp, over or '-'))
        mdd = [r['main_done_day'] or 999 for r in res]
        mds = [r['main_done_standing'] for r in res if r['main_done_standing'] is not None]
        f80 = [r['first80'] or 999 for r in res]
        seal = [r['seal_day'] or 999 for r in res]
        P('  main line done (M1-M6 and M7 steps 1-4), game day p10/p50/p90: %s' % q(mdd))
        P('  Standing on that day p10/p50/p90: %.1f/%.1f/%.1f; share >= 80: %.0f%%, >= 78: %.0f%%, >= 75: %.0f%%' % (
            tuple(pct(mds)) + tuple(100 * sum(1 for x in mds if x >= t) / len(mds) for t in (80, 78, 75))))
        P('  Seal day (main line done and Standing 80) p10/p50/p90: %s;  no Seal by day 90: %.1f%%' % (q(seal), 100 * sum(1 for x in seal if x == 999) / len(seal)))
        P('  extra game days from main line done to the Seal: p50 %d, p90 %d; share needing any: %.0f%%' % (
            pct([s - m for s, m in zip(seal, mdd)])[1], pct([s - m for s, m in zip(seal, mdd)])[2], 100 * sum(1 for s, m in zip(seal, mdd) if s > m) / len(seal)))
        rowmed = defaultdict(list)
        for r in res:
            for kk, v in (r['main_done_rows'] or {}).items():
                if not kk.startswith('_'):
                    rowmed[kk].append(v)
        P('  chapter done on game day, median: ' + ', '.join('%s %s' % (c[0], statistics.median([r['g'].ch_day.get(c[0], 999) for r in res])) for c in CH))
        P('  marks latched (full bars of 54) on the main-line-done day: %s' % q([(r['main_done_rows'] or {}).get('_marks', 0) for r in res]))
        P('  rows on the main-line-done day, median (p10): ' + ', '.join('%s %.1f (%.1f)' % (kk, statistics.median(v), pct(v)[0]) for kk, v in rowmed.items()))
        lv_seal = [next((d['level'] for d in r['daily'] if d['day'] == r['seal_day']), r['g'].L) for r in res]
        P('  level on the Seal day p10/p50/p90: %s' % q(lv_seal))
        P('  game days on which a lamp, stall or stage waited for Petals: p50 %d, p90 %d, share of runs with any: %.0f%%' % (
            pct([r['g'].stall_days for r in res])[1], pct([r['g'].stall_days for r in res])[2], 100 * sum(1 for r in res if r['g'].stall_days) / len(res)))
        sb = Counter()
        for r in res:
            sb.update(r['g'].stall_by)
        P('  stalled step-days by cause, mean per run: ' + ', '.join('%s %.1f' % (kk, v / len(res)) for kk, v in sb.most_common()))
        P('  7th lamp lit on game day p10/p50/p90: %s' % q([r['g'].lamp7_day or 999 for r in res]))
        P('  Stops-row Petals actually paid (fee + tier 1 + tier 2): median %d' % statistics.median(r['g'].spend['stops row (fee + tiers)'] for r in res))
        g20 = [next((d['gross_cum'] for d in r['daily'] if d['day'] == 20), r['daily'][-1]['gross_cum']) for r in res]
        g35 = [next((d['gross_cum'] for d in r['daily'] if d['day'] == 35), r['daily'][-1]['gross_cum']) for r in res]
        d20 = [next((d['disc_cum'] for d in r['daily'] if d['day'] == 20), r['daily'][-1]['disc_cum']) for r in res]
        d35 = [next((d['disc_cum'] for d in r['daily'] if d['day'] == 35), r['daily'][-1]['disc_cum']) for r in res]
        aff_g = [next((d['day'] for d in r['daily'] if d['gross_cum'] >= 3600), 999) for r in res]
        aff_d = [next((d['day'] for d in r['daily'] if d['disc_cum'] >= 3600), 999) for r in res]
        P('  gross Petals by day 20: %s; by day 35: %s' % (q(g20), q(g35)))
        P('  free Petals (gross - seeds, stage Petals, stop buys, meals eaten, bought rope/wax) by day 20: %s; by day 35: %s' % (q(d20), q(d35)))
        P('  game day when gross reaches 3,600: %s; when free Petals reach 3,600: %s' % (q(aff_g), q(aff_d)))
        led, sp, xl = Counter(), Counter(), Counter()
        nd = sum(len(r['daily']) for r in res)
        for r in res:
            led.update(r['g'].ledger)
            sp.update(r['g'].spend)
        P('  Petals in per game day, all days: ' + ', '.join('%s %.0f' % (kk, v / nd) for kk, v in led.most_common()))
        P('  Petals out per game day: ' + ', '.join('%s %.0f' % (kk, v / nd) for kk, v in sp.most_common()))
        xs = [r['xp_at_seal'] for r in res if r['xp_at_seal']]
        for xx in xs:
            xl.update(xx[1])
        P('  XP earned by the Seal day, median total %d (Lv 15 needs %d; doc says 75,650); mean by source: %s' % (
            statistics.median(x[0] for x in xs), xp_for_level(15), ', '.join('%s %.0f' % (kk, v / len(xs)) for kk, v in xl.most_common())))
        bylev = defaultdict(lambda: defaultdict(list))
        for r in res:
            for d in r['daily']:
                for kk in ('stop acts', 'crop sales', 'chapters', 'errands', 'threads', 'passport', 'adopter welcome', 'fights', 'job board'):
                    bylev[d['level']][kk].append(d['src'].get(kk, 0))
                bylev[d['level']]['gross'].append(d['gross'])
        P('  gross Petals per game day by level (mean): ' + ', '.join('L%d %d' % (lv, statistics.mean(v['gross'])) for lv, v in sorted(bylev.items())))
        for lv, v in sorted(bylev.items()):
            lvl_rows.append(dict(variant=key, level=lv, days=len(v['gross']), gross=round(statistics.mean(v['gross']), 1),
                                 **{kk.replace(' ', '_'): round(statistics.mean(v[kk]), 1) for kk in ('stop acts', 'crop sales', 'chapters', 'errands', 'threads',
                                                                                                        'passport', 'adopter welcome', 'fights', 'job board')}))
        for D in range(1, 91):
            ds = [x for x in (next((d for d in r['daily'] if d['day'] == D), None) for r in res) if x]
            if len(ds) < len(res) * 0.5:
                break
            sts = [x['standing'] for x in ds]
            traj.append(dict(variant=key, day=D, runs=len(ds), level=statistics.median(x['level'] for x in ds), petals=statistics.median(x['petals'] for x in ds),
                             gross_cum=statistics.median(x['gross_cum'] for x in ds), lit=statistics.median(x['lit'] for x in ds),
                             standing_p10=pct(sts)[0], standing_p50=pct(sts)[1], standing_p90=pct(sts)[2]))
    wcsv('standing_by_day.csv', traj)
    wcsv('runs.csv', run_rows)
    wcsv('petals_by_level.csv', lvl_rows)

    # ------------------------------------------------------------------ the Owl and threshold what-ifs (non-fighter, base)
    base = summary['non-fighter, chapter XP rebased, jobs off']
    P('\nWHAT-IFS on the non-fighter base runs (Standing on the main-line-done day):')
    mds = [r['main_done_standing'] for r in base]
    no_owl = [r['main_done_standing'] - r['main_done_rows']['lair'] for r in base]
    P('  as run (Owl evenings done, M7 step 3): p10/p50/p90 %.1f/%.1f/%.1f' % pct(mds))
    P('  without the Owl row: %.1f/%.1f/%.1f, share >= 80: %.0f%%' % (pct(no_owl) + (100 * sum(1 for x in no_owl if x >= 80) / len(no_owl),)))
    def alt(rws, thr_lit=7, err_need=5, owl=True):
        v = sum(x for kk, x in rws.items() if not kk.startswith('_'))
        if not owl:
            v -= rws['lair']
        n_lit = round(rws['lit'] / 2)   # 2 points a lamp up to 7
        v += W_LIT * min(1, n_lit / thr_lit) - rws['lit']
        v += W_ERRANDS * min(1, rws['_errands_n'] / err_need) - rws['errands']
        return v
    for lbl, runs_ in (('base non-fighter', base), ('main-line-only non-fighter', summary['non-fighter main-line-only, chapter XP rebased, jobs off'])):
        rr = [r['main_done_rows'] for r in runs_ if r['main_done_rows']]
        for name_, kw, thr in (('as proposed (80)', {}, 80), ('threshold 75', {}, 75), ('as proposed, Owl not done', dict(owl=False), 80),
                               ('threshold 75, Owl not done', dict(owl=False), 75), ('errands row needs 3 (not 5)', dict(err_need=3), 80),
                               ('errands 3, Owl not done', dict(err_need=3, owl=False), 80), ('errands 3 + threshold 78, Owl not done', dict(err_need=3, owl=False), 78)):
            vals = [alt(x, **kw) for x in rr]
            P('  %-28s %-40s Standing p10/p50 %.1f/%.1f, share at or over %d: %.0f%%, median slack %.1f' % (
                lbl, name_, pct(vals)[0], pct(vals)[1], thr, 100 * sum(1 for x in vals if x >= thr - 1e-9) / len(vals), statistics.median(vals) - thr))
    ceil_nf = W_LIT + W_RAISED * 8 / 12 + HEARTH_PTS[2] + W_REPAIR + W_PLACES + 15 + 15 + W_LAIR + W_PAGES
    P('  ceiling for a non-fighter, 7 lit, Hearth tier 2, every other row full: %.1f (master: 87.7)' % ceil_nf)

    # ------------------------------------------------------------------ Q5 Maizehollow steady state
    P('\nQ5 MAIZEHOLLOW (tier 2) steady state, 36 beds, 3-4 stops x 5 acts a day:')
    for L in (15, 18, 21, 24):
        s = steady_state('CA', CA_STOPS, L, crops, acts, needs, bars, rng)
        en_need = s['stop_e'] + s['garden_e']
        P('  Lv %d: stops %.0f P %.0f XP (%.1f E); garden all-%s %.0f P %.0f XP (%.1f E), or basket of CA crops %.0f P %.0f XP; energy a day %.0f -> Petals %.0f-%.0f, XP %.0f-%.0f a game day' % (
            L, s['stop_p'], s['stop_x'], s['stop_e'], s['crop'], s['garden_p'], s['garden_x'], s['garden_e'], s['basket_p'], s['basket_x'], s['energy'],
            s['stop_p'] + s['basket_p'], s['stop_p'] + s['garden_p'], s['stop_x'] + s['basket_x'], s['stop_x'] + s['garden_x']))
    sNA = steady_state('NA', NA_STOPS, 8, crops, acts, needs, bars, rng, beds=24)
    P('  (Maplewold at Lv 8, 24 beds, same method: stops %.0f P, garden %.0f P, XP %.0f)' % (sNA['stop_p'], sNA['garden_p'], sNA['stop_x'] + sNA['garden_x']))
    P('  XP Lv 15 -> 25: %d; band XP rebased 35%% chapter share over the 8 chapters of the two areas: %d' % (xp_for_level(25) - xp_for_level(15), int(0.35 * (xp_for_level(25) - xp_for_level(15)))))
    return summary


if __name__ == '__main__':
    main()
