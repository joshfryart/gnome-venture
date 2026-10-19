GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/ev-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/ev-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > /tmp/e.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/e.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
echo "== default odds: 60 page views"; n=0; for i in $(seq 60); do curl -s -b $C -c $C $BASE/garden.php | grep -q 'class="eventbox' && n=$((n+1)); done; echo "events seen: $n (expect ~0-2; max 3/day and 2 h apart)"
dbx "UPDATE settings SET value='2' WHERE name='event_chance'"; dbx "UPDATE settings SET value='0' WHERE name='event_cooldown_minutes'"; dbx "UPDATE settings SET value='100' WHERE name='event_daily_max'"
dbx "INSERT OR IGNORE INTO settings (name,value) VALUES ('event_chance','2'),('event_cooldown_minutes','0'),('event_daily_max','100')"
echo "== high odds: 30 page views"; inst=0; pend=0; for i in $(seq 30); do curl -s -b $C -c $C $BASE/world.php > /tmp/e.html; grep -q 'class="eventbox"' /tmp/e.html && inst=$((inst+1)); if grep -q 'class="eventbox waiting"' /tmp/e.html; then pend=$((pend+1)); T=$(grep -o 'name="token" value="[a-f0-9]*"' /tmp/e.html | head -1 | sed 's/.*value="//; s/"//'); CH=$(grep -o 'name="choice" value="[a-z]*"' /tmp/e.html | head -1 | sed 's/.*value="//; s/"//'); curl -s -b $C -c $C -X POST $BASE/event.php --data-urlencode "csrf=$(csrf /tmp/e.html)" -d token=$T -d choice=$CH -d back=world.php -o /dev/null -w "  clicked $CH -> %{redirect_url}\n"; curl -s -b $C -c $C $BASE/world.php | grep -oE 'class="evtitle">[^<]*' | head -1 | sed 's/^/    result: /'; LASTT=$T; fi; done
echo "instant: $inst  needing a click: $pend  counted today: $(db "SELECT event_count FROM users WHERE username='sprout'")"
echo "-- replay an old token:"; curl -s -b $C -c $C $BASE/world.php > /tmp/e.html; curl -s -b $C -c $C -X POST $BASE/event.php --data-urlencode "csrf=$(csrf /tmp/e.html)" -d token=$LASTT -d choice=go -d back=world.php -o /dev/null; curl -s -b $C $BASE/index.php | grep -oE 'flash err">[^<]*' | head -1
echo "-- admin pages never show events:"; A=/tmp/ev-a; rm -f $A; curl -s -c $A -b $A $BASE/login.php > /tmp/e.html; curl -s -c $A -b $A -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/e.html)" -d username=admin -d password=TestPassword123 -o /dev/null
m=0; for i in $(seq 10); do curl -s -b $A $BASE/admin/index.php | grep -q eventbox && m=$((m+1)); done; echo "admin pages with events: $m"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/ev-php.log || echo "(none)"
