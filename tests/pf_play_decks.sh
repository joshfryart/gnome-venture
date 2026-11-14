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

# every creature of the old playtest assignments still starts
ASSIGN=${ASSIGN:-}
if [ -n "$ASSIGN" ] && [ -f "$ASSIGN" ]; then
  php -r '$a=json_decode(file_get_contents($argv[1]),true); foreach($a as $k=>$v){ echo (is_array($v)?($v["slug"]??$v["creature"]??$k):$v),"\n"; }' "$ASSIGN" | sort -u | while read -r SL; do
    php "$HERE/pf_play.php" new "$T/a.json" "$SL" 20 3 v1 >/dev/null 2>&1 || { echo "FAIL new $SL"; exit 1; }
  done || FAIL=1
fi
[ $FAIL = 0 ] && echo "pf_play_decks: all ok" || echo "pf_play_decks: FAILED"
exit $FAIL
