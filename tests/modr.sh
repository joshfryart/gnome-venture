#!/bin/bash
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/mod-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
dbx "DELETE FROM users WHERE username='bloom'"
php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $r=$p->query("SELECT * FROM users WHERE username=\"sprout\"")->fetch(PDO::FETCH_ASSOC); unset($r["id"]); $r["username"]="bloom"; $r["email"]="bloom@b.local"; $r["gnome_name"]="Bloom Thistledown"; $c=array_keys($r); $p->prepare("INSERT INTO users (".implode(",",$c).") VALUES (".implode(",",array_fill(0,count($c),"?")).")")->execute(array_values($r));'
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('fresh_hold_days','0')"   # brand-new test accounts (fresh_hold.sh tests the hold itself)
dbx "UPDATE users SET onboarded=1 WHERE username='bloom'"; dbx "UPDATE users SET level=5, coins=500 WHERE username IN ('sprout','bloom')"
login() { rm -f $1; curl -s -c $1 -b $1 $BASE/login.php > /tmp/m.html; curl -s -c $1 -b $1 -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/m.html)" -d username=$2 -d "password=$3" -o /dev/null -w "%{redirect_url}"; }
A=/tmp/mod-a; B=/tmp/mod-b; ADM=/tmp/mod-adm; login $A sprout 'TestPass123!' >/dev/null; login $B bloom 'TestPass123!' >/dev/null; login $ADM admin TestPassword123 >/dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'"); BID=$(db "SELECT id FROM users WHERE username='bloom'")
gift() { curl -s -b $B -c $B $BASE/market.php > /tmp/m.html; curl -s -b $B -c $B -X POST $BASE/market.php --data-urlencode "csrf=$(csrf /tmp/m.html)" -d do=gift -d to=sprout -d coins=5 --data-urlencode "note=$1" -o /dev/null; curl -s -b $B $BASE/market.php | grep -oE 'flash (ok|err)">[^<]*' | head -1; }
echo "== word filter"; echo -n "  bad note: "; gift "you are a b.i.t.c.h"; echo -n "  scunthorpe-ish ok: "; gift "Enjoy the class assignment, ha"
echo -n "  nice note: "; gift "Happy gardening!"
GIFT=$(db "SELECT id FROM gifts WHERE from_id=$BID ORDER BY id DESC LIMIT 1")
echo "== report buttons on sprout's market page: $(curl -s -b $A $BASE/market.php | grep -c 'reportlink')"
rep() { curl -s -b $A -c $A "$BASE/report.php?u=$1&k=$2&r=$3" > /tmp/m.html; curl -s -b $A -c $A -X POST $BASE/report.php --data-urlencode "csrf=$(csrf /tmp/m.html)" -d u=$1 -d k=$2 -d r=$3 -d reason=$4 -d back=market.php -o /dev/null; curl -s -b $A $BASE/market.php | grep -oE 'flash (ok|err)">[^<]*' | head -1; }
echo -n "  report gift: "; rep $BID gift $GIFT rude; echo -n "  again: "; rep $BID gift $GIFT rude
echo -n "  report name: "; rep $BID name 0 rude; echo -n "  self: "; rep $SID name 0 rude
echo "== a player can't open the queue: $(curl -s -b $B $BASE/modtools.php -o /dev/null -w '%{redirect_url}')"
curl -s -b $ADM $BASE/modtools.php > /tmp/m.html; echo "== admin queue: $(grep -c 'class="box report"' /tmp/m.html) reports · nav badge: $(curl -s -b $ADM $BASE/index.php | grep -oE 'Moderation \([0-9]+\)')"
modact() { curl -s -b $ADM -c $ADM $BASE/modtools.php > /tmp/m.html; curl -s -b $ADM -c $ADM -X POST $BASE/modtools.php --data-urlencode "csrf=$(csrf /tmp/m.html)" -d do=$1 -d report=$2 -d hours=$3 -o /dev/null; curl -s -b $ADM $BASE/modtools.php | grep -oE 'flash (ok|err)">[^<]*' | head -1; }
R1=$(db "SELECT id FROM reports WHERE kind='gift' LIMIT 1"); R2=$(db "SELECT id FROM reports WHERE kind='name' LIMIT 1")
echo -n "  mute on gift: "; modact mute $R1 24; echo "  gift note now: '$(db "SELECT COALESCE(note,'(none)') FROM gifts WHERE id=$GIFT")' · muted: $(db "SELECT muted_until > datetime('now') FROM users WHERE id=$BID")"
echo -n "  muted gnome writes: "; gift "hello again"
echo -n "  muted gnome gifts without a note: "; gift ""
echo -n "  lift: "; curl -s -b $ADM -c $ADM $BASE/modtools.php > /tmp/m.html; curl -s -b $ADM -c $ADM -X POST $BASE/modtools.php --data-urlencode "csrf=$(csrf /tmp/m.html)" -d do=lift -d user=$BID -d what=mute -o /dev/null; curl -s -b $ADM $BASE/modtools.php | grep -oE 'flash (ok|err)">[^<]*' | head -1
echo -n "  time-out on name: "; modact timeban $R2 24; echo "  name now: $(db "SELECT gnome_name FROM users WHERE id=$BID")"
echo "  bloom's next page: $(curl -s -b $B $BASE/garden.php -o /dev/null -w '%{redirect_url}')"
echo -n "  bloom logs in: "; login $B bloom 'TestPass123!' >/dev/null; grep -oE 'time-out[^<]*' /tmp/m.html; curl -s -c $B -b $B $BASE/login.php > /tmp/m.html; curl -s -c $B -b $B -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/m.html)" -d username=bloom -d 'password=TestPass123!' | grep -oE 'time-out[^<]*' | head -1
echo "== a mod (not admin) can't ban for good"; dbx "UPDATE users SET role='mod' WHERE id=$SID"; rep $BID other 0 cheat >/dev/null; R3=$(db "SELECT id FROM reports WHERE status='open' LIMIT 1")
curl -s -b $A -c $A $BASE/modtools.php > /tmp/m.html; echo "  mod sees queue: $(grep -c 'class="box report"' /tmp/m.html) · ban button: $(grep -c 'Ban for good' /tmp/m.html)"
curl -s -b $A -c $A -X POST $BASE/modtools.php --data-urlencode "csrf=$(csrf /tmp/m.html)" -d do=ban -d report=$R3 -o /dev/null; curl -s -b $A $BASE/modtools.php | grep -oE 'flash (ok|err)">[^<]*' | head -1; dbx "UPDATE users SET role='player' WHERE id=$SID"
echo "== admin log: $(db "SELECT group_concat(action, ', ') FROM admin_log WHERE action LIKE 'mod_%'")"
echo "== notices for bloom: $(db "SELECT COUNT(*) FROM notices WHERE user_id=$BID AND text LIKE '%moderator%'")"
echo "== welcome rejects a rude gnome name: $(php -r 'chdir("'$GAME'"); $_SERVER["HTTP_HOST"]="x"; require "includes/bootstrap.php"; echo blocked_word("Shit Weasel") ? "blocked" : "allowed", " / ", blocked_word("Bramble Puddlefoot") ? "blocked" : "allowed";')"
dbx "UPDATE users SET banned_until=NULL, muted_until=NULL WHERE id=$BID"
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/mod-php.log || echo "(none)"
