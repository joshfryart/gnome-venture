#!/usr/bin/env python3
"""Writes claude/proposal-perk-impact.md from the impact model (called by `tools_perk_impact.py --md`)."""
import os
from collections import Counter

import tools_audit_stop_perks as A
import tools_perk_impact as I

FORMULA = [   # family, baseline of the day, benefit a game day, unit, value points
    ('F01 sell', 'Petals from shop sales', 'sales x share x size', 'Petals', 'x 1'),
    ('F02 buy', 'Petals spent in shops', 'spend x share x size', 'Petals saved', 'x 1'),
    ('F03 XP', 'XP gained (place perks: XP from stop acts)', 'XP x share x size', 'XP', 'x Petals of the day / XP of the day'),
    ('F04 garden XP', 'Garden XP', 'garden XP x share x size', 'garden XP', 'x %g' % I.VP_GXP),
    ('F05 walk time', 'Walk minutes', 'minutes x share x size', 'minutes saved', 'x Petals of the day / 960'),
    ('F06 pot time', 'Pot cook minutes', 'minutes x share x size', 'minutes saved', 'x Petals of the day / 960'),
    ('F07 dish energy', 'Energy from dishes', 'energy x share x size', 'energy', 'x %g' % I.VP_ENERGY),
    ('F08 boost length', 'Boost minutes running', 'minutes x share x size', 'boost minutes', 'x %g' % I.VP_BOOST_MIN),
    ('F09 healing', 'Health healed', 'health x share x size', 'health', 'x %g' % I.VP_HP),
    ('F10 harvest extra', 'Harvests', 'harvests x share x chance', 'crops', 'x %g' % I.VP_ITEM),
    ('F11 gather extra', 'Gathered finds', 'finds x share x chance', 'finds', 'x %g' % I.VP_FIND),
    ('F12 watering lasts', 'Watering actions', 'waterings x share x size (2% longer = 2% fewer)', 'waterings saved (1 energy each)', 'x %g' % I.VP_ENERGY),
    ('F13 seed back', 'Harvests', 'harvests x share x chance', 'seeds', 'x %g' % I.VP_SEED),
    ('F14 friendship', 'Friendship events (chats, gifts)', 'events x share x chance', 'friendship points', 'x %g' % I.VP_FRIEND),
    ('F15 stop coins', 'Petals from stop acts', 'coins x share x size', 'Petals', 'x 1'),
    ('F16 stop check', 'Stop checks and contests', 'checks x share x size', 'extra wins', 'x one act reward (14 + 4 x level)'),
    ('F17 pest', 'Pest visits', 'visits x share x size', 'pests fewer', 'x %g' % I.VP_PEST),
    ('F18 fast travel cost', 'Fast travels x 150 Petals', 'travels x 150 x share x size', 'Petals saved', 'x 1'),
    ('F19 spot hidden', 'Hidden-thing rolls', 'rolls x share x chance', 'extra finds', 'x %g' % I.VP_SPOT),
    ('F20 max health', 'Fights', 'fights x share (each fought with +1 of the bar)', 'fights with +1 health', 'x %g' % I.VP_HP),
    ('F21 torch steps', 'Delve floors', 'floors x share (+1 step of 45 each)', 'torch steps', 'x %g' % I.VP_STEP),
    ('F22 rest energy', 'Rest acts', 'rest acts x share (+1 energy on 3 to 5)', 'energy', 'x %g' % I.VP_ENERGY),
    ('F23 seed on fast travel', 'Fast travels', 'travels x share x chance', 'seeds', 'x %g' % I.VP_SEED),
    ('A1 first action cheaper', 'days the trigger happens', 'chance the charge is used that day x 1 energy', 'energy', 'x %g' % I.VP_ENERGY),
    ('A2 something comes back', 'days the trigger happens', 'chance x the thing kept (a seed, a tool wear, an ingredient, a second try)', 'item or try', 'seed %g, wear 2, item %g, try = 65%% of an act reward' % (I.VP_SEED, I.VP_ITEM)),
    ('A3 daily gift', 'days the trigger happens', 'chance x 1 item', 'items', 'x %g' % I.VP_ITEM),
    ('A4 day coins', 'days the trigger happens', 'chance x coins', 'Petals', 'x 1'),
    ('A5 info flag', '-', 'no number: it saves a look-up, a wrong guess or a tap', '-', '0'),
    ('A6 looks flag', '-', 'no number: looks only', '-', '0'),
]


