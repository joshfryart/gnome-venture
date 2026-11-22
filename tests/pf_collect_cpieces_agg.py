#!/usr/bin/env python3
"""Aggregate the creature-piece run of tests/pf_collect.php (GRID=cp): merges the shards and writes CSVs and REPORT.md.

    python3 tests/pf_collect_cpieces_agg.py OUTDIR [OLD_PIECES_CSV]

OUTDIR holds fights.N.csv, pieces.N.csv, creature_pieces.N.csv. OLD_PIECES_CSV (optional) is an earlier all_pieces.csv (player pieces) for a before/after table.
Definitions (per creature piece = one deck piece in one fight):
  placed rate   = placements / draws          fire rate = pieces that fired at least once / pieces placed      fires per placement = fires / placements
  avg dmg       = hp damage dealt / placement  dmg share = group damage / all creature piece damage            blocked % = guard-absorbed / (dmg + absorbed) of Hurt pieces
  evaded %      = Hurt firings that your Evade made miss / Hurt firings
"""
import glob, sys, os
import pandas as pd

D = sys.argv[1]; OLD = sys.argv[2] if len(sys.argv) > 2 else None

def merge(t):
    fs = sorted(glob.glob(f'{D}/{t}.[0-9]*.csv'))
    df = pd.concat([pd.read_csv(f, low_memory=False, dtype={'fight_id': str}) for f in fs if os.path.getsize(f) > 0], ignore_index=True)
    df.to_csv(f'{D}/all_{t}.csv', index=False)
    return df

F = merge('fights'); P = merge('pieces'); C = merge('creature_pieces')
C['tag'] = C['tag'].fillna(''); C['mod'] = C['mod'].fillna('')
C['type_tag'] = C['type'] + ':' + C['tag'].replace('', '-')
C['placed_any'] = (C['placed'] > 0).astype(int)
C['fired_any'] = ((C['fired'] > 0) & (C['placed'] > 0)).astype(int)
C['is_hurt'] = (C['type'] == 'hurt').astype(int)
C['hurt_fires'] = C['fired'] * C['is_hurt']
C['hurt_dmg'] = C['dmg'] * C['is_hurt']
C['hurt_blk'] = C['blocked'] * C['is_hurt']
TOT_DMG = C['dmg'].sum()
RES = f'{D}'

def agg(df, by):
    g = df.groupby(by)
    o = pd.DataFrame({
        'pieces': g.size(), 'draws': g['drawn'].sum(), 'placements': g['placed'].sum(), 'fires': g['fired'].sum(),
        'dmg': g['dmg'].sum(), 'blocked': g['blocked'].sum(), 'evaded': g['evaded'].sum(), 'hurt_fires': g['hurt_fires'].sum(), 'guard_gain': g['guard_gain'].sum(), 'healed': g['healed'].sum(),
        'used_by_me': g['used_by_me'].sum(), 'fell': g['fell'].sum(), 'expired': g['expired'].sum(), 'placed_any': g['placed_any'].sum(), 'fired_any': g['fired_any'].sum()})
    o['placed_rate'] = o['placements'] / o['draws'].clip(lower=1)
    o['fire_rate'] = o['fired_any'] / o['placed_any'].clip(lower=1)
    o['fires_per_placement'] = o['fires'] / o['placements'].clip(lower=1)
    o['avg_dmg_per_placement'] = o['dmg'] / o['placements'].clip(lower=1)
    o['avg_dmg_per_draw'] = o['dmg'] / o['draws'].clip(lower=1)
    o['dmg_share'] = o['dmg'] / TOT_DMG
    o['blocked_pct'] = g['hurt_blk'].sum() / (g['hurt_dmg'].sum() + g['hurt_blk'].sum()).clip(lower=1)
    o['evaded_pct'] = o['evaded'] / o['hurt_fires'].clip(lower=1)
    o['used_by_me_per_placement'] = o['used_by_me'] / o['placements'].clip(lower=1)
    return o.round(4)

tabs = {}
tabs['size'] = agg(C, 'size'); tabs['class_rule'] = agg(C, 'class_rule'); tabs['type'] = agg(C, 'type'); tabs['tag'] = agg(C[C['tag'] != ''], 'tag')
tabs['type_tag'] = agg(C, 'type_tag'); tabs['mod'] = agg(C[C['mod'] != ''], 'mod'); tabs['size_type'] = agg(C, ['size', 'type'])
tabs['bot'] = agg(C, 'bot'); tabs['profile'] = agg(C, 'profile'); tabs['offset'] = agg(C, 'offset')
tabs['name'] = agg(C, ['name', 'type', 'tag'])
tabs['creature'] = agg(C, ['creature', 'size', 'creature_level', 'class_rule'])
for k, v in tabs.items(): v.to_csv(f'{RES}/cp_by_{k}.csv')
# pieces that rarely fire: a creature's piece slot (key) over all its fights
S = agg(C, ['creature', 'size', 'class_rule', 'key', 'name', 'type', 'tag']); S.to_csv(f'{RES}/cp_by_slot.csv')
cr = tabs['creature'].copy()
rare = S[(S['placements'] >= 6)].sort_values('fire_rate').head(40); rare.to_csv(f'{RES}/cp_rarely_fire.csv')
cr_rare = cr.sort_values('fire_rate').head(30); cr_rare.to_csv(f'{RES}/cp_creatures_rarely_fire.csv')

