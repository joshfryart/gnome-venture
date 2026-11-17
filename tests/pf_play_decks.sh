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

# every creature of the old playtest assignments still starts
ASSIGN=${ASSIGN:-}
if [ -n "$ASSIGN" ] && [ -f "$ASSIGN" ]; then
  php -r '$a=json_decode(file_get_contents($argv[1]),true); foreach($a as $k=>$v){ echo (is_array($v)?($v["slug"]??$v["creature"]??$k):$v),"\n"; }' "$ASSIGN" | sort -u | while read -r SL; do
    php "$HERE/pf_play.php" new "$T/a.json" "$SL" 20 3 v1 >/dev/null 2>&1 || { echo "FAIL new $SL"; exit 1; }
  done || FAIL=1
fi
[ $FAIL = 0 ] && echo "pf_play_decks: all ok" || echo "pf_play_decks: FAILED"
exit $FAIL
