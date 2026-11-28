#!/usr/bin/env python3
"""Write the impact raises: every perk the impact model marks LOW gets a wider trigger or a bigger size.

Proposal tooling only. Run once on the set as it was before the raises (it takes any applied raises out first):

    python3 claude/tools_perk_impact_raise.py     # rewrites the RAISES and VETO3 block at the end of tools_audit_stop_perks_fixes.py
    python3 claude/tools_audit_stop_perks.py --fix   # applies them and audits (must end with 0 errors)

Order of preference (Josh): (a) widen the trigger, (b) raise the size to at most 2% (or 1 -> 2 units), (c) a narrow place
perk that is still LOW goes to 3% and onto the veto list (VETO3). World perks stay inside their family caps.
"""
import itertools
import os
import re
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import tools_audit_stop_perks as A   # noqa: E402
import tools_perk_impact as I        # noqa: E402

F_FIXES = os.path.join(A.CL, 'tools_audit_stop_perks_fixes.py')
HDR = {A.F_MAIN: ['Stop', 'Bar', 'Perk', 'Effect', 'Size', 'Family'],
       A.F_A: ['Stop', 'Type', 'Bar', 'Perk', 'Icon', 'Effect', 'Size', 'Scope', 'Family'],
       A.F_B: ['Stop', 'Type', 'Bar', 'Perk', 'Icon', 'Effect', 'Size', 'Scope', 'Family'],
       A.F_C: ['Stop', 'Type', 'Bar', 'Perk', 'Effect', 'Size', 'Scope', 'Family']}
RP = {'NA': "the Maplewold's", 'CA': "Maizehollow's", 'NWE': "Mistmoor's", 'CB': "the Sunsprinkle Isles'", 'SA': "the Rainroot Reaches'",
      'SE': "Olivewhistle Shore's", 'EE': "Birchbramble Steppe's", 'MENA': "the Dunewhisper's", 'WCA': "the Greatcanopy's",
      'ESA': "Thornacre Savanna's", 'CSA': "Spicepeak's", 'EA': "Blossomreach's", 'SEA': "the Monsoon Tangle's", 'OC': "the Coralscatter's"}

