#!/bin/bash
# 2.7.10 edge cases for the v1 board rules on the real engine (no DB, no server): level mismatch +/-8, tiny and huge boards, empty and tiny decks, every creature, aim re-roll.
# The full bot run (win rates and turns by bot, build, size, offset) is: php tests/pf_bots.php all -8,0,8 1 std,pals,norare 0/4 json (shards 0..3) | php tests/pf_bots.php agg
OUT=$(php "$(cd "$(dirname "$0")" && pwd)/pf_bots.php" edge 2>&1); RC=$?
echo "$OUT"
echo "$OUT" | grep -q "^  FAIL" && exit 1
exit $RC
