# Balance 2.7.27: puzzle combat bot sims (2026-11-19)

Read-only analysis: no game file was edited, nothing committed. All sims run on the real PHP engine (`game/includes/pfboard.php`, `pfdeck.php`), no DB, no file writes (output goes to a scratch dir). Wind and Mud are on from the start (`nowm` 0, since 2.7.08).

## 1. Method and commands (reproducible)

Existing tools used as-is (all read-only, ~7 s per 250 fights per core):

```
# size x offset win / turns table, tuner bots (chain = always the longest chain; look = best state after the round)
for b in chain look; do for sh in 0 1 2 3; do php tests/pfboard_tune_v1.php $b 0,-4,4 1 $sh/4 json > out_${b}_$sh.json & done; done; wait
cat out_chain_*.json | php tests/pfboard_tune_v1.php agg          # (same for look)
# all 7 playtest bots, std + pals builds, 88 creatures, 2 seeds
for sh in 0 1 2 3; do php tests/pf_bots.php all 0 2 std,pals $sh/4 json > bots_$sh.json & done; wait
cat bots_*.json | php tests/pf_bots.php agg
# what-if on any rule number (V1 = pfb_v1_cfg overrides, a map by size is allowed)
V1='{"bar_x":{"small":2.3,"medium":1.5,"large":0.55,"boss":0.6},"foe_x":{"small":0.6,"medium":0.7,"large":1.8,"boss":1.55}}' php tests/pfboard_tune_v1.php chain 0 0.6 0/1
```

Two scratch scripts (appendix; not in the repo) add what the stock tools lack: per-creature rows, gentle / hostile split (temper comes from `pf_temper()`: the `PF_GENTLE` slug list, everything else hostile), per-piece fire counts, environment fire counts (incl. Mud hits), and a starter-kit-only gnome (`PFD_CORE` + one `PFD_KITS` kit, no belt / pals / crops / knacks, all stats 0, creatures of level <= 8, gnome at creature level).

```
for sh in 0 1 2 3; do php sim.php $sh/4 10 std    > std_$sh.json & done; wait    # 880 fights, chain bot, std gnome at creature level
for sh in 0 1 2 3; do php sim.php $sh/4 20 starter > st_$sh.json  & done; wait    # 360 fights, starter-kit gnome, creatures L<=8
for sh in 0 1 2 3; do V1='{"nowm":1}' php sim.php $sh/4 10 std > nowm_$sh.json & done; wait   # Wind/Mud off, same seeds
php an.php std ; php an.php st ; php an.php nowm
```

Targets used: win small 83 / medium 85 / large 68 / boss 78 (the 2.7.08 fit targets, chain bot at level); fight length 4-5 turns (todo.md, Josh 2026-11-17 "keep today's bars (4-5 turns)"; `pfboard_tune_v1.php` header still says 6-8, small 4-5 - see finding 1).

## 2. Results

### 2.1 Size x level offset (tuner bots, ~210 fights per cell, 88 creatures, std gnome)

| bot | offset | small win / turns | medium | large | boss |
|---|---|---|---|---|---|
| chain | +0 | 84% / 1.9 | 88% / 3.3 | 72% / 8.2 | 84% / 8.5 |
| chain | -4 | 78% / 1.8 | 49% / 3.2 | 36% / 8.1 | 63% / 8.7 |
| chain | +4 | 96% / 1.8 | 96% / 2.8 | 85% / 7.5 | 92% / 8.3 |
| look | +0 | 98% / 1.9 | 100% / 3.1 | 100% / 7.9 | 100% / 8.3 |
| look | -4 | 94% / 1.9 | 80% / 3.9 | 100% / 10.2 | 100% / 9.1 |
| look | +4 | 100% / 1.6 | 100% / 2.5 | 100% / 6.8 | 100% / 7.5 |

