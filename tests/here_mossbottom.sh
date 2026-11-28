#!/bin/bash
# 2.8.99b: Mossbottom's Here picture from anywhere: tests/here_mossbottom.php on an installed copy, then the real pages over HTTP.
# Usage: tests/here_mossbottom.sh GAME_DIR [PORT] [ROUTER]   (an installed copy: player "sprout")
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-9842}; ROUTER=${3:-$HERE/router.php}
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/here_mossbottom.php" "$GAME" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL here_mossbottom did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL here_mossbottom printed PHP warnings"; exit 1; }
# the pages: log in as sprout, open the Mossbottom picture and the hub square
LOG=$(mktemp); C=$(mktemp); H=$(mktemp); BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec("UPDATE settings SET value = '"'1'"' WHERE name = '"'gnav_on'"'");' 2>/dev/null
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
curl -s -c $C -b $C "$BASE/login.php" -o $H
curl -s -c $C -b $C -X POST "$BASE/login.php" --data-urlencode "csrf=$(csrf $H)" -d username=sprout --data-urlencode 'password=TestPass123!' -o /dev/null
code=$(curl -s -c $C -b $C "$BASE/here.php?hub=1" -o $H -w '%{http_code}')
[ "$code" = 200 ] && grep -q 'data-hub="town-hub"' $H && echo "  ok   here.php?hub=1 shows the Mossbottom picture" || { echo "  FAIL here.php?hub=1 ($code): $(grep -o 'data-hub="[^"]*"' $H | head -1)"; RC=1; }
grep -q 'hs-s-shops' $H && grep -q 'town.php?hub=1' $H && echo "  ok   its shops spot and the town square link" || { echo "  FAIL shops spot / town square link missing"; RC=1; }
for s in $(grep -oE 'town\.php\?hub=1&amp;spot=[0-9]+&amp;frag=1' $H | sort -u | sed 's/&amp;/\&/g'); do
  c=$(curl -s -c $C -b $C -H 'X-Requested-With: fetch' "$BASE/$s" -w '\n%{http_code}' | tail -1)
  b=$(curl -s -c $C -b $C -H 'X-Requested-With: fetch' "$BASE/$s" | head -c 20)
  [ "$c" = 200 ] && echo "$b" | grep -q '"ok":true' && echo "  ok   card $s" || { echo "  FAIL card $s ($c $b)"; RC=1; }
done
curl -s -c $C -b $C "$BASE/town.php?hub=1" -o $H
grep -q 'here.php?hub=1' $H && echo "  ok   the hub square links its picture" || { echo "  FAIL the hub square has no link to the picture"; RC=1; }
code=$(curl -s -c $C -b $C "$BASE/here.php" -o $H -w '%{http_code}')
[ "$code" = 200 ] && grep -q 'data-hub="town-' $H && ! grep -q 'data-hub="town-hub"' $H && echo "  ok   here.php is still the town the gnome stands in" || { echo "  FAIL here.php ($code)"; RC=1; }
grep -E 'PHP (Warning|Notice|Fatal|Deprecated)' $LOG && { echo "  FAIL PHP warnings in the server log"; RC=1; }
exit $RC