# ------------------------------------------------------------------ hand-written raises (name -> new effect, new size or None)
WORLD_NEW = {
    'Level Scales': ('Everything you sell in a shop sells for 1% more', None),
    'Second Breakfast': ('Home-cooked dishes eaten at dawn or by day give 2% more energy', None),
    'Tidy Skeps': ('Pests are 2% less likely on flowers, herbs and fruit crops', None),
    'Honey in the Tea': ('Boosts from teas, other drinks and sweets last 2% longer', None),
    'Greased Wheel': ('Breads, bakes, porridges and anything else with grain in it cook 2% faster', None),
    "Miller's Pinch": ('Oat, lentil, soybean and kidney bean harvests: 2% chance of one extra', '+2%'),
    'Dry Woodpile': ('Resting on any trail heals 2% more', None),
    "Squirrel's Arithmetic": ('Gathering in forest and grassland: 2% chance of one extra', '+2%'),
    'Fireside Regular': ('Stop checks are 1% kinder', None),
    'Sawdust Mulch': ('Watering lasts 2% longer in dry weather (sun, cloud, heat or wind)', None),
    'Swept Steps': ('1% better chance to spot hidden things', None),
    'What You Leave Comes Back': ('Every crop: 1% more chance of a seed back', None),
    'Sound Nets': ('Stop acts that cost energy pay 2% more coins', None),
    'Catch of the Day': ('Fish, gathered finds and dishes sell for 2% more', '+2%'),
    'Beaver-Tight Hull': ('Fast travel costs 1% less', None),
    "Porter's Crate": ('Shops charge 1% less', None),
    "Watcher's Flask": ('Walking in rain, storm, snow, frost, fog or wind takes 2% less time', '-2%'),
    'Warm to the Bones': ('Healing is 2% stronger in rain, storm, snow, frost, fog or wind', None),
    'Border Lamp': ('Walking takes 1% less time', None),
    'Up With the Lark': ('1% more XP', None),
    'Tailwind': ('2% more XP in wind, storm, rain, snow, frost or fog', None),
    'Propped Boughs': ('1% more garden XP', None),
    'Stacked Birch': ('Syrups, sweets, preserves and drinks cook 2% faster', None),
    'Brim-Full Bucket': ('Harvests from trees, bushes and vines (anything that regrows): 2% chance of one extra', '+2%'),
}
PLACE_NEW = {   # name -> (effect, size or None, scope cell or None)
    'The Straightened Signpost': ("Walks on the Maplewold's forest, grassland and wetland roads take 2% less time", None, None),
    # rest energy (+1 is already 25% of a rest act): stays at its own stop, with a condition that holds about half the time or more
    'Restrung Hammocks': ('Rest acts at Meadowmere give 1 more energy in spring and summer', None, 'P `from=` `se=spring,summer`'),
    'Split Birch for the Stove': ('Rest acts at the Northern Lights Sauna give 1 more energy outside summer', None, 'P `from=` `se=autumn,winter,spring`'),
    'Tree Frogs at Bath Time': ('Rest acts at Lianacombe give 1 more energy under cloud, in rain, storm or fog', None, 'P `from=` `we=cloud,rain,storm,fog`'),
    'Recut Stone Tubs': ('Rest acts at Highcove give 1 more energy before dusk', None, 'P `from=` `dp=dawn,day`'),
    'Steam Up to the Chin': ('Rest acts at Cragholt give 1 more energy in rain, storm, snow, frost, fog or wind', None, None),
    'Rooftop Bed Under the Stars': ('Rest acts at Gullwell give 1 more energy on windy, hot or clear days', None, None),
    'Mossy Pool Lip, Scrubbed': ('Rest acts at Mistcrest give 1 more energy in autumn and winter, while the mist is in', None, None),
    'Stew for Whoever Comes': ('Rest acts at the Drum Circle Market give 1 more energy by day and at dusk, while the stew is on', None, None),
    'Relined Rift Pool': ('Rest acts at Pinecombe give 1 more energy after dawn', None, None),
    'Dry Bedding in the Wet': ('Rest acts at Lilyby give 1 more energy in any weather but clear sun', None, None),
    'Capped Bore, No Leaks': ('Rest acts at Miragewell give 1 more energy on hot, sunny or cloudy days', None, None),
    'Lemon-Verbena Tisane': ('Dishes with lemon verbena, fava bean or oregano give boosts that last 2% longer', None, 'P items=local'),
    "This Year's Stone": ("+1 max health on the Maplewold's mountain and tundra trails", None, None),
    'Goat-Track Pickings': ("Gathering on the Maplewold's mountain, tundra, coast and wetland trails: 2% chance of one extra", '+2%', None),
}
DAILY_NEW = {
    'Two From One Stone': 'Once a day, your first avocado or papaya harvest gives one extra of that crop',
    'A Wish per Shooting Star': 'First rest act at Scorchburrow each day: 2 coins turn up in the sand',
    'Knapped a Fresh Edge': 'Once a day, the first wear on your rock pick anywhere in Maizehollow is skipped',
    'Dry Kindling Under Cover': 'Once a day, the first check act you do at Fernden costs 1 less energy',
    'Driftwood Fence Mended': 'Once a day, the first tend or mend act you do at Turtle Nesting Beach costs 1 less energy',
    'Head in the Clouds': 'Once a day, a failed Lore check at the Sky City Ruins or at any other wonder or delve of the Rainroot Reaches is rolled again',
    "Watcher's Trail Mix": "Once a day, the first walk that starts at Flintburrow or runs along the road to Condor's Crag costs 1 less energy",
    'Saddle on the Rail': 'Once a day, the first walk on a grassland or desert road of the Rainroot Reaches costs 1 less energy (saddled at the Gaucho Gnome Ranch)',
    'Lamp in the Window': 'Once a day, the first walk that starts or ends at Brinewick costs 1 less energy',
    'Crates on the Quay': "Once a day, the first seed you buy at any stall in Olivewhistle Shore comes with one extra (Driftmead's crates)",
    "Beachcomber's Pot": 'First visit to Turtlenook each day: one spiral shell (`spiral-shell`) from the tideline',
    'Ash-Baked Eggs': "Once a day, the first dish you eat anywhere in Olivewhistle Shore also heals 2 health (an egg from Cragholt's ashes)",
    'Says It Back Twice': 'Once a day, a lost contest at Echonook or anywhere else in Olivewhistle Shore is tried again',
    'Bowl Under the Bridge': "Once a day, the first gift of a common local crop to anyone in Birchbramble Steppe is not used up (Mossknoll's bowl)",
    'Cedar-Shaving Broom': 'Once a day, a craft act at Cragmead or anywhere else in the Dunewhisper that fails gives its ingredients back',
    'Tent Ropes Against the Wind': "Once a day, the first walk on a desert road of the Dunewhisper costs 1 less energy (Sandbottom's ropes hold)",
    'Grilled-Fish Night': "The first thing you sell each day at Driftglen's stall pays 2 coins more",
    'Banana-Leaf Thatch': 'The first walk each day on a grassland road of the Savanna costs 1 less energy (shade from Meadowbottom)',
    'The Baboon Has Your Towel': 'Once a day, a lost contest at Pinecombe or anywhere else in the Savanna can be played again',
    'Net Mended by the Ferryman': 'Once a day, the first wear on your bug net anywhere in the Savanna is skipped',
    'Caulked Delta Boat': 'The first walk each day on a wetland road of Spicepeak costs 1 less energy (poled from Newtdell)',
    'Purple to the Elbows': 'The first mulberry or jackfruit harvest each day gives one extra of that crop',
    'Red Envelope': 'The first act you do each day in Blossomreach pays 2 coins more',
    'Mussel Rack at Low Tide': 'First visit to Sprayholt each day: one handful of mussels (`blue-mussels`)',
    'Noodles Sold from the Wok': 'The first dish you sell each day at any stall in the Monsoon Tangle pays 2 coins more',
    'Sticky Rice in a Leaf': 'First visit to Lilyby each day: one parcel of rice (`rice`)',
    'Supper on a Banana Leaf': "Once a day, a dish cooked at Canopyford's fire or at any other stop fire in the Monsoon Tangle gives one ingredient back",
    'Salt-Crusted Catch': 'Once a day, the first thing you find on a walk from Salthollow comes with one pinch of sea salt (`sea-salt`)',
    'Trued Boomerang': "Once a day, when a walk in the Coralscatter finds nothing, your gnome looks once more (Oasiswick's boomerang comes back)",
}
CHAMP = {   # family -> region-wide text; {Rp} = the region, {L} = its landscapes
    'F01': 'Stalls in {Rp} {L} zones pay 2% more for what you sell',
    'F02': 'Stalls in {Rp} {L} zones charge 2% less',
    'F03': 'Acts at stops in {Rp} {L} zones give 2% more XP',
    'F05': 'Walks in {Rp} {L} zones take 2% less time',
    'F06': 'Pots you cook while in {Rp} {L} zones cook 2% faster',
    'F07': 'Dishes eaten in {Rp} {L} zones give 2% more energy',
    'F08': 'Boosts from anything eaten or drunk in {Rp} {L} zones last 2% longer',
    'F09': 'Rest acts and trail rests in {Rp} {L} zones heal 2% more',
    'F11': 'Gathering in {Rp} {L} zones: 2% chance of one extra',
    'F14': 'Chats and gifts with folk in {Rp} {L} zones: 2% chance of +1 friendship',
    'F15': 'Acts at stops in {Rp} {L} zones pay 2% more coins',
    'F16': 'Stop checks in {Rp} {L} zones are 2% kinder',
    'F18': 'Fast travel that starts in {Rp} {L} zones costs 2% less',
    'F19': 'Walks in {Rp} {L} zones: 2% better chance to spot hidden things',
    'F23': 'Fast travel that starts in {Rp} {L} zones: 2% more chance to turn up a seed',
}
CROP_TXT = {
    'F04': '{C} give 2% more garden XP',
    'F10': '{C} harvests: 2% chance of one extra',
    'F12': 'Watering lasts 2% longer on {c}',
    'F13': '{C} harvests: 2% more chance of a seed back',
    'F17': 'Pests are 2% less likely on {c}',
    'F06': 'Dishes with {o} in them cook 2% faster',
    'F07': 'Dishes with {o} give 2% more energy',
    'F08': 'Dishes with {o} give boosts that last 2% longer',
    'F14': 'Gifts of {o}: 2% chance of +1 friendship',
}
SIGN = {'F02': '-', 'F05': '-', 'F06': '-', 'F17': '-', 'F18': '-'}
NEED = I.THRESH_R