Fight length vs the 4-5 turn target (chain, level, creature means): small 1.9 (all 10 creatures short), medium 3.3 (21 of 26 short), large 8.2 (all 43 long), boss 8.5 (all 9 long). Nothing sits in 4-5 except 1 medium.

### 2.2 All bots, offset 0, 88 creatures x 2 seeds (`pf_bots.php`)

| bot | build | small | medium | large | boss |
|---|---|---|---|---|---|
| chain | std | 75 / 1.9 | 75 / 3.6 | 67 / 8.2 | 89 / 8.8 |
| chain | pals | 100 / 1.9 | 94 / 3.0 | 64 / 7.9 | 89 / 9.0 |
| look | std | 90 / 1.9 | 98 / 3.3 | 100 / 8.0 | 100 / 8.3 |
| greedy | std | 85 / 1.8 | 87 / 2.7 | 85 / 6.5 | 94 / 7.2 |
| charm | std | 85 / 2.1 | 79 / 3.4 | 91 / 8.0 | 94 / 8.6 |
| newbie | std | 70 / 2.0 | 62 / 4.1 | 72 / 8.9 | 67 / 8.9 |
| random | std | 35 / 3.2 | 48 / 5.1 | 47 / 10.7 | 50 / 11.2 |
| defensive | std | 60 / 3.9 | 63 / 7.8 (cap 2%) | 83 / 17.1 (cap 16%) | 78 / 18.6 |

(win % / mean turns.) Spread chain-to-look at large / boss is 67 vs 100: the skill gap is huge there; a random player still wins ~47-50% of large / boss fights.

### 2.3 Temper and starter kit

| set | gentle | hostile |
|---|---|---|
| std gnome at level, all 880 fights | 76% / 5.4 t | 74% / 6.1 t |
| large only | 70% / 8.6 | 69% / 7.5 |
| medium only | 80% / 3.0 | 83% / 3.4 |
| small only | 85% / 2.1 | 72% / 1.9 |
| starter-kit gnome, small | 79% / 2.0 | 74% / 1.9 |
| starter-kit gnome, medium | 80% / 2.8 | 69% / 2.9 |

Temper is balanced overall (gentle and hostile within 2 points); hostile small is 13 points under gentle small (std), hostile medium 11 under gentle (starter).

### 2.4 Creature outliers (std gnome, chain bot at level, 10 seeds each)

- Under target / low: bog-pike (L20 large, hostile) 30%, hermit-crab-hoarder (L12 medium, gentle) 40%, desert-camel (L27 large, gentle) 40%, tide-crab-knight 50%, badger 50%, coconut-crab-titan (L26 boss) 50%. No creature is below 10%.
- At 100% (10 of 10): aphid-swarm, garden-snail (both L1 small, 2.0 turns), barn-rat (L8, 2.0 t), dust-sidewinder, ptarmigan-flock, savanna-hyena, leafcutter-column (medium) and storm-eagle (L32 boss, 9.3 t). aphid-swarm sits at foe_x 3.035 of a 3.1 limit and is still a ceiling: the foe side cannot be lifted any further inside the tune bounds.
- Longest: fern-cassowary 9.4, delta-gharial 9.3 (60% win), beaver-foreman 9.3, storm-eagle 9.3, pelican-parliament 9.2.
- Starter-kit gnome weakest: sand-fleas 55%, bog-leech 60%, orb-spider 60%, dung-beetle 65%. Hardest early creatures are L3-6 medium and L3 small, not the L1-2 ones.

### 2.5 Pieces (chain bot, per fight, over the decks that hold the piece)

Fires per fight: t:axe 1.12, Samara Spin pal 1.05, swing 1.04, thorn (calling) 0.97, till 0.87, bloom 0.83, smash 0.83, lantern 0.77 (all 49-65% of fights); jab 0.45, charm 0.49, pierce 0.53. Under-used: **rest 0.07 (fires in 6% of fights)**, soothe 0.14, brace 0.17, c:grain 0.18, dodge 0.24, Bark Badger 0.23, brew 0.15, Bark Wall 0.22. Starter gnome: swing 1.45 per fight (73% of fights) vs jab 0.39, rest 0.12 (win when fired 42%), c:grain 0.20 (37%), sow 0.22 (40%); Hurt pieces dominate and the heal / guard / trick / item pieces are mostly dead weight. Base values (`pf_pieces.txt`): swing hurt 4, jab hurt 3 + quick, pierce hurt 3, rest heal 3, dodge guard 4, brace guard 3 + hold, soothe 2.

