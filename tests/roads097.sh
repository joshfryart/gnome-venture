#!/bin/bash
# v0.9.7 part A: near-home roads track the gnome's level, easy roads, quick walks, action XP, the new creatures, the upgrade.
# Usage: tests/roads097.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-8797}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "${GAME:?}/config.php"; rm -rf "${GAME:?}/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -d error_reporting=-1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
FAIL=0; chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAIL=1; fi; }
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
echo "== engine (tests/roads097.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/roads097.php" "$GAME" 2>&1; RC=$?
[ $RC -ne 0 ] && FAIL=1
echo "== pages: My Gnome toggle, route cards"
get account.php >/dev/null; grep -q 'name="easy_roads"' $H && echo "  ok   toggle shown" || { echo "  FAIL toggle"; FAIL=1; }
chk "easy roads is on for a new gnome" "$(db "SELECT easy_roads FROM users WHERE username='sprout'")" 1
echo "switch off -> $(post account.php -d do=easy_roads)"; chk "off saved" "$(db "SELECT easy_roads FROM users WHERE username='sprout'")" 0
get account.php >/dev/null; grep -q 'Easy roads are off' $H && echo "  ok   flash" || { grep -oE 'flash (ok|err)">[^<]*' $H | head -2; echo "  FAIL flash"; FAIL=1; }
post account.php -d do=easy_roads -d easy_roads=1 >/dev/null; chk "on saved" "$(db "SELECT easy_roads FROM users WHERE username='sprout'")" 1
echo "== a far road is a quick walk on the World page and the route plan"
dbx "UPDATE users SET level=28, easy_roads=0, energy=200, tour_step=0 WHERE username='sprout'"
FAR=$(db "SELECT r.id||'|'||r.a_id||'|'||r.b_id FROM routes r JOIN locations a ON a.id=r.a_id JOIN locations b ON b.id=r.b_id WHERE r.kind='road' AND a.kind='village' AND b.kind='village' AND r.a_id<>$VID AND r.b_id<>$VID ORDER BY r.id LIMIT 1")
RIDF=${FAR%%|*}; REST=${FAR#*|}; FA=${REST%%|*}; FB=${REST#*|}
dbx "UPDATE users SET location_id=$FA WHERE username='sprout'"
get world.php >/dev/null; grep -q 'quick walk' $H && echo "  ok   quick walk on the route card" || { echo "  FAIL no quick walk on the card"; FAIL=1; }
get "world.php?go=$FB" >/dev/null; grep -q 'quick walk' $H && echo "  ok   quick walk in the route plan" || { echo "  FAIL not in the plan"; FAIL=1; }
get world.php >/dev/null; post adventure.php -d do=start -d route_id=$RIDF >/dev/null
chk "arrival in 3 minutes (half of 6)" "$(db "SELECT CAST(ROUND((julianday(arrive_at)-julianday(started_at))*1440) AS INT) FROM expeditions WHERE user_id=(SELECT id FROM users WHERE username='sprout') ORDER BY id DESC LIMIT 1")" 3
get adventure.php >/dev/null; grep -qE 'quick walk' $H && echo "  ok   adventure page mentions the quick walk" || { echo "  FAIL adventure page"; FAIL=1; }
dbx "UPDATE expeditions SET status='done'"
echo "== upgrade from 0.9.5 (new creatures come back, higher gnomes get easy roads off, nothing else touched)"
ITEMS=$(db "SELECT COUNT(*) FROM items"); CRE=$(db "SELECT COUNT(*) FROM creatures")
dbx "UPDATE creatures SET hp = 999 WHERE slug='red-fox'"
dbx "DELETE FROM creature_drops WHERE creature_id IN (SELECT id FROM creatures WHERE slug IN ('deep-octopus','jungle-tiger'))"
dbx "DELETE FROM creatures WHERE slug IN ('deep-octopus','jungle-tiger')"
dbx "DELETE FROM encyclopedia_entries WHERE unlock_key IN ('creature:deep-octopus','creature:jungle-tiger')"
dbx "UPDATE users SET level=12, easy_roads=1 WHERE username='sprout'"
dbx "UPDATE settings SET value='0.9.5' WHERE name='db_version'"
get world.php >/dev/null
chk "creatures back" "$(db "SELECT COUNT(*) FROM creatures")" "$CRE"
chk "items unchanged" "$(db "SELECT COUNT(*) FROM items")" "$ITEMS"
chk "admin edit kept" "$(db "SELECT hp FROM creatures WHERE slug='red-fox'")" 999
chk "level 12 gnome: easy roads off" "$(db "SELECT easy_roads FROM users WHERE username='sprout'")" 0
chk "pages back" "$(db "SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN ('creature:deep-octopus','creature:jungle-tiger')")" 2
dbx "UPDATE users SET level=3, easy_roads=1 WHERE username='sprout'"; dbx "UPDATE settings SET value='0.9.5' WHERE name='db_version'"; get world.php >/dev/null
chk "level 3 gnome keeps easy roads on" "$(db "SELECT easy_roads FROM users WHERE username='sprout'")" 1
echo "== pages render"
for pg in world.php gnome.php adventure.php book.php 'book.php?ch=Creatures' town.php garden.php; do echo "$pg -> $(get "$pg")"; done
echo "== php warnings / errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG && FAIL=1 || echo "(none)"
[ $FAIL -eq 0 ] && echo "ALL OK" || { echo "SOME FAILED"; exit 1; }
