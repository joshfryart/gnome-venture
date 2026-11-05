#!/bin/bash
# Old addresses keep working (plan-polish §7.C). Next version: Today and My Gnome are one home page, gnome.php (TODAY tab by default, MY GNOME on
# ?tab=gnome, the old sub-tabs as sub-pages). Every old link to either page lands in the right place.
# Usage: tests/redirects.sh GAME PORT ROUTER   (a copy walk.sh has installed: player "sprout"; tests/ci_suites.sh does that)
HERE=$(cd "$(dirname "$0")" && pwd)
GAME=$1; PORT=${2:-8796}; ROUTER=${3:-$HERE/router.php}
BASE=http://127.0.0.1:$PORT
LOG=$(mktemp)
php -d session.save_path=/tmp -d display_errors=1 -S 127.0.0.1:$PORT -t "$GAME" "$ROUTER" >$LOG 2>&1 & PID=$!; sleep 1
trap "kill $PID 2>/dev/null" EXIT
C=$(mktemp); H=$(mktemp)
csrf() { grep -o 'name="csrf" value="[^"]*"' "$1" | head -1 | sed 's/.*value="\([^"]*\)".*/\1/'; }
get() { curl -s -c $C -b $C "$BASE/$1" -o $H -w '%{http_code}'; }
post() { local page=$1; shift; curl -s -c $C -b $C -X POST "$BASE/$page" --data-urlencode "csrf=$(csrf $H)" "$@" -o /dev/null -w '%{http_code} %{redirect_url}'; }
to() { curl -s -c $C -b $C "$BASE/$1" -o /dev/null -w '%{http_code} %{redirect_url}'; }   # status + where it goes, not followed
dbx() { php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); $p->exec($argv[1]);' "$1"; }
FAILS=0
chk() { if [ "$2" = "$3" ]; then echo "  ok   $1"; else echo "  FAIL $1 (got '$2', want '$3')"; FAILS=$((FAILS+1)); fi; }
has() { if grep -q -- "$2" $H; then echo "  ok   $1"; else echo "  FAIL $1 (no '$2')"; FAILS=$((FAILS+1)); fi; }
hasnt() { if grep -q -- "$2" $H; then echo "  FAIL $1 (found '$2')"; FAILS=$((FAILS+1)); else echo "  ok   $1"; fi; }

echo "== a visitor (not logged in)"
chk "index.php is the front page" "$(to index.php)" "200 "
chk "gnome.php asks to log in" "$(to gnome.php | cut -c1-3)" 302

dbx "UPDATE users SET tour_step = 0, tour_ask = 0 WHERE username = 'sprout'"
get login.php >/dev/null; post login.php -d username=sprout -d 'password=TestPass123!' >/dev/null
echo "== a player: the old addresses"
chk "index.php -> gnome.php" "$(to index.php)" "302 $BASE/gnome.php"
chk "index.php?today=1 -> gnome.php" "$(to 'index.php?today=1')" "302 $BASE/gnome.php"
chk "index.php?t=out -> gnome.php#todaycards" "$(to 'index.php?t=out')" "302 $BASE/gnome.php#todaycards"
chk "index.php?t=hollow -> gnome.php#hollowtoday" "$(to 'index.php?t=hollow')" "302 $BASE/gnome.php#hollowtoday"
chk "index.php?news=all still draws every post" "$(to 'index.php?news=all')" "200 "
get 'index.php?news=all' >/dev/null; has "...with the news fold" 'class="fold todayallnews" id="news" open'
for t in '' '?tab=today' '?tab=gnome' '?tab=overview' '?tab=stats' '?tab=calling' '?tab=foods' '?tab=folk' '?tab=gardens' '?tab=nonsense' '?dye=1' '?tab=stats#effects'; do
  chk "gnome.php$t is 200" "$(to "gnome.php$t")" "200 "
done
get gnome.php >/dev/null; has "gnome.php: the TODAY tab" 'id="todaycards"'; has "...with the two tabs" 'class="tabs hometabs"'; hasnt "...and not the gnome card" 'class="box gnomecard"'
get 'gnome.php?tab=nonsense' >/dev/null; has "an unknown tab shows TODAY" 'id="todaycards"'
get 'gnome.php?tab=overview' >/dev/null; has "the old Overview opens MY GNOME" 'class="box gnomecard"'; has "...with the Your gnome tiles" 'class="gvtiles"'
get 'gnome.php?dye=1' >/dev/null; has "the Dye Pot's ?dye=1 opens Stats with the dyes open" 'class="fold box dyebox" id="dyes" open'
get 'gnome.php?tab=calling' >/dev/null; has "a sub-page has a way back to MY GNOME" 'class="gvbacklink" href="/gnome.php?tab=gnome"'
chk "another gnome's id on gnome.php -> their profile" "$(to 'gnome.php?id=1')" "302 $BASE/profile.php?id=1"
get gnome.php >/dev/null
chk "the daily card's POST lands home" "$(post daily.php)" "302 $BASE/gnome.php"
get 'gnome.php?tab=gnome' >/dev/null
chk "a Heal POST comes back to MY GNOME" "$(post gnome.php -d do=heal -d what=potion -d item=0)" "302 $BASE/gnome.php?tab=gnome"
get 'gnome.php?tab=stats' >/dev/null
chk "a dye POST comes back to Stats" "$(post gnome.php -d do=dye -d hat=none)" "302 $BASE/gnome.php?tab=stats&dye=1#dyes"
get firstweek.php >/dev/null; hasnt "firstweek.php: no link to index.php?today=1" 'index.php?today=1'

echo "== the menu and the rail"
get 'gnome.php?tab=gnome' >/dev/null
chk "the menu has ONE home entry (Home -> gnome.php), no My Gnome tile" "$(grep -c 'class="navhome on" aria-current="page" href="/gnome.php"' $H)/$(grep -c 'class="navtile[^"]*" href="/gnome.php"' $H)" "1/0"
hasnt "no link to index.php?today=1 anywhere" 'index.php?today=1'
hasnt "no Go to Today rail box" 'rtoday'

echo "== tour step 7 (Meet your gnome) ticks on MY GNOME, not on landing on TODAY"
dbx "UPDATE users SET tour_step = 7, tour_ask = 0 WHERE username = 'sprout'"
get gnome.php >/dev/null
chk "landing on TODAY: still on step 7" "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query("SELECT tour_step FROM users WHERE username=\"sprout\"")->fetchColumn();')" 7
has "...and the tour card links to MY GNOME" 'href="/gnome.php?tab=gnome">See my gnome'
get 'gnome.php?tab=gnome' >/dev/null
chk "opening MY GNOME: step 8" "$(php -r '$p=new PDO("sqlite:'$GAME'/data/game.sqlite"); echo $p->query("SELECT tour_step FROM users WHERE username=\"sprout\"")->fetchColumn();')" 8
dbx "UPDATE users SET tour_step = 0, tour_ask = 0 WHERE username = 'sprout'"

echo "== php errors"
if grep -iE 'fatal|warning|notice|deprecated|parse error' $LOG; then FAILS=$((FAILS+1)); else echo "  (none)"; fi
echo; [ $FAILS -eq 0 ] && echo "ALL PASSED" || echo "$FAILS FAILED"
[ $FAILS -eq 0 ]