### 2.6 Wind and Mud (nowm=0 vs nowm=1, same 880 seeds, chain bot)

| size | nowm=1 (off) win / turns | nowm=0 (now) win / turns |
|---|---|---|
| small | 84% / 2.1 | 80% / 2.0 |
| medium | 88% / 3.3 | 82% / 3.2 |
| large | 69% / 7.7 | 69% / 7.9 |
| boss | 81% / 8.4 | 78% / 8.3 |

Per fight now: Wind placed 0.99, fired by you 0.41 / by the creature 0.14; Mud placed 0.90, "Mud hit" (a firing piece -25%) 0.52 against creature pieces vs 0.38 against yours. So Mud slightly favours the player (the chain bot does not avoid it, the creature AI does not use it), Wind is a rare effect (1 a fight). Net cost to the player is 4-6 points of win rate in small / medium, none in large. Not an outlier: both within the target band once the 2.7.08 fit is redone; but the tune rows were fitted before nowm went to 0 (the 2.7.08 fit ran with Wind / Mud out), so small / medium are 3-5 points under their targets (83 / 85 -> 80 / 82 here; the pals / look builds hide it).

## 3. Findings (ranked)

1. **Fight length is far off the 4-5 target in both directions.** Small 1.9, medium 3.3, large 8.2, boss 8.5 turns (chain, at level; random 10-11, defensive 17-19). Small and medium are over by turn 2-3 for the std gnome; large and boss run twice the target. The `pfboard_tune_v1.php` header (6-8 turns) and todo.md (4-5) disagree: decide which is wanted first.
2. **Skill gap at large / boss.** Chain bot 67-72% vs look bot 100% (also at -4 levels: look still wins 100% of large / boss at -4, 94-100% at -8 in earlier runs). A thinking player is never challenged by large / boss creatures; the simplest bot is. The look bot at 100% in every cell from +0 up means the targets are met only for the weakest competent play.
3. **Hurt pieces dominate; rest / soothe / brace / dodge are rarely fired.** swing, axe, Samara Spin are fired about 1 a fight; rest in 6% of fights (and 42% win when fired). Starter-kit gnome plays swing 1.45 a fight. Heal at value 3 is outclassed by a fight that is 2-3 turns long.
4. **Starter kit is fine overall (77% small / 74% medium) but hostile medium is the weak spot (69%) and 4 early creatures are under 65%** (sand-fleas, bog-leech, orb-spider, dung-beetle); gentle small is easy (79%+).
5. **Wind / Mud cost 4-6 win points at small / medium and are not wired into the tune rows** (rows refit with them out). Mud helps the player slightly (0.52 vs 0.38 hits); Wind fires about once a fight.
6. Single-creature outliers: bog-pike 30%, hermit-crab-hoarder 40%, desert-camel 40% (too hard); aphid-swarm, garden-snail, barn-rat, storm-eagle 100% (too easy; aphid-swarm hit the foe_x cap 3.1).

## 4. Proposed number changes (not applied)

Only needed if 4-5 turn fights are the goal. These are what-if results from `V1=` overrides on the chain bot at level (130 fights per size; per-creature tune rows folded in as shipped). Multipliers are on top of the constants; the shipped per-creature `foe_x` / `bar_x` rows would have to be refit after (`pf_creature_tune.txt`, 319 rows, the 2.7.08 fit step) because they currently compensate the old constants.

