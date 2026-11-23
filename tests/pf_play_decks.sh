#!/bin/bash
# The playtest harness (tests/pf_play.php) deals the REAL decks: the layered creature deck (class and region pieces, no archetype Lunge) and the deck-model player deck (tool, pal, crop pieces).
# Arg 8 'old' keeps the old archetype / stage A decks.
HERE=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
FAIL=0
ok() { echo "ok   $1"; }
bad() { echo "FAIL $1"; FAIL=1; }
# has FILE ROOTKEY NEEDLE  -> exit 0 if the json under ROOTKEY contains NEEDLE
has() { php -r '$s=json_decode(file_get_contents($argv[1]),true); exit(strpos(json_encode($s[$argv[2]]), $argv[3]) !== false ? 0 : 1);' "$1" "$2" "$3"; }

php "$HERE/pf_play.php" new "$T/s.json" grass-snake 14 7 v1 >/dev/null 2>&1 || bad "new (real decks) starts"
# 2.7.45: creature pieces have drawn names (no plain Bite / Venom Spit); the Reptile's venom is a poison-tagged piece
if has "$T/s.json" foe '"tag":"poison"'; then ok "(a) Reptile creature holds a poison (venom) piece"; else bad "(a) Reptile creature holds a poison (venom) piece"; fi
if has "$T/s.json" foe '"n":"Lunge"'; then bad "(a) no archetype Lunge in the real creature deck"; else ok "(a) no archetype Lunge in the real creature deck"; fi
if has "$T/s.json" me '"src":"tool"'; then ok "(b) player deck has a tool piece"; else bad "(b) player deck has a tool piece"; fi

php "$HERE/pf_play.php" new "$T/o.json" grass-snake 14 7 v1 '' old >/dev/null 2>&1 || bad "new ... old starts"
if has "$T/o.json" foe '"n":"Lunge"'; then ok "(c) 'old' keeps the archetype Lunge"; else bad "(c) 'old' keeps the archetype Lunge"; fi
if has "$T/o.json" me '"src":"tool"'; then bad "(c) 'old' keeps the stage A player deck (no tool)"; else ok "(c) 'old' keeps the stage A player deck (no tool)"; fi

# 2.7.01: the harness prints the creature's class rule (name and sentence), as the page's chip does
OUT=$(php "$HERE/pf_play.php" new "$T/k.json" grass-snake 14 7 v1 2>&1)
if echo "$OUT" | grep -q "^CLASS RULE: Venom trail: When one of its pieces leaves the board"; then ok "(d) class rule line printed (Reptile: Venom trail)"; else bad "(d) class rule line printed (Reptile: Venom trail)"; fi
if php "$HERE/pf_play.php" new "$T/c.json" grass-snake 14 7 classic 2>&1 | grep -q "^CLASS RULE"; then bad "(d) no class rule line in a fight without class rules (classic)"; else ok "(d) no class rule line in a fight without class rules (classic)"; fi

