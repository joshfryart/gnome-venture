#!/bin/bash
# Slim home (flag home_slim, includes/home_slim.php): off = the old home and Hovel; on = hovel banner + TODAY / FURNISH / GNOME,
# decor slots saved per gnome, hovel.php only sleeps and sends GETs home, the news row's "!" goes once the news is opened.
# Usage: tests/home_slim.sh GAME PORT ROUTER   (a copy walk.sh has installed: player "sprout"; tests/ci_suites.sh does that)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-8797}; ROUTER=${3:-$HERE/router.php}
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!
for _ in $(seq 1 50); do curl -s -o /dev/null "$BASE/index.php" && break; sleep 0.2; done
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o /dev/null -w '%{http_code} %{redirect_url}'; }
to() { curl -s -c $C -b $C "$BASE/$1" -o /dev/null -w '%{http_code} %{redirect_url}'; }
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
dbv() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query($argv[1])->fetchColumn();' "$1"; }
FAILS=0
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
has() { if grep -q -- "$2" $H; then echo "  ok   $1"; else echo "  FAIL $1 (no '$2')"; FAILS=$((FAILS+1)); fi; }
hasnt() { if grep -q -- "$2" $H; then echo "  FAIL $1 (found '$2')"; FAILS=$((FAILS+1)); else echo "  ok   $1"; fi; }
noerr() { if grep -qiE 'fatal error|warning:|notice:|deprecated:' $H; then echo "  FAIL $1 has a PHP error"; FAILS=$((FAILS+1)); fi; }

dbx "UPDATE users SET tour_step = 0, tour_ask = 0 WHERE username = 'sprout'"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('game_clock_on', '1')"
dbx "INSERT INTO news (title, body, published, kind, created_at) VALUES ('Slim news post', 'x', 1, 'notes', datetime('now'))"
get login.php >/dev/null; post login.php -d username=sprout -d 'password=TestPass123!' >/dev/null

echo "== flag off: the old pages"
get gnome.php >/dev/null; has "TODAY tab as before" 'class="tabs hometabs"'; hasnt "...no slim banner" 'class="hs-banner"'
chk "Furnish is not a tab" "$(get 'gnome.php?tab=furnish' >/dev/null; grep -c 'hs-slots' $H)" "0"
get hovel.php >/dev/null; has "the Hovel page shows" 'hov-tabs'

echo "== flag on"
dbx "INSERT OR REPLACE INTO settings (name, value) VALUES ('home_slim', '1')"
for t in today furnish gnome stats; do chk "gnome.php?tab=$t is 200" "$(get "gnome.php?tab=$t")" 200; noerr "tab $t"; done
get gnome.php >/dev/null
has "the banner" 'class="hs-banner"'; has "...a room picture" 'class="hroom hroom-crop'; has "...Go to sleep posts to hovel.php" 'action="/hovel.php" class="hs-rest"'
has "three tabs" 'class="tabs hometabs hstabs"'; has "Needs you" 'id="hs-needs-h"'; has "unread news row" 'class="box hs-news unread"'
hasnt "no clock pill in the header (the tag has the time)" 'hdr-clock'
get 'gnome.php?tab=gnome' >/dev/null; has "Gnome tab: the gnome card" 'class="box gnomecard"'; has "...the tiles" 'class="gvtiles"'; hasnt "...no Hovel link" 'Your hovel: sleep or nap'
hasnt "menu: no Hovel tile" 'href="/hovel.php"'
get 'gnome.php?tab=calling' >/dev/null; has "a sub-page keeps its back link" 'class="gvbacklink" href="/gnome.php?tab=gnome"'
get 'gnome.php?tab=furnish' >/dev/null; has "Furnish: slot tiles" 'class="hs-slots"'; has "...a picker per slot" 'id="hpick-rug"'; has "...the Cosiness meter" 'class="box hs-cosy"'
chk "place an owned item" "$(post gnome.php -d do=decor -d slot=rug -d item=mossrug)" "302 $BASE/gnome.php?tab=furnish&slot=rug&prev=rush"
chk "...saved" "$(dbv "SELECT item FROM user_hovel_decor d JOIN users u ON u.id = d.user_id WHERE u.username = 'sprout' AND slot = 'rug'")" "mossrug"
get 'gnome.php?tab=furnish&slot=rug&prev=rush' >/dev/null; has "...the picker is drawn open, with Undo" 'id="hpick-rug" aria-labelledby="hpick-h-rug" open'
chk "a locked item is refused" "$(post gnome.php -d do=decor -d slot=rug -d item=patch; dbv "SELECT item FROM user_hovel_decor d JOIN users u ON u.id = d.user_id WHERE u.username = 'sprout' AND slot = 'rug'")" "302 $BASE/gnome.php?tab=furnish&slot=rugmossrug"
chk "an unknown slot is refused" "$(post gnome.php -d do=decor -d slot=attic -d item=plank)" "302 $BASE/gnome.php?tab=furnish"
chk "no CSRF, no change" "$(curl -s -c $C -b $C -X POST "$BASE/gnome.php" -d do=decor -d slot=rug -d item=rush -o /dev/null -w '%{http_code}')" "400"
echo "== hovel.php sleeps, then sends you home"
chk "hovel.php -> TODAY" "$(to hovel.php)" "302 $BASE/gnome.php?tab=today"
chk "hovel.php?t=furnish -> FURNISH" "$(to 'hovel.php?t=furnish')" "302 $BASE/gnome.php?tab=furnish"
get 'gnome.php?tab=furnish' >/dev/null
chk "a nap from Furnish comes back to Furnish" "$(post hovel.php -d do=home_nap -d back=furnish)" "302 $BASE/gnome.php?tab=furnish"
chk "a sleep lands on TODAY" "$(post hovel.php -d do=home_sleep -d back=furnish)" "302 $BASE/gnome.php?tab=today"
echo "== news: opened once, the ! goes"
get 'index.php?news=all&tab=notes' >/dev/null
get gnome.php >/dev/null; has "the news row is read" 'class="hs-news read"'; hasnt "...no unread row" 'hs-news unread'
echo "== php errors"
grep -iE 'fatal|warning|notice|deprecated' $LOG && FAILS=$((FAILS+1)) || echo "(none)"
dbx "DELETE FROM settings WHERE name IN ('home_slim', 'game_clock_on')"
[ $FAILS -eq 0 ] && echo "home_slim: all ok" || echo "$FAILS FAILED"
[ $FAILS -eq 0 ]
