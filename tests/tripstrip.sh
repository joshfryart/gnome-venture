#!/bin/bash
# v2.0.65: the trip strip shows on a page while a route is remembered, and not when there is none.
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=${TMPDIR:-/tmp} -S 127.0.0.1:$PORT -t $GAME $ROUTER >${TMPDIR:-/tmp}/tripstrip-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
T=${TMPDIR:-/tmp}
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=$T/ts-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > $T/t.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $T/t.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
FAIL=0; ok() { if [ "$2" = 1 ]; then echo "ok   $1"; else echo "FAIL $1"; FAIL=1; fi; }
curl -s -b $C $BASE/garden.php > $T/t.html; ok "no strip without a route" $([ "$(grep -c tripstrip $T/t.html)" = 0 ] && echo 1 || echo 0)
NODE=$(db "SELECT location_id FROM users WHERE username='sprout'")
DEST=$(db "SELECT CASE WHEN a_id=$NODE THEN b_id ELSE a_id END FROM routes WHERE a_id=$NODE OR b_id=$NODE LIMIT 1")
dbx "UPDATE users SET dest_id=$DEST, dest_legs=3 WHERE username='sprout'"
curl -s -b $C $BASE/garden.php > $T/t.html; ok "strip with a route (dest $DEST)" $([ "$(grep -c 'class="tripstrip"' $T/t.html)" = 1 ] && echo 1 || echo 0)
ok "strip has progress bar" $([ "$(grep -c 'class="tsbar"' $T/t.html)" = 1 ] && echo 1 || echo 0)
curl -s -b $C $BASE/world.php > $T/t.html; ok "no strip on world.php" $([ "$(grep -c 'class="tripstrip"' $T/t.html)" = 0 ] && echo 1 || echo 0)
ok "no php errors" $([ -z "$(grep -iE 'fatal|warning|notice|deprecated' $T/tripstrip-php.log)" ] && echo 1 || echo 0)
exit $FAIL
