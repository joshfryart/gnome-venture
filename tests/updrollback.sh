#!/bin/bash
# v2.1 updater rollback: fresh SQLite install in a temp copy, then tests/updrollback.php (never touches src).
# Usage: tests/updrollback.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8794}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >/dev/null 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
curl -s -c $C -b $C "$BASE/install.php" -o $H
CS=$(grep -o 'name="csrf" value="[^"]*"' $H | head -1 | sed 's/.*value="\([^"]*\)".*/\1/')
curl -s -c $C -b $C -X POST "$BASE/install.php" --data-urlencode "csrf=$CS" -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 -o $H
grep -q 'All planted' $H || { echo "INSTALL FAILED"; exit 1; }
kill $PID 2>/dev/null
php -d display_errors=1 -d error_reporting=-1 "$HERE/updrollback.php" "$GAME" 2>&1
