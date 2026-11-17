#!/bin/bash
# 2.7.08: toasts (Milestone box, new Almanac pages) step aside from a fight's end scene (tests/toast_cover.js, a real Chromium).
# Usage: tests/toast_cover.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (ci_suites.sh installs the copy first: player "sprout")
HERE=$(cd "$(dirname "$0")" && pwd); ROOT=$(cd "$HERE/.." && pwd)
GAME=${1:-}; PORT=${2:-8871}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$ROOT/game" "$T/game"; rm -rf "$T/game/data" "$T/game/config.php"; mkdir -p "$T/game/data"; GAME=$T/game; bash "$HERE/walk.sh" "$GAME" $((PORT+5)) "$ROUTER" >/dev/null 2>&1; fi
BASE=http://127.0.0.1:$PORT; LOG=$(mktemp)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill \$PID 2>/dev/null; [ -n \"\$T\" ] && rm -rf \"\$T\"" EXIT
if [ -d /opt/node-tools/node_modules/playwright ] || node -e "require('playwright')" 2>/dev/null; then
  NODE_PATH=${NODE_PATH:-/opt/node-tools/node_modules} node "$HERE/toast_cover.js" "$BASE" 2>&1 | tee $LOG.out | cut -c1-300
  FAILS=$(grep -c '^FAIL' $LOG.out); [ "$(grep -c '^toast_cover: done' $LOG.out)" = 1 ] || FAILS=$((FAILS+1))
else echo "skip (no playwright)"; FAILS=0; fi
[ "$FAILS" -eq 0 ] && echo "toast_cover ok" || echo "$FAILS FAILED"
[ "$FAILS" -eq 0 ]
