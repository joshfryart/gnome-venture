#!/usr/bin/env python3
"""Merge the shards of tests/pf_collect.php and build the sheet-sized tables for the playtest workbook.

    python3 tests/pf_collect_agg.py OUTDIR PFS_DIR [RUN_ID] [WALL_MIN]

OUTDIR holds <table>.<shard>.csv and profiles.csv (from pf_collect.php); PFS_DIR the Sonnet pilot reports (<slug>/<slug>.json).
Writes OUTDIR/all_<table>.csv (merged, full) and OUTDIR/sheet_<Tab>.csv (columns in the workbook's order, no header; the sheet
already has row 1). The workbook holds at most 500,000 cells, so Fights is complete, while Turns, Options_summary and Regret
hold the SAMPLE seed 0, offset 0, no control (all bots and profiles) and Pieces the chain bot of that sample; the full tables are
the all_*.csv files. Options are never put in the sheet (CSV only).
"""
import csv, glob, json, os, sys, statistics as st
from collections import defaultdict

D = sys.argv[1]; PFS = sys.argv[2]; RUN = sys.argv[3] if len(sys.argv) > 3 else 'pfc'; WALL = sys.argv[4] if len(sys.argv) > 4 else ''
csv.field_size_limit(10 ** 9)

def merge(t):
    rows = []; hdr = None
    for f in sorted(glob.glob(f'{D}/{t}.*.csv')):
        with open(f, newline='') as fh:
            r = list(csv.reader(fh))
        if not r: continue
        if r[0][0] in ('run_id', 'fight_id'):
            hdr = r[0]; r = r[1:]
        rows += r
    with open(f'{D}/all_{t}.csv', 'w', newline='') as fh:
        w = csv.writer(fh); w.writerow(hdr); w.writerows(rows)
    return [dict(zip(hdr, x)) for x in rows]

def num(v):
    if v is None or v == '': return None
    try:
        f = float(v); return int(f) if f == int(f) and 'e' not in str(v).lower() else f
    except ValueError: return v

def txt(v):
    v = '' if v is None else str(v)
    return None if v == '' else "'" + v

def kv(s):
    o = {}
    for p in (s or '').split():
        if ':' in p: k, v = p.split(':', 1); o[k] = v
    return o

def out(name, rows):
    with open(f'{D}/sheet_{name}.csv', 'w', newline='') as fh:
        w = csv.writer(fh)
        for r in rows: w.writerow(['' if v is None else v for v in r])
    print(f'sheet_{name}: {len(rows)} rows x {len(rows[0]) if rows else 0} cols')

F = merge('fights'); T = merge('turns'); O = merge('options'); R = merge('regret'); P = merge('pieces')
prof = list(csv.DictReader(open(f'{D}/profiles.csv')))
print('fights', len(F), 'turns', len(T), 'options', len(O), 'regret', len(R), 'pieces', len(P))

# control_of: the Balanced / offset 0 fight with the same creature, bot and seed
base = {(f['creature'], f['bot'], f['seed']): f['fight_id'] for f in F if f['ctrl'] == '' and f['profile'] == 'Balanced' and f['offset'] == '0'}
fid = {f['fight_id']: f for f in F}
# seed index 0 = the lowest seed of each creature
minseed = defaultdict(lambda: 10 ** 12)
for f in F: minseed[f['creature']] = min(minseed[f['creature']], int(f['seed']))
sample = {f['fight_id'] for f in F if f['ctrl'] == '' and f['offset'] == '0' and int(f['seed']) == minseed[f['creature']]}
psample = {x for x in sample if fid[x]['bot'] == 'chain'}

