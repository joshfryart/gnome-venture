#!/bin/bash
# Trail Sights engine gaps (2.7.00): tests/npc_clockwork.php on an installed copy (ci_suites.sh installs it with walk.sh first).
# Usage: tests/npc_clockwork.sh GAME_DIR
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/npc_clockwork.php" "$1" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL npc_clockwork did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL npc_clockwork printed PHP warnings"; exit 1; }
exit $RC
