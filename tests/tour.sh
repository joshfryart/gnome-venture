#!/bin/bash
# v2.4.97 Wren's tour: the "now or later?" question after the garden is named, the bubble data (targets, skip form), arrival words on visit steps, and "skip this step".
# Run on a fresh SQLite install that walk.sh made (player "sprout"): tour.sh GAME PORT ROUTER
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
TD=$(mktemp -d)
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >$TD/tour-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null; rm -rf $TD" EXIT
C=$TD/ck; rm -f $C
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
page() { curl -s -c $C -b $C "$BASE/$1" > $TD/p.html; }
postto() { local pg=$1 form=$2; shift 2; page "$form"; curl -s -c $C -b $C -X POST "$BASE/$pg" --data-urlencode "csrf=$(csrf $TD/p.html)" "$@" -o /dev/null; }
chk() { if [ "$2" = "$3" ]; then echo "ok   $1 = $2"; else echo "FAIL $1: got '$2' want '$3'"; fi; }
has() { if grep -q -- "$1" $TD/p.html; then echo "ok   $2"; else echo "FAIL $2"; fi; }
hasnt() { if grep -q -- "$1" $TD/p.html; then echo "FAIL $2"; else echo "ok   $2"; fi; }
login() { rm -f $C; page login.php; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $TD/p.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null; }
login
UID_=$(db "SELECT id FROM users WHERE username='sprout'")
st() { db "SELECT tour_step||'/'||tour_ask FROM users WHERE id=$UID_"; }
dbx "UPDATE users SET energy=0, energy_updated_at=datetime('now') WHERE id=$UID_"

echo "== the question"
dbx "UPDATE users SET tour_step=1, tour_ask=1 WHERE id=$UID_"
page garden.php
has 'tourask' "question card shows"; has 'value="start"' "Show me now button"; has 'value="later"' "Later button"; has 'value="skip"' "skip form on the question"
page "garden.php?sel=2-2"; curl -s -c $C -b $C -X POST $BASE/garden.php --data-urlencode "csrf=$(csrf $TD/p.html)" -d do=till -d x=2 -d y=2 -o /dev/null
chk "till does not count before the answer" "$(st)" "1/1"

echo "== later, then asked again next login"
postto tour.php garden.php -d do=later
chk "later pauses" "$(st)" "1/2"
page garden.php; has "Wren’s tour is waiting" "one-line chip while paused"; hasnt 'tourask' "no question while paused"
login; page garden.php
chk "next login asks again" "$(st)" "1/1"; has 'tourask' "question again"

echo "== now"
postto tour.php garden.php -d do=start
chk "start answers" "$(st)" "1/0"
page garden.php
has 'id="wrentour"' "bubble data"; has 'data-targets=' "targets"; has 'value=till' "till target in the data"; has 'value="skip"' "skip form on step 1"; has 'assets/tour.js' "tour.js loaded"
page "garden.php?sel=2-2"
has 'class="inline toolform"' "tool forms exist"; echo "DBG forms: $(grep -o 'name="do" value="[a-z]*"' $TD/p.html | sort -u | tr '\n' ' ') sel=$(grep -o 'garden.php?sel=[0-9-]*' $TD/p.html | head -3 | tr '\n' ' ')"
has 'name="do" value="till"' "till form on a selected square"
curl -s -c $C -b $C -X POST $BASE/garden.php --data-urlencode "csrf=$(csrf $TD/p.html)" -d do=till -d x=2 -d y=2 -o /dev/null
chk "till with 0 energy moves on (free tour action)" "$(st)" "2/0"

echo "== skip this step: only the optional one"
postto tour.php garden.php -d do=nextstep
chk "compost step can be skipped" "$(st)" "3/0"
postto tour.php garden.php -d do=nextstep
chk "plant step cannot" "$(st)" "3/0"

echo "== arrival words on a visit step"
dbx "UPDATE users SET tour_step=6, tour_ask=0 WHERE id=$UID_"
page book.php
chk "opening the Almanac moves on" "$(st)" "7/0"
has 'tourarr' "arrival card"; has 'Open your Almanac' "arrival card says what the Almanac step was"; has 'Meet your gnome' "next step follows"

echo "== a paused tour does not move on a visit"
dbx "UPDATE users SET tour_step=6, tour_ask=2 WHERE id=$UID_"
curl -s -c $C -b $C -X POST $BASE/tour.php --data-urlencode "csrf=$(csrf $TD/p.html)" -d do=later -o /dev/null
page book.php; chk "paused: Almanac visit not counted" "$(st)" "6/2"

echo "== skip clears the question"
dbx "UPDATE users SET tour_step=1, tour_ask=1 WHERE id=$UID_"
postto tour.php garden.php -d do=skip
chk "skip ends the tour" "$(st)" "0/0"
