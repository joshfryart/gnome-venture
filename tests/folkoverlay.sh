#!/bin/bash
# v2.0.77 villager overlay. Run after walk.sh has installed (player "sprout").
#   stopfolk.php (JSON): panel, chat once a day, gift once a day (item taken, friendship up, no gift for tools), wrong place / no fetch header refused
#   town + rest-stop pages carry the overlay hooks (data-folk-npc, data-folk-stop, the mount and script), the no-JS chat form is still there
#   a real browser (Playwright): Chat opens a dialog instead of a new page, chat + gift happen inside it, the page behind does not navigate
GAME=$1; PORT=$2; ROUTER=$3; BASE=http://127.0.0.1:$PORT
php -d session.save_path=/tmp -S 127.0.0.1:$PORT -t $GAME $ROUTER >/tmp/fo-php.log 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
FAILS=0
chk() { if [ "$2" = 1 ]; then echo "  ok   $1"; else echo "  FAIL $1 $3"; FAILS=$((FAILS+1)); fi; }
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
db() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); foreach($p->query($argv[1])->fetchAll(PDO::FETCH_NUM) as $r) echo implode(" | ",$r),"\n";' "$1"; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
C=/tmp/fo-ck; rm -f $C; curl -s -c $C -b $C $BASE/login.php > /tmp/fo.html; curl -s -c $C -b $C -X POST $BASE/login.php --data-urlencode "csrf=$(csrf /tmp/fo.html)" -d username=sprout -d 'password=TestPass123!' -o /dev/null
SID=$(db "SELECT id FROM users WHERE username='sprout'" | tr -d ' ')
VIL=$(db "SELECT l.id FROM locations l JOIN routes r ON (r.a_id=l.id OR r.b_id=l.id) WHERE l.kind='village' AND r.kind='road' ORDER BY l.id LIMIT 1" | tr -d ' ')
dbx "UPDATE users SET location_id=$VIL, level=5, energy=40, tour_step=0 WHERE id=$SID"; dbx "UPDATE expeditions SET status='done' WHERE user_id=$SID"
page() { curl -s -b $C -c $C "$BASE/$1" > /tmp/fo.html; }
fetchj() { curl -s -b $C -c $C -H 'X-Requested-With: fetch' "$BASE/$1"; }
postj() { curl -s -b $C -c $C -H 'X-Requested-With: fetch' -X POST "$BASE/stopfolk.php" --data-urlencode "csrf=$TOK" "$@"; }
give() { dbx "INSERT OR IGNORE INTO user_items (user_id,item_id,qty) VALUES ($SID,(SELECT id FROM items WHERE slug='$1'),0)"; dbx "UPDATE user_items SET qty=qty+$2 WHERE user_id=$SID AND item_id=(SELECT id FROM items WHERE slug='$1')"; }
qty() { db "SELECT COALESCE((SELECT qty FROM user_items WHERE user_id=$SID AND item_id=(SELECT id FROM items WHERE slug='$1')),0)" | tr -d ' '; }

echo "== the rest-stop villagers page carries the hooks"
page 'town.php?t=folk'
FID=$(db "SELECT id FROM stop_folk WHERE location_id=$VIL AND active=1 ORDER BY slot LIMIT 1" | tr -d ' ')
[ -n "$FID" ] || { echo "  FAIL no villagers at the stop"; exit 1; }
chk "Chat button has data-folk-stop" "$(grep -q "data-folk-stop=\"$FID\"" /tmp/fo.html && echo 1)"
chk "the no-JS chat form is still there (kind=_chat)" "$(grep -q 'name="kind" value="_chat"' /tmp/fo.html && echo 1)"
chk "overlay mount and script on the page" "$(grep -q 'id="folkov"' /tmp/fo.html && grep -q 'assets/folkoverlay.js' /tmp/fo.html && echo 1)"
TOK=$(grep -o 'id="folkov"[^>]*data-csrf="[^"]*"' /tmp/fo.html | sed 's/.*data-csrf="\([^"]*\)".*/\1/')
chk "mount carries a csrf token" "$([ -n "$TOK" ] && echo 1)"

