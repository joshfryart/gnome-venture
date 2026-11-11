import json,collections
F=json.load(open('replay.json'))
def pct(a,b): return f"{100*a/max(1,b):.0f}%"
for mode in ['classic','blank','all']:
  fs=[f for f in F if mode=='all' or f['mode']==mode]
  wins=[f for f in fs if f['over'] in('seen_off','charmed')]; defs=[f for f in fs if f['over']=='defeat']
  print(f"== {mode} n={len(fs)} win {pct(len(wins),len(fs))} defeat {pct(len(defs),len(fs))} other {collections.Counter(f['over'] for f in fs)}")
  pl=[t for f in fs for t in f['turns'] if t['cmd']=='place']
  forced=[t for t in pl if t['nlegal']>0 and t['nsafe']==0]
  print(f" places {len(pl)}, forced-hurt decisions (all legal places fire creature Hurt) {len(forced)} ({pct(len(forced),len(pl))}); of them join available {sum(t['canjoin'] for t in forced)}; mean minimum self-hurt {sum(t['minsh'] for t in forced)/max(1,len(forced)):.1f}, actual {sum(t['selfhurt'] for t in forced)/max(1,len(forced)):.1f}")
  unforced=[t for t in pl if t['nsafe']>0 and t['selfhurt']>0]
  print(f" self-hurt by choice (a safe cell existed): {len(unforced)} places, dmg {sum(t['selfhurt'] for t in unforced)}")
  # defeats: fights with a forced turn
  for lab,grp in [('defeats',defs),('wins',wins)]:
    n=len(grp); 
    if not n: continue
    hf=sum(any(t['cmd']=='place' and t['nlegal']>0 and t['nsafe']==0 for t in f['turns']) for f in grp)
    sh=sum(t['selfhurt'] for f in grp for t in f['turns']); ft=sum(t['foeturn'] for f in grp for t in f['turns']); rf=sum(t['foerefire'] for f in grp for t in f['turns'])
    big=sum(any(t['selfhurt']>=20 for t in f['turns']) for f in grp)
    print(f" {lab} n={n}: had forced-hurt turn {pct(hf,n)}; had single self-hurt>=20 {pct(big,n)}; per fight self-hurt in own chain {sh/n:.1f}, creature turn {ft/n:.1f} (of which re-fire {rf/n:.1f}), creature-guard absorbed my Hurt {sum(t['myblocked'] for f in grp for t in f['turns'])/n:.1f}, guard fired too late {sum(t['guardlate'] for f in grp for t in f['turns'])/n:.1f}, poison {sum(t['poison'] for f in grp for t in f['turns'])/n:.1f}")
  # max single-move self hurt
  mx=sorted([t['selfhurt'] for t in pl],reverse=True)[:5]; print(" top self-hurt moves",mx)
  # set aside
  sa=[f for f in fs if any(t['cmd'] in('join','add') for t in f['turns'])]
  gp=[t for f in fs for t in f['turns'] if t['cmd']=='group']
  print(f" fights using set-aside {len(sa)}, win {pct(sum(f['over'] in('seen_off','charmed') for f in sa),len(sa))}; groups placed {len(gp)}; joins {sum(t['cmd']=='join' for f in fs for t in f['turns'])}, adds {sum(t['cmd']=='add' for f in fs for t in f['turns'])}")
  # group of 3 placements: fh gained? skip
  jt=[t for t in pl if t['canjoin']]; print(f" place decisions where a join was legal: {pct(len(jt),len(pl))}")
