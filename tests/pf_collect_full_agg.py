#!/usr/bin/env python3
"""FULL-run aggregator for tests/pf_collect.php (GRID=full): merges the lean shards of all creatures and builds the sheet-sized AGGREGATE tabs of the playtest workbook.

    python3 tests/pf_collect_full_agg.py select OUTDIR [N_PER_CELL=5]      writes OUTDIR/sample_ids.txt: the fights whose turns go to the sheet (whole fights, spread over sizes, regions, profiles)
    python3 tests/pf_collect_full_agg.py build  OUTDIR PFS_DIR [RUN_ID] [WALL_MIN] [TOTAL_SECS]   OUTDIR = the lean shards (fights.N.csv, pieces.N.csv), OUTDIR/full = the second pass over the sample
                                                                          (ONLY=OUTDIR/sample_ids.txt GRID=full php tests/pf_collect.php OUTDIR/full 0/1 all 3)

build writes OUTDIR/all_fights.csv (merged, every column), OUTDIR/xlsx/<Tab>.xlsx (the rows of each workbook tab, header in row 1, formats set; imported into the workbook and copied into the tab)
and OUTDIR/summary.json (numbers for the README).
Fights tab = AGGREGATES over seeds (and over the bots named in the bot column): creature x size x profile x build x offset x bot group, 12 columns (the workbook holds at most 500,000 cells).
"""
import csv, glob, json, os, re, sys, statistics as st
from collections import defaultdict
from openpyxl import Workbook

csv.field_size_limit(10 ** 9)
MODE = sys.argv[1]; D = sys.argv[2]
SIZES = ['small', 'medium', 'large', 'boss']
PROFS = ['Balanced', 'Grit', 'Nimble', 'Hardiness', 'Charm', 'Lore', 'Luck', 'Grit+Hardiness']
TGT = {'small': (4, 5), 'medium': (6, 8), 'large': (6, 8), 'boss': (6, 8)}   # target turns by size (README)
BG = {'chain+look': ('chain', 'look'), 'newbie+charm': ('newbie', 'charm'), 'random+greedy+defensive': ('random', 'greedy', 'defensive'), 'chain+look+newbie+charm': ('chain', 'look', 'newbie', 'charm')}


def merge(d, t):
    rows = []; hdr = None
    for f in sorted(glob.glob(f'{d}/{t}.*.csv')):
        with open(f, newline='') as fh:
            r = list(csv.reader(fh))
        if not r: continue
        if r[0][0] in ('run_id', 'fight_id'): hdr = r[0]; r = r[1:]
        rows += r
    return [dict(zip(hdr, x)) for x in rows] if hdr else []


def num(v):
    if v is None or v == '': return None
    try:
        f = float(v); return int(f) if f == int(f) and 'e' not in str(v).lower() else f
    except ValueError: return v


def txt(v):
    v = '' if v is None else str(v)
    if v == '': return None
    return "'" + v if False else v


def kv(s):
    o = {}
    for p in (s or '').split():
        if ':' in p: k, v = p.split(':', 1); o[k] = v
    return o


mean = lambda a: sum(a) / len(a) if a else None

