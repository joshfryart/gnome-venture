#!/bin/bash
# v2.0.86 landmark scene art: tests/landmark_scene.php (every landmark has its 480x270 PNG), then a fresh SQLite install in a private copy,
# a gnome standing at one landmark of each kind: world.php must show the <img class="lmscene"> with that landmark's file, and nothing when the file is missing.
# Usage: tests/landmark_scene.sh [GAME_COPY_DIR] [PORT] [ROUTER]
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8797}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "$GAME/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT; LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp); FAILS=0
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }

echo "== files and slugs"
php "$HERE/landmark_scene.php" | tee /tmp/lms.out | tail -1; grep -q '^OK' /tmp/lms.out && chk "every landmark has a scene" 1 || chk "every landmark has a scene" 0

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
SID=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "UPDATE users SET tour_step=0, level=30, energy=500, coins=5000 WHERE id=$SID"
get login.php >/dev/null; post login.php -d username=sprout -d 'password=TestPass123!' >/dev/null

echo "== panel shows the scene"
for K in haven wonder delve lair; do
  OFF=0; [ $K = haven ] && OFF=2   # the first havens are behind story chapters (journey_lock shows a note instead of the panel)
  ROW=$(db "SELECT lm.location_id||'|'||lm.name FROM landmarks lm WHERE lm.kind='$K' ORDER BY lm.id LIMIT 1 OFFSET $OFF")
  LID=${ROW%%|*}; NAME=${ROW#*|}
  dbx "UPDATE users SET location_id=$LID WHERE id=$SID"
  PG=world.php; [ $K = haven ] && PG=town.php   # havens are rest stops: their panel sits on the town page
  get $PG >/dev/null
  SRC=$(grep -o 'class="lmscene[^"]*" src="[^"]*"' $H | head -1 | sed 's/.*src="\([^"?]*\).*/\1/')
  chk "$K ($NAME) shows a scene" "$([ -n "$SRC" ] && [ -f "$GAME/$SRC" ] && echo 1)" "src='$SRC'"
done

echo "== no file = no picture"
ROW=$(db "SELECT lm.location_id||'|'||lm.name FROM landmarks lm WHERE lm.kind='wonder' ORDER BY lm.id LIMIT 1"); LID=${ROW%%|*}
dbx "UPDATE users SET location_id=$LID WHERE id=$SID"
mv "$GAME/assets/img/wonders" "$GAME/assets/img/wonders.off"
get world.php >/dev/null
chk "page loads without the folder" "$([ "$(get world.php)" = 200 ] && echo 1)"
chk "no lmscene img without art" "$(grep -q 'class="lmscene' $H && echo 0 || echo 1)"
chk "wonder panel still there" "$(grep -q 'wonderintro\|How will you investigate' $H && echo 1)"
mv "$GAME/assets/img/wonders.off" "$GAME/assets/img/wonders"
echo; [ $FAILS = 0 ] && echo "all landmark scene checks passed" || { echo "$FAILS FAILED"; exit 1; }