# ---- Fights
SRC = ['basic', 'tool', 'pal', 'crop', 'craft', 'region', 'knack', 'calling']
rows = []
for f in F:
    bs = kv(f['deck_by_source']); res = 'turn_cap' if f['turn_cap_hit'] == '1' else ('win' if f['win'] == '1' else 'loss')
    other = {k: v for k, v in bs.items() if k not in SRC}
    rows.append([f['fight_id'], f['run_id'], 'bot:' + f['bot'], f['creature'], f['family'], f['size'], num(f['creature_level']), f['region'],
                 f['class_rule'] + (' (' + f['class_rule_text'] + ')' if f['class_rule_text'] else ''), f['ai_type'], f['abilities'] or None, num(f['tune_foe_x']), num(f['tune_bar_x']), num(f['bar_max']),
                 num(f['gnome_level']), num(f['offset']), f['profile'], num(f['grit']), num(f['nimble']), num(f['hardiness']), num(f['charm']), num(f['lore']), num(f['luck']), num(f['max_hp']), num(f['deck_size'])]
                + [num(bs.get(k, 0)) for k in SRC]
                + [f['build'], num(f['seed']), res, f['end_reason'], num(f['turns']), num(f['hp_lost']), round(1 - float(f['hp_lost_pct']), 3), num(f['damage_end']), num(f['charm_end']),
                   num(f['passes']), num(f['refused']), num(f['flips']), num(f['longest_chain']), num(f['chain_count']), sum(int(v) for v in kv(f['combos']).values()), num(f['teamwork_fires']), num(f['env_pieces_fired_mine']),
                   num(f['turn_cap_hit']), num(f['win']), base.get((f['creature'], f['bot'], f['seed'])) if f['ctrl'] else None, f['ctrl'] or None,
                   # extra columns (appended at the end, see SCHEMA.md)
                   f['bot'], num(f['sense']), f['combos'] or None, num(f['forecast_n']), num(f['forecast_abs_err_mean']), num(f['regret_look_mean']), num(f['dead_hand_turns']), num(f['bar_fill_pct']),
                   ' '.join(f'{k}:{v}' for k, v in other.items()) or None, f['calling'], num(f['calling_tier'])])
out('Fights', rows)

# ---- Turns (sample)
rows = []
for t in T:
    if t['fight_id'] not in sample: continue
    notes = '; '.join(f'{k}={t[k]}' for k in ['aim_piece', 'aim_forecast_before', 'act_hp_lost_my_chain', 'hp_lost_turn', 'env_hp_lost', 'cr_bait_dmg', 'poison_on_it', 'my_evade_dodged_it', 'pred_d_err', 'pred_c_err', 'pred_h_err', 'reaim', 'over', 'chosen'] if t[k] not in ('', '0'))
    rows.append([t['fight_id'], num(t['turn']), num(t['hp_start']), num(t['hp_end']), num(t['dmg_start']), num(t['dmg_end']), num(t['charm_start']), num(t['charm_end']), num(t['my_guard']), num(t['my_guard_end']), num(t['creature_guard']), num(t['creature_guard_end']),
                 num(t['draw_n']), num(t['discard_n']), txt(t['board']), t['env_next'] or None, txt(t['hazards']), txt(t['hand']), txt(t['legal_n']), t['chosen_piece'] or None, txt(t['chosen_cell']), 'yes' if t['chosen_flip'] == '1' else 'no',
                 num(t['pv_d']), num(t['pv_c']), num(t['pv_h']), num(t['pv_n']), t['pv_flags'] or None, txt(t['aim_cell']), num(t['aim_forecast_after']), num(t['actual_first_chain_hp']), num(t['forecast_err']),
                 num(t['my_chain_len']), num(t['my_pieces_fired']), num(t['used_up']), num(t['act_dmg']), num(t['act_charm']), num(t['cr_pieces']), num(t['cr_dmg_dealt']), num(t['cr_blocked_by_guard']), num(t['cr_evade_misses_mine']),
                 num(t['cr_quick']), num(t['cr_slow']), num(t['cr_grudge']), num(t['cr_riposte']), num(t['poison_on_me']), num(t['cr_fired_my_pieces']), notes or None])
out('Turns', rows)

# ---- Options_summary (sample) and Regret (sample): from the options
byturn = defaultdict(list)
for o in O:
    if o['fight_id'] in sample: byturn[(o['fight_id'], int(o['turn']))].append(o)