| file | constant | old | new | expected effect (chain, std, level) |
|---|---|---|---|---|
| `game/includes/pfboard.php` (+ `tools/pfengine.js` mirror) | `PFB_V1_BAR_MULT` small | 1.378 | ~3.2 (x2.3) | small 1.9 -> 3.5-3.9 turns |
| same | `PFB_V1_BAR_MULT` medium | 1.7743 | ~2.66 (x1.5) | medium 3.3 -> 4.7-4.8 turns |
| same | `PFB_V1_BAR_MULT` large | 1.7193 | ~0.95 (x0.55) | large 8.2 -> 4.3-4.7 turns |
| same | `PFB_V1_BAR_MULT` boss | 0.9158 | ~0.55 (x0.6) | boss 8.5 -> 5.2-5.6 turns |
| same | `PFB_V1_FOE_MULT` small | 0.93 | ~0.45-0.5 | holds small win (x0.45-0.6 gave 59-73% at x2.3-2.0 bar; small is the hardest to hold, needs the refit) |
| same | `PFB_V1_FOE_MULT` medium | 0.735 | ~0.52 (x0.7) | medium win 82-85% |
| same | `PFB_V1_FOE_MULT` large | 0.428 | ~0.77-0.82 (x1.8-1.9) | large win 66-78% (target 68) |
| same | `PFB_V1_FOE_MULT` boss | 0.60 | ~0.93-1.0 (x1.55-1.65) | boss win 63-81% (target 78) |
| `game/includes/data/pf_pieces.txt` | `rest` v | 3 | 5 (or add a tag) | Heal worth a placement; fires in 6% of fights now |
| same | `dodge` v / `brace` v | 4 / 3 | 5 / 4 | guard competes with swing (axe, swing fire ~1/fight, guard 0.2) |
| `game/includes/data/pf_creature_tune.txt` | aphid-swarm, garden-snail, barn-rat (100%) | foe_x 3.035 (aphid) | lift ceiling past 3.1 or raise their pieces in `pf_creatures.txt` | 100% -> ~85% |
| same | bog-pike, hermit-crab-hoarder, desert-camel | now | foe_x -10-15% | 30-40% -> ~60-65% |

Smaller, cheaper alternative for fight length: keep the constants and shrink only large / boss (they are the worst, 8-9 turns): `PFB_V1_BAR_MULT` large 1.7193 -> ~0.95 and boss 0.9158 -> ~0.55 with `PFB_V1_FOE_MULT` large 0.428 -> ~0.8, boss 0.60 -> ~0.95 (variant b / c / e above: large 4.3-4.7 turns at 72-78%, boss 5.2-5.5 at 62-81%). Re-run the 2.7.08 fit step afterwards and `tests/pfengine_js.sh` for PHP / JS parity.

For the skill gap (finding 2) no single number: the look bot's 100% means large / boss need creature pieces that punish a good line (more Hurt / `quick`, fewer free pieces), which is a design question, not a constant.

## 5. Caveats

- Bots are tools, not players: the look bot is a ceiling, random a floor, the chain bot is what the tune rows are fitted to. 10 seeds per creature are noisy for single-creature calls (SE ~15 points); use more seeds before editing a row.
- Starter sim: stats 0, no calling-specific tuning, creatures at their own level (a new gnome may fight above or below).
- Nothing in the working tree was modified; scratch outputs live outside the repo.

## Appendix: scratch scripts

`sim.php` (run from anywhere; requires `tests/pf_bots.php`):

