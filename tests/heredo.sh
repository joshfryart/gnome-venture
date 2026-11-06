#!/bin/bash
# v2.5.67: the Here picture's Do here popovers post in place and come back with the result (town.php card=do). Fresh SQLite install in a temp copy.
# Usage: tests/heredo.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-9312}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "${GAME:?}/data"; mkdir -p "$GAME/data"
[ -f "$GAME/includes/festival.php" ] || printf '<?php\nif (!function_exists("festival_ensure_items")) { function festival_ensure_items(): void {} }\n' > "$GAME/includes/festival.php"   # another agent's half-written file: stub in the temp copy only
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
echo "== install + register + welcome"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; grep -oE "flash err[^<]*<[^<]*" $H; tail -5 $LOG; exit 1; }
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
echo "onboarded: $(db "SELECT onboarded FROM users WHERE username='sprout'")"
RC=0
dbx "UPDATE settings SET value='1' WHERE name='gnav_on'"; dbx "INSERT OR IGNORE INTO settings (name, value) VALUES ('gnav_on', '1')"
dbx "UPDATE settings SET value='' WHERE name IN ('season_force','weather_force','stop_daypart_force')"
dbx "UPDATE users SET energy=50, coins=2000 WHERE username='sprout'"
VIL=$(db "SELECT l.id FROM locations l WHERE l.kind='village' AND l.stop_type='jetty' ORDER BY l.id LIMIT 1")
dbx "UPDATE users SET location_id=$VIL, arrived_at='2031-01-01 00:00:09' WHERE username='sprout'"
get here.php >/dev/null; code=$(get here.php); echo "here.php -> $code doblocks=$(grep -o 'class="doblock"' $H | wc -l) stallrows=$(grep -o 'class="stallrow"' $H | wc -l)"
[ "$(grep -o 'class="doblock"' $H | wc -l)" -ge 1 ] || { echo "FAIL the Here picture has no Do here blocks (is the stop a village with activities?)"; RC=1; }
SLUG=$(grep -oE 'class="doblock" data-slug="[^"]+"' $H | head -1 | sed 's/.*data-slug="\([^"]*\)"/\1/')
echo "first activity: $SLUG"
CS=$(csrf $H)
J=$(curl -s -c $C -b $C -X POST "$BASE/town.php" -H 'X-Requested-With: fetch' --data-urlencode "csrf=$CS" -d card=do -d do=local -d "kind=$SLUG" -d opt=0 -d back=here.php)
echo "$J" | head -c 400; echo
echo "$J" | php -r '$j=json_decode(stream_get_contents(STDIN),true); if(!$j){echo "FAIL not json\n";exit(1);} echo "ok=".var_export($j["ok"],true)." msg=".substr((string)$j["msg"],0,80)."\n"; if(strpos($j["html"],"doresult")===false && $j["msg"]!=="") {echo "FAIL the card html has no result line\n";exit(1);} echo "result line in card: ".(strpos($j["html"],"doresult")!==false?"yes":"no")."\n";' || RC=1
grep -q 'name="csrf"' <<<"$J" && { echo "note: reply carries a form"; }
[ -n "$(db "SELECT 1 FROM settings WHERE name='gnav_on'")" ] || true
echo "plain (no script) post still redirects -> $(curl -s -o /dev/null -w '%{http_code}' -c $C -b $C -X POST "$BASE/town.php" --data-urlencode "csrf=$CS" -d do=local -d "kind=$SLUG" -d opt=0 -d back=here.php)"
get here.php >/dev/null; grep -qE '\sstyle=' $H && { echo "FAIL here.php has a style= attribute (CSP)"; RC=1; }
exit $RC
