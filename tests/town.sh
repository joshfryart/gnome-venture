#!/bin/bash
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/town-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/town-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > /tmp/t.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/t.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
dbx "UPDATE users SET location_id=(SELECT l.id FROM locations l WHERE l.kind='market' AND l.region_id=users.region_id LIMIT 1)"; dbx "UPDATE users SET energy = 100, coins = 1000 WHERE username='sprout'"
dbx "UPDATE settings SET value='0' WHERE name='event_chance'"; dbx "INSERT OR IGNORE INTO settings (name,value) VALUES ('event_chance','100000')"; dbx "UPDATE settings SET value='100000' WHERE name='event_chance'"
HERE=$(db "SELECT location FROM users WHERE username='sprout'")
act() { # action slug -> posts it, prints prize title/big or flash
  local id=$(db "SELECT id FROM town_actions WHERE slug='$1'"); local sp=$(db "SELECT spot_id FROM town_actions WHERE slug='$1'")
  curl -s -b $C -c $C "$BASE/town.php?${2}spot=$sp" > /tmp/t.html
  curl -s -b $C -c $C -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/t.html)" -d do=act -d action_id=$id -d spot=$sp $( [ -n "$2" ] && echo "-d hub=1") -o /dev/null
  curl -s -b $C -c $C "$BASE/town.php?${2}spot=$sp" > /tmp/t.html
  echo "  $1: $(grep -oE 'class="(pztitle|pzbig)">[^<]*|flash err">[^<]*' /tmp/t.html | sed 's/.*">//' | tr '\n' ' ' | cut -c1-160) $(grep -oE '<li>[^<]*' /tmp/t.html | sed 's/<li>//' | tr '\n' ',' | cut -c1-120)"
}
echo "== town page ($HERE)"; curl -s -b $C $BASE/town.php -o /tmp/t.html -w "town.php %{http_code}\n"; grep -oE 'class="box spotcard[^"]*"|<b>[^<]*</b>' /tmp/t.html | head -14 | tr '\n' ' '; echo
grep -oE '🕰️[^<·]*' /tmp/t.html | head -1
K=$(db "SELECT lower(code) FROM regions WHERE gnomish_name='$HERE'")
echo "== shared actions"; act $K-bench; act $K-bench; act $K-birds; act $K-picnic; act $K-drink; act $K-read; act $K-read
echo "== buff active: $(db "SELECT town_stat, town_amt, town_until > datetime('now') FROM users WHERE username='sprout'")"
echo "== lore unlocked: $(db "SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id=ue.entry_id JOIN users u ON u.id=ue.user_id WHERE u.username='sprout' AND e.unlock_key LIKE 'lore:%'")"
echo "== quiz"; act $K-riddle; T=$(grep -o 'name="token" value="[a-f0-9]*"' /tmp/t.html | head -1 | sed 's/.*value="//; s/"//'); Q=$(grep -oE 'evtitle">[^<]*' /tmp/t.html | head -1); echo "  $Q"
curl -s -b $C -c $C -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/t.html)" -d do=answer -d token=$T -d choice=o1 -o /dev/null; curl -s -b $C -c $C $BASE/town.php > /tmp/t.html; echo "  answer: $(grep -oE 'class="(pztitle|pzbig)">[^<]*' /tmp/t.html | sed 's/.*">//' | tr '\n' ' ')"
curl -s -b $C -c $C -X POST $BASE/town.php --data-urlencode "csrf=$(csrf /tmp/t.html)" -d do=answer -d token=$T -d choice=o1 -o /dev/null; curl -s -b $C $BASE/town.php | grep -oE 'flash err">[^<]*' | sed 's/^/  replay: /'
echo "== specials here"; for a in $(db "SELECT a.slug FROM town_actions a JOIN town_spots s ON s.id=a.spot_id WHERE s.region='$HERE' AND s.kind='special'"); do act $a; done
echo "== hub"; curl -s -b $C "$BASE/town.php?hub=1" -o /tmp/t.html -w "hub %{http_code}\n"; act hub-listen "hub=1&"; act hub-dig "hub=1&"
echo "== another region's place is refused"; act na-boil; act ss-comb
echo "== no csrf"; curl -s -b $C -X POST $BASE/town.php -d do=act -d action_id=1 -o /dev/null -w "%{http_code}\n"
echo "== energy 0"; dbx "UPDATE users SET energy = 0 WHERE username='sprout'"; act $K-birds
echo "== closed (hours) check"; dbx "UPDATE town_spots SET hours='3-4' WHERE slug='$K-green'"; act $K-birds; dbx "UPDATE town_spots SET hours='' WHERE slug='$K-green'"
echo "== world link"; curl -s -b $C $BASE/world.php | grep -c towncall
echo "== admin pages"; A=/tmp/town-a; rm -f $A; curl -s -c $A -b $A $BASE/login.php > /tmp/t.html; curl -s -c $A -b $A -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/t.html)" -d username=admin -d password=TestPassword123 -o /dev/null
for r in town_spots town_actions town_lore; do curl -s -b $A "$BASE/admin/crud.php?r=$r" -o /dev/null -w "$r %{http_code}\n"; done
curl -s -b $A "$BASE/admin/crud.php?r=town_spots&do=edit&id=5" -o /dev/null -w "edit %{http_code}\n"; curl -s -b $A "$BASE/admin/settings.php" | grep -c game_timezone
echo "== php errors"; grep -iE 'fatal|warning|notice|deprecated' /tmp/town-php.log || echo "(none)"
