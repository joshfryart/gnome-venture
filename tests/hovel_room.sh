#!/bin/bash
# The interactive hovel room on the slim home's Today tab (includes/home_slim.php, includes/data/hovel_things.php, assets/hovelroom.js):
# tests/hovel_room.php (the data file's boxes, the picture, the sleep row against gclock_rest_options, Furnish unchanged) on an installed
# copy (ci_suites.sh installs it with walk.sh first: player "sprout"), then the pages with curl (no script: every thing is a link, the row
# buttons are real forms), then a real browser (tests/hovel_room_page.js; skipped without playwright).
# Usage: tests/hovel_room.sh GAME_DIR PORT ROUTER
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-8977}; ROUTER=${3:-$HERE/router.php}; BASE=http://127.0.0.1:$PORT
T=$(mktemp -d); LOG=$T/php.log
OUT=$(php -d error_reporting=-1 -d display_errors=1 -d session.save_path=/tmp "$HERE/hovel_room.php" "$GAME" 2>&1); RC=$?
echo "$OUT"
LAST=$(echo "$OUT" | tail -1)
case "$LAST" in ok) ;; *FAILED) ;; *) echo "FAIL hovel_room.php did not finish (last line: $LAST)"; exit 1;; esac
echo "$OUT" | grep -qE "^(PHP )?(Warning|Notice|Deprecated|Fatal error)" && { echo "FAIL hovel_room.php printed PHP warnings"; exit 1; }
FAILS=0
php -d session.save_path=$T -d display_errors=1 -S 127.0.0.1:$PORT -t $GAME $ROUTER >$LOG 2>&1 & PID=$!
for _ in $(seq 1 50); do curl -s -o /dev/null "$BASE/index.php" && break; sleep 0.2; done
trap "kill $PID 2>/dev/null; rm -rf $T" EXIT
C=$T/ck; H=$T/p.html
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o /dev/null -w '%{http_code} %{redirect_url}'; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
set_() { dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('$1', '$2')"; }
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
has() { if grep -q -- "$2" $H; then echo "  ok   $1"; else echo "  FAIL $1 (no '$2')"; FAILS=$((FAILS+1)); fi; }
hasnt() { if grep -q -- "$2" $H; then echo "  FAIL $1 (found '$2')"; FAILS=$((FAILS+1)); else echo "  ok   $1"; fi; }
banner() { sed -n 's/.*\(<section class="hs-banner.*\)<nav class="tabs hometabs.*/\1/p' $H; }   # the banner only: the room, the greeting, the row
noerr() { if grep -qiE 'fatal error|warning:|notice:|deprecated:' $H; then echo "  FAIL $1 has a PHP error"; FAILS=$((FAILS+1)); fi; }
SID=$(dbv "SELECT id FROM users WHERE username='sprout'")
home() { dbx "UPDATE users SET tour_step = 0, tour_ask = 0, location_id = home_village_id, game_minute = 600, coins = 500, energy = 5 WHERE id = $SID"; }
home
set_ home_slim 1; set_ game_clock_on 1; set_ tea_open everyone
get login.php >/dev/null; post login.php -d username=sprout -d 'password=TestPass123!' >/dev/null

echo "== Today: the whole room with its things (no script)"
chk "home is 200" "$(get gnome.php)" 200; noerr home
has "the whole room, with things" '<svg class="hroom hroom-full hroom-things dp-'; hasnt "...no cropped banner" 'hroom-crop'
has "...the tag over the picture" '</svg><span class="hs-tag">10:00 · '
for t in window bed gnome lamp door; do has "...the $t is a link" "<a class=\"ht ht-$t"; done
has "...the kettle keeps its link" '<a class="hd hd-kettle" href="/gnome.php?tea=1#htea" data-hdlg="htea"'
chk "...six tap boxes" "$(grep -o 'class="ht-hit"\|<rect class="hd-hit" x="312"' $H | wc -l | tr -d ' ')" 6
chk "...each with a label and a title" "$(grep -o '<a class="\(ht ht-[a-z]*\( pulse\)\?\|hd hd-kettle\)" href="[^"]*"[^>]* aria-label="[^"]*"><title>[^<]*</title>' $H | wc -l | tr -d ' ')" 6
hasnt "...no decor picker links on Today" 'data-hdlg="hpick-'
has "one greeting line" '<h1 class="hs-hi">Good morning, '
has "the sleep row: Sleep (the moon is a drawn icon)" '<div class="hs-btns"><button class="btn small hs-sb" type="submit" name="do" value="home_sleep" title="Sleep in your hovel · free"><img class="ico pix" [^>]*> Sleep</button>'
has "...Nap" 'name="do" value="home_nap" title="Nap in your hovel'
chk "...no big buttons in the banner" "$(banner | grep -c 'class="btn big"')" 0; hasnt "...no old Other beds fold" 'class="hs-more"'
has "the bed's card, closed" '<dialog class="hpick hpop" id="hp-bed" aria-labelledby="hp-bed-h"><form'
has "the window's card, closed" '<dialog class="hpick hpop" id="hp-window" aria-labelledby="hp-window-h"><div'
has "the script" 'assets/hovelroom.js'
chk "the banner is on the page, with no inline style" "$(banner | grep -c 'hroom-things'):$(banner | grep -c 'style=')" "1:0"
chk "no inline style in the cards" "$(grep -o '<dialog class="hpick hpop" id="hp-bed".*id="hp-window"[^>]*>.*</dialog>' $H | sed 's/<dialog class="hpick htea.*//' | grep -c 'style=')" 0
chk "?thing=bed: the card is drawn open in the page" "$(get 'gnome.php?thing=bed' >/dev/null; grep -c 'id="hp-bed" aria-labelledby="hp-bed-h" open>' $H)" 1
has "...with Go to sleep" 'name="do" value="home_sleep" title="Sleep in your hovel · free">Go to sleep</button>'
chk "?thing=window: the weather card is drawn open" "$(get 'gnome.php?thing=window' >/dev/null; grep -c 'id="hp-window" aria-labelledby="hp-window-h" open>' $H)" 1
has "...today and tomorrow" '<small>Tomorrow</small>'; has "...a link to Seasons" 'href="/seasons.php"'
get 'gnome.php?lamp=on' >/dev/null; has "?lamp=on lights the lamp" 'hroom-things lamp-on'; has "...and the link switches it off" 'href="/gnome.php?lamp=off" data-hlamp'
DOOR=$(get gnome.php >/dev/null; grep -o '<a class="ht ht-door" href="[^"]*"' $H | sed 's/.*href="\([^"]*\)"/\1/')
chk "the door's page loads" "$(get "${DOOR#/}")" 200; noerr "the door's page"
get 'gnome.php?tab=gnome' >/dev/null; has "the gnome's no-script link is the Gnome tab" 'class="box gnomecard"'

echo "== the row's buttons do what the big ones did"
get gnome.php >/dev/null
chk "Nap from the row" "$(post hovel.php -d do=home_nap -d back=today)" "302 $BASE/gnome.php?tab=today"
chk "...the clock moved on" "$(dbv "SELECT game_minute > 600 FROM users WHERE id = $SID")" 1
get gnome.php >/dev/null; D0=$(dbv "SELECT game_day FROM users WHERE id = $SID")
chk "Sleep from the row" "$(post hovel.php -d do=home_sleep -d back=today)" "302 $BASE/gnome.php?tab=today"
chk "...a new day at 06:00" "$(dbv "SELECT (game_day - $D0) || ':' || game_minute FROM users WHERE id = $SID")" "1:360"
chk "no CSRF, no sleep" "$(curl -s -c $C -b $C -X POST "$BASE/hovel.php" -d do=home_sleep -d back=today -o /dev/null -w '%{http_code}')" 400
TOWN=$(dbv "SELECT id FROM locations WHERE kind IN ('market', 'hub') AND id <> (SELECT home_village_id FROM users WHERE id = $SID) ORDER BY id LIMIT 1")
dbx "UPDATE users SET location_id = $TOWN, coins = 500 WHERE id = $SID"
get gnome.php >/dev/null; noerr "Today in a town"
has "in a town: the inn with its price" 'name="do" value="inn_pay" title="Rent a room at the inn · 110 '; has "...as the button's words" '<img class="ico pix" [^>]*> Inn · 110</button>'
has "...Other beds opens the bed's card" '<a class="btn small ghost hs-sb" href="/gnome.php?thing=bed#hp-bed" data-hdlg="hp-bed">Other beds</a>'
has "...the card lists the bench" 'name="do" value="bench">Sleep on a bench in the park</button> <small>free, only 30% energy back</small>'
chk "the inn from the row: paid, slept" "$(post hovel.php -d do=inn_pay -d back=today; dbv "SELECT coins FROM users WHERE id = $SID")" "302 $BASE/gnome.php?tab=today390"
dbx "UPDATE users SET coins = 0 WHERE id = $SID"
get gnome.php >/dev/null; has "no Petals: the inn button is disabled" 'value="inn_pay" title="Rent a room at the inn · 110 [^"]*" disabled>'
home

echo "== Furnish and the other tabs are as they were"
get 'gnome.php?tab=furnish' >/dev/null; noerr Furnish
chk "Furnish: a picker link per slot (8 since the 2.7.58 trophy wall) in the banner room and in the side preview" "$(grep -o '<a class="hd hd-[a-z]*\( sel\)\?" href="/gnome.php?tab=furnish&amp;slot=[a-z]*" data-hdlg="hpick-[a-z]*"' $H | wc -l | tr -d ' ')" 16
has "...the rug's picker box" '<rect class="hd-hit" x="168" y="208" width="112" height="56"/></a>'
hasnt "...no things" 'hroom-things'; has "...the big buttons" '<button class="btn big" type="submit" name="do" value="home_sleep"'
chk "a slot tap still places an item" "$(post gnome.php -d do=decor -d slot=rug -d item=mossrug)" "302 $BASE/gnome.php?tab=furnish&slot=rug&prev=rush"
get gnome.php >/dev/null; has "...and Today's room shows it" 'scenes/hovel-rug-mossrug.png'
get 'gnome.php?tab=gnome' >/dev/null; has "Gnome tab: the crop banner" 'class="hroom hroom-crop'; has "...its big buttons" 'class="btn big"'
set_ tea_open off
get gnome.php >/dev/null; hasnt "tea closed: no kettle link" 'hd-kettle'; has "...the other things stay" '<a class="ht ht-door"'
set_ tea_open everyone
set_ home_slim 0
get gnome.php >/dev/null; hasnt "slim home off: no room things" 'hroom-things'; hasnt "...no script" 'assets/hovelroom.js'
set_ home_slim 1

echo "== a real browser (tests/hovel_room_page.js; skipped without playwright)"
home
NP=${NODE_PATH:-$(npm root -g 2>/dev/null)}
if command -v node >/dev/null && NODE_PATH=$NP node -e "require('playwright')" 2>/dev/null; then
  POUT=$(SHOTS=${HOVELSHOTS:-} NODE_PATH=$NP node "$HERE/hovel_room_page.js" "$BASE" 2>&1); echo "$POUT"
  echo "$POUT" | grep -q '^  ok   no script errors' || { echo "  FAIL the browser pass did not finish"; FAILS=$((FAILS+1)); }
  FAILS=$((FAILS + $(echo "$POUT" | grep -c '^  FAIL')))
else echo "  ok   browser pass: skipped (no playwright)"; fi
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG && FAILS=$((FAILS+1)) || echo "(none)"
dbx "DELETE FROM settings WHERE name IN ('home_slim', 'game_clock_on', 'tea_open')"
[ "$LAST" = "ok" ] || FAILS=$((FAILS+1))
[ $FAILS -eq 0 ] && echo "hovel_room: all ok" || echo "$FAILS FAILED"
[ $FAILS -eq 0 ]