reg = {(r['fight_id'], int(r['turn'])): r for r in R}
lab = lambda o: f"{o['piece']}@{o['cell']}" + (' flip' if o['flip'] == '1' else '')
osum = []; rrows = []
for t in T:
    if t['fight_id'] not in sample: continue
    k = (t['fight_id'], int(t['turn'])); ops = byturn.get(k, []); ch = [o for o in ops if o['chosen'] == '1']; c = ch[0] if ch else None
    def rank(key, rev=True):
        if not c: return None
        v = float(c[key]); return 1 + sum(1 for o in ops if (float(o[key]) > v if rev else float(o[key]) < v))
    if ops:
        bd = max(ops, key=lambda o: float(o['d'])); bc = max(ops, key=lambda o: float(o['c'])); sf = min(ops, key=lambda o: (float(o['turn_hp_lost']), -float(o['d']) - float(o['c'])))
        osum.append([k[0], k[1], len(ops), rank('d'), rank('c'), rank('turn_hp_lost', False), lab(bd), lab(bc), lab(sf), sum(o['end'] == 'win' for o in ops), sum(o['turn_over'] == 'defeat' for o in ops)])
    else: osum.append([k[0], k[1], 0, None, None, None, None, None, None, 0, 0])
    r = reg.get(k)
    best = max((float(o['s_look']) for o in ops), default=None)
    rrows.append([k[0], k[1], float(c['s_look']) if c else None, best, num(r['gap_dmg']) if r else None, num(r['gap_charm']) if r else None, num(r['gap_hp_lost']) if r else None, num(r['dead_hand']) if r else None, 1 if len(ops) == 1 else 0,
                  # extras: the chosen and the look bot's move, look-value gap
                  r['chosen'] if r else None, r['best_look'] if r else None, num(r['gap_look_value']) if r else None])
out('Options_summary', osum); out('Regret', rrows)

# ---- Pieces (sample, chain bot)
rows = []
for p in P:
    if p['fight_id'] not in psample: continue
    rows.append([p['fight_id'], p['key'], p['name'], p['type'], num(p['base']), num(p['stat_contrib']), num(p['level_contrib']), num(p['bonus']), num(p['value']), p['source'], num(p['rank']), p['tag'] or None, txt(p['edges']),
                 num(p['drawn']), num(p['played']), num(p['fired']), num(p['flipped']), num(p['expired']), num(p['used_up']), num(p['dmg']), num(p['charm']), num(p['hp']), p['stat'] or None, num(p['fell']), num(p['uid'])])
out('Pieces', rows)

# ---- Gnome_profiles
rows = []
for g in prof:
    cnt = lambda s: len(kv(s)) if s else 0
    rows.append([g['profile'], num(g['level']), num(g['grit']), num(g['nimble']), num(g['hardiness']), num(g['charm']), num(g['lore']), num(g['luck']), num(g['stat_points_spent']),
                 num(g['mod_grit']), num(g['mod_nimble']), num(g['mod_hardiness']), num(g['mod_charm']), num(g['mod_lore']), num(g['mod_luck']), num(g['max_hp']), num(g['deck_size']),
                 num(g['belt_slots']), len([x for x in g['pals'].split(',') if x]), cnt(g['crops']), cnt(g['crafts']), cnt(g['regions']), txt(g['calling_tier']),
                 num(g['sense']), num(g['stat_points']), g['tool_tiers'] or None, g['knacks_on'] or None, num(g['hurt_bonus_lv3'])])
out('Gnome_profiles', rows)

# ---- Sonnet_findings
DIFF = {'right': 'fair', 'fair': 'fair', 'too_easy': 'too-easy', 'easy': 'easy', 'hard': 'hard', 'too_hard': 'too-hard', 'too-easy': 'too-easy', 'too-hard': 'too-hard'}
son = {}; rows = []
for fn in sorted(glob.glob(f'{PFS}/*/*.json')):
    if os.path.basename(fn)[:-5] != os.path.basename(os.path.dirname(fn)) or os.path.basename(fn)[:-5] not in {f['creature'] for f in F}: continue
    d = json.load(open(fn)); cr = d.get('creature', {}); son[d['slug']] = d
    for f in d['fights']:
        cf = f.get('confusing') or []; bg = f.get('bugs') or []
        rows.append([d['slug'], f"sonnet-{d['slug']}-{f['id']}", 'sonnet-pilot', f.get('fair_1_5'), f.get('fun_1_5'), DIFF.get(f.get('difficulty', ''), None), f.get('why_lost_or_won'),
                     ' | '.join(f.get('dull_or_swingy_turns') or []) or None,
                     ' || '.join(f"[t{x.get('turn')} {x.get('tag')}] {x.get('text')} -- thought: {x.get('what_i_thought')} -- happened: {x.get('what_happened')}" for x in cf) or None,
                     cf[0].get('turn') if cf else None, (cf[0].get('tag') if cf and cf[0].get('tag') in ('harness', 'rule') else None),
                     ' || '.join(str(b.get('command')) for b in bg) or None, ' || '.join(str(b.get('output')) for b in bg) or None, ' || '.join(str(b.get('expected')) for b in bg) or None,
                     cr.get('dominant_strategy'), ('yes' if cr.get('class_rule_clear') else 'no') + (': ' + cr['class_rule_note'] if cr.get('class_rule_note') else ''),
                     (cr.get('tune_suspect') or '') + (': ' + cr['tune_note'] if cr.get('tune_note') else ''),
                     ' / '.join(f.get('moves') or []) or None,
                     # extras
                     f.get('result'), f.get('turns'), (f.get('hp_left_pct') / 100 if isinstance(f.get('hp_left_pct'), (int, float)) else None), f.get('gnome_level'), f.get('build'), f.get('seed'), f.get('refused'), f.get('longest_chain'), f.get('intent'), d.get('size'), d.get('creature_level')])