```php
<?php
// scratch: php sim.php SHARD/N SEEDS MODE(std|starter)  -> json lines: one per fight with tile fires and env fires
require '/home/user/gnome-venture/tests/pf_bots.php';
[$sh,$n]=array_map('intval',explode('/',$argv[1]??'0/1')); $seeds=(int)($argv[2]??6); $mode=$argv[3]??'std'; $bot=$argv[4]??'chain';
function starter_player(int $lv): array {
  $m=0; $st=['grit'=>0,'nimble'=>0,'hardiness'=>0,'charm'=>0,'lore'=>0,'luck'=>0,'level'=>$lv]; $max=20+3*$lv;
  $cals=array_keys(PF_CALLING_TILE); $src=pfd_sources_blank($lv,$cals[$lv%6],['NA','NWE','SE','EA'][$lv%4]);
  $src['ctier']=1; $src['starter']=array_merge(PFD_CORE, pfd_offer_keys($src['calling'],$src['home'],PFD_KITS[['bold','steady','kind'][$lv%3]]));
  $deck=pfd_tiles(pfd_fight_entries($src),$st,[],$src['calling'],$src['ctier']);
  return ['hp'=>$max,'max_hp'=>$max,'stats'=>$st,'deck'=>$deck,'luck'=>0];
}
$V1=json_decode(getenv('V1')?:'{}',true)?:[]; $ci=0;
foreach (tv_creatures() as $c) { if ($ci++%$n!==$sh) continue;
  if ($mode==='starter' && $c['level']>8) continue;
  for($k=0;$k<$seeds;$k++){
    $seed=900+7*$k+$c['level']+1000*(crc32($c['slug'])%97); mt_srand($seed);
    $lv=$c['level']; $pl=$mode==='starter'?starter_player($lv):tv_player($lv);
    $cr=pfd_foe_row($c,array_keys(pfd_region_pieces())[(crc32($c['slug'])+$k)%14]);
    $s=pfb_new($pl,$cr,$seed,['blank'=>true,'v1'=>($V1?:true)]);
    $hand=$s['me']['hand']; $bi=0; foreach($hand as $i=>$t) if($t['t']==='hurt'&&$t['v']>$hand[$bi]['v']) $bi=$i;
    pfb_start($s,$bi,['L','R','T','B'][$k%4]);
    $fires=[]; $env=[]; $t=0;
    while(!$s['over'] && $t++<40){
      $pl2=tv_places($s); $a=tv_choose($s,$bot,$pl2); $r=tv_act($s,$a);
      if($r['err']){ $r=pfb_pass($s,$s['turn']); if($r['err']){ if(!$pl2)break; $r=tv_act($s,$pl2[0]); if($r['err'])break; } }
      foreach($r['ev'] as $e){
        if(($e['env']??'')==='fire') $env[($e['for']??'?').':'.($e['kind']??'?')]=($env[($e['for']??'?').':'.($e['kind']??'?')]??0)+1;
        if(($e['env']??'')==='place') $env['place:'.($e['kind']??'?')]=($env['place:'.($e['kind']??'?')]??0)+1;
        if(!empty($e['mud'])) $env['mudhit:'.($e['by']??'?')]=($env['mudhit:'.($e['by']??'?')]??0)+1;
        if(isset($e['k'])&&($e['by']??'')==='me'){ $kk=$e['k']; $fires[$kk]=($fires[$kk]??0)+1; }
      }
    }
    $deck=array_map(fn($t)=>$t['k'],$pl['deck']);
    echo json_encode(['slug'=>$c['slug'],'size'=>$c['size'],'lv'=>$lv,'temper'=>pf_temper($c),'win'=>in_array($s['over'],['seen_off','charmed'],true)?1:0,'over'=>$s['over'],'turns'=>(int)$s['turn'],'hp'=>1-max(0,$s['me']['hp'])/max(1,$s['me']['max']),'fires'=>$fires,'env'=>$env,'deck'=>$deck]),"\n";
  }
}
```

`an.php` (reads `{prefix}_*.json` next to itself):