def md_table(head, rows):
    out = ['| ' + ' | '.join(head) + ' |', '|' + '---|' * len(head)]
    for r in rows:
        out.append('| ' + ' | '.join(str(x) for x in r) + ' |')
    return out


def short(boost):
    return boost.split(' = ')[-1] if ' = ' in boost else boost


def write(rows):
    before = I.read_csv(I.F_BEFORE) if os.path.exists(I.F_BEFORE) else {}
    import tools_audit_stop_perks_fixes as fx
    veto = set(getattr(fx, 'VETO3', ()))
    n_low_b = sum(1 for r in before.values() if r['status'] == 'LOW')
    n_low_a = sum(1 for d in rows if d['status'] == 'LOW')
    changed = [d for d in rows if d['id'] in before and (before[d['id']]['effect'] != d['effect'] or before[d['id']]['size'] != d['size'])]
    at3 = [d for d in rows if d['perk'].key() in veto]
    still = [d for d in at3 if d['status'] == 'LOW']
    how = Counter()
    for d in changed:
        b = before[d['id']]
        sz = b['size'] != d['size']
        tx = I.re.sub(r'\d%', 'N%', b['effect']) != I.re.sub(r'\d%', 'N%', d['effect'])
        how['3% (veto list)' if d['perk'].key() in veto else ('wider trigger and bigger size' if sz and tx else ('bigger size only' if sz else 'wider trigger only'))] += 1
    world = Counter()
    for d in rows:
        if d['perk'].cls == 'W' and d['fam'] in A.FAM:
            world[d['fam']] += A.size_of(d['size'])[1]
    o = []
    o += ['# PROPOSAL: Perk impact model and estimates (all 540 stop perks)', '',
          'Status: proposal only, no game code changed. 2026-11-27. Unsimulated: every baseline number is a source or a stated assumption.',
          'Josh: "List the estimated change or boost from the perk. If below a meaningful amount, up it."', '',
          'Files: this page (model, summary, every raised perk before and after, veto list); `proposal-perk-impact.csv` (one line for each of the 540 perks, as they are now); '
          '`proposal-perk-impact-before.csv` (the same table before the raises). Made by `python3 claude/tools_perk_impact.py --md` (model and numbers at the top of that file); '
          'the raises are rows in `tools_audit_stop_perks_fixes.py` (`RAISES`, written by `tools_perk_impact_raise.py`), applied by `python3 claude/tools_audit_stop_perks.py --fix` '
          '(0 errors) and taken out again by `--unraise`.', '',
          '## Result in short', '',
          '- Before: **%d of 540 perks were LOW** (below a meaningful amount). Typical case: 2%% on one stop\'s walks, stall or acts in one weather = 0.02 to 0.05%% of the day.' % n_low_b,
          '- **%d perks raised**: %s.' % (len(changed), ', '.join('%d %s' % (n, k) for k, n in how.most_common())),
          '- After: %d ok, **%d still LOW**. All %d are narrow place perks at 3%%, the limit; they are the second perk of their family in their region, and rule P3 allows one region-wide perk per family per region (section 7).' % (540 - n_low_a, n_low_a, n_low_a),
          '- **%d perks are at 3%%, for Josh\'s veto** (section 7). Caps: no family over its world cap, place-stack ceiling P2 unchanged (+4%% at one event), A4 still 10 coins a game day, unit perks still +1, daily charges still one a game day, flags still flags.' % len(at3),
          '']
    # 1 baseline
    o += ['## 1. Baseline: one game day of a typical gnome', '',
          'A game day = one sleep (960 awake minutes). A touring day in the region the perk belongs to: 3 to 4 stops, 5 acts each, the garden and kitchen at home. '
          'A perk is rated in the band of its region: Maplewold 1-15; Maizehollow, Mistmoor and the four second-ring regions 15-35; the seven far regions 35-55.', '']
    o += md_table(['Per game day', '1-15', '15-35', '35-55', 'Source or assumption'], [(lab, v[0], v[1], v[2], src) for k, (lab, v, src) in I.BASE.items()])
    o += ['', '## 2. Exchange rates: 1 value point (VP) = 1 Petal', '']
    o += md_table(['Thing', 'VP', 'From'], [
        ('1 energy', I.VP_ENERGY, 'inn bed: 14 Petals for 5 energy (2.8); late supper: 9 Petals for 2 energy (4.5) (`stop_acts.txt`)'),
        ('1 game minute', '%.2f / %.2f / %.2f by band' % tuple(I.vp_min(b) for b in range(3)), 'Petals earned in the day / 960 awake minutes'),
        ('1 XP', '%.3f / %.3f / %.4f by band' % tuple(I.vp_xp(b) for b in range(3)), 'a day of XP is worth a day of Petals'),
        ('1 common item (crop, snack)', I.VP_ITEM, 'common gatherables average 9 Petals (`gatherables.txt`)'),
        ('1 gathered find', I.VP_FIND, 'common 9, uncommon 21 (`gatherables.txt`)'),
        ('1 seed', I.VP_SEED, 'assumption'), ('1 friendship point', I.VP_FRIEND, 'assumption: an 8-Petal gift gives about 2 points'),
        ('1 health point', I.VP_HP, 'assumption'), ('1 boost minute', I.VP_BOOST_MIN, 'assumption: a 224-minute meal boost = about 20 Petals'),
        ('1 garden XP', I.VP_GXP, 'assumption'), ('1 pest avoided', I.VP_PEST, 'assumption: 1 energy to pick it off + lost growth'),
        ('1 hidden thing spotted', I.VP_SPOT, 'assumption'), ('1 torch step', I.VP_STEP, 'assumption'),
        ('1 fast travel', I.TRAVEL_COST, '`functions.php:407` travel_cost')])
    o += ['', 'VP is only for comparing families. LOW or ok is decided in the perk\'s own domain (section 5), not in VP: fast travel, pests and friendship are small in VP by nature.', '']
    # 3 shares
    o += ['## 3. Trigger frequency: how much of the day a scope reaches', '',
          'Expected benefit per game day = **baseline x share x size**. Share = the part of the day\'s domain the perk\'s text reaches, on a game day spent in the perk\'s region:', '']
    o += md_table(['Scope in the text', 'Share', 'Why'], [
        ('World, no condition', '1.00', ''),
        ('Region-wide, landscapes named', '0.50 to 0.75', 'villages in zones of those landscapes / all villages of the region (`zones.txt`)'),
        ('A given stop is visited', '%.2f of days' % I.V, '3.5 stops a day of about 12.5 in a region'),
        ('Acts at one stop; its stall; dishes eaten there', '%.2f' % I.S['acts_here'], 'a visit day x 5 of 17.5 acts (or 1 of 3.5 stalls)'),
        ('Walks from (or to) one stop', '%.3f' % I.S['walk_from'], 'a visit day x 1 of 5 walks'),
        ('One named road, both ways', '%.3f' % I.S['walk_pair'], 'one neighbour of about three'),
        ('Rest acts at one stop', '%.2f' % I.S['rest_here'], 'a visit day x 1 of 2 rest acts'),
        ('Fast travel from one stop', '%.2f' % I.S['travel_from'], 'the gnome stands at 1 of 12.5 stops'),
        ('Named crops', '0.70 staples, 0.25 uncommon, 0.05 rare finds', 'share of the beds while in the region, split evenly inside a tier (`region_crops.txt`); a dish holds 2.5 ingredients'),
        ('Day part', 'dawn 0.125, day 0.625, dusk 0.125, night 0.125', 'of the 16 awake hours'),
        ('Weather', ', '.join('%s %.2f' % kv for kv in I.WEATHER.items()), 'assumption'),
        ('Season', '0.25 each', ''), ('Festival day', '%.2f' % I.FESTIVAL, 'assumption'),
        ('One act kind (contest, lore, craft...)', '0.15 to 0.5', 'assumption, table `KIND` in the script'),
        ('One kind of goods at a stall', '0.1 to 0.5', 'assumption, table `GOODS` in the script')])
    o += ['', 'Conditions multiply. Example: "Walks that start at Froststead take 2% less time in snow or frost" = 180 walk minutes x (0.056 x 0.13) x 2% = 0.03 minutes a game day.', '']
    # 4 formulas
    o += ['## 4. Formula per family', '']
    o += md_table(['Family', 'Baseline of the day', 'Benefit per game day', 'Unit', 'To VP'], FORMULA)
    o += ['', 'Daily charges: chance the charge is used on a game day = a visit day (%.2f) x the act being done (0.9 for a rest, an act, a sale; less for a loss, a failure, one named road), '
          'or the day-wide chance for region-wide and world triggers (table `DAILY_RULES`).' % I.V, '']
    # 5 threshold
    o += ['## 5. What counts as meaningful', '',
          '- **Number perks:** share x size is at least about **1% of the day\'s activity in the perk\'s own domain** (0.95% or more). So a 2% perk must reach about half of the domain, a 1% perk all of it. '
          'Max health, torch steps and rest energy also pass on the felt rule below (the +1 is seen every time).',
          '- **Daily charges:** a clearly felt event **at least once in 4 game days** in the region (0.25 a day). The brief said "say once in 2 game days"; a stop is only visited on 28% of days, so once in 4 = about every visit, '
          'which is the most a perk tied to one stop can do. `THRESH_FELT` in the script changes it.',
          '- **Flags:** an info flag (A5) is meaningful when it saves a look-up, a wrong guess or a tap: all 60 do. A looks flag (A6) has no boost by design; it is listed, not rated.',
          '- Everything below is **LOW**.', '']
    # 6 results
    o += ['## 6. Results', '', '### Now (after the raises)', '']
    o += I.summary(rows)
    o += ['']
    o += I.histogram(rows)
    if before:
        o += ['', '### Before the raises', '', 'LOW per family before: ' + ', '.join('%s %d' % (f, n) for f, n in sorted(Counter(r['family'] for r in before.values() if r['status'] == 'LOW').items())) + '. Total %d.' % n_low_b, '']
        o += ['```']
        for lo, hi in [(0, 0.1), (0.1, 0.25), (0.25, 0.5), (0.5, 0.95), (0.95, 1.5), (1.5, 3), (3, 1000)]:
            n = sum(1 for r in before.values() if r['family'] in A.FAM and lo <= float(r['pct_of_domain']) < hi)
            o.append('%5s to %-5s %% | %-60s %d' % (lo, hi if hi < 1000 else 'more', '#' * int(round(n / 4.0)), n))
        o += ['```', '']
    o += ['### World budget after the raises', '',
          'World use per family (cap): ' + ', '.join('%s %d (%d)' % (A.FAM[f][0], world[f], A.FAM[f][2]) for f in A.FAM if world[f]) + '. '
          'Changed by the pass: sell 2 to 3, walk 2 to 3, harvest extra 2 to 4 (now full), gather extra 1 to 2. No cap was raised. '
          'Five families that were 1% a perk may now be 2%: harvest extra, gather extra, seed back, fast travel cost, seed on fast travel (rule P5 in `proposal-stop-perks.md` 4.1).', '']
    # 7 veto
    o += ['## 7. Veto list: %d place perks at 3%%' % len(at3), '',
          'Each is a narrow place perk that was still LOW at 2%. Strike any line to put it back to 2% (delete its row from `RAISES` and its key from `VETO3`, then `--fix`).', '']
    o += md_table(['Perk', 'Name', 'Family', 'Effect now', 'Boost per game day now', 'Status'],
                  [(d['id'], d['name'], d['fam'], d['effect'], d['boost'], d['status']) for d in at3])
    o += ['', '**%d of them are still LOW at 3%%.** Each is the second perk of its family in its region: the first one took the region-wide slot (rule P3: one `region=` perk per family per region), '
          'and a perk tied to one stop reaches 2 to 11%% of the day, so even 3%% stays under 0.35%%. For Josh, three ways out, none applied:' % len(still),
          '1. Let the second perk take the region\'s other landscapes (the first names half of the region; the two never meet on one event, so nothing stacks). Needs P3 to read "one per family per landscape of a region".',
          '2. Give these stops a perk of a family their region does not have yet.',
          '3. Leave them as small local colour at 3%.', '']
    # 8 raised perks
    o += ['## 8. Every raised perk, before and after (%d)' % len(changed), '',
          'Boost = the benefit per game day in the perk\'s own unit. % = share of the day\'s domain (number perks) or how often the charge is used (daily charges).', '']
    rws = []
    for d in changed:
        b = before[d['id']]
        isnum = d['fam'] in A.FAM
        bm = ('%s%%' % b['pct_of_domain']) if isnum else I.every(float(b['felt_per_day']))
        am = ('%.2f%%' % (d['r'] * 100)) if isnum else I.every(d['felt'])
        rws.append((d['id'], d['name'], d['fam'], '%s: %s' % (b['size'], b['effect']), '%s; %s' % (bm, short(b['boost_per_game_day'])),
                    '%s: %s' % (d['size'], d['effect']), '%s; %s' % (am, short(d['boost'])), '%.2f' % d['vp'], d['status']))
    o += md_table(['Perk', 'Name', 'Fam', 'Before', 'Boost before', 'After', 'Boost after', 'VP/day', 'Status'], rws)
    o += ['', '## 9. How the raises were chosen', '',
          '1. **Wider trigger first.** Crop perks now name enough of their region\'s crops (staples first) to cover about half of the beds or dishes; no crop has two perks of one family (rule P3). '
          'One place perk per family per region became region-wide, in the landscapes that hold half of the region or more, the stop\'s own landscape first. '
          'Daily charges lost a narrow condition (one weather, one day part, one named road) or became region-wide. Rest energy stayed at its stop with a wider condition (+1 is already 25% of a rest act).',
          '2. **Then size, to 2% at most**: harvest extra, gather extra, seed back and the fast-travel families from 1% to 2% where the wider trigger was not enough. Unit perks stayed +1 and day coins stayed at 2 or less (their caps).',
          '3. **Then 3%**, only for narrow place perks still LOW at 2%: section 7.',
          '4. **World perks** (24 of the 29 were LOW): the condition was dropped or widened; five went from 1% to 2% inside their family cap (Miller\'s Pinch, Squirrel\'s Arithmetic, Catch of the Day, Watcher\'s Flask, Brim-Full Bucket).',
          '', 'Weak spots of the model: Petals per game day are not simulated (master section 3, A4); the shares of weather, act kinds and goods are guesses; a gnome is assumed to be touring the perk\'s region. '
          'A looser threshold (0.5%) would pass crop perks on two staples; a stricter one (once in 2 days for daily charges) would fail every first-visit gift.', '']
    A.write(I.F_MD, '\n'.join(o) + '\n')
    print('wrote', I.F_MD, '(%d raised, %d LOW now, %d at 3%%)' % (len(changed), n_low_a, len(at3)))