# ---- player pieces (post-refit)
def pagg(df, by):
    g = df.groupby(by)
    o = pd.DataFrame({'pieces': g.size(), 'drawn': g['drawn'].sum(), 'played': g['played'].sum(), 'fired': g['fired'].sum(), 'dmg': g['dmg'].sum(), 'charm': g['charm'].sum(), 'hp': g['hp'].sum()})
    o['play_pct'] = o['played'] / o['drawn'].clip(lower=1)
    o['dmg_per_draw'] = o['dmg'] / o['drawn'].clip(lower=1); o['charm_per_draw'] = o['charm'] / o['drawn'].clip(lower=1); o['hp_per_draw'] = o['hp'] / o['drawn'].clip(lower=1)
    o['eff_per_draw'] = (o['dmg'] + o['charm']) / o['drawn'].clip(lower=1)   # damage + charm moved on the creature's bars per draw
    return o.round(4)
FM = F[['fight_id', 'bot', 'offset', 'profile']]
PP = P.merge(FM, on='fight_id')
pk = pagg(PP, ['key', 'name', 'type', 'source']); pk.to_csv(f'{RES}/player_by_key.csv')
ps = pagg(PP, 'source'); ps.to_csv(f'{RES}/player_by_source.csv'); pt = pagg(PP, 'type'); pt.to_csv(f'{RES}/player_by_type.csv')
cmp_txt = []
if OLD and os.path.exists(OLD):
    O = pd.read_csv(OLD); N = PP[(PP['bot'] == 'chain') & (PP['offset'] == 0)]
    ok = pagg(O, ['key']); nk = pagg(N, ['key'])
    m = ok.join(nk, lsuffix='_old', rsuffix='_new', how='inner')
    m['d_play_pct'] = m['play_pct_new'] - m['play_pct_old']; m['d_eff_per_draw'] = m['eff_per_draw_new'] - m['eff_per_draw_old']
    m[['drawn_old', 'drawn_new', 'play_pct_old', 'play_pct_new', 'd_play_pct', 'eff_per_draw_old', 'eff_per_draw_new', 'd_eff_per_draw']].round(4).to_csv(f'{RES}/player_before_after.csv')
    so = pagg(O, 'source'); sn = pagg(N, 'source'); ms = so.join(sn, lsuffix='_old', rsuffix='_new', how='outer'); ms.to_csv(f'{RES}/player_source_before_after.csv')
    cmp_txt = [m, ms]

# ---- report
def pct(x): return f'{100 * x:.1f}%'
L = []
nf = len(F); nc = F['creature'].nunique()
L.append('# Creature-piece collection, post-refit (GRID=cp)')
L.append(f'Build: git {F["git_sha"].iloc[0]} version {F["version"].iloc[0]} (small/medium refit included). Sample: {nf} fights, {nc} creatures, bots chain+look, profiles Balanced+Grit, offsets 0 and -4, 3 seeds, build std; seed 500+13k+level+1000*(crc32(slug)%97).')
L.append(f'Creature-piece rows {len(C)} (all creature deck pieces, every fight); player-piece rows {len(P)}. Wins {pct(F["win"].mean())}, mean turns {F["turns"].mean():.2f}, mean creature pieces placed per fight {F["cr_pieces_placed"].mean():.2f} of {F["cr_pieces_total"].mean():.1f} in the deck, fired {F["cr_pieces_fired"].mean():.2f}, creature piece damage {F["cr_dmg_total"].mean():.1f} per fight (blocked {F["cr_blocked_total"].mean():.1f}).')
L.append(f'Total creature piece damage {int(TOT_DMG)}; guard absorbed {int(C["blocked"].sum())}; evaded Hurt firings {int(C["evaded"].sum())}. Definitions: see docstring of tests/pf_collect_cpieces_agg.py. Caveats: pieces are per deck slot per fight; "placed rate" = placements/draws (a drawn piece can stay in hand, or be redrawn); damage counts hp lost from the piece (poison ticks, terrain and reflect-free hits are not included; Riposte reflect is); fires in my chain count as fires.')
cols = ['pieces', 'draws', 'placed_rate', 'fire_rate', 'fires_per_placement', 'avg_dmg_per_placement', 'dmg_share', 'blocked_pct', 'evaded_pct']
def table(df, title, cols=cols, n=None):
    L.append(''); L.append(f'## {title}'); L.append('| ' + df.index.name + ' | ' + ' | '.join(cols) + ' |' if not isinstance(df.index, pd.MultiIndex) else '| ' + ' / '.join(df.index.names) + ' | ' + ' | '.join(cols) + ' |')
    L.append('|' + '---|' * (len(cols) + 1))
    for i, r in (df if n is None else df.head(n)).iterrows():
        lab = ' / '.join(str(x) for x in i) if isinstance(i, tuple) else str(i)
        L.append(f'| {lab} | ' + ' | '.join((pct(r[c]) if c in ('placed_rate', 'fire_rate', 'dmg_share', 'blocked_pct', 'evaded_pct') else (f'{r[c]:.2f}' if isinstance(r[c], float) else str(int(r[c])))) for c in cols) + ' |')
