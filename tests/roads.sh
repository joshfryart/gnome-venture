#!/bin/bash
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/roads-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/roads-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > /tmp/r.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/r.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
dbx "UPDATE users SET energy = 50, level = 4, tour_step = 0 WHERE username='sprout'"; dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"
SID=$(db "SELECT id FROM users WHERE username='sprout'")
echo "== world page at home: $(db "SELECT l.name FROM users u JOIN locations l ON l.id=u.location_id WHERE u.id=$SID")"
curl -s -b $C -c $C $BASE/world.php > /tmp/r.html; grep -oE 'class="board"' /tmp/r.html | head -1; grep -oE '🛣️ [^<]* road:' /tmp/r.html; grep -oE '<td>(🛣️ Road|🌿 Side path)[^<]*' /tmp/r.html | sed 's/<td>/  /'
grep -oE '<td>[^<]*(<span class="tag">new</span>)?</td>' /tmp/r.html | head -6 | sed 's/<[^>]*>//g; s/^/  to: /'
walkto() { # route id
  curl -s -b $C -c $C $BASE/world.php > /tmp/r.html
  curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/r.html)" -d do=start -d route_id=$1 -o /dev/null -w "  start: %{redirect_url}\n"
  for i in $(seq 40); do
    curl -s -b $C -c $C $BASE/adventure.php > /tmp/r.html
    T=$(csrf /tmp/r.html); [ -z "$T" ] && break
    if grep -q 'value="auto"' /tmp/r.html; then D="-d do=auto"; elif grep -q 'value="attack"' /tmp/r.html; then D="-d do=attack"
    elif grep -q 'value="solve"' /tmp/r.html; then D="-d do=solve -d option=0"; elif grep -q 'value="continue"' /tmp/r.html; then D="-d do=continue"
    elif grep -q 'is in sight' /tmp/r.html; then dbx "UPDATE expeditions SET arrive_at = datetime('now','-1 minute') WHERE user_id=$SID AND status='active'"; curl -s -b $C -c $C $BASE/adventure.php > /tmp/r.html; D="-d do=arrive"
    else break; fi
    curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/r.html)" $D -o /dev/null
  done
  echo "  status: $(db "SELECT status, level, scaled FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1") · now at: $(db "SELECT l.name||' ('||l.kind||')' FROM users u JOIN locations l ON l.id=u.location_id WHERE u.id=$SID")"
  grep -oE '<li>[^<]*' /tmp/r.html | head -8 | sed 's/<li>/    /'
}
HOME=$(db "SELECT location_id FROM users WHERE id=$SID")
TOWNROUTE=$(db "SELECT r.id FROM routes r JOIN roads rd ON rd.id=r.road_id WHERE r.kind='road' AND (r.a_id=$HOME OR r.b_id=$HOME) ORDER BY r.id LIMIT 1")
echo "== walk the road ($TOWNROUTE)"; dbx "UPDATE users SET energy=50 WHERE id=$SID"; walkto $TOWNROUTE
echo "== energy left: $(db "SELECT energy FROM users WHERE id=$SID")"
echo "== bosses on roads? creature levels seen"; grep -oE 'level [0-9]+' /tmp/r.html | head -2
echo "== hidden side path"; NOW=$(db "SELECT location_id FROM users WHERE id=$SID"); SIDE=$(db "SELECT r.id FROM routes r WHERE r.kind='side' AND (r.a_id=$NOW OR r.b_id=$NOW) LIMIT 1")
if [ -z "$SIDE" ]; then SIDE=$(db "SELECT id FROM routes WHERE kind='side' AND a_id=$HOME LIMIT 1"); fi
echo "  side route $SIDE from $(db "SELECT a_id FROM routes WHERE id=$SIDE") (I'm at $NOW)"
curl -s -b $C -c $C $BASE/world.php > /tmp/r.html; curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/r.html)" -d do=start -d route_id=$SIDE -o /dev/null; curl -s -b $C $BASE/world.php | grep -oE 'flash err">[^<]*'
echo "== walk back home, then discover a hidden place"
BACK=$(db "SELECT id FROM routes WHERE kind='road' AND ((a_id=$NOW AND b_id=$HOME) OR (a_id=$HOME AND b_id=$NOW))"); [ -n "$BACK" ] && walkto $BACK >/dev/null
NOW=$(db "SELECT location_id FROM users WHERE id=$SID"); SIDE=$(db "SELECT id FROM routes WHERE kind='side' AND a_id=$NOW LIMIT 1"); DEST=$(db "SELECT b_id FROM routes WHERE id=$SIDE")
echo "  at $(db "SELECT name FROM locations WHERE id=$NOW"); side path to $(db "SELECT name||' ('||kind||')' FROM locations WHERE id=$DEST")"
curl -s -b $C $BASE/world.php | grep -c "Side path" | sed 's/^/  side paths shown before: /'
SLUG=$(db "SELECT slug FROM locations WHERE id=$DEST"); KIND=$(db "SELECT kind FROM locations WHERE id=$DEST"); KEY=$([ "$KIND" = village ] && echo village:$SLUG || echo landmark:$SLUG)
dbx "INSERT INTO user_encyclopedia (user_id, entry_id, unlocked_at) SELECT $SID, id, datetime('now') FROM encyclopedia_entries WHERE unlock_key='$KEY'"
curl -s -b $C $BASE/world.php | grep -c "Side path" | sed 's/^/  side paths shown after discovering it: /'
dbx "UPDATE users SET energy=50 WHERE id=$SID"; walkto $SIDE
curl -s -b $C $BASE/world.php > /tmp/r.html; grep -oE 'You’re off the road here[^<]*' /tmp/r.html
echo "== welcome only offers road villages"; echo "  (checked in walk.sh)"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/roads-php.log || echo "(none)"