def join(names, word='and'):
    names = list(names)
    return names[0] if len(names) == 1 else ', '.join(names[:-1]) + ' ' + word + ' ' + names[-1]


def crop_ok(region, slug):
    """A crop whose name the audit reads back as exactly that crop."""
    return A.crops_in('Watering lasts 2% longer on ' + A.CROP_NAME[slug], region) == {slug}


def stop_lands():
    """Stop -> its own landscape: the land of the side path that ends there, else of most of its roads (`route-list.md`)."""
    side, alln = {}, defaultdict(list)
    for ln in A.read(A.F_ROUTES).splitlines():
        if ln.startswith('| ') and re.match(r'^\| \d+', ln):
            c = A.cells(ln)
            ends = [A.norm_stop(re.sub(r' \((town|village|haven|wonder|delve|lair)\)$', '', x)) for x in (c[1], c[2])]
            for e in ends:
                alln[e].append(c[3])
            if c[4] == '2':
                side.setdefault(ends[1], c[3])
    return {s: side.get(s) or max(set(v), key=v.count) for s, v in alln.items()}


def main():
    home = stop_lands()
    A.apply_fixes(raise_too=False)        # the set before any raise
    if A.errors:
        print('\n'.join(A.errors))
        sys.exit(1)
    perks = A.parse_all()
    est = {d['id']: d for d in I.estimate_all()}
    lines = {p: A.read(p).splitlines() for p in HDR}
    text = {p: A.read(p) for p in HDR}
    out, veto, log = [], [], []

    def pid(p):
        return '%s:%s:%s' % (p.region, p.stop, p.bar)

    def low(p):
        return est[pid(p)]['status'] == 'LOW'

    def emit(p, effect, size=None, scope=None, why=''):
        hdr = HDR[p.file]
        raw = lines[p.file][p.line - 1].split('|')
        new = list(raw)
        new[hdr.index('Effect') + 1] = ' ' + effect + ' '
        if size:
            new[hdr.index('Size') + 1] = ' ' + size + ' '
        if scope and 'Scope' in hdr:
            new[hdr.index('Scope') + 1] = ' ' + scope + ' '
        i = hdr.index('Perk') + 1
        old_s, new_s = '|' + '|'.join(raw[i:]), '|' + '|'.join(new[i:])
        assert text[p.file].count(old_s) == 1, (p.name, text[p.file].count(old_s))
        d = est[pid(p)]
        out.append((A.SHORT[p.file], old_s, new_s, 'impact: ' + why + ' (was %s)' % (('%.2f%% of its domain' % (d['r'] * 100)) if p.fam in A.FAM else
                                                                               ('used %s' % I.every(d['felt'])))))
        m = re.search(r'(\d)%', size or '')
        if m and m.group(1) == '3':
            veto.append(p.key())

    def scope_cell(p, kind, extra=''):
        if p.file == A.F_A:
            return {'region': 'P `region=%s`' % p.region, 'crops': 'P `items=local:` ' + extra}[kind]
        return {'region': 'P region=%s' % p.region, 'crops': 'P items=local'}[kind]

    def bump3(p, why):
        eff = re.sub(r'\b[12]%', '3%', p.effect, count=1)
        emit(p, eff, SIGN.get(p.fam, '+') + '3%', None, why)

    done = set()
    # 1. hand-written: world perks, the Maplewold place perks, daily charges
    for p in perks:
        if p.cls == 'W' and p.name in WORLD_NEW and low(p):
            eff, size = WORLD_NEW[p.name]
            emit(p, eff, size, None, 'world perk, trigger widened' + (', size 1 to 2% inside the family cap' if size else ''))
            done.add(p.name)
        elif p.name in PLACE_NEW and low(p):
            eff, size, sc = PLACE_NEW[p.name]
            emit(p, eff, size, sc, 'condition widened' if p.fam == 'F22' else 'wider trigger')
            done.add(p.name)
        elif p.name in DAILY_NEW and low(p):
            emit(p, DAILY_NEW[p.name], None, None, 'daily charge, trigger widened')
            done.add(p.name)

    # 2. crop perks: more of the region's crops (staples first), one crop per family per region (rule P3)
    by = defaultdict(list)
    for p in perks:
        if p.cls == 'P' and p.fam in CROP_TXT and A.crop_scoped(p) and p.region != 'NA':
            by[(p.region, p.fam)].append(p)
    reserved = defaultdict(set)   # crops of daily harvest gifts count as F10
    for p in perks:
        if p.fam == 'A3' and 'harvest' in p.effect.lower():
            eff = DAILY_NEW.get(p.name, p.effect)
            reserved[(p.region, 'F10')] |= A.crops_in(eff, p.region)
    for (reg, fam), ps in sorted(by.items()):
        dish = fam in ('F06', 'F07', 'F08')
        allc = [c for t in ('staple', 'uncommon', 'treasure') for (r, c), tt in I.CROP_TIER.items() if r == reg and tt == t]
        cur = {}
        for p in ps:
            c0 = A.crops_in(p.effect, reg)
            if low(p) and len(c0) >= len(allc) - 1:
                c0 = set()                       # "local crops" = the whole region: start again from named crops
            cur[p.name] = [c for c in allc if c in c0]
        used = set(reserved[(reg, fam)])
        for v in cur.values():
            used |= set(v)
        pool = [c for c in allc if c not in used and crop_ok(reg, c)]

        def metric(p):
            q = I.crop_share(reg, cur[p.name])
            if fam == 'F14':
                return q * 0.5
            return I.dish_share(q) if dish else q
        lows = [p for p in ps if low(p)]
        while pool:
            need = [p for p in lows if metric(p) * 0.02 < NEED]
            if not need:
                break
            p = min(need, key=metric)
            cur[p.name].append(pool.pop(0))
        for p in lows:
            m = metric(p)
            names = [A.CROP_NAME[c] for c in cur[p.name]]
            size = 2 if m * 0.02 >= NEED else 3
            eff = CROP_TXT[fam].format(C=join(names).capitalize(), c=join(names), o=join(names, 'or')).replace('2%', '%d%%' % size)
            got = A.crops_in(eff, reg)
            assert got == set(cur[p.name]), (p.name, eff, got, cur[p.name])
            emit(p, eff, SIGN.get(fam, '+') + '%d%%' % size, scope_cell(p, 'crops', ', '.join(cur[p.name])),
                 'crop perk widened to %d crops (%.0f%% of the %s)' % (len(names), m * 100, 'dishes' if dish else 'beds')
                 + (', then 3% (veto list)' if size == 3 else ''))
            done.add(p.name)

    # 3. other place perks: one region-wide champion per family per region (rule P3), the rest to 3%
    grp = defaultdict(list)
    for p in perks:
        if p.cls == 'P' and p.fam in A.FAM and p.fam not in ('F20', 'F21') and p.region != 'NA' and not (p.fam in CROP_TXT and A.crop_scoped(p)):
            grp[(p.region, p.fam)].append(p)
    used_land = defaultdict(set)
    for (reg, fam), ps in sorted(grp.items()):
        lows = [p for p in ps if low(p) and p.name not in done]
        if not lows:
            continue
        has_region_ok = any(I.is_region(p) and not low(p) for p in ps)
        champ = None
        if not has_region_ok and fam in CHAMP:
            champ = next((p for p in lows if I.is_region(p)), lows[0])
            lands = I.LAND[reg]
            tot = sum(lands.values())
            cands = []
            for n in (1, 2, 3):
                for combo in itertools.combinations(sorted(lands, key=lambda l: -lands[l]), n):
                    sh = sum(lands[l] for l in combo) / tot
                    if sh >= 0.5:
                        cands.append((n, -sh, combo))
            mine = home.get(champ.stop)
            cands.sort(key=lambda x: (0 if mine in x[2] else 1,) + x)       # the stop's own landscape first
            combo = next(c for own, n, sh, c in [(0,) + x for x in cands] if frozenset(c) not in used_land[fam])
            used_land[fam].add(frozenset(combo))
            eff = CHAMP[fam].format(Rp=RP[reg], L=join(combo))
            size = None if fam == 'F22' else SIGN.get(fam, '+') + '2%'
            emit(champ, eff, size, scope_cell(champ, 'region'),
                 'region-wide in %d of its landscapes (%.0f%% of the region; the stop is in the %s)' % (len(combo), 100 * sum(lands[l] for l in combo) / tot, mine))
            done.add(champ.name)
        for p in lows:
            if p is champ:
                continue
            if fam == 'F22':
                eff = re.sub(r'(give 1 more energy).*$', r'\1 after dawn', p.effect)
                emit(p, eff, None, None, 'condition widened to any time after dawn (the region-wide slot of this family is taken)')
            else:
                bump3(p, 'narrow place perk, the region-wide slot of this family is taken: 3% (veto list)')
            done.add(p.name)

    # 4. the prose around the tables: budgets, sizes, the master's Maplewold table
    def doc(fkey, old, new, why):
        path = {'main': A.F_MAIN, 'A': A.F_A, 'B': A.F_B, 'C': A.F_C, 'master': os.path.join(A.CL, 'PROPOSAL-HOLLOW-MASTER.md')}[fkey]
        n = A.read(path).count(old)
        if n != 1:
            print('DOC ROW SKIPPED (%s, found %dx): %s' % (fkey, n, old[:80]))
            return
        out.append((fkey, old, new, 'impact doc: ' + why))

    n_file = defaultdict(int)
    for fkey, o, n, why in out:
        n_file[fkey] += 1
    world = {'F01': (2, 3), 'F05': (2, 3), 'F10': (2, 4), 'F11': (1, 2)}
    labA = {'F01': 'sell', 'F05': 'walk time', 'F10': 'harvest extra', 'F11': 'gather extra'}
    labB = {'F01': 'sell', 'F05': 'walk', 'F10': 'harvest', 'F11': 'gather'}
    capC = {'F01': '+5%', 'F05': '-6%', 'F10': '+4%', 'F11': '+4%'}
    for f, (was, now) in world.items():
        cap = A.FAM[f][2]
        doc('A', '| %s | %s | %d | %d | %d | **0** |' % (f, labA[f], cap, was, cap - was), '| %s | %s | %d | %d | %d | **0** |' % (f, labA[f], cap, now, cap - now), 'world use after the raise')
        doc('B', '| %s %s | %d%% | %d | %d | **0** |' % (f, labB[f], cap, was, cap - was), '| %s %s | %d%% | %d | %d | **0** |' % (f, labB[f], cap, now, cap - now), 'world use after the raise')
        doc('C', '| %s | %s | %s | %d | %d | **0** |' % (f, labA[f], capC[f], was, cap - was), '| %s | %s | %s | %d | %d | **0** |' % (f, labA[f], capC[f], now, cap - now), 'world use after the raise')
    note3 = ' Impact pass 2026-11-27: every % family may be 2% a perk, and the narrow place perks on the veto list of `proposal-perk-impact.md` are at 3%.'
    for fkey, old in (('A', '- Size: 1% or 2%, +1 energy, +1 torch step, +1 max health. Nothing above 2%.'),
                      ('B', '- Nothing is above 2%, +1 of a small unit, or one charge a game day (game day = a sleep, `gclock_my_date()`, not midnight).'),
                      ('B', '- No number above 2%; every +1 is energy, a torch step or a health point; every daily perk is one charge.'),
                      ('C', '- Sizes: 1% or 2%, +1 energy, +1 torch step, one item, 2 coins. Nothing above 2%. One perk per family per stop.')):
        doc(fkey, old, old + note3, 'size note')
    for fkey in ('A', 'B', 'C'):
        doc(fkey, 'Status: proposal only, no game code changed. 2026-11-27.',
            'Status: proposal only, no game code changed. 2026-11-27.\nImpact pass 2026-11-27 (`proposal-perk-impact.md`): %d perk rows of this file have a wider trigger or a bigger size '
            '(`RAISES` in `tools_audit_stop_perks_fixes.py`). The perk tables are current; prose notes below may still describe a perk\'s first, narrower scope.' % n_file[fkey], 'status line')
    doc('main', 'rules P2 to P4 added to 4.1; section "Hook list" before section 9.',
        'rules P2 to P4 added to 4.1; section "Hook list" before section 9.\nImpact pass 2026-11-27: every perk has an estimated boost per game day (`proposal-perk-impact.md`, `.csv`); '
        '312 of the 540 were below a meaningful amount and have a wider trigger or a bigger size (`RAISES` in the corrections table; %d of them in this file); rule P5 added to 4.1.' % n_file['main'], 'status line')
    doc('main', "the first shop food, a failed stop check are each one perk's).",
        "the first shop food, a failed stop check are each one perk's).\n8. **Rule P5, sizes after the impact pass** (2026-11-27, `proposal-perk-impact.md`). Every % family may be 2% a perk "
        "(harvest extra, gather extra, seed back, fast travel cost and seed on fast travel were 1%). A narrow place perk that is still below a meaningful amount at 2% may be 3%: only the perks on the "
        "veto list of the impact doc (`VETO3` in the corrections table, " + str(len(veto)) + " perks), never a world perk, and still under P2 (the place perks of a family add at most +4% at one event). "
        "Region-wide place perks name the landscapes they work in (half of the region or more). World use after the pass: sell 3 of 5, walk 3 of 6, harvest 4 of 4 (full), gather 2 of 4; every other family as before.",
        'rule P5')
    doc('main', 'sell 2 of 5, buy 1 of 5, XP 3 of 5, garden XP 1 of 5, walk 2 of 6, pots 4 of 6, meal 2 of 5, buff 4 of 8, heal 4 of 8, harvest 2 of 4, gather 1 of 4,',
        'sell 3 of 5, buy 1 of 5, XP 3 of 5, garden XP 1 of 5, walk 3 of 6, pots 4 of 6, meal 2 of 5, buff 4 of 8, heal 4 of 8, harvest 4 of 4, gather 2 of 4,', 'world use after the raise')
    doc('main', 'sell 3, buy 4, XP 2, garden XP 4, walk 4, pots 2, meal 3, buff 4, heal 4, harvest 2, gather 3,',
        'sell 2, buy 4, XP 2, garden XP 4, walk 3, pots 2, meal 3, buff 4, heal 4, harvest 0, gather 2,', 'world budget left after the raise')
    doc('main', 'are place perks; the other numeric ones are world perks and fit their budgets (4.1).',
        'are place perks; the other numeric ones are world perks and fit their budgets (4.1). Impact pass 2026-11-27: the Signpost is now region-wide on three landscapes '
        '(`region=NA` + `land=forest,grassland,wetland`), This Year\'s Stone covers mountain and tundra, Goat-Track Pickings mountain, tundra, coast and wetland at 2%, and 24 world perks have a wider '
        'trigger (five of them also go from 1% to 2%: Miller\'s Pinch, Squirrel\'s Arithmetic, Catch of the Day, Watcher\'s Flask, Brim-Full Bucket).', 'note under the Maplewold table')
    main_lines = A.read(A.F_MAIN).splitlines()
    per = {'F01': '+1% or +2%', 'F05': '-1% or -2%', 'F10': '+1% or +2%', 'F11': '+1% or +2%', 'F13': '+1% (+2% place)', 'F18': '-1% (-2% place)', 'F23': '+1% (+2% place)'}
    nasum = {'F01': '2 (3)', 'F05': '2 (3)', 'F10': '2 (4)', 'F11': '1 (2)'}
    for ln in main_lines:
        m = re.match(r'^\| (F\d\d) \| ', ln)
        if m and m.group(1) in per and ln.count('|') == 10:
            c = ln.split('|')
            c[5] = ' ' + per[m.group(1)] + ' '
            if m.group(1) in nasum:
                c[7] = ' ' + nasum[m.group(1)] + ' '
            new_ln = '|'.join(c)
            i = ln.index('|', ln.index('|', 3) + 1)   # from the Effect cell on: the row start is not unique enough
            doc('main', ln, new_ln, 'section 4 table: per-perk size and Maplewold world use')
    M = [
        ('Level Scales: Maplewold crops sell +1% (W)', 'Level Scales: everything you sell in a shop +1% (W)'),
        ('Straightened Signpost: walks to and from its seven neighbours -2% time (P)', "Straightened Signpost: walks on the Maplewold's forest, grassland and wetland roads -2% time (P)"),
        ('Second Breakfast: home-cooked dishes at dawn +2% energy (W)', 'Second Breakfast: home-cooked dishes at dawn or by day +2% energy (W)'),
        ('Tidy Skeps: pests -2% on flowering plants (W)', 'Tidy Skeps: pests -2% on flowers, herbs and fruit crops (W)'),
        ('Honey in the Tea: tea boosts +2% longer (W)', 'Honey in the Tea: boosts from teas, other drinks and sweets +2% longer (W)'),
        ('Greased Wheel: breads and bakes cook 2% faster (W)', 'Greased Wheel: anything with grain in it cooks 2% faster (W)'),
        ("Miller's Pinch: oats and lentil +1% extra harvest (W)", "Miller's Pinch: oats, lentil, soybean and kidney bean +2% extra harvest (W)"),
        ('Dry Woodpile: resting on forest trails heals +2% (W)', 'Dry Woodpile: resting on any trail heals +2% (W)'),
        ("Squirrel's Arithmetic: forest gathering +1% extra (W)", "Squirrel's Arithmetic: forest and grassland gathering +2% extra (W)"),
        ('Fireside Regular: checks at camps +1% (W)', 'Fireside Regular: stop checks +1% (W)'),
        ('Sawdust Mulch: watering +2% longer on hot or windy days (W)', 'Sawdust Mulch: watering +2% longer in dry weather (W)'),
        ('Swept Steps: spot hidden things in forest +1% (W)', 'Swept Steps: spot hidden things +1% (W)'),
        ('What You Leave Comes Back: Maplewold crops +1% seed back (W)', 'What You Leave Comes Back: every crop +1% seed back (W)'),
        ('Sound Nets: acts at jetties and ferries +2% coins (W)', 'Sound Nets: acts that cost energy +2% coins (W)'),
        ('Catch of the Day: fish sell +1% (W)', 'Catch of the Day: fish, gathered finds and dishes sell +2% (W)'),
        ('Beaver-Tight Hull: fast travel from a coast stop -1% (W)', 'Beaver-Tight Hull: fast travel -1% (W)'),
        ("Porter's Crate: coast shops -1% (W)", "Porter's Crate: shops -1% (W)"),
        ("Watcher's Flask: walking in snow or frost -1% time (W)", "Watcher's Flask: walking in rain, storm, snow, frost, fog or wind -2% time (W)"),
        ('Warm to the Bones: healing +2% while it snows (W)', 'Warm to the Bones: healing +2% in rain, storm, snow, frost, fog or wind (W)'),
        ("This Year's Stone: +1 max health on the Maplewold's mountain trails (P)", "This Year's Stone: +1 max health on the Maplewold's mountain and tundra trails (P)"),
        ("Goat-Track Pickings: gathering on the Maplewold's mountain trails +1% extra (P)", "Goat-Track Pickings: gathering on the Maplewold's mountain, tundra, coast and wetland trails +2% extra (P)"),
        ('Stacked Birch: syrups and sweets cook 2% faster (W)', 'Stacked Birch: syrups, sweets, preserves and drinks cook 2% faster (W)'),
        ('Brim-Full Bucket: tree and sap harvests +1% extra (W)', 'Brim-Full Bucket: harvests from anything that regrows +2% extra (W)'),
        ('Border Lamp: night walking -1% time (W)', 'Border Lamp: walking -1% time (W)'),
        ('Up With the Lark: +1% XP at dawn (W)', 'Up With the Lark: +1% XP (W)'),
        ('Tailwind: +2% XP on windy days (W)', 'Tailwind: +2% XP in wind, storm, rain, snow, frost or fog (W)'),
        ('Propped Boughs: fruit and tree crops +1% garden XP (W)', 'Propped Boughs: +1% garden XP (W)'),
        ('- Size: +1% or +2%, +1 of a small unit, one once-a-game-day convenience, or a flag (information or looks). Nothing bigger.',
         '- Size: +1% or +2%, +1 of a small unit, one once-a-game-day convenience, or a flag (information or looks). Nothing bigger, except the NVETO narrow place perks raised to 3% by the impact pass, each on a veto list (`proposal-perk-impact.md`).'.replace('NVETO', str(len(veto)))),
    ]
    for o, n in M:
        doc('master', o, n, 'master 7.4 / 7.5 follows the perk tables')

    # 5. write the block
    src = A.read(F_FIXES)
    mark = '\n# ---------------------------------------------------------------- impact raises (generated)'
    if mark in src:
        src = src[:src.index(mark)]
    blk = [mark,
           '# Written by `python3 claude/tools_perk_impact_raise.py` (2026-11-27): every perk the impact model',
           '# (`claude/proposal-perk-impact.md`) marked LOW, with a wider trigger or a bigger size. Applied after FIXES; taken out',
           '# again by `tools_audit_stop_perks.py --unraise`. VETO3 = the narrow place perks at 3%, for Josh\'s veto.',
           'RAISES = [']
    for fkey, o, n, why in out:
        blk.append('    (%r,\n     %r,\n     %r,\n     %r),' % (fkey, o, n, why))
    blk.append(']')
    blk.append('')
    blk.append('VETO3 = {')
    for k in veto:
        blk.append('    %r,' % k)
    blk.append('}')
    A.write(F_FIXES, src.rstrip('\n') + '\n' + '\n'.join(blk) + '\n')
    n_low = sum(1 for d in est.values() if d['status'] == 'LOW')
    print('LOW before: %d; rows written: %d (perk rows %d); at 3%%: %d' % (n_low, len(out), sum(1 for r in out if not r[3].startswith('impact doc')), len(veto)))
    miss = [d['id'] + ' ' + d['name'] for d in est.values() if d['status'] == 'LOW' and d['name'] not in done]
    print('LOW with no raise (%d):' % len(miss))
    print('\n'.join(miss))


if __name__ == '__main__':
    main()
