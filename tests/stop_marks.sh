#!/usr/bin/env bash
# Lasting marks (includes/stop_marks.php, behind stop_marks_open): unit and integration checks (tests/stop_marks.php), then the pages over HTTP:
# the town's rest stop, a haven as a stop, the Perks popover, an act posted at the town; off = none of it. Usage: stop_marks.sh GAME PORT ROUTER (a walk.sh install)
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
HERE=$(cd "$(dirname "$0")" && pwd)
php -d session.save_path=/tmp $HERE/stop_marks.php $GAME
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >${TMPDIR:-/tmp}/marks-php.log 2>&1 & PID=$!
W=$(mktemp -d); trap "kill $PID 2>/dev/null; rm -rf $W" EXIT
for _ in $(seq 1 50); do curl -s -o /dev/null "$BASE/login.php" && break; sleep 0.2; done
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
setg() { dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('$1','$2')"; }
ok() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1 (got '$2', want '$3')"; fi; }
curl -s -c $W/p -b $W/p $BASE/login.php > $W/l.html
curl -s -c $W/p -b $W/p -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $W/l.html)" -d username=sprout --data-urlencode 'password=TestPass123!' -o /dev/null
UID_=$(dbv "SELECT id FROM users WHERE username='sprout'")
TOWN=$(dbv "SELECT id FROM locations WHERE slug='market-na'"); SHACK=$(dbv "SELECT id FROM locations WHERE slug='lm-na-4-haven-aurora-camp'")
dbx "DELETE FROM expeditions WHERE user_id=$UID_; UPDATE users SET location_id=$TOWN, energy=50 WHERE id=$UID_"
echo "== HTTP: off"
setg stop_marks_open 0
ok "off: the town's rest stop view is not there (the square shows)" "$(curl -s -b $W/p "$BASE/town.php?view=reststop" | grep -c 'st-meters')" 0
ok "off: no rest stop button on the Stop tab" "$(curl -s -b $W/p "$BASE/town.php?view=stop" | grep -c 'view=reststop')" 0
echo "== HTTP: on"
setg stop_marks_open 1
curl -s -b $W/p "$BASE/town.php?view=reststop" > $W/t.html
ok "on: the town's rest stop: bars and things to do" "$(grep -c 'mk-bars' $W/t.html)/$(grep -c 'Things to do' $W/t.html)" "1/1"
ok "on: the Stop tab links to it" "$(curl -s -b $W/p "$BASE/town.php?view=stop" | grep -c 'view=reststop')" 1
ok "on: its tabs stay on the town's rest stop" "$(grep -c 'town.php?view=reststop&amp;t=folk' $W/t.html)" 1
SLUG=$(php -r '$_SERVER["SCRIPT_NAME"]="/index.php"; require $argv[1]."/includes/bootstrap.php"; require_once APP_ROOT."/includes/stops.php"; $GLOBALS["CURRENT_USER"]=q_one("SELECT * FROM users WHERE id=".(int)$argv[2]); foreach (stop_pool(q_one("SELECT * FROM locations WHERE id=".(int)$argv[3]), null, (int)$argv[2])["offer"] as $a) if (in_array($a["kind"], ["lore","gossip","tend","check"], true)) { echo $a["slug"]; break; }' $GAME $UID_ $TOWN)
ok "the town offers an act to try" "$([ -n "$SLUG" ] && echo y)" y
CODE=$(curl -s -b $W/p -c $W/p -o /dev/null -w '%{http_code} %{redirect_url}' -X POST $BASE/town.php --data-urlencode "csrf=$(csrf $W/t.html)" -d do=local -d kind=$SLUG -d opt=0)
ok "an act posted at the town ($SLUG) comes back to the town's rest stop" "$(echo "$CODE" | grep -c 'view=reststop')" 1
ok "...and fed a bar" "$(dbv "SELECT COUNT(*) > 0 FROM stop_prog WHERE user_id=$UID_ AND location_id=$TOWN AND k LIKE 'meter:%' AND n > 0")" 1
dbx "UPDATE users SET location_id=$SHACK WHERE id=$UID_"
curl -s -b $W/p "$BASE/town.php" > $W/h.html
ok "a haven is a rest stop page (local panel, bars)" "$(grep -c 'mk-bars' $W/h.html)/$(grep -c 'Rest stop' $W/h.html | awk '{print ($1>0)?1:0}')" "1/1"
ok "here.php at the haven renders" "$(curl -s -o /dev/null -w '%{http_code}' -b $W/p $BASE/here.php)" 200
setg stop_marks_open 0
ok "off again: the haven is a plain place" "$(curl -s -b $W/p "$BASE/town.php" | grep -c 'mk-bars')" 0
dbx "UPDATE users SET location_id=$TOWN WHERE id=$UID_; DELETE FROM stop_prog WHERE user_id=$UID_; DELETE FROM stop_log WHERE user_id=$UID_; DELETE FROM stop_marks WHERE user_id=$UID_"
ok "PHP log has no warnings" "$(grep -c 'Warning\|Notice\|Fatal\|Deprecated' ${TMPDIR:-/tmp}/marks-php.log)" 0