```php
<?php
$S=dirname(__FILE__); $pre=$argv[1]; $R=[]; foreach(glob("$S/{$pre}_*.json") as $f) foreach(file($f) as $l){$r=json_decode($l,true); if($r)$R[]=$r;}
$avg=fn($a,$k)=>count($a)?array_sum(array_column($a,$k))/count($a):0;
echo "n=".count($R)."\n";
foreach([['size'],['temper'],['size','temper']] as $keys){ $g=[]; foreach($R as $r){$g[implode('/',array_map(fn($k)=>$r[$k],$keys))][]=$r;} ksort($g);
 foreach($g as $k=>$a) printf("%-16s n=%4d win=%3.0f%% turns=%.1f hp_lost=%2.0f%%\n",$k,count($a),100*$avg($a,'win'),$avg($a,'turns'),100*$avg($a,'hp')); echo "\n";}
// per creature
$g=[]; foreach($R as $r)$g[$r['slug']][]=$r; $rows=[];
foreach($g as $s=>$a)$rows[]=[$s,$a[0]['size'],$a[0]['lv'],$a[0]['temper'],$avg($a,'win'),$avg($a,'turns'),count($a)];
usort($rows,fn($x,$y)=>$x[4]<=>$y[4]);
echo "LOW win:\n"; foreach(array_slice($rows,0,14) as $r)printf("%-28s %-6s L%-2d %-7s win=%3.0f%% turns=%.1f n=%d\n",$r[0],$r[1],$r[2],$r[3],100*$r[4],$r[5],$r[6]);
echo "HIGH win (100%):\n"; $h=array_filter($rows,fn($r)=>$r[4]>=0.999); echo count($h)." creatures at 100%: "; $cnt=[]; foreach($h as $r)$cnt[$r[1]]=($cnt[$r[1]]??0)+1; echo json_encode($cnt),"\n";
foreach(array_slice(array_reverse($rows),0,0) as $r);
echo "Zero-ish (<=10%): ".json_encode(array_map(fn($r)=>$r[0],array_filter($rows,fn($r)=>$r[4]<=0.1)))."\n";
// turns outliers per size
$tg=['small'=>[4,5],'medium'=>[4,5],'large'=>[4,5],'boss'=>[4,5]];
$bad=['short'=>0,'ok'=>0,'long'=>0]; $bysz=[];
foreach($rows as $r){ $t=$r[5]; $c=$t<4?'short':($t>5?'long':'ok'); $bysz[$r[1]][$c]=($bysz[$r[1]][$c]??0)+1; }
echo "creature mean turns vs 4-5: ".json_encode($bysz)."\n";
usort($rows,fn($x,$y)=>$y[5]<=>$x[5]); echo "Longest:\n"; foreach(array_slice($rows,0,6) as $r)printf("  %-28s %-6s L%-2d turns=%.1f win=%3.0f%%\n",$r[0],$r[1],$r[2],$r[5],100*$r[4]);
// tile usage
$dk=[];$fi=[];$wf=[];$lf=[];
foreach($R as $r){ foreach(array_unique($r['deck']) as $k){ $dk[$k]=($dk[$k]??0)+1; $fi[$k]=($fi[$k]??0)+($r['fires'][$k]??0); if(!empty($r['fires'][$k])){ $wf[$k][$r['win']][]=1; } } }
$tab=[]; foreach($dk as $k=>$n) if($n>=40){ $f=$fi[$k]/$n; $with=count($wf[$k][1]??[])+count($wf[$k][0]??[]); $wr=$with? count($wf[$k][1]??[])/$with:0; $tab[]=[$k,$n,$f,$wr,$with/$n]; }
usort($tab,fn($x,$y)=>$y[2]<=>$x[2]);
echo "\nTile fires per fight (decks holding it), fire-fight win% , % fights it fired:\n"; foreach($tab as $t)printf("  %-22s decks=%4d fires/fight=%.2f winWhenFired=%3.0f%% firedIn=%3.0f%%\n",$t[0],$t[1],$t[2],100*$t[3],100*$t[4]);
// env
$e=[]; foreach($R as $r) foreach($r['env'] as $k=>$v)$e[$k]=($e[$k]??0)+$v; ksort($e); echo "\nEnv per fight: "; foreach($e as $k=>$v)printf("%s=%.2f ",$k,$v/count($R)); echo "\n";
```