# 2.7.08 puzzle clarity (docs/puzzle-board-proposals.md P7): creature guard readout, join/add help, set-aside group spot numbers and marks, the blank's expiry label
OUT=$(php "$HERE/pf_play.php" show "$T/c.json" 2>&1)
if echo "$OUT" | grep -q "^TURN .* | creature guard [0-9]"; then ok "(e) the TURN line shows the creature's guard"; else bad "(e) the TURN line shows the creature's guard"; fi
if echo "$OUT" | grep -q "^JOIN (set two hand pieces aside, joined): .*join [0-9] [0-9] [LRTB]"; then ok "(e) show lists the legal joins as commands"; else bad "(e) show lists the legal joins as commands"; fi
J=$(echo "$OUT" | grep "^JOIN" | grep -o "join [0-9] [0-9] [LRTB]" | head -1)
OUT=$(php "$HERE/pf_play.php" join "$T/c.json" 0 0 L 2>&1)
if echo "$OUT" | grep -q "^HELP: join A B SIDE"; then ok "(e) a refused join explains A, B and SIDE"; else bad "(e) a refused join explains A, B and SIDE"; fi
if [ -n "$J" ]; then
  OUT=$(php "$HERE/pf_play.php" $(echo "$J" | cut -d' ' -f1) "$T/c.json" $(echo "$J" | cut -d' ' -f2-) 2>&1)
  if echo "$OUT" | grep -q "^SET-ASIDE GROUP .*places at top-left x,y in: .*([^)]*d[0-9]"; then ok "(e) the set-aside group spots carry numbers"; else bad "(e) the set-aside group spots carry numbers"; fi
  if echo "$OUT" | grep -q "^ADD (put one more hand piece on the group): "; then ok "(e) show lists the legal adds (or none)"; else bad "(e) show lists the legal adds (or none)"; fi
  OUT=$(php "$HERE/pf_play.php" add "$T/c.json" 0 9 L 2>&1)
  if echo "$OUT" | grep -q "^HELP: add B ANC SIDE: .*ANC = the group piece number"; then ok "(e) a refused add explains ANC and SIDE"; else bad "(e) a refused add explains ANC and SIDE"; fi
else bad "(e) no legal join found in the classic test fight"; fi
php "$HERE/pf_play.php" new "$T/b.json" grass-snake 14 7 v1 >/dev/null 2>&1
php "$HERE/pf_play.php" start "$T/b.json" 0 L >/dev/null 2>&1
OUT=$(php "$HERE/pf_play.php" pass "$T/b.json" 2>&1)
if echo "$OUT" | grep -q "The blank centre is gone (turn 1 is over)"; then ok "(e) the blank's expiry has its own line"; else bad "(e) the blank's expiry has its own line"; fi
if echo "$OUT" | grep -q "EXPIRED.*\"Blank\""; then bad "(e) the blank is never listed as an expired piece"; else ok "(e) the blank is never listed as an expired piece"; fi

# 2.7.48 playtest pilot Phase 0: all 319 creatures (88 base + 231 variants), a BUILD arg, and the same opening hands as the bots (tests/pf_bots.php pb_fight)
if [ "$(php "$HERE/pf_play.php" list 400 | wc -l)" = 319 ]; then ok "(f) list shows 319 creatures"; else bad "(f) list shows 319 creatures"; fi
if php "$HERE/pf_play.php" new "$T/v.json" fly-swarm 12 7 v1 >/dev/null 2>&1; then ok "(f) a pf_creatures variant (fly-swarm) starts"; else bad "(f) a pf_creatures variant (fly-swarm) starts"; fi
if [ "$(php -r 'require $argv[1]; echo count(tv_creatures());' "$HERE/pfboard_tune_v1.php")" = 319 ]; then ok "(f) tv_creatures() has 319 rows"; else bad "(f) tv_creatures() has 319 rows"; fi
php "$HERE/pf_play.php" new "$T/p.json" grass-snake 14 7 v1 '' pals >/dev/null 2>&1 && php "$HERE/pf_play.php" new "$T/n.json" grass-snake 14 7 v1 '' norare >/dev/null 2>&1 && php "$HERE/pf_play.php" new "$T/d.json" grass-snake 14 7 v1 '' std >/dev/null 2>&1 || bad "(g) BUILD pals / norare / std start"
if has "$T/p.json" me '"src":"tool"'; then bad "(g) the pals build has no belt tool"; else ok "(g) the pals build has no belt tool"; fi
if cmp -s <(php -r '$s=json_decode(file_get_contents($argv[1]),true); echo json_encode($s["me"]);' "$T/d.json") <(php -r '$s=json_decode(file_get_contents($argv[1]),true); echo json_encode($s["me"]);' "$T/k.json"); then ok "(g) BUILD std = the default deck"; else bad "(g) BUILD std = the default deck"; fi
if php "$HERE/pf_play.php" new "$T/x.json" grass-snake 14 7 v1 '' bogus >/dev/null 2>&1; then bad "(g) an unknown BUILD is refused"; else ok "(g) an unknown BUILD is refused"; fi
# (h) same slug / level / seed: the opening hand (and creature deck) equals pb_fight's (pfb_new on pb_player + pfd_foe_row, region (crc32+seed)%14)
SAME=$(php -r 'require $argv[1]; $ok=1; foreach ([["grass-snake",14,7],["fly-swarm",12,512],["tide-crab-paladin",30,2517]] as [$sl,$lv,$sd]) { $c=pt_load_creatures()[$sl]; $s=pfb_new(pb_player($lv,"std"), pfd_foe_row($c, array_keys(pfd_region_pieces())[(crc32($sl)+$sd)%14]), $sd, ["blank"=>true,"v1"=>true]); $f=sys_get_temp_dir()."/pfd_h.json"; passthru(PHP_BINARY." ".escapeshellarg($argv[2])." new ".$f." ".$sl." ".$lv." ".$sd." v1 >/dev/null"); $t=json_decode(file_get_contents($f),true); if (json_encode([$s["me"]["hand"],$s["foe"]["hand"],$s["foe"]["draw"]]) !== json_encode([$t["me"]["hand"],$t["foe"]["hand"],$t["foe"]["draw"]])) $ok=0; @unlink($f); } echo $ok;' "$HERE/pf_bots.php" "$HERE/pf_play.php")
if [ "$SAME" = 1 ]; then ok "(h) opening hands match the bots' for the same slug / level / seed"; else bad "(h) opening hands match the bots' for the same slug / level / seed"; fi

