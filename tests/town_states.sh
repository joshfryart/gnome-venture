#!/bin/bash
# 2.8.100 Town states (includes/town_states.php): unit checks plus the town, shop and Here pages over HTTP on a walk.sh install (player sprout).
# Usage: tests/town_states.sh GAME_DIR [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-9846}; ROUTER=${3:-$HERE/router.php}
LOG=$(mktemp)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!
trap "kill $PID 2>/dev/null; rm -f $LOG" EXIT
for _ in $(seq 1 50); do curl -s -o /dev/null "http://127.0.0.1:$PORT/login.php" && break; sleep 0.2; done
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/town_states.php" "$GAME" "$PORT" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) RC=1;; *) echo "FAIL town_states did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL town_states printed PHP warnings"; exit 1; }
grep -E 'PHP (Warning|Notice|Fatal|Deprecated)' $LOG && { echo "FAIL PHP warnings in the server log"; exit 1; }
exit $RC
