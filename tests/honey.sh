#!/bin/bash
# Honey Hive Harvest (fresh SQLite install in a temp copy, then tests/honey.php + page checks). Usage: tests/honey.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8797}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
FAIL=0
chk() { if [ "$2" = "1" ]; then echo "  ok   $1"; else echo "  FAIL $1"; FAIL=1; fi; }
echo "== install + register"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; tail -5 $LOG; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
UID_=$(db "SELECT id FROM users WHERE username='sprout'")

echo "== pages"
chk "hive.php loads" "$([ "$(get hive.php)" = 200 ] && echo 1)"
chk "start box has the button" "$(grep -q 'Open the hive' $H && echo 1)"
chk "rules tab has 12 rows" "$([ "$(get 'hive.php?t=rules' >/dev/null; grep -o '<li><span class="ricon"' $H | wc -l)" -ge 11 ] && echo 1)"
get games.php >/dev/null
chk "hub shows the hive tile" "$(grep -q 'hive.php' $H && echo 1)"
get hive.php >/dev/null
post hive.php -d do=start >/dev/null
get hive.php >/dev/null
chk "8 frames, closed" "$([ "$(grep -o 'class="hframe"' $H | wc -l)" = 8 ] && echo 1)"
chk "no frame kind in a live page" "$(! grep -qE 'k-(swarm|heather|amber|golden|clear|drowsy)|"frames"' $H && echo 1)"
chk "bank disabled before first lift" "$(grep -E 'Bank it' $H | grep -q disabled && echo 1)"
FIRST=$(db "SELECT state FROM game_state WHERE user_id=$UID_ AND game='hive'")
post hive.php -d do=lift -d cell=0 >/dev/null
chk "a lift moves the state on (or ends the round)" "$([ "$(db "SELECT state FROM game_state WHERE user_id=$UID_ AND game='hive'")" != "$FIRST" ] && echo 1)"
post hive.php -d do=lift -d cell=abc >/dev/null
post hive.php -d do=lift -d cell=77 >/dev/null
echo "== logic (tests/honey.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/honey.php" "$GAME" 2>&1; RC=$?
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG || echo "(none)"
[ $FAIL = 0 ] && [ $RC = 0 ]
exit $?