out('Sonnet_findings', rows)

# ---- Flags (derived from the bot fights and the Sonnet pilot; rules in SCHEMA.md / README)
TGT = {'small': (4, 5), 'medium': (6, 8), 'large': (6, 8), 'boss': (6, 8)}
main = [f for f in F if not f['ctrl']]
by = defaultdict(list)
for f in main: by[f['creature']].append(f)
mean = lambda a: sum(a) / len(a) if a else float('nan')
frows = []
for slug, fs in by.items():
    size = fs[0]['size']; lo, hi = TGT[size]; d = son.get(slug, {}); sf = d.get('fights', []); cr = d.get('creature', {})
    w = lambda cond: mean([int(f['win']) for f in fs if cond(f)])
    w4 = w(lambda f: f['offset'] == '-4' and f['bot'] in ('chain', 'look')); w0 = w(lambda f: f['offset'] == '0'); turns0 = mean([int(f['turns']) for f in fs if f['offset'] == '0'])
    slost = sum(1 for x in sf if x.get('result') not in ('seen_off', 'charmed')); seasy = sum(1 for x in sf if x.get('difficulty') in ('too_easy', 'easy'))
    if w4 < 0.6:
        frows.append([slug, 'retune-hard', f'chain+look bots win {w4:.0%} at offset -4 (rule: under 60%); Sonnet lost {slost} of {len(sf)}', 'yes' if slost else 'no', 'yes', 'open', None])
    if w0 >= 0.95 and turns0 < lo:
        frows.append([slug, 'retune-easy', f'all bots win {w0:.0%} at offset 0 in {turns0:.1f} turns (target {lo}-{hi}); Sonnet called {seasy} of {len(sf)} fights easy/too easy', 'yes' if seasy else 'no', 'yes', 'open', None])
    nconf = sum(len(x.get('confusing') or []) for x in sf); nrule = sum(1 for x in sf for c in (x.get('confusing') or []) if c.get('tag') == 'rule')
    if nrule >= 2: frows.append([slug, 'clarity', f'{nrule} rule-confusion notes in {len(sf)} Sonnet fights ({nconf} confusing notes in all)', 'yes', 'n/a', 'open', None])
    if cr.get('class_rule_clear') is False: frows.append([slug, 'class-rule', 'Sonnet: class rule not clear: ' + (cr.get('class_rule_note') or ''), 'yes', 'n/a', 'open', None])
    nb = sum(len(x.get('bugs') or []) for x in sf)
    if nb: frows.append([slug, 'bug', f'{nb} bug report(s) in the Sonnet fights: ' + ' || '.join(str(b.get('output'))[:160] for x in sf for b in (x.get('bugs') or [])), 'yes', 'n/a', 'open', None])
    wc = w(lambda f: f['offset'] == '0' and f['bot'] == 'chain'); wn = w(lambda f: f['offset'] == '0' and f['bot'] == 'newbie')
    if wc >= 0.9 and cr.get('dominant_strategy'):
        frows.append([slug, 'dominant', f'the chain bot (longest chain, reads nothing) wins {wc:.0%} at offset 0, newbie {wn:.0%}; Sonnet: ' + cr['dominant_strategy'][:300], 'yes', 'yes', 'open', None])
    fe = [float(f['forecast_abs_err_mean']) for f in fs if f['forecast_abs_err_mean'] != '']
    fn = sum(int(f['forecast_n']) for f in fs)
    if fe and mean(fe) > 1.0: frows.append([slug, 'forecast-error', f'mean |aim forecast - first creature chain| {mean(fe):.2f} HP per fight over {fn} unbroken aims (rule: over 1 HP)', 'n/a', 'yes', 'open', None])
    t1 = mean([1 if int(f['turns']) <= 1 and f['win'] == '1' else 0 for f in fs])
    if t1 > 0.10: frows.append([slug, 'turn1-kill', f'{t1:.0%} of the bot fights are won on turn 1 (rule: over 10%)', 'yes' if any(x.get('turns') == 1 for x in sf) else 'no', 'yes', 'open', None])
