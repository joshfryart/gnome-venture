#!/bin/bash
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/lm-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/lm-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > /tmp/l.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/l.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'"); RID=$(db "SELECT region_id FROM users WHERE id=$SID"); dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"
dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"; dbx "UPDATE users SET level=6, energy=40, coins=1000, tour_step=0 WHERE id=$SID"
goto() { dbx "UPDATE users SET location_id=$1 WHERE id=$SID"; curl -s -b $C -c $C $BASE/world.php > /tmp/l.html; }
lmact() { curl -s -b $C -c $C $BASE/world.php > /tmp/l.html; curl -s -b $C -c $C -X POST $BASE/landmark.php --data-urlencode "csrf=$(csrf /tmp/l.html)" "$@" -o /dev/null -w "%{redirect_url} "; curl -s -b $C -c $C $BASE/world.php > /tmp/l2.html; grep -oE 'class="(pztitle|pzbig)">[^<]*|flash (ok|err)">[^<]*' /tmp/l2.html | sed 's/.*">//' | tr '\n' ' ' | cut -c1-200; grep -oE '<li>[^<]*' /tmp/l2.html | sed 's/<li>//' | tr '\n' ',' | cut -c1-160; echo; }
pick() { db "SELECT lm.id||' '||lm.location_id FROM landmarks lm WHERE lm.kind='$1' AND lm.region_id=$RID ORDER BY lm.id LIMIT 1"; }
resolve() { for k in $(seq 60); do curl -s -b $C -c $C $BASE/adventure.php > /tmp/a.html
  T=$(csrf /tmp/a.html); [ -z "$T" ] && break
  if grep -q 'value="auto"' /tmp/a.html; then D="do=auto"; elif grep -q 'value="attack"' /tmp/a.html; then D="do=attack"; elif grep -q 'value="solve"' /tmp/a.html; then D="do=solve&option=0"; else break; fi
  curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$T" -d "$D" -o /dev/null; done; }
advpost() { curl -s -b $C -c $C $BASE/adventure.php > /tmp/a.html; curl -s -b $C -c $C -X POST $BASE/adventure.php --data-urlencode "csrf=$(csrf /tmp/a.html)" -d do=$1 -o /dev/null; }
read HID HLOC <<< "$(pick haven)"; echo "== haven: $(db "SELECT name FROM landmarks WHERE id=$HID")"; goto $HLOC
grep -oE 'lmpanel lm-[a-z]+' /tmp/l.html; grep -oE 'Today’s pantry' /tmp/l.html
dbx "UPDATE users SET energy=5 WHERE id=$SID"; echo -n "  rest: "; lmact -d do=rest -d lm=$HID; echo "  energy: $(db "SELECT energy FROM users WHERE id=$SID")"
echo -n "  rest again: "; lmact -d do=rest -d lm=$HID
echo -n "  stay: "; lmact -d do=stay -d lm=$HID; echo "  buff: $(db "SELECT town_stat||' +'||town_amt FROM users WHERE id=$SID")"
ITEM=$(grep -o 'name="item_id" value="[0-9]*"' /tmp/l.html | head -1 | grep -o '[0-9]*'); echo -n "  buy: "; lmact -d do=buy -d lm=$HID -d item_id=$ITEM; echo -n "  buy again: "; lmact -d do=buy -d lm=$HID -d item_id=$ITEM
echo -n "  buy something not in pantry: "; lmact -d do=buy -d lm=$HID -d item_id=1
echo -n "  safe base? "; php -r 'require "'$GAME'/includes/bootstrap.php";' 2>/dev/null; echo "(paths next to havens scale: $(curl -s -b $C $BASE/world.php | grep -c 'your level'))"
read WID WLOC <<< "$(pick wonder)"; echo "== wonder: $(db "SELECT name||' — '||description FROM landmarks WHERE id=$WID" | cut -c1-100)"; goto $WLOC
grep -oE '<button class="btn act">[^<]*' /tmp/l.html | head -3 | sed 's/.*">/  way: /'; grep -oE '[A-Za-z]+ \([+-][0-9]+\) vs [0-9]+ · about [0-9]+%' /tmp/l.html | sed 's/^/   /'
STAT=$(grep -o 'name="stat" value="[a-z]*"' /tmp/l.html | head -1 | sed 's/.*value="//; s/"//'); echo -n "  try ($STAT): "; lmact -d do=wonder -d lm=$WID -d stat=$STAT; echo -n "  again: "; lmact -d do=wonder -d lm=$WID -d stat=$STAT
echo -n "  not here (haven id at wonder): "; lmact -d do=rest -d lm=$HID
read DID DLOC <<< "$(pick delve)"; echo "== delve: $(db "SELECT name FROM landmarks WHERE id=$DID")"; goto $DLOC; grep -oE 'A delve <small[^>]*>[^<]*' /tmp/l.html
dbx "UPDATE users SET level=14, stat_grit=18, stat_hardiness=18, stat_nimble=16, energy=40 WHERE id=$SID"
echo -n "  go in: "; lmact -d do=delve -d lm=$DID
for room in 1 2 3 4 5; do advpost next; resolve; S2=$(db "SELECT status||' room '||depth FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1"); echo "  room $room: $S2"; case "$S2" in active*) ;; *) break;; esac; done
[ "$(db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1")" = active ] && advpost chest
echo "  end: $(db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1") · clears: $(db "SELECT clears FROM landmark_clears WHERE user_id=$SID AND landmark_id=$DID")"
db "SELECT log FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1" | php -r '$l=json_decode(stream_get_contents(STDIN),true); foreach($l as $x) if (preg_match("/^(🚪|💰|🎁|📗|⭐|🪜|🛡️|💫|🪤)/u",$x)) echo "    $x\n";'
dbx "UPDATE users SET location_id=$DLOC WHERE id=$SID"; echo -n "  again today: "; lmact -d do=delve -d lm=$DID
read LID LLOC <<< "$(pick lair)"; echo "== lair: $(db "SELECT name FROM landmarks WHERE id=$LID")"; goto $LLOC; grep -oE '<b>[^<]*</b> lives here. <small[^>]*>[^<]*' /tmp/l.html | sed 's/<[^>]*>//g; s/^/  /'
dbx "UPDATE users SET level=6, stat_grit=12, energy=40 WHERE id=$SID"; echo -n "  challenge at level 6: "; lmact -d do=lair -d lm=$LID; resolve; echo "  result: $(db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1") at $(db "SELECT l.name FROM users u JOIN locations l ON l.id=u.location_id WHERE u.id=$SID")"
dbx "DELETE FROM landmark_uses WHERE user_id=$SID AND action='lair'"; dbx "UPDATE users SET level=45, stat_grit=30, stat_hardiness=30, stat_nimble=24, energy=60, location_id=$LLOC WHERE id=$SID"
R0=$(db "SELECT ribbons FROM users WHERE id=$SID"); echo -n "  challenge at level 45: "; lmact -d do=lair -d lm=$LID; resolve
echo "  result: $(db "SELECT status FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1") · ribbons $R0 → $(db "SELECT ribbons FROM users WHERE id=$SID") · clears $(db "SELECT clears FROM landmark_clears WHERE user_id=$SID AND landmark_id=$LID")"
db "SELECT log FROM expeditions WHERE user_id=$SID ORDER BY id DESC LIMIT 1" | php -r '$l=json_decode(stream_get_contents(STDIN),true); foreach(array_slice($l,-6) as $x) echo "    $x\n";'
echo -n "  again today: "; lmact -d do=lair -d lm=$LID
echo "== gnome page: $(curl -s -b $C $BASE/gnome.php | grep -oE 'Lairs conquered: [0-9]+ · 🕳️ Delves cleared: [0-9]+')"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/lm-php.log || echo "(none)"