table(tabs['size'], 'By creature size'); table(tabs['class_rule'], 'By class rule'); table(tabs['type'], 'By piece type'); table(tabs['tag'].sort_values('dmg_share', ascending=False), 'By ability tag (tagged pieces)')
nm = tabs['name'][tabs['name']['placements'] >= 30]
table(nm.sort_values('dmg_share', ascending=False), 'Top 10 piece names by damage share (placements >= 30)', n=10)
table(nm.sort_values('dmg_share'), 'Bottom 10 piece names by damage share (placements >= 30)', n=10)
nf2 = nm[nm['draws'] >= 30]
table(nf2.sort_values('fire_rate', ascending=False), 'Top 10 piece names by fire rate', n=10)
table(nf2.sort_values('fire_rate'), 'Bottom 10 piece names by fire rate', n=10)
cc = ['pieces', 'placed_rate', 'fire_rate', 'fires_per_placement', 'avg_dmg_per_placement', 'dmg_share']
table(cr_rare, 'Creatures whose pieces rarely fire (lowest fire rate, 30)', cols=cc, n=15)
table(rare, 'Piece slots that rarely fire (placements >= 6)', cols=cc, n=15)
L.append(''); L.append('## Player pieces, post-refit (all %d fights)' % nf)
pc = ['pieces', 'drawn', 'play_pct', 'dmg_per_draw', 'charm_per_draw', 'hp_per_draw', 'eff_per_draw']
def ptable(df, n=None, title=''):
    L.append(''); L.append(f'### {title}'); L.append('| ' + ' / '.join(df.index.names) + ' | ' + ' | '.join(pc) + ' |'); L.append('|' + '---|' * (len(pc) + 1))
    for i, r in (df if n is None else df.head(n)).iterrows():
        lab = ' / '.join(str(x) for x in i) if isinstance(i, tuple) else str(i)
        L.append(f'| {lab} | ' + ' | '.join(pct(r[c]) if c == 'play_pct' else (f'{r[c]:.2f}' if isinstance(r[c], float) else str(int(r[c]))) for c in pc) + ' |')
ptable(ps, title='By source'); ptable(pt, title='By type')
big = pk[pk['drawn'] >= 200]
ptable(big.sort_values('eff_per_draw', ascending=False), 10, 'Top 10 keys by eff/draw (drawn >= 200)'); ptable(big.sort_values('eff_per_draw'), 10, 'Bottom 10 keys by eff/draw'); ptable(big.sort_values('play_pct'), 8, 'Lowest play% keys')
if cmp_txt:
    m, ms = cmp_txt
    L.append(''); L.append('### Before/after (collect3 all_pieces = chain, seed 0, offset 0, pre-refit sample, vs this run chain, offset 0, 3 seeds): largest eff/draw changes (drawn >= 100 both)')
    mm = m[(m['drawn_old'] >= 100) & (m['drawn_new'] >= 100)]
    L.append('| key | play% old | play% new | eff/draw old | eff/draw new |'); L.append('|---|---|---|---|---|')
    for i, r in pd.concat([mm.sort_values('d_eff_per_draw').head(5), mm.sort_values('d_eff_per_draw').tail(5)]).iterrows():
        L.append(f'| {i} | {pct(r["play_pct_old"])} | {pct(r["play_pct_new"])} | {r["eff_per_draw_old"]:.2f} | {r["eff_per_draw_new"]:.2f} |')
    L.append(f'Mean play% old {pct(m["play_pct_old"].mean())} new {pct(m["play_pct_new"].mean())} (keys in both: {len(m)}). Sample differs in creatures/seeds, so read as a rough direction only.')
L.append(''); L.append('CSVs: cp_by_*.csv (size, class_rule, type, tag, type_tag, mod, size_type, bot, profile, offset, name, creature, slot), cp_rarely_fire.csv, cp_creatures_rarely_fire.csv, player_by_*.csv, player_before_after.csv, all_creature_pieces.csv.')
open(f'{RES}/REPORT.md', 'w').write('\n'.join(L) + '\n')
print(len(L), 'lines')