echo "== stopfolk.php"
chk "no fetch header: refused" "$(curl -s -b $C -c $C "$BASE/stopfolk.php?folk=$FID" | grep -q '"ok":false' && echo 1)"
J=$(fetchj "stopfolk.php?folk=$FID"); chk "panel comes back as JSON with html" "$(echo "$J" | grep -q '"ok":true' && echo "$J" | grep -q 'data-folk' && echo 1)"
chk "panel offers chat" "$(echo "$J" | grep -q 'Say hello' && echo 1)"
chk "unknown villager: not ok" "$(fetchj "stopfolk.php?folk=999999" | grep -q '"ok":false' && echo 1)"
P0=$(db "SELECT COALESCE((SELECT points FROM stop_friend WHERE user_id=$SID AND folk_id=$FID),0)" | tr -d ' ')
J=$(postj -d do=chat -d folk=$FID); chk "chat works" "$(echo "$J" | grep -q '"ok":true' && echo 1)" "$J"
P1=$(db "SELECT points FROM stop_friend WHERE user_id=$SID AND folk_id=$FID" | tr -d ' ')
chk "chat gave friendship" "$([ "$P1" -gt "$P0" ] && echo 1)" "($P0 -> $P1)"
chk "panel now says Chatted today" "$(echo "$J" | grep -q 'Chatted today' && echo 1)"
give tomato 3; IT=$(db "SELECT id FROM items WHERE slug='tomato'" | tr -d ' ')
J=$(postj -d do=gift -d folk=$FID -d item_id=$IT); chk "gift works" "$(echo "$J" | grep -q '"ok":true' && echo 1)" "$J"
chk "gift took one tomato" "$([ "$(qty tomato)" = 2 ] && echo 1)" "($(qty tomato))"
P2=$(db "SELECT points FROM stop_friend WHERE user_id=$SID AND folk_id=$FID" | tr -d ' ')
chk "gift gave friendship" "$([ "$P2" -gt "$P1" ] && echo 1)" "($P1 -> $P2)"
J=$(postj -d do=gift -d folk=$FID -d item_id=$IT); chk "second gift today refused, nothing taken" "$(echo "$J" | grep -q '"ok":false' && [ "$(qty tomato)" = 2 ] && echo 1)"
dbx "UPDATE stop_friend SET last_gift=NULL WHERE user_id=$SID AND folk_id=$FID"
TOOL=$(db "SELECT id FROM items WHERE category='tool' LIMIT 1" | tr -d ' '); give "$(db "SELECT slug FROM items WHERE id=$TOOL" | tr -d ' ')" 1
J=$(postj -d do=gift -d folk=$FID -d item_id=$TOOL); chk "a tool is not a gift" "$(echo "$J" | grep -q '"ok":false' && echo 1)"
chk "bad csrf is refused (400)" "$([ "$(curl -s -o /dev/null -w '%{http_code}' -b $C -c $C -H 'X-Requested-With: fetch' -X POST "$BASE/stopfolk.php" -d csrf=nope -d do=chat -d folk=$FID)" = 400 ] && echo 1)"
OTHER=$(db "SELECT id FROM stop_folk WHERE location_id<>$VIL LIMIT 1" | tr -d ' ')
chk "the panel shows a picture (icon, placeholder or emoji frame)" "$(fetchj "stopfolk.php?folk=$FID" | grep -q 'folkimg' && echo 1)"
chk "a villager of another stop is refused" "$(fetchj "stopfolk.php?folk=$OTHER" | grep -q '"ok":false' && echo 1)"

echo "== townsfolk rows (main stop)"
HUBQ=$(db "SELECT l.id FROM locations l WHERE l.kind IN ('market','hub') ORDER BY l.id LIMIT 1" | tr -d ' ')
dbx "UPDATE users SET location_id=$HUBQ WHERE id=$SID"
page 'town.php?view=villagers'
chk "town villagers view has the overlay mount" "$(grep -q 'id="folkov"' /tmp/fo.html && echo 1)"
if grep -q 'data-folk-npc' /tmp/fo.html; then
  chk "Chat is a link to the villager page AND opens the overlay" "$(grep -q '<a class="fbtn" href="[^"]*folk.php?id=[0-9]*" data-folk-npc=' /tmp/fo.html && echo 1)"
else echo "  note: nobody is out and about in this town right now (rows not checked)"; fi
NID=$(db "SELECT id FROM npcs WHERE active=1 LIMIT 1" | tr -d ' ')
chk "villagers.php still answers the panel in JSON" "$(fetchj "villagers.php?id=$NID" | grep -qE '"ok":(true|false)' && echo 1)"

echo "== browser"
if node -e "require('playwright')" 2>/dev/null; then
  dbx "UPDATE users SET location_id=$VIL WHERE id=$SID"; dbx "UPDATE stop_friend SET last_talk=NULL, last_gift=NULL WHERE user_id=$SID"
  [ -n "$SHOT_SPECIES" ] && dbx "UPDATE stop_folk SET species='$SHOT_SPECIES' WHERE id=$FID"
  OUT=$(BASE=$BASE FID=$FID node "$(dirname "$0")/folkoverlay.js" 2>&1)
  echo "$OUT" | sed 's/^/  /'
  chk "browser: rest-stop overlay flow passed" "$(echo "$OUT" | grep -q 'OVERLAY OK' && echo 1)"
  dbx "UPDATE users SET location_id=$HUBQ WHERE id=$SID"
  OUT=$(SHOT=${SHOT_NPC:-} MODE=npc BASE=$BASE FID=$FID node "$(dirname "$0")/folkoverlay.js" 2>&1); echo "$OUT" | sed 's/^/  /'
  chk "browser: townsfolk overlay passed" "$(echo "$OUT" | grep -q 'OVERLAY OK' && echo 1)"
else echo "  note: Playwright not installed, browser part skipped"; fi
echo "== php errors"
chk "no PHP warnings or fatals" "$(grep -iE 'fatal|warning|notice|deprecated|exception' /tmp/fo-php.log | grep -q . && echo 0 || echo 1)" "$(grep -iE 'fatal|warning|notice' /tmp/fo-php.log | head -3)"
[ $FAILS -eq 0 ] && echo "all passed" || echo "$FAILS FAILED"; [ $FAILS -eq 0 ]