out('Flags', frows)

# ---- Runs
seeds = ';'.join(f"{s}:{minseed[s]}+13k" for s in sorted(minseed))
out('Runs', [[RUN, '2026-11-22', txt(F[0]['git_sha']), F[0]['version'], 'tests/pf_collect.php (first version)', 'bots', 'chain,look,newbie,charm', txt('3 seeds per cell, pf_bots formula 500+13k+level+1000*(crc32(slug)%97): ' + seeds), None, num(WALL),
              f'{len(F)} fights ({len(main)} grid: 10 creatures x 4 bots x 8 profiles x offsets 0,-4 x 3 seeds, build std; {len(F) - len(main)} controls: Balanced, offset 0, one raw stat +2/-2). Full per-turn, per-option and per-piece data: CSV in the collect folder (all_*.csv); the sheet holds Turns/Options_summary/Regret for seed 0 + offset 0 and Pieces for the chain bot of that sample (workbook cell limit).'],
             ['sonnet-pilot', '2026-11-22', None, None, 'tests/pf_play.php (Sonnet tester agent)', 'sonnet', None, None, None, None, f'{sum(len(d["fights"]) for d in son.values())} Sonnet pilot fights on the same 10 creatures; findings in Sonnet_findings (judgement, not ground truth)']])

# ---- console summary
print('\nwin rate by profile (grid fights, all bots):')
for p in ['Balanced', 'Grit', 'Nimble', 'Hardiness', 'Charm', 'Lore', 'Luck', 'Grit+Hardiness']:
    a = [f for f in main if f['profile'] == p]
    print(f"  {p:15s} n={len(a)} win={mean([int(f['win']) for f in a]):.1%} off0={mean([int(f['win']) for f in a if f['offset']=='0']):.1%} off-4={mean([int(f['win']) for f in a if f['offset']=='-4']):.1%} turns={mean([int(f['turns']) for f in a]):.2f} hp_lost={mean([1-float(f['hp_lost_pct']) for f in a]):.2f}left")
print('controls (win delta vs base):')
for c in sorted({f['ctrl'] for f in F if f['ctrl']}):
    a = [f for f in F if f['ctrl'] == c]; b = [fid[base[(f['creature'], f['bot'], f['seed'])]] for f in a]
    print(f"  {c:12s} n={len(a)} win {mean([int(f['win']) for f in a]):.1%} vs {mean([int(f['win']) for f in b]):.1%}, turns {mean([int(f['turns']) for f in a]):.2f} vs {mean([int(f['turns']) for f in b]):.2f}, hp_left {mean([1-float(f['hp_lost_pct']) for f in a]):.3f} vs {mean([1-float(f['hp_lost_pct']) for f in b]):.3f}")
print('by bot x offset:')
for b in ['chain', 'look', 'newbie', 'charm']:
    for o in ['0', '-4']:
        a = [f for f in main if f['bot'] == b and f['offset'] == o]; print(f"  {b:7s} {o:3s} win {mean([int(f['win']) for f in a]):.1%} turns {mean([int(f['turns']) for f in a]):.2f} cap {mean([int(f['turn_cap_hit']) for f in a]):.1%} charmed {mean([f['result']=='charmed' for f in a]):.1%}")
print('by creature (offset 0 / -4, all bots):')
for s, fs in by.items():
    print(f"  {s:20s} {fs[0]['size']:6s} L{fs[0]['creature_level']:3s} win0 {mean([int(f['win']) for f in fs if f['offset']=='0']):.0%} win-4 {mean([int(f['win']) for f in fs if f['offset']=='-4']):.0%} turns {mean([int(f['turns']) for f in fs]):.1f} t1win {mean([1 if f['turns']=='1' and f['win']=='1' else 0 for f in fs]):.0%} fcerr {mean([float(f['forecast_abs_err_mean']) for f in fs if f['forecast_abs_err_mean']!='']):.2f} regret {mean([float(f['regret_look_mean']) for f in fs if f['regret_look_mean']!='']):.3f} dead {sum(int(f['dead_hand_turns']) for f in fs)/max(1,sum(int(f['turns']) for f in fs)):.1%}")
