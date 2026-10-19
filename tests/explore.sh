#!/bin/bash
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/ex-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/ex-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > /tmp/x.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/x.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'"); dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"
HOME=$(db "SELECT COALESCE(NULLIF(home_village_id,0), location_id) FROM users WHERE id=$SID");   # v1.4.6: one-region start leaves home_village_id empty
 dbx "UPDATE users SET location_id=$HOME, level=6, energy=60, stat_grit=16, stat_hardiness=16, tour_step=0 WHERE id=$SID"
post() { curl -s -b $C -c $C $BASE/adventure.php > /tmp/x.html; [ -z "$(csrf /tmp/x.html)" ] && curl -s -b $C -c $C $BASE/world.php > /tmp/x.html; curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/x.html)" "$@" -o /dev/null; }
echo "== world shows wander button: $(curl -s -b $C $BASE/world.php | grep -c 'name="do" value="explore"')"
post -d do=explore; echo "start: $(db "SELECT kind, depth, status, level FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1") energy $(db "SELECT energy FROM users WHERE id=$SID")"
resolve() { for k in $(seq 30); do curl -s -b $C -c $C $BASE/adventure.php > /tmp/x.html
  if grep -q 'value="auto"' /tmp/x.html; then post -d do=auto; elif grep -q 'value="attack"' /tmp/x.html; then post -d do=attack; elif grep -q 'value="solve"' /tmp/x.html; then post -d do=solve -d option=0; elif grep -q 'value="choose"' /tmp/x.html; then post -d do=choose -d option=0; else break; fi; done; }
for i in $(seq 7); do
  post -d do=deeper; resolve
  R=$(db "SELECT depth||' | lv '||level||' | '||status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"); echo "deeper $i: $R"
  [ "$(db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1")" != "active" ] && break
done
echo "-- journal:"; db "SELECT log FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1" | php -r '$l=json_decode(stream_get_contents(STDIN),true); foreach($l as $x) if (preg_match("/^(🗺️|🌿|⚔️|❓|🏆|💫|✅|❌|🛣️)|Deeper|You find|✨|🪙|🌱/u",$x)) echo "   $x\n";' | head -30
if [ "$(db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1")" = "active" ]; then post -d do=return; fi
echo "end: $(db "SELECT status, depth FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1") · at $(db "SELECT l.name FROM users u JOIN locations l ON l.id=u.location_id WHERE u.id=$SID") (home $(db "SELECT name FROM locations WHERE id=$HOME"))"
echo "discoveries: $(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$SID AND (e.unlock_key LIKE 'landmark:%' OR e.unlock_key LIKE 'village:%')")"
echo "== energy runs out"; dbx "UPDATE users SET energy=1, energy_updated_at=datetime('now') WHERE id=$SID"; post -d do=explore; post -d do=deeper; db "SELECT depth FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"; db "SELECT log FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1" | grep -o "too tired[^\"]*" | head -1; post -d do=return
echo "== can't wander off from a hidden place"; HID=$(db "SELECT b_id FROM routes WHERE kind='side' LIMIT 1"); dbx "UPDATE users SET location_id=$HID, energy=20 WHERE id=$SID"; post -d do=explore; curl -s -b $C $BASE/world.php | grep -oE 'class="ml err[^"]*">[^<]*' | head -1
dbx "UPDATE users SET location_id=$HOME WHERE id=$SID"
echo "== many runs: depth vs level, bosses only at 5+, discoveries"
for run in $(seq 6); do dbx "UPDATE users SET energy=60, energy_updated_at=datetime('now') WHERE id=$SID"; post -d do=explore; for i in $(seq 8); do post -d do=deeper; resolve; [ "$(db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1")" != "active" ] && break; done; [ "$(db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1")" = "active" ] && post -d do=return; echo "  run $run: $(db "SELECT status||' at depth '||depth FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1")"; dbx "UPDATE users SET location_id=$HOME WHERE id=$SID"; done
echo "  discoveries now: $(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id WHERE ue.user_id=$SID AND (e.unlock_key LIKE 'landmark:%' OR e.unlock_key LIKE 'village:%')")"
echo "  side paths visible from home: $(curl -s -b $C $BASE/world.php | grep -c '🌿 Side path')"
echo "  user level now: $(db "SELECT level FROM users WHERE id=$SID")"
echo "== php log"; grep -iE 'fatal|warning|notice|deprecated' /tmp/ex-php.log || echo "(none)"
