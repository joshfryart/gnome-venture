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
if has "$T/s.json" foe '"n":"Bite"' || has "$T/s.json" foe '"n":"Venom Spit"'; then ok "(a) Reptile creature holds a Bite or Venom Spit piece"; else bad "(a) Reptile creature holds a Bite or Venom Spit piece"; fi
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

# every creature of the old playtest assignments still starts
ASSIGN=${ASSIGN:-}
if [ -n "$ASSIGN" ] && [ -f "$ASSIGN" ]; then
  php -r '$a=json_decode(file_get_contents($argv[1]),true); foreach($a as $k=>$v){ echo (is_array($v)?($v["slug"]??$v["creature"]??$k):$v),"\n"; }' "$ASSIGN" | sort -u | while read -r SL; do
    php "$HERE/pf_play.php" new "$T/a.json" "$SL" 20 3 v1 >/dev/null 2>&1 || { echo "FAIL new $SL"; exit 1; }
  done || FAIL=1
fi
[ $FAIL = 0 ] && echo "pf_play_decks: all ok" || echo "pf_play_decks: FAILED"
exit $FAIL
