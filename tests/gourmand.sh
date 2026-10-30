#!/bin/bash
# The Gourmand: pages, the off switch, serving over HTTP (incl. a double-tap race), then the engine tests (tests/gourmand.php). Fresh SQLite install in a temp copy.
# Usage: tests/gourmand.sh [GAME_COPY_DIR] [PORT] [ROUTER]   (default: copies src/game to a temp dir; never writes a DB into src)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=${1:-}; PORT=${2:-9441}; ROUTER=${3:-$HERE/router.php}
if [ -z "$GAME" ]; then T=$(mktemp -d); cp -r "$HERE/../game" "$T/game"; GAME=$T/game; fi
rm -f "$GAME/config.php"; rm -rf "${GAME:?}/data"; mkdir -p "$GAME/data"
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp); C2=$(mktemp); H2=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o $H -w '%{http_code}'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; RC=1; fi; }
RC=0
echo "== install"
get install.php >/dev/null
post install.php -d driver=sqlite -d "site_name=Gnome Venture" -d base_url= -d admin_user=admin -d admin_email=a@b.local -d admin_pass=TestPassword123 -d admin_pass2=TestPassword123 >/dev/null
grep -q 'All planted' $H && echo installed || { echo "INSTALL FAILED"; grep -oE "flash err[^<]*<[^<]*" $H; tail -5 $LOG; exit 1; }
echo "== a player (sprout, level 10, in the Maplewold) and the admin"
rm -f $C
get register.php >/dev/null; post register.php -d username=sprout -d email=s@b.local -d password=TestPass123! -d password2=TestPass123! -d rules=1 -d age=1 >/dev/null
get welcome.php >/dev/null; post welcome.php -d do=gnome -d "gnome_name=Bramble" -d 'hat=#2e7d4f' -d 'beard=#b5651d' >/dev/null
get 'welcome.php?step=place' >/dev/null
RID=$(db "SELECT id FROM regions WHERE code='NA'")
VID=$(db "SELECT l.id FROM locations l WHERE l.region_id=$RID AND l.kind='village' AND EXISTS (SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order LIMIT 1 OFFSET 1")
post welcome.php -d do=place -d village_id=$VID >/dev/null
get 'welcome.php?step=garden' >/dev/null; post welcome.php -d do=finish -d 'garden_name=Test Patch' >/dev/null
SU=$(db "SELECT id FROM users WHERE username='sprout'"); POM=$(db "SELECT id FROM npcs WHERE traveller='gourmand'")
dbx "UPDATE users SET level=10, onboarded=1, tour_step=0, coins=0, location='The Maplewold', energy=100 WHERE id=$SU"
CAMP=$(db "SELECT id FROM town_spots WHERE slug='na-sugarshack'"); TEA=$(db "SELECT id FROM town_spots WHERE slug='nwe-tea'")
dbx "INSERT OR IGNORE INTO user_npc_met (user_id, npc_id, first_at) VALUES ($SU, $POM, datetime('now'))"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('gourmand_force_date', '2026-10-02')"
give() { dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $SU, id, $2 FROM items WHERE slug='$1'"; if [ -n "${3:-}" ]; then dbx "INSERT OR REPLACE INTO item_quality (user_id,item_id,q,n) SELECT $SU, id, $3, $2 FROM items WHERE slug='$1'"; else dbx "DELETE FROM item_quality WHERE user_id=$SU AND item_id=(SELECT id FROM items WHERE slug='$1')"; fi; }
echo "== off by default: invisible to players"
chk "gourmand_open default" "$(db "SELECT COALESCE((SELECT value FROM settings WHERE name='gourmand_open'),'0')")" 0
chk "his folk row is inactive" "$(db "SELECT active FROM npcs WHERE traveller='gourmand'")" 0
chk "gourmand.php is not for players (redirect)" "$(get gourmand.php)" 302
for pg in villagers.php "villagers.php?id=$POM" "town.php?spot=$CAMP" "town.php?spot=$TEA" town.php "town.php?view=villagers&known=1" world.php jobs.php 'book.php?ch=Folk' index.php; do
  code=$(get "$pg"); if grep -qi 'pomeroy\|crumbworth\|food writer\|folding table' $H; then echo "FAIL $pg shows him while off: $(grep -oi '.\{30\}\(pomeroy\|crumbworth\|food writer\|folding table\).\{20\}' $H | head -1)"; RC=1; else echo "ok   $pg ($code) has no trace of him"; fi
done
chk "nav has no Gourmand tile" "$(get gnome.php >/dev/null; grep -c 'gourmand.php' $H)" 0
chk "serve is refused for a player while off" "$(post gourmand.php -d do=serve -d course=plate)" 302
chk "no claim made" "$(db "SELECT COUNT(*) FROM traveller_deals WHERE npc_id=$POM")" 0
chk "the Grand course is refused for a player while off" "$(post gourmand.php -d do=serve -d course=grand)" 302
chk "the Home Plate is refused for a player while off" "$(post gourmand.php -d do=home -d dish=wild-rice-hotdish)" 302
chk "no Grand or Home row was made while off" "$(db "SELECT COUNT(*) FROM gourmand_ledger WHERE user_id=$SU")" 0
echo "== the admin sees the page when it is off, and flips the switch from the settings page"
curl -s -c $C2 -b $C2 $BASE/login.php -o $H2 >/dev/null; curl -s -c $C2 -b $C2 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H2)" -d username=admin -d password=TestPassword123 -o /dev/null
dbx "UPDATE users SET onboarded=1, tour_step=0 WHERE username='admin'"
getA() { curl -s -c $C2 -b $C2 "$BASE/$1" -o $H2 -w '%{http_code}'; }
postA() { local page=$1; shift; curl -s -c $C2 -b $C2 -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H2)" "$@" -o $H2 -w '%{http_code}'; }
for t in now journal menu howto; do chk "admin: gourmand.php?t=$t" "$(getA "gourmand.php?t=$t")" 200; done
grep -q 'Closed to players' $H2 && echo "ok   admin sees the closed banner"
chk "admin: nav tile" "$(getA gnome.php >/dev/null; grep -c 'gourmand.php' $H2)" 1
getA 'admin/settings.php?q=gourmand' >/dev/null; grep -q 'gourmand_open' $H2 && echo "ok   settings page lists gourmand_open"
chk "settings: Gourmand rows sit in the World section" "$(grep -o 'Gourmand: Pomeroy' $H2 | head -1)" "Gourmand: Pomeroy"
chk "turn him on from the admin page" "$(postA admin/settings.php -d q=gourmand_open -d 's[gourmand_open]=1')" 302
chk "setting saved" "$(db "SELECT value FROM settings WHERE name='gourmand_open'")" 1
chk "npcs.active followed the setting" "$(db "SELECT active FROM npcs WHERE traveller='gourmand'")" 1
echo "== on: every page returns 200 with no new PHP log lines"
for t in now journal menu howto; do chk "player: gourmand.php?t=$t" "$(get "gourmand.php?t=$t")" 200; done
chk "player: villagers.php" "$(get villagers.php)" 200
grep -q 'Pomeroy' $H && echo "ok   villagers list shows him now"
chk "player: his villager panel" "$(get "villagers.php?id=$POM")" 200
grep -q 'Serve a course' $H && echo "ok   the panel offers a link, not a deal button" ; grep -q 'name="do" value="deal"' $H && { echo "FAIL a deal form is on his panel"; RC=1; }
chk "player: the camp spot" "$(get "town.php?spot=$CAMP")" 200
grep -q 'Pomeroy' $H && echo "ok   the camp spot shows him"
chk "player: town.php" "$(get town.php)" 200
chk "player: nav tile" "$(get gnome.php >/dev/null; grep -c 'gourmand.php' $H)" 1
echo "== serving over HTTP, on a day outside the Maplewold's window (Oct 14)"
dbx "UPDATE settings SET value='2026-10-14' WHERE name='gourmand_force_date'"
give wild-rice 3 70
get gourmand.php >/dev/null; grep -q 'Wild Rice' $H && echo "ok   the panel names the ask"; grep -q '3 held, quality 70' $H && echo "ok   the preview says quality 70" || grep -o 'quality [0-9]* →[^<]*' $H | head -2
chk "serve plate" "$(post gourmand.php -d do=serve -d course=plate)" 302
chk "240 Petals" "$(db "SELECT coins FROM users WHERE id=$SU")" 240
chk "ledger: 3 spoons" "$(db "SELECT spoons||'/'||paid||'/'||served FROM gourmand_ledger WHERE user_id=$SU AND region='NA' AND course='plate'")" "3/3/1"
get gourmand.php >/dev/null; grep -q 'Served this month' $H && echo "ok   the panel says served this month"
get 'gourmand.php?t=journal' >/dev/null; grep -q 'best 70' $H && echo "ok   the journal shows the best quality"
echo "== the double tap: two concurrent POSTs serve once"
give wild-rice 3 70; dbx "UPDATE users SET coins=0 WHERE id=$SU"; dbx "DELETE FROM traveller_deals WHERE npc_id=$POM; DELETE FROM gourmand_ledger WHERE user_id=$SU"
get gourmand.php >/dev/null; TOK=$(csrf $H)
PIDS=""; for i in 1 2 3 4; do curl -s -b $C -c $C -X POST $BASE/gourmand.php --data-urlencode "csrf=$TOK" -d do=serve -d course=plate -o /dev/null & PIDS="$PIDS $!"; done; wait $PIDS
chk "claims" "$(db "SELECT COUNT(*) FROM traveller_deals WHERE user_id=$SU AND npc_id=$POM")" 1
chk "Petals paid once" "$(db "SELECT coins FROM users WHERE id=$SU")" 240
chk "ledger served once" "$(db "SELECT served FROM gourmand_ledger WHERE user_id=$SU AND region='NA' AND course='plate'")" 1
chk "the ask was taken once" "$(db "SELECT COALESCE((SELECT qty FROM user_items WHERE user_id=$SU AND item_id=(SELECT id FROM items WHERE slug='wild-rice')),0)")" 0
echo "== the Grand course over HTTP: Kitchen III, the first Taste, one payment, a double tap"
PLOT=$(db "SELECT id FROM plots WHERE user_id=$SU LIMIT 1")
pg() { get gourmand.php >/dev/null; post gourmand.php "$@"; }
kitchen() { dbx "DELETE FROM garden_buildings WHERE plot_id=$PLOT AND building='kitchen'"; [ "$1" -gt 0 ] && dbx "INSERT INTO garden_buildings (plot_id, building, level, built_at, last_collect) VALUES ($PLOT, 'kitchen', $1, datetime('now'), datetime('now'))"; true; }
held() { db "SELECT COALESCE((SELECT qty FROM user_items WHERE user_id=$SU AND item_id=(SELECT id FROM items WHERE slug='$1')),0)"; }
dbx "DELETE FROM traveller_deals WHERE npc_id=$POM; DELETE FROM gourmand_ledger WHERE user_id=$SU; UPDATE users SET coins=0 WHERE id=$SU"
give feast-maplewold-table 2 70
kitchen 0; get gourmand.php >/dev/null; grep -q 'needs a Kitchen at level III' $H && echo "ok   the page shows the feast as locked without a Kitchen"
chk "Grand without a Kitchen" "$(pg -d do=serve -d course=grand)" 302
chk "  nothing taken, nothing claimed" "$(held feast-maplewold-table)/$(db "SELECT COUNT(*) FROM traveller_deals WHERE npc_id=$POM")/$(db "SELECT COUNT(*) FROM gourmand_ledger WHERE user_id=$SU")" "2/0/0"
kitchen 2; chk "Grand at Kitchen II" "$(pg -d do=serve -d course=grand)" 302
chk "  refused: nothing taken, nothing claimed" "$(held feast-maplewold-table)/$(db "SELECT COUNT(*) FROM traveller_deals WHERE npc_id=$POM")/$(db "SELECT COUNT(*) FROM gourmand_ledger WHERE user_id=$SU")" "2/0/0"
kitchen 3; get gourmand.php >/dev/null; grep -q 'after your first Taste' $H && echo "ok   the page says a Taste comes first"
chk "Grand at Kitchen III before the first Taste" "$(pg -d do=serve -d course=grand)" 302
chk "  refused: nothing taken, nothing claimed, nothing paid" "$(held feast-maplewold-table)/$(db "SELECT COUNT(*) FROM traveller_deals WHERE npc_id=$POM")/$(db "SELECT COUNT(*) FROM gourmand_ledger WHERE user_id=$SU")/$(db "SELECT coins FROM users WHERE id=$SU")" "2/0/0/0"
dbx "INSERT INTO gourmand_ledger (user_id, region, course, paid, served, first_at, last_at) VALUES ($SU, 'NA', 'table', 1, 0, datetime('now'), datetime('now'))"
get gourmand.php >/dev/null; grep -q 'Serve the feast' $H && echo "ok   the page offers the feast as a servable course"
TOK=$(csrf $H)
PIDS=""; for i in 1 2 3 4; do curl -s -b $C -c $C -X POST $BASE/gourmand.php --data-urlencode "csrf=$TOK" -d do=serve -d course=grand -o /dev/null & PIDS="$PIDS $!"; done; wait $PIDS
chk "double-POST Grand: one claim" "$(db "SELECT COUNT(*) FROM traveller_deals WHERE user_id=$SU AND npc_id=$POM AND stop LIKE '%|grand'")" 1
chk "  paid once (200)" "$(db "SELECT coins FROM users WHERE id=$SU")" 200
chk "  the feast was taken once" "$(held feast-maplewold-table)" 1
chk "  one grandpay row, one grand row served once" "$(db "SELECT COUNT(*) FROM gourmand_ledger WHERE user_id=$SU AND course='grandpay'")/$(db "SELECT served FROM gourmand_ledger WHERE user_id=$SU AND region='NA' AND course='grand'")" "1/1"
chk "a second Grand this month" "$(pg -d do=serve -d course=grand)" 302
chk "  pays nothing more" "$(db "SELECT coins FROM users WHERE id=$SU")/$(held feast-maplewold-table)" "200/1"
get 'gourmand.php?t=journal' >/dev/null; grep -q 'Grand 1/8' $H && echo "ok   the journal counts Grand 1/8"
echo "-- the Grand Diner title is granted by the engine test (gourmand_titles); here, seven more grandpay rows"
for rc in CA CB NWE SE EE MENA CSA; do dbx "INSERT INTO gourmand_ledger (user_id, region, course, paid, served, first_at, last_at) VALUES ($SU, '$rc', 'grandpay', 1, 0, datetime('now'), datetime('now'))"; done
echo "== the Home Plate over HTTP: 10 Tastes, a home-crop dish, once, a double tap"
dbx "DELETE FROM traveller_deals WHERE npc_id=$POM; UPDATE users SET coins=0, location='Mossbottom' WHERE id=$SU"
give wild-rice-hotdish 3 70; give falafel 1 70
chk "Home Plate before 10 Tastes (1 so far)" "$(pg -d do=home -d dish=wild-rice-hotdish)" 302
chk "  refused: nothing taken, no HOME row" "$(held wild-rice-hotdish)/$(db "SELECT COUNT(*) FROM gourmand_ledger WHERE user_id=$SU AND region='HOME'")/$(db "SELECT coins FROM users WHERE id=$SU")" "3/0/0"
for rc in CA CB SA NWE SE EE MENA WCA; do dbx "INSERT OR IGNORE INTO gourmand_ledger (user_id, region, course, paid, served, first_at, last_at) VALUES ($SU, '$rc', 'table', 1, 0, datetime('now'), datetime('now'))"; done
chk "9 Tastes before OC" "$(db "SELECT COUNT(*) FROM gourmand_ledger WHERE user_id=$SU AND course='table'")" 9
dbx "INSERT OR IGNORE INTO gourmand_ledger (user_id, region, course, paid, served, first_at, last_at) VALUES ($SU, 'OC', 'table', 1, 0, datetime('now'), datetime('now'))"
get gourmand.php >/dev/null; grep -q 'The Home Plate' $H && echo "ok   the Home Plate shows from Mossbottom at 10 Tastes"; grep -q 'value="wild-rice-hotdish"' $H && echo "ok   it lists the home dish"; grep -q 'value="falafel"' $H && { echo "FAIL it lists a dish with no home crop"; RC=1; }
chk "the wrong dish (falafel)" "$(pg -d do=home -d dish=falafel)" 302
chk "  refused: nothing taken, no HOME row, nothing paid" "$(held falafel)/$(db "SELECT COUNT(*) FROM gourmand_ledger WHERE user_id=$SU AND region='HOME'")/$(db "SELECT coins FROM users WHERE id=$SU")" "1/0/0"
get gourmand.php >/dev/null; TOK=$(csrf $H)
PIDS=""; for i in 1 2 3 4; do curl -s -b $C -c $C -X POST $BASE/gourmand.php --data-urlencode "csrf=$TOK" -d do=home -d dish=wild-rice-hotdish -o /dev/null & PIDS="$PIDS $!"; done; wait $PIDS
chk "double-POST Home Plate: paid once (200)" "$(db "SELECT coins FROM users WHERE id=$SU")" 200
chk "  one dish taken, one HOME/home row" "$(held wild-rice-hotdish)/$(db "SELECT COUNT(*) FROM gourmand_ledger WHERE user_id=$SU AND region='HOME' AND course='home'")" "2/1"
chk "a later try" "$(pg -d do=home -d dish=wild-rice-hotdish)" 302
chk "  pays nothing more, takes nothing" "$(db "SELECT coins FROM users WHERE id=$SU")/$(held wild-rice-hotdish)" "200/2"
get gourmand.php >/dev/null; grep -q 'shown Pomeroy the cooking of your home' $H && echo "ok   the page says it is done"
kitchen 0; dbx "DELETE FROM traveller_deals WHERE npc_id=$POM; DELETE FROM gourmand_ledger WHERE user_id=$SU; UPDATE users SET coins=0, location='The Maplewold' WHERE id=$SU"
echo "== the Long Table seat over HTTP"
dbx "UPDATE settings SET value='2026-11-01' WHERE name='gourmand_force_date'"; dbx "UPDATE users SET location='Mossbottom' WHERE id=$SU"
get gourmand.php >/dev/null; grep -q 'Long Table' $H && echo "ok   the Long Table shows on day 1"
for i in 1 2 3 4 5 6 7; do dbx "INSERT INTO traveller_deals (user_id,npc_id,stop,at) VALUES ($SU,$POM,'2026-10|NA|x$i',datetime('now'))"; done
dbx "UPDATE users SET coins=0 WHERE id=$SU"
get gourmand.php >/dev/null; TOK=$(csrf $H)
PIDS=""; for i in 1 2 3; do curl -s -b $C -c $C -X POST $BASE/gourmand.php --data-urlencode "csrf=$TOK" -d do=seat -o /dev/null & PIDS="$PIDS $!"; done; wait $PIDS
chk "seat paid once (50)" "$(db "SELECT coins FROM users WHERE id=$SU")" 50
echo "== road meet: on the road into the camp town at starts+1h, not at +3h"
php -d display_errors=1 -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require $argv[1]."/includes/npc_life.php"; require $argv[1]."/includes/road_life.php"; require_once $argv[1]."/includes/gourmand.php";
  $ok = function(string $w, bool $c) { echo ($c ? "ok   " : "FAIL ") . $w . "\n"; if (!$c) $GLOBALS["bad"] = 1; };
  set_setting("gourmand_force_date", ""); setting("__reload__");
  $ts = (new DateTimeImmutable("2026-10-06 00:00:00", hollow_tz()))->getTimestamp();   // Sunsprinkle Isles window starts here
  $st = gourmand_stop($ts + 3600); $town = $st["town"];
  $m = q_one("SELECT * FROM locations WHERE kind = ? AND region = ?", ["market", $town]); $v = q_one("SELECT l.* FROM locations l WHERE l.region = ? AND l.kind = ? LIMIT 1", [$town, "village"]);
  $scene = ["from" => $m, "to" => $v ?: $m];
  $has = fn(int $t) => (bool)array_filter(road_meet_candidates($scene, $t), fn($c) => $c["w"] === "t" && $c["npc"]["traveller"] === "gourmand");
  $ok("the window starts at midnight and traveller_stop agrees ($town)", $st["starts"] === $ts && traveller_stop(q_one("SELECT * FROM npcs WHERE traveller = ?", ["gourmand"]), $ts + 3600)["starts"] === $ts);
  $ok("met on the road into the town at starts + 1h", $has($ts + 3600));
  $ok("not met at starts + 3h", !$has($ts + 3 * 3600));
  $ok("met on the road out in the last hour", $has($st["ends"] - 1800));
  $ok("not met mid-stay", !$has($ts + 30 * 3600) || $st["ends"] - ($ts + 30 * 3600) <= 7200);
  exit($GLOBALS["bad"] ?? 0);' "$GAME" || RC=1
dbx "UPDATE settings SET value='' WHERE name='gourmand_force_date'"
echo "== gourmand engine (tests/gourmand.php)"
php -d display_errors=1 -d error_reporting=-1 "$HERE/gourmand.php" "$GAME" 2>&1; ER=$?; [ $ER -ne 0 ] && RC=$ER
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG || echo "(none)"
[ -s "$GAME/data/error-log.txt" ] && { echo "error-log.txt:"; head -20 "$GAME/data/error-log.txt"; RC=1; }
exit $RC