# playtest pilot: a pal's aim notice (note 'palaim') prints its own line, no PHP warning (the old `'  ' . [...][$k] ?? ...` precedence bug), and names the knocked-off piece
OUT=$(php -r 'error_reporting(E_ALL); require $argv[1]; eval(preg_match("/^function pp_events.*?^}/ms", file_get_contents($argv[2]), $m) ? $m[0] : "");
  echo pp_events([["note" => "palaim", "n" => "Smash", "by" => "me", "tid" => 1, "x" => 1, "y" => 1, "pal" => "Bark Badger", "tv" => 5]]);' "$HERE/../game/includes/pfboard.php" "$HERE/pf_play.php" 2>&1)
if echo "$OUT" | grep -qi "warning"; then bad "(i) palaim note prints no PHP warning"; else ok "(i) palaim note prints no PHP warning"; fi
if echo "$OUT" | grep -q 'PAL AIM:.*"Smash"'; then ok "(i) palaim note shows the PAL AIM line with the piece name"; else bad "(i) palaim note shows the PAL AIM line with the piece name"; fi

# 2.7.51 (Sonnet playtests): labels that read backwards, forecasts that did not say what they leave out, silent misses and class rules
OUT=$(php "$HERE/pf_play.php" new "$T/t.json" saltmarsh-leech 18 23545 v1 '' norare 2>&1)
if echo "$OUT" | grep -q "^REGION: [A-Z]"; then ok "(j) new prints the region"; else bad "(j) new prints the region"; fi
if echo "$OUT" | grep -q "Taking that cell does NOT stop it: it picks another move at full value"; then ok "(j) AIM line says blocking only reroutes the hit"; else bad "(j) AIM line says blocking only reroutes the hit"; fi
if echo "$OUT" | grep -q "FORECAST on the board as it stands BEFORE your move"; then ok "(j) AIM forecast is labelled as the board before your move"; else bad "(j) AIM forecast is labelled as the board before your move"; fi
if echo "$OUT" | grep -q "your pieces it fires deal"; then bad "(j) the old 'your pieces it fires deal N to it' wording is gone"; else ok "(j) the old 'your pieces it fires deal N to it' wording is gone"; fi
if echo "$OUT" | grep "^TURN" | grep -q "BAR [0-9.]*/[0-9.]* (damage [0-9.]* + charm [0-9.]*;" && ! echo "$OUT" | grep "^TURN" | grep -q "DAMAGE "; then ok "(j) the TURN line calls the shared bar BAR (damage + charm)"; else bad "(j) the TURN line calls the shared bar BAR (damage + charm)"; fi
php "$HERE/pf_play.php" start "$T/t.json" 4 L >/dev/null 2>&1
OUT=$(php "$HERE/pf_play.php" place "$T/t.json" 3 1 0 2>&1)
if echo "$OUT" | grep -q "damage bar +12.0"; then ok "(j) WHAT HAPPENED says 'damage bar +N' when your damage raises the bar"; else bad "(j) WHAT HAPPENED says 'damage bar +N' when your damage raises the bar"; fi
if echo "$OUT" | grep -q "creature health"; then bad "(j) no 'creature health +N' wording left"; else ok "(j) no 'creature health +N' wording left"; fi
if echo "$OUT" | grep "YOUR HAND" -A6 | grep -q "d[0-9-]* c[0-9]* h-[0-9]* n[0-9]* a-[0-9]"; then ok "(j) lit cells carry the exact reply a-N"; else bad "(j) lit cells carry the exact reply a-N"; fi
if echo "$OUT" | grep -qE " END( |\))"; then bad "(j) END always says win or loss"; else ok "(j) END always says win or loss"; fi
# the event annotations: the class rule, the guard / Evade / Soothe that cut a hit, the source of a slow (pp_ann and pp_events are cut out of the harness and run here)
if php -r '
$src = file_get_contents($argv[1]); preg_match("/^function pp_envtxt\\(.*\$/m", $src, $m); eval($m[0]); preg_match("/^function pp_ann\\(.*?^}\$/ms", $src, $m); eval($m[0]);
$t = pp_ann(["by" => "foe", "t" => "hurt", "tag" => "", "gr" => 2, "blocked" => 0, "dmg" => 15]); if (strpos($t, "GRUDGE x2") === false || strpos($t, "you take 15") === false) { echo "grudge: $t\n"; exit(1); }
$t = pp_ann(["by" => "foe", "t" => "hurt", "tag" => "", "sw" => 1, "evaded" => 9, "dmg" => 0]); if (strpos($t, "SWARM +1") === false || strpos($t, "your Evade dodged it") === false) { echo "swarm/evade: $t\n"; exit(1); }
$t = pp_ann(["by" => "foe", "t" => "hurt", "tag" => "pierce", "soothed" => 4, "blocked" => 0, "dmg" => 3]); if (strpos($t, "SOOTHED -4") === false || strpos($t, "PIERCE") === false) { echo "soothe: $t\n"; exit(1); }
$t = pp_ann(["by" => "me", "t" => "charm", "tag" => "lull", "v" => 8]); if (strpos($t, "LULL: it loses its next play") === false) { echo "lull: $t\n"; exit(1); }
if (pp_envtxt("Bramble: the creature loses 9.") !== "Bramble: the damage bar rises by 9.") { echo "env\n"; exit(1); }
' "$HERE/pf_play.php" 2>&1; then ok "(k) event annotations name Grudge, Swarm, Soothe, Pierce, Evade, Lull and the Bramble's bar"; else bad "(k) event annotations name Grudge, Swarm, Soothe, Pierce, Evade, Lull and the Bramble's bar"; fi

# every creature of the old playtest assignments still starts
ASSIGN=${ASSIGN:-}
if [ -n "$ASSIGN" ] && [ -f "$ASSIGN" ]; then
  php -r '$a=json_decode(file_get_contents($argv[1]),true); foreach($a as $k=>$v){ echo (is_array($v)?($v["slug"]??$v["creature"]??$k):$v),"\n"; }' "$ASSIGN" | sort -u | while read -r SL; do
    php "$HERE/pf_play.php" new "$T/a.json" "$SL" 20 3 v1 >/dev/null 2>&1 || { echo "FAIL new $SL"; exit 1; }
  done || FAIL=1
fi
[ $FAIL = 0 ] && echo "pf_play_decks: all ok" || echo "pf_play_decks: FAILED"
exit $FAIL