if MODE == 'select':
    n_cell = int(sys.argv[3]) if len(sys.argv) > 3 else 5
    F = merge(D, 'fights')
    k0 = {}
    for f in F:
        if not f['ctrl']: k0[f['creature']] = min(k0.get(f['creature'], 10 ** 12), int(f['seed']))
    cand = defaultdict(list)   # (size, profile) -> fights: seed index 0, std build, chain/look/newbie/charm, offset 0 and -4
    for f in F:
        if f['ctrl'] or f['build'] != 'std' or int(f['seed']) != k0[f['creature']] or f['offset'] not in ('0', '-4') or f['bot'] not in ('chain', 'look', 'newbie', 'charm'): continue
        cand[(f['size'], f['profile'])].append(f)
    pick = []; rot = 0
    for size in SIZES:
        for p in PROFS:
            cs = sorted(cand[(size, p)], key=lambda f: (f['creature'], f['bot'], f['offset']))
            creatures = sorted({f['creature'] for f in cs})
            byreg = defaultdict(list)   # spread over regions
            for c in creatures:
                byreg[[f['region'] for f in cs if f['creature'] == c][0]].append(c)
            order = []; regs = sorted(byreg)
            while any(byreg.values()):
                for r in regs:
                    if byreg[r]: order.append(byreg[r].pop(0))
            sh = (PROFS.index(p) * n_cell) % max(1, len(order)); order = order[sh:] + order[:sh]   # a different run of creatures for each profile
            for c in order[:n_cell]:
                bot = ['chain', 'look', 'newbie', 'charm'][rot % 4]; off = ['0', '-4'][(rot // 4) % 2]; rot += 1
                m = [f for f in cs if f['creature'] == c and f['bot'] == bot and f['offset'] == off] or [f for f in cs if f['creature'] == c]
                pick.append(m[0])
    open(f'{D}/sample_ids.txt', 'w').write('\n'.join(f['fight_id'] for f in pick) + '\n')
    print(len(pick), 'fights,', sum(int(f['turns']) for f in pick), 'turns (lean pass)')
    sys.exit()

# ============================================================ build
PFS = sys.argv[3]; RUN = sys.argv[4] if len(sys.argv) > 4 else 'pfc-full'; WALL = sys.argv[5] if len(sys.argv) > 5 else ''
os.makedirs(f'{D}/xlsx', exist_ok=True)
F = merge(D, 'fights'); P = merge(D, 'pieces')
hdr = list(F[0].keys())
with open(f'{D}/all_fights.csv', 'w', newline='') as fh:
    w = csv.writer(fh); w.writerow(hdr); w.writerows([[f[h] for h in hdr] for f in F])
with open(f'{D}/all_pieces.csv', 'w', newline='') as fh:
    w = csv.writer(fh); ph = list(P[0].keys()); w.writerow(ph); w.writerows([[p[h] for h in ph] for p in P])
FD = f'{D}/full'; T = merge(FD, 'turns'); O = merge(FD, 'options'); R = merge(FD, 'regret'); FF = merge(FD, 'fights'); PF = merge(FD, 'pieces')
prof = list(csv.DictReader(open(f'{D}/profiles.csv'))) if os.path.exists(f'{D}/profiles.csv') else []
print('fights', len(F), 'pieces', len(P), '| full pass: fights', len(FF), 'turns', len(T), 'options', len(O), 'regret', len(R))
fid = {f['fight_id']: f for f in F}
for f in F:
    f['_w'] = int(f['win']); f['_t'] = int(f['turns']); f['_h'] = float(f['hp_lost_pct']); f['_cap'] = int(f['turn_cap_hit']); f['_o'] = int(f['offset'])
    f['_fe'] = float(f['forecast_abs_err_mean']) if f['forecast_abs_err_mean'] != '' else None
    f['_t1'] = 1 if (f['_t'] <= 1 and f['_w']) else 0

main = [f for f in F if not f['ctrl']]
idx = defaultdict(list)   # (slug, build, profile, offset, bot) -> fights
for f in main: idx[(f['creature'], f['build'], f['profile'], f['_o'], f['bot'])].append(f)
info = {}
for f in F:
    info.setdefault(f['creature'], dict(size=f['size'], level=int(f['creature_level']), foe=f['tune_foe_x'], bar=f['tune_bar_x']))
slugs = sorted(info, key=lambda s: (SIZES.index(info[s]['size']), info[s]['level'], s))


def pool(slug, build, p, off, bots):
    r = []
    for b in bots: r += idx.get((slug, build, p, off, b), [])
    return r


def stats(r):
    if not r: return None
    fe = [f['_fe'] for f in r if f['_fe'] is not None]
    hs = [1 - f['_h'] for f in r]
    return dict(n=len(r), win=mean([f['_w'] for f in r]), turns=mean([f['_t'] for f in r]), hp=mean([f['_h'] for f in r]), t1=mean([f['_t1'] for f in r]), cap=mean([f['_cap'] for f in r]),
                swing=st.pstdev(hs) if len(hs) > 1 else 0.0, fe=mean(fe))


def r3(v, k=3): return None if v is None else round(v, k)


# formats: column -> openpyxl number format
PCT = '0.0%'; N1 = '0.0'; N2 = '0.00'


def out(name, header, rows, fmts=None, sheet=None, part=None):
    wb = Workbook(); ws = wb.active; ws.title = sheet or ('n_' + name)
    ws.append(header)
    for r in rows:
        assert len(r) == len(header), (name, len(r), len(header))
        ws.append(r)
    for col, f in (fmts or {}).items():
        for row in ws.iter_rows(min_row=2, min_col=col, max_col=col):
            for c in row: c.number_format = f
    fn = f'{D}/xlsx/{name}{"" if part is None else "_" + str(part)}.xlsx'
    wb.save(fn)
    cells = sum(1 for r in rows for v in r if v is not None)
    print(f'{name}{"" if part is None else "_" + str(part)}: {len(rows)} rows x {len(header)} cols, {cells} filled cells')
    return cells


summary = {}
cells_total = {}

# ---------------------------------------------------------------- Fights (aggregates)
FH = ['creature_slug', 'size', 'profile', 'build', 'offset', 'bot', 'n', 'win_pct', 'mean_turns', 'mean_hp_lost_pct', 'turn1_kill_pct', 'forecast_error_hp']
frows = []
for s in slugs:
    sz = info[s]['size']
    def add(build, p, off, label):
        a = stats(pool(s, build, p, off, BG[label]))
        if a: frows.append([s, sz, p, build, off, label, a['n'], r3(a['win']), r3(a['turns'], 2), r3(a['hp']), r3(a['t1']), r3(a['fe'], 2)])
    for p in PROFS:
        for off in (0, -4): add('std', p, off, 'chain+look')
    for p in ('Balanced', 'Grit'):
        for off in (0, -4): add('std', p, off, 'newbie+charm')
    for b in ('pals', 'norare'):
        for p in ('Balanced', 'Grit'):
            for off in (0, -4): add(b, p, off, 'chain+look+newbie+charm')
half = (len(frows) + 1) // 2
fm = {8: PCT, 9: N2, 10: PCT, 11: PCT, 12: N2}
# split at a creature boundary
cut = half
while frows[cut][0] == frows[cut - 1][0]: cut += 1
parts = [frows[:cut], frows[cut:]]
for i, pr in enumerate(parts): cells_total[f'Fights_{i + 1}'] = out('Fights', FH, pr, fm, sheet=f'n_Fights{i + 1}', part=i + 1)
summary['fights_rows'] = len(frows); summary['fights_part_rows'] = [len(p) for p in parts]

# ---------------------------------------------------------------- Creature_rollup
RH = ['creature_slug', 'size', 'level', 'target_turns_low', 'target_turns_high', 'tune_foe_x', 'tune_bar_x', 'fights', 'win_pct', 'win_pct_off_m8', 'win_pct_off_m4', 'win_pct_off0', 'win_pct_off_p4',
      'mean_turns_off0', 'turns_vs_target', 'mean_hp_lost_pct_off0', 'turn_cap_pct', 'swing_hp_left_pct', 'turn1_kill_pct', 'forecast_error_hp', 'grit_effect_pts', 'best_profile', 'worst_profile',
      'win_pct_casual_bots', 'win_pct_naive_bots', 'win_pals_vs_std_pts', 'win_norare_vs_std_pts']
roll = {}; rrows = []
for s in slugs:
    sz = info[s]['size']; lo, hi = TGT[sz]
    allf = [f for f in main if f['creature'] == s]
    cap = stats(allf)
    cl = lambda off, p='Balanced': stats(pool(s, 'std', p, off, BG['chain+look']))
    w = {o: cl(o) for o in (-8, -4, 0, 4)}
    b0 = w[0]
    f0 = [f for f in allf if f['_o'] == 0]
    # profile effect: chain+look at offsets 0 and -4 pooled
    pw = {}
    for p in PROFS:
        a = stats(pool(s, 'std', p, 0, BG['chain+look']) + pool(s, 'std', p, -4, BG['chain+look'])); pw[p] = a
    grit = (pw['Grit']['win'] - pw['Balanced']['win']) * 100
    order = sorted(PROFS, key=lambda p: (pw[p]['win'], -pw[p]['turns']))
    best, worst = order[-1], order[0]
    if pw[best]['win'] == pw[worst]['win']: best = worst = 'none (all equal)'
    cas = stats(pool(s, 'std', 'Balanced', 0, BG['newbie+charm'])); nai = stats(pool(s, 'std', 'Balanced', 0, BG['random+greedy+defensive']))
    base4 = stats(pool(s, 'std', 'Balanced', 0, BG['chain+look']) + pool(s, 'std', 'Balanced', -4, BG['chain+look']))
    def bld(b):
        a = stats(pool(s, b, 'Balanced', 0, BG['chain+look+newbie+charm']) + pool(s, b, 'Balanced', -4, BG['chain+look+newbie+charm']))
        c = stats(pool(s, 'std', 'Balanced', 0, BG['chain+look+newbie+charm']) + pool(s, 'std', 'Balanced', -4, BG['chain+look+newbie+charm']))
        return (a['win'] - c['win']) * 100 if a and c else None
    t1 = mean([f['_t1'] for f in f0 if f['build'] == 'std'])
    row = [s, sz, info[s]['level'], lo, hi, num(info[s]['foe']), num(info[s]['bar']), cap['n'], r3(cap['win']), r3(w[-8]['win']) if w[-8] else None, r3(w[-4]['win']), r3(b0['win']), r3(w[4]['win']) if w[4] else None,
           r3(b0['turns'], 2), None, r3(b0['hp']), r3(cap['cap']), r3(cap['swing']), r3(t1), r3(cap['fe'], 2), round(grit, 1), best, worst,
           r3(cas['win']) if cas else None, r3(nai['win']) if nai else None, round(bld('pals'), 1), round(bld('norare'), 1)]
    rrows.append(row)
    roll[s] = dict(row=row, w4=w[-4]['win'], t4=w[-4]['turns'], t0=b0['turns'], w0=b0['win'], t1=t1, fe=cap['fe'], lo=lo, hi=hi, pw=pw, sz=sz, base4=base4)
for i, r in enumerate(rrows): r[14] = f'=IF(OR(N{i + 2}="",D{i + 2}=""),"",IF(N{i + 2}<D{i + 2},"below",IF(N{i + 2}>E{i + 2},"above","in")))'
rf = {6: N2, 7: N2, 9: PCT, 10: PCT, 11: PCT, 12: PCT, 13: PCT, 14: N2, 16: PCT, 17: PCT, 18: PCT, 19: PCT, 20: N2, 21: N1, 24: PCT, 25: PCT, 26: N1, 27: N1}
rf = {6: N2, 7: N2, 9: PCT, 10: PCT, 11: PCT, 12: PCT, 13: PCT, 14: N2, 16: PCT, 17: PCT, 18: PCT, 19: PCT, 20: N2, 21: N1, 24: PCT, 25: PCT, 26: N1, 27: N1}
cells_total['Creature_rollup'] = out('Creature_rollup', RH, rrows, {k: v for k, v in rf.items() if k not in (15,)}, sheet='n_Creature_rollup')

# ---------------------------------------------------------------- Sonnet pilot findings (for the flags)
son = {}
for fn in sorted(glob.glob(f'{PFS}/*/*.json')):
    if os.path.basename(fn)[:-5] != os.path.basename(os.path.dirname(fn)): continue
    d = json.load(open(fn))
    if os.environ.get('SONNET_SLUGS') and d['slug'] not in set(open(os.environ['SONNET_SLUGS']).read().split()): continue   # only the creatures whose findings are in the workbook (Sonnet_findings)
    son[d['slug']] = d

# ---------------------------------------------------------------- Flags
flags = []
def fl(slug, flag, ev, sa, ba): flags.append([slug, flag, ev, sa, ba, 'open', None])
def diffc(sf, kinds): return sum(1 for x in sf if x.get('difficulty') in kinds)
cnt = defaultdict(int)
for s in slugs:
    r = roll[s]; d = son.get(s); sf = d.get('fights', []) if d else []; cr = d.get('creature', {}) if d else {}; lo, hi = r['lo'], r['hi']
    ns = len(sf); slost = sum(1 for x in sf if x.get('result') not in ('seen_off', 'charmed')); shard = diffc(sf, ('hard', 'too_hard', 'too-hard')); seasy = diffc(sf, ('too_easy', 'easy', 'too-easy'))
    sa = lambda yes, part=False: 'n/a' if not d else ('yes' if yes else ('partial' if part else 'no'))
    if r['w4'] < 0.6:
        fl(s, 'retune-hard', f"Balanced chain+look bots win {r['w4']:.0%} at offset -4 (rule: under 60%); offset 0: {r['w0']:.0%}" + (f'; Sonnet lost {slost} of {ns}, called {shard} hard' if d else ''), sa(shard * 2 >= ns or slost * 2 >= ns, shard or slost), 'yes'); cnt['retune-hard'] += 1
    elif d and ns and shard * 3 >= ns * 2:
        fl(s, 'retune-hard', f"Sonnet called {shard} of {ns} fights hard/too hard; bots do not agree (Balanced chain+look win {r['w4']:.0%} at -4)", 'yes', 'no'); cnt['retune-hard(sonnet only)'] += 1
    if r['w4'] > 0.98 and r['t4'] < lo / 2:
        fl(s, 'retune-easy', f"Balanced chain+look bots win {r['w4']:.0%} at offset -4 in {r['t4']:.1f} turns (rule: over 98% and under half the size target low of {lo}, i.e. under {lo / 2:g}); offset 0: {r['t0']:.1f} turns", sa(seasy * 2 >= ns, seasy), 'yes'); cnt['retune-easy'] += 1
    elif d and ns and seasy * 3 >= ns * 2:
        fl(s, 'retune-easy', f"Sonnet called {seasy} of {ns} fights easy/too easy; bots do not agree (win {r['w4']:.0%} at -4, {r['t4']:.1f} turns)", 'yes', 'no'); cnt['retune-easy(sonnet only)'] += 1
    if r['t1'] is not None and r['t1'] > 0.40:
        fl(s, 'turn1-kill', f"{r['t1']:.0%} of the offset-0 std-build bot fights are won on turn 1 (rule: over 40%)", sa(any(x.get('turns') == 1 for x in sf)), 'yes'); cnt['turn1-kill'] += 1
    if r['fe'] is not None and r['fe'] > 1.5:
        fl(s, 'forecast-error', f"mean |aim forecast - first creature chain| {r['fe']:.2f} HP per fight over all bot fights (rule: over 1.5 HP)", 'n/a', 'yes'); cnt['forecast-error'] += 1
    ef = {p: (r['pw'][p]['win'] - r['pw']['Balanced']['win']) * 100 for p in ('Luck', 'Lore')}
    if all(abs(v) < 1 for v in ef.values()):
        ceil = ' (a ceiling: Balanced wins %.0f%%, so the test cannot show an effect)' % (r['pw']['Balanced']['win'] * 100) if r['pw']['Balanced']['win'] >= 0.99 or r['pw']['Balanced']['win'] <= 0.01 else ''
        fl(s, 'stat-flat', f"Luck effect {ef['Luck']:+.1f} pts and Lore effect {ef['Lore']:+.1f} pts vs Balanced (chain+look, offsets 0 and -4; rule: both under 1 point){ceil}", 'n/a', 'yes'); cnt['stat-flat'] += 1
    if d:
        nconf = sum(len(x.get('confusing') or []) for x in sf); nrule = sum(1 for x in sf for c in (x.get('confusing') or []) if c.get('tag') == 'rule')
        if nrule >= 2: fl(s, 'clarity', f'{nrule} rule-confusion notes in {ns} Sonnet fights ({nconf} confusing notes in all)', 'yes', 'n/a'); cnt['clarity (sonnet)'] += 1
        if cr.get('class_rule_clear') is False: fl(s, 'class-rule', 'Sonnet: class rule not clear: ' + (cr.get('class_rule_note') or ''), 'yes', 'n/a'); cnt['class-rule (sonnet)'] += 1
        nb = sum(len(x.get('bugs') or []) for x in sf)
        if nb: fl(s, 'bug', f'{nb} bug report(s) in the Sonnet fights: ' + ' || '.join(str(b.get('output'))[:160] for x in sf for b in (x.get('bugs') or [])), 'yes', 'n/a'); cnt['bug (sonnet)'] += 1
        if cr.get('dominant_strategy'):
            wc = mean([f['_w'] for f in pool(s, 'std', 'Balanced', 0, ('chain',))])
            if wc is not None and wc >= 0.9:
                fl(s, 'dominant', f"the chain bot (longest chain, reads nothing) wins {wc:.0%} at offset 0 (Balanced); Sonnet: " + cr['dominant_strategy'][:300], 'yes', 'yes'); cnt['dominant'] += 1
flags_n = {k: v for k, v in cnt.items()}
FLH = ['creature_slug', 'flag', 'evidence', 'sonnet_agrees', 'bots_agree', 'status', 'reviewer_note']
cells_total['Flags'] = out('Flags', FLH, flags, sheet='n_Flags')
summary['flags'] = flags_n
summary['flag_creatures'] = {k: len({f[0] for f in flags if f[1] == k}) for k in {f[1] for f in flags}}
summary['flagged_any'] = len({f[0] for f in flags})
summary['sonnet_creatures'] = len(son)

# ---------------------------------------------------------------- Turns / Options_summary / Regret (the second, full pass over the sample)
fidF = {f['fight_id']: f for f in FF}
byturn = defaultdict(list)
for o in O: byturn[(o['fight_id'], int(o['turn']))].append(o)
reg = {(r['fight_id'], int(r['turn'])): r for r in R}
lab = lambda o: f"{o['piece']}@{o['cell']}" + (' flip' if o['flip'] == '1' else '')
TH = ['fight_id', 'turn', 'hp_start', 'hp_end', 'damage_start', 'damage_end', 'charm_start', 'charm_end', 'my_guard_start', 'my_guard_end', 'foe_guard_start', 'foe_guard_end', 'draw_n', 'discard_n', 'board_compact', 'env_next', 'hazards', 'hand', 'legal_moves',
      'chosen_piece', 'chosen_cell', 'chosen_flip', 'chosen_preview_d', 'chosen_preview_c', 'chosen_preview_h', 'chosen_preview_n', 'chosen_flags', 'foe_aim_cell', 'foe_forecast_hp', 'actual_hp_loss', 'forecast_error_hp', 'chain_len', 'pieces_fired',
      'pieces_used_up', 'damage_gained', 'charm_gained', 'foe_pieces_played', 'foe_damage_dealt', 'blocked_by_guard', 'evade_misses', 'quick', 'slow', 'grudge', 'riposte', 'poison_tick', 'my_pieces_fired_by_foe', 'notes',
      'creature_slug', 'size', 'profile', 'offset', 'bot']
trows = []; orows = []; rrw = []
for t in T:
    f = fidF.get(t['fight_id']); k = (t['fight_id'], int(t['turn']))
    notes = '; '.join(f'{k2}={t[k2]}' for k2 in ['aim_piece', 'aim_forecast_before', 'act_hp_lost_my_chain', 'hp_lost_turn', 'env_hp_lost', 'cr_bait_dmg', 'poison_on_it', 'my_evade_dodged_it', 'pred_d_err', 'pred_c_err', 'pred_h_err', 'reaim', 'over', 'chosen'] if t[k2] not in ('', '0'))
    F_ = 'F' + t['fight_id']
    trows.append([F_, num(t['turn']), num(t['hp_start']), num(t['hp_end']), num(t['dmg_start']), num(t['dmg_end']), num(t['charm_start']), num(t['charm_end']), num(t['my_guard']), num(t['my_guard_end']), num(t['creature_guard']), num(t['creature_guard_end']),
                  num(t['draw_n']), num(t['discard_n']), t['board'] or None, t['env_next'] or None, t['hazards'] or None, t['hand'] or None, num(t['legal_n']), t['chosen_piece'] or None, t['chosen_cell'] or None, 'yes' if t['chosen_flip'] == '1' else 'no',
                  num(t['pv_d']), num(t['pv_c']), num(t['pv_h']), num(t['pv_n']), t['pv_flags'] or None, t['aim_cell'] or None, num(t['aim_forecast_after']), num(t['actual_first_chain_hp']), num(t['forecast_err']),
                  num(t['my_chain_len']), num(t['my_pieces_fired']), num(t['used_up']), num(t['act_dmg']), num(t['act_charm']), num(t['cr_pieces']), num(t['cr_dmg_dealt']), num(t['cr_blocked_by_guard']), num(t['cr_evade_misses_mine']),
                  num(t['cr_quick']), num(t['cr_slow']), num(t['cr_grudge']), num(t['cr_riposte']), num(t['poison_on_me']), num(t['cr_fired_my_pieces']), notes or None,
                  t['creature'], f['size'] if f else None, t['profile'], num(t['offset']), t['bot']])
    ops = byturn.get(k, []); ch = [o for o in ops if o['chosen'] == '1']; c = ch[0] if ch else None
    def rank(key, rev=True):
        if not c: return None
        v = float(c[key]); return 1 + sum(1 for o in ops if (float(o[key]) > v if rev else float(o[key]) < v))
    if ops:
        bd = max(ops, key=lambda o: float(o['d'])); bc = max(ops, key=lambda o: float(o['c'])); sf_ = min(ops, key=lambda o: (float(o['turn_hp_lost']), -float(o['d']) - float(o['c'])))
        orows.append([F_, k[1], len(ops), rank('d'), rank('c'), rank('turn_hp_lost', False), lab(bd), lab(bc), lab(sf_), sum(o['end'] == 'win' for o in ops), sum(o['turn_over'] == 'defeat' for o in ops)])
    else: orows.append([F_, k[1], 0, None, None, None, None, None, None, 0, 0])
    r = reg.get(k); best = max((float(o['s_look']) for o in ops), default=None)
    rrw.append([F_, k[1], float(c['s_look']) if c else None, best, num(r['gap_dmg']) if r else None, num(r['gap_charm']) if r else None, num(r['gap_hp_lost']) if r else None, num(r['dead_hand']) if r else None, 1 if len(ops) == 1 else 0])
tf = {3: N1, 4: N1, 5: N1, 6: N1, 7: N1, 8: N1, 9: N1, 10: N1, 11: N1}
cells_total['Turns'] = out('Turns', TH, trows, sheet='n_Turns')
cells_total['Options_summary'] = out('Options_summary', ['fight_id', 'turn', 'n_options', 'chosen_rank_by_damage', 'chosen_rank_by_charm', 'chosen_rank_by_hp', 'best_damage_option', 'best_charm_option', 'safest_option', 'n_end_win_options', 'n_end_loss_options'], orows, sheet='n_Options_summary')
cells_total['Regret'] = out('Regret', ['fight_id', 'turn', 'chosen_score', 'best_score_look_bot', 'gap_damage', 'gap_charm', 'gap_hp', 'dead_hand', 'single_option'], rrw, {3: N2, 4: N2}, sheet='n_Regret')
summary['turn_sample'] = dict(fights=len({t['fight_id'] for t in T}), turns=len(T), by_size={s: len({t['fight_id'] for t in T if fidF[t['fight_id']]['size'] == s}) for s in SIZES},
                              regions=len({fidF[t['fight_id']]['region'] for t in T}), creatures=len({t['creature'] for t in T}))

# ---------------------------------------------------------------- Pieces roll-up: size x profile x piece key, top by contribution (the chain bot, seed 0, offset 0, std build, every creature)
acc = defaultdict(lambda: dict(n=0, v=0.0, drawn=0, played=0, fired=0, used=0, dmg=0.0, ch=0.0, hp=0, name='', type='', src='', rank='', cnt=0))
for p in P:
    f = fid.get(p['fight_id'])
    if not f or f['ctrl'] or f['bot'] != 'chain' or f['_o'] != 0 or f['build'] != 'std': continue
    a = acc[(f['size'], f['profile'], p['key'])]
    a['cnt'] += 1; a['v'] += float(p['value']); a['drawn'] += int(p['drawn']); a['played'] += int(p['played']); a['fired'] += int(p['fired']); a['used'] += int(p['used_up']); a['dmg'] += float(p['dmg']); a['ch'] += float(p['charm']); a['hp'] += int(p['hp'])
    a['name'] = p['name']; a['type'] = p['type']; a['src'] = p['source']; a['rank'] = p['rank']
per = defaultdict(list)
for (sz, pr, key), a in acc.items(): per[(sz, pr)].append((a['dmg'] + a['ch'], key, a))
K = int(os.environ.get('PIECE_K', 18)); prow = []
for sz in SIZES:
    for pr in PROFS:
        for tot, key, a in sorted(per[(sz, pr)], key=lambda x: -x[0])[:K]:
            prow.append([sz, pr, key, a['name'], a['type'], a['cnt'], round(a['v'] / a['cnt'], 1), a['src'], num(a['rank']), a['drawn'], a['played'], a['fired'], a['used'], round(a['dmg'], 1), round(a['ch'], 1), a['hp']])
cells_total['Pieces'] = out('Pieces', ['size', 'profile', 'piece_key', 'name', 'type', 'n_pieces_rolled', 'mean_final_value', 'source', 'rank', 'drawn', 'played', 'fired', 'used_up', 'damage_contrib', 'charm_contrib', 'hp_contrib'], prow, {7: N1}, sheet='n_Pieces')

# ---------------------------------------------------------------- Runs
n_grid = len(main); n_ctrl = len(F) - n_grid
secs = sum(float(f['secs']) for f in F)
runs = [[RUN, '2026-11-22', F[0]['git_sha'], F[0]['version'], 'tests/pf_collect.php GRID=full (lean) + sample pass', 'bots', 'chain,look,newbie,charm,random,greedy,defensive',
         '3 seeds per cell, pf_bots formula 500+13k+level+1000*(crc32(slug)%97)', None, num(WALL),
         f'{len(F)} fights over all {len(slugs)} creatures ({n_grid} grid + {n_ctrl} controls: Balanced, offset 0, one raw stat +2/-2, every 5th creature, chain and look); {secs / 3600:.1f} CPU-hours. Sheet = aggregates; row-level CSV (all_fights.csv) and the sampled-turn pass are in the collect3 folder, not committed.'],
        ['sonnet-pilot', '2026-11-22', None, None, 'tests/pf_play.php (Sonnet tester agent)', 'sonnet', None, None, None, None, f'{sum(len(d["fights"]) for d in son.values())} Sonnet pilot fights on {len(son)} creatures; findings in Sonnet_findings (judgement, not ground truth)']]
cells_total['Runs'] = out('Runs', ['run_id', 'date', 'git_sha', 'app_version', 'harness_version', 'tester', 'bots', 'seeds', 'token_cost_usd', 'wall_minutes', 'notes'], runs, sheet='n_Runs')

# ---------------------------------------------------------------- summaries for the README
def wr(rows): return mean([f['_w'] for f in rows])
sm = {}
for p in PROFS:
    sm[p] = {}
    for key, bots, off in (('all', ('chain', 'look'), None), ('0', ('chain', 'look'), 0), ('-4', ('chain', 'look'), -4)):
        a = [f for f in main if f['profile'] == p and f['build'] == 'std' and f['bot'] in bots and (off is None or f['_o'] == off) and f['_o'] in (0, -4)]
        sm[p][key] = [len(a), r3(wr(a), 4), r3(mean([f['_t'] for f in a]), 2)]
summary['win_by_profile'] = sm
summary['win_by_profile_all_offsets_all_bots'] = {p: r3(wr([f for f in main if f['profile'] == p]), 4) for p in PROFS}
summary['win_by_offset'] = {str(o): r3(wr([f for f in main if f['_o'] == o and f['profile'] == 'Balanced' and f['build'] == 'std' and f['bot'] in ('chain', 'look')]), 4) for o in (-8, -4, 0, 4)}
summary['win_by_bot'] = {b: {str(o): r3(wr([f for f in main if f['bot'] == b and f['_o'] == o and f['profile'] == 'Balanced' and f['build'] == 'std']), 4) for o in (0, -4)} for b in ['chain', 'look', 'newbie', 'charm', 'random', 'greedy', 'defensive']}
summary['win_by_build'] = {b: {str(o): r3(wr([f for f in main if f['build'] == b and f['_o'] == o and f['profile'] == 'Balanced' and f['bot'] in ('chain', 'look', 'newbie', 'charm')]), 4) for o in (0, -4)} for b in ['std', 'pals', 'norare']}
summary['win_by_size_off0'] = {s: r3(wr([f for f in main if f['size'] == s and f['_o'] == 0 and f['profile'] == 'Balanced' and f['build'] == 'std' and f['bot'] in ('chain', 'look')]), 4) for s in SIZES}
base = {(f['creature'], f['bot'], f['seed']): f for f in main if f['profile'] == 'Balanced' and f['_o'] == 0 and f['build'] == 'std'}
ctl = {}
for c in sorted({f['ctrl'] for f in F if f['ctrl']}):
    a = [f for f in F if f['ctrl'] == c]; b = [base[(f['creature'], f['bot'], f['seed'])] for f in a if (f['creature'], f['bot'], f['seed']) in base]
    ctl[c] = [len(a), r3((wr(a) - wr(b)) * 100, 2), r3(mean([f['_t'] for f in a]) - mean([f['_t'] for f in b]), 2)]
summary['controls_win_delta_pts_turn_delta'] = ctl
summary['cells'] = cells_total; summary['cells_total'] = sum(cells_total.values()); summary['fights'] = len(F); summary['grid'] = n_grid; summary['controls'] = n_ctrl; summary['creatures'] = len(slugs)
summary['cpu_hours'] = round(secs / 3600, 2)
summary['balanced_off_m4_chain_look_buckets'] = {'under60': sum(1 for s in slugs if roll[s]['w4'] < 0.6), 'over98': sum(1 for s in slugs if roll[s]['w4'] > 0.98), 'mean': r3(mean([roll[s]['w4'] for s in slugs]), 3)}
json.dump(summary, open(f'{D}/summary.json', 'w'), indent=1)
print(json.dumps(summary, indent=1)[:6000])
