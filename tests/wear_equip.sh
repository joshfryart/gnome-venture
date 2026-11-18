#!/bin/bash
# Wearing (2.7.14): tests/wear_equip.php on an installed copy (ci_suites.sh installs it with walk.sh first), then the pages: the Wearing panel on My Gnome
# (Wear / Take off through the form), the read-only strip on the Puzzle box, and both hidden with wear_open Off.
# Usage: tests/wear_equip.sh GAME_DIR PORT ROUTER
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-8977}; ROUTER=${3:-$HERE/router.php}; BASE=http://127.0.0.1:$PORT
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/wear_equip.php" "$GAME" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL wear_equip did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL wear_equip printed PHP warnings"; exit 1; }
T=$(mktemp -d); LOG=$T/php.log
php -d session.save_path=$T -S 127.0.0.1:$PORT -t $GAME $ROUTER >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null; rm -rf $T" EXIT
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
A=$T/ck; H=$T/p.html; FAILS=0
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
has() { if grep -q "$2" $H; then echo "  ok   $1"; else echo "  FAIL $1 (no '$2')"; FAILS=$((FAILS+1)); fi; }
hasnt() { if grep -q "$2" $H; then echo "  FAIL $1 (has '$2')"; FAILS=$((FAILS+1)); else echo "  ok   $1"; fi; }
curl -s -c $A -b $A $BASE/login.php > $H; curl -s -c $A -b $A -X POST $BASE/login.php --data-urlencode "csrf=$(csrf $H)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'")
dbx "INSERT OR REPLACE INTO settings (name,value) VALUES ('wear_open','1'); INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_v1','1'); INSERT OR REPLACE INTO settings (name,value) VALUES ('pfight_open','1'); DELETE FROM user_wear_slots WHERE user_id=$SID"
dbx "INSERT OR REPLACE INTO user_items (user_id,item_id,qty) SELECT $SID, id, 1 FROM items WHERE slug='work-gloves'"
echo "== the page: My Gnome"
chk "My Gnome opens" "$(curl -s -c $A -b $A "$BASE/gnome.php?tab=gnome" -o $H -w '%{http_code}')" 200
has "the Wearing panel" 'id="wearing"'
has "with the Hands slot" '<b>Hands</b>'
chk "the Hands picker opens" "$(curl -s -c $A -b $A "$BASE/gnome.php?tab=gnome&wear=hands" -o $H -w '%{http_code}')" 200
has "it lists the Work Gloves with a Wear button" 'name="item" value="work-gloves"'
chk "Wear (POST, redirect back)" "$(curl -s -c $A -b $A -X POST $BASE/gnome.php --data-urlencode "csrf=$(csrf $H)" -d do=wear_on -d slot=hands -d item=work-gloves -o /dev/null -w '%{http_code}')" 302
chk "the gloves are worn" "$(db "SELECT item_slug FROM user_wear_slots WHERE user_id=$SID AND slot='hands'")" work-gloves
chk "a POST without the CSRF token changes nothing" "$(curl -s -c $A -b $A -X POST $BASE/gnome.php -d do=wear_off -d slot=hands -o /dev/null -w '%{http_code}' >/dev/null; db "SELECT COUNT(*) FROM user_wear_slots WHERE user_id=$SID")" 1
curl -s -c $A -b $A "$BASE/gnome.php?tab=gnome" -o $H
has "the slot shows the worn item's picture" 'ph/work-gloves.png'
echo "== the Puzzle box strip"
chk "the Puzzle box opens" "$(curl -s -c $A -b $A "$BASE/puzzlebox.php" -o $H -w '%{http_code}')" 200
has "the read-only Wearing strip links to My Gnome" 'class="pbx-wear"'
hasnt "no Wear buttons there" 'value="wear_on"'
curl -s -c $A -b $A "$BASE/gnome.php?tab=gnome&wear=hands" -o $H
chk "Take off (POST)" "$(curl -s -c $A -b $A -X POST $BASE/gnome.php --data-urlencode "csrf=$(csrf $H)" -d do=wear_off -d slot=hands -o /dev/null -w '%{http_code}')" 302
chk "nothing worn" "$(db "SELECT COUNT(*) FROM user_wear_slots WHERE user_id=$SID")" 0
echo "== wear_open Off"
dbx "UPDATE settings SET value='0' WHERE name='wear_open'"
curl -s -c $A -b $A "$BASE/gnome.php?tab=gnome" -o $H; hasnt "no Wearing panel" 'id="wearing"'
curl -s -c $A -b $A "$BASE/puzzlebox.php" -o $H; hasnt "no Wearing strip" 'class="pbx-wear"'
chk "the Tailor page redirects away" "$(curl -s -c $A -b $A $BASE/tailor.php -o /dev/null -w '%{http_code}')" 302
dbx "UPDATE settings SET value='1' WHERE name='wear_open'"
grep -qE "(PHP )?(Warning|Notice|Deprecated|Fatal error)" $LOG && { echo "  FAIL PHP warnings:"; grep -E "(PHP )?(Warning|Notice|Deprecated|Fatal error)" $LOG | head -3; FAILS=$((FAILS+1)); }
[ $FAILS -eq 0 ] && echo ok || echo "$FAILS FAILED"
[ $RC -eq 0 ] && [ $FAILS -eq 0 ]
